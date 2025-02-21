local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()
local Placement = window:CreateCategory("Placement")

-- Configuration
local config = {
    deleteEnabled = false,
    createEnabled = false,
    partSize = Vector3.new(0.5, 0.5, 0.5)
}

-- Event connections storage
local connections = {}

-- Preview part
local previewPart = Instance.new("Part")
previewPart.Anchored = true
previewPart.CanCollide = false
previewPart.Transparency = 1
previewPart.Color = Color3.new(1, 1, 1)
previewPart.Name = "PreviewPart"
previewPart.Size = config.partSize

-- Collision group for preview
local PhysicsService = game:GetService("PhysicsService")
pcall(function()
    PhysicsService:CreateCollisionGroup("Preview")
    PhysicsService:CreateCollisionGroup("PlacedParts")
    PhysicsService:CollisionGroupSetCollidable("Preview", "PlacedParts", true)
    previewPart.CollisionGroup = "Preview"
end)

previewPart.Parent = workspace

-- Cleanup connections
local function cleanupConnections()
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    connections = {}
end

-- Handle part deletion
local function onDeleteClick()
    local mouse = game.Players.LocalPlayer:GetMouse()
    if mouse.Target and mouse.Target:IsA("BasePart") and mouse.Target ~= previewPart then
        mouse.Target:Destroy()
    end
end

-- Handle part creation
local function onCreateClick()
    if previewPart.Transparency >= 1 then return end
    
    local newPart = Instance.new("Part")
    newPart.Anchored = true
    newPart.Position = previewPart.Position
    newPart.Size = config.partSize
    newPart.Color = Color3.new(1, 1, 1)

    -- Set collision group for placed parts
    pcall(function()
        newPart.CollisionGroup = "PlacedParts"
    end)
    newPart.Parent = workspace
end

local function updatePreviewPosition()
    if not config.createEnabled then 
        previewPart.Transparency = 1
        return 
    end

    local mouse = game.Players.LocalPlayer:GetMouse()
    local target = mouse.Target
    
    -- Allow preview to show on placed parts
    if target and target.CollisionGroup == "PlacedParts" then
        local hitPos = mouse.Hit.Position
        previewPart.Position = Vector3.new(
            math.round(hitPos.X * 2) / 2,
            math.round(hitPos.Y * 2) / 2,
            math.round(hitPos.Z * 2) / 2
        )
        previewPart.Size = config.partSize
        previewPart.Transparency = 0.5
    elseif target then
        local hitPos = mouse.Hit.Position
        previewPart.Position = Vector3.new(
            math.round(hitPos.X * 2) / 2,
            math.round(hitPos.Y * 2) / 2,
            math.round(hitPos.Z * 2) / 2
        )
        previewPart.Size = config.partSize
        previewPart.Transparency = 0.5
    else
        previewPart.Transparency = 1
    end
end

local deleteToggle = Placement:CreateToggle({
    text = "Delete Part",
    callback = function(enabled)
        config.deleteEnabled = enabled
        cleanupConnections()
        previewPart.Transparency = 1
        
        if enabled then
            table.insert(connections, game.Players.LocalPlayer:GetMouse().Button1Down:Connect(onDeleteClick))
        end
    end
})

local createToggle = Placement:CreateToggle({
    text = "Create Part",
    callback = function(enabled)
        config.createEnabled = enabled
        cleanupConnections()
        
        if enabled then
            table.insert(connections, game.Players.LocalPlayer:GetMouse().Button1Down:Connect(onCreateClick))
            table.insert(connections, game:GetService("RunService").RenderStepped:Connect(updatePreviewPosition))
        else
            previewPart.Transparency = 1
        end
    end
})

createToggle:AddSlider({
    text = "Part Width (X)",
    min = 0.1,
    max = 5,
    default = 0.5,
    callback = function(value)
        config.partSize = Vector3.new(value, config.partSize.Y, config.partSize.Z)
    end
})

createToggle:AddSlider({
    text = "Part Height (Y)",
    min = 0.1,
    max = 5,
    default = 0.5,
    callback = function(value)
        config.partSize = Vector3.new(config.partSize.X, value, config.partSize.Z)
    end
})

createToggle:AddSlider({
    text = "Part Length (Z)",
    min = 0.1,
    max = 5,
    default = 0.5,
    callback = function(value)
        config.partSize = Vector3.new(config.partSize.X, config.partSize.Y, value)
    end
})

game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    cleanupConnections()
    if previewPart then
        previewPart:Destroy()
    end
end)