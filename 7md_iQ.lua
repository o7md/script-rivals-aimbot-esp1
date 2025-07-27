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
    local ESP_Enabled = false
    local ESP_Highlights = {}
    local ESP_Texts = {}
    local function CreateHighlight(player)
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.fromRGB(0, 255, 0)  
        highlight.FillTransparency = 0.5 
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)  
        highlight.OutlineTransparency = 0 
        ESP_Highlights[player] = highlight
        local textLabel = Instance.new("BillboardGui")
        textLabel.Parent = player.Character
        textLabel.Adornee = player.Character:WaitForChild("Head")
        textLabel.Size = UDim2.new(0, 200, 0, 50)
        textLabel.StudsOffset = Vector3.new(0, 2, 0)
        textLabel.AlwaysOnTop = true 
        local label = Instance.new("TextLabel")
        label.Parent = textLabel
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(0, 0, 255) 
        label.TextStrokeTransparency = 0.8
        label.TextSize = 10  
        label.Text = player.Name .. "\nHealth: " .. player.Character:WaitForChild("Humanoid").Health
        ESP_Texts[player] = label
        RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                label.Text = player.Name .. "\nHealth: " .. math.floor(humanoid.Health)
            else
                textLabel.Enabled = false
            end
        end)
        RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local headPosition, onScreen = Camera:WorldToScreenPoint(player.Character.Head.Position)
                local bodyPosition, bodyOnScreen = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
                if onScreen and bodyOnScreen then
                    highlight.Enabled = ESP_Enabled
                    textLabel.Enabled = ESP_Enabled
                else
                    highlight.Enabled = false
                    textLabel.Enabled = false
                end
            else
                highlight.Enabled = false
                textLabel.Enabled = false
            end
        end)
    end
    local function RemoveHighlight(player)
        if ESP_Highlights[player] then
            ESP_Highlights[player]:Destroy()
            ESP_Highlights[player] = nil
        end

        if ESP_Texts[player] then
            ESP_Texts[player]:Destroy()
            ESP_Texts[player] = nil
        end
    end
    local MainTab = Window:MakeTab({
        Name = "Main",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    local VisualTab = Window:MakeTab({
        Name = "Visual",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    MainTab:AddToggle({
        Name = "Aimbot",
        Default = false,
        Callback = function(Value)
            Aimbot_Enabled = Value
        end
    })
    MainTab:AddDropdown({
        Name = "Target Part",
        Default = "Head", 
        Options = {"Head", "Torso", "HumanoidRootPart"},
        Callback = function(Value)
            TargetPart = Value
        end
    })
    VisualTab:AddToggle({
        Name = "Enable ESP",
        Default = false,
        Callback = function(Value)
            ESP_Enabled = Value
            if ESP_Enabled then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        CreateHighlight(player)
                    end
                end
            else
                for _, player in pairs(Players:GetPlayers()) do
                    RemoveHighlight(player)
                end
            end
        end
    })
    Players.PlayerAdded:Connect(function(player)
        if ESP_Enabled then
            CreateHighlight(player)
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        RemoveHighlight(player)
    end)
end
