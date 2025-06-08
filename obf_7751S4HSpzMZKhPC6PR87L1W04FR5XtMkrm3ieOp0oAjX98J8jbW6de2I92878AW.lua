--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

--// Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

--// GUI Setup (เหมือนของมึง)
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FluentFarmGUI"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 270)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Active = true
frame.Parent = gui
frame.ClipsDescendants = true

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 12)

local dropShadow = Instance.new("ImageLabel", frame)
dropShadow.Size = UDim2.new(1, 60, 1, 60)
dropShadow.Position = UDim2.new(0.5, -30, 0.5, -30)
dropShadow.BackgroundTransparency = 1
dropShadow.Image = "rbxassetid://1316045217"
dropShadow.ImageTransparency = 0.7
dropShadow.ScaleType = Enum.ScaleType.Slice
dropShadow.SliceCenter = Rect.new(10, 10, 118, 118)
dropShadow.ZIndex = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "🪄 SEVENFARXIN Auto Farm"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextStrokeTransparency = 0.8
title.TextXAlignment = Enum.TextXAlignment.Center

--// Toggle States
local toggles = {
    collect = false,
    open = false,
    swing = false,
    crown = false
}

--// Toggle Button Builder
local function createToggleButton(name, positionY, toggleKey, actionFunc)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 36)
    button.Position = UDim2.new(0.05, 0, 0, positionY)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.Text = "❌ " .. name
    button.AutoButtonColor = false
    button.Parent = frame

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = toggles[toggleKey] and Color3.fromRGB(65, 130, 200) or Color3.fromRGB(45, 45, 45)
    end)

    button.MouseButton1Click:Connect(function()
        toggles[toggleKey] = not toggles[toggleKey]
        button.Text = (toggles[toggleKey] and "✅ " or "❌ ") .. name
        button.BackgroundColor3 = toggles[toggleKey] and Color3.fromRGB(65, 130, 200) or Color3.fromRGB(45, 45, 45)

        if toggles[toggleKey] then
            task.spawn(actionFunc)
        end
    end)
end

--// Existing Actions
-- ตัวอย่างออโต้เก็บไข่
createToggleButton("Auto Collect Egg", 50, "collect", function()
    while toggles.collect do
        local args = {
            {
                workspace:WaitForChild("Gameplay"):WaitForChild("CurrencyPickup"):WaitForChild("CurrencyHolder"):WaitForChild("BeachBall")
            }
        }
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("CollectCurrencyPickup"):FireServer(unpack(args))
        task.wait(0.1)
    end
end)

createToggleButton("Auto Open Egg", 95, "open", function()
    while toggles.open do
        local args = {
            "BuyEgg",
            "EK Egg"
        }
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("UIAction"):FireServer(unpack(args))
        task.wait(0.1)
    end
end)

createToggleButton("Auto Swing Saber", 140, "swing", function()
    while toggles.swing do
        pcall(function()
            ReplicatedStorage:WaitForChild("Events"):WaitForChild("SwingSaber"):FireServer()
            local tool = player.Character and player.Character:FindFirstChild("ExplosionMallet")
            if tool then
                local remote = tool:FindFirstChild("RemoteClick")
                if remote then
                    remote:FireServer()
                end
            end
        end)
        task.wait(0.1)
    end
end)

--// New Auto Collect Crown
createToggleButton("Auto Collect Crown", 185, "crown", function()
    while toggles.crown do
        -- ตรวจจับ Crown ทุกอันใน Gameplay.CurrencyPickup.CurrencyHolder
        local crownFolder = workspace:FindFirstChild("Gameplay")
            and workspace.Gameplay:FindFirstChild("CurrencyPickup")
            and workspace.Gameplay.CurrencyPickup:FindFirstChild("CurrencyHolder")

        if crownFolder then
            for _, item in pairs(crownFolder:GetChildren()) do
                if item.Name:lower():find("crown") then
                    -- ดึงไอเท็มมาหาตัวผู้เล่น (เอาง่าย ๆ ให้วางไว้ใกล้ตัว)
                    item.CFrame = rootPart.CFrame * CFrame.new(0, 0, 2)
                    -- ยิงเก็บ
                    local args = {{item}}
                    ReplicatedStorage:WaitForChild("Events"):WaitForChild("CollectCurrencyPickup"):FireServer(unpack(args))
                    task.wait(0.1)
                end
            end
        end
        task.wait(0.5)
    end
end)

--// Drag UI (เหมือนเดิม)
local dragging = false
local dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)