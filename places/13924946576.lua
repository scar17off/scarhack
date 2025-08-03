-- dingus
-- https://www.roblox.com/games/13924946576/dingus

local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

local esp = window:CreateCategory("Visuals")
local features = window:CreateCategory("Rage")

-- No NPCs
local noNPCs = false
local noNPCsToggle = features:CreateToggle({
    text = "No NPCs",
    callback = function(state)
        noNPCs = state
        
    -- Initial cleanup of existing NPCs
    if noNPCs then
        for _, model in pairs(workspace:GetChildren()) do
            if model.Name == "PlayerCharacter" then
                model:Destroy()
            end
        end
        end
    end
})

-- Connect to ChildAdded event to remove new NPCs
workspace.ChildAdded:Connect(function(child)
    if noNPCs and child.Name == "PlayerCharacter" then
        child:Destroy()
    end
end)

-- Object Listener for Players
ESPLibrary:AddObjectListener(workspace, {
    Type = "Model",
    Validator = function(obj)
        return obj:FindFirstChild("ControllerRootPart") ~= nil
    end,
    CustomName = function(obj)
        local nameDisplay = obj:FindFirstChild("NameDisplay")
        if nameDisplay and nameDisplay:FindFirstChild("TextLabel") then
            return nameDisplay.TextLabel.Text
        end
        return obj.Name
    end,
    Color = function(obj)
        return Color3.fromRGB(0, 0, 255) -- Blue for players
    end,
    IsEnabled = "Players"
})

-- Object Listener for NPCs
ESPLibrary:AddObjectListener(workspace, {
    Type = "Model",
    Validator = function(obj)
        return obj:FindFirstChild("ControllerRootPart") == nil
    end,
    CustomName = function(obj)
        return "NPC"
    end,
    Color = function(obj)
        return Color3.fromRGB(255, 0, 0) -- Red for NPCs
    end,
    IsEnabled = "NPCs"
})

-- ESP Options
esp:CreateToggle({
    text = "ESP",
    callback = function(state)
        ESPLibrary.Enabled = state
    end
})

esp:CreateToggle({
    text = "Players",
    callback = function(state)
        ESPLibrary.Players = state
    end
})

esp:CreateToggle({
    text = "NPCs",
    callback = function(state)
        ESPLibrary.NPCs = state
    end
})

esp:CreateToggle({
    text = "Team Color",
    callback = function(state)
        ESPLibrary.TeamColor = state
    end
})

esp:CreateToggle({
    text = "Teammates",
    callback = function(state)
        ESPLibrary.TeamMates = state
    end
})

esp:CreateToggle({
    text = "Tracers",
    callback = function(state)
        ESPLibrary.Tracers = state
    end
})

esp:CreateToggle({
    text = "Boxes",
    callback = function(state)
        ESPLibrary.Boxes = state
    end
})

esp:CreateToggle({
    text = "Names",
    callback = function(state)
        ESPLibrary.Names = state
    end
})

esp:CreateToggle({
    text = "Distance",
    callback = function(state)
        ESPLibrary.Distance = state
    end
})

esp:CreateToggle({
    text = "Health",
    callback = function(state)
        ESPLibrary.Health.Enabled = state
    end
})

esp:CreateToggle({
    text = "Face Camera",
    callback = function(state)
        ESPLibrary.FaceCamera = state
        ESPLibrary.Health.FaceCamera = state
    end
})

esp:CreateToggle({
    text = "Glow",
    callback = function(state)
        ESPLibrary.Glow = state
    end
})