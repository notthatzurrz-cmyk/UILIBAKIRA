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
local run = function(func)
    func()
end
local AkiraLiteFile = shared.AkiraLiteFile
local entitylib = AkiraLiteFile.loadfile("AkiraLite/Library/Entity.lua")
local prediction = AkiraLiteFile.loadfile("AkiraLite/Library/Prediction.lua")
local getfontsize = AkiraLite.Libraries.getfontsize
local addGradient = AkiraLite.Libraries.addGradient
local Targetinfo = AkiraLite.Libraries.Targetinfo
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
local function canClick()
    local mousepos = (UserInputService:GetMouseLocation() - GuiService:GetGuiInset())
    for _, v in lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y) do
        local obj = v:FindFirstAncestorOfClass('ScreenGui')
        if v.Active and v.Visible and obj and obj.Enabled then
            return false
        end
    end
    for _, v in CoreGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y) do
        local obj = v:FindFirstAncestorOfClass('ScreenGui')
        if v.Active and v.Visible and obj and obj.Enabled then
            return false
        end
    end
    return (not AkiraLite.ClickGuiStatus) and (not UserInputService:GetFocusedTextBox())
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
run(function()
    AkiraLite:Clean(entitylib.Events.LocalAdded:Connect(updateVelocity))
    AkiraLite:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
        gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
    end))
end)
entitylib.start()
repeat
    task.wait()
