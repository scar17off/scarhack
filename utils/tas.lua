local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local UserInputService = game:GetService("UserInputService")

local window = UI.CreateWindow()

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
local recordedInputs = {}

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
    
    -- Make parts semi-transparent
    for _, part in pairs(fakeCharacter:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.5
        end
    end
    
    -- Parent to workspace and position at player's location
    fakeCharacter.Parent = workspace
    if player.Character and player.Character.PrimaryPart then
        fakeCharacter:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
    end
    
    return fakeCharacter
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

-- Respawn button
TAS:CreateButton({
    text = "Respawn",
    callback = function()
        if not fakeCharacter then
            createFakeCharacter()
        else
            -- Teleport fake character to player
            local player = game.Players.LocalPlayer
            if player.Character and player.Character.PrimaryPart and fakeCharacter.PrimaryPart then
                fakeCharacter:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
            end
        end
    end
})

-- Clean up when script is destroyed
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if fakeCharacter then
        fakeCharacter:Destroy()
    end
end)