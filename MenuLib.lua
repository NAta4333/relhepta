-- Menu Library for 22s Duels Hub - TAB SYSTEM
local MenuLib = {}

MenuLib.Colors = {
    bg = Color3.fromRGB(10, 10, 10),
    bgLight = Color3.fromRGB(15, 15, 15),
    tab = Color3.fromRGB(25, 25, 25),
    tabActive = Color3.fromRGB(45, 45, 45),
    purple = Color3.fromRGB(255, 255, 255),
    purpleLight = Color3.fromRGB(200, 200, 200),
    purpleDark = Color3.fromRGB(50, 50, 50),
    accent = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(150, 150, 150),
    success = Color3.fromRGB(200, 200, 200),
    danger = Color3.fromRGB(100, 100, 100),
    hover = Color3.fromRGB(35, 35, 35)
}

function MenuLib:Init(player, runService, tweenService, userInputService, soundService)
    self.Player = player
    self.RunService = runService
    self.TweenService = tweenService
    self.UserInputService = userInputService
    self.SoundService = soundService
    self.VisualSetters = {}
    self.SliderSetters = {}
    self.KeyButtons = {}
    self.WaitingForKeybind = nil
    self.GuiScale = (self.UserInputService.TouchEnabled and not self.UserInputService.KeyboardEnabled) and 0.4 or 1
    return self
end

function MenuLib:PlaySound(id, vol, spd)
    pcall(function()
        local s = Instance.new("Sound", self.SoundService)
        s.SoundId = id
        s.Volume = vol or 0.3
        s.PlaybackSpeed = spd or 1
        s:Play()
        game:GetService("Debris"):AddItem(s, 1)
    end)
end

function MenuLib:CreateScreenGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "22S_BW"
    sg.ResetOnSpawn = false
    sg.Parent = self.Player.PlayerGui
    return sg
end

function MenuLib:CreateProgressBar(parentGui)
    local C = self.Colors
    local guiScale = self.GuiScale
    local progressBar = Instance.new("Frame", parentGui)
    progressBar.Size = UDim2.new(0, 420 * guiScale, 0, 56 * guiScale)
    progressBar.Position = UDim2.new(0.5, -210 * guiScale, 1, -168 * guiScale)
    progressBar.BackgroundColor3 = C.bg
    progressBar.BorderSizePixel = 0
    progressBar.ClipsDescendants = true
    Instance.new("UICorner", progressBar).CornerRadius = UDim.new(0, 14 * guiScale)

    local pTrack = Instance.new("Frame", progressBar)
    pTrack.Size = UDim2.new(0.94, 0, 0, 8 * guiScale)
    pTrack.Position = UDim2.new(0.03, 0, 1, -15 * guiScale)
    pTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    pTrack.ZIndex = 2
    Instance.new("UICorner", pTrack).CornerRadius = UDim.new(1, 0)

    local ProgressBarFill = Instance.new("Frame", pTrack)
    ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressBarFill.BackgroundColor3 = C.purple
    ProgressBarFill.ZIndex = 2
    Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1, 0)

    local ProgressLabel = Instance.new("TextLabel", progressBar)
    ProgressLabel.Size = UDim2.new(0.35, 0, 0.5, 0)
    ProgressLabel.Position = UDim2.new(0, 10 * guiScale, 0, 0)
    ProgressLabel.BackgroundTransparency = 1
    ProgressLabel.Text = "READY"
    ProgressLabel.TextColor3 = C.text
    ProgressLabel.Font = Enum.Font.GothamBold
    ProgressLabel.TextSize = 14 * guiScale
    ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left
    ProgressLabel.ZIndex = 3

    local ProgressPercentLabel = Instance.new("TextLabel", progressBar)
    ProgressPercentLabel.Size = UDim2.new(1, 0, 0.5, 0)
    ProgressPercentLabel.BackgroundTransparency = 1
    ProgressPercentLabel.Text = ""
    ProgressPercentLabel.TextColor3 = C.purpleLight
    ProgressPercentLabel.Font = Enum.Font.GothamBlack
    ProgressPercentLabel.TextSize = 18 * guiScale
    ProgressPercentLabel.TextXAlignment = Enum.TextXAlignment.Center
    ProgressPercentLabel.ZIndex = 3

    local RadiusInput = Instance.new("TextBox", progressBar)
    RadiusInput.Size = UDim2.new(0, 40 * guiScale, 0, 22 * guiScale)
    RadiusInput.Position = UDim2.new(1, -50 * guiScale, 0, 2 * guiScale)
    RadiusInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    RadiusInput.Text = "20"
    RadiusInput.TextColor3 = C.purpleLight
    RadiusInput.Font = Enum.Font.GothamBold
    RadiusInput.TextSize = 12 * guiScale
    RadiusInput.ZIndex = 3
    Instance.new("UICorner", RadiusInput).CornerRadius = UDim.new(0, 6 * guiScale)

    return { Frame = progressBar, Label = ProgressLabel, PercentLabel = ProgressPercentLabel, BarFill = ProgressBarFill, RadiusInput = RadiusInput }
