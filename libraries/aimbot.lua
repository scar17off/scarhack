--[[
    Arsenal Aimbot Module by: scar17off | https://github.com/scar17off/
    Usage:
        local AIMBOT = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/aimbot.lua"))()
        AIMBOT.Setup({
            Target = "Head",
            PreferredHitbox = "Head",
            AimMethod = "Plain",
            Smoothness = 2,
            FOV = 360,
            TeamCheck = true,
            VisibleCheck = true,
            IgnoreFriends = false,
        })
        AIMBOT.Enable(true)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Aimbot = {}
Aimbot.config = {
    Target = "Head",
    PreferredHitbox = "Head",
    AimMethod = "Plain",
    Smoothness = 4,
    FOV = 45,
    TeamCheck = true,
    VisibleCheck = true,
    IgnoreFriends = false,
    AutoFire = false,
    TargetGroups = {game.Players},
}
Aimbot.targets = {}
Aimbot.Target = nil

local enabled = false
local connectionsSetup = false

local function UpdateTargets()
    local updatedTargets = {}

    for _, group in ipairs(Aimbot.config.TargetGroups) do
        if typeof(group) == "Instance" then
            if group == game.Players then
                -- Handle game.Players specifically
                for _, player in ipairs(group:GetPlayers()) do
                    if player.Character then
                        table.insert(updatedTargets, player.Character)
                    end
                end
            elseif group:IsA("Folder") then
                -- Handle folders
                for _, child in ipairs(group:GetChildren()) do
                    table.insert(updatedTargets, child)
                end
            else
                -- Handle other instances directly
                table.insert(updatedTargets, group)
            end
        elseif typeof(group) == "table" then
            -- Handle tables of instances
            for _, instance in ipairs(group) do
                table.insert(updatedTargets, instance)
            end
        end
    end

    Aimbot.targets = updatedTargets
end

local function SetupConnections()
    if connectionsSetup then return end
    connectionsSetup = true

    for _, group in ipairs(Aimbot.config.TargetGroups) do
        if typeof(group) == "Instance" then
            if group == game.Players then
                -- Handle players joining and leaving
                group.PlayerAdded:Connect(function(newPlayer)
                    newPlayer.CharacterAdded:Connect(function(newCharacter)
                        UpdateTargets()
                    end)
                end)
                group.PlayerRemoving:Connect(function(removedPlayer)
                    UpdateTargets()
                end)

                -- Handle existing players respawning
                for _, player in ipairs(group:GetPlayers()) do
                    player.CharacterAdded:Connect(function(newCharacter)
                        UpdateTargets()
                    end)
                end
            elseif group:IsA("Folder") then
                group.ChildAdded:Connect(function(child)
                    UpdateTargets()
                end)
                group.ChildRemoved:Connect(function(child)
                    UpdateTargets()
                end)
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    UpdateTargets()
end)

function Aimbot.Setup(cfg)
    for k, v in pairs(cfg) do
        Aimbot.config[k] = v
    end
    UpdateTargets()
    SetupConnections()
end

function Aimbot.Enable(bool)
    enabled = bool
end

local function IsPartVisible(part)
    local camera = workspace.CurrentCamera
    if not camera then return false end
    local origin = camera.CFrame.Position
    local target = part.Position
    local ray = Ray.new(origin, target - origin)
    local ignoreList = {LocalPlayer.Character}
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
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
        "Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"
    }
    local closestPart, closestDistance = nil, math.huge
    for _, partName in ipairs(validParts) do
        local part = character:FindFirstChild(partName)
        if part and IsPartVisible(part) then
            local screenPoint = Camera:WorldToScreenPoint(part.Position)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPart = part
            end
        end
    end
    return closestPart
end

