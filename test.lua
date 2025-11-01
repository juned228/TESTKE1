
-- Minimal Admin Script for Roblox
-- Complex UI with monochrome design
-- Place this in StarterPlayerScripts or as a LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Admin variables
local defaultWalkSpeed = 16
local customWalkSpeed = 50
local isSpeedEnabled = false
local isAdminMode = true

-- Panel state variables
local isPanelVisible = false
local panelSize = UDim2.new(0, 320, 0, 460)
local logoButtonSize = UDim2.new(0, 50, 0, 50)

-- Fly variables
local isFlying = false
local flySpeed = 100
local flyDirection = Vector3.new(0, 0, 0)
local bv = nil
local bg = nil

-- Jump variables
local isInfinityJumpEnabled = false
local defaultJumpPower = humanoid.JumpPower

-- Store original values
local originalWalkSpeed = humanoid.WalkSpeed
local originalJumpPower = humanoid.JumpPower

-- Line Player variables
local isLinePlayerEnabled = false
local playerLines = {}
local lineRefreshRate = 0.1
local lineUpdateConnection = nil

-- Teleport variables
local selectedTeleportPlayer = nil
local teleportPlayerButtons = {}



-- Category collapse state variables
local isMainCategoryCollapsed = false
local isLocalPlayerCategoryCollapsed = false

-- Color scheme (monochrome)
local colors = {
    primary = Color3.fromRGB(20, 20, 20),
    secondary = Color3.fromRGB(35, 35, 35),
    tertiary = Color3.fromRGB(50, 50, 50),
    accent = Color3.fromRGB(70, 70, 70),
    text = Color3.fromRGB(255, 255, 255),
    text_dim = Color3.fromRGB(180, 180, 180),
    active = Color3.fromRGB(100, 100, 100),
    inactive = Color3.fromRGB(40, 40, 40),
    danger = Color3.fromRGB(255, 0, 0),
    success = Color3.fromRGB(0, 255, 0),
    warning = Color3.fromRGB(255, 165, 0)
}

-- Create Minimal GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MinimalAdminPanel"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Logo Button (Main Element - Always Visible)
local logoButton = Instance.new("TextButton")
logoButton.Name = "LogoButton"
logoButton.Parent = screenGui
logoButton.BackgroundColor3 = colors.primary
logoButton.BorderSizePixel = 1
logoButton.BorderColor3 = colors.accent
logoButton.Position = UDim2.new(1, -60, 0, 20)
logoButton.Size = logoButtonSize
logoButton.Text = ""
logoButton.Active = true
logoButton.Draggable = true

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 25)
logoCorner.Parent = logoButton

-- Logo Container (for custom logo/text)
local logoContainer = Instance.new("Frame")
logoContainer.Name = "LogoContainer"
logoContainer.Parent = logoButton
logoContainer.BackgroundTransparency = 1
logoContainer.Position = UDim2.new(0, 0, 0, 0)
logoContainer.Size = UDim2.new(1, 0, 1, 0)

-- Option 1: Custom Text Logo
local logoText = Instance.new("TextLabel")
logoText.Name = "LogoText"
logoText.Parent = logoContainer
logoText.BackgroundTransparency = 1
logoText.Position = UDim2.new(0, 0, 0, 0)
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.Font = Enum.Font.GothamBold
logoText.Text = "JS" -- Juned System initials
logoText.TextColor3 = colors.text
logoText.TextSize = 18
logoText.TextScaled = true

-- Option 2: Logo Icon (commented by default, you can enable this)
--[[
local logoIcon = Instance.new("ImageLabel")
logoIcon.Name = "LogoIcon"
logoIcon.Parent = logoContainer
logoIcon.BackgroundTransparency = 1
logoIcon.Position = UDim2.new(0, 10, 0, 10)
logoIcon.Size = UDim2.new(0, 30, 0, 30)
logoIcon.Image = "rbxassetid://7733658448" -- Settings/gear icon
logoIcon.ImageColor3 = colors.text
--]]

-- Option 3: Combination Text + Icon (commented by default)
--[[
local logoIcon = Instance.new("ImageLabel")
logoIcon.Name = "LogoIcon"
logoIcon.Parent = logoContainer
logoIcon.BackgroundTransparency = 1
logoIcon.Position = UDim2.new(0, 5, 0, 5)
logoIcon.Size = UDim2.new(0, 20, 0, 20)
logoIcon.Image = "rbxassetid://7733658448"
logoIcon.ImageColor3 = colors.text

local logoSmallText = Instance.new("TextLabel")
logoSmallText.Name = "LogoSmallText"
logoSmallText.Parent = logoContainer
logoSmallText.BackgroundTransparency = 1
logoSmallText.Position = UDim2.new(0, 25, 0, 15)
logoSmallText.Size = UDim2.new(0, 20, 0, 20)
logoSmallText.Font = Enum.Font.GothamBold
logoSmallText.Text = "JS"
logoSmallText.TextColor3 = colors.text
logoSmallText.TextSize = 12
--]]

-- Status Indicator on Logo
local logoStatusIndicator = Instance.new("Frame")
logoStatusIndicator.Name = "LogoStatusIndicator"
logoStatusIndicator.Parent = logoButton
logoStatusIndicator.BackgroundColor3 = colors.text_dim
logoStatusIndicator.BorderSizePixel = 0
logoStatusIndicator.Position = UDim2.new(1, -8, 0, 8)
logoStatusIndicator.Size = UDim2.new(0, 6, 0, 6)

local logoStatusCorner = Instance.new("UICorner")
logoStatusCorner.CornerRadius = UDim.new(0.5, 0)
logoStatusCorner.Parent = logoStatusIndicator

-- Main Panel Container (Initially Hidden)
local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Parent = screenGui
mainPanel.BackgroundColor3 = colors.primary
mainPanel.BorderSizePixel = 1
mainPanel.BorderColor3 = colors.accent
mainPanel.Position = UDim2.new(1, -340, 0, 20)
mainPanel.Size = panelSize
mainPanel.Visible = false
mainPanel.Active = true
mainPanel.Draggable = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 4)
mainCorner.Parent = mainPanel

-- Scrolling Frame Container
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Parent = mainPanel
scrollFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.Position = UDim2.new(0, 0, 0, 50) -- Start below header
scrollFrame.Size = UDim2.new(1, 0, 1, -50) -- Full size minus header
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = colors.accent
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.BottomImage = "rbxasset://textures/Scroll/scroll-middle.png"
scrollFrame.MidImage = "rbxasset://textures/Scroll/scroll-middle.png"
scrollFrame.TopImage = "rbxasset://textures/Scroll/scroll-middle.png"
scrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Header Section
local headerFrame = Instance.new("Frame")
headerFrame.Name = "HeaderFrame"
headerFrame.Parent = mainPanel
headerFrame.BackgroundColor3 = colors.secondary
headerFrame.BorderSizePixel = 0
headerFrame.Position = UDim2.new(0, 0, 0, 0)
headerFrame.Size = UDim2.new(1, 0, 0, 50)

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 4)
headerCorner.Parent = headerFrame

-- Title Line
local titleLine = Instance.new("Frame")
titleLine.Name = "TitleLine"
titleLine.Parent = headerFrame
titleLine.BackgroundColor3 = colors.accent
titleLine.BorderSizePixel = 0
titleLine.Position = UDim2.new(0, 15, 0, 20)
titleLine.Size = UDim2.new(0, 4, 0, 15)

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = headerFrame
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0, 25, 0, 10)
titleLabel.Size = UDim2.new(0, 280, 0, 30)
titleLabel.Font = Enum.Font.Code
titleLabel.Text = "JUNED SYSTEM"
titleLabel.TextColor3 = colors.text
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Draggable hint text
local dragHint = Instance.new("TextLabel")
dragHint.Name = "DragHint"
dragHint.Parent = headerFrame
dragHint.BackgroundTransparency = 1
dragHint.Position = UDim2.new(0, 0, 0, 30)
dragHint.Size = UDim2.new(1, 0, 0, 20)
dragHint.Font = Enum.Font.Code
dragHint.TextColor3 = colors.text_dim
dragHint.TextSize = 8
dragHint.TextTransparency = 0.5
dragHint.TextXAlignment = Enum.TextXAlignment.Center


-- Status indicator
local statusIndicator = Instance.new("Frame")
statusIndicator.Name = "StatusIndicator"
statusIndicator.Parent = headerFrame
statusIndicator.BackgroundColor3 = colors.text_dim
statusIndicator.BorderSizePixel = 0
statusIndicator.Position = UDim2.new(1, -65, 0, 20)
statusIndicator.Size = UDim2.new(0, 8, 0, 8)

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0.5, 0)
statusCorner.Parent = statusIndicator

-- MAIN Category Section
local mainCategorySection = Instance.new("Frame")
mainCategorySection.Name = "MainCategorySection"
mainCategorySection.Parent = scrollFrame
mainCategorySection.BackgroundColor3 = colors.secondary
mainCategorySection.BorderSizePixel = 1
mainCategorySection.BorderColor3 = colors.accent
mainCategorySection.Position = UDim2.new(0, 15, 0, 10)
mainCategorySection.Size = UDim2.new(0, 290, 0, 35)

local mainCategoryCorner = Instance.new("UICorner")
mainCategoryCorner.CornerRadius = UDim.new(0, 3)
mainCategoryCorner.Parent = mainCategorySection

-- Main Category Header Button (clickable)
local mainCategoryButton = Instance.new("TextButton")
mainCategoryButton.Name = "MainCategoryButton"
mainCategoryButton.Parent = mainCategorySection
mainCategoryButton.BackgroundTransparency = 1
mainCategoryButton.Position = UDim2.new(0, 0, 0, 0)
mainCategoryButton.Size = UDim2.new(1, 0, 1, 0)
mainCategoryButton.Text = ""
mainCategoryButton.Font = Enum.Font.SourceSans
mainCategoryButton.TextSize = 1

-- Expand/Collapse Indicator
local mainCategoryIndicator = Instance.new("TextLabel")
mainCategoryIndicator.Name = "MainCategoryIndicator"
mainCategoryIndicator.Parent = mainCategorySection
mainCategoryIndicator.BackgroundTransparency = 1
mainCategoryIndicator.Position = UDim2.new(0, 10, 0, 8)
mainCategoryIndicator.Size = UDim2.new(0, 20, 0, 20)
mainCategoryIndicator.Font = Enum.Font.Code
mainCategoryIndicator.Text = "▼"
mainCategoryIndicator.TextColor3 = colors.text
mainCategoryIndicator.TextSize = 12
mainCategoryIndicator.TextXAlignment = Enum.TextXAlignment.Left

-- Main Category Header
local mainCategoryLabel = Instance.new("TextLabel")
mainCategoryLabel.Name = "MainCategoryLabel"
mainCategoryLabel.Parent = mainCategorySection
mainCategoryLabel.BackgroundTransparency = 1
mainCategoryLabel.Position = UDim2.new(0, 35, 0, 8)
mainCategoryLabel.Size = UDim2.new(0, 245, 0, 20)
mainCategoryLabel.Font = Enum.Font.Code
mainCategoryLabel.Text = "MAIN"
mainCategoryLabel.TextColor3 = colors.text
mainCategoryLabel.TextSize = 12
mainCategoryLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Speed Control Section (Sub-category of MAIN)
local speedSection = Instance.new("Frame")
speedSection.Name = "SpeedSection"
speedSection.Parent = scrollFrame
speedSection.BackgroundColor3 = colors.secondary
speedSection.BorderSizePixel = 1
speedSection.BorderColor3 = colors.tertiary
speedSection.Position = UDim2.new(0, 15, 0, 50)
speedSection.Size = UDim2.new(0, 290, 0, 100)

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 3)
speedCorner.Parent = speedSection

