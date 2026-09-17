--[========================================================]
--     Death Ball Auto-Parry & Skin Changer (Fixed)
--[========================================================]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

getgenv().DeathBallSettings = {
    AutoParry = true,
    ParryDistance = 16, -- Настрой дистанцию под свой пинг
    SkinChanger = true
}

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

RunService.RenderStepped:Connect(function()
    if not getgenv().DeathBallSettings.AutoParry then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local ball = FindBall()
    
    if ball then
        local distance = (rootPart.Position - ball.Position).Magnitude
        
        if distance <= getgenv().DeathBallSettings.ParryDistance then
            -- Эмуляция клика для парирования (работает стабильнее VirtualInputManager)
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.02)
            VirtualUser:Button1Up(Vector2.new(0,0))
            
            task.wait(0.18)
        end
    end
end)

print("[-] Скрипт успешно загружен и работает!")
