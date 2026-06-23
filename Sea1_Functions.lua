-- // TITÁN HUB: VERSIÓN ESTABLE (NO SPAM)
-- // Si esto no se mueve, el problema ya no es el script, sino el ID del NPC.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local LocalPlayer = Players.LocalPlayer

getgenv().TitanConfig = { AutoFarm = false }

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "TITÁN HUB | ESTABLE", Theme = "Ocean"})
local T_Farm = Window:CreateTab("Auto Farm", "swords")

T_Farm:CreateToggle({
    Name = "Auto Farm (Bandits)", 
    Callback = function(v) getgenv().TitanConfig.AutoFarm = v end
})

-- // MOTOR ESTABLE: Solo se ejecuta cada 3 segundos para no saturar
task.spawn(function()
    while task.wait(3) do
        if getgenv().TitanConfig.AutoFarm then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- 1. Intentar aceptar misión (solo si no la tienes)
                pcall(function() CommF:InvokeServer("StartQuest", "Bandit NPC") end)
                
                -- 2. Moverse al enemigo
                local enemy = Workspace.Enemies:FindFirstChild("Bandit")
                if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5)
                end
            end
        end
    end
end)

print("✅ TITÁN HUB: CARGADO EN MODO ESTABLE")
