-- Apocalypse Rising 2
-- https://www.roblox.com/games/863266079/Apocalypse-Rising-2

-- Libraries
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()

-- Initialize the UI
local window = UI.CreateWindow()

local AimbotTab = window:CreateCategory("Aimbot")
local VisualTab = window:CreateCategory("Visuals")

-- Shortcuts for easier access
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CAMERA = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Input section (Luau-ENV Input)
local VirtualInputManager = game:GetService("VirtualInputManager")
local IsWindowFocused = true

UserInputService.WindowFocused:Connect(function()
    IsWindowFocused = true
end)
UserInputService.WindowFocusReleased:Connect(function()
    IsWindowFocused = false
end)

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

-- Aimbot
local AIMBOT_ENABLED = false
local AUTO_FIRE = false
local AUTO_FIRE_VIM = false
local lastVimFire = 0
local vimFireDelay = 0.05
local FREE_FOR_ALL = false
local AIM_METHOD = "Plain"
local AIM_TARGET = "Head"
local MAX_DISTANCE = 1000
local REQUIRE_FOV = true
local FOV_RADIUS = 360
local SMOOTHNESS = 1
local VISIBLE_CHECK = true
local IGNORE_FRIENDS = false
local TARGET_ZOMBIES = true

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

AimbotTab:CreateDropdown("Target Hitbox", {"Head", "HumanoidRootPart", "Torso", "Any"}, function(Option)
    AIM_TARGET = Option
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
    PREFERRED_HITBOX = Option
end, "Head")

AimbotTab:CreateDropdown("Aim Method", {
    "Plain",
    "Smooth",
    "Flick"
}, function(Option)
    AIM_METHOD = Option
end, "Plain")

AimbotTab:CreateToggle({
    text = "Random Hitbox Per Player",
    default = false,
    callback = function(Value)
        RANDOM_HITBOX = Value
    end
})

local PlayerHitboxes = {}

local function IsPartVisible(part)
    local camera = game.Workspace.CurrentCamera
    if not camera then return false end

    local origin = camera.CFrame.Position
    local target = part.Position
    local vector = (target - origin)
    local ray = Ray.new(origin, vector)

    local ignoreList = {game.Players.LocalPlayer.Character}

    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

    if hit then
        if hit == part or hit:IsDescendantOf(part.Parent) then
            return true
        end
        return false
    end

    return true
end

local function GetClosestVisiblePart(character)
    local validParts = {
        "Head",
        "HumanoidRootPart",
        "Torso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg"
    }

    local closestPart = nil
    local closestDistance = math.huge

    for _, partName in ipairs(validParts) do
        local part = character:FindFirstChild(partName)
        if part then

            if IsPartVisible(part) then
                local screenPoint = CAMERA:WorldToScreenPoint(part.Position)
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                if distance < closestDistance then
                    closestDistance = distance
                    closestPart = part
                end
            end
        end
    end

    return closestPart
end

