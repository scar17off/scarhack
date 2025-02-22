local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

-- Categories
local ESP = window:CreateCategory("ESP")

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
        ESPLibrary:Toggle(value)
    end
})