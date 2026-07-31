--[[
    mantis.dev - Squared / Snake-Case Roblox UI Library
    Aesthetic: Sharp 0px Squared Corners, Sleek Dark Grey/Black Main (#121415, #181a1b, #242728)
    Accent: Light Green (#8cf06e / RGB: 140, 240, 110)
    API Style: Identical compatibility with exampleui.lua & snake_case / table parameters
--]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local gethui = gethui or function() return CoreGui end

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Mantis = {
    Version = "1.1.0",
    Flags = {},
    Signals = {},
    Objects = {},
    Toggles = {},
    Keybinds = {},
    Theme = {
        Main = Color3.fromRGB(16, 18, 19),
        TopBar = Color3.fromRGB(12, 13, 14),
        Container = Color3.fromRGB(22, 25, 26),
        ContainerHeader = Color3.fromRGB(26, 30, 31),
        Border = Color3.fromRGB(36, 41, 42),
        Element = Color3.fromRGB(28, 32, 33),
        ElementHover = Color3.fromRGB(36, 42, 43),
        Accent = Color3.fromRGB(140, 240, 110), -- Light Green
        AccentDark = Color3.fromRGB(65, 130, 45),
        Text = Color3.fromRGB(235, 240, 237),
        TextDark = Color3.fromRGB(135, 142, 138),
        Outline = Color3.fromRGB(30, 34, 35)
    },
    MenuKeybind = Enum.KeyCode.RightShift,
    Visible = true,
    ScreenGui = nil,
    KeybindFrameObj = nil,
    WatermarkObj = nil
}

-- Helpers
local function Tween(object, goal, duration, easingStyle, easingDirection)
    duration = duration or 0.15
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(object, info, goal)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.04)
        end
    end)
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MantisDevUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end
Mantis.ScreenGui = ScreenGui

-- Menu Keybind Toggle
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Mantis.MenuKeybind then
        Mantis:SetVisible(not Mantis.Visible)
    end
end)

function Mantis:SetVisible(state)
    Mantis.Visible = state
    if Mantis.WindowFrame then
        Mantis.WindowFrame.Visible = state
    end
end