Aimbot.CanFire = function()
    return true -- Default implementation, override it

    --[[
        Example:
        Aimbot.CanFire = function()
            -- Use the current tool's ammo value to determine if firing is allowed
            local LocalPlayer = game.Players.LocalPlayer
            local character = LocalPlayer.Character
            local tool = character and character:FindFirstChildOfClass("Tool")

            if tool and tool:FindFirstChild("Config") and tool.Config:FindFirstChild("Ammo") then
                return tool.Config.Ammo.Value > 0 -- Only fire if ammo is greater than 0
            end
            return false
        end
    ]]
end

Aimbot.IsTeammate = function(player)
    -- Default implementation, override it
    return LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team
end

function Aimbot.GetTarget()
    local ClosestPlayer, ClosestPart, ClosestDistance = nil, nil, math.huge

    -- Iterate over updated targets
    for _, target in ipairs(Aimbot.targets) do
        local player = game.Players:GetPlayerFromCharacter(target)
        local character = target

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            continue
        end

        -- Skip self
        if character.Name == LocalPlayer.Character.Name then
            continue
        end

        -- Team check - skip teammates if enabled
        if Aimbot.config.TeamCheck and player and Aimbot.IsTeammate(player) then
            continue
        end

        -- Friends check - skip friends if enabled
        if Aimbot.config.IgnoreFriends and player and LocalPlayer:IsFriendsWith(player.UserId) then
            continue
        end

        local targetPart
        if Aimbot.config.Target == "Any" then
            local preferredPart = character:FindFirstChild(Aimbot.config.PreferredHitbox)
            if preferredPart and IsPartVisible(preferredPart) then
                targetPart = preferredPart
            else
                targetPart = GetClosestVisiblePart(character)
            end
        else
            targetPart = character:FindFirstChild(Aimbot.config.Target)
        end

        if targetPart then
            if not Aimbot.config.VisibleCheck or IsPartVisible(targetPart) then
                local screenPoint = Camera:WorldToScreenPoint(targetPart.Position)
                local mouseDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if (mouseDistance <= Aimbot.config.FOV) then
                    if mouseDistance < ClosestDistance then
                        ClosestDistance = mouseDistance
                        ClosestPlayer = character
                        ClosestPart = targetPart
                    end
                end
            end
        end
    end

    Aimbot.Target = ClosestPlayer
    return ClosestPlayer, ClosestPart
end

RunService.RenderStepped:Connect(function()
    if not enabled then return end
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local alive = humanoid and humanoid.Health > 0
    if not alive then return end

    local Target, TargetPart = Aimbot.GetTarget()

    if Target and TargetPart then
        local targetScreen = Camera:WorldToViewportPoint(TargetPart.Position)
        local mousePos = UserInputService:GetMouseLocation()
        local moveVector = Vector2.new(targetScreen.X - mousePos.X, targetScreen.Y - mousePos.Y)
        if targetScreen.Z > 0 then
            local maxMove = 100
            moveVector = Vector2.new(
                math.clamp(moveVector.X, -maxMove, maxMove),
                math.clamp(moveVector.Y, -maxMove, maxMove)
            )
            if Aimbot.config.AimMethod == "Plain" then
                mousemoverel(moveVector.X, moveVector.Y)
            elseif Aimbot.config.AimMethod == "Smooth" then
                mousemoverel(moveVector.X / Aimbot.config.Smoothness, moveVector.Y / Aimbot.config.Smoothness)
            elseif Aimbot.config.AimMethod == "Flick" then
                if math.random() < 0.1 then
                    mousemoverel(moveVector.X * 0.8, moveVector.Y * 0.8)
                end
            end

            -- Auto-fire logic
            if Aimbot.config.AutoFire and Aimbot.CanFire() then
                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, false)
                task.wait(0.03)
                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, false)
            end
        end
    end
end)

return Aimbot

--[[
Usage:
Aimbot.Setup({
    Target = "Head",
    PreferredHitbox = "Head",
    AimMethod = "Plain",
    Smoothness = 2,
    FOV = 35,
    TeamCheck = true,
    VisibleCheck = true,
    IgnoreFriends = false,
    TargetGroups = {game.Players}
})
Aimbot.Enable(true)
]]