local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

loadstring(game:HttpGet("https://raw.githubusercontent.com/Averiias/purple-haze-pf/main/ui/lib.lua"))()

local Window = library:CreateWindow({
    WindowName = "Zombie Farm",
    Color = Color3.fromRGB(255, 128, 128)
}, game:GetService("CoreGui"))

local MainTab = Window:CreateTab("Main")
local AutoFarm1Section = MainTab:CreateSection("Auto Farm 1")
local AutoFarm2Section = MainTab:CreateSection("Auto Farm 2")

-- Global variables for toggles
local AUTO_FARM = false
local AUTO_FARM_2 = false
local AUTO_FARM_DISTANCE = 50
local AUTO_FARM_BEHIND = true
local AUTO_FARM_2_DISTANCE = 5
local DEFAULT_WALKSPEED = 16

local frozenZombies = {}

function getCloseZombies(maxDistance)
    local zombies = workspace.OtherWaifus:GetChildren()
    local closeZombies = {}
    
    for _, zombie in pairs(zombies) do
        if zombie:FindFirstChild("HumanoidRootPart") and 
           zombie:FindFirstChild("Zombie") and 
           zombie.Zombie.Health > 0 then
            local distance = (HumanoidRootPart.Position - zombie.HumanoidRootPart.Position).Magnitude
            table.insert(closeZombies, {zombie = zombie, distance = distance})
        end
    end
    
    -- Put closest zombies first
    table.sort(closeZombies, function(a, b)
        return a.distance < b.distance
    end)
    
    -- Only return zombies within range
    local result = {}
    for _, data in ipairs(closeZombies) do
        if data.distance <= maxDistance then
            table.insert(result, data.zombie)
        end
    end
    
    return result
end

function findSafePosition(zombie)
    if not zombie:FindFirstChild("HumanoidRootPart") then return nil end
    
    local zombieHRP = zombie.HumanoidRootPart
    local zombieCFrame = zombieHRP.CFrame
    
    -- Use the custom distance setting
    local behindPosition = zombieCFrame * CFrame.new(0, 0, AUTO_FARM_DISTANCE)
    
    -- Make sure we're not too close to other zombies
    local nearbyZombies = getCloseZombies(10)
    for _, nearbyZombie in pairs(nearbyZombies) do
        if nearbyZombie ~= zombie then
            local distanceToNewPos = (behindPosition.Position - nearbyZombie.HumanoidRootPart.Position).Magnitude
            if distanceToNewPos < 5 then
                -- Move away from this zombie too
                local awayVector = (behindPosition.Position - nearbyZombie.HumanoidRootPart.Position).Unit
                behindPosition = CFrame.new(nearbyZombie.HumanoidRootPart.Position + awayVector * AUTO_FARM_DISTANCE)
            end
        end
    end
    
    return behindPosition
end

function teleportBehindZombies()
    if not AUTO_FARM then return end
    
    local closestZombies = getCloseZombies(AUTO_FARM_DISTANCE)
    if #closestZombies == 0 then return end
    
    local closestZombie = closestZombies[1]
    if closestZombie then
        local safePosition
        if AUTO_FARM_BEHIND then
            safePosition = findSafePosition(closestZombie)
        else
            safePosition = closestZombie.HumanoidRootPart.CFrame * CFrame.new(0, 0, -AUTO_FARM_DISTANCE)
        end
        
        if safePosition then
            HumanoidRootPart.CFrame = safePosition
        end
    end
end

function freezeZombiesInFront()
    if not AUTO_FARM_2 then
        -- Reset all zombies back to normal when turning off
        for zombie, _ in pairs(frozenZombies) do
            if zombie:FindFirstChild("Zombie") then
                zombie.Zombie.WalkSpeed = DEFAULT_WALKSPEED
            end
        end
        frozenZombies = {}
        return
    end
    
    local zombies = workspace.OtherWaifus:GetChildren()
    for _, zombie in pairs(zombies) do
        if zombie:FindFirstChild("HumanoidRootPart") and zombie:FindFirstChild("Zombie") then
            -- Let dead zombies go back to normal
            if zombie.Zombie.Health <= 0 then
                if frozenZombies[zombie] then
                    zombie.Zombie.WalkSpeed = DEFAULT_WALKSPEED
                end
                continue
            end
            
            -- Bring zombie to player
            local frontPosition = HumanoidRootPart.CFrame * CFrame.new(0, 0, -AUTO_FARM_2_DISTANCE)
            zombie.HumanoidRootPart.CFrame = frontPosition
            
            -- Freeze it in place
            zombie.Zombie.WalkSpeed = 0
            frozenZombies[zombie] = true
        end
    end
    
    -- Clean up the tracking list
    for zombie, _ in pairs(frozenZombies) do
        if not zombie:IsDescendantOf(workspace) or 
           not zombie:FindFirstChild("Zombie") or 
           zombie.Zombie.Health <= 0 then
            if zombie:FindFirstChild("Zombie") then
                zombie.Zombie.WalkSpeed = DEFAULT_WALKSPEED
            end
            frozenZombies[zombie] = nil
        end
    end
end

-- Auto Farm 1
AutoFarm1Section:CreateToggle("Enabled", false, function(Value)
    AUTO_FARM = Value
end)

AutoFarm1Section:CreateToggle("Behind", true, function(Value)
    AUTO_FARM_BEHIND = Value
end)

AutoFarm1Section:CreateSlider("Distance", 5, 200, 50, true, function(Value)
    AUTO_FARM_DISTANCE = Value
end)

-- Auto Farm 2
AutoFarm2Section:CreateToggle("Enabled", false, function(Value)
    AUTO_FARM_2 = Value
end)

AutoFarm2Section:CreateSlider("Distance", 1, 50, 5, true, function(Value)
    AUTO_FARM_2_DISTANCE = Value
end)

-- Run the functions
RunService.Heartbeat:Connect(function()
    teleportBehindZombies()
    freezeZombiesInFront()
end)

-- Settings
local SettingsTab = Window:CreateTab("Settings")
local GeneralSection = SettingsTab:CreateSection("General")

local GuiToggle = GeneralSection:CreateToggle("Toggle GUI", true, function(Value)
    Window:Toggle(Value)
end)

GuiToggle:CreateKeybind("RightShift", function()
    local guiWindow = game:GetService("CoreGui"):FindFirstChild("Zombie Farm")
    if guiWindow then
        local newState = not guiWindow.Main.Visible
        GuiToggle:SetState(newState)
        Window:Toggle(newState)
    end
end)