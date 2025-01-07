loadstring(game:HttpGet("https://raw.githubusercontent.com/Averiias/purple-haze-pf/main/ui/lib.lua"))()

local Window = library:CreateWindow({
    WindowName = "ScarHack",
    Color = Color3.fromRGB(11, 88, 11)
}, game:GetService("CoreGui"))

local AimbotTab = Window:CreateTab("Aimbot")
local VisualTab = Window:CreateTab("Visual")

local AimbotGeneral = AimbotTab:CreateSection("General")
local AimbotSettings = AimbotTab:CreateSection("Settings")

local PLAYER = game.Players.LocalPlayer
local MOUSE = PLAYER:GetMouse()
local CAMERA = game.Workspace.CurrentCamera
local ENABLED = false
local FREE_FOR_ALL = false
local AIM_TARGET = "Head"
local MAX_DISTANCE = 1000
local FOV_RADIUS = 360
local SMOOTHNESS = 1
local TEAM_CHECK = true
local VISIBLE_CHECK = true
local VirtualInputManager = game:GetService("VirtualInputManager")

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()

local ESP_ENABLED = false
local ESP_BOXES = false
local ESP_NAMES = false
local ESP_TRACERS = false
local ESP_TEAM_CHECK = true
local ESP_TEAM_COLOR = false
local ESP_GLOW = false
local ESP_GLOW_COLOR = Color3.fromRGB(255, 0, 0)
local ESP_GLOW_TRANSPARENCY = 0.5

local ESPSection = VisualTab:CreateSection("ESP")

local ESPToggle = ESPSection:CreateToggle("Enable ESP", false, function(Value)
    ESP_ENABLED = Value
    ESP:Toggle(Value)
    
    -- Clean up ESP objects when disabling
    if not Value then
        for _, v in pairs(ESP.Objects) do
            if v.Type == "Box" then
                v:Remove()
            end
        end
        -- Clear the objects table
        table.clear(ESP.Objects)
    end
end)

local BoxesToggle = ESPSection:CreateToggle("Boxes", false, function(Value)
    ESP_BOXES = Value
    ESP.Boxes = Value
end)

local NamesToggle = ESPSection:CreateToggle("Names", false, function(Value)
    ESP_NAMES = Value
    ESP.Names = Value
end)

local TracersToggle = ESPSection:CreateToggle("Tracers", false, function(Value)
    ESP_TRACERS = Value
    ESP.Tracers = Value
end)

local TeamCheckToggle = ESPSection:CreateToggle("Team Check", true, function(Value)
    ESP_TEAM_CHECK = Value
    ESP.TeamMates = not Value
end)

local TeamColorToggle = ESPSection:CreateToggle("Team Color", false, function(Value)
    ESP_TEAM_COLOR = Value
    ESP.TeamColor = Value
end)

local GlowToggle = ESPSection:CreateToggle("Glow", false, function(Value)
    ESP_GLOW = Value
    -- ESP.Glow = Value
end)

local GlowColorPicker = ESPSection:CreateColorpicker("Glow Color", Color3.fromRGB(255, 0, 0), function(Value)
    ESP_GLOW_COLOR = Value
    -- ESP.GlowColor = Value
end)

local GlowTransparencySlider = ESPSection:CreateSlider("Glow Transparency", 0, 1, 0.5, false, function(Value)
    ESP_GLOW_TRANSPARENCY = Value
    -- ESP.GlowTransparency = Value
end)

ESP.FaceCamera = true
ESP:Toggle(false)
ESP.Players = true

local DistanceToggle = ESPSection:CreateToggle("Show Distance", false, function(Value)
    ESP.Distance = Value
end)

local DistanceSlider = ESPSection:CreateSlider("Max Distance", 100, 2000, 1000, true, function(Value)
    ESP.MaxDistance = Value
end)

local TextSizeSlider = ESPSection:CreateSlider("Text Size", 8, 24, 14, true, function(Value)
    ESP.TextSize = Value
end)

local BoxTransparencySlider = ESPSection:CreateSlider("Box Transparency", 0, 1, 0.5, false, function(Value)
    ESP.BoxTransparency = Value
end)

local function IsPartVisible(part)

    local camera = game.Workspace.CurrentCamera
    if not camera then return false end

    local origin = camera.CFrame.Position
    local target = part.Position
    local vector = (target - origin)
    local ray = Ray.new(origin, vector)

    local ignoreList = {game.Players.LocalPlayer.Character}

    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

    if hit then
        if hit == part or hit:IsDescendantOf(part.Parent) then
            return true
        end
        return false
    end

    return true
