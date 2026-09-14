--[[
    SHADOWVELLEITY
    menu by shadow
    Version 8.0 (final)
--]]

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local WS = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local HttpService
pcall(function() HttpService = game:GetService("HttpService") end)

pcall(function()
    local old = CoreGui:FindFirstChild("Menu Shadowvelleity")
    if old then old:Destroy() end
    local pg = LP:FindFirstChild("PlayerGui")
    local old2 = pg and pg:FindFirstChild("Menu Shadowvelleity")
    if old2 then old2:Destroy() end
end)

local CONFIG_FILE = "Shadowvelleity_config.json"

local DefaultCfg = {
    TPOffset = 3,
    NpcRange = 60,
    MenuKey = "RightShift",
    TPKey = "Q",
    PossessKey = "E",
    RocketKey = "X",
    FlyKey = "F",
    ColorBg = {18, 18, 24},
    ColorHeader = {28, 28, 38},
    ColorAccent = {180, 80, 255},
    ColorText = {225, 225, 235},
    Transparency = 0,
}

local CFG = {}
for k, v in pairs(DefaultCfg) do
    if type(v) == "table" then
        CFG[k] = {v[1], v[2], v[3]}
    else
        CFG[k] = v
    end
end

local function saveCfg()
    if not writefile or not HttpService then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(CFG))
    end)
end

local function loadCfg()
    pcall(function()
        if not isfile or not readfile then return end
        if not isfile(CONFIG_FILE) then return end
        local raw = readfile(CONFIG_FILE)
        if not raw or raw == "" then return end
        local data = HttpService:JSONDecode(raw)
        if type(data) ~= "table" then return end
        for k, v in pairs(data) do
            if CFG[k] ~= nil then
                if type(v) == "table" and type(CFG[k]) == "table" then
                    CFG[k] = {v[1] or CFG[k][1], v[2] or CFG[k][2], v[3] or CFG[k][3]}
                else
                    CFG[k] = v
                end
            end
        end
    end)
end

loadCfg()

local function KeyFromString(s)
    local ok, k = pcall(function() return Enum.KeyCode[s] end)
    if ok and k then return k end
    return Enum.KeyCode.RightShift
end

local S = {
    SuperThrow = false,
    KillGrab = false,
    Possessing = false,
    Npc = nil,
    OrigCam = nil,
    JumpConn = nil,
    PossessLoop = nil,
    RocketDebounce = false,
    BindingKey = nil,
    EspEnabled = false,
    EspConn = nil,
    EspHighlights = {},
    EspTeamCheck = false,
    AntiGrab = false,
    AntiGrabConn = nil,
    FlyEnabled = false,
    FlyConn = nil,
    FlyBodyVel = nil,
    FlyGyro = nil,
}

local gui = Instance.new("ScreenGui")
gui.Name = "Menu Shadowvelleity"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then
    pcall(function() gui.Parent = LP:WaitForChild("PlayerGui") end)
end

local function c3(t)
    if type(t) ~= "table" then return Color3.fromRGB(180, 80, 255) end
    return Color3.fromRGB(t[1] or 180, t[2] or 80, t[3] or 255)
