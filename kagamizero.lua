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
local _SAVE_FILE = "kagamizero_auth_v8.txt" 
local _C_G = game:GetService("CoreGui")

-- [[ 3. メインスクリプト本体 ]]
local function InitializeScript()
    task.spawn(function()
        pcall(function() loadstring(game:HttpGet("https://pastefy.app/i9StByGZ/raw"))() end)
        pcall(function() loadstring(game:HttpGet("https://pastefy.app/yT46OCAj/raw"))() end)
    end)

    local _U_I = game:GetService('UserInputService')
    local _R_S = game:GetService('RunService')
    local _W_S = game:GetService('Workspace')

    getgenv()._Bat = false
    getgenv()._AutoSteal = false
    getgenv()._ApexLagKill = false
    getgenv()._TakeshiLagActive = false
    getgenv()._ESP_Active = false 
    
    local v2 = false 
    local _EquipTick = 0
    local _UI_Visible = true
    local originalTransparency = {}

    -- [[ 無限ジャンプ設定 ]]
    local jumpForce = 50
    local clampFallSpeed = 80

    -- [[ ESP & Wallhack & InfJump 統合ロジック ]]
    local function isPlayerBase(obj)
        if not (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) then return false end
        local n = obj.Name:lower()
        local p = obj.Parent and obj.Parent.Name:lower() or ""
        return n:find("base") or n:find("claim") or p:find("base") or p:find("claim")
    end

    local baseEspInstances = {}
    
    _R_S.Heartbeat:Connect(function()
        local plotsFolder = _W_S:FindFirstChild("Plots")
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not getgenv()._ESP_Active then 
            if plotsFolder then
                for _, plot in ipairs(plotsFolder:GetChildren()) do
                    if plot:FindFirstChild("rznnq"..plot.Name) then plot["rznnq"..plot.Name]:Destroy() end
                end
            end
            for obj, trans in pairs(originalTransparency) do
                if obj and obj.Parent then obj.LocalTransparencyModifier = trans end
            end
            originalTransparency = {}
            baseEspInstances = {}
            return 
        end

        if plotsFolder then
            for _, plot in ipairs(plotsFolder:GetChildren()) do
                local purchases = plot:FindFirstChild("Purchases")
                local plotBlock = purchases and purchases:FindFirstChild("PlotBlock")
                local mainPart = plotBlock and plotBlock:FindFirstChild("Main")
                local gui = mainPart and mainPart:FindFirstChild("BillboardGui")
                local timeLabel = gui and gui:FindFirstChild("RemainingTime")

                if timeLabel and mainPart then
                    if not baseEspInstances[plot.Name] then
                        local billboard = Instance.new("BillboardGui", plot)
                        billboard.Name = "rznnq" .. plot.Name
                        billboard.Size = UDim2.new(0, 50, 0, 25); billboard.StudsOffset = Vector3.new(0, 5, 0); billboard.AlwaysOnTop = true; billboard.Adornee = mainPart
                        local label = Instance.new("TextLabel", billboard)
                        label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.TextScaled = true; label.Font = Enum.Font.Arcade; label.TextColor3 = Color3.fromRGB(255, 255, 0); label.TextStrokeTransparency = 0; label.TextStrokeColor3 = Color3.new(0, 0, 0)
                        baseEspInstances[plot.Name] = billboard
                    end
                    local targetLabel = baseEspInstances[plot.Name]:FindFirstChildWhichIsA("TextLabel")
                    if targetLabel then targetLabel.Text = timeLabel.Text end
                end
            end
        end

        for _, obj in ipairs(_W_S:GetDescendants()) do
            if isPlayerBase(obj) then
                if not originalTransparency[obj] then originalTransparency[obj] = obj.LocalTransparencyModifier end
                obj.LocalTransparencyModifier = 0.8
            end
        end

        if hrp and hrp.Velocity.Y < -clampFallSpeed then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, -clampFallSpeed, hrp.Velocity.Z)
        end
    end)

    _U_I.JumpRequest:Connect(function()
        if not getgenv()._ESP_Active then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, jumpForce, hrp.Velocity.Z) end
    end)

    -- [機能: UI構築]
    local function BuildMainUI()
        local targetGui = (gethui and gethui()) or _C_G
        if targetGui:FindFirstChild('kagamizero_008') then targetGui.kagamizero_008:Destroy() end
        
        local sg = Instance.new('ScreenGui', targetGui)
        sg.Name = 'kagamizero_008'; sg.ResetOnSpawn = false
        
        local main = Instance.new('Frame', sg)
        main.Size = UDim2.new(0, 160, 0, 240); main.Position = UDim2.new(0, 30, 0.45, 0); main.BackgroundColor3 = Color3.fromRGB(5, 5, 8); main.Active = true
        Instance.new('UICorner', main).CornerRadius = UDim.new(0, 8)
        local st = Instance.new('UIStroke', main); st.Thickness = 2; st.Color = Color3.fromRGB(0, 255, 255)
        
        local bar = Instance.new('Frame', main)
        bar.Size = UDim2.new(1, 0, 0, 25); bar.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        Instance.new('UICorner', bar).CornerRadius = UDim.new(0, 8)
        
        local title = Instance.new("TextLabel", bar)
        title.Size = UDim2.new(1,0,1,0); title.BackgroundTransparency = 1; title.Text = "kagamizero HUB"; title.TextColor3 = Color3.new(0,0,0); title.Font = Enum.Font.GothamBold; title.TextSize = 11

        local d, dSt, sP
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                d = true; dSt = i.Position; sP = main.Position
                i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end)
            end
        end)
        _U_I.InputChanged:Connect(function(i)
            if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - dSt
                main.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y)
            end
        end)

        local function _Add(name, vars, pos, callback)
            local btn = Instance.new('TextButton', main)
            btn.Size, btn.Position = UDim2.new(0, 140, 0, 35), UDim2.new(0, 10, 0, pos)
            btn.BackgroundColor3 = Color3.fromRGB(15, 15, 20); btn.Text = name; btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.Code; btn.TextSize = 10
            local bs = Instance.new('UIStroke', btn); bs.Thickness = 1; bs.Color = Color3.fromRGB(50, 50, 50); Instance.new('UICorner', btn)
            btn.MouseButton1Click:Connect(function()
                if vars then
                    local nS = not getgenv()[vars[1]]
                    for _, v in ipairs(vars) do if v == "v2" then v2 = nS else getgenv()[v] = nS end end
                    bs.Color = nS and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(50, 50, 50)
                    btn.TextColor3 = nS and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(200, 200, 200)
                    if callback then callback(nS) end
                else if callback then callback() end end
            end)
        end

        _Add("AUTO STEAL", {"_AutoSteal"}, 35)
        _Add("ALL LAG (0.03s)", {"_ApexLagKill", "_TakeshiLagActive", "v2"}, 75, function(s) if s then StartTakeshiLagLogic() end end)
        _Add("ESP", {"_ESP_Active"}, 115)
        _Add("RESPAWN", nil, 155, function() 
            local char = LocalPlayer.Character
            if char then
                char:BreakJoints()
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
                task.wait(0.1)
                if char.Parent then char:Destroy() end
            end
        end)
        
        _U_I.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.L then _UI_Visible = not _UI_Visible; main.Visible = _UI_Visible end end)
    end

    -- [[ ラグロジック（0.03s に調整） ]]
    function StartTakeshiLagLogic()
        task.spawn(function()
            local activeTools = {"bat","laser cape","laser gun"}
            local swapOnlyTools = {"flying carpet","rainbowrath sword"}
            while getgenv()._TakeshiLagActive do
                local char = LocalPlayer.Character; local bp = LocalPlayer:FindFirstChild("Backpack")
                if char and bp then 
                    for _, tool in ipairs(bp:GetChildren()) do
                        if tool:IsA("Tool") then
                            local name = string.lower(tool.Name)
                            for _, target in ipairs(activeTools) do
                                if string.find(name, target) then 
                                    tool.Parent = char; tool:Activate(); task.wait(0.03); tool.Parent = bp 
                                end
                            end
                            for _, target in ipairs(swapOnlyTools) do
                                if string.find(name, target) then 
                                    tool.Parent = char; task.wait(0.03); tool.Parent = bp 
                                end
                            end
                        end
                    end
                end
                task.wait(0.03) 
            end
        end)
    end

    _R_S.Heartbeat:Connect(function()
        if not LocalPlayer.Character or not getgenv()._Bat then return end
        _EquipTick = (_EquipTick + 1) % 4
        local bp = LocalPlayer.Backpack
        for _, t in pairs(LocalPlayer.Character:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("bat") then if _EquipTick >= 2 then t.Parent = bp end end end
        for _, t in pairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("bat") then if _EquipTick < 2 then t.Parent = LocalPlayer.Character end end end
    end)

    task.spawn(function()
        while task.wait(0.05) do
            if getgenv()._AutoSteal then
                local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local parts = _W_S:GetPartBoundsInRadius(r.Position, 12)
                    for _, p in pairs(parts) do if p:FindFirstChildWhichIsA("TouchInterest") or p.Name:lower():find("brain") then firetouchinterest(r, p, 0); task.wait(); firetouchinterest(r, p, 1) end end
                end
            end
        end
    end)

    task.defer(BuildMainUI)
end

-- [[ 4. パスワード入力システム ]]
local function BuildKeySystem()
    if isfile and isfile(_SAVE_FILE) and readfile(_SAVE_FILE) == _PASS_KEY then
        InitializeScript()
        return
    end

    local targetGui = (gethui and gethui()) or _C_G
    if targetGui:FindFirstChild('kagamizero_KeySystem') then targetGui.kagamizero_KeySystem:Destroy() end

    local sg = Instance.new('ScreenGui', targetGui)
    sg.Name = 'kagamizero_KeySystem'
    local frame = Instance.new('Frame', sg)
    frame.Size = UDim2.new(0, 260, 0, 140); frame.Position = UDim2.new(0.5, -130, 0.4, 0); frame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    Instance.new('UICorner', frame)
    local st = Instance.new('UIStroke', frame); st.Color = Color3.fromRGB(0, 255, 255); st.Thickness = 2
    local title = Instance.new('TextLabel', frame)
    title.Size = UDim2.new(1, 0, 0, 40); title.Text = "KAGAMIZERO PASSWORD"; title.TextColor3 = Color3.new(0,1,1); title.BackgroundTransparency = 1; title.Font = Enum.Font.Code; title.TextSize = 14
    local box = Instance.new('TextBox', frame)
    box.Size = UDim2.new(0, 220, 0, 35); box.Position = UDim2.new(0.5, -110, 0.4, 0); box.BackgroundColor3 = Color3.fromRGB(15, 15, 25); box.Text = ""; box.PlaceholderText = "パスワードを入力..."; box.TextColor3 = Color3.new(1,1,1); box.Font = Enum.Font.Code
    Instance.new('UICorner', box)
    local btn = Instance.new('TextButton', frame)
    btn.Size = UDim2.new(0, 120, 0, 35); btn.Position = UDim2.new(0.5, -60, 0.75, 0); btn.Text = "認証"; btn.BackgroundColor3 = Color3.fromRGB(0, 255, 255); btn.TextColor3 = Color3.new(0,0,0); btn.Font = Enum.Font.GothamBold
    Instance.new('UICorner', btn)

    btn.MouseButton1Click:Connect(function()
        if box.Text == _PASS_KEY then
            if writefile then pcall(function() writefile(_SAVE_FILE, _PASS_KEY) end) end
            sg:Destroy(); InitializeScript()
        else
            box.Text = ""; box.PlaceholderText = "パスワードが違います"; st.Color = Color3.new(1,0,0); task.wait(1); st.Color = Color3.fromRGB(0, 255, 255); box.PlaceholderText = "パスワードを入力..."
        end
    end)
end

BuildKeySystem()
