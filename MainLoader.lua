-- // =========================================================================
-- // TITÁN HUB: MAIN LOADER (CARGADOR MAESTRO)
-- // =========================================================================

-- 1. Asegurar que el juego cargó
if not game:IsLoaded() then game.Loaded:Wait() end

-- 2. CONFIGURACIÓN GLOBAL (Disponible para todos los módulos)
getgenv().TitanConfig = {
    AutoFarm = false,
    KillAura = false,
    FastAttack = false,
    Weapon = "Melee",
    -- Puedes añadir aquí todas tus variables globales
}

-- 3. MAPEO DE URLS POR MAR
local SeaLinks = {
    [2753915549] = "https://raw.githubusercontent.com/Waza123-beep/Blox-Fruits-Script/refs/heads/main/Sea1_Functions.lua",
    [4442272183] = "https://raw.githubusercontent.com/Waza123-beep/Blox-Fruits-Script/refs/heads/main/Sea2_Functions.lua",
    [5885233282] = "https://raw.githubusercontent.com/Waza123-beep/Blox-Fruits-Script/refs/heads/main/Sea3_Functions.lua"
}

-- 4. LÓGICA DE CARGA
local TargetURL = SeaLinks[game.PlaceId]

if TargetURL then
    print("🌍 Titán Hub: Detectado Sea ID: " .. game.PlaceId .. ". Cargando módulo...")
    
    -- Usamos pcall para que, si el enlace falla, el resto del juego no crashee
    local success, err = pcall(function()
        local scriptCode = game:HttpGet(TargetURL)
        loadstring(scriptCode)()
    end)
    
    if not success then
        warn("❌ Error al cargar el módulo del mar: " .. tostring(err))
    else
        print("✅ Módulo cargado correctamente.")
    end
else
    warn("⚠️ Titán Hub: No se ha detectado un mar conocido (PlaceID: " .. game.PlaceId .. ")")
end
