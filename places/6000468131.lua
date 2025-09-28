-- Granny
-- https://www.roblox.com/games/6000468131/Granny

local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

ESPLibrary.TeamColor = false

-- Categories
local ESP = window:CreateCategory("ESP")

-- Toggle
ESP:CreateToggle({
    text = "ESP",
    default = false,
    callback = function(value)
        ESPLibrary:Toggle(value)
    end
})

ESP:CreateToggle({
    text = "Name",
    default = false,
    callback = function(value)
        ESPLibrary.Names = value
    end
})

ESP:CreateToggle({
    text = "Box",
    default = false,
    callback = function(value)
        ESPLibrary.Boxes = value
    end
})

ESP:CreateToggle({
    text = "Glow",
    default = false,
    callback = function(value)
        ESPLibrary.Glow.Enabled = value
    end
})

-- Tools
ESPLibrary:AddObjectListener(game:GetService("Workspace").Map.House.Tools, {
    CustomName = function(obj) return obj.Name end,
    Color = Color3.fromRGB(41, 196, 181),
    IsEnabled = "Tools",
    PrimaryPart = "Handle"
})

ESP:CreateToggle({
    text = "Tools",
    default = false,
    callback = function(value)
        ESPLibrary.Tools = value
    end
})

-- Traps
ESPLibrary:AddObjectListener(game:GetService("Workspace").Map.Traps, {
    Color = Color3.fromRGB(167, 146, 179),
    IsEnabled = "Traps"
})

ESP:CreateToggle({
    text = "Traps",
    default = false,
    callback = function(value)
        ESPLibrary.Traps = value
    end
})