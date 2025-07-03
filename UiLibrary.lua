-- Roblox UI Library with Dark Theme
-- Created for executor usage with sleek animations

local UiLibrary = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Variables
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Configuration
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(45, 45, 55),
    Primary = Color3.fromRGB(100, 100, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(50, 200, 50),
    Warning = Color3.fromRGB(255, 200, 50),
    Error = Color3.fromRGB(255, 50, 50),
    Border = Color3.fromRGB(60, 60, 70)
}

-- Animation Settings
local AnimationSpeed = 0.3
local EasingStyle = Enum.EasingStyle.Quart
local EasingDirection = Enum.EasingDirection.Out

-- Utility Functions
function UiLibrary.ChangeTheme(newTheme)
    for key, value in pairs(newTheme) do
        if Theme[key] then
            Theme[key] = value
        end
    end
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
            
            TweenService:Create(frame, TweenInfo.new(0.1, EasingStyle, EasingDirection), {
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

function UiLibrary.PackColor(color)
    return {
        R = color.R * 255,
        G = color.G * 255,
        B = color.B * 255
    }
end

function UiLibrary.UnpackColor(colorTable)
    return Color3.fromRGB(colorTable.R, colorTable.G, colorTable.B)
end

function UiLibrary.LoadConfiguration(configName)
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(configName .. ".json"))
    end)
    return success and result or {}
end

function UiLibrary.SaveConfiguration(configName, data)
    pcall(function()
        writefile(configName .. ".json", game:GetService("HttpService"):JSONEncode(data))
    end)
end

-- Data Class
local Data = {}
Data.__index = Data

function Data.new()
    local self = setmetatable({}, Data)
    self.storage = {}
    return self
end

function Data:Set(key, value)
    self.storage[key] = value
end

function Data:Get(key)
    return self.storage[key]
end

-- Module Functions
function UiLibrary.IsNotNaN(value)
    return value == value
end

-- Binds Class
local Binds = {}
Binds.__index = Binds

function Binds.new()
    local self = setmetatable({}, Binds)
    self.connections = {}
    return self
end

function Binds:Add(connection)
    table.insert(self.connections, connection)
end

function Binds:Disconnect()
    for _, connection in pairs(self.connections) do
        connection:Disconnect()
    end
    self.connections = {}
end

function UiLibrary.GenUid()
    return game:GetService("HttpService"):GenerateGUID(false)
end

function UiLibrary.DrawTriangle(parent, pointA, pointB, pointC, color)
    -- Triangle drawing implementation
    local triangle = Instance.new("Frame")
    triangle.Name = "Triangle"
    triangle.BackgroundColor3 = color or Theme.Primary
    triangle.BorderSizePixel = 0
    triangle.Parent = parent
    return triangle
end

function UiLibrary.DrawQuad(parent, points, color)
    -- Quad drawing implementation
    local quad = Instance.new("Frame")
    quad.Name = "Quad"
    quad.BackgroundColor3 = color or Theme.Primary
    quad.BorderSizePixel = 0
    quad.Parent = parent
    return quad
end

-- BindFrame Class
local BindFrame = {}
BindFrame.__index = BindFrame

function BindFrame.new()
    local self = setmetatable({}, BindFrame)
    self.parts = {}
    self.parents = {}
    return self
end

function BindFrame:add(part, parent)
    table.insert(self.parts, part)
    table.insert(self.parents, parent)
end

function BindFrame:UpdateOrientation()
    -- Update orientation logic
end

function BindFrame:Modify(properties)
    for _, part in pairs(self.parts) do
        for property, value in pairs(properties) do
            part[property] = value
        end
    end
end

function UiLibrary.UnbindFrame(bindFrame)
    bindFrame.parts = {}
    bindFrame.parents = {}
end

function UiLibrary.HasBinding(bindFrame)
    return #bindFrame.parts > 0
end

function UiLibrary.GetBoundParts(bindFrame)
    return bindFrame.parts
end

