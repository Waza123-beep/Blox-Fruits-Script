-- // TEST DE MOVIMIENTO BÁSICO
-- // Ejecuta esto una sola vez. No tiene bucles.

local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

local enemy = Workspace:FindFirstChild("Enemies") and Workspace.Enemies:FindFirstChild("Bandit")

if enemy and enemy:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5)
    print("✅ Movimiento ejecutado exitosamente.")
else
    print("❌ Error: No se encontró al enemigo 'Bandit' o tu personaje no tiene HumanoidRootPart.")
    -- Si esto falla, el nombre del enemigo podría ser "Bandit NPC" en lugar de "Bandit"
end
