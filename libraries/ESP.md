# ESP Library Documentation

A powerful and flexible ESP (Extra Sensory Perception) library for Roblox that allows you to create visual indicators for objects in the game world.

## Features

- Box ESP with customizable thickness and color
- Name Tags
- Distance Display
- Team Colors
- Tracers
- Health Bars
- Glow/Highlight Effect
- Object Listening
- Dynamic Color Updates

## Basic Usage
```lua
local ESP = loadstring(game:HttpGet("path/to/esp.lua"))()

-- Toggle ESP
ESP.Enabled = true

-- Configure basic settings
ESP.Boxes = true
ESP.Names = true
ESP.TeamColor = true
ESP.Tracers = false
ESP.Thickness = 2
```

## Settings

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Enabled | boolean | false | Master toggle for ESP |
| Boxes | boolean | true | Toggle box drawing |
| BoxShift | CFrame | CFrame.new(0,-1.5,0) | Offset for ESP boxes |
| BoxSize | Vector3 | Vector3.new(4,6,0) | Size of ESP boxes |
| Color | Color3 | RGB(255,170,0) | Default color when team colors disabled |
| DefaultColor | Color3 | RGB(255,255,255) | Fallback color |
| FaceCamera | boolean | false | Makes boxes face the camera |
| Names | boolean | false | Toggle name tags |
| TeamColor | boolean | false | Use team colors |
| TeamMates | boolean | true | Show ESP for teammates |
| Thickness | number | 2 | Line thickness for boxes and tracers |
| AttachShift | number | 1 | Tracer attachment point shift |
| MaxDistance | number | 1000 | Maximum render distance |
| Distance | boolean | false | Show distance indicators |
| Tracers | boolean | false | Show tracer lines |
| Health | table | {Enabled=false,...} | Health bar configuration |
| Glow | boolean | false | Toggle glow/highlight effect |
| GlowColor | Color3 | RGB(255,255,255) | Color for glow effect |
| GlowTeamColor | boolean | false | Use team colors for glow |
| GlowTransparency | number | 0.5 | Transparency of glow effect |

### Health Bar Settings
```lua
ESP.Health = {
    Enabled = true,
    Side = "Right", -- "Left", "Right", "Top", "Bottom"
    Width = 2,
    FaceCamera = false
}
```

## Methods

### ESP:Add(object, options)

Add an object to the ESP system.

```lua
ESP:Add(workspace.Enemy, {
    Name = "Enemy", -- Custom name to display
    Color = Color3.fromRGB(255, 0, 0), -- Custom color
    Size = Vector3.new(4, 6, 0), -- Custom box size
    PrimaryPart = part, -- Optional part to track
    IsEnabled = true, -- or function/property name
    ColorDynamic = function() -- Dynamic color function
        return Color3.fromRGB(255, 0, 0)
    end,
    RenderInNil = false -- Continue rendering if parent is nil
})
```

### ESP:AddObjectListener(parent, options)

Listen for objects being added to a parent and automatically apply ESP.

```lua
ESP:AddObjectListener(workspace, {
    Type = "Model", -- Instance type to look for
    Recursive = true, -- Check descendants
    PrimaryPart = "HumanoidRootPart", -- Part to track
    CustomName = function(obj)
        return obj.Name
    end,
    ColorDynamic = function(obj)
        return Color3.fromRGB(255, 0, 0)
    end,
    IsEnabled = "Enabled", -- Property name or function
    Validator = function(obj)
        return obj:FindFirstChild("Humanoid")
    end,
    OnAdded = function(box)
        -- Called when ESP is added to an object
    end
})
```

### ESP:GetBox(object)

Get the ESP box instance for an object.

```lua
local box = ESP:GetBox(workspace.Enemy)
if box then
    box:Remove() -- Remove ESP from object
end
```

### ESP:Toggle(boolean)

Toggle the entire ESP system.

```lua
ESP:Toggle(true)  -- Enable
ESP:Toggle(false) -- Disable
```

## Overrides

You can customize core ESP behavior through overrides:

```lua
-- Custom team detection
ESP.Overrides.IsTeamMate = function(player)
    return player.Team.Name == "Defenders"
end

-- Custom color logic
ESP.Overrides.GetColor = function(object)
    local player = ESP:GetPlrFromChar(object)
    if player then
        if player.Team.Name == "Red" then
            return Color3.fromRGB(255, 0, 0)
        end
    end
    return ESP.Color
end

-- Custom player detection
ESP.Overrides.GetPlrFromChar = function(char)
    -- Custom logic to get player from character
    return game:GetService("Players"):GetPlayerFromCharacter(char)
end
```