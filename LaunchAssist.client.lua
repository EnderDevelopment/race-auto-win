--!strict
--[[
	LaunchAssist.client.lua
	A legitimate launch-timing helper for drag racing.

	This LocalScript does NOT control the vehicle and does NOT give an
	advantage. It only displays a visual countdown at the starting line
	so the player can time their own throttle inputs more consistently.

	Place in: StarterPlayer > StarterPlayerScripts
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ============================================================
-- CONFIGURATION — edit these values to match the game
-- ============================================================
local CONFIG = {
	-- Full dot-path to the start-light object (relative to workspace).
	-- Leave "" to use automatic sensing instead.
	StartLightPath = "",

	-- Color keys (or Color3 values) used to detect the green/red lights.
	GreenLightColorKey = "Bright green",
	RedLightColorKey = "Bright red",

	-- Extra delay after green is seen, in seconds.
	GoDelaySeconds = 0,

	-- Fallback screen size for layout before the Gui is ready.
	ScreenSize = Vector2.new(800, 600),

	-- How long the "GO!" overlay flashes.
	FlashDuration = 0.3,

	-- Prints detected states to the Output console for tuning.
	ShowDebug = true,
}
-- ============================================================

-- Resolve color keys into Color3 values.
local function resolveColor(key)
	if typeof(key) == "Color3" then
		return key
	end
	local ok, value = pcall(function()
		return BrickColor.new(key).Color
	end)
	if ok and value then
		return value
	end
	return Color3.fromRGB(0, 255, 0)
end

local GREEN = resolveColor(CONFIG.GreenLightColorKey)
local RED = resolveColor(CONFIG.RedLightColorKey)

-- ------------------------------------------------------------------
-- UI setup
-- ------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LaunchAssistGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local goLabel = Instance.new("TextLabel")
goLabel.Name = "GoLabel"
goLabel.BackgroundTransparency = 1
goLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
goLabel.Text = "GO!"
goLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
goLabel.TextScaled = true
goLabel.Font = Enum.Font.GothamBlack
goLabel.ZIndex = 10
goLabel.Visible = false
goLabel.AnchorPoint = Vector2.new(0.5, 0.5)
goLabel.Position = UDim2.fromScale(0.5, 0.35)
goLabel.Size = UDim2.fromScale(0.5, 0.35)
goLabel.Parent = screenGui

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Waiting for start..."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = false
statusLabel.TextSize = 20
statusLabel.Font = Enum.Font.Gotham
statusLabel.AnchorPoint = Vector2.new(0.5, 0)
statusLabel.Position = UDim2.fromScale(0.5, 0.05)
statusLabel.Size = UDim2.fromScale(0.9, 0.06)
statusLabel.Parent = screenGui

-- ------------------------------------------------------------------
-- Start-light detection
-- ------------------------------------------------------------------
local function debouncePrint(...)
	if CONFIG.ShowDebug then
		print("[LaunchAssist]", ...)
	end
end

-- Collect candidate start-light parts from the workspace.
local function collectStartLights()
	local roots: { Instance } = {}
	if CONFIG.StartLightPath ~= "" then
		local target = workspace:FindFirstChild(CONFIG.StartLightPath)
		if target then
			table.insert(roots, target)
		else
			debouncePrint("StartLightPath not found:", CONFIG.StartLightPath)
		end
	else
		table.insert(roots, workspace)
	end
	return roots
end

-- Recursively gather every BasePart under a root.
local function gatherParts(root: Instance, out: { BasePart })
	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("BasePart") then
			table.insert(out, child)
		elseif child:IsA("Model") or child:IsA("Folder") or child:IsA("Workspace") then
			gatherParts(child, out)
		end
	end
end

-- Find the first part that equals a given color.
local function findPartWithColor(color: Color3, tolerance: number, parts: { BasePart })
	for _, part in ipairs(parts) do
		if part:IsA("BasePart") and (part.Color - color).Magnitude <= tolerance then
			return part
		end
	end
	return nil
end

local function flashGo()
	goLabel.Visible = true
	statusLabel.Text = "Launch!"
	TweenService:Create(goLabel, TweenInfo.new(CONFIG.FlashDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1,
	}):Play()
	task.delay(CONFIG.FlashDuration, function()
		goLabel.Visible = false
		goLabel.TextTransparency = 0
		statusLabel.Text = "Waiting for next start..."
	end)
end

-- Main loop watches the start lights and triggers the GO! flash.
task.spawn(function()
	local parts: { BasePart } = {}
	for _, root in ipairs(collectStartLights()) do
		gatherParts(root, parts)
	end
	debouncePrint("Monitoring", #parts, "part(s) for start lights")

	local wasGreen = false
	while true do
		task.wait(0.05)

		local greenPart = findPartWithColor(GREEN, 0.05, parts)
		local redPart = findPartWithColor(RED, 0.05, parts)

		if greenPart and not wasGreen then
			debouncePrint("Green detected on", greenPart:GetFullName())
			wasGreen = true
			if CONFIG.GoDelaySeconds > 0 then
				task.wait(CONFIG.GoDelaySeconds)
			end
			flashGo()
		elseif not greenPart and redPart then
			wasGreen = false
		end

	end
end)

-- Keep alive handling for player re-spawns.
task.spawn(function()
	while true do
		task.wait(5)
		if not player:IsConnected() then
			break
		end
	end
end)
