-- AkiraLite/Library/Entity.lua
--
-- Entity tracking and target selection.
--
-- Optimised pass over the upstream file. The public API is unchanged (every
-- member Universal.lua touches is still here with the same shape), but the hot
-- paths - EntityMouse / EntityPosition / AllPosition / Wallcheck / isVulnerable -
-- no longer allocate per call and no longer rebuild their caches every call.
-- Those functions run inside per-frame loops in a dozen modules, so they were
-- the single most-called code in the script.
--
-- What changed, and why:
--   1. REMOVED the `while task.wait(30)` loop that loaded an Animation whose id
--      was a third-party Discord advertisement. It ran forever in every
--      generation, creating and destroying Animation/AnimationTrack instances
--      every 30 seconds, and it was a hitch source plus unsolicited spam.
--   2. REMOVED `table.clear(entitysettings)` from the end of every selector.
--      It wiped the CALLER's options table, so any caller that reused a table
--      silently got nil Range/Part/Players/NPCs on the second call - and since
--      `not entitysettings.Players` is then true, every player entity was
--      skipped and the selector returned nothing at all. Callers were also
--      forced to allocate a fresh table every call to work around it. The
--      options table is read-only input; clearing it was never useful.
--   3. Wallcheck built a fresh ignore-list (one table.insert per targetable
--      entity) on EVERY call, and it is called once per candidate inside the
--      selectors - so a single query was O(players^2) table inserts. The list is
--      now cached and only rebuilt when the targetable set actually changes.
--   4. The selectors built a table of {Entity, Magnitude} per candidate and
--      table.sort'd it, then allocated a fresh comparator per call. They now
--      fill a reusable buffer and insertion-sort it in place: zero allocations
--      per query.
--   5. EntityMouse allocated a Vector2 per entity just to measure a distance.
--      It now does the arithmetic on the projected point's X/Y directly.
--   6. isVulnerable did a FindFirstChildWhichIsA('ForceField') tree walk per
--      entity per query. That result is now cached per entity for 200ms.
--   7. targetCheck called Team:GetPlayers() AND Players:GetPlayers() - two
--      freshly allocated tables - per entity per check. The player count now
--      comes from the PlayerCount property, and the team size is cached and
--      invalidated when players join, leave or change team.
--   8. Events.Fire used task.spawn per listener per event. EntityUpdated fires
--      on every health change for every entity, so that was a coroutine per
--      listener per hit. Listeners are now called directly, each guarded by its
--      own pcall so one bad listener cannot stop the others.
--   9. waitForChildOfType spun on a bare task.wait() (every scheduler tick) for
--      up to 10 seconds. It now yields on a real interval.
--  10. getEntity was a linear scan; entities are now also indexed by character.
--  11. The camera is resolved defensively, so a nil workspace.CurrentCamera at
--      load can no longer throw from every query.
local entitylib = {
    isAlive = false,
    character = {},
    List = {},
    Connections = {},
    PlayerConnections = {},
    EntityThreads = {},
    Running = false,
    Events = setmetatable({}, {
        __index = function(self, ind)
            self[ind] = {
                Connections = {},
                Connect = function(rself, func)
                    table.insert(rself.Connections, func)
                    return {
                        Disconnect = function()
                            local rind = table.find(rself.Connections, func)
                            if rind then
                                table.remove(rself.Connections, rind)
                            end
                        end
                    }
                end,
                -- direct calls, one pcall per listener: task.spawn per listener
                -- allocated a coroutine every time an entity's health changed
                Fire = function(rself, ...)
                    local listeners = rself.Connections
                    for i = 1, #listeners do
                        pcall(listeners[i], ...)
                    end
                end,
                Destroy = function(rself)
                    table.clear(rself.Connections)
                    table.clear(rself)
                end
            }
            return self[ind]
        end
    })
}
local cloneref = cloneref or function(obj)
    return obj
end
local playersService = cloneref(game:GetService('Players'))
local inputService = cloneref(game:GetService('UserInputService'))
local lplr = playersService.LocalPlayer
local gameCamera = workspace.CurrentCamera

-- ---------------------------------------------------------------------
-- shared caches
-- ---------------------------------------------------------------------

-- the camera can be nil at load and is replaced on respawn
local function camera()
    if not gameCamera then
        gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
    end
    return gameCamera
end

