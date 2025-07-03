-- Enhanced OwlHub-Style GUI System with Advanced Animations
-- Place this in StarterPlayer > StarterPlayerScripts or auto-execute

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Prevent multiple instances
if PlayerGui:FindFirstChild("TestHub_GUI") then
    PlayerGui:FindFirstChild("TestHub_GUI"):Destroy()
end

-- Enhanced OwlHub UI Library
local UiLibrary = {}

-- Premium Theme Configuration
local Theme = {
    Background = Color3.fromRGB(8, 8, 12),
    Secondary = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(22, 22, 30),
    Primary = Color3.fromRGB(88, 101, 242),
    PrimaryHover = Color3.fromRGB(98, 111, 252),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    TextMuted = Color3.fromRGB(120, 120, 130),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Border = Color3.fromRGB(40, 40, 50),
    Console = Color3.fromRGB(5, 5, 8),
    Script = Color3.fromRGB(139, 69, 255),
    Glow = Color3.fromRGB(88, 101, 242)
}

-- Animation Settings
local Anim = {
    Speed = 0.2,
    Fast = 0.1,
    Style = Enum.EasingStyle.Quart,
    Direction = Enum.EasingDirection.Out
}

-- Global Variables
local StartTime = tick()
local ConsoleLines = {}
local MaxConsoleLines = 100

-- Script Library
local ScriptLibrary = {
    {
        name = "Infinite Yield",
        description = "Advanced admin commands & tools",
        icon = "⚡",
        code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()'
    },
    {
        name = "Hydroxide",
        description = "Remote spy & debugging suite",
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

-- Enhanced Utility Functions
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateGradient(parent, color1, color2, rotation, transparency)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1 or Theme.Primary),
        ColorSequenceKeypoint.new(1, color2 or Theme.Script)
    }
    gradient.Rotation = rotation or 45
    if transparency then
        gradient.Transparency = transparency
    end
    gradient.Parent = parent
    return gradient
end

local function CreateShadow(parent, size, intensity)
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = size or UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = intensity or 0.7
    shadow.BorderSizePixel = 0
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent.Parent
    CreateCorner(shadow, 12)
    return shadow
end

local function AddHover(element, hoverColor, normalColor, scale)
    local normal = normalColor or element.BackgroundColor3
    local hover = hoverColor or Theme.PrimaryHover
    local normalScale = scale and UDim2.new(1, 0, 1, 0) or nil
    local hoverScale = scale and UDim2.new(1.02, 0, 1.02, 0) or nil
    
    element.MouseEnter:Connect(function()
        local tween = TweenService:Create(element, TweenInfo.new(Anim.Fast, Anim.Style), {
            BackgroundColor3 = hover
        })
        tween:Play()
        
        if scale then
            TweenService:Create(element, TweenInfo.new(Anim.Fast, Enum.EasingStyle.Back), {
                Size = hoverScale
            }):Play()
        end
    end)
    
    element.MouseLeave:Connect(function()
        local tween = TweenService:Create(element, TweenInfo.new(Anim.Fast, Anim.Style), {
            BackgroundColor3 = normal
        })
        tween:Play()
        
        if scale then
            TweenService:Create(element, TweenInfo.new(Anim.Fast, Enum.EasingStyle.Back), {
                Size = normalScale
            }):Play()
        end
    end)
end

local function AddRipple(element)
    element.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = element.ZIndex + 1
        ripple.Parent = element
        CreateCorner(ripple, 50)
        
        local size = math.max(element.AbsoluteSize.X, element.AbsoluteSize.Y) * 1.5
        TweenService:Create(ripple, TweenInfo.new(0.5, Anim.Style), {
            Size = UDim2.new(0, size, 0, size),
            BackgroundTransparency = 1
        }):Play()
        
        game:GetService("Debris"):AddItem(ripple, 0.5)
    end)
end

-- Enhanced Console Functions
function UiLibrary.Log(message, messageType)
    local timestamp = os.date("[%H:%M:%S]")
    local color = Theme.Text
    local prefix = "INFO"
    local icon = "ℹ️"
    
    if messageType == "success" then
        color = Theme.Success
        prefix = "SUCCESS"
        icon = "✅"
    elseif messageType == "warning" then
        color = Theme.Warning
        prefix = "WARNING"
        icon = "⚠️"
    elseif messageType == "error" then
        color = Theme.Error
        prefix = "ERROR"
        icon = "❌"
    end
    
    local logEntry = {
        text = timestamp .. " " .. icon .. " [" .. prefix .. "] " .. tostring(message),
        color = color,
        time = tick()
    }
    
    table.insert(ConsoleLines, logEntry)
    
    if #ConsoleLines > MaxConsoleLines then
        table.remove(ConsoleLines, 1)
    end
    
    -- Update console if it exists
    if UiLibrary.ConsoleContent then
        UiLibrary.UpdateConsole()
    end