-- Speed Section Header
local speedSectionLabel = Instance.new("TextLabel")
speedSectionLabel.Name = "SpeedSectionLabel"
speedSectionLabel.Parent = speedSection
speedSectionLabel.BackgroundTransparency = 1
speedSectionLabel.Position = UDim2.new(0, 10, 0, 5)
speedSectionLabel.Size = UDim2.new(0, 270, 0, 20)
speedSectionLabel.Font = Enum.Font.Code
speedSectionLabel.Text = "{01} SPEED_MODULATION"
speedSectionLabel.TextColor3 = colors.text_dim
speedSectionLabel.TextSize = 11
speedSectionLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Switch Container
local toggleContainer = Instance.new("Frame")
toggleContainer.Name = "ToggleContainer"
toggleContainer.Parent = speedSection
toggleContainer.BackgroundTransparency = 1
toggleContainer.Position = UDim2.new(0, 10, 0, 30)
toggleContainer.Size = UDim2.new(0, 270, 0, 25)

-- Toggle Label
local toggleLabel = Instance.new("TextLabel")
toggleLabel.Name = "ToggleLabel"
toggleLabel.Parent = toggleContainer
toggleLabel.BackgroundTransparency = 1
toggleLabel.Position = UDim2.new(0, 0, 0, 0)
toggleLabel.Size = UDim2.new(0, 200, 0, 25)
toggleLabel.Font = Enum.Font.Code
toggleLabel.Text = "ENABLE_SPEED"
toggleLabel.TextColor3 = colors.text
toggleLabel.TextSize = 12
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Switch Background
local toggleSwitchBg = Instance.new("Frame")
toggleSwitchBg.Name = "ToggleSwitchBg"
toggleSwitchBg.Parent = toggleContainer
toggleSwitchBg.BackgroundColor3 = colors.inactive
toggleSwitchBg.BorderSizePixel = 0
toggleSwitchBg.Position = UDim2.new(1, -50, 0, 2.5)
toggleSwitchBg.Size = UDim2.new(0, 45, 0, 20)

local toggleBgCorner = Instance.new("UICorner")
toggleBgCorner.CornerRadius = UDim.new(0, 10)
toggleBgCorner.Parent = toggleSwitchBg

-- Toggle Switch Handle
local toggleSwitch = Instance.new("Frame")
toggleSwitch.Name = "ToggleSwitch"
toggleSwitch.Parent = toggleSwitchBg
toggleSwitch.BackgroundColor3 = colors.text_dim
toggleSwitch.BorderSizePixel = 0
toggleSwitch.Position = UDim2.new(0, 2, 0, 2)
toggleSwitch.Size = UDim2.new(0, 16, 0, 16)

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleSwitch

-- Toggle Button (invisible but clickable)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = toggleContainer
toggleButton.BackgroundTransparency = 1
toggleButton.Position = UDim2.new(1, -50, 0, 0)
toggleButton.Size = UDim2.new(0, 45, 0, 25)
toggleButton.Text = ""
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 1

-- Speed Input Section
local speedInputSection = Instance.new("Frame")
speedInputSection.Name = "SpeedInputSection"
speedInputSection.Parent = speedSection
speedInputSection.BackgroundTransparency = 1
speedInputSection.Position = UDim2.new(0, 10, 0, 60)
speedInputSection.Size = UDim2.new(0, 270, 0, 30)

-- Speed Label
local speedValueLabel = Instance.new("TextLabel")
speedValueLabel.Name = "SpeedValueLabel"
speedValueLabel.Parent = speedInputSection
speedValueLabel.BackgroundTransparency = 1
speedValueLabel.Position = UDim2.new(0, 0, 0, 5)
speedValueLabel.Size = UDim2.new(0, 80, 0, 20)
speedValueLabel.Font = Enum.Font.Code
speedValueLabel.Text = "VAL:" .. originalWalkSpeed
speedValueLabel.TextColor3 = colors.text_dim
speedValueLabel.TextSize = 10
speedValueLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Speed Input
local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Parent = speedInputSection
speedInput.BackgroundColor3 = colors.tertiary
speedInput.BorderSizePixel = 1
speedInput.BorderColor3 = colors.accent
speedInput.Position = UDim2.new(0, 85, 0, 5)
speedInput.Size = UDim2.new(0, 60, 0, 20)
speedInput.Font = Enum.Font.Code
speedInput.PlaceholderText = "0-200"
speedInput.Text = tostring(customWalkSpeed)
speedInput.TextColor3 = colors.text
speedInput.TextSize = 10

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 2)
inputCorner.Parent = speedInput

-- Set Button
local setButton = Instance.new("TextButton")
setButton.Name = "SetButton"
setButton.Parent = speedInputSection
setButton.BackgroundColor3 = colors.tertiary
setButton.BorderSizePixel = 1
setButton.BorderColor3 = colors.accent
setButton.Position = UDim2.new(0, 150, 0, 5)
setButton.Size = UDim2.new(0, 40, 0, 20)
setButton.Font = Enum.Font.Code
setButton.Text = "SET"
setButton.TextColor3 = colors.text
setButton.TextSize = 10

local setCorner = Instance.new("UICorner")
setCorner.CornerRadius = UDim.new(0, 2)
setCorner.Parent = setButton

-- Current Status
local currentStatusLabel = Instance.new("TextLabel")
currentStatusLabel.Name = "CurrentStatusLabel"
currentStatusLabel.Parent = speedInputSection
currentStatusLabel.BackgroundTransparency = 1
currentStatusLabel.Position = UDim2.new(0, 195, 0, 5)
currentStatusLabel.Size = UDim2.new(0, 75, 0, 20)
currentStatusLabel.Font = Enum.Font.Code
currentStatusLabel.Text = "CUR:OFF"
currentStatusLabel.TextColor3 = colors.text_dim
currentStatusLabel.TextSize = 10
currentStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Fly Control Section
local flySection = Instance.new("Frame")
flySection.Name = "FlySection"
flySection.Parent = scrollFrame
flySection.BackgroundColor3 = colors.secondary
flySection.BorderSizePixel = 1
flySection.BorderColor3 = colors.tertiary
flySection.Position = UDim2.new(0, 15, 0, 160)
flySection.Size = UDim2.new(0, 290, 0, 90)

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 3)
flyCorner.Parent = flySection

-- Fly Section Header
local flySectionLabel = Instance.new("TextLabel")
flySectionLabel.Name = "FlySectionLabel"
flySectionLabel.Parent = flySection
flySectionLabel.BackgroundTransparency = 1
flySectionLabel.Position = UDim2.new(0, 10, 0, 5)
flySectionLabel.Size = UDim2.new(0, 270, 0, 20)
flySectionLabel.Font = Enum.Font.Code
flySectionLabel.Text = "{02} FLY_JUMP"
flySectionLabel.TextColor3 = colors.text_dim
flySectionLabel.TextSize = 11
flySectionLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Fly Toggle Switch Container
local flyToggleContainer = Instance.new("Frame")
flyToggleContainer.Name = "FlyToggleContainer"
flyToggleContainer.Parent = flySection
flyToggleContainer.BackgroundTransparency = 1
flyToggleContainer.Position = UDim2.new(0, 10, 0, 30)
flyToggleContainer.Size = UDim2.new(0, 270, 0, 25)

-- Fly Toggle Label
local flyToggleLabel = Instance.new("TextLabel")
flyToggleLabel.Name = "FlyToggleLabel"
flyToggleLabel.Parent = flyToggleContainer
flyToggleLabel.BackgroundTransparency = 1
flyToggleLabel.Position = UDim2.new(0, 0, 0, 0)
flyToggleLabel.Size = UDim2.new(0, 200, 0, 25)
flyToggleLabel.Font = Enum.Font.Code
flyToggleLabel.Text = "FLY MODE"
flyToggleLabel.TextColor3 = colors.text
flyToggleLabel.TextSize = 12
flyToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Fly Toggle Switch Background
local flyToggleSwitchBg = Instance.new("Frame")
flyToggleSwitchBg.Name = "FlyToggleSwitchBg"
flyToggleSwitchBg.Parent = flyToggleContainer
flyToggleSwitchBg.BackgroundColor3 = colors.inactive
flyToggleSwitchBg.BorderSizePixel = 0
flyToggleSwitchBg.Position = UDim2.new(1, -50, 0, 2.5)
flyToggleSwitchBg.Size = UDim2.new(0, 45, 0, 20)

local flyToggleBgCorner = Instance.new("UICorner")
flyToggleBgCorner.CornerRadius = UDim.new(0, 10)
flyToggleBgCorner.Parent = flyToggleSwitchBg

-- Fly Toggle Switch Handle
local flyToggleSwitch = Instance.new("Frame")
flyToggleSwitch.Name = "FlyToggleSwitch"
flyToggleSwitch.Parent = flyToggleSwitchBg
flyToggleSwitch.BackgroundColor3 = colors.text_dim
flyToggleSwitch.BorderSizePixel = 0
flyToggleSwitch.Position = UDim2.new(0, 2, 0, 2)
flyToggleSwitch.Size = UDim2.new(0, 16, 0, 16)

local flyToggleCorner = Instance.new("UICorner")
flyToggleCorner.CornerRadius = UDim.new(0, 8)
flyToggleCorner.Parent = flyToggleSwitch

-- Fly Toggle Button (invisible but clickable)
local flyToggleInvisibleButton = Instance.new("TextButton")
flyToggleInvisibleButton.Name = "FlyToggleInvisibleButton"
flyToggleInvisibleButton.Parent = flyToggleContainer
flyToggleInvisibleButton.BackgroundTransparency = 1
flyToggleInvisibleButton.Position = UDim2.new(1, -50, 0, 0)
flyToggleInvisibleButton.Size = UDim2.new(0, 45, 0, 25)
flyToggleInvisibleButton.Text = ""
flyToggleInvisibleButton.Font = Enum.Font.SourceSans
flyToggleInvisibleButton.TextSize = 1

-- Fly Speed Input
local flySpeedInput = Instance.new("TextBox")
flySpeedInput.Name = "FlySpeedInput"
flySpeedInput.Parent = flySection
flySpeedInput.BackgroundColor3 = colors.tertiary
flySpeedInput.BorderSizePixel = 1
flySpeedInput.BorderColor3 = colors.accent
flySpeedInput.Position = UDim2.new(0, 10, 0, 60)
flySpeedInput.Size = UDim2.new(0, 60, 0, 20)
flySpeedInput.Font = Enum.Font.Code
flySpeedInput.PlaceholderText="VELOCITY"
flySpeedInput.Text = tostring(flySpeed)
flySpeedInput.TextColor3 = colors.text
flySpeedInput.TextSize = 10

local flyInputCorner = Instance.new("UICorner")
flyInputCorner.CornerRadius = UDim.new(0, 2)
flyInputCorner.Parent = flySpeedInput

-- Fly Controls Info
local flyControlsInfo = Instance.new("TextLabel")
flyControlsInfo.Name = "FlyControlsInfo"
flyControlsInfo.Parent = flySection
flyControlsInfo.BackgroundTransparency = 1
flyControlsInfo.Position = UDim2.new(0, 75, 0, 60)  -- Moved to right of input field
flyControlsInfo.Size = UDim2.new(0, 205, 0, 20)   -- Adjusted width
flyControlsInfo.Font = Enum.Font.Code
flyControlsInfo.Text = "W:FORWARD S:BACK A:LEFT D:RIGHT SPACE:UP SHIFT:DOWN"
flyControlsInfo.TextColor3 = colors.text_dim
flyControlsInfo.TextSize = 9

-- Jump Control Section
local jumpSection = Instance.new("Frame")
jumpSection.Name = "JumpSection"
jumpSection.Parent = scrollFrame
jumpSection.BackgroundColor3 = colors.secondary
jumpSection.BorderSizePixel = 1
jumpSection.BorderColor3 = colors.tertiary
jumpSection.Position = UDim2.new(0, 15, 0, 260)
jumpSection.Size = UDim2.new(0, 290, 0, 90)

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0, 3)
jumpCorner.Parent = jumpSection

