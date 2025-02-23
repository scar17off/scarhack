local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- Categories
local ESP = window:CreateCategory("ESP")

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