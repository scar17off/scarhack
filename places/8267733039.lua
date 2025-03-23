local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- Shortcuts
local SoundService = game:GetService("SoundService")

-- Categories
local ESP = window:CreateCategory("ESP")

-- Initial ESP setup
ESPLibrary:AddObjectListener(workspace.Dynamic.Evidence.EMF, {
    CustomName = function(obj) return obj.Name end,
    Color = Color3.fromRGB(255, 255, 0),
    IsEnabled = "EMF"
})

ESPLibrary:AddObjectListener(workspace.Dynamic.Evidence.Fingerprints, {
    CustomName = "Fingerprint",
    Color = Color3.fromRGB(0, 255, 0),
    IsEnabled = "Fingerprint"
})

ESPLibrary:AddObjectListener(workspace.Dynamic.Evidence.Orbs, {
    CustomName = "Orb",
    Color = Color3.fromRGB(0, 0, 255),
    IsEnabled = "Orb"
})

ESPLibrary:AddObjectListener(workspace.ServerNPCs, {
    CustomName = "Ghost",
    Color = Color3.fromRGB(255, 0, 0),
    IsEnabled = "Ghost"
})

ESPLibrary:AddObjectListener(workspace.Map, {
    Name = "Bone",
    CustomName = "Bone",
    Color = Color3.fromRGB(255, 192, 203),
    IsEnabled = "Bone"
})

ESPLibrary:AddObjectListener(workspace.Map, {
    Name = "Safe",
    CustomName = "Safe",
    Color = Color3.fromRGB(255, 215, 0),
    IsEnabled = "Safe"
})

ESPLibrary:AddObjectListener(workspace.Map, {
    Name = "SafeKey",
    CustomName = "Safe Key",
    Color = Color3.fromRGB(0, 255, 255),
    IsEnabled = "SafeKey"
})

if workspace.Map.cursed_object:GetChildren()[1] then
    ESPLibrary:AddObjectListener(workspace.Map.cursed_object:GetChildren()[1], {
        CustomName = function(obj) return obj.Name end,
        Color = Color3.fromRGB(148, 0, 211),
        IsEnabled = "CursedObject"
    })
end

-- ESP Toggles
ESP:CreateToggle({
    text = "ESP",
    default = false,
    callback = function(value)
        ESPLibrary:Toggle(value)
    end
})

ESP:CreateToggle({
    text = "Ghost",
    default = false,
    callback = function(value)
        ESPLibrary.Ghost = value
    end
})

ESP:CreateToggle({
    text = "EMF",
    default = false,
    callback = function(value)
        ESPLibrary.EMF = value
    end
})

ESP:CreateToggle({
    text = "Fingerprint",
    default = false,
    callback = function(value)
        ESPLibrary.Fingerprint = value
    end
})

ESP:CreateToggle({
    text = "Orb",
    default = false,
    callback = function(value)
        ESPLibrary.Orb = value
    end
})

ESP:CreateToggle({
    text = "Bone",
    default = false,
    callback = function(value)
        ESPLibrary.Bone = value
    end
})

ESP:CreateToggle({
    text = "Safe",
    default = false,
    callback = function(value)
        ESPLibrary.Safe = value
    end
})

ESP:CreateToggle({
    text = "Safe Key",
    default = false,
    callback = function(value)
        ESPLibrary.SafeKey = value
    end
})

ESP:CreateToggle({
    text = "Cursed Object",
    default = false,
    callback = function(value)
        ESPLibrary.CursedObject = value
    end
})

-- Evidence Information
local Evidences = window:CreateCategory("Evidences")

-- Chat mode toggle and map
local chatMode = false
Evidences:CreateToggle({
    text = "Announce",
    default = false,
    callback = function(value)
        chatMode = value
    end
})

-- Evidence abbreviation map
local evidenceAbbr = {
    ["EMF 5"] = "emf5",
    ["Fingerprints"] = "ft",
    ["Orb"] = "orbs",
    ["Motion"] = "pm",
    ["Spirit Box"] = "spiritbox",
    ["Book Writing"] = "book",
    ["Freezing"] = "freezing"
}

-- Evidence labels
local evidenceLabel_1 = Evidences:CreateLabel("N/A")
local evidenceLabel_2 = Evidences:CreateLabel("N/A")
local evidenceLabel_3 = Evidences:CreateLabel("N/A")