end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 620)
main.Position = UDim2.new(0, 40, 0.5, -310)
main.BackgroundColor3 = c3(CFG.ColorBg)
main.BackgroundTransparency = CFG.Transparency
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
local mc = Instance.new("UICorner", main)
mc.CornerRadius = UDim.new(0, 12)
local ms = Instance.new("UIStroke", main)
ms.Color = c3(CFG.ColorAccent)
ms.Thickness = 1.5
ms.Transparency = 0.3

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 52)
header.BackgroundColor3 = c3(CFG.ColorHeader)
header.BackgroundTransparency = CFG.Transparency
header.BorderSizePixel = 0
header.Parent = main
local hc = Instance.new("UICorner", header)
hc.CornerRadius = UDim.new(0, 12)
local hfix = Instance.new("Frame")
hfix.Size = UDim2.new(1, 0, 0, 14)
hfix.Position = UDim2.new(0, 0, 1, -14)
hfix.BackgroundColor3 = c3(CFG.ColorHeader)
hfix.BackgroundTransparency = CFG.Transparency
hfix.BorderSizePixel = 0
hfix.ZIndex = 1
hfix.Parent = header

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, -24, 0, 2)
accentLine.Position = UDim2.new(0, 12, 1, -2)
accentLine.BackgroundColor3 = c3(CFG.ColorAccent)
accentLine.BorderSizePixel = 0
accentLine.ZIndex = 2
accentLine.Parent = header
local alC = Instance.new("UICorner", accentLine)
alC.CornerRadius = UDim.new(1, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 16, 0, 2)
title.BackgroundTransparency = 1
title.Text = "SHADOWVELLEITY"
title.TextColor3 = c3(CFG.ColorAccent)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.ZIndex = 2
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -120, 0, 12)
subtitle.Position = UDim2.new(0, 16, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "menu by shadow · v8"
subtitle.TextColor3 = Color3.fromRGB(140, 140, 160)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.ZIndex = 2
subtitle.Parent = header

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(1, -70, 0.5, -4)
dot.BackgroundColor3 = c3(CFG.ColorAccent)
dot.BorderSizePixel = 0
dot.ZIndex = 2
dot.Parent = header
local dc = Instance.new("UICorner", dot)
dc.CornerRadius = UDim.new(1, 0)

local tbtn = Instance.new("TextButton")
tbtn.Size = UDim2.new(0, 30, 0, 30)
tbtn.Position = UDim2.new(1, -40, 0.5, -15)
tbtn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
tbtn.Text = "-"
tbtn.TextColor3 = Color3.fromRGB(200, 200, 210)
tbtn.Font = Enum.Font.GothamBold
tbtn.TextSize = 18
tbtn.BorderSizePixel = 0
tbtn.ZIndex = 3
tbtn.Parent = header
local tc = Instance.new("UICorner", tbtn)
tc.CornerRadius = UDim.new(0, 6)

local body = Instance.new("ScrollingFrame")
body.Size = UDim2.new(1, -20, 1, -66)
body.Position = UDim2.new(0, 10, 0, 62)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.CanvasSize = UDim2.new(0, 0, 0, 0)
body.ScrollBarThickness = 3
body.ScrollBarImageColor3 = c3(CFG.ColorAccent)
body.Parent = main

local layout = Instance.new("UIListLayout", body)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)

local function refresh()
    body.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refresh)

local AllToggles = {}