-- Notification System
function UiLibrary.Notify(title, message, duration, notificationType)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "Notification"
    notificationGui.Parent = CoreGui
    
    local notification = Instance.new("Frame")
    notification.Name = "NotificationFrame"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 0, 20)
    notification.BackgroundColor3 = Theme.Secondary
    notification.BorderSizePixel = 0
    notification.Parent = notificationGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Position = UDim2.new(0, 10, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Theme.TextSecondary
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Parent = notification
    
    -- Slide in animation
    TweenService:Create(notification, TweenInfo.new(AnimationSpeed, EasingStyle, EasingDirection), {
        Position = UDim2.new(1, -320, 0, 20)
    }):Play()
    
    -- Auto dismiss
    wait(duration or 3)
    TweenService:Create(notification, TweenInfo.new(AnimationSpeed, EasingStyle, EasingDirection), {
        Position = UDim2.new(1, 0, 0, 20)
    }):Play()
    
    wait(AnimationSpeed)
    notificationGui:Destroy()
end

-- Window Management
local Windows = {}

function UiLibrary.Hide()
    for _, window in pairs(Windows) do
        if window.Visible then
            TweenService:Create(window, TweenInfo.new(AnimationSpeed, EasingStyle, EasingDirection), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
        end
    end
end

function UiLibrary.Unhide()
    for _, window in pairs(Windows) do
        TweenService:Create(window, TweenInfo.new(AnimationSpeed, EasingStyle, EasingDirection), {
            Size = window.OriginalSize or UDim2.new(0, 500, 0, 400)
        }):Play()
    end
end

function UiLibrary.Maximise()
    for _, window in pairs(Windows) do
        window.OriginalSize = window.Size
        TweenService:Create(window, TweenInfo.new(AnimationSpeed, EasingStyle, EasingDirection), {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    end
end

function UiLibrary.Minimise()
    for _, window in pairs(Windows) do
        TweenService:Create(window, TweenInfo.new(AnimationSpeed, EasingStyle, EasingDirection), {
            Size = window.OriginalSize or UDim2.new(0, 500, 0, 400)
        }):Play()
    end
end

-- Window Class
local Window = {}
Window.__index = Window

function UiLibrary.CreateWindow(title, size)
    local self = setmetatable({}, Window)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILibrary_" .. UiLibrary.GenUid()
    self.ScreenGui.Parent = CoreGui
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = size or UDim2.new(0, 500, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    self.MainFrame.BackgroundColor3 = Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = self.MainFrame
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = Theme.Secondary
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = self.TitleBar
    
    -- Title Label
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "TitleLabel"
    self.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = title or "UI Library"
    self.TitleLabel.TextColor3 = Theme.Text
    self.TitleLabel.TextScaled = true
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -35, 0, 5)
    self.CloseButton.BackgroundColor3 = Theme.Error
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Theme.Text
    self.CloseButton.TextScaled = true
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = self.TitleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = self.CloseButton
    
    -- Content Frame
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Size = UDim2.new(1, -20, 1, -60)
    self.ContentFrame.Position = UDim2.new(0, 10, 0, 50)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.ScrollBarThickness = 6
    self.ContentFrame.ScrollBarImageColor3 = Theme.Primary
    self.ContentFrame.Parent = self.MainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 5)
    contentLayout.Parent = self.ContentFrame
    
    -- Add dragging functionality
    UiLibrary.AddDraggingFunctionality(self.MainFrame, self.TitleBar)
    
    -- Close button functionality
    self.CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(self.MainFrame, TweenInfo.new(AnimationSpeed, EasingStyle, EasingDirection), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        wait(AnimationSpeed)
        self.ScreenGui:Destroy()
    end)
    
    -- Add to windows list
    table.insert(Windows, self.MainFrame)
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    return self
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Window:CreateTab(name)
    local self = setmetatable({}, Tab)
    
    -- Tab Button
    self.TabButton = Instance.new("TextButton")
    self.TabButton.Name = "TabButton_" .. name
    self.TabButton.Size = UDim2.new(0, 100, 0, 30)
    self.TabButton.BackgroundColor3 = Theme.Accent
    self.TabButton.BorderSizePixel = 0
    self.TabButton.Text = name
    self.TabButton.TextColor3 = Theme.Text
    self.TabButton.TextScaled = true
    self.TabButton.Font = Enum.Font.Gotham
    self.TabButton.Parent = self.ContentFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = self.TabButton
    
    -- Tab Content
    self.TabContent = Instance.new("ScrollingFrame")
    self.TabContent.Name = "TabContent_" .. name
    self.TabContent.Size = UDim2.new(1, 0, 1, -40)
    self.TabContent.Position = UDim2.new(0, 0, 0, 35)
    self.TabContent.BackgroundTransparency = 1
    self.TabContent.BorderSizePixel = 0
    self.TabContent.ScrollBarThickness = 4
    self.TabContent.ScrollBarImageColor3 = Theme.Primary
    self.TabContent.Visible = false
    self.TabContent.Parent = self.ContentFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = self.TabContent
    
    -- Tab switching
    self.TabButton.MouseButton1Click:Connect(function()
        -- Hide all tabs
        for _, tab in pairs(self.Tabs) do
            tab.TabContent.Visible = false
            tab.TabButton.BackgroundColor3 = Theme.Accent
        end
        
        -- Show current tab
        self.TabContent.Visible = true
        self.TabButton.BackgroundColor3 = Theme.Primary
        self.CurrentTab = self
    end)
    
    -- Add to tabs list
    table.insert(self.Tabs, self)
    
    -- If first tab, make it active
    if #self.Tabs == 1 then
        self.TabContent.Visible = true
        self.TabButton.BackgroundColor3 = Theme.Primary
        self.CurrentTab = self
    end
    
    return self
end

-- Button Class
local ButtonValue = {}
ButtonValue.__index = ButtonValue

function ButtonValue:Set(callback)
    self.Callback = callback
end

function Tab:CreateButton(text, callback)
    local self = setmetatable({}, ButtonValue)
    
    self.Button = Instance.new("TextButton")
    self.Button.Name = "Button"
    self.Button.Size = UDim2.new(1, -10, 0, 35)
    self.Button.BackgroundColor3 = Theme.Primary
    self.Button.BorderSizePixel = 0
    self.Button.Text = text
    self.Button.TextColor3 = Theme.Text
    self.Button.TextScaled = true
    self.Button.Font = Enum.Font.Gotham
    self.Button.Parent = self.TabContent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = self.Button
    
    self.Callback = callback
    
    self.Button.MouseButton1Click:Connect(function()
        if self.Callback then
            self.Callback()
        end
        
        -- Button press animation
        TweenService:Create(self.Button, TweenInfo.new(0.1, EasingStyle, EasingDirection), {
            Size = UDim2.new(1, -15, 0, 32)
        }):Play()
        
        wait(0.1)
        
        TweenService:Create(self.Button, TweenInfo.new(0.1, EasingStyle, EasingDirection), {
            Size = UDim2.new(1, -10, 0, 35)
        }):Play()
    end)
    
    return self
end

-- Color Picker
function Tab:CreateColorPicker(text, defaultColor, callback)
    local colorPicker = Instance.new("Frame")
    colorPicker.Name = "ColorPicker"
    colorPicker.Size = UDim2.new(1, -10, 0, 35)
    colorPicker.BackgroundColor3 = Theme.Secondary
    colorPicker.BorderSizePixel = 0
    colorPicker.Parent = self.TabContent
    
    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 6)
    pickerCorner.Parent = colorPicker
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorPicker
    
    local colorDisplay = Instance.new("Frame")
    colorDisplay.Size = UDim2.new(0, 25, 0, 25)
    colorDisplay.Position = UDim2.new(1, -30, 0.5, -12.5)
    colorDisplay.BackgroundColor3 = defaultColor or Theme.Primary
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Parent = colorPicker
    
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 4)
    displayCorner.Parent = colorDisplay
    
    -- Color picker functionality would go here
    -- This is a simplified version
    
    return {
        setDisplay = function(color)
            colorDisplay.BackgroundColor3 = color
        end,
        rgbBoxes = function()
            -- RGB input boxes implementation
        end,
        Set = function(color)
            colorDisplay.BackgroundColor3 = color
            if callback then callback(color) end
        end
    }
end

-- Section Class
local SectionValue = {}
SectionValue.__index = SectionValue

function SectionValue:Set(text)
    self.Label.Text = text
end

function Tab:CreateSection(text)
    local self = setmetatable({}, SectionValue)
    
    self.Section = Instance.new("Frame")
    self.Section.Name = "Section"
    self.Section.Size = UDim2.new(1, -10, 0, 30)
    self.Section.BackgroundColor3 = Theme.Accent
    self.Section.BorderSizePixel = 0
    self.Section.Parent = self.TabContent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 6)
    sectionCorner.Parent = self.Section
    
    self.Label = Instance.new("TextLabel")
    self.Label.Size = UDim2.new(1, -10, 1, 0)
    self.Label.Position = UDim2.new(0, 5, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = text
    self.Label.TextColor3 = Theme.Text
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.GothamBold
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Section
    
    return self
end

-- Label Class
local LabelValue = {}
LabelValue.__index = LabelValue

function LabelValue:Set(text)
    self.Label.Text = text
end

function Tab:CreateLabel(text)
    local self = setmetatable({}, LabelValue)
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, -10, 0, 25)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = text
    self.Label.TextColor3 = Theme.TextSecondary
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.TabContent
    
    return self
