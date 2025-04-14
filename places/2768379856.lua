local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

local ESP = window:CreateCategory("ESP")

ESPLibrary:AddObjectListener(workspace.GameObjects.Physical.Employees, {
    CustomName = function(obj) return obj.Name end,
    Color = Color3.fromRGB(255, 255, 0),
    IsEnabled = "Employees"
})

ESPLibrary:AddObjectListener(workspace.GameObjects.Physical.Items, {
    CustomName = function(obj) return obj.Name end,
    Color = Color3.fromRGB(255, 255, 0),
    IsEnabled = "Items"
})

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
    text = "Glow",
    default = false,
    callback = function(value)
        ESPLibrary.Glow.Enabled = value
    end
})

ESP:CreateToggle({
    text = "Glow Fill",
    default = false,
    callback = function(value)
        ESPLibrary.Glow.Filled = value
    end
})

ESP:CreateToggle({
    text = "Players",
    default = false,
    callback = function(value)
        ESPLibrary.Players = value
    end
})

ESP:CreateToggle({
    text = "Employees",
    default = false,
    callback = function(value)
        ESPLibrary.Employees = value
    end
})

ESP:CreateToggle({
    text = "Items",
    default = false,
    callback = function(value)
        ESPLibrary.Items = value
    end
})