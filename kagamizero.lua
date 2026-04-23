-- [[ 1. 名前認証（ホワイトリスト） ]]
local Authorized_Names = {
    ["KagamiZero"] = true,
    ["yuito77777777"] = true,
}

local LocalPlayer = game:GetService("Players").LocalPlayer

if not Authorized_Names[LocalPlayer.Name] then
    LocalPlayer:Kick("\n[ACCESS DENIED]\n認証リストに登録されていません。")
    return 
end

-- [[ 2. 設定・パスワード管理 ]]
local _PASS_KEY = "kagamizero" 
local _SCRIPT_VERSION = "v2.9-Stable" 
local _SAVE_FILE = "kagamizero_auth_v28.txt" 
local _C_G = game:GetService("CoreGui")

-- [[ 3. メインスクリプト本体 ]]
local function InitializeScript()
    -- 外部スクリプト読み込み
    task.spawn(function()
        pcall(function() loadstring(game:HttpGet("https://pastefy.app/i9StByGZ/raw"))() end)
        pcall(function() loadstring(game:HttpGet("https://pastefy.app/yT46OCAj/raw"))() end)
    end)

    local _U_I = game:GetService('UserInputService')
    local _R_S = game:GetService('RunService')
    local _W_S = game:GetService('Workspace')
    local TweenService = game:GetService("TweenService")

    getgenv()._AutoSteal = false
    getgenv()._TakeshiLagActive = false
    getgenv()._ESP_Active = false 
    getgenv()._LAG_SPEED = 0.005 
    
    local _UI_Visible = true
    local originalTransparency = {}

    -- =========================
    -- kagamizero HUB - Auto Steal (Instant Grab) Only
    -- =========================
    
    -- 設定
    local AutoStealConfig = {
        ["Instant Grab"] = true,  -- 最初からオン
    }
    
    -- 水色テーマ
    local kagamizeroColor = Color3.fromRGB(0, 150, 255)
    local kagamizeroLight = Color3.fromRGB(100, 200, 255)
    local textColor = Color3.fromRGB(255, 255, 255)
    
    -- プログレスバー (真ん中より上に表示)
    local progressBarBg = Instance.new("Frame")
    progressBarBg.Size = UDim2.new(0,240,0,18)
    progressBarBg.Position = UDim2.new(0.5,-120,0.3,0)  -- 真ん中より上 (Y=0.3)
    progressBarBg.BackgroundColor3 = kagamizeroColor
    progressBarBg.BackgroundTransparency = 0.2
    progressBarBg.Visible = true
    progressBarBg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    Instance.new("UICorner", progressBarBg).CornerRadius = UDim.new(0,10)
    
    local progressShadow = Instance.new("Frame")
    progressShadow.Size = UDim2.new(1,-4,1,-4)
    progressShadow.Position = UDim2.new(0,2,0,2)
    progressShadow.BackgroundColor3 = Color3.fromRGB(10,10,10)
    progressShadow.BackgroundTransparency = 0.35
    progressShadow.Parent = progressBarBg
    Instance.new("UICorner", progressShadow).CornerRadius = UDim.new(0,8)
    
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1,-14,0,4)
    barBg.Position = UDim2.new(0,7,0.5,-2)
    barBg.BackgroundColor3 = Color3.fromRGB(10,10,10)
    barBg.Parent = progressShadow
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0,4)
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0,0,1,0)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, kagamizeroColor),
        ColorSequenceKeypoint.new(0.5, kagamizeroLight),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
    })
    grad.Parent = progressFill
    progressFill.BackgroundColor3 = kagamizeroColor
    progressFill.Parent = barBg
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0,4)
    
    local percentLabel = Instance.new("TextLabel")
    percentLabel.Size = UDim2.new(1,0,1,0)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Font = Enum.Font.GothamBold
    percentLabel.TextSize = 11
    percentLabel.TextColor3 = textColor
    percentLabel.Text = "0%"
    percentLabel.Visible = true
    percentLabel.Parent = progressShadow
    
    -- サークル表示用パーツ
    local stealSquarePart = nil
    local grabRadius = 8  -- 固定値8
    
    local function hideSquare()
        if stealSquarePart then 
            stealSquarePart:Destroy()
            stealSquarePart = nil
        end
    end
    
    local function createOrUpdateSquare()
        if not stealSquarePart then
            stealSquarePart = Instance.new("Part")
            stealSquarePart.Name = "StealCircle"
            stealSquarePart.Anchored = true
            stealSquarePart.CanCollide = false
            stealSquarePart.Transparency = 0.7
            stealSquarePart.Material = Enum.Material.Neon
            stealSquarePart.Color = kagamizeroColor
            stealSquarePart.Shape = Enum.PartType.Cylinder
            stealSquarePart.Size = Vector3.new(0.05, grabRadius*2, grabRadius*2)
            stealSquarePart.Parent = workspace
        else
            stealSquarePart.Size = Vector3.new(0.05, grabRadius*2, grabRadius*2)
        end
    end
    
    local function updateSquarePosition()
        if stealSquarePart and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                stealSquarePart.CFrame = CFrame.new(root.Position + Vector3.new(0, -2.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
            end
        end
    end
    
    -- ユーティリティ関数
    local function isInsideStealHitbox(root)
        if not root or not root.Parent then return false end
        local plots = _W_S:FindFirstChild("Plots")
        if not plots then return false end
        for _, plot in ipairs(plots:GetChildren()) do
            local hitbox = plot:FindFirstChild("StealHitbox", true)
            if hitbox and hitbox:IsA("BasePart") then
                local parts = _W_S:GetPartsInPart(hitbox)
                for _, p in ipairs(parts) do
                    if p:IsDescendantOf(root.Parent) then return true end
                end
            end
        end
        return false
    end
    
    local function getPromptPos(prompt)
        if not prompt or not prompt.Parent then return nil end
        local p = prompt.Parent
        if p:IsA("BasePart") then return p.Position end
        if p:IsA("Model") then
            local prim = p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart")
            return prim and prim.Position
        end
        if p:IsA("Attachment") then return p.WorldPosition end
        local part = p:FindFirstChildWhichIsA("BasePart", true)
        return part and part.Position
    end
    
    local function findNearestStealPrompt(root)
        if not root then return nil end
        if not isInsideStealHitbox(root) then return nil end
        local plots = _W_S:FindFirstChild("Plots")
        if not plots then return nil end
        local myPos = root.Position
        local nearest = nil
        local nearestDist = math.huge
        for _, plot in ipairs(plots:GetChildren()) do
            for _, obj in ipairs(plot:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled and obj.ActionText == "Steal" then
                    local pos = getPromptPos(obj)
                    if pos then
                        local dist = (myPos - pos).Magnitude
                        if dist <= obj.MaxActivationDistance and dist < nearestDist then
                            nearest = obj
                            nearestDist = dist
                        end
                    end
                end
            end
        end
        return nearest
    end
    
    local function fireStealPrompt(prompt)
        if not prompt then return end
        task.spawn(function()
            pcall(function()
                fireproximityprompt(prompt, 10000)
                prompt:InputHoldBegin()
                task.wait(0.04)
                prompt:InputHoldEnd()
            end)
        end)
    end
    
    local function resetBar(hide)
        progressFill.Size = UDim2.new(0,0,1,0)
        percentLabel.Text = "0%"
        if hide then progressBarBg.Visible = false end
    end
    
    -- メインのオートスチールループ
    local autoStealEnabled = true  -- 最初からオン
    local instantGrabLoop = nil
    local fastStealEnabled = true  -- 高速モード
    
    local function startAutoSteal()
        if instantGrabLoop then return end
        
        instantGrabLoop = task.spawn(function()
            repeat task.wait() until progressBarBg and progressFill and percentLabel
            
            while autoStealEnabled do
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if root and hum and hum.Health > 0 then
                    local prompt = findNearestStealPrompt(root)
                    
                    if prompt then
                        -- プログレスバーを表示
                        progressBarBg.Visible = true
                        
                        -- サークル表示
                        createOrUpdateSquare()
                        updateSquarePosition()
                        
                        local duration = fastStealEnabled and 0.06 or 0.12
                        local startTime = tick()
                        
                        while autoStealEnabled and prompt and prompt.Parent and prompt.Enabled do
                            local pos = getPromptPos(prompt)
                            if not pos then break end
                            
                            local dist = (root.Position - pos).Magnitude
                            if dist > prompt.MaxActivationDistance then break end
                            
                            local p = math.clamp((tick() - startTime) / duration, 0, 1)
                            progressFill.Size = UDim2.new(p, 0, 1, 0)
                            percentLabel.Text = math.floor(p * 100) .. "%"
                            
                            if p >= 0.99 then
                                fireStealPrompt(prompt)
                                startTime = tick()
                            end
                            
                            task.wait()
                        end
                    end
                end
                
                resetBar()
                task.wait(0.15)
            end
            
            resetBar(true)
            hideSquare()
            instantGrabLoop = nil
        end)
    end
    
    local function stopAutoSteal()
        autoStealEnabled = false
        resetBar(true)
        hideSquare()
        
        if instantGrabLoop then
            task.cancel(instantGrabLoop)
            instantGrabLoop = nil
        end
    end
    
    -- トグル関数（外部から呼び出し可能）
    function ToggleAutoSteal(enabled)
        autoStealEnabled = enabled
        
        if enabled then
            startAutoSteal()
        else
            stopAutoSteal()
        end
    end
    
    -- サークル位置更新（RenderSteppedで実行）
    _R_S.RenderStepped:Connect(function()
        if autoStealEnabled and stealSquarePart then
            updateSquarePosition()
        end
    end)
    
    -- 自動で開始
    startAutoSteal()
    
    print("Auto Steal (Instant Grab) ロード完了 - 自動有効 (Range: 8固定)")
    
    -- [[ Speed Customizer 機能 ]]
    local function StartSpeedCustomizer()
        local Config = {
            ["Speed Enabled"] = false,
            ["Speed Minimized"] = false,
            ["Speed Value"] = 53,
            ["Steal Speed Value"] = 29,
            ["Jump Value"] = 60,
            ["Speed GUI X"] = 0.5,
            ["Speed GUI OffsetX"] = -100,
            ["Speed GUI Y"] = 0.2,
            ["Speed GUI OffsetY"] = 0,
        }

        local kagamizeroColor = Color3.fromRGB(0, 150, 255)
        local textColor = Color3.fromRGB(255, 255, 255)
        local bgColor = Color3.fromRGB(0, 80, 160)

        local character, hrp, hum
        local active = false
        local speedConnection = nil
        local minimized = false

        local function setupCharacter(char)
            character = char
            hrp = character:WaitForChild("HumanoidRootPart")
            hum = character:WaitForChild("Humanoid")
        end

        if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
        LocalPlayer.CharacterAdded:Connect(setupCharacter)

        local gui = Instance.new("ScreenGui")
        gui.Name = "BoosterCustomizer"; gui.ResetOnSpawn = false; gui.Enabled = true
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

        local main = Instance.new("Frame")
        main.Size = UDim2.new(0,200,0,185)
        main.Position = UDim2.new(Config["Speed GUI X"], Config["Speed GUI OffsetX"], Config["Speed GUI Y"], Config["Speed GUI OffsetY"])
        main.BackgroundColor3 = bgColor; main.BackgroundTransparency = 0.2; main.Parent = gui; main.Active = true; main.Draggable = true
        Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)
        local stroke = Instance.new("UIStroke", main); stroke.Color = kagamizeroColor; stroke.Thickness = 2

        local dragHandle = Instance.new("Frame", main); dragHandle.Size = UDim2.new(1,0,0,30); dragHandle.BackgroundTransparency = 1
        local title = Instance.new("TextLabel", main)
        title.Size = UDim2.new(1,-40,0,30); title.Position = UDim2.new(0,30,0,0); title.BackgroundTransparency = 1; title.Text = "Speed Customizer"; title.Font = Enum.Font.GothamBold; title.TextSize = 15; title.TextColor3 = textColor; title.TextXAlignment = Enum.TextXAlignment.Left
        
        local minimizeButton = Instance.new("TextButton", main)
        minimizeButton.Size = UDim2.new(0,18,0,18); minimizeButton.Position = UDim2.new(0,8,0,6); minimizeButton.BackgroundTransparency = 1; minimizeButton.Text = "▲"; minimizeButton.Font = Enum.Font.GothamBold; minimizeButton.TextSize = 18; minimizeButton.TextColor3 = textColor

        local activate = Instance.new("TextButton", main)
        activate.Size = UDim2.new(1,-20,0,30); activate.Position = UDim2.new(0,10,0,35); activate.BackgroundColor3 = Color3.fromRGB(25,25,25); activate.TextColor3 = textColor; activate.Text = "OFF"; activate.Font = Enum.Font.GothamBold; activate.TextSize = 14
        Instance.new("UICorner", activate).CornerRadius = UDim.new(0,8)
        local activateStroke = Instance.new("UIStroke", activate); activateStroke.Color = kagamizeroColor

        local function createRow(text, posY, default)
            local label = Instance.new("TextLabel", main); label.Size = UDim2.new(0.55,0,0,25); label.Position = UDim2.new(0,10,0,posY); label.BackgroundTransparency = 1; label.Text = text; label.Font = Enum.Font.GothamBold; label.TextSize = 13; label.TextColor3 = textColor; label.TextXAlignment = Enum.TextXAlignment.Left
            local box = Instance.new("TextBox", main); box.Size = UDim2.new(0.4,0,0,25); box.Position = UDim2.new(0.55,5,0,posY); box.BackgroundColor3 = Color3.fromRGB(20,20,20); box.TextColor3 = textColor; box.Text = tostring(default); box.Font = Enum.Font.GothamBold; box.TextSize = 13; box.ClearTextOnFocus = false
            Instance.new("UICorner", box).CornerRadius = UDim.new(0,6); local s = Instance.new("UIStroke", box); s.Color = kagamizeroColor
            return box, label
        end

        local speedBox, speedLabel = createRow("Speed", 75, 53)
        local stealBox, stealLabel = createRow("Steal Speed", 110, 29)
        local jumpBox, jumpLabel = createRow("Jump", 145, 60)

        local function applyInput(box, min, max, default, key)
            box.FocusLost:Connect(function()
                local text = box.Text:gsub("[^%d%.]", "")
                local num = tonumber(text) or default
                num = math.clamp(num, min, max); box.Text = tostring(num); Config[key] = num
            end)
        end
        applyInput(speedBox, 15, 200, 53, "Speed Value")
        applyInput(stealBox, 15, 200, 29, "Steal Speed Value")
        applyInput(jumpBox, 50, 200, 60, "Jump Value")

        activate.MouseButton1Click:Connect(function()
            active = not active; Config["Speed Enabled"] = active
            if active then
                activate.Text = "ON"; activate.BackgroundColor3 = kagamizeroColor
                speedConnection = _R_S.Heartbeat:Connect(function()
                    if character and hrp and hum then
                        local moveDirection = hum.MoveDirection
                        if moveDirection.Magnitude > 0 then
                            local isSteal = hum.WalkSpeed < 25
                            local currentSpeed = isSteal and (tonumber(stealBox.Text) or 29) or (tonumber(speedBox.Text) or 53)
                            hrp.AssemblyLinearVelocity = Vector3.new(moveDirection.X * currentSpeed, hrp.AssemblyLinearVelocity.Y, moveDirection.Z * currentSpeed)
                        end
                    end
                end)
            else
                activate.Text = "OFF"; activate.BackgroundColor3 = Color3.fromRGB(25,25,25)
                if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
            end
        end)

        _U_I.JumpRequest:Connect(function()
            if active and character and hum and hrp then
                local state = hum:GetState()
                if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed then
                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, tonumber(jumpBox.Text) or 60, hrp.AssemblyLinearVelocity.Z)
                end
            end
        end)

        local elementsToHide = {speedBox, stealBox, jumpBox, speedLabel, stealLabel, jumpLabel}
        minimizeButton.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                minimizeButton.Text = "▼"; for _, v in pairs(elementsToHide) do v.Visible = false end
                TweenService:Create(main, TweenInfo.new(0.25), {Size = UDim2.new(0,200,0,70)}):Play()
            else
                minimizeButton.Text = "▲"; local t = TweenService:Create(main, TweenInfo.new(0.25), {Size = UDim2.new(0,200,0,185)}); t:Play()
                t.Completed:Connect(function() for _, v in pairs(elementsToHide) do v.Visible = true end end)
            end
        end)
        
        _U_I.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.L then gui.Enabled = not gui.Enabled end end)
    end

    -- [[ 既存の無限ジャンプ・RESPAWN ・ESP は維持 ]]
    local jumpForce = 50
    local clampFallSpeed = 80
    _R_S.Heartbeat:Connect(function()
        local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Velocity.Y < -clampFallSpeed then hrp.Velocity = Vector3.new(hrp.Velocity.X, -clampFallSpeed, hrp.Velocity.Z) end
    end)
    _U_I.JumpRequest:Connect(function()
        local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, jumpForce, hrp.Velocity.Z) end
    end)

    local function SafeRespawn()
        local char = LocalPlayer.Character
        if char then
            char:BreakJoints(); local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
            task.delay(0.1, function() if char and char.Parent then char:Destroy() end end)
        end
    end

    local function isPlayerBase(obj)
        if not (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) then return false end
        local n = obj.Name:lower(); local p = obj.Parent and obj.Parent.Name:lower() or ""
        return n:find("base") or n:find("claim") or p:find("base") or p:find("claim")
    end

    local baseEspInstances = {}
    _R_S.Heartbeat:Connect(function()
        local plotsFolder = _W_S:FindFirstChild("Plots")
        if not getgenv()._ESP_Active then 
            if plotsFolder then for _, plot in ipairs(plotsFolder:GetChildren()) do if plot:FindFirstChild("rznnq"..plot.Name) then plot["rznnq"..plot.Name]:Destroy() end end end
            for obj, trans in pairs(originalTransparency) do if obj and obj.Parent then obj.LocalTransparencyModifier = trans end end
            originalTransparency = {}; baseEspInstances = {}
            return 
        end
        if plotsFolder then
            for _, plot in ipairs(plotsFolder:GetChildren()) do
                local pBlock = plot:FindFirstChild("Purchases") and plot.Purchases:FindFirstChild("PlotBlock")
                local main = pBlock and pBlock:FindFirstChild("Main")
                local timeLabel = main and main:FindFirstChild("BillboardGui") and main.BillboardGui:FindFirstChild("RemainingTime")
                if timeLabel and main then
                    if not baseEspInstances[plot.Name] then
                        local billboard = Instance.new("BillboardGui", plot)
                        billboard.Name = "rznnq"..plot.Name; billboard.Size = UDim2.new(0,50,0,25); billboard.StudsOffset = Vector3.new(0,5,0); billboard.AlwaysOnTop = true; billboard.Adornee = main
                        local label = Instance.new("TextLabel", billboard)
                        label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 1; label.TextScaled = true; label.Font = Enum.Font.Arcade; label.TextColor3 = Color3.new(1,1,0); label.TextStrokeTransparency = 0
                        baseEspInstances[plot.Name] = billboard
                    end
                    baseEspInstances[plot.Name].TextLabel.Text = timeLabel.Text
                end
            end
        end
        for _, obj in ipairs(_W_S:GetDescendants()) do if isPlayerBase(obj) then if not originalTransparency[obj] then originalTransparency[obj] = obj.LocalTransparencyModifier end; obj.LocalTransparencyModifier = 0.8 end end
    end)

    -- [[ LAG Logic（Quantum Clonerを削除） ]]
    function StartTakeshiLagLogic()
        local targetTools = {"bat","laser cape","laser gun","flying carpet","rainbowrath sword", "taser gun"}
        task.spawn(function()
            while getgenv()._TakeshiLagActive do
                local char = LocalPlayer.Character; local bp = LocalPlayer:FindFirstChild("Backpack")
                if char and bp then 
                    for _, tool in ipairs(bp:GetChildren()) do
                        local name = string.lower(tool.Name)
                        for _, target in ipairs(targetTools) do
                            if string.find(name, target) then 
                                tool.Parent = char 
                                if not string.find(name, "rainbowrath sword") then
                                    if tool:FindFirstChild("RemoteEvent") then tool.RemoteEvent:FireServer()
                                    elseif tool:FindFirstChild("Activate") then tool.Activate:FireServer() end
                                    tool:Activate()
                                end
                                task.wait(getgenv()._LAG_SPEED)
                                tool.Parent = bp 
                            end
                        end
                    end
                end
                task.wait(getgenv()._LAG_SPEED)
            end
        end)
    end

    local function BuildMainUI()
        local targetGui = (gethui and gethui()) or _C_G
        if targetGui:FindFirstChild('kagamizero_008') then targetGui.kagamizero_008:Destroy() end
        local sg = Instance.new('ScreenGui', targetGui); sg.Name = 'kagamizero_008'; sg.ResetOnSpawn = false
        local main = Instance.new('Frame', sg)
        main.Size = UDim2.new(0, 160, 0, 230); main.Position = UDim2.new(0, 30, 0.45, 0); main.BackgroundColor3 = Color3.fromRGB(5, 5, 8); main.Active = true
        Instance.new('UICorner', main).CornerRadius = UDim.new(0, 8); local st = Instance.new('UIStroke', main); st.Thickness = 2; st.Color = Color3.fromRGB(0, 255, 255)
        
        local function SetupWindow(frame, titleText, barColor)
            local bar = Instance.new('Frame', frame); bar.Size = UDim2.new(1, 0, 0, 25); bar.BackgroundColor3 = barColor; Instance.new('UICorner', bar)
            local title = Instance.new("TextLabel", bar); title.Size = UDim2.new(1,0,1,0); title.BackgroundTransparency = 1; title.Text = titleText; title.TextColor3 = Color3.new(0,0,0); title.Font = Enum.Font.GothamBold; title.TextSize = 10
            local dragging, dragStart, startPos
            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = i.Position; startPos = frame.Position end end)
            _U_I.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - dragStart; frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
            _U_I.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
        end
        SetupWindow(main, "Kagamizero HUB", Color3.fromRGB(0, 255, 255))

        local function _Add(name, vars, pos, parent, callback)
            local btn = Instance.new('TextButton', parent)
            btn.Size, btn.Position = UDim2.new(0, parent.Size.X.Offset - 20, 0, 35), UDim2.new(0, 10, 0, pos)
            btn.BackgroundColor3 = Color3.fromRGB(15, 15, 20); btn.Text = name; btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.Code; btn.TextSize = 10
            local bs = Instance.new('UIStroke', btn); bs.Thickness = 1; bs.Color = Color3.fromRGB(50, 50, 50); Instance.new('UICorner', btn)
            btn.MouseButton1Click:Connect(function()
                if vars then
                    local nS = not getgenv()[vars[1]]
                    for _, v in ipairs(vars) do getgenv()[v] = nS end
                    bs.Color = nS and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(50, 50, 50); btn.TextColor3 = nS and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(200, 200, 200)
                    if callback then callback(nS) end
                else if callback then callback() end end
            end)
            return btn
        end

        -- Auto Steal ボタン (メインUIに追加)
        local autoStealBtn = _Add("AUTO STEAL", {"_AutoSteal"}, 35, main, function(state)
            ToggleAutoSteal(state)
        end)
        -- 初期状態をONに合わせる
        autoStealBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
        autoStealBtn.UIStroke.Color = Color3.fromRGB(0, 255, 255)
        
        _Add("ALL LAG", {"_TakeshiLagActive"}, 80, main, function(s) if s then StartTakeshiLagLogic() end end)
        _Add("ESP", {"_ESP_Active"}, 125, main)
        _Add("RESPAWN", nil, 170, main, SafeRespawn)

        _U_I.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end end)
    end

    task.spawn(function()
        while task.wait(0.01) do
            if getgenv()._AutoSteal and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local r = LocalPlayer.Character.HumanoidRootPart; local parts = _W_S:GetPartBoundsInRadius(r.Position, 12)
                for _, p in pairs(parts) do if p:FindFirstChildWhichIsA("TouchInterest") or p.Name:lower():find("brain") then firetouchinterest(r, p, 0); firetouchinterest(r, p, 1) end end
            end
        end
    end)
    
    StartSpeedCustomizer()
    task.defer(BuildMainUI)