end

-- Paragraph Class
local ParagraphValue = {}
ParagraphValue.__index = ParagraphValue

function ParagraphValue:Set(text)
    self.Label.Text = text
end

function Tab:CreateParagraph(text)
    local self = setmetatable({}, ParagraphValue)
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Paragraph"
    self.Label.Size = UDim2.new(1, -10, 0, 50)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = text
    self.Label.TextColor3 = Theme.TextSecondary
    self.Label.TextScaled = true
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.TextWrapped = true
    self.Label.Parent = self.TabContent
    
    return self
end

-- Input Class
local InputSettings = {}
InputSettings.__index = InputSettings

function InputSettings:Set(text)
    self.TextBox.Text = text
end

function Tab:CreateInput(placeholder, callback)
    local self = setmetatable({}, InputSettings)
    
    self.InputFrame = Instance.new("Frame")
    self.InputFrame.Name = "Input"
    self.InputFrame.Size = UDim2.new(1, -10, 0, 35)
    self.InputFrame.BackgroundColor3 = Theme.Secondary
    self.InputFrame.BorderSizePixel = 0
    self.InputFrame.Parent = self.TabContent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = self.InputFrame
    
    self.TextBox = Instance.new("TextBox")
    self.TextBox.Size = UDim2.new(1, -10, 1, 0)
    self.TextBox.Position = UDim2.new(0, 5, 0, 0)
    self.TextBox.BackgroundTransparency = 1
    self.TextBox.PlaceholderText = placeholder
    self.TextBox.Text = ""
    self.TextBox.TextColor3 = Theme.Text
    self.TextBox.PlaceholderColor3 = Theme.TextSecondary
    self.TextBox.TextScaled = true
    self.TextBox.Font = Enum.Font.Gotham
    self.TextBox.TextXAlignment = Enum.TextXAlignment.Left
    self.TextBox.Parent = self.InputFrame
    
    self.TextBox.FocusLost:Connect(function()
        if callback then
            callback(self.TextBox.Text)
        end
    end)
    
    return self
