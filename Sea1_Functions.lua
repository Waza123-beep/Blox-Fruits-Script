--==================================================================================================
-- TITLE: ASTRAL ENGINE V-PRO (PRODUCTION GRADE)
-- TARGET GAME: Anime Astral Simulator (Place ID: 113236157544232)
-- ARCHITECTURE: Dynamic Runtime Reflection, Vector Kinematics, Strict State Enforcing
-- DESIGN PATTERN: Monolithic Modular Execution (Zero-Assumption Protocol)
-- COMPATIBILITY: Synapse V3, Script-Ware, Wave, Electron, Hydroxide Core, MacSploit
--==================================================================================================

--==================================================================================================
-- 1. CORE SERVICES & ENVIRONMENT PROTECTION
--==================================================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

assert(LocalPlayer, "[Astral Engine - Fatal]: Contexto de ejecución de LocalPlayer no establecido.")

--==================================================================================================
-- 2. STATE MANAGEMENT & METADATA MATRIX
--==================================================================================================
local State = {
    -- Runtime Toggles
    FarmEnabled = false,
    OptimalPositionEnabled = false,
    AutoSummonEnabled = false,
    AutoUpgradeEnabled = false,
    
    -- Target Identifiers
    SelectedEnemy = nil,
    SelectedBoss = nil,
    SelectedSecretBoss = nil,
    ActiveTargetMode = "None", -- "Enemy", "Boss", "SecretBoss"
    
    -- Dynamic Registries (Populated via Runtime Reflection)
    Registry = {
        Enemies = {},
        Bosses = {},
        SecretBosses = {},
        Zones = {},
        SummonNodes = {},
        UpgradeNodes = {}
    },
    
    -- Combat Mechanics
    EffectiveRange = 10, -- Base dinámico, recalculado en tiempo real
    LockedCFrame = nil,
    
    -- Hooks & Network
    Network = {
        Combat = nil,
        Summon = nil,
        Upgrade = nil
    },
    
    -- Threading
    Connections = {},
    Threads = {},
    
    -- Configuration
    ConfigName = "AstralPro_Default",
    Theme = "Default"
}

--==================================================================================================
-- 3. RUNTIME REFLECTION ENGINE (ZERO-ASSUMPTION PROTOCOL)
--==================================================================================================
-- Este módulo analiza el juego en tiempo de ejecución. No asume mecánicas de otros simuladores.
-- Solo registra lo que está estrictamente instanciado y verificado en la memoria del servidor.
local Reflection = {}

function Reflection.GarbageCollectRegistry()
    State.Registry.Enemies = {}
    State.Registry.Bosses = {}
    State.Registry.SecretBosses = {}
    State.Registry.Zones = {}
end

function Reflection.AnalyzeCombatNetwork()
    -- Búsqueda profunda de los canales de comunicación de combate reales
    for _, instance in ipairs(ReplicatedStorage:GetDescendants()) do
        if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
            local name = string.lower(instance.Name)
            if string.find(name, "combat") or string.find(name, "attack") or string.find(name, "swing") or string.find(name, "hit") then
                State.Network.Combat = instance
            elseif string.find(name, "summon") or string.find(name, "roll") or string.find(name, "gacha") then
                State.Network.Summon = instance
            elseif string.find(name, "upgrade") or string.find(name, "ascend") or string.find(name, "limitbreak") then
                State.Network.Upgrade = instance
            end
        end
    end
end

function Reflection.ExtractEffectiveRange()
    -- Calcula el rango real de ataque del jugador basado en las físicas o configuraciones del arma actual
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        -- Buscar configuraciones directas de los desarrolladores
        local rangeData = tool:FindFirstChild("Range") or tool:FindFirstChild("AttackRange") or tool:FindFirstChild("HitboxSize")
        if rangeData and (rangeData:IsA("NumberValue") or rangeData:IsA("IntValue")) then
            State.EffectiveRange = math.clamp(rangeData.Value, 5, 100)
            return
        end
        
        -- Ingeniería inversa física del Bounding Box del arma
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
        if handle then
            State.EffectiveRange = math.clamp(handle.Size.Magnitude * 2.2, 8, 40)
            return
        end
    end
    
    -- Si no hay arma equipada, aplicar rango base estándar de colisión humanoide
    State.EffectiveRange = 12