------------------------------------------------------------------------
-- WATERMARK (Squared)
------------------------------------------------------------------------
function Mantis:CreateWatermark(defaultText, logo)
    defaultText = defaultText or "mantis.dev | v1.0.0"
    
    local WatermarkFrame = Instance.new("Frame")
    WatermarkFrame.Name = "MantisWatermark"
    WatermarkFrame.Size = UDim2.new(0, 250, 0, 28)
    WatermarkFrame.Position = UDim2.new(0, 20, 0, 20)
    WatermarkFrame.BackgroundColor3 = Mantis.Theme.Container
    WatermarkFrame.BorderSizePixel = 0
    WatermarkFrame.Parent = ScreenGui

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Mantis.Theme.Border
    Stroke.Thickness = 1
    Stroke.Parent = WatermarkFrame

    local TopAccent = Instance.new("Frame")
    TopAccent.Size = UDim2.new(1, 0, 0, 2)
    TopAccent.BackgroundColor3 = Mantis.Theme.Accent
    TopAccent.BorderSizePixel = 0
    TopAccent.Parent = WatermarkFrame

    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 80, 1, 0)
    IconLabel.Position = UDim2.new(0, 10, 0, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "mantis<font color=\"rgb(140,240,110)\">.dev</font>"
    IconLabel.RichText = true
    IconLabel.TextColor3 = Mantis.Theme.Text
    IconLabel.TextSize = 13
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextXAlignment = Enum.TextXAlignment.Left
    IconLabel.Parent = WatermarkFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -95, 1, 0)
    TextLabel.Position = UDim2.new(0, 90, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = defaultText
    TextLabel.TextColor3 = Mantis.Theme.TextDark
    TextLabel.TextSize = 12
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextXAlignment = Enum.TextXAlignment.Right
    TextLabel.Parent = WatermarkFrame

    MakeDraggable(WatermarkFrame)

    local WatermarkObj = {
        Frame = WatermarkFrame,
        SetText = function(self, text)
            TextLabel.Text = text
            local textBounds = TextLabel.TextBounds.X
            WatermarkFrame.Size = UDim2.new(0, math.max(220, textBounds + 105), 0, 28)
        end,
        SetVisibility = function(self, visible)
            WatermarkFrame.Visible = visible
        end,
        SetVisible = function(self, visible)
            WatermarkFrame.Visible = visible
        end
    }
    Mantis.WatermarkObj = WatermarkObj
    return WatermarkObj
end

function Mantis:Watermark(text, logo)
    return Mantis:CreateWatermark(text, logo)
end

------------------------------------------------------------------------
-- KEYBIND FRAME / KEYBIND LIST (Squared)
------------------------------------------------------------------------
function Mantis:CreateKeybindFrame()
    if Mantis.KeybindFrameObj then return Mantis.KeybindFrameObj end

    local KeyFrame = Instance.new("Frame")
    KeyFrame.Name = "MantisKeybindList"
    KeyFrame.Size = UDim2.new(0, 200, 0, 140)
    KeyFrame.Position = UDim2.new(0, 20, 0, 60)
    KeyFrame.BackgroundColor3 = Mantis.Theme.Container
    KeyFrame.BorderSizePixel = 0
    KeyFrame.Parent = ScreenGui

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Mantis.Theme.Border
    Stroke.Thickness = 1
    Stroke.Parent = KeyFrame

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 26)
    Header.BackgroundColor3 = Mantis.Theme.ContainerHeader
    Header.BorderSizePixel = 0
    Header.Parent = KeyFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Keybinds"
    Title.TextColor3 = Mantis.Theme.Text
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(1, 0, 0, 2)
    AccentBar.Position = UDim2.new(0, 0, 1, -2)
    AccentBar.BackgroundColor3 = Mantis.Theme.Accent
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = Header

    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -12, 1, -34)
    Container.Position = UDim2.new(0, 6, 0, 30)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 2
    Container.ScrollBarImageColor3 = Mantis.Theme.Accent
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.Parent = KeyFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 4)
    ListLayout.Parent = Container

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end)

    MakeDraggable(KeyFrame, Header)

    local KeybindList = {
        Frame = KeyFrame,
        Container = Container,
        Items = {},
        Update = function(self)
            for _, child in ipairs(Container:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            for name, data in pairs(Mantis.Keybinds) do
                if data.Key and data.Key ~= "None" and data.Active then
                    local Row = Instance.new("Frame")
                    Row.Size = UDim2.new(1, 0, 0, 20)
                    Row.BackgroundTransparency = 1
                    Row.Parent = Container

                    local NameLabel = Instance.new("TextLabel")
                    NameLabel.Size = UDim2.new(0.6, 0, 1, 0)
                    NameLabel.BackgroundTransparency = 1
                    NameLabel.Text = name
                    NameLabel.TextColor3 = Mantis.Theme.Text
                    NameLabel.TextSize = 11
                    NameLabel.Font = Enum.Font.Gotham
                    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                    NameLabel.Parent = Row

                    local StateLabel = Instance.new("TextLabel")
                    StateLabel.Size = UDim2.new(0.4, 0, 1, 0)
                    StateLabel.Position = UDim2.new(0.6, 0, 0, 0)
                    StateLabel.BackgroundTransparency = 1
                    StateLabel.Text = "[" .. tostring(data.Key):gsub("Enum.KeyCode.", "") .. "]"
                    StateLabel.TextColor3 = Mantis.Theme.Accent
                    StateLabel.TextSize = 11
                    StateLabel.Font = Enum.Font.GothamBold
                    StateLabel.TextXAlignment = Enum.TextXAlignment.Right
                    StateLabel.Parent = Row
                end
            end
        end,
        SetVisibility = function(self, state)
            KeyFrame.Visible = state
        end
    }

    Mantis.KeybindFrameObj = KeybindList
    return KeybindList
end

function Mantis:KeybindFrame()
    return Mantis:CreateKeybindFrame()
end
function Mantis:KeybindList()
    return Mantis:CreateKeybindFrame()
end

------------------------------------------------------------------------
-- WINDOW CREATION (Squared)
------------------------------------------------------------------------
function Mantis:CreateWindow(cfg)
    cfg = cfg or {}
    local windowTitle = cfg.Title or cfg.Name or "mantis.dev"
    local windowSize = cfg.Size or UDim2.fromOffset(700, 480)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MantisMainWindow"
    MainFrame.Size = windowSize
    MainFrame.Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2)
    MainFrame.BackgroundColor3 = Mantis.Theme.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    Mantis.WindowFrame = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Mantis.Theme.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Mantis.Theme.TopBar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    -- Top Accent Line below TopBar
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = Mantis.Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = TopBar

    -- Brand Title (Left Side of Top Bar)
    local BrandContainer = Instance.new("Frame")
    BrandContainer.Size = UDim2.new(0, 150, 1, 0)
    BrandContainer.Position = UDim2.new(0, 14, 0, 0)
    BrandContainer.BackgroundTransparency = 1
    BrandContainer.Parent = TopBar

    local BrandText = Instance.new("TextLabel")
    BrandText.Size = UDim2.new(1, 0, 1, 0)
    BrandText.BackgroundTransparency = 1
    BrandText.Text = "mantis<font color=\"rgb(140,240,110)\">.dev</font>"
    BrandText.RichText = true
    BrandText.TextColor3 = Mantis.Theme.Text
    BrandText.TextSize = 16
    BrandText.Font = Enum.Font.GothamBold
    BrandText.TextXAlignment = Enum.TextXAlignment.Left
    BrandText.Parent = BrandContainer

    -- Tabs Holder (Right side of top bar)
    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, -180, 1, 0)
    TabBar.Position = UDim2.new(0, 160, 0, 0)
    TabBar.BackgroundTransparency = 1
    TabBar.BorderSizePixel = 0
    TabBar.ScrollBarThickness = 0
    TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabBar.Parent = TopBar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabListLayout.Parent = TabBar

    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabBar.CanvasSize = UDim2.new(0, TabListLayout.AbsoluteContentSize.X + 10, 0, 0)
    end)

    -- Content Container (below TopBar)
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -20, 1, -52)
    ContentContainer.Position = UDim2.new(0, 10, 0, 46)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    MakeDraggable(MainFrame, TopBar)

    local Window = {
        Frame = MainFrame,
        Tabs = {},
        ActiveTab = nil
    }

    --------------------------------------------------------------------
    -- TAB / PAGE CREATION (Squared)
    --------------------------------------------------------------------
    function Window:AddTab(tabOptions)
        local tabTitle = type(tabOptions) == "table" and (tabOptions.Name or tabOptions.Title) or tabOptions

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. tabTitle
        TabBtn.Size = UDim2.new(0, 95, 0, 28)
        TabBtn.BackgroundColor3 = Mantis.Theme.Container
        TabBtn.Text = tabTitle
        TabBtn.TextColor3 = Mantis.Theme.TextDark
        TabBtn.TextSize = 12
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.AutoButtonColor = false
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = TabBar

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Size = UDim2.new(1, 0, 0, 2)
        TabIndicator.Position = UDim2.new(0, 0, 1, -2)
        TabIndicator.BackgroundColor3 = Mantis.Theme.Accent
        TabIndicator.Visible = false
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Parent = TabBtn

        -- Tab View Frame
        local TabView = Instance.new("Frame")
        TabView.Name = "View_" .. tabTitle
        TabView.Size = UDim2.new(1, 0, 1, 0)
        TabView.BackgroundTransparency = 1
        TabView.Visible = false
        TabView.Parent = ContentContainer

        -- Left & Right Columns
        local LeftCol = Instance.new("ScrollingFrame")
        LeftCol.Name = "LeftColumn"
        LeftCol.Size = UDim2.new(0.5, -6, 1, 0)
        LeftCol.Position = UDim2.new(0, 0, 0, 0)
        LeftCol.BackgroundTransparency = 1
        LeftCol.BorderSizePixel = 0
        LeftCol.ScrollBarThickness = 2
        LeftCol.ScrollBarImageColor3 = Mantis.Theme.Accent
        LeftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftCol.Parent = TabView

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.Parent = LeftCol

        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            LeftCol.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 10)
        end)

        local RightCol = Instance.new("ScrollingFrame")
        RightCol.Name = "RightColumn"
        RightCol.Size = UDim2.new(0.5, -6, 1, 0)
        RightCol.Position = UDim2.new(0.5, 6, 0, 0)
        RightCol.BackgroundTransparency = 1
        RightCol.BorderSizePixel = 0
        RightCol.ScrollBarThickness = 2
        RightCol.ScrollBarImageColor3 = Mantis.Theme.Accent
        RightCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        RightCol.Parent = TabView

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 10)
        RightLayout.Parent = RightCol

        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            RightCol.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 10)
        end)

        local TabObj = {
            Title = tabTitle,
            Button = TabBtn,
            View = TabView,
            LeftCol = LeftCol,
            RightCol = RightCol
        }

        local function ActivateTab()
            for _, t in pairs(Window.Tabs) do
                t.View.Visible = false
                t.Button.Indicator.Visible = false
                Tween(t.Button, {BackgroundColor3 = Mantis.Theme.Container, TextColor3 = Mantis.Theme.TextDark})
                t.Button.Font = Enum.Font.GothamMedium
            end
            TabView.Visible = true
            TabIndicator.Visible = true
            Window.ActiveTab = TabObj
            Tween(TabBtn, {BackgroundColor3 = Mantis.Theme.Element, TextColor3 = Mantis.Theme.Accent})
            TabBtn.Font = Enum.Font.GothamBold
        end

        TabBtn.Indicator = TabIndicator
        TabBtn.MouseButton1Click:Connect(ActivateTab)

        if #Window.Tabs == 0 then
            ActivateTab()
        end

        table.insert(Window.Tabs, TabObj)

        ----------------------------------------------------------------
        -- GROUPBOX & TABBOX IMPLEMENTATION (Squared)
        ----------------------------------------------------------------
        local function CreateGroupboxContainer(parentCol, titleText)
            local BoxFrame = Instance.new("Frame")
            BoxFrame.Name = "Groupbox_" .. titleText
            BoxFrame.Size = UDim2.new(1, 0, 0, 40)
            BoxFrame.BackgroundColor3 = Mantis.Theme.Container
            BoxFrame.BorderSizePixel = 0
            BoxFrame.Parent = parentCol

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = Mantis.Theme.Border
            BoxStroke.Thickness = 1
            BoxStroke.Parent = BoxFrame

            -- Header
            local BoxHeader = Instance.new("Frame")
            BoxHeader.Size = UDim2.new(1, 0, 0, 24)
            BoxHeader.BackgroundColor3 = Mantis.Theme.ContainerHeader
            BoxHeader.BorderSizePixel = 0
            BoxHeader.Parent = BoxFrame

            local HeaderDot = Instance.new("Frame")
            HeaderDot.Size = UDim2.new(0, 3, 0, 12)
            HeaderDot.Position = UDim2.new(0, 8, 0.5, -6)
            HeaderDot.BackgroundColor3 = Mantis.Theme.Accent
            HeaderDot.BorderSizePixel = 0
            HeaderDot.Parent = BoxHeader

            local HeaderTitle = Instance.new("TextLabel")
            HeaderTitle.Size = UDim2.new(1, -22, 1, 0)
            HeaderTitle.Position = UDim2.new(0, 18, 0, 0)
            HeaderTitle.BackgroundTransparency = 1
            HeaderTitle.Text = titleText
            HeaderTitle.TextColor3 = Mantis.Theme.Text
            HeaderTitle.TextSize = 12
            HeaderTitle.Font = Enum.Font.GothamBold
            HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
            HeaderTitle.Parent = BoxHeader

            -- Content Frame inside Box
            local BoxContent = Instance.new("Frame")
            BoxContent.Size = UDim2.new(1, -16, 1, -30)
            BoxContent.Position = UDim2.new(0, 8, 0, 28)
            BoxContent.BackgroundTransparency = 1
            BoxContent.Parent = BoxFrame

            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Padding = UDim.new(0, 6)
            ContentLayout.Parent = BoxContent

            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                BoxFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 34)
            end)

            return BoxFrame, BoxContent
        end

        local function BuildControlsApi(containerFrame)
            local GroupObj = {}

            -- TOGGLE CONTROL (Squared)
            function GroupObj:Toggle(options)
                local flag = type(options) == "table" and (options.Flag or options.Name) or options
                local name = type(options) == "table" and (options.Name or options.Text or flag) or options
                local default = type(options) == "table" and options.Default or false
                local callback = type(options) == "table" and options.Callback or function() end

                Mantis.Flags[flag] = default

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = containerFrame

                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
                ToggleBtn.BackgroundTransparency = 1
                ToggleBtn.Text = ""
                ToggleBtn.Parent = ToggleFrame

                local Checkbox = Instance.new("Frame")
                Checkbox.Size = UDim2.new(0, 14, 0, 14)
                Checkbox.Position = UDim2.new(0, 0, 0.5, -7)
                Checkbox.BackgroundColor3 = default and Mantis.Theme.Accent or Mantis.Theme.Element
                Checkbox.BorderSizePixel = 0
                Checkbox.Parent = ToggleBtn

                local CheckStroke = Instance.new("UIStroke")
                CheckStroke.Color = default and Mantis.Theme.Accent or Mantis.Theme.Border
                CheckStroke.Thickness = 1
                CheckStroke.Parent = Checkbox

                local CheckMark = Instance.new("TextLabel")
                CheckMark.Size = UDim2.new(1, 0, 1, 0)
                CheckMark.BackgroundTransparency = 1
                CheckMark.Text = "✓"
                CheckMark.TextColor3 = Mantis.Theme.Main
                CheckMark.TextSize = 11
                CheckMark.Font = Enum.Font.GothamBold
                CheckMark.Visible = default
                CheckMark.Parent = Checkbox

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Size = UDim2.new(1, -70, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 22, 0, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = name
                ToggleLabel.TextColor3 = Mantis.Theme.Text
                ToggleLabel.TextSize = 12
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleBtn

                local SubHolder = Instance.new("Frame")
                SubHolder.Size = UDim2.new(0, 100, 1, 0)
                SubHolder.Position = UDim2.new(1, -100, 0, 0)
                SubHolder.BackgroundTransparency = 1
                SubHolder.Parent = ToggleFrame

                local SubLayout = Instance.new("UIListLayout")
                SubLayout.FillDirection = Enum.FillDirection.Horizontal
                SubLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                SubLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                SubLayout.Padding = UDim.new(0, 4)
                SubLayout.Parent = SubHolder

                local state = default

                local function SetState(val)
                    state = val
                    Mantis.Flags[flag] = state
                    CheckMark.Visible = state
                    Tween(Checkbox, {BackgroundColor3 = state and Mantis.Theme.Accent or Mantis.Theme.Element})
                    CheckStroke.Color = state and Mantis.Theme.Accent or Mantis.Theme.Border
                    pcall(callback, state)
                end

                ToggleBtn.MouseButton1Click:Connect(function()
                    SetState(not state)
                end)

                local ToggleObj = {
                    Set = SetState,
                    Frame = ToggleFrame
                }

                -- Colorpicker on Toggle (Squared)
                function ToggleObj:Colorpicker(cpOptions)
                    local cpFlag = type(cpOptions) == "table" and (cpOptions.Flag or cpOptions.Name) or cpOptions
                    local defaultColor = type(cpOptions) == "table" and (cpOptions.Default or cpOptions.Color) or Color3.fromRGB(255, 255, 255)
                    local cpCallback = type(cpOptions) == "table" and cpOptions.Callback or function() end

                    Mantis.Flags[cpFlag] = defaultColor

                    local ColorBtn = Instance.new("TextButton")
                    ColorBtn.Size = UDim2.new(0, 20, 0, 12)
                    ColorBtn.BackgroundColor3 = defaultColor
                    ColorBtn.Text = ""
                    ColorBtn.AutoButtonColor = false
                    ColorBtn.BorderSizePixel = 0
                    ColorBtn.Parent = SubHolder

                    local CBStroke = Instance.new("UIStroke")
                    CBStroke.Color = Mantis.Theme.Border
                    CBStroke.Thickness = 1
                    CBStroke.Parent = ColorBtn

                    local PickerPopout = Instance.new("Frame")
                    PickerPopout.Size = UDim2.new(0, 160, 0, 115)
                    PickerPopout.BackgroundColor3 = Mantis.Theme.Container
                    PickerPopout.Position = UDim2.new(1, -165, 1, 4)
                    PickerPopout.Visible = false
                    PickerPopout.ZIndex = 10
                    PickerPopout.Parent = ColorBtn

                    local PPStroke = Instance.new("UIStroke")
                    PPStroke.Color = Mantis.Theme.Accent
                    PPStroke.Thickness = 1
                    PPStroke.Parent = PickerPopout

                    local HueCanvas = Instance.new("TextButton")
                    HueCanvas.Size = UDim2.new(1, -12, 0, 75)
                    HueCanvas.Position = UDim2.new(0, 6, 0, 6)
                    HueCanvas.BackgroundColor3 = defaultColor
                    HueCanvas.Text = "Select Color"
                    HueCanvas.TextColor3 = Mantis.Theme.Main
                    HueCanvas.TextSize = 10
                    HueCanvas.Font = Enum.Font.GothamBold
                    HueCanvas.ZIndex = 11
                    HueCanvas.BorderSizePixel = 0
                    HueCanvas.Parent = PickerPopout

                    local PresetContainer = Instance.new("Frame")
                    PresetContainer.Size = UDim2.new(1, -12, 0, 20)
                    PresetContainer.Position = UDim2.new(0, 6, 0, 86)
                    PresetContainer.BackgroundTransparency = 1
                    PresetContainer.ZIndex = 11
                    PresetContainer.Parent = PickerPopout

                    local PLayout = Instance.new("UIListLayout")
                    PLayout.FillDirection = Enum.FillDirection.Horizontal
                    PLayout.Padding = UDim.new(0, 4)
                    PLayout.Parent = PresetContainer

                    local presets = {
                        Color3.fromRGB(140, 240, 110),
                        Color3.fromRGB(255, 85, 85),
                        Color3.fromRGB(85, 170, 255),
                        Color3.fromRGB(255, 255, 85),
                        Color3.fromRGB(255, 255, 255)
                    }

                    for _, pColor in ipairs(presets) do
                        local pBtn = Instance.new("TextButton")
                        pBtn.Size = UDim2.new(0, 24, 0, 18)
                        pBtn.BackgroundColor3 = pColor
                        pBtn.Text = ""
                        pBtn.BorderSizePixel = 0
                        pBtn.ZIndex = 12
                        pBtn.Parent = PresetContainer

                        pBtn.MouseButton1Click:Connect(function()
                            ColorBtn.BackgroundColor3 = pColor
                            HueCanvas.BackgroundColor3 = pColor
                            Mantis.Flags[cpFlag] = pColor
                            pcall(cpCallback, pColor)
                        end)
                    end

                    ColorBtn.MouseButton1Click:Connect(function()
                        PickerPopout.Visible = not PickerPopout.Visible
                    end)

                    return ToggleObj
                end

                ToggleObj.AddColorPicker = ToggleObj.Colorpicker
                ToggleObj.colorpicker = ToggleObj.Colorpicker

                -- Keybind on Toggle (Squared)
                function ToggleObj:Keybind(kpOptions)
                    local kpFlag = type(kpOptions) == "table" and (kpOptions.Flag or kpOptions.Name) or kpOptions
                    local defaultKey = type(kpOptions) == "table" and kpOptions.Default or Enum.KeyCode.Unknown
                    local kpCallback = type(kpOptions) == "table" and kpOptions.Callback or function() end
                    local mode = type(kpOptions) == "table" and kpOptions.Mode or "Toggle"

                    local keyName = typeof(defaultKey) == "EnumItem" and defaultKey.Name or tostring(defaultKey)
                    Mantis.Flags[kpFlag] = keyName

                    local KeyBtn = Instance.new("TextButton")
                    KeyBtn.Size = UDim2.new(0, 40, 0, 14)
                    KeyBtn.BackgroundColor3 = Mantis.Theme.Element
                    KeyBtn.Text = "[" .. keyName .. "]"
                    KeyBtn.TextColor3 = Mantis.Theme.Accent
                    KeyBtn.TextSize = 10
                    KeyBtn.Font = Enum.Font.GothamBold
                    KeyBtn.BorderSizePixel = 0
                    KeyBtn.Parent = SubHolder

                    local KeyStroke = Instance.new("UIStroke")
                    KeyStroke.Color = Mantis.Theme.Border
                    KeyStroke.Thickness = 1
                    KeyStroke.Parent = KeyBtn

                    KeyBtn.MouseButton1Click:Connect(function()
                        KeyBtn.Text = "[...]"
                        local conn
                        conn = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                keyName = input.KeyCode.Name
                                KeyBtn.Text = "[" .. keyName .. "]"
                                Mantis.Flags[kpFlag] = keyName
                                conn:Disconnect()
                                pcall(kpCallback, input.KeyCode)
                            end
                        end)
                    end)

                    Mantis.Keybinds[name] = {
                        Key = keyName,
                        Active = state,
                        Mode = mode
                    }

                    if Mantis.KeybindFrameObj then
                        Mantis.KeybindFrameObj:Update()
                    end

                    return ToggleObj
                end

                ToggleObj.AddKeyPicker = ToggleObj.Keybind
                ToggleObj.keybind = ToggleObj.Keybind

                return ToggleObj
            end

            GroupObj.AddToggle = GroupObj.Toggle
            GroupObj.toggle = GroupObj.Toggle

            -- BUTTON CONTROL (Squared)
            function GroupObj:Button(options, funcCall)
                local name = type(options) == "table" and (options.Name or options.Text) or options
                local callback = type(options) == "table" and (options.Callback or options.Func) or funcCall or function() end

                local BtnFrame = Instance.new("Frame")
                BtnFrame.Size = UDim2.new(1, 0, 0, 26)
                BtnFrame.BackgroundTransparency = 1
                BtnFrame.Parent = containerFrame

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundColor3 = Mantis.Theme.Element
                Btn.Text = name
                Btn.TextColor3 = Mantis.Theme.Text
                Btn.TextSize = 12
                Btn.Font = Enum.Font.GothamMedium
                Btn.AutoButtonColor = false
                Btn.BorderSizePixel = 0
                Btn.Parent = BtnFrame

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Mantis.Theme.Border
                BtnStroke.Thickness = 1
                BtnStroke.Parent = Btn

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Mantis.Theme.ElementHover})
                    BtnStroke.Color = Mantis.Theme.Accent
                end)

                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Mantis.Theme.Element})
                    BtnStroke.Color = Mantis.Theme.Border
                end)

                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Mantis.Theme.AccentDark}, 0.08).Completed:Connect(function()
                        Tween(Btn, {BackgroundColor3 = Mantis.Theme.ElementHover})
                    end)
                    pcall(callback)
                end)

                local ButtonObj = {
                    Frame = BtnFrame,
                    Btn = Btn
                }

                function ButtonObj:SubButton(subOptions, subFuncCall)
                    local subName = type(subOptions) == "table" and (subOptions.Name or subOptions.Text) or subOptions
                    local subCallback = type(subOptions) == "table" and (subOptions.Callback or subOptions.Func) or subFuncCall or function() end

                    Btn.Size = UDim2.new(0.5, -2, 1, 0)

                    local SubBtn = Instance.new("TextButton")
                    SubBtn.Size = UDim2.new(0.5, -2, 1, 0)
                    SubBtn.Position = UDim2.new(0.5, 2, 0, 0)
                    SubBtn.BackgroundColor3 = Mantis.Theme.Element
                    SubBtn.Text = subName
                    SubBtn.TextColor3 = Mantis.Theme.Text
                    SubBtn.TextSize = 12
                    SubBtn.Font = Enum.Font.GothamMedium
                    SubBtn.AutoButtonColor = false
                    SubBtn.BorderSizePixel = 0
                    SubBtn.Parent = BtnFrame

                    local SubBtnStroke = Instance.new("UIStroke")
                    SubBtnStroke.Color = Mantis.Theme.Border
                    SubBtnStroke.Thickness = 1
                    SubBtnStroke.Parent = SubBtn

                    SubBtn.MouseEnter:Connect(function()
                        Tween(SubBtn, {BackgroundColor3 = Mantis.Theme.ElementHover})
                        SubBtnStroke.Color = Mantis.Theme.Accent
                    end)

                    SubBtn.MouseLeave:Connect(function()
                        Tween(SubBtn, {BackgroundColor3 = Mantis.Theme.Element})
                        SubBtnStroke.Color = Mantis.Theme.Border
                    end)

                    SubBtn.MouseButton1Click:Connect(function()
                        pcall(subCallback)
                    end)

                    return ButtonObj
                end

                ButtonObj.AddSubButton = ButtonObj.SubButton
                ButtonObj.AddButton = ButtonObj.SubButton

                return ButtonObj
            end

            GroupObj.AddButton = GroupObj.Button
            GroupObj.button = GroupObj.Button
            GroupObj.SubButton = GroupObj.Button
            GroupObj.AddSubButton = GroupObj.Button

            -- LABEL CONTROL
            function GroupObj:Label(options)
                local text = type(options) == "table" and (options.Name or options.Text) or options

                local LabelFrame = Instance.new("Frame")
                LabelFrame.Size = UDim2.new(1, 0, 0, 18)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Parent = containerFrame

                local LabelText = Instance.new("TextLabel")
                LabelText.Size = UDim2.new(1, 0, 1, 0)
                LabelText.BackgroundTransparency = 1
                LabelText.Text = text
                LabelText.TextColor3 = Mantis.Theme.TextDark
                LabelText.TextSize = 12
                LabelText.Font = Enum.Font.Gotham
                LabelText.TextXAlignment = Enum.TextXAlignment.Left
                LabelText.Parent = LabelFrame

                local LabelObj = {
                    Frame = LabelFrame,
                    SetText = function(self, newText)
                        LabelText.Text = newText
                    end
                }

                function LabelObj:Colorpicker(cpOptions)
                    local cpFlag = type(cpOptions) == "table" and (cpOptions.Flag or cpOptions.Name) or cpOptions
                    local defaultColor = type(cpOptions) == "table" and (cpOptions.Default or cpOptions.Color) or Color3.fromRGB(255, 255, 255)
                    local cpCallback = type(cpOptions) == "table" and cpOptions.Callback or function() end

                    Mantis.Flags[cpFlag] = defaultColor

                    local ColorBtn = Instance.new("TextButton")
                    ColorBtn.Size = UDim2.new(0, 20, 0, 12)
                    ColorBtn.Position = UDim2.new(1, -20, 0.5, -6)
                    ColorBtn.BackgroundColor3 = defaultColor
                    ColorBtn.Text = ""
                    ColorBtn.BorderSizePixel = 0
                    ColorBtn.Parent = LabelFrame

                    ColorBtn.MouseButton1Click:Connect(function()
                        pcall(cpCallback, defaultColor)
                    end)

                    return LabelObj
                end

                LabelObj.AddColorPicker = LabelObj.Colorpicker
                return LabelObj
            end

            GroupObj.AddLabel = GroupObj.Label
            GroupObj.label = GroupObj.Label

            -- DIVIDER CONTROL
            function GroupObj:Divider()
                local DivFrame = Instance.new("Frame")
                DivFrame.Size = UDim2.new(1, 0, 0, 6)
                DivFrame.BackgroundTransparency = 1
                DivFrame.Parent = containerFrame

                local Line = Instance.new("Frame")
                Line.Size = UDim2.new(1, 0, 0, 1)
                Line.Position = UDim2.new(0, 0, 0.5, 0)
                Line.BackgroundColor3 = Mantis.Theme.Border
                Line.BorderSizePixel = 0
                Line.Parent = DivFrame

                return DivFrame
            end

            GroupObj.AddDivider = GroupObj.Divider

            -- SLIDER CONTROL (Squared)
            function GroupObj:Slider(options)
                local flag = type(options) == "table" and (options.Flag or options.Name) or options
                local name = type(options) == "table" and (options.Name or options.Text or flag) or options
                local min = type(options) == "table" and options.Min or 0
                local max = type(options) == "table" and options.Max or 100
                local default = type(options) == "table" and options.Default or min
                local decimals = type(options) == "table" and options.Decimals or 0
                local suffix = type(options) == "table" and options.Suffix or ""
                local callback = type(options) == "table" and options.Callback or function() end

                Mantis.Flags[flag] = default

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 40)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = containerFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.6, 0, 0, 16)
                Label.BackgroundTransparency = 1
                Label.Text = name
                Label.TextColor3 = Mantis.Theme.Text
                Label.TextSize = 12
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SliderFrame

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0.4, 0, 0, 16)
                ValueLabel.Position = UDim2.new(0.6, 0, 0, 0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(default) .. suffix
                ValueLabel.TextColor3 = Mantis.Theme.Accent
                ValueLabel.TextSize = 12
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame

                local Track = Instance.new("TextButton")
                Track.Size = UDim2.new(1, 0, 0, 12)
                Track.Position = UDim2.new(0, 0, 0, 20)
                Track.BackgroundColor3 = Mantis.Theme.Element
                Track.Text = ""
                Track.AutoButtonColor = false
                Track.BorderSizePixel = 0
                Track.Parent = SliderFrame

                local TrackStroke = Instance.new("UIStroke")
                TrackStroke.Color = Mantis.Theme.Border
                TrackStroke.Thickness = 1
                TrackStroke.Parent = Track

                local Fill = Instance.new("Frame")
                local startPercent = (default - min) / (max - min)
                Fill.Size = UDim2.new(startPercent, 0, 1, 0)
                Fill.BackgroundColor3 = Mantis.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Parent = Track

                local dragging = false

                local function UpdateValue(input)
                    local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local val = min + (max - min) * percent
                    if decimals == 0 then
                        val = math.floor(val + 0.5)
                    else
                        local mult = 10 ^ decimals
                        val = math.floor(val * mult + 0.5) / mult
                    end

                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    ValueLabel.Text = tostring(val) .. suffix
                    Mantis.Flags[flag] = val
                    pcall(callback, val)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateValue(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateValue(input)
                    end
                end)

                return {
                    Set = function(self, val)
                        val = math.clamp(val, min, max)
                        local percent = (val - min) / (max - min)
                        Fill.Size = UDim2.new(percent, 0, 1, 0)
                        ValueLabel.Text = tostring(val) .. suffix
                        Mantis.Flags[flag] = val
                        pcall(callback, val)
                    end
                }
            end

            GroupObj.AddSlider = GroupObj.Slider
            GroupObj.slider = GroupObj.Slider

            -- TEXTBOX / INPUT CONTROL (Squared)
            function GroupObj:Textbox(options)
                local flag = type(options) == "table" and (options.Flag or options.Name) or options
                local name = type(options) == "table" and (options.Name or options.Text or flag) or options
                local default = type(options) == "table" and options.Default or ""
                local placeholder = type(options) == "table" and options.Placeholder or "..."
                local callback = type(options) == "table" and options.Callback or function() end

                Mantis.Flags[flag] = default

                local InputFrame = Instance.new("Frame")
                InputFrame.Size = UDim2.new(1, 0, 0, 42)
                InputFrame.BackgroundTransparency = 1
                InputFrame.Parent = containerFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.BackgroundTransparency = 1
                Label.Text = name
                Label.TextColor3 = Mantis.Theme.Text
                Label.TextSize = 12
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = InputFrame

                local BoxContainer = Instance.new("Frame")
                BoxContainer.Size = UDim2.new(1, 0, 0, 22)
                BoxContainer.Position = UDim2.new(0, 0, 0, 18)
                BoxContainer.BackgroundColor3 = Mantis.Theme.Element
                BoxContainer.BorderSizePixel = 0
                BoxContainer.Parent = InputFrame

                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Mantis.Theme.Border
                BoxStroke.Thickness = 1
                BoxStroke.Parent = BoxContainer

                local TextBox = Instance.new("TextBox")
                TextBox.Size = UDim2.new(1, -10, 1, 0)
                TextBox.Position = UDim2.new(0, 5, 0, 0)
                TextBox.BackgroundTransparency = 1
                TextBox.Text = default
                TextBox.PlaceholderText = placeholder
                TextBox.TextColor3 = Mantis.Theme.Text
                TextBox.PlaceholderColor3 = Mantis.Theme.TextDark
                TextBox.TextSize = 11
                TextBox.Font = Enum.Font.Gotham
                TextBox.TextXAlignment = Enum.TextXAlignment.Left
                TextBox.ClearTextOnFocus = false
                TextBox.Parent = BoxContainer

                TextBox.Focused:Connect(function()
                    BoxStroke.Color = Mantis.Theme.Accent
                end)

                TextBox.FocusLost:Connect(function()
                    BoxStroke.Color = Mantis.Theme.Border
                    Mantis.Flags[flag] = TextBox.Text
                    pcall(callback, TextBox.Text)
                end)

                return {
                    Set = function(self, val)
                        TextBox.Text = val
                        Mantis.Flags[flag] = val
                        pcall(callback, val)
                    end
                }
            end

            GroupObj.AddTextbox = GroupObj.Textbox
            GroupObj.textbox = GroupObj.Textbox
            GroupObj.Input = GroupObj.Textbox
            GroupObj.AddInput = GroupObj.Textbox
            GroupObj.input = GroupObj.Textbox

            -- DROPDOWN CONTROL (Single & Multi, Squared)
            function GroupObj:Dropdown(options)
                local flag = type(options) == "table" and (options.Flag or options.Name) or options
                local name = type(options) == "table" and (options.Name or options.Text or flag) or options
                local items = type(options) == "table" and (options.Items or options.Values) or {}
                local default = type(options) == "table" and options.Default or nil
                local isMulti = type(options) == "table" and options.Multi or false
                local callback = type(options) == "table" and options.Callback or function() end

                local selected = isMulti and {} or default or items[1]
                if isMulti and type(default) == "table" then selected = default end

                Mantis.Flags[flag] = selected

                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, 0, 0, 42)
                DropFrame.BackgroundTransparency = 1
                DropFrame.Parent = containerFrame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.BackgroundTransparency = 1
                Label.Text = name
                Label.TextColor3 = Mantis.Theme.Text
                Label.TextSize = 12
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = DropFrame

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1, 0, 0, 22)
                DropBtn.Position = UDim2.new(0, 0, 0, 18)
                DropBtn.BackgroundColor3 = Mantis.Theme.Element
                DropBtn.Text = ""
                DropBtn.AutoButtonColor = false
                DropBtn.BorderSizePixel = 0
                DropBtn.Parent = DropFrame

                local DropStroke = Instance.new("UIStroke")
                DropStroke.Color = Mantis.Theme.Border
                DropStroke.Thickness = 1
                DropStroke.Parent = DropBtn

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(1, -22, 1, 0)
                ValLabel.Position = UDim2.new(0, 6, 0, 0)
                ValLabel.BackgroundTransparency = 1
                ValLabel.TextColor3 = Mantis.Theme.Text
                ValLabel.TextSize = 11
                ValLabel.Font = Enum.Font.Gotham
                ValLabel.TextXAlignment = Enum.TextXAlignment.Left
                ValLabel.Parent = DropBtn

                local Arrow = Instance.new("TextLabel")
                Arrow.Size = UDim2.new(0, 18, 1, 0)
                Arrow.Position = UDim2.new(1, -18, 0, 0)
                Arrow.BackgroundTransparency = 1
                Arrow.Text = "▼"
                Arrow.TextColor3 = Mantis.Theme.TextDark
                Arrow.TextSize = 9
                Arrow.Font = Enum.Font.GothamBold
                Arrow.Parent = DropBtn

                local Menu = Instance.new("ScrollingFrame")
                Menu.Size = UDim2.new(1, 0, 0, 95)
                Menu.Position = UDim2.new(0, 0, 1, 2)
                Menu.BackgroundColor3 = Mantis.Theme.Container
                Menu.BorderSizePixel = 0
                Menu.Visible = false
                Menu.ZIndex = 20
                Menu.ScrollBarThickness = 2
                Menu.ScrollBarImageColor3 = Mantis.Theme.Accent
                Menu.Parent = DropBtn

                local MenuStroke = Instance.new("UIStroke")
                MenuStroke.Color = Mantis.Theme.Accent
                MenuStroke.Thickness = 1
                MenuStroke.Parent = Menu

                local MenuLayout = Instance.new("UIListLayout")
                MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
                MenuLayout.Padding = UDim.new(0, 2)
                MenuLayout.Parent = Menu

                local function FormatValue()
                    if isMulti then
                        local active = {}
                        for k, v in pairs(selected) do
                            if v then table.insert(active, k) end
                        end
                        return #active > 0 and table.concat(active, ", ") or "None"
                    else
                        return tostring(selected)
                    end
                end

                ValLabel.Text = FormatValue()

                local function PopulateItems(itemTable)
                    for _, child in ipairs(Menu:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, item in ipairs(itemTable) do
                        local ItemBtn = Instance.new("TextButton")
                        ItemBtn.Size = UDim2.new(1, -4, 0, 20)
                        ItemBtn.BackgroundColor3 = Mantis.Theme.Element
                        ItemBtn.Text = "  " .. tostring(item)
                        ItemBtn.TextColor3 = Mantis.Theme.Text
                        ItemBtn.TextSize = 11
                        ItemBtn.Font = Enum.Font.Gotham
                        ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
                        ItemBtn.ZIndex = 21
                        ItemBtn.BorderSizePixel = 0
                        ItemBtn.Parent = Menu

                        ItemBtn.MouseButton1Click:Connect(function()
                            if isMulti then
                                selected[item] = not selected[item]
                                ItemBtn.TextColor3 = selected[item] and Mantis.Theme.Accent or Mantis.Theme.Text
                            else
                                selected = item
                                Menu.Visible = false
                                Arrow.Text = "▼"
                            end
                            ValLabel.Text = FormatValue()
                            Mantis.Flags[flag] = selected
                            pcall(callback, selected)
                        end)
                    end
                    Menu.CanvasSize = UDim2.new(0, 0, 0, #itemTable * 22)
                end

                PopulateItems(items)

                DropBtn.MouseButton1Click:Connect(function()
                    Menu.Visible = not Menu.Visible
                    Arrow.Text = Menu.Visible and "▲" or "▼"
                end)

                return {
                    Set = function(self, val)
                        selected = val
                        ValLabel.Text = FormatValue()
                        Mantis.Flags[flag] = selected
                        pcall(callback, selected)
                    end,
                    Refresh = function(self, newList)
                        PopulateItems(newList)
                    end
                }
            end

            GroupObj.AddDropdown = GroupObj.Dropdown
            GroupObj.dropdown = GroupObj.Dropdown
            GroupObj.Searchbox = GroupObj.Dropdown
            GroupObj.AddSearchbox = GroupObj.Dropdown
            GroupObj.MultiDropdown = function(self, opt)
                if type(opt) == "table" then opt.Multi = true end
                return GroupObj:Dropdown(opt)
            end
            GroupObj.AddMultiDropdown = GroupObj.MultiDropdown

            return GroupObj
        end

        function TabObj:Section(options)
            local title = type(options) == "table" and (options.Name or options.Title) or options
            local side = type(options) == "table" and options.Side or "Left"
            local parentCol = side == "Right" and RightCol or LeftCol

            local frame, content = CreateGroupboxContainer(parentCol, title)
            return BuildControlsApi(content)
        end

        function TabObj:SubPage(options)
            return TabObj:Section(options)
        end

        function TabObj:AddLeftGroupbox(title)
            return TabObj:Section({Name = title, Side = "Left"})
        end

        function TabObj:AddRightGroupbox(title)
            return TabObj:Section({Name = title, Side = "Right"})
        end

        function TabObj:AddTabbox(side)
            side = side or "Left"
            local parentCol = side == "Right" and RightCol or LeftCol

            local TabboxFrame = Instance.new("Frame")
            TabboxFrame.Name = "Tabbox"
            TabboxFrame.Size = UDim2.new(1, 0, 0, 40)
            TabboxFrame.BackgroundColor3 = Mantis.Theme.Container
            TabboxFrame.BorderSizePixel = 0
            TabboxFrame.Parent = parentCol

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = Mantis.Theme.Border
            BoxStroke.Thickness = 1
            BoxStroke.Parent = TabboxFrame

            local TabboxHeader = Instance.new("Frame")
            TabboxHeader.Size = UDim2.new(1, 0, 0, 24)
            TabboxHeader.BackgroundColor3 = Mantis.Theme.ContainerHeader
            TabboxHeader.BorderSizePixel = 0
            TabboxHeader.Parent = TabboxFrame

            local SubTabList = Instance.new("UIListLayout")
            SubTabList.FillDirection = Enum.FillDirection.Horizontal
            SubTabList.SortOrder = Enum.SortOrder.LayoutOrder
            SubTabList.Parent = TabboxHeader

            local TabboxContent = Instance.new("Frame")
            TabboxContent.Size = UDim2.new(1, -16, 1, -30)
            TabboxContent.Position = UDim2.new(0, 8, 0, 28)
            TabboxContent.BackgroundTransparency = 1
            TabboxContent.Parent = TabboxFrame

            local TabboxObj = {
                SubTabs = {}
            }

            function TabboxObj:AddTab(subTitle)
                local subName = type(subTitle) == "table" and (subTitle.Name or subTitle.Title) or subTitle

                local SubTabBtn = Instance.new("TextButton")
                SubTabBtn.Size = UDim2.new(0, 75, 1, 0)
                SubTabBtn.BackgroundColor3 = Mantis.Theme.ContainerHeader
                SubTabBtn.Text = subName
                SubTabBtn.TextColor3 = Mantis.Theme.TextDark
                SubTabBtn.TextSize = 11
                SubTabBtn.Font = Enum.Font.GothamMedium
                SubTabBtn.AutoButtonColor = false
                SubTabBtn.BorderSizePixel = 0
                SubTabBtn.Parent = TabboxHeader

                local SubContent = Instance.new("Frame")
                SubContent.Size = UDim2.new(1, 0, 1, 0)
                SubContent.BackgroundTransparency = 1
                SubContent.Visible = false
                SubContent.Parent = TabboxContent

                local ContentLayout = Instance.new("UIListLayout")
                ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ContentLayout.Padding = UDim.new(0, 6)
                ContentLayout.Parent = SubContent

                ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if SubContent.Visible then
                        TabboxFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 34)
                    end
                end)

                local controlsApi = BuildControlsApi(SubContent)

                local function SelectSubTab()
                    for _, st in ipairs(TabboxObj.SubTabs) do
                        st.Content.Visible = false
                        st.Button.TextColor3 = Mantis.Theme.TextDark
                    end
                    SubContent.Visible = true
                    SubTabBtn.TextColor3 = Mantis.Theme.Accent
                    TabboxFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 34)
                end

                SubTabBtn.MouseButton1Click:Connect(SelectSubTab)

                table.insert(TabboxObj.SubTabs, {
                    Button = SubTabBtn,
                    Content = SubContent
                })

                if #TabboxObj.SubTabs == 1 then
                    SelectSubTab()
                end

                return controlsApi
            end

            TabboxObj.Tab = TabboxObj.AddTab
            return TabboxObj
        end

        function TabObj:AddLeftTabbox()
            return TabObj:AddTabbox("Left")
        end

        function TabObj:AddRightTabbox()
            return TabObj:AddTabbox("Right")
        end

        TabObj.LeftGroupbox = TabObj.AddLeftGroupbox
        TabObj.RightGroupbox = TabObj.AddRightGroupbox
        TabObj.Tabbox = TabObj.AddTabbox

        return TabObj
    end

    Window.Tab = Window.AddTab
    Window.Page = Window.AddTab

    return Window
