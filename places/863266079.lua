-- Apocalypse Rising 2
-- https://www.roblox.com/games/863266079/Apocalypse-Rising-2

-- Libraries
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/aimbot.lua"))()

-- Initialize the UI
local window = UI.CreateWindow()

local AimbotTab = window:CreateCategory("Aimbot")
local VisualTab = window:CreateCategory("Visuals")

-- Shortcuts for easier access
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ESP Initialization
-- ESP toggles
ESP.Players = true
ESP.Zombies = true
ESP.Vehicles = true

-- Custom colors
ESP.PlayerColor = Color3.fromRGB(255, 162, 162) -- Light red for players
ESP.ZombieColor = Color3.fromRGB(162, 255, 162) -- Light green for zombies
ESP.VehicleColor = Color3.fromRGB(255, 255, 162) -- Light yellow for vehicles
ESP.FriendColor = Color3.fromRGB(255, 162, 255) -- Pink for friends

-- ESP Overrides for players
ESP.Overrides.IsPlayer = function(char)
    -- Only mark as player if Humanoid exists and is not a zombie/vehicle
    return char:FindFirstChildOfClass("Humanoid") and char.Parent == workspace.Characters
end

ESP.Overrides.GetColor = function(char)
    -- Use custom color for players, zombies, vehicles
    local player = game.Players:GetPlayerFromCharacter(char)
    if ESP.Overrides.IsPlayer(char) then
        if player and game.Players.LocalPlayer:IsFriendsWith(player.UserId) then
            return ESP.FriendColor
        end
        return ESP.PlayerColor
    elseif ESP.ZombieColor and char.Parent == workspace.Zombies then
        return ESP.ZombieColor
    elseif ESP.VehicleColor and char.Parent == workspace.Vehicles then
        return ESP.VehicleColor
    end
    return ESP.DefaultColor
end

-- ESP for players
ESP:AddObjectListener(workspace.Characters, {
    Type = "Model",
    PrimaryPart = "HumanoidRootPart",
    IsEnabled = function(obj)
        local player = Players:GetPlayerFromCharacter(obj)
        return ESP.Players and ESP.Overrides.IsPlayer(obj) and player and player.Name ~= Players.LocalPlayer.Name
    end,
    Validator = function(obj)
        local player = Players:GetPlayerFromCharacter(obj)
        return ESP.Overrides.IsPlayer(obj) and player and player.Name ~= Players.LocalPlayer.Name
    end,
    Color = ESP.Overrides.GetColor
})

-- ESP for zombies
ESP:AddObjectListener(workspace.Zombies, {
    Type = "Model",
    PrimaryPart = "HumanoidRootPart",
    IsEnabled = function(obj)
        return ESP.Zombies
    end,
    Color = function(obj)
        return ESP.ZombieColor
    end
})

-- ESP for vehicles
ESP:AddObjectListener(workspace.Vehicles, {
    Type = "Model",
    PrimaryPart = "Base",
    IsEnabled = function(obj)
        return ESP.Vehicles
    end,
    Validator = function(obj)
        return obj:FindFirstChild("Base") and obj.Base:IsA("BasePart")
    end,
    Color = function(obj)
        return ESP.VehicleColor
    end
})

Aimbot:Setup({
    FOV = 360,
    Smoothness = 2,
    TeamCheck = true,
    VisibleCheck = true,
    IgnoreFriends = false,
    AutoFire = false,
    Target = "Head",
    PreferredHitbox = "Head",
    AimMethod = "Plain",
    TargetGroups = {game.Players, workspace.Zombies}
})

AimbotTab:CreateToggle({
    text = "Enable Aimbot",
    default = false,
    callback = function(Value)
        Aimbot.Enable(Value)
    end
})

AimbotTab:CreateToggle({
    text = "Auto Fire",
    default = false,
    callback = function(Value)
        Aimbot.config.AutoFire = Value
    end
})

AimbotTab:CreateToggle({
    text = "Team Check",
    default = true,
    callback = function(Value)
        Aimbot.config.TeamCheck = Value
    end
})

AimbotTab:CreateToggle({
    text = "Visible Check",
    default = true,
    callback = function(Value)
        Aimbot.config.VisibleCheck = Value
    end
})

AimbotTab:CreateToggle({
    text = "Show FOV",
    default = false,
    callback = function(Value)
        FOVCircle.Visible = Value
    end
})

AimbotTab:CreateDropdown("Target Hitbox", {"Head", "HumanoidRootPart", "Torso", "Any"}, function(Option)
    Aimbot.config.Target = Option
end, "Head")

AimbotTab:CreateDropdown("Preferred Hitbox", {
    "Head",
    "HumanoidRootPart",
    "Torso",
    "Left Arm",
    "Right Arm",
    "Left Leg",
    "Right Leg"
}, function(Option)
    Aimbot.config.PreferredHitbox = Option
end, "Head")

AimbotTab:CreateDropdown("Aim Method", {
    "Plain",
    "Smooth",
    "Flick"
}, function(Option)
    Aimbot.config.AimMethod = Option
end, "Plain")

AimbotTab:CreateSlider({
    text = "FOV Radius",
    min = 0,
    max = 800,
    default = 360,
    callback = function(Value)
        Aimbot.config.FOV = Value
    end
})

AimbotTab:CreateSlider({
    text = "Smoothness",
    min = 2,
    max = 10,
    default = 2,
    callback = function(Value)
        Aimbot.config.Smoothness = Value
    end
})

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Radius = Aimbot.config.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end
end)

-- Visuals
VisualTab:CreateToggle({
    text = "Enable ESP",
    default = false,
    callback = function(Value)
        ESP:Toggle(Value)
    end
})

VisualTab:CreateToggle({
    text = "Players",
    default = true,
    callback = function(Value)
        ESP.Players = Value
    end
})

VisualTab:CreateToggle({
    text = "Zombies",
    default = true,
    callback = function(Value)
        ESP.Zombies = Value
    end
})

VisualTab:CreateToggle({
    text = "Vehicles",
    default = true,
    callback = function(Value)
        ESP.Vehicles = Value
    end
})

VisualTab:CreateToggle({
    text = "Face Camera",
    callback = function(state)
        ESP.FaceCamera = state
        ESP.Health.FaceCamera = state
    end
})

VisualTab:CreateToggle({
    text = "Boxes",
    default = true,
    callback = function(Value)
        ESP.Boxes = Value
    end
})

VisualTab:CreateToggle({
    text = "Names",
    default = false,
    callback = function(Value)
        ESP.Names = Value
    end
})

VisualTab:CreateToggle({
    text = "Tracers",
    default = false,
    callback = function(Value)
        ESP.Tracers = Value
    end
})

VisualTab:CreateToggle({
    text = "Glow",
    default = false,
    callback = function(Value)
        ESP.Glow.Enabled = Value
    end
})

VisualTab:CreateToggle({
    text = "Show Distance",
    default = false,
    callback = function(Value)
        ESP.Distance = Value
    end
})