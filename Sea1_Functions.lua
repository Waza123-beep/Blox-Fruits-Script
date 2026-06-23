-- // TITÁN HUB: VERSIÓN FINAL Y ESTABLE
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local LocalPlayer = Players.LocalPlayer

getgenv().TitanConfig = { AutoFarm = false }

-- // UI SETUP
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "TITÁN HUB | ESTABLE", Theme = "Ocean"})

local T_Farm = Window:CreateTab("Auto Farm", "swords")
local T_Misc = Window:CreateTab("Misc", "settings")

-- // TOGGLE DE FARM (USA LA LÓGICA QUE SÍ FUNCIONÓ)
T_Farm:CreateToggle({
    Name = "Auto Farm Automático", 
    Callback = function(v) getgenv().TitanConfig.AutoFarm = v end
})

-- // BOTÓN DE CÓDIGOS
T_Misc:CreateButton({Name = "Canjear Códigos", Callback = function()
    local Codes = {"SUB2OFFICIALNOOBIE", "BIGNEWS", "FUDD10", "FUDD10_V2", "THIRDSEA"}
    for _, c in pairs(Codes) do pcall(function() CommF:InvokeServer("RedeemCode", c) end) task.wait(0.5) end
end})

-- // MOTOR DE FARM (LÓGICA DINÁMICA QUE VIENE DE LA IMAGEN)
task.spawn(function()
    while task.wait(3) do -- Delay seguro para evitar 'queue exhausted'
        if getgenv().TitanConfig.AutoFarm then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and Workspace:FindFirstChild("Enemies") then
                local closestEnemy = nil
                local dist = 999999
                
                -- Busca el enemigo más cercano dinámicamente
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") then
                        local d = (enemy.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                        if d < dist then
                            dist = d
                            closestEnemy = enemy
                        end
                    end
                end

                if closestEnemy then
                    char.HumanoidRootPart.CFrame = closestEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5)
                end
            end
        end
    end
end)

print("✅ TITÁN HUB: MÓDULO INTELIGENTE CARGADO")
