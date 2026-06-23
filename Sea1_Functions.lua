-- // TITÁN HUB: VERSIÓN CON KILL AURA (COMBATE AUTOMÁTICO)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

getgenv().TitanConfig = { AutoFarm = false }

-- // UI SETUP
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "TITÁN HUB | COMBAT READY", Theme = "Ocean"})
local T_Farm = Window:CreateTab("Auto Farm", "swords")

T_Farm:CreateToggle({
    Name = "Auto Farm + Kill Aura", 
    Callback = function(v) getgenv().TitanConfig.AutoFarm = v end
})

-- // MOTOR DE COMBATE Y MOVIMIENTO
task.spawn(function()
    while task.wait(0.5) do -- Reducimos el tiempo a 0.5 para que el ataque sea rápido
        if getgenv().TitanConfig.AutoFarm then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and Workspace:FindFirstChild("Enemies") then
                local closestEnemy = nil
                local dist = 999999
                
                -- Detectar enemigo cercano
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") then
                        local d = (enemy.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                        if d < dist then
                            dist = d
                            closestEnemy = enemy
                        end
                    end
                end

                -- Acción: Teletransporte + Click
                if closestEnemy then
                    -- Teletransportarse justo encima/enfrente
                    char.HumanoidRootPart.CFrame = closestEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    
                    -- Simular clic (M1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, false)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, false)
                end
            end
        end
    end
end)

print("✅ TITÁN HUB: MODO COMBATE ACTIVADO")
