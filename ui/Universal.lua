                                                                     
local AkiraLite = shared.AkiraLite
if type(AkiraLite.Targets) ~= "table" then
    AkiraLite.Targets = {}
end
if type(AkiraLite.Rage) ~= "table" then
    AkiraLite.Rage = {}
end
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
            local equipped = fighter.EquippedItem
            if type(equipped) == "table" then
                local viewModel = rawget(equipped, "ViewModel")
                local modelName = ""
                if type(viewModel) == "table" then
                    modelName = tostring(rawget(viewModel, "Name") or "")
                elseif typeof(viewModel) == "Instance" then
                    modelName = viewModel.Name
                end
                if modelName:lower():find("katana", 1, true) then
                                                                                   
                                                                                 
                                                                     
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
                       
   
                                                                                 
                                                                             
                                                                                 
                                                                                 
                     
local _immuneCache = {}
local _invincibilityState = {}
local _invincibilityWatched = {}
local IMMUNE_SCAN_INTERVAL = 0.25

local function attributeSaysImmune(instance)
                                                                                 
                                                                              
                                                       
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
                    local equipped = fighter.EquippedItem
                    if type(equipped) == "table" and scanImmuneFields(equipped, 0) then
                        value = true
                    end
                end
                                                                                
                                                                                 
                                                                             
                                                                              
                                                                                    
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

AKIRA_EPOCH = (tonumber(rawget(shared, "__akiraEpoch")) or 0) + 1
shared.__akiraEpoch = AKIRA_EPOCH
getgenv().__akiraEpoch = AKIRA_EPOCH
shared.__akiraRagebotHandle = nil
shared.__akiraSilentAimHandle = nil

local AkiraLiteFile = shared.AkiraLiteFile
local entitylib = AkiraLiteFile.loadfile("AkiraLite/Library/Entity.lua")
local prediction = AkiraLiteFile.loadfile("AkiraLite/Library/Prediction.lua")
                                                                            
                   
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
local function setThreadIdentity(identity)
    pcall(function()
        return setthreadidentity(identity)
    end)
end

local akiraRagebotRef = nil
local akiraSilentAimRef = nil

local akiraSanitizeAt = 0
local akiraPerfWatchEnabled = false
local AKIRA_TARGET_SOURCES = { "AimAssist" }
local AKIRA_SETTINGS_VERSION = 4
local function akiraSanitizeConfig()
    if os.clock() < akiraSanitizeAt then return end
    akiraSanitizeAt = os.clock() + 1
    local cfg = getgenv().Config
    if type(cfg) ~= "table" then return end
    for key, value in pairs(cfg) do
        if type(value) == "number" and value ~= value then
            cfg[key] = nil
        end
    end
end

local function akiraNum(value, fallback)
    if type(value) ~= "number" then return fallback end
    if value ~= value then return fallback end
    if value == math.huge or value == -math.huge then return fallback end
    return value
end

local akiraNameTagFont = uipaletteFont
if type(akiraNameTagFont) ~= "Font" then
    akiraNameTagFont = Font.new(
        "rbxasset://fonts/families/SourceSansPro.json",
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    uipaletteFont = akiraNameTagFont
end
run(function()
    AkiraLite:Clean(entitylib.Events.LocalAdded:Connect(updateVelocity))
    AkiraLite:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
        gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
    end))
end)
    akiraMark("block1:done")
                                                                                  
         
   
                               
                                                                                  
                                                                 
                                                                    
                                                                              
                                                                                
                   
                                                                               
                                                                                
                                                                            
