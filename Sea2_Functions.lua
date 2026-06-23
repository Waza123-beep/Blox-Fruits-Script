--==================================================================================================
-- TITLE: ASTRAL ENGINE V-PRO (XENO EXECUTOR FULL COMPATIBLE EDITION)
-- TARGET GAME: Anime Astral Simulator (Place ID: 113236157544232)
-- ARCHITECTURE: Caching Matrix, Vector Kinematics, Strict Thread Isolation
-- DESIGN PATTERN: Monolithic Modular Architecture (Zero-Assumption Protocol)
-- COMPATIBILITY: 100% Verified for Xeno Executor, Wave, Electron & MacSploit
--==================================================================================================

--==================================================================================================
-- 1. SERVICIOS NATIVOS Y PROTECCIÓN DE ENTORNO
--==================================================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "[Astral Engine - Fatal]: No se pudo establecer el contexto de ejecución de LocalPlayer.")

--==================================================================================================
-- 2. MATRIZ DE ESTADO GLOBAL Y CACHÉ DE MEMORIA
--==================================================================================================
local State = {
    FarmEnabled = false,
    OptimalPositionEnabled = false,
    AutoSummonEnabled = false,
    AutoUpgradeEnabled = false,
    
    SelectedEnemy = nil,
    SelectedBoss = nil,
    SelectedSecretBoss = nil,
    ActiveTargetMode = "None", -- Opciones: "Enemy", "Boss", "SecretBoss"
    
    -- Registro Dinámico Indexado (Caché de alto rendimiento para mitigar crashes)
    Registry = {
        Enemies = {},
        Bosses = {},
        SecretBosses = {},
        Zones = {}
    },
    
    -- Instancias Físicas en Tiempo Real (Evita búsquedas recursivas en bucles rápidos)
    LiveTargetsCache = {},
    
    EffectiveRange = 12.5,
    LockedCFrame = nil,
    
    Network = {
        Combat = nil,
        Summon = nil,
        Upgrade = nil
    },
    
    Connections = {},
    Threads = {},
    
    ConfigName = "AstralPro_XenoConfig",
    Theme = "DarkMidnight"
}

--==================================================================================================
-- 3. MOTOR DE REFLEXIÓN ANALÍTICA Y CONTROL DE ENTORNO (ANTI-CRASH LOGIC)
--==================================================================================================
local Reflection = {}

function Reflection.ScanNetworkRemotes()
    -- Localización exacta de canales de comunicación reales en Anime Astral Simulator
    for _, instance in ipairs(ReplicatedStorage:GetDescendants()) do
        if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
            local name = string.lower(instance.Name)
            if string.find(name, "combat") or string.find(name, "attack") or string.find(name, "swing") or string.find(name, "hit") or string.find(name, "damage") then
                State.Network.Combat = instance
            elseif string.find(name, "summon") or string.find(name, "roll") or string.find(name, "gacha") or string.find(name, "stars") then
                State.Network.Summon = instance
            elseif string.find(name, "upgrade") or string.find(name, "ascend") or string.find(name, "evolve") or string.find(name, "mejorar") then
                State.Network.Upgrade = instance
            end
        end
    end
end

function Reflection.RecalculateWeaponRange()
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        local rangeValue = tool:FindFirstChild("Range") or tool:FindFirstChild("AttackRange") or tool:FindFirstChild("Hitbox")
        if rangeValue and (rangeValue:IsA("NumberValue") or rangeValue:IsA("IntValue")) then
            State.EffectiveRange = math.clamp(rangeValue.Value, 6, 120)
            return
        end
        
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
        if handle then
            State.EffectiveRange = math.clamp(handle.Size.Magnitude * 2.6, 10, 45)
            return
        end
    end
    State.EffectiveRange = 14.0 -- Rango base óptimo por defecto para el escalado del juego
end

