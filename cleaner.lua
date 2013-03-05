local scale = 20 --blocks
local cleanerTable = {}

class 'Cleaner' {
	scale = scale,
	x = -scale*100,
	y = field.height - scale*50,
	size = scale*50,
	speed = scale*100,
	fade = 0,
	owner = '?'
}

function Cleaner:__init(player)
	self.owner = player
	table.insert(cleanerTable,self)
end

function Cleaner:update(dt)
	self.x = self.x + self.speed*dt

	for i,v in pairs(gWorld) do
		if CheckCollision(self.x,self.y,self.size,self.size, v.x,v.y,50,50) then
			v:destroy()
		end
	end

	for i,v in pairs(getPlayers()) do
		if CheckCollision(self.x,self.y,self.size,self.size, v.x,v.y,50,50)
		and v ~= self.owner
		and not v.dead then
			self.owner:incScore(3,v)
			v:reset(v.id .. ' had no chance...')
		end
	end

	if self.x > field.width + self.size then
		self.fade = self.fade - dt
		if self.fade < 0 then return 'kill' end
	else
		self.fade = self.fade + dt
	end
	self.fade = math.clamp(0,self.fade,1)
end

function Cleaner:draw()
	love.graphics.setColor(255,255,0)
	love.graphics.draw(img.block,self.x,self.y,0,self.scale*2)
end

function updateCleaner(dt)
	for i,v in pairs(cleanerTable) do
		if v:update(dt) == 'kill' then
			table.remove(cleanerTable,i)
		end
	end
end

function drawCleaner()
	for i,v in pairs(cleanerTable) do
		v:draw()
	end
end