-- reusable candidate buffer: filled, insertion-sorted in place, never
-- reallocated. Magnitudes live alongside in candMag.
local candBuf, candMag, candCount = {}, {}, 0
local DEFAULT_SORT = function(a, b)
    return a < b
end

-- Wallcheck's ignore list, rebuilt only when the targetable set changes
local ignoreList, ignoreCount, ignoreVersion = nil, -1, 0
local function targetableVersion()
    local list = entitylib.List
    local version = 0
    for i = 1, #list do
        local ent = list[i]
        if ent.Targetable then
            version = version + i
        end
    end
    return version
end

local function ensureIgnoreList()
    local version = targetableVersion()
    if ignoreList and ignoreVersion == version then
        return ignoreList
    end
    ignoreVersion = version
    local list = ignoreList or {}
    local index = 1
    list[index] = gameCamera
    index = index + 1
    list[index] = lplr.Character
    index = index + 1
    for i = 1, #entitylib.List do
        local ent = entitylib.List[i]
        if ent.Targetable and ent.Character then
            list[index] = ent.Character
            index = index + 1
        end
    end
    for i = index, ignoreCount do
        list[i] = nil
    end
    ignoreCount = index - 1
    ignoreList = list
    return list
end

local function getMousePosition()
    local cam = camera()
    if inputService.TouchEnabled then
        return cam.ViewportSize / 2
    end
    return inputService:GetMouseLocation()
end

local function loopClean(tbl)
    for i, v in tbl do
        if type(v) == 'table' then
            loopClean(v)
        end
        tbl[i] = nil
    end
end

local function waitForChildOfType(obj, name, timeout, prop)
    local checktick = os.clock() + (timeout or 10)
    local returned
    repeat
        returned = prop and obj[name] or obj:FindFirstChildOfClass(name)
        if returned or checktick < os.clock() then
            break
        end
        -- was a bare task.wait(), i.e. a full spin of this loop every
        -- scheduler tick for up to ten seconds
        task.wait(0.05)
    until false
    return returned
end

-- ---------------------------------------------------------------------
-- team sizes
--
-- targetCheck used to call Team:GetPlayers() and Players:GetPlayers() on every
-- check, and targetCheck runs per entity in the team-change handler and in
-- Wallcheck-adjacent code. Both allocate a fresh table every time.
-- ---------------------------------------------------------------------
local teamSizeCache, teamSizeVersion = {}, 0
local function bumpTeamVersion()
    teamSizeVersion = teamSizeVersion + 1
    table.clear(teamSizeCache)
end
local function teamSize(team)
    local cached = teamSizeCache[team]
    if cached then
        return cached
    end
    local size = #team:GetPlayers()
    teamSizeCache[team] = size
    return size
end

entitylib.targetCheck = function(ent)
    if ent.TeamCheck then
        return ent:TeamCheck()
    end
    if ent.NPC then
        return true
    end
    if not lplr.Team then
        return true
    end
    if not ent.Player.Team then
        return true
    end
    if ent.Player.Team ~= lplr.Team then
        return true
    end
    return teamSize(ent.Player.Team) == playersService.PlayerCount
end

entitylib.getUpdateConnections = function(ent)
    local hum = ent.Humanoid
    return {hum:GetPropertyChangedSignal('Health'), hum:GetPropertyChangedSignal('MaxHealth')}
end

-- The ForceField lookup is a tree walk per entity per query. It changes
-- rarely, so it is cached per entity for a fifth of a second.
local FORCEFIELD_TTL = 0.2
entitylib.isVulnerable = function(ent)
    if not ent.Health or ent.Health <= 0 then
        return false
    end
    local now = os.clock()
    local cachedAt = ent._vulnAt
    if cachedAt ~= nil and (now - cachedAt) < FORCEFIELD_TTL then
        return ent._vuln
    end
    local vulnerable = ent.Character == nil
        or ent.Character:FindFirstChildWhichIsA('ForceField') == nil
    ent._vulnAt = now
    ent._vuln = vulnerable
    return vulnerable
end

entitylib.getEntityColor = function(ent)
    ent = ent.Player
    return ent and tostring(ent.TeamColor) ~= 'White' and ent.TeamColor.Color or nil
end

entitylib.IgnoreObject = RaycastParams.new()
entitylib.IgnoreObject.RespectCanCollide = true

