-- Compact OwlHub-Style GUI with Script Library & Enhanced UI
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
    Console = Color3.fromRGB(8, 8, 12),
    Script = Color3.fromRGB(139, 69, 255)
}

-- Animation Settings
local Anim = {
    Speed = 0.15,
    Style = Enum.EasingStyle.Quart,
    Direction = Enum.EasingDirection.Out
}

-- Global Variables
local StartTime = tick()
local ConsoleLines = {}
local MaxConsoleLines = 50

-- Script Library
local ScriptLibrary = {
    {
        name = "Infinite Yield",
        description = "Advanced admin commands",
        icon = "⚡",
        code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()'
    },
    {
        name = "Hydroxide",
        description = "Remote spy & debugging",
        icon = "🔍",
        code = [[local owner = "Upbolt"
local branch = "revision"

local function webImport(file)
    return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
end

webImport("init")
webImport("ui/main")]]
    }
}

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

-- Fixed Ripple Effect - No interference with button functionality
local function AddRipple(element)
    element.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.BorderSizePixel = 0
        ripple.ZIndex = element.ZIndex + 1
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
        line.Size = UDim2.new(1, -10, 0, 14)
        line.Position = UDim2.new(0, 5, 0, (i-1) * 14)
        line.BackgroundTransparency = 1
        line.Text = entry.text
        line.TextColor3 = entry.color
        line.TextSize = 9
        line.Font = Enum.Font.RobotoMono
        line.TextXAlignment = Enum.TextXAlignment.Left
        line.TextYAlignment = Enum.TextYAlignment.Top
        line.Parent = UiLibrary.ConsoleFrame
    end
    
    UiLibrary.ConsoleFrame.CanvasSize = UDim2.new(0, 0, 0, #ConsoleLines * 14)
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
    
    -- Main Frame (Even More Compact)
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = size or UDim2.new(0, 380, 0, 280)
    self.MainFrame.Position = UDim2.new(0.5, -190, 0.5, -140)
    self.MainFrame.BackgroundColor3 = Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui
    CreateCorner(self.MainFrame, 12)
    
    -- Gradient Background
    CreateGradient(self.MainFrame, Theme.Background, Theme.Secondary, 135)
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 32)
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
    logo.Size = UDim2.new(0, 28, 0, 22)
    logo.Position = UDim2.new(0, 6, 0, 5)
    logo.BackgroundTransparency = 1
    logo.Text = "🦉"
    logo.TextColor3 = Theme.Text
    logo.TextSize = 14
    logo.Font = Enum.Font.GothamBold
    logo.Parent = self.TitleBar
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(0, 120, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 36, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = title or "OwlHub"
    self.TitleLabel.TextColor3 = Theme.Text
    self.TitleLabel.TextSize = 12
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    
    -- Uptime Display
    self.UptimeLabel = Instance.new("TextLabel")
    self.UptimeLabel.Size = UDim2.new(0, 70, 1, 0)
    self.UptimeLabel.Position = UDim2.new(1, -130, 0, 0)
    self.UptimeLabel.BackgroundTransparency = 1
    self.UptimeLabel.Text = "⏱ " .. GetUptime()
    self.UptimeLabel.TextColor3 = Theme.TextSecondary
    self.UptimeLabel.TextSize = 9
    self.UptimeLabel.Font = Enum.Font.Gotham
    self.UptimeLabel.Parent = self.TitleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -27, 0, 5)
    closeBtn.BackgroundColor3 = Theme.Error
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Theme.Text
    closeBtn.TextSize = 12
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
    self.TabContainer.Size = UDim2.new(1, -8, 0, 28)
    self.TabContainer.Position = UDim2.new(0, 4, 0, 36)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = self.TabContainer
    
    -- Content Frame
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Size = UDim2.new(1, -8, 1, -110)
    self.ContentFrame.Position = UDim2.new(0, 4, 0, 68)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.Parent = self.MainFrame
    
    -- Console Frame
    self.ConsoleContainer = Instance.new("Frame")
    self.ConsoleContainer.Size = UDim2.new(1, -8, 0, 45)
    self.ConsoleContainer.Position = UDim2.new(0, 4, 1, -49)
    self.ConsoleContainer.BackgroundColor3 = Theme.Console
    self.ConsoleContainer.BorderSizePixel = 0
    self.ConsoleContainer.Parent = self.MainFrame
    CreateCorner(self.ConsoleContainer, 6)
    
    local consoleTitle = Instance.new("TextLabel")
    consoleTitle.Size = UDim2.new(1, -8, 0, 12)
    consoleTitle.Position = UDim2.new(0, 4, 0, 2)
    consoleTitle.BackgroundTransparency = 1
    consoleTitle.Text = "📟 Console"
    consoleTitle.TextColor3 = Theme.TextSecondary
    consoleTitle.TextSize = 9
    consoleTitle.Font = Enum.Font.GothamBold
    consoleTitle.TextXAlignment = Enum.TextXAlignment.Left
    consoleTitle.Parent = self.ConsoleContainer
    
    UiLibrary.ConsoleFrame = Instance.new("ScrollingFrame")
    UiLibrary.ConsoleFrame.Size = UDim2.new(1, -8, 1, -16)
    UiLibrary.ConsoleFrame.Position = UDim2.new(0, 4, 0, 14)
    UiLibrary.ConsoleFrame.BackgroundTransparency = 1
    UiLibrary.ConsoleFrame.BorderSizePixel = 0
    UiLibrary.ConsoleFrame.ScrollBarThickness = 2
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
    
    -- Fixed: Start with full size (no entrance animation delay)
    self.MainFrame.Size = size or UDim2.new(0, 380, 0, 280)
    self.MainFrame.BackgroundTransparency = 0
    
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
    
    -- Tab Button (Bigger)
    tab.TabButton = Instance.new("TextButton")
    tab.TabButton.Size = UDim2.new(0, 90, 1, 0)
    tab.TabButton.BackgroundColor3 = Theme.Accent
    tab.TabButton.BorderSizePixel = 0
    tab.TabButton.Text = (icon or "📄") .. " " .. name
    tab.TabButton.TextColor3 = Theme.TextSecondary
    tab.TabButton.TextSize = 10
    tab.TabButton.Font = Enum.Font.GothamSemibold
    tab.TabButton.Parent = self.TabContainer
    CreateCorner(tab.TabButton, 6)
    AddRipple(tab.TabButton)
    
    -- Tab Content
    tab.TabContent = Instance.new("ScrollingFrame")
    tab.TabContent.Size = UDim2.new(1, 0, 1, 0)
    tab.TabContent.Position = UDim2.new(0, 0, 0, 0)
    tab.TabContent.BackgroundTransparency = 1
    tab.TabContent.BorderSizePixel = 0
    tab.TabContent.ScrollBarThickness = 3
    tab.TabContent.ScrollBarImageColor3 = Theme.Primary
    tab.TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.TabContent.Visible = false
    tab.TabContent.Parent = self.ContentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = tab.TabContent
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.TabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)
    
    -- Fixed Tab switching - No animations that interfere
    tab.TabButton.MouseButton1Click:Connect(function()
        -- Don't switch if already active
        if self.CurrentTab == tab then return end
        
        -- Hide all tabs instantly
        for _, existingTab in pairs(self.Tabs) do
            existingTab.TabContent.Visible = false
            existingTab.TabButton.BackgroundColor3 = Theme.Accent
            existingTab.TabButton.TextColor3 = Theme.TextSecondary
        end
        
        -- Show current tab instantly
        tab.TabContent.Visible = true
        tab.TabContent.Position = UDim2.new(0, 0, 0, 0)
        tab.TabContent.BackgroundTransparency = 0
        
        tab.TabButton.BackgroundColor3 = Theme.Primary
        tab.TabButton.TextColor3 = Theme.Text
        
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

-- UI Elements (Bigger & More Prominent)
function Tab:CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 35) -- Bigger buttons
    btn.BackgroundColor3 = Theme.Primary
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.TextSize = 13 -- Bigger text
    btn.Font = Enum.Font.GothamBold
    btn.Parent = self.TabContent
    CreateCorner(btn, 8)
    CreateGradient(btn)
    AddHover(btn)
    AddRipple(btn)
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
        UiLibrary.Log("Button clicked: " .. text)
    end)
    
    return btn
