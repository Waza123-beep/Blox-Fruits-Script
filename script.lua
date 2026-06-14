loadstring([[
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local placeId = game.PlaceId
local currentSea = placeId == 7449423635 and "3rd" or placeId == 4442272183 and "2nd" or "1st"

print("✅ Custom Redz Hub 2026 cargado | Mar detectado: " .. currentSea)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460, 0, 650)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -325)
MainFrame.BackgroundColor3 = Color3.fromRGB(18,18,25)
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -140, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "🔥 Custom Redz Hub 2026 - " .. currentSea .. " Sea"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Controles
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0,35,0,35); CloseBtn.Position = UDim2.new(1,-45,0,8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,40,40); CloseBtn.Text = "✕"; CloseBtn.TextScaled = true

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0,35,0,35); MinBtn.Position = UDim2.new(1,-85,0,8)
MinBtn.BackgroundColor3 = Color3.fromRGB(40,180,40); MinBtn.Text = "−"; MinBtn.TextScaled = true

local FloatCircle = Instance.new("ImageButton")
FloatCircle.Size = UDim2.new(0,70,0,70); FloatCircle.Position = UDim2.new(0.9,-35,0.5,-35)
FloatCircle.BackgroundColor3 = Color3.fromRGB(0,162,255); FloatCircle.Image = "rbxassetid://3926307971"
FloatCircle.Visible = false; FloatCircle.Parent = ScreenGui
Instance.new("UICorner", FloatCircle).CornerRadius = UDim.new(1,0)

local function makeDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = gui.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end
makeDraggable(MainFrame); makeDraggable(FloatCircle)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible; FloatCircle.Visible = not FloatCircle.Visible end)
FloatCircle.MouseButton1Click:Connect(function() MainFrame.Visible = true; FloatCircle.Visible = false end)

-- Variables
local toggles = {Farm=false, Quest=false, KillAura=false, Chest=false, Boss=false, ESP=false}
local farmSpeed = 0.35
local connections = {}

local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function notify(title, text)
    game.StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3})
end

-- Auto Farm + Auto Quest básico
local function startFarm()
    for _, c in pairs(connections) do c:Disconnect() end
    connections = {}
    local conn = RunService.Heartbeat:Connect(function()
        if not toggles.Farm then return end
        local root = getRoot()
        if not root then return end
        local target = nil
        local minDist = 420
        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
            local hum = enemy:FindFirstChild("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local d = (root.Position - hrp.Position).Magnitude
                if d < minDist then minDist = d; target = enemy end
            end
        end
        if target then
            root.CFrame = root.CFrame:Lerp(target.HumanoidRootPart.CFrame * CFrame.new(0,6,8), farmSpeed)
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then local rem = tool:FindFirstChildWhichIsA("RemoteEvent"); if rem then rem:FireServer() end end
        end
    end)
    table.insert(connections, conn)
end

-- Kill Aura
local function startKillAura()
    local ka = RunService.Heartbeat:Connect(function()
        if not toggles.KillAura then return end
        local root = getRoot()
        if not root then return end
        for _, e in ipairs(Workspace.Enemies:GetChildren()) do
            local hrp = e:FindFirstChild("HumanoidRootPart")
            if hrp and (root.Position - hrp.Position).Magnitude < 28 then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then local rem = tool:FindFirstChildWhichIsA("RemoteEvent"); if rem then rem:FireServer() end end
            end
        end
    end)
    table.insert(connections, ka)
end

-- Auto Chest
local function startAutoChest()
    spawn(function()
        while toggles.Chest do
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v.Name:find("Chest") and v:FindFirstChild("TouchInterest") then
                    local root = getRoot()
                    if root and (root.Position - v.Position).Magnitude < 60 then
                        firetouchinterest(root, v, 0)
                        task.wait(0.8)
                    end
                end
            end
            task.wait(4)
        end
    end)
end

-- Auto Boss (básico)
local function startAutoBoss()
    spawn(function()
        while toggles.Boss do
            for _, boss in ipairs(Workspace.Enemies:GetChildren()) do
                if boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss.Name:lower():find("boss") or boss.Name:lower():find("elite") then
                    notify("Auto Boss", "Boss detectado: " .. boss.Name)
                    break
                end
            end
            task.wait(5)
        end
    end)
end

-- ESP básico
local function toggleESP()
    if toggles.ESP then
        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("HumanoidRootPart") then
                local bill = Instance.new("BillboardGui", enemy.HumanoidRootPart)
                bill.Adornee = enemy.HumanoidRootPart
                bill.Size = UDim2.new(0,100,0,50)
                local txt = Instance.new("TextLabel", bill)
                txt.Size = UDim2.new(1,0,1,0)
                txt.BackgroundTransparency = 1
                txt.Text = enemy.Name
                txt.TextColor3 = Color3.new(1,0,0)
                txt.TextScaled = true
            end
        end
    end
end

-- Crear toggles
local y = 70
for _, name in ipairs({"Farm", "Quest", "KillAura", "Chest", "Boss", "ESP"}) do
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9,0,0,48)
    btn.Position = UDim2.new(0.05,0,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    btn.Text = "🔴 " .. name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    btn.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        btn.Text = (toggles[name] and "🟢" or "🔴") .. " " .. name
        btn.BackgroundColor3 = toggles[name] and Color3.fromRGB(0,180,80) or Color3.fromRGB(40,40,50)
        
        if name == "Farm" then startFarm() end
        if name == "KillAura" then startKillAura() end
        if name == "Chest" then startAutoChest() end
        if name == "Boss" then startAutoBoss() end
        if name == "ESP" then toggleESP() end
    end)
    y = y + 55
end

-- Speed Selector
local speedLabel = Instance.new("TextLabel", MainFrame)
speedLabel.Size = UDim2.new(0.9,0,0,30); speedLabel.Position = UDim2.new(0.05,0,0,y+10)
speedLabel.BackgroundTransparency = 1; speedLabel.Text = "Farm Speed: Normal"; speedLabel.TextColor3 = Color3.new(1,1,1); speedLabel.TextScaled = true

for i, v in ipairs({{n="Safe",s=0.55}, {n="Normal",s=0.35}, {n="Fast",s=0.22}}) do
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.28,0,0,35); btn.Position = UDim2.new(0.05+(i-1)*0.32,0,0,y+45)
    btn.Text = v.n; btn.BackgroundColor3 = v.n=="Normal" and Color3.fromRGB(0,170,80) or Color3.fromRGB(40,40,50)
    btn.TextColor3 = Color3.new(1,1,1); btn.TextScaled = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.MouseButton1Click:Connect(function() farmSpeed = v.s; speedLabel.Text = "Farm Speed: "..v.n end)
end

notify("Custom Redz Hub", "Cargado en " .. currentSea .. " Sea - Usa con cuenta secundaria")
]])()
