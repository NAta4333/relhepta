-- ============================================
-- COMPLETE FIXED DRAWING LIBRARY
-- ============================================

local DrawingCache = {}
local DrawingObjects = {}
local ActiveObjects = setmetatable({}, {__mode = "k"})  -- Weak references for GC

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

local function toVector2(v)
    if typeof(v) == "Vector2" then return v end
    return Vector2.new(0, 0)
end

local function toUDim2(v)
    if typeof(v) == "Vector2" then
        return UDim2.fromOffset(v.X, v.Y)
    end
    return UDim2.new()
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
        AnchorPoint = Vector2.new(0, 0),
        FadeDuration = 0.25,
        Dashed = false,
        DashLength = 6,
        GapLength = 4
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
        properties[key] = value
    end
    
    mt.__tostring = function()
        return string.format("Drawing (%s)", drawingType)
    end
    
    mt.__metatable = "The metatable is locked"
    
    -- Remove function - CRITICAL FIX
    properties.Remove = function()
        if removed then return end
        
        removed = true
        
        -- Destroy the GUI element
        if drawingObj and drawingObj.Parent then
            pcall(function()
                drawingObj:Destroy()
            end)
        end
        
        -- Remove from ActiveObjects tracking
        ActiveObjects[self] = nil
        DrawingObjects[self] = nil
        
        -- Remove from cache by searching through array
        for i = #DrawingCache, 1, -1 do
            local entry = DrawingCache[i]
            if entry and entry.proxy == self then
                table.remove(DrawingCache, i)
                break
            end
        end
    end
    
    properties.Destroy = properties.Remove
    
    -- Track in cache
    table.insert(DrawingCache, {proxy = self, instance = drawingObj, type = drawingType})
    DrawingObjects[self] = true
    ActiveObjects[self] = true
    
    -- ===== LINE =====
    if drawingType == "Line" then
        drawingObj.AnchorPoint = Vector2.new(0.5, 0.5)
        
        properties.From = Vector2.zero
        properties.To = Vector2.zero
        properties.Thickness = 1
        
        local function updateLine()
            if removed then return end
            
            local from = toVector2(properties.From)
            local to = toVector2(properties.To)
            local dx = to.X - from.X
            local dy = to.Y - from.Y
            local length = math.sqrt(dx * dx + dy * dy)
            
            if length < 0.1 then return end
            
            drawingObj.Size = UDim2.fromOffset(length, properties.Thickness)
            drawingObj.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
            drawingObj.Rotation = math.deg(math.atan2(dy, dx))
            drawingObj.BackgroundTransparency = 1 - properties.Transparency
            drawingObj.BackgroundColor3 = properties.Color
            drawingObj.ZIndex = properties.ZIndex
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "From" or k == "To" or k == "Thickness" or k == "Color" or k == "Transparency" or k == "ZIndex" then
                updateLine()
            end
        end
        
        updateLine()
        
    -- ===== RECTANGLE/SQUARE =====
    elseif drawingType == "Square" or drawingType == "Rectangle" then
        local stroke = Instance.new("UIStroke")
        stroke.Parent = drawingObj
        stroke.Thickness = 1
        stroke.Color = Color3.new(1, 1, 1)
        
        properties.Position = Vector2.zero
        properties.Size = Vector2.new(100, 100)
        properties.Filled = false
        properties.Thickness = 1
        properties.CornerRadius = 0
        
        local function updateRect()
            if removed then return end
            
            drawingObj.Size = toUDim2(properties.Size)
            drawingObj.Position = toUDim2(properties.Position)
            drawingObj.Rotation = properties.Rotation or 0
            drawingObj.AnchorPoint = properties.AnchorPoint or Vector2.new(0, 0)
            
            if properties.Filled then
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
                drawingObj.BackgroundColor3 = properties.Color
                stroke.Enabled = false
            else
                drawingObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness or 1
                stroke.Transparency = 1 - properties.Transparency
            end
            
            drawingObj.ZIndex = properties.ZIndex or 1
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Position" or k == "Size" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" or k == "ZIndex" or k == "Rotation" or k == "AnchorPoint" then
                updateRect()
            end
        end
        
        updateRect()
        
    -- ===== CIRCLE =====
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
        
        local function updateCircle()
            if removed then return end
            
            local diameter = (properties.Radius or 50) * 2
            drawingObj.Size = UDim2.fromOffset(diameter, diameter)
            drawingObj.Position = UDim2.fromOffset((properties.Position.X or 0) - (properties.Radius or 50), (properties.Position.Y or 0) - (properties.Radius or 50))
            drawingObj.Rotation = properties.Rotation or 0
            
            if properties.Filled then
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
                drawingObj.BackgroundColor3 = properties.Color
                stroke.Enabled = false
            else
                drawingObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness or 1
                stroke.Transparency = 1 - properties.Transparency
            end
            
            drawingObj.ZIndex = properties.ZIndex or 1
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Radius" or k == "Position" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" or k == "ZIndex" or k == "Rotation" then
                updateCircle()
            end
        end
        
        updateCircle()
        
    -- ===== TEXT =====
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
        
        local function updateText()
            if removed then return end
            
            drawingObj.Text = tostring(properties.Text)
            drawingObj.TextSize = properties.Size or 13
            drawingObj.Position = toUDim2(properties.Position)
            drawingObj.TextColor3 = properties.Color
            drawingObj.TextTransparency = 1 - properties.Transparency
            drawingObj.Font = Fonts[properties.Font or 2] or Enum.Font.Code
            drawingObj.Rotation = properties.Rotation or 0
            drawingObj.ZIndex = properties.ZIndex or 1
            
            if properties.Center then
                drawingObj.TextXAlignment = Enum.TextXAlignment.Center
                drawingObj.TextYAlignment = Enum.TextYAlignment.Center
            else
                drawingObj.TextXAlignment = Enum.TextXAlignment.Left
                drawingObj.TextYAlignment = Enum.TextYAlignment.Top
            end
            
            if properties.Outline then
                drawingObj.TextStrokeTransparency = 1 - properties.Transparency
                drawingObj.TextStrokeColor3 = properties.OutlineColor
                drawingObj.TextStrokeSize = properties.OutlineSize or 1
            else
                drawingObj.TextStrokeTransparency = 1
            end
            
            properties.TextBounds = drawingObj.TextBounds
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k ~= "TextBounds" then
                updateText()
            end
        end
        
        updateText()
        
    -- ===== IMAGE =====
    elseif drawingType == "Image" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("ImageLabel")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Parent = UI
        
        properties.Data = ""
        properties.Size = Vector2.zero
        properties.Position = Vector2.zero
        
        local function updateImage()
            if removed then return end
            
            drawingObj.Image = properties.Data or ""
            drawingObj.Size = toUDim2(properties.Size)
            drawingObj.Position = toUDim2(properties.Position)
            drawingObj.ImageTransparency = 1 - properties.Transparency
            drawingObj.ImageColor3 = properties.Color
            drawingObj.Rotation = properties.Rotation or 0
            drawingObj.ZIndex = properties.ZIndex or 1
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Data" or k == "Size" or k == "Position" or k == "Transparency" or k == "Color" or k == "ZIndex" or k == "Rotation" then
                updateImage()
            end
        end
        
        updateImage()
        
    -- ===== TRIANGLE =====
    elseif drawingType == "Triangle" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("Frame")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Size = UDim2.fromOffset(100, 100)
        drawingObj.Parent = UI
        
        properties.PointA = Vector2.new(0, 0)
        properties.PointB = Vector2.new(50, 100)
        properties.PointC = Vector2.new(100, 0)
        properties.Filled = false
        properties.Thickness = 1
        
        local lines = {}
        
        local function updateTriangle()
            if removed then return end
            
            for _, line in ipairs(lines) do
                if line and line.Parent then
                    line:Destroy()
                end
            end
            lines = {}
            
            local pA = toVector2(properties.PointA)
            local pB = toVector2(properties.PointB)
            local pC = toVector2(properties.PointC)
            
            local minX = math.min(pA.X, pB.X, pC.X)
            local minY = math.min(pA.Y, pB.Y, pC.Y)
            
            drawingObj.Position = UDim2.fromOffset(minX, minY)
            drawingObj.Size = UDim2.fromOffset(
                math.max(pA.X, pB.X, pC.X) - minX,
                math.max(pA.Y, pB.Y, pC.Y) - minY
            )
            
            if not properties.Filled then
                for _, pt_pair in ipairs({{pA, pB}, {pB, pC}, {pC, pA}}) do
                    local p1, p2 = pt_pair[1], pt_pair[2]
                    local dx = p2.X - p1.X
                    local dy = p2.Y - p1.Y
                    local len = math.sqrt(dx * dx + dy * dy)
                    
                    local line = Instance.new("Frame")
                    line.AnchorPoint = Vector2.new(0.5, 0.5)
                    line.BackgroundColor3 = properties.Color
                    line.BackgroundTransparency = 1 - properties.Transparency
                    line.BorderSizePixel = 0
                    line.Size = UDim2.fromOffset(len, properties.Thickness or 1)
                    line.Position = UDim2.fromOffset((p1.X + p2.X) / 2 - minX, (p1.Y + p2.Y) / 2 - minY)
                    line.Rotation = math.deg(math.atan2(dy, dx))
                    line.ZIndex = properties.ZIndex or 1
                    line.Parent = drawingObj
                    
                    table.insert(lines, line)
                end
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k:match("^Point") or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" or k == "ZIndex" then
                updateTriangle()
            end
        end
        
        updateTriangle()
        
    -- ===== QUAD =====
    elseif drawingType == "Quad" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("Frame")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Size = UDim2.fromOffset(100, 100)
        drawingObj.Parent = UI
        
        properties.PointA = Vector2.new(0, 0)
        properties.PointB = Vector2.new(100, 0)
        properties.PointC = Vector2.new(100, 100)
        properties.PointD = Vector2.new(0, 100)
        properties.Filled = false
        properties.Thickness = 1
        
        local lines = {}
        
        local function updateQuad()
            if removed then return end
            
            for _, line in ipairs(lines) do
                if line and line.Parent then
                    line:Destroy()
                end
            end
            lines = {}
            
            local pA = toVector2(properties.PointA)
            local pB = toVector2(properties.PointB)
            local pC = toVector2(properties.PointC)
            local pD = toVector2(properties.PointD)
            
            local minX = math.min(pA.X, pB.X, pC.X, pD.X)
            local minY = math.min(pA.Y, pB.Y, pC.Y, pD.Y)
            
            drawingObj.Position = UDim2.fromOffset(minX, minY)
            drawingObj.Size = UDim2.fromOffset(
                math.max(pA.X, pB.X, pC.X, pD.X) - minX,
                math.max(pA.Y, pB.Y, pC.Y, pD.Y) - minY
            )
            
            if not properties.Filled then
                for _, pt_pair in ipairs({{pA, pB}, {pB, pC}, {pC, pD}, {pD, pA}}) do
                    local p1, p2 = pt_pair[1], pt_pair[2]
                    local dx = p2.X - p1.X
                    local dy = p2.Y - p1.Y
                    local len = math.sqrt(dx * dx + dy * dy)
                    
                    local line = Instance.new("Frame")
                    line.AnchorPoint = Vector2.new(0.5, 0.5)
                    line.BackgroundColor3 = properties.Color
                    line.BackgroundTransparency = 1 - properties.Transparency
                    line.BorderSizePixel = 0
                    line.Size = UDim2.fromOffset(len, properties.Thickness or 1)
                    line.Position = UDim2.fromOffset((p1.X + p2.X) / 2 - minX, (p1.Y + p2.Y) / 2 - minY)
                    line.Rotation = math.deg(math.atan2(dy, dx))
                    line.ZIndex = properties.ZIndex or 1
                    line.Parent = drawingObj
                    
                    table.insert(lines, line)
                end
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k:match("^Point") or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" or k == "ZIndex" then
                updateQuad()
            end
        end
        
        updateQuad()
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
    -- Create a copy to avoid modification during iteration
    local cacheToRemove = {}
    for i = #DrawingCache, 1, -1 do
        local data = DrawingCache[i]
        if data and data.proxy then
            table.insert(cacheToRemove, data.proxy)
        end
    end
    
    -- Remove all objects
    for _, proxy in ipairs(cacheToRemove) do
        pcall(function()
            proxy:Remove()
        end)
    end
    
    -- Clear all references
    DrawingCache = {}
    DrawingObjects = {}
    ActiveObjects = setmetatable({}, {__mode = "k"})
end

getgenv().getrenderproperty = function(obj, prop)
    if not isrenderobj(obj) then
        return nil
    end
    return obj[prop]
end

getgenv().setrenderproperty = function(obj, prop, value)
    if not isrenderobj(obj) then
        return
    end
    obj[prop] = value
end

print("[Drawing Library] Successfully initialized!")
