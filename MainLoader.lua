-- // =========================================================================
-- // TITÁN HUB: MAIN LOADER (EJECUTA ESTO EN EL EXECUTOR)
-- // =========================================================================

-- 1. INICIALIZAR MOTOR DE SEGURIDAD (ANTI-BAN)
getgenv().TitanEngine = {}
getgenv().TitanEngine.Protect = function()
    local RunService = game:GetService("RunService")
    -- Bypass de velocidad
    RunService.Stepped:Connect(function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = char.HumanoidRootPart.Velocity + Vector3.new(0.01, 0, 0.01)
        end
    end)
    print("✅ Motor Anti-Ban Activo")
end

-- 2. CARGADOR DE MÓDULOS
getgenv().TitanEngine.LoadSeaModule = function(url)
    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not success then warn("Error al cargar módulo: " .. err) end
end

-- 3. DETECTOR DE MAR Y EJECUCIÓN
local PlaceIDs = {
    [113236157544232] = "https://raw.githubusercontent.com/Waza123-beep/Blox-Fruits-Script/refs/heads/main/Sea1_Functions.lua",
    [4442272183] = "https://raw.githubusercontent.com/Waza123-beep/Blox-Fruits-Script/refs/heads/main/Sea2_Functions.lua",
    [5885233282] = "https://raw.githubusercontent.com/Waza123-beep/Blox-Fruits-Script/refs/heads/main/Sea3_Functions.lua"
}

TitanEngine.Protect() -- Activamos la seguridad primero

local url = PlaceIDs[game.PlaceId]
if url then
    print("🌍 Detectado Mar. Cargando funciones desde GitHub...")
    TitanEngine.LoadSeaModule(url)
else
    warn("⚠️ Mapa no soportado")
end
