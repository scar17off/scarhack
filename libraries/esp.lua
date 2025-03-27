--Settings--
local ESP = {
    Enabled = false,
    Boxes = true,
    BoxShift = CFrame.new(0,-1.5,0),
	BoxSize = Vector3.new(4,6,0),
    Color = Color3.fromRGB(255, 170, 0),
    DefaultColor = Color3.fromRGB(255, 255, 255),
    FaceCamera = false,
    Names = false,
    TeamColor = false,
    Thickness = 2,
    AttachShift = 1,
    TeamMates = true,
    Players = true,
    Glow = false,
    GlowColor = Color3.fromRGB(255, 255, 255),
    GlowTeamColor = false,
    GlowTransparency = 0.5,
    MaxDistance = 1000,
    Distance = false,
    Tracers = false,
    Health = {
        Enabled = false,
        Side = "Right", -- "Left", "Right", "Top", "Bottom"
        Width = 2,
        FaceCamera = false
    },
    
    Objects = setmetatable({}, {__mode="kv"}),
    Overrides = {}
}

--Declarations--
local cam = workspace.CurrentCamera
local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()

local V3new = Vector3.new
local WorldToViewportPoint = cam.WorldToViewportPoint

--Functions--
local function Draw(obj, props)
	local new = Drawing.new(obj)
	
	props = props or {}
	for i,v in pairs(props) do
		new[i] = v
	end
	return new
end

function ESP:GetTeam(p)
	local ov = self.Overrides.GetTeam
	if ov then
		return ov(p)
	end
	
	return p and p.Team
end

function ESP:IsTeamMate(p)
    local ov = self.Overrides.IsTeamMate
	if ov then
		return ov(p)
    end
    
    return self:GetTeam(p) == self:GetTeam(plr)
end

function ESP:GetColor(obj)
	local ov = self.Overrides.GetColor
	if ov then
		return ov(obj)
    end
    local p = self:GetPlrFromChar(obj)
    if p and self.TeamColor and p.Team then
        return p.Team.TeamColor.Color
    end
    return self.DefaultColor
end

function ESP:GetPlrFromChar(char)
	local ov = self.Overrides.GetPlrFromChar
	if ov then
		return ov(char)
	end
	
	return plrs:GetPlayerFromCharacter(char)
end

function ESP:Toggle(bool)
    ESP.Enabled = bool
    
    if not bool then
        for _, v in pairs(ESP.Objects) do
            if v.Type == "Box" then
                for _, component in pairs(v.Components) do
                    if typeof(component) ~= "Instance" then
                        component.Visible = false
                    elseif typeof(component) == "Instance" and component:IsA("Highlight") then
                        component.Enabled = false
                    end
                end
            end
        end
        return
    end
end

function ESP:GetBox(obj)
    return self.Objects[obj]
end

function ESP:AddObjectListener(parent, options)
    local function NewListener(c)
        if type(options.Type) == "string" and c:IsA(options.Type) or options.Type == nil then
            if type(options.Name) == "string" and c.Name == options.Name or options.Name == nil then
                if not options.Validator or options.Validator(c) then
                    local box = ESP:Add(c, {
                        PrimaryPart = type(options.PrimaryPart) == "string" and c:WaitForChild(options.PrimaryPart) or type(options.PrimaryPart) == "function" and options.PrimaryPart(c),
                        Color = type(options.Color) == "function" and options.Color(c) or options.Color,
                        ColorDynamic = options.ColorDynamic,
                        Name = type(options.CustomName) == "function" and options.CustomName(c) or options.CustomName,
                        IsEnabled = options.IsEnabled,
                        RenderInNil = options.RenderInNil
                    })
                    --TODO: add a better way of passing options
                    if options.OnAdded then
                        coroutine.wrap(options.OnAdded)(box)
                    end
                end
            end
        end
    end

    if options.Recursive then
        parent.DescendantAdded:Connect(NewListener)
        for i,v in pairs(parent:GetDescendants()) do
            coroutine.wrap(NewListener)(v)
        end
    else
        parent.ChildAdded:Connect(NewListener)
        for i,v in pairs(parent:GetChildren()) do
            coroutine.wrap(NewListener)(v)
        end
    end
