-- Enhanced OwlHub-Style GUI System with Advanced Animations
-- Place this in StarterPlayer > StarterPlayerScripts or auto-execute

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()

-- Enhanced OwlHub UI Library
local UiLibrary = {}

-- Theme Configuration (OwlHub Style)
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Secondary = Color3.fromRGB(20, 20, 28),
    Accent = Color3.fromRGB(35, 35, 45),
    Primary = Color3.fromRGB(88, 101, 242),
    PrimaryHover = Color3.fromRGB(98, 111, 252),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(170, 170, 180),
    TextMuted = Color3.fromRGB(120, 120, 130),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Border = Color3.fromRGB(45, 45, 55),
    Shadow = Color3.fromRGB(0, 0, 0),
    Gradient1 = Color3.fromRGB(88, 101, 242),
    Gradient2 = Color3.fromRGB(139, 69, 255)
}

-- Enhanced Animation Settings
local AnimationSpeed = {
    Fast = 0.15,
    Normal = 0.25,
    Slow = 0.4,
    Hover = 0.1
}

local EasingStyles = {
    Smooth = Enum.EasingStyle.Quart,
    Bounce = Enum.EasingStyle.Back,
    Elastic = Enum.EasingStyle.Elastic,
    Sharp = Enum.EasingStyle.Quad
}

local EasingDirection = Enum.EasingDirection.Out

-- Utility Functions
function UiLibrary.ChangeTheme(newTheme)
    for key, value in pairs(newTheme) do
        if Theme[key] then
            Theme[key] = value
        end
    end
end

function UiLibrary.CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1 or Theme.Gradient1),
        ColorSequenceKeypoint.new(1, color2 or Theme.Gradient2)
    }
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

function UiLibrary.CreateShadow(parent, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = size or UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Theme.Shadow
    shadow.ImageTransparency = transparency or 0.8
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent.Parent
    return shadow
end

function UiLibrary.AddHoverEffect(element, hoverColor, normalColor)
    local normalColor = normalColor or element.BackgroundColor3
    local hoverColor = hoverColor or Theme.PrimaryHover
    
    element.MouseEnter:Connect(function()
        TweenService:Create(element, TweenInfo.new(AnimationSpeed.Hover, EasingStyles.Smooth), {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    
    element.MouseLeave:Connect(function()
        TweenService:Create(element, TweenInfo.new(AnimationSpeed.Hover, EasingStyles.Smooth), {
            BackgroundColor3 = normalColor
        }):Play()
    end)
end

function UiLibrary.AddRippleEffect(element)
    element.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.BorderSizePixel = 0
        ripple.Parent = element
        
        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        local maxSize = math.max(element.AbsoluteSize.X, element.AbsoluteSize.Y) * 2
        
        TweenService:Create(ripple, TweenInfo.new(0.5, EasingStyles.Smooth), {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            BackgroundTransparency = 1
        }):Play()
        
        game:GetService("Debris"):AddItem(ripple, 0.5)
    end)
end

function UiLibrary.AddDraggingFunctionality(frame, dragHandle)
    local dragHandle = dragHandle or frame
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            
            TweenService:Create(frame, TweenInfo.new(0.05, EasingStyles.Sharp), {
                Position = newPos
            }):Play()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Enhanced Notification System
function UiLibrary.Notify(title, message, duration, notificationType)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "OwlHubNotification"
    notificationGui.Parent = PlayerGui
    
    local notification = Instance.new("Frame")
    notification.Name = "NotificationFrame"
    notification.Size = UDim2.new(0, 350, 0, 90)
    notification.Position = UDim2.new(1, 20, 0, 20)
    notification.BackgroundColor3 = Theme.Secondary
    notification.BorderSizePixel = 0
    notification.Parent = notificationGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notification
    
    local shadow = UiLibrary.CreateShadow(notification, UDim2.new(1, 30, 1, 30), 0.6)
    
    local gradient = UiLibrary.CreateGradient(notification)
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(1, 0.98)
    }
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 50, 1, 0)
    iconFrame.BackgroundTransparency = 1
    iconFrame.Parent = notification
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = notificationType == "success" and "✓" or notificationType == "warning" and "⚠" or notificationType == "error" and "✗" or "ℹ"
    icon.TextColor3 = notificationType == "success" and Theme.Success or notificationType == "warning" and Theme.Warning or notificationType == "error" and Theme.Error or Theme.Primary
    icon.TextScaled = true
    icon.Font = Enum.Font.GothamBold
    icon.Parent = iconFrame
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -60, 1, -10)
    contentFrame.Position = UDim2.new(0, 55, 0, 5)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = contentFrame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, 0, 1, -30)
    messageLabel.Position = UDim2.new(0, 0, 0, 25)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Theme.TextSecondary
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = contentFrame
    
    -- Slide in animation
    TweenService:Create(notification, TweenInfo.new(AnimationSpeed.Normal, EasingStyles.Bounce), {
        Position = UDim2.new(1, -370, 0, 20)
    }):Play()
    
    -- Auto dismiss
    wait(duration or 4)
    TweenService:Create(notification, TweenInfo.new(AnimationSpeed.Fast, EasingStyles.Smooth), {
        Position = UDim2.new(1, 20, 0, 20),
        BackgroundTransparency = 1
    }):Play()
    
    wait(AnimationSpeed.Fast)
    notificationGui:Destroy()
