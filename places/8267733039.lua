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

-- Evidence Information
local Evidences = window:CreateCategory("Evidences")

local evidenceLabel_1 = Evidences:CreateLabel("N/A")
local evidenceLabel_2 = Evidences:CreateLabel("N/A")
local evidenceLabel_3 = Evidences:CreateLabel("N/A")

-- Monitor for new evidence and update labels
local evidenceFound = {}

workspace.Dynamic.Evidence.EMF.ChildAdded:Connect(function(obj)
    if obj.Name == "EMF5" then
        if not table.find(evidenceFound, "EMF 5") then
            table.insert(evidenceFound, "EMF 5")
            -- Update first available label
            if evidenceLabel_1:GetText() == "N/A" then
                evidenceLabel_1:SetText("EMF 5")
            elseif evidenceLabel_2:GetText() == "N/A" then
                evidenceLabel_2:SetText("EMF 5")
            elseif evidenceLabel_3:GetText() == "N/A" then
                evidenceLabel_3:SetText("EMF 5")
            end
        end
    end
end)

workspace.Dynamic.Evidence.Fingerprints.ChildAdded:Connect(function(obj)
    if not table.find(evidenceFound, "Fingerprints") then
        table.insert(evidenceFound, "Fingerprints")
        -- Update first available label
        if evidenceLabel_1:GetText() == "N/A" then
            evidenceLabel_1:SetText("Fingerprints")
        elseif evidenceLabel_2:GetText() == "N/A" then
            evidenceLabel_2:SetText("Fingerprints")
        elseif evidenceLabel_3:GetText() == "N/A" then
            evidenceLabel_3:SetText("Fingerprints")
        end
    end
end)

