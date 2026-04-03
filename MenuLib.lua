-- Menu Library for 22s Duels Hub
local MenuLib = {}

MenuLib.Colors = {
    bg = Color3.fromRGB(10, 10, 10),
    purple = Color3.fromRGB(255, 255, 255),
    purpleLight = Color3.fromRGB(200, 200, 200),
    purpleDark = Color3.fromRGB(50, 50, 50),
    accent = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(150, 150, 150),
    success = Color3.fromRGB(200, 200, 200),
    danger = Color3.fromRGB(100, 100, 100)
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
    main.Size = UDim2.new(0, 560 * guiScale, 0, 740 * guiScale)
    main.Position = UDim2.new(0, 10 * guiScale, 0.5, -370 * guiScale)
    main.BackgroundColor3 = C.bg
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18 * guiScale)

    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 70 * guiScale)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.ZIndex = 0

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(1, 0, 0, 32 * guiScale)
    titleLabel.Position = UDim2.new(0, 0, 0, 10 * guiScale)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "22s"
    titleLabel.TextColor3 = C.text
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 28 * guiScale
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.ZIndex = 5

    local subtitleLabel = Instance.new("TextLabel", header)
    subtitleLabel.Size = UDim2.new(1, 0, 0, 24 * guiScale)
    subtitleLabel.Position = UDim2.new(0, 0, 0, 40 * guiScale)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "use the best"
    subtitleLabel.TextColor3 = C.purpleLight
    subtitleLabel.Font = Enum.Font.GothamBold
    subtitleLabel.TextSize = 16 * guiScale
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    subtitleLabel.ZIndex = 5

    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 36 * guiScale, 0, 36 * guiScale)
    closeBtn.Position = UDim2.new(1, -46 * guiScale, 0.5, -18 * guiScale)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = C.textDim
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 24 * guiScale
    closeBtn.ZIndex = 5

    local leftSide = Instance.new("Frame", main)
    leftSide.Size = UDim2.new(0.48, 0, 0, 650 * guiScale)
    leftSide.Position = UDim2.new(0.01, 0, 0, 75 * guiScale)
    leftSide.BackgroundTransparency = 1
    leftSide.BorderSizePixel = 0
    leftSide.ClipsDescendants = true
    leftSide.ZIndex = 2

    local rightSide = Instance.new("Frame", main)
    rightSide.Size = UDim2.new(0.48, 0, 0, 650 * guiScale)
    rightSide.Position = UDim2.new(0.51, 0, 0, 75 * guiScale)
    rightSide.BackgroundTransparency = 1
    rightSide.BorderSizePixel = 0
    rightSide.ClipsDescendants = true
    rightSide.ZIndex = 2

    return { Frame = main, Header = header, CloseBtn = closeBtn, LeftSide = leftSide, RightSide = rightSide }
end

function MenuLib:CreateToggleWithKey(parent, yPos, labelText, keybindKey, enabledKey, callback, specialColor)
    local C = self.Colors
    local guiScale = self.GuiScale
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -10 * guiScale, 0, 48 * guiScale)
    row.Position = UDim2.new(0, 5 * guiScale, 0, yPos * guiScale)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.ZIndex = 3

    local keyBtn = Instance.new("TextButton", row)
    keyBtn.Size = UDim2.new(0, 36 * guiScale, 0, 28 * guiScale)
    keyBtn.Position = UDim2.new(0, 3 * guiScale, 0.5, -14 * guiScale)
    keyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    keyBtn.Text = keybindKey
    keyBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 11 * guiScale
    keyBtn.ZIndex = 4
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 8 * guiScale)
    self.KeyButtons[enabledKey] = keyBtn

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 45 * guiScale, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14 * guiScale
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4

    local toggleBg = Instance.new("Frame", row)
    toggleBg.Size = UDim2.new(0, 50 * guiScale, 0, 26 * guiScale)
    toggleBg.Position = UDim2.new(1, -58 * guiScale, 0.5, -13 * guiScale)
    toggleBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    toggleBg.ZIndex = 4
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleCircle = Instance.new("Frame", toggleBg)
    toggleCircle.Size = UDim2.new(0, 20 * guiScale, 0, 20 * guiScale)
    toggleCircle.Position = UDim2.new(0, 3 * guiScale, 0.5, -10 * guiScale)
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
            self.TweenService:Create(toggleBg, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            self.TweenService:Create(toggleCircle, TweenInfo.new(0.28), { BackgroundColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, -23 * guiScale, 0.5, -10 * guiScale) }):Play()
        else
            self.TweenService:Create(toggleBg, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
            self.TweenService:Create(toggleCircle, TweenInfo.new(0.28), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(0, 3 * guiScale, 0.5, -10 * guiScale) }):Play()
        end
        if not skipCallback then callback(isOn) end
    end

    self.VisualSetters[enabledKey] = setVisual
    clickBtn.MouseButton1Click:Connect(function() isOn = not isOn setVisual(isOn) end)
    keyBtn.MouseButton1Click:Connect(function() self.WaitingForKeybind = keybindKey keyBtn.Text = "..." end)

    return row, enabledKey, function() return isOn end, setVisual, keyBtn