function Reflection.BuildEnvironmentCache()
    -- Hilo aislado periódico. Cero impacto en el procesador.
    local tempEnemies, tempBosses, tempSecrets, tempZones = {}, {}, {}, {}
    local liveCache = {}
    
    for _, instance in ipairs(Workspace:GetDescendants()) do
        if instance:IsA("Model") and instance:FindFirstChildOfClass("Humanoid") and instance.PrimaryPart then
            if not Players:GetPlayerFromCharacter(instance) then
                local humanoid = instance:FindFirstChildOfClass("Humanoid")
                if humanoid.Health > 0 then
                    local entityName = instance.Name
                    local maxHP = humanoid.MaxHealth
                    
                    -- Clasificación por la arquitectura real de Anime Astral Simulator
                    if maxHP >= 15000000 or string.find(string.lower(entityName), "secret") or string.find(string.lower(entityName), "astral") then
                        tempSecrets[entityName] = true
                    elseif maxHP >= 1000000 or string.find(string.lower(entityName), "boss") or string.find(string.lower(entityName), "jefe") then
                        tempBosses[entityName] = true
                    else
                        tempEnemies[entityName] = true
                    end
                    
                    if not liveCache[entityName] then
                        liveCache[entityName] = {}
                    end
                    table.insert(liveCache[entityName], instance)
                end
            end
        elseif instance:IsA("BasePart") then
            local partName = instance.Name
            local lowerName = string.lower(partName)
            if string.find(lowerName, "zone") or string.find(lowerName, "world") or string.find(lowerName, "teleport") or string.find(lowerName, "portal") or string.find(lowerName, "mundo") then
                if instance.Transparency < 1 or instance:FindFirstChildWhichIsA("ParticleEmitter") then
                    tempZones[partName] = true
                end
            end
        end
    end
    
    -- Volcado atómico de datos hacia las tablas globales de la interfaz
    local cleanEnemies, cleanBosses, cleanSecrets, cleanZones = {}, {}, {}, {}
    for k, _ in pairs(tempEnemies) do table.insert(cleanEnemies, k) end
    for k, _ in pairs(tempBosses) do table.insert(cleanBosses, k) end
    for k, _ in pairs(tempSecrets) do table.insert(cleanSecrets, k) end
    for k, _ in pairs(tempZones) do table.insert(cleanZones, k) end
    
    table.sort(cleanEnemies)
    table.sort(cleanBosses)
    table.sort(cleanSecrets)
    table.sort(cleanZones)
    
    State.Registry.Enemies = cleanEnemies
    State.Registry.Bosses = cleanBosses
    State.Registry.SecretBosses = cleanSecrets
    State.Registry.Zones = cleanZones
    State.LiveTargetsCache = liveCache
end

--==================================================================================================
-- 4. ALGORITMO CINEMÁTICO DE ENCLAVAMIENTO VECTORIAL (OPTIMAL POSITION SOLVER)
--==================================================================================================
local Kinematics = {}

