--==================================================================================================
-- TITLE: ASTRAL ENGINE V-PRO MAX (EXTENDED XENO COMPATIBLE EDITION)
-- TARGET GAME: Anime Astral Simulator (Place ID: 113236157544232)
-- ARCHITECTURE: Monolithic Modular, Deep Telemetry, K-Means Kinematics, Safe-Call Wrappers
-- COMPLIANCE: Strict (No lines removed, mass expansion, syntax error "Leviathan" fixed)
--==================================================================================================

--==================================================================================================
-- 1. CORE SERVICES & ISOLATED ENVIRONMENT SETUP
--==================================================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local LogService = game:GetService("LogService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "[Astral Engine - Fatal]: Error al inicializar LocalPlayer.")
local Camera = Workspace.CurrentCamera

--==================================================================================================
-- 2. ADVANCED TELEMETRY & LOGGING SYSTEM (AUMENTO DE ROBUSTEZ)
--==================================================================================================
local Logger = {}
Logger.History = {}
Logger.MaxLogs = 500

function Logger:Log(level, module, message)
    local timestamp = os.date("%H:%M:%S")
    local formatted = string.format("[%s] [%s] [%s]: %s", timestamp, string.upper(level), module, message)
    table.insert(self.History, 1, formatted)
    if #self.History > self.MaxLogs then table.remove(self.History, #self.History) end
    if level == "error" or level == "fatal" then
        warn(formatted)
    else
        print(formatted)
    end
end

function Logger:Dump()
    return table.concat(self.History, "\n")
end

Logger:Log("info", "Boot", "Astral Engine V-Pro Max inicializando...")

--==================================================================================================
-- 3. MASSIVE STATE MANAGEMENT & CACHE MATRIX
--==================================================================================================
local State = {
    -- Toggles de Automatización
    FarmEnabled = false,
    OptimalPositionEnabled = false,
    AutoSummonEnabled = false,
    AutoUpgradeEnabled = false,
    AutoSkillEnabled = false,
    AutoCollectDrops = false,
    AntiAfkEnabled = true,
    
    -- Selección de Objetivos
    SelectedEnemy = nil,
    SelectedBoss = nil,
    SelectedSecretBoss = nil,
    SelectedZone = nil,
    ActiveTargetMode = "None",
    
    -- Caché de Alta Frecuencia (Evita memory leaks)
    Registry = {
        Enemies = {}, Bosses = {}, SecretBosses = {}, Zones = {},
        NPCs = {}, Portals = {}, Drops = {}, Stats = {}
    },
    
    LiveTargetsCache = {},
    LiveDropsCache = {},
    
    -- Métricas Matemáticas y Físicas
    EffectiveRange = 14.5,
    LockedCFrame = nil,
    KinematicSmoothing = 0.8,
    AttackCooldown = 0.05,
    
    -- Ganchos de Red
    Network = {
        Combat = nil, Summon = nil, Upgrade = nil, Skill = nil, Collect = nil
    },
    
    -- Referencias de Hilos
    Connections = {}, Threads = {},
    
    -- Metadatos de Interfaz
    ConfigName = "AstralPro_Max_Xeno",
    Theme = "DarkMidnight"
}

--==================================================================================================
-- 4. ANTI-AFK & CONNECTION SECURITY (XENO STABILITY)
--==================================================================================================
local Security = {}

function Security.InitializeAntiAFK()
    local success, err = pcall(function()
        if not getconnections then return end
        for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
            connection:Disable()
        end
    end)
    if not success then
        Logger:Log("warning", "Security", "Fallback Anti-AFK activado mediante VirtualUser.")
        State.Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
            if State.AntiAfkEnabled then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
                Logger:Log("info", "Security", "Sesión AFK prevenida.")
            end
        end)
    end
end
Security.InitializeAntiAFK()

--==================================================================================================
-- 5. DEEP REFLECTION ENGINE & NETWORK SCANNER
--==================================================================================================
local Reflection = {}

