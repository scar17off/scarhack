local UI = {}
local UserInputService = game:GetService("UserInputService")

-- Flux UI Library (it's literally from a minecraft hacked client)

function UI.CreateWindow()
    local Window = {}
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local categoryCount = 0
    local categories = {}
    
    function Window:CreateCategory(name)
        local Category = {}
        categoryCount = categoryCount + 1
        
        local CategoryFrame = Instance.new("Frame")
        CategoryFrame.Name = name
        CategoryFrame.Parent = ScreenGui
        CategoryFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        CategoryFrame.BackgroundTransparency = 0.2
        CategoryFrame.BorderSizePixel = 0
        CategoryFrame.Size = UDim2.new(0, 120, 0, 25)
        CategoryFrame.Position = UDim2.new(0, (categoryCount-1) * 125, 0, 50)
        CategoryFrame.AutomaticSize = Enum.AutomaticSize.Y
        
        local CategoryHeader = Instance.new("TextButton")
        CategoryHeader.Name = "Header"
        CategoryHeader.Parent = CategoryFrame
        CategoryHeader.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        CategoryHeader.BorderSizePixel = 0
        CategoryHeader.Size = UDim2.new(1, 0, 0, 25)
        CategoryHeader.Font = Enum.Font.SourceSans
        CategoryHeader.Text = name
        CategoryHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
        CategoryHeader.TextSize = 14
        
        local ModuleHolder = Instance.new("Frame")
        ModuleHolder.Name = "ModuleHolder"
        ModuleHolder.Parent = CategoryFrame
        ModuleHolder.BackgroundTransparency = 1
        ModuleHolder.Position = UDim2.new(0, 0, 0, 25)
        ModuleHolder.Size = UDim2.new(1, 0, 0, 0)
        ModuleHolder.AutomaticSize = Enum.AutomaticSize.Y
        ModuleHolder.BorderSizePixel = 0
        
        -- Make category draggable
        local dragging, dragInput, dragStart, startPos
        
        CategoryHeader.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = CategoryFrame.Position
            end
        end)
        
        CategoryHeader.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                CategoryFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        function Category:CreateToggle(toggleConfig)
            local Toggle = {}
            local enabled = toggleConfig.default or false
            local settingsOpen = false
            
            local ToggleButton = Instance.new("TextButton")
            local SettingsHolder = Instance.new("Frame")
            
            ToggleButton.Name = toggleConfig.text
            ToggleButton.Parent = ModuleHolder
            ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ToggleButton.BackgroundTransparency = 0.3
            ToggleButton.Size = UDim2.new(1, 0, 0, 20)
            local buttonCount = 0
            for _, child in pairs(ModuleHolder:GetChildren()) do
                if child:IsA("TextButton") then
                    buttonCount = buttonCount + 1
                end
            end
            ToggleButton.Position = UDim2.new(0, 0, 0, (buttonCount - 1) * 20)
            ToggleButton.Font = Enum.Font.SourceSans
            ToggleButton.Text = toggleConfig.text
            ToggleButton.TextColor3 = enabled and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(200, 200, 200)
            ToggleButton.TextSize = 14
            ToggleButton.TextXAlignment = Enum.TextXAlignment.Center
            ToggleButton.BorderSizePixel = 0
            
            -- Settings holder
            SettingsHolder = Instance.new("Frame")
            SettingsHolder.Name = "Settings_" .. toggleConfig.text
            SettingsHolder.Parent = ModuleHolder
            SettingsHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            SettingsHolder.BorderSizePixel = 0
            SettingsHolder.Size = UDim2.new(1, 0, 0, 0)
            SettingsHolder.Visible = false
            SettingsHolder.ZIndex = 2
            
            -- Hover effect
            ToggleButton.MouseEnter:Connect(function()
                ToggleButton.BackgroundTransparency = 0.1
            end)
            
            ToggleButton.MouseLeave:Connect(function()
                ToggleButton.BackgroundTransparency = 0.3
            end)
            
            -- Left click to toggle
            ToggleButton.MouseButton1Click:Connect(function()
                enabled = not enabled
                ToggleButton.TextColor3 = enabled and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(200, 200, 200)
                ToggleButton.BackgroundColor3 = enabled and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30, 30, 30)
                if toggleConfig.callback then
                    toggleConfig.callback(enabled)
                end
            end)
            
            -- Right click to toggle settings
            ToggleButton.MouseButton2Click:Connect(function()
                settingsOpen = not settingsOpen
                SettingsHolder.Visible = settingsOpen
                
                -- Calculate the height of settings (remove extra spacing)
                local settingsHeight = 0
                for _, child in pairs(SettingsHolder:GetChildren()) do
                    if child:IsA("Frame") then  -- Count only the actual setting holders
                        settingsHeight = settingsHeight + child.Size.Y.Offset
                        -- Position each settings element directly after the previous one
                        child.Position = UDim2.new(0, 0, 0, settingsHeight - child.Size.Y.Offset)
                    end
                end
                
                -- Update settings size
                SettingsHolder.Size = UDim2.new(1, 0, 0, settingsOpen and settingsHeight or 0)
                
                -- Update positions of all buttons and their settings
                local currentOffset = 0
                for _, child in pairs(ModuleHolder:GetChildren()) do
                    if child:IsA("TextButton") then
                        -- Position the button
                        child.Position = UDim2.new(0, 0, 0, currentOffset)
                        currentOffset = currentOffset + 20
                        
                        -- Find and position its settings holder
                        local settingsHolder = ModuleHolder:FindFirstChild("Settings_" .. child.Name)
                        if settingsHolder then
                            settingsHolder.Position = UDim2.new(0, 0, 0, currentOffset)
                            if settingsHolder.Visible then
                                currentOffset = currentOffset + settingsHolder.Size.Y.Offset
                            end
                        end
                    elseif child:IsA("TextLabel") then
                        child.Position = UDim2.new(0, 0, 0, currentOffset)
                        currentOffset = currentOffset + 20
                    end
                end
            end)
            
            function Toggle:AddSlider(sliderConfig)
                local SliderHolder = Instance.new("Frame")
                local SliderLabel = Instance.new("TextLabel")
                local SliderButton = Instance.new("TextButton")
                local SliderFill = Instance.new("Frame")
                local ValueLabel = Instance.new("TextLabel")
                
                SliderHolder.Name = sliderConfig.text
                SliderHolder.Parent = SettingsHolder
                SliderHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                SliderHolder.BorderSizePixel = 0
                SliderHolder.Size = UDim2.new(1, 0, 0, 35)
                SliderHolder.Position = UDim2.new(0, 0, 0, 0)
                SliderHolder.ZIndex = 3
                
                SliderLabel.Name = "Label"
                SliderLabel.Parent = SliderHolder
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Position = UDim2.new(0, 8, 0, 0)
                SliderLabel.Size = UDim2.new(1, -50, 0, 20)
                SliderLabel.Font = Enum.Font.SourceSans
                SliderLabel.Text = sliderConfig.text
                SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                SliderLabel.TextSize = 14
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.ZIndex = 3
                
                ValueLabel.Name = "Value"
                ValueLabel.Parent = SliderHolder
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Position = UDim2.new(1, -42, 0, 0)
                ValueLabel.Size = UDim2.new(0, 34, 0, 20)
                ValueLabel.Font = Enum.Font.SourceSans
                ValueLabel.Text = tostring(sliderConfig.default or 50)
                ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ValueLabel.TextSize = 14
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.ZIndex = 3
                
                SliderButton.Name = "SliderButton"
                SliderButton.Parent = SliderHolder
                SliderButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                SliderButton.BorderSizePixel = 0
                SliderButton.Position = UDim2.new(0, 8, 0, 25)
                SliderButton.Size = UDim2.new(1, -16, 0, 4)
                SliderButton.Text = ""
                SliderButton.AutoButtonColor = false
                SliderButton.ZIndex = 3
                
                SliderFill.Name = "Fill"
                SliderFill.Parent = SliderButton
                SliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
                SliderFill.ZIndex = 3
                
                local min = sliderConfig.min or 0
                local max = sliderConfig.max or 100
                local current = sliderConfig.default or 50
                local defaultValue = sliderConfig.defaultValue or current
                
                local function updateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderButton.AbsolutePosition.X) / SliderButton.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pos)
                    current = value
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                    if sliderConfig.callback and enabled then
                        sliderConfig.callback(value)
                    end
                end
                
                -- Update the toggle callback to handle value changes
                local originalCallback = toggleConfig.callback
                toggleConfig.callback = function(state)
                    enabled = state
                    if state then
                        if sliderConfig.callback then
                            sliderConfig.callback(current)
                        end
                    else
                        if sliderConfig.onDisable then
                            sliderConfig.onDisable(defaultValue)
                        end
                    end
                    if originalCallback then
                        originalCallback(state)
                    end
                end
                
                SliderButton.MouseButton1Down:Connect(function()
                    local connection
                    connection = UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            updateSlider(input)
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if connection then
                                connection:Disconnect()
                            end
                        end
                    end)
                end)
            end
            
            function Toggle:AddToggle(toggleConfig)
                local SubToggleHolder = Instance.new("Frame")
                local SubToggleButton = Instance.new("TextButton")
                local SubToggleLabel = Instance.new("TextLabel")
                
                SubToggleHolder.Name = toggleConfig.text
                SubToggleHolder.Parent = SettingsHolder
                SubToggleHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                SubToggleHolder.BorderSizePixel = 0
                SubToggleHolder.Size = UDim2.new(1, 0, 0, 35)
                SubToggleHolder.Position = UDim2.new(0, 0, 0, #SettingsHolder:GetChildren() * 35)
                SubToggleHolder.ZIndex = 3
                
                SubToggleLabel.Name = "Label"
                SubToggleLabel.Parent = SubToggleHolder
                SubToggleLabel.BackgroundTransparency = 1
                SubToggleLabel.Position = UDim2.new(0, 8, 0, 0)
                SubToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                SubToggleLabel.Font = Enum.Font.SourceSans
                SubToggleLabel.Text = toggleConfig.text
                SubToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                SubToggleLabel.TextSize = 14
                SubToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                SubToggleLabel.ZIndex = 3
                
                SubToggleButton.Name = "Toggle"
                SubToggleButton.Parent = SubToggleHolder
                SubToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                SubToggleButton.BorderSizePixel = 0
                SubToggleButton.Position = UDim2.new(1, -42, 0.5, -10)
                SubToggleButton.Size = UDim2.new(0, 34, 0, 20)
                SubToggleButton.Font = Enum.Font.SourceSans
                SubToggleButton.Text = ""
                SubToggleButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                SubToggleButton.TextSize = 14
                SubToggleButton.ZIndex = 3
                
                local subEnabled = toggleConfig.default or false
                local defaultValue = toggleConfig.defaultValue
                
                SubToggleButton.MouseButton1Click:Connect(function()
                    subEnabled = not subEnabled
                    SubToggleButton.BackgroundColor3 = subEnabled and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(40, 40, 40)
                    if toggleConfig.callback and enabled then
                        toggleConfig.callback(subEnabled)
                    end
                end)
                
                -- Update the main toggle callback to handle sub-toggle state
                local originalCallback = toggleConfig.callback
                toggleConfig.callback = function(state)
                    if state and subEnabled and originalCallback then
                        originalCallback(subEnabled)
                    elseif not state and toggleConfig.onDisable then
                        toggleConfig.onDisable(defaultValue)
                    end
                end
            end
            
            function Toggle:AddTextbox(textboxConfig)
                local TextboxHolder = Instance.new("Frame")
                local TextboxLabel = Instance.new("TextLabel")
                local TextboxInput = Instance.new("TextBox")
                
                TextboxHolder.Name = textboxConfig.text
                TextboxHolder.Parent = SettingsHolder
                TextboxHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                TextboxHolder.BorderSizePixel = 0
                TextboxHolder.Size = UDim2.new(1, 0, 0, 40)
                TextboxHolder.ZIndex = 3
                
                TextboxLabel.Name = "Label"
                TextboxLabel.Parent = TextboxHolder
                TextboxLabel.BackgroundTransparency = 1
                TextboxLabel.Position = UDim2.new(0, 8, 0, 0)
                TextboxLabel.Size = UDim2.new(1, -16, 0, 20)
                TextboxLabel.Font = Enum.Font.SourceSans
                TextboxLabel.Text = textboxConfig.text
                TextboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                TextboxLabel.TextSize = 14
                TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextboxLabel.ZIndex = 3
                
                TextboxInput.Name = "Input"
                TextboxInput.Parent = TextboxHolder
                TextboxInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                TextboxInput.BorderSizePixel = 0
                TextboxInput.Position = UDim2.new(0, 8, 0, 20)
                TextboxInput.Size = UDim2.new(1, -16, 0, 16)
                TextboxInput.Font = Enum.Font.SourceSans
                TextboxInput.PlaceholderText = textboxConfig.placeholder or ""
                TextboxInput.Text = textboxConfig.default or ""
                TextboxInput.TextColor3 = Color3.fromRGB(200, 200, 200)
                TextboxInput.TextSize = 14
                TextboxInput.ClearTextOnFocus = textboxConfig.clearOnFocus ~= false
                TextboxInput.ZIndex = 3

                -- Handle text input
                TextboxInput.FocusLost:Connect(function(enterPressed)
                    if textboxConfig.callback and enabled then
                        textboxConfig.callback(TextboxInput.Text, enterPressed)
                    end
                end)

                -- Update the main toggle callback to handle textbox state
                local originalCallback = toggleConfig.callback
                toggleConfig.callback = function(state)
                    enabled = state
                    if state then
                        if textboxConfig.callback then
                            textboxConfig.callback(TextboxInput.Text, false)
                        end
                    else
                        if textboxConfig.onDisable then
                            textboxConfig.onDisable(textboxConfig.default or "")
                        end
                    end
                    if originalCallback then
                        originalCallback(state)
                    end
                end
            end
            
            return Toggle
        end
        
        function Category:CreateButton(buttonConfig)
            local Button = {}
            
            local ButtonInstance = Instance.new("TextButton")
            ButtonInstance.Name = buttonConfig.text
            ButtonInstance.Parent = ModuleHolder
            ButtonInstance.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ButtonInstance.BackgroundTransparency = 0.3
            ButtonInstance.Size = UDim2.new(1, 0, 0, 20)
            
            -- Position based on number of existing buttons
            local buttonCount = 0
            for _, child in pairs(ModuleHolder:GetChildren()) do
                if child:IsA("TextButton") then
                    buttonCount = buttonCount + 1
                end
            end
            ButtonInstance.Position = UDim2.new(0, 0, 0, (buttonCount - 1) * 20)
            
            ButtonInstance.Font = Enum.Font.SourceSans
            ButtonInstance.Text = buttonConfig.text
            ButtonInstance.TextColor3 = Color3.fromRGB(200, 200, 200)
            ButtonInstance.TextSize = 14
            ButtonInstance.TextXAlignment = Enum.TextXAlignment.Center
            ButtonInstance.BorderSizePixel = 0
            
            -- Hover effect
            ButtonInstance.MouseEnter:Connect(function()
                ButtonInstance.BackgroundTransparency = 0.1
            end)
            
            ButtonInstance.MouseLeave:Connect(function()
                ButtonInstance.BackgroundTransparency = 0.3
            end)
            
            -- Click effect
            ButtonInstance.MouseButton1Click:Connect(function()
                if buttonConfig.callback then
                    buttonConfig.callback()
                end
                ButtonInstance.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
                wait(0.1)
                ButtonInstance.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            end)
            
            return Button
        end
        
        function Category:CreateLabel(text)
            local Label = {}
            
            local LabelInstance = Instance.new("TextLabel")
            LabelInstance.Name = text
            LabelInstance.Parent = ModuleHolder
            LabelInstance.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            LabelInstance.BackgroundTransparency = 0.3
            LabelInstance.Size = UDim2.new(1, 0, 0, 20)
            
            -- Position based on number of existing elements
            local elementCount = 0
            for _, child in pairs(ModuleHolder:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    elementCount = elementCount + 1
                end
            end
            LabelInstance.Position = UDim2.new(0, 0, 0, (elementCount - 1) * 20)
            
            LabelInstance.Font = Enum.Font.SourceSans
            LabelInstance.Text = text
            LabelInstance.TextColor3 = Color3.fromRGB(200, 200, 200)
            LabelInstance.TextSize = 14
            LabelInstance.TextXAlignment = Enum.TextXAlignment.Center
            LabelInstance.BorderSizePixel = 0
            
            function Label:SetText(newText)
                LabelInstance.Text = newText
            end
            
            function Label:GetText()
                return LabelInstance.Text
            end
            
            return Label
        end
        
        function Category:CreateTextbox(textboxConfig)
            local TextboxHolder = Instance.new("Frame")
            local TextboxLabel = Instance.new("TextLabel")
            local TextboxInput = Instance.new("TextBox")
            
            TextboxHolder.Name = textboxConfig.text
            TextboxHolder.Parent = ModuleHolder
            TextboxHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            TextboxHolder.BackgroundTransparency = 0.3
            TextboxHolder.Size = UDim2.new(1, 0, 0, 40)
            
            -- Position based on number of existing elements
            local elementCount = 0
            for _, child in pairs(ModuleHolder:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                    elementCount = elementCount + 1
                end
            end
            TextboxHolder.Position = UDim2.new(0, 0, 0, (elementCount - 1) * 20)
            TextboxHolder.BorderSizePixel = 0
            
            TextboxLabel.Name = "Label"
            TextboxLabel.Parent = TextboxHolder
            TextboxLabel.BackgroundTransparency = 1
            TextboxLabel.Position = UDim2.new(0, 8, 0, 0)
            TextboxLabel.Size = UDim2.new(1, -16, 0, 20)
            TextboxLabel.Font = Enum.Font.SourceSans
            TextboxLabel.Text = textboxConfig.text
            TextboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            TextboxLabel.TextSize = 14
            TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            TextboxInput.Name = "Input"
            TextboxInput.Parent = TextboxHolder
            TextboxInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            TextboxInput.BorderSizePixel = 0
            TextboxInput.Position = UDim2.new(0, 8, 0, 20)
            TextboxInput.Size = UDim2.new(1, -16, 0, 16)
            TextboxInput.Font = Enum.Font.SourceSans
            TextboxInput.PlaceholderText = textboxConfig.placeholder or ""
            TextboxInput.Text = textboxConfig.default or ""
            TextboxInput.TextColor3 = Color3.fromRGB(200, 200, 200)
            TextboxInput.TextSize = 14
            TextboxInput.ClearTextOnFocus = textboxConfig.clearOnFocus ~= false
            
            -- Handle text input
            TextboxInput.FocusLost:Connect(function(enterPressed)
                if textboxConfig.callback then
                    textboxConfig.callback(TextboxInput.Text, enterPressed)
                end
            end)
            
            -- Hover effect
            TextboxHolder.MouseEnter:Connect(function()
                TextboxHolder.BackgroundTransparency = 0.1
            end)
            
            TextboxHolder.MouseLeave:Connect(function()
                TextboxHolder.BackgroundTransparency = 0.3
            end)
            
            return TextboxInput
        end
        
        table.insert(categories, Category)
        return Category
    end
    
    return Window
end

return UI

-- Example usage:
--[[
local window = UI.CreateWindow()
local movement = window:CreateCategory("Movement")

local speedToggle = movement:CreateToggle({
    text = "Speed"
})

speedToggle:AddSlider({
    text = "Walkspeed",
    min = 16,
    max = 150,
    default = 16,
    defaultValue = 16, -- Default walk speed
    callback = function(value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end,
    onDisable = function(defaultValue)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = defaultValue
        end
    end
})
--]]