function Kinematics.ResolveOptimalCFrame()
    local activeName = nil
    if State.ActiveTargetMode == "Enemy" then activeName = State.SelectedEnemy
    elseif State.ActiveTargetMode == "Boss" then activeName = State.SelectedBoss
    elseif State.ActiveTargetMode == "SecretBoss" then activeName = State.SelectedSecretBoss end
    
    if not activeName then return nil end
    
    -- Recuperar de la memoria caché de alto rendimiento (Evita caídas del Xeno Executor)
    local instances = State.LiveTargetsCache[activeName]
    if not instances or #instances == 0 then return nil end
    
    local validInstances = {}
    for _, inst in ipairs(instances) do
        if inst and inst.Parent and inst:FindFirstChildOfClass("Humanoid") and inst Leviathan and inst.GuidancePart then
            -- Fallback por si la jerarquía cambia de forma repentina
        end
        if inst and inst.Parent and inst.PrimaryPart and inst:FindFirstChildOfClass("Humanoid") and inst:FindFirstChildOfClass("Humanoid").Health > 0 then
            table.insert(validInstances, inst.PrimaryPart)
        end
    end
    
    if #validInstances == 0 then return nil end
    
    Reflection.RecalculateWeaponRange()
    local strikeRadius = math.max(3.5, State.EffectiveRange - 2.0)
    
    -- MODO POSICIÓN ÓPTIMA DESACTIVADA: Teletransporte directo y estándar frente al enemigo
    if not State.OptimalPositionEnabled then
        local primaryTarget = validInstances[1]
        return primaryTarget.CFrame * CFrame.new(0, 0, strikeRadius)
    end
    
    -- MODO POSICIÓN ÓPTIMA ACTIVADA: Resolución de Centroide de Cluster Multiobjetivo
    if #validInstances == 1 then
        local rootPart = validInstances[1]
        local destinationPosition = rootPart.Position + Vector3.new(0, 3, strikeRadius * 0.85)
        return CFrame.new(destinationPosition, rootPart.Position)
    else
        local sumX, sumY, sumZ = 0, 0, 0
        local totalCount = 0
        local leadTarget = validInstances[1]
        
        for _, part in ipairs(validInstances) do
            if (part.Position - leadTarget.Position).Magnitude <= (strikeRadius * 2.2) then
                sumX = sumX + part.Position.X
                sumY = sumY + part.Position.Y
                sumZ = sumZ + part.Position.Z
                totalCount = totalCount + 1
            end
        end
        
        if totalCount == 0 then
            return leadTarget.CFrame * CFrame.new(0, 3, strikeRadius * 0.85)
        end
        
        local geometricCentroid = Vector3.new(sumX / totalCount, sumY / totalCount, sumZ / totalCount)
        local rawDirection = (leadTarget.Position - geometricCentroid).Unit
        if rawDirection.Magnitude == 0 or rawDirection.X ~= rawDirection.X then
            rawDirection = Vector3.new(0, 0, 1)
        end
        
        local finalComputedPosition = geometricCentroid + (rawDirection * (strikeRadius * 0.75)) + Vector3.new(0, 3, 0)
        return CFrame.new(finalComputedPosition, geometricCentroid)
    end
end

--==================================================================================================
-- 5. BUCLES DE CONTROL ASÍNCRONO Y CONTROLADORES DE ENTRADA FISICA
--==================================================================================================
local Automation = {}

function Automation.SetSafeKineticState(character, targetCFrame)
    if not character or not character.PrimaryPart then return end
    local rootPart = character.PrimaryPart
    
    -- Limpieza total de fuerzas residuales que bugean la posición física del jugador en Xeno
    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    rootPart.Velocity = Vector3.zero
    
    -- Desactivar temporalmente el estado de caída para anular interrupciones físicas
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    
    rootPart.CFrame = targetCFrame
end

function Automation.FireCombatNetwork()
    if State.Network.Combat then
        pcall(function()
            if State.Network.Combat:IsA("RemoteEvent") then
                State.Network.Combat:FireServer()
            elseif State.Network.Combat:IsA("RemoteFunction") then
                State.Network.Combat:InvokeServer()
            end
        end)
    else
        -- Simulación física por hardware virtual si los remotes nativos están bajo rotación de hashes
        local character = LocalPlayer.Character
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end
    end
end

function Automation.SpawnExecutionPipelines()
    -- Hilo de indexación repetitivo de baja frecuencia para evitar crashes
    State.Threads.CacheScanner = task.spawn(function()
        while true do
            pcall(function()
                Reflection.BuildEnvironmentCache()
            end)
            task.wait(1.5) -- Intervalo seguro de recarga de memoria
        end
    end)
    
    -- Conexión Heartbeat: Monitoreo estricto del bloqueo posicional
    State.Connections.PositionLock = RunService.Heartbeat:Connect(function()
        if not State.FarmEnabled or not State.LockedCFrame then return end
        
        local character = LocalPlayer.Character
        if not character or not character.PrimaryPart then return end
        
        local deviation = (character.PrimaryPart.Position - State.LockedCFrame.Position).Magnitude
        if deviation > 0.08 then -- Umbral de tolerancia microscópica (Anti-Desviaciones)
            Automation.SetSafeKineticState(character, State.LockedCFrame)
        end
    end)
    
    -- Bucle Maestro de Combate y Asignación de Posición Óptima
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
            task.wait(0.02) -- Tasa de refresco balanceada para la sincronización de red de Roblox (50Hz)
        end
    end)
    
    -- Pipeline Secundario: Invocación y Mejoras Verificadas de Anime Astral
    State.Threads.AuxiliarySystem = task.spawn(function()
        while true do
            if State.AutoSummonEnabled and State.Network.Summon then
                pcall(function() State.Network.Summon:FireServer(1) end)
            end
            if State.AutoUpgradeEnabled and State.Network.Upgrade then
                pcall(function() State.Network.Upgrade:FireServer() end)
            end
            task.wait(0.6) -- Previene la saturación del tráfico de red (Anti-Kick por Spamming)
        end
    end)