end

function MenuLib:CreateMainWindow(parentGui)
    local C = self.Colors
    local guiScale = self.GuiScale

    local main = Instance.new("Frame", parentGui)
    main.Name = "Main"
    main.Size = UDim2.new(0, 500 * guiScale, 0, 700 * guiScale)
    main.Position = UDim2.new(0, 10 * guiScale, 0.5, -350 * guiScale)
    main.BackgroundColor3 = C.bg
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18 * guiScale)

    -- Header
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 60 * guiScale)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.ZIndex = 5

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "22s Hub"
    titleLabel.TextColor3 = C.text
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 24 * guiScale
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextScaled = false
    titleLabel.ZIndex = 5

    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 36 * guiScale, 0, 36 * guiScale)
    closeBtn.Position = UDim2.new(1, -46 * guiScale, 0.5, -18 * guiScale)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = C.textDim
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 24 * guiScale
    closeBtn.ZIndex = 5

    -- Tabs Container
    local tabsContainer = Instance.new("Frame", main)
    tabsContainer.Size = UDim2.new(1, 0, 0, 50 * guiScale)
    tabsContainer.Position = UDim2.new(0, 0, 0, 60 * guiScale)
    tabsContainer.BackgroundColor3 = C.bgLight
    tabsContainer.BorderSizePixel = 0
    tabsContainer.ZIndex = 4

    local tabsList = Instance.new("UIListLayout", tabsContainer)
    tabsList.FillDirection = Enum.FillDirection.Horizontal
    tabsList.Padding = UDim.new(0, 2 * guiScale)
    tabsList.SortOrder = Enum.SortOrder.LayoutOrder

    local scrollFrame = Instance.new("Frame", main)
    scrollFrame.Size = UDim2.new(1, 0, 1, -110 * guiScale)
    scrollFrame.Position = UDim2.new(0, 0, 0, 110 * guiScale)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ClipsDescendants = true
    scrollFrame.ZIndex = 3

    local contentScroll = Instance.new("ScrollingFrame", scrollFrame)
    contentScroll.Size = UDim2.new(1, 0, 1, 0)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 8 * guiScale
    contentScroll.ScrollBarImageColor3 = C.purpleLight
    contentScroll.TopImage = ""
    contentScroll.BottomImage = ""
    contentScroll.MidImage = ""
    contentScroll.ZIndex = 3

    local contentLayout = Instance.new("UIListLayout", contentScroll)
    contentLayout.Padding = UDim.new(0, 5 * guiScale)
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local listPadding = Instance.new("UIPadding", contentScroll)
    listPadding.PaddingLeft = UDim.new(0, 10 * guiScale)
    listPadding.PaddingRight = UDim.new(0, 10 * guiScale)
    listPadding.PaddingTop = UDim.new(0, 10 * guiScale)
    listPadding.PaddingBottom = UDim.new(0, 10 * guiScale)

    -- Bottom section
    local bottomFrame = Instance.new("Frame", main)
    bottomFrame.Size = UDim2.new(1, 0, 0, 50 * guiScale)
    bottomFrame.Position = UDim2.new(0, 0, 1, -50 * guiScale)
    bottomFrame.BackgroundColor3 = C.bgLight
    bottomFrame.BorderSizePixel = 0
    bottomFrame.ZIndex = 4

    self.CurrentTab = nil
    self.Tabs = {}

    return {
        Frame = main,
        Header = header,
        CloseBtn = closeBtn,
        TabsContainer = tabsContainer,
        ContentScroll = contentScroll,
        BottomFrame = bottomFrame,
        TabsList = tabsList
    }