end

Mantis.Window = Mantis.CreateWindow

------------------------------------------------------------------------
-- NOTIFICATION SYSTEM
------------------------------------------------------------------------
function Mantis:Notify(title, text, duration)
    duration = duration or 4
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 220, 0, 46)
    NotifFrame.Position = UDim2.new(1, 20, 1, -65)
    NotifFrame.BackgroundColor3 = Mantis.Theme.Container
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = ScreenGui

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Mantis.Theme.Accent
    Stroke.Thickness = 1
    Stroke.Parent = NotifFrame

    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -16, 0, 18)
    NTitle.Position = UDim2.new(0, 8, 0, 4)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = Mantis.Theme.Accent
    NTitle.TextSize = 12
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = NotifFrame

    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -16, 0, 18)
    NText.Position = UDim2.new(0, 8, 0, 22)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Mantis.Theme.Text
    NText.TextSize = 11
    NText.Font = Enum.Font.Gotham
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = NotifFrame

    Tween(NotifFrame, {Position = UDim2.new(1, -240, 1, -65)})

    task.delay(duration, function()
        local tw = Tween(NotifFrame, {Position = UDim2.new(1, 20, 1, -65)})
        tw.Completed:Connect(function()
            NotifFrame:Destroy()
        end)
    end)
end

function Mantis:Notification(text, duration)
    Mantis:Notify("mantis.dev", text, duration)
end

function Mantis:Unload()
    if ScreenGui then ScreenGui:Destroy() end
    getgenv().Mantis = nil
end

getgenv().Mantis = Mantis
return Mantis
