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

-- Periodically check if the player is in sunlight and on the ground in sunlight
while true do
	wait(checkInterval)
	local isDirectSunlight = not workspace:FindPartOnRay(
	Ray.new(character.HumanoidRootPart.Position, sunDirection * 1000), character)
	local isGroundInSunlight = IsGroundInSunlight()

	if isDirectSunlight and isGroundInSunlight then
		-- If the player has been exposed for longer than the threshold, burn them
		if tick() - lastSafeTime >= exposureThreshold then
			BurnPlayer()
		end
	else
		lastSafeTime = tick() -- Reset the timer if safe
	end
end

-- Update the sun direction based on the time of day
game.Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
	sunDirection = game.Lighting:GetSunDirection()
end)
