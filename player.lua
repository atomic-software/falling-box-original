class 'Player' {
	x = 0,
	y = 100,
	xvel = 0,
	yvel = 0,

	speed = 500,
	dir = 1,

	grav = 3000,
	canJump = false,
	jumpHeight = 1200,

	holding = false,

	shield = 2,
	dead = false,

	img = love.graphics.newImage('img/player.png'),
	glow = 0,
	hue = 0,
	sat = 200,
	value = 100,

	score = 0,

	melee = false
}

local playerTable = {}

function Player:__init(t)
	for i,v in pairs(t) do
		self[i] = v
	end
	self.x = field.width/2 - 25 + (math.random()-0.5)*field.width
	table.insert(playerTable,self)
end


function Player:update(dt)
	--don't update if dead
	if self.dead then return end

	self.glow = self.glow + dt*5
	self.shield = self.shield - dt

	if Effects.freeze~=nil and Effects.freeze~=self then return end

	self.yvel = self.yvel + self.grav*dt

	local moveX,moveY = self.x,self.y
	local f = self.speed*dt
	local center = screen.width/2 - 25 + getCamera().x
	local squish = 30

	--for collision prediction
	moveY = self.y + self.yvel*dt
	moveX = self.x + self.xvel*dt

	--squish checking
	local checkSquish = function(v)
		if self.dead then return end
		if v.state == 'bullet' and v.owner ~= self then
			if CheckCollision(self.x,self.y,50,50,v.x,v.y,50,50)
			and not (self.y+50 < v.y + (25 - squish/2))
			then
				local msg = {
					'MURDERED',
					'MULTILATED',
					'completely DESTROYED',
					'gave NO mercy towards',
					'OVERPOWERED',
					'FRAGGED',
					'OWNED'
				}

				local r,g,b = HSL(v.owner.hue,v.owner.sat,math.min(255,v.owner.value+20))
				self:reset(v.owner.id..' '..msg[math.random(#msg)]..' '..self.id..'!',{r,g,b})
				v.owner:incScore(3)
			end
		else
			if math.dist(self.x,self.y,v.x,v.y) < squish then
				--if you die, everyone else gets points! :D
				for i,v in pairs(getPlayers()) do
					if v ~= self then
						v:incScore(1,self)
					end
				end

				self:reset(self.id..' got crushed!')
			end
		end
	end

	--vertical movement
	local checkVert = function(v)
		if CheckCollision(self.x,moveY,50,50,v.x,v.y,50,50) then
			if moveY > self.y then
				self.yvel = 0
				self.canJump = true
				if v.state == 'bullet' then
					moveX = moveX + ((v.stop < 0 and not Effects.freeze) and v.xvel*dt or 0)
				end
			end
			if moveY > v.y then
				moveY = v.y+50
				self.yvel = 0
			elseif moveY ~= v.y then
				moveY = v.y-50
				self.yvel = 0
			end
		end
	end

	--horizontal movement
	local checkHor = function(v)
		if CheckCollision(moveX,self.y,50,50,v.x,v.y,50,50) then
			if math.abs(moveX-v.x) > squish then
				if moveX > v.x then
					moveX = v.x+50
				else
					moveX = v.x-50
				end
			end
		end
	end

	for i,v in pairs(gWorld) do
		checkSquish(v)
		if self.melee and self.holding then
			if CheckCollision(
				self.x+50*self.dir, self.y,
				50, 50,
				v.x,v.y,
				50,50
			) then
				v:destroy()
			end
		end
		checkHor(v)
		checkVert(v)
	end

	self.y = moveY
	self.x = moveX
--	moveCamera(self.x - screen.width/2)

	--bounding
	if self.x < 0 then
		self.x = 0
		triggerBound('left')
	elseif self.x > field.width-50 then
		self.x = field.width-50
		triggerBound('right')
	end

	if self.y > field.height-50 then
		self.y = field.height-50
		self.yvel = 0
		self.canJump = true
	end

	--meleeeeeee
	if self.melee and self.holding then
		for i,v in pairs(getPlayers()) do
			if CheckCollision(
				self.x+50*self.dir, self.y,
				50, 50,
				v.x,v.y,
				50,50
			) then
				self:incScore(3,v)
				v:reset(self.id .. ' MOTORBOATED '..v.id..'!',{255,10,10})
			end
		end
	end
end

function Player:draw()
	if self.dead then return end
	local glow = math.max((math.sin(self.glow) + 0.5)*20,0)
	local r, g, b = HSL(self.hue,self.sat,math.min(self.value+glow,255))
	local a = (self.shield>0 and math.multiple(math.sin(-self.shield*25),1)*255 or 255)

	love.graphics.setColor(r,g,b,a)
	love.graphics.draw(img.player,self.x,self.y,0,2,2)

	if self.holding then
		if self.melee then
			love.graphics.setColor(255,0,0)
		end
		love.graphics.draw(img.block,self.x + 50*self.dir, self.y,0,2,2)
	else
		love.graphics.point(self.x + 25 + 35*self.dir, self.y+25)
	end
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(Fonts.normal)
end

function Player:move(dir)
	dir = math.sign(dir)
	self.dir = (dir~=0 and dir or self.dir)
	self.xvel = self.speed*dir
end

function Player:jump()
	if Effects.freeze~=nil and Effects.freeze~=self then return end

	if self.canJump and not self.dead then
		self.yvel = -self.jumpHeight
		self.canJump = false
		sound.player_jump:stop()
		sound.player_jump:play()
	end
end

function Player:grab()
	if not self.holding and not self.dead then
		for i,v in pairs(gWorld) do
			local diffX = (v.x - (self.x + 50*self.dir))*self.dir
			local diffY = math.abs(v.y - self.y)
			if diffX >= 0 and diffX < 50 and diffY < 25 then
				if v.state ~= 'bullet' then
					self.holding = true
					table.remove(gWorld,i)
					return
				end
			end
		end
	end
end

function Player:release()
	if not self.dead then
		local function spawnBlock()
			Block:new{
				x = self.x + 50*self.dir,
				y = self.y,
				xvel = 1000 * self.dir,
				yvel = 0,
				state = 'bullet',
				stop = 0,
				maxhit = 3,
				fadefx = 1,
				owner = self
			}
			
			self.holding = false
		end
		
		if self.holding then
			spawnBlock()
		elseif self.rapidfire then
			for i,v in pairs(gWorld) do
				if math.dist(self.x,self.y,v.x,v.y) < 40 then
					return
				end
			end
			spawnBlock()
		end
	end
end

function Player:reset(msg,color)
	color = color==nil and {255,255,255} or color
	if not self.dead and self.shield < 0 then
		self.dead = true
		self.holding = false
		local r,g,b = HSL(self.hue,self.sat,self.value)
		partExplosion(self.x+25,self.y+25,10,50,{r,g,b})
		fireShake(0.2)
		PromptMsg:new(msg,color)
		sound.player_death:stop()
		sound.player_death:play()

		local function res()
			self.x = field.width/2 - 25 + (math.random()-0.5)*field.width
			self.y = 100
			self.yvel = 0
			self.canJump = false
			self.shield = 2
			self.dead = false
		end

		delay(3,res,'player '..self.id..' reset')
	end
end

function Player:incScore(num)
	self.score = math.max(self.score+num,0)
	print(self.id,num)
end

function Player:remove()
	local ind = table.find(playerTable,self)
	table.remove(playerTable,ind)
end

function updatePlayers(dt)
	for i,v in pairs(playerTable) do
		v:update(dt)
	end
end

function drawPlayers()
	for i,v in pairs(playerTable) do
		v:draw()
	end
end

function drawPlayerNames()
	love.graphics.setFont(Fonts.normal)
	for i,v in pairs(playerTable) do
		if not v.dead then
			local limit = field.width
			shadowText(v.id..'\n'..v.score,v.x - limit/2 + 25,v.y-48,limit,'center')
		end
	end
end

function getPlayers()
	return playerTable
end

function clearPlayers()
	playerTable = {}
end