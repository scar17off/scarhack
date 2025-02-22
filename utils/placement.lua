local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()
local Placement = window:CreateCategory("Placement")

-- Configuration
local config = {
    deleteEnabled = false,
    createEnabled = false,
    partSize = Vector3.new(0.5, 0.5, 0.5),
    climbable = false
}

-- PlacementManager class
local PlacementManager = {}
PlacementManager.__index = PlacementManager

function PlacementManager.new()
    local self = setmetatable({}, PlacementManager)
    self.placedParts = {}
    self.deletedParts = {}
    self.placementPath = game.PlaceId.."/placements/"
    return self
end

function PlacementManager:addPart(part, isDeleted)
    if isDeleted then
        table.insert(self.deletedParts, part)
    else
        table.insert(self.placedParts, part)
    end
end

function PlacementManager:restoreDeleted()
    for _, part in ipairs(self.deletedParts) do
        if part.Parent then  -- Check if part still exists
            part.Transparency = 0
            part.CanCollide = true
            pcall(function()
                part.CollisionGroup = "PlacedParts"
            end)
        end
    end
    self.deletedParts = {}
end

function PlacementManager:exportString()
    local data = {
        placedParts = {},
        deletedParts = {}
    }
    
    -- Export placed parts
    for _, part in ipairs(self.placedParts) do
        if part.Parent then
            local partData = {
                position = {part.Position.X, part.Position.Y, part.Position.Z},
                size = {part.Size.X, part.Size.Y, part.Size.Z},
                transparency = part.Transparency,
                canCollide = part.CanCollide,
                climbable = (part.Material == Enum.Material.Concrete)
            }
            table.insert(data.placedParts, partData)
        end
    end

    -- Export deleted parts
    for _, part in ipairs(self.deletedParts) do
        if part.Parent then
            local partData = {
                position = {part.Position.X, part.Position.Y, part.Position.Z},
                size = {part.Size.X, part.Size.Y, part.Size.Z}
            }
            table.insert(data.deletedParts, partData)
        end
    end
    
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(data)
    end)
    
    if success then
        return encoded
    end
    return nil
end

function PlacementManager:importString(str)
    local success, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(str)
    end)
    
    if success and decoded then
        self:resetAll()
        
        -- Create new placed parts
        if decoded.placedParts then
            for _, partData in ipairs(decoded.placedParts) do
                local newPart = Instance.new("Part")
                newPart.Position = Vector3.new(unpack(partData.position))
                newPart.Size = Vector3.new(unpack(partData.size))
                newPart.Transparency = partData.transparency
                newPart.CanCollide = partData.canCollide
                newPart.Anchored = true
                
                if partData.climbable then
                    newPart.Material = Enum.Material.Concrete
                    newPart.Friction = 1
                end
                
                pcall(function()
                    newPart.CollisionGroup = "PlacedParts"
                end)
                
                newPart.Parent = workspace
                self:addPart(newPart, false)
            end
        end

        -- Create new deleted parts
        if decoded.deletedParts then
            for _, partData in ipairs(decoded.deletedParts) do
                local newPart = Instance.new("Part")
                newPart.Position = Vector3.new(unpack(partData.position))
                newPart.Size = Vector3.new(unpack(partData.size))
                newPart.Transparency = 0.5
                newPart.CanCollide = false
                newPart.Anchored = true
                
                pcall(function()
                    newPart.CollisionGroup = "Default"
                end)
                
                newPart.Parent = workspace
                self:addPart(newPart, true)
            end
        end
        return true
    end
    print("Failed to import placement data: Invalid format or data.")
    return false
end

function PlacementManager:savePlacement(fileName)
    local encoded = self:exportString()
    if encoded then
        pcall(function()
            if not isfolder(self.placementPath) then
                makefolder(self.placementPath)
            end
            writefile(self.placementPath..fileName..".placement", encoded)
        end)
        return true
    end
    return false
end

function PlacementManager:loadPlacement(fileName)
    local success, content = pcall(function()
        return readfile(self.placementPath..fileName..".placement")
    end)
    
    if success then
        return self:importString(content)
    end
    print("Failed to read placement file: " .. fileName)
    return false
end

function PlacementManager:resetAll()
    -- Destroy all tracked parts
    for _, part in ipairs(self.placedParts) do
        if part.Parent then
            part:Destroy()
        end
    end
    for _, part in ipairs(self.deletedParts) do
        if part.Parent then
            part:Destroy()
        end
    end
    -- Clear the parts tables
    self.placedParts = {}
    self.deletedParts = {}
end

-- Create placement manager instance
local placementManager = PlacementManager.new()

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
        -- Make semi-transparent and non-collideable
        mouse.Target.Transparency = 0.5
        mouse.Target.CanCollide = false
        
        -- Remove from collision group to prevent interaction
        pcall(function()
            mouse.Target.CollisionGroup = "Default"
        end)
        
        -- Add to tracked deleted parts if not already tracked
        if not table.find(placementManager.deletedParts, mouse.Target) then
            placementManager:addPart(mouse.Target, true)
        end
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

    -- Set climbable property if enabled
    if config.climbable then
        newPart.Material = Enum.Material.Concrete
        newPart.Friction = 1
    end

    -- Set collision group for placed parts
    pcall(function()
        newPart.CollisionGroup = "PlacedParts"
    end)
    newPart.Parent = workspace
    
    placementManager:addPart(newPart, false)
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

createToggle:AddToggle({
    text = "Climbable",
    callback = function(enabled)
        config.climbable = enabled
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

local fileNameInput = ""

local fileToggle = Placement:CreateToggle({
    text = "File Operations"
})

fileToggle:AddTextbox({
    text = "File Name",
    placeholder = "Enter file name",
    callback = function(text)
        fileNameInput = text
    end
})

Placement:CreateButton({
    text = "Save",
    callback = function()
        if fileNameInput ~= "" then
            placementManager:savePlacement(fileNameInput)
        end
    end
})

Placement:CreateButton({
    text = "Load",
    callback = function()
        if fileNameInput ~= "" then
            placementManager:loadPlacement(fileNameInput)
        end
    end
})

Placement:CreateButton({
    text = "Reset",
    callback = function()
        placementManager:resetAll()
    end
})

Placement:CreateButton({
    text = "Restore Deleted",
    callback = function()
        placementManager:restoreDeleted()
    end
})