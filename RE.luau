-- ============================================
-- FIXED DRAWING LIBRARY FOR ROBLOX EXECUTOR
-- ============================================

local DrawingCache = {}
local DrawingObjects = {}

local Fonts = {
    [0] = Enum.Font.Arial,
    [1] = Enum.Font.BuilderSans,
    [2] = Enum.Font.Gotham,
    [3] = Enum.Font.RobotoMono
}

local function gethui()
    local success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    return success and result or game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

getgenv().gethui = gethui

local UI = Instance.new("ScreenGui")
UI.Name = "DrawingLib"
UI.DisplayOrder = 999999
UI.IgnoreGuiInset = true
UI.ResetOnSpawn = false
UI.Parent = gethui()

-- Drawing library definition
local Drawing = {
    Fonts = {
        UI = 0,
        System = 1,
        Plex = 2,
        Monospace = 3
    }
}

-- Utility functions
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

local function distance(p1, p2)
    local dx = p2.X - p1.X
    local dy = p2.Y - p1.Y
    return math.sqrt(dx * dx + dy * dy)
end

local function angle(p1, p2)
    local dx = p2.X - p1.X
    local dy = p2.Y - p1.Y
    return math.deg(math.atan2(dy, dx))
end

Drawing.new = function(drawingType)
    if type(drawingType) ~= "string" then
        error("Drawing.new: argument must be a string, got " .. type(drawingType), 2)
    end

    local validTypes = {
        Line = true,
        Square = true,
        Rectangle = true,
        Circle = true,
        Text = true,
        Image = true,
        Triangle = true,
        Quad = true
    }
    
    if not validTypes[drawingType] then
        error("Drawing.new: invalid drawing type '" .. drawingType .. "'", 2)
    end

    local drawingObj = Instance.new("Frame")
    drawingObj.BackgroundTransparency = 1
    drawingObj.BorderSizePixel = 0
    drawingObj.Size = UDim2.fromOffset(0, 0)
    drawingObj.Position = UDim2.fromOffset(0, 0)
    drawingObj.Parent = UI
    
    local properties = {
        Visible = true,
        Color = Color3.new(1, 1, 1),
        Transparency = 0,
        ZIndex = 1,
        Rotation = 0,
        Opacity = 1
    }
    
    local self = newproxy(true)
    local mt = getmetatable(self)
    
    local removed = false
    
    mt.__index = function(_, key)
        if key == "__OBJECT_EXISTS" then
            return not removed
        elseif key == "__TYPE" then
            return drawingType
        elseif key == "ClassName" then
            return drawingType
        end
        return properties[key]
    end
    
    mt.__newindex = function(_, key, value)
        if removed then return end
        
        if key == "__OBJECT_EXISTS" then
            return
        end
        
        properties[key] = value
    end
    
    mt.__tostring = function()
        return string.format("Drawing (%s)", drawingType)
    end
    
    mt.__metatable = "The metatable is locked"
    
    -- Standard properties
    properties.Remove = function()
        if removed then return end
        
        removed = true
        
        if drawingObj and drawingObj.Parent then
            drawingObj:Destroy()
        end
        
        for i, obj in ipairs(DrawingCache) do
            if obj.proxy == self then
                table.remove(DrawingCache, i)
                break
            end
        end
        
        DrawingObjects[self] = nil
    end
    
    properties.Destroy = properties.Remove
    
    -- New methods
    properties.SetOpacity = function(opacity)
        properties.Opacity = clamp(opacity, 0, 1)
        properties.Transparency = 1 - properties.Opacity
    end
    
    properties.SetColor = function(r, g, b)
        if type(r) == "userdata" then
            properties.Color = r
        else
            properties.Color = Color3.new(
                clamp(r, 0, 1),
                clamp(g, 0, 1),
                clamp(b, 0, 1)
            )
        end
    end
    
    table.insert(DrawingCache, {proxy = self, instance = drawingObj})
    DrawingObjects[self] = true
    
    -- Line drawing
    if drawingType == "Line" then
        drawingObj.AnchorPoint = Vector2.new(0.5, 0.5)
        
        properties.From = Vector2.zero
        properties.To = Vector2.zero
        properties.Thickness = 1
        
        local updateLine = function()
            if removed then return end
            
            local from = properties.From
            local to = properties.To
            local dx = to.X - from.X
            local dy = to.Y - from.Y
            local length = distance(from, to)
            
            drawingObj.Size = UDim2.fromOffset(length, properties.Thickness)
            drawingObj.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
            drawingObj.Rotation = angle(from, to)
            drawingObj.BackgroundTransparency = 1 - properties.Opacity
            drawingObj.BackgroundColor3 = properties.Color
        end
        
        properties.SetLinePoints = function(p1, p2)
            properties.From = p1
            properties.To = p2
            updateLine()
        end
        
        properties.GetLength = function()
            return distance(properties.From, properties.To)
        end
        
        updateLine()
        
    -- Rectangle/Square drawing
    elseif drawingType == "Square" or drawingType == "Rectangle" then
        local stroke = Instance.new("UIStroke")
        stroke.Parent = drawingObj
        stroke.Thickness = 1
        stroke.Color = Color3.new(1, 1, 1)
        
        properties.Size = Vector2.zero
        properties.Position = Vector2.zero
        properties.Filled = false
        properties.Thickness = 1
        
        local updateSquare = function()
            if removed then return end
            
            drawingObj.Size = UDim2.fromOffset(properties.Size.X, properties.Size.Y)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            drawingObj.Rotation = properties.Rotation or 0
            
            if properties.Filled then
                drawingObj.BackgroundTransparency = 1 - properties.Opacity
                drawingObj.BackgroundColor3 = properties.Color
                stroke.Enabled = false
            else
                drawingObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness
                stroke.Transparency = 1 - properties.Opacity
            end
        end
        
        properties.SetRectangle = function(pos, size)
            properties.Position = pos
            properties.Size = size
            updateSquare()
        end
        
        properties.SetOutlineOnly = function(thickness, color)
            properties.Filled = false
            properties.Thickness = thickness
            if color then properties.Color = color end
            updateSquare()
        end
        
        properties.SetFilled = function(color)
            properties.Filled = true
            if color then properties.Color = color end
            updateSquare()
        end
        
        updateSquare()
        
    -- Circle drawing
    elseif drawingType == "Circle" then
        local stroke = Instance.new("UIStroke")
        stroke.Parent = drawingObj
        stroke.Thickness = 1
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = drawingObj
        
        properties.Radius = 50
        properties.Position = Vector2.zero
        properties.Filled = false
        properties.Thickness = 1
        
        local updateCircle = function()
            if removed then return end
            
            local diameter = properties.Radius * 2
            drawingObj.Size = UDim2.fromOffset(diameter, diameter)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X - properties.Radius, properties.Position.Y - properties.Radius)
            
            if properties.Filled then
                drawingObj.BackgroundTransparency = 1 - properties.Opacity
                drawingObj.BackgroundColor3 = properties.Color
                stroke.Enabled = false
            else
                drawingObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness
                stroke.Transparency = 1 - properties.Opacity
            end
        end
        
        properties.SetCircle = function(center, radius)
            properties.Position = center
            properties.Radius = radius
            updateCircle()
        end
        
        properties.GetCircumference = function()
            return 2 * math.pi * properties.Radius
        end
        
        properties.GetArea = function()
            return math.pi * properties.Radius * properties.Radius
        end
        
        updateCircle()
        
    -- Text drawing
    elseif drawingType == "Text" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("TextLabel")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.TextColor3 = Color3.new(1, 1, 1)
        drawingObj.TextSize = 13
        drawingObj.Font = Enum.Font.Code
        drawingObj.Text = ""
        drawingObj.AutomaticSize = Enum.AutomaticSize.XY
        drawingObj.Parent = UI
        
        properties.Text = ""
        properties.Size = 13
        properties.Center = false
        properties.Outline = false
        properties.OutlineColor = Color3.new(0, 0, 0)
        properties.OutlineSize = 1
        properties.Position = Vector2.zero
        properties.Font = 2
        properties.TextBounds = Vector2.zero
        
        local updateText = function()
            if removed then return end
            
            drawingObj.Text = tostring(properties.Text)
            drawingObj.TextSize = properties.Size
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            drawingObj.TextColor3 = properties.Color
            drawingObj.TextTransparency = 1 - properties.Opacity
            drawingObj.Font = Fonts[properties.Font] or Enum.Font.Code
            drawingObj.Rotation = properties.Rotation or 0
            
            if properties.Center then
                drawingObj.TextXAlignment = Enum.TextXAlignment.Center
                drawingObj.TextYAlignment = Enum.TextYAlignment.Center
            else
                drawingObj.TextXAlignment = Enum.TextXAlignment.Left
                drawingObj.TextYAlignment = Enum.TextYAlignment.Top
            end
            
            if properties.Outline then
                drawingObj.TextStrokeTransparency = 1 - properties.Opacity
                drawingObj.TextStrokeColor3 = properties.OutlineColor
                drawingObj.TextStrokeSize = properties.OutlineSize or 1
            else
                drawingObj.TextStrokeTransparency = 1
            end
            
            -- Update text bounds synchronously
            properties.TextBounds = drawingObj.TextBounds
        end
        
        properties.SetText = function(text)
            properties.Text = tostring(text)
            updateText()
        end
        
        properties.GetTextBounds = function()
            return properties.TextBounds
        end
        
        updateText()
        
    -- Image drawing
    elseif drawingType == "Image" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("ImageLabel")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Parent = UI
        
        properties.Data = ""
        properties.Size = Vector2.zero
        properties.Position = Vector2.zero
        
        local updateImage = function()
            if removed then return end
            
            drawingObj.Image = properties.Data
            drawingObj.Size = UDim2.fromOffset(properties.Size.X, properties.Size.Y)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            drawingObj.ImageTransparency = 1 - properties.Opacity
            drawingObj.ImageColor3 = properties.Color
            drawingObj.Rotation = properties.Rotation or 0
        end
        
        properties.SetImage = function(imageId, size, position)
            properties.Data = imageId
            if size then properties.Size = size end
            if position then properties.Position = position end
            updateImage()
        end
        
        updateImage()
    end
    
    return self