-- Jump Section Header
local jumpSectionLabel = Instance.new("TextLabel")
jumpSectionLabel.Name = "JumpSectionLabel"
jumpSectionLabel.Parent = jumpSection
jumpSectionLabel.BackgroundTransparency = 1
jumpSectionLabel.Position = UDim2.new(0, 10, 0, 5)
jumpSectionLabel.Size = UDim2.new(0, 270, 0, 20)
jumpSectionLabel.Font = Enum.Font.Code
jumpSectionLabel.Text = "{03} VERTICAL_PROPULSION"
jumpSectionLabel.TextColor3 = colors.text_dim
jumpSectionLabel.TextSize = 11
jumpSectionLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Infinity Jump Toggle Container
local infinityToggleContainer = Instance.new("Frame")
infinityToggleContainer.Name = "InfinityToggleContainer"
infinityToggleContainer.Parent = jumpSection
infinityToggleContainer.BackgroundTransparency = 1
infinityToggleContainer.Position = UDim2.new(0, 10, 0, 30)
infinityToggleContainer.Size = UDim2.new(0, 270, 0, 25)

-- Infinity Toggle Label
local infinityToggleLabel = Instance.new("TextLabel")
infinityToggleLabel.Name = "InfinityToggleLabel"
infinityToggleLabel.Parent = infinityToggleContainer
infinityToggleLabel.BackgroundTransparency = 1
infinityToggleLabel.Position = UDim2.new(0, 0, 0, 0)
infinityToggleLabel.Size = UDim2.new(0, 200, 0, 25)
infinityToggleLabel.Font = Enum.Font.Code
infinityToggleLabel.Text = "INFINITE_JUMP"
infinityToggleLabel.TextColor3 = colors.text
infinityToggleLabel.TextSize = 11
infinityToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Infinity Toggle Switch Background
local infinityToggleSwitchBg = Instance.new("Frame")
infinityToggleSwitchBg.Name = "InfinityToggleSwitchBg"
infinityToggleSwitchBg.Parent = infinityToggleContainer
infinityToggleSwitchBg.BackgroundColor3 = colors.inactive
infinityToggleSwitchBg.BorderSizePixel = 0
infinityToggleSwitchBg.Position = UDim2.new(1, -50, 0, 2.5)
infinityToggleSwitchBg.Size = UDim2.new(0, 45, 0, 20)

local infinityToggleBgCorner = Instance.new("UICorner")
infinityToggleBgCorner.CornerRadius = UDim.new(0, 10)
infinityToggleBgCorner.Parent = infinityToggleSwitchBg

-- Infinity Toggle Switch Handle
local infinityToggleSwitch = Instance.new("Frame")
infinityToggleSwitch.Name = "InfinityToggleSwitch"
infinityToggleSwitch.Parent = infinityToggleSwitchBg
infinityToggleSwitch.BackgroundColor3 = colors.text_dim
infinityToggleSwitch.BorderSizePixel = 0
infinityToggleSwitch.Position = UDim2.new(0, 2, 0, 2)
infinityToggleSwitch.Size = UDim2.new(0, 16, 0, 16)

local infinityToggleCorner = Instance.new("UICorner")
infinityToggleCorner.CornerRadius = UDim.new(0, 8)
infinityToggleCorner.Parent = infinityToggleSwitch

-- Infinity Toggle Button (invisible but clickable)
local infinityToggleInvisibleButton = Instance.new("TextButton")
infinityToggleInvisibleButton.Name = "InfinityToggleInvisibleButton"
infinityToggleInvisibleButton.Parent = infinityToggleContainer
infinityToggleInvisibleButton.BackgroundTransparency = 1
infinityToggleInvisibleButton.Position = UDim2.new(1, -50, 0, 0)
infinityToggleInvisibleButton.Size = UDim2.new(0, 45, 0, 25)
infinityToggleInvisibleButton.Text = ""
infinityToggleInvisibleButton.Font = Enum.Font.SourceSans
infinityToggleInvisibleButton.TextSize = 1

-- Jump Power Display
local jumpPowerDisplay = Instance.new("TextLabel")
jumpPowerDisplay.Name = "JumpPowerDisplay"
jumpPowerDisplay.Parent = jumpSection
jumpPowerDisplay.BackgroundTransparency = 1
jumpPowerDisplay.Position = UDim2.new(0, 10, 0, 60)
jumpPowerDisplay.Size = UDim2.new(0, 270, 0, 20)
jumpPowerDisplay.Font = Enum.Font.Code
jumpPowerDisplay.Text = "POWER: " .. defaultJumpPower .. " | STATUS: INACTIVE"
jumpPowerDisplay.TextColor3 = colors.text
jumpPowerDisplay.TextSize = 9



-- LOCALPLAYER Category Section
local localPlayerCategorySection = Instance.new("Frame")
localPlayerCategorySection.Name = "LocalPlayerCategorySection"
localPlayerCategorySection.Parent = scrollFrame
localPlayerCategorySection.BackgroundColor3 = colors.secondary
localPlayerCategorySection.BorderSizePixel = 1
localPlayerCategorySection.BorderColor3 = colors.accent
localPlayerCategorySection.Position = UDim2.new(0, 15, 0, 475)
localPlayerCategorySection.Size = UDim2.new(0, 290, 0, 35)

local localPlayerCategoryCorner = Instance.new("UICorner")
localPlayerCategoryCorner.CornerRadius = UDim.new(0, 3)
localPlayerCategoryCorner.Parent = localPlayerCategorySection

-- LocalPlayer Category Header Button (clickable)
local localPlayerCategoryButton = Instance.new("TextButton")
localPlayerCategoryButton.Name = "LocalPlayerCategoryButton"
localPlayerCategoryButton.Parent = localPlayerCategorySection
localPlayerCategoryButton.BackgroundTransparency = 1
localPlayerCategoryButton.Position = UDim2.new(0, 0, 0, 0)
localPlayerCategoryButton.Size = UDim2.new(1, 0, 1, 0)
localPlayerCategoryButton.Text = ""
localPlayerCategoryButton.Font = Enum.Font.SourceSans
localPlayerCategoryButton.TextSize = 1

-- LocalPlayer Expand/Collapse Indicator
local localPlayerCategoryIndicator = Instance.new("TextLabel")
localPlayerCategoryIndicator.Name = "LocalPlayerCategoryIndicator"
localPlayerCategoryIndicator.Parent = localPlayerCategorySection
localPlayerCategoryIndicator.BackgroundTransparency = 1
localPlayerCategoryIndicator.Position = UDim2.new(0, 10, 0, 8)
localPlayerCategoryIndicator.Size = UDim2.new(0, 20, 0, 20)
localPlayerCategoryIndicator.Font = Enum.Font.Code
localPlayerCategoryIndicator.Text = "▼"
localPlayerCategoryIndicator.TextColor3 = colors.text
localPlayerCategoryIndicator.TextSize = 12
localPlayerCategoryIndicator.TextXAlignment = Enum.TextXAlignment.Left

-- LocalPlayer Category Header
local localPlayerCategoryLabel = Instance.new("TextLabel")
localPlayerCategoryLabel.Name = "LocalPlayerCategoryLabel"
localPlayerCategoryLabel.Parent = localPlayerCategorySection
localPlayerCategoryLabel.BackgroundTransparency = 1
localPlayerCategoryLabel.Position = UDim2.new(0, 35, 0, 8)
localPlayerCategoryLabel.Size = UDim2.new(0, 245, 0, 20)
localPlayerCategoryLabel.Font = Enum.Font.Code
localPlayerCategoryLabel.Text = "LOCALPLAYER"
localPlayerCategoryLabel.TextColor3 = colors.text
localPlayerCategoryLabel.TextSize = 12
localPlayerCategoryLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Line Player Section (Sub-category of LOCALPLAYER)
local linePlayerSection = Instance.new("Frame")
linePlayerSection.Name = "LinePlayerSection"
linePlayerSection.Parent = scrollFrame
linePlayerSection.BackgroundColor3 = colors.secondary
linePlayerSection.BorderSizePixel = 1
linePlayerSection.BorderColor3 = colors.tertiary
linePlayerSection.Position = UDim2.new(0, 15, 0, 515)
linePlayerSection.Size = UDim2.new(0, 290, 0, 80)

local linePlayerCorner = Instance.new("UICorner")
linePlayerCorner.CornerRadius = UDim.new(0, 3)
linePlayerCorner.Parent = linePlayerSection

-- Line Player Section Header
local linePlayerSectionLabel = Instance.new("TextLabel")
linePlayerSectionLabel.Name = "LinePlayerSectionLabel"
linePlayerSectionLabel.Parent = linePlayerSection
linePlayerSectionLabel.BackgroundTransparency = 1
linePlayerSectionLabel.Position = UDim2.new(0, 10, 0, 5)
linePlayerSectionLabel.Size = UDim2.new(0, 270, 0, 20)
linePlayerSectionLabel.Font = Enum.Font.Code
linePlayerSectionLabel.Text = "{01} LINE_PLAYER_ON_HEAD"
linePlayerSectionLabel.TextColor3 = colors.text_dim
linePlayerSectionLabel.TextSize = 11
linePlayerSectionLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Line Player Toggle Container
local linePlayerToggleContainer = Instance.new("Frame")
linePlayerToggleContainer.Name = "LinePlayerToggleContainer"
linePlayerToggleContainer.Parent = linePlayerSection
linePlayerToggleContainer.BackgroundTransparency = 1
linePlayerToggleContainer.Position = UDim2.new(0, 10, 0, 30)
linePlayerToggleContainer.Size = UDim2.new(0, 270, 0, 25)

-- Line Player Toggle Label
local linePlayerToggleLabel = Instance.new("TextLabel")
linePlayerToggleLabel.Name = "LinePlayerToggleLabel"
linePlayerToggleLabel.Parent = linePlayerToggleContainer
linePlayerToggleLabel.BackgroundTransparency = 1
linePlayerToggleLabel.Position = UDim2.new(0, 0, 0, 0)
linePlayerToggleLabel.Size = UDim2.new(0, 200, 0, 25)
linePlayerToggleLabel.Font = Enum.Font.Code
linePlayerToggleLabel.Text = "SHOW_PLAYER_LINES"
linePlayerToggleLabel.TextColor3 = colors.text
linePlayerToggleLabel.TextSize = 12
linePlayerToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Line Player Toggle Switch Background
local linePlayerToggleSwitchBg = Instance.new("Frame")
linePlayerToggleSwitchBg.Name = "LinePlayerToggleSwitchBg"
linePlayerToggleSwitchBg.Parent = linePlayerToggleContainer
linePlayerToggleSwitchBg.BackgroundColor3 = colors.inactive
linePlayerToggleSwitchBg.BorderSizePixel = 0
linePlayerToggleSwitchBg.Position = UDim2.new(1, -50, 0, 2.5)
linePlayerToggleSwitchBg.Size = UDim2.new(0, 45, 0, 20)

local linePlayerToggleBgCorner = Instance.new("UICorner")
linePlayerToggleBgCorner.CornerRadius = UDim.new(0, 10)
linePlayerToggleBgCorner.Parent = linePlayerToggleSwitchBg

-- Line Player Toggle Switch Handle
local linePlayerToggleSwitch = Instance.new("Frame")
linePlayerToggleSwitch.Name = "LinePlayerToggleSwitch"
linePlayerToggleSwitch.Parent = linePlayerToggleSwitchBg
linePlayerToggleSwitch.BackgroundColor3 = colors.text_dim
linePlayerToggleSwitch.BorderSizePixel = 0
linePlayerToggleSwitch.Position = UDim2.new(0, 2, 0, 2)
linePlayerToggleSwitch.Size = UDim2.new(0, 16, 0, 16)

