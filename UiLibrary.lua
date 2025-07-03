-- Compact OwlHub-Style GUI with Console, Uptime & Reactive Design
-- Place this in StarterPlayer > StarterPlayerScripts or auto-execute

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Enhanced OwlHub UI Library
local UiLibrary = {}

-- Compact Theme Configuration
local Theme = {
    Background = Color3.fromRGB(12, 12, 16),
    Secondary = Color3.fromRGB(18, 18, 24),
    Accent = Color3.fromRGB(25, 25, 32),
    Primary = Color3.fromRGB(88, 101, 242),
    PrimaryHover = Color3.fromRGB(98, 111, 252),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 170),
    TextMuted = Color3.fromRGB(100, 100, 110),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Border = Color3.fromRGB(35, 35, 45),
    Console = Color3.fromRGB(8, 8, 12)
}

-- Animation Settings
local Anim = {
    Speed = 0.2,
    Style = Enum.EasingStyle.Quart,
    Direction = Enum.EasingDirection.Out
}

-- Global Variables
local StartTime = tick()
local ConsoleLines = {}
local MaxConsoleLines = 50

-- Utility Functions
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1 or Theme.Primary),
        ColorSequenceKeypoint.new(1, color2 or Color3.fromRGB(139, 69, 255))
    }
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

local function AddHover(element, hoverColor, normalColor)
    local normal = normalColor or element.BackgroundColor3
    local hover = hoverColor or Theme.PrimaryHover
    
    element.MouseEnter:Connect(function()
        TweenService:Create(element, TweenInfo.new(0.1, Anim.Style), {
            BackgroundColor3 = hover
        }):Play()
    end)
    
    element.MouseLeave:Connect(function()
        TweenService:Create(element, TweenInfo.new(0.1, Anim.Style), {
            BackgroundColor3 = normal
        }):Play()
    end)
end

local function AddRipple(element)
    element.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.BorderSizePixel = 0
        ripple.Parent = element
        CreateCorner(ripple, 50)
        
        local size = math.max(element.AbsoluteSize.X, element.AbsoluteSize.Y)
        TweenService:Create(ripple, TweenInfo.new(0.4, Anim.Style), {
            Size = UDim2.new(0, size, 0, size),
            BackgroundTransparency = 1
        }):Play()
        
        game:GetService("Debris"):AddItem(ripple, 0.4)
    end)
end

-- Console Functions
function UiLibrary.Log(message, messageType)
    local timestamp = os.date("[%H:%M:%S]")
    local color = Theme.Text
    local prefix = "INFO"
    
    if messageType == "success" then
        color = Theme.Success
        prefix = "SUCCESS"
    elseif messageType == "warning" then
        color = Theme.Warning
        prefix = "WARNING"
    elseif messageType == "error" then
        color = Theme.Error
        prefix = "ERROR"
    end
    
    local logEntry = {
        text = timestamp .. " [" .. prefix .. "] " .. tostring(message),
        color = color,
        time = tick()
    }
    
    table.insert(ConsoleLines, logEntry)
    
    if #ConsoleLines > MaxConsoleLines then
        table.remove(ConsoleLines, 1)
    end
    
    -- Update console if it exists
    if UiLibrary.ConsoleFrame then
        UiLibrary.UpdateConsole()
    end
end

