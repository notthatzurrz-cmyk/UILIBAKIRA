                               
  
                                        
  
                                                                            
                                                                               
                                                                                  
                                                                             
                                                                              
                                             
  
                         
                                                                                
                                                                        
                                                                              
                                                                          
                                                                             
                                                                              
                                                                               
                                                                          
                                                                           
                                                                          
                                                                       
                                                                            
                                                                             
                                                                                 
                                                                             
                                                                            
                                                                             
                                                                               
                  
                                                                              
                                                                         
                                                                                
                                                                           
                                                                            
                                                                        
                                                                           
                                                                             
                                                                            
                                                            
                                                                          
                                                                         
                                                                   
                                                                                
                                                           
                                                                                
                                                                               
                                                  
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
                Fire = function(rself, ...)
                    for _, v in rself.Connections do
                        task.spawn(v, ...)
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

                                                                        
                
                                                                        

                                                           
local function camera()
    if not gameCamera then
        gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
    end
    return gameCamera
end

                                                                      
                                                     
local candBuf, candMag, candCount = {}, {}, 0
local DEFAULT_SORT = function(a, b)
    return a < b
end

                                                                        
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
                                                                          
                                           
    local checktick = tick() + (timeout or 10)
    local returned
    repeat
        returned = prop and obj[name] or obj:FindFirstChildOfClass(name)
        if returned or checktick < tick() then
            break
        end
                                                                      
                                               
        task.wait(0.05)
    until false
    return returned
end

                                                                        
             
  
                                                                               
                                                                           
                                                                   
                                                                        
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

entitylib.isVulnerable = function(ent)
                                                                              
                                                                               
                                                                            
                                                                                
                                                                       
    return ent.Health > 0 and not ent.Character.FindFirstChildWhichIsA(ent.Character, 'ForceField')
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
                                                                               
                                    
        if ignoreobject.FilterDescendantsInstances ~= ignorelist then
            ignoreobject.FilterDescendantsInstances = ignorelist
        end
    end
    return workspace:Raycast(origin, (position - origin), ignoreobject)
end

                                                                        
                       
  
                                                                          
                                                                              
                                                          
                                                                        
                                                                            
                                                                          
                                                                                
                                                                            
                                                    
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
                                                                        
                        candMag[candCount] = v.Target and -1 or magnitude
                    end
                end
            end
        end
    end
                                                                                
                                                          
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
                                                                                 
                                                        
                ignoreVersion = -1
                entitylib.Events.LocalAdded:Fire(entity)
            else
                entity.Targetable = entitylib.targetCheck(entity)
                for _, v in entitylib.getUpdateConnections(entity) do
                    table.insert(entity.Connections, v:Connect(function()
                        entity.Health = hum.Health
                        entity.MaxHealth = hum.MaxHealth
                                                                        
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
