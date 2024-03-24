local character = game.Players.LocalPlayer.Character
local sunDirection = game.Lighting:GetSunDirection()

local checkInterval = 0.5     -- Checking player exposure interval
local exposureThreshold = 0.5 -- Time in seconds before the player burn

local lastSafeTime = tick()

local sun_Detect = 10000

local safe = true
local burning = false

function BurnPlayer()
	character.Humanoid:TakeDamage(100)
	burning = false
end

function IsGroundInSunlight()
	local rayDown = Ray.new(character.HumanoidRootPart.Position, Vector3.new(0, -100, 0)) -- Ray pointing downwards
	local hit, hitPosition = workspace:FindPartOnRay(rayDown, character)
	if hit then
		-- check if this point is in sunlight casting a ray from the sun position
		local rayFromSun = Ray.new(hitPosition, sunDirection * -100)
		local partFound = workspace:FindPartOnRayWithIgnoreList(rayFromSun, { character, hit })
		return not partFound -- If we found no obstruction, the ground is in sunlight
	end
	return false
end

-- Update the sun direction based on the time of day
game.Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
	sunDirection = game.Lighting:GetSunDirection()
end)


function Safe()
	if burning == true then
		burning = false
	end
end

game:GetService("RunService"):BindToRenderStep("SunService", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
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
