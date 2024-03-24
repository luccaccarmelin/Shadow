local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local sunDirection = game.Lighting:GetSunDirection()

local sunDetectDistance = 10000 -- Distance to detect the sun
local checkInterval = 0.5       -- Interval in seconds to check for sun exposure
local exposureThreshold = 1     -- Time in seconds before the player starts burning

local lastSafeTime = tick()     -- Using tick() to get the current time

-- Function to damage the player
function BurnPlayer()
	character.Humanoid:TakeDamage(100)
end

-- Function to check if the ground beneath the player is in direct sunlight
function IsGroundInSunlight()
	local rayDown = Ray.new(character.HumanoidRootPart.Position, Vector3.new(0, -100, 0)) -- Ray pointing downwards
	local hit, hitPosition = workspace:FindPartOnRayWithIgnoreList(rayDown, { character })
	if hit then
		-- Check if this point is in sunlight by casting a ray from the sun's direction to the hit position
		local rayFromSun = Ray.new(hitPosition + sunDirection * 100, sunDirection * -100)
		local partFound, _, _, _, material = workspace:FindPartOnRayWithIgnoreList(rayFromSun, { character, hit })
		-- If no part is found or the material is transparent, then it's considered in sunlight
		return not partFound or material == Enum.Material.Air
	end
	return false
end

-- Main loop to periodically check sun exposure and ground status
game:GetService("RunService").Heartbeat:Connect(function()
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return -- Ensure the character and necessary parts exist
	end

	local isDirectSunlight = not workspace:FindPartOnRay(
	Ray.new(character.HumanoidRootPart.Position, sunDirection * sunDetectDistance), character)
	local isGroundInSunlight = IsGroundInSunlight()

	if isDirectSunlight and isGroundInSunlight then
		-- If the player has been exposed for longer than the threshold, burn them
		if tick() - lastSafeTime >= exposureThreshold then
			BurnPlayer()
		end
	else
		lastSafeTime = tick() -- Reset the timer if safe
	end
end)

-- Update the sun direction based on the time of day
game.Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
	sunDirection = game.Lighting:GetSunDirection()
end)