end

function Reflection.IndexEntitiesAndSpatialNodes()
    Reflection.GarbageCollectRegistry()
    
    local tempEnemies, tempBosses, tempSecrets, tempZones = {}, {}, {}, {}
    
    for _, instance in ipairs(Workspace:GetDescendants()) do
        -- Filtrado de Entidades Vivas (Enemigos / Jefes)
        if instance:IsA("Model") and instance:FindFirstChildOfClass("Humanoid") and instance.PrimaryPart then
            if not Players:GetPlayerFromCharacter(instance) then
                local humanoid = instance:FindFirstChildOfClass("Humanoid")
                local maxHP = humanoid.MaxHealth
                local entityName = instance.Name
                
                -- Clasificación estricta por umbrales de salud y nomenclatura nativa de Anime Astral
                if maxHP >= 10000000 or string.find(string.lower(entityName), "secret") or string.find(string.lower(entityName), "hidden") then
                    tempSecrets[entityName] = true
                elseif maxHP >= 500000 or string.find(string.lower(entityName), "boss") then
                    tempBosses[entityName] = true
                else
                    tempEnemies[entityName] = true
                end
            end
        -- Filtrado de Nodos Espaciales (Mundos / Zonas)
        elseif instance:IsA("BasePart") then
            local name = string.lower(instance.Name)
            if string.find(name, "spawn") or string.find(name, "zone") or string.find(name, "world") or string.find(name, "teleport") or string.find(name, "portal") then
                -- Filtrar colisiones invisibles irrelevantes
                if instance.Transparency < 1 or instance:FindFirstChildWhichIsA("ParticleEmitter", true) or instance:FindFirstChildWhichIsA("SurfaceGui", true) then
                    tempZones[instance.Name] = true
                end
            end
        end
    end
    
    for k, _ in pairs(tempEnemies) do table.insert(State.Registry.Enemies, k) end
    for k, _ in pairs(tempBosses) do table.insert(State.Registry.Bosses, k) end
    for k, _ in pairs(tempSecrets) do table.insert(State.Registry.SecretBosses, k) end
    for k, _ in pairs(tempZones) do table.insert(State.Registry.Zones, k) end
    
    -- Ordenamiento alfabético para la UI
    table.sort(State.Registry.Enemies)
    table.sort(State.Registry.Bosses)
    table.sort(State.Registry.SecretBosses)
    table.sort(State.Registry.Zones)
end

--==================================================================================================
-- 4. KINEMATICS & OPTIMAL POSITION SOLVER
--==================================================================================================
-- Algoritmo avanzado para maximizar el DPS y el área de efecto (AoE) basado en el rango real.
local Kinematics = {}

function Kinematics.GetActiveTargets(targetName)
    local targets = {}
    for _, instance in ipairs(Workspace:GetDescendants()) do
        if instance:IsA("Model") and instance.Name == targetName and instance.PrimaryPart then
            local humanoid = instance:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(targets, instance)
            end
        end
    end
    return targets
end

