# Flux UI Library Documentation

A lightweight UI library for Roblox that provides a clean and customizable interface with categories, toggles, sliders, and more.

## Basic Usage

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()
```

## Window Methods

### CreateCategory(name: string)
Creates a new draggable category in the window.
```lua
local category = window:CreateCategory("Movement")
```

## Category Methods

### CreateToggle(config: table)
Creates a toggle button with optional settings.
```lua
local toggle = category:CreateToggle({
    text = "Speed",
    default = false, -- Optional: default state
    callback = function(enabled)
        -- Called when toggle state changes
    end
})
```

### CreateButton(config: table)
Creates a clickable button.
```lua
category:CreateButton({
    text = "Click Me",
    callback = function()
        -- Called when button is clicked
    end
})
```

### CreateLabel(text: string)
Creates a static text label.
```lua
category:CreateLabel("Section Title")
```

### CreateTextbox(config: table)
Creates an input text box.
```lua
category:CreateTextbox({
    text = "Name",
    placeholder = "Enter text...",
    default = "", -- Optional: default value
    clearOnFocus = true, -- Optional: clear text when focused
    callback = function(text, enterPressed)
        -- Called when text is submitted
    end
})
```

## Toggle Methods

### AddSlider(config: table)
Adds a slider to a toggle's settings.
```lua
toggle:AddSlider({
    text = "Speed",
    min = 0,
    max = 100,
    default = 50,
    defaultValue = 50, -- Value to revert to when disabled
    callback = function(value)
        -- Called when slider value changes
    end,
    onDisable = function(defaultValue)
        -- Called when toggle is disabled
    end
})
```

### AddToggle(config: table)
Adds a sub-toggle to a toggle's settings.
```lua
toggle:AddToggle({
    text = "Sub Option",
    default = false,
    defaultValue = false, -- Value to revert to when disabled
    callback = function(enabled)
        -- Called when sub-toggle state changes
    end,
    onDisable = function(defaultValue)
        -- Called when main toggle is disabled
    end
})
```

### AddTextbox(config: table)
Adds a textbox to a toggle's settings.
```lua
toggle:AddTextbox({
    text = "Input",
    placeholder = "Enter value...",
    default = "",
    clearOnFocus = true,
    callback = function(text, enterPressed)
        -- Called when text is submitted
    end,
    onDisable = function(defaultValue)
        -- Called when toggle is disabled
    end
})
```

## Example Usage

```lua
local UI = require("ui-library")
local window = UI.CreateWindow()
local movement = window:CreateCategory("Movement")

-- Create a toggle with a slider
local speedToggle = movement:CreateToggle({
    text = "Speed"
})

speedToggle:AddSlider({
    text = "Walkspeed",
    min = 16,
    max = 150,
    default = 16,
    defaultValue = 16,
    callback = function(value)
        -- Handle speed change
    end,
    onDisable = function(defaultValue)
        -- Reset speed to default
    end
})

-- Create a button
movement:CreateButton({
    text = "Reset Position",
    callback = function()
        -- Handle button click
    end
})

-- Create a label
movement:CreateLabel("Settings")

-- Create a textbox
movement:CreateTextbox({
    text = "Player Name",
    placeholder = "Enter name...",
    callback = function(text)
        -- Handle text input
    end
})