end

-- Window Management
local Windows = {}

function UiLibrary.Hide()
    for _, window in pairs(Windows) do
        if window.Visible then
            TweenService:Create(window, TweenInfo.new(AnimationSpeed.Fast, EasingStyles.Smooth), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
        end
    end
end

function UiLibrary.Unhide()
    for _, window in pairs(Windows) do
        TweenService:Create(window, TweenInfo.new(AnimationSpeed.Normal, EasingStyles.Bounce), {
            Size = window.OriginalSize or UDim2.new(0, 600, 0, 450),
            BackgroundTransparency = 0
        }):Play()
    end
end

-- Enhanced Window Class
local Window = {}
Window.__index = Window

function UiLibrary.CreateWindow(title, size)
    local self = setmetatable({}, Window)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "OwlHub_" .. HttpService:GenerateGUID(false):sub(1, 8)
    self.ScreenGui.Parent = PlayerGui
    
    -- Main Frame with enhanced styling
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = size or UDim2.new(0, 600, 0, 450)
    self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    self.MainFrame.BackgroundColor3 = Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = self.MainFrame
    
    -- Enhanced shadow
    local shadow = UiLibrary.CreateShadow(self.MainFrame, UDim2.new(1, 40, 1, 40), 0.5)
    
    -- Gradient background
    local backgroundGradient = UiLibrary.CreateGradient(self.MainFrame)
    backgroundGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.3)
    }
    
    -- Enhanced Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 50)
    self.TitleBar.BackgroundColor3 = Theme.Secondary
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = self.TitleBar
    
    local titleGradient = UiLibrary.CreateGradient(self.TitleBar)
    titleGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 0.4)
    }
    
    -- OwlHub Logo/Icon
    local logoFrame = Instance.new("Frame")
    logoFrame.Size = UDim2.new(0, 40, 0, 40)
    logoFrame.Position = UDim2.new(0, 10, 0, 5)
    logoFrame.BackgroundColor3 = Theme.Primary
    logoFrame.BorderSizePixel = 0
    logoFrame.Parent = self.TitleBar
    
    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 8)
    logoCorner.Parent = logoFrame
    
    local logoGradient = UiLibrary.CreateGradient(logoFrame)
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 1, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "🦉"
    logo.TextColor3 = Theme.Text
    logo.TextScaled = true
    logo.Font = Enum.Font.GothamBold
    logo.Parent = logoFrame
    
    -- Enhanced Title Label
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "TitleLabel"
    self.TitleLabel.Size = UDim2.new(1, -200, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 60, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = title or "OwlHub"
    self.TitleLabel.TextColor3 = Theme.Text
    self.TitleLabel.TextScaled = true
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    
    -- Control Buttons
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 120, 0, 30)
    controlsFrame.Position = UDim2.new(1, -130, 0, 10)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = self.TitleBar
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.Padding = UDim.new(0, 5)
    controlsLayout.Parent = controlsFrame
    
    -- Minimize Button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.BackgroundColor3 = Theme.Warning
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = Theme.Text
    minimizeButton.TextScaled = true
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = controlsFrame
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimizeButton
    
    UiLibrary.AddHoverEffect(minimizeButton, Color3.fromRGB(255, 180, 40))
    UiLibrary.AddRippleEffect(minimizeButton)
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.BackgroundColor3 = Theme.Error
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Theme.Text
    self.CloseButton.TextScaled = true
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = controlsFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = self.CloseButton
    
    UiLibrary.AddHoverEffect(self.CloseButton, Color3.fromRGB(255, 80, 80))
    UiLibrary.AddRippleEffect(self.CloseButton)
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, -20, 0, 40)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 60)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = self.TabContainer
    
    -- Content Frame
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Size = UDim2.new(1, -20, 1, -120)
    self.ContentFrame.Position = UDim2.new(0, 10, 0, 110)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.Parent = self.MainFrame
    
    -- Add dragging functionality
    UiLibrary.AddDraggingFunctionality(self.MainFrame, self.TitleBar)
    
    -- Close button functionality
    self.CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(self.MainFrame, TweenInfo.new(AnimationSpeed.Fast, EasingStyles.Smooth), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        wait(AnimationSpeed.Fast)
        self.ScreenGui:Destroy()
    end)
    
    -- Minimize functionality
    minimizeButton.MouseButton1Click:Connect(function()
        local isMinimized = self.MainFrame.Size.Y.Offset <= 60
        if isMinimized then
            TweenService:Create(self.MainFrame, TweenInfo.new(AnimationSpeed.Normal, EasingStyles.Bounce), {
                Size = self.OriginalSize or UDim2.new(0, 600, 0, 450)
            }):Play()
        else
            self.OriginalSize = self.MainFrame.Size
            TweenService:Create(self.MainFrame, TweenInfo.new(AnimationSpeed.Normal, EasingStyles.Smooth), {
                Size = UDim2.new(self.MainFrame.Size.X.Scale, self.MainFrame.Size.X.Offset, 0, 60)
            }):Play()
        end
    end)
    
    -- Add to windows list
    table.insert(Windows, self.MainFrame)
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Entrance animation
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.MainFrame.BackgroundTransparency = 1
    TweenService:Create(self.MainFrame, TweenInfo.new(AnimationSpeed.Normal, EasingStyles.Bounce), {
        Size = size or UDim2.new(0, 600, 0, 450),
        BackgroundTransparency = 0
    }):Play()
    
    return self