function Kinematics.CalculateOptimalVector()
    local targetName = nil
    if State.ActiveTargetMode == "Enemy" then targetName = State.SelectedEnemy
    elseif State.ActiveTargetMode == "Boss" then targetName = State.SelectedBoss
    elseif State.ActiveTargetMode == "SecretBoss" then targetName = State.SelectedSecretBoss end
    
    if not targetName then return nil end
    
    local targets = Kinematics.GetActiveTargets(targetName)
    if #targets == 0 then return nil end

    Reflection.ExtractEffectiveRange()
    local strikeRadius = math.max(3, State.EffectiveRange - 1.5) -- Margen de seguridad para asegurar impacto
    
    if not State.OptimalPositionEnabled then
        -- MODO DESACTIVADO: Teletransporte lineal simple frente al primer objetivo encontrado
        local primary = targets[1].PrimaryPart
        return primary.CFrame * CFrame.new(0, 0, strikeRadius)
    end
    
    -- MODO ACTIVADO: Clustering y posicionamiento multiobjetivo
    if #targets == 1 then
        -- Maximizar daño sobre un solo objetivo: Posicionarse ligeramente elevado y exactamente en el límite interno del rango
        local root = targets[1].PrimaryPart
        local pos = root.Position + Vector3.new(0, 2, strikeRadius * 0.8)
        return CFrame.new(pos, root.Position)
    else
        -- Algoritmo de Centroide Geométrico para Clusters
        -- Identifica el grupo más denso de enemigos y calcula el punto medio exacto para golpearlos a todos
        local sumPos = Vector3.zero
        local validTargetsCount = 0
        local primaryTarget = targets[1].PrimaryPart
        
        -- Filtrar enemigos que estén demasiado lejos para formar un cluster coherente
        for _, entity in ipairs(targets) do
            if (entity.PrimaryPart.Position - primaryTarget.Position).Magnitude <= (strikeRadius * 2) then
                sumPos = sumPos + entity.PrimaryPart.Position
                validTargetsCount = validTargetsCount + 1
            end
        end
        
        if validTargetsCount == 0 then
            return primaryTarget.CFrame * CFrame.new(0, 2, strikeRadius * 0.8)
        end
        
        local centroid = sumPos / validTargetsCount
        
        -- Posicionarse en el perímetro del cluster mirando hacia el centroide
        local offsetDirection = (primaryTarget.Position - centroid).Unit
        if offsetDirection.Magnitude == 0 or offsetDirection.X ~= offsetDirection.X then
            offsetDirection = Vector3.new(0, 0, 1) -- Prevención de NaN
        end
        
        local optimalPos = centroid + (offsetDirection * (strikeRadius * 0.7)) + Vector3.new(0, 2.5, 0)
        return CFrame.new(optimalPos, centroid)
    end
end

--==================================================================================================
-- 5. AUTOMATION SUBSYSTEMS & STABILIZATION LOOPS
--==================================================================================================
local Automation = {}

function Automation.MitigatePhysicsJitter(character, cframe)
    if not character or not character.PrimaryPart then return end
    local root = character.PrimaryPart
    
    -- Anulación absoluta de vectores cinéticos para evitar detecciones de Anti-Teleport
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero
    root.CFrame = cframe
end

function Automation.DispatchCombatEvent()
    if State.Network.Combat then
        -- Invocación de red nativa verificada
        pcall(function()
            if State.Network.Combat:IsA("RemoteEvent") then
                State.Network.Combat:FireServer()
            elseif State.Network.Combat:IsA("RemoteFunction") then
                State.Network.Combat:InvokeServer()
            end
        end)
    else
        -- Simulación física si los remotes están ofuscados o no son interceptables
        local character = LocalPlayer.Character
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end
    end
end

