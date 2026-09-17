--[========================================================]
--     Death Ball | Universal Screen UI for Xeno & Delta
--[========================================================]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Универсальный поиск безопасного контейнера для GUI (Защита от сбоев Xeno)
local function GetSafeParent()
    if gethui then
        return gethui()
    end
    local success, _ = pcall(function() return game:GetService("CoreGui").Name end)
    if success then
        return game:GetService("CoreGui")
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ParentGui = GetSafeParent()

-- Удаление старого GUI перед запуском
if ParentGui:FindFirstChild("DeathBallXenoUI") then
    ParentGui.DeathBallXenoUI:Destroy()
end

-- Глобальный конфиг
getgenv().DBConfig = {
    AutoParry = false,
    ParryDistance = 16,
    SkinChanger = false
}

-- Создание главного экрана
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeathBallXenoUI"
ScreenGui.Parent = ParentGui
ScreenGui.ResetOnSpawn = false

-- 1. Плавающая кнопка для открытия/закрытия меню на экране
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "OpenCloseBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtn.Size = UDim2.new(0, 80, 0, 35)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.TextSize = 13
ToggleBtn.Active = true
ToggleBtn.Draggable = true -- Кнопку можно двигать по экрану

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

-- 2. Главное окно настроек
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Text = "Death Ball | Fixed Menu"

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Логика переключения видимости по кнопке
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Конструктор переключателей (Toggle)
local function AddToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Text = text .. ": OFF"
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
            btn.Text = text .. ": ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            btn.Text = text .. ": OFF"
        end
        callback(enabled)
    end)
end

-- Конструктор ввода текста
local function AddInput(text, yPos, defaultVal, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = MainFrame
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0.05, 0, 0, yPos)
    lbl.Size = UDim2.new(0.5, 0, 0, 35)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    
    local box = Instance.new("TextBox")
    box.Parent = MainFrame
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    box.Position = UDim2.new(0.65, 0, 0, yPos)
    box.Size = UDim2.new(0.3, 0, 0, 35)
    box.Font = Enum.Font.Gotham
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 13
    box.Text = tostring(defaultVal)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = box
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then callback(num) else box.Text = tostring(defaultVal) end
    end)
end

-- Элементы меню
AddToggle("Auto Parry", 55, function(val) getgenv().DBConfig.AutoParry = val end)
AddInput("Parry Distance", 105, 16, function(val) getgenv().DBConfig.ParryDistance = val end)
AddToggle("Skin Changer (All Unlocks)", 155, function(val) getgenv().DBConfig.SkinChanger = val end)

-- Хоткей Insert (дублирует плавающую кнопку)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Безопасный поиск мяча
local function GetBall()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj:FindFirstChild("Trail")) then
            return obj
        end
    end
    if workspace:FindFirstChild("Balls") then
        for _, ball in ipairs(workspace.Balls:GetChildren()) do
            if ball:IsA("BasePart") then return ball end
        end
    end
    return nil
end

-- Цикл Авто-парирования
RunService.RenderStepped:Connect(function()
    if not getgenv().DBConfig.AutoParry then return end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local ball = GetBall()
    if ball then
        local dist = (char.HumanoidRootPart.Position - ball.Position).Magnitude
        if dist <= getgenv().DBConfig.ParryDistance then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            else
                VirtualUser:Button1Down(Vector2.new(0,0))
                task.wait(0.01)
                VirtualUser:Button1Up(Vector2.new(0,0))
            end
            task.wait(0.12)
        end
    end
end)

-- Скинченджер
task.spawn(function()
    while task.wait(1) do
        if getgenv().DBConfig.SkinChanger then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
                    if tool and tool:FindFirstChild("Handle") then
                        tool.Handle.Color = Color3.fromRGB(0, 255, 200)
                    end
                end
            end)
        end
    end
end)

print("[+] Death Ball GUI полностью загружен!")
