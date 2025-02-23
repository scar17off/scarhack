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
local evidenceLabel_1 = Evidences:CreateLabel({
    text = "N/A"
})
local evidenceLabel_2 = Evidences:CreateLabel({
    text = "N/A"
})
local evidenceLabel_3 = Evidences:CreateLabel({
    text = "N/A"
})

-- Monitor for new evidence and update labels
local evidenceFound = {}

workspace.Dynamic.Evidence.DescendantAdded:Connect(function(obj)
    if obj.Name == "EMF" and obj.Value == 5 then
        if not table.find(evidenceFound, "EMF 5") then
            table.insert(evidenceFound, "EMF 5")
            -- Update first available label
            if evidenceLabel_1.Text == "N/A" then
                evidenceLabel_1:SetText("EMF 5")
            elseif evidenceLabel_2.Text == "N/A" then
                evidenceLabel_2:SetText("EMF 5")
            elseif evidenceLabel_3.Text == "N/A" then
                evidenceLabel_3:SetText("EMF 5")
            end
        end
    elseif obj.Name == "Fingerprints" then
        if not table.find(evidenceFound, "Fingerprint") then
            table.insert(evidenceFound, "Fingerprint")
            -- Update first available label
            if evidenceLabel_1.Text == "N/A" then
                evidenceLabel_1:SetText("Fingerprints")
            elseif evidenceLabel_2.Text == "N/A" then
                evidenceLabel_2:SetText("Fingerprints")
            elseif evidenceLabel_3.Text == "N/A" then
                evidenceLabel_3:SetText("Fingerprints")
            end
        end
    elseif obj.Name == "Orbs" then
        if not table.find(evidenceFound, "Orb") then
            table.insert(evidenceFound, "Orb")
            -- Update first available label
            if evidenceLabel_1.Text == "N/A" then
                evidenceLabel_1:SetText("Orb")
            elseif evidenceLabel_2.Text == "N/A" then
                evidenceLabel_2:SetText("Orb")
            elseif evidenceLabel_3.Text == "N/A" then
                evidenceLabel_3:SetText("Orb")
            end
        end
    end
end)

-- Monitor for book writing sounds
local bookSounds = SoundService.Sounds.BookWrite

local function checkBookWriting()
    if not table.find(evidenceFound, "Book Writing") then
        table.insert(evidenceFound, "Book Writing")
        -- Update first available label
        if evidenceLabel_1.Text == "N/A" then
            evidenceLabel_1:SetText("Book Writing")
        elseif evidenceLabel_2.Text == "N/A" then
            evidenceLabel_2:SetText("Book Writing")
        elseif evidenceLabel_3.Text == "N/A" then
            evidenceLabel_3:SetText("Book Writing")
        end
    end
end

for _, sound in ipairs(bookSounds:GetChildren()) do
    sound:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        if sound.IsPlaying then
            checkBookWriting()
        end
    end)
end