local linePlayerToggleCorner = Instance.new("UICorner")
linePlayerToggleCorner.CornerRadius = UDim.new(0, 8)
linePlayerToggleCorner.Parent = linePlayerToggleSwitch

-- Line Player Toggle Button (invisible but clickable)
local linePlayerToggleInvisibleButton = Instance.new("TextButton")
linePlayerToggleInvisibleButton.Name = "LinePlayerToggleInvisibleButton"
linePlayerToggleInvisibleButton.Parent = linePlayerToggleContainer
linePlayerToggleInvisibleButton.BackgroundTransparency = 1
linePlayerToggleInvisibleButton.Position = UDim2.new(1, -50, 0, 0)
linePlayerToggleInvisibleButton.Size = UDim2.new(0, 45, 0, 25)
linePlayerToggleInvisibleButton.Text = ""
linePlayerToggleInvisibleButton.Font = Enum.Font.SourceSans
linePlayerToggleInvisibleButton.TextSize = 1

-- Line Player Status Display
local linePlayerStatusDisplay = Instance.new("TextLabel")
linePlayerStatusDisplay.Name = "LinePlayerStatusDisplay"
linePlayerStatusDisplay.Parent = linePlayerSection
linePlayerStatusDisplay.BackgroundTransparency = 1
linePlayerStatusDisplay.Position = UDim2.new(0, 10, 0, 55)
linePlayerStatusDisplay.Size = UDim2.new(0, 270, 0, 20)
linePlayerStatusDisplay.Font = Enum.Font.Code
linePlayerStatusDisplay.Text = "PLAYERS: 0 | STATUS: INACTIVE"
linePlayerStatusDisplay.TextColor3 = colors.text
linePlayerStatusDisplay.TextSize = 9

-- Teleport Section (Sub-category of LOCALPLAYER)
local teleportSection = Instance.new("Frame")
teleportSection.Name = "TeleportSection"
teleportSection.Parent = scrollFrame
teleportSection.BackgroundColor3 = colors.secondary
teleportSection.BorderSizePixel = 1
teleportSection.BorderColor3 = colors.tertiary
teleportSection.Position = UDim2.new(0, 15, 0, 685)  -- Will be positioned by updateCategoryPositions
teleportSection.Size = UDim2.new(0, 290, 0, 180)

local teleportCorner = Instance.new("UICorner")
teleportCorner.CornerRadius = UDim.new(0, 3)
teleportCorner.Parent = teleportSection

-- Teleport Section Header
local teleportSectionLabel = Instance.new("TextLabel")
teleportSectionLabel.Name = "TeleportSectionLabel"
teleportSectionLabel.Parent = teleportSection
teleportSectionLabel.BackgroundTransparency = 1
teleportSectionLabel.Position = UDim2.new(0, 10, 0, 5)
teleportSectionLabel.Size = UDim2.new(0, 240, 0, 20)
teleportSectionLabel.Font = Enum.Font.Code
teleportSectionLabel.Text = "{02} PLAYER_TELEPORT"
teleportSectionLabel.TextColor3 = colors.text_dim
teleportSectionLabel.TextSize = 11
teleportSectionLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Teleport Refresh Button
local teleportRefreshButton = Instance.new("TextButton")
teleportRefreshButton.Name = "TeleportRefreshButton"
teleportRefreshButton.Parent = teleportSection
teleportRefreshButton.BackgroundColor3 = colors.tertiary
teleportRefreshButton.BorderSizePixel = 1
teleportRefreshButton.BorderColor3 = colors.secondary
teleportRefreshButton.Position = UDim2.new(0, 255, 0, 5)
teleportRefreshButton.Size = UDim2.new(0, 25, 0, 20)
teleportRefreshButton.Font = Enum.Font.Code
teleportRefreshButton.Text = "⟳"
teleportRefreshButton.TextColor3 = colors.text_dim
teleportRefreshButton.TextSize = 12
teleportRefreshButton.ZIndex = 3
local teleportRefreshCorner = Instance.new("UICorner")
teleportRefreshCorner.CornerRadius = UDim.new(0, 2)
teleportRefreshCorner.Parent = teleportRefreshButton

-- Player List Container
local playerListContainer = Instance.new("Frame")
playerListContainer.Name = "PlayerListContainer"
playerListContainer.Parent = teleportSection
playerListContainer.BackgroundColor3 = colors.tertiary
playerListContainer.BorderSizePixel = 0
playerListContainer.Position = UDim2.new(0, 10, 0, 30)
playerListContainer.Size = UDim2.new(0, 270, 0, 100)

local playerListCorner = Instance.new("UICorner")
playerListCorner.CornerRadius = UDim.new(0, 2)
playerListCorner.Parent = playerListContainer

-- Player List ScrollFrame
local playerListScroll = Instance.new("ScrollingFrame")
playerListScroll.Name = "PlayerListScroll"
playerListScroll.Parent = playerListContainer
playerListScroll.BackgroundColor3 = colors.tertiary
playerListScroll.BackgroundTransparency = 0
playerListScroll.BorderSizePixel = 0
playerListScroll.Position = UDim2.new(0, 0, 0, 0)
playerListScroll.Size = UDim2.new(1, 0, 1, 0)
playerListScroll.ScrollBarThickness = 4
playerListScroll.ScrollBarImageColor3 = colors.accent
playerListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Teleport Button
local teleportButton = Instance.new("TextButton")
teleportButton.Name = "TeleportButton"
teleportButton.Parent = teleportSection
teleportButton.BackgroundColor3 = colors.active
teleportButton.BorderSizePixel = 1
teleportButton.BorderColor3 = colors.accent
teleportButton.Position = UDim2.new(0, 10, 0, 140)
teleportButton.Size = UDim2.new(0, 270, 0, 25)
teleportButton.Font = Enum.Font.Code
teleportButton.Text = "TELEPORT TO PLAYER"
teleportButton.TextColor3 = colors.text
teleportButton.TextSize = 11
teleportButton.Active = false  -- Disabled until player is selected

local teleportButtonCorner = Instance.new("UICorner")
teleportButtonCorner.CornerRadius = UDim.new(0, 2)
teleportButtonCorner.Parent = teleportButton

-- Selected Player Display
local selectedPlayerDisplay = Instance.new("TextLabel")
selectedPlayerDisplay.Name = "SelectedPlayerDisplay"
selectedPlayerDisplay.Parent = teleportSection
selectedPlayerDisplay.BackgroundTransparency = 1
selectedPlayerDisplay.Position = UDim2.new(0, 10, 0, 170)
selectedPlayerDisplay.Size = UDim2.new(0, 270, 0, 15)
selectedPlayerDisplay.Font = Enum.Font.Code
selectedPlayerDisplay.Text = "SELECTED: NONE"
selectedPlayerDisplay.TextColor3 = colors.text_dim
selectedPlayerDisplay.TextSize = 9



-- Line Player Functions
local function updateLinePlayerToggleSwitch(enabled)
    if enabled then
        TweenService:Create(linePlayerToggleSwitch, TweenInfo.new(0.3), {Position = UDim2.new(0, 27, 0, 2)}):Play()
        TweenService:Create(linePlayerToggleSwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = colors.active}):Play()
        linePlayerToggleSwitch.BackgroundColor3 = colors.text
    else
        TweenService:Create(linePlayerToggleSwitch, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0, 2)}):Play()
        TweenService:Create(linePlayerToggleSwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = colors.inactive}):Play()
        linePlayerToggleSwitch.BackgroundColor3 = colors.text_dim
    end
end

local function createPlayerLine(targetPlayer)
    -- Don't create line for local player (admin) itself
    if targetPlayer == player then return end

    if not targetPlayer or not targetPlayer.Character then return end

    local targetCharacter = targetPlayer.Character
    local targetHead = targetCharacter:FindFirstChild("Head")
    if not targetHead then return end

    -- Check local player character
    local localCharacter = player.Character
    if not localCharacter then return end

    local localHead = localCharacter:FindFirstChild("Head")
    if not localHead then return end

    -- Remove existing line and name display for this player
    if playerLines[targetPlayer] then
        playerLines[targetPlayer].Line:Destroy()
        playerLines[targetPlayer].NameDisplay:Destroy()
        playerLines[targetPlayer].Box:Destroy()
    end

    -- Create new line
    local line = Instance.new("Beam")
    line.Name = "PlayerLine_" .. targetPlayer.Name
    line.Parent = Workspace.CurrentCamera

    -- Create attachments
    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "LineStart"
    attachment0.Parent = targetHead

    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "LineEnd"
    attachment1.Parent = localHead

    -- Determine player gender by checking multiple characteristics (most reliable method available)
    local isFemale = false
    local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        -- First check for female-specific accessories
        for _, child in pairs(targetCharacter:GetChildren()) do
            if child:IsA("Accessory") then
                local accessoryType = child.AccessoryType or Enum.AccessoryType.Unknown
                -- Check for accessories that are typically female-specific
                if accessoryType == Enum.AccessoryType.Hair or 
                   accessoryType == Enum.AccessoryType.Hat or
                   string.find(string.lower(child.Name), "hair") or
                   string.find(string.lower(child.Name), "curl") or
                   string.find(string.lower(child.Name), "bun") or
                   string.find(string.lower(child.Name), "ponytail") or
                   string.find(string.lower(child.Name), "pigtails") or
                   string.find(string.lower(child.Name), "braided") or
                   string.find(string.lower(child.Name), "flow") then
                    isFemale = true
                    break
                end
            end
        end
        
        -- If no gender-specific accessories found, try to determine based on proportions
        if not isFemale then
            local bodyTypeScale = humanoid.BodyTypeScale
            local headScale = humanoid.HeadScale
            
            -- If body type scale is smaller or head scale is proportionally larger, it might indicate female
            if bodyTypeScale and headScale then
                -- This is a heuristic - different body types might indicate gender
                if bodyTypeScale.Value < 0.9 or headScale.Value > 1.2 then
                    isFemale = true
                end
            end
        end
        
        -- Additional check: examine the character's body mesh to determine gender
        -- Some R6/R15 characters have different mesh types for male/female
        local torso = targetCharacter:FindFirstChild("Torso") or targetCharacter:FindFirstChild("UpperTorso") or targetCharacter:FindFirstChild("LowerTorso")
        if torso then
            for _, part in pairs(torso:GetChildren()) do
                if part:IsA("SpecialMesh") then
                    -- Check if this mesh is typically associated with female characters
                    if string.find(string.lower(part.MeshId), "female") or string.find(string.lower(part.MeshId), "girl") then
                        isFemale = true
                        break
                    end
                end
            end
        end
    end
    
    -- As a final fallback to ensure color variety, if no visual gender indicators are found,
    -- assign based on player's UserId to ensure we see both colors
    if not isFemale then
        -- Use UserId to create a deterministic assignment that ensures variety
        isFemale = (targetPlayer.UserId % 2 == 0)  -- Even userIds = female (pink), odd = male (green)
    end
    
    -- Determine line color based on gender
    local lineColor
    if isFemale then
        -- Pink line for female
        lineColor = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 105, 180)), -- Pink at target player
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 182, 193)), -- Light pink in middle
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 100))  -- Green at local player
        })
    else
        -- Green line for male
        lineColor = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 205, 50)), -- Green at target player
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(144, 238, 144)), -- Light green in middle
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 100))  -- Green at local player
        })
    end

    -- Configure line - connect target player to local player (admin)
    line.Attachment0 = attachment0
    line.Attachment1 = attachment1
    line.Color = lineColor
    line.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2), -- More visible at target
        NumberSequenceKeypoint.new(0.5, 0.15), -- Most visible in middle
        NumberSequenceKeypoint.new(1, 0.2)  -- More visible at local player
    })
    line.Width0 = 0.3
    line.Width1 = 0.3
    line.FaceCamera = true
    line.LightInfluence = 0.5
    line.LightEmission = 0.2

    -- Create name display above head using BillboardGui
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "PlayerNameDisplay_" .. targetPlayer.Name
    billboardGui.Parent = targetHead
    billboardGui.Size = UDim2.new(0, 150, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 5, 0) -- Position above the head
    billboardGui.AlwaysOnTop = true
    billboardGui.ExtentsOffset = Vector3.new(5, 5, 5) -- Make it visible from further away
    billboardGui.MaxDistance = 500 -- Increase max distance for visibility

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "PlayerNameLabel"
    nameLabel.Parent = billboardGui
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.Text = targetPlayer.DisplayName
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.BackgroundTransparency = 1
    nameLabel.BorderSizePixel = 0
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    -- Create 3D box around the player character
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "PlayerBox_" .. targetPlayer.Name
    box.Parent = targetCharacter
    box.Adornee = targetCharacter
    box.AlwaysOnTop = true
    box.Size = Vector3.new(4, 6, 3) -- Standard humanoid size
    box.Color3 = Color3.fromRGB(255, 100, 100) -- Red color for visibility
    box.Transparency = 0.5  -- Reduced transparency for better visibility
    box.ZIndex = 0
    box.Visible = true -- Ensure it's visible

    -- Store both line and name display in the playerLines table
    playerLines[targetPlayer] = {
        Line = line,
        NameDisplay = billboardGui,
        Box = box
    }
