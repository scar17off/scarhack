local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- Categories
local ESP = window:CreateCategory("ESP")

-- Toggle
local ESPToggle = ESP:CreateToggle({
    text = "ESP",
    default = false,
    callback = function(value)
        ESPLibrary:Toggle(value)
    end
})

-- Ghost
ESPLibrary:AddObjectListener(workspace.GhostModel, {
    Name = "HumanoidRootPart",
    CustomName = "Ghost",
    Color = Color3.fromRGB(255, 255, 0),
    IsEnabled = "Ghost"
})

ESP:CreateToggle({
    text = "Ghost",
    default = false,
    callback = function(value)
        ESPLibrary.Ghost = value
    end
})

-- Bones
ESPLibrary:AddObjectListener(workspace.House, {
    Name = "Bone",
    CustomName = "Bone",
    Color = Color3.fromRGB(255, 255, 0),
    IsEnabled = "Bone"
})

ESP:CreateToggle({
    text = "Bone ESP",
    default = false,
    callback = function(value)
        ESPLibrary.Bone = value
    end
})

ESP:CreateButton({
    text = "Pickup Bone",
    callback = function()
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            local bone = workspace.House:FindFirstChild("Bone")
            if bone then
                local prompt = bone:FindFirstChild("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                end
            end
        end)
        
        getfenv(1)._bonePromptConnection = connection
    end
})