-- Monitor for new evidence and update labels
local evidenceFound = {}

local function addEvidence(evidenceName)
    if not table.find(evidenceFound, evidenceName) then
        table.insert(evidenceFound, evidenceName)
        -- Find first available N/A label and update it
        for _, label in ipairs({evidenceLabel_1, evidenceLabel_2, evidenceLabel_3}) do
            if label:GetText() == "N/A" then
                label:SetText(evidenceName)
                -- Send chat message if chat mode is enabled
                if chatMode and evidenceAbbr[evidenceName] then
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(evidenceAbbr[evidenceName], "All")
                end
                break
            end
        end
    end
end

workspace.Dynamic.Evidence.EMF.ChildAdded:Connect(function(obj)
    if obj.Name == "EMF5" then
        addEvidence("EMF 5")
    end
end)

workspace.Dynamic.Evidence.Fingerprints.ChildAdded:Connect(function(obj)
    addEvidence("Fingerprints")
end)

workspace.Dynamic.Evidence.Orbs.ChildAdded:Connect(function(obj)
    addEvidence("Orb")
end)

-- Monitor for book writing
local function checkBookWriting()
    if not table.find(evidenceFound, "Book Writing") then
        local book = workspace.Equipment:FindFirstChild("Book")
        if book then
            local leftPage = book:FindFirstChild("LeftPage")
            local rightPage = book:FindFirstChild("RightPage")
            
            -- Check if either page has a Decal
            local hasWriting = false
            if leftPage and #leftPage:GetChildren() > 0 then
                for _, child in pairs(leftPage:GetChildren()) do
                    if child:IsA("Decal") then
                        hasWriting = true
                        break
                    end
                end
            end
            if not hasWriting and rightPage and #rightPage:GetChildren() > 0 then
                for _, child in pairs(rightPage:GetChildren()) do
                    if child:IsA("Decal") then
                        hasWriting = true
                        break
                    end
                end
            end

            if hasWriting then
                addEvidence("Book Writing")
            end
        end
    end
end

-- Set up book monitoring
workspace.Equipment.ChildAdded:Connect(function(child)
    if child.Name == "Book" then
        task.wait(1)
        checkBookWriting()
        
        -- Monitor the pages for changes
        child.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("Decal") then
                checkBookWriting()
            end
        end)
    end
end)

-- Monitor for motion detection
local motionDetected = false -- Flag to prevent multiple detections

local function checkMotion(part)
    if not motionDetected and not table.find(evidenceFound, "Motion") then
        if part:IsA("Part") then
            -- Check if the color is close to red (allowing for some variation)
            local r, g, b = part.Color.R, part.Color.G, part.Color.B
            
            -- Red detection criteria:
            -- R value should be high (> 0.8)
            -- G and B values should be low (< 0.2)
            if r > 0.8 and g < 0.2 and b < 0.2 then
                -- Wait a short moment to confirm it's not a temporary change
                motionDetected = true -- Set flag to prevent multiple detections during wait
                task.wait(0.1)
                
                -- Check if still red (to avoid false positives)
                if part.Parent and part:IsA("Part") then
                    r, g, b = part.Color.R, part.Color.G, part.Color.B
                    if r > 0.8 and g < 0.2 and b < 0.2 and not table.find(evidenceFound, "Motion") then
                        addEvidence("Motion")
                    end
                end
                task.wait(0.1)
                motionDetected = false -- Reset flag after detection attempt
            end
        end
    end
end

-- Monitor MotionGrids parts
local function setupMotionMonitoring()
    local motionGrids = workspace.Dynamic.Evidence.MotionGrids
    
    local function setupPart(part)
        if part:IsA("Part") then
            part:GetPropertyChangedSignal("Color"):Connect(function()
                checkMotion(part)
            end)
        end
    end
    
    local function setupSensorGrid(sensorGrid)
        -- Monitor existing parts
        for _, part in ipairs(sensorGrid:GetDescendants()) do
            setupPart(part)
        end
        
        -- Monitor for new parts
        sensorGrid.DescendantAdded:Connect(function(child)
            setupPart(child)
        end)
    end
    
    -- Monitor existing SensorGrids
    for _, model in ipairs(motionGrids:GetChildren()) do
        if model.Name == "SensorGrid" then
            setupSensorGrid(model)
        end
    end
    
    -- Monitor for new SensorGrids
    motionGrids.ChildAdded:Connect(function(child)
        if child.Name == "SensorGrid" then
            setupSensorGrid(child)
        end
    end)
