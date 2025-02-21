local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local UserInputService = game:GetService("UserInputService")

local window = UI.CreateWindow()

-- TAS Manager Class
local TASManager = {}
TASManager.__index = TASManager

function TASManager.new()
    local self = setmetatable({}, TASManager)
    self.actions = {}
    self.tickRate = 60
    self.tasPath = game.PlaceId.."/tas/"
    return self
end

function TASManager:setRecording(actions, tickRate)
    self.actions = actions or {}
    self.tickRate = tickRate or 60
end

function TASManager:getRecording()
    return self.actions, self.tickRate
end

function TASManager:exportString()
    local data = {
        actions = {},
        tickRate = self.tickRate
    }
    
    for _, action in ipairs(self.actions) do
        local serializedAction = {
            tick = action.tick,
            time = action.time,
            inputs = action.inputs,
            cframe = action.cframe and {action.cframe.X, action.cframe.Y, action.cframe.Z, action.cframe:toEulerAnglesXYZ()} or nil  -- Convert CFrame to table
        }
        table.insert(data.actions, serializedAction)
    end
    
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(data)
    end)
    
    if success then
        return encoded
    end
    return nil
end

function TASManager:importString(str)
    local success, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(str)
    end)
    
    if success and decoded and decoded.actions then
        self.actions = {}
        for _, action in ipairs(decoded.actions) do
            local cframe = action.cframe and CFrame.new(action.cframe[1], action.cframe[2], action.cframe[3]) * CFrame.fromEulerAnglesXYZ(action.cframe[4], action.cframe[5], action.cframe[6]) or nil  -- Convert table back to CFrame
            table.insert(self.actions, {
                tick = action.tick,
                time = action.time,
                inputs = action.inputs,
                cframe = cframe
            })
        end
        self.tickRate = decoded.tickRate or 60
        return true
    end
    print("Failed to import TAS: Invalid format or data.")
    return false
end

function TASManager:saveTAS(fileName)
    local encoded = self:exportString()
    print(encoded)
    if encoded then
        pcall(function()
            writefile(self.tasPath..fileName..".tas", encoded)
        end)
        return true
    end
    return false
end

function TASManager:loadTAS(fileName)
    local success, content = pcall(function()
        return readfile(self.tasPath..fileName..".tas")
    end)
    
    if success then
        if not self:importString(content) then
            print("Failed to load TAS from file: " .. fileName)
        end
        return true
    end
    print("Failed to read TAS file: " .. fileName)
    return false
end

-- Create TAS manager instance
local tasManager = TASManager.new()

-- Categories
local TAS = window:CreateCategory("TAS")

local freecam = false
local freecamConnection = nil
local camera = workspace.CurrentCamera
local originalCameraType
local originalCameraSubject
local originalCameraPos
local originalCameraRot

-- Variables for fake character
local fakeCharacter = nil
local currentTick = 1

-- TAS Recording
local recording = false
local paused = false
local tickRate = 60
local recordedActions = {}
local recordConnection = nil
local playbackConnection = nil
local lastRecordedTime = 0
local controlling = false

-- Pathfinding
local PathfindingService = game:GetService("PathfindingService")
local autoPilot = false
local currentPath = nil
local pathVisual = nil
local targetPosition = nil

local TASDirectory = "tas/"
local fileType = ".tas"

local fileNameInput = ""

pcall(function()
    if not isfolder(TASDirectory) then
        makefolder(TASDirectory)
    end
end)