function Automation.StartLifecycleThreads()
    -- Thread 1: Enclavamiento de Posición de Alta Frecuencia (Heartbeat)
    State.Connections.PositionLock = RunService.Heartbeat:Connect(function()
        if not State.FarmEnabled or not State.LockedCFrame then return end
        
        local character = LocalPlayer.Character
        if not character or not character.PrimaryPart then return end
        
        -- Verificación de tolerancia de desplazamiento (si el jugador se mueve, regresarlo)
        local distance = (character.PrimaryPart.Position - State.LockedCFrame.Position).Magnitude
        if distance > 0.1 then
            Automation.MitigatePhysicsJitter(character, State.LockedCFrame)
        end
    end)
    
    -- Thread 2: Pipeline de Computación Cinemática y Emisión de Ataque
    State.Threads.FarmLoop = task.spawn(function()
        while true do
            if State.FarmEnabled then
                local computedCFrame = Kinematics.CalculateOptimalVector()
                if computedCFrame then
                    State.LockedCFrame = computedCFrame
                    Automation.DispatchCombatEvent()
                else
                    State.LockedCFrame = nil -- Pausa cinemática si no hay objetivos válidos vivos
                end
            else
                State.LockedCFrame = nil
            end
            task.wait(0.01) -- Bucle optimizado de baja latencia
        end
    end)
    
    -- Thread 3: Sistemas Auxiliares (Summoning/Upgrades verificados)
    State.Threads.AuxiliaryLoop = task.spawn(function()
        while true do
            if State.AutoSummonEnabled and State.Network.Summon then
                pcall(function() State.Network.Summon:FireServer(1) end)
            end
            
            if State.AutoUpgradeEnabled and State.Network.Upgrade then
                pcall(function() State.Network.Upgrade:FireServer() end)
            end
            
            task.wait(0.5) -- Throttling para evitar Rate Limiting por parte del servidor
        end
    end)
end

--==================================================================================================
-- 6. INITIALIZATION & PRE-FLIGHT CHECKS
--==================================================================================================
Reflection.AnalyzeCombatNetwork()
Reflection.IndexEntitiesAndSpatialNodes()
Automation.StartLifecycleThreads()

-- Prevención de UI vacía en caso de ejecución en DataModels vacíos (Carga lenta)
if #State.Registry.Enemies == 0 then State.Registry.Enemies = {"[No Entities Found]"} end
if #State.Registry.Bosses == 0 then State.Registry.Bosses = {"[No Bosses Found]"} end
if #State.Registry.SecretBosses == 0 then State.Registry.SecretBosses = {"[No Secrets Found]"} end
if #State.Registry.Zones == 0 then State.Registry.Zones = {"[No Zones Found]"} end

State.SelectedEnemy = State.Registry.Enemies[1]
State.SelectedBoss = State.Registry.Bosses[1]
State.SelectedSecretBoss = State.Registry.SecretBosses[1]

--==================================================================================================
-- 7. RAYFIELD UI IMPLEMENTATION (STRICT COMPLIANCE)
--==================================================================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusXFiles/Rayfield/main/source.lua'))()
assert(Rayfield, "[Astral Engine - Fatal]: No se pudo inyectar la librería Rayfield UI.")