end

function Tab:CreateScriptButton(scriptData)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 50) -- Even bigger for scripts
    frame.BackgroundColor3 = Theme.Secondary
    frame.BorderSizePixel = 0
    frame.Parent = self.TabContent
    CreateCorner(frame, 8)
    
    local gradient = CreateGradient(frame, Theme.Script, Theme.Primary, 45)
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0.9)
    }
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = scriptData.icon
    icon.TextColor3 = Theme.Text
    icon.TextSize = 20
    icon.Font = Enum.Font.GothamBold
    icon.Parent = frame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -90, 0, 20)
    nameLabel.Position = UDim2.new(0, 45, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = scriptData.name
    nameLabel.TextColor3 = Theme.Text
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -90, 0, 15)
    descLabel.Position = UDim2.new(0, 45, 0, 25)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = scriptData.description
    descLabel.TextColor3 = Theme.TextSecondary
    descLabel.TextSize = 9
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame
    
    local runBtn = Instance.new("TextButton")
    runBtn.Size = UDim2.new(0, 35, 0, 25)
    runBtn.Position = UDim2.new(1, -40, 0.5, -12)
    runBtn.BackgroundColor3 = Theme.Success
    runBtn.BorderSizePixel = 0
    runBtn.Text = "▶"
    runBtn.TextColor3 = Theme.Text
    runBtn.TextSize = 12
    runBtn.Font = Enum.Font.GothamBold
    runBtn.Parent = frame
    CreateCorner(runBtn, 6)
    AddHover(runBtn, Color3.fromRGB(80, 200, 150))
    
    -- Fixed: Simplified execution without interference
    runBtn.MouseButton1Click:Connect(function()
        -- Immediate visual feedback
        local originalText = runBtn.Text
        local originalColor = runBtn.BackgroundColor3
        
        runBtn.Text = "⏳"
        runBtn.BackgroundColor3 = Theme.Warning
        
        UiLibrary.Log("Executing " .. scriptData.name .. "...", "warning")
        
        -- Execute script
        spawn(function()
            local success, error = pcall(function()
                loadstring(scriptData.code)()
            end)
            
            wait(0.3) -- Brief feedback time
            
            if success then
                UiLibrary.Log(scriptData.name .. " executed successfully!", "success")
                runBtn.Text = "✓"
                runBtn.BackgroundColor3 = Theme.Success
            else
                UiLibrary.Log("Error executing " .. scriptData.name .. ": " .. tostring(error), "error")
                runBtn.Text = "✗"
                runBtn.BackgroundColor3 = Theme.Error
            end
            
            wait(1.5) -- Show result
            
            -- Reset button
            runBtn.Text = originalText
            runBtn.BackgroundColor3 = originalColor
        end)
    end)
    
    return frame