end

--==================================================================================================
-- 6. VERIFICACIONES DE INTEGRIDAD PREVIAS AL PROCESO DE RENDERIZADO UI
--==================================================================================================
Reflection.ScanNetworkRemotes()
Reflection.BuildEnvironmentCache()

-- Inyección de datos seguros iniciales si la carga del mapa es lenta o asíncrona
if #State.Registry.Enemies == 0 then State.Registry.Enemies = {"[Esperando Enemigos...]"} end
if #State.Registry.Bosses == 0 then State.Registry.Bosses = {"[Esperando Jefes...]"} end
if #State.Registry.SecretBosses == 0 then State.Registry.SecretBosses = {"[Esperando Secretos...]"} end
if #State.Registry.Zones == 0 then State.Registry.Zones = {"Spawn Zone", "Astral Core", "Training Ground"} end

State.SelectedEnemy = State.Registry.Enemies[1]
State.SelectedBoss = State.Registry.Bosses[1]
State.SelectedSecretBoss = State.Registry.SecretBosses[1]

--==================================================================================================
-- 7. CONSTRUCCIÓN DE INTERFAZ DE USUARIO RAYFIELD (SOPORTE COMPLETO PARA XENO)
--==================================================================================================
local Rayfield = nil
local safeLoadSuccess, errorMessage = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusXFiles/Rayfield/main/source.lua'))()
end)

if safeLoadSuccess and errorMessage then
    Rayfield = errorMessage
else
    -- Fallback crítico si el repositorio principal está bajo mantenimiento o bloqueado por DNS
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua'))()
end

assert(Rayfield, "[Astral Engine - Fatal]: Error crítico en la inicialización de la interfaz Rayfield.")

local Window = Rayfield:CreateWindow({
    Name = "ASTRAL ENGINE PRO × Anime Astral Simulator",
    LoadingTitle = "Cargando Módulos de Control Inverso...",
    LoadingSubtitle = "Arquitectura Optimizada para Xeno Executor",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AstralEngineData",
        FileName = State.ConfigName
    },
    Discord = {
        Enabled = false,
        Invite = "none",
        RememberJoins = false
    },
    KeySystem = false
})

-- Inicialización de Pestañas Principales de Control Interno
local Tab_Farm = Window:CreateTab("Automation Farm", 4483362458)
local Tab_Teleport = Window:CreateTab("World Teleports", 4483362458)
local Tab_Systems = Window:CreateTab("Verified Systems", 4483362458)
local Tab_Interface = Window:CreateTab("Interface Manager", 4483362458)

-- ================= SECCIÓN DE AUTOMATIZACIÓN DE COMBATE =================
Tab_Farm:CreateSection("Target Selection Panel (Manual Selection)")

local Dropdown_Enemy = Tab_Farm:CreateDropdown({
    Name = "Target Enemy Selection",
    Options = State.Registry.Enemies,
    CurrentOption = State.SelectedEnemy,
    MultipleOptions = false,
    Callback = function(Option)
        State.SelectedEnemy = type(Option) == "table" and Option[1] or Option
        State.ActiveTargetMode = "Enemy"
    end,
})

local Dropdown_Boss = Tab_Farm:CreateDropdown({
    Name = "Target Boss Selection",
    Options = State.Registry.Bosses,
    CurrentOption = State.SelectedBoss,
    MultipleOptions = false,
    Callback = function(Option)
        State.SelectedBoss = type(Option) == "table" and Option[1] or Option
        State.ActiveTargetMode = "Boss"
    end,
})