end

local function removePlayerLine(targetPlayer)
    if playerLines[targetPlayer] then
        local playerData = playerLines[targetPlayer]
        if playerData.Line then
            playerData.Line:Destroy()
        end
        if playerData.NameDisplay then
            playerData.NameDisplay:Destroy()
        end
        if playerData.Box then
            playerData.Box:Destroy()
        end
        playerLines[targetPlayer] = nil
    end
end

local function refreshAllPlayerLines()
    -- Clear existing lines
    for _, line in pairs(playerLines) do
        if line then
            line:Destroy()
        end
    end
    playerLines = {}

    -- Create lines for all players except local player
    local lineCount = 0
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            createPlayerLine(targetPlayer)
            lineCount = lineCount + 1
        end
    end

    -- Update status
    local totalPlayers = #Players:GetPlayers()
    local connectedPlayers = totalPlayers - 1 -- Exclude local player
    linePlayerStatusDisplay.Text = string.format("CONNECTIONS: %d/%d | STATUS: ACTIVE", lineCount, connectedPlayers)
end

local function enableLinePlayer()
    if isLinePlayerEnabled then return end

    isLinePlayerEnabled = true
    updateLinePlayerToggleSwitch(true)

    -- Create lines for all current players
    refreshAllPlayerLines()

    -- Start update loop
    lineUpdateConnection = RunService.Heartbeat:Connect(function()
        if not isLinePlayerEnabled then return end

        -- Update lines for players with valid characters
        for targetPlayer, line in pairs(playerLines) do
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
                -- Line is valid, continue
            else
                -- Remove line for invalid/disconnected player
                removePlayerLine(targetPlayer)
            end
        end

        -- Add lines for new players (except local player)
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= player and not playerLines[targetPlayer] then
                createPlayerLine(targetPlayer)
            end
        end

        -- Update connection count
        local totalPlayers = #Players:GetPlayers()
        local connectedPlayers = totalPlayers - 1 -- Exclude local player
        local activeConnections = 0
        for _, _ in pairs(playerLines) do
            activeConnections = activeConnections + 1
        end
        linePlayerStatusDisplay.Text = string.format("CONNECTIONS: %d/%d | STATUS: ACTIVE", activeConnections, connectedPlayers)
    end)

    if showNotification then
        showNotification("LINE_PLAYER_ON_HEAD: ENABLED")
    end
end

local function disableLinePlayer()
    if not isLinePlayerEnabled then return end

    isLinePlayerEnabled = false
    updateLinePlayerToggleSwitch(false)

    -- Stop update loop
    if lineUpdateConnection then
        lineUpdateConnection:Disconnect()
        lineUpdateConnection = nil
    end

    -- Remove all lines and associated elements
    for targetPlayer, playerData in pairs(playerLines) do
        if playerData.Line then
            playerData.Line:Destroy()
        end
        if playerData.NameDisplay then
            playerData.NameDisplay:Destroy()
        end
        if playerData.Box then
            playerData.Box:Destroy()
        end
    end
    playerLines = {}

    -- Update status
    linePlayerStatusDisplay.Text = "CONNECTIONS: 0/0 | STATUS: INACTIVE"

    if showNotification then
        showNotification("LINE_PLAYER_ON_HEAD: DISABLED")
    end
end

-- Teleport Functions
local function createPlayerButton(targetPlayer, index)
    -- Don't create button for local player (admin)
    if targetPlayer == player then return end

    -- Remove existing button for this player
    if teleportPlayerButtons[targetPlayer] then
        teleportPlayerButtons[targetPlayer]:Destroy()
        teleportPlayerButtons[targetPlayer] = nil
    end

    -- Calculate Y position based on index
    local buttonY = (index - 1) * 22
    print("[TELEPORT_DEBUG] Creating button for " .. targetPlayer.Name .. " at index " .. index .. ", Y position: " .. buttonY)

    -- Create new button
    local playerButton = Instance.new("TextButton")
    playerButton.Name = "PlayerButton_" .. targetPlayer.Name
    playerButton.Parent = playerListScroll
    playerButton.BackgroundColor3 = colors.inactive
    playerButton.BorderSizePixel = 0
    playerButton.Position = UDim2.new(0, 2, 0, buttonY)  -- Position each button below previous one
    playerButton.Size = UDim2.new(1, -4, 0, 20)
    playerButton.Font = Enum.Font.Code
    playerButton.Text = targetPlayer.Name
    playerButton.TextColor3 = colors.text
    playerButton.TextSize = 10
    playerButton.TextXAlignment = Enum.TextXAlignment.Left
    playerButton.TextYAlignment = Enum.TextYAlignment.Center

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 2)
    buttonCorner.Parent = playerButton

    -- Store reference
    teleportPlayerButtons[targetPlayer] = playerButton

    -- Click handler
    playerButton.MouseButton1Click:Connect(function()
        -- Deselect previous player
        if selectedTeleportPlayer and selectedTeleportPlayer ~= targetPlayer then
            if teleportPlayerButtons[selectedTeleportPlayer] then
                teleportPlayerButtons[selectedTeleportPlayer].BackgroundColor3 = colors.inactive
            end
        end

        -- Select new player
        selectedTeleportPlayer = targetPlayer
        playerButton.BackgroundColor3 = colors.active
        teleportButton.Active = true
        teleportButton.BackgroundColor3 = colors.active
        selectedPlayerDisplay.Text = "SELECTED: " .. targetPlayer.Name
        selectedPlayerDisplay.TextColor3 = colors.text
    end)

    -- Hover effects
    playerButton.MouseEnter:Connect(function()
        if selectedTeleportPlayer ~= targetPlayer then
            TweenService:Create(playerButton, TweenInfo.new(0.1), {BackgroundColor3 = colors.tertiary}):Play()
        end
    end)

    playerButton.MouseLeave:Connect(function()
        if selectedTeleportPlayer ~= targetPlayer then
            TweenService:Create(playerButton, TweenInfo.new(0.1), {BackgroundColor3 = colors.inactive}):Play()
        end
    end)
end

local function removePlayerButton(targetPlayer)
    if teleportPlayerButtons[targetPlayer] then
        teleportPlayerButtons[targetPlayer]:Destroy()
        teleportPlayerButtons[targetPlayer] = nil

        -- Clear selection if this player was selected
        if selectedTeleportPlayer == targetPlayer then
            selectedTeleportPlayer = nil
            teleportButton.Active = false
            teleportButton.BackgroundColor3 = colors.inactive
            selectedPlayerDisplay.Text = "SELECTED: NONE"
            selectedPlayerDisplay.TextColor3 = colors.text_dim
        end
    end
end