local function GetClosestPlayerToMouse()
    local ClosestPlayer = nil
    local ClosestDistance = math.huge
    local ClosestPart = nil

    -- Handle players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Ignore friends if toggle is on
            if not IGNORE_FRIENDS or not LocalPlayer:IsFriendsWith(player.UserId) then
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if character and humanoid and humanoid.Health > 0 then
                    local targetPart = nil

                    if AIM_TARGET == "Any" then
                        if RANDOM_HITBOX then
                            -- Check if player needs a new random hitbox
                            if not PlayerHitboxes[player] then
                                local validParts = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
                                PlayerHitboxes[player] = validParts[math.random(1, #validParts)]
                            end
                            targetPart = character:FindFirstChild(PlayerHitboxes[player])
                        else
                            -- Use preferred hitbox if visible, otherwise find closest visible part
                            local preferredPart = character:FindFirstChild(PREFERRED_HITBOX)
                            if preferredPart and IsPartVisible(preferredPart) then
                                targetPart = preferredPart
                            else
                                targetPart = GetClosestVisiblePart(character)
                            end
                        end
                    else
                        targetPart = character:FindFirstChild(AIM_TARGET)
                    end

                    if targetPart then
                        if not VISIBLE_CHECK or IsPartVisible(targetPart) then
                            local screenPoint = CAMERA:WorldToScreenPoint(targetPart.Position)
                            local mouseDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                            if (not REQUIRE_FOV or mouseDistance <= FOV_RADIUS) then
                                if mouseDistance < ClosestDistance then
                                    ClosestDistance = mouseDistance
                                    ClosestPlayer = player
                                    ClosestPart = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Handle zombies if enabled
    if TARGET_ZOMBIES then
        for _, zombie in ipairs(workspace.Zombies:GetChildren()) do
            if zombie:IsA("Model") then
                local targetPart = nil
                if AIM_TARGET == "Any" then
                    targetPart = GetClosestVisiblePart(zombie)
                else
                    targetPart = zombie:FindFirstChild(AIM_TARGET)
                end

                if targetPart and (not VISIBLE_CHECK or IsPartVisible(targetPart)) then
                    local screenPoint = CAMERA:WorldToScreenPoint(targetPart.Position)
                    local mouseDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                    if (not REQUIRE_FOV or mouseDistance <= FOV_RADIUS) then
                        if mouseDistance < ClosestDistance then
                            ClosestDistance = mouseDistance
                            ClosestPlayer = zombie
                            ClosestPart = targetPart
                        end
                    end
                end
            end
        end
    end

    return ClosestPlayer, ClosestPart
end

AimbotTab:CreateToggle({
    text = "Enable Aimbot",
    default = false,
    callback = function(Value)
        AIMBOT_ENABLED = Value
    end
})

AimbotTab:CreateToggle({
    text = "Target Zombies",
    default = false,
    callback = function(Value)
        TARGET_ZOMBIES = Value
    end
})

AimbotTab:CreateToggle({
    text = "Auto Fire (VIM)",
    default = false,
    callback = function(Value)
        AUTO_FIRE_VIM = Value
    end
})

AimbotTab:CreateToggle({
    text = "Visible Check",
    default = true,
    callback = function(Value)
        VISIBLE_CHECK = Value
    end
})

AimbotTab:CreateToggle({
    text = "Show FOV",
    default = false,
    callback = function(Value)
        FOVCircle.Visible = Value
    end
})

AimbotTab:CreateToggle({
    text = "Require FOV",
    default = true,
    callback = function(Value)
        REQUIRE_FOV = Value
    end
})

AimbotTab:CreateToggle({
    text = "Ignore Friends",
    default = false,
    callback = function(Value)
        IGNORE_FRIENDS = Value
    end
})

AimbotTab:CreateSlider({
    text = "FOV Radius",
    min = 0,
    max = 800,
    default = 360,
    callback = function(Value)
        FOV_RADIUS = Value
        if FOVCircle then
            FOVCircle.Radius = Value
        end
    end
})

AimbotTab:CreateSlider({
    text = "Smoothness",
    min = 1,
    max = 10,
    default = 1,
    callback = function(Value)
        SMOOTHNESS = Value
    end
})

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    end

    -- Only aim if localplayer is alive (has character and humanoid and not dead)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local alive = humanoid and humanoid.Health > 0

    local Target, TargetPart = nil, nil
    local moveVector = Vector2.new(0, 0)
    local aimReady = false

    if AIMBOT_ENABLED and alive then
        Target, TargetPart = GetClosestPlayerToMouse()
        if Target and TargetPart then
            local targetPos3 = CAMERA:WorldToScreenPoint(TargetPart.Position)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            moveVector = Vector2.new(
                (targetPos3.X - mousePos.X),
                (targetPos3.Y - mousePos.Y)
            )

            if targetPos3.Z > 0 then
                local maxMove = 100
                moveVector = Vector2.new(
                    math.clamp(moveVector.X, -maxMove, maxMove),
                    math.clamp(moveVector.Y, -maxMove, maxMove)
                )

                -- Consider "aim ready" if the mouse is close enough to the hitbox
                local aimThreshold = 2 -- pixels
                aimReady = (math.abs(moveVector.X) <= aimThreshold and math.abs(moveVector.Y) <= aimThreshold)

                if AIM_METHOD == "Plain" then
                    mousemoverel(moveVector.X, moveVector.Y)
                elseif AIM_METHOD == "Smooth" then
                    mousemoverel(moveVector.X / SMOOTHNESS, moveVector.Y / SMOOTHNESS)
                elseif AIM_METHOD == "Flick" then
                    if math.random() < 0.1 then
                        mousemoverel(moveVector.X * 0.8, moveVector.Y * 0.8)
                    end
                end
            end
        end
    end

    -- Auto Fire (VirtualInputManager) logic (only fire if aimReady)
    if AUTO_FIRE_VIM and IsWindowFocused then
        if Target and TargetPart and aimReady then
            local mousePos = UserInputService:GetMouseLocation()
            if tick() - lastVimFire > vimFireDelay then
                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, false)
                task.wait()
                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, false)
                lastVimFire = tick()
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end
end)

-- Player death handler for random hitbox
game.Players.PlayerRemoving:Connect(function(player)
    PlayerHitboxes[player] = nil
end)

-- Character removal handler
game.Workspace.ChildRemoved:Connect(function(child)
    local player = game.Players:GetPlayerFromCharacter(child)
    if player then
        -- Assign new random hitbox when player dies
        if RANDOM_HITBOX then
            local validParts = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
            PlayerHitboxes[player] = validParts[math.random(1, #validParts)]
        end
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

VisualTab:CreateSlider({
    text = "Glow Transparency",
    min = 0,
    max = 1,
    default = 0.5,
    step = 0.01,
    callback = function(Value)
        ESP.Glow.Transparency = Value
    end
})

VisualTab:CreateToggle({
    text = "Show Distance",
    default = false,
    callback = function(Value)
        ESP.Distance = Value
    end
})