local function newTick(v)
	return math.random()*0.5
end

local blocks = {}
local tick = newTick()
local time = 0
local gravity = 500

function menuAnimUpdate(dt)
	time = time+dt

	if time > tick then
		tick = tick + newTick()

		table.insert(blocks,{
			x = math.floor(math.random()*screen.width/50)*50,
			y = -50,
			yvel = 100
		})
	end

	for i,v in pairs(blocks) do
		if v.y > field.height+50 then
			table.remove(blocks,i)
		else
			v.y = v.y + v.yvel*dt
			v.yvel = v.yvel + gravity*dt
		end
	end
end

function menuAnimDraw()
	love.graphics.setColor(100,150,200)
	for i,v in pairs(blocks) do
		love.graphics.draw(img.block,v.x,v.y,0,2,2)
	end
end