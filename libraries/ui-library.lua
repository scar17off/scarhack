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

                -- Calculate the height of settings and position each child correctly
                local settingsHeight = 0
                for _, child in pairs(SettingsHolder:GetChildren()) do
                    if child:IsA("Frame") then
                        child.Position = UDim2.new(0, 0, 0, settingsHeight)
                        settingsHeight = settingsHeight + child.Size.Y.Offset
                    end
                end

                -- Update settings size
                SettingsHolder.Size = UDim2.new(1, 0, 0, settingsOpen and settingsHeight or 0)

                -- Move all elements below this toggle down if settings are open
                local foundSelf = false
                local offset = 0
                for _, child in ipairs(ModuleHolder:GetChildren()) do
                    if child == ToggleButton then
                        foundSelf = true
                        child.Position = UDim2.new(0, 0, 0, offset)
                        offset = offset + child.Size.Y.Offset
                        -- Position settings holder right after the toggle
                        SettingsHolder.Position = UDim2.new(0, 0, 0, offset)
                        if SettingsHolder.Visible then
                            offset = offset + SettingsHolder.Size.Y.Offset
                        end
                    elseif foundSelf then
                        child.Position = UDim2.new(0, 0, 0, offset)
                        offset = offset + child.Size.Y.Offset
                        -- Also move their settings if open
                        local settingsHolder = ModuleHolder:FindFirstChild("Settings_" .. child.Name)
                        if settingsHolder and settingsHolder.Visible then
                            settingsHolder.Position = UDim2.new(0, 0, 0, offset)
                            offset = offset + settingsHolder.Size.Y.Offset
                        end
                    else
                        child.Position = UDim2.new(0, 0, 0, offset)
                        offset = offset + child.Size.Y.Offset
                        -- Also move their settings if open
                        local settingsHolder = ModuleHolder:FindFirstChild("Settings_" .. child.Name)
                        if settingsHolder and settingsHolder.Visible then
                            settingsHolder.Position = UDim2.new(0, 0, 0, offset)
                            offset = offset + settingsHolder.Size.Y.Offset
                        end
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
                
                local function updateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderButton.AbsolutePosition.X) / SliderButton.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pos)
                    current = value
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                    if sliderConfig.callback then
                        sliderConfig.callback(value)
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
            
            function Toggle:CreateKeybind(defaultKey, callback)
                local key = defaultKey or "F"
                local KeybindHolder = Instance.new("Frame")
                local KeybindLabel = Instance.new("TextLabel")
                local KeybindButton = Instance.new("TextButton")

                KeybindHolder.Name = "Keybind_" .. (toggleConfig.text or "")
                KeybindHolder.Parent = SettingsHolder
                KeybindHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                KeybindHolder.BorderSizePixel = 0
                KeybindHolder.Size = UDim2.new(1, 0, 0, 28)
                KeybindHolder.Position = UDim2.new(0, 0, 0, #SettingsHolder:GetChildren() * 28)
                KeybindHolder.ZIndex = 3

                KeybindLabel.Name = "Label"
                KeybindLabel.Parent = KeybindHolder
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.Position = UDim2.new(0, 8, 0, 0)
                KeybindLabel.Size = UDim2.new(1, -60, 1, 0)
                KeybindLabel.Font = Enum.Font.SourceSans
                KeybindLabel.Text = "Keybind"
                KeybindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                KeybindLabel.TextSize = 14
                KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                KeybindLabel.ZIndex = 3

                KeybindButton.Name = "KeybindButton"
                KeybindButton.Parent = KeybindHolder
                KeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                KeybindButton.BorderSizePixel = 0
                KeybindButton.Position = UDim2.new(1, -46, 0.5, -10)
                KeybindButton.Size = UDim2.new(0, 38, 0, 20)
                KeybindButton.Font = Enum.Font.SourceSans
                KeybindButton.Text = tostring(key)
                KeybindButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                KeybindButton.TextSize = 14
                KeybindButton.ZIndex = 3

                local listening = false

                KeybindButton.MouseButton1Click:Connect(function()
                    KeybindButton.Text = "..."
                    listening = true
                end)

                local inputConn
                inputConn = UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and not processed then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            key = input.KeyCode.Name
                            KeybindButton.Text = key
                            listening = false
                            if callback then
                                callback(key)
                            end
                        end
                    elseif not listening and input.KeyCode.Name == key then
                        -- Toggle the button if key is pressed
                        ToggleButton:MouseButton1Click()
                    end
                end)

                -- Optional: Clean up connection if needed
                KeybindButton.AncestryChanged:Connect(function(_, parent)
                    if not parent and inputConn then
                        inputConn:Disconnect()
                    end
                end)

                -- Allow programmatic keybind set
                function Toggle:SetKeybind(newKey)
                    key = newKey
                    KeybindButton.Text = tostring(key)
                end

                return KeybindButton
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
        
        function Category:CreateDropdown(text, options, callback, default)
            local Dropdown = {}
            local selected = default or options[1]
            local isOpen = false

            local DropdownHolder = Instance.new("Frame")
            DropdownHolder.Name = text
            DropdownHolder.Parent = ModuleHolder
            DropdownHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            DropdownHolder.BackgroundTransparency = 0.3
            DropdownHolder.Size = UDim2.new(1, 0, 0, 24)
            DropdownHolder.BorderSizePixel = 0

            -- Position based on number of existing elements
            local elementCount = 0
            for _, child in pairs(ModuleHolder:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                    elementCount = elementCount + 1
                end
            end
            DropdownHolder.Position = UDim2.new(0, 0, 0, (elementCount - 1) * 20)

            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Name = "Label"
            DropdownLabel.Parent = DropdownHolder
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Position = UDim2.new(0, 8, 0, 0)
            DropdownLabel.Size = UDim2.new(1, -32, 1, 0)
            DropdownLabel.Font = Enum.Font.SourceSans
            DropdownLabel.Text = text .. ": " .. tostring(selected)
            DropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            DropdownLabel.TextSize = 14
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left

            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Name = "DropdownButton"
            DropdownButton.Parent = DropdownHolder
            DropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            DropdownButton.BorderSizePixel = 0
            DropdownButton.Position = UDim2.new(1, -24, 0, 2)
            DropdownButton.Size = UDim2.new(0, 20, 0, 20)
            DropdownButton.Font = Enum.Font.SourceSans
            DropdownButton.Text = "▼"
            DropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            DropdownButton.TextSize = 14
            DropdownButton.ZIndex = 2

            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Name = "Options"
            OptionsFrame.Parent = DropdownHolder
            OptionsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.Position = UDim2.new(0, 0, 1, 0)
            OptionsFrame.Size = UDim2.new(1, 0, 0, #options * 20)
            OptionsFrame.Visible = false
            OptionsFrame.ZIndex = 3

            -- Add option buttons
            for i, option in ipairs(options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Name = tostring(option)
                OptionButton.Parent = OptionsFrame
                OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                OptionButton.BorderSizePixel = 0
                OptionButton.Position = UDim2.new(0, 0, 0, (i - 1) * 20)
                OptionButton.Size = UDim2.new(1, 0, 0, 20)
                OptionButton.Font = Enum.Font.SourceSans
                OptionButton.Text = tostring(option)
                OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptionButton.TextSize = 14
                OptionButton.ZIndex = 4

                OptionButton.MouseButton1Click:Connect(function()
                    selected = option
                    DropdownLabel.Text = text .. ": " .. tostring(selected)
                    OptionsFrame.Visible = false
                    isOpen = false
                    if callback then
                        callback(selected)
                    end
                end)
            end

            DropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                OptionsFrame.Visible = isOpen
            end)

            -- Hide dropdown if user clicks elsewhere
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mouse = game:GetService("UserInputService"):GetMouseLocation()
                    local absPos = OptionsFrame.AbsolutePosition
                    local absSize = OptionsFrame.AbsoluteSize
                    if not (mouse.X >= absPos.X and mouse.X <= absPos.X + absSize.X and mouse.Y >= absPos.Y and mouse.Y <= absPos.Y + absSize.Y) then
                        OptionsFrame.Visible = false
                        isOpen = false
                    end
                end
            end)

            function Dropdown:GetSelected()
                return selected
            end

            function Dropdown:SetSelected(val)
                selected = val
                DropdownLabel.Text = text .. ": " .. tostring(selected)
                if callback then
                    callback(selected)
                end
            end

            return Dropdown
        end

        function Category:CreateSlider(sliderConfig)
            local Slider = {}
            local SliderHolder = Instance.new("Frame")
            local SliderLabel = Instance.new("TextLabel")
            local SliderButton = Instance.new("TextButton")
            local SliderFill = Instance.new("Frame")
            local ValueLabel = Instance.new("TextLabel")

            SliderHolder.Name = sliderConfig.text
            SliderHolder.Parent = ModuleHolder
            SliderHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            SliderHolder.BorderSizePixel = 0
            SliderHolder.Size = UDim2.new(1, 0, 0, 35)
            -- Position based on number of elements
            local elementCount = 0
            for _, child in pairs(ModuleHolder:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                    elementCount = elementCount + 1
                end
            end
            SliderHolder.Position = UDim2.new(0, 0, 0, (elementCount - 1) * 20)
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

            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - SliderButton.AbsolutePosition.X) / SliderButton.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                current = value
                SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                ValueLabel.Text = tostring(value)
                if sliderConfig.callback then
                    sliderConfig.callback(value)
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

            return Slider
        end
        
        function Category:CreateColorpicker(text, default, callback)
            local Colorpicker = {}
            local color = default or Color3.fromRGB(255, 255, 255)

            local PickerHolder = Instance.new("Frame")
            PickerHolder.Name = text
            PickerHolder.Parent = ModuleHolder
            PickerHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            PickerHolder.BackgroundTransparency = 0.3
            PickerHolder.Size = UDim2.new(1, 0, 0, 32)
            PickerHolder.BorderSizePixel = 0

            -- Position based on number of existing elements
            local elementCount = 0
            for _, child in pairs(ModuleHolder:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                    elementCount = elementCount + 1
                end
            end
            PickerHolder.Position = UDim2.new(0, 0, 0, (elementCount - 1) * 20)

            local PickerLabel = Instance.new("TextLabel")
            PickerLabel.Name = "Label"
            PickerLabel.Parent = PickerHolder
            PickerLabel.BackgroundTransparency = 1
            PickerLabel.Position = UDim2.new(0, 8, 0, 0)
            PickerLabel.Size = UDim2.new(1, -40, 0, 20)
            PickerLabel.Font = Enum.Font.SourceSans
            PickerLabel.Text = text
            PickerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            PickerLabel.TextSize = 14
            PickerLabel.TextXAlignment = Enum.TextXAlignment.Left

            local ColorPreview = Instance.new("TextButton")
            ColorPreview.Name = "ColorPreview"
            ColorPreview.Parent = PickerHolder
            ColorPreview.BackgroundColor3 = color
            ColorPreview.BorderSizePixel = 0
            ColorPreview.Position = UDim2.new(1, -28, 0, 4)
            ColorPreview.Size = UDim2.new(0, 24, 0, 24)
            ColorPreview.Text = ""
            ColorPreview.AutoButtonColor = false

            -- Popup for RGB input
            local Popup = Instance.new("Frame")
            Popup.Name = "ColorPopup"
            Popup.Parent = PickerHolder
            Popup.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Popup.BorderSizePixel = 0
            Popup.Position = UDim2.new(0, 0, 1, 0)
            Popup.Size = UDim2.new(1, 0, 0, 40)
            Popup.Visible = false
            Popup.ZIndex = 10

            local RBox = Instance.new("TextBox")
            RBox.Parent = Popup
            RBox.Size = UDim2.new(0, 36, 0, 24)
            RBox.Position = UDim2.new(0, 8, 0, 8)
            RBox.Text = tostring(math.floor(color.R * 255))
            RBox.PlaceholderText = "R"
            RBox.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
            RBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            RBox.Font = Enum.Font.SourceSans
            RBox.TextSize = 14

            local GBox = Instance.new("TextBox")
            GBox.Parent = Popup
            GBox.Size = UDim2.new(0, 36, 0, 24)
            GBox.Position = UDim2.new(0, 52, 0, 8)
            GBox.Text = tostring(math.floor(color.G * 255))
            GBox.PlaceholderText = "G"
            GBox.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
            GBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            GBox.Font = Enum.Font.SourceSans
            GBox.TextSize = 14

            local BBox = Instance.new("TextBox")
            BBox.Parent = Popup
            BBox.Size = UDim2.new(0, 36, 0, 24)
            BBox.Position = UDim2.new(0, 96, 0, 8)
            BBox.Text = tostring(math.floor(color.B * 255))
            BBox.PlaceholderText = "B"
            BBox.BackgroundColor3 = Color3.fromRGB(0, 0, 60)
            BBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            BBox.Font = Enum.Font.SourceSans
            BBox.TextSize = 14

            local ApplyBtn = Instance.new("TextButton")
            ApplyBtn.Parent = Popup
            ApplyBtn.Size = UDim2.new(0, 36, 0, 24)
            ApplyBtn.Position = UDim2.new(0, 140, 0, 8)
            ApplyBtn.Text = "Set"
            ApplyBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
            ApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ApplyBtn.Font = Enum.Font.SourceSans
            ApplyBtn.TextSize = 14

            ColorPreview.MouseButton1Click:Connect(function()
                Popup.Visible = not Popup.Visible
            end)

            ApplyBtn.MouseButton1Click:Connect(function()
                local r = tonumber(RBox.Text) or 0
                local g = tonumber(GBox.Text) or 0
                local b = tonumber(BBox.Text) or 0
                r = math.clamp(r, 0, 255)
                g = math.clamp(g, 0, 255)
                b = math.clamp(b, 0, 255)
                color = Color3.fromRGB(r, g, b)
                ColorPreview.BackgroundColor3 = color
                Popup.Visible = false
                if callback then
                    callback(color)
                end
            end)

            function Colorpicker:GetColor()
                return color
            end

            function Colorpicker:SetColor(newColor)
                color = newColor
                ColorPreview.BackgroundColor3 = color
                RBox.Text = tostring(math.floor(color.R * 255))
                GBox.Text = tostring(math.floor(color.G * 255))
                BBox.Text = tostring(math.floor(color.B * 255))
                if callback then
                    callback(color)
                end
            end

            return Colorpicker
        end

        -- Track the maximum width of any option text in this category
        local maxOptionWidth = 120

        -- Helper to get the next Y offset for a new element in ModuleHolder
        local function getNextYOffset()
            local offset = 0
            for _, child in ipairs(ModuleHolder:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                    offset = offset + child.Size.Y.Offset
                end
            end
            return offset
        end

        -- Patch all option creators to use getNextYOffset for positioning
        local oldCreateToggle = Category.CreateToggle
        function Category:CreateToggle(toggleConfig)
            local toggle = oldCreateToggle(self, toggleConfig)
            -- Fix position
            local btn = ModuleHolder:FindFirstChild(toggleConfig.text)
            if btn then
                btn.Position = UDim2.new(0, 0, 0, getNextYOffset() - btn.Size.Y.Offset)
            end
            -- Also fix settings holder if present
            local settingsHolder = ModuleHolder:FindFirstChild("Settings_" .. toggleConfig.text)
            if settingsHolder then
                settingsHolder.Position = UDim2.new(0, 0, 0, getNextYOffset())
            end
            return toggle
        end

        local oldCreateButton = Category.CreateButton
        function Category:CreateButton(buttonConfig)
            local btn = oldCreateButton(self, buttonConfig)
            local btnInst = ModuleHolder:FindFirstChild(buttonConfig.text)
            if btnInst then
                btnInst.Position = UDim2.new(0, 0, 0, getNextYOffset() - btnInst.Size.Y.Offset)
            end
            return btn
        end

        local oldCreateLabel = Category.CreateLabel
        function Category:CreateLabel(text)
            local lbl = oldCreateLabel(self, text)
            local lblInst = ModuleHolder:FindFirstChild(text)
            if lblInst then
                lblInst.Position = UDim2.new(0, 0, 0, getNextYOffset() - lblInst.Size.Y.Offset)
            end
            return lbl
        end

        local oldCreateTextbox = Category.CreateTextbox
        function Category:CreateTextbox(textboxConfig)
            local tb = oldCreateTextbox(self, textboxConfig)
            local tbInst = ModuleHolder:FindFirstChild(textboxConfig.text)
            if tbInst then
                tbInst.Position = UDim2.new(0, 0, 0, getNextYOffset() - tbInst.Size.Y.Offset)
            end
            return tb
        end

        local oldCreateDropdown = Category.CreateDropdown
        function Category:CreateDropdown(text, options, callback, default)
            local dd = oldCreateDropdown(self, text, options, callback, default)
            local ddInst = ModuleHolder:FindFirstChild(text)
            if ddInst then
                ddInst.Position = UDim2.new(0, 0, 0, getNextYOffset() - ddInst.Size.Y.Offset)
            end
            return dd
        end

        local oldCreateSlider = Category.CreateSlider
        function Category:CreateSlider(sliderConfig)
            local sl = oldCreateSlider(self, sliderConfig)
            local slInst = ModuleHolder:FindFirstChild(sliderConfig.text)
            if slInst then
                slInst.Position = UDim2.new(0, 0, 0, getNextYOffset() - slInst.Size.Y.Offset)
            end
            return sl
        end

        local oldCreateColorpicker = Category.CreateColorpicker
        function Category:CreateColorpicker(text, default, callback)
            local cp = oldCreateColorpicker(self, text, default, callback)
            local cpInst = ModuleHolder:FindFirstChild(text)
            if cpInst then
                cpInst.Position = UDim2.new(0, 0, 0, getNextYOffset() - cpInst.Size.Y.Offset)
            end
            return cp
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