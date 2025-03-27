local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

local esp = window:CreateCategory("Visuals")
local features = window:CreateCategory("Rage")

-- No NPCs
local noNPCs = false
local noNPCsToggle = features:CreateToggle("No NPCs", function(state)
    noNPCs = state
    
    -- Initial cleanup of existing NPCs
    if noNPCs then
        for _, model in pairs(workspace:GetChildren()) do
            if model.Name == "PlayerCharacter" then
                model:Destroy()
            end
        end
    end
end)

-- Connect to ChildAdded event to remove new NPCs
workspace.ChildAdded:Connect(function(child)
    if noNPCs and child.Name == "PlayerCharacter" then
        child:Destroy()
    end
end)