end

function Tab:CreateToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 38) -- Bigger toggles
    frame.BackgroundColor3 = Theme.Secondary
    frame.BorderSizePixel = 0
    frame.Parent = self.TabContent
    CreateCorner(frame, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 12 -- Bigger text
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 45, 0, 20) -- Bigger toggle
    toggle.Position = UDim2.new(1, -50, 0.5, -10)
    toggle.BackgroundColor3 = default and Theme.Success or Theme.Accent
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = frame
    CreateCorner(toggle, 10)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    CreateCorner(knob, 8)
    
    local state = default or false
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        
        TweenService:Create(toggle, TweenInfo.new(0.2, Anim.Style), {
            BackgroundColor3 = state and Theme.Success or Theme.Accent
        }):Play()
        
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        
        if callback then callback(state) end
        UiLibrary.Log("Toggle " .. text .. ": " .. tostring(state))
    end)
    
    return {
        Set = function(newState)
            state = newState
            toggle.BackgroundColor3 = state and Theme.Success or Theme.Accent
            knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        end
    }
end

function Tab:CreateInput(placeholder, callback)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -4, 0, 32) -- Bigger input
    input.BackgroundColor3 = Theme.Secondary
    input.BorderSizePixel = 0
    input.PlaceholderText = placeholder
    input.Text = ""
    input.TextColor3 = Theme.Text
    input.PlaceholderColor3 = Theme.TextMuted
    input.TextSize = 12 -- Bigger text
    input.Font = Enum.Font.Gotham
    input.Parent = self.TabContent
    CreateCorner(input, 8)
    
    input.Focused:Connect(function()
        TweenService:Create(input, TweenInfo.new(0.1, Anim.Style), {
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(1, -2, 0, 34)
        }):Play()
    end)
    
    input.FocusLost:Connect(function()
        TweenService:Create(input, TweenInfo.new(0.1, Anim.Style), {
            BackgroundColor3 = Theme.Secondary,
            Size = UDim2.new(1, -4, 0, 32)
        }):Play()
        if callback then callback(input.Text) end
        UiLibrary.Log("Input: " .. input.Text)
    end)
    
    return input
end

function Tab:CreateLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 28) -- Bigger labels
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextSecondary
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = self.TabContent
    
    return label
end

-- Example Usage Function
function UiLibrary.CreateExampleWindow()
    local Window = UiLibrary.CreateWindow("OwlHub Pro")
    
    -- Main Tab
    local MainTab = Window:CreateTab("Main", "🏠")
    MainTab:CreateLabel("🎯 Main Features")
    MainTab:CreateButton("Test Feature", function()
        UiLibrary.Log("Test feature activated!", "success")
    end)
    MainTab:CreateToggle("Auto Farm", false, function(state)
        UiLibrary.Log("Auto Farm: " .. tostring(state), state and "success" or "warning")
    end)
    MainTab:CreateInput("Enter value...", function(text)
        UiLibrary.Log("Input received: " .. text)
    end)
    
    -- Script Library Tab
    local ScriptTab = Window:CreateTab("Scripts", "📜")
    ScriptTab:CreateLabel("🚀 Script Library")
    
    for _, script in pairs(ScriptLibrary) do
        ScriptTab:CreateScriptButton(script)
    end
    
    -- Settings Tab
    local SettingsTab = Window:CreateTab("Settings", "⚙️")
    SettingsTab:CreateLabel("🔧 Configuration")
    SettingsTab:CreateToggle("Auto Execute", false, function(state)
        UiLibrary.Log("Auto Execute: " .. tostring(state))
    end)
    SettingsTab:CreateButton("Clear Console", function()
        ConsoleLines = {}
        UiLibrary.UpdateConsole()
        UiLibrary.Log("Console cleared", "success")
    end)
    
    return Window
end

-- Fixed: Auto-initialize immediately without delay
UiLibrary.CreateExampleWindow()
UiLibrary.Log("OwlHub UI Library loaded", "success")

return UiLibrary