until game:IsLoaded()
local TargetStrafeVector
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
    local CircleRender
    local RightClick
    local ShowTarget
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
                AimAssist:Clean(RunService.RenderStepped:Connect(function(dt)
                    if CircleObject then
                        CircleObject.Position = UserInputService:GetMouseLocation()
                    end
                    if rightClicked and not AkiraLite.ClickGuiStatus then
                        ent = entitylib.EntityMouse({
                            Range = FOV.Value,
                            Part = Part.Value,
                            Players = true,
                            NPCs = false,
                            Wallcheck = true,
                            Origin = gameCamera.CFrame.Position
                        })
                        if ent then
                            local facing = gameCamera.CFrame.LookVector
                            local new = (ent[Part.Value].Position - gameCamera.CFrame.Position).Unit
                            new = new == new and new or Vector3.zero
                            if ShowTarget.Enabled then
                                Targetinfo.Targets[ent] = tick() + 1
                            end
                            if new ~= Vector3.zero then
                                local diffYaw = wrapAngle(math.atan2(facing.X, facing.Z) - math.atan2(new.X, new.Z))
                                local diffPitch = math.asin(facing.Y) - math.asin(new.Y)
                                local angle = Vector2.new(diffYaw, diffPitch) // (moveConst * UserSettings():GetService('UserGameSettings').MouseSensitivity)
                                angle *= math.min(Speed.Value * dt, 1)
                                mousemoverel(angle.X, angle.Y)
                            end
                        end
                    end
                end))
                if RightClick.Enabled then
                    AimAssist:Clean(UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton2 then
                            ent = nil
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
                CircleObject.Transparency = 0.5
                CircleRender = RunService.RenderStepped:Connect(function()
                    if CircleObject then
                        CircleObject.Position = UserInputService:GetMouseLocation()
                        CircleObject.Radius = FOV.Value
                        CircleObject.Filled = CircleFilled.Enabled
                        CircleObject.Visible = AimAssist.Enabled
                    end
                end)
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
    CircleFilled = AimAssist:AddToggle({
        Name = 'Circle Filled',
        Function = function(callback)
            if CircleObject then
                CircleObject.Filled = callback
            end
        end,
        Darker = true,
        Visible = false
    })
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
end)
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
            frictionTable.Speed = callback and CustomProperties.Enabled or nil
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
    CustomProperties = Speed:AddToggle({
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
                setthreadidentity(8)
            end
            Strings[ent] = ent.Player and (DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
            if Health.Enabled then
                local healthColor = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
                Strings[ent] = Strings[ent] .. ' <font color="rgb(' .. tostring(math.floor(healthColor.R * 255)) .. ',' .. tostring(math.floor(healthColor.G * 255)) .. ',' .. tostring(math.floor(healthColor.B * 255)) .. ')">' .. math.round(ent.Health) .. '</font>'
            end
            if Distance.Enabled then
                Strings[ent] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> ' .. Strings[ent]
            end
            local nametag = Instance.new('TextLabel')
            nametag.TextSize = 14 * Scale.Value
            nametag.FontFace = AkiraLite.Libraries.uipallet.Font
            nametag.ZIndex = - 1
            local ize = getfontsize(removeTags(Strings[ent]), nametag.TextSize, AkiraLite.Libraries.uipallet.Font, Vector2.new(100000, 100000))
            nametag.Name = ent.Player and ent.Player.Name or ent.Character.Name
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
                setthreadidentity(8)
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
            Strings[ent] = ent.Player and (DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
            if Health.Enabled then
                Strings[ent] = Strings[ent] .. ' ' .. math.round(ent.Health)
            end
            if Distance.Enabled then
                Strings[ent] = '[%s] ' .. Strings[ent]
            end
            nametag.Text.Text = Strings[ent]
            nametag.Text.Color = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
            nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
            Reference[ent] = nametag
        end
    }
    local Removed = {
        Normal = function(ent)
            local v = Reference[ent]
            if v then
                if AkiraLite.ThreadFix then
                    setthreadidentity(8)
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
                    setthreadidentity(8)
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
                    setthreadidentity(8)
                end
                Sizes[ent] = nil
                Strings[ent] = ent.Player and (DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
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
                    setthreadidentity(8)
                end
                Sizes[ent] = nil
                Strings[ent] = ent.Player and (DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
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
                nametag.Text.Color = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
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
            for ent, nametag in Reference do
                if DistanceCheck.Enabled then
                    local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
                    if distance > DistanceLimit.Value then
                        nametag.Visible = false
                        continue
                    end
                end
                local headPos, headVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position + Vector3.new(0, ent.HipHeight + 1, 0))
                nametag.Visible = headVis
                if not headVis then
                    continue
                end
                if Distance.Enabled then
                    local mag = entitylib.isAlive and math.floor((entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude) or 0
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
            for ent, nametag in Reference do
                if DistanceCheck.Enabled then
                    local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
                    if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
                        nametag.Text.Visible = false
                        nametag.BG.Visible = false
                        continue
                    end
                end
                local headPos, headVis = gameCamera:WorldToScreenPoint(ent.RootPart.Position + Vector3.new(0, ent.HipHeight + 1, 0))
                nametag.Text.Visible = headVis
                nametag.BG.Visible = headVis
                if not headVis then
                    continue
                end
                if Distance.Enabled then
                    local mag = entitylib.isAlive and math.floor((entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude) or 0
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
run(function()
    local Timer
    local Value
    Timer = AkiraLite.Catalogs.Player:AddModule({
        Name = 'Timer',
        Function = function(callback)
            if callback then
                setfflag('SimEnableStepPhysics', 'True')
                setfflag('SimEnableStepPhysicsSelective', 'True')
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
local visited, attempted, tpSwitch = {}, {}, false
local cacheExpire, cache = tick()
local function serverHop(pointer, filter)
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
    local data = suc and httpService:JSONDecode(httpdata) or nil
    if data and data.data then
        for _, v in data.data do
            if tonumber(v.playing) < Players.MaxPlayers and not table.find(visited, v.id) and not table.find(attempted, v.id) then
                cacheExpire, cache = tick() + 60, httpdata
                table.insert(attempted, v.id)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id)
                return
            end
        end
        if data.nextPageCursor then
            serverHop(data.nextPageCursor, filter)
        else
        end
    else
    end
end
run(function()
    local StaffDetector
    local Mode
    local Profile
    local Users
    local Group
    local Role
    local function getRole(plr, id)
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
    local function playerAdded(plr)
        if not AkiraLite.Loaded then
            repeat
                task.wait()
            until AkiraLite.Loaded
        end
        if getRole(plr, 0) >= 1 then
            if Mode.Value == 'Uninject' then
                task.spawn(function()
                    AkiraLite:Uninject()
                end)
                game:GetService('StarterGui'):SetCore('SendNotification', {
                    Title = 'StaffDetector',
                    Text = 'Staff Detected\n' .. plr.Name,
                    Duration = 60,
                })
            elseif Mode.Value == 'ServerHop' then
                serverHop()
            end
        end
    end
    StaffDetector = AkiraLite.Catalogs.Player:AddModule({
        Name = 'StaffDetector',
        Function = function(callback)
            if callback then
                local placeinfo = MarketplaceService:GetProductInfo(game.PlaceId)
                if placeinfo.Creator.CreatorType ~= 'Group' then
                    local desc = placeinfo.Description:split('\n')
                    for _, str in desc do
                        local _, begin = str:find('roblox.com/groups/')
                        if begin then
                            local endof = str:find('/', begin + 1)
                            placeinfo = {
                                Creator = {
                                    CreatorType = 'Group',
                                    CreatorTargetId = str:sub(begin + 1, endof - 1)
                                }
                            }
                        end
                    end
                    if placeinfo.Creator.CreatorType ~= 'Group' then
                        return
                    end
                    local groupinfo = GroupService:GetGroupInfoAsync(placeinfo.Creator.CreatorTargetId)
                    Group:SetValue(placeinfo.Creator.CreatorTargetId)
                    Role:SetValue(getLowestStaffRole(groupinfo.Roles))
                end
                StaffDetector:Clean(Players.PlayerAdded:Connect(playerAdded))
                for _, v in Players:GetPlayers() do
                    task.spawn(playerAdded, v)
                end
            end
        end
    })
    Mode = StaffDetector:AddDropdown({
        Name = 'Mode',
        List = {'Uninject', 'ServerHop', 'Notify'}
    })
end)
run(function()
    local Freecam
    local Value
    local randomkey, module, old = HttpService:GenerateGUID(false)
    Freecam = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Freecam',
        Function = function(callback)
            if callback then
                repeat
                    task.wait(0.1)
                    for _, v in getconnections(gameCamera:GetPropertyChangedSignal('CameraType')) do
                        if v.Function then
                            module = debug.getupvalue(v.Function, 1)
                        end
                    end
                until module or not Freecam.Enabled
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
run(function()
    local Chams
    local Targets
    local Mode
    local FillColor
    local OutlineColor
    local FillTransparency
    local OutlineTransparency
    local Teammates
    local Walls
    local Reference = {}
    local Folder = Instance.new('Folder')
    Folder.Parent = AkiraLite.MainScreenGui
    local function Added(ent)
        if not ent.Player then
            return
        end
        if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then
            return
        end
        if AkiraLite.ThreadFix then
            setthreadidentity(8)
        end
        if Mode.Value == 'Highlight' then
            local cham = Instance.new('Highlight')
            cham.Adornee = ent.Character
            cham.DepthMode = Enum.HighlightDepthMode[Walls.Enabled and 'AlwaysOnTop' or 'Occluded']
            cham.FillColor = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
            cham.OutlineColor = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
            cham.FillTransparency = FillTransparency.Value
            cham.OutlineTransparency = OutlineTransparency.Value
            cham.Parent = Folder
            Reference[ent] = cham
        else
            local chams = {}
            for _, v in ent.Character:GetChildren() do
                if v:IsA('BasePart') and (ent.NPC or v.Name:find('Arm') or v.Name:find('Leg') or v.Name:find('Hand') or v.Name:find('Feet') or v.Name:find('Torso') or v.Name == 'Head') then
                    local box = Instance.new(v.Name == 'Head' and 'SphereHandleAdornment' or 'BoxHandleAdornment')
                    if v.Name == 'Head' then
                        box.Radius = 0.75
                    else
                        box.Size = v.Size
                    end
                    box.AlwaysOnTop = Walls.Enabled
                    box.Adornee = v
                    box.ZIndex = 0
                    box.Transparency = FillTransparency.Value
                    box.Color3 = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
                    box.Parent = Folder
                    table.insert(chams, box)
                end
            end
            Reference[ent] = chams
        end
    end
    local function Removed(ent)
        if Reference[ent] then
            if AkiraLite.ThreadFix then
                setthreadidentity(8)
            end
            if type(Reference[ent]) == 'table' then
                for _, v in Reference[ent] do
                    v:Destroy()
                end
                table.clear(Reference[ent])
            else
                Reference[ent]:Destroy()
            end
            Reference[ent] = nil
        end
    end
    local function Looped()
        for ent, ref in next, Reference do
            if AkiraLite.ThreadFix then
                setthreadidentity(8)
            end
            if type(ref) == 'table' then
                for _, v in ref do
                    if v:IsA('SphereHandleAdornment') or v:IsA('BoxHandleAdornment') then
                        v.Color3 = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
                    end
                end
            else
                ref.FillColor = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
                ref.OutlineColor = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
            end
        end
    end
    Chams = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Chams',
        Function = function(callback)
            if callback then
                Chams:Clean(entitylib.Events.EntityRemoved:Connect(Removed))
                Chams:Clean(RunService.RenderStepped:Connect(Looped))
                Chams:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
                    if Reference[ent] then
                        Removed(ent)
                    end
                    Added(ent)
                end))
                for _, v in entitylib.List do
                    if Reference[v] then
                        Removed(v)
                    end
                    Added(v)
                end
            else
                for i in Reference do
                    Removed(i)
                end
            end
        end
    })
    Mode = Chams:AddDropdown({
        Name = 'Mode',
        List = {'Highlight', 'BoxHandles'},
        Function = function(val)
            OutlineTransparency.Frame.Visible = val == 'Highlight'
            if Chams.Enabled then
                Chams:Toggle()
                Chams:Toggle()
            end
        end
    })
    FillTransparency = Chams:AddSlider({
        Name = 'Transparency',
        Min = 0,
        Max = 1,
        Default = 0.5,
        Function = function(val)
            for _, v in Reference do
                if type(v) == 'table' then
                    for _, v2 in v do
                        v2.Transparency = val
                    end
                else
                    v.FillTransparency = val
                end
            end
        end,
        Decimal = 10
    })
    OutlineTransparency = Chams:AddSlider({
        Name = 'Outline Transparency',
        Min = 0,
        Max = 1,
        Default = 0.5,
        Function = function(val)
            for _, v in Reference do
                if type(v) ~= 'table' then
                    v.OutlineTransparency = val
                end
            end
        end,
        Decimal = 10,
        Darker = true
    })
    Walls = Chams:AddToggle({
        Name = 'Render Walls',
        Function = function(callback)
            for _, v in Reference do
                if type(v) == 'table' then
                    for _, v2 in v do
                        v2.AlwaysOnTop = callback
                    end
                else
                    v.DepthMode = Enum.HighlightDepthMode[callback and 'AlwaysOnTop' or 'Occluded']
                end
            end
        end,
        Default = true
    })
    Teammates = Chams:AddToggle({
        Name = 'Priority Only',
        Function = function()
            if Chams.Enabled then
                Chams:Toggle()
                Chams:Toggle()
            end
        end,
        Default = true
    })
end)
run(function()
    local ESP
    local Targets
    local Color
    local Method
    local BoundingBox
    local Filled
    local HealthBar
    local Name
    local DisplayName
    local Background
    local Teammates
    local Distance
    local DistanceLimit
    local Snaplines
    local SnaplineOrigin
    local HeadDot
    local ShowWeapon
    local ShowDistance
    local Reference = {}
    local methodused
    local function ESPWorldToViewport(pos)
        local newpos = gameCamera:WorldToViewportPoint(gameCamera.CFrame:pointToWorldSpace(gameCamera.CFrame:PointToObjectSpace(pos)))
        return Vector2.new(newpos.X, newpos.Y)
    end
    local ESPAdded = {
        Drawing2D = function(ent)
            if not ent.Player then
                return
            end
            if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then
                return
            end
            if AkiraLite.ThreadFix then
                setthreadidentity(8)
            end
            local EntityESP = {}
            EntityESP.Main = Drawing.new('Square')
            EntityESP.Main.Transparency = BoundingBox.Enabled and 1 or 0
            EntityESP.Main.ZIndex = 2
            EntityESP.Main.Filled = false
            EntityESP.Main.Thickness = 1
            EntityESP.Main.Color = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
            if BoundingBox.Enabled then
                EntityESP.Border = Drawing.new('Square')
                EntityESP.Border.Transparency = 0.35
                EntityESP.Border.ZIndex = 1
                EntityESP.Border.Thickness = 1
                EntityESP.Border.Filled = false
                EntityESP.Border.Color = Color3.new()
                EntityESP.Border2 = Drawing.new('Square')
                EntityESP.Border2.Transparency = 0.35
                EntityESP.Border2.ZIndex = 1
                EntityESP.Border2.Thickness = 1
                EntityESP.Border2.Filled = Filled.Enabled
                EntityESP.Border2.Color = Color3.new()
            end
            if HealthBar.Enabled then
                EntityESP.HealthLine = Drawing.new('Line')
                EntityESP.HealthLine.Thickness = 1
                EntityESP.HealthLine.ZIndex = 2
                EntityESP.HealthLine.Color = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
                EntityESP.HealthBorder = Drawing.new('Line')
                EntityESP.HealthBorder.Thickness = 3
                EntityESP.HealthBorder.Transparency = 0.35
                EntityESP.HealthBorder.ZIndex = 1
                EntityESP.HealthBorder.Color = Color3.new()
            end
            if Snaplines and Snaplines.Enabled then
                EntityESP.Snapline = Drawing.new('Line')
                EntityESP.Snapline.Thickness = 1
                EntityESP.Snapline.ZIndex = 2
                EntityESP.Snapline.Color = EntityESP.Main and EntityESP.Main.Color or AkiraLite.Libraries.uipallet.FinalColor
            end
            if HeadDot and HeadDot.Enabled then
                EntityESP.HeadDot = Drawing.new('Circle')
                EntityESP.HeadDot.Radius = 3
                EntityESP.HeadDot.Filled = true
                EntityESP.HeadDot.Thickness = 1
                EntityESP.HeadDot.ZIndex = 3
                EntityESP.HeadDot.Color = EntityESP.Main and EntityESP.Main.Color or AkiraLite.Libraries.uipallet.FinalColor
            end
            if ShowWeapon and ShowWeapon.Enabled then
                EntityESP.WeaponText = Drawing.new('Text')
                EntityESP.WeaponText.Size = 13
                EntityESP.WeaponText.Center = true
                EntityESP.WeaponText.ZIndex = 2
                EntityESP.WeaponText.Color = Color3.fromRGB(240, 240, 240)
            end
            if ShowDistance and ShowDistance.Enabled then
                EntityESP.DistanceText = Drawing.new('Text')
                EntityESP.DistanceText.Size = 13
                EntityESP.DistanceText.Center = true
                EntityESP.DistanceText.ZIndex = 2
                EntityESP.DistanceText.Color = Color3.fromRGB(200, 200, 200)
            end
            if Name.Enabled then
                if Background.Enabled then
                    EntityESP.TextBKG = Drawing.new('Square')
                    EntityESP.TextBKG.Transparency = 0.35
                    EntityESP.TextBKG.ZIndex = 0
                    EntityESP.TextBKG.Thickness = 1
                    EntityESP.TextBKG.Filled = true
                    EntityESP.TextBKG.Color = Color3.new()
                end
                EntityESP.Drop = Drawing.new('Text')
                EntityESP.Drop.Color = Color3.new()
                EntityESP.Drop.Text = ent.Player and (DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
                EntityESP.Drop.ZIndex = 1
                EntityESP.Drop.Center = true
                EntityESP.Drop.Size = 20
                EntityESP.Text = Drawing.new('Text')
                EntityESP.Text.Text = EntityESP.Drop.Text
                EntityESP.Text.ZIndex = 2
                EntityESP.Text.Color = EntityESP.Main.Color
                EntityESP.Text.Center = true
                EntityESP.Text.Size = 20
            end
            Reference[ent] = EntityESP
        end,
        Drawing3D = function(ent)
            if not ent.Player then
                return
            end
            if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then
                return
            end
            if AkiraLite.ThreadFix then
                setthreadidentity(8)
            end
            local EntityESP = {}
            EntityESP.Line1 = Drawing.new('Line')
            EntityESP.Line2 = Drawing.new('Line')
            EntityESP.Line3 = Drawing.new('Line')
            EntityESP.Line4 = Drawing.new('Line')
            EntityESP.Line5 = Drawing.new('Line')
            EntityESP.Line6 = Drawing.new('Line')
            EntityESP.Line7 = Drawing.new('Line')
            EntityESP.Line8 = Drawing.new('Line')
            EntityESP.Line9 = Drawing.new('Line')
            EntityESP.Line10 = Drawing.new('Line')
            EntityESP.Line11 = Drawing.new('Line')
            EntityESP.Line12 = Drawing.new('Line')
            local color = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
            for _, v in EntityESP do
                v.Thickness = 1
                v.Color = color
            end
            Reference[ent] = EntityESP
        end,
        DrawingSkeleton = function(ent)
            if not ent.Player then
                return
            end
            if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then
                return
            end
            if AkiraLite.ThreadFix then
                setthreadidentity(8)
            end
            local EntityESP = {}
            EntityESP.Head = Drawing.new('Line')
            EntityESP.HeadFacing = Drawing.new('Line')
            EntityESP.Torso = Drawing.new('Line')
            EntityESP.UpperTorso = Drawing.new('Line')
            EntityESP.LowerTorso = Drawing.new('Line')
            EntityESP.LeftArm = Drawing.new('Line')
            EntityESP.RightArm = Drawing.new('Line')
            EntityESP.LeftLeg = Drawing.new('Line')
            EntityESP.RightLeg = Drawing.new('Line')
            local color = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
            for _, v in EntityESP do
                v.Thickness = 2
                v.Color = color
            end
            Reference[ent] = EntityESP
        end
    }
    local ESPRemoved = {
        Drawing2D = function(ent)
            local EntityESP = Reference[ent]
            if EntityESP then
                if AkiraLite.ThreadFix then
                    setthreadidentity(8)
                end
                Reference[ent] = nil
                for _, v in EntityESP do
                    pcall(function()
                        v.Visible = false
                        v:Remove()
                    end)
                end
            end
        end
    }
    ESPRemoved.Drawing3D = ESPRemoved.Drawing2D
    ESPRemoved.DrawingSkeleton = ESPRemoved.Drawing2D
    local ESPUpdated = {
        Drawing2D = function(ent)
            local EntityESP = Reference[ent]
            if EntityESP then
                if AkiraLite.ThreadFix then
                    setthreadidentity(8)
                end
                if EntityESP.HealthLine then
                    EntityESP.HealthLine.Color = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
                end
                if EntityESP.Text then
                    EntityESP.Text.Text = ent.Player and (DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
                    EntityESP.Drop.Text = EntityESP.Text.Text
                end
            end
        end
    }
    local ColorFunc = {
        Drawing2D = function(hue, sat, val)
            local color = Color3.fromHSV(hue, sat, val)
            for i, v in Reference do
                v.Main.Color = entitylib.getEntityColor(i) or color
                if v.Text then
                    v.Text.Color = v.Main.Color
                end
                if v.Snapline then
                    v.Snapline.Color = v.Main.Color
                end
                if v.HeadDot then
                    v.HeadDot.Color = v.Main.Color
                end
            end
        end,
        Drawing3D = function(hue, sat, val)
            local color = Color3.fromHSV(hue, sat, val)
            for i, v in Reference do
                local playercolor = entitylib.getEntityColor(i) or color
                for _, v2 in v do
                    v2.Color = playercolor
                end
            end
        end
    }
    ColorFunc.DrawingSkeleton = ColorFunc.Drawing3D
    local ESPLoop = {
        Drawing2D = function()
            for ent, EntityESP in Reference do
                if Distance.Enabled then
                    local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
                    if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
                        for _, obj in EntityESP do
                            obj.Visible = false
                        end
                        continue
                    end
                end
                local rootPos, rootVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position)
                local color = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
                for _, obj in EntityESP do
                    obj.Visible = rootVis
                    obj.Color = color
                end
                if not rootVis then
                    continue
                end
                local topPos = gameCamera:WorldToViewportPoint((CFrame.lookAlong(ent.RootPart.Position, gameCamera.CFrame.LookVector) * CFrame.new(2, ent.HipHeight, 0)).p)
                local bottomPos = gameCamera:WorldToViewportPoint((CFrame.lookAlong(ent.RootPart.Position, gameCamera.CFrame.LookVector) * CFrame.new(- 2, - ent.HipHeight - 1, 0)).p)
                local sizex, sizey = topPos.X - bottomPos.X, topPos.Y - bottomPos.Y
                local posx, posy = (rootPos.X - sizex / 2), ((rootPos.Y - sizey / 2))
                EntityESP.Main.Position = Vector2.new(posx, posy) // 1
                EntityESP.Main.Size = Vector2.new(sizex, sizey) // 1
                if EntityESP.Border then
                    EntityESP.Border.Position = Vector2.new(posx - 1, posy + 1) // 1
                    EntityESP.Border.Size = Vector2.new(sizex + 2, sizey - 2) // 1
                    EntityESP.Border2.Position = Vector2.new(posx + 1, posy - 1) // 1
                    EntityESP.Border2.Size = Vector2.new(sizex - 2, sizey + 2) // 1
                end
                if EntityESP.HealthLine then
                    local healthposy = sizey * math.clamp(ent.Health / ent.MaxHealth, 0, 1)
                    EntityESP.HealthLine.Visible = ent.Health > 0
                    EntityESP.HealthLine.From = Vector2.new(posx - 6, posy + (sizey - (sizey - healthposy))) // 1
                    EntityESP.HealthLine.To = Vector2.new(posx - 6, posy) // 1
                    EntityESP.HealthBorder.From = Vector2.new(posx - 6, posy + 1) // 1
                    EntityESP.HealthBorder.To = Vector2.new(posx - 6, (posy + sizey) - 1) // 1
                end
                if EntityESP.Text then
                    EntityESP.Text.Position = Vector2.new(posx + (sizex / 2), posy + (sizey - 28)) // 1
                    EntityESP.Drop.Position = EntityESP.Text.Position + Vector2.new(1, 1)
                    if EntityESP.TextBKG then
                        EntityESP.TextBKG.Size = EntityESP.Text.TextBounds + Vector2.new(8, 4)
                        EntityESP.TextBKG.Position = EntityESP.Text.Position - Vector2.new(4 + (EntityESP.Text.TextBounds.X / 2), 0)
                    end
                end
                local bottomOffset = 4
                if ShowWeapon and ShowWeapon.Enabled and EntityESP.WeaponText then
                    local char = ent.Character or (ent.Player and ent.Player.Character)
                    local wep = ""
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            wep = tool.Name
                        else
                            local eq = char:FindFirstChild("EquippedItem")
                            if eq and eq.Value then
                                wep = tostring(eq.Value)
                            else
                                local attr = char:GetAttribute("EquippedWeapon")
                                if attr then
                                    wep = tostring(attr)
                                end
                            end
                        end
                    end
                    if wep ~= "" then
                        EntityESP.WeaponText.Position = Vector2.new(posx + (sizex / 2), posy + sizey + bottomOffset) // 1
                        EntityESP.WeaponText.Text = wep
                        EntityESP.WeaponText.Visible = true
                        bottomOffset = bottomOffset + 14
                    else
                        EntityESP.WeaponText.Visible = false
                    end
                end
                if ShowDistance and ShowDistance.Enabled and EntityESP.DistanceText then
                    local dist = math.floor((gameCamera.CFrame.Position - ent.RootPart.Position).Magnitude)
                    EntityESP.DistanceText.Position = Vector2.new(posx + (sizex / 2), posy + sizey + bottomOffset) // 1
                    EntityESP.DistanceText.Text = string.format("[%dm]", dist)
                    EntityESP.DistanceText.Visible = true
                    bottomOffset = bottomOffset + 14
                end
                if Snaplines and Snaplines.Enabled and EntityESP.Snapline then
                    local vp = gameCamera.ViewportSize
                    local origin = (SnaplineOrigin and SnaplineOrigin.Value == "Top" and Vector2.new(vp.X / 2, 0))
                        or (SnaplineOrigin and SnaplineOrigin.Value == "Center" and Vector2.new(vp.X / 2, vp.Y / 2))
                        or Vector2.new(vp.X / 2, vp.Y)
                    EntityESP.Snapline.From = origin
                    EntityESP.Snapline.To = Vector2.new(posx + (sizex / 2), posy + sizey)
                    EntityESP.Snapline.Visible = true
                    EntityESP.Snapline.Color = color
                end
                if HeadDot and HeadDot.Enabled and EntityESP.HeadDot then
                    local headPart = ent.Head or (ent.Character and ent.Character:FindFirstChild("Head"))
                    if headPart then
                        local head2d, headVis = gameCamera:WorldToViewportPoint(headPart.Position)
                        if headVis then
                            EntityESP.HeadDot.Position = Vector2.new(head2d.X, head2d.Y)
                            EntityESP.HeadDot.Visible = true
                            EntityESP.HeadDot.Color = color
                        else
                            EntityESP.HeadDot.Visible = false
                        end
                    else
                        EntityESP.HeadDot.Visible = false
                    end
                end
            end
        end,
        Drawing3D = function()
            for ent, EntityESP in Reference do
                if Distance.Enabled then
                    local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
                    if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
                        for _, obj in EntityESP do
                            obj.Visible = false
                        end
                        continue
                    end
                end
                local _, rootVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position)
                local color = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
                for _, obj in EntityESP do
                    obj.Visible = rootVis
                    obj.Thickness = 2
                    obj.Color = color
                end
                if not rootVis then
                    continue
                end
                local point1 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, ent.HipHeight, 1.5))
                local point2 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, - ent.HipHeight, 1.5))
                local point3 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(- 1.5, ent.HipHeight, 1.5))
                local point4 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(- 1.5, - ent.HipHeight, 1.5))
                local point5 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, ent.HipHeight, - 1.5))
                local point6 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(1.5, - ent.HipHeight, - 1.5))
                local point7 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(- 1.5, ent.HipHeight, - 1.5))
                local point8 = ESPWorldToViewport(ent.RootPart.Position + Vector3.new(- 1.5, - ent.HipHeight, - 1.5))
                EntityESP.Line1.From = point1
                EntityESP.Line1.To = point2
                EntityESP.Line2.From = point3
                EntityESP.Line2.To = point4
                EntityESP.Line3.From = point5
                EntityESP.Line3.To = point6
                EntityESP.Line4.From = point7
                EntityESP.Line4.To = point8
                EntityESP.Line5.From = point1
                EntityESP.Line5.To = point3
                EntityESP.Line6.From = point1
                EntityESP.Line6.To = point5
                EntityESP.Line7.From = point5
                EntityESP.Line7.To = point7
                EntityESP.Line8.From = point7
                EntityESP.Line8.To = point3
                EntityESP.Line9.From = point2
                EntityESP.Line9.To = point4
                EntityESP.Line10.From = point2
                EntityESP.Line10.To = point6
                EntityESP.Line11.From = point6
                EntityESP.Line11.To = point8
                EntityESP.Line12.From = point8
                EntityESP.Line12.To = point4
            end
        end,
        DrawingSkeleton = function()
            for ent, EntityESP in Reference do
                if Distance.Enabled then
                    local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
                    if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
                        for _, obj in EntityESP do
                            obj.Visible = false
                        end
                        continue
                    end
                end
                local _, rootVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position)
                for _, obj in EntityESP do
                    obj.Visible = rootVis
                end
                if not rootVis then
                    continue
                end
                local rigcheck = ent.Humanoid.RigType == Enum.HumanoidRigType.R6
                pcall(function()
                    local offset = rigcheck and CFrame.new(0, - 0.8, 0) or CFrame.identity
                    local head = ESPWorldToViewport((ent.Head.CFrame).p)
                    local headfront = ESPWorldToViewport((ent.Head.CFrame * CFrame.new(0, 0, - 0.5)).p)
                    local toplefttorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(- 1.5, 0.8, 0)).p)
                    local toprighttorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(1.5, 0.8, 0)).p)
                    local toptorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0, 0.8, 0)).p)
                    local bottomtorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0, - 0.8, 0)).p)
                    local bottomlefttorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(- 0.5, - 0.8, 0)).p)
                    local bottomrighttorso = ESPWorldToViewport((ent.Character[(rigcheck and 'Torso' or 'UpperTorso')].CFrame * CFrame.new(0.5, - 0.8, 0)).p)
                    local leftarm = ESPWorldToViewport((ent.Character[(rigcheck and 'Left Arm' or 'LeftHand')].CFrame * offset).p)
                    local rightarm = ESPWorldToViewport((ent.Character[(rigcheck and 'Right Arm' or 'RightHand')].CFrame * offset).p)
                    local leftleg = ESPWorldToViewport((ent.Character[(rigcheck and 'Left Leg' or 'LeftFoot')].CFrame * offset).p)
                    local rightleg = ESPWorldToViewport((ent.Character[(rigcheck and 'Right Leg' or 'RightFoot')].CFrame * offset).p)
                    EntityESP.Head.From = toptorso
                    EntityESP.Head.To = head
                    EntityESP.HeadFacing.From = head
                    EntityESP.HeadFacing.To = headfront
                    EntityESP.UpperTorso.From = toplefttorso
                    EntityESP.UpperTorso.To = toprighttorso
                    EntityESP.Torso.From = toptorso
                    EntityESP.Torso.To = bottomtorso
                    EntityESP.LowerTorso.From = bottomlefttorso
                    EntityESP.LowerTorso.To = bottomrighttorso
                    EntityESP.LeftArm.From = toplefttorso
                    EntityESP.LeftArm.To = leftarm
                    EntityESP.RightArm.From = toprighttorso
                    EntityESP.RightArm.To = rightarm
                    EntityESP.LeftLeg.From = bottomlefttorso
                    EntityESP.LeftLeg.To = leftleg
                    EntityESP.RightLeg.From = bottomrighttorso
                    EntityESP.RightLeg.To = rightleg
                end)
            end
        end
    }
    ESP = AkiraLite.Catalogs.Render:AddModule({
        Name = 'ESP',
        Function = function(callback)
            if callback then
                methodused = 'Drawing' .. Method.Value
                if ESPRemoved[methodused] then
                    ESP:Clean(entitylib.Events.EntityRemoved:Connect(ESPRemoved[methodused]))
                end
                if ESPAdded[methodused] then
                    for _, v in entitylib.List do
                        if Reference[v] then
                            ESPRemoved[methodused](v)
                        end
                        ESPAdded[methodused](v)
                    end
                    ESP:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
                        if Reference[ent] then
                            ESPRemoved[methodused](ent)
                        end
                        ESPAdded[methodused](ent)
                    end))
                end
                if ESPUpdated[methodused] then
                    ESP:Clean(entitylib.Events.EntityUpdated:Connect(ESPUpdated[methodused]))
                    for _, v in entitylib.List do
                        ESPUpdated[methodused](v)
                    end
                end
                if ESPLoop[methodused] then
                    ESP:Clean(RunService.RenderStepped:Connect(ESPLoop[methodused]))
                end
            else
                if ESPRemoved[methodused] then
                    for i in Reference do
                        ESPRemoved[methodused](i)
                    end
                end
            end
        end
    })
    Method = ESP:AddDropdown({
        Name = 'Mode',
        List = {'2D', '3D', 'Skeleton'},
        Function = function(val)
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
            BoundingBox.Frame.Visible = (val == '2D')
            Filled.Frame.Visible = (val == '2D')
            HealthBar.Frame.Visible = (val == '2D')
            Name.Frame.Visible = (val == '2D')
            DisplayName.Frame.Visible = Name.Frame.Visible and Name.Enabled
            Background.Frame.Visible = Name.Frame.Visible and Name.Enabled
        end,
    })
    BoundingBox = ESP:AddToggle({
        Name = 'Bounding Box',
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end,
        Default = true,
        Darker = true
    })
    Filled = ESP:AddToggle({
        Name = 'Filled',
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end,
        Darker = true
    })
    HealthBar = ESP:AddToggle({
        Name = 'Health Bar',
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end,
        Darker = true
    })
    Name = ESP:AddToggle({
        Name = 'Name',
        Function = function(callback)
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
            DisplayName.Frame.Visible = callback
            Background.Frame.Visible = callback
        end,
        Darker = true
    })
    DisplayName = ESP:AddToggle({
        Name = 'Use Displayname',
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end,
        Default = true,
        Darker = true
    })
    Background = ESP:AddToggle({
        Name = 'Show Background',
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end,
        Darker = true
    })
    Teammates = ESP:AddToggle({
        Name = 'Priority Only',
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end,
        Default = true
    })
    Distance = ESP:AddToggle({
        Name = 'Distance Check',
        Function = function(callback)
            DistanceLimit.Object.Visible = callback
        end
    })
    DistanceLimit = ESP:AddSlider({
        Name = 'Player Distance',
        Min = 0,
        Max = 256,
        Default = 64,
        Darker = true,
        Visible = false
    })
    Snaplines = ESP:AddToggle({
        Name = 'Snaplines',
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end,
        Darker = true
    })
    SnaplineOrigin = ESP:AddDropdown({
        Name = 'Snapline Origin',
        List = {'Bottom', 'Center', 'Top'},
        Darker = true
    })
    HeadDot = ESP:AddToggle({
        Name = 'Head Dot',
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end,
        Darker = true
    })
    ShowWeapon = ESP:AddToggle({
        Name = 'Show Weapon',
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end,
        Darker = true
    })
    ShowDistance = ESP:AddToggle({
        Name = 'Show Distance',
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end,
        Darker = true
    })
