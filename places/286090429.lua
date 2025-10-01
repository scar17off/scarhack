-- Arsenal
-- https://www.roblox.com/games/286090429/Arsenal

-- Libraries
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/aimbot.lua"))()

-- Initialize the UI
local Window = UI.CreateWindow()

local AimbotTab = Window:CreateCategory("Aimbot")
local VisualTab = Window:CreateCategory("Visuals")
local AutoPlayTab = Window:CreateCategory("Auto Play")

-- Shortcuts for easier access
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

Aimbot:Setup({
    FOV = 360,
    Smoothness = 2,
    TeamCheck = true,
    VisibleCheck = true,
    IgnoreFriends = false,
    AutoFire = false,
    Target = "Head",
    PreferredHitbox = "Head",
    AimMethod = "Plain"
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

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end
end)

-- Player death handler for random hitbox
game.Players.PlayerRemoving:Connect(function(player)
    PlayerHitboxes[player] = nil
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

-- Auto play
-- Pathfinder to nearest enemy
local PathfindingService = game:GetService("PathfindingService")

local PATHFINDER_ENABLED = false
local PATH_UPDATE_INTERVAL = 0.2 -- seconds between path recalculation
local WAYPOINT_THRESHOLD = 3 -- studs to next waypoint
local STUCK_TIME = 0.5 -- seconds to consider stuck at a waypoint
local STUCK_DIST = 4   -- if not closer than this, consider stuck

local function getNearestEnemy()
    local myTeam = LocalPlayer.Team
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local nearest, nearestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= myTeam and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
            if dist < nearestDist then
                nearest = p
                nearestDist = dist
            end
        end
    end
    return nearest
end

local function getPathTo(targetPos)
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
        AgentMaxSlope = 45,
    })
    path:ComputeAsync(myRoot.Position, targetPos)
    if path.Status == Enum.PathStatus.Success then
        return path
    end
    return nil
end

local function clearWaypointVisuals(folder)
    if folder and folder:IsA("Folder") then
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("Part") then
                v:Destroy()
            end
        end
    end
end

local function visualizeWaypoints(waypoints)
    local ws = game:GetService("Workspace")
    local folder = ws:FindFirstChild("Autoplay waypoints")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Autoplay waypoints"
        folder.Parent = ws
    end
    clearWaypointVisuals(folder)
    for i, wp in ipairs(waypoints) do
        local part = Instance.new("Part")
        part.Name = "Waypoint_" .. tostring(i)
        part.Size = Vector3.new(0.8, 0.8, 0.8)
        part.Shape = Enum.PartType.Ball
        part.Anchored = true
        part.CanCollide = false
        part.Position = wp.Position
        part.Color = Color3.fromRGB(255, 200, 0)
        part.Material = Enum.Material.Neon
        part.Parent = folder
    end
end

local function pathfindToEnemy()
    local lastPathUpdate = 0
    local path = nil
    local waypoints = {}
    local currentWaypoint = 1
    local lastTarget = nil

    -- Stuck detection
    local stuckTimer = 0
    local lastPos = nil
    local lastMoveDir = Vector3.new(0,0,0)
    local jumpCooldown = 0

    RunService.RenderStepped:Connect(function(dt)
        if not PATHFINDER_ENABLED then return end

        local myChar = LocalPlayer.Character
        local humanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not humanoid or not myRoot or humanoid.Health <= 0 then return end

        -- Always update path to current target every PATH_UPDATE_INTERVAL
        local enemy = getNearestEnemy()
        local shouldUpdatePath = false
        if tick() - lastPathUpdate > PATH_UPDATE_INTERVAL then
            shouldUpdatePath = true
        end
        if not path or currentWaypoint > #waypoints then
            shouldUpdatePath = true
        end
        if shouldUpdatePath and enemy and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
            path = getPathTo(enemy.Character.HumanoidRootPart.Position)
            if path then
                waypoints = path:GetWaypoints()
                currentWaypoint = 2 -- skip the first (current position)
                visualizeWaypoints(waypoints)
            else
                waypoints = {}
                currentWaypoint = 1
                visualizeWaypoints({})
            end
            lastPathUpdate = tick()
        elseif shouldUpdatePath then
            waypoints = {}
            currentWaypoint = 1
            visualizeWaypoints({})
            lastPathUpdate = tick()
        end

        -- Blend direction toward up to 3 next waypoints for even more direct path
        local moveDir = nil
        if waypoints and waypoints[currentWaypoint] then
            local wp = waypoints[currentWaypoint]
            local dir = (wp.Position - myRoot.Position)
            -- Stuck detection: if not getting closer to the waypoint for a while, skip it
            if not lastPos then lastPos = myRoot.Position end
            local distNow = (wp.Position - myRoot.Position).Magnitude
            local distLast = (wp.Position - lastPos).Magnitude
            if distNow > STUCK_DIST and math.abs(distNow - distLast) < 0.1 then
                stuckTimer = stuckTimer + dt
                if stuckTimer > STUCK_TIME then
                    currentWaypoint = currentWaypoint + 1
                    stuckTimer = 0
                    lastPos = myRoot.Position
                    return
                end
            else
                stuckTimer = 0
            end
            lastPos = myRoot.Position

            -- If we're moving away from the waypoint, skip it
            if dir.Magnitude > WAYPOINT_THRESHOLD then
                if lastPos and distNow > distLast + 0.2 then
                    currentWaypoint = currentWaypoint + 1
                    stuckTimer = 0
                else
                    -- Blend direction to next 2 waypoints for a very direct path
                    local blendDir = Vector3.new(dir.X, 0, dir.Z)
                    local blendCount = 1
                    for i = 1, 2 do
                        local nextIdx = currentWaypoint + i
                        if waypoints[nextIdx] then
                            local nextWp = waypoints[nextIdx]
                            local nextDir = (nextWp.Position - myRoot.Position)
                            blendDir = blendDir + Vector3.new(nextDir.X, 0, nextDir.Z)
                            blendCount = blendCount + 1
                        end
                    end
                    moveDir = blendDir.Magnitude > 0 and blendDir.Unit or Vector3.new(0,0,0)
                end
            else
                currentWaypoint = currentWaypoint + 1
                stuckTimer = 0
            end
        end

        -- If not moving to a waypoint, move toward last waypoint (not lookvector)
        if not moveDir then
            if waypoints and #waypoints > 1 then
                local lastWp = waypoints[#waypoints]
                local dir = (lastWp.Position - myRoot.Position)
                moveDir = dir.Magnitude > 0.1 and Vector3.new(dir.X, 0, dir.Z).Unit or Vector3.new(0,0,0)
            else
                moveDir = Vector3.new(0,0,0)
            end
        end

        -- Always use world direction, not relative to character's facing
        humanoid:Move(moveDir, false)
        lastMoveDir = moveDir

        -- Jump if stuck (can't move)
        jumpCooldown = math.max(0, jumpCooldown - dt)
        if moveDir.Magnitude > 0.1 and humanoid.MoveDirection.Magnitude < 0.05 and jumpCooldown <= 0 then
            humanoid.Jump = true
            jumpCooldown = 0.5
        end
    end)
end

pathfindToEnemy()

AutoPlayTab:CreateToggle({
    text = "Enable Auto Play",
    default = false,
    callback = function(Value)
        PATHFINDER_ENABLED = Value
    end
})