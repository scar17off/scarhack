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
local ESPTab = Window:CreateTab("ESP")
local AutoFarm1Section = MainTab:CreateSection("Auto Farm 1")
local AutoFarm2Section = MainTab:CreateSection("Auto Farm 2")
local FreezeSection = MainTab:CreateSection("Freeze Control")
local AimbotSection = MainTab:CreateSection("Aimbot")

-- Global variables for toggles
local AUTO_FARM = false
local AUTO_FARM_2 = false
local RANGE_FREEZE = false
local AUTO_FARM_DISTANCE = 50
local AUTO_FARM_BEHIND = true
local AUTO_FARM_2_DISTANCE = 5
local FREEZE_RANGE = 30
local DEFAULT_WALKSPEED = 16
local AIMBOT_ENABLED = false
local AIMBOT_INCLUDE_BOSSES = false
local FOV_RADIUS = 360
local AUTO_FARM_INCLUDE_BOSSES = false
local AUTO_FARM_2_INCLUDE_BOSSES = false

local frozenZombies = {}

-- Create FOV circle for aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

function getCloseZombies(maxDistance, includeBosses)
    local zombies = workspace.OtherWaifus:GetChildren()
    local closeZombies = {}
    
    -- Add boss zombies if enabled
    if includeBosses then
        for _, boss in pairs(workspace.Waifus:GetChildren()) do
            table.insert(zombies, boss)
        end
    end
    
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
    local nearbyZombies = getCloseZombies(10, AUTO_FARM_INCLUDE_BOSSES)
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
    
    local closestZombies = getCloseZombies(AUTO_FARM_DISTANCE, AUTO_FARM_INCLUDE_BOSSES)
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
    if AUTO_FARM_2_INCLUDE_BOSSES then
        for _, boss in pairs(workspace.Waifus:GetChildren()) do
            table.insert(zombies, boss)
        end
    end
    
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

function freezeZombiesInRange()
    if not RANGE_FREEZE then
        -- Unfreeze all zombies when toggle is off
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
            local distance = (HumanoidRootPart.Position - zombie.HumanoidRootPart.Position).Magnitude
            
            -- Freeze zombies within range
            if distance <= FREEZE_RANGE and zombie.Zombie.Health > 0 then
                zombie.Zombie.WalkSpeed = 0
                frozenZombies[zombie] = true
            -- Unfreeze zombies outside range
            elseif frozenZombies[zombie] then
                zombie.Zombie.WalkSpeed = DEFAULT_WALKSPEED
                frozenZombies[zombie] = nil
            end
        end
    end
end

function IsPartVisible(part)
    local camera = game.Workspace.CurrentCamera
    if not camera then return false end

    local origin = camera.CFrame.Position
    local target = part.Position
    local vector = (target - origin)
    local ray = Ray.new(origin, vector)

    local ignoreList = {game.Players.LocalPlayer.Character}
    
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

function GetClosestZombieToMouse()
    local CLOSEST_ZOMBIE = nil
    local CLOSEST_DISTANCE = math.huge
    local CLOSEST_HEAD = nil
    local MOUSE = game.Players.LocalPlayer:GetMouse()
    local CAMERA = game.Workspace.CurrentCamera

    -- Get all zombies
    local zombies = workspace.OtherWaifus:GetChildren()
    if AIMBOT_INCLUDE_BOSSES then
        for _, boss in pairs(workspace.Waifus:GetChildren()) do
            table.insert(zombies, boss)
        end
    end

    for _, zombie in pairs(zombies) do
        if zombie:FindFirstChild("Head") and zombie:FindFirstChild("Zombie") and zombie.Zombie.Health > 0 then
            local head = zombie.Head
            
            -- Always check visibility (removed the if VISIBLE_CHECK condition)
            if not IsPartVisible(head) then
                continue
            end
            
            local screenPoint = CAMERA:WorldToScreenPoint(head.Position)
            local mouseDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(MOUSE.X, MOUSE.Y)).Magnitude

            if mouseDistance <= FOV_RADIUS then
                if mouseDistance < CLOSEST_DISTANCE then
                    CLOSEST_DISTANCE = mouseDistance
                    CLOSEST_ZOMBIE = zombie
                    CLOSEST_HEAD = head
                end
            end
        end
    end

    return CLOSEST_ZOMBIE, CLOSEST_HEAD
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

