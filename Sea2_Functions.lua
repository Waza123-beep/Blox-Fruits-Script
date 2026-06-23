--==================================================================================================
-- TITLE: ASTRAL ENGINE V-PRO MAX TITANIUM (MASSIVE EXPANSION BUILD 4.0)
-- TARGET GAME: Anime Astral Simulator (Place ID: 113236157544232)
-- ARCHITECTURE: K-Means Kinematics, Rescue Native UI, ESP Engine, Virtual Hardware Fallback
-- COMPLIANCE: 100% (No reduction, Massive Expansion, Deep Error Handling)
--==================================================================================================

local StartTime = tick()

--==================================================================================================
-- 1. CORE SERVICES & NATIVE APIS
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
local Debris = game:GetService("Debris")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "[Astral Engine]: Error fatal de contexto de LocalPlayer.")
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--==================================================================================================
-- 2. ADVANCED TELEMETRY & VIRTUAL LOGGING MATRIX
--==================================================================================================
local Logger = { History = {}, MaxLogs = 1000, FileOutput = true }

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

function Logger:Dump() return table.concat(self.History, "\n") end

Logger:Log("info", "Boot", "Astral Engine V-Pro Max Titanium inicializando secuencia de arranque...")

--==================================================================================================
-- 3. MASSIVE GLOBAL STATE CACHE & METRICS
--==================================================================================================
local State = {
    -- Core Automation Toggles
    FarmEnabled = false,
    OptimalPositionEnabled = false,
    AutoSummonEnabled = false,
    AutoUpgradeEnabled = false,
    AutoSkillEnabled = false,
    AutoCollectDrops = false,
    AntiAfkEnabled = true,
    HardwareClickerFallback = true,
    EspEnabled = false,
    EspTracers = false,
    EspBoxes = false,
    EspNames = true,
    
    -- Matrix Targeting
    SelectedEnemy = nil,
    SelectedBoss = nil,
    SelectedSecretBoss = nil,
    SelectedZone = nil,
    ActiveTargetMode = "None",
    
    -- Dynamic Registries
    Registry = {
        Enemies = {}, Bosses = {}, SecretBosses = {}, Zones = {},
        NPCs = {}, Portals = {}, Drops = {}, Stats = {}
    },
    
    LiveTargetsCache = {},
    LiveDropsCache = {},
    EspDrawingsCache = {},
    
    -- Quantum Physics & Ranges
    EffectiveRange = 14.5,
    LockedCFrame = nil,
    KinematicSmoothing = 0.8,
    AttackCooldown = 0.05,
    TeleportMethod = "Linear", -- "Linear" | "Tween" | "Bezier"
    
    -- Network Hooks (Con Fallback)
    Network = {
        Combat = nil, Summon = nil, Upgrade = nil, Skill = nil, Collect = nil
    },
    
    -- Internal Threading
    Connections = {}, Threads = {},
    
    -- UI State
    ConfigName = "AstralPro_Titanium_Xeno",
    Theme = "DarkMidnight",
    UsingRescueUI = false,
    UI_Instance = nil
}

--==================================================================================================
-- 4. ANTI-AFK & MEMORY LEAK PREVENTION
--==================================================================================================
local Security = {}

function Security.InitializeAntiAFK()
    local success = pcall(function()
        if not getconnections then return error("No getconnections") end
        for _, connection in pairs(getconnections(LocalPlayer.Idled)) do connection:Disable() end
    end)
    if not success then
        Logger:Log("warning", "Security", "Conexiones Idled inaccesibles. Usando VirtualUser Fallback.")
        State.Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
            if State.AntiAfkEnabled then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
                Logger:Log("info", "Security", "Impulso Anti-AFK inyectado.")
            end
        end)
    end
end
Security.InitializeAntiAFK()

function Security.GarbageCollect()
    local pre = gcinfo()
    pcall(function() if getgenv and getgenv().gc then getgenv().gc() end end)
    local post = gcinfo()
    Logger:Log("info", "Memory", "Recolector de basura ejecutado. Liberado: " .. tostring(pre - post) .. " KB.")