end

function UiLibrary.UpdateConsole()
    if not UiLibrary.ConsoleContent then return end
    
    -- Clear existing lines
    for i, child in pairs(UiLibrary.ConsoleContent:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    -- Add new lines
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
        line.TextWrapped = true
        line.Parent = UiLibrary.ConsoleContent
    end
    
    UiLibrary.ConsoleContent.CanvasSize = UDim2.new(0, 0, 0, #ConsoleLines * 16 + 10)
    UiLibrary.ConsoleContent.CanvasPosition = Vector2.new(0, UiLibrary.ConsoleContent.CanvasSize.Y.Offset)
end

-- Uptime Function
local function GetUptime()
    local elapsed = tick() - StartTime
    local hours = math.floor(elapsed / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = math.floor(elapsed % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

-- Enhanced Window Class
local Window = {}
Window.__index = Window

function UiLibrary.CreateWindow(title, size)
    local self = setmetatable({}, Window)
    
    -- Create ScreenGui with unique name
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "TestHub_GUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = PlayerGui
    
    -- Main Frame with enhanced styling
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = size or UDim2.new(0, 420, 0, 320)
    self.MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
    self.MainFrame.BackgroundColor3 = Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.ZIndex = 1
    self.MainFrame.Parent = self.ScreenGui
    CreateCorner(self.MainFrame, 16)
    
    -- Enhanced shadow
    CreateShadow(self.MainFrame, UDim2.new(1, 20, 1, 20), 0.5)
    
    -- Animated gradient background
    local bgGradient = CreateGradient(self.MainFrame, Theme.Background, Theme.Secondary, 135)
    bgGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.3)
    }
    
    -- Glowing border effect
    local borderGlow = Instance.new("UIStroke")
    borderGlow.Color = Theme.Glow
    borderGlow.Thickness = 1
    borderGlow.Transparency = 0.8
    borderGlow.Parent = self.MainFrame
    
    -- Enhanced Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = Theme.Secondary
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.ZIndex = 2
    self.TitleBar.Parent = self.MainFrame
    CreateCorner(self.TitleBar, 16)
    
    -- Title bar gradient with glow effect
    local titleGradient = CreateGradient(self.TitleBar, Theme.Primary, Theme.Script, 90)
    titleGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 0.8)
    }
    
    -- Animated logo with glow
    local logoFrame = Instance.new("Frame")
    logoFrame.Size = UDim2.new(0, 32, 0, 32)
    logoFrame.Position = UDim2.new(0, 8, 0, 4)
    logoFrame.BackgroundColor3 = Theme.Primary
    logoFrame.BorderSizePixel = 0
    logoFrame.ZIndex = 3
    logoFrame.Parent = self.TitleBar
    CreateCorner(logoFrame, 8)
    CreateGradient(logoFrame, Theme.Primary, Theme.Script)
    
    local logoGlow = Instance.new("UIStroke")
    logoGlow.Color = Theme.Glow
    logoGlow.Thickness = 2
    logoGlow.Transparency = 0.5
    logoGlow.Parent = logoFrame
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 1, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "🦉"
    logo.TextColor3 = Theme.Text
    logo.TextSize = 16
    logo.Font = Enum.Font.GothamBold
    logo.ZIndex = 4
    logo.Parent = logoFrame
    
    -- Enhanced Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(0, 150, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 48, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = title or "Test"
    self.TitleLabel.TextColor3 = Theme.Text
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.ZIndex = 3
    self.TitleLabel.Parent = self.TitleBar
    
    -- Enhanced Uptime Display
    self.UptimeLabel = Instance.new("TextLabel")
    self.UptimeLabel.Size = UDim2.new(0, 80, 1, 0)
    self.UptimeLabel.Position = UDim2.new(1, -140, 0, 0)
    self.UptimeLabel.BackgroundTransparency = 1
    self.UptimeLabel.Text = "⏱️ " .. GetUptime()
    self.UptimeLabel.TextColor3 = Theme.TextSecondary
    self.UptimeLabel.TextSize = 10
    self.UptimeLabel.Font = Enum.Font.GothamSemibold
    self.UptimeLabel.ZIndex = 3
    self.UptimeLabel.Parent = self.TitleBar
    
    -- Enhanced Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0, 6)
    closeBtn.BackgroundColor3 = Theme.Error
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Theme.Text
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 3
    closeBtn.Parent = self.TitleBar
    CreateCorner(closeBtn, 8)
    AddHover(closeBtn, Color3.fromRGB(255, 80, 80), Theme.Error, true)
    AddRipple(closeBtn)
    
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(self.MainFrame, TweenInfo.new(Anim.Speed, Anim.Style), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        wait(Anim.Speed)
        self.ScreenGui:Destroy()
    end)
    
    -- Enhanced Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, -12, 0, 32)
    self.TabContainer.Position = UDim2.new(0, 6, 0, 46)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.ZIndex = 2
    self.TabContainer.Parent = self.MainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 3)
    tabLayout.Parent = self.TabContainer
    
    -- Enhanced Content Frame
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Size = UDim2.new(1, -12, 1, -90)
    self.ContentFrame.Position = UDim2.new(0, 6, 0, 84)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.ZIndex = 2
    self.ContentFrame.Parent = self.MainFrame
    
    -- Enhanced Dragging with smooth animation
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
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            
            TweenService:Create(self.MainFrame, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
                Position = newPos
            }):Play()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Animated uptime updates
    spawn(function()
        while self.ScreenGui.Parent do
            self.UptimeLabel.Text = "⏱️ " .. GetUptime()
            wait(1)
        end
    end)
    
    -- Entrance animation
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.MainFrame.BackgroundTransparency = 1
    TweenService:Create(self.MainFrame, TweenInfo.new(Anim.Speed * 2, Enum.EasingStyle.Back), {
        Size = size or UDim2.new(0, 420, 0, 320),
        BackgroundTransparency = 0
    }):Play()
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    UiLibrary.Log("Test GUI initialized successfully", "success")
    
    return self