end

-- Start motion monitoring
setupMotionMonitoring()

-- Monitor for freezing temperatures
local thermometerConnections = {} -- Store connections for cleanup

local function checkThermometer(thermometer)
    if not table.find(evidenceFound, "Freezing") then
        local tempLabel = thermometer:FindFirstChild("Temp")
        if tempLabel and tempLabel:FindFirstChild("SurfaceGui") then
            local textLabel = tempLabel.SurfaceGui:FindFirstChild("TextLabel")
            if textLabel then
                local text = textLabel.Text
                -- Extract number from text (handles formats like "-2.5°C" or "-2.5 °C")
                local number = tonumber(string.match(text, "([%-%.%d]+)"))
                -- Check if it's a valid negative number (not nil and less than 0)
                if number and number < 0 then
                    -- Wait a short moment to confirm it's not temporary
                    task.wait(0.1)
                    -- Check again to avoid false positives
                    if thermometer.Parent and textLabel.Parent then
                        local newText = textLabel.Text
                        local newNumber = tonumber(string.match(newText, "([%-%.%d]+)"))
                        if newNumber and newNumber < 0 then
                            addEvidence("Freezing")
                        end
                    end
                end
            end
        end
    end
end

local function disconnectThermometer(thermometer)
    if thermometerConnections[thermometer] then
        for _, connection in ipairs(thermometerConnections[thermometer]) do
            connection:Disconnect()
        end
        thermometerConnections[thermometer] = nil
    end
end

local function setupThermometerMonitoring(thermometer)
    if thermometer then
        thermometerConnections[thermometer] = {}
        
        -- Check initial state
        checkThermometer(thermometer)
        
        -- Monitor for text changes
        local tempLabel = thermometer:FindFirstChild("Temp")
        if tempLabel and tempLabel:FindFirstChild("SurfaceGui") then
            local textLabel = tempLabel.SurfaceGui:FindFirstChild("TextLabel")
            if textLabel then
                local connection = textLabel:GetPropertyChangedSignal("Text"):Connect(function()
                    checkThermometer(thermometer)
                end)
                table.insert(thermometerConnections[thermometer], connection)
            end
        end
    end
end

-- Monitor Equipment folder and all players
local function monitorAllThermometers()
    -- Check workspace Equipment
    local equipmentConnection = workspace.Equipment.ChildAdded:Connect(function(child)
        if child.Name == "Thermometer" then
            setupThermometerMonitoring(child)
        end
    end)
    
    -- Check existing thermometer in workspace
    local equipmentThermometer = workspace.Equipment:FindFirstChild("Thermometer")
    if equipmentThermometer then
        setupThermometerMonitoring(equipmentThermometer)
    end
    
    -- Monitor character equipment
    local function setupCharacterMonitoring(character)
        local equipModel = character:WaitForChild("EquipmentModel", 5)
        if not equipModel then return end
        
        -- Monitor for new thermometers
        local addedConnection = equipModel.ChildAdded:Connect(function(child)
            if child.Name == "Thermometer" then
                setupThermometerMonitoring(child)
            end
        end)
        
        -- Monitor for removed thermometers
        local removedConnection = equipModel.ChildRemoved:Connect(function(child)
            if child.Name == "Thermometer" then
                disconnectThermometer(child)
            end
        end)
        
        -- Store connections for cleanup
        thermometerConnections[character] = {addedConnection, removedConnection}
        
        -- Check existing thermometer
        local thermometer = equipModel:FindFirstChild("Thermometer")
        if thermometer then
            setupThermometerMonitoring(thermometer)
        end
    end
    
    -- Monitor for new characters
    workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child:FindFirstChild("Humanoid") then
            setupCharacterMonitoring(child)
        end
    end)
    
    -- Monitor for removed characters
    workspace.ChildRemoved:Connect(function(child)
        if thermometerConnections[child] then
            for _, connection in ipairs(thermometerConnections[child]) do
                connection:Disconnect()
            end
            thermometerConnections[child] = nil
        end
    end)
    
    -- Check existing characters
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("Humanoid") then
            setupCharacterMonitoring(child)
        end
    end
end