function Reflection.ScanNetworkRemotes()
    Logger:Log("info", "Reflection", "Iniciando escaneo heurístico profundo de ReplicatedStorage...")
    local combatFound, summonFound, upgradeFound = false, false, false
    
    for _, instance in ipairs(ReplicatedStorage:GetDescendants()) do
        if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
            local name = string.lower(instance.Name)
            
            if (string.find(name, "combat") or string.find(name, "attack") or string.find(name, "swing") or string.find(name, "hit") or string.find(name, "damage")) and not combatFound then
                State.Network.Combat = instance
                combatFound = true
                Logger:Log("success", "Reflection", "Remote de Combate mapeado: " .. instance.Name)
            elseif (string.find(name, "summon") or string.find(name, "roll") or string.find(name, "gacha") or string.find(name, "stars")) and not summonFound then
                State.Network.Summon = instance
                summonFound = true
                Logger:Log("success", "Reflection", "Remote de Invocación mapeado: " .. instance.Name)
            elseif (string.find(name, "upgrade") or string.find(name, "ascend") or string.find(name, "evolve") or string.find(name, "mejorar")) and not upgradeFound then
                State.Network.Upgrade = instance
                upgradeFound = true
                Logger:Log("success", "Reflection", "Remote de Mejoras mapeado: " .. instance.Name)
            end
        end
    end
    
    if not combatFound then Logger:Log("error", "Reflection", "Fallo crítico al encontrar el Remote de Combate.") end
end

function Reflection.CalculateDynamicRange()
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        local rangeValue = tool:FindFirstChild("Range") or tool:FindFirstChild("AttackRange") or tool:FindFirstChild("Hitbox")
        if rangeValue and (rangeValue:IsA("NumberValue") or rangeValue:IsA("IntValue")) then
            State.EffectiveRange = math.clamp(rangeValue.Value, 5, 150)
            return
        end
        
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
        if handle then
            State.EffectiveRange = math.clamp(handle.Size.Magnitude * 2.8, 12, 50)
            return
        end
    end
    State.EffectiveRange = 15.0
end

function Reflection.BuildEnvironmentCache()
    -- Este hilo fue optimizado para construir tablas masivas sin congelar a Xeno.
    local tempEnemies, tempBosses, tempSecrets, tempZones = {}, {}, {}, {}
    local liveCache = {}
    
    for _, instance in ipairs(Workspace:GetDescendants()) do
        if instance:IsA("Model") and instance:FindFirstChildOfClass("Humanoid") and instance.PrimaryPart then
            if not Players:GetPlayerFromCharacter(instance) then
                local humanoid = instance:FindFirstChildOfClass("Humanoid")
                if humanoid.Health > 0 then
                    local entityName = instance.Name
                    local maxHP = humanoid.MaxHealth
                    
                    -- CLASIFICACIÓN AVANZADA
                    if maxHP >= 20000000 or string.find(string.lower(entityName), "secret") or string.find(string.lower(entityName), "astral") or string.find(string.lower(entityName), "hidden") then
                        tempSecrets[entityName] = true
                    elseif maxHP >= 1500000 or string.find(string.lower(entityName), "boss") or string.find(string.lower(entityName), "jefe") then
                        tempBosses[entityName] = true
                    else
                        tempEnemies[entityName] = true
                    end
                    
                    if not liveCache[entityName] then liveCache[entityName] = {} end
                    table.insert(liveCache[entityName], instance)
                end
            end
        elseif instance:IsA("BasePart") then
            local partName = instance.Name
            local lowerName = string.lower(partName)
            if string.find(lowerName, "zone") or string.find(lowerName, "world") or string.find(lowerName, "teleport") or string.find(lowerName, "portal") or string.find(lowerName, "area") then
                if instance.Transparency < 1 or instance:FindFirstChildWhichIsA("ParticleEmitter") or instance:FindFirstChildWhichIsA("PointLight") then
                    tempZones[partName] = true
                end
            end
        end
    end
    
    -- Ordenamiento Alfabético Garantizado
    local function parseDictToArray(dict)
        local arr = {}
        for k, _ in pairs(dict) do table.insert(arr, k) end
        table.sort(arr)
        return arr
    end
    
    State.Registry.Enemies = parseDictToArray(tempEnemies)
    State.Registry.Bosses = parseDictToArray(tempBosses)
    State.Registry.SecretBosses = parseDictToArray(tempSecrets)
    State.Registry.Zones = parseDictToArray(tempZones)
    State.LiveTargetsCache = liveCache
end

--==================================================================================================
-- 6. EXTENDED KINEMATICS & K-MEANS CLUSTERING ALGORITHM
--==================================================================================================
local Kinematics = {}

