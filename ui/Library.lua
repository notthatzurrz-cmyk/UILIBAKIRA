                               
                       
local function InitLibrary()
        local w = {
            Tabs = {},
            Keybind = {"RightShift", "RightControl"},
            Loaded = false,
            Modules = {},
            Catalogs = {},
            Libraries = {},
            Binds = {},
            Place = game.PlaceId,
            ThreadFix = setthreadidentity and true or false,
            Scale = {
                Value = 1
            },
            GradientKeypoints = 3,
            TargetHudFrame = Instance.new("Frame"),
            MainScreenGui = Instance.new("ScreenGui"),
            GlobalGui = Instance.new("ScreenGui"),
            ClickGuiStatus = false,
            Font = Enum.Font.BuilderSans
        }
        local m = cloneref or function(L)
            return L
        end
        local L = shared.AkiraLiteFile
        local B = getcustomasset
        local P = m(game:GetService("UserInputService"))
        local A = m(game:GetService("TextChatService"))
        local d = m(game:GetService("TweenService"))
        local K = m(game:GetService("TextService"))
        local x = m(game:GetService("GuiService"))
        local j = m(game:GetService("RunService"))
        local M = m(game:GetService("HttpService"))
        local Y = m(game:GetService("CoreGui"))
        local c = m(game:GetService("Players"))
        local T = c.LocalPlayer
        local c = Instance.new("GetTextBoundsParams")
        c.Width = math.huge
        local T = function(l)
            l()
        end
                                                                            
                                                                              
                                                                           
                                                                
                          
  
                                                                             
                                                                             
                                                                               
                    
local lCache, lCacheCount = {}, 0
local LUAU_L_CACHE_MAX = 1024
local l = function(u, n, s)
    local key = tostring(u) .. "\0" .. tostring(n) .. "\0" .. tostring(s)
    local cached = lCache[key]
    if cached then
        return cached
    end
    c.Text = u
    c.Size = n
    if typeof(s) == "Font" then
        c.Font = s
    end
    local bounds = K:GetTextBoundsAsync(c)
    if lCacheCount >= LUAU_L_CACHE_MAX then
        lCache = {}
        lCacheCount = 0
    end
    lCache[key] = bounds
    lCacheCount = lCacheCount + 1
    return bounds