-- Function to create fake character
local function createFakeCharacter()
    if fakeCharacter then
        fakeCharacter:Destroy()
    end
    
    local player = game.Players.LocalPlayer
    
    -- Create new model
    fakeCharacter = Instance.new("Model")
    fakeCharacter.Name = "TAS_FakeCharacter"
    
    -- Create humanoid
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = fakeCharacter
    
    -- Create main parts
    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.Size = Vector3.new(2, 2, 1)
    torso.Anchored = false
    torso.CanCollide = true
    torso.Parent = fakeCharacter
    
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1, 1, 1)
    head.CanCollide = true
    head.Parent = fakeCharacter
    
    local leftArm = Instance.new("Part")
    leftArm.Name = "Left Arm"
    leftArm.Size = Vector3.new(1, 2, 1)
    leftArm.CanCollide = true
    leftArm.Parent = fakeCharacter
    
    local rightArm = Instance.new("Part")
    rightArm.Name = "Right Arm"
    rightArm.Size = Vector3.new(1, 2, 1)
    rightArm.CanCollide = true
    rightArm.Parent = fakeCharacter
    
    local leftLeg = Instance.new("Part")
    leftLeg.Name = "Left Leg"
    leftLeg.Size = Vector3.new(1, 2, 1)
    leftLeg.CanCollide = true
    leftLeg.Parent = fakeCharacter
    
    local rightLeg = Instance.new("Part")
    rightLeg.Name = "Right Leg"
    rightLeg.Size = Vector3.new(1, 2, 1)
    rightLeg.CanCollide = true
    rightLeg.Parent = fakeCharacter
    
    -- Set primary part
    fakeCharacter.PrimaryPart = torso
    
    -- Position parts and create welds
    local function weldParts(part0, part1, c0)
        local weld = Instance.new("Weld")
        weld.Part0 = part0
        weld.Part1 = part1
        weld.C0 = c0
        weld.Parent = part0
        return weld
    end
    
    -- Weld head to torso
    weldParts(torso, head, CFrame.new(0, 1.5, 0))
    
    -- Weld arms to torso
    weldParts(torso, leftArm, CFrame.new(-1.5, 0, 0))
    weldParts(torso, rightArm, CFrame.new(1.5, 0, 0))
    
    -- Weld legs to torso
    weldParts(torso, leftLeg, CFrame.new(-0.5, -2, 0))
    weldParts(torso, rightLeg, CFrame.new(0.5, -2, 0))
    
    -- Update physics properties
    for _, part in pairs(fakeCharacter:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(
                0.7,  -- Density
                0.3,  -- Friction
                0.5,  -- Elasticity
                1,    -- FrictionWeight
                1     -- ElasticityWeight
            )
            part.Transparency = 0.5
        end
    end
    
    -- Add a HumanoidRootPart for proper physics
    local hrp = Instance.new("Part")
    hrp.Name = "HumanoidRootPart"
    hrp.Size = Vector3.new(2, 2, 1)
    hrp.Transparency = 1
    hrp.CanCollide = false
    hrp.Parent = fakeCharacter
    
    -- Weld HRP to torso at the correct height
    weldParts(hrp, torso, CFrame.new(0, 0, 0))
    
    -- Update the humanoid
    humanoid.HipHeight = 0
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
    humanoid.AutoRotate = true
    
    -- Parent to workspace and position at player's location
    fakeCharacter.Parent = workspace
    if player.Character and player.Character.PrimaryPart then
        -- Match player position exactly
        local playerCFrame = player.Character.PrimaryPart.CFrame
        fakeCharacter:SetPrimaryPartCFrame(playerCFrame * CFrame.new(0, 1, 0))
    end
    
    return fakeCharacter
end

local function moveFakeCharacter(direction, jump)
    if fakeCharacter then
        local humanoid = fakeCharacter:FindFirstChild("Humanoid")
        
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            
            humanoid:Move(direction)
            
            if jump then
                humanoid.Jump = true
            end
        end
    end
end

local function visualizePath(path)
    if pathVisual then
        pathVisual:Destroy()
    end
    
    pathVisual = Instance.new("Folder")
    pathVisual.Name = "PathVisual"
    pathVisual.Parent = workspace
    
    for i = 1, #path - 1 do
        local p1 = path[i].Position
        local p2 = path[i + 1].Position
        
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(0, 255, 0)
        part.Size = Vector3.new(0.3, 0.3, (p2 - p1).Magnitude)
        part.CFrame = CFrame.new(p1:Lerp(p2, 0.5), p2)
        part.Transparency = 0.5
        part.Parent = pathVisual
    end
end

local function handleAutoPilotClick()
    if not (freecam and autoPilot and fakeCharacter) then return end
    
    local mouse = game.Players.LocalPlayer:GetMouse()
    local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {fakeCharacter}
    
    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    if raycastResult then
        targetPosition = raycastResult.Position
        
        -- Create and compute path with parkour-friendly settings
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            WaypointSpacing = 4,
            Costs = {
                Jump = 1,
            }
        })
        
        local success, errorMessage = pcall(function()
            path:ComputeAsync(fakeCharacter.PrimaryPart.Position, targetPosition)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            currentPath = path:GetWaypoints()
            visualizePath(currentPath)
            
            -- Start following path
            if not recordConnection then
                recordConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if not autoPilot or not currentPath or #currentPath == 0 then
                        if recordConnection then
                            recordConnection:Disconnect()
                            recordConnection = nil
                        end
                        return
                    end
                    
                    local nextWaypoint = currentPath[1]
                    local humanoid = fakeCharacter:FindFirstChild("Humanoid")
                    
                    if humanoid then
                        -- Calculate direction to next waypoint
                        local direction = (nextWaypoint.Position - fakeCharacter.PrimaryPart.Position)
                        local horizontalDir = direction * Vector3.new(1, 0, 1)
                        
                        -- Check if we need to jump
                        local shouldJump = false
                        
                        -- Jump if next waypoint is higher
                        if nextWaypoint.Position.Y > fakeCharacter.PrimaryPart.Position.Y + 1 then
                            shouldJump = true
                        end
                        
                        -- Jump if waypoint action is Jump
                        if nextWaypoint.Action == Enum.PathWaypointAction.Jump then
                            shouldJump = true
                        end
                        
                        -- Check if we've reached current waypoint
                        if horizontalDir.Magnitude < 3 then
                            table.remove(currentPath, 1)
                            if #currentPath == 0 then
                                if pathVisual then
                                    pathVisual:Destroy()
                                    pathVisual = nil
                                end
                                return
                            end
                        else
                            -- Move towards waypoint
                            direction = horizontalDir.Unit
                            moveFakeCharacter(direction, shouldJump)
                        end
                    end
                end)
            end
        end
    end