workspace.Dynamic.Evidence.Orbs.ChildAdded:Connect(function(obj)
    if not table.find(evidenceFound, "Orb") then
        table.insert(evidenceFound, "Orb")
        -- Update first available label
        if evidenceLabel_1:GetText() == "N/A" then
            evidenceLabel_1:SetText("Orb")
        elseif evidenceLabel_2:GetText() == "N/A" then
            evidenceLabel_2:SetText("Orb")
        elseif evidenceLabel_3:GetText() == "N/A" then
            evidenceLabel_3:SetText("Orb")
        end
    end
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
                table.insert(evidenceFound, "Book Writing")
                -- Update first available label
                if evidenceLabel_1:GetText() == "N/A" then
                    evidenceLabel_1:SetText("Book Writing")
                elseif evidenceLabel_2:GetText() == "N/A" then
                    evidenceLabel_2:SetText("Book Writing")
                elseif evidenceLabel_3:GetText() == "N/A" then
                    evidenceLabel_3:SetText("Book Writing")
                end
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
local function checkMotion(part)
    if not table.find(evidenceFound, "Motion") then
        if part:IsA("Part") then
            -- Check if the color is close to red (allowing for some variation)
            local r, g, b = part.Color.R, part.Color.G, part.Color.B
            
            -- Red detection criteria:
            -- R value should be high (> 0.8)
            -- G and B values should be low (< 0.2)
            if r > 0.8 and g < 0.2 and b < 0.2 then
                -- Wait a short moment to confirm it's not a temporary change
                task.wait(0.1)
                
                -- Check if still red (to avoid false positives)
                if part.Parent and part:IsA("Part") then
                    r, g, b = part.Color.R, part.Color.G, part.Color.B
                    if r > 0.8 and g < 0.2 and b < 0.2 then
                        table.insert(evidenceFound, "Motion")
                        -- Update first available label
                        if evidenceLabel_1:GetText() == "N/A" then
                            evidenceLabel_1:SetText("Motion")
                        elseif evidenceLabel_2:GetText() == "N/A" then
                            evidenceLabel_2:SetText("Motion")
                        elseif evidenceLabel_3:GetText() == "N/A" then
                            evidenceLabel_3:SetText("Motion")
                        end
                    end
                end
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
                            table.insert(evidenceFound, "Freezing")
                            -- Update first available label
                            if evidenceLabel_1:GetText() == "N/A" then
                                evidenceLabel_1:SetText("Freezing")
                            elseif evidenceLabel_2:GetText() == "N/A" then
                                evidenceLabel_2:SetText("Freezing")
                            elseif evidenceLabel_3:GetText() == "N/A" then
                                evidenceLabel_3:SetText("Freezing")
                            end
                        end
                    end
                end
            end
        end
    end
end

local function setupThermometerMonitoring(thermometer)
    if thermometer then
        -- Check initial state
        checkThermometer(thermometer)
        
        -- Monitor for text changes
        local tempLabel = thermometer:FindFirstChild("Temp")
        if tempLabel and tempLabel:FindFirstChild("SurfaceGui") then
            local textLabel = tempLabel.SurfaceGui:FindFirstChild("TextLabel")
            if textLabel then
                textLabel:GetPropertyChangedSignal("Text"):Connect(function()
                    checkThermometer(thermometer)
                end)
            end
        end
    end
end

-- Monitor Equipment folder and all players
local function monitorAllThermometers()
    -- Check workspace Equipment
    workspace.Equipment.ChildAdded:Connect(function(child)
        if child.Name == "Thermometer" then
            setupThermometerMonitoring(child)
        end
    end)
    
    -- Check existing thermometer in workspace
    local equipmentThermometer = workspace.Equipment:FindFirstChild("Thermometer")
    if equipmentThermometer then
        setupThermometerMonitoring(equipmentThermometer)
    end
    
    -- Monitor all EquipmentModels in workspace
    local function checkEquipmentModel(model)
        if model then
            -- Monitor for new thermometers
            model.ChildAdded:Connect(function(child)
                if child.Name == "Thermometer" then
                    setupThermometerMonitoring(child)
                end
            end)
            
            -- Check existing thermometer
            local thermometer = model:FindFirstChild("Thermometer")
            if thermometer then
                setupThermometerMonitoring(thermometer)
            end
        end
    end
    
    -- Check all existing EquipmentModels
    for _, obj in ipairs(workspace:GetChildren()) do
        local equipModel = obj:FindFirstChild("EquipmentModel")
        if equipModel then
            checkEquipmentModel(equipModel)
        end
    end
    
    -- Monitor for new EquipmentModels
    workspace.ChildAdded:Connect(function(child)
        local equipModel = child:FindFirstChild("EquipmentModel")
        if equipModel then
            checkEquipmentModel(equipModel)
        end
    end)
end

-- Monitor for Spirit Box responses
local function checkSpiritBox(spiritBox)
    if not table.find(evidenceFound, "Spirit Box") then
        local main = spiritBox:FindFirstChild("Main")
        if main then
            -- Check if there are any SurfaceGuis besides Template
            for _, child in ipairs(main:GetDescendants()) do
                if child:IsA("SurfaceGui") and child.Name ~= "Template" then
                    table.insert(evidenceFound, "Spirit Box")
                    -- Update first available label
                    if evidenceLabel_1:GetText() == "N/A" then
                        evidenceLabel_1:SetText("Spirit Box")
                    elseif evidenceLabel_2:GetText() == "N/A" then
                        evidenceLabel_2:SetText("Spirit Box")
                    elseif evidenceLabel_3:GetText() == "N/A" then
                        evidenceLabel_3:SetText("Spirit Box")
                    end
                    break
                end
            end
        end
    end
end

local function setupSpiritBoxMonitoring(spiritBox)
    if spiritBox then
        -- Check initial state
        checkSpiritBox(spiritBox)
        
        -- Monitor for new SurfaceGuis
        local main = spiritBox:FindFirstChild("Main")
        if main then
            main.DescendantAdded:Connect(function(child)
                if child:IsA("SurfaceGui") then
                    checkSpiritBox(spiritBox)
                end
            end)
        end
    end
end

-- Monitor Equipment folder and all players for Spirit Boxes
local function monitorAllSpiritBoxes()
    -- Check workspace Equipment
    workspace.Equipment.ChildAdded:Connect(function(child)
        if child.Name == "Spirit Box" then
            setupSpiritBoxMonitoring(child)
        end
    end)
    
    -- Check existing Spirit Box in workspace
    local equipmentSpiritBox = workspace.Equipment:FindFirstChild("Spirit Box")
    if equipmentSpiritBox then
        setupSpiritBoxMonitoring(equipmentSpiritBox)
    end
    
    -- Monitor all EquipmentModels in workspace
    local function checkEquipmentModel(model)
        if model then
            -- Monitor for new Spirit Boxes
            model.ChildAdded:Connect(function(child)
                if child.Name == "Spirit Box" then
                    setupSpiritBoxMonitoring(child)
                end
            end)
            
            -- Check existing Spirit Box
            local spiritBox = model:FindFirstChild("Spirit Box")
            if spiritBox then
                setupSpiritBoxMonitoring(spiritBox)
            end
        end
    end
    
    -- Check all existing EquipmentModels
    for _, obj in ipairs(workspace:GetChildren()) do
        local equipModel = obj:FindFirstChild("EquipmentModel")
        if equipModel then
            checkEquipmentModel(equipModel)
        end
    end
    
    -- Monitor for new EquipmentModels
    workspace.ChildAdded:Connect(function(child)
        local equipModel = child:FindFirstChild("EquipmentModel")
        if equipModel then
            checkEquipmentModel(equipModel)
        end
    end)
end

-- Start monitoring
monitorAllThermometers()
monitorAllSpiritBoxes()

-- Players Information
local Players = window:CreateCategory("Sanity")

local playerLabels = {}

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
            end)
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
    end
end)