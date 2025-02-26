local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

local movement = window:CreateCategory("Movement")
local visuals = window:CreateCategory("Visuals")
local scripts = window:CreateCategory("Scripts")

-- Shortcuts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- External loader of seperate modules
loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/utils/replaybot.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/utils/tas.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/utils/placement.lua"))()

-- [Movement]
-- Infinite Jump
local infiniteJumpConnection
movement:CreateToggle({
    text = "Infinite Jump",
    callback = function(state)
        if state then
            infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
        end
    end
})

-- No Clip
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

-- Click TP
local mouse = LocalPlayer:GetMouse()
local clickTpConnection
movement:CreateToggle({
    text = "Click TP",
    callback = function(state)
        if state then
            clickTpConnection = mouse.Button1Down:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = mouse.Hit.Position
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                end
            end)
        else
            if clickTpConnection then
                clickTpConnection:Disconnect()
                clickTpConnection = nil
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

-- [Visuals]
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

-- Dev Textures
-- Constants and helpers
local TEXTURES = {
    GREY = "rbxassetid://78071731233259",
    ORANGE = "rbxassetid://120981721004720"
}

local ORANGE_MATERIALS = {
    [Enum.Material.Wood] = true,
    [Enum.Material.WoodPlanks] = true,
    [Enum.Material.Sand] = true,
    [Enum.Material.Ground] = true,
    [Enum.Material.Grass] = true,
    [Enum.Material.Concrete] = true,
    [Enum.Material.Brick] = true,
}

local appliedTextures = {}

local function isPlayerCharacter(model)
    if Players:GetPlayerFromCharacter(model) then
        return true
    end
    if model.Name:match("^FakeCharacter_") then
        return true
    end
    return false
end

local function getTextureForMaterial(material)
    return ORANGE_MATERIALS[material] and TEXTURES.ORANGE or TEXTURES.GREY
end

visuals:CreateToggle({
    text = "Dev Textures",
    callback = function(enabled)
        if enabled then
            -- Apply textures
            for _, part in ipairs(workspace:GetDescendants()) do
                local model = part:FindFirstAncestorWhichIsA("Model")
                if model and isPlayerCharacter(model) then
                    continue
                end

                if part:IsA("BasePart") and not part:IsA("Terrain") then
                    pcall(function()
                        local texture = Instance.new("Texture")
                        texture.Texture = getTextureForMaterial(part.Material)
                        texture.Face = Enum.NormalId.Front
                        texture.StudsPerTileU = 2
                        texture.StudsPerTileV = 2
                        texture.Parent = part

                        if not appliedTextures[part] then
                            appliedTextures[part] = {}
                        end
                        table.insert(appliedTextures[part], texture)

                        for _, face in ipairs({Enum.NormalId.Back, Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right}) do
                            local faceTexture = texture:Clone()
                            faceTexture.Face = face
                            faceTexture.Parent = part
                            table.insert(appliedTextures[part], faceTexture)
                        end
                    end)
                end
            end
        else
            -- Remove textures
            for part, textures in pairs(appliedTextures) do
                for _, texture in ipairs(textures) do
                    pcall(function() texture:Destroy() end)
                end
            end
            appliedTextures = {}
        end
    end
})

-- Fullbright
local Lighting = game:GetService("Lighting")
local originalAmbient = Lighting.Ambient
local originalBrightness = Lighting.Brightness
local originalClockTime = Lighting.ClockTime
local originalFogEnd = Lighting.FogEnd
local originalGlobalShadows = Lighting.GlobalShadows

visuals:CreateToggle({
    text = "Fullbright",
    callback = function(enabled)
        if enabled then
            -- Store original lighting values and apply fullbright
            originalAmbient = Lighting.Ambient
            originalBrightness = Lighting.Brightness
            originalClockTime = Lighting.ClockTime
            originalFogEnd = Lighting.FogEnd
            originalGlobalShadows = Lighting.GlobalShadows

            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            -- Restore original lighting values
            Lighting.Ambient = originalAmbient
            Lighting.Brightness = originalBrightness
            Lighting.ClockTime = originalClockTime
            Lighting.FogEnd = originalFogEnd
            Lighting.GlobalShadows = originalGlobalShadows
        end
    end
})

-- [Scripts]
scripts:CreateButton({
    text = "DEV V2",
    callback = function()
        loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Dex%20Explorer%20V2.txt"))()
    end
})

scripts:CreateButton({
    text = "DEV V4",
    callback = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/dannythehacker/1781582ab545302f2b34afc4ec53e811/raw/ee5324771f017073fc30e640323ac2a9b3bfc550/dark%2520dex%2520v4"))()
    end
})

scripts:CreateButton({
    text = "Infinite Yield",
    callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})