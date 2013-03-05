local function newTick() return math.random()*20 + 10 end
local tick = newTick()
local powerups = {}

class 'Powerup'{
	x=0,
	y=0,
	yvel = 70,
	fadefx = 0,
	effect = nil
}

function Powerup:__init(effect)
	self.x = math.random()*(field.width-50)
	self.effect = effect
	table.insert(powerups,self)
	sound.powerup_spawn:stop()
	sound.powerup_spawn:play()
end

function Powerup:update(dt,i)
	self.y = self.y + self.yvel*dt
--	self.yvel = self.yvel - 20*dt

	if self.y < field.height then
		self.fadefx = self.fadefx + dt
	else
		self.fadefx = self.fadefx - dt
		if self.fadefx < 0 then
			return 'kill'
		end
	end

	for i,v in pairs(getPlayers()) do
		if math.dist(v.x,v.y,self.x,self.y) <= 70 and not v.dead then
			fireEffect(v)
			sound.powerup_collect:stop()
			sound.powerup_collect:play()
			return 'kill'
		end
	end

	self.fadefx = math.clamp(0,self.fadefx,1)
end

function Powerup:draw()
	local rot = math.sin(gTime*3)/4
	love.graphics.setColor(255,255,255,255*self.fadefx)
	love.graphics.draw(img.powerup,self.x,self.y,rot,1,1,50,50)
end

function updatePowerups(dt)
	if gTime > tick then
		tick = tick + newTick()
		for i=1, math.random(#getPlayers()) do
			Powerup:new()
		end
	end

	for i,v in pairs(powerups) do
		if v:update(dt,i) == 'kill' then
			table.remove(powerups,i)
		end
	end
end

function drawPowerups()
	for i,v in pairs(powerups) do
		v:draw()
	end
end

function clearPowerups()
	powerups = {}
end
