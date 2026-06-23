-- // TITÁN HUB: VERSIÓN CORREGIDA Y BLINDADA
-- // Inicialización segura de la configuración
getgenv().TitanConfig = {
    AutoFarm = false,
    AutoFarmMaterial = false,
    SelectedMat = nil
}

local Titan = getgenv().TitanConfig
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local LocalPlayer = Players.LocalPlayer

-- // 1. INTERFAZ (RAYFIELD)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "TITÁN HUB | FIXED VERSION", Theme = "Amethyst"})

-- // SECCIONES
local T_Profile = Window:CreateTab("Perfil", "user")
local T_Farm = Window:CreateTab("Auto Farm", "swords")
local T_Teleport = Window:CreateTab("Teleport", "globe")
local T_Boss = Window:CreateTab("Bosses", "crosshair")
local T_Shop = Window:CreateTab("Shop", "shopping-cart")
local T_Misc = Window:CreateTab("Misc", "settings")

-- // PESTAÑA PERFIL
T_Profile:CreateSection("Usuario: " .. LocalPlayer.Name)

-- // PESTAÑA AUTO FARM (CORREGIDA)
T_Farm:CreateToggle({Name = "Auto Farm Level", Callback = function(v) Titan.AutoFarm = v end})
T_Farm:CreateToggle({Name = "Auto Farm Material", Callback = function(v) Titan.AutoFarmMaterial = v end})

-- // PESTAÑA TELEPORT
T_Teleport:CreateButton({Name = "Viajar al 1er Mar", Callback = function() CommF:InvokeServer("Travel", "First Sea") end})
T_Teleport:CreateButton({Name = "Viajar al 2do Mar", Callback = function() CommF:InvokeServer("Travel", "Second Sea") end})
T_Teleport:CreateButton({Name = "Viajar al 3er Mar", Callback = function() CommF:InvokeServer("Travel", "Third Sea") end})

-- // PESTAÑA BOSSES
local Bosses = {"Longbeard", "The Saw", "Saber Expert"}
for _, name in pairs(Bosses) do
    T_Boss:CreateButton({Name = "Teleport to " .. name, Callback = function() 
        local b = Workspace.Enemies:FindFirstChild(name)
        if b and b:FindFirstChild("HumanoidRootPart") then 
            LocalPlayer.Character.HumanoidRootPart.CFrame = b.HumanoidRootPart.CFrame 
        else
            Rayfield:Notify({Title = "Error", Content = name .. " no encontrado o muerto."})
        end
    end})
end

-- // PESTAÑA SHOP
local Items = {"Black Leg", "Electro", "Bisento", "Saber"}
for _, item in pairs(Items) do
    T_Shop:CreateButton({Name = "Comprar " .. item, Callback = function() CommF:InvokeServer("Buy", item) end})
end

-- // PESTAÑA MISC
T_Misc:CreateButton({Name = "Canjear Códigos", Callback = function()
    local Codes = {"SUB2OFFICIALNOOBIE", "BIGNEWS", "FUDD10", "FUDD10_V2", "THIRDSEA"}
    for _, c in pairs(Codes) do pcall(function() CommF:InvokeServer("RedeemCode", c) end) task.wait(0.5) end
end})

-- // MOTOR PRINCIPAL (LOGICA SEGURA)
task.spawn(function()
    while task.wait(1) do
        -- Auto Farm Level
        if Titan.AutoFarm then
            local lvl = LocalPlayer.Data.Level.Value
            local Quest = (lvl < 10 and {NPC="Bandit NPC", Mob="Bandit"}) or (lvl < 30 and {NPC="Monkey NPC", Mob="Monkey"}) or {NPC="Cyborg NPC", Mob="Cyborg"}
            
            pcall(function()
                CommF:InvokeServer("StartQuest", Quest.NPC)
                local enemy = Workspace.Enemies:FindFirstChild(Quest.Mob)
                if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,5,0)
                end
            end)
        end
    end
end)

print("✅ TITÁN HUB: CARGADO Y CORREGIDO")
