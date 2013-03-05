class 'Particle' {
	x = 0,
	y = 0,
	xvel = 0,
	yvel = 0,
	grav = 1000,
	speed = 500,

	img = img.block,
	quad = {0,0,4,4},

	size = 4,
	life = 5,

	color = {255,255,255}
}

local partTable = {}

function Particle:__init(x,y,img,size,color)
	self.x = x
	self.y = y
	self.xvel = (math.random()-0.5) * 1000
	self.yvel = (math.random()-0.5) * 1000
	self.img = img
	self.size = size
	self.quad = love.graphics.newQuad(
		math.floor(math.random() * (img:getWidth()-size)),
		math.floor(math.random() * (img:getHeight()-size)),
		size,
		size,
		img:getWidth(),
		img:getHeight()
	)
	self.color = color

	table.insert(partTable,self)
end

function Particle:update(dt)
	self.xvel = self.xvel - math.sign(self.xvel)*100*dt
	self.yvel = self.yvel + self.grav*dt

	self.x = self.x + self.xvel*dt
	self.y = math.min(self.y + self.yvel*dt, field.height-self.size*2)

	for i,v in pairs(gWorld) do
		if CheckCollision(self.x,self.y,self.size*2,self.size*2,v.x,v.y,50,50) then
			self.y = v.y - self.size*2
			self.yvel = 0
			if v.state == 'static' then
				self.xvel = 0
			end
		end
	end

	--[[
	for i,v in pairs(partTable) do
		if CheckCollision(
			self.x,self.y,self.size*2,self.size*2,
			v.x,v.y,v.size*2,v.size*2
		) then
			self.y = v.y - self.size
		end
	end
	]]

	self.life = self.life - dt
	if self.life <= 0 then
		return 'kill'
	end
end

function Particle:draw()
	love.graphics.setColor(self.color)
	love.graphics.drawq(self.img,self.quad,self.x,self.y,0,2)
end

function updateParticles(dt)
	for i,v in pairs(partTable) do
		if v:update(dt)=='kill' then
			table.remove(partTable,i)
		end
	end
end

function drawParticles()
	for i,v in pairs(partTable) do
		v:draw()
	end
end

function clearParticles()
	partTable = {}
end

function partExplosion(x,y,density,radius,color)
	for i=1, density do
		Particle:new(
			x - math.random()*radius,
			y - math.random()*radius,
			img.block,
			4,
			color
		)
	end
end