end

-- Enhanced Tab Class
local Tab = {}
Tab.__index = Tab

function Window:CreateTab(name, icon)
    local tab = setmetatable({}, Tab)
    
    -- Enhanced Tab Button
    tab.TabButton = Instance.new("TextButton")
    tab.TabButton.Size = UDim2.new(0, 100, 1, 0)
    tab.TabButton.BackgroundColor3 = Theme.Accent
    tab.TabButton.BorderSizePixel = 0
    tab.TabButton.Text = (icon or "📄") .. " " .. name
    tab.TabButton.TextColor3 = Theme.TextSecondary
    tab.TabButton.TextSize = 11
    tab.TabButton.Font = Enum.Font.GothamSemibold
    tab.TabButton.ZIndex = 3
    tab.TabButton.Parent = self.TabContainer
    CreateCorner(tab.TabButton, 8)
    AddRipple(tab.TabButton)
    
    -- Tab glow effect
    local tabGlow = Instance.new("UIStroke")
    tabGlow.Color = Theme.Primary
    tabGlow.Thickness = 1
    tabGlow.Transparency = 1
    tabGlow.Parent = tab.TabButton
    
    -- Enhanced Tab Content
    tab.TabContent = Instance.new("ScrollingFrame")
    tab.TabContent.Size = UDim2.new(1, 0, 1, 0)
    tab.TabContent.Position = UDim2.new(0, 0, 0, 0)
    tab.TabContent.BackgroundTransparency = 1
    tab.TabContent.BorderSizePixel = 0
    tab.TabContent.ScrollBarThickness = 4
    tab.TabContent.ScrollBarImageColor3 = Theme.Primary
    tab.TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.TabContent.Visible = false
    tab.TabContent.ZIndex = 3
    tab.TabContent.Parent = self.ContentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = tab.TabContent
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.TabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end)
    
    -- Enhanced tab switching with smooth animations
    tab.TabButton.MouseButton1Click:Connect(function()
        if self.CurrentTab == tab then return end
        
        -- Animate out current tab
        if self.CurrentTab then
            self.CurrentTab.TabContent.Visible = false
            
            TweenService:Create(self.CurrentTab.TabButton, TweenInfo.new(Anim.Fast, Anim.Style), {
                BackgroundColor3 = Theme.Accent,
                TextColor3 = Theme.TextSecondary
            }):Play()
            
            local currentGlow = self.CurrentTab.TabButton:FindFirstChild("UIStroke")
            if currentGlow then
                TweenService:Create(currentGlow, TweenInfo.new(Anim.Fast, Anim.Style), {
                    Transparency = 1
                }):Play()
            end
        end
        
        -- Animate in new tab
        tab.TabContent.Visible = true
        
        TweenService:Create(tab.TabButton, TweenInfo.new(Anim.Speed, Anim.Style), {
            BackgroundColor3 = Theme.Primary,
            TextColor3 = Theme.Text
        }):Play()
        
        TweenService:Create(tabGlow, TweenInfo.new(Anim.Speed, Anim.Style), {
            Transparency = 0.3
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
        tabGlow.Transparency = 0.3
        self.CurrentTab = tab
    end
    
    return tab
end

-- Enhanced UI Elements
function Tab:CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 40)
    btn.BackgroundColor3 = Theme.Primary
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 4
    btn.Parent = self.TabContent
    CreateCorner(btn, 10)
    CreateGradient(btn, Theme.Primary, Theme.Script)
    AddHover(btn, Theme.PrimaryHover, Theme.Primary, true)
    AddRipple(btn)
    
    -- Enhanced glow effect
    local btnGlow = Instance.new("UIStroke")
    btnGlow.Color = Theme.Glow
    btnGlow.Thickness = 1
    btnGlow.Transparency = 0.8
    btnGlow.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
        UiLibrary.Log("Button clicked: " .. text)
    end)
    
    return btn
end

function Tab:CreateScriptButton(scriptData)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 60)
    frame.BackgroundColor3 = Theme.Secondary
    frame.BorderSizePixel = 0
    frame.ZIndex = 4
    frame.Parent = self.TabContent
    CreateCorner(frame, 12)
    
    -- Enhanced gradient with glow
    local gradient = CreateGradient(frame, Theme.Script, Theme.Primary, 45)
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 0.9)
    }
    
    local frameGlow = Instance.new("UIStroke")
    frameGlow.Color = Theme.Script
    frameGlow.Thickness = 1
    frameGlow.Transparency = 0.8
    frameGlow.Parent = frame
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 45, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = scriptData.icon
    icon.TextColor3 = Theme.Text
    icon.TextSize = 24
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = 5
    icon.Parent = frame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -100, 0, 25)
    nameLabel.Position = UDim2.new(0, 50, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = scriptData.name
    nameLabel.TextColor3 = Theme.Text
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = frame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -100, 0, 18)
    descLabel.Position = UDim2.new(0, 50, 0, 32)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = scriptData.description
    descLabel.TextColor3 = Theme.TextSecondary
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 5
    descLabel.Parent = frame
    
    local runBtn = Instance.new("TextButton")
    runBtn.Size = UDim2.new(0, 40, 0, 30)
    runBtn.Position = UDim2.new(1, -45, 0.5, -15)
    runBtn.BackgroundColor3 = Theme.Success
    runBtn.BorderSizePixel = 0
    runBtn.Text = "▶"
    runBtn.TextColor3 = Theme.Text
    runBtn.TextSize = 14
    runBtn.Font = Enum.Font.GothamBold
    runBtn.ZIndex = 5
    runBtn.Parent = frame
    CreateCorner(runBtn, 8)
    AddHover(runBtn, Color3.fromRGB(80, 200, 150), Theme.Success, true)
    AddRipple(runBtn)
    
    runBtn.MouseButton1Click:Connect(function()
        local originalText = runBtn.Text
        local originalColor = runBtn.BackgroundColor3
        
        runBtn.Text = "⏳"
        runBtn.BackgroundColor3 = Theme.Warning
        
        UiLibrary.Log("Executing " .. scriptData.name .. "...", "warning")
        
        spawn(function()
            local success, error = pcall(function()
                loadstring(scriptData.code)()
            end)
            
            wait(0.5)
            
            if success then
                UiLibrary.Log(scriptData.name .. " executed successfully!", "success")
                runBtn.Text = "✓"
                runBtn.BackgroundColor3 = Theme.Success
            else
                UiLibrary.Log("Error executing " .. scriptData.name .. ": " .. tostring(error), "error")
                runBtn.Text = "✗"
                runBtn.BackgroundColor3 = Theme.Error
            end
            
            wait(2)
            
            runBtn.Text = originalText
            runBtn.BackgroundColor3 = originalColor
        end)
    end)
    
    return frame
