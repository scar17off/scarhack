-- Forsaken
-- https://www.roblox.com/games/18687417158/NOLI-Forsaken

local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- Categories
local ESP = window:CreateCategory("ESP")

ESPLibrary.Players = false

ESPLibrary:AddObjectListener(workspace.Map.Ingame.Map, {
    Name = "Generator",
    CustomName = "Generators",
    Color = Color3.fromRGB(255, 255, 0),
    IsEnabled = function(obj)
        return ESPLibrary.Generators
    end
})
ESPLibrary.Generators = false

ESPLibrary:AddObjectListener(workspace.Players, {
    CustomName = function(obj) return obj.Name end,
    Color = Color3.fromRGB(255, 0, 0),
    IsEnabled = function(obj)
        return ESPLibrary.Killers
    end,
})
ESPLibrary.Killers = false

ESPLibrary:AddObjectListener(workspace.Players, {
    CustomName = function(obj) return obj.Name end,
    Color = Color3.fromRGB(0, 255, 0),
    IsEnabled = function(obj)
        return ESPLibrary.Survivors
    end,
})
ESPLibrary.Survivors = false

ESP:CreateToggle({
    text = "ESP",
    default = false,
    callback = function(value)
        ESPLibrary:Toggle(value)
    end
})

ESP:CreateToggle({
    text = "Boxes",
    default = false,
    callback = function(value)
        ESPLibrary.Boxes = value
    end
})

ESP:CreateToggle({
    text = "Names",
    default = false,
    callback = function(value)
        ESPLibrary.Names = value
    end
})

ESP:CreateToggle({
    text = "Generators",
    default = false,
    callback = function(value)
        ESPLibrary.Generators = value
    end
})

ESP:CreateToggle({
    text = "Killers",
    default = false,
    callback = function(value)
        ESPLibrary.Killers = value
    end
})

ESP:CreateToggle({
    text = "Survivors",
    default = false,
    callback = function(value)
        ESPLibrary.Survivors = value
    end
})