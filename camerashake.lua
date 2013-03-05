local shake = {
	intensity = 0
}

function fireShake(int)
	shake.intensity = shake.intensity + int
end

function updateShake(dt)
	shake.intensity = math.max(0,shake.intensity - dt*1.5)
end

function drawShake()
	local function getShake()
		return (math.random()-0.5) * shake.intensity * 20
	end
	love.graphics.translate(getShake(),getShake())
end

function clearShake()
	shake.intensity = 0
end