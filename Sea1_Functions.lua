-- // =========================================================================
-- // TITÁN HUB PRO v4.0: MÓDULO TOTAL SEA 1 (CÓDIGOS ACTUALIZADOS)
-- // =========================================================================

local Titan = getgenv().TitanConfig
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local LocalPlayer = Players.LocalPlayer

-- // 1. BASE DE DATOS DE CÓDIGOS (COMPLETA)
local RedeemCodes = {
    "EASTEREXP", "KITT_RESET", "SUB2OFFICIALNOOBIE", "AXIORE", "BIGNEWS", 
    "BLUXXY", "CHANDLER", "ENYU_IS_PRO", "FUDD10", "FUDD10_V2", "JCWK", 
    "KITTGAMING", "MAGICBUS", "STARCODEHEO", "STRAWHATMAINE", "SUB2CAPTAINMAUI", 
    "SUB2DAIGROCK", "SUB2FER999", "SUB2GAMERROBOT_EXP1", "SUB2GAMERROBOT_RESET1", 
    "SUB2NOOBMASTER123", "SUB2UNCLEKIZARU", "TANTAIGAMING", "THEGREATACE",
    "THIRDSEA", "EXP_5B", "UPDATE11", "PointsReset", "Update10", "Control", 
    "1MLIKES_RESET", "2BILLION", "3BVISITS", "UPD14", "ShutDownFix2", 
    "15B_BESTBROTHERS", "GAMERROBOT_YT", "TY_FOR_WATCHING", "DEVSCOOKING", 
    "NOOB_REFUND", "NEWWORLD", "SEAUNLOCK"
}

-- // 2. INTERFAZ PROFESIONAL
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "TITÁN HUB | PRO DASHBOARD", Theme = "Ocean"})

-- // SECCIÓN: PERFIL
local T_Profile = Window:CreateTab("Perfil", "user")
T_Profile:CreateSection("Usuario: " .. LocalPlayer.Name)

-- // SECCIÓN: FARM
local T_Farm = Window:CreateTab("Auto Farm", "swords")
T_Farm:CreateToggle({Name = "Auto Farm Level (1-700)", Callback = function(v) Titan.AutoFarm = v end})

-- // SECCIÓN: MISC (CÓDIGOS Y FPS)
local T_Misc = Window:CreateTab("Misc", "settings")
T_Misc:CreateButton({Name = "Canjear TODOS los Códigos", Callback = function()
    Rayfield:Notify({Title = "Códigos", Content = "Iniciando canje masivo... ¡Espera un momento!"})
    for _, code in pairs(RedeemCodes) do
        pcall(function()
            CommF:InvokeServer("RedeemCode", code)
        end)
        task.wait(1.5) -- Delay de seguridad
    end
    Rayfield:Notify({Title = "Códigos", Content = "Canje finalizado. Revisa tu consola (F9)."})
end})
T_Misc:CreateButton({Name = "Boost FPS (Remover Texturas)", Callback = function()
    for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("Part") then v.Material = "SmoothPlastic" end end
end})

-- // MOTOR PRINCIPAL (LOGICA AUTO FARM)
task.spawn(function()
    while task.wait(1) do
        if Titan.AutoFarm then
            local lvl = LocalPlayer.Data.Level.Value
            local Quests = {{Level = 1, NPC = "Bandit NPC", Mob = "Bandit"}, {Level = 10, NPC = "Monkey NPC", Mob = "Monkey"}, {Level = 600, NPC = "Cyborg NPC", Mob = "Cyborg"}}
            
            for i = #Quests, 1, -1 do
                if lvl >= Quests[i].Level then
                    CommF:InvokeServer("StartQuest", Quests[i].NPC)
                    local enemy = Workspace.Enemies:FindFirstChild(Quests[i].Mob)
                    if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0,5,5)
                    end
                    break
                end
            end
        end
    end
end)

print("✅ TITÁN HUB PRO: MÓDULO ACTUALIZADO CON CÓDIGOS MASIVOS")
