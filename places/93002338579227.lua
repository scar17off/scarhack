-- Build Your Factory Tycoon
-- https://www.roblox.com/games/93002338579227/Build-Your-Factory-Tycoon-ALPHA

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- Categories
local AutoFarm = window:CreateCategory("AutoFarm")

-- Shortcuts
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local autoFarmEnabled = false

local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function farmCashBoxes()
    while autoFarmEnabled do
        for _, model in pairs(workspace.Temp:GetChildren()) do
            if model.Name:match("CashBox$") then
                local basePart = model:FindFirstChild("Base") or model:FindFirstChild("Small")
                if basePart and (basePart:IsA("BasePart") or basePart:IsA("MeshPart")) then
                    local prompt = basePart:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        -- Teleport player to the Base part
                        local root = getRoot()
                        root.CFrame = basePart.CFrame + Vector3.new(0, 3, 0)

                        -- Ensure HoldDuration is instant
                        if prompt.HoldDuration ~= 0 then
                            prompt.HoldDuration = 0
                        end

                        task.wait(0.2) -- small delay to ensure teleport finished
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1) -- hold for a short moment
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end

-- UI toggle
AutoFarm:CreateToggle({
    text = "Auto Cashbox",
    default = false,
    callback = function(value)
        autoFarmEnabled = value
        if autoFarmEnabled then
            task.spawn(farmCashBoxes)
        end
    end
})