end

local freecamToggle = TAS:CreateToggle({
    text = "Freecam",
    default = false,
    callback = function(value)
        freecam = value
        if value then
            -- Store original camera settings
            originalCameraType = camera.CameraType
            originalCameraSubject = camera.CameraSubject
            originalCameraPos = camera.CFrame.Position
            originalCameraRot = camera.CFrame.Rotation
            
            -- Set up freecam
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CameraSubject = nil
            
            -- Initialize camera position and rotation
            if game.Players.LocalPlayer.Character then
                local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    camera.CFrame = rootPart.CFrame * CFrame.new(0, 2, 0)
                    currentRotation = Vector2.new(camera.CFrame:toEulerAnglesYXZ())
                end
            end
            
            -- Freeze the player
            if game.Players.LocalPlayer.Character then
                local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                end
            end
            
            -- Constants for smooth camera control
            local NAV_GAIN = 50
            local PAN_GAIN = Vector2.new(0.75, 1) * 2
            
            local targetPosition = camera.CFrame.Position
            local isRightMouseDown = false
            
            -- Handle right mouse button state
            local mouseButtonConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 and freecam then
                    isRightMouseDown = true
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                end
            end)
            
            local mouseButtonEndedConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    isRightMouseDown = false
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                end
            end)
            
            -- Handle mouse movement
            local mouseConnection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and isRightMouseDown and freecam then
                    local delta = input.Delta
                    currentRotation = Vector2.new(
                        math.clamp(currentRotation.X - delta.Y/300, -math.pi/2, math.pi/2),
                        currentRotation.Y - delta.X/300
                    )
                    
                    camera.CFrame = CFrame.new(camera.CFrame.Position) * 
                                  CFrame.fromEulerAnglesYXZ(currentRotation.X, currentRotation.Y, 0)
                end
            end)
            
            -- Handle movement
            freecamConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
                if not freecam then return end
                
                local moveVector = Vector3.new()
                local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 4 or 1
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                    moveVector = moveVector + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                    moveVector = moveVector - Vector3.new(0, 1, 0)
                end
                
                if moveVector.Magnitude > 0 then
                    moveVector = moveVector.Unit
                    targetPosition = targetPosition + moveVector * speed * NAV_GAIN * dt
                    camera.CFrame = CFrame.new(targetPosition) * 
                                  CFrame.fromEulerAnglesYXZ(currentRotation.X, currentRotation.Y, 0)
                end
            end)
            
            -- Click detection for auto pilot
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    handleAutoPilotClick()
                end
            end)
            
        else
            -- Clean up connections
            if mouseButtonConnection then
                mouseButtonConnection:Disconnect()
            end
            if mouseButtonEndedConnection then
                mouseButtonEndedConnection:Disconnect()
            end
            if mouseConnection then
                mouseConnection:Disconnect()
            end
            if freecamConnection then
                freecamConnection:Disconnect()
            end
            
            -- Restore original camera settings
            camera.CameraType = originalCameraType
            camera.CameraSubject = originalCameraSubject
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            
            -- Unfreeze the player
            if game.Players.LocalPlayer.Character then
                local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                    humanoid.JumpPower = 50
                end
            end
        end
    end
})