local function refreshPlayerList()
    -- Clear existing buttons
    for _, button in pairs(teleportPlayerButtons) do
        if button then
            button:Destroy()
        end
    end
    teleportPlayerButtons = {}

    -- Clear selection
    selectedTeleportPlayer = nil
    teleportButton.Active = false
    teleportButton.BackgroundColor3 = colors.inactive
    selectedPlayerDisplay.Text = "SELECTED: NONE"
    selectedPlayerDisplay.TextColor3 = colors.text_dim

    -- Get all players except local player
    local otherPlayers = {}
    local allPlayers = Players:GetPlayers()
    print("[TELEPORT_DEBUG] Total players found: " .. #allPlayers)

    for _, targetPlayer in ipairs(allPlayers) do
        if targetPlayer ~= player then
            table.insert(otherPlayers, targetPlayer)
            print("[TELEPORT_DEBUG] Added player to list: " .. targetPlayer.Name)
        else
            print("[TELEPORT_DEBUG] Skipping local player: " .. targetPlayer.Name)
        end
    end

    print("[TELEPORT_DEBUG] Other players count: " .. #otherPlayers)

    -- Create buttons for all other players
    for i, targetPlayer in ipairs(otherPlayers) do
        createPlayerButton(targetPlayer, i)
    end

    -- Update canvas size based on number of players
    local canvasHeight = #otherPlayers * 22
    playerListScroll.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
end

local function findSafePositionNearTarget(targetPosition, maxRadius)
    -- Helper function to find a safe position near the target
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character}

    -- Try different positions in a spiral pattern
    for radius = 5, maxRadius, 5 do
        for angle = 0, 360, 45 do
            local rad = math.rad(angle)
            local offset = Vector3.new(
                math.cos(rad) * radius,
                0,
                math.sin(rad) * radius
            )
            local testPosition = targetPosition + offset

            -- Check ground at this position
            local rayDown = workspace:Raycast(
                testPosition + Vector3.new(0, 50, 0),
                Vector3.new(0, -100, 0),
                raycastParams
            )

            if rayDown then
                -- Check if there's enough space above ground
                local rayUp = workspace:Raycast(
                    rayDown.Position + Vector3.new(0, 5, 0),
                    Vector3.new(0, 20, 0),
                    raycastParams
                )

                if not rayUp then
                    -- Found a safe position with enough headroom
                    return rayDown.Position + Vector3.new(0, 3, 0)
                end
            end
        end
    end

    return nil -- No safe position found
end

local function teleportToTargetPlayer()
    print("[TELEPORT_DEBUG] Starting teleport function...")

    if not selectedTeleportPlayer then
        print("[TELEPORT_DEBUG] No player selected!")
        if showNotification then showNotification("❌ TELEPORT: TIDAK ADA PLAYER YANG DIPILIH") else print("[TELEPORT] TIDAK ADA PLAYER YANG DIPILIH") end
        return
    end

    print("[TELEPORT_DEBUG] Selected player:", selectedTeleportPlayer.Name)

    -- Check if target player exists and is in the game
    if not selectedTeleportPlayer.Parent then
        print("[TELEPORT_DEBUG] Target player is not in the game!")
        if showNotification then showNotification("❌ TELEPORT: PLAYER SUDAH KELUAR DARI GAME") else print("[TELEPORT] PLAYER SUDAH KELUAR DARI GAME") end
        return
    end

    if not selectedTeleportPlayer.Character then
        print("[TELEPORT_DEBUG] Selected player has no character!")
        if showNotification then
            showNotification("❌ TELEPORT: PLAYER BELUM MEMPUNYAI KARAKTER")
        else
            warn("showNotification function not available")
        end
        return
    end

    local targetCharacter = selectedTeleportPlayer.Character
    local targetHumanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")

    if not targetHumanoidRootPart then
        print("[TELEPORT_DEBUG] Target has no HumanoidRootPart!")
        if showNotification then showNotification("❌ TELEPORT: KARAKTER TARGET RUSAK (TIDAK ADA HUMANOIDROOTPART)") else print("[TELEPORT] KARAKTER TARGET RUSAK (TIDAK ADA HUMANOIDROOTPART)") end
        return
    end

    -- Get local player character
    local localCharacter = player.Character
    if not localCharacter then
        print("[TELEPORT_DEBUG] Local player has no character!")
        if showNotification then showNotification("❌ TELEPORT: KAMU BELUM MEMPUNYAI KARAKTER") else print("[TELEPORT] KAMU BELUM MEMPUNYAI KARAKTER") end
        return
    end

    local localHumanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
    if not localHumanoidRootPart then
        print("[TELEPORT_DEBUG] Local player has no HumanoidRootPart!")
        if showNotification then showNotification("❌ TELEPORT: KARAKTERMU RUSAK (TIDAK ADA HUMANOIDROOTPART)") else print("[TELEPORT] KARAKTERMU RUSAK (TIDAK ADA HUMANOIDROOTPART)") end
        return
    end

    -- Get target position info
    local targetCFrame = targetHumanoidRootPart.CFrame
    local targetPosition = targetCFrame.Position
    local localPosition = localHumanoidRootPart.CFrame.Position
    local distance = (targetPosition - localPosition).Magnitude

    print("[TELEPORT_DEBUG] Target position:", targetPosition)
    print("[TELEPORT_DEBUG] Current local position:", localPosition)
    print("[TELEPORT_DEBUG] Distance to target:", distance)

    -- Display distance info
    if distance < 100 then
        if showNotification then showNotification("📍 JARAK: " .. math.floor(distance) .. " studs - SANGAT DEKAT") else print("[TELEPORT] JARAK: " .. math.floor(distance) .. " studs - SANGAT DEKAT") end
    elseif distance < 1000 then
        if showNotification then showNotification("📍 JARAK: " .. math.floor(distance) .. " studs - SEDANG") else print("[TELEPORT] JARAK: " .. math.floor(distance) .. " studs - SEDANG") end
    else
        if showNotification then showNotification("📍 JARAK: " .. math.floor(distance) .. " studs - JAUH") else print("[TELEPORT] JARAK: " .. math.floor(distance) .. " studs - JAUH") end
    end

    -- Check for workspace streaming limitations
    if distance > 100000 then
        if showNotification then showNotification("⚠️ PERINGATAN: JARAK TERLALU JAUH, TELEPORT MUNGKIN GAGAL") else print("[TELEPORT] PERINGATAN: JARAK TERLALU JAUH, TELEPORT MUNGKIN GAGAL") end
    end

    -- Enhanced teleport strategy with multiple fallback options
    local teleportPositions = {
        -- Priority 1: Direct teleport to player position with various offsets
        {pos = targetCFrame + Vector3.new(0, 5, 0), desc = "di atas player"},
        {pos = targetCFrame + Vector3.new(3, 3, 0), desc = "di samping kanan player"},
        {pos = targetCFrame + Vector3.new(-3, 3, 0), desc = "di samping kiri player"},
        {pos = targetCFrame + Vector3.new(0, 3, 3), desc = "di depan player"},
        {pos = targetCFrame + Vector3.new(0, 3, -3), desc = "di belakang player"},

        -- Priority 2: Higher positions for protected areas
        {pos = targetCFrame + Vector3.new(0, 10, 0), desc = "10 studs di atas player"},
        {pos = targetCFrame + Vector3.new(0, 15, 0), desc = "15 studs di atas player"},
        {pos = targetCFrame + Vector3.new(0, 20, 0), desc = "20 studs di atas player"},

        -- Priority 3: Use target player's camera position as fallback
        {pos = targetCharacter:FindFirstChild("Head") and targetCharacter.Head.CFrame or targetCFrame, desc = "posisi head player"},
    }

    local teleportSuccess = false
    local lastPosition = localPosition

    -- Try all teleport positions
    for i, teleportData in ipairs(teleportPositions) do
        print("[TELEPORT_DEBUG] Trying position", i .. ":", teleportData.desc)

        -- Store original position for rollback
        local originalPosition = localHumanoidRootPart.CFrame

        -- Attempt teleport
        localHumanoidRootPart.CFrame = teleportData.pos

        -- Wait for teleport to register
        wait(0.05)

        -- Check if teleport was successful
        local newPosition = localHumanoidRootPart.CFrame.Position
        local newDistance = (targetPosition - newPosition).Magnitude

        if newDistance < 100 or (newPosition - originalPosition.Position).Magnitude > 10 then
            teleportSuccess = true
            lastPosition = newPosition
            print("[TELEPORT_DEBUG] Teleport successful using:", teleportData.desc)
            if showNotification then showNotification("✅ TELEPORT: BERHASIL " .. teleportData.desc .. " " .. selectedTeleportPlayer.Name:upper()) else print("[TELEPORT] BERHASIL " .. teleportData.desc .. " " .. selectedTeleportPlayer.Name:upper()) end
            break
        else
            print("[TELEPORT_DEBUG] Teleport failed for:", teleportData.desc)
            -- Restore original position for next attempt
            localHumanoidRootPart.CFrame = originalPosition
            wait(0.05)
        end
    end

    -- If all direct attempts failed, try finding safe position nearby
    if not teleportSuccess then
        print("[TELEPORT_DEBUG] Direct teleport failed, searching for safe position...")
        if showNotification then showNotification("🔍 TELEPORT: MENCARI POSISI AMAN TERDEKAT...") else print("[TELEPORT] MENCARI POSISI AMAN TERDEKAT...") end

        local safePosition = findSafePositionNearTarget(targetPosition, 50)

        if safePosition then
            -- Try teleporting to safe position
            localHumanoidRootPart.CFrame = CFrame.new(safePosition)
            wait(0.1)

            local finalDistance = (targetPosition - localHumanoidRootPart.CFrame.Position).Magnitude
            if finalDistance < 100 then
                teleportSuccess = true
                if showNotification then showNotification("✅ TELEPORT: BERHASIL KE POSISI AMAN TERDEKAT (" .. math.floor(finalDistance) .. " studs dari target)") else print("[TELEPORT] BERHASIL KE POSISI AMAN TERDEKAT (" .. math.floor(finalDistance) .. " studs dari target)") end
                print("[TELEPORT_DEBUG] Safe position teleport successful. Distance:", finalDistance)
            else
                if showNotification then showNotification("⚠️ TELEPORT: POSISI AMAN MASIH JAUH (" .. math.floor(finalDistance) .. " studs)") else print("[TELEPORT] POSISI AMAN MASIH JAUH (" .. math.floor(finalDistance) .. " studs)") end
            end
        else
            if showNotification then showNotification("❌ TELEPORT: TIDAK DAPAT MENEMUKAN POSISI AMAN DI SEKITAR TARGET") else print("[TELEPORT] TIDAK DAPAT MENEMUKAN POSISI AMAN DI SEKITAR TARGET") end
        end
    end

    -- Final status
    if teleportSuccess then
        print("[TELEPORT_DEBUG] Final successful position:", localHumanoidRootPart.CFrame.Position)
    else
        if showNotification then showNotification("❌ TELEPORT: SEMUA METODE GAGAL - AREA TERLALU DILINDUNGI") else print("[TELEPORT] SEMUA METODE GAGAL - AREA TERLALU DILINDUNGI") end
        print("[TELEPORT_DEBUG] All teleport methods failed")
    end
end




-- Category Collapse/Expand Functions
local function updateCategoryPositions()
    local speedSectionY = isMainCategoryCollapsed and 50 or 160
    local flySectionY = speedSectionY + (isMainCategoryCollapsed and 0 or 110)
    local jumpSectionY = flySectionY + (isMainCategoryCollapsed and 0 or 90)
    local localPlayerY = jumpSectionY + (isMainCategoryCollapsed and 0 or 120)
    local linePlayerY = localPlayerY + (isLocalPlayerCategoryCollapsed and 0 or 50)
    local teleportY = linePlayerY + (isLocalPlayerCategoryCollapsed and 0 or 85)

    -- Update positions with animation
    local function updatePosition(element, y)
        local currentY = element.Position.Y.Offset
        if currentY ~= y then
            local tween = TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 15, 0, y)
            })
            tween:Play()
        end
    end

    updatePosition(speedSection, speedSectionY)
    updatePosition(flySection, flySectionY)
    updatePosition(jumpSection, jumpSectionY)
    updatePosition(localPlayerCategorySection, localPlayerY)
    updatePosition(linePlayerSection, linePlayerY)
    updatePosition(teleportSection, teleportY)

    -- Update visibility
    speedSection.Visible = not isMainCategoryCollapsed
    flySection.Visible = not isMainCategoryCollapsed
    jumpSection.Visible = not isMainCategoryCollapsed
    linePlayerSection.Visible = not isLocalPlayerCategoryCollapsed
    teleportSection.Visible = not isLocalPlayerCategoryCollapsed
end

local function toggleMainCategory()
    isMainCategoryCollapsed = not isMainCategoryCollapsed

    -- Animate indicator
    if isMainCategoryCollapsed then
        mainCategoryIndicator.Text = "▶"
        TweenService:Create(mainCategoryIndicator, TweenInfo.new(0.3), {Rotation = 0}):Play()
    else
        mainCategoryIndicator.Text = "▼"
        TweenService:Create(mainCategoryIndicator, TweenInfo.new(0.3), {Rotation = 90}):Play()
    end

    -- Animate sections
    local targetVisibility = not isMainCategoryCollapsed
    local sections = {speedSection, flySection, jumpSection}

    if targetVisibility then
        -- Fade in sections
        for i, section in ipairs(sections) do
            section.Visible = true
            section.BackgroundTransparency = 1
            local fadeIn = TweenService:Create(section, TweenInfo.new(0.3), {BackgroundTransparency = 0})
            fadeIn:Play()
        end
    else
        -- Fade out sections
        for _, section in ipairs(sections) do
            local fadeOut = TweenService:Create(section, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                if isMainCategoryCollapsed then
                    section.Visible = false
                end
            end)
        end
    end

    updateCategoryPositions()
end