end

-- Dropdown
function Tab:CreateDropdown(text, options, callback)
    local dropdown = Instance.new("Frame")
    dropdown.Name = "Dropdown"
    dropdown.Size = UDim2.new(1, -10, 0, 35)
    dropdown.BackgroundColor3 = Theme.Secondary
    dropdown.BorderSizePixel = 0
    dropdown.Parent = self.TabContent
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdown
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdown
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.3, -5, 0, 25)
    button.Position = UDim2.new(0.7, 0, 0.5, -12.5)
    button.BackgroundColor3 = Theme.Primary
    button.BorderSizePixel = 0
    button.Text = options[1] or "Select"
    button.TextColor3 = Theme.Text
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.Parent = dropdown
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    return {
        Set = function(option)
            button.Text = option
            if callback then callback(option) end
        end
    }
end

-- Keybind
function Tab:CreateKeybind(text, defaultKey, callback)
    local keybind = Instance.new("Frame")
    keybind.Name = "Keybind"
    keybind.Size = UDim2.new(1, -10, 0, 35)
    keybind.BackgroundColor3 = Theme.Secondary
    keybind.BorderSizePixel = 0
    keybind.Parent = self.TabContent
    
    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 6)
    keybindCorner.Parent = keybind
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = keybind
    
    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(0.3, -5, 0, 25)
    keyButton.Position = UDim2.new(0.7, 0, 0.5, -12.5)
    keyButton.BackgroundColor3 = Theme.Primary
    keyButton.BorderSizePixel = 0
    keyButton.Text = defaultKey or "None"
    keyButton.TextColor3 = Theme.Text
    keyButton.TextScaled = true
    keyButton.Font = Enum.Font.Gotham
    keyButton.Parent = keybind
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 4)
    keyCorner.Parent = keyButton
    
    return {
        Set = function(key)
            keyButton.Text = key
            if callback then callback(key) end
        end
    }