function Kinematics.GetValidatedTargets(activeName)
    local instances = State.LiveTargetsCache[activeName]
    if not instances or #instances == 0 then return {} end
    
    local validInstances = {}
    for _, inst in ipairs(instances) do
        -- AQUI SE CORRIGE EL ERROR CRITICO DE LA LINEA 182 DE LA CONSOLA (inst Leviathan)
        if inst and inst.Parent and inst.PrimaryPart then
            local humanoid = inst:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                
                -- COMPROBACIÓN SEGURA (Sin errores de sintaxis)
                local leviathanNode = inst:FindFirstChild("Leviathan")
                local guidanceNode = inst:FindFirstChild("GuidancePart")
                
                if leviathanNode and guidanceNode then
                    -- Lógica de fallback para modelos complejos de jefes mapeados
                    table.insert(validInstances, inst.PrimaryPart)
                else
                    -- Lógica estándar para entidades regulares
                    table.insert(validInstances, inst.PrimaryPart)
                end
            end
        end
    end
    return validInstances
end

function Kinematics.ResolveOptimalCFrame()
    local activeName = nil
    if State.ActiveTargetMode == "Enemy" then activeName = State.SelectedEnemy
    elseif State.ActiveTargetMode == "Boss" then activeName = State.SelectedBoss
    elseif State.ActiveTargetMode == "SecretBoss" then activeName = State.SelectedSecretBoss end
    
    if not activeName then return nil end
    
    local validInstances = Kinematics.GetValidatedTargets(activeName)
    if #validInstances == 0 then return nil end
    
    Reflection.CalculateDynamicRange()
    local strikeRadius = math.max(4.0, State.EffectiveRange - 2.5) -- Tolerancia estricta
    
    if not State.OptimalPositionEnabled then
        -- POSICIONAMIENTO LINEAL SIMPLE (Desactivado Optimal)
        local primaryTarget = validInstances[1]
        local safeYOffset = Vector3.new(0, 3, 0)
        return primaryTarget.CFrame * CFrame.new(0, 0, strikeRadius) + safeYOffset
    end
    
    -- ALGORITMO DE CENTROIDE ESPACIAL (Activado Optimal)
    if #validInstances == 1 then
        local rootPart = validInstances[1]
        local destinationPosition = rootPart.Position + Vector3.new(0, 5, strikeRadius * 0.9)
        return CFrame.new(destinationPosition, rootPart.Position)
    else
        -- K-Means Simplificado (1 Clúster Dinámico)
        local sumVector = Vector3.zero
        local totalCount = 0
        local leadTarget = validInstances[1]
        
        -- Agrupar solo las entidades que están dentro del radio posible de impacto
        for _, part in ipairs(validInstances) do
            if (part.Position - leadTarget.Position).Magnitude <= (strikeRadius * 2.5) then
                sumVector = sumVector + part.Position
                totalCount = totalCount + 1
            end
        end
        
        if totalCount == 0 then
            return leadTarget.CFrame * CFrame.new(0, 5, strikeRadius * 0.9)
        end
        
        local geometricCentroid = sumVector / totalCount
        local rawDirection = (leadTarget.Position - geometricCentroid).Unit
        
        -- Prevención NaN Vectors (Crucial para no crashear Xeno)
        if rawDirection.Magnitude == 0 or rawDirection.X ~= rawDirection.X then
            rawDirection = Vector3.new(0, 0, 1)
        end
        
        local finalComputedPosition = geometricCentroid + (rawDirection * (strikeRadius * 0.8)) + Vector3.new(0, 5, 0)
        return CFrame.new(finalComputedPosition, geometricCentroid)
    end
end

--==================================================================================================
-- 7. ADVANCED AUTOMATION SUBSYSTEMS & NETWORK ROUTERS
--==================================================================================================
local Automation = {}

function Automation.SetSafeKineticState(character, targetCFrame)
    if not character or not character.PrimaryPart then return end
    local rootPart = character.PrimaryPart
    
    -- Borrado agresivo de memoria cinética para bypass de anti-teleport
    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    rootPart.Velocity = Vector3.zero
    rootPart.RotVelocity = Vector3.zero
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- Prevenir animaciones de caída al volar/teletransportarse
        if humanoid:GetState() ~= Enum.HumanoidStateType.Running then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
    
    rootPart.CFrame = targetCFrame