end)
run(function()
    local Mode
    local StudLimit = {
        Object = {}
    }
    local rayCheck = RaycastParams.new()
    rayCheck.RespectCanCollide = true
    local overlapCheck = OverlapParams.new()
    overlapCheck.MaxParts = 9e9
    local modified, fflag = {}
    local teleported
    local function grabClosestNormal(ray)
        local partCF, mag, closest = ray.Instance.CFrame, 0, Enum.NormalId.Top
        for _, normal in Enum.NormalId:GetEnumItems() do
            local dot = partCF:VectorToWorldSpace(Vector3.fromNormalId(normal)):Dot(ray.Normal)
            if dot > mag then
                mag, closest = dot, normal
            end
        end
        return Vector3.fromNormalId(closest).X ~= 0 and 'X' or 'Z'
    end
    local Functions = {
        Part = function()
            local chars = {gameCamera, lplr.Character}
            for _, v in entitylib.List do
                table.insert(chars, v.Character)
            end
            overlapCheck.FilterDescendantsInstances = chars
            local parts = workspace:GetPartBoundsInBox(entitylib.character.RootPart.CFrame + Vector3.new(0, 1, 0), entitylib.character.RootPart.Size + Vector3.new(1, entitylib.character.HipHeight, 1), overlapCheck)
            for _, part in parts do
                if part.CanCollide and (not Spider.Enabled or SpiderShift) then
                    modified[part] = true
                    part.CanCollide = false
                end
            end
            for part in modified do
                if not table.find(parts, part) then
                    modified[part] = nil
                    part.CanCollide = true
                end
            end
        end,
        Character = function()
            for _, part in lplr.Character:GetDescendants() do
                if part:IsA('BasePart') and part.CanCollide and (not Spider.Enabled or SpiderShift) then
                    modified[part] = true
                    part.CanCollide = Spider.Enabled and not SpiderShift
                end
            end
        end,
        CFrame = function()
            local chars = {gameCamera, lplr.Character}
            for _, v in entitylib.List do
                table.insert(chars, v.Character)
            end
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
            setfflag('AssemblyExtentsExpansionStudHundredth', '-10000')
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
                        Functions[Mode.Value]()
                    end
                end))
                if Mode.Value == 'FFlag' then
                    Phase:Clean(lplr.OnTeleport:Connect(function()
                        teleported = true
                        setfflag('AssemblyExtentsExpansionStudHundredth', '30')
                    end))
                end
            else
                if fflag then
                    setfflag('AssemblyExtentsExpansionStudHundredth', '30')
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
            StudLimit.Object.Visible = val == 'CFrame' or val == 'Motor'
            if fflag then
                setfflag('AssemblyExtentsExpansionStudHundredth', '30')
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
    local Reference = {}
    local function Added(ent)
        if not ent.Player then
            return
        end
        if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then
            return
        end
        if AkiraLite.ThreadFix then
            setthreadidentity(8)
        end
        local EntityTracer = Drawing.new('Line')
        EntityTracer.Thickness = 1
        EntityTracer.Transparency = 1 - Transparency.Value
        EntityTracer.Color = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
        Reference[ent] = EntityTracer
    end
    local function Removed(ent)
        local v = Reference[ent]
        if v then
            if AkiraLite.ThreadFix then
                setthreadidentity(8)
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
        for ent, EntityTracer in Reference do
            local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude
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
            EntityTracer.Color = entitylib.getEntityColor(ent) or AkiraLite.Libraries.uipallet.FinalColor
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
        Function = function(val)
            for _, tracer in Reference do
                tracer.Transparency = 1 - val
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
                    setfflag('S2PhysicsSenderRate', '15')
                    setfflag('DataSenderRate', '60')
                    teleported = true
                end))
                repeat
                    local physicsrate, senderrate = '0', Type.Value == 'All' and '-1' or '60'
                    if AutoSend.Enabled and tick() % (AutoSendLength.Value + 0.1) > AutoSendLength.Value then
                        physicsrate, senderrate = '15', '60'
                    end
                    if physicsrate ~= oldphys or senderrate ~= oldsend then
                        setfflag('S2PhysicsSenderRate', physicsrate)
                        setfflag('DataSenderRate', senderrate)
                        oldphys, oldsend = physicsrate, oldsend
                    end
                    task.wait(0.03)
                until (not Blink.Enabled and not teleported)
            else
                if setfflag then
                    setfflag('S2PhysicsSenderRate', '15')
                    setfflag('DataSenderRate', '60')
                end
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
run(function()
    local Xray
    local List
    local modified = {}
    local function modifyPart(v)
        if v:IsA('BasePart') then
            modified[v] = true
            v.LocalTransparencyModifier = 0.5
        end
    end
    Xray = AkiraLite.Catalogs.Render:AddModule({
        Name = 'XRay',
        Function = function(callback)
            if callback then
                Xray:Clean(workspace.DescendantAdded:Connect(modifyPart))
                for _, v in workspace:GetDescendants() do
                    modifyPart(v)
                end
            else
                for i in modified do
                    i.LocalTransparencyModifier = 0
                end
                table.clear(modified)
            end
        end
    })
    Transparency = Xray:AddSlider({
        Name = 'Transparency',
        Min = 0,
        Max = 1,
        Function = function(val)
            for i in modified do
                i.LocalTransparencyModifier = 1 - val
            end
        end,
        Decimal = 100
    })
end)
local mouseClicked
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
            local ent, targetPart, origin = getTarget(gameCamera.CFrame.Position)
            if not ent then
                return
            end
            local direction = CFrame.lookAt(origin, targetPart.Position)
            if Projectile.Enabled then
                local calc = prediction.SolveTrajectory(origin, ProjectileSpeed.Value, ProjectileGravity.Value, targetPart.Position, targetPart.Velocity, workspace.Gravity, ent.HipHeight, nil, ProjectileRaycast)
                if not calc then
                    return
                end
                direction = CFrame.lookAt(origin, calc)
            end
            return {Ray.new(origin + (args[3] and direction.LookVector * args[3] or Vector3.zero), direction.LookVector)}
        end
    }
    SilentAim = AkiraLite.Catalogs.Combat:AddModule({
        Name = 'Silent Aim',
        Function = function(callback)
            if CircleObject then
                CircleObject.Visible = callback and Mode.Value == 'Mouse'
            end
            if callback then
                oldnamecall = hookmetamethod(game, '__namecall', function(...)
                    if getnamecallmethod() ~= 'ScreenPointToRay' then
                        return oldnamecall(...)
                    end
                    if checkcaller() then
                        return oldnamecall(...)
                    end
                    local calling = getcallingscript()
                    if calling then
                        local list = {'ControlScript', 'ControlModule'}
                        if table.find(list, tostring(calling)) then
                            return oldnamecall(...)
                        end
                    end
                    local self, args = ..., {select(2, ...)}
                    local res = Hooks.ScreenPointToRay(args)
                    if res then
                        return unpack(res)
                    end
                    return oldnamecall(self, unpack(args))
                end)
                repeat
                    if AutoFire.Enabled then
                        local origin = AutoFireMode.Value == 'Camera' and gameCamera.CFrame or entitylib.isAlive and entitylib.character.RootPart.CFrame or CFrame.identity
                        local ent = entitylib['Entity' .. Mode.Value]({
                            Range = Range.Value,
                            Wallcheck = true,
                            Part = 'Head',
                            Origin = (origin * fireoffset).Position,
                            Players = true,
                            NPCs = false
                        })
                        if mouse1click and (isrbxactive or iswindowactive)() then
                            if ent and canClick() then
                                if delayCheck < tick() then
                                    if mouseClicked then
                                        mouse1release()
                                        delayCheck = tick() + AutoFireShootDelay.Value
                                    else
                                        mouse1press()
                                    end
                                    mouseClicked = not mouseClicked
                                end
                            else
                                if mouseClicked then
                                    mouse1release()
                                end
                                mouseClicked = false
                            end
                        end
                    end
                    task.wait()
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
                    CircleObject.Color = AkiraLite.Libraries.uipallet.FinalColor
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
run(function()
    local RageBot
    local Weapon
    local AutoReload
    local RapidFire
    local KnifeBackstab
    local Visualizer
    local GradientText
    local ShowAmmo

    local renderCon
    local lastFire = 0
    local lastReload = 0
    local lastTarget = nil
    local swapTargetTime = 0
    local currentState = "SEARCHING"

    local deflecting = {}
    local RageRepS = cloneref(game:GetService('ReplicatedStorage'))
    local RagePlrs = cloneref(game:GetService('Players'))
    local RageRunS = cloneref(game:GetService('RunService'))
    local RageTweenS = cloneref(game:GetService('TweenService'))
    local RageUIS = cloneref(game:GetService('UserInputService'))
    local RageUtil = require(RageRepS.Modules.Utility)
    local RageEnum = require(RageRepS.Modules.EnumLibrary)
    local FighterController = require(RagePlrs.LocalPlayer.PlayerScripts.Controllers.FighterController)
    local SpectateController = require(RagePlrs.LocalPlayer.PlayerScripts.Controllers:WaitForChild('SpectateController'))

    local function applyRapidCooldowns()
        task.spawn(function()
            pcall(function()
                local modulesFolder = RageRepS:FindFirstChild("Modules")
                local itemLibObj = modulesFolder and modulesFolder:FindFirstChild("ItemLibrary")
                if not itemLibObj then
                    itemLibObj = RageRepS:WaitForChild("Modules", 2)
                    itemLibObj = itemLibObj and itemLibObj:WaitForChild("ItemLibrary", 2)
                end
                if itemLibObj then
                    local ItemLibrary = require(itemLibObj)
                    local function scan(tbl)
                        for _, v in pairs(tbl) do
                            if typeof(v) == "table" then
                                if v.ShootCooldown ~= nil then
                                    v.ShootCooldown = 0.000000000000000001
                                end
                                if v.BurstCooldown ~= nil then
                                    v.BurstCooldown = 0.000000000000000001
                                end
                                if v.AttackCooldown ~= nil then
                                    v.AttackCooldown = 0.000000000000000001
                                end
                                if v.HeavyAttackCooldown ~= nil then
                                    v.HeavyAttackCooldown = 0.000000000000000001
                                end
                                scan(v)
                            end
                        end
                    end
                    scan(ItemLibrary)
                end
            end)
        end)
    end

    local slotMap = { Primary = 1, Secondary = 2, Melee = 3 }
    local function getSlotNumber()
        return slotMap[Weapon and Weapon.Value or 'Melee'] or 3
    end

    -- Check if target player has a knife model
    local function hasKnifeViewModel(targetPlayer)
        if not targetPlayer then return false end
        local viewModels = workspace:FindFirstChild('ViewModels')
        if not viewModels then return false end
        local targetName = targetPlayer.Name
        for _, model in viewModels:GetChildren() do
            if model:IsA('Model') and string.find(model.Name, targetName, 1, true) and string.find(model.Name, 'Knife', 1, true) then
                return true
            end
        end
        return false
    end

    -- Check if the local player has a knife equipped (Knife, Dagger, Karambit, Chancla, Machete, Balisong)
    local function isLocalKnifeEquipped()
        if not FighterController or not FighterController.LocalFighter then
            return false
        end
        local fighter = FighterController.LocalFighter
        local item = fighter.EquippedItem
        if not item then
            return false
        end
        local name = rawget(item, 'Name') or rawget(item, 'ItemName')
        if not name and item.ViewModel then
            name = item.ViewModel.Name
        end
        if not name and item.Config then
            name = item.Config.Name
        end
        if name then
            local lower = string.lower(tostring(name))
            if string.find(lower, 'knife', 1, true) or string.find(lower, 'dagger', 1, true) or string.find(lower, 'karambit', 1, true) or string.find(lower, 'chancla', 1, true) or string.find(lower, 'machete', 1, true) or string.find(lower, 'balisong', 1, true) then
                return true
            end
        end
        local viewModels = workspace:FindFirstChild('ViewModels')
        if viewModels and lplr then
            for _, model in viewModels:GetChildren() do
                if model:IsA('Model') and string.find(model.Name, lplr.Name, 1, true) and string.find(model.Name, 'Knife', 1, true) then
                    return true
                end
            end
        end
        return false
    end

    -- Extract full weapon and ammo information from equipped item
    local function getEquippedAmmoInfo()
        if not FighterController or not FighterController.LocalFighter then
            return nil
        end
        local fighter = FighterController.LocalFighter
        local item = fighter.EquippedItem
        if not item then
            return nil
        end

        local name = rawget(item, 'Name') or rawget(item, 'ItemName')
        if not name and item.ViewModel then
            name = item.ViewModel.Name
        end
        if not name and item.Config then
            name = item.Config.Name
        end
        if not name then
            name = "Weapon"
        end

        local data = rawget(item, 'Data')
        local curAmmo = nil
        if item.Get then
            pcall(function() curAmmo = item:Get('Ammo') end)
        end
        if curAmmo == nil and data then
            curAmmo = rawget(data, 'Ammo')
        end
        if curAmmo == nil then
            curAmmo = rawget(item, 'Ammo')
        end

        local info = (item.Get and select(2, pcall(function() return item:Get('Info') end))) or rawget(item, 'Info')
        local maxAmmo = info and (rawget(info, 'MaxAmmo') or rawget(info, 'MagSize') or rawget(info, 'ClipSize'))
        if maxAmmo == nil and data then
            maxAmmo = rawget(data, 'MaxAmmo') or rawget(data, 'MagSize')
        end
        if maxAmmo == nil then
            pcall(function()
                local ItemLib = require(RageRepS.Modules.ItemLibrary)
                if ItemLib and ItemLib[name] then
                    maxAmmo = ItemLib[name].MaxAmmo or ItemLib[name].MagSize
                end
            end)
        end

        local reserve = nil
        if item.Get then
            pcall(function() reserve = item:Get('AmmoReserve') end)
        end
        if reserve == nil and data then
            reserve = rawget(data, 'AmmoReserve')
        end
        if reserve == nil then
            reserve = rawget(item, 'AmmoReserve')
        end

        local isReloading = false
        if item._reload_cooldown and type(item._reload_cooldown) == "number" then
            isReloading = item._reload_cooldown > tick()
        end

        local isMelee = false
        local lowerName = string.lower(tostring(name))
        if string.find(lowerName, 'knife', 1, true) or string.find(lowerName, 'dagger', 1, true) or string.find(lowerName, 'karambit', 1, true) or string.find(lowerName, 'katana', 1, true) or string.find(lowerName, 'chancla', 1, true) or string.find(lowerName, 'machete', 1, true) or string.find(lowerName, 'balisong', 1, true) or string.find(lowerName, 'fist', 1, true) or string.find(lowerName, 'bat', 1, true) then
            isMelee = true
        end

        return {
            Name = tostring(name),
            CurAmmo = type(curAmmo) == "number" and curAmmo or 0,
            MaxAmmo = type(maxAmmo) == "number" and maxAmmo or (type(curAmmo) == "number" and curAmmo or 30),
            Reserve = type(reserve) == "number" and reserve or 0,
            IsReloading = isReloading,
            IsMelee = isMelee,
        }
    end

    local function updateDeflection()
        if not FighterController or not FighterController.Objects then
            return
        end
        for _, fighterObj in FighterController.Objects do
            local player = fighterObj.Player
            if not player then
                deflecting[player] = false
                continue
            end
            if not fighterObj.Entity or not fighterObj.Entity:IsAlive() or fighterObj:Get('IsSpectating') then
                deflecting[player] = false
                continue
            end
            local equipped = fighterObj.EquippedItem
            local isKatana = equipped and equipped.ViewModel and equipped.ViewModel.Name == 'Katana'
            local isDeflecting = false
            if isKatana then
                isDeflecting = (equipped._attack_cooldown and equipped._attack_cooldown > tick()) or false
            end
            deflecting[player] = isDeflecting
        end
    end

    local function isEnemy(player)
        if player == lplr then
            return false
        end
        local duel = SpectateController.CurrentDuelSubject
        local localDueler = duel and duel:GetDueler(lplr)
        local localTeam = localDueler and localDueler:Get('TeamID') or nil
        if localTeam and duel and duel.Duelers then
            for _, dueler in duel.Duelers do
                if dueler.Player == player then
                    local team = dueler:Get('TeamID')
                    return team ~= localTeam
                end
            end
        end
        local pTeam = player:GetAttribute('TeamID')
        local lTeam = lplr:GetAttribute('TeamID')
        if pTeam and lTeam then
            return pTeam ~= lTeam
        end
        return true
    end

    local function getClosestTarget()
        local char = lplr.Character
        if not char then
            return nil, nil, nil
        end
        local myRoot = char:FindFirstChild('HumanoidRootPart')
        if not myRoot then
            return nil, nil, nil
        end
        local closestPlayer = nil
        local closestRoot = nil
        local closestHead = nil
        local closestDist = 500
        for _, player in RagePlrs:GetPlayers() do
            if not isEnemy(player) then
                continue
            end
            local pChar = player.Character
            if not pChar then
                continue
            end
            local pRoot = pChar:FindFirstChild('HumanoidRootPart')
            local pHead = pChar:FindFirstChild('Head')
            local pHum = pChar:FindFirstChildWhichIsA('Humanoid')
            if not (pRoot and pHead and pHum and pHum.Health > 0) then
                continue
            end
            local dist = (myRoot.Position - pRoot.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPlayer = player
                closestRoot = pRoot
                closestHead = pHead
            end
        end
        return closestPlayer, closestRoot, closestHead
    end

    local function pushEquip()
        if not (RageBot and RageBot.Enabled) then return end
        local fighter = FighterController and FighterController.LocalFighter
        if fighter then
            pcall(function()
                fighter:EquipItem(getSlotNumber())
            end)
        end
    end
    RagePlrs.PlayerRemoving:Connect(function(player)
        deflecting[player] = nil
    end)

    -- =========================================================================
    -- RAGEBOT VISUALIZER HUD (STATUS, GRADIENT TEXT, AMMO COUNTER)
    -- =========================================================================
    local VisualizerGui = nil
    local VisCard = nil
    local VisScale = nil
    local VisDot = nil
    local VisStatusLabel = nil
    local VisStatusGradient = nil
    local VisDivider = nil
    local VisAmmoRow = nil
    local VisGunLabel = nil
    local VisAmmoLabel = nil
    local VisAmmoBarBg = nil
    local VisAmmoBarFill = nil
    local VisAmmoGradient = nil

    local function createVisualizerHUD()
        if VisCard then return end
        local parentGui = AkiraLite.MainScreenGui or lplr:WaitForChild("PlayerGui")
        
        VisCard = Instance.new("Frame")
        VisCard.Name = "RagebotVisualizer"
        VisCard.Size = UDim2.fromOffset(260, 78)
        VisCard.Position = UDim2.new(0.5, -130, 0.74, 0)
        VisCard.BackgroundColor3 = Color3.fromRGB(13, 14, 18)
        VisCard.BackgroundTransparency = 0.12
        VisCard.BorderSizePixel = 0
        VisCard.ZIndex = 80
        VisCard.Visible = false
        VisCard.Parent = parentGui

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 10)
        cardCorner.Parent = VisCard

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = Color3.fromRGB(38, 42, 54)
        cardStroke.Thickness = 1
        cardStroke.Parent = VisCard

        VisScale = Instance.new("UIScale")
        VisScale.Scale = 0
        VisScale.Parent = VisCard

        -- Make VisCard Draggable
        local isDragging = false
        local dragStart = nil
        local startPos = nil

        VisCard.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                dragStart = input.Position
                startPos = VisCard.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isDragging = false
                    end
                end)
            end
        end)

        RageUIS.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                VisCard.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)

        -- Top Status Row
        local StatusRow = Instance.new("Frame")
        StatusRow.Name = "StatusRow"
        StatusRow.Size = UDim2.new(1, 0, 0, 34)
        StatusRow.BackgroundTransparency = 1
        StatusRow.ZIndex = 81
        StatusRow.Parent = VisCard

        VisDot = Instance.new("Frame")
        VisDot.Name = "StatusDot"
        VisDot.Size = UDim2.fromOffset(8, 8)
        VisDot.AnchorPoint = Vector2.new(0, 0.5)
        VisDot.Position = UDim2.new(0, 12, 0.5, 0)
        VisDot.BackgroundColor3 = Color3.fromRGB(150, 155, 170)
        VisDot.BorderSizePixel = 0
        VisDot.ZIndex = 82
        VisDot.Parent = StatusRow

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = VisDot

        VisStatusLabel = Instance.new("TextLabel")
        VisStatusLabel.Name = "StatusLabel"
        VisStatusLabel.Size = UDim2.new(1, -34, 1, 0)
        VisStatusLabel.Position = UDim2.new(0, 26, 0, 0)
        VisStatusLabel.BackgroundTransparency = 1
        VisStatusLabel.Text = "RAGEBOT : SEARCHING"
        VisStatusLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
        VisStatusLabel.TextSize = 12
        VisStatusLabel.FontFace = (AkiraLite.Libraries and AkiraLite.Libraries.uipallet and AkiraLite.Libraries.uipallet.Font) or Enum.Font.BuilderSansBold
        VisStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        VisStatusLabel.ZIndex = 82
        VisStatusLabel.Parent = StatusRow

        VisStatusGradient = Instance.new("UIGradient")
        VisStatusGradient.Rotation = 45
        VisStatusGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(160, 165, 180))
        VisStatusGradient.Parent = VisStatusLabel

        -- Divider Line
        VisDivider = Instance.new("Frame")
        VisDivider.Name = "Divider"
        VisDivider.Size = UDim2.new(1, -20, 0, 1)
        VisDivider.Position = UDim2.new(0, 10, 0, 34)
        VisDivider.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        VisDivider.BorderSizePixel = 0
        VisDivider.ZIndex = 81
        VisDivider.Parent = VisCard

        -- Ammo Section
        VisAmmoRow = Instance.new("Frame")
        VisAmmoRow.Name = "AmmoRow"
        VisAmmoRow.Size = UDim2.new(1, 0, 0, 44)
        VisAmmoRow.Position = UDim2.new(0, 0, 0, 34)
        VisAmmoRow.BackgroundTransparency = 1
        VisAmmoRow.ZIndex = 81
        VisAmmoRow.Parent = VisCard

        VisGunLabel = Instance.new("TextLabel")
        VisGunLabel.Name = "GunLabel"
        VisGunLabel.Size = UDim2.new(0.5, -12, 0, 18)
        VisGunLabel.Position = UDim2.new(0, 12, 0, 6)
        VisGunLabel.BackgroundTransparency = 1
        VisGunLabel.Text = "WEAPON"
        VisGunLabel.TextColor3 = Color3.fromRGB(150, 155, 170)
        VisGunLabel.TextSize = 11
        VisGunLabel.FontFace = (AkiraLite.Libraries and AkiraLite.Libraries.uipallet and AkiraLite.Libraries.uipallet.Font) or Enum.Font.BuilderSansMedium
        VisGunLabel.TextXAlignment = Enum.TextXAlignment.Left
        VisGunLabel.ZIndex = 82
        VisGunLabel.Parent = VisAmmoRow

        VisAmmoLabel = Instance.new("TextLabel")
        VisAmmoLabel.Name = "AmmoLabel"
        VisAmmoLabel.Size = UDim2.new(0.5, -12, 0, 18)
        VisAmmoLabel.Position = UDim2.new(0.5, 0, 0, 6)
        VisAmmoLabel.BackgroundTransparency = 1
        VisAmmoLabel.Text = "-- / --"
        VisAmmoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        VisAmmoLabel.TextSize = 12
        VisAmmoLabel.FontFace = (AkiraLite.Libraries and AkiraLite.Libraries.uipallet and AkiraLite.Libraries.uipallet.Font) or Enum.Font.BuilderSansBold
        VisAmmoLabel.TextXAlignment = Enum.TextXAlignment.Right
        VisAmmoLabel.ZIndex = 82
        VisAmmoLabel.Parent = VisAmmoRow

        VisAmmoBarBg = Instance.new("Frame")
        VisAmmoBarBg.Name = "AmmoBarBg"
        VisAmmoBarBg.Size = UDim2.new(1, -24, 0, 4)
        VisAmmoBarBg.Position = UDim2.new(0, 12, 0, 28)
        VisAmmoBarBg.BackgroundColor3 = Color3.fromRGB(24, 25, 33)
        VisAmmoBarBg.BorderSizePixel = 0
        VisAmmoBarBg.ZIndex = 82
        VisAmmoBarBg.Parent = VisAmmoRow

        local barBgCorner = Instance.new("UICorner")
        barBgCorner.CornerRadius = UDim.new(0, 2)
        barBgCorner.Parent = VisAmmoBarBg

        VisAmmoBarFill = Instance.new("Frame")
        VisAmmoBarFill.Name = "AmmoBarFill"
        VisAmmoBarFill.Size = UDim2.new(1, 0, 1, 0)
        VisAmmoBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        VisAmmoBarFill.BorderSizePixel = 0
        VisAmmoBarFill.ZIndex = 83
        VisAmmoBarFill.Parent = VisAmmoBarBg

        local barFillCorner = Instance.new("UICorner")
        barFillCorner.CornerRadius = UDim.new(0, 2)
        barFillCorner.Parent = VisAmmoBarFill

        VisAmmoGradient = Instance.new("UIGradient")
        VisAmmoGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(80, 190, 255))
        VisAmmoGradient.Parent = VisAmmoBarFill
    end

    local function updateVisualizerHUD(state, targetName, ammoInfo)
        if not VisCard then return end
        if AkiraLite.ThreadFix then
            pcall(setthreadidentity, 8)
        end
        local visOn = (Visualizer == nil or Visualizer.Enabled)
        if not (RageBot and RageBot.Enabled and visOn) then
            if VisCard.Visible then
                RageTweenS:Create(VisScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { Scale = 0 }):Play()
                task.delay(0.2, function()
                    local nowVisOn = (Visualizer == nil or Visualizer.Enabled)
                    if not (RageBot and RageBot.Enabled and nowVisOn) then
                        VisCard.Visible = false
                    end
                end)
            end
            return
        end

        if not VisCard.Visible then
            VisCard.Visible = true
            RageTweenS:Create(VisScale, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
        end

        local useGradient = (GradientText == nil or GradientText.Enabled)
        VisStatusGradient.Enabled = useGradient

        -- State Visual Styling
        if state == "ACTIVE" then
            VisDot.BackgroundColor3 = Color3.fromRGB(50, 235, 120)
            VisStatusLabel.Text = targetName and ("RAGEBOT : ACTIVE [" .. string.upper(targetName) .. "]") or "RAGEBOT : ACTIVE"
            if useGradient then
                VisStatusGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(50, 235, 120))
            else
                VisStatusLabel.TextColor3 = Color3.fromRGB(50, 235, 120)
            end
        elseif state == "RELOADING" then
            VisDot.BackgroundColor3 = Color3.fromRGB(255, 175, 45)
            VisStatusLabel.Text = "RAGEBOT : RELOADING..."
            if useGradient then
                VisStatusGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 175, 45))
            else
                VisStatusLabel.TextColor3 = Color3.fromRGB(255, 175, 45)
            end
        elseif state == "SWAPPING" then
            VisDot.BackgroundColor3 = Color3.fromRGB(60, 200, 255)
            VisStatusLabel.Text = targetName and ("RAGEBOT : SWAPPING [" .. string.upper(targetName) .. "]") or "RAGEBOT : SWAPPING TARGETS"
            if useGradient then
                VisStatusGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(60, 200, 255))
            else
                VisStatusLabel.TextColor3 = Color3.fromRGB(60, 200, 255)
            end
        else -- SEARCHING
            VisDot.BackgroundColor3 = Color3.fromRGB(130, 135, 150)
            VisStatusLabel.Text = "RAGEBOT : SEARCHING"
            if useGradient then
                VisStatusGradient.Color = ColorSequence.new(Color3.fromRGB(240, 240, 245), Color3.fromRGB(140, 145, 160))
            else
                VisStatusLabel.TextColor3 = Color3.fromRGB(180, 185, 200)
            end
        end

        -- Ammo Section Display
        local showAmmo = (ShowAmmo == nil or ShowAmmo.Enabled)
        if showAmmo then
            VisAmmoRow.Visible = true
            VisDivider.Visible = true
            VisCard.Size = UDim2.fromOffset(260, 78)

            if ammoInfo then
                VisGunLabel.Text = string.upper(ammoInfo.Name)
                if ammoInfo.IsMelee then
                    VisAmmoLabel.Text = "MELEE / INF"
                    VisAmmoBarFill.Size = UDim2.new(1, 0, 1, 0)
                    VisAmmoGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(50, 235, 120))
                else
                    local cur = ammoInfo.CurAmmo
                    local maxA = ammoInfo.MaxAmmo
                    local res = ammoInfo.Reserve
                    local resStr = (res and res > 0 and res < 9999) and ("  (+" .. tostring(res) .. ")") or ""
                    VisAmmoLabel.Text = tostring(cur) .. " / " .. tostring(maxA) .. resStr

                    local pct = math.clamp(cur / math.max(maxA, 1), 0, 1)
                    RageTweenS:Create(VisAmmoBarFill, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
                        Size = UDim2.new(pct, 0, 1, 0)
                    }):Play()

                    if pct <= 0.25 then
                        VisAmmoGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 70, 70))
                    elseif pct <= 0.5 then
                        VisAmmoGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 180, 50))
                    else
                        VisAmmoGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(80, 190, 255))
                    end
                end
            else
                VisGunLabel.Text = "WEAPON"
                VisAmmoLabel.Text = "-- / --"
                VisAmmoBarFill.Size = UDim2.new(1, 0, 1, 0)
            end
        else
            VisAmmoRow.Visible = false
            VisDivider.Visible = false
            VisCard.Size = UDim2.fromOffset(260, 36)
        end
    end

    RageBot = AkiraLite.Catalogs.Combat:AddModule({
        Name = 'Ragebot',
        Function = function(callback)
            if renderCon then
                renderCon:Disconnect()
                renderCon = nil
            end
            if callback then
                createVisualizerHUD()
                pushEquip()
                if RapidFire == nil or RapidFire.Enabled then
                    applyRapidCooldowns()
                end
                renderCon = RageRunS.Heartbeat:Connect(function()
                    updateDeflection()
                    local targetPlayer, targetRoot, targetHead = getClosestTarget()
                    local ammoInfo = getEquippedAmmoInfo()

                    -- Target swapping tracking for visualizer
                    if targetPlayer then
                        if lastTarget ~= targetPlayer then
                            lastTarget = targetPlayer
                            swapTargetTime = tick()
                        end
                    else
                        lastTarget = nil
                    end

                    local isSwapping = (tick() - swapTargetTime < 0.35)
                    local isKnife = isLocalKnifeEquipped()
                    local isMeleeSlot = (getSlotNumber() == 3)

                    local desyncCF = nil
                    if targetRoot and targetHead then
                        local desyncPos
                        -- If we have knife equipped or melee slot, position directly behind enemy for knife backstab
                        if isKnife or isMeleeSlot then
                            desyncPos = (targetRoot.CFrame * CFrame.new(0, 0.4, 2.2)).Position
                        elseif hasKnifeViewModel(targetPlayer) then
                            desyncPos = (targetRoot.CFrame * CFrame.new(0, 6, 0)).Position
                        else
                            desyncPos = (targetRoot.CFrame * CFrame.new(0, 1, 2)).Position
                        end
                        desyncCF = CFrame.lookAt(desyncPos, targetHead.Position)
                    end

                    if desyncCF and lplr.Character then
                        local myRoot = lplr.Character:FindFirstChild('HumanoidRootPart')
                        if myRoot then
                            local oldCF = myRoot.CFrame
                            local oldVel = myRoot.Velocity
                            local oldRotVel = myRoot.RotVelocity
                            myRoot.CFrame = desyncCF
                            RageRunS:BindToRenderStep('__restore', 101, function()
                                if myRoot then
                                    myRoot.CFrame = oldCF
                                    myRoot.Velocity = oldVel
                                    myRoot.RotVelocity = oldRotVel
                                end
                                RageRunS:UnbindFromRenderStep('__restore')
                            end)
                        end
                    end

                    if not targetPlayer or not targetHead or not targetRoot then
                        updateVisualizerHUD("SEARCHING", nil, ammoInfo)
                        return
                    end
                    if deflecting[targetPlayer] then
                        updateVisualizerHUD("SEARCHING", nil, ammoInfo)
                        return
                    end
                    if not lplr.Character or not lplr.Character:FindFirstChild('HumanoidRootPart') then
                        updateVisualizerHUD("SEARCHING", nil, ammoInfo)
                        return
                    end
                    if not FighterController or not FighterController.LocalFighter then
                        updateVisualizerHUD("SEARCHING", nil, ammoInfo)
                        return
                    end
                    local item = FighterController.LocalFighter.EquippedItem
                    if not item then
                        updateVisualizerHUD("SEARCHING", nil, ammoInfo)
                        return
                    end

                    -- Automatic reload check
                    local okA, ammo = pcall(function() return item:Get("Ammo") end)
                    local okR, reloading = pcall(function() return (item._reload_cooldown or 0) > tick() end)
                    if (okR and reloading) or (ammoInfo and ammoInfo.IsReloading) then
                        updateVisualizerHUD("RELOADING", targetPlayer.Name, ammoInfo)
                        return
                    end

                    if (AutoReload == nil or AutoReload.Enabled) and okA and type(ammo) == "number" and ammo <= 0 then
                        if tick() - lastReload > 0.35 then
                            lastReload = tick()
                            pcall(function() FighterController.LocalFighter:Input("StartReloading") end)
                            pcall(function() item:StartReloading() end)
                        end
                        updateVisualizerHUD("RELOADING", targetPlayer.Name, ammoInfo)
                        return
                    end

                    if isSwapping then
                        updateVisualizerHUD("SWAPPING", targetPlayer.Name, ammoInfo)
                    else
                        updateVisualizerHUD("ACTIVE", targetPlayer.Name, ammoInfo)
                    end

                    if tick() - lastFire < 0.0005 then
                        return
                    end
                    lastFire = tick()

                    local originPos = desyncCF and desyncCF.Position or targetRoot.Position
                    local targetPos = targetHead.Position
                    local aimCF = CFrame.lookAt(originPos, targetPos)
                    local targetCF = targetHead.CFrame
                    local randomOffset = Vector3.new((math.random() - 0.5) * 0.1, (math.random() - 0.5) * 0.1, (math.random() - 0.5) * 0.1)
                    local aimedPos = targetPos + randomOffset
                    local objSpaceHeadOffset = targetHead.CFrame:ToObjectSpace(CFrame.new(aimedPos))
                    local cameradata = {}
                    cameradata[utf8.char(1)] = {
                        [utf8.char(0)] = RageUtil:EncodeCFrame(aimCF),
                        [utf8.char(1)] = RageUtil:EncodeCFrame(targetCF),
                        [utf8.char(2)] = targetHead,
                        [utf8.char(3)] = RageUtil:EncodeCFrame(objSpaceHeadOffset)
                    }

                    -- Attack Action: If Knife equipped or Melee slot, ONLY do HeavyAttack for knife backstab
                    local action = RageEnum:ToEnum('StartShooting')
                    local doHeavy = false
                    if isKnife or isMeleeSlot then
                        doHeavy = true
                    elseif KnifeBackstab and KnifeBackstab.Enabled and isKnife then
                        doHeavy = true
                    elseif hasKnifeViewModel(targetPlayer) then
                        doHeavy = true
                    end

                    if doHeavy then
                        local okH, heavyAct = pcall(function()
                            return RageEnum:ToEnum('HeavyAttack')
                        end)
                        if okH and heavyAct then
                            action = heavyAct
                        end
                    end

                    RageRepS.Remotes.Replication.Fighter.UseItem:FireServer(item:Get('ObjectID'), action, cameradata, nil)
                end)
            else
                if VisCard then
                    VisCard.Visible = false
                end
            end
        end
    })

    Weapon = RageBot:AddDropdown({
        Name = 'Weapon',
        List = {'Primary', 'Secondary', 'Melee'}
    })
    AutoReload = RageBot:AddToggle({
        Name = 'Auto Reload',
        Default = true
    })
    RapidFire = RageBot:AddToggle({
        Name = 'Rapid Hit',
        Default = true,
        Function = function(v)
            if v then
                applyRapidCooldowns()
            end
        end
    })
    KnifeBackstab = RageBot:AddToggle({
        Name = 'Knife Backstab Only',
        Default = true
    })
    Visualizer = RageBot:AddToggle({
        Name = 'Visualizer',
        Default = true,
        Function = function(v)
            if VisCard then
                if v and RageBot and RageBot.Enabled then
                    VisCard.Visible = true
                    RageTweenS:Create(VisScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { Scale = 1 }):Play()
                else
                    RageTweenS:Create(VisScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { Scale = 0 }):Play()
                    task.delay(0.2, function()
                        if VisCard and not (Visualizer and Visualizer.Enabled and RageBot and RageBot.Enabled) then
                            VisCard.Visible = false
                        end
                    end)
                end
            end
        end
    })
    GradientText = RageBot:AddToggle({
        Name = 'Gradient Text',
        Default = true
    })
    ShowAmmo = RageBot:AddToggle({
        Name = 'Show Ammo',
        Default = true
    })
