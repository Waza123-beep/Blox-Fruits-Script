-- // Blox Fruits Titán Hub - Main Loader
if not game:IsLoaded() then game.Loaded:Wait() end

local PlaceIDs = { [2753915549] = "Sea1", [4442272183] = "Sea2", [5885233282] = "Sea3" }
local CurrentSea = PlaceIDs[game.PlaceId]

if CurrentSea then
    -- Aquí insertas el link de tu Gist o Pastebin del módulo específico
    -- Ejemplo: loadstring(game:HttpGet("TU_LINK_AQUI_" .. CurrentSea .. ".lua"))()
    print("Cargando módulos para: " .. CurrentSea)
else
    warn("Mapa no soportado")
end
