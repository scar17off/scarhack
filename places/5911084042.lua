-- Specter: Legacy
-- https://www.roblox.com/games/5911084042/Specter-Legacy

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

-- Pickup Bone
ESP:CreateButton({
    text = "Pickup Bone", 
    callback = function()
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            local bone = workspace.House:FindFirstChild("Bone")
            if bone then
                local prompt = bone:FindFirstChild("ProximityPrompt")
                if prompt then
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    if character then
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            local originalPosition = humanoidRootPart.CFrame
                            humanoidRootPart.CFrame = bone.CFrame
                            task.wait(0.1)
                            fireproximityprompt(prompt)
                            task.wait(0.1)
                            humanoidRootPart.CFrame = originalPosition
                        end
                    end
                end
            end
        end)
    end
})

-- Fix Fuse
ESP:CreateButton({
    text = "Fix Fuse",
    callback = function()
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            local fuse = workspace.House.FuseBox
            if fuse then
                local prompt = fuse:FindFirstChild("ProximityPrompt")
                if prompt then
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    if character then
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            local originalPosition = humanoidRootPart.CFrame
                            humanoidRootPart.CFrame = fuse.CFrame
                            task.wait(0.1)
                            fireproximityprompt(prompt)
                            task.wait(0.1)
                            humanoidRootPart.CFrame = originalPosition
                        end
                    end
                end
            end
        end)
    end
})

-- Hide doors
ESP:CreateToggle({
    text = "Hide Doors",
    default = false,
    callback = function(value)
        local transparency = 0
        local collide = false

        if value then
            transparency = 1
            collide = true
        end

        local doorPaths = {workspace.House.Doors, workspace.House.Outside.Doors}
        for _, doorFolder in doorPaths do
            for _, door in doorFolder:GetChildren() do
                for _, part in door:GetDescendants() do
                    pcall(function()
                        part.Transparency = transparency
                        part.CanCollide = collide
                    end)
                end
            end
        end
    end
})