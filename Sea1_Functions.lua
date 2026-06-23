-- // =========================================================================
-- // TITÁN HUB: VERSIÓN "LOAD-SAFE" (CORRECCIÓN DE ERRORES)
-- // =========================================================================

-- 1. CONFIGURACIÓN GLOBAL INMEDIATA
getgenv().TitanConfig = {
    AutoFarm = false,
    AutoFarmMaterial = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- 2. ESPERA SEGURA A QUE EL JUEGO CARGUE (IMPORTANTE EN BLOX FRUITS)
repeat task.wait() until LocalPlayer:FindFirstChild("Data")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- 3. INTERFAZ
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "TITÁN HUB | ULTIMATE", Theme = "Ocean"})

-- 4. SECCIONES
local T_Profile = Window:CreateTab("Perfil", "user")
local T_Farm = Window:CreateTab("Auto Farm", "swords")
local T_Teleport = Window:CreateTab("Teleport", "globe")
local T_Boss = Window:CreateTab("Bosses", "crosshair")
local T_Shop = Window:CreateTab("Shop", "shopping-cart")
local T_Misc = Window:CreateTab("Misc", "settings")

-- PESTAÑA PERFIL
T_Profile:CreateSection("Usuario: " .. LocalPlayer.Name)
T_Profile:CreateSection("Nivel: " .. LocalPlayer.Data.Level.Value)

-- PESTAÑA AUTO FARM
T_Farm:CreateToggle({Name = "Auto Farm Level", Callback = function(v) getgenv().TitanConfig.AutoFarm = v end})
T_Farm:CreateToggle({Name = "Auto Farm Material", Callback = function(v) getgenv().TitanConfig.AutoFarmMaterial = v end})

-- PESTAÑA TELEPORT
T_Teleport:CreateButton({Name = "Viajar al 1er Mar", Callback = function() CommF:InvokeServer("Travel", "First Sea") end})
T_Teleport:CreateButton({Name = "Viajar al 2do Mar", Callback = function() CommF:InvokeServer("Travel", "Second Sea") end})
T_Teleport:CreateButton({Name = "Viajar al 3er Mar", Callback = function() CommF:InvokeServer("Travel", "Third Sea") end})

-- PESTAÑA BOSSES
local Bosses = {"Longbeard", "The Saw", "Saber Expert"}
for _, name in pairs(Bosses) do
    T_Boss:CreateButton({Name = "Teleport to " .. name, Callback = function() 
        local b = Workspace.Enemies:FindFirstChild(name)
        if b and b:FindFirstChild("HumanoidRootPart") then 
            LocalPlayer.Character.HumanoidRootPart.CFrame = b.HumanoidRootPart.CFrame 
        end
    end})
end

-- PESTAÑA SHOP
local Items = {"Black Leg", "Electro", "Bisento", "Saber"}
for _, item in pairs(Items) do
    T_Shop:CreateButton({Name = "Comprar " .. item, Callback = function() CommF:InvokeServer("Buy", item) end})
end

-- PESTAÑA MISC
T_Misc:CreateButton({Name = "Canjear Códigos", Callback = function()
    local Codes = {"SUB2OFFICIALNOOBIE", "BIGNEWS", "FUDD10", "FUDD10_V2", "THIRDSEA"}
    for _, c in pairs(Codes) do pcall(function() CommF:InvokeServer("RedeemCode", c) end) task.wait(0.5) end
end})

-- 5. MOTOR DE FARM (CÓDIGO LÓGICO SEGURO)
task.spawn(function()
    while task.wait(1) do
        if getgenv().TitanConfig.AutoFarm then
            pcall(function()
                local Quest = {NPC = "Bandit NPC", Mob = "Bandit"} -- Ejemplo básico
                -- Aquí iría la lógica avanzada de niveles
                CommF:InvokeServer("StartQuest", Quest.NPC)
                local enemy = Workspace.Enemies:FindFirstChild(Quest.Mob)
                if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,5,5)
                end
            end)
        end
    end
end)

print("✅ TITÁN HUB: CARGA EXITOSA")