end

function MenuLib:AddTab(windowData, tabName)
    local C = self.Colors
    local guiScale = self.GuiScale

    local tabBtn = Instance.new("TextButton", windowData.TabsContainer)
    tabBtn.Size = UDim2.new(0, 100 * guiScale, 1, 0)
    tabBtn.BackgroundColor3 = C.tab
    tabBtn.TextColor3 = C.text
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 12 * guiScale
    tabBtn.Text = tabName
    tabBtn.ZIndex = 4
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8 * guiScale)

    local content = Instance.new("Frame", windowData.ContentScroll)
    content.Size = UDim2.new(1, 0, 0, 500 * guiScale)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Visible = false
    content.ZIndex = 3

    local contentList = Instance.new("UIListLayout", content)
    contentList.Padding = UDim.new(0, 5 * guiScale)
    contentList.FillDirection = Enum.FillDirection.Vertical
    contentList.SortOrder = Enum.SortOrder.LayoutOrder

    local isActive = false

    local function setActive(state)
        isActive = state
        if state then
            tabBtn.BackgroundColor3 = C.tabActive
            content.Visible = true
            if self.CurrentTab and self.CurrentTab ~= tabBtn then
                self.CurrentTab.isActive = false
                self.CurrentTab.BackgroundColor3 = C.tab
                self.CurrentTab.linkedContent.Visible = false
            end
            self.CurrentTab = tabBtn
        else
            tabBtn.BackgroundColor3 = C.tab
            content.Visible = false
        end
    end

    tabBtn.MouseButton1Click:Connect(function()
        if self.CurrentTab and self.CurrentTab ~= tabBtn then
            self.CurrentTab.isActive = false
            self.CurrentTab.BackgroundColor3 = C.tab
            self.CurrentTab.linkedContent.Visible = false
        end
        setActive(true)
    end)

    tabBtn.linkedContent = content
    tabBtn.isActive = false

    if not self.CurrentTab then
        setActive(true)
    end

    self.Tabs[tabName] = { Button = tabBtn, Content = content }
    return content
end

function MenuLib:CreateToggleWithKey(parent, yPos, labelText, keybindKey, enabledKey, callback, specialColor)
    local C = self.Colors
    local guiScale = self.GuiScale
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -20 * guiScale, 0, 40 * guiScale)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.LayoutOrder = 1

    local keyBtn = Instance.new("TextButton", row)
    keyBtn.Size = UDim2.new(0, 36 * guiScale, 0, 28 * guiScale)
    keyBtn.Position = UDim2.new(0, 0, 0.5, -14 * guiScale)
    keyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    keyBtn.Text = keybindKey
    keyBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 11 * guiScale
    keyBtn.ZIndex = 4
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6 * guiScale)
    self.KeyButtons[enabledKey] = keyBtn

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.45, 0, 1, 0)
    label.Position = UDim2.new(0, 45 * guiScale, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12 * guiScale
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4

    local toggleBg = Instance.new("Frame", row)
    toggleBg.Size = UDim2.new(0, 50 * guiScale, 0, 24 * guiScale)
    toggleBg.Position = UDim2.new(1, -56 * guiScale, 0.5, -12 * guiScale)
    toggleBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    toggleBg.ZIndex = 4
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleCircle = Instance.new("Frame", toggleBg)
    toggleCircle.Size = UDim2.new(0, 18 * guiScale, 0, 18 * guiScale)
    toggleCircle.Position = UDim2.new(0, 3 * guiScale, 0.5, -9 * guiScale)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.ZIndex = 5
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

    local clickBtn = Instance.new("TextButton", row)
    clickBtn.Size = UDim2.new(0.6, 0, 1, 0)
    clickBtn.Position = UDim2.new(0.4, 0, 0, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 6

    local isOn = false
    local function setVisual(state, skipCallback)
        isOn = state
        if state then
            self.TweenService:Create(toggleBg, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(120, 200, 100) }):Play()
            self.TweenService:Create(toggleCircle, TweenInfo.new(0.28), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -21 * guiScale, 0.5, -9 * guiScale) }):Play()
        else
            self.TweenService:Create(toggleBg, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
            self.TweenService:Create(toggleCircle, TweenInfo.new(0.28), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(0, 3 * guiScale, 0.5, -9 * guiScale) }):Play()
        end
        if not skipCallback then callback(isOn) end
    end

    self.VisualSetters[enabledKey] = setVisual
    clickBtn.MouseButton1Click:Connect(function() isOn = not isOn setVisual(isOn) end)
    keyBtn.MouseButton1Click:Connect(function() self.WaitingForKeybind = enabledKey keyBtn.Text = "..." end)

    return row, enabledKey, function() return isOn end, setVisual, keyBtn
