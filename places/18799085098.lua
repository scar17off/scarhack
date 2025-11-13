-- Hide or Die
-- https://www.roblox.com/games/18799085098/Hide-or-Die

local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/esp.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/scar17off/scarhack/refs/heads/main/libraries/ui-library.lua"))()
local window = UI.CreateWindow()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local coinAuraEnabled = false
local coinAuraThread = nil

local function startCoinAuraLoop()
	-- avoid spawning multiple loops
	if coinAuraThread then return end
	coinAuraThread = spawn(function()
		while coinAuraEnabled do
			local character = LocalPlayer and LocalPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local coinsFolder = workspace:FindFirstChild("Trash") and workspace.Trash:FindFirstChild("Coins")
				if coinsFolder then
					local closestPart
					local closestDist
					for _, coin in pairs(coinsFolder:GetChildren()) do
						if coin and coin:IsA("Model") then
							local part = coin:FindFirstChild("Handle") or coin:FindFirstChildWhichIsA("BasePart")
							if part then
								local dist = (hrp.Position - part.Position).Magnitude
								if not closestDist or dist < closestDist then
									closestDist = dist
									closestPart = part
								end
							end
						end
					end
					if closestPart then
						hrp.CFrame = CFrame.new(closestPart.Position + Vector3.new(0, 3, 0))
					end
				end
			end
			wait(0.12)
		end
		coinAuraThread = nil
	end)
end

local ESP = window:CreateCategory("ESP")

ESP:CreateToggle({
    text = "ESP",
    default = false,
    callback = function(value)
        ESPLibrary:Toggle(value)
    end
})

ESP:CreateToggle({
    text = "Boxes",
    default = false,
    callback = function(value)
        ESPLibrary.Boxes = value
    end
})

ESP:CreateToggle({
    text = "Names",
    default = false,
    callback = function(value)
        ESPLibrary.Names = value
    end
})

ESP:CreateToggle({
    text = "Glow",
    default = false,
    callback = function(value)
        ESPLibrary.Glow.Enabled = value
    end
})

ESP:CreateToggle({
    text = "Glow Fill",
    default = false,
    callback = function(value)
        ESPLibrary.Glow.Filled = value
    end
})

ESP:CreateToggle({
    text = "Glow TeamColor",
    default = false,
    callback = function(value)
        ESPLibrary.Glow.TeamColor = value
    end
})

ESP:CreateToggle({
    text = "TeamColor",
    default = false,
    callback = function(value)
        ESPLibrary.TeamColor = value
    end
})

ESP:CreateToggle({
    text = "Players",
    default = false,
    callback = function(value)
        ESPLibrary.Players = value
    end
})

ESP:CreateToggle({
	text = "Coin TP Aura",
	default = false,
	callback = function(value)
		coinAuraEnabled = value
		if value then
			startCoinAuraLoop()
		end
	end
})