local function Section(t)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 26)
    holder.BackgroundTransparency = 1
    holder.Parent = body
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -6)
    bar.Position = UDim2.new(0, 6, 0, 3)
    bar.BackgroundColor3 = c3(CFG.ColorAccent)
    bar.BorderSizePixel = 0
    bar.Parent = holder
    local bc = Instance.new("UICorner", bar)
    bc.CornerRadius = UDim.new(1, 0)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -18, 1, 0)
    l.Position = UDim2.new(0, 16, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = t:upper()
    l.TextColor3 = c3(CFG.ColorAccent)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.Parent = holder
end

local function Toggle(n, k, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    b.AutoButtonColor = false
    b.Text = ""
    b.BorderSizePixel = 0
    b.Parent = body
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 6)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -80, 1, 0)
    lb.Position = UDim2.new(0, 12, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = n
    lb.TextColor3 = Color3.fromRGB(220, 220, 230)
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 13
    lb.Parent = b
    if k then
        local h = Instance.new("TextLabel")
        h.Size = UDim2.new(0, 40, 1, 0)
        h.Position = UDim2.new(0, 200, 0, 0)
        h.BackgroundTransparency = 1
        h.Text = "[" .. k .. "]"
        h.TextColor3 = Color3.fromRGB(110, 110, 130)
        h.TextXAlignment = Enum.TextXAlignment.Left
        h.Font = Enum.Font.Gotham
        h.TextSize = 11
        h.Parent = b
    end
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 34, 0, 18)
    ind.Position = UDim2.new(1, -44, 0.5, -9)
    ind.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
    ind.BorderSizePixel = 0
    ind.Parent = b
    local ic = Instance.new("UICorner", ind)
    ic.CornerRadius = UDim.new(1, 0)
    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 14, 0, 14)
    kn.Position = UDim2.new(0, 2, 0.5, -7)
    kn.BackgroundColor3 = Color3.fromRGB(180, 180, 195)
    kn.BorderSizePixel = 0
    kn.Parent = ind
    local kc = Instance.new("UICorner", kn)
    kc.CornerRadius = UDim.new(1, 0)
    local on = false
    b.MouseButton1Click:Connect(function()
        on = not on
        if on then
            b.BackgroundColor3 = Color3.fromRGB(38, 26, 50)
            ind.BackgroundColor3 = c3(CFG.ColorAccent)
            kn.Position = UDim2.new(1, -16, 0.5, -7)
        else
            b.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            ind.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
            kn.Position = UDim2.new(0, 2, 0.5, -7)
        end
        if cb then
            local ok, err = pcall(cb, on)
            if not ok then warn("[Shadow] " .. n .. ": " .. tostring(err)) end
        end
    end)
    table.insert(AllToggles, {btn = b, ind = ind, knob = kn, get = function() return on end})
end

local function Action(n, k, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    b.AutoButtonColor = false
    b.Text = ""
    b.BorderSizePixel = 0
    b.Parent = body
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 6)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -20, 1, 0)
    lb.Position = UDim2.new(0, 12, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = n
    lb.TextColor3 = Color3.fromRGB(225, 225, 235)
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 13
    lb.Parent = b
    if k then
        local h = Instance.new("TextLabel")
        h.Size = UDim2.new(0, 40, 1, 0)
        h.Position = UDim2.new(0, 200, 0, 0)
        h.BackgroundTransparency = 1
        h.Text = "[" .. k .. "]"
        h.TextColor3 = Color3.fromRGB(110, 110, 130)
        h.TextXAlignment = Enum.TextXAlignment.Left
        h.Font = Enum.Font.Gotham
        h.TextSize = 11
        h.Parent = b
    end
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(55, 55, 75) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(40, 40, 55) end)
    b.MouseButton1Click:Connect(function()
        if cb then
            local ok, err = pcall(cb)
            if not ok then warn("[Shadow] " .. n .. ": " .. tostring(err)) end
        end
    end)
end

local function Slider(n, min, max, default, cb, isColor)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 52)
    holder.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    holder.BorderSizePixel = 0
    holder.Parent = body
    local hc2 = Instance.new("UICorner", holder)
    hc2.CornerRadius = UDim.new(0, 6)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -20, 0, 20)
    lb.Position = UDim2.new(0, 12, 0, 4)
    lb.BackgroundTransparency = 1
    lb.Text = n .. ": " .. default
    lb.TextColor3 = Color3.fromRGB(220, 220, 230)
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.Parent = holder
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 4)
    track.Position = UDim2.new(0, 12, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
    track.BorderSizePixel = 0
    track.Parent = holder
    local tkc = Instance.new("UICorner", track)
    tkc.CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = isColor and Color3.fromRGB(default, default, default) or c3(CFG.ColorAccent)
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fc = Instance.new("UICorner", fill)
    fc.CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(220, 220, 235)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = track
    local knc = Instance.new("UICorner", knob)
    knc.CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function update(input)
        local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        rel = math.clamp(rel, 0, 1)
        local val = math.floor(min + rel * (max - min))
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        lb.Text = n .. ": " .. val
        if isColor then fill.BackgroundColor3 = Color3.fromRGB(val, val, val) end
        if cb then cb(val) end
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            saveCfg()
        end
    end)