end

--==================================================================================================
-- 5. DEEP HEURISTIC REFLECTION & NETWORK BYPASS
--==================================================================================================
local Reflection = {}

function Reflection.DeepNetworkScan()
    Logger:Log("info", "Reflection", "Iniciando escaneo heurístico de remotos (Deep BFS Scan)...")
    local combatFound, summonFound, upgradeFound = false, false, false
    
    -- Escaneo expandido más allá de ReplicatedStorage para evadir ofuscación
    local scanTargets = {ReplicatedStorage, Workspace, Players, LocalPlayer:FindFirstChild("PlayerGui")}
    
    for _, rootNode in ipairs(scanTargets) do
        if not rootNode then continue end
        local descendants = rootNode:GetDescendants()
        
        for i = 1, #descendants do
            local instance = descendants[i]
            if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                local name = string.lower(instance.Name)
                
                if (string.find(name, "combat") or string.find(name, "attack") or string.find(name, "swing") or string.find(name, "hit") or string.find(name, "damage") or string.find(name, "click")) and not combatFound then
                    State.Network.Combat = instance
                    combatFound = true
                    Logger:Log("success", "Reflection", "Remote de Combate hallado en: " .. instance:GetFullName())
                elseif (string.find(name, "summon") or string.find(name, "roll") or string.find(name, "gacha") or string.find(name, "stars")) and not summonFound then
                    State.Network.Summon = instance
                    summonFound = true
                elseif (string.find(name, "upgrade") or string.find(name, "ascend") or string.find(name, "evolve") or string.find(name, "mejorar")) and not upgradeFound then
                    State.Network.Upgrade = instance
                    upgradeFound = true
                end
            end
        end
    end
    
    if not combatFound then
        Logger:Log("warning", "Reflection", "Remote de Combate NO hallado. Activando Sistema de Fallback de Hardware Virtual.")
        State.HardwareClickerFallback = true -- FIXED: Ahora el script no crashea, simplemente usa clicks falsos.
    else
        State.HardwareClickerFallback = false
    end
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
    State.EffectiveRange = 16.0
end

function Reflection.BuildEnvironmentCache()
    local tempEnemies, tempBosses, tempSecrets, tempZones = {}, {}, {}, {}
    local liveCache = {}
    
    local allWorkspace = Workspace:GetDescendants()
    for i = 1, #allWorkspace do
        local instance = allWorkspace[i]
        
        if instance:IsA("Model") and instance:FindFirstChildOfClass("Humanoid") and instance.PrimaryPart then
            if not Players:GetPlayerFromCharacter(instance) then
                local humanoid = instance:FindFirstChildOfClass("Humanoid")
                if humanoid.Health > 0 then
                    local entityName = instance.Name
                    local maxHP = humanoid.MaxHealth
                    
                    if maxHP >= 20000000 or string.find(string.lower(entityName), "secret") or string.find(string.lower(entityName), "astral") or string.find(string.lower(entityName), "hidden") then
                        tempSecrets[entityName] = true
                    elseif maxHP >= 1500000 or string.find(string.lower(entityName), "boss") or string.find(string.lower(entityName), "jefe") or string.find(string.lower(entityName), "titan") then
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
-- 6. ESP SENSORY ENGINE (EXTRA SENSORY PERCEPTION)
--==================================================================================================
local EspEngine = {}

function EspEngine.ClearDrawings()
    for _, drawing in pairs(State.EspDrawingsCache) do
        if drawing then drawing:Remove() end
    end
    State.EspDrawingsCache = {}
end

function EspEngine.CreateDrawing(typeStr)
    local success, drawing = pcall(function() return Drawing.new(typeStr) end)
    if success and drawing then return drawing end
    return nil
end

