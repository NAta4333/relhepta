-- Improved Drawing Library (2025–2026 edition)
-- Features: gradients, fade animation, auto Vector2→UDim2, reliable TextBounds, etc.

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

local TweenService   = game:GetService("TweenService")
local TextService    = game:GetService("TextService")
local RunService     = game:GetService("RunService")
local Players        = game:GetService("Players")

local function gethui()
    local success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    return success and result or Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
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
        UI = 0, System = 1, Plex = 2, Monospace = 3,
        SourceSans = 4, Legacy = 5, Code = 6,
        Highway = 7, Fantasy = 8, Arcade = 9
    }
}

local function isVector2(v) return typeof(v) == "Vector2" end

local function toUDim2(v)
    if isVector2(v) then return UDim2.fromOffset(v.X, v.Y) end
    return v
end

local function createGradient(colors)
    if typeof(colors) == "Color3" then return nil end
    if type(colors) ~= "table" or #colors < 2 then return nil end
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = 90  -- можно сделать настраиваемым позже
    return gradient
end

Drawing.new = function(drawingType)
    if type(drawingType) ~= "string" then
        error("Drawing.new: argument must be a string", 2)
    end

    local validTypes = {Line=true, Square=true, Rectangle=true, Circle=true, Text=true, Image=true, Triangle=true, Quad=true}
    if not validTypes[drawingType] then
        error("Drawing.new: invalid type '" .. drawingType .. "'", 2)
    end

    local mainObj = Instance.new("Frame")
    mainObj.BackgroundTransparency = 1
    mainObj.BorderSizePixel = 0
    mainObj.Size = UDim2.new()
    mainObj.Position = UDim2.new()
    mainObj.Parent = UI

    local properties = {
        Visible       = true,
        Color         = Color3.new(1,1,1),     -- Color3 | {Color3, Color3, ...}
        Transparency  = 0,                      -- 0 = opaque, 1 = transparent
        ZIndex        = 1,
        Rotation      = 0,
        AnchorPoint   = Vector2.new(0,0),
        FadeDuration  = 0.25,
    }

    local self = newproxy(true)
    local mt = getmetatable(self)
    local removed = false

    local fadeTweenInfo = TweenInfo.new(properties.FadeDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

    local function updateFade()
        local targetTrans = properties.Visible and (1 - properties.Transparency) or 1
        local tween = TweenService:Create(mainObj, fadeTweenInfo, {BackgroundTransparency = targetTrans})
        tween:Play()
    end

    mt.__index = function(_, key)
        if key == "__OBJECT_EXISTS" then return not removed end
        if key == "Transparency" then return properties.Transparency end
        if key == "Visible" then return properties.Visible end
        return properties[key]
    end

    mt.__newindex = function(_, key, value)
        if removed then return end

        if key == "Visible" then
            properties.Visible = not not value
            mainObj.Visible = true
            updateFade()
        elseif key == "Transparency" then
            properties.Transparency = math.clamp(value, 0, 1)
            if properties.Visible then
                mainObj.BackgroundTransparency = 1 - properties.Transparency
            end
        elseif key == "Color" then
            properties.Color = value
        elseif key == "ZIndex" then
            mainObj.ZIndex = value
        elseif key == "Rotation" then
            mainObj.Rotation = value
        elseif key == "AnchorPoint" then
            mainObj.AnchorPoint = value
        elseif key == "FadeDuration" then
            properties.FadeDuration = math.max(0, value or 0.25)
            fadeTweenInfo = TweenInfo.new(properties.FadeDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        else
            properties[key] = value
        end
    end

    mt.__tostring = function() return "Drawing" end
    mt.__metatable = "The metatable is locked"

    properties.Remove = function()
        if removed then return end
        removed = true
        if mainObj and mainObj.Parent then mainObj:Destroy() end
        for i = #DrawingCache, 1, -1 do
            if DrawingCache[i].proxy == self then
                table.remove(DrawingCache, i)
                break
            end
        end
        DrawingObjects[self] = nil
    end
    properties.Destroy = properties.Remove

    -- Метод для получения экранных координат центра объекта
    properties.GetScreenPosition = function()
        if removed or not mainObj.AbsolutePosition then return Vector2.zero end
        local absPos = mainObj.AbsolutePosition
        local absSize = mainObj.AbsoluteSize
        return absPos + absSize / 2
    end

    table.insert(DrawingCache, {proxy = self, instance = mainObj})
    DrawingObjects[self] = true

    if drawingType == "Line" then
        mainObj.AnchorPoint = Vector2.new(0.5, 0.5)

        properties.From     = Vector2.zero
        properties.To       = Vector2.zero
        properties.Thickness = 1

        local update = function()
            if removed then return end
            local f, t = properties.From, properties.To
            local dx, dy = t.X - f.X, t.Y - f.Y
            local len = math.sqrt(dx*dx + dy*dy)

            mainObj.Size = UDim2.fromOffset(len, properties.Thickness)
            mainObj.Position = toUDim2((f + t)/2)
            mainObj.Rotation = math.deg(math.atan2(dy, dx))
            mainObj.BackgroundColor3 = properties.Color
            mainObj.BackgroundTransparency = properties.Visible and (1 - properties.Transparency) or 1
        end

        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "From" or k == "To" or k == "Thickness" or k == "Color" or k == "Transparency" or k == "Visible" then
                update()
            end
        end

        update()

    elseif drawingType == "Square" or drawingType == "Rectangle" then
        local stroke = Instance.new("UIStroke", mainObj)
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Transparency = 0

        local corner = Instance.new("UICorner", mainObj)

        properties.Position = Vector2.zero
        properties.Size     = Vector2.new(100, 100)
        properties.Filled   = true
        properties.Thickness = 1
        properties.CornerRadius = 0

        local update = function()
            mainObj.Position = toUDim2(properties.Position)
            mainObj.Size     = toUDim2(properties.Size)
            mainObj.Rotation = properties.Rotation
            mainObj.AnchorPoint = properties.AnchorPoint
            corner.CornerRadius = UDim.new(0, properties.CornerRadius)

            if properties.Filled then
                mainObj.BackgroundColor3 = properties.Color
                mainObj.BackgroundTransparency = properties.Visible and (1 - properties.Transparency) or 1
                stroke.Enabled = false
            else
                mainObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness
                stroke.Transparency = properties.Visible and (1 - properties.Transparency) or 1
            end

            local grad = createGradient(properties.Color)
            if grad then
                grad.Parent = mainObj
                mainObj.BackgroundColor3 = Color3.new(1,1,1) -- градиент перехватывает
            elseif mainObj:FindFirstChildOfClass("UIGradient") then
                mainObj:FindFirstChildOfClass("UIGradient"):Destroy()
            end
        end

        local old = mt.__newindex
        mt.__newindex = function(t,k,v)
            old(t,k,v)
            if k=="Position" or k=="Size" or k=="Filled" or k=="Thickness" or k=="Color" or
               k=="Transparency" or k=="CornerRadius" or k=="Rotation" or k=="AnchorPoint" or k=="Visible" then
                update()
            end
        end

        update()

    elseif drawingType == "Circle" then
        local stroke = Instance.new("UIStroke", mainObj)
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local corner = Instance.new("UICorner", mainObj)
        corner.CornerRadius = UDim.new(0.5, 0)

        properties.Position = Vector2.zero
        properties.Radius   = 50
        properties.Filled   = true
        properties.Thickness = 1

        local update = function()
            local diam = properties.Radius * 2
            mainObj.Size = UDim2.fromOffset(diam, diam)
            mainObj.Position = toUDim2(properties.Position - Vector2.new(properties.Radius, properties.Radius))
            mainObj.Rotation = properties.Rotation
            mainObj.AnchorPoint = properties.AnchorPoint

            if properties.Filled then
                mainObj.BackgroundColor3 = properties.Color
                mainObj.BackgroundTransparency = properties.Visible and (1 - properties.Transparency) or 1
                stroke.Enabled = false
            else
                mainObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness
                stroke.Transparency = properties.Visible and (1 - properties.Transparency) or 1
            end

            local grad = createGradient(properties.Color)
            if grad then grad.Parent = mainObj end
        end

        local old = mt.__newindex
        mt.__newindex = function(t,k,v)
            old(t,k,v)
            if k=="Radius" or k=="Position" or k=="Filled" or k=="Thickness" or k=="Color" or
               k=="Transparency" or k=="Rotation" or k=="AnchorPoint" or k=="Visible" then
                update()
            end
        end

        update()

    elseif drawingType == "Text" then
        mainObj:Destroy()
        mainObj = Instance.new("TextLabel")
        mainObj.BackgroundTransparency = 1
        mainObj.BorderSizePixel = 0
        mainObj.AutomaticSize = Enum.AutomaticSize.XY
        mainObj.TextXAlignment = Enum.TextXAlignment.Left
        mainObj.TextYAlignment = Enum.TextYAlignment.Top
        mainObj.Parent = UI

        properties.Text         = ""
        properties.Position     = Vector2.zero
        properties.Size         = Vector2.new(0, 13)   -- если X>0 и Y>0 → фиксированный размер + wrap
        properties.Font         = 2
        properties.Center       = false
        properties.Outline      = false
        properties.OutlineColor = Color3.new(0,0,0)
        properties.TextWrapped  = false

        local function updateBounds()
            if properties.Size.X <= 0 or properties.Size.Y <= 0 then
                mainObj.AutomaticSize = Enum.AutomaticSize.XY
                mainObj.TextWrapped = false
            else
                mainObj.Size = toUDim2(properties.Size)
                mainObj.AutomaticSize = Enum.AutomaticSize.None
                mainObj.TextWrapped = properties.TextWrapped
            end

            local font = Fonts[properties.Font] or Enum.Font.Code
            local textSize = properties.Size.Y > 0 and properties.Size.Y or 13

            local params = GetTextBoundsParams.new()
            params.Text = tostring(properties.Text)
            params.Font = font
            params.TextSize = textSize
            params.Width = properties.Size.X > 0 and properties.Size.X or math.huge

            local bounds = TextService:GetTextSizeAsync(params)
            properties.TextBounds = bounds
        end

        local update = function()
            mainObj.Text = tostring(properties.Text)
            mainObj.TextSize = properties.Size.Y > 0 and properties.Size.Y or 13
            mainObj.Position = toUDim2(properties.Position)
            mainObj.TextColor3 = properties.Color
            mainObj.TextTransparency = properties.Visible and (1 - properties.Transparency) or 1
            mainObj.Font = Fonts[properties.Font] or Enum.Font.Code
            mainObj.Rotation = properties.Rotation
            mainObj.AnchorPoint = properties.AnchorPoint

            if properties.Center then
                mainObj.TextXAlignment = Enum.TextXAlignment.Center
                mainObj.TextYAlignment = Enum.TextYAlignment.Center
            else
                mainObj.TextXAlignment = Enum.TextXAlignment.Left
                mainObj.TextYAlignment = Enum.TextYAlignment.Top
            end

            if properties.Outline then
                mainObj.TextStrokeTransparency = 0
                mainObj.TextStrokeColor3 = properties.OutlineColor
            else
                mainObj.TextStrokeTransparency = 1
            end

            updateBounds()
        end

        local old = mt.__newindex
        mt.__newindex = function(t,k,v)
            old(t,k,v)
            if k ~= "TextBounds" then
                task.spawn(update)  -- асинхронно, чтобы не блокировать
            end
        end

        update()

    elseif drawingType == "Image" then
        mainObj:Destroy()
        mainObj = Instance.new("ImageLabel")
        mainObj.BackgroundTransparency = 1
        mainObj.BorderSizePixel = 0
        mainObj.Parent = UI

        local corner = Instance.new("UICorner", mainObj)

        properties.Data     = ""
        properties.Size     = Vector2.new(100, 100)
        properties.Position = Vector2.zero
        properties.Rounding = 0

        local update = function()
            mainObj.Image = properties.Data
            mainObj.Size = toUDim2(properties.Size)
            mainObj.Position = toUDim2(properties.Position)
            mainObj.ImageTransparency = properties.Visible and (1 - properties.Transparency) or 1
            mainObj.ImageColor3 = properties.Color
            mainObj.Rotation = properties.Rotation
            mainObj.AnchorPoint = properties.AnchorPoint
            corner.CornerRadius = UDim.new(0, properties.Rounding)
        end

        local old = mt.__newindex
        mt.__newindex = function(t,k,v)
            old(t,k,v)
            if k=="Data" or k=="Size" or k=="Position" or k=="Transparency" or k=="Color" or
               k=="Rounding" or k=="Rotation" or k=="AnchorPoint" or k=="Visible" then
                update()
            end
        end

        update()

    elseif drawingType == "Triangle" or drawingType == "Quad" then
        -- Оставляем только контур (Filled не поддерживается надёжно)
        -- Если нужен Filled → используй ImageLabel с заранее подготовленным изображением

        mainObj.BackgroundTransparency = 1

        local lines = {}
        local pointCount = (drawingType == "Triangle") and 3 or 4

        for i = 1, pointCount do
            local ln = Instance.new("Frame")
            ln.AnchorPoint = Vector2.new(0.5, 0.5)
            ln.BackgroundColor3 = Color3.new(1,1,1)
            ln.BorderSizePixel = 0
            ln.Parent = mainObj
            lines[i] = ln
        end

        for k, v in pairs({"PointA","PointB","PointC","PointD"}) do
            properties[v] = (k <= pointCount) and Vector2.zero or nil
        end
        properties.Thickness = 1

        local function getPoints()
            if drawingType == "Triangle" then
                return {properties.PointA, properties.PointB, properties.PointC}
            else
                return {properties.PointA, properties.PointB, properties.PointC, properties.PointD}
            end
        end

        local update = function()
            local pts = getPoints()
            local minX, minY = math.huge, math.huge
            local maxX, maxY = -math.huge, -math.huge

            for _, p in ipairs(pts) do
                minX = math.min(minX, p.X)
                minY = math.min(minY, p.Y)
                maxX = math.max(maxX, p.X)
                maxY = math.max(maxY, p.Y)
            end

            mainObj.Position = UDim2.fromOffset(minX, minY)
            mainObj.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
            mainObj.Rotation = properties.Rotation
            mainObj.AnchorPoint = properties.AnchorPoint

            if properties.Filled then
                warn("Filled not supported for " .. drawingType .. " (use Image instead)")
            end

            for i = 1, pointCount do
                local p1 = pts[i]
                local p2 = pts[(i % pointCount) + 1]

                local dx = p2.X - p1.X
                local dy = p2.Y - p1.Y
                local len = math.sqrt(dx*dx + dy*dy)

                local ln = lines[i]
                ln.Size = UDim2.fromOffset(len, properties.Thickness)
                ln.Position = toUDim2(Vector2.new((p1.X + p2.X)/2, (p1.Y + p2.Y)/2) - Vector2.new(minX, minY))
                ln.Rotation = math.deg(math.atan2(dy, dx))
                ln.BackgroundColor3 = properties.Color
                ln.BackgroundTransparency = properties.Visible and (1 - properties.Transparency) or 1
            end
        end

        local old = mt.__newindex
        mt.__newindex = function(t,k,v)
            old(t,k,v)
            if (k:match("^Point") or k=="Thickness" or k=="Color" or k=="Transparency" or
                k=="Rotation" or k=="AnchorPoint" or k=="Visible" or k=="Filled") then
                update()
            end
        end

        update()
    end

    return self
end

getgenv().Drawing = Drawing

getgenv().isrenderobj = function(obj)
    if type(obj) ~= "userdata" then return false end
    local s, ex = pcall(function() return obj.__OBJECT_EXISTS end)
    return s and ex == true
end

getgenv().cleardrawcache = function()
    for i = #DrawingCache, 1, -1 do
        pcall(function() DrawingCache[i].proxy:Remove() end)
    end
    DrawingCache = {}
    DrawingObjects = {}
end

getgenv().getrenderproperty  = function(obj, prop) return isrenderobj(obj) and obj[prop] or nil end
getgenv().setrenderproperty  = function(obj, prop, val) if isrenderobj(obj) then obj[prop] = val end end