entitylib.Wallcheck = function(origin, position, ignoreobject)
    if typeof(ignoreobject) ~= 'Instance' then
        local ignorelist = ensureIgnoreList()
        if typeof(ignoreobject) == 'table' then
            -- explicit extras are appended into the cached list's tail
            local index = ignoreCount + 1
            for _, v in ignoreobject do
                ignorelist[index] = v
                index = index + 1
            end
            for i = index, ignoreCount do
                ignorelist[i] = nil
            end
        end
        ignoreobject = entitylib.IgnoreObject
        -- only reassign when the list actually changed: the engine copies this
        -- table on every assignment
        if ignoreobject.FilterDescendantsInstances ~= ignorelist then
            ignoreobject.FilterDescendantsInstances = ignorelist
        end
    end
    return workspace:Raycast(origin, (position - origin), ignoreobject)
end

-- ---------------------------------------------------------------------
-- shared selector core
--
-- Fills the reusable candidate buffer, sorts it by distance and hands the
-- candidates to `pick`. No allocation per query, and `entitysettings` is left
-- untouched (upstream cleared it, see note 2 at the top).
-- ---------------------------------------------------------------------
-- `requireVulnerable` reproduces upstream's per-selector filtering exactly:
-- EntityMouse accepted a target when `ignoreVulnerable` was set OR it was
-- vulnerable, EntityPosition only accepted vulnerable ones, and AllPosition did
-- not filter on vulnerability at all. The shared core has to be told which,
-- otherwise a single filter cannot serve all three.
local function selectCandidates(entitysettings, origin, project, requireVulnerable)
    local ignoreVulnerable = entitysettings.ignoreVulnerable
    candCount = 0
    local list = entitylib.List
    local wantPlayers = entitysettings.Players
    local wantNPCs = entitysettings.NPCs
    local part = entitysettings.Part
    local range = entitysettings.Range or math.huge
    local cam = project and camera()
    for i = 1, #list do
        local v = list[i]
        if v.Targetable then
            local skip = false
            if not wantPlayers and v.Player then
                skip = true
            elseif not wantNPCs and v.NPC then
                skip = true
            end
            if not skip then
                local target = v[part]
                local magnitude
                if project then
                    local point = cam:WorldToViewportPoint(target.Position)
                    if not point then
                        skip = true
                    else
                        local dx, dy = point.X - origin.X, point.Y - origin.Y
                        magnitude = math.sqrt(dx * dx + dy * dy)
                    end
                else
                    local position = target.Position
                    local dx, dy, dz = position.X - origin.X, position.Y - origin.Y, position.Z - origin.Z
                    magnitude = math.sqrt(dx * dx + dy * dy + dz * dz)
                end
                if not skip and magnitude <= range then
                    if ignoreVulnerable or not requireVulnerable or entitylib.isVulnerable(v) then
                        candCount = candCount + 1
                        candBuf[candCount] = v
                        -- a locked target always sorts first, as before
                        candMag[candCount] = v.Target and -1 or magnitude
                    end
                end
            end
        end
    end
    -- insertion sort in place: the candidate count is the player count, so this
    -- is cheaper than table.sort AND it allocates nothing
    for i = 2, candCount do
        local value, magnitude = candBuf[i], candMag[i]
        local j = i - 1
        while j >= 1 and candMag[j] > magnitude do
            candBuf[j + 1] = candBuf[j]
            candMag[j + 1] = candMag[j]
            j = j - 1
        end
        candBuf[j + 1] = value
        candMag[j + 1] = magnitude
    end
    local sorter = entitysettings.Sort
    if sorter then
        -- a custom comparator is rare (nothing in Universal.lua passes one) and
        -- needs the old shape, so it gets a throwaway table
        local ordered = {}
        for i = 1, candCount do
            ordered[i] = {Entity = candBuf[i], Magnitude = candMag[i]}
        end
        table.sort(ordered, sorter)
        for i = 1, candCount do
            candBuf[i] = ordered[i].Entity
            candMag[i] = ordered[i].Magnitude
        end
        table.clear(ordered)
    end
    return candCount
end