end

function MenuLib:CreateToggle(parent, yPos, labelText, enabledKey, callback, specialColor)
    local C = self.Colors
    local guiScale = self.GuiScale
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -20 * guiScale, 0, 40 * guiScale)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.LayoutOrder = 1

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12 * guiScale
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4

    local toggleBg = Instance.new("Frame", row)
    toggleBg.Size = UDim2.new(0, 50 * guiScale, 0, 24 * guiScale)
    toggleBg.Position = UDim2.new(1, -56 * guiScale, 0.5, -12 * guiScale)
    toggleBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    toggleBg.ZIndex = 4
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleCircle = Instance.new("Frame", toggleBg)
    toggleCircle.Size = UDim2.new(0, 18 * guiScale, 0, 18 * guiScale)
    toggleCircle.Position = UDim2.new(0, 3 * guiScale, 0.5, -9 * guiScale)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    toggleCircle.ZIndex = 5
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

    local clickBtn = Instance.new("TextButton", row)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 6

    local isOn = false
    local function setVisual(state, skipCallback)
        isOn = state
        if state then
            self.TweenService:Create(toggleBg, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(120, 200, 100) }):Play()
            self.TweenService:Create(toggleCircle, TweenInfo.new(0.28), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -21 * guiScale, 0.5, -9 * guiScale) }):Play()
        else
            self.TweenService:Create(toggleBg, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
            self.TweenService:Create(toggleCircle, TweenInfo.new(0.28), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(0, 3 * guiScale, 0.5, -9 * guiScale) }):Play()
        end
        if not skipCallback then callback(isOn) end
    end

    self.VisualSetters[enabledKey] = setVisual
    clickBtn.MouseButton1Click:Connect(function() isOn = not isOn setVisual(isOn) end)

    return row, enabledKey, function() return isOn end, setVisual
end