end

-- Key System (維持)
local function BuildKeySystem()
    local savedData = ""
    pcall(function() if isfile and isfile(_SAVE_FILE) then savedData = readfile(_SAVE_FILE) end end)
    if savedData == (_PASS_KEY .. "|" .. _SCRIPT_VERSION) then InitializeScript(); return end
    local targetGui = (gethui and gethui()) or _C_G
    if targetGui:FindFirstChild('kagamizero_KeySystem') then targetGui.kagamizero_KeySystem:Destroy() end
    local sg = Instance.new('ScreenGui', targetGui); sg.Name = 'kagamizero_KeySystem'
    local frame = Instance.new('Frame', sg); frame.Size = UDim2.new(0, 260, 0, 140); frame.Position = UDim2.new(0.5, -130, 0.4, 0); frame.BackgroundColor3 = Color3.fromRGB(5, 5, 10); Instance.new('UICorner', frame)
    local st = Instance.new('UIStroke', frame); st.Color = Color3.fromRGB(0, 255, 255); st.Thickness = 2
    local title = Instance.new('TextLabel', frame); title.Size = UDim2.new(1,0,0,40); title.Text = "KAGAMIZERO PASSWORD"; title.TextColor3 = Color3.new(0,1,1); title.BackgroundTransparency = 1; title.Font = Enum.Font.Code; title.TextSize = 14
    local box = Instance.new('TextBox', frame); box.Size = UDim2.new(0, 220, 0, 35); box.Position = UDim2.new(0.5, -110, 0.4, 0); box.BackgroundColor3 = Color3.fromRGB(15, 15, 25); box.Text = ""; box.PlaceholderText = "パスワードを入力..."; box.TextColor3 = Color3.new(1,1,1); box.Font = Enum.Font.Code; Instance.new('UICorner', box)
    local btn = Instance.new('TextButton', frame); btn.Size = UDim2.new(0, 120, 0, 35); btn.Position = UDim2.new(0.5, -60, 0.75, 0); btn.Text = "認証"; btn.BackgroundColor3 = Color3.fromRGB(0, 255, 255); btn.TextColor3 = Color3.new(0,0,0); btn.Font = Enum.Font.GothamBold; Instance.new('UICorner', btn)
    btn.MouseButton1Click:Connect(function()
        if box.Text == _PASS_KEY then
            pcall(function() if writefile then writefile(_SAVE_FILE, _PASS_KEY .. "|" .. _SCRIPT_VERSION) end end)
            sg:Destroy(); InitializeScript()
        else
            box.Text = ""; box.PlaceholderText = "パスワードが違います"; st.Color = Color3.new(1,0,0); task.wait(1); st.Color = Color3.fromRGB(0, 255, 255); box.PlaceholderText = "パスワードを入力..."
        end
    end)
end

BuildKeySystem()