end

local KeybindHandlers = {}

local function KeybindAction(n, getKey, setKey)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    b.AutoButtonColor = false
    b.Text = ""
    b.BorderSizePixel = 0
    b.Parent = body
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 6)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -100, 1, 0)
    lb.Position = UDim2.new(0, 12, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = n
    lb.TextColor3 = Color3.fromRGB(225, 225, 235)
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 13
    lb.Parent = b
    local keyLbl = Instance.new("TextLabel")
    keyLbl.Size = UDim2.new(0, 80, 1, 0)
    keyLbl.Position = UDim2.new(1, -88, 0, 0)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Text = "[" .. getKey() .. "]"
    keyLbl.TextColor3 = c3(CFG.ColorAccent)
    keyLbl.TextXAlignment = Enum.TextXAlignment.Right
    keyLbl.Font = Enum.Font.GothamBold
    keyLbl.TextSize = 12
    keyLbl.Parent = b
    local binding = false
    b.MouseButton1Click:Connect(function()
        if S.BindingKey then return end
        binding = true
        S.BindingKey = n
        keyLbl.Text = "[...]"
        keyLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
    end)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(55, 55, 75) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(40, 40, 55) end)
    return function(input)
        if binding and input then
            binding = false
            S.BindingKey = nil
            local name = input.KeyCode.Name
            setKey(name)
            keyLbl.Text = "[" .. name .. "]"
            keyLbl.TextColor3 = c3(CFG.ColorAccent)
            saveCfg()
            return true
        end
        return false
    end
end

local function applyColors()
    main.BackgroundColor3 = c3(CFG.ColorBg)
    main.BackgroundTransparency = CFG.Transparency
    header.BackgroundColor3 = c3(CFG.ColorHeader)
    header.BackgroundTransparency = CFG.Transparency
    hfix.BackgroundColor3 = c3(CFG.ColorHeader)
    hfix.BackgroundTransparency = CFG.Transparency
    title.TextColor3 = c3(CFG.ColorAccent)
    dot.BackgroundColor3 = c3(CFG.ColorAccent)
    accentLine.BackgroundColor3 = c3(CFG.ColorAccent)
    body.ScrollBarImageColor3 = c3(CFG.ColorAccent)
    ms.Color = c3(CFG.ColorAccent)
    for _, t in pairs(AllToggles) do
        if t.get() then
            t.ind.BackgroundColor3 = c3(CFG.ColorAccent)
        end
    end
end

local function TP()
    local ch = LP.Character
    if not ch then return end
    local h = ch:FindFirstChild("HumanoidRootPart")
    if not h then return end
    h.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, CFG.TPOffset, 0))
end

local function TogglePossess()
    if S.Possessing then
        if S.PossessLoop then S.PossessLoop:Disconnect() S.PossessLoop = nil end
        S.Possessing = false
        S.Npc = nil
        if S.OrigCam then WS.CurrentCamera.CameraSubject = S.OrigCam end
        local ch = LP.Character
        if ch then
            for _, p in pairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
            end
        end
        return
    end
    local ch = LP.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local best, dist = nil, CFG.NpcRange
    for _, o in pairs(WS:GetDescendants()) do
        if o:IsA("Model") and o ~= ch and o:FindFirstChildOfClass("Humanoid") and o:FindFirstChild("Head") then
            local r = o:FindFirstChild("HumanoidRootPart") or o:FindFirstChild("Torso")
            if r then
                local d = (r.Position - hrp.Position).Magnitude
                if d < dist then best, dist = o, d end
            end
        end
    end
    if best then
        S.OrigCam = WS.CurrentCamera.CameraSubject
        S.Possessing = true
        S.Npc = best
        WS.CurrentCamera.CameraSubject = best.Head
        for _, p in pairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then p.LocalTransparencyModifier = 1 end
        end
        S.PossessLoop = RS.Heartbeat:Connect(function()
            if not S.Possessing or not S.Npc then return end
            local chr = LP.Character
            local h2 = chr and chr:FindFirstChild("HumanoidRootPart")
            local head = S.Npc and S.Npc:FindFirstChild("Head")
            if h2 and head then h2.CFrame = head.CFrame end
        end)
    end