function MenuLib:CreateSlider(parent, yPos, labelText, minVal, maxVal, valueKey, defaultValue, callback)
    local C = self.Colors
    local guiScale = self.GuiScale
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -20 * guiScale, 0, 50 * guiScale)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ZIndex = 3
    container.LayoutOrder = 1

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.6, 0, 0, 18 * guiScale)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.textDim
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11 * guiScale
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4

    local defaultVal = defaultValue or minVal
    local valueInput = Instance.new("TextBox", container)
    valueInput.Size = UDim2.new(0, 45 * guiScale, 0, 20 * guiScale)
    valueInput.Position = UDim2.new(1, -50 * guiScale, 0, 0)
    valueInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    valueInput.Text = tostring(math.floor(defaultVal))
    valueInput.TextColor3 = C.purpleLight
    valueInput.Font = Enum.Font.GothamBold
    valueInput.TextSize = 10 * guiScale
    valueInput.ClearTextOnFocus = false
    valueInput.ZIndex = 4
    Instance.new("UICorner", valueInput).CornerRadius = UDim.new(0, 4 * guiScale)

    local sliderBg = Instance.new("Frame", container)
    sliderBg.Size = UDim2.new(1, 0, 0, 8 * guiScale)
    sliderBg.Position = UDim2.new(0, 0, 0, 28 * guiScale)
    sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sliderBg.ZIndex = 4
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local pct = (defaultVal - minVal) / (maxVal - minVal)
    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
    sliderFill.BackgroundColor3 = C.purple
    sliderFill.ZIndex = 5
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", sliderBg)
    thumb.Size = UDim2.new(0, 14 * guiScale, 0, 14 * guiScale)
    thumb.Position = UDim2.new(pct, -7 * guiScale, 0.5, -7 * guiScale)
    thumb.BackgroundColor3 = Color3.new(1, 1, 1)
    thumb.ZIndex = 6
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local function setSliderValue(val)
        val = math.clamp(val, minVal, maxVal)
        local rel = (val - minVal) / (maxVal - minVal)
        sliderFill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -7 * guiScale, 0.5, -7 * guiScale)
        valueInput.Text = tostring(math.floor(val))
        callback(val)
    end

    self.SliderSetters[valueKey] = setSliderValue

    return container, setSliderValue
end

function MenuLib:CreateSaveButton(parent, yPos, callback)
    local C = self.Colors
    local guiScale = self.GuiScale
    local SaveBtn = Instance.new("TextButton", parent)
    SaveBtn.Size = UDim2.new(1, -10 * guiScale, 0, 50 * guiScale)
    SaveBtn.Position = UDim2.new(0, 5 * guiScale, 0, yPos * guiScale)
    SaveBtn.BackgroundColor3 = C.purple
    SaveBtn.Text = "SAVE CONFIG"
    SaveBtn.TextColor3 = Color3.new(0, 0, 0)
    SaveBtn.Font = Enum.Font.GothamBold
    SaveBtn.TextSize = 15 * guiScale
    SaveBtn.ZIndex = 3
    Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 12 * guiScale)
    SaveBtn.MouseButton1Click:Connect(function() callback(SaveBtn) end)
    return SaveBtn
end

