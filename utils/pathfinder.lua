-- Pathfinder to nearest enemy

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

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