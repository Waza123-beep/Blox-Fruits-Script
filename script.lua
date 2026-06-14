local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Detectar Mar actual
local function getCurrentSea()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return "1st Sea" 
    elseif placeId == 4442272183 then return "2nd Sea"
    elseif placeId == 7449423635 then return "3rd Sea"
    else return "Unknown" end
end

local currentSea = getCurrentSea()

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomRedzHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 580)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "🔥 Custom Redz Hub - " .. currentSea
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Controles
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0,35,0,35)
CloseBtn.Position = UDim2.new(1,-42,0,8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextScaled = true

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0,35,0,35)
MinBtn.Position = UDim2.new(1,-82,0,8)
MinBtn.BackgroundColor3 = Color3.fromRGB(40,180,40)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.TextScaled = true

-- Floating Circle
local FloatCircle = Instance.new("ImageButton")
FloatCircle.Size = UDim2.new(0, 68, 0, 68)
FloatCircle.Position = UDim2.new(0.9, -34, 0.5, -34)
FloatCircle.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
FloatCircle.Image = "rbxassetid://3926307971"
FloatCircle.Visible = false
FloatCircle.Parent = ScreenGui
Instance.new("UICorner", FloatCircle).CornerRadius = UDim.new(1,0)

local function makeDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

makeDraggable(MainFrame)
makeDraggable(FloatCircle)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    FloatCircle.Visible = not FloatCircle.Visible
end)
FloatCircle.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatCircle.Visible = false
end)

-- Variables
local isFarming = false
local farmSpeed = 0.35  -- Default Normal
local farmConnection = nil

local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function notify(title, text)
    game.StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3})
end

-- Selector de Velocidad de Farm
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9,0,0,30)
speedLabel.Position = UDim2.new(0.05,0,0,65)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Velocidad de Farm: Normal"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.GothamSemibold
speedLabel.Parent = MainFrame

local speeds = {Safe = 0.55, Normal = 0.35, Fast = 0.22}
local speedButtons = {}
local currentSpeedName = "Normal"

for i, name in ipairs({"Safe", "Normal", "Fast"}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28,0,0,35)
    btn.Position = UDim2.new(0.05 + (i-1)*0.31, 0, 0, 100)
    btn.BackgroundColor3 = name == "Normal" and Color3.fromRGB(0,170,100) or Color3.fromRGB(40,40,50)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    
    btn.MouseButton1Click:Connect(function()
        currentSpeedName = name
        farmSpeed = speeds[name]
        speedLabel.Text = "Velocidad de Farm: " .. name
        for _, b in pairs(speedButtons) do b.BackgroundColor3 = Color3.fromRGB(40,40,50) end
        btn.BackgroundColor3 = Color3.fromRGB(0,170,100)
        notify("Farm Speed", "Cambiado a " .. name)
    end)
    table.insert(speedButtons, btn)
end

-- Auto Farm (adaptado al mar)
local function startAutoFarm()
    if farmConnection then farmConnection:Disconnect() end
    
    farmConnection = RunService.Heartbeat:Connect(function()
        if not isFarming then return end
        local root = getRoot()
        if not root then return end
        
        local target = nil
        local minDist = 350
        
        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
            local hum = enemy:FindFirstChild("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    target = enemy
                end
            end
        end
        
        if target and target:FindFirstChild("HumanoidRootPart") then
            local goal = target.HumanoidRootPart.CFrame * CFrame.new(0, 6, 7)
            root.CFrame = root.CFrame:Lerp(goal, farmSpeed)
            
            -- Ataque
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if tool then
                local remote = tool:FindFirstChildWhichIsA("RemoteEvent")
                if remote then remote:FireServer() end
            end
        end
    end)
end

-- Toggle Auto Farm
local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(0.9,0,0,55)
FarmToggle.Position = UDim2.new(0.05,0,0,150)
FarmToggle.BackgroundColor3 = Color3.fromRGB(40,40,50)
FarmToggle.Text = "🔴 Auto Farm Level: OFF"
FarmToggle.TextColor3 = Color3.new(1,1,1)
FarmToggle.TextScaled = true
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.Parent = MainFrame
Instance.new("UICorner", FarmToggle).CornerRadius = UDim.new(0,12)

FarmToggle.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        FarmToggle.Text = "🟢 Auto Farm Level: ON (" .. currentSpeedName .. ")"
        FarmToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        startAutoFarm()
        notify("Auto Farm", "Activado en " .. currentSea)
    else
        FarmToggle.Text = "🔴 Auto Farm Level: OFF"
        FarmToggle.BackgroundColor3 = Color3.fromRGB(40,40,50)
        if farmConnection then farmConnection:Disconnect() end
    end
end)

-- Teleports según el mar
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(0.95,0,0,300)
Scroll.Position = UDim2.new(0.025,0,0,220)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6
Scroll.Parent = MainFrame

local layout = Instance.new("UIListLayout", Scroll)
layout.Padding = UDim.new(0,8)

local teleports = {}
if currentSea == "1st Sea" then
    teleports = {"Starter Island", "Jungle", "Pirate Village", "Desert", "Middle Town", "Frozen Village"}
elseif currentSea == "2nd Sea" then
    teleports = {"Kingdom of Rose", "Cafe", "Green Zone", "Colosseum", "Factory", "Graveyard"}
else -- 3rd Sea
    teleports = {"Port Town", "Hydra Island", "Great Tree", "Floating Turtle", "Haunted Castle", "Sea of Treats", "Tiki Outpost", "Castle on the Sea"}
end

for _, island in ipairs(teleports) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
    btn.Text = "🌊 " .. island
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = Scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    
    btn.MouseButton1Click:Connect(function()
        notify("Teleport", "Yendo a " .. island)
        -- Aquí puedes agregar posiciones reales según el mar
        print("Teleport a: " .. island .. " (" .. currentSea .. ")")
    end)
end

print("✅ Custom Redz Hub cargado correctamente en " .. currentSea)
notify("Custom Redz Hub", "Detectado: " .. currentSea .. "\nElige tu velocidad de farm")