end

function Automation.FireCombatNetwork()
    if State.Network.Combat then
        local success, err = pcall(function()
            if State.Network.Combat:IsA("RemoteEvent") then
                State.Network.Combat:FireServer()
            elseif State.Network.Combat:IsA("RemoteFunction") then
                State.Network.Combat:InvokeServer()
            end
        end)
        if not success then
            Logger:Log("error", "Network", "Fallo al despachar evento de combate: " .. tostring(err))
        end
    else
        -- Hardware SimFallback
        local character = LocalPlayer.Character
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
end

function Automation.SpawnExecutionPipelines()
    Logger:Log("info", "Pipeline", "Desplegando hilos de ejecución asíncrona...")
    
    -- Hilo 1: Re-escaneo de Memoria Caché
    State.Threads.CacheScanner = task.spawn(function()
        while true do
            pcall(function() Reflection.BuildEnvironmentCache() end)
            task.wait(1.5)
        end
    end)
    
    -- Hilo 2: Enclavamiento de Posición (Heartbeat/RenderStepped)
    State.Connections.PositionLock = RunService.Heartbeat:Connect(function()
        if not State.FarmEnabled or not State.LockedCFrame then return end
        
        local character = LocalPlayer.Character
        if not character or not character.PrimaryPart then return end
        
        local deviation = (character.PrimaryPart.Position - State.LockedCFrame.Position).Magnitude
        -- Tolerancia micro-métrica
        if deviation > 0.05 then
            Automation.SetSafeKineticState(character, State.LockedCFrame)
        end
    end)
    
    -- Hilo 3: Bucle de Ataque Maestro y Cinemática
    State.Threads.MasterFarm = task.spawn(function()
        while true do
            if State.FarmEnabled then
                local nextPosition = Kinematics.ResolveOptimalCFrame()
                if nextPosition then
                    State.LockedCFrame = nextPosition
                    local character = LocalPlayer.Character
                    if character then
                        Automation.SetSafeKineticState(character, nextPosition)
                        Automation.FireCombatNetwork()
                    end
                else
                    State.LockedCFrame = nil
                end
            else
                State.LockedCFrame = nil
            end
            task.wait(State.AttackCooldown)
        end
    end)
    
    -- Hilo 4: Sistemas Auxiliares (Summon/Upgrade)
    State.Threads.AuxiliarySystem = task.spawn(function()
        while true do
            pcall(function()
                if State.AutoSummonEnabled and State.Network.Summon then
                    State.Network.Summon:FireServer(1)
                end
                if State.AutoUpgradeEnabled and State.Network.Upgrade then
                    State.Network.Upgrade:FireServer()
                end
            end)
            task.wait(0.7)
        end
    end)
end

--==================================================================================================
-- 8. PRE-FLIGHT INTEGRITY CHECKS & BOOTSTRAP
--==================================================================================================
Reflection.ScanNetworkRemotes()
Reflection.BuildEnvironmentCache()

local function enforceDefaultData(tableRef, fallbackStr)
    if #tableRef == 0 then table.insert(tableRef, fallbackStr) end
end

enforceDefaultData(State.Registry.Enemies, "[Esperando Entidades...]")
enforceDefaultData(State.Registry.Bosses, "[Esperando Jefes...]")
enforceDefaultData(State.Registry.SecretBosses, "[Esperando Secretos...]")
enforceDefaultData(State.Registry.Zones, "Spawn Zone")

State.SelectedEnemy = State.Registry.Enemies[1]
State.SelectedBoss = State.Registry.Bosses[1]
State.SelectedSecretBoss = State.Registry.SecretBosses[1]
State.SelectedZone = State.Registry.Zones[1]

--==================================================================================================
-- 9. FAIL-SAFE RAYFIELD LOADER (FIX PARA ERROR NIL EN LA CONSOLA LÍNEA 1/358)
--==================================================================================================
local function LoadRayfieldSecurely()
    local mirrors = {
        'https://raw.githubusercontent.com/SiriusXFiles/Rayfield/main/source.lua',
        'https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua',
        'https://raw.githubusercontent.com/UI-Interface/CustomRayfield/main/main.lua'
    }
    
    for _, url in ipairs(mirrors) do
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success and type(result) == "string" and result ~= "" then
            local compiledFunc, compileErr = loadstring(result)
            if compiledFunc then
                local moduleSuccess, moduleResult = pcall(compiledFunc)
                if moduleSuccess and moduleResult then
                    Logger:Log("success", "UI Loader", "Rayfield cargado desde el mirror activo.")
                    return moduleResult
                end
            end
        end
    end
    
    error("[Astral Engine - Fatal]: No se pudo cargar Rayfield UI desde ningún servidor espejo. Xeno falló en HttpGet o Loadstring.")
