local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- Categories
local category = window:CreateCategory("Tower of Hell")

-- Shortcuts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Godmode
local godmodeConnection = nil
local killScript = nil
local originalParent = nil

category:CreateToggle({
    text = "Godmode",
    default = false,
    callback = function(enabled)
        if enabled then
            godmodeConnection = LocalPlayer.CharacterAdded:Connect(function(char)
                local ks = char:WaitForChild("KillScript")
                killScript = ks
                originalParent = ks.Parent
                ks.Parent = workspace
            end)
            
            if LocalPlayer.Character then
                local ks = LocalPlayer.Character:WaitForChild("KillScript")
                if ks then
                    killScript = ks
                    originalParent = ks.Parent
                    ks.Parent = workspace
                end
            end
        else
            if godmodeConnection then
                godmodeConnection:Disconnect()
                godmodeConnection = nil
            end
            
            if killScript then
                if originalParent and originalParent:IsA("Instance") and originalParent.Parent then
                    killScript.Parent = originalParent
                elseif LocalPlayer.Character then
                    killScript.Parent = LocalPlayer.Character
                end
                killScript = nil
                originalParent = nil
            end
        end
    end
})

-- Finish
category:CreateButton({
    text = "Finish",
    callback = function()
        local FinishPart = workspace.tower.sections.finish:FindFirstChild("FinishGlow")
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoidRootPart then
            local startPos = humanoidRootPart.Position
            local endPos = FinishPart.Position - Vector3.new(8, 6, 0)
            local distance = (endPos - startPos).Magnitude
            local duration = distance / 60 -- Slightly slower for the spiral
            
            local startTime = tick()
            local connection
            
            -- Control points for bezier curve
            local midPoint = (startPos + endPos) / 2
            local controlPoint1 = midPoint + Vector3.new(20, 0, 20) 
            local controlPoint2 = midPoint + Vector3.new(-20, 0, -20)
            
            connection = game:GetService("RunService").RenderStepped:Connect(function()
                local character = LocalPlayer.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then
                    connection:Disconnect()
                    return
                end
                
                local elapsed = tick() - startTime
                local alpha = math.min(elapsed / duration, 1)
                
                -- Cubic bezier curve calculation
                local a = (1 - alpha)
                local b = alpha
                local p1 = startPos * (a^3)
                local p2 = controlPoint1 * (3 * a^2 * b)
                local p3 = controlPoint2 * (3 * a * b^2) 
                local p4 = endPos * (b^3)
                local basePos = p1 + p2 + p3 + p4
                
                -- Spiral motion
                local spiral = Vector3.new(
                    math.cos(alpha * math.pi * 4) * 8,
                    0,
                    math.sin(alpha * math.pi * 4) * 8
                )
                
                local finalPos = basePos + spiral
                humanoidRootPart.CFrame = CFrame.new(finalPos) * CFrame.fromEulerAnglesXYZ(0, alpha * math.pi * 4, 0)
                
                if alpha == 1 then
                    connection:Disconnect()
                end
            end)
        end
    end
})