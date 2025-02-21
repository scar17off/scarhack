local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

local movement = window:CreateCategory("Movement")
local visuals = window:CreateCategory("Visuals")

-- Shortcuts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local noClipConnection = nil

movement:CreateToggle({
    text = "No Clip",
    callback = function(state)
        if state then
            -- Disconnect existing connection if any
            if noClipConnection then
                noClipConnection:Disconnect()
            end
            
            -- Create new connection to handle noclip
            noClipConnection = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- Disconnect and restore collision
            if noClipConnection then
                noClipConnection:Disconnect()
                noClipConnection = nil
            end
            
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

-- Speed and high jump
local walkspeed = 16
local jumppower = 50

local speedToggle = movement:CreateToggle({
    text = "Speed",
    callback = function(state) end
})

speedToggle:AddSlider({
    text = "Walk Speed",
    min = 16,
    max = 50,
    default = 16,
    defaultValue = 16,
    callback = function(value)
        walkspeed = value
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end,
    onDisable = function(defaultValue)
        LocalPlayer.Character.Humanoid.WalkSpeed = defaultValue
    end
})

local jumpToggle = movement:CreateToggle({
    text = "High Jump",
    callback = function(state)
        if state then
            LocalPlayer.Character.Humanoid.JumpPower = 100
        else
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end
})

jumpToggle:AddSlider({
    text = "Jump Power",
    min = 50,
    max = 100,
    default = 50,
    defaultValue = 50,
    callback = function(value)
        jumppower = value
        LocalPlayer.Character.Humanoid.JumpPower = value
    end,
    onDisable = function(defaultValue)
        LocalPlayer.Character.Humanoid.JumpPower = defaultValue
    end
})

--[[ Visuals ]]
-- Freecam
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local freecam = false
local freecamConnection = nil
local camera = workspace.CurrentCamera
local originalCameraType
local originalCameraSubject
local originalCameraPos
local originalCameraRot
local currentRotation = Vector2.new()
local mouseButtonConnection
local mouseButtonEndedConnection
local mouseConnection
local frozenPosition
local freezeConnection

visuals:CreateToggle({
    text = "Freecam",
    default = false,
    callback = function(value)
        freecam = value
        if value then
            -- Store original camera settings and player position
            originalCameraType = camera.CameraType
            originalCameraSubject = camera.CameraSubject
            originalCameraPos = camera.CFrame.Position
            originalCameraRot = camera.CFrame.Rotation
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                frozenPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
                
                -- Create heartbeat connection to freeze player
                freezeConnection = RunService.Heartbeat:Connect(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = frozenPosition
                        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    end
                end)
            end
            
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
            mouseButtonConnection = UserInputService.InputBegan:Connect(function(input)
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
            mouseConnection = UserInputService.InputChanged:Connect(function(input)
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
            if freezeConnection then
                freezeConnection:Disconnect()
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