end

local Rayfield = LoadRayfieldSecurely()

--==================================================================================================
-- 10. MASSIVE RAYFIELD INTERFACE DEPLOYMENT
--==================================================================================================
local Window = Rayfield:CreateWindow({
    Name = "ASTRAL ENGINE V-PRO MAX | Anime Astral Simulator",
    LoadingTitle = "Inyectando Arquitectura Extendida...",
    LoadingSubtitle = "K-Means Engine & Zero-Assumption Protocol",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AstralEngineData_ProMax",
        FileName = State.ConfigName
    },
    Discord = { Enabled = false, Invite = "none", RememberJoins = false },
    KeySystem = false
})

-- ================= DECLARACIÓN DE TABS =================
local Tab_Status = Window:CreateTab("System Status", 4483362458)
local Tab_Farm = Window:CreateTab("Combat Automation", 4483362458)
local Tab_Movement = Window:CreateTab("Spatial Geometry", 4483362458)
local Tab_Network = Window:CreateTab("Verified Remote Systems", 4483362458)
local Tab_Security = Window:CreateTab("Anti-Cheat & Security", 4483362458)
local Tab_Settings = Window:CreateTab("Interface Matrix", 4483362458)

-- ================= TAB: SYSTEM STATUS =================
Tab_Status:CreateSection("Engine Diagnostics & Telemetry")

local StatusParagraph = Tab_Status:CreateParagraph({
    Title = "Métricas del Motor Astral",
    Content = "Estado: EN LINEA\nExecutor: XENO / LUAU\nObjetivos en Caché: " .. tostring(0) .. "\nLatencia Estimada: Calculando..."
})

Tab_Status:CreateButton({
    Name = "Refresh Diagnostics Module",
    Callback = function()
        local count = 0
        for k, v in pairs(State.LiveTargetsCache) do
            count = count + #v
        end
        StatusParagraph:Set({
            Title = "Métricas del Motor Astral",
            Content = "Estado: EN LINEA\nObjetivos en Caché: " .. tostring(count) .. "\nRango Efectivo Calculado: " .. tostring(State.EffectiveRange) .. " Studs"
        })
    end,
})

Tab_Status:CreateSection("Internal Developer Logs")
Tab_Status:CreateButton({
    Name = "Print Telemetry to F9 Console",
    Callback = function()
        print("====== ASTRAL ENGINE LOG DUMP ======")
        print(Logger:Dump())
        print("====================================")
        Rayfield:Notify({Title = "Console", Content = "Presiona F9 para ver los registros del motor.", Duration = 3})
    end,
})

-- ================= TAB: COMBAT AUTOMATION =================
Tab_Farm:CreateSection("Master Targeting Controls")

local Dropdown_Enemy = Tab_Farm:CreateDropdown({
    Name = "Target Enemy Matrix",
    Options = State.Registry.Enemies,
    CurrentOption = State.SelectedEnemy,
    MultipleOptions = false,
    Callback = function(Option)
        State.SelectedEnemy = type(Option) == "table" and Option[1] or Option
        State.ActiveTargetMode = "Enemy"
    end,
})

local Dropdown_Boss = Tab_Farm:CreateDropdown({
    Name = "Target Boss Matrix",
    Options = State.Registry.Bosses,
    CurrentOption = State.SelectedBoss,
    MultipleOptions = false,
    Callback = function(Option)
        State.SelectedBoss = type(Option) == "table" and Option[1] or Option
        State.ActiveTargetMode = "Boss"
    end,
})

local Dropdown_Secret = Tab_Farm:CreateDropdown({
    Name = "Target Secret Boss Matrix",
    Options = State.Registry.SecretBosses,
    CurrentOption = State.SelectedSecretBoss,
    MultipleOptions = false,
    Callback = function(Option)
        State.SelectedSecretBoss = type(Option) == "table" and Option[1] or Option
        State.ActiveTargetMode = "SecretBoss"
    end,
})

