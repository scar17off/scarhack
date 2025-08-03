-- Zombie Tower
-- https://www.roblox.com/games/115338810233057/HARD-Zombie-Tower

-- Libraries
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()

-- Initialize the UI
local window = UI.CreateWindow()

local AimbotTab = window:CreateCategory("Aimbot")
local VisualTab = window:CreateCategory("Visuals")
local AutoFarmTab = window:CreateCategory("Auto Farm")

-- Shortcuts for easier access
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
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
ESP.Players = false
ESP.Zombies = true

-- ESP for zombies (now uses workspace.AliveZombies)
ESP:AddObjectListener(workspace.AliveZombies, {
    Type = "Model",
    PrimaryPart = "HumanoidRootPart",
    Name = "Zombie",
    IsEnabled = function(obj)
        return ESP.Zombies
    end,
    Color = Color3.fromRGB(162, 255, 162)
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
                local screenPoint = Camera:WorldToScreenPoint(part.Position)
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

local function GetClosestZombieToMouse()
    local ClosestZombie = nil
    local ClosestDistance = math.huge
    local ClosestPart = nil

    -- Handle zombies if enabled
    for _, zombie in ipairs(workspace.AliveZombies:GetChildren()) do
        if zombie:IsA("Model") and zombie.Name == "Zombie" then
            local humanoid = zombie:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local targetPart = nil
                if AIM_TARGET == "Any" then
                    targetPart = GetClosestVisiblePart(zombie)
                else
                    targetPart = zombie:FindFirstChild(AIM_TARGET)
                end

                if targetPart and (not VISIBLE_CHECK or IsPartVisible(targetPart)) then
                    local screenPoint = Camera:WorldToScreenPoint(targetPart.Position)
                    local mouseDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                    if (not REQUIRE_FOV or mouseDistance <= FOV_RADIUS) then
                        if mouseDistance < ClosestDistance then
                            ClosestDistance = mouseDistance
                            ClosestZombie = zombie
                            ClosestPart = targetPart
                        end
                    end
                end
            end
        end
    end

    return ClosestZombie, ClosestPart
end

AimbotTab:CreateToggle({
    text = "Enable Aimbot",
    default = false,
    callback = function(Value)
        AIMBOT_ENABLED = Value
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
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end

    -- Only aim if localplayer is alive (has character and humanoid and not dead)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local alive = humanoid and humanoid.Health > 0

    local Target, TargetPart = nil, nil
    local moveVector = Vector2.new(0, 0)
    local aimReady = false

    if AIMBOT_ENABLED and alive then
        Target, TargetPart = GetClosestZombieToMouse()
        if Target and TargetPart then
            local targetScreen = Camera:WorldToViewportPoint(TargetPart.Position)
            local mousePos = UserInputService:GetMouseLocation()
            moveVector = Vector2.new(
                (targetScreen.X - mousePos.X),
                (targetScreen.Y - mousePos.Y)
            )

            if targetScreen.Z > 0 then
                local maxMove = 100
                moveVector = Vector2.new(
                    math.clamp(moveVector.X, -maxMove, maxMove),
                    math.clamp(moveVector.Y, -maxMove, maxMove)
                )

                -- Raycast check for aimReady
                local origin = Camera.CFrame.Position
                local direction = (TargetPart.Position - origin).Unit * (TargetPart.Position - origin).Magnitude
                local ignoreList = {LocalPlayer.Character}
                local hit = workspace:FindPartOnRayWithIgnoreList(Ray.new(origin, direction), ignoreList)
                aimReady = (hit == TargetPart)

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

    -- Teleport all zombies in front of player when enabled
    if AUTO_FARM_ENABLED then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, zombie in ipairs(workspace.AliveZombies:GetChildren()) do
                if zombie:IsA("Model") and zombie.Name == "Zombie" then
                    local zhrp = zombie:FindFirstChild("HumanoidRootPart")
                    if zhrp then
                        zhrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -AUTO_FARM_DISTANCE)
                    end
                end
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
    default = false,
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

AutoFarmTab:CreateToggle({
    text = "Teleport Zombies In Front",
    default = false,
    callback = function(Value)
        AUTO_FARM_ENABLED = Value
    end
})

AutoFarmTab:CreateSlider({
    text = "Teleport Distance",
    min = 1,
    max = 50,
    default = 5,
    callback = function(Value)
        AUTO_FARM_DISTANCE = Value
    end
})