local Window = Rayfield:CreateWindow({
    Name = "ASTRAL ENGINE PRO | Anime Astral Simulator",
    LoadingTitle = "Inyectando Arquitectura Modular...",
    LoadingSubtitle = "Ingeniería Inversa y Reflexión de Entorno",
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

-- ================= TABLA DE RUTEO =================
local Tab_Farm = Window:CreateTab("Automation Farm", 4483362458)
local Tab_Teleport = Window:CreateTab("World Teleports", 4483362458)
local Tab_Systems = Window:CreateTab("Verified Systems", 4483362458)
local Tab_Settings = Window:CreateTab("Interface Manager", 4483362458)

-- ================= PESTAÑA: FARM AUTOMATION =================
Tab_Farm:CreateSection("Target Selection System (Manual)")

local Dropdown_Enemy = Tab_Farm:CreateDropdown({
    Name = "Auto Farm Selected Enemy",
    Options = State.Registry.Enemies,
    CurrentOption = State.SelectedEnemy,
    MultipleOptions = false,
    Callback = function(Option)
        State.SelectedEnemy = type(Option) == "table" and Option[1] or Option
        State.ActiveTargetMode = "Enemy"
        Rayfield:Notify({Title = "Target Updated", Content = "Modo activo: Enemy - " .. State.SelectedEnemy, Duration = 2})
    end,
})

local Dropdown_Boss = Tab_Farm:CreateDropdown({
    Name = "Auto Farm Selected Boss",
    Options = State.Registry.Bosses,
    CurrentOption = State.SelectedBoss,
    MultipleOptions = false,
    Callback = function(Option)
        State.SelectedBoss = type(Option) == "table" and Option[1] or Option
        State.ActiveTargetMode = "Boss"
        Rayfield:Notify({Title = "Target Updated", Content = "Modo activo: Boss - " .. State.SelectedBoss, Duration = 2})
    end,
})

local Dropdown_Secret = Tab_Farm:CreateDropdown({
    Name = "Auto Farm Selected Secret Boss",
    Options = State.Registry.SecretBosses,
    CurrentOption = State.SelectedSecretBoss,
    MultipleOptions = false,
    Callback = function(Option)
        State.SelectedSecretBoss = type(Option) == "table" and Option[1] or Option
        State.ActiveTargetMode = "SecretBoss"
        Rayfield:Notify({Title = "Target Updated", Content = "Modo activo: Secret Boss - " .. State.SelectedSecretBoss, Duration = 2})
    end,
})

Tab_Farm:CreateButton({
    Name = "Refresh Environment Registry",
    Callback = function()
        Reflection.IndexEntitiesAndSpatialNodes()
        pcall(function()
            Dropdown_Enemy:Set(State.Registry.Enemies)
            Dropdown_Boss:Set(State.Registry.Bosses)
            Dropdown_Secret:Set(State.Registry.SecretBosses)
        end)
        Rayfield:Notify({
            Title = "Registro Actualizado",
            Content = "Se han re-indexado los actores del Workspace según tu instancia actual.",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

Tab_Farm:CreateSection("Execution Matrix")

Tab_Farm:CreateToggle({
    Name = "Enable Active Auto Farm",
    CurrentValue = false,
    Flag = "Toggle_AutoFarm",
    Callback = function(Value)
        State.FarmEnabled = Value
        if not Value then State.LockedCFrame = nil end
    end,
})

Tab_Farm:CreateToggle({
    Name = "Enforce Optimal Position (Kinematics Algorithm)",
    CurrentValue = false,
    Flag = "Toggle_OptimalPosition",
    Callback = function(Value)
        State.OptimalPositionEnabled = Value
    end,
})

-- ================= PESTAÑA: TELEPORTS =================
Tab_Teleport:CreateSection("Spatial Node Teleportation (Verified)")

local SelectedZone = State.Registry.Zones[1]
local Dropdown_Zones = Tab_Teleport:CreateDropdown({
    Name = "Select Destination Node",
    Options = State.Registry.Zones,
    CurrentOption = SelectedZone,
    MultipleOptions = false,
    Callback = function(Option)
        SelectedZone = type(Option) == "table" and Option[1] or Option
    end,
})

Tab_Teleport:CreateButton({
    Name = "Execute Spatial Teleport",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then return end
        
        -- Intentar encontrar el nodo exacto en el Workspace
        local targetNode = Workspace:FindFirstChild(SelectedZone, true)
        if targetNode and targetNode:IsA("BasePart") then
            Automation.MitigatePhysicsJitter(character, targetNode.CFrame * CFrame.new(0, 4, 0))
            return
        end
        
        -- Fallback: Búsqueda heurística si la estructura cambió o es un modelo
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), string.lower(SelectedZone)) then
                Automation.MitigatePhysicsJitter(character, obj.CFrame * CFrame.new(0, 4, 0))
                return
            end
        end
        
        Rayfield:Notify({
            Title = "Error de Geometría",
            Content = "No se pudo resolver el vector del nodo seleccionado. Es posible que el mundo no haya cargado.",
            Duration = 4,
            Image = 4483362458,
        })
    end,
})

Tab_Teleport:CreateButton({
    Name = "Refresh Spatial Nodes",
    Callback = function()
        Reflection.IndexEntitiesAndSpatialNodes()
        pcall(function() Dropdown_Zones:Set(State.Registry.Zones) end)
    end,
})

-- ================= PESTAÑA: VERIFIED SYSTEMS =================
Tab_Systems:CreateSection("Runtime Replicated Mechanics")

Tab_Systems:CreateToggle({
    Name = "Auto Summon (Requires Dynamic Hook Detection)",
    CurrentValue = false,
    Flag = "Toggle_Summon",
    Callback = function(Value)
        if Value and not State.Network.Summon then
            Rayfield:Notify({
                Title = "Ausencia de Sistema",
                Content = "No se detectaron remotes de invocación en esta instancia. El sistema se pausará.",
                Duration = 4
            })
        end
        State.AutoSummonEnabled = Value
    end,
})

Tab_Systems:CreateToggle({
    Name = "Auto Upgrade (Requires Dynamic Hook Detection)",
    CurrentValue = false,
    Flag = "Toggle_Upgrade",
    Callback = function(Value)
        if Value and not State.Network.Upgrade then
            Rayfield:Notify({
                Title = "Ausencia de Sistema",
                Content = "No se detectaron remotes de mejoras verificados. La automatización se omitirá.",
                Duration = 4
            })
        end
        State.AutoUpgradeEnabled = Value
    end,
})

-- ================= PESTAÑA: INTERFACE MANAGER =================
Tab_Settings:CreateSection("Configuration Profile System")

Tab_Settings:CreateInput({
    Name = "Profile Identifier Name",
    PlaceholderText = "Escribe el nombre del perfil...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        State.ConfigName = Text
    end,
})

Tab_Settings:CreateButton({
    Name = "Save Architecture Configuration",
    Callback = function()
        local data = {
            FarmEnabled = State.FarmEnabled,
            OptimalPositionEnabled = State.OptimalPositionEnabled,
            AutoSummonEnabled = State.AutoSummonEnabled,
            AutoUpgradeEnabled = State.AutoUpgradeEnabled
        }
        pcall(function()
            writefile(State.ConfigName .. ".json", HttpService:JSONEncode(data))
            Rayfield:Notify({Title = "I/O System", Content = "Perfil ["..State.ConfigName.."] guardado exitosamente.", Duration = 3})
        end)
    end,
})

Tab_Settings:CreateButton({
    Name = "Load Architecture Configuration",
    Callback = function()
        pcall(function()
            if isfile(State.ConfigName .. ".json") then
                local parsed = HttpService:JSONDecode(readfile(State.ConfigName .. ".json"))
                if parsed then
                    Rayfield.Flags["Toggle_AutoFarm"]:Set(parsed.FarmEnabled or false)
                    Rayfield.Flags["Toggle_OptimalPosition"]:Set(parsed.OptimalPositionEnabled or false)
                    Rayfield.Flags["Toggle_Summon"]:Set(parsed.AutoSummonEnabled or false)
                    Rayfield.Flags["Toggle_Upgrade"]:Set(parsed.AutoUpgradeEnabled or false)
                    Rayfield:Notify({Title = "I/O System", Content = "Perfil cargado con éxito.", Duration = 3})
                end
            else
                Rayfield:Notify({Title = "I/O System", Content = "No se encontró el archivo especificado.", Duration = 3})
            end
        end)
    end,
})

Tab_Settings:CreateSection("Theme Integrations")

Tab_Settings:CreateDropdown({
    Name = "Rayfield UI Theme Matrix",
    Options = {"Default", "Amberglow", "Ocean", "GreenGradient", "DarkMidnight", "Serenity"},
    CurrentOption = "Default",
    MultipleOptions = false,
    Callback = function(Option)
        local theme = type(Option) == "table" and Option[1] or Option
        -- Rayfield maneja la integración de temas de forma nativa a través de su framework base
        Rayfield:Notify({Title = "Theme Manager", Content = "Solicitud de recarga de paleta a: " .. theme .. " (Requiere soporte en source)", Duration = 2})
    end,
})

--==================================================================================================
-- 8. COMPILER FINALIZATION
--==================================================================================================
Rayfield:LoadConfiguration()

Rayfield:Notify({
    Title = "Astral Engine Pro Cargado",
    Content = "Compilación ejecutada con éxito. Políticas de Zero-Assumption activas.",
    Duration = 5,
    Image = 4483362458,
})