end

function Tab:CreateToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 42)
    frame.BackgroundColor3 = Theme.Secondary
    frame.BorderSizePixel = 0
    frame.ZIndex = 4
    frame.Parent = self.TabContent
    CreateCorner(frame, 10)
    
    local frameGlow = Instance.new("UIStroke")
    frameGlow.Color = Theme.Border
    frameGlow.Thickness = 1
    frameGlow.Transparency = 0.5
    frameGlow.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 5
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 24)
    toggle.Position = UDim2.new(1, -60, 0.5, -12)
    toggle.BackgroundColor3 = default and Theme.Success or Theme.Accent
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.ZIndex = 5
    toggle.Parent = frame
    CreateCorner(toggle, 12)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.ZIndex = 6
    knob.Parent = toggle
    CreateCorner(knob, 9)
    
    local knobGlow = Instance.new("UIStroke")
    knobGlow.Color = Theme.Glow
    knobGlow.Thickness = 1
    knobGlow.Transparency = 0.6
    knobGlow.Parent = knob
    
    local state = default or false
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        
        TweenService:Create(toggle, TweenInfo.new(Anim.Speed, Anim.Style), {
            BackgroundColor3 = state and Theme.Success or Theme.Accent
        }):Play()
        
        TweenService:Create(knob, TweenInfo.new(Anim.Speed, Enum.EasingStyle.Back), {
            Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        
        if callback then callback(state) end
        UiLibrary.Log("Toggle " .. text .. ": " .. tostring(state))
    end)
    
    return {
        Set = function(newState)
            state = newState
            toggle.BackgroundColor3 = state and Theme.Success or Theme.Accent
            knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        end
    }
end

function Tab:CreateInput(placeholder, callback)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -6, 0, 36)
    input.BackgroundColor3 = Theme.Secondary
    input.BorderSizePixel = 0
    input.PlaceholderText = placeholder
    input.Text = ""
    input.TextColor3 = Theme.Text
    input.PlaceholderColor3 = Theme.TextMuted
    input.TextSize = 12
    input.Font = Enum.Font.Gotham
    input.ZIndex = 4
    input.Parent = self.TabContent
    CreateCorner(input, 10)
    
    local inputGlow = Instance.new("UIStroke")
    inputGlow.Color = Theme.Primary
    inputGlow.Thickness = 1
    inputGlow.Transparency = 1
    inputGlow.Parent = input
    
    input.Focused:Connect(function()
        TweenService:Create(input, TweenInfo.new(Anim.Fast, Anim.Style), {
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(1, -4, 0, 38)
        }):Play()
        
        TweenService:Create(inputGlow, TweenInfo.new(Anim.Fast, Anim.Style), {
            Transparency = 0.5
        }):Play()
    end)
    
    input.FocusLost:Connect(function()
        TweenService:Create(input, TweenInfo.new(Anim.Fast, Anim.Style), {
            BackgroundColor3 = Theme.Secondary,
            Size = UDim2.new(1, -6, 0, 36)
        }):Play()
        
        TweenService:Create(inputGlow, TweenInfo.new(Anim.Fast, Anim.Style), {
            Transparency = 1
        }):Play()
        
        if callback then callback(input.Text) end
        UiLibrary.Log("Input: " .. input.Text)
    end)
    
    return input