end

local function GetClosestVisiblePart(character)
    local validParts = {
        "Head",
        "HumanoidRootPart",
        "Torso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg"
    }

    local closestPart = nil
    local closestDistance = math.huge

    for _, partName in ipairs(validParts) do
        local part = character:FindFirstChild(partName)
        if part then

            if IsPartVisible(part) then
                local screenPoint = CAMERA:WorldToScreenPoint(part.Position)
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(MOUSE.X, MOUSE.Y)).Magnitude

                if distance < closestDistance then
                    closestDistance = distance
                    closestPart = part
                end
            end
        end
    end

    return closestPart
end

local function GetClosestPlayerToMouse()
    local PLAYERS = {}
    local CLOSEST_PLAYER = nil
    local CLOSEST_DISTANCE = math.huge
    local CLOSEST_PART = nil

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= PLAYER then
            if not TEAM_CHECK or player.Team ~= PLAYER.Team then
                local character = player.Character
                if character then
                    local targetPart = nil

                    if AIM_TARGET == "Any" then
                        targetPart = GetClosestVisiblePart(character)
                    else
                        targetPart = character:FindFirstChild(AIM_TARGET)
                    end

                    if targetPart then
                        if not VISIBLE_CHECK or IsPartVisible(targetPart) then
                            local screenPoint = CAMERA:WorldToScreenPoint(targetPart.Position)
                            local mouseDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(MOUSE.X, MOUSE.Y)).Magnitude

                            if mouseDistance <= FOV_RADIUS then
                                if mouseDistance < CLOSEST_DISTANCE then
                                    CLOSEST_DISTANCE = mouseDistance
                                    CLOSEST_PLAYER = player
                                    CLOSEST_PART = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return CLOSEST_PLAYER, CLOSEST_PART
end

local AimbotToggle = AimbotGeneral:CreateToggle("Enable Aimbot", false, function(Value)
    ENABLED = Value
end)

local TeamCheckToggle = AimbotGeneral:CreateToggle("Team Check", true, function(Value)
    TEAM_CHECK = Value
end)

local VisibleCheckToggle = AimbotGeneral:CreateToggle("Visible Check", true, function(Value)
    VISIBLE_CHECK = Value
end)

local ShowFOVToggle = AimbotGeneral:CreateToggle("Show FOV", false, function(Value)
    FOVCircle.Visible = Value
end)

local FOVSlider = AimbotSettings:CreateSlider("FOV Radius", 0, 800, 360, true, function(Value)
    FOV_RADIUS = Value
    if FOVCircle then
        FOVCircle.Radius = Value
    end
end)

local SmoothnessSlider = AimbotSettings:CreateSlider("Smoothness", 1, 10, 1, true, function(Value)
    SMOOTHNESS = Value
end)

AimbotSettings:CreateDropdown("Target Part", {"Any", "Head", "HumanoidRootPart", "Torso"}, function(Option)
    AIM_TARGET = Option
end)

AimbotToggle:CreateKeybind("F")

game:GetService("RunService").RenderStepped:Connect(function()

    if FOVCircle then
        FOVCircle.Position = Vector2.new(MOUSE.X, MOUSE.Y + 36)
    end

    if ENABLED then
        local Target, TargetPart = GetClosestPlayerToMouse()
        if Target and TargetPart then
            local targetPos = CAMERA:WorldToScreenPoint(TargetPart.Position)
            local mousePos = Vector2.new(MOUSE.X, MOUSE.Y)
            local moveVector = Vector2.new(
                (targetPos.X - mousePos.X) / SMOOTHNESS,
                (targetPos.Y - mousePos.Y) / SMOOTHNESS
            )
            mousemoverel(moveVector.X, moveVector.Y)
        end
    end
end)

local UserInputService = game:GetService("UserInputService")

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end
end)

-- Cleanup when script is unloaded
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "ScarHack" then
        ESP:Toggle(false)
        for _, v in pairs(ESP.Objects) do
            if v.Type == "Box" then
                v:Remove()
            end
        end
        table.clear(ESP.Objects)
        
        -- Clean up drawings
        if FOVCircle then
            FOVCircle:Remove()
        end
    end
end)