end

function MenuLib:CreateToggle(parent, yPos, labelText, enabledKey, callback, specialColor)
    local C = self.Colors
    local guiScale = self.GuiScale
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -10 * guiScale, 0, 48 * guiScale)
    row.Position = UDim2.new(0, 5 * guiScale, 0, yPos * guiScale)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.ZIndex = 3

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10 * guiScale, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14 * guiScale
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4

    local toggleBg = Instance.new("Frame", row)
    toggleBg.Size = UDim2.new(0, 50 * guiScale, 0, 26 * guiScale)
    toggleBg.Position = UDim2.new(1, -58 * guiScale, 0.5, -13 * guiScale)
    toggleBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    toggleBg.ZIndex = 4
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleCircle = Instance.new("Frame", toggleBg)
    toggleCircle.Size = UDim2.new(0, 20 * guiScale, 0, 20 * guiScale)
    toggleCircle.Position = UDim2.new(0, 3 * guiScale, 0.5, -10 * guiScale)
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
            self.TweenService:Create(toggleBg, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            self.TweenService:Create(toggleCircle, TweenInfo.new(0.28), { BackgroundColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, -23 * guiScale, 0.5, -10 * guiScale) }):Play()
        else
            self.TweenService:Create(toggleBg, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
            self.TweenService:Create(toggleCircle, TweenInfo.new(0.28), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(0, 3 * guiScale, 0.5, -10 * guiScale) }):Play()
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
    container.Size = UDim2.new(1, -10 * guiScale, 0, 56 * guiScale)
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

    local defaultVal = defaultValue or minVal
    local valueInput = Instance.new("TextBox", container)
    valueInput.Size = UDim2.new(0, 50 * guiScale, 0, 22 * guiScale)
    valueInput.Position = UDim2.new(1, -58 * guiScale, 0, 2 * guiScale)
    valueInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    valueInput.Text = tostring(defaultVal)
    valueInput.TextColor3 = C.purpleLight
    valueInput.Font = Enum.Font.GothamBold
    valueInput.TextSize = 12 * guiScale
    valueInput.ClearTextOnFocus = false
    valueInput.ZIndex = 4
    Instance.new("UICorner", valueInput).CornerRadius = UDim.new(0, 6 * guiScale)

    local sliderBg = Instance.new("Frame", container)
    sliderBg.Size = UDim2.new(0.92, 0, 0, 10 * guiScale)
    sliderBg.Position = UDim2.new(0.04, 0, 0, 32 * guiScale)
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
    thumb.Size = UDim2.new(0, 16 * guiScale, 0, 16 * guiScale)
    thumb.Position = UDim2.new(pct, -8 * guiScale, 0.5, -8 * guiScale)
    thumb.BackgroundColor3 = Color3.new(1, 1, 1)
    thumb.ZIndex = 6
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local function setSliderValue(val)
        val = math.clamp(val, minVal, maxVal)
        local rel = (val - minVal) / (maxVal - minVal)
        sliderFill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -8 * guiScale, 0.5, -8 * guiScale)
        valueInput.Text = tostring(val)
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