end

function Tab:CreateLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -6, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextSecondary
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = self.TabContent
    
    return label
end

-- Console Tab Creation
function Tab:CreateConsole()
    UiLibrary.ConsoleContent = Instance.new("ScrollingFrame")
    UiLibrary.ConsoleContent.Size = UDim2.new(1, -6, 1, 0)
    UiLibrary.ConsoleContent.BackgroundColor3 = Theme.Console
    UiLibrary.ConsoleContent.BorderSizePixel = 0
    UiLibrary.ConsoleContent.ScrollBarThickness = 4
    UiLibrary.ConsoleContent.ScrollBarImageColor3 = Theme.Primary
    UiLibrary.ConsoleContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    UiLibrary.ConsoleContent.ZIndex = 4
    UiLibrary.ConsoleContent.Parent = self.TabContent
    CreateCorner(UiLibrary.ConsoleContent, 10)
    
    local consoleGlow = Instance.new("UIStroke")
    consoleGlow.Color = Theme.Success
    consoleGlow.Thickness = 1
    consoleGlow.Transparency = 0.8
    consoleGlow.Parent = UiLibrary.ConsoleContent
    
    UiLibrary.UpdateConsole()
    
    return UiLibrary.ConsoleContent
end

-- Single Instance Creation
local function CreateSingleWindow()
    local Window = UiLibrary.CreateWindow("Test")
    
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
    
    -- Console Tab
    local ConsoleTab = Window:CreateTab("Console", "📟")
    ConsoleTab:CreateConsole()
    
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

-- Auto-initialize single instance
CreateSingleWindow()
UiLibrary.Log("Test UI Library loaded successfully", "success")

return UiLibrary