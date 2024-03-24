local character = game.Players.LocalPlayer.Character

local sunDirection = game.Lighting:GetSunDirection()

local sun_Detect = 10000

local safe = true
local burning = false

function BurnPlayer()
	character.Humanoid:TakeDamage(100)
	burning = false
end

function Safe()
	if burning == true then
		burning = false
	end
end

game:GetService("RunService"):BindToRenderStep("SunService" ,Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
	local ray = Ray.new(character.HumanoidRootPart.Position, sunDirection * sun_Detect)
	local partFound = workspace:FindPartOnRay(ray, character)
	
	if partFound then
		safe = true
		Safe()
		print("This player is safe")
	else 
		safe = false
		BurnPlayer()
	end
end)

game.Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
	sunDirection = game.Lighting:GetSunDirection()
end)