end

-- Toggle Class
local ToggleValue = {}
ToggleValue.__index = ToggleValue

function ToggleValue:Set(state)
    self.State = state
    self.Toggle.BackgroundColor3 = state and Theme.Success or Theme.Accent
    if self.Callback then
        self.Callback(state)
    end
end

function Tab:CreateToggle(text, defaultState, callback)
    local self = setmetatable({}, ToggleValue)
    
    self.ToggleFrame = Instance.new("Frame")
    self.ToggleFrame.Name = "Toggle"
    self.ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
    self.ToggleFrame.BackgroundColor3 = Theme.Secondary
    self.ToggleFrame.BorderSizePixel = 0
    self.ToggleFrame.Parent = self.TabContent
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = self.ToggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = self.ToggleFrame
    
    self.Toggle = Instance.new("TextButton")
    self.Toggle.Size = UDim2.new(0, 50, 0, 25)
    self.Toggle.Position = UDim2.new(1, -55, 0.5, -12.5)
    self.Toggle.BackgroundColor3 = defaultState and Theme.Success or Theme.Accent
    self.Toggle.BorderSizePixel = 0
    self.Toggle.Text = defaultState and "ON" or "OFF"
    self.Toggle.TextColor3 = Theme.Text
    self.Toggle.TextScaled = true
    self.Toggle.Font = Enum.Font.GothamBold
    self.Toggle.Parent = self.ToggleFrame
    
    local toggleButtonCorner = Instance.new("UICorner")
    toggleButtonCorner.CornerRadius = UDim.new(0, 4)
    toggleButtonCorner.Parent = self.Toggle
    
    self.State = defaultState or false
    self.Callback = callback
    
    self.Toggle.MouseButton1Click:Connect(function()
        self.State = not self.State
        self:Set(self.State)
        self.Toggle.Text = self.State and "ON" or "OFF"
    end)
    
    return self
end

-- Slider
function Tab:CreateSlider(text, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.Size = UDim2.new(1, -10, 0, 50)
    slider.BackgroundColor3 = Theme.Secondary
    slider.BorderSizePixel = 0
    slider.Parent = self.TabContent
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 6)
    sliderCorner.Parent = slider
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. (default or min)
    label.TextColor3 = Theme.Text
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 6)
    sliderBar.Position = UDim2.new(0, 10, 1, -15)
    sliderBar.BackgroundColor3 = Theme.Accent
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = slider
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 3)
    barCorner.Parent = sliderBar
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default or min) / max, 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    return {
        Set = function(value)
            local percentage = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            label.Text = text .. ": " .. value
            if callback then callback(value) end
        end
    }
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

return UiLibrary