end

local boxBase = {}
boxBase.__index = boxBase

function boxBase:Remove()
    ESP.Objects[self.Object] = nil
    for i,v in pairs(self.Components) do
        if typeof(v) ~= "Instance" then
            v:Remove()
        else
            v:Destroy()
        end
        self.Components[i] = nil
    end
end

function boxBase:Update()
    if not self.PrimaryPart then
        return self:Remove()
    end

    -- Check if ESP is enabled and if this specific object should be visible
    local isEnabled = true
    if type(self.IsEnabled) == "string" then
        isEnabled = ESP[self.IsEnabled] -- Get the toggle value from ESP table
    elseif type(self.IsEnabled) == "function" then
        isEnabled = self.IsEnabled(self.Object)
    end

    if not ESP.Enabled or not isEnabled then
        for _, v in pairs(self.Components) do
            if typeof(v) ~= "Instance" then
                v.Visible = false
            elseif typeof(v) == "Instance" and v:IsA("Highlight") then
                v.Enabled = false
            end
        end
        return
    end

    local color = self.Color or self.ColorDynamic and self:ColorDynamic() or ESP:GetColor(self.Object) or ESP.Color

    --calculations--
    local cf = self.PrimaryPart.CFrame
    if ESP.FaceCamera then
        cf = CFrame.new(cf.p, cam.CFrame.p)
    end
    local size = self.Size
    local locs = {
        TopLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,size.Y/2,0),
        TopRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,size.Y/2,0),
        BottomLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,-size.Y/2,0),
        BottomRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,-size.Y/2,0),
        TagPos = cf * ESP.BoxShift * CFrame.new(0,size.Y/2,0),
        Torso = cf * ESP.BoxShift
    }

    if ESP.Boxes then
        local TopLeft, Vis1 = WorldToViewportPoint(cam, locs.TopLeft.p)
        local TopRight, Vis2 = WorldToViewportPoint(cam, locs.TopRight.p)
        local BottomLeft, Vis3 = WorldToViewportPoint(cam, locs.BottomLeft.p)
        local BottomRight, Vis4 = WorldToViewportPoint(cam, locs.BottomRight.p)

        -- Check if all points are behind the camera
        local allBehindCamera = TopLeft.Z < 0 and TopRight.Z < 0 and BottomLeft.Z < 0 and BottomRight.Z < 0

        -- Check if all points are outside the viewport
        local minX = -100
        local minY = -100
        local maxX = cam.ViewportSize.X + 100
        local maxY = cam.ViewportSize.Y + 100

        local allOutside = true
        local points = {TopLeft, TopRight, BottomLeft, BottomRight}
        for _, point in pairs(points) do
            if point.X >= minX and point.X <= maxX and point.Y >= minY and point.Y <= maxY then
                allOutside = false
                break
            end
        end

        if allBehindCamera or allOutside then
            self.Components.TopLine.Visible = false
            self.Components.LeftLine.Visible = false
            self.Components.RightLine.Visible = false
            self.Components.BottomLine.Visible = false
        else
            -- Top Line
            self.Components.TopLine.From = Vector2.new(TopLeft.X, TopLeft.Y)
            self.Components.TopLine.To = Vector2.new(TopRight.X, TopRight.Y)
            self.Components.TopLine.Visible = true
            self.Components.TopLine.Color = color

            -- Left Line
            self.Components.LeftLine.From = Vector2.new(TopLeft.X, TopLeft.Y)
            self.Components.LeftLine.To = Vector2.new(BottomLeft.X, BottomLeft.Y)
            self.Components.LeftLine.Visible = true
            self.Components.LeftLine.Color = color

            -- Right Line
            self.Components.RightLine.From = Vector2.new(TopRight.X, TopRight.Y)
            self.Components.RightLine.To = Vector2.new(BottomRight.X, BottomRight.Y)
            self.Components.RightLine.Visible = true
            self.Components.RightLine.Color = color

            -- Bottom Line
            self.Components.BottomLine.From = Vector2.new(BottomLeft.X, BottomLeft.Y)
            self.Components.BottomLine.To = Vector2.new(BottomRight.X, BottomRight.Y)
            self.Components.BottomLine.Visible = true
            self.Components.BottomLine.Color = color
        end
    else
        self.Components.TopLine.Visible = false
        self.Components.LeftLine.Visible = false
        self.Components.RightLine.Visible = false
        self.Components.BottomLine.Visible = false
    end

    if ESP.Names then
        local TagPos, Vis5 = WorldToViewportPoint(cam, locs.TagPos.p)
        
        local inView = Vis5 and TagPos.Z > 0 and
            TagPos.X > -100 and TagPos.X < cam.ViewportSize.X + 100 and
            TagPos.Y > -100 and TagPos.Y < cam.ViewportSize.Y + 100

        if inView then
            self.Components.Name.Visible = true
            self.Components.Name.Position = Vector2.new(TagPos.X, TagPos.Y)
            self.Components.Name.Text = self.Name
            self.Components.Name.Color = color
        else
            self.Components.Name.Visible = false
        end
    else
        self.Components.Name.Visible = false
    end

    if ESP.Distance then
        local TagPos, Vis5 = WorldToViewportPoint(cam, locs.TagPos.p)
        
        if Vis5 then
            self.Components.Distance.Visible = true
            self.Components.Distance.Position = Vector2.new(TagPos.X, TagPos.Y + 14)
            self.Components.Distance.Text = math.floor((cam.CFrame.p - cf.p).magnitude) .."m away"
            self.Components.Distance.Color = color
        else
            self.Components.Distance.Visible = false
        end
    else
        self.Components.Distance.Visible = false
    end
    
    if ESP.Tracers then
        local TorsoPos, Vis6 = WorldToViewportPoint(cam, locs.Torso.p)

        if Vis6 then
            self.Components.Tracer.Visible = true
            self.Components.Tracer.From = Vector2.new(TorsoPos.X, TorsoPos.Y)
            self.Components.Tracer.To = Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/ESP.AttachShift)
            self.Components.Tracer.Color = color
        else
            self.Components.Tracer.Visible = false
        end
    else
        self.Components.Tracer.Visible = false
    end

    if ESP.Glow then
        if not self.Components.Highlight then
            self.Components.Highlight = Instance.new("Highlight")
            self.Components.Highlight.Parent = self.Object
        end
        
        -- Determine glow color based on team settings
        local glowColor
        if ESP.GlowTeamColor then
            local p = self:GetPlrFromChar(self.Object)
            if p and p.Team then
                glowColor = p.Team.TeamColor.Color
            else
                glowColor = ESP.GlowColor
            end
        else
            glowColor = ESP.GlowColor
        end
        
        -- Set the outline to be solid and visible
        self.Components.Highlight.OutlineTransparency = 0
        self.Components.Highlight.OutlineColor = glowColor
        
        -- Set the fill to be more transparent
        self.Components.Highlight.FillTransparency = ESP.GlowTransparency
        self.Components.Highlight.FillColor = glowColor
        
        -- Enable the highlight
        self.Components.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        self.Components.Highlight.Enabled = true
    else
        if self.Components.Highlight then
            self.Components.Highlight.Enabled = false
            self.Components.Highlight:Destroy()
            self.Components.Highlight = nil
        end
    end

    -- Health Bar
    if ESP.Health.Enabled then
        local humanoid = self.Object:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local cf = self.PrimaryPart.CFrame
            if ESP.Health.FaceCamera then
                cf = CFrame.new(cf.p, cam.CFrame.p)
            end
            local size = self.Size
            local healthLocs = {
                TopLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,size.Y/2,0),
                TopRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,size.Y/2,0),
                BottomLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,-size.Y/2,0),
                BottomRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,-size.Y/2,0)
            }

            local TopLeft, Vis1 = WorldToViewportPoint(cam, healthLocs.TopLeft.p)
            local TopRight, Vis2 = WorldToViewportPoint(cam, healthLocs.TopRight.p)
            local BottomLeft, Vis3 = WorldToViewportPoint(cam, healthLocs.BottomLeft.p)
            local BottomRight, Vis4 = WorldToViewportPoint(cam, healthLocs.BottomRight.p)

            if Vis1 or Vis2 or Vis3 or Vis4 then
                if not self.Components.HealthBarOutline then
                    self.Components.HealthBarOutline = Drawing.new("Square")
                    self.Components.HealthBarOutline.Thickness = 1
                    self.Components.HealthBarOutline.Filled = true
                    self.Components.HealthBarOutline.Transparency = 1
                end

                if not self.Components.HealthBar then
                    self.Components.HealthBar = Drawing.new("Square")
                    self.Components.HealthBar.Thickness = 1
                    self.Components.HealthBar.Filled = true
                    self.Components.HealthBar.Transparency = 1
                end

                local healthPercentage = humanoid.Health / humanoid.MaxHealth
                local healthColor = Color3.new(1 - healthPercentage, healthPercentage, 0)
                local width = ESP.Health.Width
                
                local position = Vector2.new(0, 0)
                local size = Vector2.new(0, 0)
                local offset = width + 4

                if ESP.Health.Side == "Left" then
                    -- Calculate direction vector for proper offset
                    local dir = (Vector2.new(TopLeft.X, TopLeft.Y) - Vector2.new(TopRight.X, TopRight.Y)).Unit
                    local perpDir = Vector2.new(-dir.Y, dir.X)
                    position = Vector2.new(TopLeft.X, TopLeft.Y) + (perpDir * offset)
                    size = Vector2.new(width, (BottomLeft.Y - TopLeft.Y))
                elseif ESP.Health.Side == "Right" then
                    local dir = (Vector2.new(TopRight.X, TopRight.Y) - Vector2.new(TopLeft.X, TopLeft.Y)).Unit
                    local perpDir = Vector2.new(-dir.Y, dir.X)
                    position = Vector2.new(TopRight.X, TopRight.Y) + (perpDir * offset)
                    size = Vector2.new(width, (BottomRight.Y - TopRight.Y))
                elseif ESP.Health.Side == "Top" then
                    local dir = (Vector2.new(TopLeft.X, TopLeft.Y) - Vector2.new(BottomLeft.X, BottomLeft.Y)).Unit
                    local perpDir = Vector2.new(-dir.Y, dir.X)
                    position = Vector2.new(TopLeft.X, TopLeft.Y) + (perpDir * offset)
                    size = Vector2.new(TopRight.X - TopLeft.X, width)
                elseif ESP.Health.Side == "Bottom" then
                    local dir = (Vector2.new(BottomLeft.X, BottomLeft.Y) - Vector2.new(TopLeft.X, TopLeft.Y)).Unit
                    local perpDir = Vector2.new(-dir.Y, dir.X)
                    position = Vector2.new(BottomLeft.X, BottomLeft.Y) + (perpDir * offset)
                    size = Vector2.new(BottomRight.X - BottomLeft.X, width)
                end

                -- Update outline
                self.Components.HealthBarOutline.Position = position
                self.Components.HealthBarOutline.Size = size
                self.Components.HealthBarOutline.Color = Color3.new(0, 0, 0)
                self.Components.HealthBarOutline.Visible = true

                -- Update health bar
                local healthBarSize = size
                if ESP.Health.Side == "Left" or ESP.Health.Side == "Right" then
                    healthBarSize = Vector2.new(size.X, size.Y * healthPercentage)
                    self.Components.HealthBar.Position = position + Vector2.new(0, size.Y * (1 - healthPercentage))
                else
                    healthBarSize = Vector2.new(size.X * healthPercentage, size.Y)
                    self.Components.HealthBar.Position = position
                end

                self.Components.HealthBar.Size = healthBarSize
                self.Components.HealthBar.Color = healthColor
                self.Components.HealthBar.Visible = true
            else
                if self.Components.HealthBarOutline then
                    self.Components.HealthBarOutline.Visible = false
                end
                if self.Components.HealthBar then
                    self.Components.HealthBar.Visible = false
                end
            end
        end
    else
        if self.Components.HealthBarOutline then
            self.Components.HealthBarOutline.Visible = false
        end
        if self.Components.HealthBar then
            self.Components.HealthBar.Visible = false
        end
    end