AutoFarm1Section:CreateToggle("Target Bosses", false, function(Value)
    AUTO_FARM_INCLUDE_BOSSES = Value
end)

-- Auto Farm 2
AutoFarm2Section:CreateToggle("Enabled", false, function(Value)
    AUTO_FARM_2 = Value
end)

AutoFarm2Section:CreateSlider("Distance", 1, 50, 5, true, function(Value)
    AUTO_FARM_2_DISTANCE = Value
end)

AutoFarm2Section:CreateToggle("Target Bosses", false, function(Value)
    AUTO_FARM_2_INCLUDE_BOSSES = Value
end)

FreezeSection:CreateToggle("Range Freeze", false, function(Value)
    RANGE_FREEZE = Value
end)

FreezeSection:CreateSlider("Freeze Range", 5, 100, 30, true, function(Value)
    FREEZE_RANGE = Value
end)

local AimbotToggle = AimbotSection:CreateToggle("Enable Aimbot", false, function(Value)
    AIMBOT_ENABLED = Value
end)

AimbotToggle:CreateKeybind("F")

local BossesToggle = AimbotSection:CreateToggle("Target Bosses", false, function(Value)
    AIMBOT_INCLUDE_BOSSES = Value
end)

local ShowFOVToggle = AimbotSection:CreateToggle("Show FOV", false, function(Value)
    FOVCircle.Visible = Value
end)

local FOVSlider = AimbotSection:CreateSlider("FOV Radius", 0, 800, 360, true, function(Value)
    FOV_RADIUS = Value
    FOVCircle.Radius = Value
end)

-- Load ESP Library
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()

-- Create ESP Sections
local PlayerSection = ESPTab:CreateSection("Player")
local ZombieSection = ESPTab:CreateSection("Zombie")
local AmmoSection = ESPTab:CreateSection("Ammo Boxes")
local VehicleSection = ESPTab:CreateSection("Cars")

-- Player ESP
PlayerSection:CreateToggle("Enable", false, function(Value)
    ESP.Players = Value
    ESP:Toggle(Value)
end)

PlayerSection:CreateToggle("Boxes", false, function(Value)
    ESP.Boxes = Value
end)

PlayerSection:CreateToggle("Names", false, function(Value)
    ESP.Names = Value
end)

PlayerSection:CreateToggle("Tracers", false, function(Value)
    ESP.Tracers = Value
end)

-- Zombie ESP
ZombieSection:CreateToggle("Enable", false, function(Value)
    ESP.Zombie = Value
end)

ESP:AddObjectListener(workspace.OtherWaifus, {
    Type = "Model",
    CustomName = function(obj) return obj.Name end,
    Color = Color3.fromRGB(255, 0, 0),
    IsEnabled = "Zombie"
})

-- Ammo Boxes ESP
AmmoSection:CreateToggle("Pistol Ammo", false, function(Value)
    ESP.PistolAmmo = Value
end)

AmmoSection:CreateToggle("Shotgun Ammo", false, function(Value)
    ESP.ShotgunAmmo = Value
end)

AmmoSection:CreateToggle("Rifle Ammo", false, function(Value)
    ESP.RifleAmmo = Value
end)

ESP:AddObjectListener(workspace.AmmoBoxes, {
    Name = "PistolAmmo",
    CustomName = "Pistol Ammo",
    Color = Color3.fromRGB(255, 255, 0),
    IsEnabled = "PistolAmmo"
})

ESP:AddObjectListener(workspace.AmmoBoxes, {
    Name = "ShotgunAmmo",
    CustomName = "Shotgun Ammo",
    Color = Color3.fromRGB(255, 128, 0),
    IsEnabled = "ShotgunAmmo"
})