local function toggleLocalPlayerCategory()
    isLocalPlayerCategoryCollapsed = not isLocalPlayerCategoryCollapsed

    -- Animate indicator
    if isLocalPlayerCategoryCollapsed then
        localPlayerCategoryIndicator.Text = "▶"
        TweenService:Create(localPlayerCategoryIndicator, TweenInfo.new(0.3), {Rotation = 0}):Play()
    else
        localPlayerCategoryIndicator.Text = "▼"
        TweenService:Create(localPlayerCategoryIndicator, TweenInfo.new(0.3), {Rotation = 90}):Play()
    end

    -- Animate sections
    if isLocalPlayerCategoryCollapsed then
        local fadeOut1 = TweenService:Create(linePlayerSection, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        fadeOut1:Play()
        fadeOut1.Completed:Connect(function()
            if isLocalPlayerCategoryCollapsed then
                linePlayerSection.Visible = false
            end
        end)

        local fadeOut2 = TweenService:Create(teleportSection, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        fadeOut2:Play()
        fadeOut2.Completed:Connect(function()
            if isLocalPlayerCategoryCollapsed then
                teleportSection.Visible = false
            end
        end)
    else
        linePlayerSection.Visible = true
        linePlayerSection.BackgroundTransparency = 1
        local fadeIn1 = TweenService:Create(linePlayerSection, TweenInfo.new(0.3), {BackgroundTransparency = 0})
        fadeIn1:Play()

        teleportSection.Visible = true
        teleportSection.BackgroundTransparency = 1
        local fadeIn2 = TweenService:Create(teleportSection, TweenInfo.new(0.3), {BackgroundTransparency = 0})
        fadeIn2:Play()
    end

    updateCategoryPositions()
end

-- Functions
local function togglePanelVisibility()
    isPanelVisible = not isPanelVisible

    if isPanelVisible then
        -- Show panel
        mainPanel.Visible = true

        -- Position panel relative to logo button (only if not already positioned)
        local currentX = mainPanel.Position.X.Offset
        local currentY = mainPanel.Position.Y.Offset
        if currentX == -340 and currentY == 20 then
            local logoPos = logoButton.Position
            mainPanel.Position = UDim2.new(logoPos.X.Scale, logoPos.X.Offset - 280, logoPos.Y.Scale, logoPos.Y.Offset + 60)
        end

        -- Smooth fade in animation
        mainPanel.BackgroundTransparency = 1
        for i = 1, 10 do
            mainPanel.BackgroundTransparency = 1 - (i * 0.1)
            task.wait(0.02)
        end

        -- Rotate logo container to indicate active state
        TweenService:Create(logoContainer, TweenInfo.new(0.3), {Rotation = 90}):Play()

        -- Update logo status indicator
        logoStatusIndicator.BackgroundColor3 = colors.text
        TweenService:Create(logoStatusIndicator, TweenInfo.new(0.3), {Size = UDim2.new(0, 8, 0, 8)}):Play()

        if showNotification then
            showNotification("PANEL_STATE: VISIBLE")
        end
    else
        -- Hide panel
        mainPanel.BackgroundTransparency = 1
        mainPanel.Visible = false

        -- Rotate logo container back to normal
        TweenService:Create(logoContainer, TweenInfo.new(0.3), {Rotation = 0}):Play()

        -- Update logo status indicator
        logoStatusIndicator.BackgroundColor3 = colors.text_dim
        TweenService:Create(logoStatusIndicator, TweenInfo.new(0.3), {Size = UDim2.new(0, 6, 0, 6)}):Play()

        if showNotification then
            showNotification("PANEL_STATE: HIDDEN")
        end
    end
end

local function updateToggleSwitch(enabled)
    if enabled then
        TweenService:Create(toggleSwitch, TweenInfo.new(0.3), {Position = UDim2.new(0, 27, 0, 2)}):Play()
        TweenService:Create(toggleSwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = colors.active}):Play()
        toggleSwitch.BackgroundColor3 = colors.text
    else
        TweenService:Create(toggleSwitch, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0, 2)}):Play()
        TweenService:Create(toggleSwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = colors.inactive}):Play()
        toggleSwitch.BackgroundColor3 = colors.text_dim
    end
end

local function updateFlyToggleSwitch(enabled)
    if enabled then
        TweenService:Create(flyToggleSwitch, TweenInfo.new(0.3), {Position = UDim2.new(0, 27, 0, 2)}):Play()
        TweenService:Create(flyToggleSwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = colors.active}):Play()
        flyToggleSwitch.BackgroundColor3 = colors.text
    else
        TweenService:Create(flyToggleSwitch, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0, 2)}):Play()
        TweenService:Create(flyToggleSwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = colors.inactive}):Play()
        flyToggleSwitch.BackgroundColor3 = colors.text_dim
    end
end

local function updateInfinityToggleSwitch(enabled)
    if enabled then
        TweenService:Create(infinityToggleSwitch, TweenInfo.new(0.3), {Position = UDim2.new(0, 27, 0, 2)}):Play()
        TweenService:Create(infinityToggleSwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = colors.active}):Play()
        infinityToggleSwitch.BackgroundColor3 = colors.text
    else
        TweenService:Create(infinityToggleSwitch, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0, 2)}):Play()
        TweenService:Create(infinityToggleSwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = colors.inactive}):Play()
        infinityToggleSwitch.BackgroundColor3 = colors.text_dim
    end
end



local function updateStatus(active)
    if active then
        statusIndicator.BackgroundColor3 = colors.text
        TweenService:Create(statusIndicator, TweenInfo.new(0.5), {Size = UDim2.new(0, 12, 0, 12)}):Play()
    else
        statusIndicator.BackgroundColor3 = colors.text_dim
        TweenService:Create(statusIndicator, TweenInfo.new(0.5), {Size = UDim2.new(0, 8, 0, 8)}):Play()
    end
end

local function enableCustomSpeed()
    if isSpeedEnabled then return end

    isSpeedEnabled = true
    -- Use the value from input field, not just customWalkSpeed variable
    local inputSpeed = tonumber(speedInput.Text) or customWalkSpeed
    if inputSpeed >= 1 and inputSpeed <= 200 then
        humanoid.WalkSpeed = inputSpeed
        customWalkSpeed = inputSpeed
        speedValueLabel.Text = "VAL:" .. inputSpeed
    else
        humanoid.WalkSpeed = customWalkSpeed
        speedValueLabel.Text = "VAL:" .. customWalkSpeed
    end
    updateToggleSwitch(true)
    currentStatusLabel.Text = "CUR:ON"
    currentStatusLabel.TextColor3 = colors.text
    updateStatus(true)

    showNotification("SPEED_MODULATION: ENABLED")
end

local function disableCustomSpeed()
    if not isSpeedEnabled then return end

    isSpeedEnabled = false
    humanoid.WalkSpeed = originalWalkSpeed
    updateToggleSwitch(false)
    speedValueLabel.Text = "VAL:" .. originalWalkSpeed
    currentStatusLabel.Text = "CUR:OFF"
    currentStatusLabel.TextColor3 = colors.text_dim
    updateStatus(false)

    showNotification("SPEED_MODULATION: DISABLED")
end

local function updateCustomSpeed(newSpeed)
    local speed = tonumber(newSpeed)
    if speed and speed >= 1 and speed <= 200 then
        customWalkSpeed = speed
        speedInput.Text = tostring(speed)

        if isSpeedEnabled then
            humanoid.WalkSpeed = speed  -- Apply immediately if enabled
            speedValueLabel.Text = "VAL:" .. speed
        end
        -- Update display even if not enabled
        speedValueLabel.Text = "VAL:" .. speed
    else
        -- Revert to last valid value
        speedInput.Text = tostring(customWalkSpeed)
        speedValueLabel.Text = "VAL:" .. customWalkSpeed
    end
end

local function showNotification(message, notificationType)
    notificationType = notificationType or "Info"
    local iconMap = {
        Info = "rbxassetid://2544403653",
        Success = "rbxassetid://6031068421",
        Danger = "rbxassetid://6031068428",
        Warning = "rbxassetid://6031068426"
    }

    -- Use chat for system messages (more reliable)
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[SYSTEM] " .. message;
        Color = notificationType == "Success" and Color3.fromRGB(0, 255, 0) or
               notificationType == "Danger" and Color3.fromRGB(255, 0, 0) or
               notificationType == "Warning" and Color3.fromRGB(255, 165, 0) or
               colors.text;
        Font = Enum.Font.Code;
        FontSize = Enum.FontSize.Size18;
    })

    -- Also show notification
    StarterGui:SetCore("SendNotification", {
        Title = "JUNED SYSTEM",
        Text = message,
        Duration = 3,
        Icon = iconMap[notificationType] or iconMap.Info
    })
end

-- Create temporary notification GUI for special cases
local function createTempNotification(message, notificationType, callback)
    notificationType = notificationType or "Info"

    -- Remove existing temp notification
    local existingGui = player.PlayerGui:FindFirstChild("TempNotificationGui")
    if existingGui then
        existingGui:Destroy()
    end

    -- Create notification GUI
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "TempNotificationGui"
    notificationGui.Parent = player.PlayerGui
    notificationGui.IgnoreGuiInset = true
    notificationGui.ResetOnSpawn = false

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "NotificationFrame"
    mainFrame.Parent = notificationGui
    mainFrame.Size = UDim2.new(0, 350, 0, 50)
    mainFrame.Position = UDim2.new(0.5, 0, 0, -60)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0)
    mainFrame.BackgroundColor3 = notificationType == "Success" and Color3.fromRGB(0, 255, 0) or
                                  notificationType == "Danger" and Color3.fromRGB(255, 0, 0) or
                                  notificationType == "Warning" and Color3.fromRGB(255, 165, 0) or
                                  colors.secondary
    mainFrame.BorderSizePixel = 0

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame

    -- Text label
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "NotificationText"
    textLabel.Parent = mainFrame
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = message
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold

    -- Animate in
    local tweenIn = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, 0, 0, 20)
    })
    tweenIn:Play()

    -- Auto remove after 5 seconds
    task.delay(5, function()
        if notificationGui and notificationGui.Parent then
            local tweenOut = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0, -60)
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                notificationGui:Destroy()
            end)
        end
    end)

    return notificationGui
end











-- Fly Functions
local function enableFly()
    if isFlying then return end

    isFlying = true
    updateFlyToggleSwitch(true)

    -- Create fly components
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 5000
    bv.Parent = humanoid.RootPart

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 5000
    bg.Parent = humanoid.RootPart

    showNotification("FLY MODE: ENABLED")
end

local function disableFly()
    if not isFlying then return end

    isFlying = false
    updateFlyToggleSwitch(false)

    if bv then
        bv:Destroy()
        bv = nil
    end

    if bg then
        bg:Destroy()
        bg = nil
    end

    showNotification("FLY MODE: DISABLED")
end

local function updateFlySpeed(newSpeed)
    local speed = tonumber(newSpeed)
    if speed and speed >= 10 and speed <= 500 then
        flySpeed = speed
        flySpeedInput.Text = tostring(speed)
        -- Update velocity immediately if currently flying
        if isFlying and bv then
            if flyDirection ~= Vector3.new(0, 0, 0) then
                local camera = Workspace.CurrentCamera
                local cameraDirection = camera.CFrame.LookVector
                local adjustedDirection = (cameraDirection * flyDirection.Z + camera.CFrame.RightVector * flyDirection.X + Vector3.new(0, flyDirection.Y, 0)).Unit
                bv.Velocity = adjustedDirection * flySpeed
            end
        end
    else
        flySpeedInput.Text = tostring(flySpeed)
    end
end

-- Jump Functions
local function enableInfinityJump()
    if isInfinityJumpEnabled then return end

    isInfinityJumpEnabled = true
    updateInfinityToggleSwitch(true)

    showNotification("INFINITE_JUMP: ENABLED")
end

local function disableInfinityJump()
    if not isInfinityJumpEnabled then return end

    isInfinityJumpEnabled = false
    updateInfinityToggleSwitch(false)

    showNotification("INFINITE_JUMP: DISABLED")
end





-- Button Events
-- Logo button for show/hide panel
logoButton.MouseButton1Click:Connect(function()
    togglePanelVisibility()
end)

-- Logo button hover effects
logoButton.MouseEnter:Connect(function()
    TweenService:Create(logoText, TweenInfo.new(0.2), {TextColor3 = colors.active}):Play()
    TweenService:Create(logoButton, TweenInfo.new(0.2), {BackgroundColor3 = colors.accent}):Play()
end)

logoButton.MouseLeave:Connect(function()
    TweenService:Create(logoText, TweenInfo.new(0.2), {TextColor3 = colors.text}):Play()
    TweenService:Create(logoButton, TweenInfo.new(0.2), {BackgroundColor3 = colors.primary}):Play()
end)

-- Main panel drag start feedback
mainPanel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Change header color to indicate dragging
        TweenService:Create(headerFrame, TweenInfo.new(0.1), {BackgroundColor3 = colors.tertiary}):Play()
        -- Show drag hint
        TweenService:Create(dragHint, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
    end
end)

-- Main panel drag end feedback
mainPanel.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Restore header color
        TweenService:Create(headerFrame, TweenInfo.new(0.1), {BackgroundColor3 = colors.secondary}):Play()
        -- Hide drag hint
        TweenService:Create(dragHint, TweenInfo.new(0.2), {TextTransparency = 0.5}):Play()
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    if isSpeedEnabled then
        disableCustomSpeed()
    else
        enableCustomSpeed()
    end
