-- E.R.P.O
-- https://www.roblox.com/games/121141591457716/NEW-E-R-P-O

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local Players = game:GetService("Players")
local window = UI.CreateWindow()

-- Store previous positions for teleports
local previousPositions = {
    cart = nil,
    loot = nil,
    bestLoot = nil
}

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

local function getLootValue(obj)
    local moneyDisplayText = ""
    if obj:IsA("Model") then
        for _, part in ipairs(obj:GetDescendants()) do
            if part:FindFirstChild("MoneyDisplay") and part.MoneyDisplay:FindFirstChild("TextLabel") then
                moneyDisplayText = part.MoneyDisplay.TextLabel.Text
                break
            end
        end
    else
        if obj:FindFirstChild("MoneyDisplay") and obj.MoneyDisplay:FindFirstChild("TextLabel") then
            moneyDisplayText = obj.MoneyDisplay.TextLabel.Text
        end
    end
    
    -- Convert money text to number (remove "$" and "," characters)
    local numberStr = moneyDisplayText:gsub("%$", ""):gsub(",", "")
    return tonumber(numberStr) or 0
end

ESPCategory:CreateButton({
    text = "Teleport to Best Loot",
    callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Store current position before teleporting
        previousPositions.bestLoot = humanoidRootPart.CFrame
        
        local bestLoot = nil
        local highestValue = 0
        
        for _, loot in ipairs(workspace["Spawned Loot"]:GetChildren()) do
            local primaryPart = loot:IsA("Model") and loot.PrimaryPart or loot
            if primaryPart and not isNearCart(primaryPart.Position) then
                local value = getLootValue(loot)
                if value > highestValue then
                    highestValue = value
                    bestLoot = primaryPart
                end
            end
        end
        
        if bestLoot then
            -- Teleport above the loot
            humanoidRootPart.CFrame = bestLoot.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

ESPCategory:CreateButton({
    text = "Return from Best Loot",
    callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        if previousPositions.bestLoot then
            humanoidRootPart.CFrame = previousPositions.bestLoot
            previousPositions.bestLoot = nil
        end
    end
})

-- Visual Effects category
local VisualCategory = window:CreateCategory("Visual Effects")

VisualCategory:CreateToggle({
    text = "No Pixelization",
    default = false,
    callback = function(value)
        local pixelsEffect = Players.LocalPlayer.PlayerGui:FindFirstChild("Pixels Effect")
        if pixelsEffect then
            pixelsEffect.Enabled = not value
        end
    end
})

VisualCategory:CreateToggle({
    text = "No VHS",
    default = false,
    callback = function(value)
        local vhsEffect = Players.LocalPlayer.PlayerGui:FindFirstChild("VHS_effect")
        if vhsEffect then
            vhsEffect.Enabled = not value
        end
    end
})

VisualCategory:CreateToggle({
    text = "No Vignette",
    default = false,
    callback = function(value)
        local vignetteEffect = Players.LocalPlayer.PlayerGui:FindFirstChild("Vignette Effect")
        if vignetteEffect then
            vignetteEffect.Enabled = not value
        end
    end
})

-- Fullbright
local Lighting = game:GetService("Lighting")
local originalAmbient = Lighting.Ambient
local originalBrightness = Lighting.Brightness
local originalClockTime = Lighting.ClockTime
local originalFogEnd = Lighting.FogEnd
local originalGlobalShadows = Lighting.GlobalShadows

visuals:CreateToggle({
    text = "Fullbright",
    callback = function(enabled)
        if enabled then
            -- Store original lighting values and apply fullbright
            originalAmbient = Lighting.Ambient
            originalBrightness = Lighting.Brightness
            originalClockTime = Lighting.ClockTime
            originalFogEnd = Lighting.FogEnd
            originalGlobalShadows = Lighting.GlobalShadows

            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            -- Restore original lighting values
            Lighting.Ambient = originalAmbient
            Lighting.Brightness = originalBrightness
            Lighting.ClockTime = originalClockTime
            Lighting.FogEnd = originalFogEnd
            Lighting.GlobalShadows = originalGlobalShadows
        end
    end
})

-- No Fog
local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd
local originalFogColor = Lighting.FogColor

visuals:CreateToggle({
    text = "No Fog",
    callback = function(enabled)
        if enabled then
            -- Store original fog values and remove fog
            originalFogStart = Lighting.FogStart
            originalFogEnd = Lighting.FogEnd
            originalFogColor = Lighting.FogColor

            Lighting.FogStart = 0
            Lighting.FogEnd = 9e9
            Lighting.FogColor = Color3.fromRGB(255, 255, 255)
        else
            -- Restore original fog values
            Lighting.FogStart = originalFogStart
            Lighting.FogEnd = originalFogEnd
            Lighting.FogColor = originalFogColor
        end
    end
})