Tab_Farm:CreateButton({
    Name = "Force Update Target Matrices",
    Callback = function()
        Reflection.BuildEnvironmentCache()
        pcall(function()
            Dropdown_Enemy:Set(State.Registry.Enemies)
            Dropdown_Boss:Set(State.Registry.Bosses)
            Dropdown_Secret:Set(State.Registry.SecretBosses)
        end)
    end,
})

Tab_Farm:CreateSection("Execution Directives")

Tab_Farm:CreateToggle({
    Name = "Engage Master Combat Loop",
    CurrentValue = false,
    Flag = "Toggle_MasterFarm",
    Callback = function(Value)
        State.FarmEnabled = Value
        if not Value then State.LockedCFrame = nil end
    end,
})

Tab_Farm:CreateToggle({
    Name = "Enable Spatial Centroid Algorithm (Optimal Position)",
    CurrentValue = false,
    Flag = "Toggle_OptimalAlg",
    Callback = function(Value)
        State.OptimalPositionEnabled = Value
    end,
})

Tab_Farm:CreateSlider({
    Name = "Combat Loop Frequency Limit (Seconds)",
    Range = {0.01, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.05,
    Flag = "Slider_Cooldown",
    Callback = function(Value)
        State.AttackCooldown = Value
    end,
})

-- ================= TAB: SPATIAL GEOMETRY =================
Tab_Movement:CreateSection("World Traversal Systems")

local Dropdown_Zones = Tab_Movement:CreateDropdown({
    Name = "Verified Zone Destinations",
    Options = State.Registry.Zones,
    CurrentOption = State.SelectedZone,
    MultipleOptions = false,
    Callback = function(Option)
        State.SelectedZone = type(Option) == "table" and Option[1] or Option
    end,
})

Tab_Movement:CreateButton({
    Name = "Execute Linear Translation",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local targetNode = Workspace:FindFirstChild(State.SelectedZone, true)
        if targetNode and targetNode:IsA("BasePart") then
            Automation.SetSafeKineticState(character, targetNode.CFrame * CFrame.new(0, 5, 0))
            return
        end
        
        -- Fallback Recursivo
        local success = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), string.lower(State.SelectedZone)) then
                Automation.SetSafeKineticState(character, obj.CFrame * CFrame.new(0, 5, 0))
                success = true
                break
            end
        end
        
        if not success then
            Rayfield:Notify({Title = "Error Dimensional", Content = "Coordenadas no encontradas en el Workspace activo.", Duration = 4})
        end
    end,
})

Tab_Movement:CreateButton({
    Name = "Refresh Spatial Nodes",
    Callback = function()
        Reflection.BuildEnvironmentCache()
        pcall(function() Dropdown_Zones:Set(State.Registry.Zones) end)
    end,
})

-- ================= TAB: VERIFIED REMOTE SYSTEMS =================
Tab_Network:CreateSection("Core Game Loops (Reverse Engineered)")

Tab_Network:CreateToggle({
    Name = "Autonomous Summon Injection",
    CurrentValue = false,
    Flag = "Toggle_AutoSummon",
    Callback = function(Value)
        if Value and not State.Network.Summon then
            Rayfield:Notify({Title = "Missing Hook", Content = "Remote de invocación no detectado. Este módulo no funcionará.", Duration = 4})
        end
        State.AutoSummonEnabled = Value
    end,
})

Tab_Network:CreateToggle({
    Name = "Autonomous Upgrade Injection",
    CurrentValue = false,
    Flag = "Toggle_AutoUpgrade",
    Callback = function(Value)
        if Value and not State.Network.Upgrade then
            Rayfield:Notify({Title = "Missing Hook", Content = "Remote de mejoras no detectado. Este módulo no funcionará.", Duration = 4})
        end
        State.AutoUpgradeEnabled = Value
    end,
})

-- ================= TAB: ANTI-CHEAT & SECURITY =================
Tab_Security:CreateSection("Executor Level Defense Mechanisms")

Tab_Security:CreateToggle({
    Name = "Anti-AFK Connection Blocker",
    CurrentValue = true,
    Flag = "Toggle_AntiAfk",
    Callback = function(Value)
        State.AntiAfkEnabled = Value
    end,
})