ESP:AddObjectListener(workspace.AmmoBoxes, {
    Name = "RifleAmmo",
    CustomName = "Rifle Ammo",
    Color = Color3.fromRGB(255, 0, 0),
    IsEnabled = "RifleAmmo"
})

-- Vehicle ESP
VehicleSection:CreateToggle("Black Convertible", false, function(Value)
    ESP.BlackConvertible = Value
end)

VehicleSection:CreateToggle("Red Convertible", false, function(Value)
    ESP.RedConvertible = Value
end)

VehicleSection:CreateToggle("White Convertible", false, function(Value)
    ESP.WhiteConvertible = Value
end)

VehicleSection:CreateToggle("Helicopter", false, function(Value)
    ESP.Helicopter = Value
end)

VehicleSection:CreateToggle("White Sedan", false, function(Value)
    ESP.WhiteSedan = Value
end)

VehicleSection:CreateToggle("Humvee", false, function(Value)
    ESP.Humvee = Value
end)

ESP:AddObjectListener(workspace.Cars, {
    Name = "Convertable (Black)",
    CustomName = "Black Convertible",
    Color = Color3.fromRGB(0, 0, 0),
    IsEnabled = "BlackConvertible"
})

ESP:AddObjectListener(workspace.Cars, {
    Name = "Convertable (Red)",
    CustomName = "Red Convertible",
    Color = Color3.fromRGB(255, 0, 0),
    IsEnabled = "RedConvertible"
})

ESP:AddObjectListener(workspace.Cars, {
    Name = "Convertable (White)",
    CustomName = "White Convertible",
    Color = Color3.fromRGB(255, 255, 255),
    IsEnabled = "WhiteConvertible"
})

ESP:AddObjectListener(workspace.Cars, {
    Name = "Helicopter",
    CustomName = "Helicopter",
    Color = Color3.fromRGB(0, 255, 0),
    IsEnabled = "Helicopter"
})

ESP:AddObjectListener(workspace.Cars, {
    Name = "Sedan(White)",
    CustomName = "White Sedan",
    Color = Color3.fromRGB(200, 200, 200),
    IsEnabled = "WhiteSedan"
})

ESP:AddObjectListener(workspace.Cars, {
    Name = "Humvee",
    CustomName = "Humvee",
    Color = Color3.fromRGB(50, 50, 50),
    IsEnabled = "Humvee"
})

-- Initialize ESP
ESP:Toggle(false)
ESP.Players = false
ESP.Zombie = false
ESP.PistolAmmo = false
ESP.ShotgunAmmo = false
ESP.RifleAmmo = false
ESP.BlackConvertible = false
ESP.RedConvertible = false
ESP.WhiteConvertible = false
ESP.Helicopter = false
ESP.WhiteSedan = false
ESP.Humvee = false

-- Run the functions
RunService.RenderStepped:Connect(function()
    teleportBehindZombies()
    freezeZombiesInFront()
    freezeZombiesInRange()
    
    -- Update FOV circle position
    if FOVCircle then
        FOVCircle.Position = game:GetService("UserInputService"):GetMouseLocation()
    end
    
    -- Handle aimbot
    if AIMBOT_ENABLED then
        local _, TargetHead = GetClosestZombieToMouse()
        if TargetHead then
            local MOUSE = game.Players.LocalPlayer:GetMouse()
            local CAMERA = game.Workspace.CurrentCamera
            
            local targetPos = CAMERA:WorldToScreenPoint(TargetHead.Position)
            local mousePos = Vector2.new(MOUSE.X, MOUSE.Y)
            local moveVector = Vector2.new(
                targetPos.X - mousePos.X,
                targetPos.Y - mousePos.Y
            )
            
            mousemoverel(moveVector.X, moveVector.Y)
        end
    end
end)

-- Clean up FOV circle when GUI is closed
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "Zombie Farm" then
        if FOVCircle then
            FOVCircle:Remove()
        end
    end
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