local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- Categories
local ESP = window:CreateCategory("ESP")

ESP:AddObjectListener(workspace.Map.Ingame.Map, {
    Name = "Generator",
    CustomName = "Generators",
    Color = Color3.fromRGB(255, 255, 0),
    IsEnabled = "Generator"
})

local espToggle = ESP:CreateToggle({
    text = "ESP",
    default = false,
    callback = function(value)
        ESPLibrary.Players = value
        ESPLibrary:Toggle(value)
    end
})

espToggle:AddToggle({
    text = "Boxes",
    default = false,
    callback = function(value)
        ESPLibrary.Boxes = value
    end
})

espToggle:AddToggle({
    text = "Generators",
    default = false,
    callback = function(value)
        ESPLibrary.Generators = value
    end
})

espToggle:AddToggle({
    text = "Killers",
    default = false,
    callback = function(value)
        -- ESPLibrary.Killers = value
    end
})