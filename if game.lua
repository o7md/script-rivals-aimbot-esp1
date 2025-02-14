if game.PlaceId == 17625359962 then
    local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
    local Window = OrionLib:MakeWindow({Name = "7md_iQ Hub | RIVALS", HidePremium = false, IntroText = "7md_iQ Hub", SaveConfig = true, ConfigFolder = "7md_iQConfig"})

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Aimbot_Enabled = false
    local AimRadius = 100
    local SmoothAim = 5
    local TargetPart = "Head"
    local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")

    -- ESP
    local ESP_Enabled = false
    local ESP_Highlights = {}
    local ESP_Texts = {}

    local FOV_Enabled = false
    local FOV_Radius = 100  -- نصف قطر دائرة FOV

    local FOVCircle = Instance.new("Frame")  -- الدائرة التي ستظهر على الشاشة
    FOVCircle.Parent = game:GetService("CoreGui")  -- جعلها تظهر في CoreGui
    FOVCircle.Size = UDim2.new(0, FOV_Radius * 2, 0, FOV_Radius * 2)
    FOVCircle.Position = UDim2.new(0.5, -FOV_Radius, 0.5, -FOV_Radius)
    FOVCircle.BorderSizePixel = 2
    FOVCircle.BorderColor3 = Color3.fromRGB(0, 255, 255)  -- اللون الفاتح
    FOVCircle.BackgroundTransparency = 0.5
    FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 255)  -- اللون الفاتح لدائرة الـ FOV
    FOVCircle.Visible = false  -- جعلها غير مرئية افتراضيًا

    -- إنشاء التبويب "Main"
    local MainTab = Window:MakeTab({
        Name = "Main",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- إنشاء التبويب "Visual"
    local VisualTab = Window:MakeTab({
        Name = "Visual",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- زر تفعيل Aimbot
    MainTab:AddToggle({
        Name = "Aimbot",
        Default = false,
        Callback = function(Value)
            Aimbot_Enabled = Value
        end
    })

    -- إضافة قائمة لاختيار الجزء المستهدف للأيمبوت
    MainTab:AddDropdown({
        Name = "Target Part",
        Default = "Head",  -- القيمة الافتراضية هي الرأس
        Options = {"Head", "Torso", "HumanoidRootPart"},
        Callback = function(Value)
            TargetPart = Value  -- تعيين الجزء الذي سيستهدفه الأيمبوت
        end
    })

    -- إضافة خيار لتفعيل دائرة الـ FOV
    MainTab:AddToggle({
        Name = "Enable FOV Circle",
        Default = false,
        Callback = function(Value)
            FOV_Enabled = Value
            FOVCircle.Visible = FOV_Enabled  -- إذا تم تفعيل الخيار، سيتم إظهار دائرة الـ FOV
        end
    })

    -- إضافة خيار لتحديد نصف قطر دائرة الـ FOV
    MainTab:AddSlider({
        Name = "FOV Radius",
        Min = 50,
        Max = 200,
        Default = FOV_Radius,
        Color = Color3.fromRGB(0, 255, 255),
        Increment = 10,
        Callback = function(Value)
            FOV_Radius = Value
            FOVCircle.Size = UDim2.new(0, FOV_Radius * 2, 0, FOV_Radius * 2)  -- تغيير حجم الدائرة بناءً على القيمة
            FOVCircle.Position = UDim2.new(0.5, -FOV_Radius, 0.5, -FOV_Radius)  -- تعديل موضع الدائرة
        end
    })

    -- دالة لإطلاق الرصاص نحو أي شخص داخل دائرة الـ FOV
    local function ShootTowardsFOVTarget()
        local mousePosition = UserInputService:GetMouseLocation()  -- الحصول على موقع الماوس
        local closestPlayer = nil
        local closestDistance = FOV_Radius

        -- العثور على أقرب لاعب داخل دائرة الـ FOV
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(TargetPart) then
                local targetPosition = player.Character[TargetPart].Position
                local screenPos = Camera:WorldToScreenPoint(targetPosition)
                local distance = (mousePosition - screenPos).Magnitude

                if distance <= FOV_Radius then
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end

        -- إذا تم العثور على لاعب داخل دائرة الـ FOV
        if closestPlayer then
            local rayOrigin = LocalPlayer.Character.HumanoidRootPart.Position
            local rayDirection = (closestPlayer.Character[TargetPart].Position - rayOrigin).unit * 1000
            local raycastResult = workspace:Raycast(rayOrigin, rayDirection)

            -- إذا تم الاصطفاف مع الهدف، قم بإطلاق الرصاصة
            if raycastResult then
                local bullet = Instance.new("Part")
                bullet.Size = Vector3.new(1, 1, 1)
                bullet.Position = raycastResult.Position
                bullet.Anchored = true
                bullet.Parent = workspace
            end
        end
    end

    -- إطلاق الطلقات نحو الهدف في دائرة الـ FOV
    RunService.Heartbeat:Connect(function()
        if Aimbot_Enabled and FOV_Enabled then
            ShootTowardsFOVTarget()
        end
    end)

    -- زر تفعيل ESP في التبويب Visual
    VisualTab:AddToggle({
        Name = "Enable ESP",
        Default = false,
        Callback = function(Value)
            ESP_Enabled = Value
            if ESP_Enabled then
                -- إنشاء Highlight لكل اللاعبين الموجودين
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        CreateHighlight(player)
                    end
                end
            else
                -- إخفاء كل الـ ESP
                for _, player in pairs(Players:GetPlayers()) do
                    RemoveHighlight(player)
                end
            end
        end
    })

    -- إضافة اللاعبين الجدد للـ ESP
    Players.PlayerAdded:Connect(function(player)
        if ESP_Enabled then
            CreateHighlight(player)
        end
    end)

    -- إزالة Highlight للاعبين الذين يغادرون
    Players.PlayerRemoving:Connect(function(player)
        RemoveHighlight(player)
    end)

    -- تحسين وظيفة الـ Highlight بشكل مستمر
    RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if ESP_Highlights[player] then
                local highlight = ESP_Highlights[player]
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local headPosition, onScreen = Camera:WorldToScreenPoint(player.Character.Head.Position)
                    local bodyPosition, bodyOnScreen = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)

                    if onScreen and bodyOnScreen then
                        highlight.Enabled = ESP_Enabled
                    else
                        highlight.Enabled = false
                    end
                else
                    highlight.Enabled = false
                end
            end
        end
    end)
end