end

-- Enhanced Tab Class
local Tab = {}
Tab.__index = Tab

function Window:CreateTab(name, icon)
    local tab = setmetatable({}, Tab)
    
    -- Tab Button
    tab.TabButton = Instance.new("TextButton")
    tab.TabButton.Name = "TabButton_" .. name
    tab.TabButton.Size = UDim2.new(0, 120, 1, 0)
    tab.TabButton.BackgroundColor3 = Theme.Accent
    tab.TabButton.BorderSizePixel = 0
    tab.TabButton.Text = (icon or "📄") .. " " .. name
    tab.TabButton.TextColor3 = Theme.TextSecondary
    tab.TabButton.TextScaled = true
    tab.TabButton.Font = Enum.Font.Gotham
    tab.TabButton.Parent = self.TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tab.TabButton
    
    UiLibrary.AddHoverEffect(tab.TabButton, Theme.Primary, Theme.Accent)
    UiLibrary.AddRippleEffect(tab.TabButton)
    
    -- Tab Content
    tab.TabContent = Instance.new("ScrollingFrame")
    tab.TabContent.Name = "TabContent_" .. name
    tab.TabContent.Size = UDim2.new(1, 0, 1, 0)
    tab.TabContent.BackgroundTransparency = 1
    tab.TabContent.BorderSizePixel = 0
    tab.TabContent.ScrollBarThickness = 6
    tab.TabContent.ScrollBarImageColor3 = Theme.Primary
    tab.TabContent.ScrollingDirection = Enum.ScrollingDirection.Y
    tab.TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.TabContent.Visible = false
    tab.TabContent.Parent = self.ContentFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = tab.TabContent
    
    -- Auto-resize canvas
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.TabContent.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab switching with animation
    tab.TabButton.MouseButton1Click:Connect(function()
        -- Hide all tabs
        for _, existingTab in pairs(self.Tabs) do
            existingTab.TabContent.Visible = false
            existingTab.TabButton.BackgroundColor3 = Theme.Accent
            existingTab.TabButton.TextColor3 = Theme.TextSecondary
        end
        
        -- Show current tab with animation
        tab.TabContent.Visible = true
        tab.TabButton.BackgroundColor3 = Theme.Primary
        tab.TabButton.TextColor3 = Theme.Text
        
        -- Slide animation
        tab.TabContent.Position = UDim2.new(0, 20, 0, 0)
        TweenService:Create(tab.TabContent, TweenInfo.new(AnimationSpeed.Fast, EasingStyles.Smooth), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        self.CurrentTab = tab
    end)
    
    -- Add to tabs list
    table.insert(self.Tabs, tab)
    
    -- If first tab, make it active
    if #self.Tabs == 1 then
        tab.TabContent.Visible = true
        tab.TabButton.BackgroundColor3 = Theme.Primary
        tab.TabButton.TextColor3 = Theme.Text
        self.CurrentTab = tab
    end
    
    return tab
end

-- Enhanced Button Class
local ButtonValue = {}
ButtonValue.__index = ButtonValue

function ButtonValue:Set(callback)
    self.Callback = callback
end

function Tab:CreateButton(text, callback)
    local button = setmetatable({}, ButtonValue)
    
    button.ButtonFrame = Instance.new("Frame")
    button.ButtonFrame.Name = "ButtonFrame"
    button.ButtonFrame.Size = UDim2.new(1, -10, 0, 40)
    button.ButtonFrame.BackgroundTransparency = 1
    button.ButtonFrame.Parent = self.TabContent
    
    button.Button = Instance.new("TextButton")
    button.Button.Name = "Button"
    button.Button.Size = UDim2.new(1, 0, 1, 0)
    button.Button.BackgroundColor3 = Theme.Primary
    button.Button.BorderSizePixel = 0
    button.Button.Text = text
    button.Button.TextColor3 = Theme.Text
    button.Button.TextScaled = true
    button.Button.Font = Enum.Font.GothamSemibold
    button.Button.Parent = button.ButtonFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button.Button
    
    local buttonGradient = UiLibrary.CreateGradient(button.Button)
    buttonGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.3)
    }
    
    UiLibrary.AddHoverEffect(button.Button, Theme.PrimaryHover, Theme.Primary)
    UiLibrary.AddRippleEffect(button.Button)
    
    button.Callback = callback
    
    button.Button.MouseButton1Click:Connect(function()
        if button.Callback then
            button.Callback()
        end
        
        -- Enhanced button press animation
        TweenService:Create(button.Button, TweenInfo.new(0.1, EasingStyles.Sharp), {
            Size = UDim2.new(0.98, 0, 0.9, 0)
        }):Play()
        
        wait(0.1)
        
        TweenService:Create(button.Button, TweenInfo.new(0.1, EasingStyles.Bounce), {
            Size = UDim2.new(1, 0, 1, 0)
        }):Play()
    end)
    
    return button
