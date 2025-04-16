local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- Function to check if a position is near the cart
local function isNearCart(position, maxDistance)
    maxDistance = maxDistance or 15 -- Default distance of 15 studs
    local cart = workspace.Cart:FindFirstChild("MoneyCart")
    if cart and cart.PrimaryPart then
        return (cart.PrimaryPart.Position - position).Magnitude <= maxDistance
    end
    return false
end

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
    IsEnabled = function(obj)
        -- Get the position of the loot
        local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
        -- Only show ESP if the loot is not near the cart
        return ESP.Loot and not isNearCart(pos)
    end
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

-- Store previous positions for teleports
local previousPositions = {
    cart = nil,
    loot = nil
}

ESPCategory:CreateButton({
    text = "Cart TP",
    callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Store current position before teleporting
        previousPositions.cart = humanoidRootPart.CFrame
        
        -- Find and teleport to cart
        local cart = workspace.Cart:FindFirstChild("MoneyCart")
        if cart and cart.PrimaryPart then
            humanoidRootPart.CFrame = cart.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

ESPCategory:CreateButton({
    text = "Return from Cart",
    callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        if previousPositions.cart then
            humanoidRootPart.CFrame = previousPositions.cart
            previousPositions.cart = nil
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
        
        -- Store current position before teleporting
        previousPositions.loot = humanoidRootPart.CFrame
        
        local closestLoot = nil
        local closestDistance = math.huge
        
        for _, loot in ipairs(workspace["Spawned Loot"]:GetChildren()) do
            local primaryPart = loot:IsA("Model") and loot.PrimaryPart or loot
            if primaryPart then
                -- Only consider loot that's not near the cart
                if not isNearCart(primaryPart.Position) then
                    local distance = (primaryPart.Position - humanoidRootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestLoot = primaryPart
                    end
                end
            end
        end
        
        if closestLoot then
            -- Teleport above the loot
            humanoidRootPart.CFrame = closestLoot.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

ESPCategory:CreateButton({
    text = "Return from Loot",
    callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        if previousPositions.loot then
            humanoidRootPart.CFrame = previousPositions.loot
            previousPositions.loot = nil
        end
    end
})