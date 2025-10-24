-- Full rewritten Lua code for Roblox Whitelist GUI with fixed drag functionality
-- This script creates a draggable GUI to check HWID whitelist, copy HWID, and load script if whitelisted.

local whitelist = {
    "0bfb6c74-b00e-11f0-a74e-806e6f6e6963",  -- Example HWID, replace with real ones
    -- Add more if needed
}

-- Universal HWID retrieval with minimal calls
local hwid = "Unknown"
local executorName = "Unknown"

pcall(function() executorName = identifyexecutor().Name end)
pcall(function() hwid = gethwid() end)
if hwid == "Unknown" then pcall(function() if syn then hwid = syn.gethwid() end end) end
if hwid == "Unknown" then pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end) end

local function isWhitelisted()
    if hwid == "Unknown" then return false end
    for _, id in ipairs(whitelist) do
        if id == hwid then return true end
    end
    return false
end

-- Quick ScreenGui creation without extra elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NewYearWhitelistGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false  -- For speed, no respawn reset

local tweenService = game:GetService("TweenService")
local inputService = game:GetService("UserInputService")

-- Main Frame (simplified, no images)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
mainFrame.BorderSizePixel = 5
mainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
mainFrame.Parent = screenGui

-- Quick Corner for mainFrame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- Drag Bar as Frame (not a button to avoid click look)
local dragBar = Instance.new("Frame")
dragBar.Size = UDim2.new(1, 0, 0, 50)
dragBar.Position = UDim2.new(0, 0, 0, 0)
dragBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dragBar.BackgroundTransparency = 0.5
dragBar.ZIndex = 3
dragBar.Parent = mainFrame
dragBar.Active = true  -- Enable for clicking

local dragCorner = Instance.new("UICorner")
dragCorner.CornerRadius = UDim.new(0, 15)
dragCorner.Parent = dragBar

-- Gradient for dragBar (red -> green -> yellow, smooth style)
local dragGradient = Instance.new("UIGradient")
dragGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 160, 0))
}
dragGradient.Rotation = 0  -- Can animate later for beauty, but static for speed
dragGradient.Parent = dragBar

-- Title in dragBar
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "🎄 Merry Christmas Whitelist 🎅"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.ZIndex = 4
titleLabel.Parent = dragBar

-- Another gradient on title for nice color blend (white -> gold)
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
}
titleGradient.Rotation = 90
titleGradient.Parent = titleLabel

-- Animated gradient for beauty: color mixing over time (fast animation without load)
local function animateGradient(gradient)
    local tween = tweenService:Create(gradient, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Rotation = gradient.Rotation + 360})
    tween:Play()
end
animateGradient(dragGradient)  -- Animate dragBar gradient
animateGradient(titleGradient)  -- Animate title gradient

-- Drag functionality for dragBar
local dragging = false
local dragInput
local dragStart
local startPos

local function updateInput(input)
    if not dragging then return end
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

dragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

inputService.InputChanged:Connect(updateInput)

-- Status text (now with constant text: whitelist status and HWID)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 50)
statusLabel.Position = UDim2.new(0, 0, 0.8, 0)
statusLabel.Text = isWhitelisted() and "✅ Whitelisted! HWID: " .. hwid or "❌ Not whitelisted. HWID: " .. hwid .. " | Copy and send to developer."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White by default, but gradient overrides
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 14
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.ZIndex = 4
statusLabel.Parent = mainFrame

-- Gradient on status for darker flowing red (dark red -> slightly lighter red)
local statusGradient = Instance.new("UIGradient")
statusGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 0, 0)),  -- Dark red
    ColorSequenceKeypoint.new(1, Color3.fromRGB(178, 34, 52))  -- London brick (darker than previous)
}
statusGradient.Rotation = 180
statusGradient.Parent = statusLabel
animateGradient(statusGradient)  -- Animate status gradient for constant dark red flow

-- Copy HWID Button
local copyHwidButton = Instance.new("TextButton")
copyHwidButton.Size = UDim2.new(0.8, 0, 0, 40)
copyHwidButton.Position = UDim2.new(0.1, 0, 0.35, 0)
copyHwidButton.Text = "Copy my Hwid"
copyHwidButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
copyHwidButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyHwidButton.Font = Enum.Font.SourceSansBold  -- Made bold for visibility
copyHwidButton.TextSize = 16
copyHwidButton.TextStrokeTransparency = 0  -- Black outline for visibility on gradient
copyHwidButton.TextStrokeColor3 = Color3.new(0, 0, 0)
copyHwidButton.ZIndex = 5
copyHwidButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = copyHwidButton