end

-- Enhanced Toggle Class
local ToggleValue = {}
ToggleValue.__index = ToggleValue

function ToggleValue:Set(state)
    self.State = state
    
    local targetColor = state and Theme.Success or Theme.Accent
    local knobPosition = state and UDim2.new(1, -22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    
    TweenService:Create(self.ToggleBackground, TweenInfo.new(AnimationSpeed.Fast, EasingStyles.Smooth), {
        BackgroundColor3 = targetColor
    }):Play()
    
    TweenService:Create(self.ToggleKnob, TweenInfo.new(AnimationSpeed.Fast, EasingStyles.Bounce), {
        Position = knobPosition
    }):Play()
    
    if self.Callback then
        self.Callback(state)
    end
end

function Tab:CreateToggle(text, defaultState, callback)
    local toggle = setmetatable({}, ToggleValue)
    
    toggle.ToggleFrame = Instance.new("Frame")
    toggle.ToggleFrame.Name = "ToggleFrame"
    toggle.ToggleFrame.Size = UDim2.new(1, -10, 0, 45)
    toggle.ToggleFrame.BackgroundColor3 = Theme.Secondary
    toggle.ToggleFrame.BorderSizePixel = 0
    toggle.ToggleFrame.Parent = self.TabContent
    
    local toggleFrameCorner = Instance.new("UICorner")
    toggleFrameCorner.CornerRadius = UDim.new(0, 10)
    toggleFrameCorner.Parent = toggle.ToggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle.ToggleFrame
    
    -- Enhanced toggle switch
    toggle.ToggleBackground = Instance.new("TextButton")
    toggle.ToggleBackground.Size = UDim2.new(0, 50, 0, 20)
    toggle.ToggleBackground.Position = UDim2.new(1, -65, 0.5, -10)
    toggle.ToggleBackground.BackgroundColor3 = defaultState and Theme.Success or Theme.Accent
    toggle.ToggleBackground.BorderSizePixel = 0
    toggle.ToggleBackground.Text = ""
    toggle.ToggleBackground.Parent = toggle.ToggleFrame
    
    local toggleBgCorner = Instance.new("UICorner")
    toggleBgCorner.CornerRadius = UDim.new(0, 10)
    toggleBgCorner.Parent = toggle.ToggleBackground
    
    toggle.ToggleKnob = Instance.new("Frame")
    toggle.ToggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggle.ToggleKnob.Position = defaultState and UDim2.new(1, -22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggle.ToggleKnob.BackgroundColor3 = Theme.Text
    toggle.ToggleKnob.BorderSizePixel = 0
    toggle.ToggleKnob.Parent = toggle.ToggleBackground
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 8)
    knobCorner.Parent = toggle.ToggleKnob
    
    toggle.State = defaultState or false
    toggle.Callback = callback
    
    toggle.ToggleBackground.MouseButton1Click:Connect(function()
        toggle.State = not toggle.State
        toggle:Set(toggle.State)
    end)
    
    UiLibrary.AddRippleEffect(toggle.ToggleBackground)
    
    return toggle
end

-- Enhanced Slider Class
function Tab:CreateSlider(text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderFrame"
    sliderFrame.Size = UDim2.new(1, -10, 0, 60)
    sliderFrame.BackgroundColor3 = Theme.Secondary
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = self.TabContent
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 10)
    sliderCorner.Parent = sliderFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. (default or min)
    label.TextColor3 = Theme.Text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -30, 0, 6)
    sliderTrack.Position = UDim2.new(0, 15, 1, -20)
    sliderTrack.BackgroundColor3 = Theme.Accent
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default or min) / max, 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    local fillGradient = UiLibrary.CreateGradient(sliderFill)
    
    local sliderKnob = Instance.new("TextButton")
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Position = UDim2.new((default or min) / max, -8, 0.5, -8)
    sliderKnob.BackgroundColor3 = Theme.Text
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Text = ""
    sliderKnob.Parent = sliderTrack
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 8)
    knobCorner.Parent = sliderKnob
    
    UiLibrary.AddHoverEffect(sliderKnob, Color3.fromRGB(240, 240, 240), Theme.Text)
    
    local dragging = false
    local currentValue = default or min
    
    sliderKnob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = sliderTrack.AbsolutePosition.X
            local sliderSize = sliderTrack.AbsoluteSize.X
            
            local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            currentValue = math.floor(min + (max - min) * percentage)
            
            TweenService:Create(sliderFill, TweenInfo.new(0.05, EasingStyles.Sharp), {
                Size = UDim2.new(percentage, 0, 1, 0)
            }):Play()
            
            TweenService:Create(sliderKnob, TweenInfo.new(0.05, EasingStyles.Sharp), {
                Position = UDim2.new(percentage, -8, 0.5, -8)
            }):Play()
            
            label.Text = text .. ": " .. currentValue
            
            if callback then
                callback(currentValue)
            end
        end
    end)
    
    return {
        Set = function(value)
            currentValue = math.clamp(value, min, max)
            local percentage = (currentValue - min) / (max - min)
            
            TweenService:Create(sliderFill, TweenInfo.new(AnimationSpeed.Fast, EasingStyles.Smooth), {
                Size = UDim2.new(percentage, 0, 1, 0)
            }):Play()
            
            TweenService:Create(sliderKnob, TweenInfo.new(AnimationSpeed.Fast, EasingStyles.Smooth), {
                Position = UDim2.new(percentage, -8, 0.5, -8)
            }):Play()
            
            label.Text = text .. ": " .. currentValue
            
            if callback then
                callback(currentValue)
            end
        end
    }
