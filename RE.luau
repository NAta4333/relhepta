local DrawingCache = {}
local DrawingObjects = {}

local Fonts = {
    [0] = Enum.Font.Arial,
    [1] = Enum.Font.BuilderSans,
    [2] = Enum.Font.Gotham,
    [3] = Enum.Font.RobotoMono,
    [4] = Enum.Font.SourceSans,
    [5] = Enum.Font.Legacy,
    [6] = Enum.Font.Code,
    [7] = Enum.Font.Highway,
    [8] = Enum.Font.Fantasy,
    [9] = Enum.Font.Arcade
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

local Drawing = {
    Fonts = {
        UI = 0,
        System = 1,
        Plex = 2,
        Monospace = 3,
        SourceSans = 4,
        Legacy = 5,
        Code = 6,
        Highway = 7,
        Fantasy = 8,
        Arcade = 9
    }
}

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
        Transparency = 1,
        ZIndex = 1,
        Rotation = 0,
        AnchorPoint = Vector2.new(0, 0)
    }
    
    local self = newproxy(true)
    local mt = getmetatable(self)
    
    local removed = false
    
    mt.__index = function(_, key)
        if key == "__OBJECT_EXISTS" then
            return not removed
        end
        return properties[key]
    end
    
    mt.__newindex = function(_, key, value)
        if removed then return end
        
        if key == "__OBJECT_EXISTS" then
            return
        end
        
        properties[key] = value
        
        if key == "Visible" then
            drawingObj.Visible = value
        elseif key == "Color" then
            drawingObj.BackgroundColor3 = value
        elseif key == "Transparency" then
            drawingObj.BackgroundTransparency = 1 - value
        elseif key == "ZIndex" then
            drawingObj.ZIndex = value
        elseif key == "Rotation" then
            drawingObj.Rotation = value
        elseif key == "AnchorPoint" then
            drawingObj.AnchorPoint = value
        end
    end
    
    mt.__tostring = function()
        return "Drawing"
    end
    
    mt.__metatable = "The metatable is locked"
    
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
    
    properties.Clear = function()
        -- Clears any child elements if applicable, but for most, no-op
    end
    
    table.insert(DrawingCache, {proxy = self, instance = drawingObj})
    DrawingObjects[self] = true
    
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
            local length = math.sqrt(dx * dx + dy * dy)
            
            drawingObj.Size = UDim2.fromOffset(length, properties.Thickness)
            drawingObj.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
            drawingObj.Rotation = math.deg(math.atan2(dy, dx))
            drawingObj.BackgroundTransparency = 1 - properties.Transparency
            drawingObj.BackgroundColor3 = properties.Color
            drawingObj.AnchorPoint = Vector2.new(0.5, 0.5)  -- Override user AnchorPoint for lines
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            if k ~= "Rotation" and k ~= "AnchorPoint" then  -- Ignore Rotation and AnchorPoint for Line
                oldNewindex(t, k, v)
            end
            if k == "From" or k == "To" or k == "Thickness" or k == "Color" or k == "Transparency" then
                updateLine()
            end
        end
        
    elseif drawingType == "Square" or drawingType == "Rectangle" then
        local stroke = Instance.new("UIStroke")
        stroke.Parent = drawingObj
        stroke.Thickness = 1
        stroke.Color = Color3.new(1, 1, 1)
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Transparency = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 0)
        corner.Parent = drawingObj
        
        properties.Size = Vector2.zero
        properties.Position = Vector2.zero
        properties.Filled = true
        properties.Thickness = 1
        properties.CornerRadius = 0
        
        local updateSquare = function()
            if removed then return end
            
            drawingObj.Size = UDim2.fromOffset(properties.Size.X, properties.Size.Y)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            drawingObj.Rotation = properties.Rotation
            drawingObj.AnchorPoint = properties.AnchorPoint
            
            corner.CornerRadius = UDim.new(0, properties.CornerRadius)
            
            if properties.Filled then
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
                drawingObj.BackgroundColor3 = properties.Color
                stroke.Enabled = false
            else
                drawingObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness
                stroke.Transparency = 1 - properties.Transparency
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Size" or k == "Position" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" or k == "CornerRadius" or k == "Rotation" or k == "AnchorPoint" then
                updateSquare()
            end
        end
        
    elseif drawingType == "Circle" then
        local stroke = Instance.new("UIStroke")
        stroke.Parent = drawingObj
        stroke.Thickness = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Transparency = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = drawingObj
        
        properties.Radius = 50
        properties.Position = Vector2.zero
        properties.Filled = true
        properties.Thickness = 1
        -- NumSides not used as GUI provides perfect circle
        
        local updateCircle = function()
            if removed then return end
            
            local diameter = properties.Radius * 2
            drawingObj.Size = UDim2.fromOffset(diameter, diameter)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            drawingObj.Rotation = properties.Rotation
            drawingObj.AnchorPoint = properties.AnchorPoint
            
            if properties.Filled then
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
                drawingObj.BackgroundColor3 = properties.Color
                stroke.Enabled = false
            else
                drawingObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness
                stroke.Transparency = 1 - properties.Transparency
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Radius" or k == "Position" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" or k == "Rotation" or k == "AnchorPoint" then
                updateCircle()
            end
        end
        
    elseif drawingType == "Triangle" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("Frame")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Size = UDim2.fromOffset(100, 100)
        drawingObj.Parent = UI
        
        local point1Frame = Instance.new("Frame")
        point1Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        point1Frame.BackgroundColor3 = Color3.new(1, 1, 1)
        point1Frame.BorderSizePixel = 0
        point1Frame.Parent = drawingObj
        
        local point2Frame = Instance.new("Frame")
        point2Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        point2Frame.BackgroundColor3 = Color3.new(1, 1, 1)
        point2Frame.BorderSizePixel = 0
        point2Frame.Parent = drawingObj
        
        local point3Frame = Instance.new("Frame")
        point3Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        point3Frame.BackgroundColor3 = Color3.new(1, 1, 1)
        point3Frame.BorderSizePixel = 0
        point3Frame.Parent = drawingObj
        
        properties.PointA = Vector2.zero
        properties.PointB = Vector2.new(50, 100)
        properties.PointC = Vector2.new(100, 0)
        properties.Thickness = 1
        -- Filled removed as proper filling is not supported with GUI elements
        
        local updateTriangle = function()
            if removed then return end
            
            local pA = properties.PointA
            local pB = properties.PointB
            local pC = properties.PointC
            
            local minX = math.min(pA.X, pB.X, pC.X)
            local minY = math.min(pA.Y, pB.Y, pC.Y)
            local maxX = math.max(pA.X, pB.X, pC.X)
            local maxY = math.max(pA.Y, pB.Y, pC.Y)
            
            drawingObj.Position = UDim2.fromOffset(minX, minY)
            drawingObj.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
            drawingObj.Rotation = properties.Rotation
            drawingObj.AnchorPoint = properties.AnchorPoint
            
            local function drawLine(frame, p1, p2)
                local dx = p2.X - p1.X
                local dy = p2.Y - p1.Y
                local length = math.sqrt(dx * dx + dy * dy)
                
                frame.Size = UDim2.fromOffset(length, properties.Thickness)
                frame.Position = UDim2.fromOffset((p1.X + p2.X) / 2 - minX, (p1.Y + p2.Y) / 2 - minY)
                frame.Rotation = math.deg(math.atan2(dy, dx))
                frame.BackgroundColor3 = properties.Color
                frame.BackgroundTransparency = 1 - properties.Transparency
            end
            
            drawingObj.BackgroundTransparency = 1
            
            drawLine(point1Frame, pA, pB)
            drawLine(point2Frame, pB, pC)
            drawLine(point3Frame, pC, pA)
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            if k == "Filled" then
                warn("Filled not supported for Triangle")
                return
            end
            oldNewindex(t, k, v)
            if k == "PointA" or k == "PointB" or k == "PointC" or k == "Thickness" or k == "Color" or k == "Transparency" or k == "Rotation" or k == "AnchorPoint" then
                updateTriangle()
            end
        end
        
    elseif drawingType == "Quad" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("Frame")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Size = UDim2.fromOffset(100, 100)
        drawingObj.Parent = UI
        
        local line1 = Instance.new("Frame")
        line1.AnchorPoint = Vector2.new(0.5, 0.5)
        line1.BackgroundColor3 = Color3.new(1, 1, 1)
        line1.BorderSizePixel = 0
        line1.Parent = drawingObj
        
        local line2 = Instance.new("Frame")
        line2.AnchorPoint = Vector2.new(0.5, 0.5)
        line2.BackgroundColor3 = Color3.new(1, 1, 1)
        line2.BorderSizePixel = 0
        line2.Parent = drawingObj
        
        local line3 = Instance.new("Frame")
        line3.AnchorPoint = Vector2.new(0.5, 0.5)
        line3.BackgroundColor3 = Color3.new(1, 1, 1)
        line3.BorderSizePixel = 0
        line3.Parent = drawingObj
        
        local line4 = Instance.new("Frame")
        line4.AnchorPoint = Vector2.new(0.5, 0.5)
        line4.BackgroundColor3 = Color3.new(1, 1, 1)
        line4.BorderSizePixel = 0
        line4.Parent = drawingObj
        
        properties.PointA = Vector2.zero
        properties.PointB = Vector2.new(100, 0)
        properties.PointC = Vector2.new(100, 100)
        properties.PointD = Vector2.new(0, 100)
        properties.Thickness = 1
        -- Filled removed as proper filling is not supported with GUI elements
        
        local updateQuad = function()
            if removed then return end
            
            local pA = properties.PointA
            local pB = properties.PointB
            local pC = properties.PointC
            local pD = properties.PointD
            
            local minX = math.min(pA.X, pB.X, pC.X, pD.X)
            local minY = math.min(pA.Y, pB.Y, pC.Y, pD.Y)
            local maxX = math.max(pA.X, pB.X, pC.X, pD.X)
            local maxY = math.max(pA.Y, pB.Y, pC.Y, pD.Y)
            
            drawingObj.Position = UDim2.fromOffset(minX, minY)
            drawingObj.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
            drawingObj.Rotation = properties.Rotation
            drawingObj.AnchorPoint = properties.AnchorPoint
            
            local function drawLine(frame, p1, p2)
                local dx = p2.X - p1.X
                local dy = p2.Y - p1.Y
                local length = math.sqrt(dx * dx + dy * dy)
                
                frame.Size = UDim2.fromOffset(length, properties.Thickness)
                frame.Position = UDim2.fromOffset((p1.X + p2.X) / 2 - minX, (p1.Y + p2.Y) / 2 - minY)
                frame.Rotation = math.deg(math.atan2(dy, dx))
                frame.BackgroundColor3 = properties.Color
                frame.BackgroundTransparency = 1 - properties.Transparency
            end
            
            drawingObj.BackgroundTransparency = 1
            
            drawLine(line1, pA, pB)
            drawLine(line2, pB, pC)
            drawLine(line3, pC, pD)
            drawLine(line4, pD, pA)
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            if k == "Filled" then
                warn("Filled not supported for Quad")
                return
            end
            oldNewindex(t, k, v)
            if k == "PointA" or k == "PointB" or k == "PointC" or k == "PointD" or k == "Thickness" or k == "Color" or k == "Transparency" or k == "Rotation" or k == "AnchorPoint" then
                updateQuad()
            end
        end
        
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
        properties.Size = Vector2.new(0, 0)  -- If non-zero, sets fixed size with wrapping
        properties.TextWrapped = false
        properties.Center = false
        properties.Outline = false
        properties.OutlineColor = Color3.new(0, 0, 0)
        properties.Position = Vector2.zero
        properties.Font = 2
        properties.TextBounds = Vector2.zero
        
        local updateText = function()
            if removed then return end
            
            drawingObj.Text = tostring(properties.Text)
            drawingObj.TextSize = properties.Size.Y > 0 and properties.Size.Y or 13  -- Use Size.Y as text size if set
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            drawingObj.TextColor3 = properties.Color
            drawingObj.TextTransparency = 1 - properties.Transparency
            drawingObj.Font = Fonts[properties.Font] or Enum.Font.Code
            drawingObj.Rotation = properties.Rotation
            drawingObj.AnchorPoint = properties.AnchorPoint
            
            if properties.Center then
                drawingObj.TextXAlignment = Enum.TextXAlignment.Center
                drawingObj.TextYAlignment = Enum.TextYAlignment.Center
            else
                drawingObj.TextXAlignment = Enum.TextXAlignment.Left
                drawingObj.TextYAlignment = Enum.TextYAlignment.Top
            end
            
            if properties.Outline then
                drawingObj.TextStrokeTransparency = 0
                drawingObj.TextStrokeColor3 = properties.OutlineColor
            else
                drawingObj.TextStrokeTransparency = 1
            end
            
            if properties.Size ~= Vector2.new(0, 0) then
                drawingObj.Size = UDim2.fromOffset(properties.Size.X, properties.Size.Y)
                drawingObj.AutomaticSize = Enum.AutomaticSize.None
                drawingObj.TextWrapped = properties.TextWrapped
            else
                drawingObj.AutomaticSize = Enum.AutomaticSize.XY
                drawingObj.TextWrapped = false
            end
            
            game:GetService("RunService").RenderStepped:Wait()
            properties.TextBounds = drawingObj.TextBounds
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k ~= "TextBounds" then
                task.spawn(updateText)
            end
        end
        
    elseif drawingType == "Image" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("ImageLabel")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Parent = UI
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 0)
        corner.Parent = drawingObj
        
        properties.Data = ""
        properties.Size = Vector2.zero
        properties.Position = Vector2.zero
        properties.Rounding = 0
        
        local updateImage = function()
            if removed then return end
            
            drawingObj.Image = properties.Data
            drawingObj.Size = UDim2.fromOffset(properties.Size.X, properties.Size.Y)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            drawingObj.ImageTransparency = 1 - properties.Transparency
            drawingObj.ImageColor3 = properties.Color
            drawingObj.Rotation = properties.Rotation
            drawingObj.AnchorPoint = properties.AnchorPoint
            
            corner.CornerRadius = UDim.new(0, properties.Rounding)
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Data" or k == "Size" or k == "Position" or k == "Transparency" or k == "Color" or k == "Rounding" or k == "Rotation" or k == "AnchorPoint" then
                updateImage()
            end
        end
    end
    
    return self
end

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
