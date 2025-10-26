-- coolkidmode.lua — Coolkid Mode (ТРЯСКА + ТЕКСТУРЫ + ЗВУК)
-- ВСЁ В ОДНОМ, САМ СОЗДАЁТСЯ, ВИДНО/СЛЫШНО ВСЕМ
-- ИСПРАВЛЕНО: Работает без ошибок, GUI для всех

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- === ТВОИ ID ===
local COOLKID_IMAGE_ID = "rbxassetid://118652198574158"
local COOLKID_SOUND_ID = "rbxassetid://119729923584444"

-- === REMOTE EVENTS ===
local textureEvent = ReplicatedStorage:FindFirstChild("CoolkidTextureEvent") or Instance.new("RemoteEvent")
textureEvent.Name = "CoolkidTextureEvent"
textureEvent.Parent = ReplicatedStorage

local soundEvent = ReplicatedStorage:FindFirstChild("CoolkidSoundEvent") or Instance.new("RemoteEvent")
soundEvent.Name = "CoolkidSoundEvent"
soundEvent.Parent = ReplicatedStorage

local shakeEvent = ReplicatedStorage:FindFirstChild("CoolkidShakeEvent") or Instance.new("RemoteEvent")
shakeEvent.Name = "CoolkidShakeEvent"
shakeEvent.Parent = ReplicatedStorage

-- === ТЕКСТУРЫ ===
textureEvent.OnServerEvent:Connect(function(player, enable)
	-- Очистка
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("MeshPart") then
			for _, child in ipairs(obj:GetChildren()) do
				if child:IsA("Decal") and child.Name == "CoolkidDecal" then
					child:Destroy()
				end
			end
		end
	end

	if enable then
		-- Применение
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") or obj:IsA("MeshPart") then
				for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
					local decal = Instance.new("Decal")
					decal.Name = "CoolkidDecal"
					decal.Texture = COOLKID_IMAGE_ID
					decal.Face = face
					decal.Transparency = 0
					decal.Parent = obj
				end
			end
		end
	end
end)

-- === ЗВУК ===
soundEvent.OnServerEvent:Connect(function(player, enable)
	-- Очистка
	for _, s in ipairs(workspace:GetDescendants()) do
		if s:IsA("Sound") and s.Name == "CoolkidSound" then
			s:Stop()
			s:Destroy()
		end
	end

	if enable then
		local sound = Instance.new("Sound")
		sound.Name = "CoolkidSound"
		sound.SoundId = COOLKID_SOUND_ID
		sound.Volume = 8
		sound.Looped = false
		sound.Parent = workspace
		sound:Play()
		Debris:AddItem(sound, 15)
	end
end)

-- === ТРЯСКА ===
shakeEvent.OnServerEvent:Connect(function(player, enable)
	shakeEvent:FireAllClients(enable)
end)

-- === GUI + ТРЯСКА (для каждого игрока) ===
local function createGUI(player)
	local guiSource = [[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local textureEvent = ReplicatedStorage:WaitForChild("CoolkidTextureEvent")
local soundEvent = ReplicatedStorage:WaitForChild("CoolkidSoundEvent")
local shakeEvent = ReplicatedStorage:WaitForChild("CoolkidShakeEvent")

local textureOn = false
local soundOn = false
local shakeOn = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CoolkidGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 230)
frame.Position = UDim2.new(0, 10, 0.5, -115)
frame.BackgroundColor3 = Color3.new(0,0,0)
frame.BackgroundTransparency = 0.3
frame.BorderColor3 = Color3.new(1,1,0)
frame.BorderSizePixel = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Text = "COOLKID MODE"
title.TextColor3 = Color3.new(1,1,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextScaled = true

local btnY = 50
local function createBtn(text, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.Position = UDim2.new(0.05, 0, 0, btnY)
	btn.Text = text
	btn.TextColor3 = Color3.new(0,0,0)
	btn.BackgroundColor3 = Color3.new(1,0,0)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.MouseButton1Click:Connect(callback)
	btnY = btnY + 50
	return btn
end

local texBtn = createBtn("TEXTURES: OFF", function()
	textureOn = not textureOn
	texBtn.Text = "TEXTURES: " .. (textureOn and "ON" or "OFF")
	texBtn.BackgroundColor3 = textureOn and Color3.new(0,1,0) or Color3.new(1,0,0)
	textureEvent:FireServer(textureOn)
end)

local sndBtn = createBtn("SOUND: OFF", function()
	soundOn = not soundOn
	sndBtn.Text = "SOUND: " .. (soundOn and "ON" or "OFF")
	sndBtn.BackgroundColor3 = soundOn and Color3.new(0,1,0) or Color3.new(1,0,0)
	soundEvent:FireServer(soundOn)
end)

local shakeBtn = createBtn("SHAKE: OFF", function()
	shakeOn = not shakeOn
	shakeBtn.Text = "SHAKE: " .. (shakeOn and "ON" or "OFF")
	shakeBtn.BackgroundColor3 = shakeOn and Color3.new(0,1,0) or Color3.new(1,0,0)
	shakeEvent:FireServer(shakeOn)
end)

local clearBtn = createBtn("CLEAR ALL", function()
	texBtn.Text, texBtn.BackgroundColor3 = "TEXTURES: OFF", Color3.new(1,0,0)
	sndBtn.Text, sndBtn.BackgroundColor3 = "SOUND: OFF", Color3.new(1,0,0)
	shakeBtn.Text, shakeBtn.BackgroundColor3 = "SHAKE: OFF", Color3.new(1,0,0)
	textureOn, soundOn, shakeOn = false, false, false
	textureEvent:FireServer(false)
	soundEvent:FireServer(false)
	shakeEvent:FireServer(false)
end)

-- ТРЯСКА
local shaking = false
shakeEvent.OnClientEvent:Connect(function(enable)
	shaking = enable
end)

local intensity = 0
RunService.RenderStepped:Connect(function(dt)
	if shaking then
		intensity = 0.7
		local offset = Vector3.new(
			(math.random() - 0.5) * intensity,
			(math.random() - 0.5) * intensity,
			0
		)
		camera.CFrame = camera.CFrame * CFrame.new(offset)
		intensity = math.max(intensity - 10 * dt, 0)
	else
		intensity = 0
	end
end)
]]

	local script = Instance.new("LocalScript")
	script.Name = "CoolkidGUI"
	script.Source = guiSource
	script.Parent = player:WaitForChild("PlayerGui")
end

-- Раздача GUI
for _, player in ipairs(Players:GetPlayers()) do
	createGUI(player)
end

Players.PlayerAdded:Connect(createGUI)

print("COOLKID MODE ЗАГРУЖЕН! GUI для всех игроков.")