entitylib.EntityMouse = function(entitysettings)
    if not entitylib.isAlive then
        return
    end
    local mouseLocation = entitysettings.MouseOrigin or getMousePosition()
    if selectCandidates(entitysettings, mouseLocation, true, true) == 0 then
        return
    end
    local origin = entitysettings.Origin
    local wallcheck = entitysettings.Wallcheck
    local part = entitysettings.Part
    for i = 1, candCount do
        local ent = candBuf[i]
        local blocked = false
        if wallcheck then
            local from = origin or mouseLocation
            blocked = entitylib.Wallcheck(from, ent[part].Position, wallcheck) ~= nil
        end
        if not blocked then
            return ent
        end
    end
end

entitylib.EntityPosition = function(entitysettings)
    if not entitylib.isAlive then
        return
    end
    local origin = entitysettings.Origin or entitylib.character.HumanoidRootPart.Position
    if selectCandidates(entitysettings, origin, false, true) == 0 then
        return
    end
    local wallcheck = entitysettings.Wallcheck
    local part = entitysettings.Part
    for i = 1, candCount do
        local ent = candBuf[i]
        local blocked = false
        if wallcheck then
            blocked = entitylib.Wallcheck(origin, ent[part].Position, wallcheck) ~= nil
        end
        if not blocked then
            return ent
        end
    end
end

entitylib.AllPosition = function(entitysettings)
    local returned = {}
    if not entitylib.isAlive then
        return returned
    end
    local origin = entitysettings.Origin or entitylib.character.HumanoidRootPart.Position
    if selectCandidates(entitysettings, origin, false, false) == 0 then
        return returned
    end
    local wallcheck = entitysettings.Wallcheck
    local part = entitysettings.Part
    local limit = entitysettings.Limit or math.huge
    for i = 1, candCount do
        local ent = candBuf[i]
        local skip = false
        if wallcheck and entitylib.Wallcheck(origin, ent[part].Position, wallcheck)
            and entitylib.isVulnerable(ent) then
            skip = true
        end
        if not skip then
            returned[#returned + 1] = ent
            if #returned >= limit then
                break
            end
        end
    end
    return returned
end

-- entities indexed by character as well as by list position
local entityByChar = setmetatable({}, {__mode = 'k'})

entitylib.getEntity = function(char)
    if char == nil then
        return
    end
    local cached = entityByChar[char]
    if cached ~= nil then
        for i = 1, #entitylib.List do
            if entitylib.List[i] == cached then
                return cached, i
            end
        end
        entityByChar[char] = nil
    end
    for i, v in ipairs(entitylib.List) do
        if v.Player == char or v.Character == char then
            entityByChar[char] = v
            return v, i
        end
    end
end

entitylib.addEntity = function(char, plr, teamfunc)
    if not char then
        return
    end
    entitylib.EntityThreads[char] = task.spawn(function()
        local hum = waitForChildOfType(char, 'Humanoid', 10)
        local humrootpart = hum and waitForChildOfType(hum, 'RootPart', workspace.StreamingEnabled and 9e9 or 10, true)
        local head = char:WaitForChild('Head', 10) or humrootpart
        if hum and humrootpart then
            local entity = {
                Connections = {},
                Character = char,
                Health = hum.Health,
                Head = head,
                Humanoid = hum,
                HumanoidRootPart = humrootpart,
                HipHeight = hum.HipHeight + (humrootpart.Size.Y / 2) + (hum.RigType == Enum.HumanoidRigType.R6 and 2 or 0),
                MaxHealth = hum.MaxHealth,
                NPC = plr == nil,
                Player = plr,
                RootPart = humrootpart,
                TeamCheck = teamfunc
            }
            if plr == lplr then
                entitylib.character = entity
                entitylib.isAlive = true
                -- the local character changed, so Wallcheck's cached ignore list
                -- (which holds lplr.Character) is stale
                ignoreVersion = -1
                entitylib.Events.LocalAdded:Fire(entity)
            else
                entity.Targetable = entitylib.targetCheck(entity)
                for _, v in entitylib.getUpdateConnections(entity) do
                    table.insert(entity.Connections, v:Connect(function()
                        entity.Health = hum.Health
                        entity.MaxHealth = hum.MaxHealth
                        -- health changed, so the cached ForceField result and the
                        -- cached ignore list may both be stale
                        entity._vulnAt = nil
                        ignoreVersion = -1
                        entitylib.Events.EntityUpdated:Fire(entity)
                    end))
                end
                table.insert(entitylib.List, entity)
                entityByChar[char] = entity
                entitylib.Events.EntityAdded:Fire(entity)
            end
        end
        entitylib.EntityThreads[char] = nil
    end)
end

entitylib.removeEntity = function(char, localcheck)
    if localcheck then
        if entitylib.isAlive then
            entitylib.isAlive = false
            for _, v in entitylib.character.Connections do
                v:Disconnect()
            end
            table.clear(entitylib.character.Connections)
            entitylib.Events.LocalRemoved:Fire(entitylib.character)
        end
        ignoreVersion = -1
        return
    end
    if char then
        if entitylib.EntityThreads[char] then
            task.cancel(entitylib.EntityThreads[char])
            entitylib.EntityThreads[char] = nil
        end
        local entity, ind = entitylib.getEntity(char)
        if ind then
            for _, v in entity.Connections do
                v:Disconnect()
            end
            table.clear(entity.Connections)
            table.remove(entitylib.List, ind)
            entityByChar[entity.Character] = nil
            ignoreVersion = -1
            entitylib.Events.EntityRemoved:Fire(entity)
        end
    end
end

entitylib.refreshEntity = function(char, plr)
    entitylib.removeEntity(char)
    entitylib.addEntity(char, plr)
end

entitylib.addPlayer = function(plr)
    if plr.Character then
        entitylib.refreshEntity(plr.Character, plr)
    end
    entitylib.PlayerConnections[plr] = {
        plr.CharacterAdded:Connect(function(char)
            entitylib.refreshEntity(char, plr)
        end),
        plr.CharacterRemoving:Connect(function(char)
            entitylib.removeEntity(char, plr == lplr)
        end),
        plr:GetPropertyChangedSignal('Team'):Connect(function()
            bumpTeamVersion()
            ignoreVersion = -1
            for _, v in entitylib.List do
                if v.Targetable ~= entitylib.targetCheck(v) then
                    entitylib.refreshEntity(v.Character, v.Player)
                end
            end
            if plr == lplr then
                entitylib.start()
            else
                entitylib.refreshEntity(plr.Character, plr)
            end
        end)
    }
end

entitylib.removePlayer = function(plr)
    if entitylib.PlayerConnections[plr] then
        for _, v in entitylib.PlayerConnections[plr] do
            v:Disconnect()
        end
        table.clear(entitylib.PlayerConnections[plr])
        entitylib.PlayerConnections[plr] = nil
    end
    entitylib.removeEntity(plr)
end

entitylib.start = function()
    if entitylib.Running then
        entitylib.stop()
    end
    table.insert(entitylib.Connections, playersService.PlayerAdded:Connect(function(v)
        bumpTeamVersion()
        entitylib.addPlayer(v)
    end))
    table.insert(entitylib.Connections, playersService.PlayerRemoving:Connect(function(v)
        bumpTeamVersion()
        entitylib.removePlayer(v)
    end))
    for _, v in playersService:GetPlayers() do
        entitylib.addPlayer(v)
    end
    table.insert(entitylib.Connections, workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
        gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
        ignoreVersion = -1
    end))
    entitylib.Running = true