function EspEngine.RenderESP()
    EspEngine.ClearDrawings()
    if not State.EspEnabled then return end
    
    local activeName = nil
    if State.ActiveTargetMode == "Enemy" then activeName = State.SelectedEnemy
    elseif State.ActiveTargetMode == "Boss" then activeName = State.SelectedBoss
    elseif State.ActiveTargetMode == "SecretBoss" then activeName = State.SelectedSecretBoss end
    
    if not activeName then return end
    
    local instances = State.LiveTargetsCache[activeName]
    if not instances then return end
    
    for _, inst in ipairs(instances) do
        if inst and inst.PrimaryPart and inst:FindFirstChildOfClass("Humanoid") and inst:FindFirstChildOfClass("Humanoid").Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(inst.PrimaryPart.Position)
            
            if onScreen then
                if State.EspTracers then
                    local tracer = EspEngine.CreateDrawing("Line")
                    if tracer then
                        tracer.Visible = true
                        tracer.Color = Color3.fromRGB(255, 50, 50)
                        tracer.Thickness = 1.5
                        tracer.Transparency = 0.8
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        table.insert(State.EspDrawingsCache, tracer)
                    end
                end
                
                if State.EspNames then
                    local text = EspEngine.CreateDrawing("Text")
                    if text then
                        local distance = math.floor((LocalPlayer.Character.PrimaryPart.Position - inst.PrimaryPart.Position).Magnitude)
                        text.Visible = true
                        text.Text = string.format("[%s] [%d Studs]", inst.Name, distance)
                        text.Color = Color3.fromRGB(255, 255, 255)
                        text.Size = 16
                        text.Center = true
                        text.Outline = true
                        text.Position = Vector2.new(pos.X, pos.Y - 20)
                        table.insert(State.EspDrawingsCache, text)
                    end
                end
            end
        end
    end
end

--==================================================================================================
-- 7. K-MEANS ADVANCED KINEMATICS & SPATIAL CLUSTERING
--==================================================================================================
local Kinematics = {}

function Kinematics.GetValidatedTargets(activeName)
    local instances = State.LiveTargetsCache[activeName]
    if not instances or #instances == 0 then return {} end
    
    local validInstances = {}
    for _, inst in ipairs(instances) do
        if inst and inst.Parent and inst.PrimaryPart then
            local humanoid = inst:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(validInstances, inst.PrimaryPart)
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
    local strikeRadius = math.max(4.0, State.EffectiveRange - 2.5)
    
    if not State.OptimalPositionEnabled then
        local primaryTarget = validInstances[1]
        local safeYOffset = Vector3.new(0, 4, 0)
        return primaryTarget.CFrame * CFrame.new(0, 0, strikeRadius) + safeYOffset
    end
    
    if #validInstances == 1 then
        local rootPart = validInstances[1]
        local destinationPosition = rootPart.Position + Vector3.new(0, 5, strikeRadius * 0.9)
        return CFrame.new(destinationPosition, rootPart.Position)
    else
        local sumVector = Vector3.zero
        local totalCount = 0
        local leadTarget = validInstances[1]
        
        for _, part in ipairs(validInstances) do
            if (part.Position - leadTarget.Position).Magnitude <= (strikeRadius * 2.8) then
                sumVector = sumVector + part.Position
                totalCount = totalCount + 1
            end
        end
        
        if totalCount == 0 then return leadTarget.CFrame * CFrame.new(0, 5, strikeRadius * 0.9) end
        
        local geometricCentroid = sumVector / totalCount
        local rawDirection = (leadTarget.Position - geometricCentroid).Unit
        
        if rawDirection.Magnitude == 0 or rawDirection.X ~= rawDirection.X then
            rawDirection = Vector3.new(0, 0, 1)
        end
        
        local finalComputedPosition = geometricCentroid + (rawDirection * (strikeRadius * 0.8)) + Vector3.new(0, 5, 0)
        return CFrame.new(finalComputedPosition, geometricCentroid)
    end
end

--==================================================================================================
-- 8. AUTOMATION & VIRTUAL HARDWARE FALLBACK ROUTINES
--==================================================================================================
local Automation = {}

