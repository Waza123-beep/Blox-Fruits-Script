-- // =========================================================================
-- // TITÁN HUB: VERSIÓN ULTIMATE (TODO EN UNO)
-- // =========================================================================

local Titan = getgenv().TitanConfig
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local LocalPlayer = Players.LocalPlayer

-- // 1. BASE DE DATOS
local RedeemCodes = {"EASTEREXP", "KITT_RESET", "SUB2OFFICIALNOOBIE", "AXIORE", "BIGNEWS", "BLUXXY", "CHANDLER", "ENYU_IS_PRO", "FUDD10", "FUDD10_V2", "JCWK", "KITTGAMING", "MAGICBUS", "STARCODEHEO", "STRAWHATMAINE", "SUB2CAPTAINMAUI", "SUB2DAIGROCK", "SUB2FER999", "SUB2GAMERROBOT_EXP1", "SUB2GAMERROBOT_RESET1", "SUB2NOOBMASTER123", "SUB2UNCLEKIZARU", "TANTAIGAMING", "THEGREATACE", "THIRDSEA", "EXP_5B", "UPDATE11", "PointsReset", "Update10", "Control", "1MLIKES_RESET", "2BILLION", "3BVISITS", "UPD14", "ShutDownFix2", "15B_BESTBROTHERS", "GAMERROBOT_YT", "TY_FOR_WATCHING", "DEVSCOOKING", "NOOB_REFUND", "NEWWORLD", "SEAUNLOCK"}

-- // 2. INTERFAZ
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "TITÁN HUB | ULTIMATE", Theme = "Ocean"})

-- // SECCIONES
local T_Profile = Window:CreateTab("Perfil", "user")
local T_Farm = Window:CreateTab("Auto Farm", "swords")
local T_Teleport = Window:CreateTab("Teleport", "globe")
local T_Boss = Window:CreateTab("Bosses", "crosshair")
local T_Shop = Window:CreateTab("Shop", "shopping-cart")
local T_Misc = Window:CreateTab("Misc", "settings")

-- // PESTAÑA PERFIL
T_Profile:CreateSection("Usuario: " .. LocalPlayer.Name)
T_Profile:CreateDropdown({Name = "Cambiar Color de UI", Options = {"Ocean", "Amethyst", "Serenity"}, Callback = function(v) Rayfield:LoadConfiguration(v) end})

-- // PESTAÑA AUTO FARM
T_Farm:CreateToggle({Name = "Auto Farm Level", Callback = function(v) Titan.AutoFarm = v end})
T_Farm:CreateToggle({Name = "Auto Farm Material", Callback = function(v) Titan.FarmMats = v end})

-- // PESTAÑA TELEPORT (VIAJE ENTRE MARES)
T_Teleport:CreateButton({Name = "Viajar al 1er Mar", Callback = function() CommF:InvokeServer("Travel", "First Sea") end})
T_Teleport:CreateButton({Name = "Viajar al 2do Mar", Callback = function() CommF:InvokeServer("Travel", "Second Sea") end})
T_Teleport:CreateButton({Name = "Viajar al 3er Mar", Callback = function() CommF:InvokeServer("Travel", "Third Sea") end})

-- // PESTAÑA BOSSES
for _, boss in pairs({"Longbeard", "The Saw", "Saber Expert"}) do
    T_Boss:CreateButton({Name = "Teleport to " .. boss, Callback = function() 
        local b = Workspace.Enemies:FindFirstChild(boss)
        if b then LocalPlayer.Character.HumanoidRootPart.CFrame = b.HumanoidRootPart.CFrame end
    end})
end

-- // PESTAÑA SHOP
for _, item in pairs({"Black Leg", "Electro", "Bisento", "Saber"}) do
    T_Shop:CreateButton({Name = "Comprar " .. item, Callback = function() CommF:InvokeServer("Buy", item) end})
end

-- // PESTAÑA MISC
T_Misc:CreateButton({Name = "Canjear Todos los Códigos", Callback = function()
    for _, code in pairs(RedeemCodes) do pcall(function() CommF:InvokeServer("RedeemCode", code) end) task.wait(1.5) end
end})
T_Misc:CreateButton({Name = "Boost FPS", Callback = function() for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("Part") then v.Material = "SmoothPlastic" end end end})
T_Misc:CreateButton({Name = "Destroy UI", Callback = function() Rayfield:Destroy() end})

-- // MOTOR LÓGICO
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

print("✅ TITÁN HUB: MÓDULO ULTIMATE CARGADO")
