# Purple Haze UI Library Documentation

A clean and modern UI library for Roblox with support for multiple window elements and customization options.

## Basic Usage

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/purple-haze-ui.lua"))()

local Window = Library:CreateWindow({
    WindowName = "Example Window",
    Color = Color3.fromRGB(11, 88, 11)
}, game:GetService("CoreGui"))

local Tab = Window:CreateTab("Main")
local Section = Tab:CreateSection("General")
```

## Window Methods

### CreateWindow(config, parent)
Creates a new window instance.

```lua
local Window = Library:CreateWindow({
    WindowName = "My Window",
    Color = Color3.fromRGB(255, 0, 0)
}, game:GetService("CoreGui"))
```

#### Window Methods
- `Window:Toggle(bool)` - Shows/hides the window
- `Window:ChangeColor(Color3)` - Changes the UI accent color
- `Window:SetBackground(imageId)` - Sets background image
- `Window:SetBackgroundColor(Color3)` - Sets background color
- `Window:SetBackgroundTransparency(number)` - Sets background transparency
- `Window:SetTileOffset(number)` - Sets background tile offset
- `Window:SetTileScale(number)` - Sets background tile scale

## Tab Methods

### CreateTab(name)
Creates a new tab in the window.

```lua
local Tab = Window:CreateTab("Settings")
```

### CreateSection(name) 
Creates a new section in the tab.

```lua
local Section = Tab:CreateSection("Configuration")
```

## Section Elements

### CreateButton(name, callback)
Creates a clickable button.

```lua
local Button = Section:CreateButton("Click Me", function()
    print("Button clicked!")
end)

-- Add tooltip
Button:AddToolTip("This is a helpful tooltip")
```

### CreateToggle(name, default, callback)
Creates a toggle switch.

```lua
local Toggle = Section:CreateToggle("Enable Feature", false, function(Value)
    print("Toggle state:", Value)
end)

-- Add keybind
local Keybind = Toggle:CreateKeybind("F", function(Key)
    print("Keybind pressed:", Key)
end)

-- Get/Set state
Toggle:SetState(true)
local state = Toggle:GetState()
```

### CreateSlider(name, min, max, default, precise, callback)
Creates a slider for number input.

```lua
local Slider = Section:CreateSlider("Speed", 0, 100, 50, true, function(Value)
    print("Slider value:", Value)
end)

-- Get/Set value
Slider:SetValue(75)
local value = Slider:GetValue()
```

### CreateDropdown(name, options, callback, default)
Creates a dropdown selection menu.

```lua
local Dropdown = Section:CreateDropdown("Select Option", {
    "Option 1",
    "Option 2",
    "Option 3"
}, function(Selected)
    print("Selected:", Selected)
end, "Option 1")

-- Modify options
Dropdown:RemoveOption("Option 1")
Dropdown:ClearOptions()
Dropdown:SetOption("Option 2")
local selected = Dropdown:GetOption()
```

### CreateColorpicker(name, callback)
Creates a color picker.

```lua
local Colorpicker = Section:CreateColorpicker("Choose Color", function(Color)
    print("Selected color:", Color)
end)

-- Update color
Colorpicker:UpdateColor(Color3.fromRGB(255, 0, 0))
```

### CreateTextBox(name, placeholder, numbersOnly, callback)
Creates a text input box.

```lua
local TextBox = Section:CreateTextBox("Input", "Enter text...", false, function(Text)
    print("Input text:", Text)
end)

-- Set value
TextBox:SetValue("New text")
```

### CreateLabel(name)
Creates a text label.

```lua
local Label = Section:CreateLabel("Information")

-- Update text
Label:UpdateText("New information")
```

## Tooltips
Most elements support tooltips through the AddToolTip method:

```lua
Element:AddToolTip("Helpful information about this element")
```

## Example Implementation

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/purple-haze-ui.lua"))()

local Window = Library:CreateWindow({
    WindowName = "Example UI",
    Color = Color3.fromRGB(11, 88, 11)
}, game:GetService("CoreGui"))

local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")

local MainSection = MainTab:CreateSection("Features")
local ConfigSection = SettingsTab:CreateSection("Configuration")

-- Create various elements
MainSection:CreateToggle("Enable Feature", false, function(Value)
    print("Feature enabled:", Value)
end):AddToolTip("Enables the main feature")

MainSection:CreateSlider("Speed", 0, 100, 50, true, function(Value)
    print("Speed set to:", Value)
end)

ConfigSection:CreateColorpicker("UI Color", function(Color)
    Window:ChangeColor(Color)
end)

ConfigSection:CreateDropdown("Theme", {
    "Default",
    "Dark",
    "Light"
}, function(Theme)
    print("Selected theme:", Theme)
end, "Default")
```