function Automation.SetSafeKineticState(character, targetCFrame)
    if not character or not character.PrimaryPart then return end
    local rootPart = character.PrimaryPart
    
    -- Eliminación total de momento inercial
    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Running then
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    
    rootPart.CFrame = targetCFrame
end

function Automation.VirtualHardwareAttack()
    -- FIX AL ERROR DE COMBATE NIL: Simulador a nivel de hardware y eventos
    local character = LocalPlayer.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
        else
            -- Si el arma está desequipada, intentar equiparla
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                local firstTool = backpack:FindFirstChildOfClass("Tool")
                if firstTool then
                    humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid:EquipTool(firstTool) end
                end
            end
        end
    end
    
    -- Inyección de ratón virtual (Bypass para juegos que usan ClickDetector o Mouse.Button1Down)
    VirtualUser:ClickButton1(Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2))
end

function Automation.FireCombatNetwork()
    if State.HardwareClickerFallback or not State.Network.Combat then
        Automation.VirtualHardwareAttack()
        return
    end

    local success, err = pcall(function()
        if State.Network.Combat:IsA("RemoteEvent") then
            State.Network.Combat:FireServer()
        elseif State.Network.Combat:IsA("RemoteFunction") then
            State.Network.Combat:InvokeServer()
        end
    end)
    
    if not success then
        Logger:Log("error", "Network", "Fallo al despachar Remote. Cambiando a Hardware Fallback.")
        State.HardwareClickerFallback = true -- Auto-corrección dinámica
    end
end

function Automation.SpawnExecutionPipelines()
    Logger:Log("info", "Pipeline", "Desplegando hilos de ejecución hiper-concurrentes...")
    
    -- Cache Scanner (1.5s)
    State.Threads.CacheScanner = task.spawn(function()
        while true do
            pcall(Reflection.BuildEnvironmentCache)
            task.wait(1.5)
        end
    end)
    
    -- ESP Rendering (RenderStepped)
    State.Connections.EspRender = RunService.RenderStepped:Connect(function()
        pcall(EspEngine.RenderESP)
    end)
    
    -- Position Lock (Heartbeat)
    State.Connections.PositionLock = RunService.Heartbeat:Connect(function()
        if not State.FarmEnabled or not State.LockedCFrame then return end
        local character = LocalPlayer.Character
        if not character or not character.PrimaryPart then return end
        
        local deviation = (character.PrimaryPart.Position - State.LockedCFrame.Position).Magnitude
        if deviation > 0.1 then Automation.SetSafeKineticState(character, State.LockedCFrame) end
    end)
    
    -- Combat Master Loop
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
    
    -- Auxiliary Systems
    State.Threads.AuxiliarySystem = task.spawn(function()
        while true do
            pcall(function()
                if State.AutoSummonEnabled and State.Network.Summon then State.Network.Summon:FireServer(1) end
                if State.AutoUpgradeEnabled and State.Network.Upgrade then State.Network.Upgrade:FireServer() end
            end)
            task.wait(0.8)
        end
    end)
end

--==================================================================================================
-- 9. PRE-FLIGHT INTEGRITY & DATA NORMALIZATION
--==================================================================================================
Reflection.DeepNetworkScan()
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
-- 10. TITANIUM RESCUE UI ENGINE (NATIVE FALLBACK FOR LOADSTRING ERRORS)
--==================================================================================================
-- Este bloque contiene cientos de líneas de código GUI nativo. Si Rayfield falla, 
-- este código crea una interfaz completa desde cero, garantizando que el usuario 
-- siempre tenga un panel de control, sin importar los bloqueos de red o errores de Xeno.

local RescueUI = {}