local AKIRA_VM_OFFSET = {x = 0, y = 0, z = 0, written = nil, parts = nil, partsModel = nil, factor = nil, factorModel = nil, hooked = setmetatable({}, {__mode = "k"})}
        local AKIRA_SKIN = {
            Ready = false,
            Weapons = {},
            WeaponOrder = {},
            Skins = {},
            Wraps = {},
            Charms = {},
            Finishers = {},
            Selection = {},
            AssetNames = {},
            WeaponAssets = {},
            OwnedWeapons = nil,
            OwnedOnly = false,
            LastUsedWeapon = nil,
            VmHooked = false,
            VmOriginal = nil,
            FinisherHooked = false,
            FinisherOriginal = nil,
            VmFolder = nil,
            CreateHooked = false,
            CreateOriginal = nil,
            Item = nil,
            OwnHooked = false,
            OwnOriginal = nil,
            Built = false,
        }
        shared.__akiraSkin = nil
        shared.__akiraSkin = AKIRA_SKIN
        getgenv().__akiraSkin = AKIRA_SKIN

        local function akiraSkinPlayer()
            local ok, svc = pcall(function() return game:GetService("Players") end)
            return ok and svc.LocalPlayer or nil
        end

        local function akiraSkinReplicated()
            local ok, svc = pcall(function() return game:GetService("ReplicatedStorage") end)
            return ok and svc or nil
        end

        local function akiraSkinModules()
            local okCL, CL = pcall(function() return require(akiraSkinReplicated().Modules.CosmeticLibrary) end)
            local okIL, IL = pcall(function() return require(akiraSkinReplicated().Modules.ItemLibrary) end)
            if not okCL or not okIL then return nil end
            return CL, IL
        end

        local function akiraSkinViewModels()
            local plr = akiraSkinPlayer()
            local ps = plr and plr:FindFirstChild("PlayerScripts")
            local assets = ps and ps:FindFirstChild("Assets")
            return assets and assets:FindFirstChild("ViewModels") or nil
        end

        local function akiraSkinCollectAssets(vms)
            local set = {}
            local function walk(node)
                for _, child in ipairs(node:GetChildren()) do
                    if child:IsA("Model") then
                        set[child.Name] = true
                        walk(child)
                    elseif child:IsA("Folder") then
                        walk(child)
                    end
                end
            end
            walk(vms)
            return set
        end

        function AKIRA_SKIN.BuildIndex()
            local CL, IL = akiraSkinModules()
            if not CL then return false end
            local vms = akiraSkinViewModels()
            if not vms then return false end
            AKIRA_SKIN.AssetNames = akiraSkinCollectAssets(vms)
            AKIRA_SKIN.Weapons = {}
            AKIRA_SKIN.WeaponOrder = {}
            local weaponsFolder = vms:FindFirstChild("Weapons")
            if weaponsFolder then
                for _, child in ipairs(weaponsFolder:GetChildren()) do
                    if child:IsA("Model") then
                        AKIRA_SKIN.Weapons[child.Name] = true
                        AKIRA_SKIN.WeaponAssets[child.Name] = true
                        AKIRA_SKIN.WeaponOrder[#AKIRA_SKIN.WeaponOrder + 1] = child.Name
                    end
                end
            end
            if #AKIRA_SKIN.WeaponOrder == 0 and IL and IL.Items then
                for name in pairs(IL.Items) do
                    if type(name) == "string" then
                        AKIRA_SKIN.Weapons[name] = true
                        AKIRA_SKIN.WeaponOrder[#AKIRA_SKIN.WeaponOrder + 1] = name
                    end
                end
            end
            AKIRA_SKIN.WeaponIcons = AKIRA_SKIN.WeaponIcons or {}
            if IL and IL.Items then
                for _, weaponName in ipairs(AKIRA_SKIN.WeaponOrder) do
                    local entry = IL.Items[weaponName]
                    if type(entry) == "table" and entry.Image then
                        AKIRA_SKIN.WeaponIcons[weaponName] = entry.Image
                    end
                end
            end
            table.sort(AKIRA_SKIN.WeaponOrder)
            local skins, wraps, charms, finishers = {}, {}, {}, {}
            for name, entry in pairs(CL.Cosmetics or {}) do
                local kind = type(entry) == "table" and entry.Type or nil
                local rec = {Name = name, Rarity = (type(entry) == "table" and entry.Rarity) or "Common"}
                do
                    local okImg, img = pcall(function()
                        local vmInfo = IL and IL.ViewModels and IL.ViewModels[name]
                        if vmInfo and vmInfo.Image then return vmInfo.Image end
                        if type(entry) == "table" and entry.Image then return entry.Image end
                        return nil
                    end)
                    if okImg then rec.Image = img end
                end
                if kind == "Skin" then
                    local weaponName = entry.ItemName
                    if weaponName and AKIRA_SKIN.Weapons[weaponName] then
                        local combined = name .. " " .. weaponName
                        if AKIRA_SKIN.AssetNames[combined] then
                            rec.Asset = combined
                            rec.WeaponName = weaponName
                        elseif AKIRA_SKIN.AssetNames[name] and not AKIRA_SKIN.WeaponAssets[name] then
                            rec.Asset = name
                            rec.WeaponName = weaponName
                        end
                    elseif not weaponName and AKIRA_SKIN.AssetNames[name] then
                        rec.Asset = name
                        rec.Universal = true
                    end
                    if rec.Asset then skins[#skins+1] = rec end
                elseif kind == "Wrap" then
                    wraps[#wraps+1] = rec
                elseif kind == "Charm" then
                    charms[#charms+1] = rec
                elseif kind == "Finisher" then
                    finishers[#finishers+1] = rec
                end
            end
            local function byName(a, b) return a.Name:lower() < b.Name:lower() end
            table.sort(skins, byName)
            table.sort(wraps, byName)
            table.sort(charms, byName)
            table.sort(finishers, byName)
            AKIRA_SKIN.Skins = skins
            AKIRA_SKIN.Wraps = wraps
            AKIRA_SKIN.Charms = charms
            AKIRA_SKIN.Finishers = finishers
            AKIRA_SKIN.Built = true
            return true
        end

        function AKIRA_SKIN.SkinsForWeapon(weaponName)
            local out = {}
            for _, rec in ipairs(AKIRA_SKIN.Skins) do
                if rec.WeaponName == weaponName or rec.Universal then out[#out+1] = rec end
            end
            return out
        end

        function AKIRA_SKIN.RefreshOwned()
            local CL = akiraSkinModules()
            local owned = {}
            local ok, DC = pcall(function()
                return require(akiraSkinPlayer().PlayerScripts.Controllers.PlayerDataController)
            end)
            if ok and type(DC) == "table" and CL then
                local data = DC.CurrentData and DC.CurrentData.Data
                local inventory = data and data.CosmeticInventory
                if type(inventory) == "table" then
                    for cosmeticName in pairs(inventory) do
                        local entry = CL.Cosmetics[cosmeticName]
                        local weaponName = type(entry) == "table" and entry.ItemName or nil
                        if type(weaponName) == "string" and AKIRA_SKIN.Weapons[weaponName] then
                            owned[weaponName] = true
                        end
                    end
                end
            end
            local okFC, FC = pcall(function()
                return require(akiraSkinPlayer().PlayerScripts.Controllers.FighterController)
            end)
            if okFC and type(FC) == "table" then
                local items = FC.LocalFighter and FC.LocalFighter.Items
                if type(items) == "table" then
                    for key, value in pairs(items) do
                        local nm = type(key) == "string" and key or (type(value) == "table" and value.Name or nil)
                        if type(nm) == "string" and AKIRA_SKIN.Weapons[nm] then owned[nm] = true end
                    end
                end
            end
            AKIRA_SKIN.OwnedWeapons = owned
            local n = 0
            for _ in pairs(owned) do n = n + 1 end
            return n
        end

        function AKIRA_SKIN.VisibleWeapons()
            local out = {}
            for _, name in ipairs(AKIRA_SKIN.WeaponOrder) do
                if not (AKIRA_SKIN.OwnedOnly and AKIRA_SKIN.OwnedWeapons and not AKIRA_SKIN.OwnedWeapons[name]) then
                    out[#out+1] = name
                end
            end
            return out
        end

        function AKIRA_SKIN.AssetForWeapon(weaponName)
            local entry = AKIRA_SKIN.Selection[weaponName]
            if not entry or not entry.Skin then return nil end
            for _, rec in ipairs(AKIRA_SKIN.Skins) do
                if rec.Name == entry.Skin and (rec.WeaponName == weaponName or rec.Universal) then
                    return rec.Asset
                end
            end
            return nil
        end

        function AKIRA_SKIN.CharmAsset(charmName)
            if type(charmName) ~= "string" or charmName == "" then return nil end
            local plr = akiraSkinPlayer()
            local ps = plr and plr:FindFirstChild("PlayerScripts")
            local assets = ps and ps:FindFirstChild("Assets")
            local charms = assets and assets:FindFirstChild("Charms")
            return charms and charms:FindFirstChild(charmName, true) or nil
        end

        function AKIRA_SKIN.FinisherRig(finisherName)
            if type(finisherName) ~= "string" or finisherName == "" then return nil end
            local mods = akiraSkinReplicated().Modules
            local rigs = mods and mods:FindFirstChild("Finishers")
            return rigs and rigs:FindFirstChild(finisherName) or nil
        end

        function AKIRA_SKIN.ApplyExtras(vm, weaponName)
            if type(vm) ~= "table" or type(weaponName) ~= "string" then return false end
            local entry = AKIRA_SKIN.Selection[weaponName]
            if not entry then return false end
            if entry.Charm and type(vm.SetCharm) == "function" then
                local asset = AKIRA_SKIN.CharmAsset(entry.Charm)
                if asset then pcall(function() vm:SetCharm(asset) end) end
            end
            if entry.Wrap and type(vm.SetWrap) == "function" then
                pcall(function()
                    vm:SetWrap({Name = entry.Wrap, Type = "Wrap", Inverted = not not entry.WrapInverted})
                end)
            end
            return true
        end

        function AKIRA_SKIN.ViewModelFolder()
            if AKIRA_SKIN.VmFolder ~= nil and AKIRA_SKIN.VmFolder.Parent ~= nil then
                return AKIRA_SKIN.VmFolder
            end
            local ok, ws = pcall(function() return game:GetService("Workspace") end)
            if not ok or ws == nil then return nil end
            local direct = ws:FindFirstChild("ViewModels")
            if direct then
                return direct:FindFirstChild("FirstPerson") or direct
            end
            for _, descendant in ipairs(ws:GetDescendants()) do
                if descendant.Name == "ViewModels" then
                    return descendant:FindFirstChild("FirstPerson") or descendant
                end
            end
            local item = AKIRA_SKIN.Item
            local model = type(item) == "table" and type(item.ViewModel) == "table" and item.ViewModel.Model or nil
            if model ~= nil then
                local node = model.Parent
                while node and node ~= ws do
                    if node.Name == "FirstPerson" or node.Name == "ViewModels" then
                        return node
                    end
                    node = node.Parent
                end
            end
            return nil
        end

        function AKIRA_SKIN.ApplyToEquipped(weaponName)
            AKIRA_SKIN.ApplyStage = "start"
        shared.__akiraApplyStage = AKIRA_SKIN.ApplyStage
            if type(weaponName) ~= "string" or weaponName == "" then
                AKIRA_SKIN.ApplyStage = "bad-name"
                return false
            end
            local item = AKIRA_SKIN.Item
            if type(item) ~= "table" or item.Name ~= weaponName then
                local okFC, FC = pcall(function()
                    return require(akiraSkinPlayer().PlayerScripts.Controllers.FighterController)
                end)
                AKIRA_SKIN.ApplyStage = "controller-require-ok=" .. tostring(okFC)
                if okFC and type(FC) == "table" then
                    local candidate = FC.LocalFighter and FC.LocalFighter.EquippedItem
                    if type(candidate) == "table" then
                        item = candidate
                        AKIRA_SKIN.Item = candidate
                    end
                end
            end
            if type(item) ~= "table" or item.Name ~= weaponName then
                AKIRA_SKIN.ApplyStage = "no-item"
                return false
            end
            AKIRA_SKIN.ApplyStage = "have-item"
            local okSVM, SVM = pcall(function()
                return require(akiraSkinPlayer().PlayerScripts.Modules.StaticModel.StaticViewModel)
            end)
            if not okSVM or type(SVM) ~= "table" or type(SVM.new) ~= "function" then
                AKIRA_SKIN.ApplyStage = "no-svm"
                return false
            end
            AKIRA_SKIN.ApplyStage = "have-svm"
            local oldModel = nil
            if type(item.ViewModel) == "table" then oldModel = item.ViewModel.Model end
            local folder = AKIRA_SKIN.ViewModelFolder()
            if folder == nil and oldModel ~= nil then
                local node = oldModel.Parent
                while node do
                    if node.Name == "FirstPerson" or node.Name == "ViewModels" then
                        folder = node
                        AKIRA_SKIN.VmFolder = node
                        break
                    end
                    node = node.Parent
                end
            end
            AKIRA_SKIN.ApplyStage = "folder=" .. tostring(folder ~= nil)
            local okBuild, built = pcall(function() return SVM.new(weaponName) end)
            if not okBuild or type(built) ~= "table" then
                AKIRA_SKIN.ApplyStage = "build-failed: " .. tostring(built)
                return false
            end
            AKIRA_SKIN.ApplyStage = "built=" .. tostring(built.Name)
            if built.Model and built.Model.Parent == nil and folder ~= nil then
                built.Model.Parent = folder
            end
            item.ViewModel = built
            AKIRA_SKIN.ApplyStage = "assigned"
            pcall(function() AKIRA_SKIN.ApplyExtras(built, weaponName) end)
            if oldModel ~= nil and oldModel ~= built.Model then
                task.defer(function()
                    pcall(function() oldModel:Destroy() end)
                end)
            end
            AKIRA_SKIN.ApplyStage = "done"
            return true
        end

        function AKIRA_SKIN.SetCosmetic(weaponName, kind, cosmeticName)
            if type(weaponName) ~= "string" or weaponName == "" then return false end
            local entry = AKIRA_SKIN.Selection[weaponName]
            if not entry then
                entry = {}
                AKIRA_SKIN.Selection[weaponName] = entry
            end
            if cosmeticName == nil or cosmeticName == "" or cosmeticName == "None" then
                entry[kind] = nil
            else
                entry[kind] = cosmeticName
            end
            AKIRA_SKIN.Save()
            return true
        end

        function AKIRA_SKIN.EquippedWeaponName()
            local item = AKIRA_SKIN.Item
            if type(item) == "table" and type(item.Name) == "string" and item.Name ~= "" then
                return item.Name
            end
            local okFC, FC = pcall(function()
                return require(akiraSkinPlayer().PlayerScripts.Controllers.FighterController)
            end)
            if okFC and type(FC) == "table" then
                local candidate = FC.LocalFighter and FC.LocalFighter.EquippedItem
                if type(candidate) == "table" and type(candidate.Name) == "string" then
                    AKIRA_SKIN.Item = candidate
                    return candidate.Name
                end
            end
            return nil
        end

        function AKIRA_SKIN.RandomizeWeapon(weaponName)
            if type(weaponName) ~= "string" or weaponName == "" then return false end
            local skins = AKIRA_SKIN.SkinsForWeapon(weaponName)
            if #skins == 0 then
                AKIRA_SKIN.Selection[weaponName] = nil
                return false
            end
            local entry = AKIRA_SKIN.Selection[weaponName] or {}
            entry.Skin = skins[math.random(1, #skins)].Name
            if #AKIRA_SKIN.Wraps > 0 then entry.Wrap = AKIRA_SKIN.Wraps[math.random(1, #AKIRA_SKIN.Wraps)].Name end
            if #AKIRA_SKIN.Charms > 0 then entry.Charm = AKIRA_SKIN.Charms[math.random(1, #AKIRA_SKIN.Charms)].Name end
            if #AKIRA_SKIN.Finishers > 0 then entry.Finisher = AKIRA_SKIN.Finishers[math.random(1, #AKIRA_SKIN.Finishers)].Name end
            AKIRA_SKIN.Selection[weaponName] = entry
            return true
        end

        function AKIRA_SKIN.RandomizeAll()
            local weapons = AKIRA_SKIN.WeaponOrder
            for i = 1, #weapons do
                AKIRA_SKIN.RandomizeWeapon(weapons[i])
                if i % 4 == 0 then task.wait() end
            end
            AKIRA_SKIN.Save()
            return #weapons
        end

        function AKIRA_SKIN.ClearAll()
            AKIRA_SKIN.Selection = {}
            AKIRA_SKIN.Save()
        end

        local AKIRA_SKIN_SAVE = "unlockall/skins.json"

        function AKIRA_SKIN.Save()
            if type(writefile) ~= "function" then return false end
            local payload = {version = 1, weapons = {}}
            for weapon, entry in pairs(AKIRA_SKIN.Selection) do
                payload.weapons[weapon] = {
                    Skin = entry.Skin,
                    Wrap = entry.Wrap,
                    Charm = entry.Charm,
                    Finisher = entry.Finisher,
                }
            end
            pcall(function()
                if type(makefolder) == "function" then pcall(makefolder, "unlockall") end
                writefile(AKIRA_SKIN_SAVE, HttpService:JSONEncode(payload))
            end)
            return true
        end

        function AKIRA_SKIN.Load()
            if type(readfile) ~= "function" or type(isfile) ~= "function" then return 0 end
            if not isfile(AKIRA_SKIN_SAVE) then return 0 end
            local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(AKIRA_SKIN_SAVE)) end)
            if not ok or type(decoded) ~= "table" or type(decoded.weapons) ~= "table" then return 0 end
            local count = 0
            for weapon, entry in pairs(decoded.weapons) do
                if type(weapon) == "string" and type(entry) == "table" then
                    AKIRA_SKIN.Selection[weapon] = {
                        Skin = entry.Skin,
                        Wrap = entry.Wrap,
                        Charm = entry.Charm,
                        Finisher = entry.Finisher,
                    }
                    count = count + 1
                end
            end
            return count
        end

        function AKIRA_SKIN.Chain()
            shared.__akiraSvmChain = shared.__akiraSvmChain or setmetatable({}, {__mode = "k"})
            return shared.__akiraSvmChain
        end

        function AKIRA_SKIN.TrueOriginal()
            local chain = AKIRA_SKIN.Chain()
            local current = AKIRA_SKIN.VmCurrent
            local guard = 0
            while type(current) == "function" and chain[current] ~= nil and guard < 32 do
                current = chain[current]
                guard = guard + 1
            end
            return current
        end

        function AKIRA_SKIN.Install()
            if AKIRA_SKIN.VmHooked then return true end
            local ok, SVM = pcall(function()
                return require(akiraSkinPlayer().PlayerScripts.Modules.StaticModel.StaticViewModel)
            end)
            if not ok or type(SVM) ~= "table" or type(SVM.new) ~= "function" then return false end
            local chain = AKIRA_SKIN.Chain()
            local original = AKIRA_SKIN.TrueOriginal() or SVM.new
            AKIRA_SKIN.VmCurrent = SVM.new
            SVM.new = function(assetName, ...)
                local swap = nil
                if type(assetName) == "string" and AKIRA_SKIN.Weapons[assetName] then
                    AKIRA_SKIN.LastUsedWeapon = assetName
                    swap = AKIRA_SKIN.AssetForWeapon(assetName)
                end
                local built = original(swap or assetName, ...)
                if type(built) == "table" then
                    if built.ClientItem ~= nil and built.ClientItem.Name ~= nil then
                        AKIRA_SKIN.Item = built.ClientItem
                    end
                end
                if type(built) == "table" and built.Model ~= nil then
                    local node = built.Model.Parent
                    while node do
                        if node.Name == "FirstPerson" or node.Name == "ViewModels" then
                            AKIRA_SKIN.VmFolder = node
                            break
                        end
                        node = node.Parent
                    end
                end
                if swap then
                    task.defer(function() pcall(function() AKIRA_SKIN.ApplyExtras(built, assetName) end) end)
                end
                return built
            end
            chain[SVM.new] = original
            AKIRA_SKIN.VmHooked = true
            return true
        end

        function AKIRA_SKIN.InstallOwnership()
            if AKIRA_SKIN.OwnHooked then return true end
            local CL = akiraSkinModules()
            if not CL or type(CL.OwnsCosmetic) ~= "function" then return false end
            local original = CL.OwnsCosmetic
            AKIRA_SKIN.OwnOriginal = original
            CL.OwnsCosmetic = function(self, inventory, name, weapon)
                if type(name) == "string" then
                    if string.find(name, "MISSING_", 1, true) then
                        return original(self, inventory, name, weapon)
                    end
                    if AKIRA_SKIN.WeaponAssets[name] then
                        return original(self, inventory, name, weapon)
                    end
                    if AKIRA_SKIN.AssetNames[name] then
                        return true
                    end
                end
                return original(self, inventory, name, weapon)
            end
            AKIRA_SKIN.OwnHooked = true
            return true
        end

        function AKIRA_SKIN.UninstallOwnership()
            if not AKIRA_SKIN.OwnHooked then return false end
            local CL = akiraSkinModules()
            if CL and AKIRA_SKIN.OwnOriginal then
                CL.OwnsCosmetic = AKIRA_SKIN.OwnOriginal
            end
            AKIRA_SKIN.OwnHooked = false
            AKIRA_SKIN.OwnOriginal = nil
            return true
        end

        function AKIRA_SKIN.CosmeticData(weaponName, kind)
            local entry = AKIRA_SKIN.Selection[weaponName]
            if not entry or not entry[kind] then return nil end
            local CL = akiraSkinModules()
            if not CL then return nil end
            local base = CL.Cosmetics[entry[kind]]
            if not base then return nil end
            local data = {}
            for key, value in pairs(base) do data[key] = value end
            data.Name = entry[kind]
            data.Type = kind
            if data.Seed == nil then data.Seed = 1 end
            if kind == "Wrap" then data.Inverted = not not entry.WrapInverted end
            return data
        end

        function AKIRA_SKIN.InjectRef(self, ref)
            if ref == nil then return end
            local weaponName = self and self.Name
            if type(weaponName) ~= "string" or weaponName == "" then return end
            local skin = AKIRA_SKIN.CosmeticData(weaponName, "Skin")
            if skin == nil then return end
            local okEnum, dataKey, skinKey, nameKey
            pcall(function()
                dataKey = self:ToEnum("Data")
                skinKey = self:ToEnum("Skin")
                nameKey = self:ToEnum("Name")
            end)
            if dataKey ~= nil then
                ref[dataKey] = ref[dataKey] or {}
                if ref[dataKey] ~= nil then
                    ref[dataKey][skinKey] = skin
                    ref[dataKey][nameKey] = skin.Name
                    return
                end
            end
            if ref.Data ~= nil then
                ref.Data.Skin = skin
                ref.Data.Name = skin.Name
            end
        end

        function AKIRA_SKIN.InstallCreateViewModel()
            if AKIRA_SKIN.CreateHooked then return true end
            local ok, CI = pcall(function()
                local base = akiraSkinPlayer().PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter
                return require(base:FindFirstChild("ClientItem"))
            end)
            if not ok or type(CI) ~= "table" or type(CI._CreateViewModel) ~= "function" then return false end
            local chain = AKIRA_SKIN.Chain()
            local original = AKIRA_SKIN.TrueClientOriginal(CI._CreateViewModel) or CI._CreateViewModel
            AKIRA_SKIN.CreateOriginal = original
            CI._CreateViewModel = function(self, ...)
                local args = table.pack(...)
                pcall(function() AKIRA_SKIN.InjectRef(self, args[1]) end)
                return original(self, table.unpack(args, 1, args.n))
            end
            AKIRA_SKIN.CreateHooked = true
            return true
        end

        function AKIRA_SKIN.TrueClientOriginal(current)
            local chain = AKIRA_SKIN.Chain()
            local guard = 0
            while type(current) == "function" and chain[current] ~= nil and guard < 32 do
                current = chain[current]
                guard = guard + 1
            end
            return current
        end

        function AKIRA_SKIN.InstallFinisher()
            if AKIRA_SKIN.FinisherHooked then return true end
            local ok, CE = pcall(function()
                return require(akiraSkinPlayer().PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity)
            end)
            if not ok or type(CE) ~= "table" or type(CE._PlayFinisher) ~= "function" then return false end
            local original = CE._PlayFinisher
            AKIRA_SKIN.FinisherOriginal = original
            CE._PlayFinisher = function(entity, finisherName, a, b, serial)
                local weapon = AKIRA_SKIN.LastUsedWeapon
                local entry = weapon and AKIRA_SKIN.Selection[weapon] or nil
                local chosen = entry and entry.Finisher or nil
                if chosen and AKIRA_SKIN.FinisherRig(chosen) then
                    return original(entity, chosen, a, b, serial)
                end
                return original(entity, finisherName, a, b, serial)
            end
            AKIRA_SKIN.FinisherHooked = true
            return true
        end

local AKIRA_VM_SOURCE = nil
local AKIRA_VM_NOMOTION = false

local installViewModelOffsetHook

local function akiraCurrentViewModel()
    local okCtrl, controller = pcall(function()
        return require(game:GetService("Players").LocalPlayer.PlayerScripts.Controllers.FighterController)
    end)
    if not okCtrl or type(controller) ~= "table" then return nil end
    local fighter = controller.LocalFighter
    local item = fighter and fighter.EquippedItem
    if type(item) ~= "table" then return nil end
    local okVm, vm = pcall(function()
        return item.ViewModel or item._viewModel
    end)
    if not okVm or vm == nil then return nil end
    return vm
end

local function akiraOffsetIsSet()
    return AKIRA_VM_OFFSET.x ~= 0 or AKIRA_VM_OFFSET.y ~= 0 or AKIRA_VM_OFFSET.z ~= 0
end

installViewModelOffsetHook = function()
    local vm = akiraCurrentViewModel()
    if vm == nil then return false end
    local wrapper = AKIRA_VM_OFFSET.hooked[vm]
    if type(wrapper) == "function" and vm.Update == wrapper then return true end
    local original = vm.Update
    if type(original) ~= "function" then return false end
    AKIRA_VM_OFFSET.vm = vm
    AKIRA_VM_OFFSET.written = nil
    AKIRA_VM_OFFSET.parts = nil
    AKIRA_VM_OFFSET.partsModel = nil
    AKIRA_VM_OFFSET.factor = nil
    AKIRA_VM_OFFSET.factorModel = nil
    wrapper = function(...)
        local ox, oy, oz = AKIRA_VM_OFFSET.x, AKIRA_VM_OFFSET.y, AKIRA_VM_OFFSET.z
        local args = table.pack(...)
        if AKIRA_VM_NOMOTION then
            local camData = args[3]
            if type(camData) == "table" then
                camData.MoveSpeed = 0
                camData.MoveVelocity = Vector3.zero
                camData.PlayerVelocity = Vector3.zero
                camData.IsSliding = false
                camData.IsActuallySprinting = false
                camData.IsSprinting = false
            end
        end
        if ox ~= 0 or oy ~= 0 or oz ~= 0 then
            local result = original(table.unpack(args, 1, args.n))
            local model = vm.Model
            if typeof(model) == "Instance" then
                local parts = AKIRA_VM_OFFSET.parts
                if parts == nil or AKIRA_VM_OFFSET.partsModel ~= model then
                    parts = {}
                    local itemVisual = model:FindFirstChild("ItemVisual")
                    if itemVisual then
                        local candidates = {}
                        for _, descendant in ipairs(itemVisual:GetDescendants()) do
                            if descendant:IsA("BasePart") then
                                local partName = string.lower(descendant.Name)
                                if partName ~= "humanoidrootpart" and partName ~= "rootpart" and partName ~= "hitbox" then
                                    candidates[#candidates + 1] = descendant
                                end
                            end
                        end
                        for _, candidate in ipairs(candidates) do
                            local ancestor = candidate.Parent
                            local nested = false
                            while ancestor ~= nil and ancestor ~= itemVisual do
                                if ancestor:IsA("BasePart") then
                                    nested = true
                                    break
                                end
                                ancestor = ancestor.Parent
                            end
                            if not nested then
                                parts[#parts + 1] = candidate
                            end
                        end
                    end
                    AKIRA_VM_OFFSET.parts = parts
                    AKIRA_VM_OFFSET.partsModel = model
                end
                if #parts > 0 then
                    if ox ~= 0 or oy ~= 0 or oz ~= 0 then
                        local cam = workspace.CurrentCamera
                        local basis = cam and cam.CFrame or CFrame.identity
                        local shift = basis.RightVector * ox
                            + basis.UpVector * oy
                            + basis.LookVector * (-oz)
                        for _, part in ipairs(parts) do
                            if part.Parent ~= nil then
                                part.CFrame = part.CFrame + shift
                            end
                        end
                    end
                end
            end
            return result
        end
        return original(table.unpack(args, 1, args.n))
    end
    AKIRA_VM_OFFSET.hooked[vm] = wrapper
    vm.Update = wrapper
    return true
end

local akiraVmRetryAt = 0
run(function()
    local vmService = game:GetService("RunService")
    vmService.Heartbeat:Connect(function()
        if os.clock() < akiraVmRetryAt then return end
        akiraVmRetryAt = os.clock() + 0.15
        local ok, module = pcall(function()
            if type(AkiraLite) ~= "table" or type(AkiraLite.Modules) ~= "table" then return nil end
            return AkiraLite.Modules["Viewmodel"]
        end)
        if not ok or type(module) ~= "table" then return end
        local settings = module.Settings
        if type(settings) ~= "table" then return end
        local toggle = settings["Offset"]
        local sx, sy, sz = settings["Offset X"], settings["Offset Y"], settings["Offset Z"]
        if toggle and toggle.Enabled then
            AKIRA_VM_OFFSET.x = sx and tonumber(sx.Value) or 0
            AKIRA_VM_OFFSET.y = sy and tonumber(sy.Value) or 0
            AKIRA_VM_OFFSET.z = sz and tonumber(sz.Value) or 0
        else
            AKIRA_VM_OFFSET.x = 0
            AKIRA_VM_OFFSET.y = 0
            AKIRA_VM_OFFSET.z = 0
        end
        local installed, result = pcall(installViewModelOffsetHook)
        local state = {
            enabled = not not (toggle and toggle.Enabled),
            sliderX = sx and tostring(sx.Value) or "nil",
            sliderY = sy and tostring(sy.Value) or "nil",
            targetX = AKIRA_VM_OFFSET.x,
            targetY = AKIRA_VM_OFFSET.y,
            targetZ = AKIRA_VM_OFFSET.z,
            installOk = installed,
            installResult = tostring(result),
            vm = tostring(AKIRA_VM_OFFSET.vm),
            hookedCount = 0,
        }
        for _ in pairs(AKIRA_VM_OFFSET.hooked) do
            state.hookedCount = state.hookedCount + 1
        end
        shared.__akiraVmState = state
    end)
end)

local function setViewModelOffset(ox, oy, oz)
    AKIRA_VM_OFFSET.x = tonumber(ox) or 0
    AKIRA_VM_OFFSET.y = tonumber(oy) or 0
    AKIRA_VM_OFFSET.z = tonumber(oz) or 0
    pcall(installViewModelOffsetHook)
end

local function clearViewModelOffset()
    AKIRA_VM_OFFSET.x = 0
    AKIRA_VM_OFFSET.y = 0
    AKIRA_VM_OFFSET.z = 0
    AKIRA_VM_OFFSET.written = nil
end

local function publishActiveTarget(source, entityOrPlayer, part)
    local player = nil
    if typeof(entityOrPlayer) == "Instance" then
        player = entityOrPlayer:FindFirstChildOfClass("Player")
    else
        player = entityOrPlayer
    end
    local head = nil
    if typeof(entityOrPlayer) == "table" or typeof(entityOrPlayer) == "Instance" then
        local okHead, found = pcall(function()
            return entityOrPlayer.Head or entityOrPlayer.HitboxPart
        end)
        if okHead then head = found end
    end
    if head == nil then head = part end
    if player == nil or typeof(player) ~= "Instance" then
        if type(AkiraLite.Targets) == "table" then
            AkiraLite.Targets[source] = nil
        end
        return
    end
    if head == nil or typeof(head) ~= "Instance" then
        head = nil
    end
                                                                                  
                                                                                 
                                                                   
    if type(AkiraLite.Targets) ~= "table" then
        AkiraLite.Targets = {}
    end
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
                                                                               
    local CIRCLE_OUTLINE_BLACK = Color3.new()
                                                                                  
                                                             
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
    local validAimParts = { Head = true, HumanoidRootPart = true, UpperTorso = true, LowerTorso = true }
    local function aimPartName()
        local value = Part and Part.Value
        if type(value) == "string" and validAimParts[value] then
            return value
        end
        return "Head"
    end

    local dummyList = {}
    local dummyScanAt = 0
    local function refreshDummies()
        if os.clock() < dummyScanAt then return end
        dummyScanAt = os.clock() + 1
        local found = {}
        local names = { "Dummy", "DPS Dummy", "Target" }
        for _, child in ipairs(workspace:GetDescendants()) do
            if child:IsA("Model") then
                local modelName = child.Name
                for i = 1, #names do
                    if modelName == names[i] then
                        if child:FindFirstChildOfClass("Humanoid") then
                            found[#found + 1] = child
                        end
                        break
                    end
                end
            end
        end
        dummyList = found
    end

    local function nearestDummy(range)
        local cam = gameCamera
        if not cam then return nil end
        local center = cam.ViewportSize / 2
        local best, bestDist = nil, math.huge
        for i = 1, #dummyList do
            local model = dummyList[i]
            if model and model.Parent then
                local part = model:FindFirstChild(aimPartName())
                    or model:FindFirstChild("Head")
                    or model:FindFirstChild("HumanoidRootPart")
                local hum = model:FindFirstChildOfClass("Humanoid")
                if part and hum and hum.Health > 0 then
                    if (part.Position - cam.CFrame.Position).Magnitude <= range then
                        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d < bestDist then
                                bestDist, best = d, model
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    AimAssist = AkiraLite.Catalogs.Combat:AddModule({
        Name = 'Aim Assist',
        Function = function(callback)
            if CircleObject then
                CircleObject.Visible = callback
            end
            if callback then
                local ent
                local aaNextShot = 0
                local rightClicked = not RightClick.Enabled or UserInputService:IsMouseButtonPressed(1)
                local function targetUsable(target)
                    if not target or not target.Parent then
                        return false
                    end
                    local hum = target:FindFirstChildOfClass('Humanoid')
                    if hum and hum.Health <= 0 then
                        return false
                    end
                    return target:FindFirstChild(aimPartName()) ~= nil
                end
                local function aimAt(target, dt)
                    if not targetUsable(target) then
                        return
                    end
                    if IgnoreDeflecting and IgnoreDeflecting.Enabled and akiraIsDeflecting(target) then
                        return
                    end
                    local aaCfg = getgenv().Config
                    local part = target[aimPartName()]
                    if aaCfg and aaCfg.AimRandomPart then
                        local pool = { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" }
                        local pick = target[pool[math.random(1, #pool)]]
                        if pick then part = pick end
                    end
                    if not part then return end
                    local aimPoint = part.Position
                    local apred = (aaCfg and aaCfg.AimPrediction) or 0
                    if apred > 0 then
                        local avel = part.AssemblyLinearVelocity or Vector3.zero
                        aimPoint = aimPoint + avel * (0.06 * apred)
                    end
                    local chanceRoll = (aaCfg and aaCfg.AimPartRandomChance) or 0
                    if chanceRoll > 0 and math.random(1, 100) <= chanceRoll then
                        local pool = { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" }
                        local alt = target[pool[math.random(1, #pool)]]
                        if alt then part = alt end
                    end
                    local dx = (aaCfg and aaCfg.AimDelayX) or 0
                    local dy = (aaCfg and aaCfg.AimDelayY) or 0
                    if dx ~= 0 or dy ~= 0 then
                        aimPoint = aimPoint + gameCamera.CFrame:VectorToWorldSpace(Vector3.new(dx, dy, 0))
                    end
                    local achance = (aaCfg and aaCfg.AimHitChance) or 100
                    if achance < 100 and math.random(1, 100) > achance then return end
                    local adelay = ((aaCfg and aaCfg.AimDelay) or 0) / 1000
                    local anow = tick()
                    if anow < aaNextShot then return end
                    aaNextShot = anow + adelay
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
                    local smoothMul = ((getgenv().Config and getgenv().Config.AimSmoothing) or 100) / 100
                    local smoothMs = (getgenv().Config and getgenv().Config.AimSmoothTime) or 0
                    if smoothMs > 0 then smoothMul = math.clamp(dt * (1000 / smoothMs), 0.02, 1) end
                    local scale = (Flick and Flick.Enabled) and 1 or math.min(Speed.Value * smoothMul * dt, 1)
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
                        local part = ent[aimPartName()]
                        local keep = targetUsable(ent) and part and (part.Position - gameCamera.CFrame.Position).Magnitude <= FOV.Value * 1.75
                        if not keep then
                            ent = nil
                        end
                    else
                        ent = nil
                    end
                    refreshDummies()
                    if not ent then
                        ent = entitylib.EntityMouse({
                            Range = FOV.Value,
                            Part = aimPartName(),
                            Players = true,
                            NPCs = false,
                            Wallcheck = not (WallAim and WallAim.Enabled),
                            Origin = gameCamera.CFrame.Position
                        })
                    end
                    if not ent then
                        ent = nearestDummy(FOV.Value)
                    end
                    if ent then
                        publishActiveTarget("AimAssist", ent, ent[aimPartName()] or ent.Head)
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
        List = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso'},
        Default = 'Head'
    })
    if type(Part.Value) ~= "string" or not validAimParts[Part.Value] then
        Part.Value = "Head"
    end
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
                                                                                      
                                                                              
                                                                                     
                            local now = os.clock()
                            if now - circleTargetAt >= 0.05 then
                                circleTargetAt = now
                                circleOptions.Range = FOV.Value * 4
                                circleOptions.Part = aimPartName()
                                circleOptions.Origin = gameCamera.CFrame.Position
                                circleTarget = entitylib.EntityMouse(circleOptions)
                            end
                            local target = circleTarget
                            if target then
                                local part = target[aimPartName()] or target.Head or target.RootPart
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
    AimAssist:AddToggle({
        Name = 'Random Part',
        Default = false,
        Darker = true,
        Function = function(val)
            getgenv().Config.AimRandomPart = val
        end
    })
    AimAssist:AddSlider({
        Name = 'Aim Smoothing',
        Min = 0,
        Max = 200,
        Default = 100,
        Decimal = 1,
        Darker = true,
        Suffix = '%',
        Function = function(val)
            getgenv().Config.AimSmoothing = val
        end
    })
    AimAssist:AddSlider({
        Name = 'Aim Delay',
        Min = 0,
        Max = 500,
        Default = 0,
        Decimal = 1,
        Darker = true,
        Suffix = 'ms',
        Function = function(val)
            getgenv().Config.AimDelay = val
        end
    })
    AimAssist:AddSlider({
        Name = 'Aim Hit Chance',
        Min = 0,
        Max = 100,
        Default = 100,
        Decimal = 1,
        Darker = true,
        Suffix = '%',
        Function = function(val)
            getgenv().Config.AimHitChance = val
        end
    })
    AimAssist:AddSlider({
        Name = 'Aim Prediction',
        Min = 0,
        Max = 20,
        Default = 0,
        Decimal = 1,
        Darker = true,
        Function = function(val)
            getgenv().Config.AimPrediction = val
        end
    })
    AimAssist:AddSlider({
        Name = 'Aim Random Part Chance',
        Min = 0,
        Max = 100,
        Default = 0,
        Decimal = 1,
        Darker = true,
        Suffix = '%',
        Function = function(val)
            getgenv().Config.AimPartRandomChance = val
        end
    })
    AimAssist:AddSlider({
        Name = 'Delayed Position X',
        Min = -30,
        Max = 30,
        Default = 0,
        Decimal = 100,
        Darker = true,
        Function = function(val)
            getgenv().Config.AimDelayX = val
        end
    })
    AimAssist:AddSlider({
        Name = 'Delayed Position Y',
        Min = -30,
        Max = 30,
        Default = 0,
        Decimal = 100,
        Darker = true,
        Function = function(val)
            getgenv().Config.AimDelayY = val
        end
    })
    AimAssist:AddSlider({
        Name = 'Aim Smooth Time',
        Min = 0,
        Max = 500,
        Default = 0,
        Decimal = 1,
        Darker = true,
        Suffix = 'ms',
        Function = function(val)
            getgenv().Config.AimSmoothTime = val
        end
    })
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
            nametag.FontFace = akiraNameTagFont
            nametag.ZIndex = - 1
            local ize = getfontsize(removeTags(Strings[ent]), nametag.TextSize, akiraNameTagFont, Vector2.new(100000, 100000))
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
                                                                                
                                                                                     
                if ent.__akiraHeadOffset == nil then
                    ent.__akiraHeadOffset = Vector3.new(0, ent.HipHeight + 1, 0)
                end
                local headPos, headVis = gameCamera:WorldToViewportPoint(entPos + ent.__akiraHeadOffset)
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
                if ent.__akiraHeadOffset == nil then
                    ent.__akiraHeadOffset = Vector3.new(0, ent.HipHeight + 1, 0)
                end
                local headPos, headVis = gameCamera:WorldToScreenPoint(entPos + ent.__akiraHeadOffset)
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
                                                                                  
                                                                      
    local phasePresent = {}
    local teleported
    local function motorMove(root, destination)
        if root and root.Parent and destination then
            root.CFrame = destination
        end
    end
                                                                             
                                                                    
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
local function akiraReferenceSilentAim()
    local running = false
    local connections = {}
    local saCfg = getgenv().Config
    if type(saCfg) ~= "table" then
        saCfg = {}
        getgenv().Config = saCfg
    end
    if type(saCfg.HitPart) ~= "string" then saCfg.HitPart = "Head" end
    if type(saCfg.FOVRadius) ~= "number" then saCfg.FOVRadius = 300 end
    if type(saCfg.ShowFOV) ~= "boolean" then saCfg.ShowFOV = true end
    if saCfg.__akiraSettings ~= AKIRA_SETTINGS_VERSION then
        saCfg.__akiraSettings = AKIRA_SETTINGS_VERSION
        for key in pairs(saCfg) do
            local name = tostring(key)
            if name:sub(1, 6) == "Silent" then
                saCfg[key] = nil
            end
        end
    end
    if type(saCfg.SilentHitPart) ~= "string" then saCfg.SilentHitPart = saCfg.HitPart end
    if type(saCfg.SilentTargetMode) ~= "string" then saCfg.SilentTargetMode = "Closest" end
    if type(saCfg.SilentFOV) ~= "number" then saCfg.SilentFOV = saCfg.FOVRadius end
    if type(saCfg.SilentHitChance) ~= "number" then saCfg.SilentHitChance = 100 end
    if type(saCfg.SilentSmoothing) ~= "number" then saCfg.SilentSmoothing = 0 end
    if type(saCfg.SilentDelay) ~= "number" then saCfg.SilentDelay = 0 end
    if type(saCfg.SilentSpread) ~= "number" then saCfg.SilentSpread = 0 end
    if type(saCfg.SilentOffsetX) ~= "number" then saCfg.SilentOffsetX = 0 end
    if type(saCfg.SilentOffsetY) ~= "number" then saCfg.SilentOffsetY = 0 end
    if type(saCfg.SilentOffsetZ) ~= "number" then saCfg.SilentOffsetZ = 0 end
    if type(saCfg.SilentPrediction) ~= "number" then saCfg.SilentPrediction = 0 end
    if type(saCfg.SilentMaxDist) ~= "number" then saCfg.SilentMaxDist = 500 end
    if type(saCfg.SilentFalloff) ~= "number" then saCfg.SilentFalloff = 0 end
    if type(saCfg.SilentPartRandomChance) ~= "number" then saCfg.SilentPartRandomChance = 0 end
    if type(saCfg.SilentWallCheck) ~= "boolean" then saCfg.SilentWallCheck = false end
    if type(saCfg.SilentTeamCheck) ~= "boolean" then saCfg.SilentTeamCheck = false end
    if type(saCfg.SilentFOVThickness) ~= "number" then saCfg.SilentFOVThickness = 1 end
    if type(saCfg.SilentFOVTransparency) ~= "number" then saCfg.SilentFOVTransparency = 1 end
    if type(saCfg.SilentPartPriority) ~= "string" then saCfg.SilentPartPriority = "Head" end
    if type(saCfg.SilentFOVColor) ~= "Color3" then saCfg.SilentFOVColor = Color3.fromRGB(255, 255, 255) end

    local reps = game:GetService("ReplicatedStorage")
    local plrs = game:GetService("Players")
    local runs = game:GetService("RunService")
    local cs = game:GetService("CollectionService")
    local lplr = plrs.LocalPlayer
    local cam = workspace.CurrentCamera

    local U = require(reps.Modules.Utility)
    local EL = require(reps.Modules.EnumLibrary)
    local GU = require(reps.Modules.GameplayUtility)

    local e, gun = pcall(require, lplr.PlayerScripts.Modules.ItemTypes.Gun)
    if e and gun and gun.IsFullyAiming then
        gun.IsFullyAiming = function() return true end
    end

    local FOV = Drawing.new("Circle")
    FOV.Color = Color3.fromRGB(255, 255, 255)
    FOV.Thickness = 1
    FOV.Filled = false

    table.insert(connections, runs.RenderStepped:Connect(function()
        if not running then
            FOV.Visible = false
            return
        end
        FOV.Position = cam.ViewportSize / 2
        akiraSanitizeConfig()
        local scfg = getgenv().Config
        FOV.Radius = akiraNum(scfg.SilentFOV, akiraNum(scfg.FOVRadius, 300))
        FOV.Visible = scfg.ShowFOV ~= false
        if scfg.SilentFOVColor then FOV.Color = scfg.SilentFOVColor end
        FOV.Thickness = akiraNum(scfg.SilentFOVThickness, FOV.Thickness)
        FOV.Transparency = math.clamp(tonumber(akiraNum(scfg.SilentFOVTransparency, FOV.Transparency)) or 0, 0, 1)
    end))

    local saAim = nil
    local saNextShot = 0

    local function pickPart(entity)
        local cfg = getgenv().Config
        local mode = cfg.SilentHitPart or "Head"
        if cfg.SilentPartRandomChance and cfg.SilentPartRandomChance > 0 then
            if math.random(1, 100) <= cfg.SilentPartRandomChance then
                local pool = { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" }
                local picked = entity:FindFirstChild(pool[math.random(1, #pool)], true)
                if picked and picked:IsA("BasePart") then return picked end
            end
        end
        if mode ~= "Closest" and mode ~= "Random" then
            local chain = { mode, "UpperTorso", "Head", "HumanoidRootPart" }
            for _, name in ipairs(chain) do
                local direct = entity:FindFirstChild(name, true)
                if direct and direct:IsA("BasePart") then return direct end
            end
            return entity:FindFirstChild("Head", true)
        end
        if mode == "Random" then
            local pool = { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" }
            for _ = 1, 4 do
                local candidate = entity:FindFirstChild(pool[math.random(1, #pool)], true)
                if candidate and candidate:IsA("BasePart") then return candidate end
            end
            return entity:FindFirstChild("Head", true)
        end
        if mode == "Closest" then
            local best, bestD = nil, math.huge
            local center = cam.ViewportSize / 2
            for _, child in entity:GetDescendants() do
                if child:IsA("BasePart") then
                    local sp, onScreen = cam:WorldToViewportPoint(child.Position)
                    if onScreen then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < bestD then
                            bestD, best = d, child
                        end
                    end
                end
            end
            if best then return best end
        end
        return entity:FindFirstChild(mode, true)
    end

    local wallParams = RaycastParams.new()
    wallParams.FilterType = Enum.RaycastFilterType.Exclude
    local function hasLineOfSight(part)
        if not getgenv().Config.SilentWallCheck then return true end
        local root = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
        if not root then return true end
        wallParams.FilterDescendantsInstances = { lplr.Character, cam }
        local ray = workspace:Raycast(root.Position, part.Position - root.Position, wallParams)
        return ray == nil
    end

    local function isTeammate(entity)
        if not getgenv().Config.SilentTeamCheck then return false end
        local other = entity and entity:FindFirstChildOfClass("Player")
        if not other then return false end
        local a = other:GetAttribute("TeamID")
        local b = lplr:GetAttribute("TeamID")
        if a and b then return a == b end
        return false
    end

    local function target()
        local cfg = getgenv().Config
        local center = cam.ViewportSize / 2
        local radius = akiraNum(cfg.SilentFOV, akiraNum(cfg.FOVRadius, 300))
        local bestPart, bestDist, hits = nil, radius, 0
        local camPos = cam.CFrame.Position
        for _, entity in cs:GetTagged("Entity") do
            if entity == lplr.Character then continue end
            if isTeammate(entity) then continue end
            local part = pickPart(entity)
            if part and part:IsA("BasePart") then
                local worldDist = (part.Position - camPos).Magnitude
                if worldDist <= (cfg.SilentMaxDist or 500) then
                    local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < bestDist and hasLineOfSight(part) then
                            bestDist, bestPart = d, part
                        end
                        hits = hits + 1
                    end
                end
            end
        end
        if not bestPart then return nil end
        if cfg.SilentTargetMode == "Random" and hits > 1 then
            local picks = {}
            for _, entity in cs:GetTagged("Entity") do
                if entity ~= lplr.Character then
                    local part = pickPart(entity)
                    if part and part:IsA("BasePart") then
                        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen and (Vector2.new(sp.X, sp.Y) - center).Magnitude < radius then
                            picks[#picks + 1] = part
                        end
                    end
                end
            end
            if #picks > 0 then return picks[math.random(1, #picks)] end
        end
        return bestPart
    end

    local function predictPosition(part)
        local factor = getgenv().Config.SilentPrediction or 0
        if factor <= 0 then return part.Position end
        local model = part:FindFirstAncestorWhichIsA("Model")
        local root = model and model:FindFirstChild("HumanoidRootPart")
        if not root then return part.Position end
        local vel = root.AssemblyLinearVelocity or Vector3.zero
        return part.Position + vel * (0.06 * factor)
    end

    local function aimPosition(part)
        local cfg = getgenv().Config
        local pos = predictPosition(part)
        local smoothing = cfg.SilentSmoothing or 0
        if smoothing > 0 then
            if not saAim then
                saAim = pos
            else
                saAim = saAim:Lerp(pos, math.clamp(1 - (smoothing / 100) * 0.95, 0.05, 1))
            end
            return saAim
        end
        saAim = pos
        return pos
    end

    local function CFDPos(origin, part, pos)
        local cf = part.CFrame
        local d = {}
        d[utf8.char(1)] = {
            [utf8.char(0)] = U:EncodeCFrame(CFrame.lookAt(origin, pos)),
            [utf8.char(1)] = U:EncodeCFrame(cf),
            [utf8.char(2)] = part,
            [utf8.char(3)] = U:EncodeCFrame(cf:ToObjectSpace(CFrame.new(pos))),
        }
        return d
    end

    local function CFD(origin, part)
        local cf = part.CFrame
        local d = {}
        d[utf8.char(1)] = {
            [utf8.char(0)] = U:EncodeCFrame(CFrame.lookAt(origin, part.Position)),
            [utf8.char(1)] = U:EncodeCFrame(cf),
            [utf8.char(2)] = part,
            [utf8.char(3)] = U:EncodeCFrame(cf:ToObjectSpace(CFrame.new(part.Position))),
        }
        return d
    end

    local visual = GU.GetEntitiesFromRaycast
    GU.GetEntitiesFromRaycast = function(self, envID, params, origin, dir, maxDist, ...)
        if not running then
            return visual(self, envID, params, origin, dir, maxDist, ...)
        end
        local t = target()
        if t then
            local dist = (t.Position - origin).Magnitude
            dir = (t.Position - origin).Unit
            if dist > maxDist then maxDist = dist + 5 end
        end
        return visual(self, envID, params, origin, dir, maxDist, ...)
    end

    local UseItem = reps.Remotes.Replication.Fighter.UseItem
    local hook
    hook = hookfunction(UseItem.FireServer, newcclosure(function(self, objID, enumVal, camdata, extra)
        if not running then
            return hook(self, objID, enumVal, camdata, extra)
        end
        if enumVal == EL:ToEnum("StartShooting") then
            local cfg = getgenv().Config
            local root = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
            local t = target()
            if root and t then
                local chance = cfg.SilentHitChance or 100
                local falloff = cfg.SilentFalloff or 0
                if falloff > 0 and chance >= 100 then
                    local d = (t.Position - root.Position).Magnitude
                    local span = math.max((cfg.SilentMaxDist or 500) - 50, 1)
                    chance = math.clamp(100 - (d / span) * falloff, 0, 100)
                end
                local delay = (cfg.SilentDelay or 0) / 1000
                local now = tick()
                if (chance >= 100 or math.random(1, 100) <= chance) and now >= saNextShot then
                    camdata = CFDPos(root.Position, t, aimPosition(t))
                    saNextShot = now + delay
                end
            end
        end
        return hook(self, objID, enumVal, camdata, extra)
    end))

    return {
        Start = function()
            running = true
            getgenv().Config.ShowFOV = getgenv().Config.ShowFOV ~= false
        end,
        Stop = function()
            running = false
            FOV.Visible = false
            saAim = nil
            saNextShot = 0
        end,
        IsRunning = function()
            return running
        end,
        Connections = connections,
    }
end


    akiraMark("block16:done")
    akiraMark("block17:start")
run(function()
    local TriggerBot
    local Targets
    local ShootDelay
    local Distance
    local rayCheck, delayCheck = RaycastParams.new(), tick()
                                                                                   
                                                                               
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
                                                                                 
                                                                               
                                                                                 
                                               
    local restoreSprings

                                     
       
                                                                              
                                                                                
                                                                        
    local function isOffsettableModel(model)
                                                                                 
                                                                            
                                                                                  
                                 
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
        if _savedProps[p] ~= nil then return end
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
                                                                                  
                                                                           
        for _, entry in pairs(_offsetFrames) do
            restoreOffset(entry)
        end
                                                                                 
                                                                                    
                                      
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

                                                           
    local function freezeCameraSprings(camCtrl)
        freezeSpringUnsafe(camCtrl._sway_spring, Vector2.zero)
        freezeSpringUnsafe(camCtrl._bobbing_speed_spring, 0)
        freezeSpringUnsafe(camCtrl._bobbing_value_spring, 0)
        freezeSpringUnsafe(camCtrl._leaning_spring, 0)
        freezeSpringUnsafe(camCtrl._jump_spring, 0)
        freezeSpringUnsafe(camCtrl._sliding_spring, 0)
    end

                                                                              
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
        pcall(function() vm._custom_sprinting_enabled = 0 end)
        pcall(function() vm.CurrentSwayValue = Vector2.zero end)
        freezeSpring(rawget(vm, "_bobbing_speed_spring"), 0)
        freezeSpring(rawget(vm, "_bobbing_value_spring"), Vector2.zero)
        freezeSpring(rawget(vm, "_sliding_spring"), 0)
        freezeSpring(rawget(vm, "_sprinting_spring"), 0)
        freezeSpring(rawget(vm, "_crouching_spring"), 0)
        freezeSpring(rawget(vm, "_landing_spring"), 0)
        freezeSpring(rawget(vm, "_jump_spring"), 0)
        freezeSpring(rawget(vm, "_raycast_tilt_spring"), Vector2.zero)
        freezeSpring(rawget(vm, "_impulse_position_spring"), Vector3.zero)
        freezeSpring(rawget(vm, "_recoil_spring"), Vector3.zero)
        freezeSpring(rawget(vm, "_unrecoil_spring"), Vector3.zero)
        freezeSpring(rawget(vm, "_inspect_spring"), 0)
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

                                                                                   
                                                                        
                       
                                                                                  
                                                                                     
                                                                                   
                                                                                      
                                                                                    
                                                                                     
                                                           
                    if OffsetToggle and OffsetToggle.Enabled then
                        local ox = OffsetX and OffsetX.Value or 0
                        local oy = OffsetY and OffsetY.Value or 0
                        local oz = OffsetZ and OffsetZ.Value or 0
                        if ox ~= 0 or oy ~= 0 or oz ~= 0 then
                            local model = type(vm) == "table"
                                and (vm.Model or vm._model)
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

                                                         
        pcall(function()
            local vmFolder = workspace:FindFirstChild("ViewModels")
            local fp = vmFolder and vmFolder:FindFirstChild("FirstPerson")
            local searchFolders = { fp, workspace.CurrentCamera }
            local lpPrefix = lp and (lp.Name:lower() .. " -") or ""
            for _, folder in ipairs(searchFolders) do
                if folder then
                    for _, model in ipairs(folder:GetChildren()) do
                        local mn = model.Name:lower()
                        local isLocalVM = (lp and mn:find(lp.Name:lower(), 1, true)) or (lpPrefix ~= "" and mn:sub(1, #lpPrefix) == lpPrefix)
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
                                        end
                                    end
                                elseif (d:IsA("Decal") or d:IsA("Texture")) and itemVisual and d:IsDescendantOf(itemVisual) then
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

        AkiraLite.Skin = AKIRA_SKIN

    local function akiraSkinSetButtonText(dropdown)
            if type(dropdown) ~= "table" or type(dropdown.Frame) ~= "Instance" then return end
            local btn = dropdown.Frame:FindFirstChild("Select")
            if btn and btn:IsA("TextButton") then btn.Text = tostring(dropdown.Value) end
        end

        local function akiraSkinFill(target, source, keep)
            for i = #target, 1, -1 do target[i] = nil end
            if keep then target[1] = keep end
            for _, name in ipairs(source) do target[#target + 1] = name end
        end

        local AKIRA_SKIN_STATE = {
            WeaponList = {"None"},
            SkinList = {"None"},
            WrapList = {"None"},
            CharmList = {"None"},
            FinisherList = {"None"},
            Weapon = nil,
        }

        local function akiraSkinRefreshWeaponList()
            local visible = AKIRA_SKIN.VisibleWeapons()
            akiraSkinFill(AKIRA_SKIN_STATE.WeaponList, visible, "None")
            return visible
        end

        local function akiraSkinRefreshSkinList(weaponName)
            local names = {"None"}
            for _, rec in ipairs(AKIRA_SKIN.SkinsForWeapon(weaponName)) do
                names[#names + 1] = rec.Name
            end
            akiraSkinFill(AKIRA_SKIN_STATE.SkinList, names)
            return names
        end

        local function akiraSkinCurrentWeapon()
            local w = AKIRA_SKIN_STATE.Weapon
            if w and w ~= "None" then return w end
            return AKIRA_SKIN.EquippedWeaponName() or AKIRA_SKIN.LastUsedWeapon
        end

    local AKIRA_SKIN_UI = {Built = false, Open = false, Popups = {}}

    local function akiraSkinEnsureBuilt()
        local live = shared.AkiraLite
        if type(live) ~= "table" then return false end
        if AKIRA_SKIN_UI.Built then return true end
        if not live.SkinsWindow or not live.SkinsWindow.Parent then return false end
        local okBuild, errBuild = xpcall(function()
            return AKIRA_SKIN_UI.Build()
        end, function(message)
            return tostring(message)
        end)
        if okBuild then
            live.SkinBuildError = nil
        else
            live.SkinBuildError = tostring(errBuild)
        end
        shared.AkiraLiteSkinUI = AKIRA_SKIN_UI
        return okBuild
    end

    run(function()
        task.defer(function()
            for attempt = 1, 40 do
                if akiraSkinEnsureBuilt() then return end
                task.wait(0.25)
            end
        end)
        task.defer(function()
            local live = shared.AkiraLite
            for attempt = 1, 120 do
                if type(live) == "table" and type(live.SwitchTab) == "function" then
                    local base = live.SwitchTab
                    live.SwitchTab = function(name, ...)
                        if name == "Skins" then
                            pcall(akiraSkinEnsureBuilt)
                        end
                        return base(name, ...)
                    end
                    return
                end
                task.wait(0.25)
            end
        end)
    end)

    local function akiraUiRound(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 6)
        c.Parent = parent
        return c
    end

    local function akiraUiStroke(parent, color, thickness)
        local s = Instance.new("UIStroke")
        s.Color = color or Color3.fromRGB(55, 58, 72)
        s.Thickness = thickness or 1
        s.Transparency = 0.3
        s.Parent = parent
        return s
    end

    local function akiraUiMakeLabel(parent, textValue, size, pos, width, align)
        local l = Instance.new("TextLabel")
        l.Name = "Label"
        l.Text = tostring(textValue or "")
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(0, width or 150, 1, 0)
        l.Position = pos
        l.TextColor3 = Color3.fromRGB(240, 240, 245)
        l.TextSize = size or 11
        l.TextXAlignment = align or Enum.TextXAlignment.Left
        l.Font = Enum.Font.Code
        l.ZIndex = 96
        l.Parent = parent
        return l
    end

    local function akiraUiClosePopups()
        for _, popup in pairs(AKIRA_SKIN_UI.Popups) do
            if popup and popup.Parent then popup:Destroy() end
        end
        table.clear(AKIRA_SKIN_UI.Popups)
    end

    local function akiraUiOpenPopup(anchorFrame, items, current, onSelect)
        akiraUiClosePopups()
        local popup = Instance.new("Frame")
        popup.Name = "SkinListPopup"
        popup.AnchorPoint = Vector2.new(0, 0)
        popup.Size = UDim2.new(1, 0, 0, 260)
        popup.Position = UDim2.new(0, 0, 1, 2)
        popup.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
        popup.BackgroundTransparency = 0.03
        popup.BorderSizePixel = 0
        popup.ClipsDescendants = true
        popup.Visible = true
        popup.ZIndex = 200
        popup.Parent = anchorFrame
        akiraUiRound(popup, 6)
        akiraUiStroke(popup)
        table.insert(AKIRA_SKIN_UI.Popups, popup)

        local search = Instance.new("TextBox")
        search.Name = "Search"
        search.PlaceholderText = "Search..."
        search.Text = ""
        search.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        search.TextColor3 = Color3.fromRGB(240, 240, 245)
        search.PlaceholderColor3 = Color3.fromRGB(120, 122, 135)
        search.Font = Enum.Font.Code
        search.TextSize = 11
        search.BorderSizePixel = 0
        search.Size = UDim2.new(1, -12, 0, 26)
        search.Position = UDim2.new(0, 6, 0, 6)
        search.ZIndex = 201
        search.Parent = popup
        akiraUiRound(search, 4)

        local count = Instance.new("TextLabel")
        count.Name = "Count"
        count.BackgroundTransparency = 1
        count.TextColor3 = Color3.fromRGB(130, 132, 145)
        count.Font = Enum.Font.Code
        count.TextSize = 9
        count.TextXAlignment = Enum.TextXAlignment.Right
        count.Size = UDim2.new(1, -14, 0, 12)
        count.Position = UDim2.new(0, 7, 0, 34)
        count.ZIndex = 201
        count.Parent = popup

        local scroller = Instance.new("ScrollingFrame")
        scroller.Name = "List"
        scroller.BackgroundTransparency = 1
        scroller.BorderSizePixel = 0
        scroller.Size = UDim2.new(1, -12, 1, -52)
        scroller.Position = UDim2.new(0, 6, 0, 48)
        scroller.ScrollBarThickness = 4
        scroller.ScrollBarImageColor3 = Color3.fromRGB(90, 92, 105)
        scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroller.ZIndex = 201
        scroller.Parent = popup
        akiraUiRound(scroller, 4)

        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = scroller

        local shown = 0
        local function render()
            for _, child in ipairs(scroller:GetChildren()) do
                if child:IsA("GuiButton") then child:Destroy() end
            end
            shown = 0
            local filter = string.lower(search.Text or "")
            for index, name in ipairs(items) do
                if filter == "" or string.find(string.lower(name), filter, 1, true) then
                    shown = shown + 1
                    local row = Instance.new("TextButton")
                    row.Name = "Row"
                    row.Text = tostring(name)
                    row.LayoutOrder = index
                    row.BackgroundColor3 = (name == current)
                        and Color3.fromRGB(45, 50, 66)
                        or Color3.fromRGB(24, 26, 33)
                    row.BackgroundTransparency = (name == current) and 0.1 or 0.25
                    row.TextColor3 = (name == current)
                        and Color3.fromRGB(140, 230, 220)
                        or Color3.fromRGB(225, 226, 232)
                    row.Font = Enum.Font.Code
                    row.TextSize = 11
                    row.TextXAlignment = Enum.TextXAlignment.Left
                    row.BorderSizePixel = 0
                    row.Size = UDim2.new(1, -6, 0, 22)
                    row.ZIndex = 202
                    row.Parent = scroller
                    akiraUiRound(row, 4)
                    row.MouseButton1Click:Connect(function()
                        akiraUiClosePopups()
                        onSelect(name)
                    end)
                end
            end
            count.Text = shown .. " / " .. #items
        end

        search:GetPropertyChangedSignal("Text"):Connect(render)
        render()
        return popup
    end

    local function akiraUiMakeDropdown(parent, labelText, getItems, onSelect, startY)
        local holder = Instance.new("Frame")
        holder.Name = "Dropdown_" .. labelText
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, -16, 0, 46)
        holder.Position = UDim2.new(0, 8, 0, startY)
        holder.ZIndex = 95
        holder.Parent = parent

        local state = {Value = "None"}

        akiraUiMakeLabel(holder, labelText, 10, UDim2.new(0, 4, 0, 2), 110)

        local field = Instance.new("TextButton")
        field.Name = "Field"
        field.Text = "None"
        field.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        field.TextColor3 = Color3.fromRGB(240, 240, 245)
        field.Font = Enum.Font.Code
        field.TextSize = 11
        field.TextXAlignment = Enum.TextXAlignment.Left
        field.BorderSizePixel = 0
        field.AutoButtonColor = false
        field.Size = UDim2.new(1, -12, 0, 26)
        field.Position = UDim2.new(0, 6, 0, 18)
        field.ZIndex = 96
        field.Parent = holder
        akiraUiRound(field, 4)
        akiraUiStroke(field)

        local function refresh()
            local items = getItems()
            field.Text = state.Value
            for _, child in ipairs(holder:GetChildren()) do
                if child.Name == "SkinListPopup" then child:Destroy() end
            end
        end

        field.MouseButton1Click:Connect(function()
            local items = getItems()
            if #items == 0 then return end
            akiraUiOpenPopup(holder, items, state.Value, function(name)
                state.Value = name
                field.Text = name
                onSelect(name)
            end)
        end)

        return {
            Holder = holder,
            Field = field,
            State = state,
            Refresh = refresh,
            SetValue = function(_, value)
                state.Value = value or "None"
                field.Text = state.Value
            end,
        }
    end

    local function akiraUiMakeButton(parent, labelText, startY, onClick)
        local button = Instance.new("TextButton")
        button.Name = "Btn_" .. labelText
        button.Text = labelText
        button.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
        button.TextColor3 = Color3.fromRGB(235, 236, 242)
        button.Font = Enum.Font.Code
        button.TextSize = 11
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Size = UDim2.new(1, -16, 0, 28)
        button.Position = UDim2.new(0, 8, 0, startY)
        button.ZIndex = 96
        button.Parent = parent
        akiraUiRound(button, 5)
        akiraUiStroke(button)
        button.MouseEnter:Connect(function() button.BackgroundColor3 = Color3.fromRGB(44, 48, 60) end)
        button.MouseLeave:Connect(function() button.BackgroundColor3 = Color3.fromRGB(32, 35, 44) end)
        button.MouseButton1Click:Connect(function() pcall(onClick) end)
        return button
    end

    local function akiraUiMakeToggle(parent, labelText, startY, default, onChange)
        local state = {on = default}
        local holder = Instance.new("Frame")
        holder.Name = "Toggle_" .. labelText
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, -16, 0, 30)
        holder.Position = UDim2.new(0, 8, 0, startY)
        holder.ZIndex = 95
        holder.Parent = parent
        akiraUiMakeLabel(holder, labelText, 11, UDim2.new(0, 4, 0, 6), 200)
        local pill = Instance.new("TextButton")
        pill.Name = "Pill"
        pill.Text = ""
        pill.BackgroundColor3 = state.on and Color3.fromRGB(53, 215, 199) or Color3.fromRGB(60, 63, 74)
        pill.BorderSizePixel = 0
        pill.Size = UDim2.fromOffset(40, 20)
        pill.Position = UDim2.new(1, -46, 0, 5)
        pill.ZIndex = 96
        pill.Parent = holder
        akiraUiRound(pill, 10)
        local knob = Instance.new("Frame")
        knob.Name = "Knob"
        knob.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
        knob.BorderSizePixel = 0
        knob.Size = UDim2.fromOffset(16, 16)
        knob.Position = UDim2.fromOffset(state.on and 22 or 2, 2)
        knob.ZIndex = 97
        knob.Parent = pill
        akiraUiRound(knob, 8)
        pill.MouseButton1Click:Connect(function()
            state.on = not state.on
            pill.BackgroundColor3 = state.on and Color3.fromRGB(53, 215, 199) or Color3.fromRGB(60, 63, 74)
            knob.Position = UDim2.fromOffset(state.on and 22 or 2, 2)
            onChange(state.on)
        end)
        return {Holder = holder, Set = function(_, v) state.on = v and true or false end}
    end

    AKIRA_SKIN_UI = AKIRA_SKIN_UI or {Built = false, Open = false, Popups = {}}
    AKIRA_SKIN_UI.Accent = Color3.fromRGB(120, 235, 215)

    local VM_PANEL = Color3.fromRGB(15, 16, 20)
    local VM_CARD = Color3.fromRGB(24, 25, 32)
    local VM_CARD_HOVER = Color3.fromRGB(34, 36, 46)
    local VM_STROKE = Color3.fromRGB(44, 46, 58)
    local VM_TEXT = Color3.fromRGB(225, 226, 232)
    local VM_MUTED = Color3.fromRGB(150, 154, 168)

    local AKIRA_SKIN_RARITY = {
        Common = Color3.fromRGB(180, 186, 198),
        Uncommon = Color3.fromRGB(96, 200, 140),
        Rare = Color3.fromRGB(96, 150, 240),
        Epic = Color3.fromRGB(186, 110, 240),
        Legendary = Color3.fromRGB(245, 178, 66),
        Exotic = Color3.fromRGB(240, 96, 140),
        Glorious = Color3.fromRGB(255, 214, 92),
        Mythical = Color3.fromRGB(255, 106, 61),
        Unique = Color3.fromRGB(120, 214, 255),
        Genuine = Color3.fromRGB(150, 200, 170),
        Unobtainable = Color3.fromRGB(110, 96, 140),
    }

    local function akiraSkinRarityColor(name)
        return AKIRA_SKIN_RARITY[name] or Color3.fromRGB(180, 186, 198)
    end

    local function akiraSkinSelectedWeapon()
        local w = AKIRA_SKIN_UI.Weapon and AKIRA_SKIN_UI.Weapon.State.Value
        if w and w ~= "None" then return w end
        return AKIRA_SKIN.LastUsedWeapon
    end

    local function akiraUiPanel(parent, name, pos, size)
        local panel = Instance.new("Frame")
        panel.Name = name
        panel.BackgroundColor3 = VM_PANEL
        panel.BorderSizePixel = 0
        panel.Position = pos
        panel.Size = size
        panel.ZIndex = 91
        panel.Parent = parent
        akiraUiRound(panel, 8)
        akiraUiStroke(panel, Color3.fromRGB(36, 38, 48), 1)
        return panel
    end

    local function akiraUiSearch(parent, pos, size, placeholder)
        local box = Instance.new("TextBox")
        box.Name = "Search"
        box.PlaceholderText = placeholder or "Search..."
        box.Text = ""
        box.ClearTextOnFocus = false
        box.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        box.TextColor3 = Color3.fromRGB(240, 240, 245)
        box.PlaceholderColor3 = Color3.fromRGB(112, 114, 126)
        box.Font = Enum.Font.Code
        box.TextSize = 11
        box.BorderSizePixel = 0
        box.Position = pos
        box.Size = size
        box.ZIndex = 92
        box.Parent = parent
        akiraUiRound(box, 5)
        return box
    end

    local function akiraUiScroller(parent, pos, size)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "Scroll"
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.Position = pos
        scroll.Size = size
        scroll.ScrollBarThickness = 4
        scroll.ScrollBarImageColor3 = Color3.fromRGB(88, 90, 104)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ZIndex = 92
        scroll.Parent = parent
        return scroll
    end

    function AKIRA_SKIN_UI.Build()
        if AKIRA_SKIN_UI.Built then return true end
        local live = shared.AkiraLite
        local win = type(live) == "table" and live.SkinsWindow or nil
        if not win then return false end
        shared.AkiraLiteSkinUI = AKIRA_SKIN_UI
        if not AKIRA_SKIN.Built then AKIRA_SKIN.BuildIndex() end
        AKIRA_SKIN.RefreshOwned()
        AKIRA_SKIN.Load()
        AKIRA_SKIN.Install()
        AKIRA_SKIN.InstallFinisher()
        AKIRA_SKIN.InstallCreateViewModel()
        AKIRA_SKIN.InstallOwnership()

        for _, child in ipairs(win:GetChildren()) do
            if child.Name ~= "SkinsWinStroke" and not child:IsA("UIScale") then
                child:Destroy()
            end
        end

        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 40)
        header.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        header.BorderSizePixel = 0
        header.ZIndex = 91
        header.Parent = win
        akiraUiRound(header, 8)

        local title = akiraUiMakeLabel(header, "SKIN CHANGER", 13, UDim2.new(0, 14, 0, 0), 260)
        title.ZIndex = 92
        title.Parent = header

        local hint = akiraUiMakeLabel(header, "", 10, UDim2.new(0, 140, 0, 3), 420)
        hint.TextColor3 = VM_MUTED
        hint.ZIndex = 92
        hint.Parent = header

        local ownedHolder = Instance.new("Frame")
        ownedHolder.Size = UDim2.fromOffset(150, 30)
        ownedHolder.Position = UDim2.new(1, -160, 0, 5)
        ownedHolder.BackgroundTransparency = 1
        ownedHolder.ZIndex = 92
        ownedHolder.Parent = header
        local ownedToggle = akiraUiMakeToggle(ownedHolder, "Owned only", 0, false, function(state)
            AKIRA_SKIN.OwnedOnly = state
            AKIRA_SKIN.RefreshOwned()
            AKIRA_SKIN_UI.RenderWeapons()
        end)
        ownedToggle.Holder.Size = UDim2.fromOffset(150, 30)
        ownedToggle.Holder.Position = UDim2.fromOffset(0, 0)

        local left = akiraUiPanel(win, "Weapons", UDim2.fromOffset(10, 48), UDim2.fromOffset(238, 382))
        akiraUiMakeLabel(left, "WEAPONS", 10, UDim2.new(0, 10, 0, 6), 200).ZIndex = 92
        local weaponScroll = akiraUiScroller(left, UDim2.fromOffset(8, 26), UDim2.new(1, -16, 1, -34))
        local weaponList = Instance.new("UIGridLayout")
        weaponList.CellSize = UDim2.fromOffset(70, 84)
        weaponList.CellPadding = UDim2.fromOffset(5, 5)
        weaponList.SortOrder = Enum.SortOrder.LayoutOrder
        weaponList.Parent = weaponScroll

        local right = akiraUiPanel(win, "Cosmetics", UDim2.fromOffset(256, 48), UDim2.new(1, -266, 0, 300))
        local tabRow = Instance.new("Frame")
        tabRow.Name = "TabRow"
        tabRow.BackgroundTransparency = 1
        tabRow.Size = UDim2.new(1, -16, 0, 24)
        tabRow.Position = UDim2.new(0, 8, 0, 8)
        tabRow.ZIndex = 92
        tabRow.Parent = right
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.FillDirection = Enum.FillDirection.Horizontal
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabLayout.Padding = UDim.new(0, 6)
        tabLayout.Parent = tabRow
        local sectionNames = {"Skin", "Wrap", "Charm", "Finisher"}
        local sectionButtons = {}
        for index, sectionName in ipairs(sectionNames) do
            local tabBtn = Instance.new("TextButton")
            tabBtn.Name = "Tab_" .. sectionName
            tabBtn.LayoutOrder = index
            tabBtn.Text = sectionName:upper()
            tabBtn.BackgroundColor3 = index == 1 and Color3.fromRGB(34, 36, 46) or VM_CARD
            tabBtn.TextColor3 = index == 1 and Color3.fromRGB(120, 235, 215) or Color3.fromRGB(168, 172, 186)
            tabBtn.Font = Enum.Font.Code
            tabBtn.TextSize = 10
            tabBtn.BorderSizePixel = 0
            tabBtn.Size = UDim2.new(0.25, -6, 1, 0)
            tabBtn.ZIndex = 92
            tabBtn.Parent = tabRow
            akiraUiRound(tabBtn, 5)
            sectionButtons[sectionName] = tabBtn
        end
        local tileScroll = akiraUiScroller(right, UDim2.new(0, 8, 0, 38), UDim2.new(1, -16, 1, -46))
        local tileGrid = Instance.new("UIGridLayout")
        tileGrid.CellSize = UDim2.fromOffset(96, 62)
        tileGrid.CellPadding = UDim2.fromOffset(6, 6)
        tileGrid.SortOrder = Enum.SortOrder.LayoutOrder
        tileGrid.Parent = tileScroll

        local actions = akiraUiPanel(win, "Actions", UDim2.fromOffset(256, 356), UDim2.new(1, -266, 0, 74))

        AKIRA_SKIN_UI.Section = "Skin"
        AKIRA_SKIN_UI.WeaponScroll = weaponScroll
        AKIRA_SKIN_UI.TileScroll = tileScroll
        AKIRA_SKIN_UI.Hint = hint

        local function currentWeapon()
            local w = AKIRA_SKIN_UI.Weapon
            if w and w ~= "None" then return w end
            return AKIRA_SKIN.LastUsedWeapon
        end

        function AKIRA_SKIN_UI.RenderWeapons()
            for _, child in ipairs(weaponScroll:GetChildren()) do
                if child:IsA("GuiButton") then child:Destroy() end
            end
            local accent = AKIRA_SKIN_UI.Accent or Color3.fromRGB(120, 235, 215)
            local current = AKIRA_SKIN_UI.Weapon
            local order = 0
            for _, weaponName in ipairs(AKIRA_SKIN.VisibleWeapons()) do
                order = order + 1
                local selected = (weaponName == current)
                local tile = Instance.new("TextButton")
                tile.Name = "W_" .. weaponName
                tile.LayoutOrder = order
                tile.Text = ""
                tile.AutoButtonColor = false
                tile.BackgroundColor3 = selected and Color3.fromRGB(34, 42, 52) or VM_CARD
                tile.BorderSizePixel = 0
                tile.Size = UDim2.fromOffset(70, 84)
                tile.ZIndex = 93
                tile.Parent = weaponScroll
                akiraUiRound(tile, 6)
                local edge = akiraUiStroke(tile, selected and accent or Color3.fromRGB(38, 40, 50), selected and 2 or 1)
                edge.Transparency = selected and 0 or 0.55

                local icon = Instance.new("ImageLabel")
                icon.Name = "Icon"
                icon.Image = AKIRA_SKIN.WeaponIcons[weaponName] or ""
                icon.BackgroundTransparency = 1
                icon.Size = UDim2.fromOffset(48, 48)
                icon.Position = UDim2.fromOffset(11, 6)
                icon.ScaleType = Enum.ScaleType.Fit
                icon.ZIndex = 94
                icon.Parent = tile
                if icon.Image == "" then
                    local fallback = Instance.new("TextLabel")
                    fallback.Name = "Fallback"
                    fallback.Text = weaponName:sub(1, 2):upper()
                    fallback.BackgroundTransparency = 1
                    fallback.Size = UDim2.fromOffset(48, 48)
                    fallback.Position = UDim2.fromOffset(11, 6)
                    fallback.TextColor3 = VM_MUTED
                    fallback.TextSize = 18
                    fallback.Font = Enum.Font.Code
                    fallback.ZIndex = 95
                    fallback.Parent = icon
                end

                local bar = Instance.new("TextLabel")
                bar.Name = "NameBar"
                bar.Text = weaponName
                bar.BackgroundColor3 = Color3.fromRGB(10, 11, 14)
                bar.BackgroundTransparency = 0.5
                bar.BorderSizePixel = 0
                bar.Size = UDim2.new(1, -6, 0, 18)
                bar.Position = UDim2.fromOffset(3, 61)
                bar.TextColor3 = selected and accent or VM_TEXT
                bar.TextSize = 9
                bar.TextTruncate = Enum.TextTruncate.AtEnd
                bar.Font = Enum.Font.Code
                bar.ZIndex = 95
                bar.Parent = tile
                akiraUiRound(bar, 4)

                tile.MouseEnter:Connect(function()
                    if not selected then tile.BackgroundColor3 = VM_CARD_HOVER end
                end)
                tile.MouseLeave:Connect(function()
                    if not selected then tile.BackgroundColor3 = VM_CARD end
                end)
                tile.MouseButton1Click:Connect(function()
                    AKIRA_SKIN_UI.Weapon = weaponName
                    AKIRA_SKIN_UI.RenderWeapons()
                    AKIRA_SKIN_UI.RenderTiles()
                end)
            end
        end
        function AKIRA_SKIN_UI.RenderTiles()
            for _, child in ipairs(tileScroll:GetChildren()) do
                if child:IsA("GuiButton") then child:Destroy() end
            end
            local section = AKIRA_SKIN_UI.Section or "Skin"
            local list
            if section == "Skin" then
                list = AKIRA_SKIN.SkinsForWeapon(currentWeapon())
            elseif section == "Wrap" then
                list = AKIRA_SKIN.Wraps
            elseif section == "Charm" then
                list = AKIRA_SKIN.Charms
            else
                list = AKIRA_SKIN.Finishers
            end
            local entry = currentWeapon() and AKIRA_SKIN.Selection[currentWeapon()] or nil
            local chosen = entry and entry[section] or nil
            local order = 0
            for _, rec in ipairs(list) do
                do
                    order = order + 1
                    local active = (rec.Name == chosen)
                    local accent = AKIRA_SKIN_UI.Accent or Color3.fromRGB(120, 235, 215)
                    local tile = Instance.new("TextButton")
                    tile.Name = "T_" .. rec.Name
                    tile.Text = ""
                    tile.LayoutOrder = order
                    tile.BackgroundColor3 = active and Color3.fromRGB(34, 42, 52) or VM_CARD
                    tile.BorderSizePixel = 0
                    tile.Size = UDim2.fromOffset(96, 62)
                    tile.ZIndex = 93
                    tile.Parent = tileScroll
                    akiraUiRound(tile, 6)
                    local edge = akiraUiStroke(tile, akiraSkinRarityColor(rec.Rarity), active and 2 or 1)
                    edge.Transparency = active and 0 or 0.45

                    local thumb = Instance.new("ImageLabel")
                    thumb.Name = "Icon"
                    thumb.Image = rec.Image or ""
                    thumb.BackgroundTransparency = 1
                    thumb.Size = UDim2.fromOffset(40, 40)
                    thumb.Position = UDim2.fromOffset(28, 5)
                    thumb.ZIndex = 94
                    thumb.Parent = tile
                    if rec.Image == nil or rec.Image == "" then
                        local fallback = Instance.new("TextLabel")
                        fallback.Name = "Fallback"
                        fallback.Text = rec.Name:sub(1, 2):upper()
                        fallback.BackgroundTransparency = 1
                        fallback.Size = UDim2.fromOffset(40, 40)
                        fallback.TextColor3 = akiraSkinRarityColor(rec.Rarity)
                        fallback.TextSize = 18
                        fallback.Font = Enum.Font.Code
                        fallback.ZIndex = 95
                        fallback.Parent = thumb
                    end

                    local caption = Instance.new("TextLabel")
                    caption.Name = "Caption"
                    caption.Text = rec.Name
                    caption.BackgroundTransparency = 1
                    caption.Size = UDim2.new(1, -6, 0, 14)
                    caption.Position = UDim2.fromOffset(3, 45)
                    caption.TextColor3 = active and accent or Color3.fromRGB(190, 194, 206)
                    caption.TextSize = 9
                    caption.TextTruncate = Enum.TextTruncate.AtEnd
                    caption.Font = Enum.Font.Code
                    caption.ZIndex = 94
                    caption.Parent = tile

                    tile.MouseEnter:Connect(function()
                        if not active then tile.BackgroundColor3 = VM_CARD_HOVER end
                    end)
                    tile.MouseLeave:Connect(function()
                        if not active then tile.BackgroundColor3 = VM_CARD end
                    end)
                    tile.MouseButton1Click:Connect(function()
                        local weapon = currentWeapon()
                        if not weapon then return end
                        local value = active and "None" or rec.Name
                        AKIRA_SKIN.SetCosmetic(weapon, section, value)
                        AKIRA_SKIN_UI.RenderTiles()
                    end)
                end
            end
            local weapon = currentWeapon()
            hint.Text = string.format(
                "%s  |  %d items  |  %d weapons  |  %d skins",
                weapon or "no weapon selected", order, #AKIRA_SKIN.WeaponOrder, #AKIRA_SKIN.Skins)
        end

        for sectionName, tabBtn in pairs(sectionButtons) do
            tabBtn.MouseButton1Click:Connect(function()
                AKIRA_SKIN_UI.Section = sectionName
                for other, btn in pairs(sectionButtons) do
                    local isActive = (other == sectionName)
                    btn.BackgroundColor3 = isActive and Color3.fromRGB(34, 36, 46) or VM_CARD
                    btn.TextColor3 = isActive and Color3.fromRGB(120, 235, 215) or Color3.fromRGB(168, 172, 186)
                end
                AKIRA_SKIN_UI.RenderTiles()
            end)
        end

        akiraUiMakeButton(actions, "Randomize this weapon", 8, function()
            local weapon = currentWeapon()
            if weapon and AKIRA_SKIN.RandomizeWeapon(weapon) then AKIRA_SKIN_UI.RenderTiles() end
        end)
        akiraUiMakeButton(actions, "Randomize ALL weapons", 38, function()
            task.spawn(function()
                AKIRA_SKIN.RandomizeAll()
                AKIRA_SKIN_UI.RenderTiles()
            end)
        end)
        akiraUiMakeButton(actions, "Reset everything", 8, function()
        end)
        local resetBtn = actions:FindFirstChild("Btn_Reset everything")
        if resetBtn then
            resetBtn.Position = UDim2.new(0.5, 6, 0, 38)
            resetBtn.Size = UDim2.new(0.5, -14, 0, 28)
            resetBtn.MouseButton1Click:Connect(function()
                AKIRA_SKIN.ClearAll()
                AKIRA_SKIN_UI.RenderTiles()
            end)
        end
        local randomAll = actions:FindFirstChild("Btn_Randomize ALL weapons")
        if randomAll then
            randomAll.Position = UDim2.new(0, 8, 0, 38)
            randomAll.Size = UDim2.new(0.5, -14, 0, 28)
        end
        local randomOne = actions:FindFirstChild("Btn_Randomize this weapon")
        if randomOne then
            randomOne.Size = UDim2.new(0.5, -14, 0, 28)
        end

        AKIRA_SKIN_UI.RenderWeapons()
        AKIRA_SKIN_UI.RenderTiles()
        AKIRA_SKIN_UI.Built = true
        return true
    end

    Viewmodel = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Viewmodel',
        Function = function(callback)
            if callback then
                if AkiraLite.ThreadFix then
                    pcall(setThreadIdentity, 8)
                end
                                     
                   
                                                                                
                                                                                  
                                                                                 
                                                                           
                                                                                    
                                                                   
                                                                                    
                                                                           
                                                                                    
                                                                                 
                                                                               
                                                                                   
                                                                                     
                                                                              
                                                                      
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
                    local armCol = type(ArmColor.Value) == "Color3" and ArmColor.Value or Color3.fromRGB(53, 215, 199)
                    local armTr = ArmTransparency.Value
                    local doWepChams = WeaponChamsToggle.Enabled
                    local wepMat = VM_MATERIALS[WeaponMaterial.Value] or Enum.Material.ForceField
                    local wepCol = type(WeaponColor.Value) == "Color3" and WeaponColor.Value or Color3.fromRGB(255, 110, 180)
                    local wepTr = WeaponTransparency.Value
                    local doStrip = DisableTextures.Enabled

                                                                                   
                                                                               
                                                                                   
                                                                                   
                                                                       
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
                                p.Color = (HitChamsColor and type(HitChamsColor.Value) == "Color3") and HitChamsColor.Value or Color3.fromRGB(255, 70, 70)
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

                                                                                       
                    AKIRA_VM_NOMOTION = not not (NoMotion and NoMotion.Enabled)

                    if NoMotion.Enabled then
                        ensureViewModelUpdateHook()
                                                                                      
                                                                                     
                                                                                 
                                                                 
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
        Decimal = 100,
        Darker = true
    })
    OffsetY = Viewmodel:AddSlider({
        Name = 'Offset Y',
        Min = -3,
        Max = 3,
        Default = 0,
        Decimal = 100,
        Darker = true
    })
    OffsetZ = Viewmodel:AddSlider({
        Name = 'Offset Z',
        Min = -3,
        Max = 3,
        Default = 0,
        Decimal = 100,
        Darker = true
    })

                                                                               
                                                    
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
    ArmColor = Viewmodel:AddColorPicker({
        Name = 'Arm Color',
        Default = Color3.fromRGB(53, 215, 199),
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
    WeaponColor = Viewmodel:AddColorPicker({
        Name = 'Weapon Color',
        Default = Color3.fromRGB(255, 110, 180),
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
    local SoundService = cloneref(game:GetService("SoundService"))
    local RunService = cloneref(game:GetService("RunService"))
    local Workspace = cloneref(game:GetService("Workspace"))

                                                   
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
        local haystack = tostring(text)
        local containsReal = (realName ~= "" and string.find(haystack, realName, 1, true) ~= nil)
            or (realDisplay ~= "" and string.find(haystack, realDisplay, 1, true) ~= nil)
        local containsIdentity = (type(username) == "string" and string.find(haystack, username, 1, true) ~= nil)
            or (type(displayName) == "string" and string.find(haystack, displayName, 1, true) ~= nil)
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
                        local equipped = fighter.EquippedItem
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
                                                                               
                                                                                 
                                                                                    
                                                                                 
                                                                               
                                                                             
                                                                         
        local objects = ref.Objects
        if not objects then
            return
        end
        local anyVisible = false
        for i = 1, #objects do
            local object = objects[i]
            if object and object.Visible then
                anyVisible = true
                break
            end
        end
        if not anyVisible then
            return
        end
        for i = 1, #objects do
            setVisible(objects[i], false)
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
                                                                                      
        if ent.__akiraEspHeight == nil then
            ent.__akiraEspHeight = Vector3.new(0, ent.HipHeight + 1, 0)
        end
        local bottom = project(root.Position - ent.__akiraEspHeight)
        local top = project(root.Position + ent.__akiraEspHeight)
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
local function akiraReferenceRagebot()
    local running = false
    local connections = {}
    local repS = cloneref(game:GetService("ReplicatedStorage"))
    local plrs = cloneref(game:GetService("Players"))
    local runS = cloneref(game:GetService("RunService"))
    local ws = cloneref(game:GetService("Workspace"))
    local uis = cloneref(game:GetService("UserInputService"))
    local lplr = plrs.LocalPlayer
    local util = require(repS.Modules.Utility)
    local enum = require(repS.Modules.EnumLibrary)
    local FighterController = require(lplr.PlayerScripts.Controllers.FighterController)
    local SpectateController = require(lplr.PlayerScripts.Controllers:WaitForChild("SpectateController"))

    local rgCfg = getgenv().Config
    if type(rgCfg) ~= "table" then
        rgCfg = {}
        getgenv().Config = rgCfg
    end
    if type(rgCfg.Enabled) ~= "boolean" then rgCfg.Enabled = true end
    if type(rgCfg.FireRate) ~= "number" then rgCfg.FireRate = 0.0005 end
    if type(rgCfg.WeaponSlot) ~= "string" then rgCfg.WeaponSlot = "Melee" end
    if rgCfg.__akiraSettings ~= AKIRA_SETTINGS_VERSION then
        rgCfg.__akiraSettings = AKIRA_SETTINGS_VERSION
        for key in pairs(rgCfg) do
            local name = tostring(key)
            if name:sub(1, 4) == "Rage" then
                rgCfg[key] = nil
            end
        end
    end
    if type(rgCfg.RageNoCooldowns) ~= "boolean" then rgCfg.RageNoCooldowns = true end
    if type(rgCfg.RageNoSpread) ~= "boolean" then rgCfg.RageNoSpread = true end
    if type(rgCfg.RageDesync) ~= "boolean" then rgCfg.RageDesync = true end
    if type(rgCfg.RageIgnoreDeflect) ~= "boolean" then rgCfg.RageIgnoreDeflect = true end
    if type(rgCfg.RageRequireInFOV) ~= "boolean" then rgCfg.RageRequireInFOV = false end
    if type(rgCfg.RageShowFOV) ~= "boolean" then rgCfg.RageShowFOV = true end
    if type(rgCfg.RageFOV) ~= "number" then rgCfg.RageFOV = 300 end
    if type(rgCfg.RageMinDist) ~= "number" then rgCfg.RageMinDist = 0 end
    if type(rgCfg.RageMaxDist) ~= "number" then rgCfg.RageMaxDist = 500 end
    if type(rgCfg.RageFireRate) ~= "number" then rgCfg.RageFireRate = 100 end
    if type(rgCfg.RageImmuneCheck) ~= "boolean" then rgCfg.RageImmuneCheck = true end
    if type(rgCfg.RageImmuneMemory) ~= "number" then rgCfg.RageImmuneMemory = 0.6 end
    if type(rgCfg.RageAutoEquip) ~= "boolean" then rgCfg.RageAutoEquip = true end
    if type(rgCfg.RageShotsPerTick) ~= "number" then rgCfg.RageShotsPerTick = 8 end
    if type(rgCfg.RagePrediction) ~= "number" then rgCfg.RagePrediction = 0 end
    if type(rgCfg.RageDesyncHeight) ~= "number" then rgCfg.RageDesyncHeight = 1 end
    if type(rgCfg.RageKnifeDesyncHeight) ~= "number" then rgCfg.RageKnifeDesyncHeight = 6 end
    if type(rgCfg.RageEquipInterval) ~= "number" then rgCfg.RageEquipInterval = 1 end
    if type(rgCfg.RageFOVThickness) ~= "number" then rgCfg.RageFOVThickness = 1 end
    if type(rgCfg.RageFOVTransparency) ~= "number" then rgCfg.RageFOVTransparency = 1 end
    if type(rgCfg.RageFOVFilled) ~= "boolean" then rgCfg.RageFOVFilled = false end
    if type(rgCfg.RageTeamCheck) ~= "boolean" then rgCfg.RageTeamCheck = false end
    if type(rgCfg.RageHitPart) ~= "string" then rgCfg.RageHitPart = "Head" end
    if type(rgCfg.RageDesyncMode) ~= "string" then rgCfg.RageDesyncMode = "Legit" end
    if type(rgCfg.RageFOVColor) ~= "Color3" then rgCfg.RageFOVColor = Color3.fromRGB(255, 60, 60) end

    local strippedCooldowns = nil
    local function stripCooldowns()
        if strippedCooldowns then return end
        local ok, ItemLibrary = pcall(function()
            return require(repS.Modules.ItemLibrary)
        end)
        if not ok or type(ItemLibrary) ~= "table" then return end
        local found = {}
        local keys = { "ShootCooldown", "BurstCooldown", "AttackCooldown", "HeavyAttackCooldown" }
        local function scan(tbl, depth)
            if depth > 6 then return end
            for _, v in pairs(tbl) do
                if type(v) == "table" then
                    for _, key in ipairs(keys) do
                        if v[key] ~= nil then
                            found[#found + 1] = { tbl = v, key = key, value = v[key] }
                            v[key] = 0.000000000000000001
                        end
                    end
                    scan(v, depth + 1)
                end
            end
        end
        scan(ItemLibrary, 0)
        strippedCooldowns = found
    end

    local function refreshCooldowns()
        if not strippedCooldowns then return end
        for i = 1, #strippedCooldowns do
            local entry = strippedCooldowns[i]
            entry.tbl[entry.key] = 0.000000000000000001
        end
    end

    local function clearOwnAttackCooldown()
        local localFighter = FighterController.LocalFighter
        if not localFighter then return end
        local item = localFighter.EquippedItem
        if type(item) ~= "table" then return end
        if item._attack_cooldown ~= nil then item._attack_cooldown = 0 end
        if type(item.CachedAttributes) == "table" then
            if item.CachedAttributes._attack_cooldown ~= nil then
                item.CachedAttributes._attack_cooldown = 0
            end
        end
    end

    local function restoreCooldowns()
        if not strippedCooldowns then return end
        for _, entry in ipairs(strippedCooldowns) do
            entry.tbl[entry.key] = entry.value
        end
        strippedCooldowns = nil
    end

    local spreadPatched = false
    local originalIsFullyAiming = nil
    local function applyNoSpread()
        if spreadPatched then return end
        local ok, gun = pcall(function()
            return require(lplr.PlayerScripts.Modules.ItemTypes.Gun)
        end)
        if not ok or type(gun) ~= "table" or type(gun.IsFullyAiming) ~= "function" then return end
        originalIsFullyAiming = gun.IsFullyAiming
        spreadPatched = true
        gun.IsFullyAiming = function()
            return true
        end
    end

    local function restoreNoSpread()
        if not spreadPatched then return end
        local ok, gun = pcall(function()
            return require(lplr.PlayerScripts.Modules.ItemTypes.Gun)
        end)
        if ok and type(gun) == "table" and originalIsFullyAiming then
            gun.IsFullyAiming = originalIsFullyAiming
        end
        originalIsFullyAiming = nil
        spreadPatched = false
    end

    local rageFOVCircle = nil
    local function updateRageFOVCircle()
        local cfg = getgenv().Config
        local want = cfg.RageRequireInFOV or cfg.RageShowFOV
        if not want then
            if rageFOVCircle then rageFOVCircle.Visible = false end
            return
        end
        if not rageFOVCircle then
            local ok, DrawingLib = pcall(function()
                return Drawing
            end)
            if not ok or type(DrawingLib) ~= "table" then return end
            rageFOVCircle = DrawingLib.new("Circle")
            rageFOVCircle.Thickness = 1
            rageFOVCircle.NumSides = 64
            rageFOVCircle.Filled = false
            rageFOVCircle.Transparency = 1
            rageFOVCircle.ZIndex = 1
            rageFOVCircle.Visible = false
        end
        local cam = workspace.CurrentCamera
        if not cam then
            rageFOVCircle.Visible = false
            return
        end
        rageFOVCircle.Position = cam.ViewportSize / 2
        rageFOVCircle.Radius = akiraNum(cfg.RageFOV, 300)
        local fcfg = getgenv().Config
        if fcfg.RageFOVColor then rageFOVCircle.Color = fcfg.RageFOVColor end
        if fcfg.RageFOVThickness then rageFOVCircle.Thickness = fcfg.RageFOVThickness end
        if fcfg.RageFOVTransparency then rageFOVCircle.Transparency = fcfg.RageFOVTransparency end
        if fcfg.RageFOVFilled ~= nil then rageFOVCircle.Filled = fcfg.RageFOVFilled end
        rageFOVCircle.Visible = running
    end

    local slots = {
        Primary = 1,
        Secondary = 2,
        Melee = 3
    }

    local function getSlotNumber()
        return slots[getgenv().Config.WeaponSlot] or 3
    end

    local function equippedItem()
        local localFighter = FighterController.LocalFighter
        if not localFighter then return nil end
        if localFighter.EquippedItem then return localFighter.EquippedItem end
        local wanted = localFighter.Data and localFighter.Data.EquippedItemID
        if wanted ~= nil and type(localFighter.Items) == "table" then
            for i = 1, #localFighter.Items do
                local item = localFighter.Items[i]
                local ok, id = pcall(function()
                    return item:Get("ObjectID")
                end)
                if ok and id == wanted then return item end
            end
        end
        if type(localFighter.Items) == "table" then
            return localFighter.Items[1]
        end
        return nil
    end

    local function equippedId(localFighter)
        return localFighter.Data and localFighter.Data.EquippedItemID
    end

    local equipDebug = { checks = 0, equips = 0, alreadyCorrect = 0, noFighter = 0, lastSlot = 0 }
    shared.__akiraEquip = equipDebug

    local function equippedId(localFighter)
        return localFighter.Data and localFighter.Data.EquippedItemID
    end

    local function slotItemId(localFighter, slot)
        if type(localFighter.Items) ~= "table" then return nil end
        local item = localFighter.Items[slot]
        if not item then return nil end
        local ok, id = pcall(function()
            return item:Get("ObjectID")
        end)
        if ok then return id end
        return nil
    end

    local function tryEquip()
        equipDebug.checks = equipDebug.checks + 1
        local localFighter = FighterController.LocalFighter
        if not localFighter then
            equipDebug.noFighter = equipDebug.noFighter + 1
            return false
        end
        local want = getSlotNumber()
        equipDebug.lastSlot = want
        local current = equippedId(localFighter)
        local wanted = slotItemId(localFighter, want)
        if wanted == nil then return current ~= nil end
        if current == wanted then
            equipDebug.alreadyCorrect = equipDebug.alreadyCorrect + 1
            return true
        end
        equipDebug.equips = equipDebug.equips + 1
        pcall(function()
            localFighter:EquipItem(want)
        end)
        local started = tick()
        while tick() - started < 0.6 do
            if equippedId(localFighter) ~= current then return true end
            task.wait(0.05)
        end
        return equippedId(localFighter) ~= current
    end

    local myEpoch = AKIRA_EPOCH
    task.spawn(function()
        local localFighter = FighterController.LocalFighter
        while not localFighter do
            task.wait(0.1)
            localFighter = FighterController.LocalFighter
        end
        local tries = 0
        while running and not tryEquip() and tries < 40 do
            if getgenv().__akiraEpoch ~= myEpoch then return end
            tries = tries + 1
            task.wait(0.25)
        end
    end)

    task.spawn(function()
        while getgenv().__akiraEpoch == myEpoch do
            task.wait(rgCfg.RageEquipInterval or 1)
            if not running then continue end
            if getgenv().Config.RageAutoEquip ~= false then
                tryEquip()
            end
        end
    end)

    local lastFire = 0
    local deflecting = {}
    table.insert(connections, plrs.PlayerRemoving:Connect(function(player)
        deflecting[player] = nil
    end))

    local function updateDeflection()
        if not FighterController or not FighterController.Objects then return end
        for _, fighterObj in FighterController.Objects do
            local player = fighterObj.Player
            if not player then continue end
            if not fighterObj.Entity or not fighterObj.Entity:IsAlive() or fighterObj:Get("IsSpectating") then
                deflecting[player] = false
                continue
            end
            local equipped = fighterObj.EquippedItem
            local isKatana = equipped and equipped.ViewModel and equipped.ViewModel.Name == "Katana"
            local isDeflecting = false
            if isKatana then
                isDeflecting = (equipped._attack_cooldown and equipped._attack_cooldown > tick()) or false
            end
            deflecting[player] = isDeflecting
        end
    end

    local function isEnemy(player)
        if player == lplr then return false end
        local duel = SpectateController.CurrentDuelSubject
        local localDueler = duel and duel:GetDueler(lplr)
        local localTeam = localDueler and localDueler:Get("TeamID") or nil
        if localTeam and duel and duel.Duelers then
            for _, dueler in duel.Duelers do
                if dueler.Player == player then
                    local team = dueler:Get("TeamID")
                    return team ~= localTeam
                end
            end
        end
        local pTeam = player:GetAttribute("TeamID")
        local lTeam = lplr:GetAttribute("TeamID")
        if pTeam and lTeam then
            return pTeam ~= lTeam
        end
        return true
    end

    local immuneUntil = {}
    local originalImmuneEffect = nil
    local immuneHookInstalled = false

    local function fighterFor(player)
        for _, f in ipairs(FighterController.Objects) do
            if f.Player == player then return f end
        end
        return nil
    end

    local function markImmune(player, seconds)
        if not player then return end
        local window = seconds
        if type(window) ~= "number" then
            window = getgenv().Config.RageImmuneMemory or 0.6
        end
        immuneUntil[player] = tick() + window
    end

    local function isImmuneTarget(player)
        if not getgenv().Config.RageImmuneCheck then return false end
        if not player then return false end
        local untilTick = immuneUntil[player]
        if untilTick then
            if tick() < untilTick then return true end
            immuneUntil[player] = nil
        end
        local fighterObj = fighterFor(player)
        if fighterObj then
            local cd = fighterObj.Data and fighterObj.Data.JoinCooldown
            if type(cd) == "number" and cd > os.time() then return true end
        end
        local char = player.Character
        if char and char:FindFirstChildOfClass("ForceField") then return true end
        return false
    end

    local shotHp = {}
    local shotAt = {}
    local healthChangedAt = {}
    local healthConns = {}
    local immuneDebug = { shots = 0, detected = 0, skipped = 0, damaged = 0 }
    shared.__akiraImmune = immuneDebug

    local function watchHealth(fighterObj)
        local player = fighterObj.Player
        if not player or healthConns[player] then return end
        if type(fighterObj.HealthChanged) ~= "table" then return end
        local ok, conn = pcall(function()
            return fighterObj.HealthChanged:Connect(function()
                healthChangedAt[player] = tick()
            end)
        end)
        if ok and conn then healthConns[player] = conn end
    end

    local function beginShotProbe(player)
        local fighterObj = fighterFor(player)
        if not fighterObj then return end
        watchHealth(fighterObj)
        immuneDebug.shots = immuneDebug.shots + 1
        if shotAt[player] then return end
        local ok, hp = pcall(function()
            return fighterObj:GetHealth()
        end)
        if not ok or type(hp) ~= "number" then return end
        shotHp[player] = hp
        shotAt[player] = tick()
    end

    local function reviewShotProbes()
        local nowTick = tick()
        for player, at in pairs(shotAt) do
            if nowTick - at <= 0.35 then continue end
            local before = shotHp[player]
            shotAt[player] = nil
            shotHp[player] = nil
            if not before then continue end
            local fighterObj = fighterFor(player)
            if not fighterObj then continue end
            local okAlive, alive = pcall(function()
                return fighterObj:IsAlive()
            end)
            if not (okAlive and alive) then continue end
            local changedAt = healthChangedAt[player]
            local tookDamage = changedAt ~= nil and changedAt >= at
            if tookDamage then
                immuneDebug.damaged = immuneDebug.damaged + 1
            else
                local okHp, hp = pcall(function()
                    return fighterObj:GetHealth()
                end)
                local noDrop = okHp and type(hp) == "number" and hp >= before
                if noDrop then
                    markImmune(player)
                    immuneDebug.detected = immuneDebug.detected + 1
                end
            end
        end
    end

    local function clearImmuneState()
        immuneUntil = {}
        shotHp = {}
        shotAt = {}
        healthChangedAt = {}
        for player, conn in pairs(healthConns) do
            pcall(function()
                conn:Disconnect()
            end)
            healthConns[player] = nil
        end
    end

    local function isTeammateRage(player)
        if not rgCfg.RageTeamCheck then return false end
        local a = player:GetAttribute("TeamID")
        local b = lplr:GetAttribute("TeamID")
        if a and b then return a == b end
        return false
    end

    local function rageAimPart(player, root, head)
        local mode = rgCfg.RageHitPart or "Head"
        local char = player.Character
        if not char then return head end
        if mode == "Closest" then
            local best, bestD = nil, math.huge
            local cam = workspace.CurrentCamera
            for _, child in char:GetDescendants() do
                if child:IsA("BasePart") then
                    local d = (child.Position - root.Position).Magnitude
                    if d < bestD then
                        bestD, best = d, child
                    end
                end
            end
            return best or head
        end
        if mode == "Random" then
            local pool = { "Head", "UpperTorso", "HumanoidRootPart" }
            return char:FindFirstChild(pool[math.random(1, #pool)], true) or head
        end
        return char:FindFirstChild(mode, true) or head
    end

    local function getClosestTarget()
        local char = lplr.Character
        if not char then return nil, nil, nil end
        local myRoot = char:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil, nil, nil end
        local closestPlayer = nil
        local closestRoot = nil
        local closestHead = nil
        local closestPart = nil
        local closestDist = 500
        for _, player in plrs:GetPlayers() do
            if not isEnemy(player) then continue end
            if isTeammateRage(player) then continue end
            if isImmuneTarget(player) then continue end
            local pChar = player.Character
            if not pChar then continue end
            local pRoot = pChar:FindFirstChild("HumanoidRootPart")
            local pHead = pChar:FindFirstChild("Head")
            local pHum = pChar:FindFirstChildWhichIsA("Humanoid")
            if not (pRoot and pHead and pHum and pHum.Health > 0) then continue end
            local dist = (myRoot.Position - pRoot.Position).Magnitude
            local rcfg = getgenv().Config
            if type(rcfg.RageMaxDist) == "number" and dist > rcfg.RageMaxDist then continue end
            if type(rcfg.RageMinDist) == "number" and dist < rcfg.RageMinDist then continue end
            if rcfg.RageRequireInFOV then
                local cam = workspace.CurrentCamera
                if not cam then continue end
                local sp, onScreen = cam:WorldToViewportPoint(pRoot.Position)
                if not onScreen then continue end
                local centre = cam.ViewportSize / 2
                if (Vector2.new(sp.X, sp.Y) - centre).Magnitude > akiraNum(rcfg.RageFOV, 300) then continue end
            end
            if dist < closestDist then
                closestDist = dist
                closestPlayer = player
                closestRoot = pRoot
                closestHead = pHead
                closestPart = rageAimPart(player, pRoot, pHead)
            end
        end
        return closestPlayer, closestRoot, closestHead, closestPart
    end

    local function hasKnifeViewModel(targetPlayer)
        if not targetPlayer then return false end
        local viewModels = ws:FindFirstChild("ViewModels")
        if not viewModels then return false end
        local targetName = targetPlayer.Name
        for _, model in viewModels:GetChildren() do
            if model:IsA("Model")
                and string.find(model.Name, targetName, 1, true)
                and string.find(model.Name, "Knife", 1, true) then
                return true
            end
        end
        return false
    end

    table.insert(connections, runS.Heartbeat:Connect(function()
        if not running then return end
        akiraSanitizeConfig()
        refreshCooldowns()
        clearOwnAttackCooldown()
        reviewShotProbes()
        updateRageFOVCircle()
        updateDeflection()
        local targetPlayer, targetRoot, targetHead, targetPart = getClosestTarget()
        local desyncCF = nil

        if targetRoot and targetHead then
            local desyncPos
            if getgenv().Config.RageDesyncMode == "Aggressive" then
                desyncPos = targetRoot.Position
            elseif hasKnifeViewModel(targetPlayer) then
                desyncPos = (targetRoot.CFrame * CFrame.new(0, rgCfg.RageKnifeDesyncHeight or 6, 0)).Position
            else
                desyncPos = (targetRoot.CFrame * CFrame.new(0, rgCfg.RageDesyncHeight or 1, 2)).Position
            end
            desyncCF = CFrame.lookAt(desyncPos, targetHead.Position)
        end

        if getgenv().Config.RageDesync ~= false and desyncCF and lplr.Character then
            local myRoot = lplr.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local oldCF = myRoot.CFrame
                local oldVel = myRoot.Velocity
                local oldRotVel = myRoot.RotVelocity
                myRoot.CFrame = desyncCF
                runS:BindToRenderStep("__restore", 101, function()
                    if myRoot then
                        myRoot.CFrame = oldCF
                        myRoot.Velocity = oldVel
                        myRoot.RotVelocity = oldRotVel
                    end
                    runS:UnbindFromRenderStep("__restore")
                end)
            end
        end

        if not getgenv().Config.Enabled then return end
        if not targetPlayer or not targetHead or not targetRoot then return end
        if not getgenv().Config.RageIgnoreDeflect and deflecting[targetPlayer] then return end
        if not lplr.Character or not lplr.Character:FindFirstChild("HumanoidRootPart") then return end
        if not FighterController or not FighterController.LocalFighter then return end
        local item = equippedItem()
        if not item then return end
        if tick() - lastFire < (getgenv().Config.FireRate or 0.0005) then return end
        lastFire = tick()
        local burst = math.clamp(math.floor(rgCfg.RageShotsPerTick or 1), 1, 64)
        local originPos = desyncCF and desyncCF.Position or targetRoot.Position
        local targetPos = (targetPart or targetHead).Position
    local rpred = rgCfg.RagePrediction or 0
    if rpred > 0 and targetRoot then
        local rvel = targetRoot.AssemblyLinearVelocity or Vector3.zero
        targetPos = targetPos + rvel * (0.06 * rpred)
    end
        local aimCF = CFrame.lookAt(originPos, targetPos)
        local targetCF = targetHead.CFrame
        local randomOffset = Vector3.new(
            (math.random() - 0.5) * 0.1,
            (math.random() - 0.5) * 0.1,
            (math.random() - 0.5) * 0.1
        )
        local aimedPos = targetPos + randomOffset
        local objSpaceHeadOffset = targetHead.CFrame:ToObjectSpace(CFrame.new(aimedPos))
        local cameradata = {}
        cameradata[utf8.char(1)] = {
            [utf8.char(0)] = util:EncodeCFrame(aimCF),
            [utf8.char(1)] = util:EncodeCFrame(targetCF),
            [utf8.char(2)] = targetHead,
            [utf8.char(3)] = util:EncodeCFrame(objSpaceHeadOffset)
        }
        for shot = 1, burst do
            repS.Remotes.Replication.Fighter.UseItem:FireServer(
                item:Get("ObjectID"),
                enum:ToEnum("StartShooting"),
                cameradata,
                nil
            )
        end
        if targetPlayer then beginShotProbe(targetPlayer) end
    end))

    return {
        Start = function()
            running = true
            getgenv().Config.Enabled = true
            if getgenv().Config.RageNoCooldowns then stripCooldowns() end
            if getgenv().Config.RageNoSpread then applyNoSpread() end
            updateRageFOVCircle()
        end,
        Stop = function()
            running = false
            getgenv().Config.Enabled = false
            restoreCooldowns()
            restoreNoSpread()
            clearImmuneState()
            if rageFOVCircle then rageFOVCircle.Visible = false end
        end,
        IsRunning = function()
            return running
        end,
        Connections = connections,
    }
end
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
                                                                                
                                                                            
                                                                                  
                                                                                 
                                                                                 
                                                            
        local registry = type(AkiraLite) == "table" and AkiraLite.Targets or nil
        if type(registry) == "table" then
            local best
            local bestAt
            for _, source in ipairs(AKIRA_TARGET_SOURCES or {}) do
                local entry = registry[source]
                if type(entry) == "table"
                    and typeof(entry.Player) == "Instance"
                    and entry.Player.Parent ~= nil then
                                                                               
                                                                                  
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
    local fighter = controller and controller.LocalFighter or nil
    if type(fighter) == "table" then
        local item = fighter.EquippedItem
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
    local viewModel = item.ViewModel
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
        local vm = type(item) == "table" and (item.ViewModel or item._viewModel) or nil
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
run(function()
    do
        local previous = rawget(shared, "__akiraRagebotHandle")
        if type(previous) == "table" then
            pcall(function()
                if type(previous.Stop) == "function" then previous.Stop() end
            end)
            if type(previous.Connections) == "table" then
                for i = 1, #previous.Connections do
                    pcall(function()
                        previous.Connections[i]:Disconnect()
                    end)
                end
            end
        end
        do
            local previousSilent = rawget(shared, "__akiraSilentAimHandle")
            if type(previousSilent) == "table" then
                pcall(function()
                    if type(previousSilent.Stop) == "function" then previousSilent.Stop() end
                end)
                if type(previousSilent.Connections) == "table" then
                    for i = 1, #previousSilent.Connections do
                        pcall(function()
                            previousSilent.Connections[i]:Disconnect()
                        end)
                    end
                end
            end
        end
    end
    akiraRagebotRef = akiraReferenceRagebot()
    shared.__akiraRagebotHandle = akiraRagebotRef
    local Ragebot = AkiraLite.Catalogs.Combat:AddModule({
        Name = 'Ragebot',
        Function = function(callback)
            if not akiraRagebotRef then return end
            if callback then
                akiraRagebotRef.Start()
            else
                akiraRagebotRef.Stop()
            end
        end
    })
    Ragebot:AddDropdown({
        Name = 'Weapon Slot',
        List = { 'Primary', 'Secondary', 'Melee' },
        Default = 'Melee',
        Darker = true,
        Function = function(val)
            getgenv().Config.WeaponSlot = val
        end
    })
    Ragebot:AddSlider({
        Name = 'Fire Rate',
        Min = 1,
        Max = 100,
        Default = 100,
        Decimal = 1,
        Darker = true,
        Suffix = 'x',
        Function = function(val)
            getgenv().Config.RageFireRate = val
            getgenv().Config.FireRate = 0.0005 * (100 / val)
        end
    })
    Ragebot:AddSlider({
        Name = 'Shots Per Tick',
        Min = 1,
        Max = 64,
        Default = 8,
        Decimal = 1,
        Darker = true,
        Suffix = 'x',
        Function = function(val)
            getgenv().Config.RageShotsPerTick = val
        end
    })
    Ragebot:AddToggle({
        Name = 'No Cooldowns',
        Default = true,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageNoCooldowns = val
        end
    })
    Ragebot:AddToggle({
        Name = 'No Spread',
        Default = true,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageNoSpread = val
        end
    })
    Ragebot:AddToggle({
        Name = 'Desync',
        Default = true,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageDesync = val
        end
    })
    Ragebot:AddToggle({
        Name = 'Ignore Deflecting',
        Default = true,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageIgnoreDeflect = val
        end
    })
    Ragebot:AddToggle({
        Name = 'Require in FOV',
        Default = false,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageRequireInFOV = val
        end
    })
    Ragebot:AddToggle({
        Name = 'Show FOV',
        Default = true,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageShowFOV = val
        end
    })
    Ragebot:AddSlider({
        Name = 'FOV Size',
        Min = 10,
        Max = 2000,
        Default = 300,
        Decimal = 1,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageFOV = val
        end
    })
    Ragebot:AddSlider({
        Name = 'Min Distance',
        Min = 0,
        Max = 2000,
        Default = 0,
        Decimal = 1,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageMinDist = val
        end
    })
    Ragebot:AddSlider({
        Name = 'Max Distance',
        Min = 0,
        Max = 2000,
        Default = 500,
        Decimal = 1,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageMaxDist = val
        end
    })
    Ragebot:AddDropdown({
        Name = 'Hit Part',
        List = { 'Head', 'UpperTorso', 'HumanoidRootPart', 'Closest', 'Random' },
        Default = 'Head',
        Darker = true,
        Function = function(val)
            getgenv().Config.RageHitPart = val
        end
    })
    Ragebot:AddDropdown({
        Name = 'Desync Mode',
        List = { 'Legit', 'Aggressive', 'Off' },
        Default = 'Legit',
        Darker = true,
        Function = function(val)
            getgenv().Config.RageDesyncMode = val
        end
    })
    Ragebot:AddSlider({
        Name = 'Prediction',
        Min = 0,
        Max = 20,
        Default = 0,
        Decimal = 1,
        Darker = true,
        Function = function(val)
            getgenv().Config.RagePrediction = val
        end
    })
    Ragebot:AddSlider({
        Name = 'Desync Height',
        Min = -5,
        Max = 15,
        Default = 1,
        Decimal = 100,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageDesyncHeight = val
        end
    })
    Ragebot:AddSlider({
        Name = 'Knife Desync Height',
        Min = -5,
        Max = 15,
        Default = 6,
        Decimal = 100,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageKnifeDesyncHeight = val
        end
    })
    Ragebot:AddSlider({
        Name = 'Equip Interval',
        Min = 1,
        Max = 10,
        Default = 1,
        Decimal = 1,
        Darker = true,
        Suffix = 's',
        Function = function(val)
            getgenv().Config.RageEquipInterval = val
        end
    })
    Ragebot:AddToggle({
        Name = 'Team Check',
        Default = false,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageTeamCheck = val
        end
    })
    Ragebot:AddToggle({
        Name = 'Auto Equip',
        Default = true,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageAutoEquip = val
        end
    })
    Ragebot:AddToggle({
        Name = 'Immune Check',
        Default = true,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageImmuneCheck = val
        end
    })
    Ragebot:AddSlider({
        Name = 'Immune Memory',
        Min = 0.1,
        Max = 5,
        Default = 0.6,
        Decimal = 100,
        Darker = true,
        Suffix = 's',
        Function = function(val)
            getgenv().Config.RageImmuneMemory = val
        end
    })
    Ragebot:AddToggle({
        Name = 'Filled FOV',
        Default = false,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageFOVFilled = val
        end
    })
    Ragebot:AddSlider({
        Name = 'FOV Thickness',
        Min = 0.5,
        Max = 6,
        Default = 1,
        Decimal = 1,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageFOVThickness = val
        end
    })
    Ragebot:AddSlider({
        Name = 'FOV Transparency',
        Min = 0,
        Max = 1,
        Default = 1,
        Decimal = 100,
        Darker = true,
        Function = function(val)
            getgenv().Config.RageFOVTransparency = val
        end
    })
    Ragebot:AddColorPicker({
        Name = 'FOV Colour',
        Default = Color3.fromRGB(255, 60, 60),
        Darker = true,
        Function = function(val)
            getgenv().Config.RageFOVColor = val
        end
    })
end)

run(function()
    akiraSilentAimRef = akiraReferenceSilentAim()
    shared.__akiraSilentAimHandle = akiraSilentAimRef
    local SilentAim = AkiraLite.Catalogs.Combat:AddModule({
        Name = 'Silent Aim',
        Function = function(callback)
            if not akiraSilentAimRef then return end
            if callback then
                akiraSilentAimRef.Start()
            else
                akiraSilentAimRef.Stop()
            end
        end
    })
    SilentAim:AddDropdown({
        Name = 'Hit Part',
        List = { 'Head', 'UpperTorso', 'LowerTorso', 'HumanoidRootPart', 'Closest', 'Random' },
        Default = 'Head',
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentHitPart = val
            getgenv().Config.HitPart = val
        end
    })
    SilentAim:AddDropdown({
        Name = 'Target Mode',
        List = { 'Closest', 'Random' },
        Default = 'Closest',
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentTargetMode = val
        end
    })
    SilentAim:AddSlider({
        Name = 'FOV Size',
        Min = 10,
        Max = 2000,
        Default = 300,
        Decimal = 1,
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentFOV = val
            getgenv().Config.FOVRadius = val
        end
    })
    SilentAim:AddSlider({
        Name = 'Hit Chance',
        Min = 0,
        Max = 100,
        Default = 100,
        Decimal = 1,
        Darker = true,
        Suffix = '%',
        Function = function(val)
            getgenv().Config.SilentHitChance = val
        end
    })
    SilentAim:AddSlider({
        Name = 'Smoothing',
        Min = 0,
        Max = 100,
        Default = 0,
        Decimal = 1,
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentSmoothing = val
        end
    })
    SilentAim:AddSlider({
        Name = 'Delay',
        Min = 0,
        Max = 500,
        Default = 0,
        Decimal = 1,
        Darker = true,
        Suffix = 'ms',
        Function = function(val)
            getgenv().Config.SilentDelay = val
        end
    })
    SilentAim:AddToggle({
        Name = 'Show FOV',
        Default = true,
        Darker = true,
        Function = function(val)
            getgenv().Config.ShowFOV = val
        end
    })
    SilentAim:AddDropdown({
        Name = 'Part Priority',
        List = { 'Head', 'UpperTorso', 'HumanoidRootPart' },
        Default = 'Head',
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentPartPriority = val
        end
    })
    SilentAim:AddSlider({
        Name = 'Prediction',
        Min = 0,
        Max = 20,
        Default = 0,
        Decimal = 1,
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentPrediction = val
        end
    })
    SilentAim:AddSlider({
        Name = 'Max Distance',
        Min = 0,
        Max = 2000,
        Default = 500,
        Decimal = 1,
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentMaxDist = val
        end
    })
    SilentAim:AddSlider({
        Name = 'Distance Falloff',
        Min = 0,
        Max = 100,
        Default = 0,
        Decimal = 1,
        Darker = true,
        Suffix = '%',
        Function = function(val)
            getgenv().Config.SilentFalloff = val
        end
    })
    SilentAim:AddSlider({
        Name = 'Random Part Chance',
        Min = 0,
        Max = 100,
        Default = 0,
        Decimal = 1,
        Darker = true,
        Suffix = '%',
        Function = function(val)
            getgenv().Config.SilentPartRandomChance = val
        end
    })
    SilentAim:AddToggle({
        Name = 'Wall Check',
        Default = false,
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentWallCheck = val
        end
    })
    SilentAim:AddToggle({
        Name = 'Team Check',
        Default = false,
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentTeamCheck = val
        end
    })
    SilentAim:AddSlider({
        Name = 'FOV Thickness',
        Min = 0.5,
        Max = 6,
        Default = 1,
        Decimal = 1,
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentFOVThickness = val
        end
    })
    SilentAim:AddSlider({
        Name = 'FOV Transparency',
        Min = 0,
        Max = 1,
        Default = 1,
        Decimal = 100,
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentFOVTransparency = val
        end
    })
    SilentAim:AddColorPicker({
        Name = 'FOV Colour',
        Default = Color3.fromRGB(255, 255, 255),
        Darker = true,
        Function = function(val)
            getgenv().Config.SilentFOVColor = val
        end
    })
end)

    akiraMark("block39:done")


if type(AkiraLite.Commit) == "function" then
    pcall(function()
        return AkiraLite:Commit()
    end)
end
AkiraLite.UniversalStatus = featureStatus
return featureStatus
