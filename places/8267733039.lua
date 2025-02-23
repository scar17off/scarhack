local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- Shortcuts
local SoundService = game:GetService("SoundService")

-- Categories
local ESP = window:CreateCategory("ESP")
local Evidences = window:CreateCategory("Evidences")

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
    if not table.find(evidenceFound, "Fingerprint") then
        table.insert(evidenceFound, "Fingerprint")
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