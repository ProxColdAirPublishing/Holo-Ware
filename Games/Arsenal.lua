local HOLODATA = {
    Name = "Holo-Ware",
    Version = "V2 Priv",
    GameName = "Arsenal",
    UseScriptDebuging = false
}
getgenv().CanCommitToExecutible = true
if getgenv().CanCommitToExecutible == true then
local repo = 'https://raw.githubusercontent.com/ProxColdAirPublishing/Ghost-X/main/Library/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

    local Window = Library:CreateWindow({
        Size = UDim2.new(0,550,0,700),
        Title = "".. HOLODATA.Name .." | ".. HOLODATA.Version .." | ".. HOLODATA.GameName .."",
        Center = true, 
        AutoShow = true,
    })
    local Tabs = {
        ['General'] = Window:AddTab('General'),
        ['Visuals'] = Window:AddTab('Visuals'),
        ['UI Settings'] = Window:AddTab('Settings')
    }

--! >Local/Vars \
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera

local LocalPlayer = Players.LocalPlayer
local RequiredDistance = math.huge
local Typing = false
local Running = false
local Animation = nil
local ServiceConnections = {RenderSteppedConnection = nil, InputBeganConnection = nil, InputEndedConnection = nil, TypingStartedConnection = nil, TypingEndedConnection = nil}

local R6BodyParts = {
	"Head",
	"Torso",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg"
}
local UniversalBodyParts = {
	"Head",
	"UpperTorso",
	"LowerTorso",
	"Torso",
	"Left Arm",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"Right Arm",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"Left Leg",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"Right Leg",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot"
}

