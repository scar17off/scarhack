local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- ESP listeners
ESP:AddObjectListener(workspace.Cart, {
    CustomName = "MoneyCart",
    Name = "MoneyCart",
    Color = Color3.fromRGB(40, 255, 40),
    IsEnabled = "Cart"
})

ESP:AddObjectListener(workspace["Spawned Loot"], {
    CustomName = function(obj)
        local moneyDisplayText = ""
        if obj:IsA("Model") then
            for _, part in ipairs(obj:GetDescendants()) do
                if part:FindFirstChild("MoneyDisplay") and part.MoneyDisplay:FindFirstChild("TextLabel") then
                    moneyDisplayText = part.MoneyDisplay.TextLabel.Text
                    break
                end
            end
        else
            moneyDisplayText = obj.MoneyDisplay.TextLabel.Text
        end
        return obj.Name .. " (" .. moneyDisplayText .. ")"
    end,
    Color = Color3.fromRGB(255, 40, 255),
    IsEnabled = "Loot"
})

-- UI category
local ESPCategory = window:CreateCategory("ESP")

ESPCategory:CreateToggle({
    text = "ESP",
    default = false,
    callback = function(value)
        ESP:Toggle(value)
    end
})

ESPCategory:CreateToggle({
    text = "Names",
    default = false,
    callback = function(value)
        ESP.Names = value
    end
})

ESPCategory:CreateToggle({
    text = "Boxes",
    default = false,
    callback = function(value)
        ESP.Boxes = value
    end
})

ESPCategory:CreateToggle({
    text = "Glow",
    default = false,
    callback = function(value)
        ESP.Glow = value
    end
})

ESPCategory:CreateToggle({
    text = "Money Cart",
    default = false,
    callback = function(value)
        ESP.MoneyCart = value
    end
})

ESPCategory:CreateToggle({
    text = "Loot",
    default = false,
    callback = function(value)
        ESP.Loot = value
    end
})