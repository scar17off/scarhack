-- Hypershot
-- https://www.roblox.com/games/17516596118/NEW-Hypershot-Gunfight

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

-- Input section (Luau-ENV Input)
local VirtualInputManager = game:GetService("VirtualInputManager")
local IsWindowFocused = true

UserInputService.WindowFocused:Connect(function()
    IsWindowFocused = true
end)
UserInputService.WindowFocusReleased:Connect(function()
    IsWindowFocused = false
end)

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
local TEAM_CHECK = true
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
local IsPartVisible_ignoreList = nil
local IsPartVisible_ignoreListTime = nil

local function IsPartVisible(part)
    local camera = workspace.CurrentCamera
    if not camera then return false end

    local origin = camera.CFrame.Position
    local target = part.Position
    local direction = (target - origin)

    -- Use a local cache table instead of attaching to the function
    local ignoreList, ignoreListTime = IsPartVisible_ignoreList, IsPartVisible_ignoreListTime
    if not ignoreList or tick() - (ignoreListTime or 0) > 0.5 then
        ignoreList = {LocalPlayer.Character}
        local mobs = workspace:FindFirstChild("Mobs")
        if mobs then
            for _, mob in ipairs(mobs:GetChildren()) do
                for _, child in ipairs(mob:GetDescendants()) do
                    if child:IsA("Highlight") or (child:IsA("BasePart") and child.Name == "FakeHRP") then
                        table.insert(ignoreList, child)
                    end
                end
            end
        end
        -- Add everything in workspace.IgnoreThese to ignore list
        local ignoreFolder = workspace:FindFirstChild("IgnoreThese")
        if ignoreFolder then
            for _, obj in ipairs(ignoreFolder:GetDescendants()) do
                if typeof(obj) == "Instance" then
                    table.insert(ignoreList, obj)
                end
            end
        end
        IsPartVisible_ignoreList = ignoreList
        IsPartVisible_ignoreListTime = tick()
    end

    -- Filter ignoreList to only objects (Instance)
    local filteredIgnoreList = {}
    for _, v in ipairs(ignoreList) do
        if typeof(v) == "Instance" then
            table.insert(filteredIgnoreList, v)
        end
    end

    local ray = Ray.new(origin, direction)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, filteredIgnoreList)

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
    local ClosestTarget = nil
    local ClosestDistance = math.huge
    local ClosestPart = nil

    -- Check enemy players (with highlight check instead of .Team)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not IGNORE_FRIENDS or not LocalPlayer:IsFriendsWith(player.UserId) then
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if character and humanoid and humanoid.Health > 0 and (not TEAM_CHECK or not character:FindFirstChild("PlayerOutline")) then
                    local targetPart = nil
                    if AIM_TARGET == "Any" then
                        local preferredPart = character:FindFirstChild(PREFERRED_HITBOX)
                        if preferredPart and (not VISIBLE_CHECK or IsPartVisible(preferredPart)) then
                            targetPart = preferredPart
                        else
                            local validParts = {
                                "Head", "HumanoidRootPart", "Torso",
                                "Left Arm", "Right Arm", "Left Leg", "Right Leg"
                            }
                            local closestPart = nil
                            local closestDist = math.huge
                            for _, partName in ipairs(validParts) do
                                local part = character:FindFirstChild(partName)
                                if part and (not VISIBLE_CHECK or IsPartVisible(part)) then
                                    local screenPoint = CAMERA:WorldToScreenPoint(part.Position)
                                    local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                                    if dist < closestDist then
                                        closestDist = dist
                                        closestPart = part
                                    end
                                end
                            end
                            targetPart = closestPart
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
                                    ClosestTarget = player
                                    ClosestPart = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Check enemy mobs (must have EnemyHighlight)
    local mobs = workspace:FindFirstChild("Mobs")
    if mobs then
        for _, mob in ipairs(mobs:GetChildren()) do
            if mob:FindFirstChild("EnemyHighlight") then
                local humanoid = mob:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPart = nil
                    if AIM_TARGET == "Any" then
                        -- Try preferred hitbox first if visible
                        if PREFERRED_HITBOX and mob:FindFirstChild(PREFERRED_HITBOX) and (not VISIBLE_CHECK or IsPartVisible(mob[PREFERRED_HITBOX])) then
                            targetPart = mob[PREFERRED_HITBOX]
                        else
                            -- Fallback: find the closest visible part (ignoring visibility if VISIBLE_CHECK is off)
                            local validParts = {
                                "Head", "HumanoidRootPart", "Torso",
                                "Left Arm", "Right Arm", "Left Leg", "Right Leg"
                            }
                            local closestPart = nil
                            local closestDist = math.huge
                            for _, partName in ipairs(validParts) do
                                local part = mob:FindFirstChild(partName)
                                if part and (not VISIBLE_CHECK or IsPartVisible(part)) then
                                    local screenPoint = CAMERA:WorldToScreenPoint(part.Position)
                                    local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                                    if dist < closestDist then
                                        closestDist = dist
                                        closestPart = part
                                    end
                                end
                            end
                            targetPart = closestPart
                        end
                    else
                        targetPart = mob:FindFirstChild(AIM_TARGET)
                    end
                    if targetPart then
                        if not VISIBLE_CHECK or IsPartVisible(targetPart) then
                            local screenPoint = CAMERA:WorldToScreenPoint(targetPart.Position)
                            local mouseDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                            if (not REQUIRE_FOV or mouseDistance <= FOV_RADIUS) then
                                if mouseDistance < ClosestDistance then
                                    ClosestDistance = mouseDistance
                                    ClosestTarget = mob
                                    ClosestPart = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return ClosestTarget, ClosestPart
end

AimbotTab:CreateToggle({
    text = "Enable Aimbot",
    default = false,
    callback = function(Value)
        AIMBOT_ENABLED = Value
    end
})

AimbotTab:CreateToggle({
    text = "Auto Fire",
    default = false,
    callback = function(Value)
        AUTO_FIRE = Value
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

    -- Auto Fire logic (only fire if aimReady)
    --[[
    if AUTO_FIRE then
        local isrbxactive = isrbxactive
        local iswindowactive = iswindowactive
        local focused = UserInputService:GetFocusedTextBox()
        local active = (isrbxactive and isrbxactive() or iswindowactive and iswindowactive())

        if active then
            if Target and TargetPart and aimReady then
                if not focused then
                    if MouseClicked then
                        mouse1release()
                    else
                        mouse1press()
                    end
                    MouseClicked = not MouseClicked
                else
                    if MouseClicked then mouse1release() end
                    MouseClicked = false
                end
            else
                if MouseClicked then mouse1release() end
                MouseClicked = false
            end
        else
            if MouseClicked then mouse1release() end
            MouseClicked = false
        end
    else
        if MouseClicked then mouse1release() end
        MouseClicked = false
    end
    ]]

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
    step = 0.01,
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