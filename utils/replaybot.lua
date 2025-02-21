local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()
local Replay = window:CreateCategory("Replay")

local recording = false
local playing = false
local recordedActions = {}
local recordConnection = nil
local playbackConnection = nil

local replayToggle = Replay:CreateToggle({
    text = "Record",
    default = false,
    callback = function(value)
        recording = value
        if value then
            recordedActions = {}
            local startTime = tick()
            
            -- Disconnect existing connection if any
            if recordConnection then
                recordConnection:Disconnect()
            end
            
            recordConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not recording then return end
                
                if game.Players.LocalPlayer.Character then
                    local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                    local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and rootPart then
                        table.insert(recordedActions, {
                            time = tick() - startTime,
                            position = rootPart.Position,
                            rotation = rootPart.CFrame.Rotation,
                            moveDirection = humanoid.MoveDirection
                        })
                    end
                end
            end)
        else
            -- Disconnect when recording is stopped
            if recordConnection then
                recordConnection:Disconnect()
                recordConnection = nil
            end
        end
    end
})

local playbackToggle = Replay:CreateToggle({
    text = "Playback",
    default = false,
    callback = function(value)
        playing = value
        if value and #recordedActions > 0 then
            local startTime = tick()
            local currentIndex = 1
            
            -- Disconnect existing connection if any
            if playbackConnection then
                playbackConnection:Disconnect()
            end
            
            playbackConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not playing then return end
                
                local currentTime = tick() - startTime
                local action = recordedActions[currentIndex]
                
                if action and currentTime >= action.time then
                    if game.Players.LocalPlayer.Character then
                        local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                        
                        if rootPart and humanoid then
                            rootPart.CFrame = CFrame.new(action.position) * action.rotation
                            humanoid:Move(action.moveDirection)
                        end
                    end
                    
                    currentIndex = currentIndex + 1
                    if currentIndex > #recordedActions then
                        playing = false
                        playbackToggle:SetState(false)
                        -- Disconnect when playback is complete
                        if playbackConnection then
                            playbackConnection:Disconnect()
                            playbackConnection = nil
                        end
                    end
                end
            end)
        else
            -- Disconnect when playback is stopped
            if playbackConnection then
                playbackConnection:Disconnect()
                playbackConnection = nil
            end
        end
    end
})