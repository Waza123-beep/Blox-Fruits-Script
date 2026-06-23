-- // TITÁN HUB: VERSIÓN "HARD-CODED" (ESTRICTAMENTE GLOBAL)
-- // Forzamos la creación de la tabla en el entorno global del juego
getgenv().TitanConfig = {
    AutoFarm = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Espera de seguridad a que cargue todo
repeat task.wait() until LocalPlayer:FindFirstChild("Data")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "TITÁN HUB | 100% VERIFIED", Theme = "Ocean"})

-- // PESTAÑAS
local T_Farm = Window:CreateTab("Auto Farm", "swords")

-- // BOTONES (Acceso directo a getgenv)
T_Farm:CreateToggle({
    Name = "Auto Farm Level", 
    Callback = function(v) 
        getgenv().TitanConfig.AutoFarm = v 
        print("AutoFarm cambiado a: " .. tostring(v))
    end
})

-- // MOTOR DE FARM (Independiente y directo)
task.spawn(function()
    while task.wait(1) do
        -- Leemos directamente de getgenv(), no de variables locales
        if getgenv().TitanConfig and getgenv().TitanConfig.AutoFarm then
            print("Motor corriendo: Buscando Quest...")
            
            pcall(function()
                -- Lógica básica de movimiento
                CommF:InvokeServer("StartQuest", "Bandit NPC")
                
                local enemy = Workspace.Enemies:FindFirstChild("Bandit")
                if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5)
                    print("Movimiento ejecutado hacia Bandit")
                else
                    print("No se encontró enemigo 'Bandit'")
                end
            end)
        end
    end
end)

print("✅ TITÁN HUB CARGADO CON ÉXITO")
