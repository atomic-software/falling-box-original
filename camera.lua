local camera = {
	x = 0,
	y = 0,
	scale = 1,

	destx = 0,
	desty = 0,
	destscale = 1,

	--[[
	min = 0,
	max = field.width-screen.width,
	]]

	speed = 20
}
--[[
function moveCamera(n)
	camera.x = n
end
]]
function updateCamera(dt)
	local players = getPlayers()
	if #players < 1 then return end

	table.sort(players,function(a,b)
		return a.x < b.x
	end)

	local left = players[1]
	local right = players[#players]

	camera.destx = (left.x + right.x)/2 - screen.width/2 + 25
	camera.destscale = math.min((screen.width-200) / math.abs(left.x - right.x), 1)
	
	camera.x = camera.x - (camera.x - camera.destx)*dt*camera.speed
	camera.y = camera.y - (camera.y - camera.desty)*dt*camera.speed
	camera.scale = camera.scale - (camera.scale - camera.destscale)*dt*camera.speed
end

function drawCamera()
	love.graphics.translate(screen.width/2,screen.height/2)
	love.graphics.scale(camera.scale)
	love.graphics.translate(-screen.width/2,-screen.height/2)

	love.graphics.translate(-camera.x,-camera.y)

	love.graphics.translate(0,screen.height-field.height)
end

function getCamera()
	return camera
end
