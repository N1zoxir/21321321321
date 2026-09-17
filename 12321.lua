--[========================================================]
--     Death Ball Script (Xeno Optimized + Native GUI)
--     Управление меню: клавиша RightShift (Правый Shift)
--[========================================================]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Удаляем старое меню, если оно было запущено
if CoreGui:FindFirstChild("DeathBallXenoGUI") then
    CoreGui.DeathBallXenoGUI:Destroy()
end

-- Настройки скрипта по умолчанию
getgenv().DBConfig = {
    AutoParry = false,
    ParryDistance = 16,
    SkinChanger = false
}

-- Создание графического интерфейса (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeathBallXenoGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 310)
MainFrame.Active = true
MainFrame.Draggable = true -- Меню можно перетаскивать мышкой

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Text = "Death Ball | Xeno Menu"

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Функция создания переключателей (Toggle)
local function CreateToggle(name, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Text = name .. ": [OFF]"
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 160, 80)
            btn.Text = name .. ": [ON]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.Text = name .. ": [OFF]"
        end
        callback(state)
    end)
end

-- Функция создания поля ввода текста (для дистанции)
local function CreateTextBox(name, yPos, defaultVal, callback)
    local label = Instance.new("TextLabel")
    label.Parent = MainFrame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0.05, 0, 0, yPos)
    label.Size = UDim2.new(0.5, 0, 0, 35)
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    
    local box = Instance.new("TextBox")
    box.Parent = MainFrame
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.Position = UDim2.new(0.65, 0, 0, yPos)
    box.Size = UDim2.new(0.3, 0, 0, 35)
    box.Font = Enum.Font.Gotham
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 14
    box.Text = tostring(defaultVal)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = box
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            callback(num)
        else
            box.Text = tostring(defaultVal)
        end
    end)
end

-- Добавление элементов в меню
CreateToggle("Auto Parry", 55, function(state)
    getgenv().DBConfig.AutoParry = state
end)

CreateTextBox("Parry Distance", 105, 16, function(val)
    getgenv().DBConfig.ParryDistance = val
end)

CreateToggle("Skin Changer (All Unlocks)", 155, function(state)
    getgenv().DBConfig.SkinChanger = state
end)

-- Подсказка управления
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = MainFrame
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0.05, 0, 0, 255)
InfoLabel.Size = UDim2.new(0.9, 0, 0, 35)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.TextSize = 12
InfoLabel.Text = "Скрыть/Показать меню: правый Shift"

-- Кнопка скрыть/показать по клавише RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Логика поиска мяча
local function FindBall()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj:FindFirstChild("Trail")) then
            if obj.AssemblyLinearVelocity.Magnitude > 5 then
                return obj
            end
        end
    end
    if workspace:FindFirstChild("Balls") then
        for _, ball in ipairs(workspace.Balls:GetChildren()) do
            if ball:IsA("BasePart") then return ball end
        end
    end
    return nil
end

-- Цикл авто-парирования
RunService.RenderStepped:Connect(function()
    if not getgenv().DBConfig.AutoParry then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local ball = FindBall()
    
    if ball then
        local distance = (rootPart.Position - ball.Position).Magnitude
        
        if distance <= getgenv().DBConfig.ParryDistance then
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.02)
            VirtualUser:Button1Up(Vector2.new(0,0))
            task.wait(0.18)
        end
    end
end)

-- Логика скин-ченджера (клиентская визуализация мечей и аур)
task.spawn(function()
    while task.wait(1) do
        if getgenv().DBConfig.SkinChanger then
            pcall(function()
                local character = LocalPlayer.Character
                if character then
                    local tool = character:FindFirstChildOfClass("Tool") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
                    if tool and tool:FindFirstChild("Handle") then
                        -- Применяем светящийся цвет к мечу для проверки работы визуального мода
                        tool.Handle.Color = Color3.fromRGB(0, 255, 255)
                    end
                end
            end)
        end
    end
end)

print("[-] Меню Death Ball успешно загружено для Xeno!")