--*\ AimbotSetup /*--
--// Preventing Multiple Processes

pcall(function()
    getgenv().Aimbot.Functions:Exit()
end)

--// Environment

getgenv().Aimbot = {}
local Environment = getgenv().Aimbot

--// Services

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera

--// Variables

local LocalPlayer = Players.LocalPlayer
local RequiredDistance = math.huge
local Typing = false
local Running = false
local Animation = nil
local ServiceConnections = {RenderSteppedConnection = nil, InputBeganConnection = nil, InputEndedConnection = nil, TypingStartedConnection = nil, TypingEndedConnection = nil}

--// Script Settings

Environment.Settings = {
    Enabled = false,
    TeamCheck = false,
    AliveCheck = false,
    WallCheck = false, -- Laggy
    Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
    TriggerKey = "MouseButton2",
    Toggle = false,
    LockPart = "Head" -- Body part to lock on
}

Environment.FOVSettings = {
    Enabled = false,
    Visible = false,
    Amount = 0,
    Color = Color3.fromRGB(255,255,255),
    LockedColor = Color3.fromRGB(0,0,0),
    Transparency = 1,
    Sides = 0,
    Thickness = 1,
    Filled = false
}

Environment.FOVCircle = Drawing.new("Circle")
Environment.Locked = nil

--// Core Functions

local function Encode(Table)
    if Table and type(Table) == "table" then
        local EncodedTable = HttpService:JSONEncode(Table)

        return EncodedTable
    end
end

local function Decode(String)
    if String and type(String) == "string" then
        local DecodedTable = HttpService:JSONDecode(String)

        return DecodedTable
    end
end

local function GetColor(Color)
    local R = tonumber(string.match(Color, "([%d]+)[%s]*,[%s]*[%d]+[%s]*,[%s]*[%d]+"))
    local G = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*([%d]+)[%s]*,[%s]*[%d]+"))
    local B = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*[%d]+[%s]*,[%s]*([%d]+)"))

    return Color3.fromRGB(R, G, B)
end

--// Functions
local function GetClosestPlayer()
    if Environment.Locked == nil then
        if Environment.FOVSettings.Enabled then
            RequiredDistance = Environment.FOVSettings.Amount
        else
            RequiredDistance = math.huge
        end

        for _, v in next, Players:GetPlayers() do
            if v ~= LocalPlayer then
                if v.Character and v.Character[Environment.Settings.LockPart] then
                    if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
                    if Environment.Settings.AliveCheck and v.Character.Humanoid.Health <= 0 then continue end
                    if Environment.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end

                    local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position)
                    local Distance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude

                    if Distance < RequiredDistance and OnScreen then
                        RequiredDistance = Distance
                        Environment.Locked = v
                    end
                end
            end
        end
    elseif 
    (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).X, Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).Y)).Magnitude > RequiredDistance then
        Environment.Locked = nil
        Animation:Cancel()
        Environment.FOVCircle.Color = Environment.FOVSettings.Color
    end
end

--// Typing Check

ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

--// Create, Save & Load Settings
local function Load()
    ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
        if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
            if Environment.FOVSettings.Dynamic == true then
                Environment.FOVCircle.Radius = Environment.FOVSettings.Amount * (Camera.FieldOfView * 2)
            else
                Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
            end
            Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
            Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
            Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
            Environment.FOVCircle.Color = Environment.FOVSettings.Color
            Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
            Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
            Environment.FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        else
            Environment.FOVCircle.Visible = false
        end

        if Running and Environment.Settings.Enabled then
            GetClosestPlayer()

            if Environment.Settings.Sensitivity > 0 then
                Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)})
                Animation:Play()
            else
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)
            end

            Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor
        end
    end)

    ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
        if not Typing then
            pcall(function()
                if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
                    if Environment.Settings.Toggle then
                        Running = not Running

                        if not Running then
                            Environment.Locked = nil
                            Animation:Cancel()
                            Environment.FOVCircle.Color = Environment.FOVSettings.Color
                        end
                    else
                        Running = true
                    end
                end
            end)

            pcall(function()
                if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
                    if Environment.Settings.Toggle then
                        Running = not Running

                        if not Running then
                            Environment.Locked = nil
                            Animation:Cancel()
                            Environment.FOVCircle.Color = Environment.FOVSettings.Color
                        end
                    else
                        Running = true
                    end
                end
            end)
        end
    end)

    ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
        if not Typing then
            pcall(function()
                if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
                    if not Environment.Settings.Toggle then
                        Running = false
                        Environment.Locked = nil
                        Animation:Cancel()
                        Environment.FOVCircle.Color = Environment.FOVSettings.Color
                    end
                end
            end)

            pcall(function()
                if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
                    if not Environment.Settings.Toggle then
                        Running = false
                        Environment.Locked = nil
                        Animation:Cancel()
                        Environment.FOVCircle.Color = Environment.FOVSettings.Color
                    end
                end
            end)
        end
    end)
end

--// Functions

Environment.Functions = {}

function Environment.Functions:Exit()

    for _, v in next, ServiceConnections do
        v:Disconnect()
    end

    Environment.FOVCircle:Remove()

    getgenv().Aimbot.Functions = nil
    getgenv().Aimbot = nil
end

function Environment.Functions:Restart()

    for _, v in next, ServiceConnections do
        v:Disconnect()
    end

    Environment.FOVCircle:Remove()

    Load()
end

function Environment.Functions:ResetSettings()
    Environment.Settings = {
        Enabled = false,
        TeamCheck = false,
        AliveCheck = false,
        WallCheck = false,
        Sensitivity = 0.2, -- Animation length (in seconds) before fully locking onto target
        TriggerKey = "MouseButton2",
        Toggle = false,
        LockPart = "Head" -- Body part to lock on
    }

    Environment.FOVSettings = {
        Enabled = false,
        Visible = false,
        Amount = 90,
        Dynamic = false,
        Color = Color3.fromRGB(255,255,255),
        LockedColor = Color3.fromRGB(0,0,0),
        Transparency = 0.5,
        Sides = 60,
        Thickness = 1,
        Filled = false
    }

    for _, v in next, ServiceConnections do
        v:Disconnect()
    end

    Load()
end

--// Support Check

if not Drawing or not writefile or not makefolder then

end

--// Reload On Teleport

--// Load

Load();
--*\ End Of Aimbot /*--

--*\ ESP Setup /*--
-- made by rang#2415 or https://v3rmillion.net/member.php?action=profile&uid=1906262
local ESPConfig = {
    Enabled = false,
    Box = false,
    BoxOutline = false,
    BoxColor = Color3.fromRGB(255,255,255),
    BoxOutlineColor = Color3.fromRGB(0,0,0),
    HealthBar = false,
    HealthBarSide = "Left", -- Left,Bottom,Right
    Names = false,
    NamesOutline = false,
    NamesColor = Color3.fromRGB(255,255,255),
    NamesOutlineColor = Color3.fromRGB(0,0,0),
    NamesFont = 2, -- 0,1,2,3
    NamesSize = 13,
    UseTeamColours = false,
    TeamCheck = false,
}

function CreateEsp(Player)
    local Box,BoxOutline,Name,HealthBar,HealthBarOutline = Drawing.new("Square"),Drawing.new("Square"),Drawing.new("Text"),Drawing.new("Square"),Drawing.new("Square")
    local Updater = game:GetService("RunService").RenderStepped:Connect(function()
    if Player.Character ~= nil and Player.Character:FindFirstChild("Humanoid") ~= nil and Player.Character:FindFirstChild("HumanoidRootPart") ~= nil and Player.Character.Humanoid.Health > 0 and Player.Character:FindFirstChild("Head") ~= nil and Players[Player.Name] ~= nil then
            local Target2dPosition,IsVisible = workspace.CurrentCamera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)
            local scale_factor = 1 / (Target2dPosition.Z * math.tan(math.rad(workspace.CurrentCamera.FieldOfView * 0.5)) * 2) * 100
            local width, height = math.floor(40 * scale_factor), math.floor(60 * scale_factor)
            if ESPConfig.Box then
                Box.Visible = IsVisible
                Box.Size = Vector2.new(width,height)
                if ESPConfig.UseTeamColours == true then 
                    Box.Color = Player.TeamColor.Color
                elseif ESPConfig.UseTeamColours == false then
                    Box.Color = ESPConfig.BoxColor 
                end
                Box.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2)
                Box.Thickness = 1
                Box.ZIndex = 999
                if ESPConfig.BoxOutline then
                    BoxOutline.Visible = IsVisible
                    BoxOutline.Color = ESPConfig.BoxOutlineColor
                    BoxOutline.Size = Vector2.new(width,height)
                    BoxOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2)
                    BoxOutline.Thickness = 3
                    BoxOutline.ZIndex = 1
                else
                    BoxOutline.Visible = false
                end
            else
                Box.Visible = false
                BoxOutline.Visible = false
            end
            if ESPConfig.Names then
                Name.Visible = IsVisible
                Name.Text = Player.Name.." "..math.floor((workspace.CurrentCamera.CFrame.p - Player.Character.HumanoidRootPart.Position).magnitude).."m"
                Name.Center = true
                if ESPConfig.UseTeamColours == true then 
                    Name.Color = Player.TeamColor.Color
                elseif ESPConfig.UseTeamColours == false then
                    Name.Color = ESPConfig.NamesColor 
                end
                Name.Outline = ESPConfig.NamesOutline
                Name.OutlineColor = ESPConfig.NamesOutlineColor
                Name.Position = Vector2.new(Target2dPosition.X,Target2dPosition.Y - height * 0.5 + -15)
                Name.Font = ESPConfig.NamesFont
                Name.Size = ESPConfig.NamesSize
            else
                Name.Visible = false
            end
            if ESPConfig.HealthBar then
                HealthBarOutline.Visible = IsVisible
                HealthBarOutline.Color = Color3.fromRGB(0,0,0)
                HealthBarOutline.Filled = true
                HealthBarOutline.ZIndex = 1
    
                HealthBar.Visible = IsVisible
                HealthBar.Color = Color3.fromRGB(255,0,0):lerp(Color3.fromRGB(0,255,0), Player.Character:FindFirstChild("Humanoid").Health/Player.Character:FindFirstChild("Humanoid").MaxHealth)
                HealthBar.Thickness = 1
                HealthBar.Filled = true
                HealthBar.ZIndex = 69
                if ESPConfig.HealthBarSide == "Left" then
                    HealthBarOutline.Size = Vector2.new(2,height)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(-3,0)
                    
                    HealthBar.Size = Vector2.new(1,-(HealthBarOutline.Size.Y - 2) * (Player.Character:FindFirstChild("Humanoid").Health/Player.Character:FindFirstChild("Humanoid").MaxHealth))
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                elseif ESPConfig.HealthBarSide == "Bottom" then
                    HealthBarOutline.Size = Vector2.new(width,3)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(0,height + 2)

                    HealthBar.Size = Vector2.new((HealthBarOutline.Size.X - 2) * (Player.Character:FindFirstChild("Humanoid").Health/Player.Character:FindFirstChild("Humanoid").MaxHealth),1)
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                elseif ESPConfig.HealthBarSide == "Right" then
                    HealthBarOutline.Size = Vector2.new(2,height)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(width + 1,0)
                    
                    HealthBar.Size = Vector2.new(1,-(HealthBarOutline.Size.Y - 2) * (Player.Character:FindFirstChild("Humanoid").Health/Player.Character:FindFirstChild("Humanoid").MaxHealth))
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                end
            else
                HealthBar.Visible = false
                HealthBarOutline.Visible = false
            end
            if ESPConfig.TeamCheck == true then
                if Player.TeamColor == LocalPlayer.TeamColor then
                    Box.Visible = false
                    BoxOutline.Visible = false
                    Name.Visible = false
                    HealthBar.Visible = false
                    HealthBarOutline.Visible = false
                end
            end
            if ESPConfig.Enabled == false then
                Box.Visible = false
                BoxOutline.Visible = false
                Name.Visible = false
                HealthBar.Visible = false
                HealthBarOutline.Visible = false
            end
        else
            if Player.Character == nil or Player == nil then
                Box.Visible = false
                BoxOutline.Visible = false
                Name.Visible = false
                HealthBar.Visible = false
                HealthBarOutline.Visible = false
                Box:Remove()
                BoxOutline:Remove()
                Name:Remove()
                HealthBar:Remove()
                HealthBarOutline:Remove()
                Updater:Disconnect()
            end
        end
    end)
end

for _,v in pairs(game:GetService("Players"):GetPlayers()) do
   if v ~= game:GetService("Players").LocalPlayer then
      CreateEsp(v)
      v.CharacterAdded:Connect(CreateEsp(v))
   end
end

game:GetService("Players").PlayerAdded:Connect(function(v)
   if v ~= game:GetService("Players").LocalPlayer then
      CreateEsp(v)
      v.CharacterAdded:Connect(CreateEsp(v))
   end
end)
--*\ End Of ESP \*--

--*\ Out Of View Arrows /*--
-- Made by Blissful#4992

local TriangleEnabled = false
local DistFromCenter = 80
local TriangleHeight = 16
local TriangleWidth = 16
local TriangleFilled = true
local TriangleTransparency = 0
local TriangleThickness = 1
local TriangleColor = Color3.fromRGB(255, 255, 255)
local AntiAliasing = false
local OOVUseTeamColor = false
local OOVTeamCheck = false

----------------------------------------------------------------

local Players = game:service("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RS = game:service("RunService")

local V3 = Vector3.new
local V2 = Vector2.new
local CF = CFrame.new
local COS = math.cos
local SIN = math.sin
local RAD = math.rad
local DRAWING = Drawing.new
local CWRAP = coroutine.wrap
local ROUND = math.round

local function GetRelative(pos, char)
    if not char then return V2(0,0) end

    local rootP = char.PrimaryPart.Position
    local camP = Camera.CFrame.Position
    local relative = CF(V3(rootP.X, camP.Y, rootP.Z), camP):PointToObjectSpace(pos)

    return V2(relative.X, relative.Z)
end

local function RelativeToCenter(v)
    return Camera.ViewportSize/2 - v
end

local function RotateVect(v, a)
    a = RAD(a)
    local x = v.x * COS(a) - v.y * SIN(a)
    local y = v.x * SIN(a) + v.y * COS(a)

    return V2(x, y)
end

local function AntiA(v)
    if (not AntiAliasing) then return v end
    return V2(ROUND(v.x), ROUND(v.y))
end

local function ShowArrow(PLAYER)
    local Arrow = DRAWING("Triangle")
    local function Update()
        local c ; c = RS.RenderStepped:Connect(function()
            if OOVUseTeamColor == true then
                Arrow.Color = PLAYER.TeamColor.Color
            elseif OOVUseTeamColor == false then
                Arrow.Color = TriangleColor
            end
            Arrow.Filled = TriangleFilled
            Arrow.Thickness = TriangleThickness
            Arrow.Transparency = TriangleTransparency
            if PLAYER and PLAYER.Character then
                local CHAR = PLAYER.Character
                local HUM = CHAR:FindFirstChildOfClass("Humanoid")
                if HUM and CHAR.PrimaryPart ~= nil and HUM.Health > 0 then
                    local _,vis = Camera:WorldToViewportPoint(CHAR.PrimaryPart.Position)
                    if vis == false then
                        local rel = GetRelative(CHAR.PrimaryPart.Position, Player.Character)
                        local direction = rel.unit

                        local base  = direction * DistFromCenter
                        local sideLength = TriangleWidth/2
                        local baseL = base + RotateVect(direction, 90) * sideLength
                        local baseR = base + RotateVect(direction, -90) * sideLength

                        local tip = direction * (DistFromCenter + TriangleHeight)
                        
                        Arrow.PointA = AntiA(RelativeToCenter(baseL))
                        Arrow.PointB = AntiA(RelativeToCenter(baseR))

                        Arrow.PointC = AntiA(RelativeToCenter(tip))

                        Arrow.Visible = true
                        if OOVTeamCheck == true and PLAYER.TeamColor == LocalPlayer.TeamColor then
                            Arrow.Visible = false
                        end
                        if TriangleEnabled == false then
                            Arrow.Visible = false
                        end
                    else Arrow.Visible = false end
                else Arrow.Visible = false end
            else 
                Arrow.Visible = false

                if not PLAYER or not PLAYER.Parent then
                    Arrow:Remove()
                    c:Disconnect()
                end
            end
        end)
    end

    CWRAP(Update)()
end

for _,v in pairs(Players:GetChildren()) do
    if v.Name ~= Player.Name then
        ShowArrow(v)
    end
end

Players.PlayerAdded:Connect(function(v)
    if v.Name ~= Player.Name then
        ShowArrow(v)
    end
end)
--*\ End of OOVA \*--


--! End Of Locals< /


--! >Functions \
function Library:InitManagers(args)
    --* Settings
    Library.KeybindFrame.Visible = false;
    Library:OnUnload(function() Library.Unloaded = true end)
    --\
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
        MenuGroup:AddButton('Unload', function() Library:Unload() end)
        MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' }) 

        Library.ToggleKeybind = Options.MenuKeybind

        ThemeManager:SetLibrary(Library)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings() 
        SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 
        ThemeManager:SetFolder('HoloWare')
        SaveManager:SetFolder('HoloWare/'.. HOLODATA.GameName)
        SaveManager:BuildConfigSection(Tabs['UI Settings'])
        ThemeManager:ApplyToTab(Tabs['UI Settings'])
    --/
end
--! End Of Functions /





--! UI \

-- --* General \
local AimbotTabLeft = Tabs.General:AddLeftGroupbox('Aimbot')
AimbotTabLeft:AddToggle('ABEnabledToggle', {
    Text = 'Enabled',
    Default = false,
    Tooltip = 'Enable/Disable Aimbot | Press M2',
})
AimbotTabLeft:AddToggle('ABTeamCheckToggle', {
    Text = 'TeamCheck',
    Default = false,
    Tooltip = 'Checks if the target is on the enemy team, if so then it will be a valid target and can be locked on to.',
})
AimbotTabLeft:AddToggle('ABAliveCheckToggle', {
    Text = 'AliveCheck',
    Default = false,
    Tooltip = "Checks if the target is alive (if the target is > 0 health), if so it will be locked onto",
})
AimbotTabLeft:AddToggle('ABWallCheckToggle', {
    Text = 'WallCheck',
    Default = false,
    Tooltip = 'Checks if the target is behind a wall of not, if not then it is a valid target and can be locked on to | Unstable/Laggy, Not Reccomended',
})
AimbotTabLeft:AddSlider('ABSensitivitySlider', {
    Text = 'Sensitivity',
    Default = 0,
    Min = 0,
    Max = 0.5,
    Rounding = 2,
    Compact = false,
})
AimbotTabLeft:AddLabel('Aimbot Activation'):AddKeyPicker('ActivateAimbotKey', {
    Default = 'MB2',
    SyncToggleState = false, 
    Mode = 'Hold',
    Text = 'Active Aimbot',
    NoUI = false,
})
AimbotTabLeft:AddToggle('AB_USETOGGLE', {
    Text = 'Use Toggle',
    Default = false,
    Tooltip = 'When active, activation of the aimbot will be done by toggling not holding/pressing M2',
})
AimbotTabLeft:AddDropdown('ABAimpartDropDown', {
    Values = { 'Head', 'Torso', 'HumanoidRootPart' },
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'AimPart',
    Tooltip = 'What part the aimbot will target', -- Information shown when you hover over the textbox
})
Toggles.ABEnabledToggle:OnChanged(function() getgenv().Aimbot.Settings.Enabled = Toggles.ABEnabledToggle.Value end)
Toggles.ABTeamCheckToggle:OnChanged(function() getgenv().Aimbot.Settings.TeamCheck = Toggles.ABTeamCheckToggle.Value end)
Toggles.ABAliveCheckToggle:OnChanged(function() getgenv().Aimbot.Settings.AliveCheck = Toggles.ABAliveCheckToggle.Value end)
Toggles.ABWallCheckToggle:OnChanged(function() getgenv().Aimbot.Settings.WallCheck = Toggles.ABWallCheckToggle.Value end)
Options.ABSensitivitySlider:OnChanged(function() getgenv().Aimbot.Settings.Sensitivity = Options.ABSensitivitySlider.Value end)
Options.ActivateAimbotKey:OnClick(function() getgenv().Aimbot.Settings.TriggerKey = Options.ActivateAimbotKey.Value end)
Toggles.AB_USETOGGLE:OnChanged(function() getgenv().Aimbot.Settings.Toggle = Toggles.AB_USETOGGLE.Value end)
Options.ABAimpartDropDown:OnChanged(function() getgenv().Aimbot.Settings.LockPart = Options.ABAimpartDropDown.Value end)
AimbotTabLeft:AddLabel('FOV Settings')
AimbotTabLeft:AddToggle('ABIngoreFOVToggle', {
    Text = 'Enabled',
    Default = false,
    Tooltip = 'If the script will use the FOV or not',
})
AimbotTabLeft:AddToggle('ABFOVVisibleToggle', {
    Text = 'FOV Visible',
    Default = false,
    Tooltip = 'Enable/Disable Circle Visiblility',
})
AimbotTabLeft:AddSlider('ABFOVSIZESlider', {
    Text = 'Fov Size',
    Default = 0,
    Min = 0,
    Max = 2648,
    Rounding = 0,
    Compact = false,
})
AimbotTabLeft:AddToggle('ABDynamicFOV', {
    Text = 'Dynamic FOV',
    Default = false,
    Tooltip = "Will change the size of the circle depending on the localplayer's Field Of View Value",
})

AimbotTabLeft:AddLabel('Circle Color'):AddColorPicker('ABCircColor', {
    Default = Color3.new(0.8, 0, 1),
    Title = 'FOV Circle Color',
})
AimbotTabLeft:AddLabel('Circle Lock Color'):AddColorPicker('ABCircLockColor', {
    Default = Color3.new(1, 0, 0),
    Title = 'FOV Circle Lock Color',
})

AimbotTabLeft:AddSlider('ABTransparencySlider', {
    Text = 'Transparency',
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
})

AimbotTabLeft:AddSlider('ABSidesSlider', {
    Text = 'Sides',
    Default = 0,
    Min = 0,
    Max = 60,
    Rounding = 0,
    Compact = false,
})

AimbotTabLeft:AddSlider('ABThicknessSlider', {
    Text = 'Thickness',
    Default = 1,
    Min = 0,
    Max = 2,
    Rounding = 1,
    Compact = false,
})

AimbotTabLeft:AddToggle('ABFOVFilledToggle', {
    Text = 'Filled',
    Default = false,
    Tooltip = 'Fills in the FOV Circle',
})

Toggles.ABIngoreFOVToggle:OnChanged(function() getgenv().Aimbot.FOVSettings.Enabled = Toggles.ABIngoreFOVToggle.Value end)
Toggles.ABFOVVisibleToggle:OnChanged(function() getgenv().Aimbot.FOVSettings.Visible = Toggles.ABFOVVisibleToggle.Value end)
Options.ABFOVSIZESlider:OnChanged(function() getgenv().Aimbot.FOVSettings.Amount = Options.ABFOVSIZESlider.Value end)
Options.ABCircColor:OnChanged(function() getgenv().Aimbot.FOVSettings.Color = Options.ABCircColor.Value end)
Options.ABCircLockColor:OnChanged(function() getgenv().Aimbot.FOVSettings.LockedColor = Options.ABCircLockColor.Value end)
Options.ABTransparencySlider:OnChanged(function() getgenv().Aimbot.FOVSettings.Transparency = Options.ABTransparencySlider.Value end)
Options.ABSidesSlider:OnChanged(function() getgenv().Aimbot.FOVSettings.Sides = Options.ABSidesSlider.Value end)
Options.ABThicknessSlider:OnChanged(function() getgenv().Aimbot.FOVSettings.Thickness = Options.ABThicknessSlider.Value end)
Toggles.ABFOVFilledToggle:OnChanged(function() getgenv().Aimbot.FOVSettings.Filled = Toggles.ABFOVFilledToggle.Value end)

--* End Of General /


--* Visuals \
local ESPTabLeft = Tabs.Visuals:AddLeftGroupbox('ESP')
print()
ESPTabLeft:AddToggle('ESPEnabledToggle', {
    Text = 'Enabled',
    Default = false,
    Tooltip = 'Enable/Disable ESP',
})
ESPTabLeft:AddDivider()
ESPTabLeft:AddLabel('Box ESP')
ESPTabLeft:AddToggle('ESPBoxToggle', {
    Text = 'Box',
    Default = false,
    Tooltip = 'puts a box around the target that shows through walls',
})
ESPTabLeft:AddToggle('ESPBoxOutlineToggle', {
    Text = 'BoxOutline',
    Default = false,
    Tooltip = 'outlines the esp box',
})
ESPTabLeft:AddLabel('BoxColor'):AddColorPicker('ESPBoxColor', {
    Default = Color3.new(0.8, 0, 1),
    Title = 'BoxColor',
})
ESPTabLeft:AddLabel('BoxOutlineColor'):AddColorPicker('ESPBoxOutlineColor', {
    Default = Color3.new(0, 0, 0),
    Title = 'BoxOutlineColor',
})
ESPTabLeft:AddDivider()
ESPTabLeft:AddLabel('HealthBar ESP')
ESPTabLeft:AddToggle('ESPHealthBarToggle', {
    Text = 'HealthBar',
    Default = false,
    Tooltip = 'will add a healthbar to the esp box',
})
ESPTabLeft:AddDropdown('ESPHealthBarSideDropdown', {
    Values = { 'Left', 'Bottom', 'Right' },
    Default = 1,
    Multi = false,

    Text = 'HealthBarSide',
    Tooltip = 'Which side the healthbar will display on',
})
ESPTabLeft:AddDivider()
ESPTabLeft:AddLabel('Names ESP')
ESPTabLeft:AddToggle('ESPNamesToggle', {
    Text = 'Names',
    Default = false,
    Tooltip = 'Text will be added next to the esp box displaying the targets username',
})
ESPTabLeft:AddToggle('ESPNamesOutlineToggle', {
    Text = 'NamesOutline',
    Default = false,
    Tooltip = 'Outlines the Name Text',
})
ESPTabLeft:AddLabel('NamesColor'):AddColorPicker('ESPNamesColor', {
    Default = Color3.new(0.8, 0, 1),
    Title = 'NamesColor',
})
ESPTabLeft:AddLabel('NamesOutlineColor'):AddColorPicker('ESPNamesOutlineColor', {
    Default = Color3.new(0, 0, 0),
    Title = 'NamesOutlineColor',
})
ESPTabLeft:AddSlider('ESPNamesFontSlider', {
    Text = 'NamesFont',
    Default = 0,
    Min = 0,
    Max = 3,
    Rounding = 0,
    Compact = false,
})
ESPTabLeft:AddSlider('ESPNamesSizeSlider', {
    Text = 'NamesSize',
    Default = 13,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Compact = false,
})
ESPTabLeft:AddDivider()
ESPTabLeft:AddLabel('ESP Settings')
ESPTabLeft:AddToggle('ESPTeamColorsToggle', {
    Text = 'UseTeamColors',
    Default = false,
    Tooltip = 'If enabled the color of the esp box will be changed to the color of the team of the target',
})
ESPTabLeft:AddToggle('ESPTeamCheckToggle', {
    Text = 'TeamCheck',
    Default = false,
    Tooltip = 'Disbles ESP for all teammates (do not use in a FFA gamemode)',
})

Toggles.ESPEnabledToggle:OnChanged(function() ESPConfig.Enabled = Toggles.ESPEnabledToggle.Value end)
--Boxes
Toggles.ESPBoxToggle:OnChanged(function() ESPConfig.Box = Toggles.ESPBoxToggle.Value end)
Toggles.ESPBoxOutlineToggle:OnChanged(function() ESPConfig.BoxOutline = Toggles.ESPBoxOutlineToggle.Value end)
Options.ESPBoxColor:OnChanged(function() ESPConfig.BoxColor = Options.ESPBoxColor.Value end)
Options.ESPBoxOutlineColor:OnChanged(function() ESPConfig.BoxOutlineColor = Options.ESPBoxOutlineColor.Value end)
--HealthBar
Toggles.ESPHealthBarToggle:OnChanged(function() ESPConfig.HealthBar = Toggles.ESPHealthBarToggle.Value end)
Options.ESPHealthBarSideDropdown:OnChanged(function() ESPConfig.HealthBarSide = Options.ESPHealthBarSideDropdown.Value end)
Toggles.ESPNamesToggle:OnChanged(function() ESPConfig.Names = Toggles.ESPNamesToggle.Value end)
Toggles.ESPNamesOutlineToggle:OnChanged(function() ESPConfig.NamesOutline = Toggles.ESPNamesOutlineToggle.Value end)
Options.ESPNamesFontSlider:OnChanged(function() ESPConfig.NamesFont = Options.ESPNamesFontSlider.Value end)
Options.ESPNamesSizeSlider:OnChanged(function() ESPConfig.NamesSize = Options.ESPNamesSizeSlider.Value end)
Options.ESPNamesColor:OnChanged(function() ESPConfig.NamesColor = Options.ESPNamesColor.Value end)
Options.ESPNamesOutlineColor:OnChanged(function() ESPConfig.NamesOutlineColor = Options.ESPNamesOutlineColor.Value end)
--ESP Settings
Toggles.ESPTeamColorsToggle:OnChanged(function() ESPConfig.UseTeamColours = Toggles.ESPTeamColorsToggle.Value end)
Toggles.ESPTeamCheckToggle:OnChanged(function() ESPConfig.TeamCheck = Toggles.ESPTeamCheckToggle.Value end)


--! Out of view arrows

local OFVTabRight = Tabs.Visuals:AddRightGroupbox('Out Of View Arrows')
OFVTabRight:AddToggle('OFVEnabled', {
    Text = 'Enabled',
    Default = false,
    Tooltip = 'Enable/Disables Arrows',
})
OFVTabRight:AddSlider('OFVDistFromCenter', {
    Text = 'Distance From Centre',
    Default = 80,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
})
OFVTabRight:AddSlider('OFVTraingleHieght', {
    Text = 'Triangle Height',
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
})
OFVTabRight:AddSlider('OFVTraingleWidth', {
    Text = 'Triangle Width',
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
})
OFVTabRight:AddToggle('OFVFilled', {
    Text = 'Filled',
    Default = false,
    Tooltip = 'Fills the traingles',
})
OFVTabRight:AddSlider('OFVTraingleTrans', {
    Text = 'Triangle Transparency',
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
})
OFVTabRight:AddSlider('OFVTraingleThickness', {
    Text = 'Triangle Thickness',
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 0,
    Compact = false,
})
OFVTabRight:AddLabel('Traingle Color'):AddColorPicker('OFVTraingleColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Traingle Color',
})
OFVTabRight:AddToggle('OFVAntiAil', {
    Text = 'AntiAliasing',
    Default = false,
    Tooltip = 'Smooths jagged edges of the traingle by averaging the colors of the pixels at a boundary',
})
OFVTabRight:AddDivider()
OFVTabRight:AddLabel('Settings')
OFVTabRight:AddToggle('OFVUseTeamColor', {
    Text = 'UseTeamColors',
    Default = false,
    Tooltip = 'If enabled the color of the esp traingle will be changed to the color of the team of the target',
})
OFVTabRight:AddToggle('OFVTeamCheck', {
    Text = 'TeamCheck',
    Default = false,
    Tooltip = 'Disbles Arrows for all teammates (do not use in a FFA gamemode)',
})
Toggles.OFVEnabled:OnChanged(function() TriangleEnabled = Toggles.OFVEnabled.Value end)
Options.OFVDistFromCenter:OnChanged(function() DistFromCenterr = Options.OFVDistFromCenter.Value end)
Options.OFVTraingleHieght:OnChanged(function() TriangleHeight = Options.OFVTraingleHieght.Value end)
Options.OFVTraingleWidth:OnChanged(function() TriangleWidth = Options.OFVTraingleWidth.Value end)
Toggles.OFVFilled:OnChanged(function() TriangleFilled = Toggles.OFVFilled.Value end)
Options.OFVTraingleTrans:OnChanged(function() TriangleTransparency = Options.OFVTraingleTrans.Value end)
Options.OFVTraingleThickness:OnChanged(function() TriangleThickness = Options.OFVTraingleThickness.Value end)
Options.OFVTraingleColor:OnChanged(function() TriangleColor = Options.OFVTraingleColor.Value end)
Toggles.OFVAntiAil:OnChanged(function() AntiAliasing = Toggles.OFVAntiAil.Value end)
Toggles.OFVUseTeamColor:OnChanged(function() OOVUseTeamColor = Toggles.OFVUseTeamColor.Value end)
Toggles.OFVTeamCheck:OnChanged(function() OOVTeamCheck = Toggles.OFVTeamCheck.Value end)

local ChamsTabRight = Tabs.Visuals:AddRightGroupbox('Chams')

local ChamsSettings = {
    Enabled = false,
    ChamsFillTrans = 0,
    ChamsOutlineTrans = 0,
    ChamsFillColor = Color3.new(1, 0, 0),
    ChamsOutlineColor = Color3.new(1, 1, 1),
    UseTeamColors = false,
    TeamCheck = false,
}
function ChamsCreateInstance()
    if not Player.Character:FindFirstChild("PlrHighlight") then
        for _,Player in pairs(game:GetService"Players":GetPlayers()) do
            local l = Instance.new("Highlight")
            l.Name = "PlrHighlight"
            local Updater = game:GetService("RunService").RenderStepped:Connect(function()
                if ChamsSettings.TeamCheck == true then
                    if Player.TeamColor == LocalPlayer.TeamColor then
                        l.Enabled = false
                    end
                elseif ChamsSettings.TeamCheck == false then
                    l.Enabled = ChamsSettings.Enabled
                end
                l.FillTransparency = ChamsSettings.ChamsFillTrans
                l.OutlineTransparency = ChamsSettings.ChamsOutlineTrans
                if ChamsSettings.UseTeamColors then
                    l.FillColor = Player.TeamColor.Color
                else
                    l.FillColor = ChamsSettings.ChamsFillColor
                end
                l.OutlineColor = ChamsSettings.ChamsOutlineColor
                l.Parent = Player.Character

            end)
            if Player == nil then
                if Player.Character:FindFirstChild("PlrHighlight") then
                    Updater:Disconnect()
                    Player.Character.PlrHighlight:Destroy()
                end
            end
        end
    end
end
function ChamsDestroyAllInstances()
    for _,Player in pairs(game:GetService"Players":GetPlayers()) do
        if Player.Character:FindFirstChild("PlrHighlight") then
            Player.Character.PlrHighlight:Destroy()
        end
    end
end

game:GetService"RunService".RenderStepped:Connect(ChamsCreateInstance())
ChamsTabRight:AddToggle('ChamsEnabled', {
    Text = 'Enabled',
    Default = false,
    Tooltip = 'Enable/Disables Chams',
})

ChamsTabRight:AddSlider('ChamsFillTrans', {
    Text = 'Fill Transparency',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
})
ChamsTabRight:AddSlider('ChamsOutlineTrans', {
    Text = 'Outline Transparency',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
})

ChamsTabRight:AddLabel('Fill Color'):AddColorPicker('ChamsFillColor', {
    Default = Color3.new(1, 0, 0),
    Title = 'Fill Color',
})
ChamsTabRight:AddLabel('Outline Color'):AddColorPicker('ChamsOutlineColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Outline Color',
})

ChamsTabRight:AddDivider()
ChamsTabRight:AddLabel('Chams Settings')
ChamsTabRight:AddToggle('ChamsTeamColors', {
    Text = 'UseTeamColors',
    Default = false,
    Tooltip = 'If enabled the color of the esp box will be changed to the color of the team of the target',
})
ChamsTabRight:AddToggle('ChamsTeamCheck', {
    Text = 'TeamCheck',
    Default = false,
    Tooltip = 'Disbles ESP for all teammates (do not use in a FFA gamemode)',
})
Toggles.ChamsEnabled:OnChanged(function() ChamsSettings.Enabled = Toggles.ChamsEnabled.Value end)
Options.ChamsFillTrans:OnChanged(function() ChamsSettings.ChamsFillTrans = Options.ChamsFillTrans.Value end)
Options.ChamsOutlineTrans:OnChanged(function() ChamsSettings.ChamsOutlineTrans = Options.ChamsOutlineTrans.Value end)
Options.ChamsFillColor:OnChanged(function() ChamsSettings.ChamsFillColor = Options.ChamsFillColor.Value end)
Options.ChamsOutlineColor:OnChanged(function() ChamsSettings.ChamsOutlineColor = Options.ChamsOutlineColor.Value end)
Toggles.ChamsTeamColors:OnChanged(function() ChamsSettings.UseTeamColors = Toggles.ChamsTeamColors.Value end)
Toggles.ChamsTeamCheck:OnChanged(function() ChamsSettings.TeamCheck = Toggles.ChamsTeamCheck.Value end)


--*End Of Visuals /

--* Settings \
Library.InitManagers()

--* End Of Settings /

--! End Of UI \






--! Load
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ProxColdAirPublishing/Holo-Ware/main/InitExploit.lua"))();
end
