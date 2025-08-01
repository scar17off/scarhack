-- Libraries
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()

-- Initialize the UI
local Window = UI.CreateWindow()

local AimbotTab = Window:CreateCategory("Aimbot")
local VisualTab = Window:CreateCategory("Visuals")

-- Shortcuts for easier access
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CAMERA = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Aimbot
local AIMBOT_ENABLED = false
local FREE_FOR_ALL = false
local AIM_TARGET = "Head"
local MAX_DISTANCE = 1000
local FOV_RADIUS = 360
local SMOOTHNESS = 1
local TEAM_CHECK = true
local VISIBLE_CHECK = true

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

AimbotTab:CreateDropdown("Target Hitbox", {"Any", "Head", "HumanoidRootPart", "Torso"}, function(Option)
    AIM_TARGET = Option
end)

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
end, "Smooth")

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
    local LocalPlayerS = {}
    local CLOSEST_LocalPlayer = nil
    local CLOSEST_DISTANCE = math.huge
    local CLOSEST_PART = nil

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not TEAM_CHECK or player.Team ~= LocalPlayer.Team then
                local character = player.Character
                if character then
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

                            if mouseDistance <= FOV_RADIUS then
                                if mouseDistance < CLOSEST_DISTANCE then
                                    CLOSEST_DISTANCE = mouseDistance
                                    CLOSEST_LocalPlayer = player
                                    CLOSEST_PART = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return CLOSEST_LocalPlayer, CLOSEST_PART
end

AimbotTab:CreateToggle({
    text = "Enable Aimbot",
    default = false,
    callback = function(Value)
        AIMBOT_ENABLED = Value
    end
})

AimbotTab:CreateToggle({
    text = "Team Check",
    default = true,
    callback = function(Value)
        TEAM_CHECK = Value
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

AimbotTab:CreateSlider({
    text = "FOV Radius",
    min = 0,
    max = 800,
    default = 360,
    decimal = true,
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
    decimal = true,
    callback = function(Value)
        SMOOTHNESS = Value
    end
})

-- AimbotToggle:CreateKeybind("F", function()
--     AIMBOT_ENABLED = not AIMBOT_ENABLED
--     AimbotToggle:SetState(AIMBOT_ENABLED)
--     if AIMBOT_ENABLED then
--         FOVCircle.Visible = true
--     else
--         FOVCircle.Visible = false
--     end
-- end)

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    end

    -- Only aim if localplayer is alive (has character and humanoid and not dead)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local alive = humanoid and humanoid.Health > 0

    if AIMBOT_ENABLED and alive then
        local Target, TargetPart = GetClosestPlayerToMouse()
        if Target and TargetPart then
            local targetPos3 = CAMERA:WorldToScreenPoint(TargetPart.Position)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local moveVector = Vector2.new(
                (targetPos3.X - mousePos.X),
                (targetPos3.Y - mousePos.Y)
            )

            -- Only move if target is on screen
            if targetPos3.Z > 0 then
                -- Clamp the move vector to avoid huge jumps
                local maxMove = 100
                moveVector = Vector2.new(
                    math.clamp(moveVector.X, -maxMove, maxMove),
                    math.clamp(moveVector.Y, -maxMove, maxMove)
                )

                if AIM_METHOD == "Plain" then
                    mousemoverel(moveVector.X, moveVector.Y)
                elseif AIM_METHOD == "Smooth" then
                    mousemoverel(moveVector.X / SMOOTHNESS, moveVector.Y / SMOOTHNESS)
                elseif AIM_METHOD == "Flick" then
                    -- Wait small random delay then flick
                    if math.random() < 0.1 then  -- 10% chance each frame
                        mousemoverel(moveVector.X * 0.8, moveVector.Y * 0.8)
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
    text = "Teammates",
    default = true,
    callback = function(Value)
        ESP.TeamMates = Value
    end
})

VisualTab:CreateToggle({
    text = "Team Color",
    default = false,
    callback = function(Value)
        ESP.TeamColor = Value
    end
})

VisualTab:CreateToggle({
    text = "Glow",
    default = false,
    callback = function(Value)
        ESP.Glow.Enabled = Value
    end
})

VisualTab:CreateColorpicker("Glow Color", Color3.fromRGB(255, 0, 0), function(Value)
    ESP.Glow.FillColor = Value
    ESP.Glow.OutlineColor = Value
end)

VisualTab:CreateSlider({
    text = "Glow Transparency",
    min = 0,
    max = 1,
    default = 0.5,
    callback = function(Value)
        ESP.Glow.Transparency = Value
    end
})

VisualTab:CreateToggle({
    text = "Team Color Glow",
    default = false,
    callback = function(Value)
        ESP.Glow.TeamColor = Value
    end
})

VisualTab:CreateToggle({
    text = "Show Distance",
    default = false,
    callback = function(Value)
        ESP.Distance = Value
    end
})

VisualTab:CreateSlider({
    text = "Max Distance",
    min = 100,
    max = 2000,
    default = 1000,
    callback = function(Value)
        ESP.MaxDistance = Value
    end
})

VisualTab:CreateToggle({
    text = "Health",
    callback = function(state)
        ESP.Health.Enabled = state
    end
})