end

entitylib.stop = function()
    for _, v in entitylib.Connections do
        v:Disconnect()
    end
    for _, v in entitylib.PlayerConnections do
        for _, v2 in v do
            v2:Disconnect()
        end
        table.clear(v)
    end
    entitylib.removeEntity(nil, true)
    local cloned = table.clone(entitylib.List)
    for _, v in cloned do
        entitylib.removeEntity(v.Character)
    end
    for _, v in entitylib.EntityThreads do
        task.cancel(v)
    end
    table.clear(entitylib.PlayerConnections)
    table.clear(entitylib.EntityThreads)
    table.clear(entitylib.Connections)
    table.clear(cloned)
    table.clear(entityByChar)
    table.clear(teamSizeCache)
    entitylib.List = {}
    candCount = 0
    ignoreList, ignoreCount, ignoreVersion = nil, -1, 0
    entitylib.Running = false
end

entitylib.kill = function()
    if entitylib.Running then
        entitylib.stop()
    end
    for _, v in entitylib.Events do
        v:Destroy()
    end
    entitylib.IgnoreObject:Destroy()
    loopClean(entitylib)
end

entitylib.refresh = function()
    local cloned = table.clone(entitylib.List)
    for _, v in cloned do
        entitylib.refreshEntity(v.Character, v.Player)
    end
    table.clear(cloned)
end

entitylib.start()
return entitylib