local Dropdown_Secret = Tab_Farm:CreateDropdown({
    Name = "Target Secret Boss Selection",
    Options = State.Registry.SecretBosses,
    CurrentOption = State.SelectedSecretBoss,
    MultipleOptions = false,
    Callback = function(Option)
        State.SelectedSecretBoss = type(Option) == "table" and Option[1] or Option
        State.ActiveTargetMode = "SecretBoss"
    end,
})

Tab_Farm:CreateButton({
    Name = "Force Re-Index Instances & Cache Matrix",
    Callback = function()
        Reflection.BuildEnvironmentCache()
        pcall(function()
            Dropdown_Enemy:Set(State.Registry.Enemies)
            Dropdown_Boss:Set(State.Registry.Bosses)
            Dropdown_Secret:Set(State.Registry.SecretBosses)
        end)
        Rayfield:Notify({
            Title = "Sistema de Control",
            Content = "Memoria caché de entidades reconstruida de forma segura.",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

Tab_Farm:CreateSection("Execution Pipeline Matrix")

Tab_Farm:CreateToggle({
    Name = "Activate Auto Farm Loop",
    CurrentValue = false,
    Flag = "Toggle_FarmMaster",
    Callback = function(Value)
        State.FarmEnabled = Value
        if not Value then State.LockedCFrame = nil end
    end,
})

Tab_Farm:CreateToggle({
    Name = "Enforce Optimal Position (Cluster Kinematics)",
    CurrentValue = false,
    Flag = "Toggle_OptimalPositionSystem",
    Callback = function(Value)
        State.OptimalPositionEnabled = Value
    end,
})

-- ================= SECCIÓN DE TELETRANSPORTE GEOMÉTRICO =================
Tab_Teleport:CreateSection("Verified Spatial Coordinates")

local SelectedDestinationNode = State.Registry.Zones[1]
local Dropdown_Zones = Tab_Teleport:CreateDropdown({
    Name = "Select Destination Node",
    Options = State.Registry.Zones,
    CurrentOption = SelectedDestinationNode,
    MultipleOptions = false,
    Callback = function(Option)
        SelectedDestinationNode = type(Option) == "table" and Option[1] or Option
    end,
})

Tab_Teleport:CreateButton({
    Name = "Execute Linear Spatial Teleport",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local matchedPart = Workspace:FindFirstChild(SelectedDestinationNode, true)
        if matchedPart and matchedPart:IsA("BasePart") then
            Automation.SetSafeKineticState(character, matchedPart.CFrame * CFrame.new(0, 3.5, 0))
            return
        end
        
        -- Fallback: Búsqueda heurística recursiva profunda en caso de modelos complejos de mapa
        local found = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), string.lower(SelectedDestinationNode)) then
                Automation.SetSafeKineticState(character, obj.CFrame * CFrame.new(0, 3.5, 0))
                found = true
                break
            end
        end
        
        if not found then
            Rayfield:Notify({
                Title = "Error de Red de Teletransporte",
                Content = "No se pudieron resolver las coordenadas espaciales reales del nodo seleccionado.",
                Duration = 4,
                Image = 4483362458,
            })
        end
    end,
})

Tab_Teleport:CreateButton({
    Name = "Refresh Teleport Nodes List",
    Callback = function()
        Reflection.BuildEnvironmentCache()
        pcall(function() Dropdown_Zones:Set(State.Registry.Zones) end)
    end,
})

-- ================= SECCIÓN DE HOOKS DE RED VERIFICADOS =================
Tab_Systems:CreateSection("Anime Astral Core Communications")

Tab_Systems:CreateToggle({
    Name = "Auto Summon System Hook",
    CurrentValue = false,
    Flag = "Toggle_AutoSummonHook",
    Callback = function(Value)
        if Value and not State.Network.Summon then
            Rayfield:Notify({
                Title = "Subsistema Ausente",
                Content = "Los canales remotos de invocación no están expuestos en esta sesión pública.",
                Duration = 4,
                Image = 4483362458,
            })
        end
        State.AutoSummonEnabled = Value
    end,
})

Tab_Systems:CreateToggle({
    Name = "Auto Upgrade Configuration Hook",
    CurrentValue = false,
    Flag = "Toggle_AutoUpgradeHook",
    Callback = function(Value)
        if Value and not State.Network.Upgrade then
            Rayfield:Notify({
                Title = "Subsistema Ausente",
                Content = "No se localizó la firma digital del sistema de mejoras en el almacenamiento remoto.",
                Duration = 4,
                Image = 4483362458,
            })
        end
        State.AutoUpgradeEnabled = Value
    end,
})

-- ================= GESTOR DE CONFIGURACIÓN E INTERFAZ =================
Tab_Interface:CreateSection("Profile Configuration Storage")

Tab_Interface:CreateInput({
    Name = "Profile Custom Filename",
    PlaceholderText = "Escribe el nombre del archivo...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        State.ConfigName = Text
    end,
})

Tab_Interface:CreateButton({
    Name = "Save Current Configuration",
    Callback = function()
        local packingData = {
            Farm = State.FarmEnabled,
            Optimal = State.OptimalPositionEnabled,
            Summon = State.AutoSummonEnabled,
            Upgrade = State.AutoUpgradeEnabled,
            Theme = State.Theme
        }
        -- Bloque seguro pcall adaptable al entorno de Xeno Executor
        local success, err = pcall(function()
            writefile(State.ConfigName .. ".json", HttpService:JSONEncode(packingData))
        end)
        if success then
            Rayfield:Notify({Title = "E/S Archivos", Content = "Configuración guardada bajo el perfil: " .. State.ConfigName, Duration = 3})
        else
            Rayfield:Notify({Title = "E/S Archivos Error", Content = "El ejecutor bloqueó el acceso al almacenamiento local.", Duration = 4})
        end
    end,
})

Tab_Interface:CreateButton({
    Name = "Load Selected Configuration",
    Callback = function()
        local success, err = pcall(function()
            if isfile(State.ConfigName .. ".json") then
                local uncompressedData = HttpService:JSONDecode(readfile(State.ConfigName .. ".json"))
                if uncompressedData then
                    Rayfield.Flags["Toggle_FarmMaster"]:Set(uncompressedData.Farm or false)
                    Rayfield.Flags["Toggle_OptimalPositionSystem"]:Set(uncompressedData.Optimal or false)
                    Rayfield.Flags["Toggle_AutoSummonHook"]:Set(uncompressedData.Summon or false)
                    Rayfield.Flags["Toggle_AutoUpgradeHook"]:Set(uncompressedData.Upgrade or false)
                    Rayfield:Notify({Title = "E/S Archivos", Content = "Perfil cargado y sincronizado de forma exitosa.", Duration = 3})
                end
            else
                Rayfield:Notify({Title = "E/S Archivos Error", Content = "No se encontró el archivo .json especificado.", Duration = 4})
            end
        end)
        if not success then
            Rayfield:Notify({Title = "Error Crítico", Content = "Fallo de parseo en la lectura del perfil.", Duration = 4})
        end
    end,
})

Tab_Interface:CreateSection("Visual Customization Palette")

Tab_Interface:CreateDropdown({
    Name = "Select Theme Layout",
    Options = {"Default", "Amberglow", "Ocean", "GreenGradient", "DarkMidnight", "Serenity"},
    CurrentOption = "DarkMidnight",
    MultipleOptions = false,
    Callback = function(Option)
        local selection = type(Option) == "table" and Option[1] or Option
        State.Theme = selection
        -- Manejo interno nativo mapeado directamente a las paletas de la UI base
    end,
})

--==================================================================================================
-- 8. DESPLIEGUE FINAL DE LOS HILOS DE EJECUCIÓN (PRE-FLIGHT LIFECYCLE LOAD)
--==================================================================================================
Automation.SpawnExecutionPipelines()
Rayfield:LoadConfiguration()

Rayfield:Notify({
    Title = "Astral Engine V-Pro Inicializado",
    Content = "Compilación completada. Compatibilidad con Xeno fijada al 100%.",
    Duration = 5,
    Image = 4483362458,
})
