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

-- ESP Toggles
ESP:CreateToggle({
    text = "ESP",
    default = false,
    callback = function(value)
        ESPLibrary:Toggle(value)
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
local function checkMotion(sensorField)
    if not table.find(evidenceFound, "Motion") then
        for _, part in ipairs(sensorField:GetChildren()) do
            if part:IsA("Part") and part.Color ~= Color3.fromRGB(255, 255, 255) then
                table.insert(evidenceFound, "Motion")
                -- Update first available label
                if evidenceLabel_1:GetText() == "N/A" then
                    evidenceLabel_1:SetText("Motion")
                elseif evidenceLabel_2:GetText() == "N/A" then
                    evidenceLabel_2:SetText("Motion")
                elseif evidenceLabel_3:GetText() == "N/A" then
                    evidenceLabel_3:SetText("Motion")
                end
                break
            end
        end
    end
end

workspace.Dynamic.Evidence.MotionGrids.ChildAdded:Connect(function(child)
    if child.Name == "SensorField" then
        -- Check initial state
        checkMotion(child)
        
        -- Monitor for color changes
        child.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("Part") then
                descendant:GetPropertyChangedSignal("Color"):Connect(function()
                    checkMotion(child)
                end)
            end
        end)
    end
end)

-- Monitor for freezing temperatures
local function checkThermometer(thermometer)
    if not table.find(evidenceFound, "Freezing") then
        local tempLabel = thermometer:FindFirstChild("Temp")
        if tempLabel and tempLabel:FindFirstChild("SurfaceGui") then
            local textLabel = tempLabel.SurfaceGui:FindFirstChild("TextLabel")
            -- Check for actual negative number, not just dashes
            if textLabel and string.match(textLabel.Text, "^%-[0-9]") then
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
        if main and main:FindFirstChild("Template") then
            local message = main.Template:FindFirstChild("Message")
            if message and message.Text ~= "" then
                table.insert(evidenceFound, "Spirit Box")
                -- Update first available label
                if evidenceLabel_1:GetText() == "N/A" then
                    evidenceLabel_1:SetText("Spirit Box")
                elseif evidenceLabel_2:GetText() == "N/A" then
                    evidenceLabel_2:SetText("Spirit Box")
                elseif evidenceLabel_3:GetText() == "N/A" then
                    evidenceLabel_3:SetText("Spirit Box")
                end
            end
        end
    end
end

local function setupSpiritBoxMonitoring(spiritBox)
    if spiritBox then
        -- Check initial state
        checkSpiritBox(spiritBox)
        
        -- Monitor for message changes
        local main = spiritBox:FindFirstChild("Main")
        if main and main:FindFirstChild("Template") then
            local message = main.Template:FindFirstChild("Message")
            if message then
                message:GetPropertyChangedSignal("Text"):Connect(function()
                    checkSpiritBox(spiritBox)
                end)
            end
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