local controlToggle = TAS:CreateToggle({
    text = "Control",
    default = false,
    callback = function(value)
        controlling = value
        if value then
            -- Center camera on fake character
            if fakeCharacter and fakeCharacter.PrimaryPart then
                camera.CameraSubject = fakeCharacter.Humanoid
                camera.CameraType = Enum.CameraType.Custom
            end
            
            -- Freeze local player
            if game.Players.LocalPlayer.Character then
                local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                end
                
                local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.Anchored = true
                end
            end
        else
            -- Reset camera to player
            camera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
            camera.CameraType = Enum.CameraType.Custom
            
            -- Unfreeze player
            if game.Players.LocalPlayer.Character then
                local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                    humanoid.JumpPower = 50
                end
                
                local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.Anchored = false
                end
            end
        end
    end
})

local recordToggle = TAS:CreateToggle({
    text = "Record",
    default = false,
    callback = function(value)
        recording = value
        if value then
            -- Reset recording state
            currentTick = 1
            recordedActions = {}  -- Clear recorded actions for new recording
            lastRecordedTime = tick()
            
            -- Create fake character if it doesn't exist
            if not fakeCharacter then
                createFakeCharacter()
            end
            
            -- Start recording loop
            if recordConnection then
                recordConnection:Disconnect()
            end
            
            recordConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not recording or paused or not controlling then return end
                
                if fakeCharacter and fakeCharacter.PrimaryPart then
                    -- Handle movement inputs
                    local moveDir = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDir = moveDir + (camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDir = moveDir - (camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDir = moveDir - camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDir = moveDir + camera.CFrame.RightVector
                    end
                    
                    -- Normalize movement direction
                    if moveDir.Magnitude > 0 then
                        moveDir = moveDir.Unit
                    end
                    
                    -- Calculate if we should update this frame
                    local timeSinceLastUpdate = tick() - lastRecordedTime
                    local updateInterval = 1/tickRate
                    local shouldUpdate = timeSinceLastUpdate >= updateInterval
                    
                    -- Only anchor if we're running slower than 60 FPS
                    if tickRate < 60 then
                        -- Anchor between updates for slow motion
                        for _, part in pairs(fakeCharacter:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Anchored = not shouldUpdate
                            end
                        end
                    else
                        -- Keep unanchored for normal/fast motion
                        for _, part in pairs(fakeCharacter:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Anchored = false
                            end
                        end
                    end
                    
                    -- Apply movement and record if it's time to update
                    if shouldUpdate then
                        moveFakeCharacter(moveDir, UserInputService:IsKeyDown(Enum.KeyCode.Space))
                        
                        -- Record character state
                        local hrp = fakeCharacter:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            table.insert(recordedActions, {
                                tick = currentTick,
                                time = updateInterval * currentTick,
                                cframe = hrp.CFrame,
                                inputs = {
                                    w = UserInputService:IsKeyDown(Enum.KeyCode.W),
                                    a = UserInputService:IsKeyDown(Enum.KeyCode.A),
                                    s = UserInputService:IsKeyDown(Enum.KeyCode.S),
                                    d = UserInputService:IsKeyDown(Enum.KeyCode.D),
                                    space = UserInputService:IsKeyDown(Enum.KeyCode.Space)
                                }
                            })
                            currentTick = currentTick + 1
                            lastRecordedTime = tick()
                        end
                    end
                end
            end)
            
        else
            if recordConnection then
                recordConnection:Disconnect()
                recordConnection = nil
            end
        end
    end
})

TAS:CreateButton({
    text = "Respawn",
    callback = function()
        createFakeCharacter()
        
        if recording then
            camera.CameraSubject = fakeCharacter.Humanoid
            camera.CameraType = Enum.CameraType.Custom
        end
    end
})

local pauseToggle = TAS:CreateToggle({
    text = "Pause",
    default = false,
    callback = function(value)
        paused = value
        
        -- Anchor/unanchor fake character parts based on pause state
        if fakeCharacter then
            for _, part in pairs(fakeCharacter:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = value
                end
            end
        end
        
        if value then
            lastRecordedTime = tick() - recordedActions[#recordedActions].time
        else
            lastRecordedTime = tick() - recordedActions[currentTick].time
        end
    end
})

local rewindButton = TAS:CreateButton({
    text = "Rewind",
    callback = function()
        if paused and #recordedActions > 0 and currentTick > 1 then
            -- Go back one tick
            currentTick = currentTick - 1
            
            -- Move fake character to position and ensure it stays anchored
            local action = recordedActions[currentTick]
            if action and fakeCharacter and fakeCharacter.PrimaryPart then
                -- Anchor all parts before moving
                for _, part in pairs(fakeCharacter:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                    end
                end
                
                -- Move to recorded position
                fakeCharacter:SetPrimaryPartCFrame(action.cframe)
                
                -- Remove all actions after current tick
                for i = #recordedActions, currentTick + 1, -1 do
                    table.remove(recordedActions, i)
                end
            end
            
            -- Update recording time
            lastRecordedTime = tick() - action.time
        end
    end
})

local tickRateSlider = TAS:CreateToggle({
    text = "Settings"
}):AddSlider({
    text = "Recording Speed",
    min = 1,
    max = 60,
    default = 60,
    callback = function(value)
        tickRate = value
        
        -- Update fake character speed if it exists and we're recording
        if recording and fakeCharacter then
            local humanoid = fakeCharacter:FindFirstChild("Humanoid")
            if humanoid then
                local speedMultiplier = 60/value
                humanoid.WalkSpeed = 16 * speedMultiplier
            end
        end
    end
})

local playbackToggle = TAS:CreateToggle({
    text = "Playback",
    default = false,
    callback = function(value)
        if value and #recordedActions > 0 then
            currentTick = 1
            local startTime = tick()
            
            if playbackConnection then
                playbackConnection:Disconnect()
            end
            
            playbackConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not value then return end
                
                local action = recordedActions[currentTick]
                if action then
                    local currentTime = tick() - startTime
                    local targetTime = action.time / (tickRate/60)
                    
                    if currentTime >= targetTime then
                        if game.Players.LocalPlayer.Character then
                            local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                            
                            if rootPart and humanoid then
                                rootPart.CFrame = action.cframe
                            end
                        end
                        
                        currentTick = currentTick + 1
                        
                        if currentTick > #recordedActions then
                            playbackToggle:SetState(false)
                            if playbackConnection then
                                playbackConnection:Disconnect()
                                playbackConnection = nil
                            end
                        end
                    end
                end
            end)
        else
            if playbackConnection then
                playbackConnection:Disconnect()
                playbackConnection = nil
            end
        end
    end
})

local autoPilotToggle = TAS:CreateToggle({
    text = "Auto Pilot",
    default = false,
    callback = function(value)
        autoPilot = value
        if not value then
            if pathVisual then
                pathVisual:Destroy()
                pathVisual = nil
            end
            currentPath = nil
            targetPosition = nil
        end
    end
})

local fileToggle = TAS:CreateToggle({
    text = "File Operations"
})

fileToggle:AddTextbox({
    text = "File Name",
    placeholder = "Enter file name",
    callback = function(text)
        fileNameInput = text
    end
})

TAS:CreateButton({
    text = "Save",
    callback = function()
        if fileNameInput ~= "" then
            tasManager:setRecording(recordedActions, tickRate)
            tasManager:saveTAS(fileNameInput)
            recordedActions = {}
        end
    end
})

TAS:CreateButton({
    text = "Load", 
    callback = function()
        if fileNameInput ~= "" then
            recordedActions = {}
            if tasManager:loadTAS(fileNameInput) then
                currentTick = 1
                recordedActions, tickRate = tasManager:getRecording()
            end
        end
    end
})

game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if fakeCharacter then
        fakeCharacter:Destroy()
    end
end)