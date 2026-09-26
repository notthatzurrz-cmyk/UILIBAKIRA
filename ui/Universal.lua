-- Перехвачено из: loadstring() call / AkiraLite/Games/Universal.lua
local AkiraLite = shared.AkiraLite
local cloneref = cloneref or function(obj)
    return obj
end
if identifyexecutor then
    if table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
        getgenv().setthreadidentity = nil
    end
end
local Players = cloneref(game:GetService('Players'))
local TweenService = cloneref(game:GetService('TweenService'))
local UserInputService = cloneref(game:GetService('UserInputService'))
local TextService = cloneref(game:GetService('TextService'))
local GuiService = cloneref(game:GetService('GuiService'))
local RunService = cloneref(game:GetService('RunService'))
local HttpService = cloneref(game:GetService('HttpService'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local GroupService = cloneref(game:GetService('GroupService'))
local MarketplaceService = cloneref(game:GetService('MarketplaceService'))
local TeleportService = cloneref(game:GetService('TeleportService'))
local ContextService = cloneref(game:GetService('ContextActionService'))
local Lighting = cloneref(game:GetService("Lighting"))
local gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
local lplr = Players.LocalPlayer
local assetfunction = getcustomasset
local featureStatus = {
    Total = 0,
    Registered = 0,
    Failed = 0,
    Errors = {}
}
local runBudget = 0
local runSlice = 0.06
local run = function(func, label)
    if type(func) ~= "function" then
        return false
    end
    local info
    if type(debug) == "table" and type(debug.getinfo) == "function" then
        info = debug.getinfo(2, "Sl")
    end
    local name = label or (info and info.currentline and ("line " .. tostring(info.currentline))) or "anonymous"
    local sliceStart = os.clock()
    local ok, err = xpcall(func, function(message)
        return tostring(message)
    end)
    runBudget += os.clock() - sliceStart
    if runBudget >= runSlice then
        runBudget = 0
        pcall(task.wait)
    end
    featureStatus.Total += 1
    if ok then
        featureStatus.Registered += 1
    else
        featureStatus.Failed += 1
        local message = "[Universal] feature " .. tostring(name) .. " failed: " .. tostring(err)
        table.insert(featureStatus.Errors, {
            Name = tostring(name),
            Error = tostring(err)
        })
        if #featureStatus.Errors > 32 then
            table.remove(featureStatus.Errors, 1)
        end
        pcall(warn, message)
    end
    return ok
end

local akiraT0 = os.clock()
local function akiraMark(name)
    if type(shared) == "table" and type(shared.AkiraLiteProfile) == "table" then
        table.insert(shared.AkiraLiteProfile, {name, os.clock() - akiraT0})
    end
end

local function getPlayerIdentity(player, display)
    if type(AkiraLite.GetIdentity) == "function" then
        local ok, username, displayName = pcall(AkiraLite.GetIdentity, AkiraLite, player, false)
        if ok and type(username) == "string" then
            return display and (type(displayName) == "string" and displayName or username) or username, username, type(displayName) == "string" and displayName or username
        end
    end
    local username = player and player.Name or ""
    local displayName = player and player.DisplayName or username
    return display and displayName or username, username, displayName
end
local function getLocalIdentity(display)
    return getPlayerIdentity(lplr, display)
end
local akiraPlaySound
local akiraGetLocalFighter
local akiraGetEquippedItem
local akiraItemValue
local akiraItemDataTables
local akiraOverrideFields
local akiraRestoreSpec
local akiraRankLadder = {
    {Name = "Unranked", Elo = 0},
    {Name = "Bronze", Elo = 400},
    {Name = "Silver", Elo = 700},
    {Name = "Gold", Elo = 1000},
    {Name = "Platinum", Elo = 1400},
    {Name = "Diamond", Elo = 1800},
    {Name = "Master", Elo = 2200},
    {Name = "Grandmaster", Elo = 2600}
}
local function akiraRankName(player)
    local elo = tonumber(player and player:GetAttribute("DisplayELO")) or tonumber(player and player:GetAttribute("Elo")) or nil
    if not elo then
        return "Unranked"
    end
    local name = "Unranked"
    for _, entry in ipairs(akiraRankLadder) do
        if elo >= entry.Elo then
            name = entry.Name
        end
    end
    return name
end
local function akiraWinStreak(player)
    return math.max(0, math.floor(tonumber(player and player:GetAttribute("StatisticDuelsWinStreak")) or 0))
end
local function akiraIsDeflecting(player)
    local controller = akiraGetLocalFighter()
    local objects = controller and rawget(controller, "Objects") or nil
    if type(objects) ~= "table" then
        return false
    end
    for _, fighter in pairs(objects) do
        if type(fighter) == "table" and rawget(fighter, "Player") == player then
            local equipped = rawget(fighter, "EquippedItem")
            if type(equipped) == "table" then
                local viewModel = rawget(equipped, "ViewModel")
                local modelName = ""
                if type(viewModel) == "table" then
                    modelName = tostring(rawget(viewModel, "Name") or "")
                elseif typeof(viewModel) == "Instance" then
                    modelName = viewModel.Name
                end
                if modelName:lower():find("katana", 1, true) then
                    -- Only an ACTIVE katana swing counts as deflecting. Returning
                    -- true unconditionally made every katana holder permanently
                    -- untargetable while "Avoid Deflecting" was on.
                    local cooldown = rawget(equipped, "_attack_cooldown")
                    if type(cooldown) == "number" and cooldown > os.clock() then
                        return true
                    end
                    return false
                end
            end
            return false
        end
    end
    return false
end
-- Immunity detection.
--
-- Rivals exposes "cannot be damaged" in a few different places depending on the
-- game mode, so this checks the cheap sources first (attributes, which cost
-- almost nothing) and only then falls back to scanning the remote fighter state
-- table for an immunity-style flag. The scan is rate limited per player because
-- it walks a table.
local _immuneCache = {}
local _invincibilityState = {}
local _invincibilityWatched = {}
local IMMUNE_SCAN_INTERVAL = 0.25

local function attributeSaysImmune(instance)
    -- typeof(), not type(): type() yields "userdata" for every instance, so the
    -- old `type(instance) ~= "Instance"` guard always returned early and the
    -- whole attribute-based immunity check never ran.
    if typeof(instance) ~= "Instance" then
        return false
    end
    if instance:GetAttribute("Immune") == true
        or instance:GetAttribute("Invulnerable") == true
        or instance:GetAttribute("Invulnerability") == true
        or instance:GetAttribute("God") == true
        or instance:GetAttribute("GodMode") == true
        or instance:GetAttribute("Intangible") == true
        or instance:GetAttribute("Untargetable") == true then
        return true
    end
    -- CanBeDamaged = false is Roblox's own "this thing is immune" flag
    if instance:GetAttribute("CanBeDamaged") == false then
        return true
    end
    return false
end

local function scanImmuneFields(tbl, depth)
    if type(tbl) ~= "table" or depth > 1 then
        return false
    end
    local now = os.clock()
    for key, value in pairs(tbl) do
        if type(key) == "string" and type(value) ~= "table" and type(value) ~= "function" then
            local lower = key:lower()
            if lower:find("immun", 1, true)
                or lower:find("invulner", 1, true)
                or lower:find("untargetab", 1, true)
                or lower:find("intangib", 1, true) then
                -- a boolean flag, or a cooldown-style timestamp still in the future
                if value == true or (type(value) == "number" and value > now) then
                    return true
                end
            end
        end
    end
    return false
end

local function akiraIsImmune(player)
    if not player then
        return false
    end
    if attributeSaysImmune(player) then
        return true
    end
    local character = player.Character
    if attributeSaysImmune(character) then
        return true
    end
    if typeof(character) == "Instance" then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if attributeSaysImmune(humanoid) then
            return true
        end
    end
    -- fall back to the replicated fighter state, rate limited per player
    local now = os.clock()
    local cached = _immuneCache[player]
    if cached and (now - cached.at) < IMMUNE_SCAN_INTERVAL then
        return cached.value
    end
    local value = false
    local controller = akiraGetLocalFighter()
    local objects = controller and rawget(controller, "Objects") or nil
    if type(objects) == "table" then
        for _, fighter in pairs(objects) do
            if type(fighter) == "table" and rawget(fighter, "Player") == player then
                if scanImmuneFields(fighter, 0) then
                    value = true
                else
                    local equipped = rawget(fighter, "EquippedItem")
                    if type(equipped) == "table" and scanImmuneFields(equipped, 0) then
                        value = true
                    end
                end
                -- Live inspection of FighterController.Objects showed the game
                -- signals immunity through a per-fighter "InvincibilityChanged"
                -- signal rather than any Player/Character attribute, so the
                -- attribute checks above never fired for a real invulnerable
                -- target. Observe that signal and cache the last state per player.
                local signal = rawget(fighter, "InvincibilityChanged")
                local signalType = typeof(signal)
                if signalType == "Instance" then
                    if not _invincibilityWatched[signal] then
                        _invincibilityWatched[signal] = true
                        local okConnect, err = pcall(function()
                            signal:Connect(function(...)
                                local a = select(1, ...)
                                local newValue
                                if type(a) == "boolean" then
                                    newValue = a
                                elseif type(a) == "number" then
                                    newValue = a > 0
                                else
                                    -- no payload: treat the event itself as the
                                    -- state change and toggle
                                    local prev = _invincibilityState[player]
                                    newValue = not (prev == true)
                                end
                                _invincibilityState[player] = {value = newValue, at = os.clock()}
                            end)
                        end)
                        if not okConnect then
                            _invincibilityWatched[signal] = nil
                            pcall(function()
                                _invincibilityWatchError = tostring(err)
                            end)
                        end
                    end
                end
                local observed = _invincibilityState[player]
                if observed and (now - observed.at) < 3 then
                    value = value or observed.value == true
                end
                break
            end
        end
    end
    _immuneCache[player] = {at = now, value = value}
    return value
end

-- ---------------------------------------------------------------------
-- Generation guard.
--
-- Re-running the script used to stack live state: Entity.lua is re-loaded on
-- every run and its connections (PlayerAdded, per-player CharacterAdded, the
-- camera signal) live in `entitylib.Connections`, which the library's Uninject
-- never touches because it only knows about `w.Connections`. Every extra run
-- therefore left another entity tracker, another set of player listeners and
-- another 30-second animation loop running forever, and none of them show up
-- in the perf reporter's "enabled modules" list.
--
-- The previous generation is now disconnected before this one starts, so the
-- number of live listeners depends on how many copies are running (one) and not
-- on how many times the script has been executed.
-- ---------------------------------------------------------------------
do
    local registry = rawget(shared, "__akiraGeneration")
    if type(registry) == "table" then
        local function disconnectAll(list)
            if type(list) ~= "table" then
                return
            end
            for i = 1, #list do
                pcall(function()
                    list[i]:Disconnect()
                end)
            end
            table.clear(list)
        end
        pcall(disconnectAll, registry.connections)
        pcall(disconnectAll, registry.entityConnections)
    end
    shared.__akiraGeneration = {connections = {}, entityConnections = {}}
end

local AkiraLiteFile = shared.AkiraLiteFile
local entitylib = AkiraLiteFile.loadfile("AkiraLite/Library/Entity.lua")
local prediction = AkiraLiteFile.loadfile("AkiraLite/Library/Prediction.lua")
-- hand this generation's entity listeners to the guard so the NEXT run can
-- disconnect them
do
    local registry = rawget(shared, "__akiraGeneration")
    local source = entitylib and rawget(entitylib, "Connections")
    if type(registry) == "table" and type(source) == "table" then
        for i = 1, #source do
            registry.entityConnections[i] = source[i]
        end
    end
end
local getfontsize = AkiraLite.Libraries.getfontsize
local addGradient = AkiraLite.Libraries.addGradient
local Targetinfo = AkiraLite.Libraries.Targetinfo
-- Luraph's performance guidance: cache repeated deep lookups. These were read
-- as AkiraLite.Libraries.uipallet.<x> from inside per-frame code, which under
-- the VM turns every property read into a chain of emulated instructions.
local uipalette = AkiraLite.Libraries.uipallet
local uipalletFont = uipalette and uipalette.Font
AkiraLite.Libraries.entitylib = entitylib
AkiraLite.Libraries.prediction = prediction
AkiraLite.Libraries.auraanims = {
    Normal = {
        {
            CFrame = CFrame.new(- 0.17, - 0.14, - 0.12) * CFrame.Angles(math.rad(- 53), math.rad(50), math.rad(- 64)),
            Time = 0.1
        },
        {
            CFrame = CFrame.new(- 0.55, - 0.59, - 0.1) * CFrame.Angles(math.rad(- 161), math.rad(54), math.rad(- 6)),
            Time = 0.08
        },
        {
            CFrame = CFrame.new(- 0.62, - 0.68, - 0.07) * CFrame.Angles(math.rad(- 167), math.rad(47), math.rad(- 1)),
            Time = 0.03
        },
        {
            CFrame = CFrame.new(- 0.56, - 0.86, 0.23) * CFrame.Angles(math.rad(- 167), math.rad(49), math.rad(- 1)),
            Time = 0.03
        }
    },
    Random = {},
    ['Horizontal Spin'] = {
        {
            CFrame = CFrame.Angles(math.rad(- 10), math.rad(- 90), math.rad(- 80)),
            Time = 0.12
        },
        {
            CFrame = CFrame.Angles(math.rad(- 10), math.rad(180), math.rad(- 80)),
            Time = 0.12
        },
        {
            CFrame = CFrame.Angles(math.rad(- 10), math.rad(90), math.rad(- 80)),
            Time = 0.12
        },
        {
            CFrame = CFrame.Angles(math.rad(- 10), 0, math.rad(- 80)),
            Time = 0.12
        }
    },
    ['Vertical Spin'] = {
        {
            CFrame = CFrame.Angles(math.rad(- 90), 0, math.rad(15)),
            Time = 0.12
        },
        {
            CFrame = CFrame.Angles(math.rad(180), 0, math.rad(15)),
            Time = 0.12
        },
        {
            CFrame = CFrame.Angles(math.rad(90), 0, math.rad(15)),
            Time = 0.12
        },
        {
            CFrame = CFrame.Angles(0, 0, math.rad(15)),
            Time = 0.12
        }
    },
    Exhibition = {
        {
            CFrame = CFrame.new(0.69, - 0.7, 0.6) * CFrame.Angles(math.rad(- 30), math.rad(50), math.rad(- 90)),
            Time = 0.1
        },
        {
            CFrame = CFrame.new(0.7, - 0.71, 0.59) * CFrame.Angles(math.rad(- 84), math.rad(50), math.rad(- 38)),
            Time = 0.2
        }
    },
    ['Exhibition Old'] = {
        {
            CFrame = CFrame.new(0.69, - 0.7, 0.6) * CFrame.Angles(math.rad(- 30), math.rad(50), math.rad(- 90)),
            Time = 0.15
        },
        {
            CFrame = CFrame.new(0.69, - 0.7, 0.6) * CFrame.Angles(math.rad(- 30), math.rad(50), math.rad(- 90)),
            Time = 0.05
        },
        {
            CFrame = CFrame.new(0.7, - 0.71, 0.59) * CFrame.Angles(math.rad(- 84), math.rad(50), math.rad(- 38)),
            Time = 0.1
        },
        {
            CFrame = CFrame.new(0.7, - 0.71, 0.59) * CFrame.Angles(math.rad(- 84), math.rad(50), math.rad(- 38)),
            Time = 0.05
        },
        {
            CFrame = CFrame.new(0.63, - 0.1, 1.37) * CFrame.Angles(math.rad(- 84), math.rad(50), math.rad(- 38)),
            Time = 0.15
        }
    }
}
local function calculateMoveVector(vec)
    local c, s
    local _, _, _, R00, R01, R02, _, _, R12, _, _, R22 = gameCamera.CFrame:GetComponents()
    if R12 < 1 and R12 > - 1 then
        c = R22
        s = R02
    else
        c = R00
        s = - R01 * math.sign(R12)
    end
    vec = vector.create((c * vec.X + s * vec.Z), 0, (c * vec.Z - s * vec.X)) / math.sqrt(c * c + s * s)
    return vec.Unit == vec.Unit and vec.Unit or vector.zero
end
-- canClick() costs two GetGuiObjectsAtPosition calls (plus a FindFirstAncestorOfClass
-- per hit object) and used to run on EVERY scheduler tick from the Trigger Bot and
-- Silent Aim spin loops. GUI state does not change fast enough to need that, so the
-- answer is cached for a short window.
local canClickCache, canClickCachedAt = true, 0
local function canClick()
    local now = os.clock()
    if now - canClickCachedAt < 0.03 then
        return canClickCache
    end
    local result = true
    local mousepos = (UserInputService:GetMouseLocation() - GuiService:GetGuiInset())
    for _, v in lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y) do
        local obj = v:FindFirstAncestorOfClass('ScreenGui')
        if v.Active and v.Visible and obj and obj.Enabled then
            result = false
            break
        end
    end
    if result then
        for _, v in CoreGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y) do
            local obj = v:FindFirstAncestorOfClass('ScreenGui')
            if v.Active and v.Visible and obj and obj.Enabled then
                result = false
                break
            end
        end
    end
    if result then
        result = (not AkiraLite.ClickGuiStatus) and (not UserInputService:GetFocusedTextBox())
    end
    canClickCache = result
    canClickCachedAt = now
    return result
end
local function getTableSize(tab)
    local ind = 0
    for _ in tab do
        ind += 1
    end
    return ind
end
local function removeTags(str)
    str = str:gsub('<br%s*/>', '\n')
    return (str:gsub('<[^<>]->', ''))
end
local function addBlur(parent)
    local blur = Instance.new('ImageLabel')
    blur.Name = 'Blur'
    blur.Size = UDim2.new(1, 89, 1, 52)
    blur.Position = UDim2.fromOffset(- 48, - 31)
    blur.BackgroundTransparency = 1
    blur.Image = "rbxassetid://74663567791967"
    blur.ScaleType = Enum.ScaleType.Slice
    blur.SliceCenter = Rect.new(52, 31, 261, 502)
    blur.ZIndex = - 100
    blur.Parent = parent
    return blur
end
local function addRoundedShadow(parent)
    local blur = Instance.new('ImageLabel')
    blur.Name = 'Shadow'
    blur.Size = UDim2.new(1, 18, 1, 18)
    blur.AnchorPoint = Vector2.new(0.5, 0.5)
    blur.Position = UDim2.fromScale(0.5, 0.5)
    -- blur.ImageColor3 = Color3.fromRGB(12, 12, 12)
    blur.BackgroundTransparency
    = 1
    blur.Image = "rbxassetid://85528155206269"
    blur.ScaleType = Enum.ScaleType.Slice
    blur.ImageTransparency = 0.5
    blur.SliceCenter = Rect.new(36, 36, 900, 50)
    blur.SliceScale = 0.5
    blur.ZIndex = - 100
    blur.Parent = parent
    return blur
end
local function addCorner(parent, radius)
    local corner = Instance.new('UICorner')
    corner.CornerRadius = radius or UDim.new(0, 5)
    corner.Parent = parent
    return corner
end
local frictionTable, oldfrict = {}, {}
local function updateVelocity()
    if getTableSize(frictionTable) > 0 then
        if entitylib.isAlive then
            for _, v in entitylib.character.Character:GetChildren() do
                if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' and not oldfrict[v] then
                    oldfrict[v] = v.CustomPhysicalProperties or 'none'
                    v.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.2, 0.5, 1, 1)
                end
            end
        end
    else
        for i, v in oldfrict do
            i.CustomPhysicalProperties = v ~= 'none' and v or nil
        end
        table.clear(oldfrict)
    end
end
local Spider = {
    Enabled = false
}
local Phase = {
    Enabled = false
}
local SpiderShift = false

-- ---------------------------------------------------------------------
-- World modules removed for performance.
--
-- Weather, fog, skybox, ambience, post-processing, storm and colour
-- grading all mutate Lighting / Terrain / the camera every single frame and
-- were the heaviest per-frame cost in this script by a wide margin. Only the
-- Shader module (Other tab) is kept.
--
-- The catalog hands out inert stubs, so the settings variables in those
-- blocks still resolve and nothing errors, but no World module is ever
-- registered, enabled, or ticked. Default every control to its neutral value
-- so the surrounding "if not X.Enabled" branches behave as if it is off.
--
-- This lives at FILE scope on purpose: it used to be a local inside the first
-- World block, so the Storm and Color Grading blocks - which are separate
-- run() blocks further down - resolved it as a nil GLOBAL and died with
-- "attempt to call a nil value" the moment they tried to stub their module.
-- ---------------------------------------------------------------------
local function __worldStub(opts)
    opts = type(opts) == "table" and opts or {}
    local function control(o, kind)
        o = type(o) == "table" and o or {}
        local value = o.Default
        if value == nil then
            if kind == "dropdown" then
                local list = o.List
                value = (type(list) == "table" and list[1]) or nil
            elseif kind == "toggle" then
                value = false
            else
                value = 0
            end
        end
        local frame = Instance.new("Frame")
        frame.Name = "DisabledControl"
        frame.Size = UDim2.fromOffset(0, 0)
        frame.BackgroundTransparency = 1
        frame.Visible = false
        return {
            Name = o.Name,
            Value = value,
            Min = o.Min,
            Max = o.Max,
            Decimal = o.Decimal,
            Darker = o.Darker,
            Enabled = kind == "toggle" and value == true or kind ~= "toggle",
            Frame = frame,
            SetValue = function() end,
            GetValue = function() end,
            Set = function() end,
            Update = function() end,
        }
    end
    return {
        Name = opts.Name or "World",
        Enabled = false,
        Clean = function() end,
        Delete = function() end,
        SetEnabled = function() end,
        Toggle = function() end,
        AddToggle = function(_, o) return control(o, "toggle") end,
        AddSlider = function(_, o) return control(o, "slider") end,
        AddDropdown = function(_, o) return control(o, "dropdown") end,
        AddColorPicker = function(_, o) return control(o, "color") end,
        AddTextInput = function(_, o) return control(o, "text") end,
        AddLabel = function(_, o) return control(o, "label") end,
    }
end

    akiraMark("block1:start")
run(function()
    AkiraLite:Clean(entitylib.Events.LocalAdded:Connect(updateVelocity))
    AkiraLite:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
        gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
    end))
end)
    akiraMark("block1:done")
-- Viewmodel offset, installed at FILE scope rather than from the module's enable
-- path.
--
-- Proven live, in this order:
--   * the game rewrites the viewmodel root CFrame every frame, so a write from a
--     RenderStepped connection is discarded microseconds later,
--   * RunService:BindToRenderStep does not exist in this executor,
--   * the per-frame positioning pass calls Update/SetParent on the viewmodel
--     INSTANCE hundreds of times a second, and wrapping those instance methods
--     does stick,
--   * the module's own enable path could not be relied on to install the hook
--     (its Function is not even stored on the module by the upstream library).
-- So: wrap the instance methods, and poll cheaply from outside the module.
local AKIRA_VM_OFFSET = {x = 0, y = 0, z = 0, hooked = setmetatable({}, {__mode = "k"})}
local AKIRA_VM_SOURCE = nil

local function installViewModelOffsetHook()
    local lplr = game:GetService("Players").LocalPlayer
    if not lplr then
        return
    end
    local okCtrl, controller = pcall(function()
        return require(lplr.PlayerScripts.Controllers.FighterController)
    end)
    if not okCtrl or type(controller) ~= "table" then
        return
    end
    local fighter = rawget(controller, "LocalFighter")
    local item = fighter and rawget(fighter, "EquippedItem")
    if type(item) ~= "table" then
        return
    end
    local vm = rawget(item, "ViewModel") or rawget(item, "_viewModel")
    if type(vm) ~= "table" or AKIRA_VM_OFFSET.hooked[vm] then
        return
    end
    AKIRA_VM_OFFSET.hooked[vm] = true
    for _, method in ipairs({"Update", "SetParent", "PivotTo", "_UpdateWrap"}) do
        local original = rawget(vm, method)
        if type(original) == "function" then
            rawset(vm, method, function(...)
                local packed = table.pack and table.pack(original(...)) or nil
                -- applied as the last step, on the transform the game just wrote
                pcall(function()
                    local ox, oy, oz = AKIRA_VM_OFFSET.x, AKIRA_VM_OFFSET.y, AKIRA_VM_OFFSET.z
                    if ox == 0 and oy == 0 and oz == 0 then
                        return
                    end
                    local model = rawget(vm, "Model") or rawget(vm, "_model")
                    local part = model and model.PrimaryPart
                    if part and part:IsA("BasePart") then
                        part.CFrame = part.CFrame * CFrame.new(ox, oy, oz)
                    end
                end)
                if packed then
                    return table.unpack(packed, 1, packed.n)
                end
                return nil
            end)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.25)
        local source = AKIRA_VM_SOURCE
        if type(source) == "function" then
            local ok, toggle, ox, oy, oz = pcall(source)
            if ok then
                if toggle and toggle.Enabled then
                    AKIRA_VM_OFFSET.x = tonumber(ox) or 0
                    AKIRA_VM_OFFSET.y = tonumber(oy) or 0
                    AKIRA_VM_OFFSET.z = tonumber(oz) or 0
                    installViewModelOffsetHook()
                else
                    AKIRA_VM_OFFSET.x = 0
                    AKIRA_VM_OFFSET.y = 0
                    AKIRA_VM_OFFSET.z = 0
                end
            end
        end
    end
end)

local akiraPerfWatchEnabled = true

-- Shared "who is the script currently aiming at" registry.
--
-- The ragebot, silent aim and aim assist each resolve their own target inside
-- their own closure, so nothing outside could see it. The crosshair used to
-- consult only AkiraLite.Rage / RageBridge and then fall back to whatever was
-- under the mouse, and its Follow Target toggles defaulted to OFF - so it never
-- followed anything at all. Every system now publishes here and the crosshair
-- reads all of them, newest first.
local AKIRA_TARGET_SOURCES = {"Ragebot", "AimAssist", "SilentAim"}
local function publishActiveTarget(source, entityOrPlayer, part)
    if type(AkiraLite) ~= "table" then
        return
    end
    if type(AkiraLite.Targets) ~= "table" then
        AkiraLite.Targets = {}
    end
    local player
    local head
    if typeof(entityOrPlayer) == "Instance" and entityOrPlayer:IsA("Player") then
        player = entityOrPlayer
        head = part
    elseif type(entityOrPlayer) == "table" then
        player = rawget(entityOrPlayer, "Player")
        head = rawget(entityOrPlayer, "Head") or rawget(entityOrPlayer, "HitboxPart") or part
    end
    if player == nil or typeof(player) ~= "Instance" then
        AkiraLite.Targets[source] = nil
        return
    end
    if head == nil or typeof(head) ~= "Instance" then
        head = nil
    end
    -- the entry table is reused per source: publishActiveTarget runs every frame
    -- from the ragebot, aim assist and silent aim, and a fresh {Player,Head,At}
    -- table each time was three allocations per frame for nothing
    local targets = AkiraLite.Targets
    local entry = targets[source]
    if type(entry) ~= "table" then
        entry = {Player = nil, Head = nil, At = 0}
        targets[source] = entry
    end
    entry.Player = player
    entry.Head = head
    entry.At = os.clock()
end

local function clearActiveTarget(source)
    if type(AkiraLite) == "table" and type(AkiraLite.Targets) == "table" then
        AkiraLite.Targets[source] = nil
    end
end

local function akiraPerfWatch()
    if shared and shared.AkiraLitePerfWatch then
        return
    end
    shared.AkiraLitePerfWatch = true

    -- Continuous low-FPS reporter, and the ONLY always-on heartbeat the script
    -- creates. There used to be a second, 5-second one-shot probe here as well,
    -- so every load briefly ran two per-frame callbacks to measure the same
    -- thing; the loop below already covers the first five seconds and keeps
    -- reporting afterwards.
    if not akiraPerfWatchEnabled then
        return
    end
    task.spawn(function()
        local RunService = cloneref(game:GetService("RunService"))
        local frames = 0
        local worstFrame = 0
        local windowStart = os.clock()
        local reported = 0
        local connection = RunService.Heartbeat:Connect(function(deltaTime)
            frames += 1
            if type(deltaTime) == "number" and deltaTime > worstFrame then
                worstFrame = deltaTime
            end
        end)
        while shared and shared.AkiraLite do
            task.wait(1)
            local elapsed = os.clock() - windowStart
            if elapsed < 1 then
                continue
            end
            local fps = frames / elapsed
            if type(shared) == "table" then
                shared.AkiraLitePerf = {
                    Frames = frames,
                    Seconds = elapsed,
                    FPS = fps,
                    WorstFrame = worstFrame,
                }
            end
            -- 50, not 30: sitting at exactly 30fps is still terrible and the
            -- reporter stayed silent, which made it useless for the one job it
            -- exists for.
            if fps < 50 and reported < 8 then
                reported += 1
                local enabled = {}
                local modules = shared.AkiraLite and shared.AkiraLite.Modules
                local moduleCount = 0
                if type(modules) == "table" then
                    for name, module in pairs(modules) do
                        moduleCount += 1
                        if type(module) == "table" and module.Enabled then
                            enabled[#enabled + 1] = tostring(name)
                        end
                    end
                end
                table.sort(enabled)
                -- "Enabled: nothing" used to be the whole diagnosis, which is
                -- useless: a module can be off while its connections are still
                -- live, and re-runs used to leave whole generations behind. Report
                -- the things that actually distinguish those cases.
                local registry = rawget(shared, "__akiraGeneration")
                local tracked = 0
                local entityTracked = 0
                if type(registry) == "table" then
                    tracked = type(registry.connections) == "table" and #registry.connections or 0
                    entityTracked = type(registry.entityConnections) == "table" and #registry.entityConnections or 0
                end
                local liveEntity = 0
                local entity = AkiraLite.Libraries and AkiraLite.Libraries.entitylib
                if type(entity) == "table" and type(rawget(entity, "Connections")) == "table" then
                    liveEntity = #rawget(entity, "Connections")
                end
                local ourGuis = 0
                if type(shared.AkiraLite) == "table" and shared.AkiraLite.MainScreenGui then
                    ourGuis = 1
                end
                pcall(warn, string.format(
                    "[AkiraLite] LOW FPS %.0f (worst frame %.0fms). Enabled: %s | modules=%d gui=%d entityConns=%d genTracked=%d genEntity=%d",
                    fps, worstFrame * 1000,
                    #enabled > 0 and table.concat(enabled, ", ") or "nothing",
                    moduleCount, ourGuis, liveEntity, tracked, entityTracked))
            end
            frames = 0
            worstFrame = 0
            windowStart = os.clock()
        end
        if connection then
            connection:Disconnect()
        end
    end)
end
akiraMark("universal:pre-entitylib")
entitylib.start()
akiraMark("universal:entitylib")
akiraMark("universal:pre-gameload")
if not game:IsLoaded() then
    pcall(function()
        local finished = false
        task.spawn(function()
            game.Loaded:Wait()
            finished = true
        end)
        local deadline = os.clock() + 6
        while not finished and os.clock() < deadline do
            task.wait(0.1)
        end
    end)
end
akiraMark("universal:post-gameloaded")
akiraPerfWatch()
local TargetStrafeVector
    akiraMark("block2:start")
run(function()
    local AimAssist
    local Targets
    local Part
    local FOV
    local Speed
    local CircleColor
    local CircleTransparency
    local CircleFilled
    local CircleObject
    local CircleOutlineObject
    local CircleOutlineToggle
    local CircleOutline
    local CircleRainbow
    local CircleRainbowSpeed
    local CircleColorA
    local CircleColorB
    local CircleFlowSpeed
    local CircleFollow
    local CircleAlways
    local CircleRender
    -- hoisted: this was Color3.new() (a fresh Color3) on every rendered frame
    local CIRCLE_OUTLINE_BLACK = Color3.new()
    -- 20Hz cache for the circle's follow target. It is a second full entity scan
    -- in the same frame as the aim lookup, at 4x the range.
    local circleTarget, circleTargetAt = nil, 0
    local circleOptions = {Range = 400, Part = 'RootPart', Players = true, NPCs = false, Wallcheck = false, Origin = Vector3.zero}
    local RightClick
    local ShowTarget
    local Flick
    local AlwaysOn
    local TargetLock
    local PingComp
    local PingFactor
    local WallAim
    local IgnoreDeflecting
    local moveConst = Vector2.new(1, 0.77) * math.rad(0.5)
    local function wrapAngle(num)
        num = num % math.pi
        num -= num >= (math.pi / 2) and math.pi or 0
        num += num < - (math.pi / 2) and math.pi or 0
        return num
    end
    AimAssist = AkiraLite.Catalogs.Combat:AddModule({
        Name = 'Aim Assist',
        Function = function(callback)
            if CircleObject then
                CircleObject.Visible = callback
            end
            if callback then
                local ent
                local rightClicked = not RightClick.Enabled or UserInputService:IsMouseButtonPressed(1)
                local function targetUsable(target)
                    if not target or not target.Parent then
                        return false
                    end
                    local hum = target:FindFirstChildOfClass('Humanoid')
                    if hum and hum.Health <= 0 then
                        return false
                    end
                    return target:FindFirstChild(Part.Value) ~= nil
                end
                local function aimAt(target, dt)
                    if not targetUsable(target) then
                        return
                    end
                    if IgnoreDeflecting and IgnoreDeflecting.Enabled and akiraIsDeflecting(target) then
                        return
                    end
                    local part = target[Part.Value]
                    local aimPoint = part.Position
                    if PingComp and PingComp.Enabled then
                        local velocity = part.AssemblyLinearVelocity or Vector3.zero
                        local owner = target:FindFirstChildOfClass('Player') or Players:GetPlayerFromCharacter(target)
                        local ping = (owner and owner:GetNetworkPing() * 1000) or 60
                        aimPoint += velocity * ((ping / 1000) * (PingFactor and PingFactor.Value or 0.5))
                    end
                    local facing = gameCamera.CFrame.LookVector
                    local new = (aimPoint - gameCamera.CFrame.Position).Unit
                    new = new == new and new or Vector3.zero
                    if new == Vector3.zero then
                        return
                    end
                    if ShowTarget.Enabled then
                        Targetinfo.Targets[target] = tick() + 1
                    end
                    local diffYaw = wrapAngle(math.atan2(facing.X, facing.Z) - math.atan2(new.X, new.Z))
                    local diffPitch = math.asin(facing.Y) - math.asin(new.Y)
                    local angle = Vector2.new(diffYaw, diffPitch) // (moveConst * UserSettings():GetService('UserGameSettings').MouseSensitivity)
                    local scale = (Flick and Flick.Enabled) and 1 or math.min(Speed.Value * dt, 1)
                    mouseMove(angle.X * scale, angle.Y * scale)
                end
                AimAssist:Clean(RunService.RenderStepped:Connect(function(dt)
                    if CircleObject then
                        CircleObject.Position = UserInputService:GetMouseLocation()
                    end
                    local active = (AlwaysOn and AlwaysOn.Enabled) or rightClicked
                    if not active or AkiraLite.ClickGuiStatus then
                        ent = nil
                        clearActiveTarget("AimAssist")
                        return
                    end
                    if TargetLock and TargetLock.Enabled and ent then
                        local part = ent[Part.Value]
                        local keep = targetUsable(ent) and part and (part.Position - gameCamera.CFrame.Position).Magnitude <= FOV.Value * 1.75
                        if not keep then
                            ent = nil
                        end
                    else
                        ent = nil
                    end
                    if not ent then
                        ent = entitylib.EntityMouse({
                            Range = FOV.Value,
                            Part = Part.Value,
                            Players = true,
                            NPCs = false,
                            Wallcheck = not (WallAim and WallAim.Enabled),
                            Origin = gameCamera.CFrame.Position
                        })
                    end
                    if ent then
                        publishActiveTarget("AimAssist", ent, ent[Part.Value] or ent.Head)
                        aimAt(ent, dt)
                    else
                        clearActiveTarget("AimAssist")
                    end
                end))
                if RightClick.Enabled then
                    AimAssist:Clean(UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton2 then
                            rightClicked = true
                        end
                    end))
                    AimAssist:Clean(UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton2 then
                            rightClicked = false
                        end
                    end))
                end
            end
        end
    })
    Part = AimAssist:AddDropdown({
        Name = 'Part',
        List = {'RootPart', 'Head'}
    })
    FOV = AimAssist:AddSlider({
        Name = 'FOV',
        Min = 0,
        Max = 1000,
        Default = 100,
        Function = function(val)
            if CircleObject then
                CircleObject.Radius = val
            end
        end
    })
    Speed = AimAssist:AddSlider({
        Name = 'Speed',
        Min = 0,
        Max = 80,
        Default = 15
    })
    AimAssist:AddToggle({
        Name = 'Range Circle',
        Function = function(callback)
            CircleFilled.Frame.Visible = callback
            if CircleRender then
                CircleRender:Disconnect()
                CircleRender = nil
            end
            if callback then
                if not CircleObject then
                    CircleObject = Drawing.new('Circle')
                    CircleObject.Color = Color3.fromRGB(255, 255, 255)
                    CircleObject.NumSides = 100
                end
                if CircleOutlineToggle and CircleOutlineToggle.Enabled and not CircleOutlineObject then
                    pcall(function()
                        CircleOutlineObject = Drawing.new('Circle')
                        CircleOutlineObject.NumSides = 100
                        CircleOutlineObject.Thickness = CircleOutline and CircleOutline.Value or 1
                    end)
                end
                CircleObject.Transparency = CircleTransparency and 1 - CircleTransparency.Value or 0.5
                CircleRender = RunService.RenderStepped:Connect(function()
                    if CircleObject then
                        local mouse = UserInputService:GetMouseLocation()
                        local position = mouse
                        if (CircleFollow and CircleFollow.Enabled) or (CircleAlways and CircleAlways.Enabled) then
                            -- this is a SECOND full entity scan in the same frame as
                            -- the aim lookup above, at 4x the range. 20Hz is
                            -- indistinguishable for a circle that follows a target.
                            local now = os.clock()
                            if now - circleTargetAt >= 0.05 then
                                circleTargetAt = now
                                circleOptions.Range = FOV.Value * 4
                                circleOptions.Part = Part.Value
                                circleOptions.Origin = gameCamera.CFrame.Position
                                circleTarget = entitylib.EntityMouse(circleOptions)
                            end
                            local target = circleTarget
                            if target then
                                local part = target[Part.Value] or target.Head or target.RootPart
                                local point, onScreen = gameCamera:WorldToViewportPoint(part.Position)
                                if onScreen and point.Z > 0 then
                                    position = Vector2.new(point.X, point.Y)
                                end
                            end
                        end
                        local color = CircleColorA and CircleColorA.Value or Color3.fromRGB(255, 255, 255)
                        if CircleRainbow and CircleRainbow.Enabled then
                            color = Color3.fromHSV((os.clock() * (CircleRainbowSpeed and CircleRainbowSpeed.Value or 0.15)) % 1, 0.85, 1)
                        elseif CircleColorB and CircleColorB.Value ~= CircleColorA.Value then
                            local phase = (os.clock() * (CircleFlowSpeed and CircleFlowSpeed.Value or 0.4)) % 1
                            color = color:Lerp(CircleColorB.Value, (math.sin(phase * math.pi * 2) + 1) * 0.5)
                        end
                        CircleObject.Position = position
                        CircleObject.Radius = FOV.Value
                        CircleObject.Color = color
                        CircleObject.Filled = CircleFilled.Enabled
                        CircleObject.Thickness = CircleOutline and CircleOutline.Value or 1
                        CircleObject.Transparency = CircleTransparency and 1 - CircleTransparency.Value or 0.5
                        CircleObject.Visible = AimAssist.Enabled
                        if CircleOutlineObject then
                            CircleOutlineObject.Position = position
                            CircleOutlineObject.Radius = FOV.Value
                            CircleOutlineObject.Thickness = (CircleOutline and CircleOutline.Value or 1) + 1
                            CircleOutlineObject.Color = CIRCLE_OUTLINE_BLACK
                            CircleOutlineObject.Transparency = CircleObject.Transparency
                            CircleOutlineObject.Visible = AimAssist.Enabled and CircleOutlineToggle.Enabled
                        end
                    end
                end)
                AimAssist:Clean(CircleRender)
            else
                pcall(function()
                    if CircleObject then
                        CircleObject.Visible = false
                        CircleObject:Remove()
                    end
                    if CircleOutlineObject then
                        CircleOutlineObject.Visible = false
                        CircleOutlineObject:Remove()
                        CircleOutlineObject = nil
                    end
                end)
                CircleObject = nil
            end
        end
    })
    CircleFilled = AimAssist:AddToggle({
        Name = 'Circle Filled',
        Function = function(callback)
            if CircleObject then
                CircleObject.Filled = callback
            end
        end,
        Darker = true
    })
    CircleColorA = AimAssist:AddColorPicker({Name = 'Circle Color', Default = Color3.fromRGB(255, 255, 255), Darker = true})
    CircleColorB = AimAssist:AddColorPicker({Name = 'Gradient Color', Default = Color3.fromRGB(70, 210, 255), Darker = true})
    CircleTransparency = AimAssist:AddSlider({Name = 'Circle Transparency', Min = 0, Max = 1, Default = 0.5, Decimal = 10, Darker = true})
    CircleOutlineToggle = AimAssist:AddToggle({Name = 'Circle Outline', Darker = true})
    CircleOutline = AimAssist:AddSlider({Name = 'Outline Thickness', Min = 1, Max = 6, Default = 2, Decimal = 1, Darker = true})
    CircleRainbow = AimAssist:AddToggle({Name = 'Rainbow Circle', Darker = true})
    CircleRainbowSpeed = AimAssist:AddSlider({Name = 'Rainbow Speed', Min = 0.05, Max = 2, Default = 0.15, Decimal = 100, Darker = true})
    CircleFlowSpeed = AimAssist:AddSlider({Name = 'Flow Speed', Min = 0, Max = 2, Default = 0.4, Decimal = 100, Darker = true})
    CircleFollow = AimAssist:AddToggle({Name = 'Follow Target', Darker = true})
    CircleAlways = AimAssist:AddToggle({Name = 'Always Follow', Darker = true})
    RightClick = AimAssist:AddToggle({
        Name = 'Require right click',
        Function = function()
            if AimAssist.Enabled then
                AimAssist:Toggle()
                AimAssist:Toggle()
            end
        end
    })
    ShowTarget = AimAssist:AddToggle({
        Name = 'Show Target',
        Function = function()
            if AimAssist.Enabled then
                AimAssist:Toggle()
                AimAssist:Toggle()
            end
        end
    })
    Flick = AimAssist:AddToggle({Name = 'Flick Bot', Default = true, Darker = true})
    AlwaysOn = AimAssist:AddToggle({Name = 'Always On Target', Darker = true})
    TargetLock = AimAssist:AddToggle({Name = 'Target Lock', Default = true, Darker = true})
    WallAim = AimAssist:AddToggle({Name = 'Ignore Walls', Darker = true})
    PingComp = AimAssist:AddToggle({Name = 'Ping Compensation', Darker = true})
    PingFactor = AimAssist:AddSlider({Name = 'Ping Factor', Min = 0, Max = 2, Default = 0.5, Decimal = 100, Darker = true})
    IgnoreDeflecting = AimAssist:AddToggle({Name = 'Ignore Deflecting', Darker = true})
end)
    akiraMark("block2:done")
local SpeedMethods
local SpeedMethodList = {'Velocity'}
SpeedMethods = {
    Velocity = function(options, moveDirection)
        local root = entitylib.character.RootPart
        root.AssemblyLinearVelocity = (moveDirection * options.Value.Value) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
    end,
    Impulse = function(options, moveDirection)
        local root = entitylib.character.RootPart
        local diff = ((moveDirection * options.Value.Value) - root.AssemblyLinearVelocity) * Vector3.new(1, 0, 1)
        if diff.Magnitude > (moveDirection == Vector3.zero and 10 or 2) then
            root:ApplyImpulse(diff * root.AssemblyMass)
        end
    end,
    CFrame = function(options, moveDirection, dt)
        local root = entitylib.character.RootPart
        local dest = (moveDirection * math.max(options.Value.Value - entitylib.character.Humanoid.WalkSpeed, 0) * dt)
        if options.WallCheck.Enabled then
            options.rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
            options.rayCheck.CollisionGroup = root.CollisionGroup
            local ray = workspace:Raycast(root.Position, dest, options.rayCheck)
            if ray then
                dest = ((ray.Position + ray.Normal) - root.Position)
            end
        end
        root.CFrame += dest
    end,
    TP = function(options, moveDirection)
        if options.TPTiming < tick() then
            options.TPTiming = tick() + options.TPFrequency.Value
            SpeedMethods.CFrame(options, moveDirection, 1)
        end
    end,
    WalkSpeed = function(options)
        if not options.WalkSpeed then
            options.WalkSpeed = entitylib.character.Humanoid.WalkSpeed
        end
        entitylib.character.Humanoid.WalkSpeed = options.Value.Value
    end,
    Pulse = function(options, moveDirection)
        local root = entitylib.character.RootPart
        local dt = math.max(options.Value.Value - entitylib.character.Humanoid.WalkSpeed, 0)
        dt = dt * (1 - math.min((tick() % (options.PulseLength.Value + options.PulseDelay.Value)) / options.PulseLength.Value, 1))
        root.AssemblyLinearVelocity = (moveDirection * (entitylib.character.Humanoid.WalkSpeed + dt)) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
    end
}
for name in SpeedMethods do
    if not table.find(SpeedMethodList, name) then
        table.insert(SpeedMethodList, name)
    end
end
local Fly
    akiraMark("block3:start")
run(function()
    local Options = {
        TPTiming = tick()
    }
    local Mode
    local FloatMode
    local State
    local MoveMethod
    local Keys
    local VerticalValue
    local BounceLength
    local BounceDelay
    local FloatTPGround
    local FloatTPAir
    local CustomProperties
    local WallCheck
    local PlatformStanding
    local Platform, YLevel, OldYLevel
    local w, s, a, d, up, down = 0, 0, 0, 0, 0, 0
    local rayCheck = RaycastParams.new()
    rayCheck.RespectCanCollide = true
    Options.rayCheck = rayCheck
    local Functions
    Functions = {
        Velocity = function()
            entitylib.character.RootPart.Velocity = (entitylib.character.RootPart.Velocity * Vector3.new(1, 0, 1)) + Vector3.new(0, 2.25 + ((up + down) * VerticalValue.Value), 0)
        end,
        Impulse = function(options, moveDirection)
            local root = entitylib.character.RootPart
            local diff = (Vector3.new(0, 2.25 + ((up + down) * VerticalValue.Value), 0) - root.AssemblyLinearVelocity) * Vector3.new(0, 1, 0)
            if diff.Magnitude > 2 then
                root:ApplyImpulse(diff * root.AssemblyMass)
            end
        end,
        CFrame = function(dt)
            local root = entitylib.character.RootPart
            if not YLevel then
                YLevel = root.Position.Y
            end
            YLevel = YLevel + ((up + down) * VerticalValue.Value * dt)
            if WallCheck.Enabled then
                rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
                rayCheck.CollisionGroup = root.CollisionGroup
                local ray = workspace:Raycast(root.Position, Vector3.new(0, YLevel - root.Position.Y, 0), rayCheck)
                if ray then
                    YLevel = ray.Position.Y + entitylib.character.HipHeight
                end
            end
            root.Velocity *= Vector3.new(1, 0, 1)
            root.CFrame += Vector3.new(0, YLevel - root.Position.Y, 0)
        end,
        Bounce = function()
            Functions.Velocity()
            entitylib.character.RootPart.Velocity += Vector3.new(0, ((tick() % BounceDelay.Value) / BounceDelay.Value > 0.5 and 1 or - 1) * BounceLength.Value, 0)
        end,
        Floor = function()
            Platform.CFrame = down ~= 0 and CFrame.identity or entitylib.character.RootPart.CFrame + Vector3.new(0, - (entitylib.character.HipHeight + 0.5), 0)
        end,
        TP = function(dt)
            Functions.CFrame(dt)
            if tick() % (FloatTPAir.Value + FloatTPGround.Value) > FloatTPAir.Value then
                OldYLevel = OldYLevel or YLevel
                rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
                rayCheck.CollisionGroup = entitylib.character.RootPart.CollisionGroup
                local ray = workspace:Raycast(entitylib.character.RootPart.Position, Vector3.new(0, - 1000, 0), rayCheck)
                if ray then
                    YLevel = ray.Position.Y + entitylib.character.HipHeight
                end
            else
                if OldYLevel then
                    YLevel = OldYLevel
                    OldYLevel = nil
                end
            end
        end,
        Jump = function(dt)
            local root = entitylib.character.RootPart
            if not YLevel then
                YLevel = root.Position.Y
            end
            YLevel = YLevel + ((up + down) * VerticalValue.Value * dt)
            if root.Position.Y < YLevel then
                entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    }
    Fly = AkiraLite.Catalogs.Movement:AddModule({
        Name = 'Fly',
        Function = function(callback)
            if Platform then
                Platform.Parent = callback and gameCamera or nil
            end
            frictionTable.Fly = callback and CustomProperties.Enabled or nil
            updateVelocity()
            if callback then
                Fly:Clean(RunService.PreSimulation:Connect(function(dt)
                    if entitylib.isAlive then
                        if PlatformStanding.Enabled then
                            entitylib.character.Humanoid.PlatformStand = true
                            entitylib.character.RootPart.RotVelocity = Vector3.zero
                            entitylib.character.RootPart.CFrame = CFrame.lookAlong(entitylib.character.RootPart.CFrame.Position, gameCamera.CFrame.LookVector)
                        end
                        if State.Value ~= 'None' then
                            entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType[State.Value])
                        end
                        SpeedMethods[Mode.Value](Options, TargetStrafeVector or MoveMethod.Value == 'Direct' and calculateMoveVector(Vector3.new(a + d, 0, w + s)) or entitylib.character.Humanoid.MoveDirection, dt)
                        Functions[FloatMode.Value](dt)
                    else
                        YLevel = nil
                        OldYLevel = nil
                    end
                end))
                w, s, a, d = UserInputService:IsKeyDown(Enum.KeyCode.W) and - 1 or 0, UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0, UserInputService:IsKeyDown(Enum.KeyCode.A) and - 1 or 0, UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
                up, down = 0, 0
                for _, v in {'InputBegan', 'InputEnded'} do
                    Fly:Clean(UserInputService[v]:Connect(function(input)
                        if not UserInputService:GetFocusedTextBox() then
                            local divided = Keys.Value:split('/')
                            if input.KeyCode == Enum.KeyCode.W then
                                w = v == 'InputBegan' and - 1 or 0
                            elseif input.KeyCode == Enum.KeyCode.S then
                                s = v == 'InputBegan' and 1 or 0
                            elseif input.KeyCode == Enum.KeyCode.A then
                                a = v == 'InputBegan' and - 1 or 0
                            elseif input.KeyCode == Enum.KeyCode.D then
                                d = v == 'InputBegan' and 1 or 0
                            elseif input.KeyCode == Enum.KeyCode[divided[1]] then
                                up = v == 'InputBegan' and 1 or 0
                            elseif input.KeyCode == Enum.KeyCode[divided[2]] then
                                down = v == 'InputBegan' and - 1 or 0
                            end
                        end
                    end))
                end
                if UserInputService.TouchEnabled then
                    pcall(function()
                        local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
                        Fly:Clean(jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
                            up = jumpButton.ImageRectOffset.X == 146 and 1 or 0
                        end))
                    end)
                end
            else
                YLevel, OldYLevel = nil, nil
                if entitylib.isAlive and PlatformStanding.Enabled then
                    entitylib.character.Humanoid.PlatformStand = false
                end
            end
        end,
        ExtraText = function()
            return Mode.Value
        end
    })
    Mode = Fly:AddDropdown({
        Name = 'Speed Mode',
        List = SpeedMethodList,
        Function = function(val)
            WallCheck.Frame.Visible = FloatMode.Value == 'CFrame' or FloatMode.Value == 'TP' or val == 'CFrame' or val == 'TP'
            Options.TPFrequency.Frame.Visible = val == 'TP'
            Options.PulseLength.Frame.Visible = val == 'Pulse'
            Options.PulseDelay.Frame.Visible = val == 'Pulse'
            if Fly.Enabled then
                Fly:Toggle()
                Fly:Toggle()
            end
        end
    })
    FloatMode = Fly:AddDropdown({
        Name = 'Float Mode',
        List = {'Velocity', 'Impulse', 'CFrame', 'Bounce', 'Floor', 'Jump', 'TP'},
        Function = function(val)
            WallCheck.Frame.Visible = Mode.Value == 'CFrame' or Mode.Value == 'TP' or val == 'CFrame' or val == 'TP'
            BounceLength.Frame.Visible = val == 'Bounce'
            BounceDelay.Frame.Visible = val == 'Bounce'
            VerticalValue.Frame.Visible = val ~= 'Floor'
            FloatTPGround.Frame.Visible = val == 'TP'
            FloatTPAir.Frame.Visible = val == 'TP'
            if Platform then
                Platform:Destroy()
                Platform = nil
            end
            if val == 'Floor' then
                Platform = Instance.new('Part')
                Platform.CanQuery = false
                Platform.Anchored = true
                Platform.Size = Vector3.one
                Platform.Transparency = 1
                Platform.Parent = Fly.Enabled and gameCamera or nil
            end
        end
    })
    local states = {'None'}
    for _, v in Enum.HumanoidStateType:GetEnumItems() do
        if v.Name ~= 'Dead' and v.Name ~= 'None' then
            table.insert(states, v.Name)
        end
    end
    State = Fly:AddDropdown({
        Name = 'Humanoid State',
        List = states
    })
    MoveMethod = Fly:AddDropdown({
        Name = 'Move Mode',
        List = {'MoveDirection', 'Direct'}
    })
    Keys = Fly:AddDropdown({
        Name = 'Keys',
        List = {'Space/LeftControl', 'Space/LeftShift', 'E/Q', 'Space/Q', 'ButtonA/ButtonL2'}
    })
    Options.Value = Fly:AddSlider({
        Name = 'Speed',
        Min = 1,
        Max = 150,
        Default = 50,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    VerticalValue = Fly:AddSlider({
        Name = 'Vertical Speed',
        Min = 1,
        Max = 150,
        Default = 50,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    Options.TPFrequency = Fly:AddSlider({
        Name = 'TP Frequency',
        Min = 0,
        Max = 1,
        Decimal = 100,
        Darker = true,
        Visible = false,
        Suffix = function(val)
            return val == 1 and 'second' or 'seconds'
        end
    })
    Options.PulseLength = Fly:AddSlider({
        Name = 'Pulse Length',
        Min = 0,
        Max = 1,
        Decimal = 100,
        Darker = true,
        Visible = false,
        Suffix = function(val)
            return val == 1 and 'second' or 'seconds'
        end
    })
    Options.PulseDelay = Fly:AddSlider({
        Name = 'Pulse Delay',
        Min = 0,
        Max = 1,
        Decimal = 100,
        Darker = true,
        Visible = false,
        Suffix = function(val)
            return val == 1 and 'second' or 'seconds'
        end
    })
    BounceLength = Fly:AddSlider({
        Name = 'Bounce Length',
        Min = 0,
        Max = 30,
        Darker = true,
        Visible = false,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    BounceDelay = Fly:AddSlider({
        Name = 'Bounce Delay',
        Min = 0,
        Max = 1,
        Decimal = 100,
        Darker = true,
        Visible = false,
        Suffix = function(val)
            return val == 1 and 'second' or 'seconds'
        end
    })
    FloatTPGround = Fly:AddSlider({
        Name = 'Ground',
        Min = 0,
        Max = 1,
        Decimal = 10,
        Default = 0.1,
        Darker = true,
        Visible = false,
        Suffix = function(val)
            return val == 1 and 'second' or 'seconds'
        end
    })
    FloatTPAir = Fly:AddSlider({
        Name = 'Air',
        Min = 0,
        Max = 5,
        Decimal = 10,
        Default = 2,
        Darker = true,
        Visible = false,
        Suffix = function(val)
            return val == 1 and 'second' or 'seconds'
        end
    })
    WallCheck = Fly:AddToggle({
        Name = 'Wall Check',
        Default = true,
        Darker = true,
        Visible = false
    })
    Options.WallCheck = WallCheck
    PlatformStanding = Fly:AddToggle({
        Name = 'PlatformStand',
        Function = function(callback)
            if Fly.Enabled then
                entitylib.character.Humanoid.PlatformStand = callback
            end
        end
    })
    CustomProperties = Fly:AddToggle({
        Name = 'Custom Properties',
        Function = function()
            if Fly.Enabled then
                Fly:Toggle()
                Fly:Toggle()
            end
        end,
        Default = true
    })
end)
    akiraMark("block3:done")
    akiraMark("block4:start")
run(function()
    local Speed
    local Mode
    local Options
    local AutoJump
    local AutoJumpCustom
    local AutoJumpValue
    local w, s, a, d = 0, 0, 0, 0
    Speed = AkiraLite.Catalogs.Movement:AddModule({
        Name = 'Speed',
        Function = function(callback)
            frictionTable.Speed = callback and Options.CustomProperties.Enabled or nil
            updateVelocity()
            if callback then
                Speed:Clean(RunService.PreSimulation:Connect(function(dt)
                    if entitylib.isAlive and not Fly.Enabled then
                        local state = entitylib.character.Humanoid:GetState()
                        if state == Enum.HumanoidStateType.Climbing then
                            return
                        end
                        local movevec = TargetStrafeVector or Options.MoveMethod.Value == 'Direct' and calculateMoveVector(Vector3.new(a + d, 0, w + s)) or entitylib.character.Humanoid.MoveDirection
                        local a = (function(options, moveDirection, dt)
                            local root = entitylib.character.RootPart
                            local dest = (moveDirection * math.max(options.Value.Value - entitylib.character.Humanoid.WalkSpeed, 0) * dt)
                            if options.WallCheck.Enabled then
                                options.rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
                                options.rayCheck.CollisionGroup = root.CollisionGroup
                                local ray = workspace:Raycast(root.Position, dest, options.rayCheck)
                                if ray then
                                    dest = ((ray.Position + ray.Normal) - root.Position)
                                end
                            end
                            root.CFrame += dest
                        end)(Options, movevec, dt)
                        if AutoJump.Enabled and entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air and movevec ~= Vector3.zero then
                            if AutoJumpCustom.Enabled then
                                local velocity = entitylib.character.RootPart.Velocity * Vector3.new(1, 0, 1)
                                entitylib.character.RootPart.Velocity = Vector3.new(velocity.X, AutoJumpValue.Value, velocity.Z)
                            else
                                entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                    end
                end))
                w, s, a, d = UserInputService:IsKeyDown(Enum.KeyCode.W) and - 1 or 0, UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0, UserInputService:IsKeyDown(Enum.KeyCode.A) and - 1 or 0, UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
                for _, v in {'InputBegan', 'InputEnded'} do
                    Speed:Clean(UserInputService[v]:Connect(function(input)
                        if not UserInputService:GetFocusedTextBox() then
                            if input.KeyCode == Enum.KeyCode.W then
                                w = v == 'InputBegan' and - 1 or 0
                            elseif input.KeyCode == Enum.KeyCode.S then
                                s = v == 'InputBegan' and 1 or 0
                            elseif input.KeyCode == Enum.KeyCode.A then
                                a = v == 'InputBegan' and - 1 or 0
                            elseif input.KeyCode == Enum.KeyCode.D then
                                d = v == 'InputBegan' and 1 or 0
                            end
                        end
                    end))
                end
            else
                if Options.WalkSpeed and entitylib.isAlive then
                    entitylib.character.Humanoid.WalkSpeed = Options.WalkSpeed
                end
                Options.WalkSpeed = nil
            end
        end,
        ExtraText = function()
            return Mode.Value
        end
    })
    Mode = Speed:AddDropdown({
        Name = 'Mode',
        List = SpeedMethodList,
        Function = function(val)
            Options.WallCheck.Frame.Visible = val == 'CFrame' or val == 'TP'
            Options.TPFrequency.Frame.Visible = val == 'TP'
            Options.PulseLength.Frame.Visible = val == 'Pulse'
            Options.PulseDelay.Frame.Visible = val == 'Pulse'
            if Speed.Enabled then
                Speed:Toggle()
                Speed:Toggle()
            end
        end
    })
    Options = {
        MoveMethod = Speed:AddDropdown({
            Name = 'Move Mode',
            List = {'MoveDirection', 'Direct'}
        }),
        Value = Speed:AddSlider({
            Name = 'Speed',
            Min = 1,
            Max = 150,
            Default = 50,
            Suffix = function(val)
                return val == 1 and 'stud' or 'studs'
            end
        }),
        TPFrequency = Speed:AddSlider({
            Name = 'TP Frequency',
            Min = 0,
            Max = 1,
            Decimal = 100,
            Darker = true,
            Visible = false,
            Suffix = function(val)
                return val == 1 and 'second' or 'seconds'
            end
        }),
        PulseLength = Speed:AddSlider({
            Name = 'Pulse Length',
            Min = 0,
            Max = 1,
            Decimal = 100,
            Darker = true,
            Visible = false,
            Suffix = function(val)
                return val == 1 and 'second' or 'seconds'
            end
        }),
        PulseDelay = Speed:AddSlider({
            Name = 'Pulse Delay',
            Min = 0,
            Max = 1,
            Decimal = 100,
            Darker = true,
            Visible = false,
            Suffix = function(val)
                return val == 1 and 'second' or 'seconds'
            end
        }),
        WallCheck = Speed:AddToggle({
            Name = 'Wall Check',
            Default = true,
            Darker = true,
            Visible = false
        }),
        TPTiming = tick(),
        rayCheck = RaycastParams.new()
    }
    Options.rayCheck.RespectCanCollide = true
    Options.CustomProperties = Speed:AddToggle({
        Name = 'Custom Properties',
        Function = function()
            if Speed.Enabled then
                Speed:Toggle()
                Speed:Toggle()
            end
        end,
        Default = true
    })
    AutoJump = Speed:AddToggle({
        Name = 'AutoJump',
        Function = function(callback)
            AutoJumpCustom.Frame.Visible = callback
        end
    })
    AutoJumpCustom = Speed:AddToggle({
        Name = 'Custom Jump',
        Function = function(callback)
            AutoJumpValue.Frame.Visible = callback
        end,
        Darker = true,
        Visible = false
    })
    AutoJumpValue = Speed:AddSlider({
        Name = 'Jump Power',
        Min = 1,
        Max = 50,
        Default = 30,
        Darker = true,
        Visible = false
    })
end)
    akiraMark("block4:done")
    akiraMark("block5:start")
run(function()
    local NameTags
    local Targets
    local Color
    local Background
    local DisplayName
    local Health
    local Distance
    local DrawingToggle
    local Scale
    local FontOption
    local GlowEffect
    local Teammates
    local DistanceCheck
    local DistanceLimit
    local Strings, Sizes, Reference, Gradients = {}, {}, {}, {}
    local Folder = Instance.new('Folder')
    Folder.Parent = AkiraLite.MainScreenGui
    local methodused
    local Added = {
        Normal = function(ent)
            if ent.NPC then
                return
            end
            if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then
                return
            end
            if AkiraLite.ThreadFix then
                setThreadIdentity(8)
            end
            Strings[ent] = ent.Player and (DisplayName.Enabled and getPlayerIdentity(ent.Player, true) or getPlayerIdentity(ent.Player, false)) or ent.Character.Name
            if Health.Enabled then
                local healthColor = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
                Strings[ent] = Strings[ent] .. ' <font color="rgb(' .. tostring(math.floor(healthColor.R * 255)) .. ',' .. tostring(math.floor(healthColor.G * 255)) .. ',' .. tostring(math.floor(healthColor.B * 255)) .. ')">' .. math.round(ent.Health) .. '</font>'
            end
            if Distance.Enabled then
                Strings[ent] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> ' .. Strings[ent]
            end
            local nametag = Instance.new('TextLabel')
            nametag.TextSize = 14 * Scale.Value
            nametag.FontFace = uipaletteFont
            nametag.ZIndex = - 1
            local ize = getfontsize(removeTags(Strings[ent]), nametag.TextSize, uipaletteFont, Vector2.new(100000, 100000))
            nametag.Name = ent.Player and getPlayerIdentity(ent.Player, false) or ent.Character.Name
            nametag.Size = UDim2.fromOffset(ize.X + 8, ize.Y + 7)
            nametag.AnchorPoint = Vector2.new(0.5, 1)
            nametag.BackgroundColor3 = Color3.new()
            nametag.BackgroundTransparency = Background.Value
            nametag.BorderSizePixel = 0
            if GlowEffect.Enabled then
                addGradient(addRoundedShadow(nametag))
            end
            addCorner(nametag, UDim.new(12, 0))
            nametag.Visible = false
            nametag.Text = Strings[ent]
            if entitylib.getEntityColor(ent) then
                nametag.TextColor3 = entitylib.getEntityColor(ent)
                if Gradients[ent] then
                    Gradients[ent].Enabled = false
                end
            else
                nametag.TextColor3 = Color3.fromRGB(255, 255, 255)
                Gradients[ent] = addGradient(nametag)
            end
            nametag.RichText = true
            nametag.Parent = Folder
            Reference[ent] = nametag
        end,
        Drawing = function(ent)
            -- if not Targets.Players.Enabled and ent.Player then return end
            if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then
                return
            end
            if AkiraLite.ThreadFix then
                setThreadIdentity(8)
            end
            local nametag = {}
            nametag.BG = Drawing.new('Square')
            nametag.BG.Filled = true
            nametag.BG.Transparency = 1 - Background.Value
            nametag.BG.Color = Color3.new()
            nametag.BG.ZIndex = 1
            nametag.Text = Drawing.new('Text')
            nametag.Text.Size = 15 * Scale.Value
            nametag.Text.Font = 0
            nametag.Text.ZIndex = 2
            Strings[ent] = ent.Player and (DisplayName.Enabled and getPlayerIdentity(ent.Player, true) or getPlayerIdentity(ent.Player, false)) or ent.Character.Name
            if Health.Enabled then
                Strings[ent] = Strings[ent] .. ' ' .. math.round(ent.Health)
            end
            if Distance.Enabled then
                Strings[ent] = '[%s] ' .. Strings[ent]
            end
            nametag.Text.Text = Strings[ent]
            nametag.Text.Color = entitylib.getEntityColor(ent) or uipalette.FinalColor
            nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
            Reference[ent] = nametag
        end
    }
    local Removed = {
        Normal = function(ent)
            local v = Reference[ent]
            if v then
                if AkiraLite.ThreadFix then
                    setThreadIdentity(8)
                end
                Reference[ent] = nil
                Strings[ent] = nil
                Sizes[ent] = nil
                v:Destroy()
            end
        end,
        Drawing = function(ent)
            local v = Reference[ent]
            if v then
                if AkiraLite.ThreadFix then
                    setThreadIdentity(8)
                end
                Reference[ent] = nil
                Strings[ent] = nil
                Sizes[ent] = nil
                for _, v2 in v do
                    pcall(function()
                        v2.Visible = false
                        v2:Remove()
                    end)
                end
            end
        end
    }
    local Updated = {
        Normal = function(ent)
            local nametag = Reference[ent]
            if nametag then
                if AkiraLite.ThreadFix then
                    setThreadIdentity(8)
                end
                Sizes[ent] = nil
                Strings[ent] = ent.Player and (DisplayName.Enabled and getPlayerIdentity(ent.Player, true) or getPlayerIdentity(ent.Player, false)) or ent.Character.Name
                if Health.Enabled then
                    local color = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
                    Strings[ent] = Strings[ent] .. ' <font color="rgb(' .. tostring(math.floor(color.R * 255)) .. ',' .. tostring(math.floor(color.G * 255)) .. ',' .. tostring(math.floor(color.B * 255)) .. ')">' .. math.round(ent.Health) .. '</font>'
                end
                if Distance.Enabled then
                    Strings[ent] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> ' .. Strings[ent]
                end
                local ize = getfontsize(removeTags(Strings[ent]), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000))
                nametag.Size = UDim2.fromOffset(ize.X + 8, ize.Y + 7)
                nametag.Text = Strings[ent]
            end
        end,
        Drawing = function(ent)
            local nametag = Reference[ent]
            if nametag then
                if AkiraLite.ThreadFix then
                    setThreadIdentity(8)
                end
                Sizes[ent] = nil
                Strings[ent] = ent.Player and (DisplayName.Enabled and getPlayerIdentity(ent.Player, true) or getPlayerIdentity(ent.Player, false)) or ent.Character.Name
                if Health.Enabled then
                    Strings[ent] = Strings[ent] .. ' ' .. math.round(ent.Health)
                end
                if Distance.Enabled then
                    Strings[ent] = '[%s] ' .. Strings[ent]
                    nametag.Text.Text = entitylib.isAlive and string.format(Strings[ent], math.floor((entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude)) or Strings[ent]
                else
                    nametag.Text.Text = Strings[ent]
                end
                nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
                nametag.Text.Color = entitylib.getEntityColor(ent) or uipalette.FinalColor
            end
        end
    }
    local ColorFunc = {
        Normal = function(hue, sat, val)
            local color = Color3.fromHSV(hue, sat, val)
            for i, v in Reference do
                v.TextColor3 = entitylib.getEntityColor(i) or color
            end
        end,
        Drawing = function(hue, sat, val)
            local color = Color3.fromHSV(hue, sat, val)
            for i, v in Reference do
                v.Text.Color = entitylib.getEntityColor(i) or color
            end
        end
    }
    local Loop = {
        Normal = function()
            -- Hoisted out of the per-entity loop: these are the same for every
            -- entity on every frame, and re-reading them per entity (and
            -- re-reading RootPart.Position twice per entity) is the single
            -- hottest thing in this file.
            local useDistanceCheck = DistanceCheck.Enabled
            local useDistance = Distance.Enabled
            local distanceLimit = DistanceLimit.Value
            local isAlive = entitylib.isAlive
            local myRoot = isAlive and entitylib.character and entitylib.character.RootPart
            local myPos = myRoot and myRoot.Position
            for ent, nametag in Reference do
                local entPos = ent.RootPart.Position
                if useDistanceCheck then
                    local distance = (isAlive and myPos) and (myPos - entPos).Magnitude or math.huge
                    if distance > distanceLimit then
                        nametag.Visible = false
                        continue
                    end
                end
                local headPos, headVis = gameCamera:WorldToViewportPoint(entPos + Vector3.new(0, ent.HipHeight + 1, 0))
                nametag.Visible = headVis
                if not headVis then
                    continue
                end
                if useDistance then
                    local mag = (isAlive and myPos) and math.floor((myPos - entPos).Magnitude) or 0
                    if Sizes[ent] ~= mag then
                        nametag.Text = string.format(Strings[ent], mag)
                        local ize = getfontsize(removeTags(nametag.Text), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000))
                        nametag.Size = UDim2.fromOffset(ize.X + 8, ize.Y + 7)
                        Sizes[ent] = mag
                    end
                end
                nametag.Position = UDim2.fromOffset(headPos.X, headPos.Y)
            end
        end,
        Drawing = function()
            -- same hoisting as Loop.Normal above
            local useDistanceCheck = DistanceCheck.Enabled
            local useDistance = Distance.Enabled
            local distanceLimit = DistanceLimit.Value
            local isAlive = entitylib.isAlive
            local myRoot = isAlive and entitylib.character and entitylib.character.RootPart
            local myPos = myRoot and myRoot.Position
            for ent, nametag in Reference do
                local entPos = ent.RootPart.Position
                if useDistanceCheck then
                    local distance = (isAlive and myPos) and (myPos - entPos).Magnitude or math.huge
                    if distance > distanceLimit then
                        nametag.Text.Visible = false
                        nametag.BG.Visible = false
                        continue
                    end
                end
                local headPos, headVis = gameCamera:WorldToScreenPoint(entPos + Vector3.new(0, ent.HipHeight + 1, 0))
                nametag.Text.Visible = headVis
                nametag.BG.Visible = headVis
                if not headVis then
                    continue
                end
                if useDistance then
                    local mag = (isAlive and myPos) and math.floor((myPos - entPos).Magnitude) or 0
                    if Sizes[ent] ~= mag then
                        nametag.Text.Text = string.format(Strings[ent], mag)
                        nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
                        Sizes[ent] = mag
                    end
                end
                nametag.BG.Position = Vector2.new(headPos.X - (nametag.BG.Size.X / 2), headPos.Y + (nametag.BG.Size.Y / 2))
                nametag.Text.Position = nametag.BG.Position + Vector2.new(4, 2.5)
            end
        end
    }
    NameTags = AkiraLite.Catalogs.Render:AddModule({
        Name = 'NameTags',
        Function = function(callback)
            if callback then
                methodused = DrawingToggle.Enabled and 'Drawing' or 'Normal'
                if Removed[methodused] then
                    NameTags:Clean(entitylib.Events.EntityRemoved:Connect(Removed[methodused]))
                end
                if Added[methodused] then
                    for _, v in entitylib.List do
                        if Reference[v] then
                            Removed[methodused](v)
                        end
                        Added[methodused](v)
                    end
                    NameTags:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
                        if Reference[ent] then
                            Removed[methodused](ent)
                        end
                        Added[methodused](ent)
                    end))
                end
                if Updated[methodused] then
                    NameTags:Clean(entitylib.Events.EntityUpdated:Connect(Updated[methodused]))
                    for _, v in entitylib.List do
                        Updated[methodused](v)
                    end
                end
                if Loop[methodused] then
                    NameTags:Clean(RunService.RenderStepped:Connect(Loop[methodused]))
                end
            else
                if Removed[methodused] then
                    for i in Reference do
                        Removed[methodused](i)
                    end
                end
            end
        end
    })
    Scale = NameTags:AddSlider({
        Name = 'Scale',
        Function = function()
            if NameTags.Enabled then
                NameTags:Toggle()
                NameTags:Toggle()
            end
        end,
        Default = 1,
        Min = 0.1,
        Max = 1.5,
        Decimal = 10
    })
    Background = NameTags:AddSlider({
        Name = 'Transparency',
        Function = function()
            if NameTags.Enabled then
                NameTags:Toggle()
                NameTags:Toggle()
            end
        end,
        Default = 0.5,
        Min = 0,
        Max = 1,
        Decimal = 10
    })
    GlowEffect = NameTags:AddToggle({
        Name = 'Glow Effect',
        Function = function()
            if NameTags.Enabled then
                NameTags:Toggle()
                NameTags:Toggle()
            end
        end,
        Default = true
    })
    Health = NameTags:AddToggle({
        Name = 'Health',
        Function = function()
            if NameTags.Enabled then
                NameTags:Toggle()
                NameTags:Toggle()
            end
        end
    })
    Distance = NameTags:AddToggle({
        Name = 'Distance',
        Function = function()
            if NameTags.Enabled then
                NameTags:Toggle()
                NameTags:Toggle()
            end
        end
    })
    DisplayName = NameTags:AddToggle({
        Name = 'Use Displayname',
        Function = function()
            if NameTags.Enabled then
                NameTags:Toggle()
                NameTags:Toggle()
            end
        end,
        Default = true
    })
    Teammates = NameTags:AddToggle({
        Name = 'Priority Only',
        Function = function()
            if NameTags.Enabled then
                NameTags:Toggle()
                NameTags:Toggle()
            end
        end,
        Default = true
    })
    DrawingToggle = NameTags:AddToggle({
        Name = 'Drawing',
        Function = function(callback)
            GlowEffect.Frame.Visible = not callback
            if NameTags.Enabled then
                NameTags:Toggle()
                NameTags:Toggle()
            end
        end
    })
    DistanceCheck = NameTags:AddToggle({
        Name = 'Distance Check',
        Function = function(callback)
            DistanceLimit.Frame.Visible = callback
        end
    })
    DistanceLimit = NameTags:AddSlider({
        Name = 'Player Distance',
        Min = 0,
        Max = 256,
        Default = 64,
        Darker = true,
        Visible = false
    })
end)
    akiraMark("block5:done")
    akiraMark("block6:start")
run(function()
    local Timer
    local Value
    Timer = AkiraLite.Catalogs.Player:AddModule({
        Name = 'Timer',
        Function = function(callback)
            if callback then
                setFFlag('SimEnableStepPhysics', 'True')
                setFFlag('SimEnableStepPhysicsSelective', 'True')
                Timer:Clean(RunService.RenderStepped:Connect(function(dt)
                    if Value.Value > 1 then
                        RunService:Pause()
                        workspace:StepPhysics(dt * (Value.Value - 1), {entitylib.character.RootPart})
                        RunService:Run()
                    end
                end))
            end
        end
    })
    Value = Timer:AddSlider({
        Name = 'Value',
        Min = 1,
        Max = 3,
        Decimal = 10
    })
end)
    akiraMark("block6:done")
local visited, attempted = {}, {}
local cacheExpire, cache = tick()
local hopPages = 0
local function serverHop(pointer, filter)
    hopPages += 1
    if hopPages > 10 then
        return
    end
    visited = shared.AkiraLiteServerhoplist and shared.AkiraLiteServerhoplist:split('/') or {}
    if not table.find(visited, game.JobId) then
        table.insert(visited, game.JobId)
    end
    if not pointer then
        warn('Searching for an available server.')
    end
    local suc, httpdata = pcall(function()
        return cacheExpire < tick() and game:HttpGet('https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=' .. (filter == 'Ascending' and 1 or 2) .. '&excludeFullGames=true&limit=100' .. (pointer and '&cursor=' .. pointer or '')) or cache
    end)
    local decodeOk, data = false, nil
    if suc and type(httpdata) == "string" then
        decodeOk, data = pcall(function()
            return HttpService:JSONDecode(httpdata)
        end)
    end
    if decodeOk and data and data.data then
        for _, v in data.data do
            if tonumber(v.playing) < Players.MaxPlayers and not table.find(visited, v.id) and not table.find(attempted, v.id) then
                cacheExpire, cache = tick() + 60, httpdata
                table.insert(attempted, v.id)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id)
                return
            end
        end
        if data.nextPageCursor then
            task.delay(0.2, function()
                serverHop(data.nextPageCursor, filter)
            end)
        end
    end
end
    akiraMark("block7:start")
run(function()
    local StaffDetector
    local Mode
    local staffGroupId = 0
    local staffRole = math.huge
    local function getRole(plr, id)
        if not id or id == 0 then
            return 0
        end
        local suc, res
        for _ = 1, 3 do
            suc, res = pcall(function()
                return plr:GetRankInGroup(id)
            end)
            if suc then
                break
            end
        end
        return suc and res or 0
    end
    local function getLowestStaffRole(roles)
        local highest = math.huge
        for _, v in roles do
            local low = v.Name:lower()
            if (low:find('admin') or low:find('mod') or low:find('dev')) and v.Rank < highest then
                highest = v.Rank
            end
        end
        return highest
    end
    local function isStaff(plr)
        if staffGroupId == 0 or staffRole == math.huge then
            return false
        end
        return getRole(plr, staffGroupId) >= staffRole
    end
    local function playerAdded(plr)
        if not AkiraLite.Loaded and not AkiraLite.Destroyed then
            local waitUntil = os.clock() + 10
            while not AkiraLite.Loaded and not AkiraLite.Destroyed and os.clock() < waitUntil do
                task.wait(0.2)
            end
        end
        if AkiraLite.Destroyed or not StaffDetector or not StaffDetector.Enabled then
            return
        end
        if isStaff(plr) then
            if Mode.Value == 'Uninject' then
                pcall(function()
                    game:GetService('StarterGui'):SetCore('SendNotification', {
                        Title = 'StaffDetector',
                        Text = 'Staff Detected\n' .. plr.Name,
                        Duration = 60,
                    })
                end)
                task.spawn(function()
                    AkiraLite:Uninject()
                end)
            elseif Mode.Value == 'ServerHop' then
                serverHop()
            elseif Mode.Value == 'Notify' then
                AkiraLite:Notify({
                    Text = 'Staff detected: ' .. plr.Name,
                    Duration = 6
                })
            end
        end
    end
    StaffDetector = AkiraLite.Catalogs.Player:AddModule({
        Name = 'StaffDetector',
        Function = function(callback)
            if callback then
                local okInfo, placeinfo = pcall(function()
                    return MarketplaceService:GetProductInfo(game.PlaceId)
                end)
                local creatorType = okInfo and placeinfo and placeinfo.Creator and placeinfo.Creator.CreatorType or nil
                local groupId = okInfo and placeinfo and placeinfo.Creator and tonumber(placeinfo.Creator.CreatorTargetId) or nil
                if creatorType ~= 'Group' and okInfo and placeinfo and type(placeinfo.Description) == 'string' then
                    for str in placeinfo.Description:split('\n') do
                        local _, begin = str:find('roblox.com/groups/')
                        if begin then
                            local endof = str:find('/', begin + 1)
                            if endof then
                                groupId = tonumber(str:sub(begin + 1, endof - 1))
                                break
                            end
                        end
                    end
                end
                if groupId and groupId > 0 then
                    staffGroupId = groupId
                    local okGroup, groupinfo = pcall(function()
                        return GroupService:GetGroupInfoAsync(groupId)
                    end)
                    if okGroup and type(groupinfo) == 'table' and type(groupinfo.Roles) == 'table' then
                        staffRole = getLowestStaffRole(groupinfo.Roles)
                    end
                end
                StaffDetector:Clean(Players.PlayerAdded:Connect(playerAdded))
                for _, v in Players:GetPlayers() do
                    StaffDetector:Clean(task.spawn(playerAdded, v))
                end
            end
        end
    })
    Mode = StaffDetector:AddDropdown({
        Name = 'Mode',
        List = {'Uninject', 'ServerHop', 'Notify'}
    })
end)
    akiraMark("block7:done")
    akiraMark("block8:start")
run(function()
    local Freecam
    local Value
    local randomkey, module, old = HttpService:GenerateGUID(false)
    Freecam = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Freecam',
        Function = function(callback)
            if callback then
                local camAttempts = 0
                repeat
                    task.wait(0.1)
                    camAttempts += 1
                    pcall(function()
                        for _, v in getConnections(gameCamera:GetPropertyChangedSignal('CameraType')) do
                            if v.Function then
                                module = debug.getupvalue(v.Function, 1)
                            end
                        end
                    end)
                until module or not Freecam.Enabled or camAttempts > 20
                if module and module.activeCameraController and Freecam.Enabled then
                    old = module.activeCameraController.GetSubjectPosition
                    local camPos = old(module.activeCameraController) or Vector3.zero
                    module.activeCameraController.GetSubjectPosition = function()
                        return camPos
                    end Freecam:Clean(RunService.PreSimulation:Connect(function(dt)
                        if not UserInputService:GetFocusedTextBox() then
                            local forward = (UserInputService:IsKeyDown(Enum.KeyCode.W) and - 1 or 0) + (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
                            local side = (UserInputService:IsKeyDown(Enum.KeyCode.A) and - 1 or 0) + (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0)
                            local up = (UserInputService:IsKeyDown(Enum.KeyCode.Q) and - 1 or 0) + (UserInputService:IsKeyDown(Enum.KeyCode.E) and 1 or 0)
                            dt = dt * (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 0.25 or 1)
                            camPos = (CFrame.lookAlong(camPos, gameCamera.CFrame.LookVector) * CFrame.new(Vector3.new(side, up, forward) * (Value.Value * dt))).Position
                        end
                    end))
                    ContextService:BindActionAtPriority('FreecamKeyboard' .. randomkey, function()
                        return Enum.ContextActionResult.Sink
                    end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.Up, Enum.KeyCode.Down)
                end
            else
                pcall(function()
                    ContextService:UnbindAction('FreecamKeyboard' .. randomkey)
                end)
                if module and old then
                    module.activeCameraController.GetSubjectPosition = old
                    module = nil
                    old = nil
                end
            end
        end
    })
    Value = Freecam:AddSlider({
        Name = 'Speed',
        Min = 1,
        Max = 150,
        Default = 50,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
end)
    akiraMark("block8:done")
    akiraMark("block9:start")
run(function()
    local Mode
    local StudLimit
    local rayCheck = RaycastParams.new()
    rayCheck.RespectCanCollide = true
    local overlapCheck = OverlapParams.new()
    overlapCheck.MaxParts = 9e9
    local modified, fflag = {}
    -- scratch set for the per-step "is this part still in the box" check, so the
    -- old O(#modified x #parts) table.find scan becomes a set lookup
    local phasePresent = {}
    local teleported
    local function motorMove(root, destination)
        if root and root.Parent and destination then
            root.CFrame = destination
        end
    end
    -- Enum.NormalId:GetEnumItems() allocated a fresh 6-entry table on every
    -- grabClosestNormal call, and that runs on every physics step.
    local NORMAL_IDS = Enum.NormalId:GetEnumItems()
    local function grabClosestNormal(ray)
        local partCF, mag, closest = ray.Instance.CFrame, 0, Enum.NormalId.Top
        for i = 1, #NORMAL_IDS do
            local normal = NORMAL_IDS[i]
            local dot = partCF:VectorToWorldSpace(Vector3.fromNormalId(normal)):Dot(ray.Normal)
            if dot > mag then
                mag, closest = dot, normal
            end
        end
        return Vector3.fromNormalId(closest).X ~= 0 and 'X' or 'Z'
    end
    -- The raycast filter used to be rebuilt from scratch (plus one table.insert
    -- per entity) on every physics step, twice. It is rebuilt only when the
    -- entity list actually changes now.
    local phaseFilter, phaseFilterCount = nil, -1
    local function refreshPhaseFilter()
        local list = entitylib.List
        local count = #list
        if phaseFilter and phaseFilterCount == count then
            return phaseFilter
        end
        local chars = phaseFilter or {}
        chars[1] = gameCamera
        chars[2] = lplr.Character
        local index = 3
        for i = 1, count do
            local character = list[i].Character
            if character ~= nil then
                chars[index] = character
                index = index + 1
            end
        end
        for i = index, count + 2 do
            chars[i] = nil
        end
        phaseFilter = chars
        phaseFilterCount = count
        return chars
    end
    -- lplr.Character:GetDescendants() ran on every physics step for the character
    -- mode. The BasePart list is cached and only invalidated when the character
    -- or one of its parts actually changes.
    local charPartsCache, charPartsChar = nil, nil
    local function invalidateCharParts(char)
        if charPartsChar == char then
            charPartsCache = nil
        end
    end
    lplr.CharacterAdded:Connect(function(char)
        charPartsCache, charPartsChar = nil, char
        char.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") then
                invalidateCharParts(char)
            end
        end)
        char.DescendantRemoving:Connect(function(part)
            if part:IsA("BasePart") then
                invalidateCharParts(char)
            end
        end)
    end)
    local function characterParts()
        local char = lplr.Character
        if not char then
            return nil
        end
        if charPartsChar ~= char then
            charPartsChar, charPartsCache = char, nil
        end
        if charPartsCache == nil then
            local parts = {}
            for _, part in char:GetDescendants() do
                if part:IsA("BasePart") then
                    parts[#parts + 1] = part
                end
            end
            charPartsCache = parts
        end
        return charPartsCache
    end
    local Functions = {
        Part = function()
            overlapCheck.FilterDescendantsInstances = refreshPhaseFilter()
            local parts = workspace:GetPartBoundsInBox(entitylib.character.RootPart.CFrame + Vector3.new(0, 1, 0), entitylib.character.RootPart.Size + Vector3.new(1, entitylib.character.HipHeight, 1), overlapCheck)
            for _, part in parts do
                if part.CanCollide and (not Spider.Enabled or SpiderShift) then
                    modified[part] = true
                    part.CanCollide = false
                end
            end
            -- set lookup instead of table.find over the parts array
            local present = phasePresent
            table.clear(present)
            for _, part in parts do
                present[part] = true
            end
            for part in modified do
                if not present[part] then
                    modified[part] = nil
                    part.CanCollide = true
                end
            end
        end,
        Character = function()
            local parts = characterParts()
            if not parts then
                return
            end
            for i = 1, #parts do
                local part = parts[i]
                if part.CanCollide and (not Spider.Enabled or SpiderShift) then
                    modified[part] = true
                    part.CanCollide = Spider.Enabled and not SpiderShift
                end
            end
        end,
        CFrame = function()
            local chars = refreshPhaseFilter()
            rayCheck.FilterDescendantsInstances = chars
            overlapCheck.FilterDescendantsInstances = chars
            local ray = workspace:Raycast(entitylib.character.Head.CFrame.Position, entitylib.character.Humanoid.MoveDirection * 1.1, rayCheck)
            if ray and (not Spider.Enabled or SpiderShift) then
                local phaseDirection = grabClosestNormal(ray)
                if ray.Instance.Size[phaseDirection] <= StudLimit.Value then
                    local root = entitylib.character.RootPart
                    local dest = root.CFrame + (ray.Normal * (- (ray.Instance.Size[phaseDirection]) - (root.Size.X / 1.5)))
                    if #workspace:GetPartBoundsInBox(dest, Vector3.one, overlapCheck) <= 0 then
                        if Mode.Value == 'Motor' then
                            motorMove(root, dest)
                        else
                            root.CFrame = dest
                        end
                    end
                end
            end
        end,
        FFlag = function()
            if teleported then
                return
            end
            setFFlag('AssemblyExtentsExpansionStudHundredth', '-10000')
            fflag = true
        end
    }
    Functions.Motor = Functions.CFrame
    Phase = AkiraLite.Catalogs.Player:AddModule({
        Name = 'Phase',
        Function = function(callback)
            if callback then
                Phase:Clean(RunService.Stepped:Connect(function()
                    if entitylib.isAlive then
                        local action = Functions[Mode.Value]
                        if action then
                            pcall(action)
                        end
                    end
                end))
                if Mode.Value == 'FFlag' then
                    Phase:Clean(lplr.OnTeleport:Connect(function()
                        teleported = true
                        setFFlag('AssemblyExtentsExpansionStudHundredth', '30')
                    end))
                end
            else
                if fflag then
                    setFFlag('AssemblyExtentsExpansionStudHundredth', '30')
                end
                for part in modified do
                    part.CanCollide = true
                end
                table.clear(modified)
                fflag = nil
            end
        end
    })
    Mode = Phase:AddDropdown({
        Name = 'Mode',
        List = {'Part', 'Character', 'CFrame', 'Motor', 'FFlag'},
        Function = function(val)
            if StudLimit then
                StudLimit.Frame.Visible = val == 'CFrame' or val == 'Motor'
            end
            if fflag then
                setFFlag('AssemblyExtentsExpansionStudHundredth', '30')
            end
            for part in modified do
                part.CanCollide = true
            end
            table.clear(modified)
            fflag = nil
        end
    })
    StudLimit = Phase:AddSlider({
        Name = 'Wall Size',
        Min = 1,
        Max = 20,
        Default = 5,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end,
        Darker = true,
        Visible = false
    })
end)
    akiraMark("block9:done")
    akiraMark("block10:start")
run(function()
    local Mode
    local Value
    local State
    local rayCheck = RaycastParams.new()
    rayCheck.RespectCanCollide = true
    local Active, Truss
    Spider = AkiraLite.Catalogs.Movement:AddModule({
        Name = 'Spider',
        Function = function(callback)
            if callback then
                if Truss then
                    Truss.Parent = gameCamera
                end
                Spider:Clean(RunService.PreSimulation:Connect(function(dt)
                    if entitylib.isAlive then
                        local root = lplr.Character.PrimaryPart or entitylib.character.RootPart
                        local chars = {gameCamera, lplr.Character, Truss}
                        for _, v in entitylib.List do
                            table.insert(chars, v.Character)
                        end
                        SpiderShift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                        rayCheck.FilterDescendantsInstances = chars
                        rayCheck.CollisionGroup = root.CollisionGroup
                        if Mode.Value ~= 'Part' then
                            local vec = entitylib.character.Humanoid.MoveDirection * 2.5
                            local ray = workspace:Raycast(root.Position - Vector3.new(0, entitylib.character.HipHeight - 0.5, 0), vec, rayCheck)
                            if Active and not ray then
                                root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                            end
                            Active = ray
                            if Active and ray.Normal.Y == 0 then
                                if not Phase.Enabled or not SpiderShift then
                                    if State.Enabled then
                                        entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
                                    end
                                    root.Velocity *= Vector3.new(1, 0, 1)
                                    if Mode.Value == 'CFrame' then
                                        root.CFrame += Vector3.new(0, Value.Value * dt, 0)
                                    elseif Mode.Value == 'Impulse' then
                                        root:ApplyImpulse(Vector3.new(0, Value.Value, 0) * root.AssemblyMass)
                                    else
                                        root.Velocity += Vector3.new(0, Value.Value, 0)
                                    end
                                end
                            end
                        else
                            local ray = workspace:Raycast(root.Position - Vector3.new(0, entitylib.character.HipHeight - 0.5, 0), entitylib.character.RootPart.CFrame.LookVector * 2, rayCheck)
                            if ray and (not Phase.Enabled or not SpiderShift) then
                                Truss.Position = ray.Position - ray.Normal * 0.9 or Vector3.zero
                            else
                                Truss.Position = Vector3.zero
                            end
                        end
                    end
                end))
            else
                if Truss then
                    Truss.Parent = nil
                end
                SpiderShift = false
            end
        end
    })
    Mode = Spider:AddDropdown({
        Name = 'Mode',
        List = {'Velocity', 'Impulse', 'CFrame', 'Part'},
        Function = function(val)
            Value.Frame.Visible = val ~= 'Part'
            State.Frame.Visible = val ~= 'Part'
            if Truss then
                Truss:Destroy()
                Truss = nil
            end
            if val == 'Part' then
                Truss = Instance.new('TrussPart')
                Truss.Size = Vector3.new(2, 2, 2)
                Truss.Transparency = 1
                Truss.Anchored = true
                Truss.Parent = Spider.Enabled and gameCamera or nil
            end
        end
    })
    Value = Spider:AddSlider({
        Name = 'Speed',
        Min = 0,
        Max = 100,
        Default = 30,
        Darker = true,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    State = Spider:AddToggle({
        Name = 'Climb State',
        Darker = true
    })
end)
    akiraMark("block10:done")
    akiraMark("block11:start")
run(function()
    local SpinBot
    local Mode
    local XToggle
    local YToggle
    local ZToggle
    local Value
    local AngularVelocity
    SpinBot = AkiraLite.Catalogs.Movement:AddModule({
        Name = 'Spin',
        Function = function(callback)
            if callback then
                SpinBot:Clean(RunService.PreSimulation:Connect(function()
                    if entitylib.isAlive then
                        if Mode.Value == 'RotVelocity' then
                            local originalRotVelocity = entitylib.character.RootPart.RotVelocity
                            entitylib.character.Humanoid.AutoRotate = false
                            entitylib.character.RootPart.RotVelocity = Vector3.new(XToggle.Enabled and Value.Value or originalRotVelocity.X, YToggle.Enabled and Value.Value or originalRotVelocity.Y, ZToggle.Enabled and Value.Value or originalRotVelocity.Z)
                        elseif Mode.Value == 'CFrame' then
                            local val = math.rad((tick() * (20 * Value.Value)) % 360)
                            local x, y, z = entitylib.character.RootPart.CFrame:ToOrientation()
                            entitylib.character.RootPart.CFrame = CFrame.new(entitylib.character.RootPart.Position) * CFrame.Angles(XToggle.Enabled and val or x, YToggle.Enabled and val or y, ZToggle.Enabled and val or z)
                        elseif AngularVelocity then
                            AngularVelocity.Parent = entitylib.isAlive and entitylib.character.RootPart
                            AngularVelocity.MaxTorque = Vector3.new(XToggle.Enabled and math.huge or 0, YToggle.Enabled and math.huge or 0, ZToggle.Enabled and math.huge or 0)
                            AngularVelocity.AngularVelocity = Vector3.new(Value.Value, Value.Value, Value.Value)
                        end
                    end
                end))
            else
                if entitylib.isAlive and Mode.Value == 'RotVelocity' then
                    entitylib.character.Humanoid.AutoRotate = true
                end
                if AngularVelocity then
                    AngularVelocity.Parent = nil
                end
            end
        end
    })
    Mode = SpinBot:AddDropdown({
        Name = 'Mode',
        List = {'CFrame', 'RotVelocity', 'BodyMover'},
        Function = function(val)
            if AngularVelocity then
                AngularVelocity:Destroy()
                AngularVelocity = nil
            end
            AngularVelocity = val == 'BodyMover' and Instance.new('BodyAngularVelocity') or nil
        end
    })
    Value = SpinBot:AddSlider({
        Name = 'Speed',
        Min = 1,
        Max = 100,
        Default = 40
    })
    XToggle = SpinBot:AddToggle({
        Name = 'Spin X'
    })
    YToggle = SpinBot:AddToggle({
        Name = 'Spin Y',
        Default = true
    })
    ZToggle = SpinBot:AddToggle({
        Name = 'Spin Z'
    })
end)
    akiraMark("block11:done")
    akiraMark("block12:start")
run(function()
    local Tracers
    local Targets
    local Color
    local Transparency
    local StartPosition
    local EndPosition
    local Teammates
    local DistanceColor
    local Distance
    local DistanceLimit
    local Behind
    local ColorMode
    local CustomColor
    local Reference = {}
    -- Added() calls Removed() before Removed is defined below, which made that
    -- call a nil global; forward declared so the tracer refresh cannot throw.
    local Removed
    local function tracerColor(ent)
        local fallback = CustomColor and CustomColor.Value or uipalette.FinalColor
        if ColorMode and ColorMode.Value == "Team" then
            return entitylib.getEntityColor(ent) or fallback
        elseif ColorMode and ColorMode.Value == "Rainbow" then
            return Color3.fromHSV((tick() * 0.1 + (ent and ent.Player and ent.Player.UserId or 0) * 0.00001) % 1, 0.85, 1)
        end
        return fallback
    end
    local function Added(ent)
        if not ent or not ent.Player or not ent.Character then
            return
        end
        if Reference[ent] then
            Removed(ent)
        end
        if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then
            return
        end
        if AkiraLite.ThreadFix then
            setThreadIdentity(8)
        end
        local EntityTracer = Drawing.new('Line')
        EntityTracer.Thickness = 1
        EntityTracer.Transparency = Transparency.Value
        EntityTracer.Color = tracerColor(ent)
        Reference[ent] = EntityTracer
    end
    Removed = function(ent)
        local v = Reference[ent]
        if v then
            if AkiraLite.ThreadFix then
                setThreadIdentity(8)
            end
            Reference[ent] = nil
            pcall(function()
                v.Visible = false
                v:Remove()
            end)
        end
    end
    local function Loop()
        local screenSize = AkiraLite.MainScreenGui.AbsoluteSize
        local startVector = StartPosition.Value == 'Mouse' and UserInputService:GetMouseLocation() or Vector2.new(screenSize.X / 2, (StartPosition.Value == 'Middle' and screenSize.Y / 2 or screenSize.Y))
        -- hoisted out of the per-entity loop: this walked entitylib.isAlive and
        -- entitylib.character.RootPart once per tracer, every frame
        local localRoot = entitylib.isAlive and entitylib.character and entitylib.character.RootPart
        for ent, EntityTracer in Reference do
            if not ent or not ent.Character or not ent.RootPart or not EntityTracer then
                if ent then
                    Removed(ent)
                end
                continue
            end
            local localRootPos = localRoot and localRoot.Position
            local distance = localRootPos and (localRootPos - ent.RootPart.Position).Magnitude
            if Distance.Enabled and distance then
                if distance > DistanceLimit.Value then
                    EntityTracer.Visible = false
                    continue
                end
            end
            local pos = ent[EndPosition.Value == 'Torso' and 'RootPart' or 'Head'].Position
            local rootPos, rootVis = gameCamera:WorldToViewportPoint(pos)
            if not rootVis and Behind.Enabled then
                local tempPos = gameCamera.CFrame:PointToObjectSpace(pos)
                tempPos = CFrame.Angles(0, 0, (math.atan2(tempPos.Y, tempPos.X) + math.pi)):VectorToWorldSpace((CFrame.Angles(0, math.rad(89.9), 0):VectorToWorldSpace(Vector3.new(0, 0, - 1))))
                rootPos = gameCamera:WorldToViewportPoint(gameCamera.CFrame:pointToWorldSpace(tempPos))
                rootVis = true
            end
            local endVector = Vector2.new(rootPos.X, rootPos.Y)
            EntityTracer.Visible = rootVis
            EntityTracer.From = startVector
            EntityTracer.To = endVector
            EntityTracer.Color = tracerColor(ent)
        end
    end
    Tracers = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Tracers',
        Function = function(callback)
            if callback then
                Tracers:Clean(entitylib.Events.EntityRemoved:Connect(Removed))
                for _, v in entitylib.List do
                    if Reference[v] then
                        Removed(v)
                    end
                    Added(v)
                end
                Tracers:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
                    if Reference[ent] then
                        Removed(ent)
                    end
                    Added(ent)
                end))
                Tracers:Clean(RunService.RenderStepped:Connect(Loop))
            else
                for i in Reference do
                    Removed(i)
                end
            end
        end
    })
    StartPosition = Tracers:AddDropdown({
        Name = 'Start Position',
        List = {'Middle', 'Bottom', 'Mouse'},
        Function = function()
            if Tracers.Enabled then
                Tracers:Toggle()
                Tracers:Toggle()
            end
        end
    })
    EndPosition = Tracers:AddDropdown({
        Name = 'End Position',
        List = {'Head', 'Torso'},
        Function = function()
            if Tracers.Enabled then
                Tracers:Toggle()
                Tracers:Toggle()
            end
        end
    })
    Transparency = Tracers:AddSlider({
        Name = 'Transparency',
        Min = 0,
        Max = 1,
        Default = 0,
        Function = function(val)
            for _, tracer in Reference do
                tracer.Transparency = val
            end
        end,
        Decimal = 10
    })
    Distance = Tracers:AddToggle({
        Name = 'Distance Check',
        Function = function(callback)
            DistanceLimit.Frame.Visible = callback
        end
    })
    DistanceLimit = Tracers:AddSlider({
        Name = 'Player Distance',
        Min = 0,
        Max = 256,
        Default = 64,
        Darker = true,
        Visible = false
    })
    ColorMode = Tracers:AddDropdown({
        Name = 'Color Mode',
        List = {'Team', 'Custom', 'Rainbow'},
        Function = function()
            for ent, tracer in Reference do
                tracer.Color = tracerColor(ent)
            end
        end,
        Darker = true
    })
    CustomColor = Tracers:AddColorPicker({
        Name = 'Custom Color',
        Default = Color3.fromRGB(255, 255, 255),
        Function = function()
            for ent, tracer in Reference do
                tracer.Color = tracerColor(ent)
            end
        end,
        Darker = true
    })
    Behind = Tracers:AddToggle({
        Name = 'Behind',
        Default = true
    })
    Teammates = Tracers:AddToggle({
        Name = 'Priority Only',
        Function = function()
            if Tracers.Enabled then
                Tracers:Toggle()
                Tracers:Toggle()
            end
        end,
        Default = true
    })
end)
    akiraMark("block12:done")
    akiraMark("block13:start")
run(function()
    local AntiRagdoll
    AntiRagdoll = AkiraLite.Catalogs.Other:AddModule({
        Name = 'AntiRagdoll',
        Function = function(callback)
            if entitylib.isAlive then
                entitylib.character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not callback)
            end
            if callback then
                AntiRagdoll:Clean(entitylib.Events.LocalAdded:Connect(function(char)
                    char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                end))
            end
        end
    })
end)
    akiraMark("block13:done")
    akiraMark("block14:start")
run(function()
    local Blink
    local Type
    local AutoSend
    local AutoSendLength
    local oldphys, oldsend
    Blink = AkiraLite.Catalogs.Other:AddModule({
        Name = 'Blink',
        Function = function(callback)
            if callback then
                local teleported
                Blink:Clean(lplr.OnTeleport:Connect(function()
                    setFFlag('S2PhysicsSenderRate', '15')
                    setFFlag('DataSenderRate', '60')
                    teleported = true
                end))
                repeat
                    local physicsrate, senderrate = '0', Type.Value == 'All' and '-1' or '60'
                    if AutoSend.Enabled and tick() % (AutoSendLength.Value + 0.1) > AutoSendLength.Value then
                        physicsrate, senderrate = '15', '60'
                    end
                    if physicsrate ~= oldphys or senderrate ~= oldsend then
                        setFFlag('S2PhysicsSenderRate', physicsrate)
                        setFFlag('DataSenderRate', senderrate)
                        oldphys, oldsend = physicsrate, senderrate
                    end
                    task.wait(0.03)
                until (not Blink.Enabled or teleported)
            else
                setFFlag('S2PhysicsSenderRate', '15')
                setFFlag('DataSenderRate', '60')
                oldphys, oldsend = nil, nil
            end
        end
    })
    Type = Blink:AddDropdown({
        Name = 'Type',
        List = {'Movement Only', 'All'}
    })
    AutoSend = Blink:AddToggle({
        Name = 'Auto send',
        Function = function(callback)
            AutoSendLength.Frame.Visible = callback
        end
    })
    AutoSendLength = Blink:AddSlider({
        Name = 'Send threshold',
        Min = 0,
        Max = 1,
        Decimal = 100,
        Darker = true,
        Visible = false,
        Suffix = function(val)
            return val == 1 and 'second' or 'seconds'
        end
    })
end)
    akiraMark("block14:done")
    akiraMark("block15:start")
run(function()
    local Xray
    local XrayTransparency
    local modified = {}
    local function modifyPart(v)
        if v:IsA('BasePart') and not modified[v] then
            modified[v] = v.LocalTransparencyModifier
            v.LocalTransparencyModifier = XrayTransparency and 1 - XrayTransparency.Value or 0.5
        end
    end
    Xray = AkiraLite.Catalogs.Render:AddModule({
        Name = 'XRay',
        Function = function(callback)
            if callback then
                Xray:Clean(workspace.DescendantAdded:Connect(modifyPart))
                Xray:Clean(task.spawn(function()
                    local scanned = 0
                    for _, v in ipairs(workspace:GetDescendants()) do
                        modifyPart(v)
                        scanned += 1
                        if scanned % 250 == 0 then
                            task.wait()
                        end
                    end
                end))
            else
                for i, original in pairs(modified) do
                    if i and i.Parent then
                        pcall(function()
                            i.LocalTransparencyModifier = original
                        end)
                    end
                end
                table.clear(modified)
            end
        end
    })
    XrayTransparency = Xray:AddSlider({
        Name = 'Transparency',
        Min = 0,
        Max = 1,
        Function = function(val)
            for i in modified do
                if i and i.Parent then
                    i.LocalTransparencyModifier = 1 - val
                end
            end
        end,
        Decimal = 100
    })
end)
    akiraMark("block15:done")
local mouseClicked
    akiraMark("block16:start")
run(function()
    local SilentAim
    local Mode
    local Range
    local HitChance
    local HeadshotChance
    local AutoFire
    local AutoFireShootDelay
    local AutoFireMode
    local CircleTransparency
    local CircleObject
    local CircleRender
    local Projectile
    local ProjectileSpeed
    local ProjectileGravity
    local ProjectileRaycast = RaycastParams.new()
    ProjectileRaycast.RespectCanCollide = true
    local fireoffset, rand, delayCheck = CFrame.identity, Random.new(), tick()
    local oldnamecall
    local hookDirection, hookOrigin, hookDirectionAt, hookDistance = nil, nil, 0, nil
    local hookRayBox = {}
    local function getTarget(origin, obj)
        if rand.NextNumber(rand, 0, 100) > (AutoFire.Enabled and 100 or HitChance.Value) then
            return
        end
        local targetPart = (rand.NextNumber(rand, 0, 100) < (AutoFire.Enabled and 100 or HeadshotChance.Value)) and 'Head' or 'RootPart'
        local ent = entitylib['Entity' .. Mode.Value]({
            Range = Range.Value,
            Wallcheck = true,
            Part = targetPart,
            Origin = origin,
            Players = true,
            NPCs = true
        })
        if ent then
            Targetinfo.Targets[ent] = tick() + 1
            if Projectile.Enabled then
                ProjectileRaycast.FilterDescendantsInstances = {gameCamera, ent.Character}
                ProjectileRaycast.CollisionGroup = ent[targetPart].CollisionGroup
            end
        end
        return ent, ent and ent[targetPart], origin
    end
    local Hooks = {
        ScreenPointToRay = function(args)
            -- This runs for EVERY ScreenPointToRay call the engine makes (camera,
            -- cursor, UI), and each call used to run a full entity scan with
            -- Wallcheck (a raycast per candidate) plus a fresh options table.
            -- The scan is now refreshed at ~100Hz and the resulting direction is
            -- reused for the calls in between; the Ray is still rebuilt whenever
            -- the caller passes a different distance, so the maths is unchanged.
            local now = os.clock()
            if hookDirection == nil or now - hookDirectionAt >= 0.01 then
                local ent, targetPart, origin = getTarget(gameCamera.CFrame.Position)
                if not ent then
                    hookDirection = nil
                    clearActiveTarget("SilentAim")
                    return
                end
                publishActiveTarget("SilentAim", ent, targetPart)
                local direction = CFrame.lookAt(origin, targetPart.Position)
                if Projectile.Enabled then
                    local calc = prediction.SolveTrajectory(origin, ProjectileSpeed.Value, ProjectileGravity.Value, targetPart.Position, targetPart.Velocity, workspace.Gravity, ent.HipHeight, nil, ProjectileRaycast)
                    if not calc then
                        return
                    end
                    direction = CFrame.lookAt(origin, calc)
                end
                hookDirection = direction
                hookOrigin = origin
                hookDirectionAt = now
                hookDistance = nil
            end
            local distance = args[3]
            if not hookRayBox[1] or distance ~= hookDistance then
                hookRayBox[1] = Ray.new(hookOrigin + (distance and hookDirection.LookVector * distance or Vector3.zero), hookDirection.LookVector)
                hookDistance = distance
            end
            return hookRayBox
        end
    }
    SilentAim = AkiraLite.Catalogs.Combat:AddModule({
        Name = 'Silent Aim',
        Function = function(callback)
            if CircleObject then
                CircleObject.Visible = callback and Mode.Value == 'Mouse'
            end
            if callback then
                -- Hoisted out of the hook. This metamethod intercepts EVERY
                -- method call on `game` for the whole engine, so every
                -- statement in here is paid on every call the game makes. It
                -- used to allocate a fresh {'ControlScript','ControlModule'}
                -- table and tostring() the caller on every single call.
                local skipCallers = {ControlScript = true, ControlModule = true}
                local namecallUnpack = table.unpack or unpack
                local namecallArgs = {}
                oldnamecall = hookmetamethod(game, '__namecall', function(...)
                    if getnamecallmethod() ~= 'ScreenPointToRay' then
                        return oldnamecall(...)
                    end
                    if checkcaller() then
                        return oldnamecall(...)
                    end
                    local calling = getcallingscript()
                    if calling and skipCallers[calling] then
                        return oldnamecall(...)
                    end
                    local self = ...
                    -- the args table is reused between calls: it is only read by
                    -- Hooks.ScreenPointToRay and unpacked straight back out, so
                    -- allocating a fresh {select(2, ...)} on every engine call was
                    -- pure garbage
                    local count = select('#', ...) - 1
                    local args = namecallArgs
                    for i = 1, count do
                        args[i] = select(i + 1, ...)
                    end
                    args.n = count
                    local res = Hooks.ScreenPointToRay(args)
                    if res then
                        return namecallUnpack(res)
                    end
                    return oldnamecall(self, namecallUnpack(args, 1, args.n))
                end)
                -- The entity scan is the expensive part, and the game calls
                -- ScreenPointToRay many times per frame (camera, cursor, UI).
                -- Scanning every player on each of those was a large, constant
                -- per-frame cost, so the scan is rate limited to ~50Hz. The
                -- firing path below still runs every frame.
                local lastSilentScan = 0
                local cachedSilentTarget
                repeat
                    local nowSilent = os.clock()
                    if AutoFire.Enabled and nowSilent - lastSilentScan >= 0.02 then
                        lastSilentScan = nowSilent
                        local origin = AutoFireMode.Value == 'Camera' and gameCamera.CFrame or entitylib.isAlive and entitylib.character.RootPart.CFrame or CFrame.identity
                        cachedSilentTarget = entitylib['Entity' .. Mode.Value]({
                            Range = Range.Value,
                            Wallcheck = true,
                            Part = 'Head',
                            Origin = (origin * fireoffset).Position,
                            Players = true,
                            NPCs = false
                        })
                        if cachedSilentTarget then
                            publishActiveTarget("SilentAim", cachedSilentTarget, cachedSilentTarget.Head)
                        else
                            clearActiveTarget("SilentAim")
                        end
                        if mouse1click and (isrbxactive or iswindowactive)() then
                            if cachedSilentTarget and canClick() then
                                if delayCheck < tick() then
                                    if mouseClicked then
                                        mouseUp()
                                        delayCheck = tick() + AutoFireShootDelay.Value
                                    else
                                        mouseDown()
                                    end
                                    mouseClicked = not mouseClicked
                                end
                            else
                                if mouseClicked then
                                    mouseUp()
                                end
                                mouseClicked = false
                            end
                        end
                    end
                    -- was a bare yield: a full spin of the loop every
                    -- scheduler tick. 0.006 keeps aim responsive at ~166Hz.
                    task.wait(0.006)
                until not SilentAim.Enabled
            else
                if oldnamecall then
                    hookmetamethod(game, '__namecall', oldnamecall)
                end
                oldnamecall = nil
            end
        end,
        ExtraText = function()
            return 'ScreenPointToRay'
        end
    })
    Mode = SilentAim:AddDropdown({
        Name = 'Mode',
        List = {'Mouse', 'Position'},
        Function = function(val)
            if CircleObject then
                CircleObject.Visible = SilentAim.Enabled and val == 'Mouse'
            end
        end
    })
    Range = SilentAim:AddSlider({
        Name = 'Range',
        Min = 1,
        Max = 1000,
        Default = 150,
        Function = function(val)
            if CircleObject then
                CircleObject.Radius = val
            end
        end,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    HitChance = SilentAim:AddSlider({
        Name = 'Hit Chance',
        Min = 0,
        Max = 100,
        Default = 85,
        Suffix = '%'
    })
    HeadshotChance = SilentAim:AddSlider({
        Name = 'Headshot Chance',
        Min = 0,
        Max = 100,
        Default = 65,
        Suffix = '%'
    })
    AutoFire = SilentAim:AddToggle({
        Name = 'AutoFire',
        Function = function(callback)
            AutoFireShootDelay.Frame.Visible = callback
            AutoFireMode.Frame.Visible = callback
        end
    })
    AutoFireShootDelay = SilentAim:AddSlider({
        Name = 'Delay',
        Min = 0,
        Max = 1,
        Decimal = 100,
        Visible = false,
        Darker = true,
        Suffix = function(val)
            return val == 1 and 'second' or 'seconds'
        end
    })
    AutoFireMode = SilentAim:AddDropdown({
        Name = 'Origin',
        List = {'RootPart', 'Camera'},
        Visible = false,
        Darker = true
    })
    SilentAim:AddToggle({
        Name = 'Range Circle',
        Function = function(callback)
            CircleTransparency.Frame.Visible = callback
            if CircleRender then
                CircleRender:Disconnect()
                CircleRender = nil
            end
            if callback then
                if not CircleObject then
                    CircleObject = Drawing.new('Circle')
                    CircleObject.Color = uipalette.FinalColor
                    CircleObject.NumSides = 100
                end
                CircleObject.Transparency = 1 - CircleTransparency.Value
                CircleRender = RunService.RenderStepped:Connect(function()
                    if CircleObject then
                        CircleObject.Position = UserInputService:GetMouseLocation()
                        CircleObject.Radius = Range.Value
                        CircleObject.Transparency = 1 - CircleTransparency.Value
                        CircleObject.Visible = SilentAim.Enabled and Mode.Value == 'Mouse'
                    end
                end)
                SilentAim:Clean(CircleRender)
            else
                pcall(function()
                    if CircleObject then
                        CircleObject.Visible = false
                        CircleObject:Remove()
                    end
                end)
                CircleObject = nil
            end
        end
    })
    CircleTransparency = SilentAim:AddSlider({
        Name = 'Transparency',
        Min = 0,
        Max = 1,
        Decimal = 10,
        Default = 0.5,
        Function = function(val)
            if CircleObject then
                CircleObject.Transparency = 1 - val
            end
        end,
        Darker = true,
        Visible = false
    })
    Projectile = SilentAim:AddToggle({
        Name = 'Projectile',
        Function = function(callback)
            ProjectileSpeed.Frame.Visible = callback
            ProjectileGravity.Frame.Visible = callback
        end
    })
    ProjectileSpeed = SilentAim:AddSlider({
        Name = 'Speed',
        Min = 1,
        Max = 1000,
        Default = 1000,
        Darker = true,
        Visible = false,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    ProjectileGravity = SilentAim:AddSlider({
        Name = 'Gravity',
        Min = 0,
        Max = 192.6,
        Default = 192.6,
        Darker = true,
        Visible = false
    })
end)
    akiraMark("block16:done")
    akiraMark("block17:start")
run(function()
    local TriggerBot
    local Targets
    local ShootDelay
    local Distance
    local rayCheck, delayCheck = RaycastParams.new(), tick()
    -- one filter table reused forever instead of a fresh one per call (the engine
    -- copies it on every assignment, so allocating per call was pure garbage)
    local triggerFilter = {lplr.Character, gameCamera}
    rayCheck.FilterDescendantsInstances = triggerFilter
    lplr.CharacterAdded:Connect(function(char)
        triggerFilter[1] = char
        rayCheck.FilterDescendantsInstances = triggerFilter
    end)
    local function getTriggerBotTarget()
        rayCheck.FilterDescendantsInstances = triggerFilter
        local ray = workspace:Raycast(gameCamera.CFrame.Position, gameCamera.CFrame.LookVector * Distance.Value, rayCheck)
        if ray and ray.Instance then
            for _, v in entitylib.List do
                if v.Targetable and v.Character and v.Player then
                    if ray.Instance:IsDescendantOf(v.Character) then
                        return entitylib.isVulnerable(v) and v
                    end
                end
            end
        end
    end
    TriggerBot = AkiraLite.Catalogs.Combat:AddModule({
        Name = 'Trigger Bot',
        Function = function(callback)
            if callback then
                repeat
                    if mouse1click and (isrbxactive or iswindowactive)() then
                        if getTriggerBotTarget() and canClick() then
                            if delayCheck < tick() then
                                if mouseClicked then
                                    mouseUp()
                                    delayCheck = tick() + ShootDelay.Value
                                else
                                    mouseDown()
                                end
                                mouseClicked = not mouseClicked
                            end
                        else
                            if mouseClicked then
                                mouseUp()
                            end
                            mouseClicked = false
                        end
                    end
                -- was a bare yield, i.e. a full raycast + entity scan + canClick
                -- every scheduler tick (~60+/s). 0.006 keeps it responsive at ~166Hz
                -- while cutting the per-frame cost by roughly two thirds.
                task.wait(0.006)
            until not TriggerBot.Enabled
            else
                if mouse1click and (isrbxactive or iswindowactive)() then
                    if mouseClicked then
                        mouseUp()
                    end
                end
                mouseClicked = false
            end
        end
    })
    ShootDelay = TriggerBot:AddSlider({
        Name = 'Delay',
        Min = 0,
        Max = 1,
        Decimal = 100,
        Suffix = function(val)
            return val == 1 and 'second' or 'seconds'
        end
    })
    Distance = TriggerBot:AddSlider({
        Name = 'Distance',
        Min = 0,
        Max = 1000,
        Default = 1000,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
end)
    akiraMark("block17:done")
    akiraMark("block18:start")
run(function()
    local FOV
    local Value
    local oldfov
    FOV = AkiraLite.Catalogs.Render:AddModule({
        Name = 'FOV',
        Function = function(callback)
            if callback then
                oldfov = gameCamera.FieldOfView
            repeat
                gameCamera.FieldOfView = Value.Value
                -- was a bare yield, writing a camera property on every
                -- scheduler tick. FOV does not need 60+Hz; 20Hz is identical
                -- to the eye and cuts the writes by two thirds.
                task.wait(0.05)
            until not FOV.Enabled
            else
                gameCamera.FieldOfView = oldfov
            end
        end
    })
    Value = FOV:AddSlider({
        Name = 'FOV',
        Min = 30,
        Max = 120
    })
end)
    akiraMark("block18:done")
    akiraMark("block19:start")
run(function()
    local TargetStrafe
    local Targets
    local SearchRange
    local StrafeRange
    local YFactor
    local WallCheck
    local rayCheck = RaycastParams.new()
    rayCheck.RespectCanCollide = true
    local module, old
    -- cached per-frame state for the moveFunction hook (see the note there)
    local STRAFE_DOWN = Vector3.new(0, -70, 0)
    local strafeFilter = {lplr.Character, gameCamera, nil}
    local strafeOptions = {Range = 1000, Wallcheck = false, Part = 'RootPart', Players = true, NPCs = false}
    local strafeTarget, strafeTargetAt, strafePos, strafeHasFloor = nil, 0, nil, false
    TargetStrafe = AkiraLite.Catalogs.Movement:AddModule({
        Name = 'Target Strafe',
        Function = function(callback)
            if callback then
                if not module then
                    local suc = pcall(function()
                        module = require(lplr.PlayerScripts.PlayerModule).controls
                    end)
                    if not suc then
                        module = {}
                    end
                end
                old = module.moveFunction
                local flymod, ang, oldent = AkiraLite.Modules.Fly or {
                    Enabled = false
                }
        module.moveFunction = function(self, vec, face)
            -- the game's per-frame move function. It used to run a full
            -- EntityPosition scan (fresh options table) plus up to FOUR spatial
            -- queries and a fresh raycast filter table on EVERY call. The target
            -- lookup and the filter are now cached, and the ground raycast is
            -- only re-run when the resolved position actually moved.
            local now = os.clock()
            local ent
            if not UserInputService:IsKeyDown(Enum.KeyCode.S) then
                if now - strafeTargetAt >= 0.05 then
                    strafeTargetAt = now
                    strafeOptions.Range = SearchRange.Value
                    strafeTarget = entitylib.EntityPosition(strafeOptions)
                end
                ent = strafeTarget
            end
            if ent then
                local root, targetPos = entitylib.character.RootPart, ent.RootPart.Position
                if strafeFilter[3] ~= ent.Character then
                    strafeFilter[1] = lplr.Character
                    strafeFilter[2] = gameCamera
                    strafeFilter[3] = ent.Character
                    rayCheck.FilterDescendantsInstances = strafeFilter
                end
                rayCheck.CollisionGroup = root.CollisionGroup
                if flymod.Enabled or workspace:Raycast(targetPos, STRAFE_DOWN, rayCheck) then
                    local factor, localPosition = 0, root.Position
                    if ent ~= oldent then
                        ang = math.deg(select(2, CFrame.lookAt(targetPos, localPosition):ToEulerAnglesYXZ()))
                        strafePos = nil
                    end
                    local yFactor = math.abs(localPosition.Y - targetPos.Y) * (YFactor.Value / 100)
                    local entityPos = Vector3.new(targetPos.X, localPosition.Y, targetPos.Z)
                    local newPos = entityPos + (CFrame.Angles(0, math.rad(ang), 0).LookVector * (StrafeRange.Value - yFactor))
                    local startRay, endRay = entityPos, newPos
                    if WallCheck and WallCheck.Enabled and workspace:Raycast(targetPos, (localPosition - targetPos), rayCheck) then
                        startRay, endRay = entityPos + (CFrame.Angles(0, math.rad(ang), 0).LookVector * (entityPos - localPosition).Magnitude), entityPos
                    end
                    local ray = workspace:Blockcast(CFrame.new(startRay), Vector3.new(1, entitylib.character.HipHeight + (root.Size.Y / 2), 1), (endRay - startRay), rayCheck)
                    if (localPosition - newPos).Magnitude < 3 or ray then
                        factor = (8 - math.min((localPosition - newPos).Magnitude, 3))
                        if ray then
                            newPos = ray.Position + (ray.Normal * 1.5)
                            factor = (localPosition - newPos).Magnitude > 3 and 0 or factor
                        end
                    end
                    -- the "is there floor under the new position" raycast only
                    -- needs re-running when that position actually changed
                    if newPos ~= strafePos then
                        strafePos = newPos
                        strafeHasFloor = workspace:Raycast(newPos, STRAFE_DOWN, rayCheck) ~= nil
                    end
                    if not flymod.Enabled and not strafeHasFloor then
                        newPos = entityPos
                        factor = 40
                    end
                            ang += factor % 360
                            vec = ((newPos - localPosition) * Vector3.new(1, 0, 1)).Unit
                            vec = vec == vec and vec or Vector3.zero
                            TargetStrafeVector = vec
                        else
                            ent = nil
                        end
                    end
                    TargetStrafeVector = ent and vec or nil
                    oldent = ent
                    if type(old) == "function" then
                        return old(self, vec, face)
                    end
                    return vec
                end
            else
                if module and old then
                    module.moveFunction = old
                end
                TargetStrafeVector = nil
            end
        end
    })
    SearchRange = TargetStrafe:AddSlider({
        Name = 'Search Range',
        Min = 1,
        Max = 30,
        Default = 24,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    StrafeRange = TargetStrafe:AddSlider({
        Name = 'Strafe Range',
        Min = 1,
        Max = 30,
        Default = 18,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    YFactor = TargetStrafe:AddSlider({
        Name = 'Y Factor',
        Min = 0,
        Max = 100,
        Default = 100,
        Suffix = '%'
    })
    WallCheck = TargetStrafe:AddToggle({
        Name = 'Wall Check',
        Default = false,
        Darker = true
    })
end)
    akiraMark("block19:done")
    akiraMark("block20:start")
run(function()
    local Shader
    local cacheLighting = {}
    local BlurEffect = Instance.new('BlurEffect')
    BlurEffect.Size = 6
    local ColorCorrectionEffect = Instance.new('ColorCorrectionEffect')
    ColorCorrectionEffect.Saturation = - 0.4
    local SnowEffect = Instance.new("Part")
    SnowEffect.Size = vector.create(200, 1, 200)
    SnowEffect.Transparency = 1
    SnowEffect.Anchored = true
    local SnowParticle = Instance.new("ParticleEmitter")    SnowParticle.EmissionDirection = "Bottom"
    -- Three cloned emitters at Rate 20000 meant 60,000 particles per second being
    -- simulated and rendered, which is easily several milliseconds of frame time
    -- on its own. 600 x3 keeps the same look at a fraction of the cost.
    SnowParticle.Rate = 600
    SnowParticle.Lifetime = NumberRange.new(3.5, 3.5)
    SnowParticle.Speed = NumberRange.new(50, 50)
    SnowParticle.Texture = "rbxassetid://92367298778210"
    SnowParticle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0.4)})
    SnowParticle.SpreadAngle = Vector2.new(70, 70)
    SnowParticle.Parent = SnowEffect
    SnowParticle:Clone().Parent = SnowEffect
    SnowParticle:Clone().Parent = SnowEffect
    local Time = {}
    local snowMovedAt = 0
    local SNOW_OFFSET = Vector3.new(0, 90, 0)
    Shader = AkiraLite.Catalogs.Other:AddModule({
        Name = 'Shader',
        Function = function(callback)
            if callback then
                if not AkiraLite.Modules.Lighting or not AkiraLite.Modules.Lighting.Enabled then
                    cacheLighting = {Lighting.Ambient; Lighting.Brightness; Lighting.ColorShift_Bottom; Lighting.ColorShift_Top; Lighting.EnvironmentDiffuseScale; Lighting.EnvironmentSpecularScale; Lighting.GlobalShadows; Lighting.OutdoorAmbient; Lighting.ShadowSoftness; Lighting.TimeOfDay; }
                else
                    cacheLighting = {}
                end
                Lighting.Ambient = Color3.fromRGB(94, 99, 188)
                Lighting.Brightness = 4
                Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
                Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
                Lighting.EnvironmentDiffuseScale = 1
                Lighting.EnvironmentSpecularScale = 1
                Lighting.GlobalShadows = true
                Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
                Lighting.ShadowSoftness = 3
                Lighting.TimeOfDay = (Time.Value or '00') .. ':30:00'
            SnowEffect.Parent = workspace
            Shader:Clean(RunService.RenderStepped:Connect(function()
                -- an anchored 200x1x200 part is in the spatial hash, so moving it
                -- forces a physics broadphase rebuild every frame. 20Hz is
                -- indistinguishable for falling snow.
                local now = os.clock()
                if entitylib.isAlive and now - snowMovedAt >= 0.05 then
                    snowMovedAt = now
                    SnowEffect.Position = entitylib.character.RootPart.Position + SNOW_OFFSET
                end
            end))
                BlurEffect.Parent = Lighting
                ColorCorrectionEffect.Parent = Lighting
            else
                if #cacheLighting > 0 then
                    Lighting.Ambient = cacheLighting[1]
                    Lighting.Brightness = cacheLighting[2]
                    Lighting.ColorShift_Bottom = cacheLighting[3]
                    Lighting.ColorShift_Top = cacheLighting[4]
                    Lighting.EnvironmentDiffuseScale = cacheLighting[5]
                    Lighting.EnvironmentSpecularScale = cacheLighting[6]
                    Lighting.GlobalShadows = cacheLighting[7]
                    Lighting.OutdoorAmbient = cacheLighting[8]
                    Lighting.ShadowSoftness = cacheLighting[9]
                    Lighting.TimeOfDay = cacheLighting[10]
                end
                SnowEffect.Parent = nil
                BlurEffect.Parent = nil
                ColorCorrectionEffect.Parent = nil
            end
        end,
        Default = false
    })
    Time = Shader:AddSlider({
        Name = 'Time',
        Min = 0,
        Max = 24,
        Default = 12,
        Function = function(val)
            if Shader.Enabled then
                Lighting.TimeOfDay = val .. ':00:00'
            end
        end
    })
end)
    akiraMark("block20:done")
    akiraMark("block21:start")
run(function()
    local AirJump
    local Velocity
    AirJump = AkiraLite.Catalogs.Player:AddModule({
        Name = "AirJump",
        Function = function(callback)
            if callback then
                AirJump:Clean(UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then
                        return
                    end
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
                        local holdThread = task.spawn(function()
            while AirJump.Enabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) do
                if entitylib.isAlive and lplr.Character and lplr.Character.PrimaryPart then
                    local PrimaryPart = lplr.Character.PrimaryPart
                    PrimaryPart.Velocity = vector.create(PrimaryPart.Velocity.X, Velocity.Value, PrimaryPart.Velocity.Z)
                end
                -- was a bare yield, i.e. a velocity write on every scheduler tick
                task.wait(0.01)
            end
                        end)
                        AirJump:Clean(holdThread)
                    end
                end))
                if UserInputService.TouchEnabled then
                    local Jumping = false
                    local JumpButton = lplr.PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
                    AirJump:Clean(JumpButton.MouseButton1Down:Connect(function()
                        Jumping = true
                    end))
                    AirJump:Clean(JumpButton.MouseButton1Up:Connect(function()
                        Jumping = false
                    end))
                    AirJump:Clean(RunService.RenderStepped:Connect(function()
                        if Jumping and entitylib.isAlive and lplr.Character then
                            local PrimaryPart = lplr.Character.PrimaryPart
                            PrimaryPart.Velocity = vector.create(PrimaryPart.Velocity.X, Velocity.Value, PrimaryPart.Velocity.Z)
                        end
                    end))
                end
            end
        end
    })
    Velocity = AirJump:AddSlider({
        Name = 'Velocity',
        Min = 50,
        Max = 300,
        Default = 50
    })
end)
    akiraMark("block21:done")
    akiraMark("block22:start")
run(function()
    local Trails
    local Texture
    local Lifetime
    local Thickness
    local Rate
    local Particle
    local ParticleMain
    Trails = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Trails',
        Function = function(callback)
            if callback then
                ParticleMain = Instance.new("Part")
                ParticleMain.Size = vector.create(0, 0, 0)
                ParticleMain.Transparency = 0
                ParticleMain.CanCollide = false
                ParticleMain.Anchored = true
                Particle = Instance.new('ParticleEmitter')
                Particle.EmissionDirection = "Bottom"
                Particle.Rate = 5
                Particle.Lifetime = NumberRange.new(3.5, 3.5)
                Particle.Speed = NumberRange.new(0, 0)
                Particle.Texture = "rbxassetid://84083457957085"
                Particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, Thickness.Value / 5), NumberSequenceKeypoint.new(0.02, Thickness.Value), NumberSequenceKeypoint.new(1, 0)})
                Particle.SpreadAngle = Vector2.new(0, 0)
                Particle.Parent = ParticleMain
                Trails:Clean(Particle)
                Trails:Clean(ParticleMain)
                Trails:Clean(RunService.RenderStepped:Connect(function(ent)
                    if entitylib.isAlive then
                        ParticleMain.Position = entitylib.character.RootPart.Position - vector.create(0, 1, 0)
                    end
                end))
                ParticleMain.Parent = workspace
            else
                Particle = nil
                ParticleMain = nil
            end
        end
    })
    Rate = Trails:AddSlider({
        Name = 'Rate',
        Min = 0,
        Max = 10,
        Default = 5,
        Decimal = 10,
        Function = function(val)
            if Particle then
                Particle.Rate = val
            end
        end
    })
    Lifetime = Trails:AddSlider({
        Name = 'Lifetime',
        Min = 1,
        Max = 5,
        Default = 3,
        Decimal = 10,
        Function = function(val)
            if Particle then
                Particle.Lifetime = NumberRange.new(val, val)
            end
        end,
        Suffix = function(val)
            return val == 1 and 'second' or 'seconds'
        end
    })
    Thickness = Trails:AddSlider({
        Name = 'Thickness',
        Min = 0,
        Max = 2,
        Default = 1,
        Decimal = 100,
        Function = function(val)
            if Particle then
                Particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, val), NumberSequenceKeypoint.new(1, 0)})
            end
        end,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
end)
    akiraMark("block22:done")

-- =========================================================================
-- AKIRALITE VIEWMODEL CHANGER & WEAPON / ARM CHAMS
-- =========================================================================
    akiraMark("block23:start")
run(function()
    local Viewmodel
    local OffsetToggle, OffsetX, OffsetY, OffsetZ
    local ArmChamsToggle, ArmMaterial, ArmColor, ArmTransparency
    local WeaponChamsToggle, WeaponMaterial, WeaponColor, WeaponTransparency
    local HitChamsToggle, HitChamsColor, HitChamsDuration
    local DisableTextures, NoMotion
    local _offsetFrames = {}
    local ViewmodelOffsetStep = "AkiraViewmodelOffset"
    local _hitUntil = 0
    local _lastHealth = nil

    local VM_MATERIALS = {
        ForceField = Enum.Material.ForceField,
        Neon = Enum.Material.Neon,
        Glass = Enum.Material.Glass,
        SmoothPlastic = Enum.Material.SmoothPlastic,
    }

    local VM_COLORS = {
        Cyan = Color3.fromRGB(53, 215, 199),
        White = Color3.fromRGB(255, 255, 255),
        Purple = Color3.fromRGB(180, 100, 255),
        Red = Color3.fromRGB(255, 65, 65),
        Green = Color3.fromRGB(65, 255, 100),
        Yellow = Color3.fromRGB(255, 220, 65),
        Pink = Color3.fromRGB(255, 110, 180),
        Blue = Color3.fromRGB(65, 140, 255),
        Black = Color3.fromRGB(30, 30, 30),
    }

    local _savedProps = {}
    local vmScopeCache = nil
    local _origShake = nil
    local _vmUpdateRestore = nil
    -- restoreAll() below calls restoreSprings(), which is defined further down.
    -- Without this forward declaration that call resolved to a nil GLOBAL and
    -- threw "attempt to call a nil value" (stack: restoreAll -> Function) every
    -- time the Viewmodel module was disabled.
    local restoreSprings

    -- Viewmodel offsetting helpers.
    --
    -- Offset must never be able to move the character itself. Any model that
    -- carries a Humanoid, or that lives under the local character, is skipped:
    -- moving a body root is what visually rips the arms off the model.
    local function isOffsettableModel(model)
        -- typeof(), NOT type(): Roblox returns "userdata" from type() for every
        -- instance, so `type(x) ~= "Instance"` is ALWAYS true and silently
        -- disabled the entire offset feature. This is the same trap that hid the
        -- mobile toggle button.
        if typeof(model) ~= "Instance" or not model:IsA("Model") then
            return false
        end
        if model:FindFirstChildOfClass("Humanoid") then
            return false
        end
        local character = lplr and lplr.Character
        if character then
            if model == character then
                return false
            end
            for _, ancestor in ipairs(model:GetAncestors()) do
                if ancestor == character then
                    return false
                end
            end
        end
        return true
    end

    local function offsettablePart(model)
        if not isOffsettableModel(model) then
            return nil
        end
        -- Part-level guard, because the model-level check is not enough: the
        -- viewmodel model handed to us can reference parts that really live on
        -- the character.
        --
        -- IMPORTANT: this must NOT reject parts by NAME. Live inspection shows
        -- the first-person viewmodel's own root is literally named
        -- "HumanoidRootPart" (Workspace.ViewModels.FirstPerson.<name>.<name>),
        -- so a name check silently disabled the entire offset feature. The only
        -- thing that must never be moved is the CHARACTER's own root instance.
        local character = lplr and lplr.Character
        local characterRoot
        if character then
            characterRoot = character:FindFirstChild("HumanoidRootPart")
        end
        local function partAllowed(part)
            if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
                return false
            end
            if part == characterRoot or part == character then
                return false
            end
            if character then
                for _, ancestor in ipairs(part:GetAncestors()) do
                    if ancestor == character then
                        return false
                    end
                end
            end
            return true
        end
        local part = model.PrimaryPart
        if partAllowed(part) then
            return part
        end
        for _, descendant in ipairs(model:GetDescendants()) do
            if partAllowed(descendant) then
                return descendant
            end
        end
        return nil
    end

    local function restoreOffset(entry)
        local part = entry and entry.Part
        if part and part.Parent then
            pcall(function()
                part.CFrame = entry.CFrame
            end)
        end
        if entry then
            entry.Written = nil
        end
    end

    local function saveProp(p, isPart)
        local s = { Transparency = p.Transparency }
        if isPart then
            s.Material = p.Material
            s.Color = p.Color
        end
        _savedProps[p] = s
    end

    local function restoreAll()
        if _vmUpdateRestore then
            local restore = _vmUpdateRestore
            _vmUpdateRestore = nil
            pcall(function()
                restore.module.Update = restore.original
            end)
        end
        restoreSprings()
        -- Assigning the table straight to PrimaryPart.CFrame threw (swallowed by
        -- the pcall) and left the viewmodel parked at its offset forever.
        for _, entry in pairs(_offsetFrames) do
            restoreOffset(entry)
        end
        -- Safe to clear HERE (unlike the per-frame disable path): the module is
        -- fully off, the game owns the arms again, and the next enable re-captures
        -- a genuine un-offset frame.
        table.clear(_offsetFrames)
        _hitUntil = 0
        _lastHealth = nil
        for p, s in pairs(_savedProps) do
            pcall(function()
                if p and p.Parent ~= nil then
                    if s.Material ~= nil then p.Material = s.Material end
                    if s.Color ~= nil then p.Color = s.Color end
                    if s.Transparency ~= nil then p.Transparency = s.Transparency end
                end
            end)
            _savedProps[p] = nil
        end
        if _origShake ~= nil then
            pcall(function()
                local lp = game:GetService("Players").LocalPlayer
                local psc = lp and lp:FindFirstChild("PlayerScripts") and lp.PlayerScripts:FindFirstChild("Controllers")
                local camMod = psc and psc:FindFirstChild("CameraController")
                if camMod then
                    local camCtrl = require(camMod)
                    if camCtrl then camCtrl._shake_enabled = _origShake end
                end
            end)
            _origShake = nil
        end
    end

    -- hoisted: isArmName is called for every descendant AND every ancestor of
    -- every viewmodel model on each getVMScopes() rebuild, and it used to
    -- allocate this 9-element table on every single call
    local ARM_NAME_KEYS = { "arm", "hand", "sleeve", "elbow", "wrist", "shoulder", "finger", "thumb", "glove" }
    local function isArmName(name)
        if type(name) ~= "string" then return false end
        name = string.lower(name)
        for i = 1, 9 do
            if string.find(name, ARM_NAME_KEYS[i], 1, true) then return true end
        end
        return false
    end

    local function isArmPart(part, rootModel)
        if isArmName(part.Name) then return true end
        local cur = part.Parent
        while cur and cur ~= rootModel and cur ~= workspace do
            if isArmName(cur.Name) then return true end
            cur = cur.Parent
        end
        return false
    end

    local springOriginals = {}
    -- one shared pcall trampoline: freezeSpring used to allocate a closure on
    -- every call, and it runs ~18 times per frame while No Motion is on
    local function freezeSpringUnsafe(spring, targetVal)
        if springOriginals[spring] == nil then
            springOriginals[spring] = {
                Value = spring.Value,
                Position = spring.Position,
                Target = spring.Target,
                Goal = spring.Goal,
                Velocity = spring.Velocity
            }
        end
        if spring.Value ~= nil then spring.Value = targetVal end
        if spring.Position ~= nil then spring.Position = targetVal end
        if spring.Target ~= nil then spring.Target = targetVal end
        if spring.Goal ~= nil then spring.Goal = targetVal end
        if spring.Velocity ~= nil then
            if typeof(targetVal) == "Vector3" then spring.Velocity = Vector3.zero
            elseif typeof(targetVal) == "Vector2" then spring.Velocity = Vector2.zero
            else spring.Velocity = 0 end
        end
    end
    local function freezeSpring(spring, targetVal)
        if not spring then return end
        pcall(freezeSpringUnsafe, spring, targetVal)
    end

    -- the six camera springs, frozen under a single pcall
    local function freezeCameraSprings(camCtrl)
        freezeSpringUnsafe(camCtrl._sway_spring, Vector2.zero)
        freezeSpringUnsafe(camCtrl._bobbing_speed_spring, 0)
        freezeSpringUnsafe(camCtrl._bobbing_value_spring, 0)
        freezeSpringUnsafe(camCtrl._leaning_spring, 0)
        freezeSpringUnsafe(camCtrl._jump_spring, 0)
        freezeSpringUnsafe(camCtrl._sliding_spring, 0)
    end

    -- resolved refs for the No Motion path, refreshed at most twice a second
    local noMotionRefs = {at = 0, character = nil, item = nil, camCtrl = nil}

    restoreSprings = function()
        for spring, original in pairs(springOriginals) do
            pcall(function()
                if original.Value ~= nil then spring.Value = original.Value end
                if original.Position ~= nil then spring.Position = original.Position end
                if original.Target ~= nil then spring.Target = original.Target end
                if original.Goal ~= nil then spring.Goal = original.Goal end
                if original.Velocity ~= nil then spring.Velocity = original.Velocity end
            end)
        end
        table.clear(springOriginals)
    end

    local function freezeViewModelMotion(vm)
        if type(vm) ~= "table" then return end
        pcall(function() vm._bobbing_tick = 0 end)
        freezeSpring(rawget(vm, "_sway_spring"), Vector2.zero)
        freezeSpring(rawget(vm, "_leaning_spring"), 0)
        freezeSpring(rawget(vm, "_sliding_spring"), 0)
        freezeSpring(rawget(vm, "_sprinting_spring"), 0)
        freezeSpring(rawget(vm, "_bobbing_speed_spring"), 0)
        freezeSpring(rawget(vm, "_bobbing_value_spring"), Vector2.zero)
        freezeSpring(rawget(vm, "_landing_spring"), 0)
        freezeSpring(rawget(vm, "_jump_spring"), 0)
        freezeSpring(rawget(vm, "_tilt_spring"), Vector2.zero)
        freezeSpring(rawget(vm, "_impulse_position_spring"), Vector3.zero)
        freezeSpring(rawget(vm, "_recoil_spring"), Vector3.zero)
        freezeSpring(rawget(vm, "_unrecoil_spring"), Vector3.zero)
        pcall(function()
            if type(vm.SetCustomSprintingEnabled) == "function" then
                vm:SetCustomSprintingEnabled(false)
            end
        end)
    end

    local function ensureViewModelUpdateHook()
        if _vmUpdateRestore then return end
        pcall(function()
            local lp = game:GetService("Players").LocalPlayer
            local psc = lp and lp:FindFirstChild("PlayerScripts")
            local clientVMModule = nil
            pcall(function()
                clientVMModule = require(game:GetService("ReplicatedStorage").Modules.ClientViewModel)
            end)
            if not clientVMModule and psc and psc:FindFirstChild("Modules") then
                pcall(function()
                    clientVMModule = require(psc.Modules.ClientViewModel)
                end)
            end
            if clientVMModule and type(clientVMModule.Update) == "function" then
                local origUpdate = clientVMModule.Update
                clientVMModule.Update = function(vm, dt, camData, offsets, ...)
                    if NoMotion and NoMotion.Enabled then
                        if type(camData) == "table" then
                            camData.MoveSpeed = 0
                            camData.JustLanded = false
                            camData.PlayerVelocity = Vector3.zero
                            camData.MoveVelocity = Vector3.zero
                            camData.IsSliding = false
                            camData.IsActuallySprinting = false
                        end
                        freezeViewModelMotion(vm)
                    end
                    local result = origUpdate(vm, dt, camData, offsets, ...)

                    -- The viewmodel offset is applied HERE, immediately after the
                    -- game has positioned the model, and nowhere else.
                    --
                    -- It used to be written from a RenderStepped callback, which
                    -- can never work: the game rewrites the viewmodel root's CFrame
                    -- every single frame, so our write was always clobbered a few
                    -- microseconds later. Verified live - a hand-written CFrame read
                    -- back correctly and was reset to the original position within
                    -- one frame. Doing it as the last step of the game's own update
                    -- is the only ordering that survives.
                    if OffsetToggle and OffsetToggle.Enabled then
                        local ox = OffsetX and OffsetX.Value or 0
                        local oy = OffsetY and OffsetY.Value or 0
                        local oz = OffsetZ and OffsetZ.Value or 0
                        if ox ~= 0 or oy ~= 0 or oz ~= 0 then
                            local model = type(vm) == "table"
                                and (rawget(vm, "Model") or rawget(vm, "_model"))
                                or (typeof(vm) == "Instance" and vm:IsA("Model") and vm or nil)
                            local root = model and model.PrimaryPart
                            if root and root:IsA("BasePart") then
                                pcall(function()
                                    root.CFrame = root.CFrame * CFrame.new(ox, oy, oz)
                                end)
                            end
                        end
                    end
                    return result
                end
                _vmUpdateRestore = {
                    module = clientVMModule,
                    original = origUpdate
                }
            end
        end)
    end

    local function getVMScopes()
        local now = os.clock()
        if vmScopeCache and (now - vmScopeCache.at) < 0.35 and vmScopeCache.character == (lplr and lplr.Character) then
            return vmScopeCache.armParts, vmScopeCache.wepParts, vmScopeCache.vmModels
        end
        local armParts = {}
        local wepParts = {}
        local vmModels = {}
        local seenArm = {}
        local seenWep = {}
        local seenVM = {}

        local function addArm(p)
            if p and p:IsA("BasePart") and not seenArm[p] then
                seenArm[p] = true
                table.insert(armParts, p)
            end
        end

        local function addWep(p)
            if p and (p:IsA("BasePart") or p:IsA("Decal") or p:IsA("Texture")) and not seenWep[p] then
                seenWep[p] = true
                table.insert(wepParts, p)
            end
        end

        local function addVM(m)
            if m and m:IsA("Model") and not seenVM[m] then
                seenVM[m] = true
                table.insert(vmModels, m)
            end
        end

        local lp = game:GetService("Players").LocalPlayer

        -- 1. ClientViewModel / EquippedItem (FIRST PERSON ONLY)
        pcall(function()
            local fc = rawget(rawget(AkiraLite, "Rivals") or {}, "Fighter")
            if not fc and lp and lp:FindFirstChild("PlayerScripts") then
                local psc = lp.PlayerScripts:FindFirstChild("Controllers")
                local mod = psc and psc:FindFirstChild("FighterController")
                if mod then pcall(function() fc = require(mod) end) end
            end
            local lf = fc and (fc.LocalFighter or (fc.GetFighter and fc:GetFighter(lp)))
            local item = lf and lf.EquippedItem
            if item then
                local vm = item.ViewModel or item._viewModel
                if type(vm) == "table" then
                    if typeof(vm.Model) == "Instance" and vm.Model:IsA("Model") then addVM(vm.Model) end
                    if typeof(vm._left_arm) == "Instance" then
                        for _, d in ipairs(vm._left_arm:GetDescendants()) do if d:IsA("BasePart") then addArm(d) end end
                        if vm._left_arm:IsA("BasePart") then addArm(vm._left_arm) end
                    end
                    if typeof(vm._right_arm) == "Instance" then
                        for _, d in ipairs(vm._right_arm:GetDescendants()) do if d:IsA("BasePart") then addArm(d) end end
                        if vm._right_arm:IsA("BasePart") then addArm(vm._right_arm) end
                    end
                    if typeof(vm.ArmsModel) == "Instance" then
                        for _, d in ipairs(vm.ArmsModel:GetDescendants()) do if d:IsA("BasePart") then addArm(d) end end
                    end
                    if typeof(vm.ItemModel) == "Instance" then
                        for _, d in ipairs(vm.ItemModel:GetDescendants()) do addWep(d) end
                    end
                end
            end
        end)

        -- 2. FirstPerson ViewModels folder in Workspace
        pcall(function()
            local vmFolder = workspace:FindFirstChild("ViewModels")
            local fp = vmFolder and vmFolder:FindFirstChild("FirstPerson")
            local searchFolders = { fp, workspace.CurrentCamera }
            local lpPrefix = lp and (lp.Name:lower() .. " -") or ""
            for _, folder in ipairs(searchFolders) do
                if folder then
                    for _, model in ipairs(folder:GetChildren()) do
                        local mn = model.Name:lower()
                        local isLocalVM = (lp and mn:find(lp.Name:lower(), 1, true)) or (lpPrefix ~= "" and mn:sub(1, #lpPrefix) == lpPrefix) or folder == fp
                        if isLocalVM and model:IsA("Model") then
                            addVM(model)
                            local itemVisual = model:FindFirstChild("ItemVisual")
                            for _, d in ipairs(model:GetDescendants()) do
                                if d:IsA("BasePart") then
                                    local dn = d.Name:lower()
                                    if dn ~= "humanoidrootpart" and dn ~= "rootpart" and dn ~= "hitbox" and dn ~= "camera" then
                                        if isArmPart(d, model) then
                                            addArm(d)
                                        elseif itemVisual and d:IsDescendantOf(itemVisual) then
                                            addWep(d)
                                        elseif not isArmPart(d, model) then
                                            addWep(d)
                                        end
                                    end
                                elseif (d:IsA("Decal") or d:IsA("Texture")) and not isArmPart(d, model) then
                                    addWep(d)
                                end
                            end
                        end
                    end
                end
            end
        end)

        vmScopeCache = {
            at = now,
            character = lplr and lplr.Character,
            armParts = armParts,
            wepParts = wepParts,
            vmModels = vmModels
        }
        return armParts, wepParts, vmModels
    end

    Viewmodel = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Viewmodel',
        Function = function(callback)
            if callback then
                if AkiraLite.ThreadFix then
                    pcall(setThreadIdentity, 8)
                end
                -- Viewmodel offset.
                --
                -- Verified live, and this is the only thing that works in this
                -- game: the per-frame positioning pass calls Update/SetParent on
                -- the viewmodel INSTANCE (hundreds of times a second), not on a
                -- module we can require. Two dead ends were proven first:
                --   * the offset written from a normal RenderStepped connection is
                --     overwritten microseconds later by the game,
                --   * RunService:BindToRenderStep does not exist in this executor,
                --     so a RenderPriority.Last bind silently did nothing.
                -- So we wrap the instance methods and apply the offset as the very
                -- last step, after the game has positioned the model. Each call
                -- multiplies onto the fresh transform, so it cannot compound.
                -- The offset itself is applied by the file-scope installer, which
                -- wraps the viewmodel instance's Update/SetParent methods: the game
                -- rewrites the root CFrame every frame, so writing it from a
                -- RenderStepped connection is discarded immediately.
                Viewmodel:Clean(RunService.Heartbeat:Connect(function()
                    if OffsetToggle and OffsetToggle.Enabled then
                        AKIRA_VM_OFFSET.x = OffsetX and OffsetX.Value or 0
                        AKIRA_VM_OFFSET.y = OffsetY and OffsetY.Value or 0
                        AKIRA_VM_OFFSET.z = OffsetZ and OffsetZ.Value or 0
                        installViewModelOffsetHook()
                    end
                end))
                installViewModelOffsetHook()
            Viewmodel:Clean(RunService.RenderStepped:Connect(function()
                local now = os.clock()
                local armParts, wepParts, vmModels = getVMScopes()
                local doOffset = OffsetToggle.Enabled
                local doArmChams = ArmChamsToggle.Enabled
                    local armMat = VM_MATERIALS[ArmMaterial.Value] or Enum.Material.ForceField
                    local armCol = VM_COLORS[ArmColor.Value] or Color3.fromRGB(53, 215, 199)
                    local armTr = ArmTransparency.Value
                    local doWepChams = WeaponChamsToggle.Enabled
                    local wepMat = VM_MATERIALS[WeaponMaterial.Value] or Enum.Material.ForceField
                    local wepCol = VM_COLORS[WeaponColor.Value] or Color3.fromRGB(255, 110, 180)
                    local wepTr = WeaponTransparency.Value
                    local doStrip = DisableTextures.Enabled

                    -- The actual offset is applied by the instance hook installed
                    -- above (inside the game's own per-frame Update/SetParent
                    -- pass). It is deliberately NOT written here: this connection
                    -- runs before the game repositions the model, so a write from
                    -- here was provably discarded every single frame.
                    if not doOffset then
                        for _, entry in pairs(_offsetFrames) do
                            restoreOffset(entry)
                        end
                    end

                    if doArmChams then
                        for _, p in ipairs(armParts) do
                            saveProp(p, true)
                            if p.Material ~= armMat then p.Material = armMat end
                            if p.Color ~= armCol then p.Color = armCol end
                            if p.Transparency ~= armTr then p.Transparency = armTr end
                        end
                    else
                        for _, p in ipairs(armParts) do
                            local snapshot = _savedProps[p]
                            if snapshot then
                                pcall(function()
                                    if snapshot.Material ~= nil then p.Material = snapshot.Material end
                                    if snapshot.Color ~= nil then p.Color = snapshot.Color end
                                    if snapshot.Transparency ~= nil then p.Transparency = snapshot.Transparency end
                                end)
                                _savedProps[p] = nil
                            end
                        end
                    end

                    if doWepChams then
                        for _, p in ipairs(wepParts) do
                            if p:IsA("BasePart") then
                                saveProp(p, true)
                                if p.Material ~= wepMat then p.Material = wepMat end
                                if p.Color ~= wepCol then p.Color = wepCol end
                                if p.Transparency ~= wepTr then p.Transparency = wepTr end
                            end
                        end
                    end

                    local localHumanoid = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                    if localHumanoid then
                        local health = localHumanoid.Health
                        if _lastHealth ~= nil and health < _lastHealth then
                            _hitUntil = tick() + (HitChamsDuration and HitChamsDuration.Value or 0.12)
                        end
                        _lastHealth = health
                    end
                    local hitActive = HitChamsToggle and HitChamsToggle.Enabled and tick() < _hitUntil
                    for _, p in ipairs(wepParts) do
                        if p:IsA("BasePart") then
                            if hitActive then
                                saveProp(p, true)
                                p.Color = HitChamsColor and HitChamsColor.Value or Color3.fromRGB(255, 70, 70)
                            elseif not doWepChams and not doStrip then
                                local snapshot = _savedProps[p]
                                if snapshot then
                                    pcall(function()
                                        if snapshot.Material ~= nil then p.Material = snapshot.Material end
                                        if snapshot.Color ~= nil then p.Color = snapshot.Color end
                                        if snapshot.Transparency ~= nil then p.Transparency = snapshot.Transparency end
                                    end)
                                    _savedProps[p] = nil
                                end
                            end
                        end
                    end

                    if doStrip then
                        for _, p in ipairs(wepParts) do
                            if p:IsA("Decal") or p:IsA("Texture") then
                                saveProp(p, false)
                                if p.Transparency ~= 1 then p.Transparency = 1 end
                            end
                        end
                    else
                        for _, p in ipairs(wepParts) do
                            if p:IsA("Decal") or p:IsA("Texture") then
                                local snapshot = _savedProps[p]
                                if snapshot then
                                    pcall(function()
                                        if snapshot.Transparency ~= nil then p.Transparency = snapshot.Transparency end
                                    end)
                                    _savedProps[p] = nil
                                end
                            end
                        end
                    end

                    -- No Motion suppression (fully hooks and freezes springs/bobbing)
                    if NoMotion.Enabled then
                        ensureViewModelUpdateHook()
                        -- the controller/camera modules and the item's viewmodel are
                        -- resolved ONCE (and refreshed only on respawn/weapon swap)
                        -- instead of re-running two FindFirstChild chains and a
                        -- require(camMod) on every single frame
                        local noMotion = noMotionRefs
                        if noMotion.at < (now or 0) or noMotion.character ~= lplr.Character then
                            noMotion.at = (now or 0) + 0.5
                            noMotion.character = lplr.Character
                            noMotion.item = nil
                            noMotion.camCtrl = nil
                            pcall(function()
                                local lp = game:GetService("Players").LocalPlayer
                                local fc = rawget(rawget(AkiraLite, "Rivals") or {}, "Fighter")
                                if not fc and lp and lp:FindFirstChild("PlayerScripts") then
                                    local psc = lp.PlayerScripts:FindFirstChild("Controllers")
                                    local mod = psc and psc:FindFirstChild("FighterController")
                                    if mod then pcall(function() fc = require(mod) end) end
                                end
                                local lf = fc and (fc.LocalFighter or (fc.GetFighter and fc:GetFighter(lp)))
                                local item = lf and lf.EquippedItem
                                if item then
                                    noMotion.item = item.ViewModel or item._viewModel
                                end
                                local psc = lp and lp:FindFirstChild("PlayerScripts") and lp.PlayerScripts:FindFirstChild("Controllers")
                                local camMod = psc and psc:FindFirstChild("CameraController")
                                if camMod then
                                    noMotion.camCtrl = require(camMod)
                                end
                            end)
                        end
                        local vm = noMotion.item
                        if vm then
                            freezeViewModelMotion(vm)
                        end
                        local camCtrl = noMotion.camCtrl
                        if camCtrl then
                            if _origShake == nil and camCtrl._shake_enabled ~= nil then
                                _origShake = camCtrl._shake_enabled
                            end
                            camCtrl._shake_enabled = false
                            -- one pcall for the whole batch instead of six
                            -- freshly allocated closures per frame
                            pcall(freezeCameraSprings, camCtrl)
                        end
                    end
                end))
            else
                restoreAll()
            end
        end
    })

    OffsetToggle = Viewmodel:AddToggle({
        Name = 'Offset',
        Default = false
    })
    OffsetX = Viewmodel:AddSlider({
        Name = 'Offset X',
        Min = -3,
        Max = 3,
        Default = 0,
        Decimal = 10,
        Darker = true
    })
    OffsetY = Viewmodel:AddSlider({
        Name = 'Offset Y',
        Min = -3,
        Max = 3,
        Default = 0,
        Decimal = 10,
        Darker = true
    })
    OffsetZ = Viewmodel:AddSlider({
        Name = 'Offset Z',
        Min = -3,
        Max = 3,
        Default = 0,
        Decimal = 10,
        Darker = true
    })

    -- published so the file-scope watchdog can install the instance hook even
    -- when the module's own enable path never runs
    AKIRA_VM_SOURCE = function()
        return OffsetToggle, OffsetX.Value, OffsetY.Value, OffsetZ.Value
    end
    _G.__akiraVmBlock = "afterOffsetSliders"
    AkiraLite.VmOffsetSource = AKIRA_VM_SOURCE
    _G.__akiraVmBlock = "afterSharedPublish"
    _G.__akiraVmOffset = function(x, y, z, on)
        if on ~= nil then
            OffsetToggle:Change(on)
        end
        if x ~= nil then
            OffsetX:Change(x)
        end
        if y ~= nil then
            OffsetY:Change(y)
        end
        if z ~= nil then
            OffsetZ:Change(z)
        end
        return OffsetToggle.Enabled, OffsetX.Value, OffsetY.Value, OffsetZ.Value
    end

    ArmChamsToggle = Viewmodel:AddToggle({
        Name = 'Arm Chams',
        Default = false
    })
    ArmMaterial = Viewmodel:AddDropdown({
        Name = 'Arm Material',
        List = {'ForceField', 'Neon', 'Glass', 'SmoothPlastic'},
        Darker = true
    })
    ArmColor = Viewmodel:AddDropdown({
        Name = 'Arm Color',
        List = {'Cyan', 'White', 'Purple', 'Red', 'Green', 'Yellow', 'Pink', 'Blue', 'Black'},
        Darker = true
    })
    ArmTransparency = Viewmodel:AddSlider({
        Name = 'Arm Transparency',
        Min = 0,
        Max = 1,
        Default = 0.5,
        Decimal = 10,
        Darker = true
    })

    WeaponChamsToggle = Viewmodel:AddToggle({
        Name = 'Weapon Chams',
        Default = false
    })
    WeaponMaterial = Viewmodel:AddDropdown({
        Name = 'Weapon Material',
        List = {'ForceField', 'Neon', 'Glass', 'SmoothPlastic'},
        Darker = true
    })
    WeaponColor = Viewmodel:AddDropdown({
        Name = 'Weapon Color',
        List = {'Pink', 'Cyan', 'White', 'Purple', 'Red', 'Green', 'Yellow', 'Blue', 'Black'},
        Darker = true
    })
    WeaponTransparency = Viewmodel:AddSlider({
        Name = 'Weapon Transparency',
        Min = 0,
        Max = 1,
        Default = 0.5,
        Decimal = 10,
        Darker = true
    })

    HitChamsToggle = Viewmodel:AddToggle({
        Name = 'Hit Chams',
        Default = false
    })
    HitChamsColor = Viewmodel:AddColorPicker({
        Name = 'Hit Color',
        Default = Color3.fromRGB(255, 70, 70),
        Darker = true
    })
    HitChamsDuration = Viewmodel:AddSlider({
        Name = 'Hit Duration',
        Min = 0.03,
        Max = 1,
        Default = 0.12,
        Decimal = 100,
        Darker = true
    })

    DisableTextures = Viewmodel:AddToggle({
        Name = 'Disable Textures',
        Default = false
    })

    NoMotion = Viewmodel:AddToggle({
        Name = 'No Motion',
        Default = false,
        Function = function(callback)
            if callback then
                return
            end
            if _vmUpdateRestore then
                local restore = _vmUpdateRestore
                _vmUpdateRestore = nil
                pcall(function()
                    restore.module.Update = restore.original
                end)
            end
            restoreSprings()
            if _origShake ~= nil then
                pcall(function()
                    local lp = game:GetService("Players").LocalPlayer
                    local psc = lp and lp:FindFirstChild("PlayerScripts") and lp.PlayerScripts:FindFirstChild("Controllers")
                    local camMod = psc and psc:FindFirstChild("CameraController")
                    if camMod then
                        local camCtrl = require(camMod)
                        if camCtrl then
                            camCtrl._shake_enabled = _origShake
                        end
                    end
                end)
                _origShake = nil
            end
        end
    })
end)
    akiraMark("block23:done")

-- =========================================================================
-- AKIRALITE CUSTOM CROSSHAIR
-- =========================================================================
-- =========================================================================
-- AKIRALITE WORLD VISUALS (PORTED FEATURES FROM HYDRA REFERENCE)
-- =========================================================================
-- scratch/world_catalog_snippet.lua
-- World Catalog for AkiraLite
    akiraMark("block24:start")
run(function()
    if not AkiraLite.Catalogs.World then return end

local Lighting = cloneref(game:GetService("Lighting"))
local function mouseMove(dx, dy)
    pcall(function()
        return mousemoverel(dx, dy)
    end)
end
local function mouseDown()
    pcall(function()
        return mouse1press()
    end)
end
local function mouseUp()
    pcall(function()
        return mouse1release()
    end)
end
local function setFFlag(name, value)
    return pcall(function()
        return setfflag(name, value)
    end)
end
local function getConnections(signal)
    local ok, list = pcall(function()
        return getconnections(signal)
    end)
    if ok and type(list) == "table" then
        return list
    end
    return {}
end
local function setThreadIdentity(identity)
    pcall(function()
        return setthreadidentity(identity)
    end)
end
    local SoundService = cloneref(game:GetService("SoundService"))
    local RunService = cloneref(game:GetService("RunService"))
    local Workspace = cloneref(game:GetService("Workspace"))

    -- Native state caching for clean restorations
    local _origLighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime = Lighting.ClockTime,
        Brightness = Lighting.Brightness,
        ColorShift_Top = Lighting.ColorShift_Top,
        ColorShift_Bottom = Lighting.ColorShift_Bottom,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        ExposureCompensation = Lighting.ExposureCompensation,
        FogColor = Lighting.FogColor,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        ShadowSoftness = Lighting.ShadowSoftness,
    }

    local SKY_PRESETS = {
        BetterSky = { SkyboxBk = "rbxassetid://591058823", SkyboxDn = "rbxassetid://591059876", SkyboxFt = "rbxassetid://591058104", SkyboxLf = "rbxassetid://591057861", SkyboxRt = "rbxassetid://591057625", SkyboxUp = "rbxassetid://591059642", StarCount = 3000 },
        BetterNight = { SkyboxBk = "rbxassetid://15470289121", SkyboxDn = "rbxassetid://15470291746", SkyboxFt = "rbxassetid://15470294431", SkyboxLf = "rbxassetid://15470297162", SkyboxRt = "rbxassetid://15470299887", SkyboxUp = "rbxassetid://15470303050", StarCount = 3000 },
        BetterNight2 = { SkyboxBk = "rbxassetid://248431616", SkyboxDn = "rbxassetid://248431677", SkyboxFt = "rbxassetid://248431598", SkyboxLf = "rbxassetid://248431686", SkyboxRt = "rbxassetid://248431611", SkyboxUp = "rbxassetid://248431605", StarCount = 3000 },
        BetterNight3 = { SkyboxBk = "rbxassetid://2670643994", SkyboxDn = "rbxassetid://2670643365", SkyboxFt = "rbxassetid://2670643214", SkyboxLf = "rbxassetid://2670643070", SkyboxRt = "rbxassetid://2670644173", SkyboxUp = "rbxassetid://2670644331", StarCount = 500 },
        Nebula3 = { SkyboxBk = "rbxassetid://17839210699", SkyboxDn = "rbxassetid://17839215896", SkyboxFt = "rbxassetid://17839218166", SkyboxLf = "rbxassetid://17839220800", SkyboxRt = "rbxassetid://17839223605", SkyboxUp = "rbxassetid://17839226876", StarCount = 3000 },
        PinkMountains = { SkyboxBk = "rbxassetid://17901353811", SkyboxDn = "rbxassetid://17901366771", SkyboxFt = "rbxassetid://17901356262", SkyboxLf = "rbxassetid://17901359687", SkyboxRt = "rbxassetid://17901362326", SkyboxUp = "rbxassetid://17901365106", StarCount = 3000 },
        DarkMountains = { SkyboxBk = "rbxassetid://5098814730", SkyboxDn = "rbxassetid://5098815227", SkyboxFt = "rbxassetid://5098815653", SkyboxLf = "rbxassetid://5098816155", SkyboxRt = "rbxassetid://5098820352", SkyboxUp = "rbxassetid://5098819127", StarCount = 3000 },
        Realistic = { SkyboxBk = "rbxassetid://402559900", SkyboxDn = "rbxassetid://402559927", SkyboxFt = "rbxassetid://402559953", SkyboxLf = "rbxassetid://402559983", SkyboxRt = "rbxassetid://402560019", SkyboxUp = "rbxassetid://402560052", StarCount = 3000 },
        Space = { SkyboxBk = "rbxassetid://159248188", SkyboxDn = "rbxassetid://159248183", SkyboxFt = "rbxassetid://159248187", SkyboxLf = "rbxassetid://159248173", SkyboxRt = "rbxassetid://159248192", SkyboxUp = "rbxassetid://159248176", StarCount = 3000 },
        Space2 = { SkyboxBk = "rbxassetid://179723991", SkyboxDn = "rbxassetid://179724005", SkyboxFt = "rbxassetid://179724018", SkyboxLf = "rbxassetid://179724029", SkyboxRt = "rbxassetid://179724037", SkyboxUp = "rbxassetid://179724054", StarCount = 3000 },
        Midnight = { SkyboxBk = "rbxassetid://154185004", SkyboxDn = "rbxassetid://154184960", SkyboxFt = "rbxassetid://154185021", SkyboxLf = "rbxassetid://154184943", SkyboxRt = "rbxassetid://154184972", SkyboxUp = "rbxassetid://154185031", StarCount = 3000 },
        Moon = { SkyboxBk = "rbxassetid://17489386489", SkyboxDn = "rbxassetid://17489387417", SkyboxFt = "rbxassetid://17489388310", SkyboxLf = "rbxassetid://17489389632", SkyboxRt = "rbxassetid://17489391101", SkyboxUp = "rbxassetid://17489393055", StarCount = 3000 },
        Retro = { SkyboxBk = "rbxassetid://16642396302", SkyboxDn = "rbxassetid://16642397027", SkyboxFt = "rbxassetid://16642398372", SkyboxLf = "rbxassetid://16642399309", SkyboxRt = "rbxassetid://16642400745", SkyboxUp = "rbxassetid://16642401907", StarCount = 3000 },
        FPSBoost = { SkyboxBk = "rbxassetid://0", SkyboxDn = "rbxassetid://0", SkyboxFt = "rbxassetid://0", SkyboxLf = "rbxassetid://0", SkyboxRt = "rbxassetid://0", SkyboxUp = "rbxassetid://0", StarCount = 0 },
        Galaxy = { SkyboxBk = "rbxassetid://159248188", SkyboxDn = "rbxassetid://159248183", SkyboxFt = "rbxassetid://159248187", SkyboxLf = "rbxassetid://159248173", SkyboxRt = "rbxassetid://159248192", SkyboxUp = "rbxassetid://159248176", StarCount = 5000 },
        Art = { SkyboxBk = "rbxassetid://9831762777", SkyboxDn = "rbxassetid://9831764283", SkyboxFt = "rbxassetid://9831766232", SkyboxLf = "rbxassetid://9831768023", SkyboxRt = "rbxassetid://9831768909", SkyboxUp = "rbxassetid://9831769868", StarCount = 3000 },
        Ame = { SkyboxBk = "rbxassetid://160185927", SkyboxDn = "rbxassetid://160185945", SkyboxFt = "rbxassetid://160186027", SkyboxLf = "rbxassetid://160186075", SkyboxRt = "rbxassetid://160186126", SkyboxUp = "rbxassetid://160186148", StarCount = 3000 },
        Dawn = { SkyboxBk = "rbxassetid://250381017", SkyboxDn = "rbxassetid://254156892", SkyboxFt = "rbxassetid://250380916", SkyboxLf = "rbxassetid://250380953", SkyboxRt = "rbxassetid://250380985", SkyboxUp = "rbxassetid://250381047", StarCount = 3000 },
        Alien = { SkyboxBk = "rbxassetid://159248188", SkyboxDn = "rbxassetid://159248183", SkyboxFt = "rbxassetid://159248187", SkyboxLf = "rbxassetid://159248173", SkyboxRt = "rbxassetid://159248192", SkyboxUp = "rbxassetid://159248176", StarCount = 0 },
        Lunar = { SkyboxBk = "rbxassetid://179723991", SkyboxDn = "rbxassetid://179724005", SkyboxFt = "rbxassetid://179724018", SkyboxLf = "rbxassetid://179724029", SkyboxRt = "rbxassetid://179724037", SkyboxUp = "rbxassetid://179724054", StarCount = 3000 },
    }

    local AMBIENCE_SOUNDS = {
        ['Heavy Rain'] = 'rbxassetid://9112853286',
        ['Rain On Window'] = 'rbxassetid://9112856394',
        ['Rain At 3 A.M.'] = 'rbxassetid://130699135921413',
        ['Ocean Surf'] = 'rbxassetid://9117143192',
        ['Howling Wind'] = 'rbxassetid://5516579371',
        ['Night Crickets'] = 'rbxassetid://9112764573',
        ['Cozy Fire'] = 'rbxassetid://150367086',
        ['Lofi Focus'] = 'rbxassetid://136419664364400',
    }

    local WEATHER_SPECS = {
        Snow = {
            {Texture = 'rbxassetid://119455261341623', BaseRate = 18, SpeedMin = 8, SpeedMax = 12, SizeStart = 0.025, SizeEnd = 0.05, TransparencyMax = 0.4, LifetimeMin = 4, LifetimeMax = 6, RotationMin = 0, RotationMax = 360, RotationSpeedMin = -25, RotationSpeedMax = 25, BaseSpread = 0.4, BaseAccelerationY = -3},
            {Texture = 'rbxassetid://135953828575052', BaseRate = 12, SpeedMin = 12, SpeedMax = 18, SizeStart = 0.03, SizeEnd = 0.08, TransparencyMax = 0.5, LifetimeMin = 3, LifetimeMax = 5, RotationMin = 0, RotationMax = 360, RotationSpeedMin = -35, RotationSpeedMax = 35, BaseSpread = 0.45, BaseAccelerationY = -4},
            {Texture = 'rbxassetid://119888390708774', BaseRate = 48, SpeedMin = 10, SpeedMax = 16, SizeStart = 0.06, SizeEnd = 0.13, TransparencyMax = 0.15, LifetimeMin = 4, LifetimeMax = 6, RotationMin = 0, RotationMax = 360, RotationSpeedMin = -90, RotationSpeedMax = 90, BaseSpread = 0.5, BaseAccelerationY = -2},
        },
        Rain = {
            {Texture = 'rbxassetid://1822883048', BaseRate = 550, SpeedMin = 135, SpeedMax = 180, SizeStart = 0.28, SizeEnd = 0.72, TransparencyMax = 0.15, LifetimeMin = 0.65, LifetimeMax = 0.85, RotationMin = 90, RotationMax = 90, RotationSpeedMin = 0, RotationSpeedMax = 0, BaseSpread = 0.03, BaseAccelerationY = -105, Orientation = Enum.ParticleOrientation.VelocityParallel, LightEmission = 0.12},
            {Texture = 'rbxassetid://113640658844067', BaseRate = 400, SpeedMin = 145, SpeedMax = 190, SizeStart = 0.22, SizeEnd = 0.58, TransparencyMax = 0.20, LifetimeMin = 0.60, LifetimeMax = 0.80, RotationMin = 90, RotationMax = 90, RotationSpeedMin = 0, RotationSpeedMax = 0, BaseSpread = 0.03, BaseAccelerationY = -120, Orientation = Enum.ParticleOrientation.VelocityParallel, LightEmission = 0.10},
        },
        ['Heavy Rain'] = {
            {Texture = 'rbxassetid://1822883048', BaseRate = 900, SpeedMin = 140, SpeedMax = 195, SizeStart = 0.32, SizeEnd = 0.85, TransparencyMax = 0.12, LifetimeMin = 0.65, LifetimeMax = 0.85, RotationMin = 90, RotationMax = 90, RotationSpeedMin = 0, RotationSpeedMax = 0, BaseSpread = 0.03, BaseAccelerationY = -120, Orientation = Enum.ParticleOrientation.VelocityParallel, LightEmission = 0.14},
            {Texture = 'rbxassetid://113640658844067', BaseRate = 700, SpeedMin = 150, SpeedMax = 205, SizeStart = 0.24, SizeEnd = 0.65, TransparencyMax = 0.15, LifetimeMin = 0.60, LifetimeMax = 0.80, RotationMin = 90, RotationMax = 90, RotationSpeedMin = 0, RotationSpeedMax = 0, BaseSpread = 0.025, BaseAccelerationY = -135, Orientation = Enum.ParticleOrientation.VelocityParallel, LightEmission = 0.12},
            {Texture = 'rbxassetid://1822883048', BaseRate = 450, SpeedMin = 130, SpeedMax = 175, SizeStart = 0.20, SizeEnd = 0.50, TransparencyMax = 0.22, LifetimeMin = 0.70, LifetimeMax = 0.90, RotationMin = 90, RotationMax = 90, RotationSpeedMin = 0, RotationSpeedMax = 0, BaseSpread = 0.04, BaseAccelerationY = -100, Orientation = Enum.ParticleOrientation.VelocityParallel, LightEmission = 0.10},
        },
        Blizzard = {
            {Texture = 'rbxassetid://119455261341623', BaseRate = 25, SpeedMin = 25, SpeedMax = 40, SizeStart = 0.025, SizeEnd = 0.06, TransparencyMax = 0.35, LifetimeMin = 2.5, LifetimeMax = 4, RotationMin = 0, RotationMax = 360, RotationSpeedMin = -45, RotationSpeedMax = 45, BaseSpread = 0.55, BaseAccelerationY = -8},
            {Texture = 'rbxassetid://135953828575052', BaseRate = 20, SpeedMin = 28, SpeedMax = 45, SizeStart = 0.035, SizeEnd = 0.09, TransparencyMax = 0.45, LifetimeMin = 2.2, LifetimeMax = 3.8, RotationMin = 0, RotationMax = 360, RotationSpeedMin = -55, RotationSpeedMax = 55, BaseSpread = 0.6, BaseAccelerationY = -10},
            {Texture = 'rbxassetid://119888390708774', BaseRate = 90, SpeedMin = 22, SpeedMax = 38, SizeStart = 0.07, SizeEnd = 0.15, TransparencyMax = 0.1, LifetimeMin = 2.8, LifetimeMax = 4.5, RotationMin = 0, RotationMax = 360, RotationSpeedMin = -120, RotationSpeedMax = 120, BaseSpread = 0.7, BaseAccelerationY = -7},
            {Texture = 'rbxassetid://1822883048', BaseRate = 50, SpeedMin = 55, SpeedMax = 80, SizeStart = 0.14, SizeEnd = 0.28, TransparencyMax = 0.2, LifetimeMin = 1.8, LifetimeMax = 2.6, RotationMin = -12, RotationMax = 12, RotationSpeedMin = 0, RotationSpeedMax = 0, BaseSpread = 0.5, BaseAccelerationY = -35},
        },
    }

    local COLOR_PALETTES = {
        Default = Color3.fromRGB(128, 128, 128),
        ['Soft White'] = Color3.fromRGB(200, 200, 200),
        Daylight = Color3.fromRGB(240, 235, 220),
        ['Warm Sunset'] = Color3.fromRGB(255, 160, 90),
        ['Cyber Cyan'] = Color3.fromRGB(60, 210, 255),
        ['Neon Purple'] = Color3.fromRGB(180, 70, 255),
        ['Midnight Blue'] = Color3.fromRGB(40, 55, 100),
        ['Pitch Dark'] = Color3.fromRGB(10, 10, 15),
        White = Color3.fromRGB(255, 255, 255),
        ['Soft Grey'] = Color3.fromRGB(180, 180, 180),
        Midnight = Color3.fromRGB(30, 40, 70),
        Sunset = Color3.fromRGB(255, 120, 60),
        Purple = Color3.fromRGB(160, 80, 240),
        Crimson = Color3.fromRGB(220, 30, 50),
        Cyan = Color3.fromRGB(40, 220, 240),
        ['Toxic Green'] = Color3.fromRGB(80, 240, 90),
    }

    -- Active world instances
    local _ownedSky = nil
    local _ownedSound = nil
    local _weatherPart = nil
    local _weatherEmitters = {}
    local _weatherConn = nil
    local _bloomEffect = nil
    local _ccEffect = nil
    local _sunRaysEffect = nil
    local applySkyRef
    local setupWeatherRef
    local function safeApplySky(name)
        if type(applySkyRef) == "function" then
            pcall(applySkyRef, name)
        end
    end
    local function toggleModule(module, want)
        if type(module) ~= "table" then
            return false
        end
        local enabled = module.Enabled == true
        if enabled == want then
            return false
        end
        if type(module.SetEnabled) == "function" then
            pcall(function()
                module:SetEnabled(want)
            end)
            return true
        end
        if type(module.Toggle) == "function" then
            pcall(module.Toggle, module)
            return true
        end
        return false
    end
    local function safeSetupWeather(name)
        if type(setupWeatherRef) == "function" then
            pcall(setupWeatherRef, name)
        end
    end

    -- 1. PRESETS MODULE
    local Presets = __worldStub({
        Name = 'Presets',
        Function = function(callback)
            if not callback then
                for _, moduleName in ipairs({'Lighting', 'Fog & Atmosphere', 'Skybox', 'Post Processing', 'Weather', 'Ambience'}) do
                    local module = AkiraLite.Modules[moduleName]
                    if module and module.Enabled then
                        module:Toggle()
                    end
                end
            end
        end
    })

    local LightingModule = __worldStub({
        Name = 'Lighting',
        Function = function(callback)
            if not callback then
                pcall(function()
                    Lighting.Ambient = _origLighting.Ambient
                    Lighting.OutdoorAmbient = _origLighting.OutdoorAmbient
                    Lighting.ClockTime = _origLighting.ClockTime
                    Lighting.Brightness = _origLighting.Brightness
                    Lighting.ColorShift_Top = _origLighting.ColorShift_Top
                    Lighting.ColorShift_Bottom = _origLighting.ColorShift_Bottom
                    Lighting.EnvironmentDiffuseScale = _origLighting.EnvironmentDiffuseScale
                    Lighting.EnvironmentSpecularScale = _origLighting.EnvironmentSpecularScale
                    Lighting.ExposureCompensation = _origLighting.ExposureCompensation
                    Lighting.GlobalShadows = _origLighting.GlobalShadows
                    Lighting.ShadowSoftness = _origLighting.ShadowSoftness
                end)
            end
        end
    })

    local ClockTime = LightingModule:AddSlider({
        Name = 'Clock Time',
        Min = 0,
        Max = 24,
        Default = 14,
        Decimal = 10,
        Function = function(val)
            if LightingModule.Enabled then Lighting.ClockTime = val end
        end
    })
    local Brightness = LightingModule:AddSlider({
        Name = 'Brightness',
        Min = 0,
        Max = 10,
        Default = 2,
        Decimal = 10,
        Function = function(val)
            if LightingModule.Enabled then Lighting.Brightness = val end
        end
    })
    local Exposure = LightingModule:AddSlider({
        Name = 'Exposure',
        Min = -5,
        Max = 5,
        Default = 0,
        Decimal = 10,
        Function = function(val)
            if LightingModule.Enabled then Lighting.ExposureCompensation = val end
        end
    })
    local DiffuseScale = LightingModule:AddSlider({
        Name = 'Diffuse Scale',
        Min = 0,
        Max = 1,
        Default = 1,
        Decimal = 10,
        Function = function(val)
            if LightingModule.Enabled then Lighting.EnvironmentDiffuseScale = val end
        end
    })
    local SpecularScale = LightingModule:AddSlider({
        Name = 'Specular Scale',
        Min = 0,
        Max = 1,
        Default = 1,
        Decimal = 10,
        Function = function(val)
            if LightingModule.Enabled then Lighting.EnvironmentSpecularScale = val end
        end
    })
    local DisableShadows = LightingModule:AddToggle({
        Name = 'Disable Shadows',
        Default = false,
        Function = function(val)
            if LightingModule.Enabled then Lighting.GlobalShadows = not val end
        end
    })
    local ShadowSoftness = LightingModule:AddSlider({
        Name = 'Shadow Softness',
        Min = 0,
        Max = 1,
        Default = 0.5,
        Decimal = 10,
        Function = function(val)
            if LightingModule.Enabled then Lighting.ShadowSoftness = val end
        end
    })
    local AmbientColor = LightingModule:AddDropdown({
        Name = 'Indoor Ambient',
        List = {'Default', 'Soft White', 'Daylight', 'Warm Sunset', 'Cyber Cyan', 'Neon Purple', 'Midnight Blue', 'Pitch Dark'},
        Function = function(val)
            if LightingModule.Enabled and COLOR_PALETTES[val] then Lighting.Ambient = COLOR_PALETTES[val] end
        end
    })
    local OutdoorAmbientColor = LightingModule:AddDropdown({
        Name = 'Outdoor Ambient',
        List = {'Default', 'Soft White', 'Daylight', 'Warm Sunset', 'Cyber Cyan', 'Neon Purple', 'Midnight Blue', 'Pitch Dark'},
        Function = function(val)
            if LightingModule.Enabled and COLOR_PALETTES[val] then Lighting.OutdoorAmbient = COLOR_PALETTES[val] end
        end
    })
    LightingModule:AddDropdown({
        Name = 'Shadow Color',
        List = {'Default', 'Soft Grey', 'Pitch Dark', 'Warm Sunset', 'Cyber Cyan', 'Neon Purple', 'Crimson'},
        Function = function(val)
            if LightingModule.Enabled and COLOR_PALETTES[val] then
                Lighting.ShadowColor = COLOR_PALETTES[val]
            end
        end
    })
    LightingModule:AddDropdown({
        Name = 'Color Shift Top',
        List = {'Default', 'Soft White', 'Daylight', 'Midnight Blue', 'Pitch Dark', 'Neon Purple', 'Crimson'},
        Function = function(val)
            if LightingModule.Enabled and COLOR_PALETTES[val] then
                Lighting.ColorShift_Top = COLOR_PALETTES[val]
            end
        end
    })

    -- 2. FOG & ATMOSPHERE
    local AtmosphereDensity, AtmosphereHaze
    local ownedAtmosphere
    local function ensureAtmosphere()
        local existing = Lighting:FindFirstChildOfClass("Atmosphere")
        if existing then
            ownedAtmosphere = nil
            return existing
        end
        ownedAtmosphere = Instance.new("Atmosphere")
        ownedAtmosphere.Name = "AkiraLiteAtmosphere"
        ownedAtmosphere.Parent = Lighting
        return ownedAtmosphere
    end
    local FogModule = __worldStub({
        Name = 'Fog & Atmosphere',
        Function = function(callback)
            if not callback then
                pcall(function()
                    Lighting.FogColor = _origLighting.FogColor
                    Lighting.FogStart = _origLighting.FogStart
                    Lighting.FogEnd = _origLighting.FogEnd
                end)
                if ownedAtmosphere then
                    pcall(function()
                        ownedAtmosphere:Destroy()
                    end)
                    ownedAtmosphere = nil
                end
            else
                local atmosphere = ensureAtmosphere()
                if atmosphere then
                    atmosphere.Density = AtmosphereDensity and AtmosphereDensity.Value or atmosphere.Density
                    atmosphere.Haze = AtmosphereHaze and AtmosphereHaze.Value or atmosphere.Haze
                end
            end
        end
    })
    local FogStart = FogModule:AddSlider({
        Name = 'Fog Start',
        Min = 0,
        Max = 5000,
        Default = 0,
        Function = function(val)
            if FogModule.Enabled then Lighting.FogStart = val end
        end
    })
    local FogEnd = FogModule:AddSlider({
        Name = 'Fog End',
        Min = 100,
        Max = 10000,
        Default = 3000,
        Function = function(val)
            if FogModule.Enabled then Lighting.FogEnd = val end
        end
    })
    local FogColor = FogModule:AddDropdown({
        Name = 'Fog Color',
        List = {'White', 'Soft Grey', 'Midnight', 'Sunset', 'Purple', 'Crimson', 'Cyan', 'Toxic Green'},
        Function = function(val)
            if FogModule.Enabled and COLOR_PALETTES[val] then Lighting.FogColor = COLOR_PALETTES[val] end
        end
    })
    AtmosphereDensity = FogModule:AddSlider({
        Name = 'Atmosphere Density',
        Min = 0,
        Max = 1,
        Default = 0.3,
        Decimal = 10,
        Function = function(val)
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then atm.Density = val end
        end
    })
    AtmosphereHaze = FogModule:AddSlider({
        Name = 'Atmosphere Haze',
        Min = 0,
        Max = 2,
        Default = 0,
        Decimal = 10,
        Function = function(val)
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then atm.Haze = val end
        end
    })

    -- 3. SKYBOX MODULE
    local SkyboxPreset = {
        Enabled = false,
        Value = "BetterSky"
    }
    local function applySky(presetName)
        local data = SKY_PRESETS[presetName]
        if not data then return end
        if not _ownedSky then
            _ownedSky = Instance.new("Sky")
            _ownedSky.Name = "AkiraLiteSky"
            _ownedSky.Parent = Lighting
        end
        _ownedSky.SkyboxBk = data.SkyboxBk or ""
        _ownedSky.SkyboxDn = data.SkyboxDn or ""
        _ownedSky.SkyboxFt = data.SkyboxFt or ""
        _ownedSky.SkyboxLf = data.SkyboxLf or ""
        _ownedSky.SkyboxRt = data.SkyboxRt or ""
        _ownedSky.SkyboxUp = data.SkyboxUp or ""
        _ownedSky.StarCount = data.StarCount or 3000
    end

    applySkyRef = applySky

    local SkyboxModule = __worldStub({
        Name = 'Skybox',
        Function = function(callback)
            if callback then
                applySky(SkyboxPreset.Value)
            else
                if _ownedSky then
                    _ownedSky:Destroy()
                    _ownedSky = nil
                end
            end
        end
    })
    SkyboxPreset = SkyboxModule:AddDropdown({
        Name = 'Preset',
        List = {
            'BetterSky', 'BetterNight', 'BetterNight2', 'BetterNight3', 'Nebula3',
            'PinkMountains', 'DarkMountains', 'Realistic', 'Space', 'Space2',
            'Midnight', 'Moon', 'Retro', 'FPSBoost', 'Galaxy', 'Art', 'Ame', 'Dawn', 'Alien', 'Lunar'
        },
        Function = function(val)
            if SkyboxModule.Enabled then
                applySky(val)
            end
        end
    })

    -- 4. WEATHER MODULE
    local WeatherPreset = {Enabled = false, Value = "Clear"}
    local WeatherIntensity = {Enabled = false, Value = 1}
    local WeatherSpeed = {Enabled = false, Value = 1}
    local WeatherRate = {Enabled = false, Value = 1}
    local function clearWeather()
        if _weatherConn then _weatherConn:Disconnect(); _weatherConn = nil end
        for _, em in ipairs(_weatherEmitters) do pcall(function() em:Destroy() end) end
        table.clear(_weatherEmitters)
        if _weatherPart then pcall(function() _weatherPart:Destroy() end); _weatherPart = nil end
    end

    local function setupWeather(presetName)
        clearWeather()
        local specs = WEATHER_SPECS[presetName] or WEATHER_SPECS['Heavy Rain']
        local cam = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")
        if not cam then return end

        _weatherPart = Instance.new("Part")
        _weatherPart.Name = "AkiraLiteWeatherPart"
        _weatherPart.Transparency = 1
        _weatherPart.CanCollide = false
        _weatherPart.CanTouch = false
        _weatherPart.CanQuery = false
        _weatherPart.Anchored = true
        _weatherPart.Size = Vector3.new(120, 2, 120)
        _weatherPart.CFrame = cam.CFrame * CFrame.new(0, 35, 0)
        _weatherPart.Parent = Workspace

        local intensity = WeatherIntensity and WeatherIntensity.Value or 1
        local speedMult = WeatherSpeed and WeatherSpeed.Value or 1
        local rateMult = WeatherRate and WeatherRate.Value or 1

        for _, spec in ipairs(specs) do
            local emitter = Instance.new("ParticleEmitter")
            emitter.Name = "WeatherParticle"
            emitter.Shape = Enum.ParticleEmitterShape.Box
            emitter.EmissionDirection = Enum.NormalId.Bottom
            emitter.Enabled = true
            emitter.Texture = spec.Texture
            emitter.Rate = math.clamp(spec.BaseRate * intensity * rateMult, 1, 1500)
            local effSpeed = math.max(10, spec.SpeedMin * speedMult)
            emitter.Speed = NumberRange.new(effSpeed, math.max(effSpeed, spec.SpeedMax * speedMult))
            emitter.Lifetime = NumberRange.new(spec.LifetimeMin, spec.LifetimeMax)
            emitter.Size = NumberSequence.new(spec.SizeStart, spec.SizeEnd)
            emitter.Rotation = NumberRange.new(spec.RotationMin or 0, spec.RotationMax or 360)
            emitter.RotSpeed = NumberRange.new(spec.RotationSpeedMin or 0, spec.RotationSpeedMax or 0)
            emitter.LightEmission = spec.LightEmission or 0.1
            emitter.Acceleration = Vector3.new(0, spec.BaseAccelerationY or -50, 0)
            if spec.Orientation then emitter.Orientation = spec.Orientation end
            emitter.Parent = _weatherPart
            table.insert(_weatherEmitters, emitter)
        end

        _weatherConn = RunService.RenderStepped:Connect(function()
            local c = Workspace.CurrentCamera
            if c and _weatherPart then
                _weatherPart.CFrame = CFrame.new(c.CFrame.Position + Vector3.new(0, 35, 0))
            end
        end)
    end

    setupWeatherRef = setupWeather

    local WeatherModule = __worldStub({
        Name = 'Weather',
        Function = function(callback)
            if callback then
                setupWeather(WeatherPreset.Value)
            else
                clearWeather()
            end
        end
    })
    WeatherPreset = WeatherModule:AddDropdown({
        Name = 'Weather Preset',
        List = {'Heavy Rain', 'Rain', 'Snow', 'Blizzard'},
        Function = function(val)
            if WeatherModule.Enabled then setupWeather(val) end
        end
    })
    WeatherIntensity = WeatherModule:AddSlider({
        Name = 'Intensity',
        Min = 0.2,
        Max = 3,
        Default = 1,
        Decimal = 10,
        Function = function() if WeatherModule.Enabled then setupWeather(WeatherPreset.Value) end end
    })
    WeatherSpeed = WeatherModule:AddSlider({
        Name = 'Speed',
        Min = 0.5,
        Max = 3,
        Default = 1,
        Decimal = 10,
        Function = function() if WeatherModule.Enabled then setupWeather(WeatherPreset.Value) end end
    })
    WeatherRate = WeatherModule:AddSlider({
        Name = 'Rate',
        Min = 0.2,
        Max = 3,
        Default = 1,
        Decimal = 10,
        Function = function() if WeatherModule.Enabled then setupWeather(WeatherPreset.Value) end end
    })

    -- 5. AMBIENCE MODULE
    local AmbiencePreset, AmbienceVolume
    local function playAmbience(soundName)
        local id = AMBIENCE_SOUNDS[soundName]
        if not id then return end
        if not _ownedSound then
            _ownedSound = Instance.new("Sound")
            _ownedSound.Name = "AkiraLiteAmbience"
            _ownedSound.Looped = true
            _ownedSound.Parent = SoundService
        end
        _ownedSound.SoundId = id
        _ownedSound.Volume = AmbienceVolume and AmbienceVolume.Value or 1
        _ownedSound:Play()
    end

    local AmbienceModule = __worldStub({
        Name = 'Ambience',
        Function = function(callback)
            if callback then
                playAmbience(AmbiencePreset.Value)
            else
                if _ownedSound then
                    _ownedSound:Stop()
                    _ownedSound:Destroy()
                    _ownedSound = nil
                end
            end
        end
    })
    AmbiencePreset = AmbienceModule:AddDropdown({
        Name = 'Sound Preset',
        List = {'Heavy Rain', 'Rain On Window', 'Rain At 3 A.M.', 'Ocean Surf', 'Howling Wind', 'Night Crickets', 'Cozy Fire', 'Lofi Focus'},
        Function = function(val)
            if AmbienceModule.Enabled then playAmbience(val) end
        end
    })
    AmbienceVolume = AmbienceModule:AddSlider({
        Name = 'Volume',
        Min = 0.1,
        Max = 1.5,
        Default = 1,
        Decimal = 10,
        Function = function(val)
            if _ownedSound then _ownedSound.Volume = val end
        end
    })

    -- 6. POST PROCESSING MODULE
    local BloomToggle, BloomIntensity, BloomSize
    local CcToggle, CcSaturation, CcContrast, CcBrightness
    local SunRaysToggle, SunRaysIntensity

    local PostFxModule = __worldStub({
        Name = 'Post Processing',
        Function = function(callback)
            if not callback then
                if _bloomEffect then _bloomEffect:Destroy(); _bloomEffect = nil end
                if _ccEffect then _ccEffect:Destroy(); _ccEffect = nil end
                if _sunRaysEffect then _sunRaysEffect:Destroy(); _sunRaysEffect = nil end
            else
                if BloomToggle.Enabled then
                    if not _bloomEffect then _bloomEffect = Instance.new("BloomEffect", Lighting) end
                    _bloomEffect.Intensity = BloomIntensity.Value
                    _bloomEffect.Size = BloomSize.Value
                end
                if CcToggle.Enabled then
                    if not _ccEffect then _ccEffect = Instance.new("ColorCorrectionEffect", Lighting) end
                    _ccEffect.Saturation = CcSaturation.Value
                    _ccEffect.Contrast = CcContrast.Value
                    _ccEffect.Brightness = CcBrightness.Value
                end
                if SunRaysToggle.Enabled then
                    if not _sunRaysEffect then _sunRaysEffect = Instance.new("SunRaysEffect", Lighting) end
                    _sunRaysEffect.Intensity = SunRaysIntensity.Value
                end
            end
        end
    })

    BloomToggle = PostFxModule:AddToggle({
        Name = 'Bloom',
        Default = false,
        Function = function(val)
            if val and PostFxModule.Enabled then
                if not _bloomEffect then _bloomEffect = Instance.new("BloomEffect", Lighting) end
                _bloomEffect.Intensity = BloomIntensity.Value
                _bloomEffect.Size = BloomSize.Value
            elseif _bloomEffect then
                _bloomEffect:Destroy()
                _bloomEffect = nil
            end
        end
    })
    BloomIntensity = PostFxModule:AddSlider({
        Name = 'Bloom Intensity',
        Min = 0,
        Max = 1,
        Default = 0.4,
        Decimal = 10,
        Function = function(val)
            if _bloomEffect then _bloomEffect.Intensity = val end
        end
    })
    BloomSize = PostFxModule:AddSlider({
        Name = 'Bloom Size',
        Min = 0,
        Max = 56,
        Default = 24,
        Function = function(val)
            if _bloomEffect then _bloomEffect.Size = val end
        end
    })

    CcToggle = PostFxModule:AddToggle({
        Name = 'Color Correction',
        Default = false,
        Function = function(val)
            if val and PostFxModule.Enabled then
                if not _ccEffect then _ccEffect = Instance.new("ColorCorrectionEffect", Lighting) end
                _ccEffect.Saturation = CcSaturation.Value
                _ccEffect.Contrast = CcContrast.Value
                _ccEffect.Brightness = CcBrightness.Value
            elseif _ccEffect then
                _ccEffect:Destroy()
                _ccEffect = nil
            end
        end
    })
    CcSaturation = PostFxModule:AddSlider({
        Name = 'Saturation',
        Min = -1,
        Max = 1,
        Default = 0,
        Decimal = 10,
        Function = function(val)
            if _ccEffect then _ccEffect.Saturation = val end
        end
    })
    CcContrast = PostFxModule:AddSlider({
        Name = 'Contrast',
        Min = -1,
        Max = 1,
        Default = 0,
        Decimal = 10,
        Function = function(val)
            if _ccEffect then _ccEffect.Contrast = val end
        end
    })
    CcBrightness = PostFxModule:AddSlider({
        Name = 'CC Brightness',
        Min = -1,
        Max = 1,
        Default = 0,
        Decimal = 10,
        Function = function(val)
            if _ccEffect then _ccEffect.Brightness = val end
        end
    })

    SunRaysToggle = PostFxModule:AddToggle({
        Name = 'Sun Rays',
        Default = false,
        Function = function(val)
            if val and PostFxModule.Enabled then
                if not _sunRaysEffect then _sunRaysEffect = Instance.new("SunRaysEffect", Lighting) end
                _sunRaysEffect.Intensity = SunRaysIntensity.Value
            elseif _sunRaysEffect then
                _sunRaysEffect:Destroy()
                _sunRaysEffect = nil
            end
        end
    })
    SunRaysIntensity = PostFxModule:AddSlider({
        Name = 'Sun Rays Intensity',
        Min = 0,
        Max = 1,
        Default = 0.25,
        Decimal = 10,
        Function = function(val)
            if _sunRaysEffect then _sunRaysEffect.Intensity = val end
        end
    })

    -- WORLD PRESET HANDLER
    local function applyThemePreset(preset)
        if preset == 'Game Default' then
            toggleModule(LightingModule, false)
            toggleModule(FogModule, false)
            toggleModule(SkyboxModule, false)
            toggleModule(PostFxModule, false)
            toggleModule(WeatherModule, false)
            toggleModule(AmbienceModule, false)
        elseif preset == 'Competitive Clarity' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 12
            Lighting.Brightness = 2.8
            Lighting.ExposureCompensation = 0.1
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(170, 170, 170)
            Lighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
            toggleModule(FogModule, true)
            Lighting.FogStart = 0
            Lighting.FogEnd = 10000
            Lighting.FogColor = Color3.fromRGB(200, 200, 200)
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'FPSBoost'
            safeApplySky('FPSBoost')
        elseif preset == 'Sunny Day' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 13
            Lighting.Brightness = 2.4
            Lighting.ExposureCompensation = 0.05
            Lighting.EnvironmentDiffuseScale = 0.4
            Lighting.EnvironmentSpecularScale = 0.3
            Lighting.Ambient = Color3.fromRGB(160, 170, 190)
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'BetterSky'
            safeApplySky('BetterSky')
        elseif preset == 'Golden Hour' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 17.5
            Lighting.Brightness = 2.5
            Lighting.ExposureCompensation = 0.15
            Lighting.Ambient = Color3.fromRGB(140, 120, 105)
            Lighting.OutdoorAmbient = Color3.fromRGB(150, 115, 85)
            toggleModule(FogModule, true)
            Lighting.FogColor = Color3.fromRGB(255, 170, 110)
            Lighting.FogStart = 100
            Lighting.FogEnd = 4000
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'PinkMountains'
            safeApplySky('PinkMountains')
        elseif preset == 'Cinematic' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 15.5
            Lighting.Brightness = 2.2
            Lighting.ExposureCompensation = -0.1
            Lighting.Ambient = Color3.fromRGB(100, 120, 140)
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'Realistic'
            safeApplySky('Realistic')
        elseif preset == 'Midnight' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 0
            Lighting.Brightness = 1.2
            Lighting.ExposureCompensation = 0.1
            Lighting.Ambient = Color3.fromRGB(70, 80, 110)
            Lighting.OutdoorAmbient = Color3.fromRGB(60, 70, 105)
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'BetterNight'
            safeApplySky('BetterNight')
        elseif preset == 'Neon Nights' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 0
            Lighting.Brightness = 1.5
            Lighting.ExposureCompensation = 0.1
            Lighting.Ambient = Color3.fromRGB(60, 20, 100)
            Lighting.OutdoorAmbient = Color3.fromRGB(20, 10, 60)
            toggleModule(FogModule, true)
            Lighting.FogColor = Color3.fromRGB(160, 40, 220)
            Lighting.FogStart = 0
            Lighting.FogEnd = 2500
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'Nebula3'
            safeApplySky('Nebula3')
        elseif preset == 'Vaporwave' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 18
            Lighting.Brightness = 2.0
            Lighting.ExposureCompensation = 0.1
            Lighting.Ambient = Color3.fromRGB(220, 100, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(50, 180, 230)
            toggleModule(FogModule, true)
            Lighting.FogColor = Color3.fromRGB(255, 120, 220)
            Lighting.FogStart = 0
            Lighting.FogEnd = 3000
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'Retro'
            safeApplySky('Retro')
        elseif preset == 'Crimson Dusk' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 18.5
            Lighting.Brightness = 1.8
            Lighting.Ambient = Color3.fromRGB(120, 20, 30)
            Lighting.OutdoorAmbient = Color3.fromRGB(80, 10, 20)
            toggleModule(FogModule, true)
            Lighting.FogColor = Color3.fromRGB(180, 30, 40)
            Lighting.FogStart = 0
            Lighting.FogEnd = 2000
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'DarkMountains'
            safeApplySky('DarkMountains')
        elseif preset == 'Arctic' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 11
            Lighting.Brightness = 2.6
            Lighting.Ambient = Color3.fromRGB(200, 230, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 220, 250)
            toggleModule(FogModule, true)
            Lighting.FogColor = Color3.fromRGB(220, 240, 255)
            Lighting.FogStart = 0
            Lighting.FogEnd = 3500
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'Moon'
            safeApplySky('Moon')
        elseif preset == 'Toxic' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 14
            Lighting.Brightness = 2.0
            Lighting.Ambient = Color3.fromRGB(40, 90, 40)
            Lighting.OutdoorAmbient = Color3.fromRGB(30, 70, 30)
            toggleModule(FogModule, true)
            Lighting.FogColor = Color3.fromRGB(60, 180, 60)
            Lighting.FogStart = 0
            Lighting.FogEnd = 2000
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'Alien'
            safeApplySky('Alien')
        elseif preset == 'Deep Space' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 0
            Lighting.Brightness = 1.0
            Lighting.Ambient = Color3.fromRGB(10, 10, 20)
            Lighting.OutdoorAmbient = Color3.fromRGB(5, 5, 15)
            toggleModule(FogModule, true)
            Lighting.FogColor = Color3.fromRGB(15, 10, 30)
            Lighting.FogStart = 0
            Lighting.FogEnd = 5000
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'Space2'
            safeApplySky('Space2')
        elseif preset == 'Retro Aesthetic' then
            toggleModule(LightingModule, true)
            Lighting.ClockTime = 16
            Lighting.Brightness = 2.2
            Lighting.Ambient = Color3.fromRGB(180, 140, 100)
            toggleModule(SkyboxModule, true)
            SkyboxPreset.Value = 'Retro'
            safeApplySky('Retro')
        end
    end

    local ThemeDropdown = Presets:AddDropdown({
        Name = 'Theme Preset',
        List = {
            'Game Default', 'Competitive Clarity', 'Sunny Day', 'Golden Hour',
            'Cinematic', 'Midnight', 'Neon Nights', 'Vaporwave', 'Crimson Dusk',
            'Arctic', 'Toxic', 'Deep Space', 'Retro Aesthetic'
        },
        Function = function(val)
            applyThemePreset(val)
        end
    })
end)
    akiraMark("block24:done")
    akiraMark("block25:start")
run(function()
    local NameSpoof
    local UsernameToggle
    local DisplayToggle
    local UsernameInput
    local DisplayInput
    local originals = setmetatable({}, {__mode = "k"})
    local connections = {}
    local active = false

    local function isLocalObject(object)
        local current = object
        while current do
            if current == lplr.Character or current == CoreGui or current == AkiraLite.MainScreenGui then
                return true
            end
            if current:IsA("PlayerGui") and current.Parent == lplr then
                return true
            end
            current = current.Parent
        end
        return false
    end

    local function approvedLabel(object)
        local current = object
        local depth = 0
        while current and depth < 5 do
            local name = string.lower(tostring(current.Name or ""))
            if string.find(name, "displayname", 1, true)
                or string.find(name, "username", 1, true)
                or string.find(name, "playername", 1, true)
                or string.find(name, "namedisplay", 1, true)
                or string.find(name, "nametag", 1, true) then
                return true
            end
            current = current.Parent
            depth += 1
        end
        return false
    end

    local function desiredIdentity()
        local username = UsernameToggle and UsernameToggle.Enabled and UsernameInput and UsernameInput.Value or ""
        local displayName = DisplayToggle and DisplayToggle.Enabled and DisplayInput and DisplayInput.Value or ""
        if username == "" then
            username = nil
        end
        if displayName == "" then
            displayName = nil
        end
        return username, displayName
    end

    local function setIdentity()
        local username, displayName = desiredIdentity()
        pcall(AkiraLite.SetIdentity, AkiraLite, username, displayName)
    end

    local function rewriteText(object)
        if not active or not object or not isLocalObject(object) or not object:IsA("TextLabel")
            and not object:IsA("TextButton") and not object:IsA("TextBox") then
            return
        end
        local text = object.Text
        if type(text) ~= "string" or text == "" then
            return
        end
        local realName = tostring(lplr.Name or "")
        local realDisplay = tostring(lplr.DisplayName or realName)
        local username, displayName = desiredIdentity()
        if type(username) ~= "string" or username == "" then
            username = nil
        end
        if type(displayName) ~= "string" or displayName == "" then
            displayName = nil
        end
        if not username and not displayName then
            return
        end
        local containsReal = (realName ~= "" and string.find(text, realName, 1, true) ~= nil)
            or (realDisplay ~= "" and string.find(text, realDisplay, 1, true) ~= nil)
        local containsIdentity = (type(username) == "string" and string.find(text, username, 1, true) ~= nil)
            or (type(displayName) == "string" and string.find(text, displayName, 1, true) ~= nil)
        if not containsReal and not containsIdentity and not approvedLabel(object) then
            return
        end
        if originals[object] == nil then
            originals[object] = text
        end
        local replaced = text
        local usernameValue = username or realName
        local displayValue = displayName or realDisplay
        if username or displayName then
            replaced = replaced:gsub(realName, function()
                return usernameValue
            end)
            replaced = replaced:gsub(realDisplay, function()
                return displayValue
            end)
        end
        local lowerName = string.lower(tostring(object.Name or ""))
        if string.find(lowerName, "username", 1, true) or string.find(lowerName, "playername", 1, true) then
            replaced = "@" .. usernameValue
        elseif string.find(lowerName, "displayname", 1, true) then
            replaced = displayValue
        end
        if replaced ~= object.Text then
            pcall(function()
                object.Text = replaced
            end)
        end
    end

    local function scan(root)
        if not root or not root:IsA("Instance") then
            return
        end
        if root:IsA("TextLabel") or root:IsA("TextButton") or root:IsA("TextBox") then
            rewriteText(root)
        end
        for _, object in ipairs(root:GetDescendants()) do
            rewriteText(object)
        end
    end

    local function scanLocal()
        scan(lplr and lplr:FindFirstChildOfClass("PlayerGui"))
        scan(CoreGui)
        scan(lplr and lplr.Character)
    end

    local function disconnectAll()
        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(connections)
    end

    local function restore()
        for object, text in pairs(originals) do
            if object and object.Parent then
                pcall(function()
                    object.Text = text
                end)
            end
        end
        table.clear(originals)
    end

    local function stop()
        active = false
        disconnectAll()
        restore()
        pcall(AkiraLite.SetIdentity, AkiraLite, nil, nil)
    end

    local function start()
        stop()
        active = true
        setIdentity()
        local playerGui = lplr and lplr:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            table.insert(connections, playerGui.DescendantAdded:Connect(rewriteText))
            scan(playerGui)
        end
        table.insert(connections, CoreGui.DescendantAdded:Connect(rewriteText))
        scan(CoreGui)
        table.insert(connections, workspace.DescendantAdded:Connect(rewriteText))
        local function bindCharacter(character)
            if not character then
                return
            end
            table.insert(connections, character.DescendantAdded:Connect(rewriteText))
            scan(character)
        end
        table.insert(connections, lplr.CharacterAdded:Connect(bindCharacter))
        if lplr.Character then
            bindCharacter(lplr.Character)
        end
        pcall(AkiraLite.ApplyUIStyle, AkiraLite)
    end

    NameSpoof = AkiraLite.Catalogs.Player:AddModule({
        Name = 'Name Spoofing',
        Function = function(callback)
            if callback then
                start()
            else
                stop()
            end
        end
    })

    UsernameInput = NameSpoof:AddTextInput({
        Name = 'Username',
        Placeholder = 'Spoofed username',
        MaxLength = 64,
        Visible = false,
        Function = function()
            if active and UsernameToggle and UsernameToggle.Enabled then
                setIdentity()
                scanLocal()
            end
        end
    })
    DisplayInput = NameSpoof:AddTextInput({
        Name = 'Display Name',
        Placeholder = 'Spoofed display name',
        MaxLength = 64,
        Visible = false,
        Function = function()
            if active and DisplayToggle and DisplayToggle.Enabled then
                setIdentity()
                scanLocal()
            end
        end
    })
    UsernameToggle = NameSpoof:AddToggle({
        Name = 'Username Toggle',
        Function = function(callback)
            UsernameInput.Frame.Visible = callback
            if active then
                setIdentity()
                scanLocal()
            end
        end
    })
    DisplayToggle = NameSpoof:AddToggle({
        Name = 'Display Name Toggle',
        Function = function(callback)
            DisplayInput.Frame.Visible = callback
            if active then
                setIdentity()
                scanLocal()
            end
        end
    })
end)
    akiraMark("block25:done")
    akiraMark("block26:start")
run(function()
    local Chams
    local Mode
    local FillColor
    local OutlineColor
    local FillTransparency
    local OutlineTransparency
    local Walls
    local PriorityOnly
    local TeamFilter
    local VisibleOnly
    local ColorMode
    local CustomColor
    local VisibleColor
    local HiddenColor
    local Reference = {}
    local Blocked = {}
    local Folder = Instance.new("Folder")
    Folder.Name = "AkiraChams"
    Folder.Parent = AkiraLite.MainScreenGui
    local RayParams = RaycastParams.new()
    RayParams.RespectCanCollide = true

    local function isEnemy(player)
        if not player or player == lplr then
            return false
        end
        local a = lplr and lplr:GetAttribute("TeamID")
        local b = player and player:GetAttribute("TeamID")
        if a ~= nil and b ~= nil and tostring(a) ~= "" and tostring(b) ~= "" then
            return tostring(a) ~= tostring(b)
        end
        if lplr and player and lplr.Team and player.Team then
            return lplr.Team ~= player.Team
        end
        return true
    end

    local function allowed(ent, visible)
        if not ent or not ent.Player or ent.NPC then
            return false
        end
        if PriorityOnly and PriorityOnly.Enabled and not ent.Targetable and not ent.Friend then
            return false
        end
        if TeamFilter then
            if TeamFilter.Value == "Enemies" and not isEnemy(ent.Player) then
                return false
            elseif TeamFilter.Value == "Teammates" and isEnemy(ent.Player) then
                return false
            end
        end
        if VisibleOnly and VisibleOnly.Enabled and visible == false then
            return false
        end
        return true
    end

    -- Visibility is a workspace raycast. It used to run once per entity per
    -- frame AND allocate a fresh filter table on every single call. The filter
    -- list is now built once and only rebuilt when the local character changes,
    -- and the raycast itself is rate limited per entity - line of sight does not
    -- need 60Hz, the previous answer is reused in between.
    local _visCache = {}
    local _visFilterKey = nil
    local function visible(ent)
        local character = ent and ent.Character
        local head = ent and (ent.Head or (character and character:FindFirstChild("Head")))
        local root = entitylib.character and entitylib.character.RootPart
        if not head or not root then
            return false
        end
        local now = os.clock()
        local cached = _visCache[ent]
        if cached and (now - cached.at) < 0.1 then
            return cached.value
        end
        if _visFilterKey ~= lplr.Character then
            local filters = {}
            if lplr.Character then
                table.insert(filters, lplr.Character)
            end
            if gameCamera then
                table.insert(filters, gameCamera)
            end
            RayParams.FilterDescendantsInstances = filters
            _visFilterKey = lplr.Character
        end
        local result = workspace:Raycast(root.Position, head.Position - root.Position, RayParams)
        local value = result == nil or (result.Instance and character and result.Instance:IsDescendantOf(character)) or false
        _visCache[ent] = {at = now, value = value}
        return value
    end

    local function colorFor(ent, isVisible)
        local custom = (FillColor and FillColor.Value) or (CustomColor and CustomColor.Value) or Color3.fromRGB(255, 255, 255)
        if ColorMode then
            if ColorMode.Value == "Team" then
                return entitylib.getEntityColor(ent) or custom
            elseif ColorMode.Value == "Visibility" then
                return isVisible and (VisibleColor and VisibleColor.Value or custom) or (HiddenColor and HiddenColor.Value or custom)
            elseif ColorMode.Value == "Rainbow" then
                return Color3.fromHSV((tick() * 0.15 + (ent and ent.Player and ent.Player.UserId or 0) * 0.00001) % 1, 0.85, 1)
            end
        end
        return custom
    end

    local function destroyRef(ent)
        local ref = Reference[ent]
        if not ref then
            return
        end
        if ref.Highlight then
            pcall(function() ref.Highlight:Destroy() end)
        end
        for _, object in ipairs(ref.Objects or {}) do
            pcall(function() object:Destroy() end)
        end
        Reference[ent] = nil
    end

    local function build(ent)
        if Reference[ent] then
            destroyRef(ent)
        end
        local isVisible = visible(ent)
        if not allowed(ent, isVisible) then
            Blocked[ent] = true
            return
        end
        Blocked[ent] = nil
        local ref = {Objects = {}, Visible = isVisible}
        local fill = FillColor and FillColor.Value or Color3.fromRGB(255, 255, 255)
        local outline = OutlineColor and OutlineColor.Value or Color3.new()
        if Mode and Mode.Value == "Highlight" then
            local highlight = Instance.new("Highlight")
            highlight.Name = "AkiraChamsHighlight"
            highlight.Adornee = ent.Character
            highlight.DepthMode = Enum.HighlightDepthMode[Walls and Walls.Enabled and "AlwaysOnTop" or "Occluded"]
            highlight.FillColor = colorFor(ent, isVisible)
            highlight.OutlineColor = outline
            highlight.FillTransparency = FillTransparency and FillTransparency.Value or 0.5
            highlight.OutlineTransparency = OutlineTransparency and OutlineTransparency.Value or 0.5
            highlight.Parent = Folder
            ref.Highlight = highlight
        else
            for _, part in ipairs(ent.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    local lower = string.lower(part.Name)
                    if string.find(lower, "arm", 1, true) or string.find(lower, "leg", 1, true)
                        or string.find(lower, "hand", 1, true) or string.find(lower, "foot", 1, true)
                        or string.find(lower, "torso", 1, true) or lower == "head" then
                        local outer = Instance.new(part.Name == "Head" and "SphereHandleAdornment" or "BoxHandleAdornment")
                        outer.Name = "AkiraChamsOutline"
                        outer.Adornee = part
                        outer.AlwaysOnTop = Walls and Walls.Enabled or false
                        outer.Color3 = outline
                        outer.Transparency = OutlineTransparency and OutlineTransparency.Value or 0.5
                        outer.ZIndex = 0
                        if outer:IsA("SphereHandleAdornment") then
                            outer.Radius = (part.Size.X + 0.12) * 0.5
                        else
                            outer.Size = part.Size + Vector3.new(0.12, 0.12, 0.12)
                        end
                        outer.Parent = Folder
                        local inner = Instance.new(part.Name == "Head" and "SphereHandleAdornment" or "BoxHandleAdornment")
                        inner.Name = "AkiraChamsFill"
                        inner.Adornee = part
                        inner.AlwaysOnTop = Walls and Walls.Enabled or false
                        inner.Color3 = colorFor(ent, isVisible)
                        inner.Transparency = FillTransparency and FillTransparency.Value or 0.5
                        inner.ZIndex = 1
                        if inner:IsA("SphereHandleAdornment") then
                            inner.Radius = (part.Size.X + 0.04) * 0.5
                        else
                            inner.Size = part.Size + Vector3.new(0.04, 0.04, 0.04)
                        end
                        inner.Parent = Folder
                        table.insert(ref.Objects, outer)
                        table.insert(ref.Objects, inner)
                    end
                end
            end
        end
        Reference[ent] = ref
    end

    local function update(ent, ref)
        if not ref or not ent then
            destroyRef(ent)
            return
        end
        ref.Visible = visible(ent)
        if not allowed(ent, ref.Visible) then
            Blocked[ent] = true
            destroyRef(ent)
            return
        end
        Blocked[ent] = nil
        local color = colorFor(ent, ref.Visible)
        if ref.Highlight then
            ref.Highlight.FillColor = color
            ref.Highlight.OutlineColor = OutlineColor and OutlineColor.Value or Color3.new()
            ref.Highlight.FillTransparency = FillTransparency and FillTransparency.Value or 0.5
            ref.Highlight.OutlineTransparency = OutlineTransparency and OutlineTransparency.Value or 0.5
            ref.Highlight.DepthMode = Enum.HighlightDepthMode[Walls and Walls.Enabled and "AlwaysOnTop" or "Occluded"]
        else
            local index = 0
            for _, object in ipairs(ref.Objects) do
                if object.Name == "AkiraChamsFill" then
                    object.Color3 = color
                    object.Transparency = FillTransparency and FillTransparency.Value or 0.5
                    object.AlwaysOnTop = Walls and Walls.Enabled or false
                elseif object.Name == "AkiraChamsOutline" then
                    object.Color3 = OutlineColor and OutlineColor.Value or Color3.new()
                    object.Transparency = OutlineTransparency and OutlineTransparency.Value or 0.5
                    object.AlwaysOnTop = Walls and Walls.Enabled or false
                end
                index += 1
            end
        end
    end

    local function rebuildAll()
        table.clear(Blocked)
        for ent in pairs(Reference) do
            destroyRef(ent)
        end
        if not Chams or not Chams.Enabled then
            return
        end
        for _, ent in ipairs(entitylib.List) do
            build(ent)
        end
    end

    local function refreshAll()
        if not Chams or not Chams.Enabled then
            return
        end
        for _, ent in ipairs(entitylib.List) do
            if not Reference[ent] then
                local isVisible = visible(ent)
                if allowed(ent, isVisible) then
                    build(ent)
                else
                    Blocked[ent] = true
                end
            end
            if Reference[ent] then
                update(ent, Reference[ent])
            end
        end
    end

    Chams = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Chams',
        Function = function(callback)
            if callback then
                Chams:Clean(entitylib.Events.EntityAdded:Connect(build))
                Chams:Clean(entitylib.Events.EntityRemoved:Connect(function(ent)
                    Blocked[ent] = nil
                    destroyRef(ent)
                end))
                Chams:Clean(entitylib.Events.EntityUpdated:Connect(function(ent)
                    if Reference[ent] then
                        update(ent, Reference[ent])
                    end
                end))
                Chams:Clean(RunService.RenderStepped:Connect(function()
                    pcall(refreshAll)
                end))
                rebuildAll()
            else
                for ent in pairs(Reference) do
                    destroyRef(ent)
                end
                table.clear(Blocked)
            end
        end
    })

    Mode = Chams:AddDropdown({
        Name = 'Mode',
        List = {'Highlight', 'BoxHandles'},
        Function = rebuildAll
    })
    FillColor = Chams:AddColorPicker({
        Name = 'Fill Color',
        Default = Color3.fromRGB(255, 255, 255),
        Function = refreshAll
    })
    OutlineColor = Chams:AddColorPicker({
        Name = 'Outline Color',
        Default = Color3.fromRGB(0, 0, 0),
        Darker = true,
        Function = refreshAll
    })
    FillTransparency = Chams:AddSlider({
        Name = 'Fill Transparency',
        Min = 0,
        Max = 1,
        Default = 0.5,
        Decimal = 10,
        Function = refreshAll
    })
    OutlineTransparency = Chams:AddSlider({
        Name = 'Outline Transparency',
        Min = 0,
        Max = 1,
        Default = 0.5,
        Decimal = 10,
        Darker = true,
        Function = refreshAll
    })
    Walls = Chams:AddToggle({
        Name = 'Render Walls',
        Default = true,
        Function = refreshAll
    })
    PriorityOnly = Chams:AddToggle({
        Name = 'Priority Only',
        Default = true,
        Function = rebuildAll
    })
    TeamFilter = Chams:AddDropdown({
        Name = 'Team Filter',
        List = {'All', 'Enemies', 'Teammates'},
        Function = rebuildAll
    })
    VisibleOnly = Chams:AddToggle({
        Name = 'Visible Only',
        Function = rebuildAll
    })
    ColorMode = Chams:AddDropdown({
        Name = 'Color Mode',
        List = {'Custom', 'Team', 'Rainbow', 'Visibility'},
        Function = refreshAll
    })
    CustomColor = Chams:AddColorPicker({
        Name = 'Custom Color',
        Default = Color3.fromRGB(255, 255, 255),
        Darker = true,
        Function = refreshAll
    })
    VisibleColor = Chams:AddColorPicker({
        Name = 'Visible Color',
        Default = Color3.fromRGB(80, 255, 120),
        Darker = true,
        Function = refreshAll
    })
    HiddenColor = Chams:AddColorPicker({
        Name = 'Hidden Color',
        Default = Color3.fromRGB(255, 70, 70),
        Darker = true,
        Function = refreshAll
    })
end)
    akiraMark("block26:done")
    akiraMark("block27:start")
run(function()
    local ESP
    local Mode
    local ColorMode
    local CustomColor
    local VisibleColor
    local HiddenColor
    local OutlineColor
    local BoundingBox
    local Filled
    local Outline
    local OutlineThickness
    local Transparency
    local FillColor
    local Name
    local DisplayName
    local HealthBar
    local HealthText
    local ShowWeapon
    local ShowAmmo
    local ShowDistance
    local DistanceCheck
    local DistanceLimit
    local VisibleOnly
    local PriorityOnly
    local TeamFilter
    local Snaplines
    local SnaplineOrigin
    local HeadDot
    local LookDirection
    local OffscreenArrows
    local Skeleton
    local Box3D
    local Highlight
    local RankToggle
    local WinStreakToggle
    local DeflectingToggle
    local GradientText
    local GradientColor
    local FlowSpeed
    local GlowToggle
    local GlowSize
    local AnimatedFill
    local Reference = {}
    local Blocked = {}
    local Folder = Instance.new("Folder")
    Folder.Name = "AkiraESPHighlights"
    Folder.Parent = AkiraLite.MainScreenGui
    local RayParams = RaycastParams.new()
    RayParams.RespectCanCollide = true
    local fighterController
    local active = false
    local function newDrawing(kind, properties)
        local ok, object = pcall(function()
            return Drawing.new(kind)
        end)
        if not ok or not object then
            return nil
        end
        for key, value in pairs(properties or {}) do
            pcall(function()
                object[key] = value
            end)
        end
        return object
    end
    local ESP_BLACK = Color3.new()
    local function addObject(ref, key, kind, properties)
        local object = newDrawing(kind, properties)
        if object then
            ref.Objects[key] = object
        end
        return object
    end
-- These three run ~40 times PER ENTITY PER FRAME. Each one used to allocate a
-- fresh closure for its pcall, which meant hundreds of throwaway closures every
-- frame. The protection now lives at the caller (one pcall per entity per frame
-- in refreshAll), so the writes are direct.
local function setVisible(object, value)
    if object then
        object.Visible = value == true
    end
end
local function setLine(object, from, to, visible, color, thickness, transparency)
    if not object then
        return
    end
    object.From = from
    object.To = to
    object.Color = color
    object.Thickness = thickness
    object.Transparency = transparency
    object.Visible = visible == true
end
local function setText(object, text, position, color, size, transparency, visible)
    if not object then
        return
    end
    object.Text = text
    object.Position = position
    object.Color = color
    object.Size = size
    object.Transparency = transparency
    object.Visible = visible == true
end
    local function identity(ent)
        if ent and ent.Player then
            return getPlayerIdentity(ent.Player, DisplayName and DisplayName.Enabled == true)
        end
        return ent and ent.Character and ent.Character.Name or ""
    end
    local function teamIsEnemy(player)
        if not player or player == lplr then
            return false
        end
        local a = lplr and lplr:GetAttribute("TeamID")
        local b = player and player:GetAttribute("TeamID")
        if a ~= nil and b ~= nil and tostring(a) ~= "" and tostring(b) ~= "" then
            return tostring(a) ~= tostring(b)
        end
        if lplr and player and lplr.Team and player.Team then
            return lplr.Team ~= player.Team
        end
        return true
    end
    -- Visibility is a workspace raycast. It used to run once per entity per
    -- frame AND allocate a fresh filter table on every single call. The filter
    -- list is now built once and only rebuilt when the local character changes,
    -- and the raycast itself is rate limited per entity - line of sight does not
    -- need 60Hz, the previous answer is reused in between.
    local _visCache = {}
    local _visFilterKey = nil
    local function visible(ent)
        local character = ent and ent.Character
        local head = ent and (ent.Head or (character and character:FindFirstChild("Head")))
        local root = entitylib.character and entitylib.character.RootPart
        if not head or not root then
            return false
        end
        local now = os.clock()
        local cached = _visCache[ent]
        if cached and (now - cached.at) < 0.1 then
            return cached.value
        end
        if _visFilterKey ~= lplr.Character then
            local filters = {}
            if lplr.Character then
                table.insert(filters, lplr.Character)
            end
            if gameCamera then
                table.insert(filters, gameCamera)
            end
            RayParams.FilterDescendantsInstances = filters
            _visFilterKey = lplr.Character
        end
        local result = workspace:Raycast(root.Position, head.Position - root.Position, RayParams)
        local value = result == nil or (result.Instance and character and result.Instance:IsDescendantOf(character)) or false
        _visCache[ent] = {at = now, value = value}
        return value
    end
    local function allowed(ent, isVisible)
        if not ent or not ent.Player or ent.NPC or not ent.Character or not ent.Character.Parent then
            return false
        end
        if PriorityOnly and PriorityOnly.Enabled and not ent.Targetable and not ent.Friend then
            return false
        end
        if TeamFilter then
            if TeamFilter.Value == "Enemies" and not teamIsEnemy(ent.Player) then
                return false
            elseif TeamFilter.Value == "Teammates" and teamIsEnemy(ent.Player) then
                return false
            end
        end
        local root = ent.RootPart
        local localRoot = entitylib.character and entitylib.character.RootPart
        if DistanceCheck and DistanceCheck.Enabled and root and localRoot and DistanceLimit then
            if (root.Position - localRoot.Position).Magnitude > DistanceLimit.Value then
                return false
            end
        end
        if VisibleOnly and VisibleOnly.Enabled and isVisible == false then
            return false
        end
        return true
    end
    local function colorFor(ent, isVisible)
        local custom = (FillColor and FillColor.Value) or (CustomColor and CustomColor.Value) or Color3.fromRGB(255, 255, 255)
        if ColorMode then
            if ColorMode.Value == "Team" then
                return entitylib.getEntityColor(ent) or custom
            elseif ColorMode.Value == "Visibility" then
                return isVisible and (VisibleColor and VisibleColor.Value or custom) or (HiddenColor and HiddenColor.Value or custom)
            elseif ColorMode.Value == "Rainbow" then
                local seed = ent and ent.Player and ent.Player.UserId or 0
                return Color3.fromHSV((tick() * 0.12 + seed * 0.00001) % 1, 0.85, 1)
            end
        end
        return custom
    end
    local function weaponInfo(ent)
        local character = ent and ent.Character
        if not character then
            return nil
        end
        if not fighterController then
            local scripts = lplr and lplr:FindFirstChild("PlayerScripts")
            local controllers = scripts and scripts:FindFirstChild("Controllers")
            local module = controllers and controllers:FindFirstChild("FighterController")
            if module then
                pcall(function()
                    fighterController = require(module)
                end)
            end
        end
        if fighterController and type(fighterController) == "table" then
            local objects = rawget(fighterController, "Objects")
            if type(objects) == "table" then
                for _, fighter in pairs(objects) do
                    if type(fighter) == "table" and rawget(fighter, "Player") == ent.Player then
                        local equipped = rawget(fighter, "EquippedItem")
                        if equipped then
                            local info = type(equipped) == "table" and (rawget(equipped, "Info") or rawget(equipped, "Config")) or nil
                            local data = type(equipped) == "table" and rawget(equipped, "Data") or nil
                            local name = type(equipped) == "table" and (rawget(equipped, "Name") or rawget(equipped, "ItemName")) or nil
                            if not name and type(info) == "table" then
                                name = rawget(info, "Name")
                            end
                            if name then
                                local ammo
                                local maxAmmo
                                local reserve
                                if type(equipped) == "table" and type(equipped.Get) == "function" then
                                    pcall(function()
                                        ammo = equipped:Get("Ammo")
                                    end)
                                    pcall(function()
                                        reserve = equipped:Get("AmmoReserve")
                                    end)
                                end
                                if type(ammo) ~= "number" and type(data) == "table" then
                                    ammo = rawget(data, "Ammo")
                                    reserve = reserve or rawget(data, "AmmoReserve")
                                end
                                if type(maxAmmo) ~= "number" and type(info) == "table" then
                                    maxAmmo = rawget(info, "MaxAmmo") or rawget(info, "MagSize") or rawget(info, "ClipSize")
                                end
                                if type(maxAmmo) ~= "number" and type(data) == "table" then
                                    maxAmmo = rawget(data, "MaxAmmo") or rawget(data, "MagSize")
                                end
                                return {
                                    Name = tostring(name),
                                    Ammo = type(ammo) == "number" and ammo or nil,
                                    MaxAmmo = type(maxAmmo) == "number" and maxAmmo or nil,
                                    Reserve = type(reserve) == "number" and reserve or nil
                                }
                            end
                        end
                    end
                end
            end
        end
        local item = character:FindFirstChildOfClass("Tool")
        if not item then
            local equipped = character:FindFirstChild("EquippedItem")
            item = equipped and equipped.Value or nil
        end
        if type(item) == "string" then
            return {Name = item}
        end
        if typeof(item) == "Instance" and item:IsA("Tool") then
            local ammo = item:GetAttribute("Ammo") or item:GetAttribute("CurrentAmmo")
            local maxAmmo = item:GetAttribute("MaxAmmo") or item:GetAttribute("MagSize") or item:GetAttribute("ClipSize")
            local reserve = item:GetAttribute("AmmoReserve")
            return {
                Name = item.Name,
                Ammo = type(ammo) == "number" and ammo or nil,
                MaxAmmo = type(maxAmmo) == "number" and maxAmmo or nil,
                Reserve = type(reserve) == "number" and reserve or nil
            }
        end
        if type(item) ~= "table" then
            local attr = character:GetAttribute("EquippedWeapon")
            return attr and {Name = tostring(attr)} or nil
        end
        local data = type(item.Data) == "table" and item.Data or item
        local info = type(item.Info) == "table" and item.Info or data
        local name = rawget(item, "Name") or rawget(item, "ItemName") or (type(info) == "table" and rawget(info, "Name")) or nil
        local ammo = rawget(data, "Ammo")
        local maxAmmo = rawget(info, "MaxAmmo") or rawget(data, "MaxAmmo") or rawget(info, "MagSize") or rawget(data, "MagSize") or rawget(info, "ClipSize") or rawget(data, "ClipSize")
        local reserve = rawget(data, "AmmoReserve") or rawget(item, "AmmoReserve")
        if type(ammo) ~= "number" then
            ammo = nil
        end
        if type(maxAmmo) ~= "number" then
            maxAmmo = nil
        end
        if type(reserve) ~= "number" then
            reserve = nil
        end
        return name and {
            Name = tostring(name),
            Ammo = ammo,
            MaxAmmo = maxAmmo,
            Reserve = reserve
        } or nil
    end
    local function destroyRef(ent)
        local ref = Reference[ent]
        if not ref then
            return
        end
        if ref.Highlight then
            pcall(function() ref.Highlight:Destroy() end)
        end
        for _, object in pairs(ref.Objects or {}) do
            pcall(function()
                object.Visible = false
                object:Remove()
            end)
        end
        Reference[ent] = nil
    end
    local function build(ent)
        if Reference[ent] then
            destroyRef(ent)
        end
        local isVisible = visible(ent)
        if not allowed(ent, isVisible) then
            Blocked[ent] = true
            return
        end
        Blocked[ent] = nil
        local ref = {Objects = {}, Visible = isVisible, Box3D = {}, Skeleton = {}}
        ref.Main = addObject(ref, "Main", "Square", {Transparency = 1, Thickness = 1, Filled = false, ZIndex = 3})
        ref.Fill = addObject(ref, "Fill", "Square", {Transparency = 1, Thickness = 1, Filled = true, ZIndex = 2})
        ref.Outline = addObject(ref, "Outline", "Square", {Transparency = 1, Thickness = 1, Filled = false, ZIndex = 4})
        ref.HealthBar = addObject(ref, "HealthBar", "Line", {Thickness = 1, ZIndex = 4})
        ref.HealthBorder = addObject(ref, "HealthBorder", "Line", {Thickness = 3, Transparency = 0.35, ZIndex = 3})
        ref.HealthText = addObject(ref, "HealthText", "Text", {Size = 13, Center = true, ZIndex = 4})
        ref.Name = addObject(ref, "Name", "Text", {Size = 15, Center = true, ZIndex = 4})
        ref.NameOutline = addObject(ref, "NameOutline", "Text", {Size = 15, Center = true, ZIndex = 3, Color = Color3.new()})
        ref.Weapon = addObject(ref, "Weapon", "Text", {Size = 12, Center = true, ZIndex = 4})
        ref.Ammo = addObject(ref, "Ammo", "Text", {Size = 12, Center = true, ZIndex = 4})
        ref.Distance = addObject(ref, "Distance", "Text", {Size = 12, Center = true, ZIndex = 4})
        ref.Snapline = addObject(ref, "Snapline", "Line", {Thickness = 1, ZIndex = 2})
        ref.Tracer = addObject(ref, "Tracer", "Line", {Thickness = 1, ZIndex = 2})
        ref.HeadDot = addObject(ref, "HeadDot", "Circle", {Radius = 3, Filled = true, Thickness = 1, ZIndex = 5})
        ref.Glow = addObject(ref, "Glow", "Circle", {Radius = 8, Filled = true, Transparency = 0.85, Thickness = 1, ZIndex = 1})
        ref.Status = addObject(ref, "Status", "Text", {Size = 12, Center = true, ZIndex = 4})
        ref.Look = addObject(ref, "Look", "Line", {Thickness = 1, ZIndex = 3})
        ref.Arrow = addObject(ref, "Arrow", "Line", {Thickness = 2, ZIndex = 5})
        ref.ArrowHead = addObject(ref, "ArrowHead", "Circle", {Radius = 5, Filled = true, Thickness = 1, ZIndex = 5})
        for index = 1, 12 do
            ref.Box3D[index] = addObject(ref, "Box3D" .. index, "Line", {Thickness = 1, ZIndex = 2})
        end
        for index = 1, 10 do
            ref.Skeleton[index] = addObject(ref, "Skeleton" .. index, "Line", {Thickness = 2, ZIndex = 3})
        end
        Reference[ent] = ref
    end
    local function hideAll(ref)
        for _, object in pairs(ref.Objects or {}) do
            setVisible(object, false)
        end
    end
    local function ensureHighlight(ent, ref, color)
        if not Highlight or not Highlight.Enabled then
            if ref.Highlight then
                pcall(function() ref.Highlight:Destroy() end)
                ref.Highlight = nil
            end
            return
        end
        if not ref.Highlight then
            local ok, highlight = pcall(function()
                local object = Instance.new("Highlight")
                object.Name = "AkiraESPHighlight"
                object.Adornee = ent.Character
                object.Parent = Folder
                return object
            end)
            ref.Highlight = ok and highlight or nil
        end
        if ref.Highlight then
            pcall(function()
                ref.Highlight.FillColor = color
                ref.Highlight.OutlineColor = OutlineColor and OutlineColor.Value or Color3.new()
                ref.Highlight.FillTransparency = Transparency and Transparency.Value or 0
                ref.Highlight.OutlineTransparency = Transparency and Transparency.Value or 0
                ref.Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
            end)
        end
    end
    local function project(position)
        return gameCamera:WorldToViewportPoint(position)
    end
    -- Hoisted out of the per-frame draw path. These used to be rebuilt for every
    -- entity on every frame: a 12-entry edge table (13 tables), an 8-entry corner
    -- table plus 8 CFrames, a points table, and 10 two-element bone tables.
    local BOX3D_EDGES = {{1, 2}, {2, 3}, {3, 4}, {4, 1}, {5, 6}, {6, 7}, {7, 8}, {8, 5}, {1, 5}, {2, 6}, {3, 7}, {4, 8}}
    local BOX3D_PAD_XY = Vector3.new(0.1, 0, 0.1)
    local boxCorners, boxPoints = {}, {}
    local function update(ent, ref)
        if not ref or not ent or not ent.Character or not ent.RootPart then
            destroyRef(ent)
            return
        end
        local isVisible = visible(ent)
        ref.Visible = isVisible
        if not allowed(ent, isVisible) then
            Blocked[ent] = true
            destroyRef(ent)
            return
        end
        Blocked[ent] = nil
        local color = colorFor(ent, isVisible)
        local outlineColor = OutlineColor and OutlineColor.Value or ESP_BLACK
        local alpha = Transparency and Transparency.Value or 0
        local root = ent.RootPart
        local head = ent.Head or ent.Character:FindFirstChild("Head") or root
        local rootPoint, rootVisible = project(root.Position)
        local headPoint, headVisible = project(head.Position)
        local center = Vector2.new(rootPoint.X, rootPoint.Y)
        local screen = gameCamera.ViewportSize
        local onScreen = rootVisible and headVisible and rootPoint.X >= 0 and rootPoint.X <= screen.X and rootPoint.Y >= 0 and rootPoint.Y <= screen.Y
        hideAll(ref)
        local is2D = not Mode or Mode.Value == "2D"
        if is2D and onScreen then
            local bottom = project(root.Position - Vector3.new(0, ent.HipHeight + 1, 0))
            local top = project(root.Position + Vector3.new(0, ent.HipHeight + 1, 0))
            local width = math.max(2, math.abs(top.X - bottom.X) + 4)
            local height = math.max(2, math.abs(top.Y - bottom.Y))
            local position = Vector2.new(center.X - width * 0.5, center.Y - height * 0.5)
            if BoundingBox and BoundingBox.Enabled then
                setVisible(ref.Outline, Outline and Outline.Enabled == true)
                setVisible(ref.Main, true)
                setVisible(ref.Fill, Filled and Filled.Enabled == true)
                pcall(function()
                    ref.Main.Position = position
                    ref.Main.Size = Vector2.new(width, height)
                    ref.Main.Color = color
                    ref.Main.Transparency = alpha
                    ref.Main.Thickness = OutlineThickness and OutlineThickness.Value or 1
                    ref.Fill.Position = position
                    ref.Fill.Size = Vector2.new(width, height)
                    ref.Fill.Color = color
                    ref.Fill.Transparency = alpha
                    ref.Outline.Position = position - Vector2.one
                    ref.Outline.Size = Vector2.new(width + 2, height + 2)
                    ref.Outline.Color = outlineColor
                    ref.Outline.Transparency = alpha
                    ref.Outline.Thickness = (OutlineThickness and OutlineThickness.Value or 1) + 1
                end)
            end
            if HealthBar and HealthBar.Enabled then
                local target = math.clamp((ent.Health or 0) / math.max(ent.MaxHealth or 1, 1), 0, 1)
                if AnimatedFill and AnimatedFill.Enabled then
                    ref.HealthRatio = ref.HealthRatio or target
                    ref.HealthRatio = ref.HealthRatio + ((target - ref.HealthRatio) * 0.25)
                else
                    ref.HealthRatio = target
                end
                local ratio = math.clamp(ref.HealthRatio, 0, 1)
                local barTop = position.Y + height * (1 - ratio)
                setLine(ref.HealthBorder, Vector2.new(position.X - 7, position.Y), Vector2.new(position.X - 7, position.Y + height), true, outlineColor, 3, alpha)
                setLine(ref.HealthBar, Vector2.new(position.X - 7, barTop), Vector2.new(position.X - 7, position.Y), true, Color3.fromHSV(ratio / 2.5, 0.9, 0.9), 1, alpha)
            end
            local textY = position.Y - 7
            if Name and Name.Enabled then
                local label = identity(ent)
                local nameColor = color
                if GradientText and GradientText.Enabled then
                    local phase = (os.clock() * (FlowSpeed and FlowSpeed.Value or 0.4)) % 1
                    nameColor = color:Lerp(GradientColor and GradientColor.Value or Color3.fromRGB(70, 210, 255), (math.sin(phase * math.pi * 2) + 1) * 0.5)
                end
                setText(ref.NameOutline, label, Vector2.new(center.X, textY), outlineColor, 15, alpha, Outline and Outline.Enabled == true)
                setText(ref.Name, label, Vector2.new(center.X, textY), nameColor, 15, alpha, true)
            end
            if RankToggle and (RankToggle.Enabled or WinStreakToggle and WinStreakToggle.Enabled or DeflectingToggle and DeflectingToggle.Enabled) then
                -- rebuilt per entity per frame before: a labels table, three
                -- table.inserts, string.upper, two string.formats and a concat,
                -- all producing the same string unless a value actually changed
                local textCache = ref.TextCache
                if not textCache then
                    textCache = {}
                    ref.TextCache = textCache
                end
                local deflecting = DeflectingToggle and DeflectingToggle.Enabled and akiraIsDeflecting(ent.Player)
                local rank = RankToggle and RankToggle.Enabled and string.upper(akiraRankName(ent.Player)) or nil
                local streak = WinStreakToggle and WinStreakToggle.Enabled and akiraWinStreak(ent.Player) or nil
                local key = tostring(deflecting) .. "|" .. tostring(rank) .. "|" .. tostring(streak)
                if textCache.statusKey ~= key then
                    textCache.statusKey = key
                    local labels = {}
                    if deflecting then
                        labels[#labels + 1] = "DEFLECTING"
                    end
                    if rank then
                        labels[#labels + 1] = rank
                    end
                    if streak then
                        labels[#labels + 1] = string.format("%d WS", streak)
                    end
                    textCache.status = table.concat(labels, "  ")
                    textCache.statusCount = #labels
                end
                setText(ref.Status, textCache.status, Vector2.new(center.X, textY - 15), color, 12, alpha, textCache.statusCount > 0)
            else
                setVisible(ref.Status, false)
            end
            local bottomOffset = 0
            if HealthText and HealthText.Enabled then
                local hp = math.floor(ent.Health or 0)
                if ref.TextCache == nil or ref.TextCache.healthKey ~= hp then
                    ref.TextCache = ref.TextCache or {}
                    ref.TextCache.healthKey = hp
                    ref.TextCache.health = string.format("%d", hp)
                end
                setText(ref.HealthText, ref.TextCache.health, Vector2.new(center.X, textY - 14), color, 12, alpha, true)
            end
            -- weaponInfo() loops every fighter in FighterController.Objects and does
        -- child lookups plus GetAttribute calls, so it used to cost O(players^2)
        -- every frame for every entity even with both labels turned off.
        local wantWeapon = ShowWeapon and ShowWeapon.Enabled
        local wantAmmo = ShowAmmo and ShowAmmo.Enabled
        local info = (wantWeapon or wantAmmo) and weaponInfo(ent) or nil
            if ShowWeapon and ShowWeapon.Enabled and info then
                setText(ref.Weapon, info.Name, Vector2.new(center.X, position.Y + height + 8 + bottomOffset), color, 12, alpha, true)
                bottomOffset += 14
            end
            if ShowAmmo and ShowAmmo.Enabled and info and (info.Ammo ~= nil or info.Reserve ~= nil) then
                local ammo = info.Ammo or 0
                local maxAmmo = info.MaxAmmo or ammo
                local reserve = info.Reserve
                local textCache = ref.TextCache
                if not textCache then
                    textCache = {}
                    ref.TextCache = textCache
                end
                local key = ammo .. "/" .. maxAmmo .. "|" .. tostring(reserve)
                if textCache.ammoKey ~= key then
                    textCache.ammoKey = key
                    textCache.ammo = string.format("%d/%d", ammo, maxAmmo)
                    if reserve then
                        textCache.ammo ..= string.format(" (%d)", reserve)
                    end
                end
                setText(ref.Ammo, textCache.ammo, Vector2.new(center.X, position.Y + height + 8 + bottomOffset), color, 12, alpha, true)
            end
            if ShowDistance and ShowDistance.Enabled then
                local distance = entitylib.character and entitylib.character.RootPart and math.floor((entitylib.character.RootPart.Position - root.Position).Magnitude) or 0
                local textCache = ref.TextCache
                if not textCache then
                    textCache = {}
                    ref.TextCache = textCache
                end
                if textCache.distanceKey ~= distance then
                    textCache.distanceKey = distance
                    textCache.distance = string.format("[%dm]", distance)
                end
                setText(ref.Distance, textCache.distance, Vector2.new(center.X, position.Y + height + 8 + bottomOffset), color, 12, alpha, true)
            end
        end
        if HeadDot and HeadDot.Enabled then
            setVisible(ref.HeadDot, onScreen)
            if onScreen then
                pcall(function()
                    ref.HeadDot.Position = Vector2.new(headPoint.X, headPoint.Y)
                    ref.HeadDot.Color = color
                    ref.HeadDot.Transparency = alpha
                end)
            end
        end
        if GlowToggle and GlowToggle.Enabled then
            setVisible(ref.Glow, onScreen)
            if onScreen then
                pcall(function()
                    ref.Glow.Position = Vector2.new(headPoint.X, headPoint.Y)
                    ref.Glow.Radius = GlowSize and GlowSize.Value or 8
                    ref.Glow.Color = color
                    ref.Glow.Transparency = math.clamp(alpha + 0.7, 0, 1)
                end)
            end
        else
            setVisible(ref.Glow, false)
        end
        if LookDirection and LookDirection.Enabled then
            local lookEnd = head.CFrame * CFrame.new(0, 0, -3)
            local lookPoint, lookVisible = project(lookEnd.Position)
            setLine(ref.Look, Vector2.new(headPoint.X, headPoint.Y), Vector2.new(lookPoint.X, lookPoint.Y), onScreen and lookVisible, color, 1, alpha)
        end
        if Snaplines and Snaplines.Enabled then
            local origin = Vector2.new(screen.X * 0.5, SnaplineOrigin and SnaplineOrigin.Value == "Top" and 0 or SnaplineOrigin and SnaplineOrigin.Value == "Center" and screen.Y * 0.5 or screen.Y)
            setLine(ref.Snapline, origin, center, onScreen, color, 1, alpha)
        end
        if OffscreenArrows and OffscreenArrows.Enabled and not onScreen then
            local direction = center - Vector2.new(screen.X * 0.5, screen.Y * 0.5)
            if direction.Magnitude > 0 then
                direction = direction.Unit
            end
            local edge = Vector2.new(screen.X * 0.5, screen.Y * 0.5) + direction * math.min(screen.X, screen.Y) * 0.42
            setLine(ref.Arrow, Vector2.new(screen.X * 0.5, screen.Y * 0.5), edge, true, color, 2, alpha)
            pcall(function()
                ref.ArrowHead.Position = edge
                ref.ArrowHead.Color = color
                ref.ArrowHead.Transparency = alpha
                ref.ArrowHead.Visible = true
            end)
        end
        if Box3D and Box3D.Enabled and Mode and Mode.Value == "3D" then
            local half = root.Size * 0.5 + BOX3D_PAD_XY + Vector3.new(0, ent.HipHeight, 0)
            local corners = boxCorners
            corners[1] = root.CFrame * CFrame.new(-half.X, -half.Y, -half.Z)
            corners[2] = root.CFrame * CFrame.new(half.X, -half.Y, -half.Z)
            corners[3] = root.CFrame * CFrame.new(half.X, half.Y, -half.Z)
            corners[4] = root.CFrame * CFrame.new(-half.X, half.Y, -half.Z)
            corners[5] = root.CFrame * CFrame.new(-half.X, -half.Y, half.Z)
            corners[6] = root.CFrame * CFrame.new(half.X, -half.Y, half.Z)
            corners[7] = root.CFrame * CFrame.new(half.X, half.Y, half.Z)
            corners[8] = root.CFrame * CFrame.new(-half.X, half.Y, half.Z)
            local points = boxPoints
            for index = 1, 8 do
                points[index] = project(corners[index].Position)
            end
            local thickness = OutlineThickness and OutlineThickness.Value or 1
            for index = 1, 12 do
                local edge = BOX3D_EDGES[index]
                -- setLine only reads .X/.Y, so the projected point is passed
                -- straight through instead of allocating a Vector2 per corner
                setLine(ref.Box3D[index], points[edge[1]], points[edge[2]], true, color, thickness, alpha)
            end
        end
        if Skeleton and Skeleton.Enabled and Mode and Mode.Value == "Skeleton" then
            local headPart = ent.Character:FindFirstChild("Head") or head
            local torso = ent.Character:FindFirstChild("UpperTorso") or ent.Character:FindFirstChild("Torso")
            local leftArm = ent.Character:FindFirstChild("Left Arm") or ent.Character:FindFirstChild("LeftHand")
            local rightArm = ent.Character:FindFirstChild("Right Arm") or ent.Character:FindFirstChild("RightHand")
            local leftLeg = ent.Character:FindFirstChild("Left Leg") or ent.Character:FindFirstChild("LeftFoot")
            local rightLeg = ent.Character:FindFirstChild("Right Leg") or ent.Character:FindFirstChild("RightFoot")
            local bones = {
                {headPart and headPart.Position, torso and torso.Position},
                {torso and (torso.Position + Vector3.new(-1, 0.8, 0)), torso and (torso.Position + Vector3.new(1, 0.8, 0))},
                {torso and (torso.Position + Vector3.new(0, 0.8, 0)), torso and (torso.Position + Vector3.new(0, -0.8, 0))},
                {torso and (torso.Position + Vector3.new(-0.5, -0.8, 0)), torso and (torso.Position + Vector3.new(0.5, -0.8, 0))},
                {torso and (torso.Position + Vector3.new(-1, 0.8, 0)), leftArm and leftArm.Position},
                {torso and (torso.Position + Vector3.new(1, 0.8, 0)), rightArm and rightArm.Position},
                {torso and (torso.Position + Vector3.new(-0.5, 0.8, 0)), leftLeg and leftLeg.Position},
                {torso and (torso.Position + Vector3.new(0.5, 0.8, 0)), rightLeg and rightLeg.Position},
                {headPart and headPart.Position, headPart and (headPart.CFrame * CFrame.new(0, 0, -0.6)).Position},
                {leftArm and leftArm.Position, rightArm and rightArm.Position}
            }
            for index, bone in ipairs(bones) do
                local a = bone[1] and project(bone[1]) or nil
                local b = bone[2] and project(bone[2]) or nil
                -- setLine only reads .X/.Y, so the projected point is passed
                -- straight through instead of allocating a Vector2 per bone
                setLine(ref.Skeleton[index], a or Vector2.zero, b or Vector2.zero, a and b and a.Z > 0 and b.Z > 0, color, OutlineThickness and OutlineThickness.Value or 1, alpha)
            end
        end
        ensureHighlight(ent, ref, color)
    end
    local function rebuildAll()
        table.clear(Blocked)
        for ent in pairs(Reference) do
            destroyRef(ent)
        end
        if not ESP or not ESP.Enabled then
            return
        end
        for _, ent in ipairs(entitylib.List) do
            build(ent)
        end
    end
    local function refreshAll()
        if not ESP or not ESP.Enabled then
            return
        end
        for _, ent in ipairs(entitylib.List) do
            if not Reference[ent] then
                local isVisible = visible(ent)
                if allowed(ent, isVisible) then
                    build(ent)
                else
                    Blocked[ent] = true
                end
            end
            -- one pcall per entity per frame replaces the ~40 per-entity pcall
            -- closures that used to be allocated inside setLine/setText/setVisible
            if Reference[ent] then
                pcall(update, ent, Reference[ent])
            end
        end
    end

    ESP = AkiraLite.Catalogs.Render:AddModule({
        Name = 'ESP',
        Function = function(callback)
            active = callback == true
            if callback then
                ESP:Clean(entitylib.Events.EntityAdded:Connect(build))
                ESP:Clean(entitylib.Events.EntityRemoved:Connect(function(ent)
                    Blocked[ent] = nil
                    destroyRef(ent)
                end))
                -- only build/destroy here: the per-frame RenderStepped pass below
                -- already redraws every entity, so calling update() on this event
                -- too meant drawing each entity twice in the same frame
                ESP:Clean(entitylib.Events.EntityUpdated:Connect(function(ent)
                    if Reference[ent] then
                        pcall(update, ent, Reference[ent])
                    end
                end))
                ESP:Clean(RunService.RenderStepped:Connect(function()
                    pcall(refreshAll)
                end))
                rebuildAll()
            else
                for ent in pairs(Reference) do
                    destroyRef(ent)
                end
                table.clear(Blocked)
            end
        end
    })
    Mode = ESP:AddDropdown({
        Name = 'Mode',
        List = {'2D', '3D', 'Skeleton'},
        Function = refreshAll
    })
    BoundingBox = ESP:AddToggle({Name = 'Bounding Box', Default = true, Darker = true, Function = refreshAll})
    Filled = ESP:AddToggle({Name = 'Filled', Darker = true, Function = refreshAll})
    Outline = ESP:AddToggle({Name = 'Outline', Default = true, Darker = true, Function = refreshAll})
    OutlineThickness = ESP:AddSlider({Name = 'Outline Thickness', Min = 1, Max = 5, Default = 1, Decimal = 1, Darker = true, Function = refreshAll})
    Transparency = ESP:AddSlider({Name = 'Transparency', Min = 0, Max = 1, Default = 0, Decimal = 10, Function = refreshAll})
    Name = ESP:AddToggle({Name = 'Name', Darker = true, Function = refreshAll})
    DisplayName = ESP:AddToggle({Name = 'Use Displayname', Default = true, Darker = true, Function = refreshAll})
    HealthBar = ESP:AddToggle({Name = 'Health Bar', Darker = true, Function = refreshAll})
    HealthText = ESP:AddToggle({Name = 'Health Text', Darker = true, Function = refreshAll})
    ShowWeapon = ESP:AddToggle({Name = 'Show Weapon', Darker = true, Function = refreshAll})
    ShowAmmo = ESP:AddToggle({Name = 'Show Ammo', Darker = true, Function = refreshAll})
    ShowDistance = ESP:AddToggle({Name = 'Show Distance', Darker = true, Function = refreshAll})
    RankToggle = ESP:AddToggle({Name = 'Show Rank', Darker = true, Function = refreshAll})
    WinStreakToggle = ESP:AddToggle({Name = 'Show Win Streak', Darker = true, Function = refreshAll})
    DeflectingToggle = ESP:AddToggle({Name = 'Show Deflecting', Darker = true, Function = refreshAll})
    GradientText = ESP:AddToggle({Name = 'Gradient Text', Darker = true, Function = refreshAll})
    GradientColor = ESP:AddColorPicker({Name = 'Gradient Color', Default = Color3.fromRGB(70, 210, 255), Darker = true})
    FlowSpeed = ESP:AddSlider({Name = 'Flow Speed', Min = 0, Max = 2, Default = 0.4, Decimal = 100, Darker = true})
    GlowToggle = ESP:AddToggle({Name = 'Head Glow', Darker = true, Function = refreshAll})
    GlowSize = ESP:AddSlider({Name = 'Glow Size', Min = 2, Max = 30, Default = 8, Decimal = 1, Darker = true})
    AnimatedFill = ESP:AddToggle({Name = 'Animated Health Fill', Darker = true, Function = refreshAll})
    DistanceCheck = ESP:AddToggle({Name = 'Render Distance Check', Function = function(callback)
        if DistanceLimit then
            DistanceLimit.Frame.Visible = callback
        end
        rebuildAll()
    end})
    DistanceLimit = ESP:AddSlider({Name = 'Render Distance', Min = 0, Max = 512, Default = 128, Decimal = 1, Darker = true, Visible = false, Function = rebuildAll})
    VisibleOnly = ESP:AddToggle({Name = 'Visible Only', Function = rebuildAll})
    PriorityOnly = ESP:AddToggle({Name = 'Priority Only', Default = true, Function = rebuildAll})
    TeamFilter = ESP:AddDropdown({Name = 'Team Filter', List = {'All', 'Enemies', 'Teammates'}, Function = rebuildAll})
    Snaplines = ESP:AddToggle({Name = 'Snaplines', Darker = true, Function = refreshAll})
    SnaplineOrigin = ESP:AddDropdown({Name = 'Snapline Origin', List = {'Bottom', 'Center', 'Top'}, Darker = true, Function = refreshAll})
    HeadDot = ESP:AddToggle({Name = 'Head Dot', Darker = true, Function = refreshAll})
    LookDirection = ESP:AddToggle({Name = 'Look Direction', Darker = true, Function = refreshAll})
    OffscreenArrows = ESP:AddToggle({Name = 'Offscreen Arrows', Darker = true, Function = refreshAll})
    Skeleton = ESP:AddToggle({Name = 'Skeleton', Default = true, Darker = true, Function = refreshAll})
    Box3D = ESP:AddToggle({Name = '3D Box', Default = true, Darker = true, Function = refreshAll})
    Highlight = ESP:AddToggle({Name = 'Highlight', Darker = true, Function = refreshAll})
    ColorMode = ESP:AddDropdown({Name = 'Color Mode', List = {'Custom', 'Team', 'Rainbow', 'Visibility'}, Function = refreshAll})
    CustomColor = ESP:AddColorPicker({Name = 'Custom Color', Default = Color3.fromRGB(255, 255, 255), Function = refreshAll})
    FillColor = CustomColor
    VisibleColor = ESP:AddColorPicker({Name = 'Visible Color', Default = Color3.fromRGB(80, 255, 120), Darker = true, Function = refreshAll})
    HiddenColor = ESP:AddColorPicker({Name = 'Hidden Color', Default = Color3.fromRGB(255, 70, 70), Darker = true, Function = refreshAll})
    OutlineColor = ESP:AddColorPicker({Name = 'Outline Color', Default = Color3.fromRGB(0, 0, 0), Darker = true, Function = refreshAll})
end)
    akiraMark("block27:done")
    akiraMark("block28:start")
run(function()
    local RageBot
    local Weapon
    local RageMode
    local ItemNameInput
    local AutoReload
    local RapidFire
    local TapsPerFrame
    local KnifeBackstab
    local BackstabDelay
    local BackstabDistance
    local Visualizer
    local GradientText
    local ShowAmmo
    local RestoreWeapon
    local CharacterOrigin
    local RearPosition
    local DesyncDistance
    local HeavySpread
    local AvoidDeflect
local AvoidImmune
    local PreferLowestHP
    local Wallbang
    local HitboxExpander
    local Range
    local TargetHysteresis
    local RepStorage
    local FighterController
    local EnumLibrary
    local Utility
    local ItemLibrary
    local dependencyRetryAt = 0
    local currentTarget
    local currentTargetPart
    local currentTargetState
    local previousSlot
    local previousItem
    local weaponRemembered = false
    local rageEquipped = false
    local lastEquipAttempt = 0
    local lastAttack = 0
    local lastReload = 0
    local targetSince = 0
    local lastSeen = {}
    local owned = {}
    local rapidSnapshot
    local rapidSeen = {}
    local lastRapidScan = 0
    local guidOk, guidValue = pcall(function()
        return HttpService:GenerateGUID(false)
    end)
    local renderStepName = "AkiraRage_" .. tostring(guidOk and guidValue or os.clock())
    local renderBound = false
    local renderState
    local heartbeatConnection
    local visualizerCard
    local visualizerScale
    local visualizerStatus
    local visualizerState
    local visualizerAmmo
    local visualizerReserve
    local visualizerGun
    local visualizerHealth
    local visualizerHealthBar
    local visualizerHealthFill
    local visualizerTarget
    local visualizerGradient
local visualizerAccent
    local visualizerConnections = {}
    local visualizerDragging = false
    local visualizerDragBound = false
    local visualizerDragPos = nil
    local lastStatus = "SEARCHING"
    local hitboxOriginalSize
    local hitboxTargetSize
    local pendingTeleportCF
    local stageBackstabTeleport
    -- Visualizer text caches. updateVisualizer() runs from the rage loop every
    -- tick; writing an unchanged .Text still forces a re-measure and re-layout,
    -- so each row only writes when its string actually changes.
    local visualizerTextCache = {
        status = {false},
        state = {false},
        target = {false},
        health = {false},
        gun = {false},
        ammo = {false},
        reserve = {false}
    }
    local function setLabel(label, value, cache)
        if label == nil then return end
        if cache[1] ~= value then
            cache[1] = value
            label.Text = value
        end
    end
    local function setColor(label, value)
        if label ~= nil and label.BackgroundColor3 ~= value then
            label.BackgroundColor3 = value
        end
    end
    local function setTextColor(label, value)
        if label ~= nil and label.TextColor3 ~= value then
            label.TextColor3 = value
        end
    end
    -- Diagnostics + caching for the rage loop. A pcall'd Heartbeat that throws
    -- every frame used to be indistinguishable from a working bot, so the first
    -- occurrence of each distinct error is reported.
    local lastRageError
    local rageErrorCount = 0
    local rageStepErrors = {}
    -- Remotes and enum tokens used to be resolved with FindFirstChild walks and
    -- an EnumLibrary reflection call on EVERY tick. They are cached and only
    -- re-resolved when missing, which is both cheaper and more reliable (a
    -- remote that appears after the bot is enabled gets picked up).
    local cachedUseRemote
    local cachedCameraRemote
    local cachedShootToken
    local cachedPlayerList
    local cachedPlayerListAt = 0
    local lastSlotAssert = 0
    local swapSince
    -- shot telemetry: "attacks slow" is ambiguous between "we are not sending
    -- payloads" and "we send them and the server drops them", so count both
    local shotsSent = 0
    local shotsFailed = 0
    local lastShotReport = 0

    -- Move our character to a CFrame and restore it on the very next render
    -- step, so the server only ever sees a single desynced position.
    local function applyTeleport(root, cframe)
        if not root or not root.Parent then
            return false
        end
        local previous = root.CFrame
        local velocity = root.AssemblyLinearVelocity
        local rotVelocity = root.RotVelocity
        if not pcall(function()
            root.CFrame = cframe
        end) then
            return false
        end
        renderState = {
            Root = root,
            Previous = previous,
            Velocity = velocity,
            RotVelocity = rotVelocity
        }
        return true
    end

    -- Queued variant: the knife backstab needs the hit to register first, so
    -- the move is deferred and applied by the heartbeat loop once it is due.
    stageBackstabTeleport = function(root, cframe)
        pendingTeleportCF = {Root = root, CFrame = cframe}
    end

    local function consumePendingTeleport()
        local queued = pendingTeleportCF
        if not queued then
            return
        end
        pendingTeleportCF = nil
        applyTeleport(queued.Root, queued.CFrame)
    end

    local function own(value)
        if value == nil then
            return
        end
        if RageBot and type(RageBot.Clean) == "function" then
            RageBot:Clean(value)
        else
            table.insert(owned, value)
        end
    end

    local function disconnect(value)
        if type(value) == "thread" then
            pcall(task.cancel, value)
        elseif value then
            pcall(function()
                value:Disconnect()
            end)
        end
    end

    local function ownVisualizer(value)
        if value ~= nil then
            table.insert(visualizerConnections, value)
        end
        own(value)
    end

    local function childPath(root, ...)
        local node = root
        for _, name in ipairs({...}) do
            if not node then
                return nil
            end
            node = node:FindFirstChild(name)
        end
        return node
    end

    local function resolveDependencies()
        if FighterController and EnumLibrary and Utility and ItemLibrary then
            return true
        end
        if os.clock() < dependencyRetryAt then
            return false
        end
        dependencyRetryAt = os.clock() + 0.5
        RepStorage = RepStorage or cloneref(game:GetService("ReplicatedStorage"))
        local rivals = rawget(AkiraLite, "Rivals")
        if type(rivals) == "table" then
            EnumLibrary = EnumLibrary or rawget(rivals, "Enums") or rawget(rivals, "Enum")
            Utility = Utility or rawget(rivals, "Util") or rawget(rivals, "Utility")
            ItemLibrary = ItemLibrary or rawget(rivals, "ItemLib") or rawget(rivals, "ItemLibrary")
        end
        local modules = RepStorage and RepStorage:FindFirstChild("Modules")
        local function requireChild(name)
            local module = modules and modules:FindFirstChild(name)
            if not module then
                return nil
            end
            local ok, result = pcall(require, module)
            if ok then
                return result
            end
            return nil
        end
        EnumLibrary = EnumLibrary or requireChild("EnumLibrary")
        Utility = Utility or requireChild("Utility")
        ItemLibrary = ItemLibrary or requireChild("ItemLibrary")
        if not FighterController then
            local rivals = rawget(AkiraLite, "Rivals")
            local source = type(rivals) == "table" and rawget(rivals, "Fighter") or nil
            if type(source) == "table" then
                FighterController = source
            else
                local controllers = lplr and lplr:FindFirstChild("PlayerScripts")
                controllers = controllers and controllers:FindFirstChild("Controllers")
                local module = controllers and controllers:FindFirstChild("FighterController")
                if module then
                    local ok, result = pcall(require, module)
                    if ok and type(result) == "table" then
                        FighterController = result
                    end
                end
            end
        end
        return FighterController ~= nil
    end

    local function localFighter()
        if not FighterController then
            return nil
        end
        local fighter = rawget(FighterController, "LocalFighter")
        if type(fighter) == "table" then
            return fighter
        end
        if type(FighterController.GetFighter) == "function" then
            local ok, result = pcall(FighterController.GetFighter, FighterController, lplr)
            if ok and type(result) == "table" then
                return result
            end
            if lplr.Character then
                local okCharacter, resultCharacter = pcall(FighterController.GetFighter, FighterController, lplr.Character)
                if okCharacter and type(resultCharacter) == "table" then
                    return resultCharacter
                end
            end
        end
        return nil
    end

    local function readValue(object, key)
        if type(object) ~= "table" or type(object.Get) ~= "function" then
            return nil
        end
        local ok, value = pcall(object.Get, object, key)
        return ok and value or nil
    end

    local function itemName(item)
        if type(item) == "string" then
            return item
        end
        if type(item) ~= "table" then
            return nil
        end
        local name = rawget(item, "Name") or rawget(item, "ItemName") or rawget(item, "name")
        if name then
            return name
        end
        local viewModel = rawget(item, "ViewModel")
        if viewModel then
            if typeof(viewModel) == "Instance" then
                return viewModel.Name
            end
            if type(viewModel) == "table" then
                return rawget(viewModel, "Name") or rawget(viewModel, "ItemName")
            end
        end
        local config = rawget(item, "Config")
        if type(config) == "table" then
            return rawget(config, "Name") or rawget(config, "ItemName")
        end
        return nil
    end

    local function itemInfo(item)
        if type(item) ~= "table" then
            return nil
        end
        return rawget(item, "Info") or rawget(item, "Config") or rawget(item, "Data") or readValue(item, "Info")
    end

    local function itemValue(item, key)
        local value = readValue(item, key)
        if value ~= nil then
            return value
        end
        local info = itemInfo(item)
        if type(info) == "table" then
            return rawget(info, key)
        end
        return nil
    end

    local function normalizeCategory(value)
        if type(value) == "string" then
            local lower = value:lower()
            if lower == "1" or lower == "primary" or lower == "gun" or lower == "primaryweapon" then
                return "Primary", 1
            elseif lower == "2" or lower == "secondary" or lower == "sidearm" or lower == "secondaryweapon" then
                return "Secondary", 2
            elseif lower == "3" or lower == "melee" or lower == "knife" or lower == "third" then
                return "Melee", 3
            end
        elseif value == 1 then
            return "Primary", 1
        elseif value == 2 then
            return "Secondary", 2
        elseif value == 3 then
            return "Melee", 3
        end
        return nil, nil
    end

    local function categoryFor(item, key)
        local info = itemInfo(item)
        local values = {
            rawget(item, "Slot"), rawget(item, "Index"), rawget(item, "ItemType"),
            rawget(item, "Type"), rawget(item, "Category"), key,
            type(info) == "table" and (rawget(info, "Type") or rawget(info, "Category") or (rawget(info, "Class") == "Melee" and "melee")) or nil
        }
        for index = 1, 7 do
            local category, slot = normalizeCategory(values[index])
            if category then
                return category, slot
            end
        end
        local name = string.lower(tostring(itemName(item) or ""))
        if string.find(name, "knife", 1, true) or string.find(name, "dagger", 1, true)
            or string.find(name, "machete", 1, true) or string.find(name, "katana", 1, true)
            or string.find(name, "karambit", 1, true) or string.find(name, "chancla", 1, true)
            or string.find(name, "balisong", 1, true) or string.find(name, "fist", 1, true)
            or string.find(name, "bat", 1, true) then
            return "Melee", 3
        end
        return nil, nil
    end

    local function inventorySources(fighter)
        local sources = {}
        if type(fighter) ~= "table" then
            return sources
        end
        for _, key in ipairs({"Items", "Loadout", "Slots", "EquippedItems", "Inventory"}) do
            local source = rawget(fighter, key)
            if type(source) == "table" then
                table.insert(sources, source)
            end
        end
        local data = rawget(fighter, "Data")
        if type(data) == "table" then
            for _, key in ipairs({"Items", "Loadout", "Slots", "Inventory"}) do
                local source = rawget(data, key)
                if type(source) == "table" then
                    table.insert(sources, source)
                end
            end
        end
        return sources
    end

    local function collectInventory(fighter)
        local result = {}
        local seen = {}
        for _, source in ipairs(inventorySources(fighter)) do
            for key, item in pairs(source) do
                if type(item) == "table" then
                    local category, slot = categoryFor(item, key)
                    if category and not seen[item] then
                        seen[item] = true
                        local usable = rawget(item, "Usable")
                        if usable == nil then
                            usable = rawget(item, "Available")
                        end
                        if usable ~= false then
                            table.insert(result, {
                                Item = item,
                                Category = category,
                                Slot = slot or (type(key) == "number" and key or type(key) == "string" and tonumber(key) or nil)
                            })
                        end
                    end
                end
            end
        end
        return result
    end

    local function itemID(item)
        local data = type(item) == "table" and rawget(item, "Data") or nil
        return (type(data) == "table" and rawget(data, "ObjectID")) or (type(item) == "table" and rawget(item, "ObjectID")) or itemValue(item, "ObjectID")
    end

    local function isEquipped(fighter, entry)
        local item = entry and entry.Item
        if not fighter or not item then
            return false
        end
        if rawget(item, "IsEquipped") == true then
            return true
        end
        local equipped = rawget(fighter, "EquippedItem")
        if equipped == item then
            return true
        end
        if type(equipped) == "string" or type(equipped) == "number" then
            return tostring(equipped) == tostring(itemID(item))
        end
        local equippedID = type(equipped) == "table" and itemID(equipped) or nil
        return equippedID ~= nil and equippedID == itemID(item)
    end

    local function slotFor(fighter, item)
        if type(item) == "string" or type(item) == "number" then
            for _, entry in ipairs(collectInventory(fighter)) do
                if tostring(itemID(entry.Item) or "") == tostring(item) then
                    return entry.Slot
                end
            end
            return nil
        end
        for _, entry in ipairs(collectInventory(fighter)) do
            if entry.Item == item or (itemID(entry.Item) ~= nil and itemID(entry.Item) == itemID(item)) then
                return entry.Slot
            end
        end
        return nil
    end

    local function rememberWeapon(fighter)
        previousItem = rawget(fighter, "EquippedItem")
        previousSlot = slotFor(fighter, previousItem)
        weaponRemembered = true
    end

    local function equipEntry(fighter, entry)
        if not fighter or not entry or not entry.Slot then
            return false
        end
        local now = os.clock()
        if now - lastEquipAttempt < 0.12 then
            return false
        end
        lastEquipAttempt = now
        local ok = pcall(function()
            fighter:EquipItem(entry.Slot)
        end)
        if not ok then
            pcall(function()
                fighter:Input("EquipItem", entry.Slot)
            end)
        end
        if ok then
            rageEquipped = true
        end
        return ok
    end

    local function restoreWeapon(fighter, force)
        if not RestoreWeapon or not RestoreWeapon.Enabled or not fighter or not previousSlot then
            return
        end
        if previousItem and slotFor(fighter, previousItem) ~= previousSlot then
            return
        end
        if not force and os.clock() - lastEquipAttempt < 0.12 then
            return
        end
        lastEquipAttempt = os.clock()
        local ok = pcall(function()
            fighter:EquipItem(previousSlot)
        end)
        if not ok then
            pcall(function()
                fighter:Input("EquipItem", previousSlot)
            end)
        end
    end

    local function selectedInventory(fighter)
        local entries = collectInventory(fighter)
        if #entries == 0 then
            return nil
        end
        local category = Weapon and Weapon.Value or "Primary"
        local requested = ItemNameInput and string.lower(ItemNameInput.Value or "") or ""
        local fallback
        for _, entry in ipairs(entries) do
            if entry.Category == category then
                fallback = fallback or entry
                local name = string.lower(tostring(itemName(entry.Item) or ""))
                if requested ~= "" and string.find(name, requested, 1, true) then
                    return entry
                end
            end
        end
        return requested == "" and fallback or nil
    end

    local cooldownFields = {
        "ShootCooldown", "BurstCooldown", "AttackCooldown", "HeavyAttackCooldown",
        "_shoot_cooldown", "_attack_cooldown", "_heavy_attack_cooldown"
    }
    local function gatherCooldowns(root, result, seen, depth)
        if type(root) ~= "table" or depth > 7 or seen[root] then
            return
        end
        seen[root] = true
        for _, field in ipairs(cooldownFields) do
            local value = rawget(root, field)
            if type(value) == "number" then
                table.insert(result, {Object = root, Field = field, Value = value})
            end
        end
        for _, value in pairs(root) do
            if type(value) == "table" then
                gatherCooldowns(value, result, seen, depth + 1)
            end
        end
        seen[root] = nil
    end

    local restoreRapid
    local function applyRapid(fighter)
        if not RapidFire or not RapidFire.Enabled then
            restoreRapid()
            return
        end
        local now = os.clock()
        if now - lastRapidScan < 0.25 then
            return
        end
        lastRapidScan = now
        rapidSnapshot = rapidSnapshot or {}
        local additions = {}
        local seen = {}
        if ItemLibrary then
            gatherCooldowns(ItemLibrary, additions, seen, 0)
        end
        if fighter then
            gatherCooldowns(fighter, additions, seen, 0)
        end
        for _, entry in ipairs(additions) do
            local key = tostring(entry.Object) .. ":" .. entry.Field
            if not rapidSeen[key] then
                rapidSeen[key] = true
                table.insert(rapidSnapshot, entry)
                pcall(rawset, entry.Object, entry.Field, 0.000000001)
            end
        end
    end

    restoreRapid = function()
        if not rapidSnapshot then
            return
        end
        for _, entry in ipairs(rapidSnapshot) do
            if type(entry.Object) == "table" then
                pcall(rawset, entry.Object, entry.Field, entry.Value)
            end
        end
        table.clear(rapidSnapshot)
        table.clear(rapidSeen)
        rapidSnapshot = nil
    end

    local SpectateController
    local function getSpectateController()
        if SpectateController ~= nil then
            return SpectateController or nil
        end
        local controllers = lplr and lplr:FindFirstChild("PlayerScripts")
        controllers = controllers and controllers:FindFirstChild("Controllers")
        local module = controllers and controllers:FindFirstChild("SpectateController")
        if not module then
            return nil
        end
        local ok, result = pcall(require, module)
        SpectateController = (ok and type(result) == "table") and result or false
        return SpectateController or nil
    end

    -- Reference behaviour: a target holding a knife viewmodel gets a much
    -- larger vertical origin offset, otherwise a small forward offset.
    local function hasKnifeViewModel(targetPlayer)
        if not targetPlayer then
            return false
        end
        local viewModels = workspace:FindFirstChild("ViewModels")
        if not viewModels then
            return false
        end
        local targetName = targetPlayer.Name
        for _, model in ipairs(viewModels:GetChildren()) do
            if model:IsA("Model")
                and string.find(model.Name, targetName, 1, true)
                and string.find(model.Name, "Knife", 1, true) then
                return true
            end
        end
        return false
    end

    local function isEnemy(player)
        if not player or player == lplr then
            return false
        end
        -- Duel teams take priority: TeamID attributes are not set in duels.
        local spectate = getSpectateController()
        local duel = spectate and rawget(spectate, "CurrentDuelSubject") or nil
        local localDueler = nil
        if type(duel) == "table" and type(duel.GetDueler) == "function" then
            local ok, result = pcall(duel.GetDueler, duel, lplr)
            if ok then
                localDueler = result
            end
        end
        local localTeam = nil
        if type(localDueler) == "table" and type(localDueler.Get) == "function" then
            local ok, result = pcall(localDueler.Get, localDueler, "TeamID")
            if ok then
                localTeam = result
            end
        end
        if localTeam ~= nil and type(duel) == "table" and type(rawget(duel, "Duelers")) == "table" then
            for _, dueler in ipairs(rawget(duel, "Duelers")) do
                if type(dueler) == "table" and rawget(dueler, "Player") == player then
                    local team = nil
                    if type(dueler.Get) == "function" then
                        local ok, result = pcall(dueler.Get, dueler, "TeamID")
                        if ok then
                            team = result
                        end
                    end
                    return team ~= localTeam
                end
            end
        end
        local a = lplr and lplr:GetAttribute("TeamID")
        local b = player and player:GetAttribute("TeamID")
        if a ~= nil and b ~= nil and tostring(a) ~= "" and tostring(b) ~= "" then
            return tostring(a) ~= tostring(b)
        end
        if lplr and player and lplr.Team and player.Team then
            return lplr.Team ~= player.Team
        end
        return true
    end

    local rageRejectCounts = {}
    local function rageReject(reason)
        rageRejectCounts[reason] = (rageRejectCounts[reason] or 0) + 1
    end
    AkiraLite.RageRejectCounts = rageRejectCounts

    -- Attack cadence, declared HERE because rageLoop (further down) reads both.
    -- They used to sit with the controls near the end of this block, which meant
    -- rageLoop was reading two nil globals: `interval` silently fell back to 0
    -- (fine) but `taps` stayed nil, so the tap loop threw every tick.
    --
    -- 0 = fire on every heartbeat (the reference behaviour); 8 = eight payloads
    -- per heartbeat, overridable by the Taps Per Frame slider.
    local ATTACK_INTERVAL = 0
    local TAPS_PER_FRAME = 8
    local function validTarget(player)
        if not player or player == lplr or not player:IsA("Player") or not player:IsDescendantOf(game) then
            rageReject("self")
            return nil
        end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local localCharacter = lplr.Character
        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
        if not character or not character:IsDescendantOf(workspace) or not root or not head or not humanoid or humanoid.Health <= 0 or not localRoot then
            rageReject("structure")
            return nil
        end
        local tracked = entitylib.getEntity(character)
        if tracked and tracked.Targetable == false then
            rageReject("targetable")
            return nil
        end
        if not isEnemy(player) then
            local seen = lastSeen[player]
            if seen then
                seen.At = os.clock()
            end
            rageReject("notEnemy")
            return nil
        end
        if AvoidDeflect and AvoidDeflect.Enabled and akiraIsDeflecting(player) then
            rageReject("deflect")
            return nil
        end
        -- Skip immune targets entirely: shooting someone who cannot be damaged
        -- just wastes the payload, and the bot used to lock onto them and look
        -- broken. Once their immunity drops they become a valid target again on
        -- the very next tick, because this is re-evaluated per tick.
        if AvoidImmune and AvoidImmune.Enabled and akiraIsImmune(player) then
            local seenImmune = lastSeen[player]
            if seenImmune then
                seenImmune.At = os.clock()
            end
            rageReject("immune")
            return nil
        end
        local distance = (localRoot.Position - root.Position).Magnitude
        if Range and distance > Range.Value then
            local seen = lastSeen[player]
            if seen then
                seen.At = os.clock()
            end
            rageReject("range")
            return nil
        end
        local now = os.clock()
        local seen = lastSeen[player]
        if not seen or seen.Character ~= character then
            lastSeen[player] = {Character = character, At = now}
            seen = lastSeen[player]
        else
            seen.At = now
        end
        -- No line-of-sight raycast at all. This used to veto any target with
        -- geometry in the way, so the bot stood there refusing to shoot. When
        -- the veto was removed the raycast was kept "for the indicator", but the
        -- value was written to seen.LOS and never read by anything - while
        -- costing a workspace raycast per player per Heartbeat. The server
        -- decides whether a shot connected; sending the payload is the point.
        seen.At = now
        rageReject("ok")
        -- Rivals characters expose the network-owned hitboxes separately from the
        -- cosmetic Head/Torso. The server validates against the hitboxes, so aim
        -- there first and only fall back to the cosmetic parts.
        local hitbox = character:FindFirstChild("HitboxHead")
            or character:FindFirstChild("HitboxTorso")
            or head
        return {
            Player = player,
            Character = character,
            Root = root,
            Head = head,
            HitboxPart = hitbox,
            Humanoid = humanoid,
            Distance = distance
        }
    end

    -- Forward declaration. knifeEngaged() is defined further up and calls
    -- isEquippedKnife(), which is only defined further down. Without this the
    -- reference resolved to a GLOBAL (nil) and every tick died with
    -- "attempt to call a nil value" - i.e. the whole bot did nothing.
    local isEquippedKnife

    local function rageMode()
        -- Only Ranged and Knife exist. Anything unexpected falls back to Ranged
        -- so a stale saved config pointing at the removed "Auto" entry still
        -- fires instead of silently doing nothing.
        local value = RageMode and RageMode.Value or "Ranged"
        if value == "Knife" then
            return "Knife"
        end
        return "Ranged"
    end

    local SLOT_NUMBERS = {Primary = 1, Secondary = 2, Melee = 3}

    local function desiredSlot()
        -- In Knife mode the melee slot is what we want, otherwise whatever the
        -- Weapon dropdown asks for.
        if rageMode() == "Knife" then
            return 3
        end
        local category = Weapon and Weapon.Value or "Primary"
        return SLOT_NUMBERS[category] or 1
    end

    local function ensureSlotEquipped(fighter)
        -- The reference implementation re-asserts the equipped slot on a timer
        -- because the game (or a death/respawn) can change it underneath us, and
        -- a stale slot is a main reason the bot "does not work" half the time.
        local slot = desiredSlot()
        local equipped = fighter and rawget(fighter, "EquippedItem")
        if equipped == nil then
            return
        end
        local currentSlot = slotFor(fighter, equipped)
        if currentSlot == slot then
            return
        end
        local now = os.clock()
        if now - (lastSlotAssert or 0) < 0.5 then
            return
        end
        lastSlotAssert = now
        pcall(function()
            fighter:EquipItem(slot)
        end)
    end

    local function knifeEngaged(fighter)
        -- Whether the knife payload should be used this tick.
        if rageMode() ~= "Knife" then
            return false
        end
        if isEquippedKnife(fighter) then
            return true
        end
        -- Selected Knife: also accept any other melee-slot item (katana, tanto,
        -- ...) rather than only something literally named "Knife".
        local equipped = fighter and rawget(fighter, "EquippedItem")
        if equipped ~= nil and slotFor(fighter, equipped) == 3 then
            return true
        end
        return false
    end

    local function playerList()
        -- Players:GetPlayers() allocates a fresh table on every call, and this
        -- runs on Heartbeat. Rebuild it only when the player count changes or the
        -- cache is stale.
    local now = os.clock()
    -- PlayerCount is a plain property read, so the cache guard no longer
    -- allocates a table just to decide whether the cache is still valid
    if cachedPlayerList and now - cachedPlayerListAt < 1 and Players.PlayerCount == #cachedPlayerList then
        return cachedPlayerList
    end
        cachedPlayerList = Players:GetPlayers()
        cachedPlayerListAt = now
        return cachedPlayerList
    end

    local function chooseTarget()
        -- rageRejectCounts is only read for diagnostics, so zeroing it on every
        -- single tick was pure churn.
        local best
        for _, player in ipairs(playerList()) do
            local candidate = validTarget(player)
            if candidate then
                if not best then
                    best = candidate
                elseif PreferLowestHP and PreferLowestHP.Enabled then
                    local candidateHealth = candidate.Humanoid.Health or 0
                    local bestHealth = best.Humanoid.Health or 0
                    if candidateHealth < bestHealth or (candidateHealth == bestHealth and candidate.Distance < best.Distance) then
                        best = candidate
                    end
                elseif candidate.Distance < best.Distance then
                    best = candidate
                end
            end
        end
        -- Relaxed fallback. validTarget() is strict: a player is rejected for
        -- team, deflecting, range, Targetable, or a half-built character. When
        -- every player trips one of those the bot simply did nothing, which is
        -- the "it wont work alot of the time" symptom. If the strict pass found
        -- nobody but there IS a living enemy in range, take the closest one and
        -- let the attack path deal with it.
        if not best then
            local localCharacter = lplr.Character
            local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
            if localRoot then
                local closest
                local closestDistance
                for _, player in ipairs(playerList()) do
                    if player ~= lplr and player:IsA("Player") and player:IsDescendantOf(game) then
                        local character = player.Character
                        local root = character and character:FindFirstChild("HumanoidRootPart")
                        local head = character and character:FindFirstChild("Head")
                        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        if root and head and humanoid and humanoid.Health > 0 and character:IsDescendantOf(workspace) then
                            -- the relaxed fallback must respect immunity too, or it
                            -- would happily pick the one player we just said to avoid
                            if AvoidImmune and AvoidImmune.Enabled and akiraIsImmune(player) then
                                rageReject("immune")
                            else
                                local distance = (localRoot.Position - root.Position).Magnitude
                                local tracked = entitylib.getEntity(character)
                                if tracked == nil or tracked.Targetable ~= false then
                                    if not closest or distance < closestDistance then
                                        closest = {
                                            Player = player,
                                            Character = character,
                                            Root = root,
                                            Head = head,
                                            Humanoid = humanoid,
                                            Distance = distance,
                                        }
                                        closestDistance = distance
                                    end
                                end
                            end
                        end
                    end
                end
                if closest then
                    best = closest
                    rageReject("relaxedFallback")
                end
            end
        end
        local current = currentTarget and validTarget(currentTarget) or nil
        if current then
            local hysteresis = TargetHysteresis and TargetHysteresis.Value or 0
            if not best or best.Player == current.Player or current.Distance <= best.Distance * (1 + hysteresis / 100) then
                best = current
            end
        end
        if not best then
            currentTarget = nil
            currentTargetPart = nil
            currentTargetState = nil
            targetSince = 0
        elseif best.Player ~= currentTarget then
            currentTarget = best.Player
            targetSince = os.clock()
        end
        currentTargetPart = best and best.Head or nil
        currentTargetState = best
        return best
    end

    local enumTokenCache = {}
    local cachedAimToken, cachedHeavyToken
    local function enumToken(name, fallback)
        -- memoised: EnumLibrary.ToEnum is a pcall'd reflection, and several hot
        -- paths asked for the same token on every single tick
        local token = enumTokenCache[name]
        if token ~= nil then
            return token
        end
        if EnumLibrary then
            local fn = EnumLibrary.ToEnum or EnumLibrary[":ToEnum"]
            if type(fn) == "function" then
                local ok, resolved = pcall(fn, EnumLibrary, name)
                if ok and resolved ~= nil then
                    enumTokenCache[name] = resolved
                    return resolved
                end
            end
        end
        local result = fallback or name
        enumTokenCache[name] = result
        return result
    end

    local function fireReloadPayload(remote, objectID, token, reloadToken)
        remote:FireServer(objectID, token, {[utf8.char(1)] = reloadToken, [utf8.char(2)] = reloadToken}, nil)
    end

    local function useRemote()        -- cached: this used to walk RepStorage with FindFirstChild on every
        -- single attack, i.e. several times a second
        if cachedUseRemote and cachedUseRemote.Parent then
            return cachedUseRemote
        end
        cachedUseRemote = childPath(RepStorage, "Remotes", "Replication", "Fighter", "UseItem")
        return cachedUseRemote
    end

    local function cameraRemote()
        if cachedCameraRemote and cachedCameraRemote.Parent then
            return cachedCameraRemote
        end
        cachedCameraRemote = childPath(RepStorage, "Remotes", "Replication", "Fighter", "UpdateCameraRotation")
        return cachedCameraRemote
    end

    local function encodeCameraRotation(value)
        if Utility and type(Utility.EncodeCameraRotation) == "function" then
            local ok, encoded = pcall(Utility.EncodeCameraRotation, Utility, value)
            if ok and encoded ~= nil then
                return encoded
            end
        end
        return value
    end

    local function sendViewAngles(targetRoot)
        local remote = cameraRemote()
        if not remote or not targetRoot then
            return false
        end
        local pitch, yaw = targetRoot.CFrame:ToOrientation()
        return pcall(function()
            remote:FireServer(encodeCameraRotation(Vector2.new(math.deg(pitch), math.deg(yaw))), nil)
        end)
    end

    local function encodeCFrame(value)
        if Utility and type(Utility.EncodeCFrame) == "function" then
            local ok, encoded = pcall(Utility.EncodeCFrame, Utility, value)
            if ok then
                return encoded
            end
        end
        return value
    end

    local function itemAmmo(item)
        local data = type(item) == "table" and rawget(item, "Data") or nil
        local value = type(data) == "table" and rawget(data, "Ammo") or nil
        if value == nil then
            value = itemValue(item, "Ammo") or itemValue(item, "CurrentAmmo")
        end
        return type(value) == "number" and value or nil
    end

    local function itemMaxAmmo(item)
        local info = itemInfo(item)
        local value = type(info) == "table" and (rawget(info, "MaxAmmo") or rawget(info, "MagSize") or rawget(info, "ClipSize")) or nil
        if value == nil then
            value = itemValue(item, "MaxAmmo") or itemValue(item, "MagSize") or itemValue(item, "ClipSize")
        end
        return type(value) == "number" and value or nil
    end

    local function itemReloading(item)
        local now = os.clock()
        for _, field in ipairs({"_reload_cooldown", "_shoot_cooldown_no_ammo"}) do
            local value = type(item) == "table" and rawget(item, field) or nil
            if type(value) == "number" and value > now then
                return true
            end
        end
        return false
    end

    local function reloadItem(fighter, entry)
        local item = entry and entry.Item
        if not item or itemReloading(item) then
            return
        end
        local ammo = itemAmmo(item)
        local maxAmmo = itemMaxAmmo(item)
        if ammo and maxAmmo and ammo >= maxAmmo then
            return
        end
        local now = os.clock()
        if now - lastReload < 0.3 then
            return
        end
        lastReload = now
        local used = false
        for _, methodName in ipairs({"StartReloading", "Reload"}) do
            local method = type(item) == "table" and item[methodName] or nil
            if type(method) == "function" then
                local ok = pcall(method, item)
                used = ok
                if ok then
                    break
                end
            end
        end
        if used then
            return
        end
        if fighter then
            local inputOk = pcall(function()
                fighter:Input("StartReloading")
            end)
            if inputOk then
                return
            end
        end
        local remote = useRemote()
        local objectID = itemID(item)
        if remote and objectID then
            local token = enumToken("StartReloading", "StartReloading")
            local reloadToken = enumToken("Reload", "Reload")
            pcall(fireReloadPayload, remote, objectID, token, reloadToken)
        end
    end

    -- Mirrors the known-good reference payload exactly:
    --   cameradata[1][0] = aim CFrame
    --   cameradata[1][1] = TARGET's CFrame   (NOT the aim CFrame)
    --   cameradata[1][2] = target head instance
    --   cameradata[1][3] = jittered aim point in head object space
    -- and nothing else at the top level. The action is always StartShooting.
    --
    -- The four payload keys are hoisted: utf8.char() allocated a fresh string on
    -- every call, and this table is built once per tap (up to 8x per heartbeat).
    local K0, K1, K2, K3 = utf8.char(0), utf8.char(1), utf8.char(2), utf8.char(3)
    local function buildCameraData(head, aimCF, spread)
        local targetCF = head.CFrame
        local amount = spread or 0.1
        local jitter = Vector3.new(
            (math.random() - 0.5) * amount,
            (math.random() - 0.5) * amount,
            (math.random() - 0.5) * amount
        )
        local objSpaceHeadOffset = targetCF:ToObjectSpace(CFrame.new(head.Position + jitter))
        return {
            [K1] = {
                [K0] = encodeCFrame(aimCF),
                [K1] = encodeCFrame(targetCF),
                [K2] = head,
                [K3] = encodeCFrame(objSpaceHeadOffset)
            }
        }
    end

    -- named target for the per-payload pcall (no closure per shot)
    local function firePayload(remote, objectID, action, head, aimCF, spread)
        remote:FireServer(objectID, action, buildCameraData(head, aimCF, spread), nil)
    end

    -- the knife payload, hoisted out of the per-swing closure
    local KNIFE_SWING_OFFSET = CFrame.new(0.43, 0.25, 0.42)
    local function fireKnifePayload(remote, objectID, action, anim, swingCF, head)
        remote:FireServer(objectID, action, {
            [K1] = {
                [K0] = encodeCFrame(swingCF),
                [K1] = encodeCFrame(swingCF),
                [K2] = head,
                [K3] = encodeCFrame(KNIFE_SWING_OFFSET)
            },
            [K2] = anim
        }, nil)
    end

    local function attackOnce(fighter, entry, target, aimCF)
        local item = entry and entry.Item
        local remote = useRemote()
        local objectID = itemID(item)
        local head = target and (target.HitboxPart or target.Head)
        if not item or not head or not objectID or not remote then
            -- count WHY it could not fire, otherwise "attacks slow" is
            -- indistinguishable from "attacks rejected by the server"
            if not remote then
                rageReject("noRemote")
            elseif not objectID then
                rageReject("noObjectID")
            elseif not head then
                rageReject("noHead")
            else
                rageReject("noItem")
            end
            return false
        end
        -- the enum token is resolved once instead of reflecting through
        -- EnumLibrary on every attack
        if cachedShootToken == nil then
            cachedShootToken = enumToken("StartShooting", "StartShooting")
        end
        local action = cachedShootToken
        local spread = (HeavySpread and HeavySpread.Value) or 0.1
        -- named pcall target instead of a fresh closure: this runs up to
        -- TAPS_PER_FRAME times per heartbeat
        local ok = pcall(firePayload, remote, objectID, action, head, aimCF, spread)
        if ok then
            shotsSent = (shotsSent or 0) + 1
            return true
        end
        shotsFailed = (shotsFailed or 0) + 1
        -- The cached remote may have been replaced by the game (remotes get
        -- swapped on respawn). Drop the cache and let the next tick re-resolve,
        -- otherwise a stale remote would fail forever.
        cachedUseRemote = nil
        -- fallback: drive the item directly if the remote path is unavailable
        local method = item["Use"] or item["StartShooting"] or item["Shoot"]
        if type(method) ~= "function" then
            return false
        end
        local called, result = pcall(method, item, aimCF, head.CFrame, {part = head})
        if called and result ~= false then
            shotsSent = (shotsSent or 0) + 1
            return true
        end
        return false
    end

    -- Reference knife behaviour: the equipped item must literally be named
    -- "Knife". This is deliberately strict -- the melee payload is only valid
    -- for the real Knife, not for every melee-class item.
    -- assigned (not `local function`) so it fills the forward declaration above
    isEquippedKnife = function(fighter)
        local item = fighter and rawget(fighter, "EquippedItem")
        if not item then
            return false, nil
        end
        local name = itemValue(item, "Name")
        if name == nil then
            name = itemName(item)
        end
        if tostring(name or "") == "Knife" then
            return true, item
        end
        return false, item
    end

    -- Knife payload from the reference: StartAiming + HeavyAttackAnimation1 and
    -- a top-level animation key. This is a DIFFERENT shape from the ranged
    -- StartShooting payload, so the two paths stay separate on purpose.
    local function knifeAttack(fighter, target)
        -- In Knife mode the heavy attack is the WHOLE point, so it must not also
        -- require the separate "Knife Backstab Only" toggle. That toggle used to
        -- gate this function, so with it off the bot fired gun payloads while
        -- holding a knife and never heavy attacked at all.
        if rageMode() ~= "Knife" then
            if not (KnifeBackstab and KnifeBackstab.Enabled) then
                return false
            end
        end
        -- Accept the same items knifeEngaged() does: literally "Knife", or
        -- anything sitting in the melee slot (katana, tanto, ...). The old strict
        -- name check meant a katana in slot 3 was treated as "not a knife" and
        -- the heavy attack was never sent.
        local _, item = isEquippedKnife(fighter)
        if item == nil then
            local equipped = fighter and rawget(fighter, "EquippedItem")
            if equipped ~= nil and slotFor(fighter, equipped) == 3 then
                item = equipped
            end
        end
        if item == nil then
            return false
        end
        local remote = useRemote()
        local objectID = itemID(item)
        local root = target.Root
        local head = target.HitboxPart or target.Head
        if not remote or not objectID or not root or not head then
            return false
        end
    -- Cached like cachedShootToken: these two EnumLibrary reflections ran on
    -- every knife swing.
    if cachedAimToken == nil then
        cachedAimToken = enumToken("StartAiming", "StartAiming")
    end
    if cachedHeavyToken == nil then
        cachedHeavyToken = enumToken("HeavyAttackAnimation1", "HeavyAttackAnimation1")
    end
    local action = cachedAimToken
    local anim = cachedHeavyToken
        local distance = BackstabDistance and math.clamp(BackstabDistance.Value, 0.5, 12) or 2
        local delay = BackstabDelay and math.clamp(BackstabDelay.Value, 0, 2) or 0.1

        local look = root.CFrame.LookVector
        local backPos = root.Position - look * distance
        local swingCF = CFrame.new(backPos, backPos + look * 5)

        sendViewAngles(root)
        -- named pcall target, hoisted K0..K3 keys: no closure and no four
        -- utf8.char() string allocations per swing
        local sent = pcall(fireKnifePayload, remote, objectID, action, anim, swingCF, head)
        if not sent then
            return false
        end
        -- The hit has to land BEFORE we move. Teleporting afterwards keeps us
        -- from being seen in front of the target mid-swing.
        if delay > 0 then
            task.delay(delay, function()
                if not (RageBot and RageBot.Enabled and not RageBot.Deleted) then
                    return
                end
                local liveRoot = target.Root
                local myRoot = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if not liveRoot or not liveRoot.Parent or not myRoot or not myRoot.Parent then
                    return
                end
                local currentLook = liveRoot.CFrame.LookVector
                local behind = liveRoot.Position - currentLook * distance
                stageBackstabTeleport(myRoot, CFrame.lookAt(behind, liveRoot.Position))
            end)
        else
            local myRoot = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and myRoot.Parent then
                stageBackstabTeleport(myRoot, CFrame.lookAt(backPos, root.Position))
            end
        end
        return true
    end

    local function ammoInfo(fighter)
        local item = fighter and rawget(fighter, "EquippedItem")
        if not item then
            return nil
        end
        local name = itemName(item) or "Weapon"
        local ammo = itemAmmo(item)
        local maxAmmo = itemMaxAmmo(item) or math.max(ammo or 0, 1)
        local info = itemInfo(item)
        local reserve = type(info) == "table" and rawget(info, "AmmoReserve") or nil
        return {Name = tostring(name), Ammo = ammo, MaxAmmo = maxAmmo, Reserve = reserve, Reloading = itemReloading(item)}
    end

    local function visualParent()
        return AkiraLite.MainScreenGui or (lplr and lplr:FindFirstChildOfClass("PlayerGui"))
    end

    -- ------------------------------------------------------------------
    -- Ragebot visualizer - rebuilt from scratch.
    --
    -- The old card was a 232x58 strip with three text lines crammed together,
    -- which is why the gun, the mag size and the reserve ammo had nowhere to
    -- go and the whole thing was unreadable at a glance. This is a proper
    -- panel: a title row with a state pill, then one aligned row per fact.
    -- ------------------------------------------------------------------
    -- Z-index discipline for this card. The parent ScreenGui uses
    -- ZIndexBehavior.Sibling, and in that mode a child whose ZIndex is LOWER
    -- than its parent renders BEHIND the parent's background. An earlier version
    -- of this panel left the title wrapper at the default ZIndex of 1 under a
    -- card at 80, so the title and state pill were painted over by the card's own
    -- background and the whole panel rendered blank. Every layer here is given
    -- an explicit, strictly increasing ZIndex, and rows are positioned manually
    -- instead of via a UIListLayout so nothing can reflow them out of view.
    -- FontFace wants a Font INSTANCE, not an EnumItem. Assigning Enum.Font.X throws
    -- "Unable to assign property FontFace. Font expected, got EnumItem", which
    -- aborted createVisualizer() partway and left the card blank.
    local VIS_FONT_BOLD = Font.fromEnum(Enum.Font.GothamBold)
    local VIS_FONT_SEMI = Font.fromEnum(Enum.Font.GothamSemibold)
    local VIS_CARD_Z = 80
    local VIS_BAR_Z = 81
    local VIS_ROW_Z = 82
    local VIS_TEXT_Z = 83

    local function visLabel(parent, text, y, width, x, size, color)
        local label = Instance.new("TextLabel")
        label.Name = text
        label.Text = text
        label.BackgroundTransparency = 1
        label.BorderSizePixel = 0
        label.TextColor3 = color or Color3.fromRGB(126, 132, 148)
        label.TextSize = size or 10
        label.FontFace = VIS_FONT_BOLD
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.Size = UDim2.new(0, width or 62, 0, 16)
        label.Position = UDim2.fromOffset(x or 14, y or 0)
        label.ZIndex = VIS_TEXT_Z
        label.Parent = parent
        return label
    end

    local function visValue(parent, y, x, width, size)
        local value = Instance.new("TextLabel")
        value.Name = "Value"
        value.Text = "--"
        value.BackgroundTransparency = 1
        value.BorderSizePixel = 0
        value.TextColor3 = Color3.fromRGB(233, 236, 244)
        value.TextSize = size or 12
        value.FontFace = VIS_FONT_SEMI
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.TextYAlignment = Enum.TextYAlignment.Center
        value.TextTruncate = Enum.TextTruncate.AtEnd
        value.Size = UDim2.new(0, width or 168, 0, 16)
        value.Position = UDim2.fromOffset(x or 80, y or 0)
        value.ZIndex = VIS_TEXT_Z
        value.Parent = parent
        return value
    end

    local function visRow(parent, y, label, height)
        local row = Instance.new("Frame")
        row.Name = "Row"
        row.Size = UDim2.new(1, -24, 0, height or 18)
        row.Position = UDim2.fromOffset(12, y)
        row.BackgroundTransparency = 1
        row.BorderSizePixel = 0
        row.ZIndex = VIS_ROW_Z
        row.Parent = parent
        visLabel(row, label, 0, 62, 2)
        local value = visValue(row, 0, 70, 168)
        return row, value
    end

    local function createVisualizer()
        if visualizerCard and visualizerCard.Parent then
            return
        end
        local parent = visualParent()
        if not parent then
            return
        end
        visualizerCard = Instance.new("Frame")
        visualizerCard.Name = "RagebotVisualizer"
        visualizerCard.Size = UDim2.fromOffset(272, 162)
        local insetY = 0
        pcall(function()
            local GuiService = game:GetService("GuiService")
            if GuiService and GuiService.GetGuiInset then
                local inset = GuiService:GetGuiInset()
                if typeof(inset) == "Vector2" then
                    insetY = inset.Y
                end
            end
        end)
        visualizerCard.Position = UDim2.fromOffset(12, 46 + insetY)
        visualizerCard.BackgroundColor3 = Color3.fromRGB(11, 12, 16)
        visualizerCard.BackgroundTransparency = 0.06
        visualizerCard.BorderSizePixel = 0
        visualizerCard.Visible = false
        visualizerCard.ZIndex = VIS_CARD_Z
        -- Active makes the card receive InputBegan (that is what bindVisualizerDrag
        -- listens for). Selectable is irrelevant for a Frame but is set false so a
        -- future control cannot steal the drag.
        visualizerCard.Active = true
        visualizerCard.Selectable = false
        visualizerCard.Parent = parent
        visualizerScale = Instance.new("UIScale")
        visualizerScale.Scale = 0
        visualizerScale.Parent = visualizerCard
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = visualizerCard
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(48, 52, 66)
        stroke.Thickness = 1
        stroke.Transparency = 0.3
        stroke.Parent = visualizerCard

        local accent = Instance.new("Frame")
        accent.Name = "Accent"
        accent.Size = UDim2.new(1, -2, 0, 2)
        accent.Position = UDim2.fromOffset(1, 0)
        accent.BackgroundColor3 = Color3.fromRGB(130, 135, 150)
        accent.BorderSizePixel = 0
        accent.ZIndex = VIS_BAR_Z
        accent.Parent = visualizerCard
        local accentCorner = Instance.new("UICorner")
        accentCorner.CornerRadius = UDim.new(1, 0)
        accentCorner.Parent = accent
        visualizerAccent = accent

        -- title strip: explicit ZIndex, otherwise it renders behind the card
        local titleWrap = Instance.new("Frame")
        titleWrap.Name = "Title"
        titleWrap.Size = UDim2.new(1, -24, 0, 28)
        titleWrap.Position = UDim2.fromOffset(12, 3)
        titleWrap.BackgroundTransparency = 1
        titleWrap.BorderSizePixel = 0
        titleWrap.ZIndex = VIS_BAR_Z
        titleWrap.Parent = visualizerCard

        visualizerStatus = visLabel(titleWrap, "RAGEBOT", 0, 140, 2, 13, Color3.fromRGB(240, 242, 248))

        visualizerState = Instance.new("TextLabel")
        visualizerState.Name = "State"
        visualizerState.Text = "SEARCHING"
        visualizerState.BackgroundTransparency = 0
        visualizerState.BackgroundColor3 = Color3.fromRGB(38, 41, 52)
        visualizerState.TextColor3 = Color3.fromRGB(150, 155, 170)
        visualizerState.TextSize = 10
        visualizerState.FontFace = VIS_FONT_BOLD
        visualizerState.TextYAlignment = Enum.TextYAlignment.Center
        visualizerState.Size = UDim2.fromOffset(86, 20)
        visualizerState.Position = UDim2.new(1, -88, 0, 4)
        visualizerState.ZIndex = VIS_TEXT_Z
        visualizerState.Parent = titleWrap
        local stateCorner = Instance.new("UICorner")
        stateCorner.CornerRadius = UDim.new(1, 0)
        stateCorner.Parent = visualizerState

        -- one row per fact, positioned by hand (no UIListLayout / UIPadding, so
        -- nothing can silently collapse the rows to zero height)
        local _, targetRow = visRow(visualizerCard, 36, "TARGET")
        visualizerTarget = targetRow

        local _, healthRow = visRow(visualizerCard, 58, "HEALTH", 24)
        visualizerHealth = healthRow
        -- Full-width health track that sits UNDER the row and spans the whole
        -- card. It used to be a 74px nub tucked to the right, and it was set
        -- Visible = false whenever there was no target - so with no lock the
        -- bar simply vanished, which read as "health bar is off". It is now
        -- always present and the fill is what scales.
        visualizerHealthBar = Instance.new("Frame")
        visualizerHealthBar.Name = "Bar"
        visualizerHealthBar.Size = UDim2.new(1, 0, 0, 4)
        visualizerHealthBar.Position = UDim2.fromOffset(0, 18)
        visualizerHealthBar.BackgroundColor3 = Color3.fromRGB(34, 37, 47)
        visualizerHealthBar.BorderSizePixel = 0
        visualizerHealthBar.ZIndex = VIS_ROW_Z
        visualizerHealthBar.Parent = healthRow
        local barBg = Instance.new("UICorner")
        barBg.CornerRadius = UDim.new(1, 0)
        barBg.Parent = visualizerHealthBar
        visualizerHealthFill = Instance.new("Frame")
        visualizerHealthFill.Name = "Fill"
        visualizerHealthFill.Size = UDim2.fromScale(0, 1)
        visualizerHealthFill.BackgroundColor3 = Color3.fromRGB(65, 235, 125)
        visualizerHealthFill.BorderSizePixel = 0
        visualizerHealthFill.ZIndex = VIS_ROW_Z + 1
        visualizerHealthFill.Parent = visualizerHealthBar
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = visualizerHealthFill

        local _, gunRow = visRow(visualizerCard, 86, "WEAPON")
        visualizerGun = gunRow
        local _, ammoRow = visRow(visualizerCard, 108, "AMMO")
        visualizerAmmo = ammoRow
        local _, reserveRow = visRow(visualizerCard, 130, "RESERVE")
        visualizerReserve = reserveRow

        visualizerGradient = Instance.new("UIGradient")
        visualizerGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(70, 210, 255))
        visualizerGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0.85),
        })
        visualizerGradient.Parent = visualizerStatus
        pcall(AkiraLite.RegisterStyleTree, AkiraLite, visualizerCard)
        pcall(AkiraLite.ApplyUIStyle, AkiraLite)
    end

    local function bindVisualizerDrag()
        if visualizerDragBound or not visualizerCard then
            return
        end
        visualizerDragBound = true
        local dragStart
        local startPosition
        local dragChangedConnection

        -- keep the card fully on screen, and remember where the user put it so
        -- the position survives a rebuild
        local function placeCard(x, y)
            local camera = workspace.CurrentCamera
            local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
            local width = visualizerCard.AbsoluteSize.X > 0 and visualizerCard.AbsoluteSize.X or 272
            local height = visualizerCard.AbsoluteSize.Y > 0 and visualizerCard.AbsoluteSize.Y or 162
            local cx = math.clamp(x, 6, math.max(6, viewport.X - width - 6))
            local cy = math.clamp(y, 6, math.max(6, viewport.Y - height - 6))
            cx = math.floor(cx + 0.5)
            cy = math.floor(cy + 0.5)
            visualizerCard.Position = UDim2.fromOffset(cx, cy)
            visualizerDragPos = {x = cx, y = cy}
        end

        local function endDrag()
            visualizerDragging = false
            dragStart = nil
            startPosition = nil
            if dragChangedConnection then
                pcall(function()
                    dragChangedConnection:Disconnect()
                end)
                dragChangedConnection = nil
            end
        end

        -- Dragging works from anywhere on the card, and from the title strip
        -- even if a future row is given Active = true and starts eating clicks.
        local function beginDrag(input)
            if visualizerDragging then
                return
            end
            visualizerDragging = true
            dragStart = input.Position
            startPosition = visualizerCard.Position
            if dragChangedConnection then
                pcall(function()
                    dragChangedConnection:Disconnect()
                end)
            end
            dragChangedConnection = input.Changed:Connect(function(change)
                if change.UserInputState == Enum.UserInputState.End then
                    endDrag()
                end
            end)
        end

        local inputConnection = visualizerCard.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                beginDrag(input)
            end
        end)
        ownVisualizer(inputConnection)

        -- Safety net. Relying on input.Changed alone is what made the card stick
        -- to the crosshair forever: if the End state is missed (releasing outside
        -- the window, focus loss, a touch that ends without a Changed event, or
        -- the mouse being released over another GuiObject) visualizerDragging
        -- stayed true and the card followed the pointer indefinitely with no way
        -- to let go. A global InputEnded always clears it.
        local endConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseMovement then
                if visualizerDragging then
                    endDrag()
                end
            end
        end)
        ownVisualizer(endConnection)

        -- and if focus is lost entirely, drop the drag rather than keep it stuck
        local focusConnection = game:GetService("WindowFocusReleased"):Connect(function()
            if visualizerDragging then
                endDrag()
            end
        end)
        pcall(ownVisualizer, focusConnection)

        local moveConnection = UserInputService.InputChanged:Connect(function(input)
            if visualizerDragging and dragStart and startPosition then
                local current = input.Position
                if type(current) ~= "Vector3" then
                    -- some executors deliver a Vector2 here; fall back to the
                    -- mouse position so the drag still tracks
                    current = UserInputService:GetMouseLocation()
                end
                if type(current) == "Vector3" or type(current) == "Vector2" then
                    local delta = current - dragStart
                    placeCard(startPosition.X.Offset + delta.X, startPosition.Y.Offset + delta.Y)
                end
            end
        end)
        ownVisualizer(moveConnection)

        -- If the window is resized (or the card is rebuilt) the stored position
        -- is re-applied through the same clamp, so it can never end up offscreen.
        if visualizerDragPos then
            placeCard(visualizerDragPos.x, visualizerDragPos.y)
        end
    end

    local function updateVisualizer(status, target, info)
        if not visualizerCard then
            createVisualizer()
        end
        if not visualizerCard then
            return
        end
        -- The card is created lazily, i.e. AFTER the enable steps have already
        -- run, so binding the drag only from the "visualizerDrag" enable step
        -- always hit `not visualizerCard` and returned: the card could be seen
        -- but never dragged. Re-binding here is a single boolean check once the
        -- card exists, so the drag attaches as soon as it is built.
        bindVisualizerDrag()
        local show = RageBot and RageBot.Enabled and (not Visualizer or Visualizer.Enabled)
        if not show then
            if visualizerCard.Visible then
                if AkiraLite.CreateTween then
                    pcall(function()
                        AkiraLite:CreateTween(visualizerScale, {
                            Time = 0.2,
                            EasingStyle = Enum.EasingStyle.Exponential,
                            EasingDirection = Enum.EasingDirection.InOut,
                            RepeatCount = 0,
                            DelayTime = 0
                        }, {Scale = 0}):Play()
                    end)
                else
                    visualizerScale.Scale = 0
                end
                if AkiraLite.Delay and AkiraLite.GetTweenDuration then
                    local delay = AkiraLite:Delay(AkiraLite:GetTweenDuration(0.2), function()
                        if visualizerCard and not (RageBot and RageBot.Enabled and (not Visualizer or Visualizer.Enabled)) then
                            visualizerCard.Visible = false
                        end
                    end)
                    ownVisualizer(delay)
                else
                    visualizerCard.Visible = false
                end
            end
            return
        end
        if not visualizerCard.Visible then
            visualizerCard.Visible = true
            -- keep it on screen using the position the user dragged it to
            do
                local camera = workspace.CurrentCamera
                local viewport = camera and camera.ViewportSize or nil
                if viewport and typeof(viewport) == "Vector2" then
                    local width = visualizerCard.AbsoluteSize.X > 0 and visualizerCard.AbsoluteSize.X or visualizerCard.Size.X.Offset
                    local height = visualizerCard.AbsoluteSize.Y > 0 and visualizerCard.AbsoluteSize.Y or visualizerCard.Size.Y.Offset
                    local x = math.clamp(visualizerCard.Position.X.Offset, 6, math.max(6, viewport.X - width - 6))
                    local y = math.clamp(visualizerCard.Position.Y.Offset, 6, math.max(6, viewport.Y - height - 6))
                    visualizerCard.Position = UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
                    visualizerDragPos = {x = visualizerCard.Position.X.Offset, y = visualizerCard.Position.Y.Offset}
                end
            end
            if AkiraLite.CreateTween then
                pcall(function()
                    AkiraLite:CreateTween(visualizerScale, {
                            Time = 0.2,
                            EasingStyle = Enum.EasingStyle.Exponential,
                            EasingDirection = Enum.EasingDirection.InOut,
                            RepeatCount = 0,
                            DelayTime = 0
                        }, {Scale = 1}):Play()
                end)
            else
                visualizerScale.Scale = 1
            end
        end
        if visualizerGradient then
            visualizerGradient.Enabled = not GradientText or GradientText.Enabled
        end
        lastStatus = status
        local color = status == "ACTIVE" and Color3.fromRGB(65, 235, 125) or status == "RELOADING" and Color3.fromRGB(255, 180, 55) or Color3.fromRGB(130, 135, 150)
        -- Every label write is guarded. updateRageState() runs from the rage
        -- loop and from the enable steps, and it used to run before (or without)
        -- createVisualizer(), so `visualizerStatus.Text = ...` threw
        -- "attempt to index nil with 'Text'" and killed the whole tick - which is
        -- exactly when the bot most needed to keep firing.
        if not visualizerStatus or not visualizerTarget or not visualizerAmmo then
            return
        end
        -- Only write a label when the text actually changed. This runs from the
        -- rage loop every tick, and assigning .Text forces a re-measure/re-layout
        -- of the label even when the string is identical, so the unchanged case
        -- was pure per-frame UI cost (plus a string alloc for the format calls).
        setLabel(visualizerStatus, "RAGEBOT", visualizerTextCache.status)
        setTextColor(visualizerStatus, GradientText and GradientText.Enabled and Color3.fromRGB(245, 245, 248) or Color3.fromRGB(240, 242, 248))
        if visualizerState then
            setLabel(visualizerState, string.upper(status), visualizerTextCache.state)
            setTextColor(visualizerState, color)
            setColor(visualizerState, Color3.fromRGB(
                math.floor(color.R * 46 + 18),
                math.floor(color.G * 46 + 18),
                math.floor(color.B * 46 + 18)))
        end
        if visualizerAccent then
            setColor(visualizerAccent, color)
        end

        -- TARGET
        setLabel(visualizerTarget, tostring(target or "No target"), visualizerTextCache.target)

        -- HEALTH. The track and the value are ALWAYS populated - with an empty
        -- bar and a "--" reading when there is no lock - instead of vanishing,
        -- so the panel never looks broken just because nothing is targeted yet.
        local humanoid = currentTargetState and rawget(currentTargetState, "Humanoid") or nil
        local health, maxHealth
        if humanoid then
            health = humanoid.Health
            maxHealth = humanoid.MaxHealth
        end
        if type(health) == "number" and type(maxHealth) == "number" and maxHealth > 0 then
            setLabel(visualizerHealth, string.format("%d / %d", math.ceil(health), math.ceil(maxHealth)), visualizerTextCache.health)
            local ratio = math.clamp(health / maxHealth, 0, 1)
            visualizerHealthFill.Size = UDim2.fromScale(ratio, 1)
            -- green -> amber -> red as the target gets closer to dead
            visualizerHealthFill.BackgroundColor3 = ratio > 0.5
                and Color3.fromRGB(65, 235, 125)
                or ratio > 0.25 and Color3.fromRGB(255, 180, 55)
                or Color3.fromRGB(235, 70, 70)
        elseif type(health) == "number" then
            setLabel(visualizerHealth, tostring(math.ceil(health)), visualizerTextCache.health)
            visualizerHealthFill.Size = UDim2.fromScale(0, 1)
        else
            setLabel(visualizerHealth, "--", visualizerTextCache.health)
            visualizerHealthFill.Size = UDim2.fromScale(0, 1)
        end

        -- WEAPON / AMMO / RESERVE - always shown, dimmed placeholders when the
        -- item does not report them. Hiding the rows is what made it look like
        -- the panel was broken rather than simply idle.
        local showAmmo = ShowAmmo and ShowAmmo.Enabled
        if showAmmo and info then
            setLabel(visualizerGun, tostring(info.Name or "Unknown"), visualizerTextCache.gun)
            if info.Ammo ~= nil and info.MaxAmmo ~= nil then
                setLabel(visualizerAmmo, string.format("%d / %d", info.Ammo, info.MaxAmmo), visualizerTextCache.ammo)
            elseif info.Ammo ~= nil then
                setLabel(visualizerAmmo, tostring(info.Ammo), visualizerTextCache.ammo)
            elseif info.MaxAmmo ~= nil then
                setLabel(visualizerAmmo, "0 / " .. tostring(info.MaxAmmo), visualizerTextCache.ammo)
            else
                setLabel(visualizerAmmo, "-- / --", visualizerTextCache.ammo)
            end
            if info.Reserve ~= nil then
                setLabel(visualizerReserve, tostring(info.Reserve), visualizerTextCache.reserve)
            else
                setLabel(visualizerReserve, "--", visualizerTextCache.reserve)
            end
        else
            setLabel(visualizerGun, showAmmo and "No weapon" or "Ammo hidden", visualizerTextCache.gun)
            setLabel(visualizerAmmo, "-- / --", visualizerTextCache.ammo)
            setLabel(visualizerReserve, "--", visualizerTextCache.reserve)
        end
    end

    local function applyHitbox()
        local root = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
        if not HitboxExpander or not HitboxExpander.Enabled then
            if hitboxOriginalSize then
                pcall(function()
                    if root then
                        root.Size = hitboxOriginalSize
                    end
                end)
                hitboxOriginalSize = nil
            end
            return
        end
        if root then
            if not hitboxOriginalSize then
                hitboxOriginalSize = root.Size
                hitboxTargetSize = hitboxOriginalSize * 1.6
            end
            -- the size only needs setting when it is not already correct: this
            -- runs every tick and each write is a replicated property change
            if root.Size ~= hitboxTargetSize then
                root.Size = hitboxTargetSize
            end
        end
    end

    local function unbindRender()
        if renderBound then
            pcall(function()
                RunService:UnbindFromRenderStep(renderStepName)
            end)
            renderBound = false
        end
        renderState = nil
    end

    local function bindRender()
        unbindRender()
        pcall(function()
                RunService:BindToRenderStep(renderStepName, 100, function()
                if renderState then
                    local state = renderState
                    renderState = nil
                    if state.Root and state.Root.Parent then
                        pcall(function()
                            state.Root.CFrame = state.Previous
                            state.Root.AssemblyLinearVelocity = state.Velocity
                            state.Root.RotVelocity = state.RotVelocity
                        end)
                    end
                end
            end)
            renderBound = true
        end)
    end

    local function updateRageState(target, status, info)
        AkiraLite.Rage = AkiraLite.Rage or {}
        AkiraLite.Rage.Enabled = RageBot and RageBot.Enabled == true
        AkiraLite.Rage.CurrentTarget = target and target.Player or nil
        AkiraLite.Rage.Target = target
        AkiraLite.Rage.TargetPlayer = target and target.Player or nil
        AkiraLite.Rage.TargetEntity = target and entitylib.getEntity(target.Character) or nil
        AkiraLite.Rage.Status = status
        AkiraLite.Rage.TargetPart = target and target.Head or nil
        AkiraLite.Rage.UpdatedAt = os.clock()
        -- publish for the crosshair / anything else that wants the live target
        publishActiveTarget("Ragebot", target)
        if type(AkiraLite.RageBridge) == "table" then
            AkiraLite.RageBridge.CurrentTarget = AkiraLite.Rage.CurrentTarget
            AkiraLite.RageBridge.TargetPart = AkiraLite.Rage.TargetPart
            AkiraLite.RageBridge.Status = status
        end
        updateVisualizer(status, target and getPlayerIdentity(target.Player, true) or nil, info)
    end

    local function clearRageState()
        currentTarget = nil
        currentTargetPart = nil
        currentTargetState = nil
        targetSince = 0
        renderState = nil
        clearActiveTarget("Ragebot")
        if AkiraLite.Rage then
            AkiraLite.Rage.Enabled = RageBot and RageBot.Enabled == true
            AkiraLite.Rage.CurrentTarget = nil
            AkiraLite.Rage.Target = nil
            AkiraLite.Rage.TargetPlayer = nil
            AkiraLite.Rage.TargetEntity = nil
            AkiraLite.Rage.TargetPart = nil
            AkiraLite.Rage.Status = "SEARCHING"
        end
        if type(AkiraLite.RageBridge) == "table" then
            AkiraLite.RageBridge.CurrentTarget = nil
            AkiraLite.RageBridge.TargetPart = nil
            AkiraLite.RageBridge.Status = "SEARCHING"
        end
    end

    local function cleanupRage(restore)
        for _, connection in ipairs(visualizerConnections) do
            disconnect(connection)
        end
        table.clear(visualizerConnections)
        if heartbeatConnection then
            disconnect(heartbeatConnection)
            heartbeatConnection = nil
        end
        for _, connection in ipairs(owned) do
            disconnect(connection)
        end
        table.clear(owned)
        visualizerDragging = false
        visualizerDragBound = false
        unbindRender()
        applyHitbox()
        local ok = pcall(resolveDependencies)
        if ok then
            local instance = localFighter()
            if restore then
                restoreWeapon(instance, true)
            end
        end
        previousSlot = nil
        previousItem = nil
        weaponRemembered = false
        rageEquipped = false
        table.clear(lastSeen)
        lastAttack = 0
        lastReload = 0
        lastEquipAttempt = 0
        lastRapidScan = 0
        targetSince = 0
        restoreRapid()
        clearRageState()
        lastStatus = "SEARCHING"
        if visualizerCard then
            visualizerCard.Visible = false
            if visualizerScale then
                visualizerScale.Scale = 0
            end
        end
    end

    local function rageLoop()
        if not RageBot or not RageBot.Enabled then
            return
        end
        resolveDependencies()
        local fighter = localFighter()
        if not fighter then
            updateRageState(nil, "SEARCHING", nil)
            return
        end
        applyHitbox()
        if not weaponRemembered then
            rememberWeapon(fighter)
        end
        -- keep the equipped slot matching the selected Weapon / Rage Mode
        ensureSlotEquipped(fighter)
        if RapidFire then
            applyRapid(fighter)
        end
        local target = chooseTarget()
        local info = ammoInfo(fighter)
        if not target then
            if rageEquipped then
                restoreWeapon(fighter, true)
                rageEquipped = false
            end
            updateRageState(nil, "SEARCHING", info)
            return
        end
        -- A reported "reloading" state used to abort the tick outright. The
        -- server simply ignores shots fired during a reload, so there is nothing
        -- to gain from standing still - keep going and keep the payload flowing.
        if info and info.Reloading then
            rageReject("reloading")
        end
        -- the inventory scan walks the fighter's inventory and isEquipped()
        -- re-inspects it: both used to run twice per tick. Resolve once, reuse.
        local invEntry = selectedInventory(fighter)
        local invEquipped = invEntry and isEquipped(fighter, invEntry) or false
        -- Out of ammo: ask for a reload but DO NOT return. Previously this
        -- returned every tick while ammo read 0, so the bot never fired again
        -- until the gun magically had bullets.
        if AutoReload and AutoReload.Enabled and info and info.Ammo ~= nil and info.Ammo <= 0 then
            local reloadEntry = invEntry
            if reloadEntry then
                if not invEquipped then
                    equipEntry(fighter, reloadEntry)
                else
                    reloadItem(fighter, reloadEntry)
                end
            end
        end
        local entry = invEntry
        if not entry then
            local equipped = type(fighter) == "table" and rawget(fighter, "EquippedItem") or nil
            if type(equipped) == "table" then
                entry = {
                    Item = equipped,
                    Category = "Equipped",
                    Equipped = true
                }
            end
        end
        if not entry then
            if rageEquipped then
                restoreWeapon(fighter, true)
                rageEquipped = false
            end
            updateRageState(nil, "SEARCHING", info)
            return
        end
        if not (entry == invEntry and invEquipped) and not isEquipped(fighter, entry) then
            equipEntry(fighter, entry)
            -- Normally we wait for the swap to land. But if the swap never
            -- registers (the game reports EquippedItem as an id string, the slot
            -- differs, or the equip is silently rejected) the old code returned
            -- here EVERY tick and never fired at all. After a grace period we
            -- stop waiting and shoot with whatever is in hand, which is what the
            -- reference implementation does.
            if not swapSince then
                swapSince = os.clock()
            end
            if os.clock() - swapSince < 1 then
                updateRageState(target, "SWAPPING", info)
                return
            end
            rageReject("swapTimeout")
            local equippedNow = type(fighter) == "table" and rawget(fighter, "EquippedItem") or nil
            if type(equippedNow) == "table" then
                entry = {Item = equippedNow, Category = "Equipped", Equipped = true}
            end
        else
            swapSince = nil
        end
        local localRoot = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
        if not localRoot then
            updateRageState(target, "SEARCHING", info)
            return
        end
        -- A backstab queued by the previous tick is due now that the hit landed.
        consumePendingTeleport()

        local aimPart = target.HitboxPart or target.Head
        -- aimPart went missing (character died / streaming out) between choose and
        -- here. CFrame.lookAt with a nil position throws, and that used to abort
        -- the whole tick.
        if not aimPart or not aimPart.Parent then
            clearRageState()
            updateRageState(nil, "SEARCHING", info)
            return
        end
        local knifeReady = knifeEngaged(fighter)
        local aimCF = CFrame.lookAt(localRoot.Position, aimPart.Position)

        -- Knife: hold position this tick. The strike is sent first and the
        -- move behind the target is queued for right after it lands.
        if not (knifeReady and target.Root) then
            if CharacterOrigin and CharacterOrigin.Enabled and target.Root then
                local spacing = DesyncDistance and DesyncDistance.Value or 2
                local height = hasKnifeViewModel(target.Player) and 6 or 1
                local position
                if RearPosition and RearPosition.Enabled then
                    -- Sit BEHIND the target so a target walking backwards never
                    -- ends up facing us. Negative Z is behind in Roblox.
                    position = (target.Root.CFrame * CFrame.new(0, height, -spacing)).Position
                else
                    position = (target.Root.CFrame * CFrame.new(0, height, spacing)).Position
                end
                local desyncCF = CFrame.lookAt(position, aimPart.Position)
                if applyTeleport(localRoot, desyncCF) then
                    aimCF = desyncCF
                end
            end
        end

        -- Ranged cadence: fixed maximum, no user control. This used to bottom out
        -- at RapidInterval's value, and a saved config had it at 1 - a whole
        -- second between bursts. The reference implementation fires every frame,
        -- so the gate is hardcoded to 0 and only the tap count is configurable.
        local minInterval = 0
        local interval = ATTACK_INTERVAL
        if type(interval) ~= "number" or interval ~= interval or interval < 0 then
            interval = 0
        end
        if interval < minInterval then
            interval = minInterval
        end
        local taps = TAPS_PER_FRAME
        if TapsPerFrame then
            taps = math.max(1, math.floor(TapsPerFrame.Value))
        end
        local now = os.clock()
        -- periodic telemetry so a slow/unresponsive ragebot is diagnosable
        if now - lastShotReport > 3 then
            lastShotReport = now
            if AkiraLite then
                AkiraLite.RageStats = {
                    Sent = shotsSent or 0,
                    Failed = shotsFailed or 0,
                    Taps = taps,
                    Interval = interval,
                    Mode = rageMode(),
                    Target = currentTarget and currentTarget.Name or nil,
                }
            end
            if (shotsFailed or 0) > 0 and (shotsSent or 0) == 0 then
                pcall(warn, "[AkiraLite] Ragebot sent 0 shots and failed "
                    .. tostring(shotsFailed)
                    .. " - check the equipped weapon and the UseItem remote")
            end
        end
        if now - lastAttack >= interval then
            local struck = false
            if knifeReady then
                struck = knifeAttack(fighter, target)
            end
            if not struck then
                local fired = false
                for _ = 1, taps do
                    if attackOnce(fighter, entry, target, aimCF) then
                        fired = true
                    end
                end
                if fired then
                    -- Only advance lastAttack on a payload we actually sent. It
                    -- used to be updated inside the loop, which meant a failed
                    -- shot consumed the whole interval and the bot silently
                    -- skipped beats.
                    lastAttack = now
                end
            else
                lastAttack = now
            end
        end
        local status = targetSince > 0 and os.clock() - targetSince < 0.35 and "SWAPPING" or "ACTIVE"
        updateRageState(target, status, info)
    end

    RageBot = AkiraLite.Catalogs.Combat:AddModule({
        Name = 'Ragebot',
        Function = function(callback)
            if callback then
                local steps = {
                    {
                        "cleanup", function()
                            cleanupRage(false)
                        end
                    },
                    {
                        "dependencies", function()
                            resolveDependencies()
                        end
                    },
                    {
                        "rememberWeapon", function()
                            local fighter = localFighter()
                            if fighter then
                                rememberWeapon(fighter)
                            end
                        end
                    },
                    {
                        "playerRemoving", function()
                            local signal = Players.PlayerRemoving
                            if type(signal) ~= "RBXScriptSignal" then
                                return
                            end
                            own(signal:Connect(function(player)
                                lastSeen[player] = nil
                                if currentTarget == player then
                                    clearRageState()
                                end
                            end))
                        end
                    },
                    {
                        "characterAdded", function()
                            own(lplr.CharacterAdded:Connect(function()
                                previousItem = nil
                                previousSlot = nil
                                weaponRemembered = false
                                rageEquipped = false
                                clearRageState()
                            end))
                        end
                    },
                        {
                            "visualizer", function()
                                createVisualizer()
                            end
                        },
                        {
                            -- From the reference implementation: zero every
                            -- fire/attack cooldown in the shared ItemLibrary so
                            -- the server-side rate limiting does not swallow
                            -- shots. It is a shallow-safe deep walk over the
                            -- required module table.
                            "cooldowns", function()
                                pcall(function()
                                    local itemLibrary = require(RepStorage.Modules.ItemLibrary)
                                    local seen = {}
                                    local function scan(tbl, depth)
                                        if type(tbl) ~= "table" or depth > 6 or seen[tbl] then
                                            return
                                        end
                                        seen[tbl] = true
                                        for _, v in pairs(tbl) do
                                            if type(v) == "table" then
                                                for _, key in ipairs({"ShootCooldown", "BurstCooldown", "AttackCooldown", "HeavyAttackCooldown"}) do
                                                    if v[key] ~= nil then
                                                        v[key] = 0.000000000000000001
                                                    end
                                                end
                                                scan(v, depth + 1)
                                            end
                                        end
                                    end
                                    scan(itemLibrary, 0)
                                end)
                            end
                        },
                    {
                        "visualizerDrag", function()
                            bindVisualizerDrag()
                        end
                    },
                    {
                        "renderBinding", function()
                            bindRender()
                        end
                    },
                        {
                            "heartbeat", function()
                                heartbeatConnection = RunService.Heartbeat:Connect(function()
                                    -- pcall here is deliberate: one bad tick must not
                                    -- kill the bot. But it used to swallow the error
                                    -- entirely, so a rageLoop that threw every frame
                                    -- looked identical to "ragebot does not work".
                                    -- Report the first occurrence of each distinct
                                    -- error so a failure is actually diagnosable.
                                    local ok, err = pcall(rageLoop)
                                    if not ok and err ~= lastRageError then
                                        lastRageError = tostring(err)
                                        rageErrorCount = (rageErrorCount or 0) + 1
                                        AkiraLite.RageStepError = "rageLoop: " .. lastRageError
                                        pcall(warn, "[AkiraLite] Ragebot loop error: " .. lastRageError)
                                    end
                                    if ok then
                                        lastRageError = nil
                                    end
                                end)
                                own(heartbeatConnection)
                            end
                        },
                        {
                            "state", function()
                                updateRageState(nil, "SEARCHING", nil)
                            end
                        }
                }
                for _, step in ipairs(steps) do
                    local ok, err = pcall(step[2])
                    if not ok then
                        -- Do NOT break. Every one of these steps is independent:
                        -- a failure in e.g. "visualizerDrag" used to skip the
                        -- heartbeat step entirely, leaving the bot enabled but
                        -- completely inert with no visible reason.
                        local message = step[1] .. ": " .. tostring(err)
                        if not AkiraLite.RageStepError then
                            AkiraLite.RageStepError = message
                        end
                        table.insert(rageStepErrors, message)
                        pcall(warn, "[AkiraLite] Ragebot step " .. tostring(step[1]) .. " failed: " .. tostring(err))
                    end
                end
            else
                cleanupRage(true)
            end
        end
    })

    local baseClean = RageBot.Clean
    function RageBot:Clean(value)
        if value ~= nil then
            table.insert(owned, value)
        end
        return baseClean(self, value)
    end
    local baseDelete = RageBot.Delete
    function RageBot:Delete()
        cleanupRage(true)
        return baseDelete and baseDelete(self) or false
    end

    Weapon = RageBot:AddDropdown({
        Name = 'Weapon',
        List = {'Primary', 'Secondary', 'Melee'}
    })
    -- Explicit mode instead of sniffing what is in your hands. Auto is gone: it
    -- only added a third behaviour that silently changed the firing path
    -- mid-fight depending on what you happened to be holding.
    --   Ranged - gun payload, never the knife one
    --   Knife  - knife payload, and equip the melee slot for it
    RageMode = RageBot:AddDropdown({
        Name = 'Rage Mode',
        List = {'Ranged', 'Knife'},
        Darker = true
    })
    ItemNameInput = RageBot:AddTextInput({
        Name = 'Item',
        Placeholder = 'Optional item name',
        MaxLength = 64,
        Darker = true
    })
    Range = RageBot:AddSlider({Name = 'Range', Min = 1, Max = 1000, Default = 500, Decimal = 1})
    Wallbang = RageBot:AddToggle({Name = 'Wallbang', Darker = true})
    AvoidDeflect = RageBot:AddToggle({Name = 'Avoid Deflecting', Default = true, Darker = true})
    AvoidImmune = RageBot:AddToggle({Name = 'Avoid Immune Targets', Default = true, Darker = true})
    PreferLowestHP = RageBot:AddToggle({Name = 'Prefer Lowest Health', Darker = true})
    HitboxExpander = RageBot:AddToggle({Name = 'Hitbox Expansion', Darker = true})
    TargetHysteresis = RageBot:AddSlider({Name = 'Target Hysteresis', Min = 0, Max = 50, Default = 0, Decimal = 1, Darker = true})
    AutoReload = RageBot:AddToggle({Name = 'Auto Reload', Default = true})
    RapidFire = RageBot:AddToggle({
        Name = 'Rapid Hit',
        Default = true,
        Function = function(callback)
            if callback then
                resolveDependencies()
                applyRapid(localFighter())
            else
                restoreRapid()
            end
        end
    })
    -- Attack cadence is fixed at maximum, deliberately with no slider.
    -- A saved config still had RapidInterval = 1 (a full SECOND between bursts),
    -- which is exactly why the bot felt like it had gotten slower - live stats
    -- showed interval=1 with taps=8, i.e. eight shots once per second. The
    -- gate is now hardcoded to 0 so the payload goes out every single frame.
    --
    -- These two MUST be declared before rageLoop (which reads them) rather than
    -- down here with the other controls: a local declared after its use is a
    -- DIFFERENT variable, so rageLoop was reading a nil global and `taps` was
    -- always nil, making the tap loop `for _ = 1, nil` throw on every tick.
    TapsPerFrame = RageBot:AddSlider({Name = 'Taps Per Frame', Min = 1, Max = 8, Default = 8, Decimal = 1, Darker = true})
    KnifeBackstab = RageBot:AddToggle({Name = 'Knife Backstab Only', Default = true})
    BackstabDelay = RageBot:AddSlider({Name = 'Backstab Delay', Min = 0, Max = 0.5, Default = 0.1, Decimal = 100, Darker = true})
    BackstabDistance = RageBot:AddSlider({Name = 'Backstab Distance', Min = 1, Max = 8, Default = 2, Decimal = 10, Darker = true})
    CharacterOrigin = RageBot:AddToggle({Name = 'Character Origin', Default = true, Darker = true})
    RearPosition = RageBot:AddToggle({Name = 'Stay Behind Target', Default = true, Darker = true})
    DesyncDistance = RageBot:AddSlider({Name = 'Origin Distance', Min = 1, Max = 6, Default = 2, Decimal = 10, Darker = true})
    HeavySpread = RageBot:AddSlider({Name = 'Aim Spread', Min = 0, Max = 1, Default = 0.1, Decimal = 100, Darker = true})
    RestoreWeapon = RageBot:AddToggle({Name = 'Restore Weapon', Default = true})
    Visualizer = RageBot:AddToggle({Name = 'Visualizer', Default = true})
    GradientText = RageBot:AddToggle({Name = 'Gradient Text', Default = true})
    ShowAmmo = RageBot:AddToggle({Name = 'Show Ammo', Default = true})
    AkiraLite.Rage = AkiraLite.Rage or {}
    AkiraLite.RageBridge = AkiraLite.RageBridge or {}
    AkiraLite.RageBridge.GetTarget = function()
        return currentTarget, currentTargetPart, currentTargetState
    end
end)
    akiraMark("block28:done")
    akiraMark("block29:start")
run(function()
    local Crosshair
    local Style
    local Angle
    local Spin
    local SpinSpeed
    local Gap
    local Length
    local Thickness
    local GlobalSize
    local Opacity
    local OutlineToggle
    local OutlineThickness
    local CenterDot
    local DotSize
    local ColorMode
    local ColorA
    local ColorB
    local GradientDirection
    local Dynamic
    local MovementBehavior
    local RecoilBounce
    local RecoilAmount
    local FollowTarget
    local AlwaysFollow
    local ArmTop
    local ArmRight
    local ArmBottom
    local ArmLeft
    local lines = {}
    local outlines = {}
    local dot
    local dotOutline
    local recoil = 0
    local lastCamera = gameCamera and gameCamera.CFrame or CFrame.identity
    local lastTargetHead
    -- 100ms cache for the crosshair's mouse fallback entity scan
    local mouseFallbackAt, mouseFallbackEntity = 0, nil
    local MOUSE_FALLBACK_OPTS = {
        Range = 1000,
        Part = "Head",
        Players = true,
        NPCs = false,
        Wallcheck = false,
        Origin = Vector3.zero
    }
    local lastTargetAt = 0
    local lastScreenPosition
    local renderConnection

    local function removeObject(object)
        if object then
            pcall(function()
                object.Visible = false
                object:Remove()
            end)
        end
    end

    local function cleanup()
        for index = 1, 4 do
            removeObject(lines[index])
            removeObject(outlines[index])
            lines[index] = nil
            outlines[index] = nil
        end
        removeObject(dot)
        removeObject(dotOutline)
        dot = nil
        dotOutline = nil
        recoil = 0
        lastTargetHead = nil
        lastTargetAt = 0
        lastScreenPosition = nil
    end

    local function createObjects()
        cleanup()
        for index = 1, 4 do
            local line = Drawing.new("Line")
            line.Visible = false
            line.ZIndex = 4
            lines[index] = line
            local outline = Drawing.new("Line")
            outline.Visible = false
            outline.ZIndex = 3
            outline.Color = Color3.new()
            outlines[index] = outline
        end
        dot = Drawing.new("Circle")
        dot.Visible = false
        dot.Filled = true
        dot.ZIndex = 5
        dotOutline = Drawing.new("Circle")
        dotOutline.Visible = false
        dotOutline.Filled = true
        dotOutline.ZIndex = 4
        dotOutline.Color = Color3.new()
    end

    local function currentTarget()
        -- Unified target lookup. Every system that can pick a target (ragebot,
        -- aim assist, silent aim) publishes into AkiraLite.Targets, so the
        -- crosshair can follow whichever one is actually aiming. Previously this
        -- only knew about the ragebot's published state and otherwise fell back
        -- to whatever sat under the mouse, so aim assist and silent aim targets
        -- were invisible to it. Freshest valid entry wins.
        local registry = type(AkiraLite) == "table" and AkiraLite.Targets or nil
        if type(registry) == "table" then
            local best
            local bestAt
            for _, source in ipairs(AKIRA_TARGET_SOURCES) do
                local entry = registry[source]
                if type(entry) == "table"
                    and typeof(entry.Player) == "Instance"
                    and entry.Player.Parent ~= nil then
                    -- an entry with no live part still counts, but only while
                    -- it is fresh; a long-stale entry must not pin the crosshair
                    local age = os.clock() - (entry.At or 0)
                    if entry.Head == nil or (typeof(entry.Head) == "Instance" and entry.Head.Parent ~= nil and age < 2) then
                        if bestAt == nil or entry.At > bestAt then
                            best = entry
                            bestAt = entry.At
                        end
                    end
                end
            end
            if best then
                return best.Player, best.Head
            end
        end
        local rage = AkiraLite and AkiraLite.Rage
        if type(rage) == "table" and rage.CurrentTarget then
            local player = rage.CurrentTarget
            local head = rage.TargetPart
            if typeof(player) == "Instance" and player:IsA("Player") and typeof(head) == "Instance" then
                return player, head
            end
        end
        local bridge = AkiraLite and AkiraLite.RageBridge
        if type(bridge) == "table" then
            local player, head
            if type(bridge.GetTarget) == "function" then
                local ok, resultPlayer, resultHead = pcall(bridge.GetTarget)
                if ok then
                    player, head = resultPlayer, resultHead
                end
            end
            player = player or bridge.CurrentTarget
            head = head or bridge.TargetPart
            if typeof(player) == "Instance" and player:IsA("Player") and typeof(head) == "Instance" then
                return player, head
            end
        end
        -- The mouse fallback is a FULL entity scan (with a fresh options table
        -- and a camera CFrame read) and currentTarget() is called from the
        -- crosshair's RenderStepped. With nothing else targeting, that was an
        -- entity scan every single frame; it is cached for 100ms instead.
        if entitylib and entitylib.EntityMouse then
            local now = os.clock()
            if now - mouseFallbackAt >= 0.1 then
                mouseFallbackAt = now
                mouseFallbackEntity = nil
                MOUSE_FALLBACK_OPTS.Origin = gameCamera.CFrame.Position
                local ok, entity = pcall(entitylib.EntityMouse, MOUSE_FALLBACK_OPTS)
                if ok and entity then
                    mouseFallbackEntity = entity
                end
            end
            if mouseFallbackEntity then
                return mouseFallbackEntity.Player, mouseFallbackEntity.Head
            end
        end
        if lastTargetHead and lastTargetHead.Parent then
            local window = (AlwaysFollow and AlwaysFollow.Enabled) and 3 or 1
            if os.clock() - lastTargetAt < window then
                return nil, lastTargetHead
            end
        end
        return nil, nil
    end

    local function targetPosition(player, head)
        if not head or not head.Parent then
            return nil
        end
        local point, visible = gameCamera:WorldToViewportPoint(head.Position)
        if not visible or point.Z <= 0 then
            return nil
        end
        lastTargetHead = head
        lastTargetAt = os.clock()
        return Vector2.new(point.X, point.Y)
    end

    local function gradientColor(index)
        local first = ColorA and ColorA.Value or Color3.fromRGB(255, 255, 255)
        local second = ColorB and ColorB.Value or Color3.fromRGB(70, 210, 255)
        local amount = (index - 1) / 3
        if GradientDirection then
            if GradientDirection.Value == "Vertical" then
                amount = 1 - amount
            elseif GradientDirection.Value == "Diagonal" then
                amount = (index % 2 == 0) and 1 or 0
            end
        end
        return first:Lerp(second, amount)
    end

    local function colorFor(index)
        if ColorMode then
            if ColorMode.Value == "Rainbow" then
                return Color3.fromHSV((tick() * 0.15 + (index - 1) * 0.08) % 1, 0.85, 1)
            elseif ColorMode.Value == "Gradient" then
                return gradientColor(index)
            end
        end
        return ColorA and ColorA.Value or Color3.fromRGB(255, 255, 255)
    end

    local function armDirection(index, style)
        local diagonal = style == "X" or style == "Chevron"
        if style == "Chevron" then
            return index == 1 and Vector2.new(-0.7071, 0.7071) or index == 2 and Vector2.new(0.7071, 0.7071) or index == 3 and Vector2.new(-0.7071, -0.7071) or Vector2.new(0.7071, -0.7071)
        elseif diagonal then
            return index == 1 and Vector2.new(-0.7071, -0.7071) or index == 2 and Vector2.new(0.7071, -0.7071) or index == 3 and Vector2.new(-0.7071, 0.7071) or Vector2.new(0.7071, 0.7071)
        end
        return index == 1 and Vector2.new(0, -1) or index == 2 and Vector2.new(0, 1) or index == 3 and Vector2.new(-1, 0) or Vector2.new(1, 0)
    end

    local function armEnabled(index)
        return (index == 1 and (not ArmTop or ArmTop.Enabled))
            or (index == 2 and (not ArmBottom or ArmBottom.Enabled))
            or (index == 3 and (not ArmLeft or ArmLeft.Enabled))
            or (index == 4 and (not ArmRight or ArmRight.Enabled))
    end

    local function update()
        if not Crosshair or not Crosshair.Enabled or not gameCamera then
            return
        end
        local viewport = gameCamera.ViewportSize
        local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
        local player, head = currentTarget()
        local followTargetEnabled = FollowTarget and FollowTarget.Enabled
        local alwaysFollowEnabled = AlwaysFollow and AlwaysFollow.Enabled
        if followTargetEnabled or alwaysFollowEnabled then
            local position = targetPosition(player, head)
            if position then
                center = position
                lastScreenPosition = position
            elseif alwaysFollowEnabled and lastScreenPosition then
                center = lastScreenPosition
            end
        end
        local movement = 0
        local root = entitylib.character and entitylib.character.RootPart
        if root then
            movement = root.AssemblyLinearVelocity.Magnitude
        end
        local cameraDelta = gameCamera.CFrame:ToObjectSpace(lastCamera).Position
        lastCamera = gameCamera.CFrame
        if RecoilBounce and RecoilBounce.Enabled then
            local mouseDelta = Vector2.zero
            if UserInputService.GetMouseDelta then
                pcall(function()
                    mouseDelta = UserInputService:GetMouseDelta()
                end)
            end
            recoil = math.clamp(recoil + mouseDelta.Magnitude * (RecoilAmount and RecoilAmount.Value or 0.1) + cameraDelta.Magnitude * 0.02, 0, 30)
        else
            recoil = math.clamp(recoil - 0.8, 0, 30)
        end
        if RecoilBounce and RecoilBounce.Enabled then
            center -= Vector2.new(recoil * 0.35, recoil * 0.2)
        end
        local size = GlobalSize and GlobalSize.Value or 1
        local gap = (Gap and Gap.Value or 4) * size
        local length = (Length and Length.Value or 7) * size
        local thickness = math.max(1, (Thickness and Thickness.Value or 2) * size)
        local dotSize = math.max(1, (DotSize and DotSize.Value or 3) * size)
        local alpha = Opacity and math.clamp(Opacity.Value, 0, 1) or 0
        if Dynamic and Dynamic.Enabled then
            gap += math.clamp(movement * 0.05, 0, 14)
        end
        if MovementBehavior then
            if MovementBehavior.Value == "Movement" then
                gap += math.clamp(movement * 0.02, 0, 8)
            elseif MovementBehavior.Value == "Recoil" and not (RecoilBounce and RecoilBounce.Enabled) then
                gap += math.clamp(recoil * 0.1, 0, 8)
            end
        end
        local rotation = Angle and Angle.Value or 0
        if Spin and Spin.Enabled then
            rotation = (rotation + (SpinSpeed and SpinSpeed.Value or 90) * (os.clock() % 360)) % 360
        end
        local radians = math.rad(rotation)
        local cosine = math.cos(radians)
        local sine = math.sin(radians)
        local style = Style and Style.Value or "Cross"
        local hideArms = style == "Dot"
        for index = 1, 4 do
            local line = lines[index]
            local outline = outlines[index]
            local enabled = not hideArms and armEnabled(index)
            if style == "T" and index == 1 then
                enabled = false
            end
            if style == "Dot" then
                enabled = false
            end
            if line and outline then
                if not enabled then
                    line.Visible = false
                    outline.Visible = false
                else
                    local direction = armDirection(index, style)
                    local rotated = Vector2.new(direction.X * cosine - direction.Y * sine, direction.X * sine + direction.Y * cosine)
                    local from = center + rotated * gap
                    local to = center + rotated * (gap + length)
                    outline.From = from
                    outline.To = to
                    outline.Thickness = thickness + (OutlineThickness and OutlineThickness.Value or 1) * 2
                    outline.Transparency = alpha
                    outline.Color = Color3.new()
                    outline.Visible = OutlineToggle and OutlineToggle.Enabled == true
                    line.From = from
                    line.To = to
                    line.Thickness = thickness
                    line.Color = colorFor(index)
                    line.Transparency = alpha
                    line.Visible = true
                end
            end
        end
        local showDot = CenterDot and CenterDot.Enabled or style == "Dot"
        if dot and dotOutline then
            dot.Position = center
            dot.Radius = dotSize
            dot.Color = colorFor(1)
            dot.Transparency = alpha
            dot.Visible = showDot
            dotOutline.Position = center
            dotOutline.Radius = dotSize + (OutlineThickness and OutlineThickness.Value or 1)
            dotOutline.Transparency = alpha
            dotOutline.Visible = showDot and OutlineToggle and OutlineToggle.Enabled == true
        end
    end

    Crosshair = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Crosshair',
        Function = function(callback)
            if callback then
                createObjects()
                Crosshair:Clean(cleanup)
                renderConnection = RunService.RenderStepped:Connect(function()
                    pcall(update)
                end)
                Crosshair:Clean(renderConnection)
            else
                cleanup()
            end
        end
    })

    Style = Crosshair:AddDropdown({Name = 'Style', List = {'Cross', 'X', 'T', 'Dot', 'Chevron'}})
    Angle = Crosshair:AddSlider({Name = 'Rotation', Min = 0, Max = 360, Default = 0, Decimal = 1, Darker = true})
    Spin = Crosshair:AddToggle({Name = 'Spin', Darker = true})
    SpinSpeed = Crosshair:AddSlider({Name = 'Spin Speed', Min = 10, Max = 360, Default = 90, Decimal = 1, Darker = true})
    Gap = Crosshair:AddSlider({Name = 'Gap', Min = 0, Max = 30, Default = 4, Decimal = 1})
    Length = Crosshair:AddSlider({Name = 'Length', Min = 1, Max = 30, Default = 7, Decimal = 1})
    Thickness = Crosshair:AddSlider({Name = 'Thickness', Min = 1, Max = 8, Default = 2, Decimal = 1})
    GlobalSize = Crosshair:AddSlider({Name = 'Global Size', Min = 0.5, Max = 3, Default = 1, Decimal = 10, Darker = true})
    Opacity = Crosshair:AddSlider({Name = 'Opacity', Min = 0, Max = 1, Default = 0, Decimal = 10, Darker = true})
    OutlineToggle = Crosshair:AddToggle({Name = 'Outline', Default = true, Darker = true})
    OutlineThickness = Crosshair:AddSlider({Name = 'Outline Thickness', Min = 1, Max = 5, Default = 1, Decimal = 1, Darker = true})
    CenterDot = Crosshair:AddToggle({Name = 'Center Dot', Default = false, Darker = true})
    DotSize = Crosshair:AddSlider({Name = 'Dot Size', Min = 1, Max = 12, Default = 3, Decimal = 1, Darker = true})
    ColorMode = Crosshair:AddDropdown({Name = 'Color Mode', List = {'Solid', 'Gradient', 'Rainbow'}})
    ColorA = Crosshair:AddColorPicker({Name = 'Primary Color', Default = Color3.fromRGB(255, 255, 255)})
    ColorB = Crosshair:AddColorPicker({Name = 'Secondary Color', Default = Color3.fromRGB(70, 210, 255), Darker = true})
    GradientDirection = Crosshair:AddDropdown({Name = 'Gradient Direction', List = {'Horizontal', 'Vertical', 'Diagonal'}, Darker = true})
    Dynamic = Crosshair:AddToggle({Name = 'Dynamic Gap', Darker = true})
    MovementBehavior = Crosshair:AddDropdown({Name = 'Movement Behavior', List = {'Static', 'Movement', 'Recoil'}, Darker = true})
    RecoilBounce = Crosshair:AddToggle({Name = 'Recoil Bounce', Darker = true})
    RecoilAmount = Crosshair:AddSlider({Name = 'Recoil Amount', Min = 0, Max = 2, Default = 0.1, Decimal = 100, Darker = true})
    -- Follow Target defaults ON. It shipped defaulted off, so out of the box the
    -- crosshair sat at screen centre no matter what the ragebot, aim assist or
    -- silent aim were doing - which is exactly "it should follow any target".
    FollowTarget = Crosshair:AddToggle({Name = 'Follow Target', Default = true, Darker = true})
    AlwaysFollow = Crosshair:AddToggle({Name = 'Hold Last Target', Darker = true})
    ArmTop = Crosshair:AddToggle({Name = 'Top Arm', Default = true, Darker = true})
    ArmBottom = Crosshair:AddToggle({Name = 'Bottom Arm', Default = true, Darker = true})
    ArmLeft = Crosshair:AddToggle({Name = 'Left Arm', Default = true, Darker = true})
    ArmRight = Crosshair:AddToggle({Name = 'Right Arm', Default = true, Darker = true})
end)
    akiraMark("block29:done")
akiraPlaySound = function(soundId, volume, playbackSpeed)
    if type(soundId) ~= "string" or soundId == "" then
        return nil
    end
    local ok, sound = pcall(function()
        local instance = Instance.new("Sound")
        instance.SoundId = soundId
        instance.Volume = math.clamp(tonumber(volume) or 0.4, 0, 1)
        instance.PlaybackSpeed = math.clamp(tonumber(playbackSpeed) or 1, 0.1, 3)
        instance.Parent = game:GetService("SoundService")
        instance:Play()
        return instance
    end)
    if not ok then
        return nil
    end
    task.delay(4, function()
        if sound and sound.Parent then
            sound:Destroy()
        end
    end)
    return sound
end
akiraGetLocalFighter = function()
    if AkiraLite.RivFighterCache then
        return AkiraLite.RivFighterCache
    end
    local scripts = lplr and lplr:FindFirstChild("PlayerScripts")
    local controllers = scripts and scripts:FindFirstChild("Controllers")
    local module = controllers and controllers:FindFirstChild("FighterController")
    if not module then
        return nil
    end
    local ok, controller = pcall(require, module)
    if ok and type(controller) == "table" then
        AkiraLite.RivFighterCache = controller
        return controller
    end
    return nil
end
akiraGetEquippedItem = function()
    local controller = akiraGetLocalFighter()
    local fighter = controller and rawget(controller, "LocalFighter") or nil
    if type(fighter) == "table" then
        local item = rawget(fighter, "EquippedItem")
        if item then
            return item
        end
    end
    local character = lplr and lplr.Character
    local tool = character and character:FindFirstChildOfClass("Tool")
    if tool then
        return tool
    end
    return nil
end
akiraItemValue = function(item, key)
    if type(item) ~= "table" then
        return nil
    end
    if type(item.Get) == "function" then
        local ok, value = pcall(item.Get, item, key)
        if ok and value ~= nil then
            return value
        end
    end
    local data = rawget(item, "Data")
    if type(data) == "table" then
        local value = rawget(data, key)
        if value ~= nil then
            return value
        end
    end
    local info = rawget(item, "Info") or rawget(item, "Config")
    if type(info) == "table" then
        local value = rawget(info, key)
        if value ~= nil then
            return value
        end
    end
    return rawget(item, key)
end
akiraItemDataTables = function(item)
    local tables = {}
    if type(item) ~= "table" then
        return tables
    end
    table.insert(tables, item)
    for _, key in ipairs({"Data", "Info", "Config"}) do
        local value = rawget(item, key)
        if type(value) == "table" then
            table.insert(tables, value)
        end
    end
    local viewModel = rawget(item, "ViewModel")
    if type(viewModel) == "table" then
        table.insert(tables, viewModel)
    end
    return tables
end
akiraOverrideFields = function(spec, item)
    if type(item) ~= "table" or not spec.Enabled or not spec.Enabled.Enabled then
        return
    end
    spec.Saved = spec.Saved or {}
    local now = os.clock()
    if spec.NextScan and spec.NextScan > now then
        return
    end
    spec.NextScan = now + 0.2
    for _, container in ipairs(akiraItemDataTables(item)) do
        local saved = spec.Saved[container]
        if not saved then
            saved = {}
            spec.Saved[container] = saved
        end
        for field, value in pairs(container) do
            if type(field) == "string" and type(value) == "number" then
                local lowered = field:lower()
                for _, pattern in ipairs(spec.Patterns or {}) do
                    if lowered:find(pattern, 1, true) then
                        if saved[field] == nil then
                            saved[field] = value
                        end
                        local nextValue
                        if spec.Mode == "replace" then
                            nextValue = spec.Value and spec.Value.Value or 0
                        else
                            local scale = spec.Scale and spec.Scale.Value or 0
                            nextValue = (saved[field] or 0) * scale
                        end
                        if nextValue ~= container[field] then
                            pcall(rawset, container, field, nextValue)
                        end
                        break
                    end
                end
            end
        end
    end
end

akiraRestoreSpec = function(spec)
    if type(spec) ~= "table" or not spec.Saved then
        return
    end
    for container, fields in pairs(spec.Saved) do
        for field, value in pairs(fields) do
            pcall(rawset, container, field, value)
        end
    end
    spec.Saved = nil
    spec.NextScan = nil
end
    akiraMark("block30:start")
run(function()
    local Feedback
    local MarkerToggle
    local MarkerColor
    local MarkerSize
    local MarkerDuration
    local ChamsToggle
    local ChamsColor
    local ChamsDuration
    local SoundToggle
    local SoundVolume
    local HitSoundId
    local KillSoundId
    local KillBanner
    local BannerDuration
    local BannerColor
    local PulseToggle
    local PulseVolume
    local PulseInterval
    local TracerToggle
    local TracerColor
    local TracerThickness
    local TracerDuration
    local markers = {}
    local tracers = {}
    local bannerFrame
    local bannerLabel
    local bannerScale
    local state = {}
    local hits, kills = 0, 0

    local function localHead()
        local character = lplr and lplr.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        return root, head
    end

    local function screenOf(part)
        if not part or not part.Parent or not gameCamera then
            return nil
        end
        local point, visible = gameCamera:WorldToViewportPoint(part.Position)
        if not visible or point.Z <= 0 then
            return nil
        end
        return Vector2.new(point.X, point.Y)
    end

    local function showBanner(text)
        if not bannerFrame or not bannerLabel then
            return
        end
        bannerLabel.Text = text
        if BannerColor and BannerColor.Value then
            pcall(function()
                bannerLabel.TextColor3 = BannerColor.Value
            end)
        end
        bannerFrame.Visible = true
        if bannerScale then
            bannerScale.Scale = 0
            if AkiraLite.CreateTween then
                pcall(function()
                    AkiraLite:CreateTween(bannerScale, {
                        Time = 0.25,
                        EasingStyle = Enum.EasingStyle.Back,
                        EasingDirection = Enum.EasingDirection.Out,
                        RepeatCount = 0,
                        DelayTime = 0
                    }, {Scale = 1}):Play()
                end)
            else
                bannerScale.Scale = 1
            end
        end
    end

    local function createBanner()
        if bannerFrame and bannerFrame.Parent then
            return
        end
        local parent = AkiraLite.MainScreenGui or (lplr and lplr:FindFirstChildOfClass("PlayerGui"))
        if not parent then
            return
        end
        bannerFrame = Instance.new("Frame")
        bannerFrame.Name = "AkiraKillBanner"
        bannerFrame.Size = UDim2.fromOffset(240, 34)
        bannerFrame.Position = UDim2.new(0.5, -120, 0.24, 0)
        bannerFrame.BackgroundColor3 = Color3.fromRGB(16, 17, 21)
        bannerFrame.BackgroundTransparency = 0.1
        bannerFrame.BorderSizePixel = 0
        bannerFrame.Visible = false
        bannerFrame.ZIndex = 70
        bannerFrame.Parent = parent
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = bannerFrame
        bannerLabel = Instance.new("TextLabel")
        bannerLabel.Size = UDim2.new(1, -16, 1, 0)
        bannerLabel.Position = UDim2.fromOffset(8, 0)
        bannerLabel.BackgroundTransparency = 1
        bannerLabel.Text = ""
        bannerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        bannerLabel.TextSize = 13
        bannerLabel.FontFace = Font.fromEnum(Enum.Font.BuilderSansBold)
        bannerLabel.TextXAlignment = Enum.TextXAlignment.Left
        bannerLabel.ZIndex = 71
        bannerLabel.Parent = bannerFrame
        bannerScale = Instance.new("UIScale")
        bannerScale.Parent = bannerFrame
        pcall(function()
            AkiraLite.RegisterStyleTree(AkiraLite, bannerFrame)
        end)
    end

    local function ensureMarker()
        if markers.mark then
            return
        end
        local ok, circle = pcall(function()
            return Drawing.new("Circle")
        end)
        markers.mark = ok and circle or nil
        if markers.mark then
            markers.mark.Visible = false
            markers.mark.Filled = false
            markers.mark.Thickness = 2
            markers.mark.NumSides = 24
        end
        for index = 1, 4 do
            local okLine, line = pcall(function()
                return Drawing.new("Line")
            end)
            markers["line" .. index] = okLine and line or nil
            if markers["line" .. index] then
                markers["line" .. index].Visible = false
                markers["line" .. index].Thickness = 2
            end
        end
    end

    local function hideMarker()
        if not markers.mark then
            return
        end
        markers.mark.Visible = false
        for index = 1, 4 do
            local line = markers["line" .. index]
            if line then
                line.Visible = false
            end
        end
    end

    local function clearMarker()
        hideMarker()
        for index = 1, 4 do
            local line = markers["line" .. index]
            if line then
                pcall(function()
                    line:Remove()
                end)
                markers["line" .. index] = nil
            end
        end
        if markers.mark then
            pcall(function()
                markers.mark:Remove()
            end)
            markers.mark = nil
        end
    end

    local function flashChams(ent, color, duration)
        local adornments = {}
        if not ent or not ent.Character then
            return
        end
        for _, part in ipairs(ent.Character:GetChildren()) do
            if part:IsA("BasePart") then
                local adornment = Instance.new(part.Name == "Head" and "SphereHandleAdornment" or "BoxHandleAdornment")
                adornment.Adornee = part
                adornment.AlwaysOnTop = true
                adornment.Color3 = color
                adornment.Transparency = 0.25
                adornment.ZIndex = 1
                if adornment:IsA("SphereHandleAdornment") then
                    adornment.Radius = part.Size.X * 0.6
                else
                    adornment.Size = part.Size * 1.05
                end
                adornment.Parent = AkiraLite.MainScreenGui
                table.insert(adornments, adornment)
            end
        end
        task.delay(duration, function()
            for _, adornment in ipairs(adornments) do
                pcall(function()
                    adornment:Destroy()
                end)
            end
        end)
    end

    local function spawnTracer(from, to, color)
        local ok, line = pcall(function()
            return Drawing.new("Line")
        end)
        if not ok or not line then
            return
        end
        line.From = from
        line.To = to
        line.Color = color
        line.Thickness = TracerThickness and TracerThickness.Value or 2
        line.Transparency = 0
        line.Visible = true
        local entry = {Line = line, Start = os.clock(), From = from, To = to}
        table.insert(tracers, entry)
    end

    local lastHealthPoll = 0
    local function onHealthChanged(ent)        if not ent or ent.Player == lplr or not Feedback or not Feedback.Enabled then
            return
        end
        local previous = state[ent]
        if not previous then
            state[ent] = {Health = ent.Health, Flash = 0}
            return
        end
        local current = ent.Health or 0
        if current < (previous.Health or 0) - 0.4 then
            previous.Flash = os.clock() + 0.4
            hits += 1
            local head = ent.Head or (ent.Character and ent.Character:FindFirstChild("Head"))
            if MarkerToggle and MarkerToggle.Enabled then
                ensureMarker()
                markers.expireAt = os.clock() + (MarkerDuration and MarkerDuration.Value or 0.25)
            end
            if ChamsToggle and ChamsToggle.Enabled then
                flashChams(ent, ChamsColor and ChamsColor.Value or Color3.fromRGB(255, 70, 70), ChamsDuration and ChamsDuration.Value or 0.3)
            end
            if TracerToggle and TracerToggle.Enabled then
                local root, localHeadPart = localHead()
                if root then
                    spawnTracer((root.Position + Vector3.new(0, 1, 0)), (head and head.Position or root.Position), TracerColor and TracerColor.Value or Color3.fromRGB(255, 255, 255))
                end
            end
            if SoundToggle and SoundToggle.Enabled then
                akiraPlaySound(HitSoundId and HitSoundId.Value or "rbxassetid://9118823100", SoundVolume and SoundVolume.Value or 0.4)
            end
        elseif current <= 0 and (previous.Health or 0) > 0 then
            previous.Dead = true
            kills += 1
            if KillBanner and KillBanner.Enabled then
                createBanner()
                showBanner("ELIMINATED  " .. getPlayerIdentity(ent.Player, true))
                task.delay(BannerDuration and BannerDuration.Value or 2, function()
                    if bannerFrame then
                        bannerFrame.Visible = false
                    end
                end)
            end
            if SoundToggle and SoundToggle.Enabled then
                akiraPlaySound(KillSoundId and KillSoundId.Value or "rbxassetid://9126226534", SoundVolume and SoundVolume.Value or 0.4)
            end
        end
        previous.Health = current
    end

    Feedback = AkiraLite.Catalogs.Combat:AddModule({
        Name = 'Combat Feedback',
        Function = function(callback)
            if callback then
                createBanner()
                Feedback:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
                    state[ent] = {Health = ent.Health, Flash = 0}
                end))
                Feedback:Clean(entitylib.Events.EntityRemoved:Connect(function(ent)
                    state[ent] = nil
                end))
                for _, ent in ipairs(entitylib.List) do
                    state[ent] = {Health = ent.Health, Flash = 0}
                end
    Feedback:Clean(RunService.RenderStepped:Connect(function()
        local now = os.clock()
        -- polling every entity's Health every frame is pure waste at 60+Hz:
        -- the flash effect only needs ~20Hz to look identical
        if now - lastHealthPoll >= 0.05 then
            lastHealthPoll = now
            for _, ent in ipairs(entitylib.List) do
                onHealthChanged(ent)
            end
        end
                    if markers.mark and markers.expireAt and now < markers.expireAt then
                        local _, headPart = localHead()
                        local position = screenOf(headPart or (entitylib.character and entitylib.character.RootPart))
                        local size = MarkerSize and MarkerSize.Value or 8
                        local color = MarkerColor and MarkerColor.Value or Color3.fromRGB(255, 255, 255)
                        if position then
                            markers.mark.Visible = true
                            markers.mark.Position = position
                            markers.mark.Radius = size
                            markers.mark.Color = color
                            markers.mark.Transparency = math.clamp((markers.expireAt - now) / 0.25, 0, 1)
                            for index = 1, 4 do
                                local line = markers["line" .. index]
                                if line then
                                    local angle = math.rad(45 + (index - 1) * 90)
                                    local direction = Vector2.new(math.cos(angle), math.sin(angle))
                                    line.Visible = true
                                    line.From = position + direction * (size * 0.5)
                                    line.To = position + direction * size
                                    line.Color = color
                                    line.Thickness = 2
                                    line.Transparency = markers.mark.Transparency
                                end
                            end
                        else
                            hideMarker()
                        end
                    else
                        hideMarker()
                    end
                    for index = #tracers, 1, -1 do
                        local entry = tracers[index]
                        local life = TracerDuration and TracerDuration.Value or 0.3
                        local elapsed = now - entry.Start
                        if elapsed >= life then
                            pcall(function()
                                entry.Line:Remove()
                            end)
                            table.remove(tracers, index)
                        else
                            local progress = elapsed / life
                            local mid = entry.From:Lerp(entry.To, math.clamp(progress * 1.4, 0, 1))
                            entry.Line.To = mid
                            entry.Line.Transparency = 1 - progress
                        end
                    end
                    if PulseToggle and PulseToggle.Enabled then
                        local interval = PulseInterval and PulseInterval.Value or 2
                        if not Feedback.LastPulse or now - Feedback.LastPulse >= interval then
                            Feedback.LastPulse = now
                            akiraPlaySound("rbxassetid://130113322", PulseVolume and PulseVolume.Value or 0.15, 1.4)
                        end
                    end
                end))
            else
                hideMarker()
                clearMarker()
                for index = #tracers, 1, -1 do
                    local entry = tracers[index]
                    pcall(function()
                        entry.Line:Remove()
                    end)
                    table.remove(tracers, index)
                end
                if bannerFrame then
                    bannerFrame.Visible = false
                end
            end
        end,
        ExtraText = function()
            return string.format("%d HITS  %d KILLS", hits, kills)
        end
    })
    MarkerToggle = Feedback:AddToggle({Name = 'Hit Marker', Default = true})
    MarkerColor = Feedback:AddColorPicker({Name = 'Marker Color', Default = Color3.fromRGB(255, 255, 255), Darker = true})
    MarkerSize = Feedback:AddSlider({Name = 'Marker Size', Min = 3, Max = 24, Default = 8, Decimal = 1, Darker = true})
    MarkerDuration = Feedback:AddSlider({Name = 'Marker Duration', Min = 0.05, Max = 1, Default = 0.25, Decimal = 100, Darker = true})
    ChamsToggle = Feedback:AddToggle({Name = 'Hit Chams', Default = true})
    ChamsColor = Feedback:AddColorPicker({Name = 'Hit Chams Color', Default = Color3.fromRGB(255, 65, 65), Darker = true})
    ChamsDuration = Feedback:AddSlider({Name = 'Hit Chams Duration', Min = 0.05, Max = 1, Default = 0.3, Decimal = 100, Darker = true})
    TracerToggle = Feedback:AddToggle({Name = 'Bullet Tracers', Darker = true})
    TracerColor = Feedback:AddColorPicker({Name = 'Tracer Color', Default = Color3.fromRGB(255, 235, 130), Darker = true})
    TracerThickness = Feedback:AddSlider({Name = 'Tracer Thickness', Min = 1, Max = 6, Default = 2, Decimal = 1, Darker = true})
    TracerDuration = Feedback:AddSlider({Name = 'Tracer Duration', Min = 0.05, Max = 1, Default = 0.3, Decimal = 100, Darker = true})
    SoundToggle = Feedback:AddToggle({Name = 'Sound'})
    SoundVolume = Feedback:AddSlider({Name = 'Volume', Min = 0, Max = 1, Default = 0.4, Decimal = 100, Darker = true})
    HitSoundId = Feedback:AddTextInput({Name = 'Hit Sound', Default = "rbxassetid://9118823100", MaxLength = 128, Darker = true})
    KillSoundId = Feedback:AddTextInput({Name = 'Kill Sound', Default = "rbxassetid://9126226534", MaxLength = 128, Darker = true})
    KillBanner = Feedback:AddToggle({Name = 'Kill Banner', Default = true})
    BannerColor = Feedback:AddColorPicker({Name = 'Banner Color', Default = Color3.fromRGB(255, 235, 130), Darker = true})
    BannerDuration = Feedback:AddSlider({Name = 'Banner Duration', Min = 0.5, Max = 5, Default = 2, Decimal = 10, Darker = true})
    PulseToggle = Feedback:AddToggle({Name = 'Sound Pulses', Darker = true})
    PulseVolume = Feedback:AddSlider({Name = 'Pulse Volume', Min = 0, Max = 0.5, Default = 0.15, Decimal = 100, Darker = true})
    PulseInterval = Feedback:AddSlider({Name = 'Pulse Interval', Min = 0.5, Max = 10, Default = 2, Decimal = 10, Darker = true})
end)
    akiraMark("block30:done")
    akiraMark("block31:start")
run(function()
    local Mods
    local AttackSpeed
    local AttackFactor
    local FastReload
    local ReloadFactor
    local NoSpread
    local NoRecoil
    local FastADS
    local FastEquip
    local ScytheDash
    local AutomaticWeapon
    local InstantFuse
    local RemoveFuse
    local ProjectileRapid
    local BowInstant
    local specs = {}
    local recoilSaved = {}
    local function buildSpecs()
        specs = {
            {Enabled = AttackSpeed, Patterns = {"shoot", "attack", "burst"}, Mode = "scale", Scale = AttackFactor},
            {Enabled = FastReload, Patterns = {"reload"}, Mode = "scale", Scale = ReloadFactor},
            {Enabled = NoSpread, Patterns = {"spread", "inaccuracy", "bloom"}, Mode = "scale", Scale = {Value = 0}},
            {Enabled = FastADS, Patterns = {"ads", "aimdown"}, Mode = "scale", Scale = {Value = 0}},
            {Enabled = FastEquip, Patterns = {"equip", "holster"}, Mode = "scale", Scale = {Value = 0}},
            {Enabled = ScytheDash, Patterns = {"dashcooldown", "_dash_cooldown"}, Mode = "scale", Scale = {Value = 0}},
            {Enabled = AutomaticWeapon, Patterns = {"autofire", "auto_cooldown", "fullauto"}, Mode = "scale", Scale = {Value = 0}},
            {Enabled = InstantFuse, Patterns = {"fuse", "cook", "detonate"}, Mode = "replace", Value = {Value = 0}},
            {Enabled = RemoveFuse, Patterns = {"fuse", "cook", "detonate"}, Mode = "replace", Value = {Value = 99999}},
            {Enabled = ProjectileRapid, Patterns = {"projectile", "rocket", "launch"}, Mode = "scale", Scale = {Value = 0}},
            {Enabled = BowInstant, Patterns = {"drawtime", "_draw_cooldown"}, Mode = "scale", Scale = {Value = 0}}
        }
    end
    local function applyNoRecoil()
        if not NoRecoil or not NoRecoil.Enabled then
            return
        end
        local item = akiraGetEquippedItem()
        local vm = type(item) == "table" and (rawget(item, "ViewModel") or rawget(item, "_viewModel")) or nil
        if type(vm) ~= "table" then
            return
        end
        for _, field in ipairs({"_recoil_spring", "_recoil_shake", "_recoil_value_spring", "_recoil_speed_spring"}) do
            local spring = rawget(vm, field)
            if spring then
                if recoilSaved[spring] == nil then
                    recoilSaved[spring] = {
                        Value = rawget(spring, "Value"),
                        Position = rawget(spring, "Position"),
                        Velocity = rawget(spring, "Velocity")
                    }
                end
                pcall(function()
                    if spring.Value ~= nil then
                        spring.Value = 0
                    end
                    if spring.Position ~= nil then
                        spring.Position = 0
                    end
                end)
            end
        end
    end
    local function restoreNoRecoil()
        for spring, original in pairs(recoilSaved) do
            pcall(function()
                if original.Value ~= nil then
                    spring.Value = original.Value
                end
                if original.Position ~= nil then
                    spring.Position = original.Position
                end
                if original.Velocity ~= nil then
                    spring.Velocity = original.Velocity
                end
            end)
        end
        table.clear(recoilSaved)
    end
    Mods = AkiraLite.Catalogs.Combat:AddModule({
        Name = 'Weapon Mods',
        Function = function(callback)
            if callback then
                buildSpecs()
                Mods:Clean(RunService.Heartbeat:Connect(function()
                    local item = akiraGetEquippedItem()
                    if not item then
                        return
                    end
                    for _, spec in ipairs(specs) do
                        akiraOverrideFields(spec, item)
                    end
                    applyNoRecoil()
                end))
            else
                for _, spec in ipairs(specs) do
                    akiraRestoreSpec(spec)
                end
                restoreNoRecoil()
                specs = {}
            end
        end
    })
    AttackSpeed = Mods:AddToggle({Name = 'Attack Speed', Default = true})
    AttackFactor = Mods:AddSlider({Name = 'Attack Speed', Min = 0, Max = 1, Default = 0, Decimal = 100, Darker = true})
    FastReload = Mods:AddToggle({Name = 'Fast Reload', Default = true})
    ReloadFactor = Mods:AddSlider({Name = 'Reload Speed', Min = 0, Max = 1, Default = 0, Decimal = 100, Darker = true})
    NoSpread = Mods:AddToggle({Name = 'No Spread', Default = true})
    NoRecoil = Mods:AddToggle({Name = 'No Recoil', Default = true})
    FastADS = Mods:AddToggle({Name = 'Fast ADS'})
    FastEquip = Mods:AddToggle({Name = 'Fast Equip'})
    ScytheDash = Mods:AddToggle({Name = 'Scythe Dash Cooldown'})
    AutomaticWeapon = Mods:AddToggle({Name = 'Automatic Weapon'})
    InstantFuse = Mods:AddToggle({Name = 'Instant Grenade Fuse'})
    RemoveFuse = Mods:AddToggle({Name = 'Remove Grenade Fuse'})
    ProjectileRapid = Mods:AddToggle({Name = 'Projectile Rapid Fire'})
    BowInstant = Mods:AddToggle({Name = 'Bow Instant Draw'})
end)
    akiraMark("block31:done")
    akiraMark("block32:start")
run(function()
    local Remover
    local patterns = {}
    local originals = {}
    local connections = {}

    local function classify(name)
        local lowered = string.lower(name or "")
        if lowered:find("flashbang", 1, true) or lowered:find("flashbangui", 1, true) or lowered:find("flash_effect", 1, true) then
            return "Flashbang"
        end
        if lowered:find("burn", 1, true) or lowered:find("fireeffect", 1, true) or lowered:find("incendiary", 1, true) then
            return "Burn"
        end
        if lowered:find("vignette", 1, true) then
            return "Vignette"
        end
        if lowered:find("scope", 1, true) and lowered:find("reticle", 1, true) then
            return "Reticle"
        end
        if lowered:find("scope", 1, true) or lowered:find("scopedgui", 1, true) or lowered:find("sniperoverlay", 1, true) then
            return "Scope"
        end
        if lowered:find("muzzle", 1, true) or lowered:find("muzzleflash", 1, true) then
            return "Muzzle"
        end
        if lowered:find("hitmarker", 1, true) or lowered:find("hit_marker", 1, true) then
            return "Hitmarker"
        end
        if lowered:find("tracer", 1, true) and lowered:find("gui", 1, true) then
            return "Tracers"
        end
        return nil
    end

    local function applyTo(object)
        if not object or not object.Parent then
            return
        end
        if not (object:IsA("GuiObject") or object:IsA("LayerCollector")) then
            return
        end
        if originals[object] ~= nil then
            return
        end
        local category = classify(object.Name)
        if not category then
            category = classify(object.Parent and object.Parent.Name)
        end
        if not category then
            return
        end
        local toggle = patterns[category]
        if not toggle or not toggle.Enabled then
            return
        end
        originals[object] = object.Visible
        object.Visible = false
    end

    local function scan(root)
        if not root then
            return
        end
        applyTo(root)
        for _, object in ipairs(root:GetDescendants()) do
            applyTo(object)
        end
    end

    local function start()
        local playerGui = lplr and lplr:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            table.insert(connections, playerGui.DescendantAdded:Connect(applyTo))
            scan(playerGui)
        end
        table.insert(connections, CoreGui.DescendantAdded:Connect(applyTo))
        scan(CoreGui)
    end

    local function stop()
        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(connections)
        for object, visible in pairs(originals) do
            if object and object.Parent then
                pcall(function()
                    object.Visible = visible
                end)
            end
        end
        table.clear(originals)
    end

    -- REMOVED for performance: 'Remove Effects' walked characters and effects
    -- every single frame. The per-frame work and the UI entry are both gone.
    --
    -- The controls that used to be created here referenced `Remover`, which no
    -- longer exists now that the module itself is gone, so this whole block died
    -- with "attempt to index nil with 'AddToggle'". Nothing outside this block
    -- reads `patterns`, so the whole thing goes.
end)
    akiraMark("block32:done")
    akiraMark("block33:start")
run(function()
    local AnimationControl
    local noShoot
    local noSprint
    local noEquip
    local noReload
    local sets = {}

    local function stopAnimations(vm)
        if type(vm) ~= "table" then
            return
        end
        local animations = rawget(vm, "Animations")
        if type(animations) ~= "table" then
            return
        end
        for name, track in pairs(animations) do
            if type(name) == "string" and sets[name:lower()] and track then
                pcall(function()
                    if type(track.StopAnimation) == "function" then
                        track:StopAnimation(0)
                    elseif type(track.Stop) == "function" then
                        track:Stop(0)
                    end
                end)
            end
        end
    end

    local function collectSets()
        sets = {}
        if noShoot and noShoot.Enabled then
            for _, pattern in ipairs({"shoot", "attack", "fire", "shots"}) do
                sets[pattern] = true
            end
        end
        if noSprint and noSprint.Enabled then
            sets["sprint"] = true
        end
        if noEquip and noEquip.Enabled then
            for _, pattern in ipairs({"equip", "draw", "holster", "switch"}) do
                sets[pattern] = true
            end
        end
        if noReload and noReload.Enabled then
            for _, pattern in ipairs({"reload"}) do
                sets[pattern] = true
            end
        end
    end

    -- REMOVED for performance: 'Remove Animations' walked characters and effects
    -- every single frame. The per-frame work and the UI entry are both gone.
    --
    -- Same story as the block above: these controls referenced `AnimationControl`,
    -- which no longer exists, so the block threw "attempt to index nil with
    -- 'AddToggle'" on every load. The guards above already tolerate nil.
end)
    akiraMark("block33:done")
    akiraMark("block34:start")
run(function()
    local Throwable
    local ShowName
    local ShowDistance
    local NameSize
    local DistanceSize
    local MaxDistance
    local NameColor
    local DistanceColor
    local LineColor
    local ShowLine
    local ShowIcon
    local entries = {}
    local icons = {}
    local WORLD_ITEMS = {
        ["Throwable - Grenade"] = {Color = Color3.fromRGB(255, 80, 80), Label = "GRENADE", Key = "Grenade"},
        ["Throwable - Flashbang"] = {Color = Color3.fromRGB(255, 220, 100), Label = "FLASH", Key = "Flashbang"},
        ["Throwable - Molotov"] = {Color = Color3.fromRGB(255, 120, 0), Label = "MOLOTOV", Key = "Molotov"},
        ["Throwable - Smoke"] = {Color = Color3.fromRGB(200, 200, 200), Label = "SMOKE", Key = "Smoke"}
    }

    local function infoFor(name)
        local direct = WORLD_ITEMS[name]
        if direct then
            return direct
        end
        for key, value in pairs(WORLD_ITEMS) do
            if name:lower():find(value.Key:lower(), 1, true) then
                return value
            end
        end
        return nil
    end

    local function anchorOf(instance)
        if instance:IsA("Model") then
            return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart") or instance
        end
        return instance
    end

    local function iconFor(key)
        if icons[key] ~= nil then
            return icons[key]
        end
        local resolved = ""
        local models = workspace:FindFirstChild("ViewModels")
        if models then
            for _, model in ipairs(models:GetChildren()) do
                if model:IsA("Model") and model.Name:lower():find(key:lower(), 1, true) then
                    for _, child in ipairs(model:GetDescendants()) do
                        if (child:IsA("ImageLabel") or child:IsA("Texture")) and type(child.Image or child.Texture) == "string" and child.Image ~= "" then
                            resolved = child.Image or child.Texture
                            break
                        end
                    end
                    if resolved ~= "" then
                        break
                    end
                end
            end
        end
        icons[key] = resolved
        return resolved
    end

    local function createEntry(instance, info)
        if entries[instance] then
            return
        end
        local labelOk, label = pcall(function()
            return Drawing.new("Text")
        end)
        local distanceOk, distance = pcall(function()
            return Drawing.new("Text")
        end)
        local lineOk, line = pcall(function()
            return Drawing.new("Line")
        end)
        if not (labelOk and distanceOk) then
            return
        end
        label.Visible = false
        label.Outline = true
        label.Font = 2
        label.Size = NameSize and NameSize.Value or 13
        label.Color = NameColor and NameColor.Value or info.Color
        distance.Visible = false
        distance.Outline = true
        distance.Font = 2
        distance.Size = DistanceSize and DistanceSize.Value or 12
        distance.Color = DistanceColor and DistanceColor.Value or info.Color
        local line = lineOk and line or nil
        if line then
            line.Visible = false
            line.Thickness = 1
            line.Color = LineColor and LineColor.Value or info.Color
        end
        local billboard
        if ShowIcon and ShowIcon.Enabled then
            local image = iconFor(info.Key)
            if image ~= "" then
                pcall(function()
                    local adornee = anchorOf(instance)
                    billboard = Instance.new("BillboardGui")
                    billboard.Name = "AkiraThrowableIcon"
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.fromOffset(42, 42)
                    billboard.StudsOffset = Vector3.new(0, 1.4, 0)
                    billboard.Adornee = adornee
                    billboard.Parent = adornee
                    local icon = Instance.new("ImageLabel")
                    icon.BackgroundTransparency = 1
                    icon.Size = UDim2.fromScale(1, 1)
                    icon.ScaleType = Enum.ScaleType.Fit
                    icon.Image = image
                    icon.Parent = billboard
                end)
            end
        end
        entries[instance] = {Label = label, Distance = distance, Line = line, Billboard = billboard, Info = info}
    end

    local function destroyEntry(instance)
        local entry = entries[instance]
        if not entry then
            return
        end
        pcall(function()
            entry.Label:Remove()
        end)
        pcall(function()
            entry.Distance:Remove()
        end)
        if entry.Line then
            pcall(function()
                entry.Line:Remove()
            end)
        end
        if entry.Billboard then
            pcall(function()
                entry.Billboard:Destroy()
            end)
        end
        entries[instance] = nil
    end

    local function track(instance)
        if not instance or not (instance:IsA("BasePart") or instance:IsA("Model")) then
            return
        end
        local info = infoFor(instance.Name)
        if not info then
            return
        end
        createEntry(instance, info)
    end

    local function clearAll()
        for instance in pairs(entries) do
            destroyEntry(instance)
        end
    end

    local function update()
        if not Throwable or not Throwable.Enabled then
            return
        end
        local localRoot = entitylib.character and entitylib.character.RootPart
        local max = MaxDistance and MaxDistance.Value or 400
        for instance, entry in pairs(entries) do
            local anchor = instance:IsA("Model") and anchorOf(instance) or instance
            if not instance.Parent or not anchor or not anchor.Parent or not gameCamera then
                destroyEntry(instance)
            else
                local point, onScreen = gameCamera:WorldToViewportPoint(anchor.Position)
                local distance = 0
                local withinRange = true
                if localRoot then
                    local offset = anchor.Position - localRoot.Position
                    distance = offset.Magnitude
                    withinRange = distance <= max
                end
                if not onScreen or point.Z <= 0 or not withinRange then
                    entry.Label.Visible = false
                    entry.Distance.Visible = false
                    if entry.Line then
                        entry.Line.Visible = false
                    end
                else
                    local position = Vector2.new(point.X, point.Y)
                    local color = entry.Info.Color
                    if ShowName and ShowName.Enabled then
                        entry.Label.Visible = true
                        entry.Label.Text = entry.Info.Label
                        entry.Label.Size = NameSize and NameSize.Value or 13
                        entry.Label.Color = NameColor and NameColor.Value or color
                        entry.Label.Position = position
                    else
                        entry.Label.Visible = false
                    end
                    if ShowDistance and ShowDistance.Enabled then
                        entry.Distance.Visible = true
                        entry.Distance.Text = string.format("%dm", math.floor(distance))
                        entry.Distance.Size = DistanceSize and DistanceSize.Value or 12
                        entry.Distance.Color = DistanceColor and DistanceColor.Value or color
                        entry.Distance.Position = position + Vector2.new(0, (NameSize and NameSize.Value or 13) + 2)
                    else
                        entry.Distance.Visible = false
                    end
                    if ShowLine and ShowLine.Enabled and entry.Line then
                        local viewport = gameCamera.ViewportSize
                        entry.Line.Visible = true
                        entry.Line.From = Vector2.new(viewport.X * 0.5, viewport.Y)
                        entry.Line.To = position
                        entry.Line.Color = LineColor and LineColor.Value or color
                    elseif entry.Line then
                        entry.Line.Visible = false
                    end
                end
            end
        end
    end

    Throwable = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Throwable ESP',
        Function = function(callback)
            if callback then
                for _, child in ipairs(workspace:GetChildren()) do
                    track(child)
                end
                Throwable:Clean(workspace.ChildAdded:Connect(track))
                Throwable:Clean(workspace.ChildRemoved:Connect(destroyEntry))
                Throwable:Clean(RunService.RenderStepped:Connect(update))
            else
                clearAll()
            end
        end
    })
    ShowName = Throwable:AddToggle({Name = 'Show Name', Default = true})
    ShowDistance = Throwable:AddToggle({Name = 'Show Distance', Default = true})
    NameSize = Throwable:AddSlider({Name = 'Name Size', Min = 8, Max = 24, Default = 13, Decimal = 1, Darker = true})
    DistanceSize = Throwable:AddSlider({Name = 'Distance Size', Min = 8, Max = 24, Default = 12, Decimal = 1, Darker = true})
    MaxDistance = Throwable:AddSlider({Name = 'Max Distance', Min = 50, Max = 2000, Default = 400, Decimal = 1, Darker = true})
    NameColor = Throwable:AddColorPicker({Name = 'Name Color', Default = Color3.fromRGB(255, 255, 255), Darker = true})
    DistanceColor = Throwable:AddColorPicker({Name = 'Distance Color', Default = Color3.fromRGB(255, 255, 255), Darker = true})
    ShowLine = Throwable:AddToggle({Name = 'Line To Throwable', Darker = true})
    LineColor = Throwable:AddColorPicker({Name = 'Line Color', Default = Color3.fromRGB(255, 255, 255), Darker = true})
    ShowIcon = Throwable:AddToggle({Name = 'Show Icon', Darker = true})
end)
    akiraMark("block34:done")
    akiraMark("block35:start")
run(function()
    local Storm
    local FlashToggle
    local FlashIntensity
    local ThunderToggle
    local ThunderVolume
    local ThunderDelay
    local Interval
    local SparksToggle
    local SparksRate
    local ExplosionToggle
    local thread
    local sparksPart
    local sparksEmitter
    local light
    local originalBrightness
    local function clearSparks()
        if sparksEmitter then
            pcall(function()
                sparksEmitter:Destroy()
            end)
            sparksEmitter = nil
        end
        if sparksPart then
            pcall(function()
                sparksPart:Destroy()
            end)
            sparksPart = nil
        end
    end
    local function ensureSparks()
        if sparksEmitter then
            return sparksEmitter
        end
        local ok, emitter = pcall(function()
            local part = Instance.new("Part")
            part.Name = "AkiraStormSparks"
            part.Size = Vector3.new(120, 1, 120)
            part.Transparency = 1
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.Parent = workspace
            sparksPart = part
            local instance = Instance.new("ParticleEmitter")
            instance.Name = "AkiraStormSparks"
            instance.Rate = SparksRate and SparksRate.Value or 40
            instance.Lifetime = NumberRange.new(0.6, 1.1)
            instance.Speed = NumberRange.new(30, 60)
            instance.Texture = "rbxassetid://241837157"
            instance.LightEmission = 1
            instance.Color = ColorSequence.new(Color3.fromRGB(200, 220, 255))
            instance.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 0)})
            instance.Parent = part
            sparksPart = part
            return instance
        end)
        if ok and emitter then
            sparksEmitter = emitter
            return emitter
        end
        sparksEmitter = nil
        return nil
    end
    local function flash()
        local target = originalBrightness or Lighting.Brightness
        pcall(function()
            Lighting.Brightness = target + (FlashIntensity and FlashIntensity.Value or 2)
        end)
        task.delay(0.08, function()
            pcall(function()
                Lighting.Brightness = target
            end)
        end)
    end
    local function explosion()
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end
        pcall(function()
            if not light then
                light = Instance.new("PointLight")
                light.Brightness = 0
                light.Range = 60
                light.Color = Color3.fromRGB(200, 220, 255)
                light.Parent = camera
            end
            light.Brightness = 6
            task.delay(0.12, function()
                if light then
                    light.Brightness = 0
                end
            end)
        end)
    end
    local function thunder()
        if not ThunderToggle or not ThunderToggle.Enabled then
            return
        end
        task.delay(ThunderDelay and ThunderDelay.Value or 1, function()
            if not Storm or not Storm.Enabled then
                return
            end
            akiraPlaySound("rbxassetid://9115373096", ThunderVolume and ThunderVolume.Value or 0.4, 1 + math.random() * -0.2)
        end)
    end
    local function cycle()
        while Storm and Storm.Enabled do
            local wait = Interval and Interval.Value or 6
            if wait > 0 then
                task.wait(wait)
            end
            if not Storm or not Storm.Enabled then
                break
            end
            if FlashToggle and FlashToggle.Enabled then
                flash()
            end
            if SparksToggle and SparksToggle.Enabled then
                local emitter = ensureSparks()
                if emitter then
                    pcall(function()
                        emitter.Rate = SparksRate and SparksRate.Value or 40
                        if sparksPart and workspace.CurrentCamera then
                            sparksPart.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position + Vector3.new(0, 40, 0))
                        end
                    end)
                end
            end
            if ExplosionToggle and ExplosionToggle.Enabled then
                explosion()
            end
            thunder()
        end
        clearSparks()
    end
    Storm = __worldStub({
        Name = 'Storm',
        Function = function(callback)
            if callback then
                originalBrightness = Lighting.Brightness
                thread = task.spawn(cycle)
                Storm:Clean(thread)
            else
                clearSparks()
                if light then
                    pcall(function()
                        light:Destroy()
                    end)
                    light = nil
                end
                if originalBrightness ~= nil then
                    pcall(function()
                        Lighting.Brightness = originalBrightness
                    end)
                    originalBrightness = nil
                end
            end
        end
    })
    FlashToggle = Storm:AddToggle({Name = 'Lightning Flash', Default = true})
    FlashIntensity = Storm:AddSlider({Name = 'Flash Intensity', Min = 0.5, Max = 8, Default = 2.5, Decimal = 10, Darker = true})
    ThunderToggle = Storm:AddToggle({Name = 'Thunder Sound', Default = true})
    ThunderVolume = Storm:AddSlider({Name = 'Thunder Volume', Min = 0, Max = 1, Default = 0.4, Decimal = 100, Darker = true})
    ThunderDelay = Storm:AddSlider({Name = 'Thunder Delay', Min = 0, Max = 5, Default = 1, Decimal = 10, Darker = true})
    Interval = Storm:AddSlider({Name = 'Interval', Min = 1, Max = 30, Default = 6, Decimal = 1, Darker = true})
    SparksToggle = Storm:AddToggle({Name = 'Sparks'})
    SparksRate = Storm:AddSlider({Name = 'Spark Rate', Min = 5, Max = 300, Default = 40, Decimal = 1, Darker = true})
    ExplosionToggle = Storm:AddToggle({Name = 'Flash Burst'})
end)
    akiraMark("block35:done")
    akiraMark("block36:start")
run(function()
    local ColorGrading
    local GradingToggle
    local Saturation
    local Contrast
    local Brightness
    local Tint
    local effect
    local function apply()
        if not effect then
            return
        end
        effect.Saturation = Saturation and Saturation.Value or 0
        effect.Contrast = Contrast and Contrast.Value or 0
        effect.Brightness = Brightness and Brightness.Value or 0
        effect.TintColor = Tint and Tint.Value or Color3.fromRGB(255, 255, 255)
    end
    ColorGrading = __worldStub({
        Name = 'Color Grading',
        Function = function(callback)
            if not callback then
                if effect then
                    pcall(function()
                        effect:Destroy()
                    end)
                    effect = nil
                end
                return
            end
            if not effect then
                local ok, created = pcall(function()
                    local instance = Instance.new("ColorCorrectionEffect")
                    instance.Name = "AkiraColorGrading"
                    instance.Parent = Lighting
                    return instance
                end)
                if ok then
                    effect = created
                end
            end
            apply()
        end
    })
    GradingToggle = ColorGrading:AddToggle({Name = 'Enabled', Default = true, Function = function(callback)
        if not callback and effect then
            pcall(function()
                effect.Enabled = false
            end)
        elseif callback and effect then
            pcall(function()
                effect.Enabled = true
            end)
        end
    end})
    Saturation = ColorGrading:AddSlider({Name = 'Saturation', Min = -1, Max = 1, Default = 0.1, Decimal = 100, Function = apply})
    Contrast = ColorGrading:AddSlider({Name = 'Contrast', Min = -1, Max = 1, Default = 0.05, Decimal = 100, Darker = true, Function = apply})
    Brightness = ColorGrading:AddSlider({Name = 'Brightness', Min = -1, Max = 1, Default = 0, Decimal = 100, Darker = true, Function = apply})
    Tint = ColorGrading:AddColorPicker({Name = 'Tint', Default = Color3.fromRGB(255, 255, 255), Darker = true, Function = apply})
end)
    akiraMark("block36:done")
    akiraMark("block37:start")
run(function()
    local AutoRespawn
    local respawning
    AutoRespawn = AkiraLite.Catalogs.Player:AddModule({
        Name = 'Auto Respawn',
        Function = function(callback)
            if callback then
                AutoRespawn:Clean(lplr.CharacterAdded:Connect(function()
                    if not respawning then
                        return
                    end
                    respawning = false
                end))
                AutoRespawn:Clean(entitylib.Events.LocalRemoved:Connect(function()
                    if not respawning or not AutoRespawn.Enabled then
                        return
                    end
                    respawning = true
                    task.delay(0.35, function()
                        if respawning and lplr and lplr.Character == nil then
                            pcall(function()
                                lplr:LoadCharacter()
                            end)
                        end
                    end)
                end))
            else
                respawning = false
            end
        end
    })
end)
    akiraMark("block37:done")
    akiraMark("block38:start")
run(function()
    local Automation
    local AutoQueue
    local QueueDelay
    local QueueRemote
    local AutoVote
    local AutoLoadout
    local LoadoutPriority
    local AutoPickup
    local PickupRange
    local Status
    local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
    local VirtualInputManager
    pcall(function()
        VirtualInputManager = cloneref(game:GetService('VirtualInputManager'))
    end)
    local loadoutOrder = {}
    local pickupKeys = {}
    local function parseList(value, fallback)
        local result = {}
        for entry in string.gmatch(tostring(value or ''), '[^,%s]+') do
            local trimmed = string.match(entry, '^%s*(.-)%s*$')
            if #trimmed > 0 then
                table.insert(result, string.lower(trimmed))
            end
        end
        if #result == 0 then
            return fallback
        end
        return result
    end
    loadoutOrder = parseList('ak47, m4, scar, ak74, famas, glock, mp5, mpx, ump, vector, deagle, revolver, bow, sword, katana, scythe, grenade, shield', loadoutOrder)
    pickupKeys = parseList('heal, health, medkit, energy, inhaler, armor, ammo, kit', pickupKeys)
    local remoteCache = {at = 0, list = nil, byName = {}}
    local function collectRemotes()
        local now = os.clock()
        if remoteCache.list and (now - remoteCache.at) < 15 then
            return remoteCache
        end
        local list = {}
        for _, instance in ipairs(ReplicatedStorage:GetDescendants()) do
            if instance:IsA('RemoteEvent') or instance:IsA('RemoteFunction') then
                list[#list + 1] = instance
            end
        end
        remoteCache = {at = now, list = list, byName = {}}
        return remoteCache
    end
    local function findRemote(override, patterns)
        if type(override) == 'string' and #override > 0 then
            local exact = ReplicatedStorage:FindFirstChild(override, true)
            if exact and (exact:IsA('RemoteEvent') or exact:IsA('RemoteFunction')) then
                return exact
            end
        end
        local cache = collectRemotes()
        for _, pattern in ipairs(patterns) do
            local lowered = string.lower(pattern)
            if cache.byName[lowered] and cache.byName[lowered].Parent then
                return cache.byName[lowered]
            end
            for _, instance in ipairs(cache.list) do
                if instance.Parent and string.find(string.lower(instance.Name), lowered, 1, true) then
                    cache.byName[lowered] = instance
                    return instance
                end
            end
        end
        return nil
    end
    local buttonCache = {at = 0, list = nil}
    local function collectButtons()
        local now = os.clock()
        if buttonCache.list and (now - buttonCache.at) < 2 then
            return buttonCache.list
        end
        local list = {}
        local playerGui = lplr and lplr:FindFirstChildOfClass('PlayerGui')
        if playerGui then
            for _, instance in ipairs(playerGui:GetDescendants()) do
                if (instance:IsA('TextButton') or instance:IsA('ImageButton')) and instance.Visible then
                    list[#list + 1] = instance
                end
            end
        end
        buttonCache = {at = now, list = list}
        return list
    end
    local function clickButton(candidates)
        if not VirtualInputManager then
            return false
        end
        for _, instance in ipairs(collectButtons()) do
            if instance.Parent and instance.Visible then
                local lowered = string.lower(instance.Name)
                for _, candidate in ipairs(candidates) do
                    if string.find(lowered, string.lower(candidate), 1, true) then
                        local fired = pcall(function()
                            local center = instance.AbsolutePosition + instance.AbsoluteSize * 0.5
                            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, 1, true)
                            task.wait(0.04)
                            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, 1, true)
                        end)
                        if fired then
                            return true, instance.Name
                        end
                    end
                end
            end
        end
        return false
    end
    local function setStatus(text)
        if Status and type(Status.Set) == 'function' then
            Status:Set(text)
        end
    end
    local function tryQueue()
        local remote = findRemote(QueueRemote and QueueRemote.Value, {'queue', 'joinmatch', 'findmatch', 'startmatch', 'playgame', 'requestgame', 'leavequeue'})
        if remote then
            local name = remote.Name
            if remote:IsA('RemoteFunction') then
                pcall(function()
                    remote:InvokeServer()
                end)
            else
                pcall(function()
                    remote:FireServer()
                end)
            end
            setStatus('Queue remote: ' .. name)
            return true
        end
        local clicked, label = clickButton({'play', 'queue', 'find match', 'findmatch', 'join game', 'start'})
        if clicked then
            setStatus('Queue button: ' .. label)
            return true
        end
        setStatus('No queue remote or button found')
        return false
    end
    local function tryVote()
        local clicked, label = clickButton({'yes', 'confirm', 'accept', 'agree', 'continue', 'vote'})
        if clicked then
            setStatus('Vote handled: ' .. label)
            return true
        end
        return false
    end
    local function equipBestTool()
        local character = entitylib and entitylib.character
        local humanoid = character and character:FindFirstChildOfClass('Humanoid')
        if not humanoid then
            return false
        end
        local backpack = lplr and lplr:FindFirstChildOfClass('Backpack')
        if not backpack then
            return false
        end
        local function priority(tool)
            local lowered = string.lower(tool.Name)
            for index, entry in ipairs(loadoutOrder) do
                if string.find(lowered, entry, 1, true) then
                    return index
                end
            end
            return #loadoutOrder + 1
        end
        local bestTool
        local bestPriority
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA('Tool') then
                local current = priority(tool)
                if not bestPriority or current < bestPriority then
                    bestTool = tool
                    bestPriority = current
                end
            end
        end
        if not bestTool or not bestTool.Parent then
            return false
        end
        local equipped = character:FindFirstChildOfClass('Tool')
        if equipped == bestTool then
            return true
        end
        if equipped and priority(equipped) <= bestPriority then
            return true
        end
        humanoid:EquipTool(bestTool)
        setStatus('Equipped ' .. bestTool.Name)
        return true
    end
    local pickupCache = {at = 0, parts = {}}
    local function collectPickupParts()
        local now = os.clock()
        if (now - pickupCache.at) < 3 then
            return pickupCache.parts
        end
        local parts = {}
        for _, instance in ipairs(workspace:GetDescendants()) do
            if instance:IsA('Model') or instance:IsA('BasePart') then
                local lowered = string.lower(instance.Name)
                for _, key in ipairs(pickupKeys) do
                    if string.find(lowered, key, 1, true) then
                        local part = instance
                        if instance:IsA('Model') then
                            part = instance.PrimaryPart or instance:FindFirstChild('Handle') or instance:FindFirstChild('Touched')
                        end
                        if part and part:IsA('BasePart') then
                            parts[#parts + 1] = part
                        end
                        break
                    end
                end
            end
        end
        pickupCache = {at = now, parts = parts}
        return parts
    end
    local function tryPickup()
        local character = entitylib and entitylib.character
        local root = character and character.RootPart
        local humanoid = character and character.Humanoid
        if not root or not humanoid then
            return false
        end
        local range = PickupRange and PickupRange.Value or 60
        local bestPart
        local bestDistance
        for _, part in ipairs(collectPickupParts()) do
            if part.Parent then
                local distance = (part.Position - root.Position).Magnitude
                if distance <= range and (not bestDistance or distance < bestDistance) then
                    bestPart = part
                    bestDistance = distance
                end
            end
        end
        if bestPart and bestDistance and bestDistance > 2 then
            pcall(function()
                humanoid:MoveTo(bestPart.Position)
            end)
            return true
        end
        return false
    end
    Automation = AkiraLite.Catalogs.Other:AddModule({
        Name = 'Game Automation',
        Function = function(callback)
            if callback then
                local nextQueue = 0
                local nextPickup = 0
                local nextVote = 0
                Automation:Clean(task.spawn(function()
                    while Automation.Enabled do
                        if AutoQueue and AutoQueue.Enabled and os.clock() >= nextQueue then
                            nextQueue = os.clock() + (QueueDelay and QueueDelay.Value or 8)
                            pcall(tryQueue)
                        end
                        if AutoVote and AutoVote.Enabled and os.clock() >= nextVote then
                            nextVote = os.clock() + 1.5
                            pcall(tryVote)
                        end
                        if AutoLoadout and AutoLoadout.Enabled then
                            pcall(equipBestTool)
                        end
                        if AutoPickup and AutoPickup.Enabled and os.clock() >= nextPickup then
                            nextPickup = os.clock() + 1.5
                            pcall(tryPickup)
                        end
                        task.wait(0.5)
                    end
                end))
            end
        end
    })
    Status = Automation:AddLabel({Name = 'Status', Default = 'Idle', Darker = true})
    AutoQueue = Automation:AddToggle({Name = 'Auto Queue', Darker = true})
    QueueDelay = Automation:AddSlider({Name = 'Queue Interval', Min = 2, Max = 60, Default = 8, Decimal = 1, Darker = true})
    QueueRemote = Automation:AddTextInput({Name = 'Queue Remote', Default = '', MaxLength = 64, Placeholder = 'optional remote name', Darker = true})
    AutoVote = Automation:AddToggle({Name = 'Auto Vote', Darker = true})
    AutoLoadout = Automation:AddToggle({Name = 'Auto Loadout', Darker = true})
    LoadoutPriority = Automation:AddTextInput({
        Name = 'Loadout Priority',
        Default = 'ak47, m4, scar, ak74, famas, glock, mp5, mpx, ump, vector, deagle, revolver, bow, sword, katana, scythe, grenade, shield',
        MaxLength = 512,
        Function = function(value)
            loadoutOrder = parseList(value, loadoutOrder)
        end,
        Darker = true
    })
    AutoPickup = Automation:AddToggle({Name = 'Auto Pickup', Darker = true})
    PickupRange = Automation:AddSlider({Name = 'Pickup Range', Min = 5, Max = 200, Default = 60, Decimal = 1, Darker = true})
end)
    akiraMark("block38:done")
    akiraMark("block39:start")
run(function()
    local Spoof
    local SpoofType
    local Spam
    local SpamRate
    local Status
    local ControlsMap = {
        Desktop = 'MouseKeyboard',
        Mobile = 'Touch',
        Console = 'Gamepad',
        VR = 'VR'
    }
    local SpamList = {'Desktop', 'Mobile', 'Console', 'VR'}
    local state = {
        Hook = nil,
        Controller = nil,
        SpamDevice = nil,
        LastDevice = nil
    }
    local function setStatus(text)
        if Status and type(Status.Set) == 'function' then
            Status:Set(text)
        end
    end
    local function attributeGuard()
        local env = (type(getgenv) == 'function' and getgenv()) or _G
        local setAttributes = env.LPH_ATTRIBUTES
        local none = env.VM and env.VM.NONE
        if type(setAttributes) == 'function' and none ~= nil then
            pcall(setAttributes, none)
        end
    end
    local function resolveControlsController()
        if state.Controller then
            return state.Controller
        end
        local playerScripts = lplr and lplr:FindFirstChild('PlayerScripts')
        local controllers = playerScripts and playerScripts:FindFirstChild('Controllers')
        local module = controllers and controllers:FindFirstChild('ControlsController')
        if not module then
            return nil
        end
        local ok, controller = pcall(require, module)
        if ok and type(controller) == 'table' then
            state.Controller = controller
            return state.Controller
        end
        return nil
    end
    local function resolveReplicateControls()
        local fighter = akiraGetLocalFighter()
        if type(fighter) ~= 'table' then
            return nil, nil
        end
        local meta = getmetatable(fighter)
        local classIndex = type(meta) == 'table' and rawget(meta, '__index') or nil
        local replicate = type(classIndex) == 'table' and rawget(classIndex, '_ReplicateControls') or nil
        if type(replicate) ~= 'function' then
            return nil, fighter
        end
        return replicate, fighter
    end
    local function readSpoofType()
        if type(state.SpamDevice) == 'string' then
            return state.SpamDevice
        end
        if SpoofType and type(SpoofType.Value) == 'string' then
            return SpoofType.Value
        end
        return 'VR'
    end
    local function forceReplicate()
        local replicate, fighter = resolveReplicateControls()
        if replicate and fighter then
            pcall(replicate, fighter)
        end
    end
    local function installHook()
        if state.Hook then
            return true
        end
        if type(debug) ~= 'table' or type(debug.getupvalues) ~= 'function' or type(debug.setupvalue) ~= 'function' then
            setStatus('Executor has no debug.setupvalue')
            return false
        end
        local controller = resolveControlsController()
        if type(controller) ~= 'table' then
            return false
        end
        local replicate = resolveReplicateControls()
        if type(replicate) ~= 'function' then
            return false
        end
        local upvalueIndex
        for index, value in pairs(debug.getupvalues(replicate)) do
            if value == controller then
                upvalueIndex = index
                break
            end
        end
        if upvalueIndex == nil then
            return false
        end
        local original = debug.getupvalue(replicate, upvalueIndex)
        local proxy = setmetatable({}, {
            __index = function(_, key)
                attributeGuard()
                if key ~= 'CurrentControls' then
                    if type(original) == 'table' then
                        local fallback = original[key]
                        if fallback ~= nil then
                            return fallback
                        end
                    end
                    return nil
                end
                return ControlsMap[readSpoofType()] or ControlsMap.VR
            end
        })
        debug.setupvalue(replicate, upvalueIndex, proxy)
        state.Hook = {
            Getter = replicate,
            UpvalueIndex = upvalueIndex,
            Original = original
        }
        return true
    end
    local function removeHook()
        local hook = state.Hook
        if not hook then
            return
        end
        state.Hook = nil
        state.LastDevice = nil
        pcall(debug.setupvalue, hook.Getter, hook.UpvalueIndex, hook.Original)
    end
    local function refresh()
        if not Spoof or not Spoof.Enabled then
            return
        end
        if installHook() then
            forceReplicate()
            state.LastDevice = readSpoofType()
            setStatus('Reporting as ' .. tostring(ControlsMap[readSpoofType()] or ControlsMap.VR))
        else
            setStatus('Waiting for game controllers')
        end
    end
    Spoof = AkiraLite.Catalogs.Player:AddModule({
        Name = 'Device Spoof',
        Function = function(callback)
            if callback then
                state.SpamDevice = nil
                Spoof:Clean(task.spawn(function()
                    local nextSpam = 0
                    while Spoof.Enabled do
                        if Spam and Spam.Enabled then
                            if os.clock() >= nextSpam then
                                nextSpam = os.clock() + math.max(SpamRate and SpamRate.Value or 1, 0.1)
                                state.SpamDevice = SpamList[math.random(1, #SpamList)]
                                refresh()
                            end
                        else
                            state.SpamDevice = nil
                            local device = readSpoofType()
                            if state.Hook and state.LastDevice ~= device then
                                refresh()
                            elseif not state.Hook then
                                refresh()
                            end
                        end
                        task.wait(0.4)
                    end
                end))
            else
                state.SpamDevice = nil
                removeHook()
                forceReplicate()
                setStatus('Disabled')
            end
        end
    })
    Status = Spoof:AddLabel({Name = 'Device Status', Default = 'Disabled', Darker = true})
    SpoofType = Spoof:AddDropdown({
        Name = 'Spoof Type',
        List = {'VR', 'Desktop', 'Mobile', 'Console'},
        Default = 'VR',
        Function = function()
            state.SpamDevice = nil
            refresh()
        end,
        Darker = true
    })
    Spam = Spoof:AddToggle({
        Name = 'Device Spam',
        Function = function()
            state.SpamDevice = nil
            refresh()
        end,
        Darker = true
    })
    SpamRate = Spoof:AddSlider({Name = 'Spam Rate', Min = 0.1, Max = 5, Default = 1, Decimal = 10, Darker = true})
end)
    akiraMark("block39:done")
if type(AkiraLite.Commit) == "function" then
    pcall(function()
        return AkiraLite:Commit()
    end)
end
AkiraLite.UniversalStatus = featureStatus
return featureStatus