end

function ESP:Add(obj, options)
    if not obj.Parent and not options.RenderInNil then
        return warn(obj, "has no parent")
    end

    local box = setmetatable({
        Name = options.Name or obj.Name,
        Type = "Box",
        Color = options.Color or self:GetColor(obj),
        Size = options.Size or self.BoxSize,
        Object = obj,
        Player = options.Player or plrs:GetPlayerFromCharacter(obj),
        PrimaryPart = options.PrimaryPart or obj.ClassName == "Model" and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj:IsA("BasePart") and obj,
        Components = {},
        IsEnabled = options.IsEnabled,
        Temporary = options.Temporary,
        ColorDynamic = options.ColorDynamic,
        RenderInNil = options.RenderInNil
    }, boxBase)

    if self:GetBox(obj) then
        self:GetBox(obj):Remove()
    end

    -- Create lines for the box instead of a Quad
    box.Components["TopLine"] = Drawing.new("Line")
    box.Components["LeftLine"] = Drawing.new("Line")
    box.Components["RightLine"] = Drawing.new("Line")
    box.Components["BottomLine"] = Drawing.new("Line")

    for _, line in pairs({"TopLine", "LeftLine", "RightLine", "BottomLine"}) do
        box.Components[line].Visible = false
        box.Components[line].Thickness = self.Thickness
        box.Components[line].Color = box.Color
        box.Components[line].Transparency = 1
    end

    box.Components["Name"] = Drawing.new("Text", {
        Text = box.Name,
        Color = box.Color,
        Center = true,
        Outline = true,
        Size = 19,
        Visible = self.Enabled and self.Names
    })

    box.Components["Distance"] = Drawing.new("Text", {
        Color = box.Color,
        Center = true,
        Outline = true,
        Size = 19,
        Visible = self.Enabled and self.Names
    })
    
    box.Components["Tracer"] = Drawing.new("Line", {
        Thickness = ESP.Thickness,
        Color = box.Color,
        Transparency = 1,
        Visible = self.Enabled and self.Tracers
    })

    box.Components["HealthBar"] = Drawing.new("Square", {
        Thickness = 1,
        Filled = true,
        Transparency = 1,
        Visible = self.Enabled and self.Health.Enabled
    })

    box.Components["HealthBarOutline"] = Drawing.new("Square", {
        Thickness = 1,
        Filled = true,
        Transparency = 1,
        Color = Color3.new(0, 0, 0),
        Visible = self.Enabled and self.Health.Enabled
    })

    self.Objects[obj] = box
    
    obj.AncestryChanged:Connect(function(_, parent)
        if parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)

    obj:GetPropertyChangedSignal("Parent"):Connect(function()
        if obj.Parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)

    local hum = obj:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Died:Connect(function()
            if ESP.AutoRemove ~= false then
                box:Remove()
            end
        end)
    end

    return box
end

local function CharAdded(char)
    local p = plrs:GetPlayerFromCharacter(char)
    if not char:FindFirstChild("HumanoidRootPart") then
        local ev
        ev = char.ChildAdded:Connect(function(c)
            if c.Name == "HumanoidRootPart" then
                ev:Disconnect()
                ESP:Add(char, {
                    Name = p.Name,
                    Player = p,
                    PrimaryPart = c
                })
            end
        end)
    else
        ESP:Add(char, {
            Name = p.Name,
            Player = p,
            PrimaryPart = char.HumanoidRootPart
        })
    end
end
local function PlayerAdded(p)
    p.CharacterAdded:Connect(CharAdded)
    if p.Character then
        coroutine.wrap(CharAdded)(p.Character)
    end
end
plrs.PlayerAdded:Connect(PlayerAdded)
for i,v in pairs(plrs:GetPlayers()) do
    if v ~= plr then
        PlayerAdded(v)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    cam = workspace.CurrentCamera
    for i,v in (ESP.Enabled and pairs or ipairs)(ESP.Objects) do
        if v.Update then
            local s,e = pcall(v.Update, v)
            if not s then warn("[EU]", e, v.Object:GetFullName()) end
        end
    end
end)

return ESP