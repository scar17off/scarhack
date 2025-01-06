# ESP Library Documentation

A powerful and flexible ESP (Extra Sensory Perception) library for Roblox that allows you to create visual indicators for objects in the game world.

## Features

- Box ESP
- Name Tags
- Distance Display
- Team Colors
- Tracers
- Glow/Highlight Effect
- Custom Components
- Object Listening

## Basic Usage

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ESP.md"))()

-- Toggle ESP
ESP.Enabled = true

-- Configure basic settings
ESP.Boxes = true
ESP.Names = true
ESP.TeamColor = true
ESP.Tracers = false
```

## Settings

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Enabled | boolean | false | Master toggle for ESP |
| Boxes | boolean | true | Toggle box drawing |
| Names | boolean | true | Toggle name tags |
| TeamColor | boolean | true | Use team colors |
| Tracers | boolean | false | Toggle tracers |
| Glow | boolean | false | Toggle glow effect |
| TeamMates | boolean | true | Show ESP for teammates |

## Methods

### ESP:Add(object, options)

Add an object to the ESP system.

```lua
ESP:Add(workspace.Enemy, {
    Name = "Enemy",
    Color = Color3.fromRGB(255, 0, 0),
    Size = Vector3.new(4, 6, 0)
})
```

### ESP:AddObjectListener(parent, options)

Listen for objects being added to a parent and automatically apply ESP.

```lua
-- Basic example: Track all humanoid models
ESP:AddObjectListener(workspace, {
    Type = "Model",
    Validator = function(obj)
        return obj:FindFirstChild("Humanoid")
    end,
    CustomName = function(obj)
        return obj.Name .. " [NPC]"
    end,
    Color = Color3.fromRGB(255, 0, 0)
})

-- Advanced example: Track items with custom properties
ESP:AddObjectListener(workspace.Items, {
    Type = "Model",
    CustomName = function(obj) 
        return obj:GetAttribute("DisplayName") 
    end,
    CustomProperties = {
        Rarity = function(obj)
            return obj:GetAttribute("Rarity")
        end,
        Distance = true
    },
    Color = function(obj)
        local rarity = obj:GetAttribute("Rarity")
        if rarity == "Legendary" then
            return Color3.fromRGB(255, 215, 0)
        end
        return Color3.fromRGB(255, 255, 255)
    end
})
```

### ESP:GetBox(object)

Get the ESP box instance for an object.

```lua
local box = ESP:GetBox(workspace.Enemy)
if box then
    box.Color = Color3.fromRGB(255, 0, 0)
end
```

### ESP:Toggle(boolean)

Toggle the entire ESP system.

```lua
ESP:Toggle(true)  -- Enable
ESP:Toggle(false) -- Disable
```

## Advanced Usage

### Custom Components

You can add custom components to ESP boxes:

```lua
ESP:AddObjectListener(workspace.Enemies, {
    Type = "Model",
    Components = {
        HealthBar = {
            Type = "Square",
            Color = Color3.fromRGB(0, 255, 0),
            Thickness = 2,
            Filled = true
        },
        Level = {
            Type = "Text",
            Color = Color3.fromRGB(255, 255, 255),
            Size = 18
        }
    }
})
```

### Team Override

You can override the team detection:

```lua
ESP.Overrides.IsTeamMate = function(player)
    return player.Team.Name == "Defenders"
end
```

### Custom Colors

```lua
ESP.Overrides.GetColor = function(object)
    local player = ESP:GetPlrFromChar(object)
    if player then
        if player.Team.Name == "Red" then
            return Color3.fromRGB(255, 0, 0)
        else
            return Color3.fromRGB(0, 0, 255)
        end
    end
    return ESP.Color
end
```

## Tips & Best Practices

1. Always clean up ESP boxes when objects are removed:
```lua
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
```
2. Use `ColorDynamic` for objects that need color updates
3. Implement proper validation in object listeners
4. Consider performance when adding many ESP objects
5. Use custom properties sparingly

## Common Issues

1. **ESP not showing:**
   - Check if `ESP.Enabled` is true
   - Verify object has proper PrimaryPart
   - Check if object is within render distance

2. **Performance Issues:**
   - Reduce number of tracked objects
   - Simplify custom update functions
   - Use proper cleanup methods

3. **Objects not being tracked:**
   - Verify listener settings
   - Check validator functions
   - Ensure proper parent hierarchy