end

-- Enhanced Input Class
local InputSettings = {}
InputSettings.__index = InputSettings

function InputSettings:Set(text)
    self.TextBox.Text = text
end

function Tab:CreateInput(placeholder, callback)
    local input = setmetatable({}, InputSettings)
    
    input.InputFrame = Instance.new("Frame")
    input.InputFrame.Name = "InputFrame"
    input.InputFrame.Size = UDim2.new(1, -10, 0, 40)
    input.InputFrame.BackgroundColor3 = Theme.Secondary
    input.InputFrame.BorderSizePixel = 0
    input.InputFrame.Parent = self.TabContent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = input.InputFrame
    
    input.TextBox = Instance.new("TextBox")
    input.TextBox.Size = UDim2.new(1, -20, 1, 0)
    input.TextBox.Position = UDim2.new(0, 10, 0, 0)
    input.TextBox.BackgroundTransparency = 1
    input.TextBox.PlaceholderText = placeholder
    input.TextBox.Text = ""
    input.TextBox.TextColor3 = Theme.Text
    input.TextBox.PlaceholderColor3 = Theme.TextMuted
    input.TextBox.TextScaled = true
    input.TextBox.Font = Enum.Font.Gotham
    input.TextBox.TextXAlignment = Enum.TextXAlignment.Left
    input.TextBox.Parent = input.InputFrame
    
    -- Focus effects
    input.TextBox.Focused:Connect(function()
        TweenService:Create(input.InputFrame, TweenInfo.new(AnimationSpeed.Fast, EasingStyles.Smooth), {
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(1, -5, 0, 40)
        }):Play()
    end)
    
    input.TextBox.FocusLost:Connect(function()
        TweenService:Create(input.InputFrame, TweenInfo.new(AnimationSpeed.Fast, EasingStyles.Smooth), {
            BackgroundColor3 = Theme.Secondary,
            Size = UDim2.new(1, -10, 0, 40)
        }):Play()
        
        if callback then
            callback(input.TextBox.Text)
        end
    end)
    
    return input
