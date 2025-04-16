local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- ESP listeners
ESP:AddObjectListener(workspace.Cart, {
    Name = "MoneyCart",
    CustomName = "Money Cart",
    Color = Color3.fromRGB(40, 255, 40),
    IsEnabled = "Cart",
    RenderInNil = true
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

ESP:AddObjectListener(workspace["Spawned Enemies"], {
    CustomName = function(obj)
        return obj.Name
    end,
    Color = Color3.fromRGB(255, 0, 0),
    IsEnabled = "Entities"
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

ESPCategory:CreateToggle({
    text = "Entities",
    default = false,
    callback = function(value)
        ESP.Entities = value
    end
})

-- Store previous position for return teleport
local previousPosition = nil

ESPCategory:CreateButton({
    text = "Cart TP",
    callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Store current position before teleporting
        previousPosition = humanoidRootPart.CFrame
        
        -- Find and teleport to cart
        local cart = workspace.Cart:FindFirstChild("MoneyCart")
        if cart and cart.PrimaryPart then
            humanoidRootPart.CFrame = cart.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

ESPCategory:CreateButton({
    text = "Return to Previous",
    callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        if previousPosition then
            humanoidRootPart.CFrame = previousPosition
            previousPosition = nil
        end
    end
})

ESPCategory:CreateButton({
    text = "Teleport to Closest Loot",
    callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local closestLoot = nil
        local closestDistance = math.huge
        
        for _, loot in ipairs(workspace["Spawned Loot"]:GetChildren()) do
            local primaryPart = loot:IsA("Model") and loot.PrimaryPart or loot
            if primaryPart then
                local distance = (primaryPart.Position - humanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestLoot = primaryPart
                end
            end
        end
        
        if closestLoot then
            -- Teleport above the loot
            humanoidRootPart.CFrame = closestLoot.CFrame + Vector3.new(0, 3, 0)
        end
    end
})