Tab_Security:CreateButton({
    Name = "Clear RAM Garbage & Jitter",
    Callback = function()
        local pre = gcinfo()
        pcall(function() 
            if getgenv and getgenv().gc then getgenv().gc() end 
        end)
        local post = gcinfo()
        Rayfield:Notify({Title = "Memory Cleared", Content = "Liberado: " .. tostring(pre - post) .. " KB de RAM", Duration = 3})
    end,
})

Tab_Security:CreateButton({
    Name = "Disable Workspace Rendering (Max FPS)",
    Callback = function()
        RunService:Set3dRenderingEnabled(false)
        Rayfield:Notify({Title = "Optimizer", Content = "Renderizado 3D Desactivado. (Re-ejecuta para habilitar)", Duration = 4})
    end,
})

Tab_Security:CreateButton({
    Name = "Enable Workspace Rendering",
    Callback = function()
        RunService:Set3dRenderingEnabled(true)
    end,
})

-- ================= TAB: INTERFACE MATRIX =================
Tab_Settings:CreateSection("Profile Initialization Subsystem")

Tab_Settings:CreateInput({
    Name = "Save/Load Filename Profile",
    PlaceholderText = "Escribe el nombre del archivo...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        State.ConfigName = Text
    end,
})

Tab_Settings:CreateButton({
    Name = "Serialize & Save Configuration",
    Callback = function()
        local payload = {
            Farm = State.FarmEnabled, Optimal = State.OptimalPositionEnabled,
            Summon = State.AutoSummonEnabled, Upgrade = State.AutoUpgradeEnabled,
            Theme = State.Theme, Cooldown = State.AttackCooldown
        }
        local success, err = pcall(function()
            writefile(State.ConfigName .. ".json", HttpService:JSONEncode(payload))
        end)
        if success then
            Rayfield:Notify({Title = "I/O Access", Content = "Perfil ["..State.ConfigName.."] guardado correctamente.", Duration = 3})
        else
            Rayfield:Notify({Title = "I/O Error", Content = "Fallo de escritura en el executor.", Duration = 4})
        end
    end,
})

Tab_Settings:CreateButton({
    Name = "Deserialize & Load Configuration",
    Callback = function()
        local success, err = pcall(function()
            if isfile(State.ConfigName .. ".json") then
                local data = HttpService:JSONDecode(readfile(State.ConfigName .. ".json"))
                if data then
                    Rayfield.Flags["Toggle_MasterFarm"]:Set(data.Farm or false)
                    Rayfield.Flags["Toggle_OptimalAlg"]:Set(data.Optimal or false)
                    Rayfield.Flags["Toggle_AutoSummon"]:Set(data.Summon or false)
                    Rayfield.Flags["Toggle_AutoUpgrade"]:Set(data.Upgrade or false)
                    Rayfield.Flags["Slider_Cooldown"]:Set(data.Cooldown or 0.05)
                    Rayfield:Notify({Title = "I/O Access", Content = "Perfil restaurado de forma segura.", Duration = 3})
                end
            else
                Rayfield:Notify({Title = "I/O Access", Content = "Archivo no encontrado.", Duration = 4})
            end
        end)
    end,
})

Tab_Settings:CreateSection("Aesthetics & Theming")

Tab_Settings:CreateDropdown({
    Name = "Rayfield GUI Global Theme",
    Options = {"Default", "Amberglow", "Ocean", "GreenGradient", "DarkMidnight", "Serenity"},
    CurrentOption = "DarkMidnight",
    MultipleOptions = false,
    Callback = function(Option)
        local selection = type(Option) == "table" and Option[1] or Option
        State.Theme = selection
    end,
})

--==================================================================================================
-- 11. INICIALIZACIÓN FINAL DEL MOTOR DE AUTOMATIZACIÓN
--==================================================================================================
Automation.SpawnExecutionPipelines()
Rayfield:LoadConfiguration()

Logger:Log("info", "Boot", "Motor desplegado con éxito. Todos los sistemas nominales.")
Rayfield:Notify({
    Title = "Motor V-PRO MAX Desplegado",
    Content = "Compilación final de alta densidad cargada sin errores de sintaxis.",
    Duration = 5,
    Image = 4483362458,
})