end)
run(function()
    local TriggerBot
    local Targets
    local ShootDelay
    local Distance
    local rayCheck, delayCheck = RaycastParams.new(), tick()
    local function getTriggerBotTarget()
        rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
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
                                    mouse1release()
                                    delayCheck = tick() + ShootDelay.Value
                                else
                                    mouse1press()
                                end
                                mouseClicked = not mouseClicked
                            end
                        else
                            if mouseClicked then
                                mouse1release()
                            end
                            mouseClicked = false
                        end
                    end
                    task.wait()
                until not TriggerBot.Enabled
            else
                if mouse1click and (isrbxactive or iswindowactive)() then
                    if mouseClicked then
                        mouse1release()
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
                    task.wait()
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
run(function()
    local TargetStrafe
    local Targets
    local SearchRange
    local StrafeRange
    local YFactor
    local rayCheck = RaycastParams.new()
    rayCheck.RespectCanCollide = true
    local module, old
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
                    local ent = not UserInputService:IsKeyDown(Enum.KeyCode.S) and entitylib.EntityPosition({
                        Range = SearchRange.Value,
                        Wallcheck = false,
                        Part = 'RootPart',
                        Players = true,
                        NPCs = false
                    })
                    if ent then
                        local root, targetPos = entitylib.character.RootPart, ent.RootPart.Position
                        rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera, ent.Character}
                        rayCheck.CollisionGroup = root.CollisionGroup
                        if flymod.Enabled or workspace:Raycast(targetPos, Vector3.new(0, - 70, 0), rayCheck) then
                            local factor, localPosition = 0, root.Position
                            if ent ~= oldent then
                                ang = math.deg(select(2, CFrame.lookAt(targetPos, localPosition):ToEulerAnglesYXZ()))
                            end
                            local yFactor = math.abs(localPosition.Y - targetPos.Y) * (YFactor.Value / 100)
                            local entityPos = Vector3.new(targetPos.X, localPosition.Y, targetPos.Z)
                            local newPos = entityPos + (CFrame.Angles(0, math.rad(ang), 0).LookVector * (StrafeRange.Value - yFactor))
                            local startRay, endRay = entityPos, newPos
                            if not wallcheck and workspace:Raycast(targetPos, (localPosition - targetPos), rayCheck) then
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
                            if not flymod.Enabled and not workspace:Raycast(newPos, Vector3.new(0, - 70, 0), rayCheck) then
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
                    return old(self, vec, face)
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
end)
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
    local SnowParticle = Instance.new("ParticleEmitter")
    SnowParticle.EmissionDirection = "Bottom"
    SnowParticle.Rate = 20000
    SnowParticle.Lifetime = NumberRange.new(3.5, 3.5)
    SnowParticle.Speed = NumberRange.new(50, 50)
    SnowParticle.Texture = "rbxassetid://92367298778210"
    SnowParticle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0.4)})
    SnowParticle.SpreadAngle = Vector2.new(70, 70)
    SnowParticle.Parent = SnowEffect
    SnowParticle:Clone().Parent = SnowEffect
    SnowParticle:Clone().Parent = SnowEffect
    local Time = {}
    Shader = AkiraLite.Catalogs.Other:AddModule({
        Name = 'Shader',
        Function = function(callback)
            if callback then
                cacheLighting = {Lighting.Ambient; Lighting.Brightness; Lighting.ColorShift_Bottom; Lighting.ColorShift_Top; Lighting.EnvironmentDiffuseScale; Lighting.EnvironmentSpecularScale; Lighting.GlobalShadows; Lighting.OutdoorAmbient; Lighting.ShadowSoftness; Lighting.TimeOfDay; }
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
                    if entitylib.isAlive then
                        SnowEffect.Position = entitylib.character.RootPart.Position + vector.create(0, 90, 0)
                    end
                end))
                BlurEffect.Parent = Lighting
                ColorCorrectionEffect.Parent = Lighting
            else
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
                        while UserInputService:IsKeyDown(Enum.KeyCode.Space) do
                            if entitylib.isAlive and lplr.Character.PrimaryPart then
                                local PrimaryPart = lplr.Character.PrimaryPart
                                PrimaryPart.Velocity = vector.create(PrimaryPart.Velocity.X, Velocity.Value, PrimaryPart.Velocity.Z)
                            end
                            wait()
                        end
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
run(function()
    local Trails
    local Texture
    local Lifetime
    local Thickness
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

-- =========================================================================
-- AKIRALITE VIEWMODEL CHANGER & WEAPON / ARM CHAMS
-- =========================================================================
run(function()
    local Viewmodel
    local OffsetToggle, OffsetX, OffsetY, OffsetZ
    local ArmChamsToggle, ArmMaterial, ArmColor, ArmTransparency
    local WeaponChamsToggle, WeaponMaterial, WeaponColor, WeaponTransparency
    local DisableTextures, NoMotion

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
    local _origShake = nil

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

    local function isArmName(name)
        if type(name) ~= "string" then return false end
        name = string.lower(name)
        local keys = { "arm", "hand", "sleeve", "elbow", "wrist", "shoulder", "finger", "thumb", "glove" }
        for _, k in ipairs(keys) do
            if string.find(name, k, 1, true) then return true end
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

    local function freezeSpring(spring, targetVal)
        if not spring then return end
        pcall(function()
            if spring.Value ~= nil then spring.Value = targetVal end
            if spring.Position ~= nil then spring.Position = targetVal end
            if spring.Target ~= nil then spring.Target = targetVal end
            if spring.Goal ~= nil then spring.Goal = targetVal end
            if spring.Velocity ~= nil then
                if typeof(targetVal) == "Vector3" then spring.Velocity = Vector3.zero
                elseif typeof(targetVal) == "Vector2" then spring.Velocity = Vector2.zero
                else spring.Velocity = 0 end
            end
        end)
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

    local _vmUpdateHooked = false
    local function ensureViewModelUpdateHook()
        if _vmUpdateHooked then return end
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
                    return origUpdate(vm, dt, camData, offsets, ...)
                end
                _vmUpdateHooked = true
            end
        end)
    end

    local function getVMScopes()
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

        return armParts, wepParts, vmModels
    end

    Viewmodel = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Viewmodel',
        Function = function(callback)
            if callback then
                if AkiraLite.ThreadFix then
                    pcall(setthreadidentity, 8)
                end
                Viewmodel:Clean(RunService.RenderStepped:Connect(function()
                    local armParts, wepParts, vmModels = getVMScopes()
                    local doOffset = OffsetToggle.Enabled
                    local offCFrame = CFrame.new(OffsetX.Value, OffsetY.Value, OffsetZ.Value)
                    local doArmChams = ArmChamsToggle.Enabled
                    local armMat = VM_MATERIALS[ArmMaterial.Value] or Enum.Material.ForceField
                    local armCol = VM_COLORS[ArmColor.Value] or Color3.fromRGB(53, 215, 199)
                    local armTr = ArmTransparency.Value
                    local doWepChams = WeaponChamsToggle.Enabled
                    local wepMat = VM_MATERIALS[WeaponMaterial.Value] or Enum.Material.ForceField
                    local wepCol = VM_COLORS[WeaponColor.Value] or Color3.fromRGB(255, 110, 180)
                    local wepTr = WeaponTransparency.Value
                    local doStrip = DisableTextures.Enabled

                    if doOffset then
                        for _, model in ipairs(vmModels) do
                            if model.PrimaryPart then
                                model.PrimaryPart.CFrame = model.PrimaryPart.CFrame * offCFrame
                            end
                        end
                    end

                    if doArmChams then
                        for _, p in ipairs(armParts) do
                            saveProp(p, true)
                            if p.Material ~= armMat then p.Material = armMat end
                            if p.Color ~= armCol then p.Color = armCol end
                            if p.Transparency ~= armTr then p.Transparency = armTr end
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

                    if doStrip then
                        for _, p in ipairs(wepParts) do
                            if p:IsA("Decal") or p:IsA("Texture") then
                                saveProp(p, false)
                                if p.Transparency ~= 1 then p.Transparency = 1 end
                            end
                        end
                    end

                    -- No Motion suppression (fully hooks and freezes springs/bobbing)
                    if NoMotion.Enabled then
                        ensureViewModelUpdateHook()
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
                                local vm = item.ViewModel or item._viewModel
                                freezeViewModelMotion(vm)
                            end

                            local psc = lp and lp:FindFirstChild("PlayerScripts") and lp.PlayerScripts:FindFirstChild("Controllers")
                            local camMod = psc and psc:FindFirstChild("CameraController")
                            if camMod then
                                local camCtrl = require(camMod)
                                if camCtrl then
                                    if _origShake == nil and camCtrl._shake_enabled ~= nil then
                                        _origShake = camCtrl._shake_enabled
                                    end
                                    camCtrl._shake_enabled = false
                                    freezeSpring(camCtrl._sway_spring, Vector2.zero)
                                    freezeSpring(camCtrl._bobbing_speed_spring, 0)
                                    freezeSpring(camCtrl._bobbing_value_spring, 0)
                                    freezeSpring(camCtrl._leaning_spring, 0)
                                    freezeSpring(camCtrl._jump_spring, 0)
                                    freezeSpring(camCtrl._sliding_spring, 0)
                                end
                            end
                        end)
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

    DisableTextures = Viewmodel:AddToggle({
        Name = 'Disable Textures',
        Default = false
    })

    NoMotion = Viewmodel:AddToggle({
        Name = 'No Motion',
        Default = false
    })
end)

-- =========================================================================
-- AKIRALITE CUSTOM CROSSHAIR
-- =========================================================================
run(function()
    local Crosshair
    local Style, CenterDot, OutlineToggle, FollowTarget
    local Gap, Length, Thickness
    local Angle, SpinToggle, RecoilBounce
    local CrossColor

    local CROSS_COLORS = {
        White = Color3.fromRGB(255, 255, 255),
        Cyan = Color3.fromRGB(53, 215, 199),
        Red = Color3.fromRGB(255, 65, 65),
        Green = Color3.fromRGB(65, 255, 100),
        Yellow = Color3.fromRGB(255, 220, 65),
        Purple = Color3.fromRGB(180, 100, 255),
        Pink = Color3.fromRGB(255, 110, 180),
        Blue = Color3.fromRGB(65, 140, 255),
    }

    local PLUS = { Vector2.new(0, -1), Vector2.new(0, 1), Vector2.new(-1, 0), Vector2.new(1, 0) }
    local DIAG = { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(-1, 1), Vector2.new(1, 1) }
    local INV_SQ2 = 0.7071067811865475

    local _chLines = {}
    local _chLinesBlk = {}
    local _chDot = nil
    local _chDotBlk = nil

    local function cleanupCrosshair()
        for i = 1, 4 do
            if _chLines[i] then pcall(function() _chLines[i]:Remove() end) _chLines[i] = nil end
            if _chLinesBlk[i] then pcall(function() _chLinesBlk[i]:Remove() end) _chLinesBlk[i] = nil end
        end
        if _chDot then pcall(function() _chDot:Remove() end) _chDot = nil end
        if _chDotBlk then pcall(function() _chDotBlk:Remove() end) _chDotBlk = nil end
    end

    Crosshair = AkiraLite.Catalogs.Render:AddModule({
        Name = 'Crosshair',
        Function = function(callback)
            if callback then
                if AkiraLite.ThreadFix then
                    pcall(setthreadidentity, 8)
                end
                for i = 1, 4 do
                    local l = Drawing.new('Line')
                    l.ZIndex = 3
                    _chLines[i] = l

                    local lb = Drawing.new('Line')
                    lb.ZIndex = 2
                    lb.Color = Color3.new(0, 0, 0)
                    _chLinesBlk[i] = lb
                end
                _chDot = Drawing.new('Circle')
                _chDot.ZIndex = 4
                _chDotBlk = Drawing.new('Circle')
                _chDotBlk.ZIndex = 3
                _chDotBlk.Color = Color3.new(0, 0, 0)

                Crosshair:Clean(cleanupCrosshair)
                Crosshair:Clean(RunService.RenderStepped:Connect(function()
                    local vp = gameCamera.ViewportSize
                    local cx, cy = vp.X * 0.5, vp.Y * 0.5

                    if FollowTarget and FollowTarget.Enabled then
                        local trgPlayer = lastTarget
                        local trgHead = nil
                        if trgPlayer and trgPlayer.Character then
                            trgHead = trgPlayer.Character:FindFirstChild("Head") or trgPlayer.Character:FindFirstChild("HumanoidRootPart")
                        end
                        if not trgHead and type(getClosestTarget) == "function" then
                            local _, _, h = getClosestTarget()
                            trgHead = h
                        end
                        if trgHead then
                            local p2d, vis = gameCamera:WorldToViewportPoint(trgHead.Position)
                            if vis and p2d.Z > 0 then
                                cx, cy = p2d.X, p2d.Y
                            end
                        end
                    end

                    local styleVal = Style.Value
                    local gapVal = Gap.Value
                    local lenVal = Length.Value
                    local thVal = Thickness.Value
                    local col = CROSS_COLORS[CrossColor.Value] or Color3.fromRGB(255, 255, 255)
                    local outl = OutlineToggle.Enabled

                    local rotDeg = Angle.Value
                    if SpinToggle.Enabled then
                        rotDeg = (rotDeg + tick() * 180) % 360
                    end
                    local rotRad = math.rad(rotDeg)
                    local cosR, sinR = math.cos(rotRad), math.sin(rotRad)

                    local chev = styleVal == "Chevron"
                    local diag = styleVal == "X"

                    for i = 1, 4 do
                        local l = _chLines[i]
                        local lb = _chLinesBlk[i]
                        local hide = styleVal == "Dot" or (styleVal == "T" and i == 1) or (chev and i > 2)
                        if l then
                            if hide then
                                l.Visible = false
                                if lb then lb.Visible = false end
                            else
                                local nx, ny
                                if chev then
                                    local sx = (i == 1) and -1 or 1
                                    nx, ny = sx * 0.707, 0.707
                                elseif diag then
                                    nx, ny = DIAG[i].X * INV_SQ2, DIAG[i].Y * INV_SQ2
                                else
                                    nx, ny = PLUS[i].X, PLUS[i].Y
                                end
                                local rnx = nx * cosR - ny * sinR
                                local rny = nx * sinR + ny * cosR
                                local from = Vector2.new(cx + rnx * gapVal, cy + rny * gapVal)
                                local to = Vector2.new(cx + rnx * (gapVal + lenVal), cy + rny * (gapVal + lenVal))

                                if lb then
                                    if outl then
                                        lb.From = from
                                        lb.To = to
                                        lb.Thickness = thVal + 2
                                        lb.Transparency = 1
                                        lb.Visible = true
                                    else
                                        lb.Visible = false
                                    end
                                end

                                l.From = from
                                l.To = to
                                l.Thickness = thVal
                                l.Color = col
                                l.Transparency = 1
                                l.Visible = true
                            end
                        end
                    end

                    if _chDot then
                        if styleVal == "Dot" or CenterDot.Enabled then
                            local r = math.max(thVal * 0.5 + 0.5, 1)
                            if styleVal == "Dot" then r = thVal + 2 end
                            if _chDotBlk then
                                if outl then
                                    _chDotBlk.Filled = true
                                    _chDotBlk.Position = Vector2.new(cx, cy)
                                    _chDotBlk.Radius = r + 1
                                    _chDotBlk.Transparency = 1
                                    _chDotBlk.Visible = true
                                else
                                    _chDotBlk.Visible = false
                                end
                            end
                            _chDot.Filled = true
                            _chDot.Position = Vector2.new(cx, cy)
                            _chDot.Radius = r
                            _chDot.Color = col
                            _chDot.Transparency = 1
                            _chDot.Visible = true
                        else
                            _chDot.Visible = false
                            if _chDotBlk then _chDotBlk.Visible = false end
                        end
                    end
                end))
            else
                cleanupCrosshair()
            end
        end
    })

    Style = Crosshair:AddDropdown({
        Name = 'Style',
        List = {'Cross', 'X', 'T', 'Dot', 'Chevron'}
    })
    CrossColor = Crosshair:AddDropdown({
        Name = 'Color',
        List = {'White', 'Cyan', 'Red', 'Green', 'Yellow', 'Purple', 'Pink', 'Blue'}
    })
    CenterDot = Crosshair:AddToggle({
        Name = 'Center Dot',
        Default = true
    })
    OutlineToggle = Crosshair:AddToggle({
        Name = 'Outline',
        Default = true
    })
    Gap = Crosshair:AddSlider({
        Name = 'Gap',
        Min = 0,
        Max = 20,
        Default = 4
    })
    Length = Crosshair:AddSlider({
        Name = 'Length',
        Min = 2,
        Max = 24,
        Default = 7
    })
    Thickness = Crosshair:AddSlider({
        Name = 'Thickness',
        Min = 1,
        Max = 5,
        Default = 2
    })
    Angle = Crosshair:AddSlider({
        Name = 'Angle',
        Min = 0,
        Max = 360,
        Default = 0
    })
    SpinToggle = Crosshair:AddToggle({
        Name = 'Spin',
        Default = false
    })
    FollowTarget = Crosshair:AddToggle({
        Name = 'Follow Target',
        Default = false
    })
end)

-- =========================================================================
-- AKIRALITE WORLD VISUALS (PORTED FEATURES FROM HYDRA REFERENCE)
-- =========================================================================
-- scratch/world_catalog_snippet.lua
-- World Catalog for AkiraLite
run(function()
    if not AkiraLite.Catalogs.World then return end

    local Lighting = cloneref(game:GetService("Lighting"))
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

    -- 1. PRESETS MODULE
    local Presets = AkiraLite.Catalogs.World:AddModule({
        Name = 'Presets',
        Function = function(callback)
        end
    })

    local LightingModule = AkiraLite.Catalogs.World:AddModule({
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

    -- 2. FOG & ATMOSPHERE
    local FogModule = AkiraLite.Catalogs.World:AddModule({
        Name = 'Fog & Atmosphere',
        Function = function(callback)
            if not callback then
                pcall(function()
                    Lighting.FogColor = _origLighting.FogColor
                    Lighting.FogStart = _origLighting.FogStart
                    Lighting.FogEnd = _origLighting.FogEnd
                end)
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
    local AtmosphereDensity = FogModule:AddSlider({
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
    local AtmosphereHaze = FogModule:AddSlider({
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
    local SkyboxPreset
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

    local SkyboxModule = AkiraLite.Catalogs.World:AddModule({
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
    local WeatherPreset, WeatherIntensity, WeatherSpeed, WeatherRate
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

    local WeatherModule = AkiraLite.Catalogs.World:AddModule({
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

    local AmbienceModule = AkiraLite.Catalogs.World:AddModule({
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

    local PostFxModule = AkiraLite.Catalogs.World:AddModule({
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
            if LightingModule.Enabled then LightingModule:Toggle() end
            if FogModule.Enabled then FogModule:Toggle() end
            if SkyboxModule.Enabled then SkyboxModule:Toggle() end
            if PostFxModule.Enabled then PostFxModule:Toggle() end
        elseif preset == 'Competitive Clarity' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 12
            Lighting.Brightness = 2.8
            Lighting.ExposureCompensation = 0.1
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(170, 170, 170)
            Lighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
            if not FogModule.Enabled then FogModule:Toggle() end
            Lighting.FogStart = 0
            Lighting.FogEnd = 10000
            Lighting.FogColor = Color3.fromRGB(200, 200, 200)
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'FPSBoost'
            applySky('FPSBoost')
        elseif preset == 'Sunny Day' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 13
            Lighting.Brightness = 2.4
            Lighting.ExposureCompensation = 0.05
            Lighting.EnvironmentDiffuseScale = 0.4
            Lighting.EnvironmentSpecularScale = 0.3
            Lighting.Ambient = Color3.fromRGB(160, 170, 190)
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'BetterSky'
            applySky('BetterSky')
        elseif preset == 'Golden Hour' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 17.5
            Lighting.Brightness = 2.5
            Lighting.ExposureCompensation = 0.15
            Lighting.Ambient = Color3.fromRGB(140, 120, 105)
            Lighting.OutdoorAmbient = Color3.fromRGB(150, 115, 85)
            if not FogModule.Enabled then FogModule:Toggle() end
            Lighting.FogColor = Color3.fromRGB(255, 170, 110)
            Lighting.FogStart = 100
            Lighting.FogEnd = 4000
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'PinkMountains'
            applySky('PinkMountains')
        elseif preset == 'Cinematic' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 15.5
            Lighting.Brightness = 2.2
            Lighting.ExposureCompensation = -0.1
            Lighting.Ambient = Color3.fromRGB(100, 120, 140)
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'Realistic'
            applySky('Realistic')
        elseif preset == 'Midnight' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 0
            Lighting.Brightness = 1.2
            Lighting.ExposureCompensation = 0.1
            Lighting.Ambient = Color3.fromRGB(70, 80, 110)
            Lighting.OutdoorAmbient = Color3.fromRGB(60, 70, 105)
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'BetterNight'
            applySky('BetterNight')
        elseif preset == 'Neon Nights' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 0
            Lighting.Brightness = 1.5
            Lighting.ExposureCompensation = 0.1
            Lighting.Ambient = Color3.fromRGB(60, 20, 100)
            Lighting.OutdoorAmbient = Color3.fromRGB(20, 10, 60)
            if not FogModule.Enabled then FogModule:Toggle() end
            Lighting.FogColor = Color3.fromRGB(160, 40, 220)
            Lighting.FogStart = 0
            Lighting.FogEnd = 2500
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'Nebula3'
            applySky('Nebula3')
        elseif preset == 'Vaporwave' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 18
            Lighting.Brightness = 2.0
            Lighting.ExposureCompensation = 0.1
            Lighting.Ambient = Color3.fromRGB(220, 100, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(50, 180, 230)
            if not FogModule.Enabled then FogModule:Toggle() end
            Lighting.FogColor = Color3.fromRGB(255, 120, 220)
            Lighting.FogStart = 0
            Lighting.FogEnd = 3000
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'Retro'
            applySky('Retro')
        elseif preset == 'Crimson Dusk' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 18.5
            Lighting.Brightness = 1.8
            Lighting.Ambient = Color3.fromRGB(120, 20, 30)
            Lighting.OutdoorAmbient = Color3.fromRGB(80, 10, 20)
            if not FogModule.Enabled then FogModule:Toggle() end
            Lighting.FogColor = Color3.fromRGB(180, 30, 40)
            Lighting.FogStart = 0
            Lighting.FogEnd = 2000
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'DarkMountains'
            applySky('DarkMountains')
        elseif preset == 'Arctic' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 11
            Lighting.Brightness = 2.6
            Lighting.Ambient = Color3.fromRGB(200, 230, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 220, 250)
            if not FogModule.Enabled then FogModule:Toggle() end
            Lighting.FogColor = Color3.fromRGB(220, 240, 255)
            Lighting.FogStart = 0
            Lighting.FogEnd = 3500
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'Moon'
            applySky('Moon')
        elseif preset == 'Toxic' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 14
            Lighting.Brightness = 2.0
            Lighting.Ambient = Color3.fromRGB(40, 90, 40)
            Lighting.OutdoorAmbient = Color3.fromRGB(30, 70, 30)
            if not FogModule.Enabled then FogModule:Toggle() end
            Lighting.FogColor = Color3.fromRGB(60, 180, 60)
            Lighting.FogStart = 0
            Lighting.FogEnd = 2000
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'Alien'
            applySky('Alien')
        elseif preset == 'Deep Space' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 0
            Lighting.Brightness = 1.0
            Lighting.Ambient = Color3.fromRGB(10, 10, 20)
            Lighting.OutdoorAmbient = Color3.fromRGB(5, 5, 15)
            if not FogModule.Enabled then FogModule:Toggle() end
            Lighting.FogColor = Color3.fromRGB(15, 10, 30)
            Lighting.FogStart = 0
            Lighting.FogEnd = 5000
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'Space2'
            applySky('Space2')
        elseif preset == 'Retro Aesthetic' then
            if not LightingModule.Enabled then LightingModule:Toggle() end
            Lighting.ClockTime = 16
            Lighting.Brightness = 2.2
            Lighting.Ambient = Color3.fromRGB(180, 140, 100)
            if not SkyboxModule.Enabled then SkyboxModule:Toggle() end
            SkyboxPreset.Value = 'Retro'
            applySky('Retro')
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
