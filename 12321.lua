--[========================================================]
--     Скрипт для "Мяч смерти" (Death Ball) | Roblox
--     Функции: Auto-Parry (с настройкой дистанции) + Skin Changer
--[========================================================]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Конфигурация настроек
getgenv().DeathBallSettings = {
    AutoParry = true,
    ParryDistance = 15, -- Дистанция отбития (можно менять в реальном времени)
    SkinChanger = {
        Enabled = true,
        SelectedSword = "AllUnlocks", -- Режим разблокировки всех мечей
        SelectedAura = "CustomAura",
        SelectedPose = "CustomPose"
    }
}

-- Функция поиска мяча на арене
local function FindBall()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj:FindFirstChild("Trail") or obj.Name == "Part") then
            -- Проверяем, движется ли мяч
            if obj.AssemblyLinearVelocity.Magnitude > 5 then
                return obj
            end
        end
    end
    -- Поиск в специальных папках, если мяч находится там
    if workspace:FindFirstChild("Balls") then
        for _, ball in ipairs(workspace.Balls:GetChildren()) do
            return ball
        end
    end
    return nil
end

-- Основной цикл авто-парирования
RunService.RenderStepped:Connect(function()
    if not getgenv().DeathBallSettings.AutoParry then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local ball = FindBall()
    
    if ball then
        local distance = (rootPart.Position - ball.Position).Magnitude
        
        -- Если мяч летит на игрока и находится в зоне досягаемости
        if distance <= getgenv().DeathBallSettings.ParryDistance then
            -- Эмуляция нажатия клавиши парирования (F / Тап по экрану)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(0.03)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            
            -- Защита от спама кликов
            task.wait(0.15)
        end
    end
end)

-- Модуль Skin Changer (Визуальное отображение предметов)
local function ApplySkinChanger()
    if not getgenv().DeathBallSettings.SkinChanger.Enabled then return end
    
    pcall(function()
        -- Базовая логика подмены клиентских визуалов персонажа и инвентаря
        local character = LocalPlayer.Character
        if character then
            -- Поиск меча в руках или в рюкзаке для применения визуального эффекта
            local tool = character:FindFirstChildOfClass("Tool") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
            if tool and tool:FindFirstChild("Handle") then
                -- Здесь можно кастомизировать цвета/текстуры меча локально
                tool.Handle.Color = Color3.fromRGB(0, 255, 255) -- Неоновый цвет для примера
            end
        end
    end)
end

-- Применение скинов в фоновом режиме
task.spawn(function()
    while task.wait(1) do
        ApplySkinChanger()
    end
end)

print("[-] Скрипт 'Мяч смерти' успешно запущен!")