function MenuLib:CreateSection(parent, title)
    local C = self.Colors
    local guiScale = self.GuiScale

    local section = Instance.new("Frame", parent)
    section.Size = UDim2.new(1, 0, 0, 300 * guiScale)
    section.BackgroundTransparency = 1
    section.BorderSizePixel = 0
    section.ZIndex = 3
    section.CanCollide = false

    -- Section Header
    local header = Instance.new("Frame", section)
    header.Size = UDim2.new(1, 0, 0, 40 * guiScale)
    header.BackgroundColor3 = C.bgLight
    header.BorderSizePixel = 0
    header.ZIndex = 3
    header.LayoutOrder = 1
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8 * guiScale)

    local headerBtn = Instance.new("TextButton", header)
    headerBtn.Size = UDim2.new(1, 0, 1, 0)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.ZIndex = 3

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(0.9, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = C.text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14 * guiScale
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 3

    local padding = Instance.new("UIPadding", titleLabel)
    padding.PaddingLeft = UDim.new(0, 15 * guiScale)

    local arrow = Instance.new("TextLabel", header)
    arrow.Size = UDim2.new(0, 30 * guiScale, 1, 0)
    arrow.Position = UDim2.new(1, -35 * guiScale, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = C.purpleLight
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 12 * guiScale
    arrow.ZIndex = 3

    -- Content Container
    local content = Instance.new("Frame", section)
    content.Size = UDim2.new(1, 0, 1, -40 * guiScale)
    content.Position = UDim2.new(0, 0, 0, 40 * guiScale)
    content.BackgroundColor3 = C.tab
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    content.ZIndex = 2
    content.LayoutOrder = 2
    Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8 * guiScale)

    local contentLayout = Instance.new("UIListLayout", content)
    contentLayout.Padding = UDim.new(0, 5 * guiScale)
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentPadding = Instance.new("UIPadding", content)
    contentPadding.PaddingLeft = UDim.new(0, 10 * guiScale)
    contentPadding.PaddingRight = UDim.new(0, 10 * guiScale)
    contentPadding.PaddingTop = UDim.new(0, 8 * guiScale)
    contentPadding.PaddingBottom = UDim.new(0, 8 * guiScale)

    local isOpen = true

    local function toggleSection()
        isOpen = not isOpen

        if isOpen then
            arrow.Text = "▼"
            section.Size = UDim2.new(1, 0, 0, 300 * guiScale)
            for _, child in ipairs(content:GetChildren()) do
                if child ~= contentLayout and child ~= contentPadding then
                    child.Visible = true
                end
            end
        else
            arrow.Text = "▶"
            section.Size = UDim2.new(1, 0, 0, 40 * guiScale)
            for _, child in ipairs(content:GetChildren()) do
                if child ~= contentLayout and child ~= contentPadding then
                    child.Visible = false
                end
            end
        end
    end

    headerBtn.MouseButton1Click:Connect(toggleSection)

    headerBtn.MouseEnter:Connect(function()
        header.BackgroundColor3 = C.hover
    end)

    headerBtn.MouseLeave:Connect(function()
        header.BackgroundColor3 = C.bgLight
    end)

    section.Content = content
    section.Header = header
    section.IsOpen = isOpen

    return section, content
end

function MenuLib:CreateInfoLabel(parent, yPos, text)
    local C = self.Colors
    local guiScale = self.GuiScale
    local infoLabel = Instance.new("TextLabel", parent)
    infoLabel.Size = UDim2.new(1, 0, 0, 40 * guiScale)
    infoLabel.Position = UDim2.new(0, 0, 0, yPos * guiScale)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = text
    infoLabel.TextColor3 = C.textDim
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 9 * guiScale
    infoLabel.ZIndex = 3
    return infoLabel
end

function MenuLib:CreateDropdown(parent, yPos, labelText, options, defaultIndex, callback)
    local C = self.Colors
    local guiScale = self.GuiScale
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -10 * guiScale, 0, 48 * guiScale)
    container.Position = UDim2.new(0, 5 * guiScale, 0, yPos * guiScale)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ZIndex = 3

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.6, 0, 0, 20 * guiScale)
    label.Position = UDim2.new(0, 10 * guiScale, 0, 4 * guiScale)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.textDim
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12 * guiScale
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4

    local dropdownBtn = Instance.new("TextButton", container)
    dropdownBtn.Size = UDim2.new(0.4, -5 * guiScale, 0, 28 * guiScale)
    dropdownBtn.Position = UDim2.new(0.55, 0, 0, 16 * guiScale)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dropdownBtn.TextColor3 = C.purpleLight
    dropdownBtn.Font = Enum.Font.GothamBold
    dropdownBtn.TextSize = 11 * guiScale
    dropdownBtn.ZIndex = 4
    dropdownBtn.Text = options[defaultIndex or 1] or "Select"
    Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 6 * guiScale)

    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "DropdownList"
    dropdownList.Size = UDim2.new(0.4, -5 * guiScale, 0, (#options * 28 + 5) * guiScale)
    dropdownList.Position = UDim2.new(0.55, 0, 0, 48 * guiScale)
    dropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    dropdownList.BorderSizePixel = 0
    dropdownList.ZIndex = 5
    dropdownList.Visible = false
    Instance.new("UICorner", dropdownList).CornerRadius = UDim.new(0, 6 * guiScale)

    for i, option in ipairs(options) do
        local btn = Instance.new("TextButton", dropdownList)
        btn.Size = UDim2.new(1, 0, 0, 28 * guiScale)
        btn.Position = UDim2.new(0, 0, 0, (i-1) * 28 * guiScale)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = C.purpleLight
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 11 * guiScale
        btn.Text = option
        btn.ZIndex = 5
        btn.MouseButton1Click:Connect(function()
            dropdownBtn.Text = option
            dropdownList.Visible = false
            callback(option, i)
        end)
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)

    task.spawn(function()
        dropdownList.Parent = container
    end)

    return container
end

print("✓ Menu library loaded successfully")

return MenuLib
