local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- ESP listeners
ESPLibrary:AddObjectListener(workspace.Cart, {
    CustomName = "Money Cart",
    Name = "MoneyCart",
    Color = Color3.fromRGB(40, 255, 40),
    IsEnabled = "Cart"
})

ESPLibrary:AddObjectListener(workspace["Spawned Loot"], {
    CustomName = function(obj) return obj.Name end,
    Color = Color3.fromRGB(255, 40, 255),
    IsEnabled = "Loot"
})

-- UI category
local ESP = window:CreateCategory("ESP")

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
    text = "Glow",
    default = false,
    callback = function(value)
        ESPLibrary.Glow = value
    end
})

ESP:CreateToggle({
    text = "Money Cart",
    default = false,
    callback = function(value)
        ESPLibrary.MoneyCart = value
    end
})

ESP:CreateToggle({
    text = "Loot",
    default = false,
    callback = function(value)
        ESPLibrary.Loot = value
    end
})