function UiLibrary.UpdateConsole()
    if not UiLibrary.ConsoleFrame then return end
    
    for i, child in pairs(UiLibrary.ConsoleFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    for i, entry in pairs(ConsoleLines) do
        local line = Instance.new("TextLabel")
        line.Size = UDim2.new(1, -10, 0, 16)
        line.Position = UDim2.new(0, 5, 0, (i-1) * 16)
        line.BackgroundTransparency = 1
        line.Text = entry.text
        line.TextColor3 = entry.color
        line.TextSize = 10
        line.Font = Enum.Font.RobotoMono
        line.TextXAlignment = Enum.TextXAlignment.Left
        line.TextYAlignment = Enum.TextYAlignment.Top
        line.Parent = UiLibrary.ConsoleFrame
    end
    
    UiLibrary.ConsoleFrame.CanvasSize = UDim2.new(0, 0, 0, #ConsoleLines * 16)
    UiLibrary.ConsoleFrame.CanvasPosition = Vector2.new(0, UiLibrary.ConsoleFrame.CanvasSize.Y.Offset)
end

-- Uptime Function
local function GetUptime()
    local elapsed = tick() - StartTime
    local hours = math.floor(elapsed / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = math.floor(elapsed % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

-- Main Window Class
local Window = {}
Window.__index = Window

function UiLibrary.CreateWindow(title, size)
    local self = setmetatable({}, Window)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "OwlHub_" .. HttpService:GenerateGUID(false):sub(1, 6)
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = PlayerGui
    
    -- Main Frame (Compact Size)
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = size or UDim2.new(0, 420, 0, 320)
    self.MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
    self.MainFrame.BackgroundColor3 = Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui
    CreateCorner(self.MainFrame, 12)
    
    -- Gradient Background
    CreateGradient(self.MainFrame, Theme.Background, Theme.Secondary, 135)
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 35)
    self.TitleBar.BackgroundColor3 = Theme.Secondary
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    CreateCorner(self.TitleBar, 12)
    
    -- Title Bar Gradient
    local titleGradient = CreateGradient(self.TitleBar, Theme.Primary, Color3.fromRGB(139, 69, 255), 90)
    titleGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 0.9)
    }
    
    -- Logo
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 30, 0, 25)
    logo.Position = UDim2.new(0, 8, 0, 5)
    logo.BackgroundTransparency = 1
    logo.Text = "🦉"
    logo.TextColor3 = Theme.Text
    logo.TextSize = 16
    logo.Font = Enum.Font.GothamBold
    logo.Parent = self.TitleBar
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(0, 150, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 40, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = title or "OwlHub"
    self.TitleLabel.TextColor3 = Theme.Text
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    
    -- Uptime Display
    self.UptimeLabel = Instance.new("TextLabel")
    self.UptimeLabel.Size = UDim2.new(0, 80, 1, 0)
    self.UptimeLabel.Position = UDim2.new(1, -150, 0, 0)
    self.UptimeLabel.BackgroundTransparency = 1
    self.UptimeLabel.Text = "⏱ " .. GetUptime()
    self.UptimeLabel.TextColor3 = Theme.TextSecondary
    self.UptimeLabel.TextSize = 10
    self.UptimeLabel.Font = Enum.Font.Gotham
    self.UptimeLabel.Parent = self.TitleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundColor3 = Theme.Error
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Theme.Text
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = self.TitleBar
    CreateCorner(closeBtn, 6)
    AddHover(closeBtn, Color3.fromRGB(255, 80, 80))
    AddRipple(closeBtn)
    
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(self.MainFrame, TweenInfo.new(Anim.Speed, Anim.Style), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        wait(Anim.Speed)
        self.ScreenGui:Destroy()
    end)
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, -10, 0, 30)
    self.TabContainer.Position = UDim2.new(0, 5, 0, 40)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = self.TabContainer
    
    -- Content Frame
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Size = UDim2.new(1, -10, 1, -140)
    self.ContentFrame.Position = UDim2.new(0, 5, 0, 75)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.Parent = self.MainFrame
    
    -- Console Frame
    self.ConsoleContainer = Instance.new("Frame")
    self.ConsoleContainer.Size = UDim2.new(1, -10, 0, 60)
    self.ConsoleContainer.Position = UDim2.new(0, 5, 1, -65)
    self.ConsoleContainer.BackgroundColor3 = Theme.Console
    self.ConsoleContainer.BorderSizePixel = 0
    self.ConsoleContainer.Parent = self.MainFrame
    CreateCorner(self.ConsoleContainer, 8)
    
    local consoleTitle = Instance.new("TextLabel")
    consoleTitle.Size = UDim2.new(1, -10, 0, 15)
    consoleTitle.Position = UDim2.new(0, 5, 0, 2)
    consoleTitle.BackgroundTransparency = 1
    consoleTitle.Text = "📟 Console"
    consoleTitle.TextColor3 = Theme.TextSecondary
    consoleTitle.TextSize = 10
    consoleTitle.Font = Enum.Font.GothamBold
    consoleTitle.TextXAlignment = Enum.TextXAlignment.Left
    consoleTitle.Parent = self.ConsoleContainer
    
    UiLibrary.ConsoleFrame = Instance.new("ScrollingFrame")
    UiLibrary.ConsoleFrame.Size = UDim2.new(1, -10, 1, -20)
    UiLibrary.ConsoleFrame.Position = UDim2.new(0, 5, 0, 17)
    UiLibrary.ConsoleFrame.BackgroundTransparency = 1
    UiLibrary.ConsoleFrame.BorderSizePixel = 0
    UiLibrary.ConsoleFrame.ScrollBarThickness = 3
    UiLibrary.ConsoleFrame.ScrollBarImageColor3 = Theme.Primary
    UiLibrary.ConsoleFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    UiLibrary.ConsoleFrame.Parent = self.ConsoleContainer
    
    -- Dragging
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Update uptime every second
    spawn(function()
        while self.ScreenGui.Parent do
            self.UptimeLabel.Text = "⏱ " .. GetUptime()
            wait(1)
        end
    end)
    
    -- Entrance animation
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(self.MainFrame, TweenInfo.new(Anim.Speed * 2, Enum.EasingStyle.Back), {
        Size = size or UDim2.new(0, 420, 0, 320)
    }):Play()
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Initial console message
    UiLibrary.Log("OwlHub initialized successfully", "success")
    
    return self
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Window:CreateTab(name, icon)
    local tab = setmetatable({}, Tab)
    
    -- Tab Button
    tab.TabButton = Instance.new("TextButton")
    tab.TabButton.Size = UDim2.new(0, 80, 1, 0)
    tab.TabButton.BackgroundColor3 = Theme.Accent
    tab.TabButton.BorderSizePixel = 0
    tab.TabButton.Text = (icon or "📄") .. " " .. name
    tab.TabButton.TextColor3 = Theme.TextSecondary
    tab.TabButton.TextSize = 10
    tab.TabButton.Font = Enum.Font.Gotham
    tab.TabButton.Parent = self.TabContainer
    CreateCorner(tab.TabButton, 6)
    AddRipple(tab.TabButton)
    
    -- Tab Content
    tab.TabContent = Instance.new("ScrollingFrame")
    tab.TabContent.Size = UDim2.new(1, 0, 1, 0)
    tab.TabContent.BackgroundTransparency = 1
    tab.TabContent.BorderSizePixel = 0
    tab.TabContent.ScrollBarThickness = 4
    tab.TabContent.ScrollBarImageColor3 = Theme.Primary
    tab.TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.TabContent.Visible = false
    tab.TabContent.Parent = self.ContentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = tab.TabContent
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.TabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Tab switching
    tab.TabButton.MouseButton1Click:Connect(function()
        for _, existingTab in pairs(self.Tabs) do
            existingTab.TabContent.Visible = false
            existingTab.TabButton.BackgroundColor3 = Theme.Accent
            existingTab.TabButton.TextColor3 = Theme.TextSecondary
        end
        
        tab.TabContent.Visible = true
        tab.TabButton.BackgroundColor3 = Theme.Primary
        tab.TabButton.TextColor3 = Theme.Text
        
        -- Slide animation
        tab.TabContent.Position = UDim2.new(0, 10, 0, 0)
        TweenService:Create(tab.TabContent, TweenInfo.new(Anim.Speed, Anim.Style), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        self.CurrentTab = tab
        UiLibrary.Log("Switched to " .. name .. " tab")
    end)
    
    table.insert(self.Tabs, tab)
    
    -- First tab active
    if #self.Tabs == 1 then
        tab.TabContent.Visible = true
        tab.TabButton.BackgroundColor3 = Theme.Primary
        tab.TabButton.TextColor3 = Theme.Text
        self.CurrentTab = tab
    end
    
    return tab
end

-- UI Elements
function Tab:CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 30)
    btn.BackgroundColor3 = Theme.Primary
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = self.TabContent
    CreateCorner(btn, 6)
    CreateGradient(btn)
    AddHover(btn)
    AddRipple(btn)
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
        UiLibrary.Log("Button clicked: " .. text)
    end)
    
    return btn