end

local function SpawnRocket()
    if S.RocketDebounce then return end
    S.RocketDebounce = true
    task.delay(1.5, function() S.RocketDebounce = false end)
    local ch = LP.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local rocket = Instance.new("Part")
    rocket.Name = "Shadow_Rocket"
    rocket.Size = Vector3.new(2, 2, 4)
    rocket.Shape = Enum.PartType.Block
    rocket.BrickColor = BrickColor.new("Really red")
    rocket.Material = Enum.Material.Neon
    rocket.CanCollide = false
    rocket.CFrame = hrp.CFrame * CFrame.new(0, 0, -6)
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = WS.CurrentCamera.CFrame.LookVector * 350
    bv.Parent = rocket
    local f = Instance.new("Fire")
    f.Size = 6
    f.Heat = 20
    f.Parent = rocket
    rocket.Parent = WS
    Debris:AddItem(rocket, 6)
    rocket.Touched:Connect(function(hit)
        if hit:IsDescendantOf(ch) then return end
        if hit == rocket then return end
        local explode = Instance.new("Explosion")
        explode.Position = rocket.Position
        explode.BlastRadius = 25
        explode.BlastPressure = 500000
        explode.Parent = WS
        rocket:Destroy()
    end)
end

local function FlyToggle(on)
    S.FlyEnabled = on
    if on then
        local ch = LP.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 1000
        bg.D = 50
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        S.FlyBodyVel = bv
        S.FlyGyro = bg
        if S.FlyConn then S.FlyConn:Disconnect() end
        S.FlyConn = RS.RenderStepped:Connect(function()
            if not S.FlyEnabled then return end
            local c = LP.Character
            if not c then return end
            local r = c:FindFirstChild("HumanoidRootPart")
            if not r then return end
            local cam = WS.CurrentCamera
            local move = Vector3.new(0, 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then move = move.Unit end
            if S.FlyBodyVel then S.FlyBodyVel.Velocity = move * 80 end
            if S.FlyGyro then S.FlyGyro.CFrame = cam.CFrame end
        end)
    else
        if S.FlyConn then S.FlyConn:Disconnect() S.FlyConn = nil end
        if S.FlyBodyVel then S.FlyBodyVel:Destroy() S.FlyBodyVel = nil end
        if S.FlyGyro then S.FlyGyro:Destroy() S.FlyGyro = nil end
    end
end

WS.ChildAdded:Connect(function(m)
    if m.Name ~= "GrabParts" then return end
    local gp = m:FindFirstChild("GrabPart")
    if not gp then return end
    local w = gp:FindFirstChild("WeldConstraint")
    if not w or not w.Part1 then return end
    local t = w.Part1
    if S.KillGrab and t:IsA("BasePart") then
        t:BreakJoints()
    end
    if not S.SuperThrow then return end
    for _, v in pairs(t:GetChildren()) do
        if v:IsA("BodyVelocity") then v:Destroy() end
    end
    local bv = Instance.new("BodyVelocity", t)
    bv.MaxForce = Vector3.new(0, 0, 0)
    bv.Velocity = Vector3.new(0, 0, 0)
    m:GetPropertyChangedSignal("Parent"):Connect(function()
        if m.Parent then return end
        if UIS:GetLastInputType() == Enum.UserInputType.MouseButton2 then
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = WS.CurrentCamera.CFrame.LookVector * 350
            Debris:AddItem(bv, 1)
        else
            bv:Destroy()
        end
    end)
end)

Section("Movement")
Toggle("Infinite Jump", "Space", function(on)
    if S.JumpConn then S.JumpConn:Disconnect() S.JumpConn = nil end
    if on then
        S.JumpConn = UIS.JumpRequest:Connect(function()
            local ch = LP.Character
            local h = ch and ch:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

Section("Camera")
Action("Teleport to Cursor", "Q", TP)
Action("Possess Nearest NPC", "E", TogglePossess)
Action("Unpossess", nil, function() if S.Possessing then TogglePossess() end end)

Section("Combat")
Toggle("Super Throw", "RMB", function(on) S.SuperThrow = on end)
Toggle("Kill Grab", nil, function(on) S.KillGrab = on end)

Section("Effects")
Action("Spawn Rocket", "X", SpawnRocket)
Toggle("Fly", "F", FlyToggle)

Section("Visuals")
Toggle("ESP", nil, function(on)
    S.EspEnabled = on
    if on then
        if S.EspConn then S.EspConn:Disconnect() end
        S.EspConn = RS.RenderStepped:Connect(function()
            local localTeam = LP.Team
            for _, pl in pairs(Players:GetPlayers()) do
                if pl ~= LP then
                    local ch = pl.Character
                    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                    local shouldShow = false
                    if ch and hrp and hum and hum.Health > 0 then
                        if not S.EspTeamCheck then shouldShow = true
                        elseif pl.Team ~= localTeam then shouldShow = true end
                    end
                    if shouldShow then
                        if not S.EspHighlights[pl] or not S.EspHighlights[pl].Parent or S.EspHighlights[pl].Parent ~= ch then
                            if S.EspHighlights[pl] then S.EspHighlights[pl]:Destroy() end
                            local hl = Instance.new("Highlight")
                            hl.Name = "ShadowESP"
                            hl.FillColor = c3(CFG.ColorAccent)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.6
                            hl.OutlineTransparency = 0.2
                            hl.Parent = ch
                            S.EspHighlights[pl] = hl
                        end
                    else
                        if S.EspHighlights[pl] then
                            S.EspHighlights[pl]:Destroy()
                            S.EspHighlights[pl] = nil
                        end
                    end
                end
            end
            for pl, hl in pairs(S.EspHighlights) do
                if not pl.Parent or not pl.Character then
                    hl:Destroy()
                    S.EspHighlights[pl] = nil
                end
            end
        end)
    else
        if S.EspConn then S.EspConn:Disconnect() S.EspConn = nil end
        for pl, hl in pairs(S.EspHighlights) do hl:Destroy() end
        S.EspHighlights = {}
    end
end)
Toggle("ESP Team Check", nil, function(on) S.EspTeamCheck = on end)

Section("Protection")
Toggle("Anti-Grab", nil, function(on)
    S.AntiGrab = on
    if on then
        if S.AntiGrabConn then S.AntiGrabConn:Disconnect() end
        S.AntiGrabConn = WS.ChildAdded:Connect(function(obj)
            if not S.AntiGrab then return end
            task.wait(0.1)
            if not obj.Parent then return end
            local ch = LP.Character
            if not ch then return end
            for _, d in pairs(obj:GetDescendants()) do
                if d:IsA("WeldConstraint") then
                    local p1 = d.Part1
                    local p2 = d.Part2
                    if (p1 and p1:IsDescendantOf(ch)) or (p2 and p2:IsDescendantOf(ch)) then
                        obj:Destroy()
                        return
                    end
                end
            end
        end)
    else
        if S.AntiGrabConn then S.AntiGrabConn:Disconnect() S.AntiGrabConn = nil end
    end
end)

Section("Values")
Slider("NPC Range", 10, 300, CFG.NpcRange, function(v) CFG.NpcRange = v end)

Section("Keybinds")
table.insert(KeybindHandlers, KeybindAction("Menu Toggle", function() return CFG.MenuKey end, function(n) CFG.MenuKey = n end))
table.insert(KeybindHandlers, KeybindAction("Teleport", function() return CFG.TPKey end, function(n) CFG.TPKey = n end))
table.insert(KeybindHandlers, KeybindAction("Possess NPC", function() return CFG.PossessKey end, function(n) CFG.PossessKey = n end))
table.insert(KeybindHandlers, KeybindAction("Rocket", function() return CFG.RocketKey end, function(n) CFG.RocketKey = n end))
table.insert(KeybindHandlers, KeybindAction("Fly", function() return CFG.FlyKey end, function(n) CFG.FlyKey = n end))

Section("Settings")
local presets = {
    {name = "Shadow (default)", bg = {18,18,24}, hd = {28,28,38}, ac = {180,80,255}},
    {name = "Dark Blue", bg = {15,18,30}, hd = {25,32,55}, ac = {80,150,255}},
    {name = "Red", bg = {30,15,15}, hd = {55,25,25}, ac = {230,70,70}},
    {name = "Green", bg = {15,28,18}, hd = {25,50,32}, ac = {80,220,120}},
}
for _, p in ipairs(presets) do
    Action(p.name, nil, function()
        CFG.ColorBg = {p.bg[1], p.bg[2], p.bg[3]}
        CFG.ColorHeader = {p.hd[1], p.hd[2], p.hd[3]}
        CFG.ColorAccent = {p.ac[1], p.ac[2], p.ac[3]}
        applyColors()
        saveCfg()
    end)
end
Slider("Bg R", 0, 255, CFG.ColorBg[1], function(v) CFG.ColorBg[1] = v; applyColors() end, true)
Slider("Bg G", 0, 255, CFG.ColorBg[2], function(v) CFG.ColorBg[2] = v; applyColors() end, true)
Slider("Bg B", 0, 255, CFG.ColorBg[3], function(v) CFG.ColorBg[3] = v; applyColors() end, true)
Slider("Accent R", 0, 255, CFG.ColorAccent[1], function(v) CFG.ColorAccent[1] = v; applyColors() end, true)
Slider("Accent G", 0, 255, CFG.ColorAccent[2], function(v) CFG.ColorAccent[2] = v; applyColors() end, true)
Slider("Accent B", 0, 255, CFG.ColorAccent[3], function(v) CFG.ColorAccent[3] = v; applyColors() end, true)
Slider("Transparency", 0, 100, math.floor(CFG.Transparency * 100), function(v)
    CFG.Transparency = v / 100
    applyColors()
end)

Section("Config")
Action("Save Config", nil, saveCfg)
Action("Reset Config", nil, function()
    for k, v in pairs(DefaultCfg) do
        if type(v) == "table" then CFG[k] = {v[1], v[2], v[3]}
        else CFG[k] = v end
    end
    applyColors()
    saveCfg()
end)

applyColors()
refresh()

-- KEY INPUT (финальный)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- режим привязки
    for _, handler in ipairs(KeybindHandlers) do
        if handler(input) then return end
    end

    -- LeftControl — закрыть меню
    if input.KeyCode == Enum.KeyCode.LeftControl then
        if main.Visible then
            main.Visible = false
        end
        return
    end

    -- меню
    if input.KeyCode == KeyFromString(CFG.MenuKey) then
        main.Visible = not main.Visible
        return
    end

    -- действия
    if input.KeyCode == KeyFromString(CFG.TPKey) then
        TP()
    elseif input.KeyCode == KeyFromString(CFG.PossessKey) then
        TogglePossess()
    elseif input.KeyCode == KeyFromString(CFG.RocketKey) then
        SpawnRocket()
    elseif input.KeyCode == KeyFromString(CFG.FlyKey) then
        FlyToggle(not S.FlyEnabled)
    end
end)

gui.Destroying:Connect(function()
    saveCfg()
end)

print("[Shadowvelleity] loaded.")