end)

setButton.MouseButton1Click:Connect(function()
    updateCustomSpeed(speedInput.Text)
end)

speedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        updateCustomSpeed(speedInput.Text)
    end
end)

-- Fly toggle button event
flyToggleInvisibleButton.MouseButton1Click:Connect(function()
    if isFlying then
        disableFly()
    else
        enableFly()
    end
end)

flySpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        updateFlySpeed(flySpeedInput.Text)
    end
end)

-- Infinity jump toggle button event
infinityToggleInvisibleButton.MouseButton1Click:Connect(function()
    if isInfinityJumpEnabled then
        disableInfinityJump()
    else
        enableInfinityJump()
    end
end)



-- Line Player toggle button event
linePlayerToggleInvisibleButton.MouseButton1Click:Connect(function()
    if isLinePlayerEnabled then
        disableLinePlayer()
    else
        enableLinePlayer()
    end
end)

-- Category button events
mainCategoryButton.MouseButton1Click:Connect(function()
    toggleMainCategory()
end)

localPlayerCategoryButton.MouseButton1Click:Connect(function()
    toggleLocalPlayerCategory()
end)

-- Teleport Button Click Handler
teleportButton.MouseButton1Click:Connect(function()
    teleportToTargetPlayer()
end)

-- Teleport Refresh Button Click Handler
teleportRefreshButton.MouseButton1Click:Connect(function()
    refreshPlayerList()
    showNotification("TELEPORT: PLAYER_LIST_REFRESHED")
end)

-- Teleport Refresh Button Hover Effects
teleportRefreshButton.MouseEnter:Connect(function()
    TweenService:Create(teleportRefreshButton, TweenInfo.new(0.1), {BackgroundColor3 = colors.accent, TextColor3 = colors.text}):Play()
end)

teleportRefreshButton.MouseLeave:Connect(function()
    TweenService:Create(teleportRefreshButton, TweenInfo.new(0.1), {BackgroundColor3 = colors.tertiary, TextColor3 = colors.text_dim}):Play()
end)



-- Hover Effects for Teleport Button
teleportButton.MouseEnter:Connect(function()
    if teleportButton.Active then
        TweenService:Create(teleportButton, TweenInfo.new(0.1), {BackgroundColor3 = colors.active}):Play()
    end
end)

teleportButton.MouseLeave:Connect(function()
    if teleportButton.Active then
        TweenService:Create(teleportButton, TweenInfo.new(0.1), {BackgroundColor3 = colors.active}):Play()
    end
end)

-- Hover Effects
toggleButton.MouseEnter:Connect(function()
    TweenService:Create(toggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.accent}):Play()
end)

toggleButton.MouseLeave:Connect(function()
    if isSpeedEnabled then
        TweenService:Create(toggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.active}):Play()
    else
        TweenService:Create(toggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.inactive}):Play()
    end
end)

setButton.MouseEnter:Connect(function()
    TweenService:Create(setButton, TweenInfo.new(0.1), {BackgroundColor3 = colors.active}):Play()
end)

setButton.MouseLeave:Connect(function()
    TweenService:Create(setButton, TweenInfo.new(0.1), {BackgroundColor3 = colors.tertiary}):Play()
end)

-- Fly toggle hover effects
flyToggleInvisibleButton.MouseEnter:Connect(function()
    if isFlying then
        TweenService:Create(flyToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.accent}):Play()
    else
        TweenService:Create(flyToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.accent}):Play()
    end
end)

flyToggleInvisibleButton.MouseLeave:Connect(function()
    if isFlying then
        TweenService:Create(flyToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.active}):Play()
    else
        TweenService:Create(flyToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.inactive}):Play()
    end
end)

-- Infinity jump toggle hover effects
infinityToggleInvisibleButton.MouseEnter:Connect(function()
    if isInfinityJumpEnabled then
        TweenService:Create(infinityToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.accent}):Play()
    else
        TweenService:Create(infinityToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.accent}):Play()
    end
end)

infinityToggleInvisibleButton.MouseLeave:Connect(function()
    if isInfinityJumpEnabled then
        TweenService:Create(infinityToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.active}):Play()
    else
        TweenService:Create(infinityToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.inactive}):Play()
    end
end)



-- Line Player toggle hover effects
linePlayerToggleInvisibleButton.MouseEnter:Connect(function()
    if isLinePlayerEnabled then
        TweenService:Create(linePlayerToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.accent}):Play()
    else
        TweenService:Create(linePlayerToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.accent}):Play()
    end
end)

linePlayerToggleInvisibleButton.MouseLeave:Connect(function()
    if isLinePlayerEnabled then
        TweenService:Create(linePlayerToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.active}):Play()
    else
        TweenService:Create(linePlayerToggleSwitchBg, TweenInfo.new(0.1), {BackgroundColor3 = colors.inactive}):Play()
    end
end)

-- Category button hover effects
mainCategoryButton.MouseEnter:Connect(function()
    TweenService:Create(mainCategorySection, TweenInfo.new(0.1), {BackgroundColor3 = colors.tertiary}):Play()
    mainCategoryIndicator.TextColor3 = colors.active
end)

mainCategoryButton.MouseLeave:Connect(function()
    TweenService:Create(mainCategorySection, TweenInfo.new(0.1), {BackgroundColor3 = colors.secondary}):Play()
    mainCategoryIndicator.TextColor3 = colors.text
end)

localPlayerCategoryButton.MouseEnter:Connect(function()
    TweenService:Create(localPlayerCategorySection, TweenInfo.new(0.1), {BackgroundColor3 = colors.tertiary}):Play()
    localPlayerCategoryIndicator.TextColor3 = colors.active
end)

localPlayerCategoryButton.MouseLeave:Connect(function()
    TweenService:Create(localPlayerCategorySection, TweenInfo.new(0.1), {BackgroundColor3 = colors.secondary}):Play()
    localPlayerCategoryIndicator.TextColor3 = colors.text
end)

-- Fly Control (FIXED: W now goes forward, S goes backward)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not isFlying then return end

    if input.KeyCode == Enum.KeyCode.W then
        flyDirection = Vector3.new(0, 0, 1)   -- Forward (positive Z)
    elseif input.KeyCode == Enum.KeyCode.S then
        flyDirection = Vector3.new(0, 0, -1)  -- Backward (negative Z)
    elseif input.KeyCode == Enum.KeyCode.A then
        flyDirection = Vector3.new(-1, 0, 0)  -- Left
    elseif input.KeyCode == Enum.KeyCode.D then
        flyDirection = Vector3.new(1, 0, 0)   -- Right
    elseif input.KeyCode == Enum.KeyCode.Space then
        flyDirection = Vector3.new(0, 1, 0)   -- Up
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        flyDirection = Vector3.new(0, -1, 0)  -- Down
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or not isFlying then return end

    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or
       input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D or
       input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then
        flyDirection = Vector3.new(0, 0, 0)
    end
end)

-- Fly Movement Loop
RunService.RenderStepped:Connect(function()
    if isFlying and bv and humanoid.RootPart then
        local camera = Workspace.CurrentCamera
        local moveDirection = flyDirection

        if moveDirection ~= Vector3.new(0, 0, 0) then
            local cameraDirection = camera.CFrame.LookVector
            local adjustedDirection = (cameraDirection * moveDirection.Z + camera.CFrame.RightVector * moveDirection.X + Vector3.new(0, moveDirection.Y, 0)).Unit
            bv.Velocity = adjustedDirection * flySpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end

        bg.CFrame = camera.CFrame
    end
end)

-- Infinity Jump
UserInputService.JumpRequest:Connect(function()
    if isInfinityJumpEnabled then
        humanoid.Jump = true
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Keyboard Shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Speed toggle
    if input.KeyCode == Enum.KeyCode.X then
        if isSpeedEnabled then
            disableCustomSpeed()
        else
            enableCustomSpeed()
        end
    end

    -- Fly toggle
    if input.KeyCode == Enum.KeyCode.F then
        if isFlying then
            disableFly()
        else
            enableFly()
        end
    end

    -- Jump toggles
    if input.KeyCode == Enum.KeyCode.J then
        if isInfinityJumpEnabled then
            disableInfinityJump()
        else
            enableInfinityJump()
        end
    end

    -- Line Player toggle
    if input.KeyCode == Enum.KeyCode.L then
        if isLinePlayerEnabled then
            disableLinePlayer()
        else
            enableLinePlayer()
        end
    end

    -- Reset panel position
    if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local logoPos = logoButton.Position
        mainPanel.Position = UDim2.new(logoPos.X.Scale, logoPos.X.Offset - 280, logoPos.Y.Scale, logoPos.Y.Offset + 60)
        showNotification("PANEL_POSITION: RESET")
    end

    -- Reset all
    if input.KeyCode == Enum.KeyCode.R and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        disableCustomSpeed()
        disableFly()
        disableInfinityJump()
        disableLinePlayer()
        customWalkSpeed = 50
        flySpeed = 100
        speedInput.Text = tostring(customWalkSpeed)
        flySpeedInput.Text = tostring(flySpeed)
        speedValueLabel.Text = "VAL:" .. originalWalkSpeed
        showNotification("SYSTEM_RESET: COMPLETE")
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    originalWalkSpeed = humanoid.WalkSpeed
    originalJumpPower = humanoid.JumpPower
    speedValueLabel.Text = "VAL:" .. originalWalkSpeed
    jumpPowerDisplay.Text = "POWER: " .. originalJumpPower .. " | STATUS: INACTIVE"

    -- Reset all features on respawn
    disableCustomSpeed()
    disableFly()
    disableInfinityJump()

    -- Refresh lines if enabled (wait for head to load)
    if isLinePlayerEnabled then
        task.wait(1) -- Wait for character to load
        local head = newCharacter:WaitForChild("Head", 5)
        if head then
            refreshAllPlayerLines()
        end
    end
end)

-- Auto-disable on death
humanoid.Died:Connect(function()
    if isSpeedEnabled then disableCustomSpeed() end
    if isFlying then disableFly() end
    if isInfinityJumpEnabled then disableInfinityJump() end
    if isLinePlayerEnabled then disableLinePlayer() end
end)

-- Player join/leave events for auto-refresh
Players.PlayerAdded:Connect(function(newPlayer)
    if isLinePlayerEnabled and newPlayer ~= player then
        -- Wait for character to load
        newPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if isLinePlayerEnabled then
                createPlayerLine(newPlayer)
            end
        end)
    end
    -- Refresh teleport player list
    refreshPlayerList()
end)

Players.PlayerRemoving:Connect(function(removingPlayer)
    if isLinePlayerEnabled then
        removePlayerLine(removingPlayer)
    end

    -- Refresh teleport player list
    refreshPlayerList()
end)

-- Initialize category positions
updateCategoryPositions()

-- Initialize teleport player list
refreshPlayerList()



print("[SYSTEM] .SYSTEM: INITIALIZED")
print("[KEYBINDS] X:SPEED F:FLY J:INFINITE_JUMP L:LINE_PLAYER")
print("[PANEL] CLICK_LOGO:TOGGLE_PANEL DRAG_HEADER:MOVE_PANEL CTRL+P:RESET_POSITION")
print("[CATEGORIES] CLICK_CATEGORY_HEADERS:TOGGLE_EXPAND_COLLAPSE")
print("[RESET] CTRL+R: SYSTEM_RESET")
print("[SCROLLING] USE_MOUSE_WHEEL_OR_SCROLLBAR")
print("[FLIGHT_CONTROLS] W:FORWARD S:BACKWARD A:LEFT D:RIGHT SPACE:UP SHIFT:DOWN") 