end

function Tab:CreateToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 35)
    frame.BackgroundColor3 = Theme.Secondary
    frame.BorderSizePixel = 0
    frame.Parent = self.TabContent
    CreateCorner(frame, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 18)
    toggle.Position = UDim2.new(1, -45, 0.5, -9)
    toggle.BackgroundColor3 = default and Theme.Success or Theme.Accent
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = frame
    CreateCorner(toggle, 9)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    CreateCorner(knob, 7)
    
    local state = default or false
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        
        TweenService:Create(toggle, TweenInfo.new(0.2, Anim.Style), {
            BackgroundColor3 = state and Theme.Success or Theme.Accent
        }):Play()
        
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        
        if callback then callback(state) end
        UiLibrary.Log("Toggle " .. text .. ": " .. tostring(state))
    end)
    
    return {
        Set = function(newState)
            state = newState
            toggle.BackgroundColor3 = state and Theme.Success or Theme.Accent
            knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        end
    }
end

function Tab:CreateSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 45)
    frame.BackgroundColor3 = Theme.Secondary
    frame.BorderSizePixel = 0
    frame.Parent = self.TabContent
    CreateCorner(frame, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. (default or min)
    label.TextColor3 = Theme.Text
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 4)
    track.Position = UDim2.new(0, 10, 1, -15)
    track.BackgroundColor3 = Theme.Accent
    track.BorderSizePixel = 0
    track.Parent = frame
    CreateCorner(track, 2)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default or min) / max, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    CreateCorner(fill, 2)
    CreateGradient(fill)
    
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((default or min) / max, -6, 0.5, -6)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.Parent = track
    CreateCorner(knob, 6)
    
    local dragging = false
    local currentValue = default or min
    
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local trackPos = track.AbsolutePosition.X
            local trackSize = track.AbsoluteSize.X
            local percentage = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            
            currentValue = math.floor(min + (max - min) * percentage)
            
            fill.Size = UDim2.new(percentage, 0, 1, 0)
            knob.Position = UDim2.new(percentage, -6, 0.5, -6)
            label.Text = text .. ": " .. currentValue
            
            if callback then callback(currentValue) end
        end
    end)
    
    return {
        Set = function(value)
            currentValue = math.clamp(value, min, max)
            local percentage = (currentValue - min) / (max - min)
            fill.Size = UDim2.new(percentage, 0, 1, 0)
            knob.Position = UDim2.new(percentage, -6, 0.5, -6)
            label.Text = text .. ": " .. currentValue
        end
    }
end

function Tab:CreateInput(placeholder, callback)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -5, 0, 30)
    input.BackgroundColor3 = Theme.Secondary
    input.BorderSizePixel = 0
    input.PlaceholderText = placeholder
    input.Text = ""
    input.TextColor3 = Theme.Text
    input.PlaceholderColor3 = Theme.TextMuted
    input.TextSize = 11
    input.Font = Enum.Font.Gotham
    input.Parent = self.TabContent
    CreateCorner(input, 6)
    
    input.Focused:Connect(function()
        TweenService:Create(input, TweenInfo.new(0.1, Anim.Style), {
            BackgroundColor3 = Theme.Accent
        }):Play()
    end)
    
    input.FocusLost:Connect(function()
        TweenService:Create(input, TweenInfo.new(0.1, Anim.Style), {
            BackgroundColor3 = Theme.Secondary
        }):Play()
        if callback then callback(input.Text) end
        UiLibrary.Log("Input: " .. input.Text)
    end)
    
    return input
end

function Tab:CreateLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -5, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextSecondary
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = self.TabContent
    
    return label
end

-- Initialize
UiLibrary.Log("OwlHub UI Library loaded", "success")

return UiLibrary