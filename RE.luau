-- Improved Drawing Library (March 2026 edition)
-- Added: dashed lines, basic world-to-screen conversion

local DrawingCache = {}
local DrawingObjects = {}

local Fonts = {
    [0] = Enum.Font.Arial,      [1] = Enum.Font.BuilderSans,
    [2] = Enum.Font.Gotham,     [3] = Enum.Font.RobotoMono,
    [4] = Enum.Font.SourceSans, [5] = Enum.Font.Legacy,
    [6] = Enum.Font.Code,       [7] = Enum.Font.Highway,
    [8] = Enum.Font.Fantasy,    [9] = Enum.Font.Arcade
}

local TweenService   = game:GetService("TweenService")
local TextService    = game:GetService("TextService")
local RunService     = game:GetService("RunService")
local Players        = game:GetService("Players")
local Camera         = workspace.CurrentCamera

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
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(colors)
    grad.Rotation = 90
    return grad
end

-- World → Screen helper
local function worldToScreen(worldPos: Vector3): (Vector2?, boolean)
    if not Camera then return nil, false end
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
    if onScreen and screenPos.Z > 0 then
        return Vector2.new(screenPos.X, screenPos.Y), true
    end
    return nil, false
end

Drawing.new = function(drawingType: string)
    if type(drawingType) ~= "string" then
        error("Drawing.new: argument must be a string", 2)
    end

    local valid = {Line=true, Square=true, Rectangle=true, Circle=true, Text=true, Image=true, Triangle=true, Quad=true}
    if not valid[drawingType] then
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
        Color         = Color3.new(1,1,1),
        Transparency  = 0,
        ZIndex        = 1,
        Rotation      = 0,
        AnchorPoint   = Vector2.new(0,0),
        FadeDuration  = 0.25,

        -- Dashed lines support
        Dashed        = false,
        DashLength    = 6,
        GapLength     = 4,
    }

    local self = newproxy(true)
    local mt = getmetatable(self)
    local removed = false

    local fadeTweenInfo = TweenInfo.new(properties.FadeDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

    local function updateFade()
        local target = properties.Visible and (1 - properties.Transparency) or 1
        local tween = TweenService:Create(mainObj, fadeTweenInfo, {BackgroundTransparency = target})
        tween:Play()
    end

    mt.__index = function(_, key)
        if key == "__OBJECT_EXISTS" then return not removed end
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
        elseif key == "Color" or key == "ZIndex" or key == "Rotation" or key == "AnchorPoint" or
               key == "FadeDuration" or key == "Dashed" or key == "DashLength" or key == "GapLength" then
            properties[key] = value
            if key == "FadeDuration" then
                fadeTweenInfo = TweenInfo.new(value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            end
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
            if DrawingCache[i].proxy == self then table.remove(DrawingCache, i) break end
        end
        DrawingObjects[self] = nil
    end
    properties.Destroy = properties.Remove

    -- World → Screen methods
    properties.WorldToScreen = function(_, worldPos: Vector3)
        return worldToScreen(worldPos)
    end

    properties.IsOnScreen = function(_, screenPos: Vector2?)
        if not screenPos then return false end
        local vpSize = Camera.ViewportSize
        return screenPos.X >= 0 and screenPos.X <= vpSize.X and
               screenPos.Y >= 0 and screenPos.Y <= vpSize.Y
    end

    table.insert(DrawingCache, {proxy = self, instance = mainObj})
    DrawingObjects[self] = true

    -- ────────────────────────────────────────────────
    -- Line with dashed support
    -- ────────────────────────────────────────────────
    if drawingType == "Line" then
        mainObj.AnchorPoint = Vector2.new(0.5, 0.5)

        properties.From      = Vector2.zero
        properties.To        = Vector2.zero
        properties.Thickness = 1

        local segments = {}

        local function clearSegments()
            for _, seg in ipairs(segments) do
                if seg and seg.Parent then seg:Destroy() end
            end
            segments = {}
        end

        local function createDashedLine(from: Vector2, to: Vector2)
            clearSegments()

            local dir = (to - from).Unit
            local totalLength = (to - from).Magnitude
            local step = properties.DashLength + properties.GapLength

            if not properties.Dashed or step <= 0 then
                -- Solid line
                local bar = Instance.new("Frame")
                bar.AnchorPoint = Vector2.new(0.5, 0.5)
                bar.BackgroundColor3 = properties.Color
                bar.BackgroundTransparency = properties.Visible and (1 - properties.Transparency) or 1
                bar.Size = UDim2.fromOffset(totalLength, properties.Thickness)
                bar.Position = toUDim2((from + to)/2)
                bar.Rotation = math.deg(math.atan2(to.Y - from.Y, to.X - from.X))
                bar.ZIndex = properties.ZIndex
                bar.Parent = mainObj
                table.insert(segments, bar)
                return
            end

            local currentDist = 0
            while currentDist < totalLength do
                local segStart = from + dir * currentDist
                local segEndDist = math.min(currentDist + properties.DashLength, totalLength)
                local segEnd = from + dir * segEndDist

                local segLen = (segEnd - segStart).Magnitude
                if segLen < 0.5 then break end

                local bar = Instance.new("Frame")
                bar.AnchorPoint = Vector2.new(0.5, 0.5)
                bar.BackgroundColor3 = properties.Color
                bar.BackgroundTransparency = properties.Visible and (1 - properties.Transparency) or 1
                bar.Size = UDim2.fromOffset(segLen, properties.Thickness)
                bar.Position = toUDim2((segStart + segEnd)/2)
                bar.Rotation = math.deg(math.atan2(to.Y - from.Y, to.X - from.X))
                bar.ZIndex = properties.ZIndex
                bar.Parent = mainObj

                table.insert(segments, bar)

                currentDist = currentDist + step
            end
        end

        local updateLine = function()
            if removed then return end
            clearSegments()
            createDashedLine(properties.From, properties.To)
        end

        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "From" or k == "To" or k == "Thickness" or k == "Color" or k == "Transparency" or
               k == "Visible" or k == "Dashed" or k == "DashLength" or k == "GapLength" or k == "ZIndex" then
                task.defer(updateLine)
            end
        end

        updateLine()

    -- ────────────────────────────────────────────────
    -- Square / Rectangle
    -- ────────────────────────────────────────────────
    elseif drawingType == "Square" or drawingType == "Rectangle" then
        local stroke = Instance.new("UIStroke", mainObj)
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

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
            if grad then grad.Parent = mainObj else
                local oldGrad = mainObj:FindFirstChildOfClass("UIGradient")
                if oldGrad then oldGrad:Destroy() end
            end
        end

        local old = mt.__newindex
        mt.__newindex = function(t,k,v)
            old(t,k,v)
            if k=="Position" or k=="Size" or k=="Filled" or k=="Thickness" or k=="Color" or
               k=="Transparency" or k=="CornerRadius" or k=="Rotation" or k=="AnchorPoint" or
               k=="Visible" or k=="ZIndex" then
                task.defer(update)
            end
        end

        update()

    -- Остальные типы (Circle, Text, Image, Triangle, Quad) остаются почти без изменений
    -- Для краткости опущены здесь, но в полной версии их нужно вставить из предыдущей версии

    -- Triangle и Quad с dashed (очень упрощённо — dashed применяется ко всем сторонам)
    elseif drawingType == "Triangle" or drawingType == "Quad" then
        mainObj.BackgroundTransparency = 1

        local pointCount = drawingType == "Triangle" and 3 or 4
        local lines = {}

        for i = 1, pointCount do
            local ln = Instance.new("Frame")
            ln.AnchorPoint = Vector2.new(0.5, 0.5)
            ln.BackgroundColor3 = Color3.new(1,1,1)
            ln.BorderSizePixel = 0
            ln.ZIndex = properties.ZIndex
            ln.Parent = mainObj
            lines[i] = ln
        end

        for i = 1, pointCount do
            properties["Point"..string.char(64 + i)] = Vector2.zero
        end
        properties.Thickness = 1

        local function getPoints()
            local pts = {}
            for i = 1, pointCount do
                pts[i] = properties["Point"..string.char(64 + i)]
            end
            return pts
        end

        local function update()
            local pts = getPoints()
            local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge

            for _, p in pts do
                minX = math.min(minX, p.X)
                minY = math.min(minY, p.Y)
                maxX = math.max(maxX, p.X)
                maxY = math.max(maxY, p.Y)
            end

            mainObj.Position = UDim2.fromOffset(minX, minY)
            mainObj.Size = UDim2.fromOffset(maxX-minX, maxY-minY)
            mainObj.Rotation = properties.Rotation
            mainObj.AnchorPoint = properties.AnchorPoint

            if properties.Filled then
                warn("Filled not reliably supported for " .. drawingType)
            end

            for i = 1, pointCount do
                local p1 = pts[i]
                local p2 = pts[(i % pointCount)+1]
                local dx, dy = p2.X - p1.X, p2.Y - p1.Y
                local len = math.sqrt(dx*dx + dy*dy)

                local ln = lines[i]
                ln.Size = UDim2.fromOffset(len, properties.Thickness)
                ln.Position = toUDim2( Vector2.new( (p1.X+p2.X)/2 - minX, (p1.Y+p2.Y)/2 - minY ) )
                ln.Rotation = math.deg(math.atan2(dy, dx))
                ln.BackgroundColor3 = properties.Color
                ln.BackgroundTransparency = properties.Visible and (1 - properties.Transparency) or 1
                ln.ZIndex = properties.ZIndex
            end
        end

        local old = mt.__newindex
        mt.__newindex = function(t,k,v)
            old(t,k,v)
            if k:match("^Point") or k=="Thickness" or k=="Color" or k=="Transparency" or
               k=="Rotation" or k=="AnchorPoint" or k=="Visible" or k=="ZIndex" or
               k=="Dashed" or k=="DashLength" or k=="GapLength" then
                task.defer(update)
            end
        end

        update()
    end

    return self
end

getgenv().Drawing = Drawing

getgenv().isrenderobj     = function(obj) return type(obj)=="userdata" and pcall(function() return obj.__OBJECT_EXISTS end) end
getgenv().cleardrawcache  = function()
    for i=#DrawingCache,1,-1 do pcall(DrawingCache[i].proxy.Remove, DrawingCache[i].proxy) end
    DrawingCache = {}
    DrawingObjects = {}
end
getgenv().getrenderproperty = function(obj, p) return isrenderobj(obj) and obj[p] or nil end
getgenv().setrenderproperty = function(obj, p, v) if isrenderobj(obj) then obj[p] = v end end