end

-- Enhanced Section Class
local SectionValue = {}
SectionValue.__index = SectionValue

function SectionValue:Set(text)
    self.Label.Text = text
end

function Tab:CreateSection(text)
    local section = setmetatable({}, SectionValue)
    
    section.SectionFrame = Instance.new("Frame")
    section.SectionFrame.Name = "SectionFrame"
    section.SectionFrame.Size = UDim2.new(1, -10, 0, 35)
    section.SectionFrame.BackgroundColor3 = Theme.Accent
    section.SectionFrame.BorderSizePixel = 0
    section.SectionFrame.Parent = self.TabContent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 10)
    sectionCorner.Parent = section.SectionFrame
    
    local sectionGradient = UiLibrary.CreateGradient(section.SectionFrame)
    sectionGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 0.5)
    }
    
    section.Label = Instance.new("TextLabel")
    section.Label.Size = UDim2.new(1, -20, 1, 0)
    section.Label.Position = UDim2.new(0, 10, 0, 0)
    section.Label.BackgroundTransparency = 1
    section.Label.Text = "📋 " .. text
    section.Label.TextColor3 = Theme.Text
    section.Label.TextScaled = true
    section.Label.Font = Enum.Font.GothamBold
    section.Label.TextXAlignment = Enum.TextXAlignment.Left
    section.Label.Parent = section.SectionFrame
    
    return section
end

-- Enhanced Label Class
local LabelValue = {}
LabelValue.__index = LabelValue

function LabelValue:Set(text)
    self.Label.Text = text
end

function Tab:CreateLabel(text)
    local label = setmetatable({}, LabelValue)
    
    label.Label = Instance.new("TextLabel")
    label.Label.Name = "Label"
    label.Label.Size = UDim2.new(1, -10, 0, 30)
    label.Label.BackgroundTransparency = 1
    label.Label.Text = text
    label.Label.TextColor3 = Theme.TextSecondary
    label.Label.TextScaled = true
    label.Label.Font = Enum.Font.Gotham
    label.Label.TextXAlignment = Enum.TextXAlignment.Left
    label.Label.Parent = self.TabContent
    
    return label
end

-- Destroy function
function UiLibrary.Destroy()
    for _, window in pairs(Windows) do
        if window.Parent then
            window.Parent:Destroy()
        end
    end
    Windows = {}
end

-- Initialize with welcome notification
spawn(function()
    wait(0.5)
    UiLibrary.Notify("OwlHub Loaded", "Enhanced UI Library initialized successfully!", 3, "success")
end)

return UiLibrary