-- Updated gradient on button (dark red -> slightly lighter red, like status, for background)
local copyGradient = Instance.new("UIGradient")
copyGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 0, 0)),  -- Dark red
    ColorSequenceKeypoint.new(1, Color3.fromRGB(178, 34, 52))  -- London brick
}
copyGradient.Parent = copyHwidButton
animateGradient(copyGradient)  -- Animate for flowing

-- New gradient for button text (same dark red flow for text)
local copyTextGradient = Instance.new("UIGradient")
copyTextGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(178, 34, 52))
}
copyTextGradient.Parent = copyHwidButton
animateGradient(copyTextGradient)  -- Animate text for flowing

copyHwidButton.MouseButton1Click:Connect(function()
    local originalText = statusLabel.Text
    local success, err = pcall(function()
        if syn and syn.clipboard_set then syn.clipboard_set(hwid ~= "Unknown" and hwid or "Unknown HWID - To get real HWID, open your executor's console (F9) and run: print(gethwid()) or print(syn.gethwid())")
        elseif setclipboard then setclipboard(hwid ~= "Unknown" and hwid or "Unknown HWID - To get real HWID, open your executor's console (F9) and run: print(gethwid()) or print(syn.gethwid())")
        elseif writeclipboard then writeclipboard(hwid ~= "Unknown" and hwid or "Unknown HWID - To get real HWID, open your executor's console (F9) and run: print(gethwid()) or print(syn.gethwid())")
        else error("No clipboard function") end
    end)
    statusLabel.Text = success and "Copied HWID to clipboard!" or "Clipboard error: " .. tostring(err) .. " | Check console for details."
    if not success then
        print("=== HWID Debug ===") print("Your HWID: " .. hwid) print("Executor: " .. executorName) print("==================")
    end
    wait(2)
    statusLabel.Text = originalText
end)

-- Load Script Button
local loadScriptButton = Instance.new("TextButton")
loadScriptButton.Size = UDim2.new(0.8, 0, 0, 40)
loadScriptButton.Position = UDim2.new(0.1, 0, 0.55, 0)
loadScriptButton.Text = "Load Script"
loadScriptButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
loadScriptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
loadScriptButton.Font = Enum.Font.SourceSansBold  -- Made bold for visibility
loadScriptButton.TextSize = 16
loadScriptButton.TextStrokeTransparency = 0  -- Black outline for visibility on gradient
loadScriptButton.TextStrokeColor3 = Color3.new(0, 0, 0)
loadScriptButton.ZIndex = 5
loadScriptButton.Parent = mainFrame

local loadCorner = Instance.new("UICorner")
loadCorner.CornerRadius = UDim.new(0, 10)
loadCorner.Parent = loadScriptButton

-- Updated gradient on button (dark red -> slightly lighter red, like status, for background)
local loadGradient = Instance.new("UIGradient")
loadGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 0, 0)),  -- Dark red
    ColorSequenceKeypoint.new(1, Color3.fromRGB(178, 34, 52))  -- London brick
}
loadGradient.Parent = loadScriptButton
animateGradient(loadGradient)  -- Animate for flowing

-- New gradient for button text (same dark red flow for text)
local loadTextGradient = Instance.new("UIGradient")
loadTextGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(178, 34, 52))
}
loadTextGradient.Parent = loadScriptButton
animateGradient(loadTextGradient)  -- Animate text for flowing

loadScriptButton.MouseButton1Click:Connect(function()
    local originalText = statusLabel.Text
    statusLabel.Text = "Loading Script..."
    if isWhitelisted() then
        local success, err = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/damir-dam/damirhub/refs/heads/main/.lua"))() end)
        statusLabel.Text = success and "Script loaded!" or "Error: " .. tostring(err)
        if success then screenGui:Destroy() end
        wait(success and 0 or 2)
        if not success then statusLabel.Text = originalText end
    else
        statusLabel.Text = "❌ HWID not whitelisted! | Copy HWID, send to developer."
        wait(3)
        statusLabel.Text = originalText
    end
end)

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -25, 0, 0)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 16
closeButton.TextStrokeTransparency = 0  -- Black outline for visibility
closeButton.TextStrokeColor3 = Color3.new(0, 0, 0)
closeButton.ZIndex = 10
closeButton.Parent = mainFrame

-- Added UICorner for closeButton
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)  -- Small radius for x
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)