-- Monitor for Spirit Box responses
local spiritBoxConnections = {}

local function disconnectSpiritBox(spiritBox)
    if spiritBoxConnections[spiritBox] then
        for _, connection in ipairs(spiritBoxConnections[spiritBox]) do
            connection:Disconnect()
        end
        spiritBoxConnections[spiritBox] = nil
    end
end

local function checkSpiritBox(spiritBox)
    if not table.find(evidenceFound, "Spirit Box") then
        local main = spiritBox:FindFirstChild("Main")
        if main then
            -- Check if there are any GUI elements besides Template
            for _, child in ipairs(main:GetChildren()) do
                if (child:IsA("SurfaceGui") or child:IsA("BillboardGui")) and child.Name ~= "Template" then
                    addEvidence("Spirit Box")
                    break
                end
            end
        end
    end
end

local function setupSpiritBoxMonitoring(spiritBox)
    if spiritBox then
        -- Disconnect existing connections if any
        disconnectSpiritBox(spiritBox)
        
        -- Create new connections table
        spiritBoxConnections[spiritBox] = {}
        
        -- Check initial state
        checkSpiritBox(spiritBox)
        
        -- Monitor for new GUIs
        local main = spiritBox:WaitForChild("Main", 5)
        if main then
            local connection = main.ChildAdded:Connect(function(child)
                if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
                    checkSpiritBox(spiritBox)
                end
            end)
            table.insert(spiritBoxConnections[spiritBox], connection)
        end
    end
end

-- Monitor Equipment folder and all players for Spirit Boxes
local function monitorAllSpiritBoxes()
    -- Monitor workspace Equipment
    local equipmentConnection = workspace.Equipment.ChildAdded:Connect(function(child)
        if child.Name == "Spirit Box" then
            task.wait(0.1)
            setupSpiritBoxMonitoring(child)
        end
    end)
    
    local equipmentRemovedConnection = workspace.Equipment.ChildRemoved:Connect(function(child)
        if child.Name == "Spirit Box" then
            disconnectSpiritBox(child)
        end
    end)
    
    -- Check existing Spirit Box in workspace
    local equipmentSpiritBox = workspace.Equipment:FindFirstChild("Spirit Box")
    if equipmentSpiritBox then
        setupSpiritBoxMonitoring(equipmentSpiritBox)
    end
end

-- Start monitoring
monitorAllThermometers()
monitorAllSpiritBoxes()

-- Sanity Information
local Sanity = window:CreateCategory("Sanity")

local peaceTimeLabel = Sanity:CreateLabel("Peace time: 00:00")

-- Monitor peace timer
local timerLabel = workspace.Van.Timer.SurfaceGui.Timer
timerLabel:GetPropertyChangedSignal("Text"):Connect(function()
    peaceTimeLabel:SetText("Peace time: " .. timerLabel.Text)
end)
-- Set initial time
peaceTimeLabel:SetText("Peace time: " .. timerLabel.Text)

-- Action status
local actionLabel = Sanity:CreateLabel("Action: Roaming")

-- Monitor hunt sound for hunting
local huntSound = SoundService:FindFirstChild("Hunt")
if huntSound then
    huntSound:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        actionLabel:SetText("Action: " .. (huntSound.IsPlaying and "Hunting" or "Roaming"))
    end)
end

-- Separator
Sanity:CreateLabel("=-=-=-=-=-=-=-=")

local avgSanityLabel = Sanity:CreateLabel("Avg sanity: 100%")

local playerLabels = {}

local function updateAverageSanity()
    local total = 0
    local count = 0
    
    for _, label in pairs(playerLabels) do
        local sanityText = label:GetText()
        -- Extract just the number before the % sign
        local sanityValue = tonumber(string.match(sanityText, ": (%d+)%%"))
        if sanityValue then
            total = total + sanityValue
            count = count + 1
        end
    end
    
    local average = count > 0 and math.floor(total / count) or 100
    avgSanityLabel:SetText("Avg sanity: " .. average .. "%")
end