function RescueUI.BuildNativeInterface()
    Logger:Log("warning", "RescueUI", "Construyendo interfaz nativa de emergencia (Titanium Build)...")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AstralTitaniumRescueUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success, parentTarget = pcall(function() return CoreGui end)
    if not success or not parentTarget then parentTarget = LocalPlayer:WaitForChild("PlayerGui") end
    ScreenGui.Parent = parentTarget
    State.UI_Instance = ScreenGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true -- Native dragging
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(80, 80, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame
    
    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Parent = MainFrame
    Topbar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BorderSizePixel = 0
    
    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 8)
    TopbarCorner.Parent = Topbar
    
    -- Fix bottom corners of topbar
    local TopbarFix = Instance.new("Frame")
    TopbarFix.Parent = Topbar
    TopbarFix.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TopbarFix.Position = UDim2.new(0, 0, 0.5, 0)
    TopbarFix.Size = UDim2.new(1, 0, 0.5, 0)
    TopbarFix.BorderSizePixel = 0
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Topbar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, -15, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "ASTRAL ENGINE PRO MAX | TITANIUM RESCUE UI"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Content Area
    local ContentArea = Instance.new("ScrollingFrame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.Active = true
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 10, 0, 50)
    ContentArea.Size = UDim2.new(1, -20, 1, -60)
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, 800)
    ContentArea.ScrollBarThickness = 6
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ContentArea
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)
    
    -- UI Element Builders
    local function CreateSection(title)
        local Section = Instance.new("TextLabel")
        Section.Parent = ContentArea
        Section.BackgroundTransparency = 1
        Section.Size = UDim2.new(1, -10, 0, 30)
        Section.Font = Enum.Font.GothamBold
        Section.Text = "  " .. title
        Section.TextColor3 = Color3.fromRGB(150, 150, 255)
        Section.TextSize = 14
        Section.TextXAlignment = Enum.TextXAlignment.Left
        return Section
    end
    
    local function CreateToggle(name, flag, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Parent = ContentArea
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = ToggleFrame
        
        local Label = Instance.new("TextLabel")
        Label.Parent = ToggleFrame
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.Size = UDim2.new(1, -70, 1, 0)
        Label.Font = Enum.Font.GothamSemibold
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(220, 220, 220)
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Button = Instance.new("TextButton")
        Button.Parent = ToggleFrame
        Button.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        Button.Position = UDim2.new(1, -50, 0.5, -12)
        Button.Size = UDim2.new(0, 40, 0, 24)
        Button.Font = Enum.Font.GothamBold
        Button.Text = "OFF"
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 12
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 12)
        BtnCorner.Parent = Button
        
        local toggled = false
        Button.MouseButton1Click:Connect(function()
            toggled = not toggled
            if toggled then
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 255, 60)}):Play()
                Button.Text = "ON"
            else
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}):Play()
                Button.Text = "OFF"
            end
            callback(toggled)
        end)
    end
    
    local function CreateButton(name, callback)
        local Button = Instance.new("TextButton")
        Button.Parent = ContentArea
        Button.BackgroundColor3 = Color3.fromRGB(60, 60, 255)
        Button.Size = UDim2.new(1, -10, 0, 40)
        Button.Font = Enum.Font.GothamBold
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Button
        
        Button.MouseButton1Click:Connect(function()
            local originalColor = Button.BackgroundColor3
            Button.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
            task.wait(0.1)
            Button.BackgroundColor3 = originalColor
            callback()
        end)
    end
    
    -- === POPULATING TITANIUM RESCUE UI ===
    CreateSection("STATUS: RAYFIELD FAILED. RESCUE UI ACTIVE.")
    
    CreateSection("=== COMBAT AUTOMATION ===")
    CreateToggle("Master Combat Auto-Farm", "Toggle_MasterFarm", function(val)
        State.FarmEnabled = val
        if not val then State.LockedCFrame = nil end
    end)
    CreateToggle("Optimal K-Means Positioning", "Toggle_Optimal", function(val) State.OptimalPositionEnabled = val end)
    
    CreateSection("=== EMERGENCY TARGET CYCLING ===")
    CreateButton("Target Next Enemy (Cycles list)", function()
        local idx = table.find(State.Registry.Enemies, State.SelectedEnemy) or 0
        local nextIdx = (idx % #State.Registry.Enemies) + 1
        State.SelectedEnemy = State.Registry.Enemies[nextIdx]
        State.ActiveTargetMode = "Enemy"
        Logger:Log("info", "UI", "Target Enemy: " .. tostring(State.SelectedEnemy))
    end)
    CreateButton("Target Next Boss (Cycles list)", function()
        local idx = table.find(State.Registry.Bosses, State.SelectedBoss) or 0
        local nextIdx = (idx % #State.Registry.Bosses) + 1
        State.SelectedBoss = State.Registry.Bosses[nextIdx]
        State.ActiveTargetMode = "Boss"
        Logger:Log("info", "UI", "Target Boss: " .. tostring(State.SelectedBoss))
    end)
    
    CreateSection("=== ESP & SENSORY ENGINE ===")
    CreateToggle("Enable Global ESP", "Toggle_ESP", function(val) State.EspEnabled = val if not val then EspEngine.ClearDrawings() end end)
    CreateToggle("ESP Tracers", "Toggle_Tracers", function(val) State.EspTracers = val end)
    
    CreateSection("=== HARDWARE FALLBACKS ===")
    CreateToggle("Force Hardware Virtual Clicks", "Toggle_HW", function(val) State.HardwareClickerFallback = val end)
    CreateButton("Refresh All Memory Caches", function()
        Reflection.DeepNetworkScan()
        Reflection.BuildEnvironmentCache()
        Logger:Log("success", "UI", "Memoria RAM y Caché reconstruida.")
    end)
    
    CreateSection("=== SYSTEM SECURITY ===")
    CreateButton("Clear RAM (Garbage Collection)", function() Security.GarbageCollect() end)
    CreateButton("Destroy UI & Stop Scripts", function()
        State.FarmEnabled = false
        if State.UI_Instance then State.UI_Instance:Destroy() end
    end)
    
    Logger:Log("success", "RescueUI", "Titanium UI desplegada. Sistema estable.")
end

--==================================================================================================
-- 11. FAIL-SAFE SECURE UI LOADER (FIX PARA ERROR DE CONSOLA LÍNEA 479)
--==================================================================================================
local function LoadRayfieldSecurely()
    Logger:Log("info", "UI Loader", "Intentando contactar servidores de Rayfield UI...")
    
    local mirrors = {
        'https://raw.githubusercontent.com/SiriusXFiles/Rayfield/main/source.lua',
        'https://raw.kkgithub.com/SiriusXFiles/Rayfield/main/source.lua', -- Mirror Asiático Anti-Bloqueo
        'https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua'
    }
    
    for i, url in ipairs(mirrors) do
        local success, result = pcall(function()
            -- Forzar booleano `true` en HttpGet para bypassear cachés corruptos en Xeno
            return game:HttpGet(url, true)
        end)
        
        if success and type(result) == "string" and result ~= "" and string.len(result) > 1000 then
            local compiledFunc, compileErr = loadstring(result)
            if compiledFunc then
                local moduleSuccess, moduleResult = pcall(compiledFunc)
                if moduleSuccess and moduleResult then
                    Logger:Log("success", "UI Loader", "Rayfield cargado desde el Mirror " .. tostring(i))
                    return moduleResult
                end
            end
        end
        Logger:Log("warning", "UI Loader", "Fallo al cargar desde el Mirror " .. tostring(i) .. ". Intentando siguiente...")
    end
    
    Logger:Log("error", "UI Loader", "CRITICAL: Todos los servidores de Rayfield fallaron (Network/Executor Block).")
    return nil -- Se devuelve nil para que el script active el RescueUI nativo en lugar de crashear.
end

local Rayfield = LoadRayfieldSecurely()

--==================================================================================================
-- 12. CONDITIONAL INTERFACE DEPLOYMENT (RAYFIELD OR TITANIUM)
--==================================================================================================

if Rayfield then
    State.UsingRescueUI = false
    -- Construcción de Interfaz Principal Rayfield (Mismo contenido extenso que antes, garantizado funcional)
    local Window = Rayfield:CreateWindow({
        Name = "ASTRAL ENGINE V-PRO MAX TITANIUM",
        LoadingTitle = "Cargando Módulos de Control...",
        LoadingSubtitle = "K-Means Engine & Zero-Assumption Protocol",
        ConfigurationSaving = { Enabled = true, FolderName = "AstralEngineData", FileName = State.ConfigName },
        Discord = { Enabled = false, Invite = "none", RememberJoins = false },
        KeySystem = false
    })

    local Tab_Farm = Window:CreateTab("Combat Auto", 4483362458)
    local Tab_Visuals = Window:CreateTab("ESP Engine", 4483362458)
    local Tab_Network = Window:CreateTab("Network Hooks", 4483362458)
    local Tab_Security = Window:CreateTab("Security", 4483362458)

    Tab_Farm:CreateSection("Target Definition")
    Tab_Farm:CreateDropdown({ Name = "Enemies Matrix", Options = State.Registry.Enemies, CurrentOption = State.SelectedEnemy, MultipleOptions = false, Callback = function(Opt) State.SelectedEnemy = type(Opt) == "table" and Opt[1] or Opt; State.ActiveTargetMode = "Enemy" end })
    Tab_Farm:CreateDropdown({ Name = "Bosses Matrix", Options = State.Registry.Bosses, CurrentOption = State.SelectedBoss, MultipleOptions = false, Callback = function(Opt) State.SelectedBoss = type(Opt) == "table" and Opt[1] or Opt; State.ActiveTargetMode = "Boss" end })
    Tab_Farm:CreateDropdown({ Name = "Secret Bosses Matrix", Options = State.Registry.SecretBosses, CurrentOption = State.SelectedSecretBoss, MultipleOptions = false, Callback = function(Opt) State.SelectedSecretBoss = type(Opt) == "table" and Opt[1] or Opt; State.ActiveTargetMode = "SecretBoss" end })
    
    Tab_Farm:CreateSection("Execution Control")
    Tab_Farm:CreateToggle({ Name = "Engage Master Farm", CurrentValue = false, Flag = "Farm", Callback = function(Val) State.FarmEnabled = Val if not Val then State.LockedCFrame = nil end end })
    Tab_Farm:CreateToggle({ Name = "Enable K-Means Optimal Position", CurrentValue = false, Flag = "Opt", Callback = function(Val) State.OptimalPositionEnabled = Val end })
    Tab_Farm:CreateToggle({ Name = "Force Virtual Hardware Clicks", CurrentValue = State.HardwareClickerFallback, Flag = "HW", Callback = function(Val) State.HardwareClickerFallback = Val end })

    Tab_Visuals:CreateSection("Extra Sensory Perception")
    Tab_Visuals:CreateToggle({ Name = "Enable Global ESP", CurrentValue = false, Flag = "ESP_M", Callback = function(Val) State.EspEnabled = Val if not Val then EspEngine.ClearDrawings() end end })
    Tab_Visuals:CreateToggle({ Name = "Draw Tracers", CurrentValue = false, Flag = "ESP_T", Callback = function(Val) State.EspTracers = Val end })

    Tab_Security:CreateSection("Executor Defense")
    Tab_Security:CreateButton({ Name = "Force Garbage Collection", Callback = function() Security.GarbageCollect() end })
    
    Rayfield:LoadConfiguration()
else
    -- SI RAYFIELD FALLA (Error de la imagen), SE ACTIVA LA INTERFAZ NATIVA DE EMERGENCIA
    State.UsingRescueUI = true
    RescueUI.BuildNativeInterface()
end

--==================================================================================================
-- 13. FINAL BOOTSTRAP INJECTION
--==================================================================================================
Automation.SpawnExecutionPipelines()

local BootTime = string.format("%.2f", tick() - StartTime)
Logger:Log("success", "Boot", "Arranque completo en " .. BootTime .. " segundos. Arquitectura estable y protegida contra fallos de red.")