end
        local function K(K)
            local u = 0
            for n in K do
                u += 1
            end
            return u
        end
        local function K(u)
            u = u:gsub("<br%s*/>", "\n")
            return (u:gsub("<[^<>]->", ""))
        end
        local u = {}
        local function n(s)
            s.Connections = {}
            function s:Clean(s)
                if typeof(s) == "Instance" then
                    table.insert(self.Connections, {
                        Disconnect = function()
                            s:ClearAllChildren()
                            s:Destroy()
                        end
                    })
                elseif type(s) == "function" then
                    table.insert(self.Connections, {
                        Disconnect = s
                    })
                else
                    table.insert(self.Connections, s)
                end
            end
        end
        n(w)
        local function s(O, k)
            O.InputBegan:Connect(function(C)
                if not w.ClickGuiStatus then
                    return
                end
                if (C.UserInputType == Enum.UserInputType.MouseButton1 or C.UserInputType == Enum.UserInputType.Touch) and (C.Position.Y - O.AbsolutePosition.Y < 40 or k) then
                    local k = Vector2.new(O.AbsolutePosition.X - C.Position.X, O.AbsolutePosition.Y - C.Position.Y + x:GetGuiInset().Y) / w.Scale.Value
                    local x = P.InputChanged:Connect(function(f)
                        if f.UserInputType == (C.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                            local Z = f.Position
                            if P:IsKeyDown(Enum.KeyCode.LeftShift) then
                                k = (k // 3) * 3
                                Z = (Z // 3) * 3
                            end
                            O.Position = UDim2.fromOffset((Z.X / w.Scale.Value) + k.X, (Z.Y / w.Scale.Value) + k.Y)
                        end
                    end)
                    local O
                    O = C.Changed:Connect(function()
                        if C.UserInputState == Enum.UserInputState.End then
                            if x then
                                x:Disconnect()
                            end
                            if O then
                                O:Disconnect()
                            end
                        end
                    end)
                end
            end)
        end
        local function x(O, k, C)
            local f = 0
            return O:Connect(function(O)
                f += O
                if f >= k then
                    f = 0
                    C()
                end
            end)
        end
        local function O(k, C)
            local f = Instance.new("UICorner")
            f.CornerRadius = C or UDim.new(0, 5)
            f.Parent = k
            return f
        end
        local function k(k)
            local C = Instance.new("ImageLabel")
            C.Name = "Blur"
            C.Size = UDim2.new(1, 89, 1, 52)
            C.Position = UDim2.fromOffset(- 48.0, - 31.0)
            C.BackgroundTransparency = 1
            C.Image = "rbxassetid://74663567791967"
            C.ScaleType = Enum.ScaleType.Slice
            C.SliceCenter = Rect.new(52, 31, 261, 502)
            C.ZIndex = - 100.0
            C.Parent = k
            return C
        end
        local function k(k)
            local C = Instance.new("ImageLabel")
            C.Name = "Blur2"
            C.Size = UDim2.new(1, 110, 1, 110)
            C.Position = UDim2.fromOffset(- 60.0, - 60.0)
            C.BackgroundTransparency = 1
            C.Image = "rbxassetid://76572707349274"
            C.ScaleType = Enum.ScaleType.Slice
            C.SliceCenter = Rect.new(95, 50, 229, 580)
            C.ZIndex = - 100.0
            C.Parent = k
            return C
        end
        local function k(C)
            local f = Instance.new("ImageLabel")
            f.Name = "Shadow"
            f.Size = UDim2.new(1, 32, 1, 32)
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            f.Position = UDim2.fromScale(0.5, 0.5)
            f.BackgroundTransparency = 1
            f.Image = "rbxassetid://85528155206269"
            f.ImageTransparency = 0.5
            f.ScaleType = Enum.ScaleType.Slice
            f.SliceCenter = Rect.new(72, 50, 864, 50)
            f.ZIndex = - 100.0
            f.Parent = C
            return f
        end
        local function C(f)
            local Z = Instance.new("ImageLabel")
            Z.Name = "Shadow"
            Z.Size = UDim2.new(1, 36, 1, 36)
            Z.AnchorPoint = Vector2.new(0.5, 0.5)
            Z.Position = UDim2.fromScale(0.5, 0.5)
            Z.BackgroundTransparency = 1
            Z.Image = "rbxassetid://85528155206269"
            Z.ImageTransparency = 0.5
            Z.ScaleType = Enum.ScaleType.Slice
            Z.SliceCenter = Rect.new(40, 40, 896, 46)
            Z.ZIndex = - 100.0
            Z.Parent = f
            return Z
        end
        local function f(Z)
            local X = Instance.new("ImageLabel")
            X.Name = "Shadow"
            X.Size = UDim2.new(1, 62, 1, 62)
            X.AnchorPoint = Vector2.new(0.5, 0.5)
            X.Position = UDim2.fromScale(0.5, 0.5)
            X.BackgroundTransparency = 1
            X.Image = "rbxassetid://88450401626084"
            X.ScaleType = Enum.ScaleType.Slice
            X.ImageTransparency = 0
            X.SliceCenter = Rect.new(31, 31, 71, 51)
            X.ZIndex = - 100.0
            X.Parent = Z
            return X
        end
        local function Z(X)
            for e, z in X do
                if type(z) == "table" then
                    Z(z)
                end
                X[e] = nil
            end
        end
        if not isfolder("AkiraLite") then
            makefolder("AkiraLite")
        end
        if not isfolder("AkiraLite/Config") then
            makefolder("AkiraLite/Config")
        end
        local function X(e)
            local z, _ = pcall(function()
                return M:JSONDecode(readfile(e))
            end)
            return z and type(_) == "table" and _ or nil
        end
        local e = {
            MainColor = Color3.fromRGB(255, 255, 255),
            SecondaryColor = Color3.fromRGB(160, 160, 160),
            ThirdColor = Color3.fromRGB(18, 18, 22)
        }
                                                   
        do
            e.Font = Font.fromEnum(Enum.Font.BuilderSans)
            c.Font = e.Font
        end
        local function L(B)
            return math.sin(DateTime.now().UnixTimestampMillis / 600 + B.X * 0.005 + B.Y * 0.06) * 0.5 + 0.5
        end
        function w:GetColor(B)
            local c = L(vector.create(B.x, 0))
            if e.ThirdColor then
                if c <= 0.5 then
                    return e.MainColor:Lerp(e.SecondaryColor, c * 2)
                end
                return e.SecondaryColor:Lerp(e.ThirdColor, (c - 0.5) * 2)
            end
            return e.SecondaryColor:Lerp(e.MainColor, c)
        end
        local B = {}
        local c = {}
        local z = {}
        local _ = {}
        local function I(i)
            local J = Instance.new("UIGradient")
            local V = {}
            if B.Value ~= "Static" then
                for r = 0, w.GradientKeypoints do
                    local o = r / w.GradientKeypoints
                    local r = i.AbsoluteSize * o
                    table.insert(V, ColorSequenceKeypoint.new(o, w:GetColor(B.Value ~= "Breathe" and i.AbsolutePosition + r or vector.zero)))
                end
            else
                table.insert(V, ColorSequenceKeypoint.new(0, e.MainColor))
                if e.ThirdColor then
                    table.insert(V, ColorSequenceKeypoint.new(0.5, e.SecondaryColor))
                    table.insert(V, ColorSequenceKeypoint.new(1, e.ThirdColor))
                else
                    table.insert(V, ColorSequenceKeypoint.new(1, e.SecondaryColor))
                end
            end
            J.Color = ColorSequence.new(V)
            table.insert(_, J)
            J.Parent = i
            return J
        end
        local i = 0
        w:Clean(x(j.PreRender, 0.05, function()
                                                                                
                                                                      
                                                                           
                                                                        
                                                                           
                                                                           
                                                                                
                                                                              
              
                                                                            
                                                                    
            if not w.ClickGuiStatus then
                e.FinalColor = w:GetColor(vector.zero)
                return
            end
            for _, i in next, _ do
                if i:IsA("GuiObject") and i.Parent and i.Visible then
                    local _ = {}
                    if B.Value ~= "Static" then
                        for J = 0, w.GradientKeypoints do
                            local V = J / w.GradientKeypoints
                            local J = i.Parent.AbsoluteSize * V
                            table.insert(_, ColorSequenceKeypoint.new(V, w:GetColor(B.Value ~= "Breathe" and i.Parent.AbsolutePosition + J or vector.zero)))
                        end
                    else
                        if e.ThirdColor then
                            table.insert(_, ColorSequenceKeypoint.new(0, e.MainColor))
                            table.insert(_, ColorSequenceKeypoint.new(0.5, e.SecondaryColor))
                            table.insert(_, ColorSequenceKeypoint.new(1, e.ThirdColor))
                        else
                            table.insert(_, ColorSequenceKeypoint.new(0, e.MainColor))
                            table.insert(_, ColorSequenceKeypoint.new(1, e.SecondaryColor))
                        end
                    end
                    i.Color = ColorSequence.new(_)
                end
            end
            e.FinalColor = w:GetColor(vector.zero)
        end))
        if shared.AkiraLite and shared.AkiraLite.Uninject then
            shared.AkiraLite:Uninject()
        end
        w.Libraries = {
            getfontsize = l,
            uipallet = e,
            addGradient = I
        }
        local _ = Instance.new("Sound")
        _.SoundId = "rbxassetid://137273815815490"
        _.TimePosition = 0.21
        _.PlayOnRemove = true
        local i, J, V, r, o, Q, p
        local F = {}
        function w:CreateGUI()
            i = w.MainScreenGui
            i.Name = "AkiraLite"
            i.DisplayOrder = 2147483647
            i.ScreenInsets = Enum.ScreenInsets.None
            i.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            J = w.GlobalGui
            J.Name = "AkiraLiteGlobal"
            J.DisplayOrder = 2147483647
            J.ScreenInsets = Enum.ScreenInsets.None
            J.ZIndexBehavior = Enum.ZIndexBehavior.Global
            w.ClickGuiLoaded = w.ClickGuiStatus
            if w.ThreadFix then
                i.Parent = m(game:GetService("CoreGui"))
                J.Parent = m(game:GetService("CoreGui"))
            else
                i.Parent = m(game:GetService("Players")).LocalPlayer.PlayerGui
                i.ResetOnSpawn = false
                J.Parent = m(game:GetService("Players")).LocalPlayer.PlayerGui
                J.ResetOnSpawn = false
            end
            V = Instance.new("Frame")
            V.Name = "ClickGui"
            V.Size = UDim2.fromScale(1.52, 0.5)
            V.Position = UDim2.fromScale(0.5, 0.08)
            V.AnchorPoint = Vector2.new(0.5, 0)
            V.BackgroundTransparency = 1
            V.SizeConstraint = Enum.SizeConstraint.RelativeYY
            V.Visible = true
            V.Parent = i
            local m = Instance.new("TextButton")
            m.Name = "Modal"
            m.BackgroundTransparency = 1
            m.Text = ""
            m.Modal = true
            m.Visible = self.ClickGuiStatus
            m.Parent = i
            local m = Instance.new("Frame")
            m.Name = "Main"
            m.Size = UDim2.fromScale(1, 1)
            m.BackgroundTransparency = 1
            m.Visible = true
            m.Parent = i
            p = Instance.new("Frame")
            p.Name = "ArrayList"
            p.Size = UDim2.fromScale(1, 1)
            p.BackgroundTransparency = 1
            p.Visible = false
            p.Parent = J
            local m = Instance.new("UIListLayout")
            m.FillDirection = Enum.FillDirection.Vertical
            m.VerticalAlignment = Enum.VerticalAlignment.Top
            m.HorizontalAlignment = Enum.HorizontalAlignment.Right
            m.SortOrder = Enum.SortOrder.LayoutOrder
            m.Parent = p
            local m = Instance.new("UIPadding")
            m.PaddingBottom = UDim.new(0.03, 0)
            m.PaddingTop = UDim.new(0.03, 0)
            m.PaddingLeft = UDim.new(0.01, 0)
            m.PaddingRight = UDim.new(0.01, 0)
            m.Parent = p
            local m = Instance.new("UIScale", V)
            m.Scale = w.ClickGuiStatus and w.Scale.Value or 0
            r = Instance.new("ImageLabel")
            r.Name = "Gradient"
            r.AnchorPoint = Vector2.new(0.5, 1)
            r.Position = UDim2.fromScale(0.5, 1)
            r.Size = UDim2.fromScale(1, 1)
            r.Image = "rbxassetid://107200271119058"
            r.ImageTransparency = w.ClickGuiStatus and 0.76 or 1
            r.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            r.BackgroundTransparency = 1
            r.ZIndex = - 10.0
            r.Visible = true
            r.Parent = i
            o = r:Clone()
            o.Size = UDim2.fromScale(1, 2)
            o.ImageTransparency = w.ClickGuiStatus and 0.9 or 1
            o.Parent = r
            I(r)
            I(o)
            Q = Instance.new("Frame")
            Q.Name = "NotifyList"
            Q.Size = UDim2.fromScale(0.2, 1)
            Q.Position = UDim2.fromScale(1, 0)
            Q.AnchorPoint = Vector2.new(1, 0)
            Q.BackgroundTransparency = 1
            Q.Visible = true
            Q.Parent = i
            local m = Instance.new("UIListLayout")
            m.FillDirection = Enum.FillDirection.Vertical
            m.VerticalAlignment = Enum.VerticalAlignment.Bottom
            m.HorizontalAlignment = Enum.HorizontalAlignment.Center
            m.SortOrder = Enum.SortOrder.LayoutOrder
            m.Padding = UDim.new(0.01, 0)
            m.Parent = Q
            local m = Instance.new("UIPadding")
            m.PaddingBottom = UDim.new(0.05, 0)
            m.PaddingTop = UDim.new(0.05, 0)
            m.Parent = Q
            local m = Instance.new("UIAspectRatioConstraint")
            m.AspectRatio = 10
            m.Parent = V
            local m = Instance.new("UIListLayout")
            m.FillDirection = Enum.FillDirection.Horizontal
            m.VerticalAlignment = Enum.VerticalAlignment.Top
            m.HorizontalAlignment = Enum.HorizontalAlignment.Center
            m.SortOrder = Enum.SortOrder.LayoutOrder
            m.Padding = UDim.new(0.016, 0)
            m.Parent = V

                                                                       
                                                                 
                                                                       
            local Dock = Instance.new("Frame")
            Dock.Name = "DockBar"
            Dock.AnchorPoint = Vector2.new(0.5, 1)
            Dock.Position = UDim2.new(0.5, 0, 0.94, 0)
            Dock.Size = UDim2.fromOffset(184, 44)
            Dock.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
            Dock.BackgroundTransparency = 0.15
            Dock.BorderSizePixel = 0
            Dock.ZIndex = 120
            Dock.Visible = true
            Dock.Parent = i
            w.DockBar = Dock
            O(Dock, UDim.new(1, 0))

            local DockStroke = Instance.new("UIStroke")
            DockStroke.Color = Color3.fromRGB(55, 55, 65)
            DockStroke.Thickness = 1
            DockStroke.Transparency = 0.35
            DockStroke.Parent = Dock

            local DockScale = Instance.new("UIScale")
            DockScale.Scale = w.ClickGuiStatus and 1 or 0
            DockScale.Parent = Dock
            w.DockScale = DockScale

                                                    
            local FeaturesBtn = Instance.new("TextButton")
            FeaturesBtn.Name = "FeaturesBtn"
            FeaturesBtn.Text = ""
            FeaturesBtn.Size = UDim2.fromOffset(40, 36)
            FeaturesBtn.Position = UDim2.new(0.235, 0, 0.44, 0)
            FeaturesBtn.AnchorPoint = Vector2.new(0.5, 0.5)
            FeaturesBtn.BackgroundTransparency = 1
            FeaturesBtn.AutoButtonColor = false
            FeaturesBtn.ZIndex = 125
            FeaturesBtn.Parent = Dock

            local FeaturesIcon = Instance.new("ImageLabel")
            FeaturesIcon.Name = "Icon"
            FeaturesIcon.Image = "rbxassetid://10709791437"                    
            FeaturesIcon.Size = UDim2.fromOffset(20, 20)
            FeaturesIcon.Position = UDim2.fromScale(0.5, 0.5)
            FeaturesIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            FeaturesIcon.BackgroundTransparency = 1
            FeaturesIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            FeaturesIcon.ZIndex = 126
            FeaturesIcon.Parent = FeaturesBtn

                                                                 
            local SettingsBtn = Instance.new("TextButton")
            SettingsBtn.Name = "SettingsBtn"
            SettingsBtn.Text = ""
            SettingsBtn.Size = UDim2.fromOffset(40, 36)
            SettingsBtn.Position = UDim2.new(0.765, 0, 0.44, 0)
            SettingsBtn.AnchorPoint = Vector2.new(0.5, 0.5)
            SettingsBtn.BackgroundTransparency = 1
            SettingsBtn.AutoButtonColor = false
            SettingsBtn.ZIndex = 125
            SettingsBtn.Parent = Dock

            local SettingsIcon = Instance.new("ImageLabel")
            SettingsIcon.Name = "Icon"
            SettingsIcon.Image = "rbxassetid://10734950309"                
            SettingsIcon.Size = UDim2.fromOffset(20, 20)
            SettingsIcon.Position = UDim2.fromScale(0.5, 0.5)
            SettingsIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            SettingsIcon.BackgroundTransparency = 1
            SettingsIcon.ImageColor3 = Color3.fromRGB(130, 130, 140)
            SettingsIcon.ZIndex = 126
            SettingsIcon.Parent = SettingsBtn

            local SkinsBtn = Instance.new("TextButton")
            SkinsBtn.Name = "SkinsBtn"
            SkinsBtn.Text = ""
            SkinsBtn.Size = UDim2.fromOffset(40, 36)
            SkinsBtn.Position = UDim2.new(0.5, 0, 0.44, 0)
            SkinsBtn.AnchorPoint = Vector2.new(0.5, 0.5)
            SkinsBtn.BackgroundTransparency = 1
            SkinsBtn.AutoButtonColor = false
            SkinsBtn.ZIndex = 125
            SkinsBtn.Parent = Dock

            local SkinsIcon = Instance.new("TextLabel")
            SkinsIcon.Name = "Icon"
            SkinsIcon.Text = "\u{25C8}"
            SkinsIcon.BackgroundTransparency = 1
            SkinsIcon.Size = UDim2.fromOffset(22, 22)
            SkinsIcon.Position = UDim2.fromScale(0.5, 0.5)
            SkinsIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            SkinsIcon.TextColor3 = Color3.fromRGB(130, 130, 140)
            SkinsIcon.TextSize = 17
            SkinsIcon.FontFace = e.Font
            SkinsIcon.ZIndex = 126
            SkinsIcon.Parent = SkinsBtn

            local SkinsLabel = Instance.new("TextLabel")
            SkinsLabel.Name = "Tag"
            SkinsLabel.Text = "SKINS"
            SkinsLabel.BackgroundTransparency = 1
            SkinsLabel.Size = UDim2.fromOffset(60, 12)
            SkinsLabel.Position = UDim2.fromOffset(0, -30)
            SkinsLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
            SkinsLabel.TextSize = 9
            SkinsLabel.FontFace = e.Font
            SkinsLabel.TextXAlignment = Enum.TextXAlignment.Center
            SkinsLabel.ZIndex = 126
            SkinsLabel.Parent = SkinsBtn

                                                                                 
            local ActiveDot = Instance.new("Frame")
            ActiveDot.Name = "ActiveDot"
            ActiveDot.Size = UDim2.fromOffset(4, 4)
            ActiveDot.Position = UDim2.new(0.3, 0, 1, -7)
            ActiveDot.AnchorPoint = Vector2.new(0.5, 0.5)
            ActiveDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ActiveDot.BorderSizePixel = 0
            ActiveDot.ZIndex = 128
            O(ActiveDot, UDim.new(1, 0))
            ActiveDot.Parent = Dock

                                                                       
                                                                       
                                                                
                                                                       
            local SettingsWin = Instance.new("Frame")
            SettingsWin.Name = "SettingsWindow"
            SettingsWin.AnchorPoint = Vector2.new(0.5, 0.5)
            SettingsWin.Position = UDim2.fromScale(0.5, 0.44)
            SettingsWin.Size = UDim2.fromOffset(580, 390)
            SettingsWin.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
            SettingsWin.BackgroundTransparency = 0.04
            SettingsWin.BorderSizePixel = 0
            SettingsWin.ZIndex = 90
            SettingsWin.Visible = false
            SettingsWin.Parent = i
            w.SettingsWindow = SettingsWin
            O(SettingsWin, UDim.new(0, 12))

            local SetWinStroke = Instance.new("UIStroke")
            SetWinStroke.Color = Color3.fromRGB(50, 52, 65)
            SetWinStroke.Thickness = 1.5
            SetWinStroke.Parent = SettingsWin

            local SetWinScale = Instance.new("UIScale")
            SetWinScale.Scale = 0
            SetWinScale.Parent = SettingsWin
            w.SettingsScale = SetWinScale

            local SkinsWin = Instance.new("Frame")
            SkinsWin.Name = "SkinsWindow"
            SkinsWin.AnchorPoint = Vector2.new(0.5, 0.5)
            SkinsWin.Position = UDim2.fromScale(0.5, 0.44)
            SkinsWin.Size = UDim2.fromOffset(700, 440)
            SkinsWin.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
            SkinsWin.BackgroundTransparency = 0.04
            SkinsWin.BorderSizePixel = 0
            SkinsWin.ZIndex = 90
            SkinsWin.Visible = false
            SkinsWin.Parent = i
            w.SkinsWindow = SkinsWin
            O(SkinsWin, UDim.new(0, 12))

            local SkinsWinStroke = Instance.new("UIStroke")
            SkinsWinStroke.Color = Color3.fromRGB(50, 52, 65)
            SkinsWinStroke.Thickness = 1.5
            SkinsWinStroke.Parent = SkinsWin

            local SkinsWinScale = Instance.new("UIScale")
            SkinsWinScale.Scale = 0
            SkinsWinScale.Parent = SkinsWin
            w.SkinsScale = SkinsWinScale
            w.SkinsTabButton = SkinsBtn

                         
            local SetHeader = Instance.new("Frame")
            SetHeader.Name = "Header"
            SetHeader.Size = UDim2.new(1, 0, 0, 42)
            SetHeader.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
            SetHeader.BorderSizePixel = 0
            SetHeader.ZIndex = 91
            SetHeader.Parent = SettingsWin
            O(SetHeader, UDim.new(0, 12))

            local SetTitle = Instance.new("TextLabel")
            SetTitle.Text = "SETTINGS & CONFIGURATIONS"
            SetTitle.Size = UDim2.new(1, -20, 1, 0)
            SetTitle.Position = UDim2.new(0, 14, 0, 0)
            SetTitle.BackgroundTransparency = 1
            SetTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SetTitle.TextXAlignment = Enum.TextXAlignment.Left
            SetTitle.TextSize = 13
            SetTitle.FontFace = e.Font
            SetTitle.ZIndex = 92
            SetTitle.Parent = SetHeader

                           
            local ContentArea = Instance.new("Frame")
            ContentArea.Name = "ContentArea"
            ContentArea.Size = UDim2.new(1, -24, 1, -54)
            ContentArea.Position = UDim2.new(0, 12, 0, 46)
            ContentArea.BackgroundTransparency = 1
            ContentArea.ZIndex = 91
            ContentArea.Parent = SettingsWin

            local SplitLayout = Instance.new("UIListLayout")
            SplitLayout.FillDirection = Enum.FillDirection.Horizontal
            SplitLayout.Padding = UDim.new(0, 12)
            SplitLayout.Parent = ContentArea

                                                                      
            local function setupNeutralButton(btn, stroke)
                btn.MouseEnter:Connect(function()
                    d:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(34, 36, 46) }):Play()
                    if stroke then
                        d:Create(stroke, TweenInfo.new(0.12), { Color = Color3.fromRGB(70, 75, 95) }):Play()
                    end
                end)
                btn.MouseLeave:Connect(function()
                    d:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(24, 25, 32) }):Play()
                    if stroke then
                        d:Create(stroke, TweenInfo.new(0.12), { Color = Color3.fromRGB(44, 46, 58) }):Play()
                    end
                end)
            end

                                                                       
                                        
                                                                       
            local CardConfigs = Instance.new("Frame")
            CardConfigs.Name = "CardConfigs"
            CardConfigs.Size = UDim2.new(0.485, 0, 1, 0)
            CardConfigs.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
            CardConfigs.BorderSizePixel = 0
            CardConfigs.ZIndex = 93
            CardConfigs.Parent = ContentArea
            O(CardConfigs, UDim.new(0, 8))
            local CfgStroke = Instance.new("UIStroke")
            CfgStroke.Color = Color3.fromRGB(36, 38, 48)
            CfgStroke.Thickness = 1
            CfgStroke.Parent = CardConfigs

            local CfgList = Instance.new("UIListLayout")
            CfgList.FillDirection = Enum.FillDirection.Vertical
            CfgList.SortOrder = Enum.SortOrder.LayoutOrder
            CfgList.Padding = UDim.new(0, 8)
            CfgList.Parent = CardConfigs

            local CfgPad = Instance.new("UIPadding")
            CfgPad.PaddingTop = UDim.new(0, 10)
            CfgPad.PaddingBottom = UDim.new(0, 10)
            CfgPad.PaddingLeft = UDim.new(0, 10)
            CfgPad.PaddingRight = UDim.new(0, 10)
            CfgPad.Parent = CardConfigs

                                                                
            local CfgHeader = Instance.new("Frame")
            CfgHeader.Name = "Header"
            CfgHeader.Size = UDim2.new(1, 0, 0, 20)
            CfgHeader.BackgroundTransparency = 1
            CfgHeader.LayoutOrder = 1
            CfgHeader.ZIndex = 94
            CfgHeader.Parent = CardConfigs

            local CfgTitle = Instance.new("TextLabel")
            CfgTitle.Text = "CONFIG MANAGER"
            CfgTitle.Size = UDim2.new(1, 0, 1, 0)
            CfgTitle.BackgroundTransparency = 1
            CfgTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
            CfgTitle.TextXAlignment = Enum.TextXAlignment.Left
            CfgTitle.TextSize = 11
            CfgTitle.FontFace = e.Font
            CfgTitle.ZIndex = 94
            CfgTitle.Parent = CfgHeader

                                                          
            local AutoloadBar = Instance.new("Frame")
            AutoloadBar.Name = "AutoloadBar"
            AutoloadBar.Size = UDim2.new(1, 0, 0, 30)
            AutoloadBar.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
            AutoloadBar.BorderSizePixel = 0
            AutoloadBar.LayoutOrder = 2
            AutoloadBar.ZIndex = 94
            AutoloadBar.Parent = CardConfigs
            O(AutoloadBar, UDim.new(0, 6))
            local AutoStroke = Instance.new("UIStroke")
            AutoStroke.Color = Color3.fromRGB(36, 38, 48)
            AutoStroke.Thickness = 1
            AutoStroke.Parent = AutoloadBar

            local AutoLabel = Instance.new("TextLabel")
            AutoLabel.Name = "AutoLabel"
            AutoLabel.Size = UDim2.new(1, -96, 1, 0)
            AutoLabel.Position = UDim2.new(0, 8, 0, 0)
            AutoLabel.BackgroundTransparency = 1
            AutoLabel.Text = "Autoload: None"
            AutoLabel.TextColor3 = Color3.fromRGB(180, 185, 195)
            AutoLabel.TextSize = 11
            AutoLabel.FontFace = e.Font
            AutoLabel.TextXAlignment = Enum.TextXAlignment.Left
            AutoLabel.ZIndex = 95
            AutoLabel.Parent = AutoloadBar

            local SetAutoBtn = Instance.new("TextButton")
            SetAutoBtn.Name = "SetAutoBtn"
            SetAutoBtn.Text = "Set Autoload"
            SetAutoBtn.Size = UDim2.new(0, 84, 1, -6)
            SetAutoBtn.Position = UDim2.new(1, -87, 0, 3)
            SetAutoBtn.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
            SetAutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            SetAutoBtn.TextSize = 11
            SetAutoBtn.FontFace = e.Font
            SetAutoBtn.AutoButtonColor = false
            SetAutoBtn.ZIndex = 95
            SetAutoBtn.Parent = AutoloadBar
            O(SetAutoBtn, UDim.new(0, 5))
            local SetAutoStroke = Instance.new("UIStroke")
            SetAutoStroke.Color = Color3.fromRGB(44, 46, 58)
            SetAutoStroke.Thickness = 1
            SetAutoStroke.Parent = SetAutoBtn
            setupNeutralButton(SetAutoBtn, SetAutoStroke)

                                    
            local CfgInput = Instance.new("TextBox")
            CfgInput.Name = "ConfigNameInput"
            CfgInput.Size = UDim2.new(1, 0, 0, 30)
            CfgInput.BackgroundColor3 = Color3.fromRGB(12, 13, 17)
            CfgInput.BorderSizePixel = 0
            CfgInput.Text = tostring(w.Place)
            CfgInput.PlaceholderText = "Config name..."
            CfgInput.TextColor3 = Color3.fromRGB(255, 255, 255)
            CfgInput.PlaceholderColor3 = Color3.fromRGB(110, 115, 130)
            CfgInput.TextSize = 11
            CfgInput.FontFace = e.Font
            CfgInput.TextXAlignment = Enum.TextXAlignment.Left
            CfgInput.LayoutOrder = 3
            CfgInput.ZIndex = 94
            CfgInput.Parent = CardConfigs
            O(CfgInput, UDim.new(0, 6))
            local InpStroke = Instance.new("UIStroke")
            InpStroke.Color = Color3.fromRGB(36, 38, 48)
            InpStroke.Thickness = 1
            InpStroke.Parent = CfgInput
            local InpPad = Instance.new("UIPadding")
            InpPad.PaddingLeft = UDim.new(0, 8)
            InpPad.PaddingRight = UDim.new(0, 8)
            InpPad.Parent = CfgInput

                                                                            
            local ConfigScroll = Instance.new("ScrollingFrame")
            ConfigScroll.Name = "ConfigScroll"
            ConfigScroll.Size = UDim2.new(1, 0, 0, 110)
            ConfigScroll.BackgroundColor3 = Color3.fromRGB(12, 13, 17)
            ConfigScroll.BorderSizePixel = 0
            ConfigScroll.ScrollBarThickness = 3
            ConfigScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 75, 95)
            ConfigScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            ConfigScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ConfigScroll.LayoutOrder = 4
            ConfigScroll.ZIndex = 94
            ConfigScroll.Parent = CardConfigs
            O(ConfigScroll, UDim.new(0, 6))
            local ScrollStroke = Instance.new("UIStroke")
            ScrollStroke.Color = Color3.fromRGB(36, 38, 48)
            ScrollStroke.Thickness = 1
            ScrollStroke.Parent = ConfigScroll

            local ScrollList = Instance.new("UIListLayout")
            ScrollList.FillDirection = Enum.FillDirection.Vertical
            ScrollList.Padding = UDim.new(0, 4)
            ScrollList.Parent = ConfigScroll
            local ScrollPad = Instance.new("UIPadding")
            ScrollPad.PaddingTop = UDim.new(0, 6)
            ScrollPad.PaddingBottom = UDim.new(0, 6)
            ScrollPad.PaddingLeft = UDim.new(0, 6)
            ScrollPad.PaddingRight = UDim.new(0, 6)
            ScrollPad.Parent = ConfigScroll

            local function GetAutoloadName()
                if isfile and isfile("AkiraLite/autoload.txt") and readfile then
                    local ok, val = pcall(readfile, "AkiraLite/autoload.txt")
                    if ok and val and #val > 0 then
                        return val:gsub("^%s+", ""):gsub("%s+$", "")
                    end
                end
                return nil
            end

            local function RefreshConfigList()
                for _, ch in ipairs(ConfigScroll:GetChildren()) do
                    if ch:IsA("TextButton") then ch:Destroy() end
                end
                local autoCfg = GetAutoloadName()
                if autoCfg and #autoCfg > 0 then
                    AutoLabel.Text = "Autoload: " .. autoCfg
                else
                    AutoLabel.Text = "Autoload: None"
                end
                local cfgs = (w.GetConfigs and w:GetConfigs()) or {}
                for _, name in ipairs(cfgs) do
                    local isAuto = (name == autoCfg)
                    local itemBtn = Instance.new("TextButton")
                    itemBtn.Name = "CfgItem_" .. name
                    itemBtn.Size = UDim2.new(1, 0, 0, 26)
                    itemBtn.BackgroundColor3 = isAuto and Color3.fromRGB(28, 30, 40) or Color3.fromRGB(18, 19, 25)
                    itemBtn.BorderSizePixel = 0
                    itemBtn.Text = isAuto and ("[AUTOLOAD]  " .. name) or ("  " .. name)
                    itemBtn.TextColor3 = isAuto and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 205, 215)
                    itemBtn.TextSize = 11
                    itemBtn.FontFace = e.Font
                    itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                    itemBtn.AutoButtonColor = false
                    itemBtn.ZIndex = 95
                    itemBtn.Parent = ConfigScroll
                    O(itemBtn, UDim.new(0, 4))
                    local itmStroke = Instance.new("UIStroke")
                    itmStroke.Color = isAuto and Color3.fromRGB(55, 60, 78) or Color3.fromRGB(30, 32, 42)
                    itmStroke.Thickness = 1
                    itmStroke.Parent = itemBtn
                    setupNeutralButton(itemBtn, itmStroke)
                    itemBtn.MouseButton1Click:Connect(function()
                        CfgInput.Text = name
                    end)
                end
            end

                                                                                 
            local BtnRow1 = Instance.new("Frame")
            BtnRow1.Name = "BtnRow1"
            BtnRow1.Size = UDim2.new(1, 0, 0, 30)
            BtnRow1.BackgroundTransparency = 1
            BtnRow1.LayoutOrder = 5
            BtnRow1.ZIndex = 94
            BtnRow1.Parent = CardConfigs

            local LoadBtn = Instance.new("TextButton")
            LoadBtn.Name = "LoadBtn"
            LoadBtn.Size = UDim2.new(0.485, 0, 1, 0)
            LoadBtn.Position = UDim2.new(0, 0, 0, 0)
            LoadBtn.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
            LoadBtn.BorderSizePixel = 0
            LoadBtn.Text = "Load Config"
            LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            LoadBtn.TextSize = 11
            LoadBtn.FontFace = e.Font
            LoadBtn.AutoButtonColor = false
            LoadBtn.ZIndex = 95
            LoadBtn.Parent = BtnRow1
            O(LoadBtn, UDim.new(0, 6))
            local LoadStroke = Instance.new("UIStroke")
            LoadStroke.Color = Color3.fromRGB(44, 46, 58)
            LoadStroke.Thickness = 1
            LoadStroke.Parent = LoadBtn
            setupNeutralButton(LoadBtn, LoadStroke)

            local SaveBtn = Instance.new("TextButton")
            SaveBtn.Name = "SaveBtn"
            SaveBtn.Size = UDim2.new(0.485, 0, 1, 0)
            SaveBtn.Position = UDim2.new(0.515, 0, 0, 0)
            SaveBtn.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
            SaveBtn.BorderSizePixel = 0
            SaveBtn.Text = "Save Config"
            SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            SaveBtn.TextSize = 11
            SaveBtn.FontFace = e.Font
            SaveBtn.AutoButtonColor = false
            SaveBtn.ZIndex = 95
            SaveBtn.Parent = BtnRow1
            O(SaveBtn, UDim.new(0, 6))
            local SaveStroke = Instance.new("UIStroke")
            SaveStroke.Color = Color3.fromRGB(44, 46, 58)
            SaveStroke.Thickness = 1
            SaveStroke.Parent = SaveBtn
            setupNeutralButton(SaveBtn, SaveStroke)

                                                                                      
            local BtnRow2 = Instance.new("Frame")
            BtnRow2.Name = "BtnRow2"
            BtnRow2.Size = UDim2.new(1, 0, 0, 30)
            BtnRow2.BackgroundTransparency = 1
            BtnRow2.LayoutOrder = 6
            BtnRow2.ZIndex = 94
            BtnRow2.Parent = CardConfigs

            local OverwriteBtn = Instance.new("TextButton")
            OverwriteBtn.Name = "OverwriteBtn"
            OverwriteBtn.Size = UDim2.new(0.485, 0, 1, 0)
            OverwriteBtn.Position = UDim2.new(0, 0, 0, 0)
            OverwriteBtn.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
            OverwriteBtn.BorderSizePixel = 0
            OverwriteBtn.Text = "Overwrite"
            OverwriteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            OverwriteBtn.TextSize = 11
            OverwriteBtn.FontFace = e.Font
            OverwriteBtn.AutoButtonColor = false
            OverwriteBtn.ZIndex = 95
            OverwriteBtn.Parent = BtnRow2
            O(OverwriteBtn, UDim.new(0, 6))
            local OverwriteStroke = Instance.new("UIStroke")
            OverwriteStroke.Color = Color3.fromRGB(44, 46, 58)
            OverwriteStroke.Thickness = 1
            OverwriteStroke.Parent = OverwriteBtn
            setupNeutralButton(OverwriteBtn, OverwriteStroke)

            local DeleteBtn = Instance.new("TextButton")
            DeleteBtn.Name = "DeleteBtn"
            DeleteBtn.Size = UDim2.new(0.485, 0, 1, 0)
            DeleteBtn.Position = UDim2.new(0.515, 0, 0, 0)
            DeleteBtn.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
            DeleteBtn.BorderSizePixel = 0
            DeleteBtn.Text = "Delete"
            DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            DeleteBtn.TextSize = 11
            DeleteBtn.FontFace = e.Font
            DeleteBtn.AutoButtonColor = false
            DeleteBtn.ZIndex = 95
            DeleteBtn.Parent = BtnRow2
            O(DeleteBtn, UDim.new(0, 6))
            local DeleteStroke = Instance.new("UIStroke")
            DeleteStroke.Color = Color3.fromRGB(44, 46, 58)
            DeleteStroke.Thickness = 1
            DeleteStroke.Parent = DeleteBtn
            setupNeutralButton(DeleteBtn, DeleteStroke)

                                     
            SaveBtn.MouseButton1Click:Connect(function()
                local name = CfgInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
                if #name > 0 then
                    w:SaveConfig(name)
                    RefreshConfigList()
                end
            end)

            LoadBtn.MouseButton1Click:Connect(function()
                local name = CfgInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
                if #name > 0 then
                    w:LoadConfig(name)
                end
            end)

            OverwriteBtn.MouseButton1Click:Connect(function()
                local name = CfgInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
                if #name > 0 then
                    w:SaveConfig(name)
                    RefreshConfigList()
                end
            end)

            DeleteBtn.MouseButton1Click:Connect(function()
                local name = CfgInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
                if #name > 0 then
                    if delfile and isfile and isfile("AkiraLite/Config/" .. name .. ".json") then
                        pcall(delfile, "AkiraLite/Config/" .. name .. ".json")
                    end
                    local autoCfg = GetAutoloadName()
                    if autoCfg == name and delfile and isfile and isfile("AkiraLite/autoload.txt") then
                        pcall(delfile, "AkiraLite/autoload.txt")
                    end
                    RefreshConfigList()
                end
            end)

            SetAutoBtn.MouseButton1Click:Connect(function()
                local name = CfgInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
                if #name > 0 then
                    w:SetAutoload(name)
                    RefreshConfigList()
                end
            end)

            task.spawn(RefreshConfigList)

                                                                       
                                               
                                                                       
            local CardInterface = Instance.new("Frame")
            CardInterface.Name = "CardInterface"
            CardInterface.Size = UDim2.new(0.485, 0, 1, 0)
            CardInterface.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
            CardInterface.BorderSizePixel = 0
            CardInterface.ZIndex = 93
            CardInterface.Parent = ContentArea
            O(CardInterface, UDim.new(0, 8))
            local IntStroke = Instance.new("UIStroke")
            IntStroke.Color = Color3.fromRGB(36, 38, 48)
            IntStroke.Thickness = 1
            IntStroke.Parent = CardInterface

            local IntList = Instance.new("UIListLayout")
            IntList.FillDirection = Enum.FillDirection.Vertical
            IntList.SortOrder = Enum.SortOrder.LayoutOrder
            IntList.Padding = UDim.new(0, 8)
            IntList.Parent = CardInterface

            local IntPad = Instance.new("UIPadding")
            IntPad.PaddingTop = UDim.new(0, 10)
            IntPad.PaddingBottom = UDim.new(0, 10)
            IntPad.PaddingLeft = UDim.new(0, 10)
            IntPad.PaddingRight = UDim.new(0, 10)
            IntPad.Parent = CardInterface

                                                                
            local IntHeader = Instance.new("Frame")
            IntHeader.Name = "Header"
            IntHeader.Size = UDim2.new(1, 0, 0, 20)
            IntHeader.BackgroundTransparency = 1
            IntHeader.LayoutOrder = 1
            IntHeader.ZIndex = 94
            IntHeader.Parent = CardInterface

            local IntTitle = Instance.new("TextLabel")
            IntTitle.Text = "INTERFACE & SETTINGS"
            IntTitle.Size = UDim2.new(1, 0, 1, 0)
            IntTitle.BackgroundTransparency = 1
            IntTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
            IntTitle.TextXAlignment = Enum.TextXAlignment.Left
            IntTitle.TextSize = 11
            IntTitle.FontFace = e.Font
            IntTitle.ZIndex = 94
            IntTitle.Parent = IntHeader

                           
            local ThemeRow = Instance.new("Frame")
            ThemeRow.Name = "ThemeRow"
            ThemeRow.Size = UDim2.new(1, 0, 0, 30)
            ThemeRow.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
            ThemeRow.BorderSizePixel = 0
            ThemeRow.LayoutOrder = 2
            ThemeRow.ZIndex = 94
            ThemeRow.Parent = CardInterface
            O(ThemeRow, UDim.new(0, 6))
            local ThemeStroke = Instance.new("UIStroke")
            ThemeStroke.Color = Color3.fromRGB(36, 38, 48)
            ThemeStroke.Thickness = 1
            ThemeStroke.Parent = ThemeRow

            local ThemeLabel = Instance.new("TextLabel")
            ThemeLabel.Text = "Theme Palette"
            ThemeLabel.Size = UDim2.new(0.44, 0, 1, 0)
            ThemeLabel.Position = UDim2.new(0, 8, 0, 0)
            ThemeLabel.BackgroundTransparency = 1
            ThemeLabel.TextColor3 = Color3.fromRGB(200, 205, 215)
            ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
            ThemeLabel.TextSize = 11
            ThemeLabel.FontFace = e.Font
            ThemeLabel.ZIndex = 95
            ThemeLabel.Parent = ThemeRow

            local ThemeValBtn = Instance.new("TextButton")
            ThemeValBtn.Text = "Monochrome"
            ThemeValBtn.Size = UDim2.new(0.5, 0, 1, -6)
            ThemeValBtn.Position = UDim2.new(0.48, 0, 0, 3)
            ThemeValBtn.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
            ThemeValBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ThemeValBtn.TextSize = 11
            ThemeValBtn.FontFace = e.Font
            ThemeValBtn.AutoButtonColor = false
            ThemeValBtn.ZIndex = 95
            ThemeValBtn.Parent = ThemeRow
            O(ThemeValBtn, UDim.new(0, 5))
            local TS = Instance.new("UIStroke")
            TS.Color = Color3.fromRGB(44, 46, 58)
            TS.Thickness = 1
            TS.Parent = ThemeValBtn
            setupNeutralButton(ThemeValBtn, TS)

            local function ApplyTheme(thName)
                if ThemesMap[thName] then
                    e.MainColor = ThemesMap[thName][1]
                    e.SecondaryColor = ThemesMap[thName][2]
                    e.ThirdColor = ThemesMap[thName][3]
                    ThemeValBtn.Text = thName
                end
            end

            ThemeValBtn.MouseButton1Click:Connect(function()
                local curIdx = table.find(themeListNames, ThemeValBtn.Text) or 1
                curIdx = curIdx % #themeListNames + 1
                local nextTheme = themeListNames[curIdx]
                ApplyTheme(nextTheme)
            end)

                                    
            local ModeRow = Instance.new("Frame")
            ModeRow.Name = "ModeRow"
            ModeRow.Size = UDim2.new(1, 0, 0, 30)
            ModeRow.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
            ModeRow.BorderSizePixel = 0
            ModeRow.LayoutOrder = 3
            ModeRow.ZIndex = 94
            ModeRow.Parent = CardInterface
            O(ModeRow, UDim.new(0, 6))
            local ModeStroke = Instance.new("UIStroke")
            ModeStroke.Color = Color3.fromRGB(36, 38, 48)
            ModeStroke.Thickness = 1
            ModeStroke.Parent = ModeRow

            local ModeLabel = Instance.new("TextLabel")
            ModeLabel.Text = "Gradient Style"
            ModeLabel.Size = UDim2.new(0.44, 0, 1, 0)
            ModeLabel.Position = UDim2.new(0, 8, 0, 0)
            ModeLabel.BackgroundTransparency = 1
            ModeLabel.TextColor3 = Color3.fromRGB(200, 205, 215)
            ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
            ModeLabel.TextSize = 11
            ModeLabel.FontFace = e.Font
            ModeLabel.ZIndex = 95
            ModeLabel.Parent = ModeRow

            local ModeValBtn = Instance.new("TextButton")
            ModeValBtn.Text = B.Value or "Fade"
            ModeValBtn.Size = UDim2.new(0.5, 0, 1, -6)
            ModeValBtn.Position = UDim2.new(0.48, 0, 0, 3)
            ModeValBtn.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
            ModeValBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ModeValBtn.TextSize = 11
            ModeValBtn.FontFace = e.Font
            ModeValBtn.AutoButtonColor = false
            ModeValBtn.ZIndex = 95
            ModeValBtn.Parent = ModeRow
            O(ModeValBtn, UDim.new(0, 5))
            local MS = Instance.new("UIStroke")
            MS.Color = Color3.fromRGB(44, 46, 58)
            MS.Thickness = 1
            MS.Parent = ModeValBtn
            setupNeutralButton(ModeValBtn, MS)

            local modeList = {"Fade", "Breathe", "Static"}
            ModeValBtn.MouseButton1Click:Connect(function()
                local cIdx = table.find(modeList, ModeValBtn.Text) or 1
                cIdx = cIdx % #modeList + 1
                ModeValBtn.Text = modeList[cIdx]
                B.Value = modeList[cIdx]
            end)

                                  
            local ScaleRow = Instance.new("Frame")
            ScaleRow.Name = "ScaleRow"
            ScaleRow.Size = UDim2.new(1, 0, 0, 36)
            ScaleRow.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
            ScaleRow.BorderSizePixel = 0
            ScaleRow.LayoutOrder = 4
            ScaleRow.ZIndex = 94
            ScaleRow.Parent = CardInterface
            O(ScaleRow, UDim.new(0, 6))
            local ScStroke = Instance.new("UIStroke")
            ScStroke.Color = Color3.fromRGB(36, 38, 48)
            ScStroke.Thickness = 1
            ScStroke.Parent = ScaleRow

            local ScaleLabel = Instance.new("TextLabel")
            ScaleLabel.Text = "GUI Scale"
            ScaleLabel.Size = UDim2.new(0.5, 0, 0, 18)
            ScaleLabel.Position = UDim2.new(0, 8, 0, 3)
            ScaleLabel.BackgroundTransparency = 1
            ScaleLabel.TextColor3 = Color3.fromRGB(200, 205, 215)
            ScaleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ScaleLabel.TextSize = 11
            ScaleLabel.FontFace = e.Font
            ScaleLabel.ZIndex = 95
            ScaleLabel.Parent = ScaleRow

            local ScaleValLabel = Instance.new("TextLabel")
            ScaleValLabel.Text = string.format("%.1fx", w.Scale.Value)
            ScaleValLabel.Size = UDim2.new(0.45, 0, 0, 18)
            ScaleValLabel.Position = UDim2.new(0.52, 0, 0, 3)
            ScaleValLabel.BackgroundTransparency = 1
            ScaleValLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ScaleValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ScaleValLabel.TextSize = 11
            ScaleValLabel.FontFace = e.Font
            ScaleValLabel.ZIndex = 95
            ScaleValLabel.Parent = ScaleRow

            local ScaleTrack = Instance.new("TextButton")
            ScaleTrack.Text = ""
            ScaleTrack.AutoButtonColor = false
            ScaleTrack.Size = UDim2.new(1, -16, 0, 6)
            ScaleTrack.Position = UDim2.new(0, 8, 0, 23)
            ScaleTrack.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
            ScaleTrack.BorderSizePixel = 0
            ScaleTrack.ZIndex = 95
            ScaleTrack.Parent = ScaleRow
            O(ScaleTrack, UDim.new(0, 3))

            local ScaleFill = Instance.new("Frame")
            local initPct = math.clamp((w.Scale.Value - 0.5) / 1.0, 0, 1)
            ScaleFill.Size = UDim2.new(initPct, 0, 1, 0)
            ScaleFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ScaleFill.BorderSizePixel = 0
            ScaleFill.ZIndex = 96
            ScaleFill.Parent = ScaleTrack
            O(ScaleFill, UDim.new(0, 3))

            local isDraggingScale = false
            local function updateScaleFromInput(xPos)
                local absPos = ScaleTrack.AbsolutePosition.X
                local absSize = ScaleTrack.AbsoluteSize.X
                local pct = math.clamp((xPos - absPos) / absSize, 0, 1)
                ScaleFill.Size = UDim2.new(pct, 0, 1, 0)
                local scaleVal = math.floor((0.5 + pct * 1.0) * 10 + 0.5) / 10
                ScaleValLabel.Text = string.format("%.1fx", scaleVal)
                w.Scale.Value = scaleVal
            end

            ScaleTrack.MouseButton1Down:Connect(function()
                isDraggingScale = true
                local mousePos = P:GetMouseLocation().X
                updateScaleFromInput(mousePos)
                local moveConn, upConn
                moveConn = P.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement and isDraggingScale then
                        updateScaleFromInput(inp.Position.X)
                    end
                end)
                upConn = P.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDraggingScale = false
                        if moveConn then moveConn:Disconnect() end
                        if upConn then upConn:Disconnect() end
                    end
                end)
            end)

                                  
            local KeyRow = Instance.new("Frame")
            KeyRow.Name = "KeyRow"
            KeyRow.Size = UDim2.new(1, 0, 0, 30)
            KeyRow.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
            KeyRow.BorderSizePixel = 0
            KeyRow.LayoutOrder = 5
            KeyRow.ZIndex = 94
            KeyRow.Parent = CardInterface
            O(KeyRow, UDim.new(0, 6))
            local KeyStroke = Instance.new("UIStroke")
            KeyStroke.Color = Color3.fromRGB(36, 38, 48)
            KeyStroke.Thickness = 1
            KeyStroke.Parent = KeyRow

            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Text = "Menu Keybind"
            KeyLabel.Size = UDim2.new(0.44, 0, 1, 0)
            KeyLabel.Position = UDim2.new(0, 8, 0, 0)
            KeyLabel.BackgroundTransparency = 1
            KeyLabel.TextColor3 = Color3.fromRGB(200, 205, 215)
            KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeyLabel.TextSize = 11
            KeyLabel.FontFace = e.Font
            KeyLabel.ZIndex = 95
            KeyLabel.Parent = KeyRow

            local KeyBtn = Instance.new("TextButton")
            local function formatKeyNames(tbl)
                local names = {}
                for _, k in ipairs(tbl) do
                    table.insert(names, k.Name)
                end
                return table.concat(names, ", ")
            end
            KeyBtn.Text = formatKeyNames(w.Keybind)
            KeyBtn.Size = UDim2.new(0.5, 0, 1, -6)
            KeyBtn.Position = UDim2.new(0.48, 0, 0, 3)
            KeyBtn.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
            KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            KeyBtn.TextSize = 11
            KeyBtn.FontFace = e.Font
            KeyBtn.AutoButtonColor = false
            KeyBtn.ZIndex = 95
            KeyBtn.Parent = KeyRow
            O(KeyBtn, UDim.new(0, 5))
            local KS = Instance.new("UIStroke")
            KS.Color = Color3.fromRGB(44, 46, 58)
            KS.Thickness = 1
            KS.Parent = KeyBtn
            setupNeutralButton(KeyBtn, KS)

            local listeningKey = false
            KeyBtn.MouseButton1Click:Connect(function()
                if listeningKey then return end
                listeningKey = true
                KeyBtn.Text = "Press key..."
                local keyConn
                keyConn = P.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        w.Keybind = { input.KeyCode }
                        KeyBtn.Text = input.KeyCode.Name
                        listeningKey = false
                        if keyConn then keyConn:Disconnect() end
                    end
                end)
            end)

                                                                                             
            local UninjectBtn = Instance.new("TextButton")
            UninjectBtn.Name = "UninjectBtn"
            UninjectBtn.Size = UDim2.new(1, 0, 0, 32)
            UninjectBtn.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
            UninjectBtn.BorderSizePixel = 0
            UninjectBtn.Text = "Unload & Uninject"
            UninjectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            UninjectBtn.TextSize = 11
            UninjectBtn.FontFace = e.Font
            UninjectBtn.AutoButtonColor = false
            UninjectBtn.LayoutOrder = 6
            UninjectBtn.ZIndex = 94
            UninjectBtn.Parent = CardInterface
            O(UninjectBtn, UDim.new(0, 6))
            local UninjectStroke = Instance.new("UIStroke")
            UninjectStroke.Color = Color3.fromRGB(44, 46, 58)
            UninjectStroke.Thickness = 1
            UninjectStroke.Parent = UninjectBtn
            setupNeutralButton(UninjectBtn, UninjectStroke)

            UninjectBtn.MouseButton1Click:Connect(function()
                w:Uninject()
            end)

            w.ActiveTab = "Features"
            local TAB_DOT = {Features = 0.235, Skins = 0.5, Settings = 0.765}
            local function SwitchTab(tabName)
                w.ActiveTab = tabName
                d:Create(ActiveDot, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                    Position = UDim2.new(TAB_DOT[tabName] or 0.235, 0, 1, -7)
                }):Play()
                local dim = Color3.fromRGB(130, 130, 140)
                local lit = Color3.fromRGB(255, 255, 255)
                d:Create(FeaturesIcon, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
                    ImageColor3 = tabName == "Features" and lit or dim
                }):Play()
                if SkinsIcon:IsA("ImageLabel") then
                    d:Create(SkinsIcon, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
                        ImageColor3 = tabName == "Skins" and lit or dim
                    }):Play()
                else
                    d:Create(SkinsIcon, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
                        TextColor3 = tabName == "Skins" and lit or dim
                    }):Play()
                end
                d:Create(SettingsIcon, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
                    ImageColor3 = tabName == "Settings" and lit or dim
                }):Play()
                if w.ClickGuiStatus then
                    local wantFeatures = (tabName == "Features")
                    local wantSkins = (tabName == "Skins")
                    SettingsWin.Visible = not wantFeatures and not wantSkins
                    SkinsWin.Visible = wantSkins
                    V.Visible = wantFeatures
                    d:Create(V.UIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
                        Scale = wantFeatures and w.Scale.Value or 0
                    }):Play()
                    d:Create(SetWinScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
                        Scale = SettingsWin.Visible and w.Scale.Value or 0
                    }):Play()
                    d:Create(SkinsWinScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
                        Scale = wantSkins and w.Scale.Value or 0
                    }):Play()
                end
            end
            w.SwitchTab = SwitchTab

            FeaturesBtn.MouseButton1Click:Connect(function()
                SwitchTab("Features")
            end)
            SkinsBtn.MouseButton1Click:Connect(function()
                SwitchTab("Skins")
            end)
            SettingsBtn.MouseButton1Click:Connect(function()
                SwitchTab("Settings")
            end)

            self.AddCatalog = function(m, m)
                local i = {
                    Name = m["Name"] or "",
                    Frame = Instance.new("CanvasGroup"),
                    AddModule = function()
                    end,
                    Modules = {}
                }
                local J = i.Frame
                J.Name = m["Name"] .. "_Catalog"
                J.Size = UDim2.fromScale(0.14, 4)
                J.BackgroundTransparency = 1
                J.Parent = V
                local g = Instance.new("Frame")
                g.Size = UDim2.fromScale(1, 0.07)
                g.ClipsDescendants = true
                g.BackgroundTransparency = 1
                g.Parent = J
                local y = Instance.new("TextButton")
                y.Name = "CatalogName"
                y.AutoButtonColor = false
                y.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
                y.BorderSizePixel = 0
                y.Size = UDim2.fromScale(1, 2)
                y.FontFace = e.Font
                y.TextScaled = true
                y.Text = i.Name
                y.Parent = g
                y.TextColor3 = Color3.fromRGB(255, 255, 255)
                table.insert(F, O(y, UDim.new(0, 25)).Parent)
                local g = Instance.new("UIPadding")
                g.PaddingBottom = UDim.new(0.63, 0)
                g.PaddingTop = UDim.new(0.1, 0)
                g.Parent = y
                local g = Instance.new("CanvasGroup")
                g.Name = "List"
                g.Size = UDim2.fromScale(1, 0.5)
                g.Position = UDim2.new(0, 0, 0, 0)
                g.BackgroundTransparency = 1
                g.Parent = J
                table.insert(F, O(g, UDim.new(0, 25)).Parent)
                local N = Instance.new("ScrollingFrame")
                N.Position = UDim2.new(0, 0, 0, y.AbsoluteSize.Y / 2)
                N.Size = UDim2.fromScale(1, 0.94)
                N.BackgroundTransparency = 1
                N.ScrollBarThickness = 0
                N.ScrollingDirection = Enum.ScrollingDirection.Y
                N.AutomaticCanvasSize = Enum.AutomaticSize.Y
                N.ScrollBarImageTransparency = 1
                N.Parent = g
    w:Clean(x(j.PreRender, 0.05, function()
        if w.ClickGuiStatus then
                                                                            
                                                                              
                                                                       
            local target = UDim2.new(0, 0, 0, y.AbsoluteSize.Y / 2)
            if N.Position ~= target then
                d:Create(N, TweenInfo.new(0.05, Enum.EasingStyle.Exponential), {
                    Position = target
                }):Play()
                N.Position = target
            end
        end
    end))
                local t = Instance.new("Frame", w.MainScreenGui)
                t.Position = UDim2.fromScale(- 1.0, - 1.0)
                t.BackgroundTransparency = 1
                t.ZIndex = - 10.0
                k(t).ImageColor3 = Color3.fromRGB(0, 0, 0)
                k(t).ImageColor3 = Color3.fromRGB(0, 0, 0)
                k(t).ImageColor3 = Color3.fromRGB(0, 0, 0)
                table.insert(u, t)
                local R
    w:Clean(x(j.PreRender, 0.05, function()
        if w.ClickGuiStatus then
            local x = 0
            for q, q in next, N:GetChildren() do
                if q:IsA("Frame") or q:IsA("CanvasGroup") and q.Visible then
                    x += q.AbsoluteSize.Y
                end
            end
            if x ~= R then
                            R = x
                            local padBottom = 16
                            local screenH = (w.MainScreenGui.AbsoluteSize.Y > 0 and w.MainScreenGui.AbsoluteSize.Y) or 1080
                            local maxVisibleHeight = math.max(250, screenH * 0.76 - 40)
                            local totalNeeded = x + y.AbsoluteSize.Y / 2 + padBottom
                            local finalHeight = math.min(totalNeeded, maxVisibleHeight)
                            g.Size = UDim2.new(1, 0, 0, finalHeight)
                            N.Size = UDim2.new(1, 0, 1, - (y.AbsoluteSize.Y / 2))
                            N.CanvasSize = UDim2.new(0, 0, 0, x + padBottom + 8)
                            N.ScrollBarThickness = (totalNeeded > maxVisibleHeight) and 2 or 0
                            N.ScrollBarImageColor3 = Color3.fromRGB(80, 85, 105)
                            N.ScrollBarImageTransparency = 0.3
                            t.Size = UDim2.new(0, N.AbsoluteSize.X, 0, finalHeight)
                            t.Position = UDim2.new(0, N.AbsolutePosition.X + 1, 0, y.AbsolutePosition.Y + y.AbsoluteSize.Y / 2)
                        end
                    end
                end))
                local x = Instance.new("UIListLayout")
                x.FillDirection = Enum.FillDirection.Vertical
                x.SortOrder = Enum.SortOrder.LayoutOrder
                x.Parent = N
                local x = Instance.new("ImageLabel")
                x.Size = UDim2.fromScale(1, 1)
                x.Image = "rbxassetid://107200271119058"
                x.ImageTransparency = 0.4
                x.Rotation = 180
                x.BackgroundTransparency = 1
                x.ImageColor3 = Color3.fromRGB(30, 30, 30)
                local t = 0
                i.AddModule = function(R, R)
                    local q = {
                        Name = R["Name"],
                        Frame = Instance.new("TextButton"),
                        Children = Instance.new("Frame"),
                        Expanded = R["Expanded"] or false,
                        Enabled = R["Enabled"] or R["Default"] or false,
                        ExtraText = R["ExtraText"] or function()
                            return ""
                        end,
                        Bind = {},
                        Settings = {}
                    }
                    n(q)
                    t += 1
                    if w.Modules[R["Name"]] then
                        w.Modules[R["Name"]]:Delete()
                    end
                    local n = Instance.new("Frame")
                    local U = q.Frame
                    n.Size = UDim2.new(1, 0, 0, y.AbsoluteSize.Y * 0.36)
                    n.BorderSizePixel = 0
                    n.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                    n.Parent = N
                    w:Clean(y:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                        if w.ClickGuiStatus then
                            n.Size = UDim2.new(1, 0, 0, y.AbsoluteSize.Y * 0.36)
                            U.TextSize = y.AbsoluteSize.Y * 0.24
                            local h = 0
                            for G, G in next, N:GetChildren() do
                                if (G:IsA("Frame") or G:IsA("CanvasGroup")) and G.Visible then
                                    h += G.AbsoluteSize.Y
                                end
                            end
                            local padBottom = 16
                            g.Size = h >= J.AbsoluteSize.Y and UDim2.new(1, 0, 0, J.AbsoluteSize.Y) or UDim2.new(1, 0, 0, h + y.AbsoluteSize.Y / 2 + padBottom)
                            N.CanvasSize = UDim2.new(0, 0, 0, h + padBottom)
                        end
                    end))
                    U.Size = UDim2.fromScale(1, 1)
                    U.BorderSizePixel = 0
                    U.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
                    U.BackgroundTransparency = 0
                    U.AutoButtonColor = false
                    U.Text = q.Name
                    U.TextSize = y.AbsoluteSize.Y * 0.24
                    U.TextScaled = false
                    U.FontFace = e.Font
                    U.TextColor3 = q.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(227, 227, 227)
                    n.LayoutOrder = - ((l(U.Text, 10, Enum.Font.BuilderSansMedium).X + 10) * 100 - t)
                    U.Parent = n
                    I(n)
                    local J = 1 / 0
                    local g
                    for h, h in next, N:GetChildren() do
                        if h:IsA("Frame") and h.LayoutOrder < J then
                            J = h.LayoutOrder
                            g = h
                        end
                    end
                    x.Parent = g
                    q.Function = R["Function"] or function()
                    end
                    if q.Enabled then
                        d:Create(U, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                            BackgroundTransparency = 1
                        }):Play()
                        U.TextColor3 = q.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(227, 227, 227)
                        task.spawn(q.Function, q.Enabled)
                    end
                    function q:Toggle(J)
                        pcall(function()
                            q.Enabled = not q.Enabled
                            d:Create(U, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                                BackgroundTransparency = q.Enabled and 1 or 0
                            }):Play()
                            U.TextColor3 = q.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(227, 227, 227)
                            if not q.Enabled then
                                for J, J in q.Connections do
                                    J:Disconnect()
                                end
                                table.clear(q.Connections)
                            end
                            w:UpdateArrayList()
                            task.spawn(q.Function, q.Enabled)
                        end)
                    end
                    U.MouseButton1Click:Connect(q.Toggle)
                    U.MouseButton1Click:Connect(function()
                        local J = _:Clone()
                        J.Volume = 0.6
                        J.Parent = w.MainScreenGui
                        J:Play()
                    end)
                    local J = Instance.new("UIPadding")
                    J.PaddingBottom = UDim.new(0.13, 0)
                    J.PaddingTop = UDim.new(0.13, 0)
                    J.Parent = U
                    local J = q.Children
                    J.Name = "Children"
                    J.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
                    J.BorderSizePixel = 0
                    J.LayoutOrder = - ((l(U.Text, 10, Enum.Font.BuilderSansMedium).X + 10) * 100 - t - 1)
                    J.ClipsDescendants = true
                    J.Parent = N
                    local g = Instance.new("UIListLayout")
                    g.FillDirection = Enum.FillDirection.Vertical
                    g.SortOrder = Enum.SortOrder.LayoutOrder
                    g.Padding = UDim.new(0, y.AbsoluteSize.Y * 0.04)
                    g.Parent = J
                    local N = Instance.new("UIPadding")
                    N.PaddingTop = UDim.new(0, y.AbsoluteSize.Y * 0.05)
                    N.Parent = J
                    function q:Delete()
                        local t = q.Enabled
                        q.Enabled = false
                        for h, h in q.Connections do
                            h:Disconnect()
                        end
                        table.clear(q.Connections)
                        if t then
                            task.spawn(q.Function, false)
                        end
                        x.Parent = Y
                        J:ClearAllChildren()
                        n:ClearAllChildren()
                        J:Destroy()
                        n:Destroy()
                        q = nil
                    end
                    function q.getChilrenSize()
                        local x = y.AbsoluteSize.Y * 0.05
                        for Y, Y in next, J:GetChildren() do
                            if Y:IsA("Frame") and Y.Visible then
                                x += Y.AbsoluteSize.Y + y.AbsoluteSize.Y * 0.05
                            end
                        end
                        if x == y.AbsoluteSize.Y * 0.05 then
                            return 0
                        end
                        return x
                    end
                    if q.Expanded then
                        q:Expand()
                    end
                    function q:Expand()
                        pcall(function()
                            q.Expanded = not q.Expanded
                            d:Create(J, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
                                Size = q.Expanded and UDim2.new(1, 0, 0, q.getChilrenSize()) or UDim2.new(1, 0, 0, 0)
                            }):Play()
                            for x, x in next, J:GetDescendants() do
                                if x:IsA("Frame") and x.Name == "Slider_Fill" then
                                    if q.Expanded then
                                        x.Size = UDim2.fromScale(0, 1)
                                        d:Create(x, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {
                                            Size = UDim2.fromScale(x:GetAttribute("Value"), 1)
                                        }):Play()
                                    end
                                end
                            end
                        end)
                    end
                    U.MouseButton2Click:Connect(q.Expand)
                    U.MouseButton2Click:Connect(function()
                        if q.getChilrenSize() ~= 0 then
                            local x = _:Clone()
                            x.Volume = 0.7
                            x.Parent = w.MainScreenGui
                            x:Play()
                        end
                    end)
                    w:Clean(g:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        if w.ClickGuiStatus then
                            if V.UIScale.Scale == w.Scale.Value or V.UIScale.Scale == 0 then
                                d:Create(J, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
                                    Size = q.Expanded and UDim2.new(1, 0, 0, q.getChilrenSize()) or UDim2.new(1, 0, 0, 0)
                                }):Play()
                            end
                            g.Padding = UDim.new(0, y.AbsoluteSize.Y * 0.05)
                            N.PaddingTop = UDim.new(0, y.AbsoluteSize.Y * 0.05)
                        end
                    end))
                    function q:SetBind(x)
                        q.Bind = x
                    end
                    q.AddToggle = function(x, Y)
                        local n = {
                            Name = Y["Name"] or "",
                            Frame = Instance.new("Frame"),
                            Enabled = Y["Enabled"] or Y["Default"] or false,
                            Function = Y["Function"] or Y["function"] or function()
                            end
                        }
                        local g = n.Frame
                        g.Size = UDim2.new(1, 0, 0, U.AbsoluteSize.Y * 0.8)
                        g.BackgroundTransparency = 1
                        if Y["Visible"] == false then
                            g.Visible = false
                        end
                        g.Parent = J
                        w:Clean(U:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                            if w.ClickGuiStatus then
                                g.Size = UDim2.new(1, 0, 0, U.AbsoluteSize.Y * 0.8)
                            end
                        end))
                        local y = Instance.new("TextLabel")
                        y.Name = "Alias"
                        y.Text = Y["Text"] or n.Name
                        y.BackgroundTransparency = 1
                        y.Size = UDim2.fromScale(1, 1)
                        y.TextColor3 = Color3.fromRGB(255, 255, 255)
                        y.TextScaled = true
                        y.TextXAlignment = Enum.TextXAlignment.Left
                        y.FontFace = e.Font
                        y.Parent = g
                        local Y = Instance.new("UIPadding")
                        Y.PaddingBottom = UDim.new(0.1, 0)
                        Y.PaddingLeft = UDim.new(0.05, 0)
                        Y.PaddingRight = UDim.new(0.3, 0)
                        Y.PaddingTop = UDim.new(0.1, 0)
                        Y.Parent = y
                        local Y = Instance.new("TextButton")
                        Y.Name = "Button"
                        Y.Text = ""
                        Y.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
                        Y.Position = UDim2.fromScale(0.93, 0.5)
                        Y.BorderSizePixel = 0
                        Y.AnchorPoint = Vector2.new(0.9, 0.5)
                        Y.SizeConstraint = Enum.SizeConstraint.RelativeYY
                        Y.AutoButtonColor = false
                        Y.Size = UDim2.fromScale(1.75, 0.8)
                        Y.Parent = g
                        O(Y, UDim.new(999, 0))
                        local g = I(Y)
                        g.Enabled = n.Enabled
                        local y = Instance.new("TextButton")
                        y.Name = "Button"
                        y.Text = ""
                        y.Interactable = false
                        y.BackgroundTransparency = 0
                        y.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
                        y.Position = UDim2.fromScale(0.25, 0.5)
                        y.BorderSizePixel = 0
                        y.AnchorPoint = Vector2.new(0.5, 0.5)
                        y.SizeConstraint = Enum.SizeConstraint.RelativeYY
                        y.Size = UDim2.fromScale(0.7, 0.7)
                        y.Parent = Y
                        O(y, UDim.new(999, 0))
                        local N = Instance.new("ImageLabel")
                        N.BackgroundTransparency = 1
                        N.Position = UDim2.fromScale(0.5, 0.5)
                        N.Size = n.Enabled and UDim2.fromScale(3, 3) or UDim2.fromScale(0, 0)
                        N.Parent = y
                        N.AnchorPoint = Vector2.new(0.5, 0.5)
                        N.Image = "rbxassetid://77031034070194"
                        if n.Enabled then
                            d:Create(y, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
                                Position = n.Enabled and UDim2.fromScale(0.75, 0.5) or UDim2.fromScale(0.25, 0.5)
                            }):Play()
                            d:Create(N, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                                Size = n.Enabled and UDim2.fromScale(3, 3) or UDim2.fromScale(0, 0)
                            }):Play()
                            Y.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        end
                        function n:Toggle(t)
                            n.Enabled = t or not n.Enabled
                            d:Create(y, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
                                Position = n.Enabled and UDim2.fromScale(0.75, 0.5) or UDim2.fromScale(0.25, 0.5)
                            }):Play()
                            d:Create(N, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                                Size = n.Enabled and UDim2.fromScale(3, 3) or UDim2.fromScale(0, 0)
                            }):Play()
                            g.Enabled = n.Enabled
                            Y.BackgroundColor3 = n.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(32, 32, 38)
                            n.Function(n.Enabled)
                        end
                        Y.MouseButton1Click:Connect(n.Toggle)
                        Y.MouseButton1Click:Connect(function()
                            local Y = _:Clone()
                            Y.Volume = 0.6
                            Y.Parent = w.MainScreenGui
                            Y:Play()
                        end)
                        function n:Save(Y)
                            Y[n.Name] = {
                                Enabled = n.Enabled
                            }
                        end
                        function n:Load(Y)
                            if Y and n.Enabled ~= Y.Enabled then
                                n:Toggle(Y.Enabled)
                            end
                        end
                        x.Settings[n.Name] = n
                        return n
                    end
                    q.AddSlider = function(x, Y)
                        local n = {
                            Name = Y["Name"] or "",
                            Frame = Instance.new("Frame"),
                            Max = Y["Max"] or Y["max"] or 100,
                            Min = Y["Min"] or Y["min"] or 1,
                            Value = Y["default"] or Y["Default"] or Y["Value"] or (Y["Min"] or Y["min"] or 1),
                            Decimal = (tonumber(Y["Decimal"] or Y["decimal"]) or 1) < 1 and 1 or (tonumber(Y["Decimal"] or Y["decimal"]) or 1),
                            Suffix = Y["Suffix"],
                            Function = Y["Function"] or Y["function"] or function()
                            end,
                            Visible = Y["Visible"] or true
                        }
                        local g = n.Frame
                        g.Size = UDim2.new(1, 0, 0, U.AbsoluteSize.Y * 1.2)
                        g.BackgroundTransparency = 1
                        if Y["Visible"] == false then
                            g.Visible = false
                        end
                        g.Parent = J
                        w:Clean(U:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                            if w.ClickGuiStatus then
                                g.Size = UDim2.new(1, 0, 0, U.AbsoluteSize.Y * 1.2)
                            end
                        end))
                        local y = Instance.new("TextLabel")
                        y.Name = "Alias"
                        y.Text = Y["Text"] or n.Name
                        y.BackgroundTransparency = 1
                        y.Size = UDim2.fromScale(1, 0.66)
                        y.TextColor3 = Color3.fromRGB(255, 255, 255)
                        y.TextScaled = true
                        y.TextXAlignment = Enum.TextXAlignment.Left
                        y.FontFace = e.Font
                        y.Parent = g
                        local Y = Instance.new("UIPadding")
                        Y.PaddingBottom = UDim.new(0.1, 0)
                        Y.PaddingLeft = UDim.new(0.05, 0)
                        Y.PaddingRight = UDim.new(0.4, 0)
                        Y.PaddingTop = UDim.new(0.1, 0)
                        Y.Parent = y
                        local Y = Instance.new("TextLabel")
                        Y.Name = "Select"
                        Y.Text = n.Value .. (n.Suffix and " " .. (type(n.Suffix) == "function" and n.Suffix(n.Value) or n.Suffix) or "")
                        Y.BackgroundTransparency = 1
                        Y.Size = UDim2.fromScale(1, 0.66)
                        Y.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Y.TextScaled = true
                        Y.TextXAlignment = Enum.TextXAlignment.Right
                        Y.FontFace = e.Font
                        Y.Parent = g
                        local y = Instance.new("UIPadding")
                        y.PaddingBottom = UDim.new(0.1, 0)
                        y.PaddingLeft = UDim.new(0.4, 0)
                        y.PaddingRight = UDim.new(0.05, 0)
                        y.PaddingTop = UDim.new(0.1, 0)
                        y.Parent = Y
                        local y = Instance.new("Frame")
                        y.Name = "Slider"
                        y.AnchorPoint = Vector2.new(0, 0.5)
                        y.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        y.BackgroundTransparency = 1
                        y.Position = UDim2.fromScale(0, 0.75)
                        y.Size = UDim2.fromScale(1, 0.08)
                        y.Parent = g
                        local g = Instance.new("UIPadding")
                        g.PaddingLeft = UDim.new(0.07, 0)
                        g.PaddingRight = UDim.new(0.07, 0)
                        g.Parent = y
                        local g = Instance.new("Frame")
                        g.Name = "Line"
                        g.AnchorPoint = Vector2.new(0.5, 0.5)
                        g.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
                        g.BackgroundTransparency = 0
                        g.Position = UDim2.fromScale(0.5, 0.5)
                        g.Size = UDim2.fromScale(1, 1)
                        g.Parent = y
                        local N = Instance.new("Frame")
                        N.Name = "Slider_Fill"
                        N.AnchorPoint = Vector2.new(0, 0.5)
                        N.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        N.BackgroundTransparency = 0
                        N.Position = UDim2.fromScale(0, 0.5)
                        N.Size = UDim2.fromScale(n.Value / n.Max, 1)
                        N.BorderSizePixel = 0
                        N.Parent = g
                        N:SetAttribute("Value", n.Value / n.Max)
                        I(N)
                        local t = Instance.new("Frame")
                        t.Name = "BALL"
                        t.AnchorPoint = Vector2.new(0.5, 0.5)
                        t.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        t.BackgroundTransparency = 0
                        t.Position = UDim2.fromScale(1, 0.5)
                        t.Size = UDim2.fromScale(3, 3.05)
                        t.SizeConstraint = Enum.SizeConstraint.RelativeYY
                        t.BorderSizePixel = 0
                        t.Parent = N
                        O(t, UDim.new(10, 0))
                        I(t)
                        local h = Instance.new("ImageLabel")
                        h.BackgroundTransparency = 1
                        h.Position = UDim2.fromScale(0.5, 0.5)
                        h.Size = UDim2.fromScale(3, 3)
                        h.AnchorPoint = Vector2.new(0.5, 0.5)
                        h.Image = "rbxassetid://77031034070194"
                        h.Parent = t
                        I(h)
                        local t = Instance.new("TextButton")
                        t.Name = "Input"
                        t.Text = ""
                        t.AnchorPoint = Vector2.new(0.5, 0.5)
                        t.AutoButtonColor = false
                        t.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        t.BackgroundTransparency = 1
                        t.Position = UDim2.fromScale(0.5, 0.5)
                        t.Size = UDim2.fromScale(1, 7)
                        t.Parent = y
                        local function y(h, G, b, E)
                            local a = n.Value ~= G
                            if not E then
                                d:Create(N, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {
                                    Size = UDim2.fromScale(h, 1)
                                }):Play()
                            end
                            if G ~= G then G = n.Min end
                            n.Value = G
                            Y.Text = n.Value .. (n.Suffix and " " .. (type(n.Suffix) == "function" and n.Suffix(n.Value) or n.Suffix) or "")
                            N:SetAttribute("Value", h)
                            if a or b then
                                n.Function(G, b)
                            end
                        end
                        t.InputBegan:Connect(function(Y)
                            if (Y.UserInputType == Enum.UserInputType.MouseButton1 or Y.UserInputType == Enum.UserInputType.Touch) then
                                local trackW = g.AbsoluteSize.X
                                if trackW <= 0 then return end
                                local N = math.clamp((Y.Position.X - g.AbsolutePosition.X) / trackW, 0, 1)
                                if N ~= N then N = 0 end
                                local t = math.floor((n.Min + (n.Max - n.Min) * N) * n.Decimal) / n.Decimal
                                if t ~= t then t = n.Min end
                                y(N, t)
                                local h = N
                                local N = t
                                local t = P.InputChanged:Connect(function(G)
                                    if G.UserInputType == (Y.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                                        local trackW = g.AbsoluteSize.X
                                        if trackW <= 0 then return end
                                        local b = math.clamp((G.Position.X - g.AbsolutePosition.X) / trackW, 0, 1)
                                        if b ~= b then b = 0 end
                                        local g = math.floor((n.Min + (n.Max - n.Min) * b) * n.Decimal) / n.Decimal
                                        if g ~= g then g = n.Min end
                                        y(b, g)
                                        if N ~= g then
                                            local G = _:Clone()
                                            G.Volume = 0.2
                                            G.Parent = w.MainScreenGui
                                            G:Play()
                                        end
                                        N = g
                                        h = b
                                    end
                                end)
                                local g
                                g = Y.Changed:Connect(function()
                                    if Y.UserInputState == Enum.UserInputState.End then
                                        if t then
                                            t:Disconnect()
                                        end
                                        if g then
                                            g:Disconnect()
                                        end
                                        y(h, N, true)
                                    end
                                end)
                            end
                        end)
                        function n:Save(Y)
                            Y[n.Name] = {
                                Max = n.Max,
                                Min = n.Min,
                                Value = n.Value
                            }
                        end
                        function n:Load(Y)
                            if Y and Y.Max and n.Min and Y.Max == n.Max and Y.Min == n.Min and Y.Value then
                                local g = math.clamp((Y.Value - Y.Min) / (Y.Max - Y.Min), 0, 1)
                                n.Value = Y.Value
                                y(g, Y.Value, true, true)
                            end
                        end
                        x.Settings[n.Name] = n
                        return n
                    end
                    q.AddDropdown = function(x, x)
                        local list = x["List"] or {}
                        local Y = {
                            Name = x["Name"] or x["Text"] or "",
                            Frame = Instance.new("Frame"),
                            Value = x["Default"] or (list[1]) or "None",
                            Function = x["Function"] or x["function"] or function()
                            end
                        }
                        local n = Y.Frame
                        n.Size = UDim2.new(1, 0, 0, U.AbsoluteSize.Y * 0.8)
                        n.BackgroundTransparency = 1
                        n.Parent = J
                        w:Clean(U:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                            if w.ClickGuiStatus then
                                n.Size = UDim2.new(1, 0, 0, U.AbsoluteSize.Y * 0.8)
                            end
                        end))
                        local AliasLabel = Instance.new("TextLabel")
                        AliasLabel.Name = "Alias"
                        AliasLabel.Text = Y.Name
                        AliasLabel.BackgroundTransparency = 1
                        AliasLabel.Size = UDim2.new(0.48, 0, 1, 0)
                        AliasLabel.Position = UDim2.new(0, 8, 0, 0)
                        AliasLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
                        AliasLabel.TextScaled = false
                        AliasLabel.TextSize = 11
                        AliasLabel.TextXAlignment = Enum.TextXAlignment.Left
                        AliasLabel.FontFace = e.Font
                        AliasLabel.Parent = n

                        local SelectBtn = Instance.new("TextButton")
                        SelectBtn.Name = "Select"
                        SelectBtn.Text = tostring(Y.Value)
                            SelectBtn.Size = UDim2.new(0.48, -6, 0.8, 0)
                        SelectBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
                        SelectBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
                        SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        SelectBtn.TextScaled = false
                        SelectBtn.TextSize = 10
                        SelectBtn.FontFace = e.Font
                        SelectBtn.AutoButtonColor = false
                        SelectBtn.ZIndex = 5
                        SelectBtn.Parent = n
                        O(SelectBtn, UDim.new(0, 4))
                        local DropStroke = Instance.new("UIStroke")
                        DropStroke.Color = Color3.fromRGB(55, 58, 72)
                        DropStroke.Thickness = 1
                        DropStroke.Parent = SelectBtn

                        local DropArrow = Instance.new("TextLabel")
                        DropArrow.Name = "Arrow"
                        DropArrow.Text = "\u{25BC}"
                        DropArrow.BackgroundTransparency = 1
                        DropArrow.Size = UDim2.fromOffset(12, 12)
                        DropArrow.Position = UDim2.new(1, -14, 0.5, -6)
                        DropArrow.TextColor3 = Color3.fromRGB(150, 154, 168)
                        DropArrow.TextSize = 8
                        DropArrow.FontFace = e.Font
                        DropArrow.TextXAlignment = Enum.TextXAlignment.Center
                        DropArrow.ZIndex = 6
                        DropArrow.Parent = SelectBtn

                        local dropBtnRef = SelectBtn
                        SelectBtn.MouseEnter:Connect(function()
                            d:Create(SelectBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(34, 36, 46) }):Play()
                            d:Create(DropStroke, TweenInfo.new(0.12), { Color = Color3.fromRGB(70, 75, 95) }):Play()
                        end)
                        SelectBtn.MouseLeave:Connect(function()
                            d:Create(SelectBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(24, 25, 32) }):Play()
                            d:Create(DropStroke, TweenInfo.new(0.12), { Color = Color3.fromRGB(44, 46, 58) }):Play()
                        end)
                        SelectBtn.MouseButton1Click:Connect(function()
                            if #list == 0 then return end
                            local idx = table.find(list, Y.Value) or 1
                            idx = idx % #list + 1
                            Y.Value = list[idx]
                            dropBtnRef.Text = tostring(list[idx])
                            local arrow = dropBtnRef:FindFirstChild("Arrow")
                            if arrow then
                                arrow.Rotation = 180
                                task.delay(0.12, function()
                                    if arrow.Parent then arrow.Rotation = 0 end
                                end)
                            end
                            local g = _:Clone()
                            g.Volume = 0.5
                            g.Parent = w.MainScreenGui
                            g:Play()
                            Y.Function(list[idx])
                        end)
                        function Y:Save(x)
                            x[Y.Name] = {
                                Value = Y.Value
                            }
                        end
                        function Y:Load(x)
                            if x and x.Value then
                                Y.Value = x.Value
                                dropBtnRef.Text = tostring(x.Value)
                                local arrow = dropBtnRef:FindFirstChild("Arrow")
                                if arrow then arrow.Rotation = 0 end
                            end
                        end
                        q.Settings[Y.Name] = Y
                        return Y
                    end
                    w.Modules[R["Name"]] = q
                    i.Modules[R["Name"]] = q
                    return q
                end
                i.RemoveModule = function(x, x)
                    if w.Modules[x["Name"]] then
                        w.Modules[x["Name"]]:Delete()
                    end
                end
                w.Catalogs[m["Name"]] = i
                return i
            end
        end
        w:CreateGUI()
        local m = 20
        local x = {}
        local Y, n, i = {}, {}, {}
        do
            function w:GetArrayListColor(i)
                local J = L(i)
                if e.ThirdColor then
                    if J <= 0.5 then
                        return e.MainColor:Lerp(e.SecondaryColor, J * 2)
                    end
                    return e.SecondaryColor:Lerp(e.ThirdColor, (J - 0.5) * 2)
                end
                return e.SecondaryColor:Lerp(e.MainColor, J)
            end
            local L = Instance.new("Frame")
            L.Size = UDim2.new(0, 0, 0, m)
            L.BackgroundTransparency = 1
            L.AnchorPoint = Vector2.new(1, 0)
            L.Position = UDim2.fromScale(0, 0)
            f(L)
            local f = Instance.new("TextLabel")
            f.Name = "TextLabel"
            f.Size = UDim2.fromScale(1, 1)
            f.TextColor3 = Color3.fromRGB(255, 255, 255)
            f.BorderSizePixel = 0
            f.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
            f.BackgroundTransparency = 0.3
            f.RichText = true
            f.FontFace = e.Font
            f.TextSize = L.AbsoluteSize.Y
            f.Parent = L
            local i = Instance.new("Frame")
            i.BackgroundTransparency = 1
            i.AnchorPoint = Vector2.new(1, 0.5)
            i.ClipsDescendants = true
            i.Position = UDim2.fromScale(1, 0)
            i.Parent = f
            local f = Instance.new("Frame")
            f.Size = UDim2.fromScale(0.6, 0.3)
            f.BackgroundTransparency = 0
            f.AnchorPoint = Vector2.new(0, 0.5)
            f.Position = UDim2.fromScale(- 0.3, 0.5)
            f.Parent = i
            local i = Instance.new("ImageLabel")
            i.BackgroundTransparency = 1
            i.AnchorPoint = Vector2.new(0, 0.5)
            i.Position = UDim2.fromScale(- 8.0, 0.5)
            i.ZIndex = - 10.0
            i.Size = UDim2.fromScale(10, 1.3)
            i.ImageTransparency = 0.6
            i.Image = "rbxassetid://93106615966363"
            i.Parent = f
            O(i, UDim.new(999, 0))
            O(f, UDim.new(999, 0))
            local f = {}
            function w:UpdateArrayList()
                local i, J = {}, {}
                for g, y in next, self.Modules do
                    if y.Enabled and not f[g] then
                        f[g] = g
                        table.insert(i, g)
                    elseif not y.Enabled and f[g] then
                        table.insert(J, g)
                        f[g] = nil
                    end
                end
                for f, f in p:GetChildren() do
                    if f:IsA("Frame") then
                        if table.find(J, f.Name) then
                            d:Create(f.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                                Scale = 0
                            }):Play()
                            task.delay(0.3, function()
                                f:Destroy()
                            end)
                        end
                    end
                end
                for f, f in next, i do
                    local i = L:Clone()
                    i.Parent = p
                    i.Name = f
                    local L = w:GetArrayListColor(i.AbsolutePosition)
                    i.TextLabel.Text = "<font color=\"rgb(" .. tostring(math.floor(L.R * 255)) .. "," .. tostring(math.floor(L.G * 255)) .. "," .. tostring(math.floor(L.B * 255)) .. ")\">" .. f .. "</font>"
                    local L = self.Modules[f]
                    if L and L.ExtraText then
                        local f = L.ExtraText()
                        i.TextLabel.Text ..= f ~= "" and " " .. f or f
                    end
                    i.Size = UDim2.new(0, 0, 0, m)
                    local L = UDim2.new(0, l(K(i.TextLabel.Text), i.TextLabel.TextSize, e.Font, Vector2.new(100000, 100000)).X + m / 2, 0, m)
                    i.Size = L
                    i.LayoutOrder = - l(K(i.TextLabel.Text), i.TextLabel.TextSize, e.Font, Vector2.new(100000, 100000)).X
                    if Y.Value then
                        i.TextLabel.BackgroundTransparency = 1 - Y.Value
                    end
                    i.TextLabel.Frame.Visible = n.Enabled or false
                    local L = Instance.new("UIScale")
                    L.Parent = i
                    L.Scale = 0
                    L.Parent = i
                    d:Create(L, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                        Scale = 1
                    }):Play()
                end
            end
            w:Clean(j.PreRender:Connect(function()
                                                                                  
                                                                                 
                                                                               
                                                                                 
                                                                                  
                                                                               
                  
                                                                                
                                                                              
                                                                                
                if x.Enabled and w.ClickGuiStatus then
                    for L, L in next, p:GetChildren() do
                        if L:IsA("Frame") then
                            local f = w:GetArrayListColor(L.AbsolutePosition)
                            local text = "<font color=\"rgb(" .. tostring(math.floor(f.R * 255)) .. "," .. tostring(math.floor(f.G * 255)) .. "," .. tostring(math.floor(f.B * 255)) .. ")\">" .. L.Name .. "</font>"
                            local module = w.Modules[L.Name]
                            if module and module.ExtraText then
                                local extra = module.ExtraText()
                                text ..= extra ~= "" and " " .. extra or extra
                            end
                            local key = text .. "|" .. tostring(m)
                            if L.__akiraTextKey ~= key then
                                L.__akiraTextKey = key
                                L.TextLabel.Text = text
                                                                                
                                                                             
                                L.Size = UDim2.new(0, l(K(text), m, e.Font, Vector2.new(100000, 100000)).X + m / 2, 0, m)
                            end
                            if ArrayListGlowEffect.Enabled then
                                L.Shadow.ImageColor3 = f
                                L.Shadow.Visible = true
                            else
                                L.Shadow.Visible = false
                            end
                            L.TextLabel.Frame.Frame.BackgroundColor3 = f
                            L.TextLabel.BackgroundTransparency = 1 - Y.Value
                            L.TextLabel.Frame.Frame.ImageLabel.ImageColor3 = f
                            L.TextLabel.TextSize = m
                        end
                    end
                end
            end))
        end
        local L
        local K = w.TargetHudFrame
        K.Size = UDim2.new(0, w.MainScreenGui.AbsoluteSize.Y / 6, 0, w.MainScreenGui.AbsoluteSize.Y / 14)
        K.BackgroundTransparency = 1
        K.Parent = w.MainScreenGui
        K.Visible = false
        local l = Instance.new("Frame")
        l.AnchorPoint = Vector2.new(0.5, 0.5)
        l.Position = UDim2.fromScale(0.5, 0.5)
        l.Size = UDim2.fromScale(1, 1)
        l.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
        l.BackgroundTransparency = 0.2
        l.BorderSizePixel = 0
        l.Parent = K
        local f = Instance.new("TextLabel")
        f.TextScaled = true
        f.BackgroundTransparency = 1
        f.Text = "None"
        f.TextColor3 = Color3.fromRGB(240, 240, 240)
        f.Size = UDim2.fromScale(1, 0.5)
        f.TextXAlignment = Enum.TextXAlignment.Left
        f.FontFace = e.Font
        f.Parent = l
        local i = Instance.new("UIPadding")
        i.PaddingBottom = UDim.new(0.15, 0)
        i.PaddingTop = UDim.new(0.4, 0)
        i.PaddingLeft = UDim.new(0.42, 0)
        i.PaddingRight = UDim.new(0.1, 0)
        i.Parent = f
        O(l, UDim.new(0, 26))
        C(l).ImageColor3 = Color3.fromRGB(0, 0, 0)
        local i = Instance.new("CanvasGroup")
        i.AnchorPoint = Vector2.new(0, 0.5)
        i.Position = UDim2.fromScale(0.42, 0.7)
        i.Size = UDim2.fromScale(0.46, 0.12)
        i.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
        i.BackgroundTransparency = 0.7
        i.BorderSizePixel = 0
        i.Parent = l
        O(i, UDim.new(99, 0))
        local J = Instance.new("TextLabel")
        J.Text = "0"
        J.TextXAlignment = Enum.TextXAlignment.Left
        J.AnchorPoint = Vector2.new(0, 0.5)
        J.Position = UDim2.fromScale(0.42, 0.5)
        J.Size = UDim2.fromScale(0.5, 0.2)
        J.TextScaled = true
        J.TextColor3 = Color3.fromRGB(240, 240, 240)
        J.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        J.BackgroundTransparency = 1
        J.BorderSizePixel = 0
        J.FontFace = e.Font
        J.Parent = l
        local g = Instance.new("Frame")
        g.AnchorPoint = Vector2.new(0, 0.5)
        g.Position = UDim2.fromScale(0, 0.5)
        g.Size = UDim2.fromScale(0, 1)
        g.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        g.BackgroundTransparency = 0.1
        g.BorderSizePixel = 0
        g.Parent = i
        local i = Instance.new("ImageLabel")
        i.AnchorPoint = Vector2.new(0.5, 0.5)
        i.Position = UDim2.fromScale(0.2, 0.5)
        i.BackgroundTransparency = 1
        i.SizeConstraint = Enum.SizeConstraint.RelativeYY
        i.Size = UDim2.fromScale(0.7, 0.7)
        i.Parent = l
        i.ImageColor3 = Color3.fromRGB(255, 255, 255)
        O(i, UDim.new(0, 26))
        C(i).ImageColor3 = Color3.fromRGB(0, 0, 0)
        s(K, w.MainScreenGui.ClickGui)
        local s = Instance.new("UIScale", l)
        s.Scale = w.ClickGuiStatus and w.Scale.Value or 0
        local C = Instance.new("UIScale", i)
        C.Scale = 1
        local y
        local N = 0
        local t = 0
        local R
        local q = {
            Targets = {},
            Object = l,
            UpdateInfo = function(U)
                local h = w.Libraries.entitylib
                if not h then
                    return
                end
                for G, b in U.Targets do
                    if b < tick() then
                        U.Targets[G] = nil
                    end
                end
                local G, b = nil, tick()
                for E, a in U.Targets do
                    if a > b then
                        G = E
                        b = a
                    end
                end
                local b
                if G ~= nil or w.ClickGuiStatus and s.Scale == 0 and not b then
                    b = d:Create(s, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
                        Scale = R.Value or 1
                    }):Play()
                elseif not w.ClickGuiStatus and not b then
                    b = d:Create(s, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
                        Scale = 0
                    }):Play()
                end
                if G then
                    f.Text = G.Player and (G.Player.Name) or G.Character and G.Character.Name or f.Text
                    if not G.Character then
                        G.Health = G.Health or 0
                        G.MaxHealth = G.MaxHealth or 100
                    end
                    J.Text = ("%2d HP"):format(G.Health)
                    if G.Health == math.huge then
                        J.Text = "Inf"
                    end
                    if h.character.Humanoid.Health == G.Health then
                        J.Text = J.Text .. " Drawing"
                    elseif h.character.Humanoid.Health < G.Health then
                        J.Text = J.Text .. " Losing"
                    elseif h.character.Humanoid.Health > G.Health then
                        J.Text = J.Text .. " Winning"
                    end
                    if G.Health ~= N then
                        local f = math.max(G.Health / G.MaxHealth, 0)
                        if G.Health == math.huge then
                            f = 1
                        end
                        d:Create(g, TweenInfo.new(0.3), {
                            Size = UDim2.fromScale(math.min(f, 1), 1),
                            BackgroundColor3 = Color3.fromHSV(math.clamp(f / 2.5, 0, 1), 0.89, 0.75)
                        }):Play()
                        if N > G.Health and U.LastTarget == G then
                            i.ImageColor3 = Color3.fromRGB(255, 0, 0)
                            C.Scale = 0.8
                            d:Create(i, TweenInfo.new(0.3), {
                                ImageColor3 = Color3.fromRGB(255, 255, 255)
                            }):Play()
                            i.Rotation = 20
                            d:Create(i, TweenInfo.new(0.3), {
                                Rotation = 0
                            }):Play()
                            d:Create(C, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {
                                Scale = 1
                            }):Play()
                            if y and y.Enabled then
                                local C = _:Clone()
                                C.Volume = 0.7
                                C.Parent = w.MainScreenGui
                                C:Play()
                            end
                        end
                        N = G.Health
                        t = G.MaxHealth
                    end
                    if not G.Character then
                        table.clear(G)
                    end
                    U.LastTarget = G
                end
                return G
            end
        }
        w.Libraries.Targetinfo = q
        function w:Notify(C)
            local f = {
                Text = C["Text"] or "None",
                Duration = C["Duration"] or C["Durn"] or 2,
                Frame = Instance.new("Frame"),
                Sound = C["Sound"],
                Status = false
            }
            local C = f.Frame
            C.Size = UDim2.fromScale(0.8, 0.05)
            C.BackgroundTransparency = 1
            C.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
            C.Parent = Q
            local _ = Instance.new("UIScale", C)
            _.Scale = 0
            local i = Instance.new("Frame")
            i.Name = "NotifyMain"
            i.Size = UDim2.fromScale(1, 1)
            i.Position = UDim2.fromScale(2, 0.2)
            i.BackgroundTransparency = 0.3
            i.BorderSizePixel = 0
            i.ZIndex = - 1.0
            i.ClipsDescendants = false
            i.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
            i.Parent = C
            O(i, UDim.new(999, 0))
            I(k(i))
            local k = Instance.new("TextButton")
            k.Size = UDim2.fromScale(1, 1)
            k.Text = f.Text
            k.FontFace = e.Font
            k.BorderSizePixel = 0
            k.BackgroundTransparency = 1
            k.ZIndex = 10
            k.TextScaled = true
            k.TextXAlignment = Enum.TextXAlignment.Left
            k.TextColor3 = Color3.fromRGB(255, 255, 255)
            k.Parent = i
            local J = Instance.new("UIPadding")
            J.PaddingBottom = UDim.new(0.25, 0)
            J.PaddingLeft = UDim.new(0.1, 0)
            J.PaddingRight = UDim.new(0.1, 0)
            J.PaddingTop = UDim.new(0.25, 0)
            J.Parent = k
            local J = Instance.new("Frame")
            J.Size = UDim2.fromScale(0, 1)
            J.BorderSizePixel = 0
            J.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
            J.BackgroundTransparency = 0
            J.Parent = i
            I(J)
            O(J, UDim.new(999, 0))
            d:Create(i, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
                Position = UDim2.fromScale(0, 0)
            }):Play()
            d:Create(_, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                Scale = 1
            }):Play()
            d:Create(J, TweenInfo.new(f.Duration, Enum.EasingStyle.Linear), {
                Size = UDim2.fromScale(1, 1)
            }):Play()
            function f:Delete()
                if f.Status then
                    return
                end
                f.Status = true
                d:Create(i, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
                    Position = UDim2.fromScale(2, 0.2)
                }):Play()
                wait(1)
                C:ClearAllChildren()
                C:Destroy()
            end
            k.MouseButton1Click:Connect(f.Delete)
            task.delay(f.Duration, f.Delete)
        end
        w:Clean(P.InputBegan:Connect(function(k)
            if not P:GetFocusedTextBox() and k.KeyCode ~= Enum.KeyCode.Unknown then
                if table.find(w.Keybind, k.KeyCode.Name) then
                    if w.ThreadFix then
                        setthreadidentity(8)
                    end
                    w.ClickGuiStatus = not w.ClickGuiStatus
                    w.MainScreenGui.Modal.Visible = w.ClickGuiStatus
                    d:Create(w.DockScale, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                        Scale = w.ClickGuiStatus and 1 or 0
                    }):Play()
                    if w.ActiveTab == "Settings" then
                        w.SettingsWindow.Visible = w.ClickGuiStatus
            if w.SkinsWindow then w.SkinsWindow.Visible = false end
                        V.Visible = false
                        d:Create(w.SettingsScale, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                            Scale = w.ClickGuiStatus and w.Scale.Value or 0
                        }):Play()
                    else
                        V.Visible = w.ClickGuiStatus
                        w.SettingsWindow.Visible = false
            if w.SkinsWindow then w.SkinsWindow.Visible = false end
                        d:Create(V.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                            Scale = w.ClickGuiStatus and w.Scale.Value or 0
                        }):Play()
                    end
                    d:Create(r, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
                        Transparency = w.ClickGuiStatus and z.Value or 1
                    }):Play()
                    d:Create(r, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
                        ImageTransparency = w.ClickGuiStatus and 0.76 or 1
                    }):Play()
                    d:Create(o, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
                        ImageTransparency = w.ClickGuiStatus and 0.9 or 1
                    }):Play()
                    d:Create(w.TargetHudFrame.Frame.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {
                        Scale = w.ClickGuiStatus and (R.Value or 1) or 0
                    }):Play()
                    for P, P in next, u do
                        P.Visible = false
                    end
                    task.delay(0.16, function()
                        w.ClickGuiLoaded = w.ClickGuiStatus
                        if c.Enabled then
                            for P, P in next, u do
                                P.Visible = w.ClickGuiStatus
                            end
                        end
                    end)
                    return
                end
                for P, P in w.Modules do
                    if k.KeyCode.Name == P.Bind.Name then
                        P:Toggle()
                        w:Notify({
                            Text = P.Name .. " has been " .. (P.Enabled and "Enabled" or "Disabled"),
                            Duration = 1.5
                        })
                    end
                end
            end
        end))
        local P = {}
        function w:SaveOptions(k, C)
            local out = {}
            if k and k.Settings then
                for sName, sObj in pairs(k.Settings) do
                    if sObj.Save then
                        sObj:Save(out)
                    end
                end
            end
            return out
        end

        function w:Save(customName)
            local configName = (type(customName) == "string" and #customName > 0 and customName) or tostring(self.Place)
            local k = {
                ConfigName = configName,
                PlaceId = self.Place,
                SavedAt = os.time(),
                Modules = {},
                Gui = {}
            }
            for C, f in pairs(self.Modules) do
                k.Modules[C] = {
                    Enabled = f.Enabled,
                    Expanded = f.Expanded,
                    Bind = (f.Bind and f.Bind.Name) or "None",
                    Settings = w:SaveOptions(f, true)
                }
            end
            local curTheme = (self.Modules.Interface and self.Modules.Interface.Settings and self.Modules.Interface.Settings.Theme and self.Modules.Interface.Settings.Theme.Value) or "Monochrome"
            local curTrans = (self.Modules.Interface and self.Modules.Interface.Settings and self.Modules.Interface.Settings.Transparency and self.Modules.Interface.Settings.Transparency.Value) or 0.4
            local curMode = (self.Modules.Interface and self.Modules.Interface.Settings and self.Modules.Interface.Settings.Mode and self.Modules.Interface.Settings.Mode.Value) or "Fade"
            k.Gui = {
                Theme = curTheme,
                Scale = self.Scale.Value,
                Transparency = curTrans,
                Mode = curMode,
                Keybind = self.Keybind,
                TargetHud = {
                    X = (K and K.AbsolutePosition.X) or 0,
                    Y = (K and K.AbsolutePosition.Y) or 0
                }
            }
            if not isfolder("AkiraLite/Config") and makefolder then
                makefolder("AkiraLite/Config")
            end
            local encoded = M:JSONEncode(k)
            writefile("AkiraLite/Config/" .. configName .. ".txt", encoded)
            writefile("AkiraLite/Config/Gui.txt", M:JSONEncode(k.Gui))
            return true, configName
        end

        function w:LoadOptions(M, k)
            if not (M and M.Settings and k) then return end
            for C, f in pairs(k) do
                local sObj = M.Settings[C]
                if sObj and sObj.Load then
                    sObj:Load(f)
                end
            end
        end

        function w:Load(customName)
            local configName = (type(customName) == "string" and #customName > 0 and customName) or (function()
                if isfile and isfile("AkiraLite/Config/Autoload.txt") and readfile then
                    local auto = readfile("AkiraLite/Config/Autoload.txt"):gsub("%s+", "")
                    if #auto > 0 and isfile("AkiraLite/Config/" .. auto .. ".txt") then
                        return auto
                    end
                end
                return tostring(self.Place)
            end)()

            local cfgPath = "AkiraLite/Config/" .. configName .. ".txt"
            if not (isfile and isfile(cfgPath) and readfile) then
                return false, "File not found: " .. configName
            end

            local k = X(cfgPath)
            if not k or type(k) ~= "table" then
                return false, "Invalid JSON data"
            end

            if k.Modules then
                for C, f in pairs(k.Modules) do
                    local mod = self.Modules[C]
                    if mod then
                        if f.Settings and mod.Settings then
                            self:LoadOptions(mod, f.Settings)
                        end
                        if f.Enabled ~= mod.Enabled then
                            mod:Toggle()
                        end
                        if f.Expanded ~= mod.Expanded then
                            mod:Expand()
                        end
                        if f.Bind and f.Bind ~= "None" then
                            pcall(function()
                                mod:SetBind(Enum.KeyCode[f.Bind])
                            end)
                        end
                    end
                end
            end

            local guiData = k.Gui or (isfile and isfile("AkiraLite/Config/Gui.txt") and X("AkiraLite/Config/Gui.txt"))
            if guiData and type(guiData) == "table" then
                if guiData.TargetHud and guiData.TargetHud.X and guiData.TargetHud.Y and K and guiData.TargetHud.X > 0 and guiData.TargetHud.Y > 0 then
                    K.Position = UDim2.fromOffset(guiData.TargetHud.X, guiData.TargetHud.Y)
                end
                if guiData.Theme and self.Modules.Interface and self.Modules.Interface.Settings and self.Modules.Interface.Settings.Theme then
                    self.Modules.Interface.Settings.Theme:Load({Value = guiData.Theme})
                end
                if guiData.Scale and type(guiData.Scale) == "number" then
                    self.Scale.Value = guiData.Scale
                    if V and V:FindFirstChildOfClass("UIScale") then
                        V:FindFirstChildOfClass("UIScale").Scale = (self.ClickGuiStatus and self.Scale.Value) or 0
                    end
                    if self.SettingsScale then
                        self.SettingsScale.Scale = (self.ClickGuiStatus and self.Scale.Value) or 0
                    end
                    if self.SkinsScale then
                        self.SkinsScale.Scale = (self.ClickGuiStatus and self.ActiveTab == "Skins" and self.Scale.Value) or 0
                    end
                end
                if guiData.Keybind and type(guiData.Keybind) == "table" and #guiData.Keybind > 0 then
                    self.Keybind = guiData.Keybind
                end
            end

            self.Loaded = true
            return true, configName
        end

        function w:SaveConfig(name)
            return self:Save(name)
        end

        function w:LoadConfig(name)
            return self:Load(name)
        end

        function w:SetAutoload(name)
            if not isfolder("AkiraLite/Config") and makefolder then
                makefolder("AkiraLite/Config")
            end
            if writefile then
                pcall(writefile, "AkiraLite/Config/Autoload.txt", name)
                pcall(writefile, "AkiraLite/autoload.txt", name)
            end
        end

        function w:GetConfigs()
            local cfgs = {}
            if listfiles and isfolder and isfolder("AkiraLite/Config") then
                local ok, files = pcall(listfiles, "AkiraLite/Config")
                if ok and type(files) == "table" then
                    for _, f in ipairs(files) do
                        local name = f:match("([^/\\]+)%.txt$") or f:match("([^/\\]+)%.json$")
                        if name and name ~= "Gui" and name ~= "Autoload" then
                            table.insert(cfgs, name)
                        end
                    end
                end
            end
            return cfgs
        end


        function w:Autoload()
            local target = nil
            if isfile and isfile("AkiraLite/Config/Autoload.txt") and readfile then
                local auto = readfile("AkiraLite/Config/Autoload.txt"):gsub("%s+", "")
                if #auto > 0 and isfile("AkiraLite/Config/" .. auto .. ".txt") then
                    target = auto
                end
            end
            if not target then
                local placeCfg = tostring(self.Place)
                if isfile and isfile("AkiraLite/Config/" .. placeCfg .. ".txt") then
                    target = placeCfg
                end
            end
            if target then
                local ok, name = self:Load(target)
                if ok then
                    self:Notify({
                        Text = "Autoloaded config: " .. tostring(name),
                        Duration = 3
                    })
                    return true, target
                end
            end
            return false
        end
        function w:Uninject()
            w:Save()
            w.Loaded = nil
            for M, M in self.Modules do
                if M.Enabled then
                    M:Toggle()
                end
            end
            for M, M in w.Connections do
                pcall(function()
                    M:Disconnect()
                end)
            end
            if w.ThreadFix then
                setthreadidentity(8)
            end
            w.MainScreenGui:ClearAllChildren()
            w.MainScreenGui:Destroy()
            table.clear(w.Libraries)
            Z(w)
            shared.AkiraLite = nil
        end
        function w:SendChat(M)
            game:GetService("TextChatService").TextChannels.RBXSystem:DisplaySystemMessage("<b><font color = \"rgb(150, 150, 150)\">[</font><font color = \"rgb(84, 140, 209)\">Akira Lite</font><font color = \"rgb(150, 150, 150)\">]</font></b>: " .. M)
        end
        local function M(k)
            if k.TextSource and k.Status == Enum.TextChatMessageStatus.Sending then
                if k.Text:find("^.bind") then
                    local C = k.Text:split(" ")
                    local f
                    pcall(function()
                        f = Enum.KeyCode[C[3]]
                    end)
                    if C[2] then
                        C[2] = C[2]:gsub("_", " ")
                    end
                    if #C == 3 and f and w.Modules[C[2]] then
                        w.Modules[C[2]]:SetBind(f)
                        w:SendChat(C[2] .. " has been bound to " .. C[3])
                    else
                        w:SendChat("Error")
                    end
                    k.Text = ""
                elseif k.Text:find("^.clearbind") or k.Text:find("^.unbind") then
                    local C = k.Text:split(" ")
                    if C[2] then
                        C[2] = C[2]:gsub("_", " ")
                    end
                    if #C == 2 and w.Modules[C[2]] then
                        w.Modules[C[2]]:SetBind({})
                        w:SendChat("Unbound " .. C[2])
                    else
                        w:SendChat("Error")
                    end
                    k.Text = ""
                end
            end
        end
        task.spawn(function()
            repeat
                A.OnIncomingMessage = M
                task.wait(1)
            until not (w.Loaded or shared.AkiraLiteLoading)
        end)
        local A = w:AddCatalog({
            Name = "Combat"
        })
        local A = w:AddCatalog({
            Name = "Render"
        })
        local A = w:AddCatalog({
            Name = "Movement"
        })
        local A = w:AddCatalog({
            Name = "Player"
        })
        local A = w:AddCatalog({
            Name = "Other"
        })
        local A = w:AddCatalog({
            Name = "World"
        })
                                                        
        T(function()
            L = A:AddModule({
                Name = "Target Hud",
                Function = function(B)
                    if B then
                        L:Clean(w.MainScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                            l.Size = UDim2.new(0, w.MainScreenGui.AbsoluteSize.Y / 6, 0, w.MainScreenGui.AbsoluteSize.Y / 14)
                        end))
                                                                              
                                                                       
                                                  
        L:Clean(x(j.PreRender, 0.1, function()
            q:UpdateInfo()
        end))
                        K.Visible = true
                        s.Scale = 0
                        d:Create(s, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {
                            Scale = R.Value or 1
                        }):Play()
                    else
                        s.Scale = R.Value or 1
                        d:Create(s, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {
                            Scale = 0
                        }):Play()
                        task.wait(0.3)
                        K.Visible = false
                    end
                end
            })
            y = L:AddToggle({
                Name = "Sound Effect"
            })
            R = L:AddSlider({
                Name = "Scale",
                Min = 0.1,
                Max = 3,
                Decimal = 10,
                Default = 1,
                Function = function(L)
                    s.Scale = L
                end
            })
        end)
        T(function()
            x = A:AddModule({
                Name = "ArrayList",
                Function = function(L)
                    p.Visible = L
                end
            })
            Y = x:AddSlider({
                Name = "Transparency",
                Min = 0,
                Max = 1,
                Function = function(L)
                    for B, B in p:GetChildren() do
                        if B:IsA("Frame") then
                            B.TextLabel.BackgroundTransparency = 1 - L
                        end
                    end
                end,
                Decimal = 10,
                Default = 1
            })
            x:AddSlider({
                Name = "Size",
                Min = 5,
                Max = 30,
                Function = function(L)
                    m = L
                end,
                Decimal = 10,
                Default = 20
            })
            n = x:AddToggle({
                Name = "Glow Line",
                Function = function(m)
                    for L, L in p:GetChildren() do
                        if L:IsA("Frame") then
                            L.TextLabel.Frame.Visible = m
                        end
                    end
                end
            })
            ArrayListGlowEffect = x:AddToggle({
                Name = "Glow Effect",
                Function = function(m)
                    for L, L in p:GetChildren() do
                        if L:IsA("Frame") then
                            L.TextLabel.Frame.Visible = m
                        end
                    end
                end
            })
        end)
        shared.AkiraLite = w
                                          
        task.spawn(function()
            task.wait(0.2)
            pcall(function()
                w:Autoload()
            end)
        end)

    return w
end

                                                                                        
return setmetatable({ Init = InitLibrary }, {
    __call = function(_, ...)
        return InitLibrary(...)
    end
})