local function updatePlayerSanity(playerFrame)
    local playerName = playerFrame.Name
    local entireFrame = playerFrame:FindFirstChild("Entire")
    if entireFrame then
        local valLabel = entireFrame:FindFirstChild("Val")
        if valLabel then
            -- Create or update player label
            if not playerLabels[playerName] then
                playerLabels[playerName] = Sanity:CreateLabel(playerName .. ": " .. valLabel.Text)
            else
                playerLabels[playerName]:SetText(playerName .. ": " .. valLabel.Text)
            end
            
            -- Monitor for sanity changes
            valLabel:GetPropertyChangedSignal("Text"):Connect(function()
                playerLabels[playerName]:SetText(playerName .. ": " .. valLabel.Text)
                updateAverageSanity()
            end)
            
            updateAverageSanity()
        end
    end
end

-- Monitor players board
local playersFrame = workspace.Van.SanityBoard.SurfaceGui.Frame.Players

-- Set up monitoring for existing players
for _, playerFrame in ipairs(playersFrame:GetChildren()) do
    if playerFrame:IsA("Frame") then
        updatePlayerSanity(playerFrame)
    end
end

-- Monitor for new players
playersFrame.ChildAdded:Connect(function(child)
    if child:IsA("Frame") then
        task.wait(0.1)
        updatePlayerSanity(child)
    end
end)

-- Clean up removed players
playersFrame.ChildRemoved:Connect(function(child)
    if playerLabels[child.Name] then
        playerLabels[child.Name]:SetText(child.Name .. ": N/A")
        updateAverageSanity()
    end
end)

-- Teleports
Teleports = window:CreateCategory("Teleports")

Teleports:CreateButton({
    text = "TP to Van",
    callback = function()
        local character = game.Players.LocalPlayer.Character
        if character and workspace.Van:FindFirstChild("Spawn") then
            character:PivotTo(workspace.Van.Spawn.CFrame)
        end
    end
})

-- Objectives Information
local Objectives = window:CreateCategory("Objectives")

-- Create labels for each objective
local objectiveLabels = {
    Objectives:CreateLabel("1: ..."),
    Objectives:CreateLabel("2: ..."),
    Objectives:CreateLabel("3: ...")
}

-- Function to update objective display
local function updateObjective(objectiveFrame, index)
    if objectiveFrame and objectiveFrame:IsA("Frame") then
        local textLabel = objectiveFrame:FindFirstChild("TextLabel")
        if textLabel then
            local text = textLabel.Text
            local isCompleted = objectiveFrame:FindFirstChild("Strike") ~= nil
            local status = isCompleted and "✓" or "✗"
            objectiveLabels[index]:SetText(status .. " " .. text)
        end
    end
end

-- Get the objectives frame
local objectivesFrame = workspace.Van.Objectives.SurfaceGui.Frame.Objectives

-- Set initial objectives
for i = 1, 3 do
    objectiveLabels[i]:SetText("✗ ...")
end

for i = 1, 3 do
    local objective = objectivesFrame:FindFirstChild(tostring(i))
    if objective then
        updateObjective(objective, i)
    end
end

-- Monitor existing objectives
for i = 1, 3 do
    local objective = objectivesFrame:FindFirstChild(tostring(i))
    if objective then
        updateObjective(objective, i)
        
        -- Monitor text changes
        local textLabel = objective:FindFirstChild("TextLabel")
        if textLabel then
            textLabel:GetPropertyChangedSignal("Text"):Connect(function()
                updateObjective(objective, i)
            end)
        end
        
        -- Monitor completion status changes
        objective.ChildAdded:Connect(function(child)
            if child.Name == "Strike" then
                updateObjective(objective, i)
            end
        end)
        
        objective.ChildRemoved:Connect(function(child)
            if child.Name == "Strike" then
                updateObjective(objective, i)
            end
        end)
    end
end

-- Monitor for changes in objectives
objectivesFrame.ChildAdded:Connect(function(child)
    local index = tonumber(child.Name)
    if index and index >= 1 and index <= 3 then
        task.wait(0.1)
        updateObjective(child, index)
        
        -- Monitor text changes
        local textLabel = child:FindFirstChild("TextLabel")
        if textLabel then
            textLabel:GetPropertyChangedSignal("Text"):Connect(function()
                updateObjective(child, index)
            end)
        end
        
        -- Monitor completion status changes
        child.ChildAdded:Connect(function(grandChild)
            if grandChild.Name == "Strike" then
                updateObjective(child, index)
            end
        end)
        
        child.ChildRemoved:Connect(function(grandChild)
            if grandChild.Name == "Strike" then
                updateObjective(child, index)
            end
        end)
    end
end)