end

-- Global functions
getgenv().Drawing = Drawing

getgenv().isrenderobj = function(obj)
    if type(obj) ~= "userdata" then
        return false
    end
    
    local success, exists = pcall(function()
        return obj.__OBJECT_EXISTS
    end)
    
    return success and exists == true
end

getgenv().cleardrawcache = function()
    for i = #DrawingCache, 1, -1 do
        local data = DrawingCache[i]
        if data and data.proxy then
            pcall(function()
                data.proxy:Remove()
            end)
        end
    end
    
    DrawingCache = {}
    DrawingObjects = {}
end

getgenv().getrenderproperty = function(obj, prop)
    if not getgenv().isrenderobj(obj) then
        return nil
    end
    return obj[prop]
end

getgenv().setrenderproperty = function(obj, prop, value)
    if not getgenv().isrenderobj(obj) then
        return
    end
    obj[prop] = value
end

-- Utility functions
getgenv().drawingutil = {
    Distance = distance,
    Angle = angle,
    
    GetCacheSize = function()
        return #DrawingCache
    end,
    
    GetDrawingObjects = function()
        return DrawingObjects
    end,
    
    HSVtoRGB = function(h, s, v)
        h = h % 360
        local c = v * s
        local x = c * (1 - ((h / 60) % 2 - 1))
        local m = v - c
        
        local r, g, b = 0, 0, 0
        if h < 60 then r, g, b = c, x, 0
        elseif h < 120 then r, g, b = x, c, 0
        elseif h < 180 then r, g, b = 0, c, x
        elseif h < 240 then r, g, b = 0, x, c
        elseif h < 300 then r, g, b = x, 0, c
        else r, g, b = c, 0, x
        end
        
        return Color3.new(r + m, g + m, b + m)
    end,
    
    LerpColor = function(c1, c2, t)
        return Color3.new(
            lerp(c1.R, c2.R, t),
            lerp(c1.G, c2.G, t),
            lerp(c1.B, c2.B, t)
        )
    end
}
