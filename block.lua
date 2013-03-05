class 'Block' {
	x = 0,
	y = 0,
	xvel = 0,
	yvel = 0,
	life = 20,
	state = 'falling',
	fadefx = 0,
	stop = 0,
	hit = 3,
	maxhit = 3,
	shake = 0.12,
	owner = '',
	color = {100,150,200},
	grav = 500
}

function Block:__init(t)
	for i,v in pairs(t) do
		self[i] = v
	end
	self.hit = self.maxhit
	table.insert(gWorld,self)
end

function Block:update(dt)
	if Effects.freeze then return end

	local function kill()
		table.remove(gWorld,table.find(gWorld,self))
	end

	if self.state == 'falling' or self.state == 'static' then
		self.y = self.y - self.yvel*dt
		self.yvel = self.yvel - self.grav*dt
		self.life = self.life - dt
		
		for ii,vv in ipairs(gWorld) do
			if self ~= vv then
				if CheckCollision(self.x,self.y,50,50, vv.x,vv.y,50,50)
				and vv.state ~= 'bullet' then
					self.y = vv.y + (self.y > vv.y and 50 or -50)
					self.yvel = 0
					if self.state == 'falling' then
						self.state = 'static'
						fireShake(self.shake)
					end
				end
			end
		end

		if self.life > 0 then
			if self.y > field.height-50 then
				self.y = field.height-50
				self.yvel = 0
				if self.state == 'falling' then
					self.state = 'static'
					fireShake(self.shake)
					sound.box_fall:stop()
					sound.box_fall:play()
				end
			end
		elseif self.y > field.height then
			kill()
			return
		end


		if self.yvel > 0 then
			self.state = 'falling'
		end
	else
		self.stop = self.stop-dt
		if self.stop < 0 then
			self.x = self.x + self.xvel*dt
		end

		local function stopFlying(x,obj)
			if self.hit > 0 then
				if self.stop < 0 then
					self.hit = self.hit - 1
					self.stop = 0.1
					fireShake(obj.shake)
					obj:destroy()
				end
			else
				self.xvel = 0
				self.yvel = 0
				self.state = 'falling'
				self.x = x
				fireShake(-self.shake)
			end
		end

		for ii,vv in pairs(gWorld) do
			if self ~= vv then
				if CheckCollision(self.x,self.y,50,50, vv.x,vv.y,50,50) then
					if vv.state ~= 'bullet' then
						if self.x < vv.x then
							stopFlying(vv.x-50,vv)
						else
							stopFlying(vv.x+50,vv)
						end
					elseif vv.owner ~= self.owner then
						if math.random() > 0.5 then
							blockExplosion(self,vv)
						end
						vv:destroy()
						return
					end
				end
			end
		end

		if self.x < 0 then
			self:destroy()
			triggerBound('left')
			return
		elseif self.x > field.width-50 then
			self:destroy()
		end
	end

	if self.fadefx then
		self.fadefx = math.min(self.fadefx+dt,1)
	else
		self.fadefx = 1
	end
end

function Block:draw()
	local colors = {
		['falling'] = {100,150,200},
		['static'] = {100,150,200},
		['bullet'] = {30,180,30}
	}
	self.color = colors[self.state]
	self.color[4] = 255*(self.fadefx~=nil and self.fadefx or 1)

	love.graphics.setColor(self.color)
	love.graphics.draw(img.block,self.x,self.y,0,2,2)
--	love.graphics.setColor(0,0,0)
--	love.graphics.print(i,self.x+10,self.y+10)

	self.color[4] = 255
end

function Block:destroy()
	partExplosion(self.x,self.y,5,50,self.color)
	table.remove(gWorld,table.find(gWorld,self))
	sound.block_destroy:stop()
	sound.block_destroy:play()
end

function updateBlocks(dt)
	for i,v in pairs(gWorld) do
		v:update(dt)
	end
end

function drawBlocks()
	for i,v in pairs(gWorld) do
		v:draw()
	end
end

function spawnBlocks()
	for i=1, math.random(4,8) do
		Block:new{
			x = math.multiple(math.random(field.width-50),50),
			y = -50,
			xvel = 0,
			yvel = 0,
			state = 'falling',
			fadefx = 0
		}
	end
end

function blockExplosion(b1,b2)
	local x,y = (b1.x+b2.x)/2, (b1.y+b2.y)/2
	local radius = 200

	for i,v in pairs(gWorld) do
		if math.dist(x,y,v.x,v.y) < radius then
			v:destroy()
		end
	end

	for i,v in pairs(getPlayers()) do
		if math.dist(x,y,v.x,v.y) < radius then
			v:reset(v.id..' exploded!')
		end
	end

	fireShake(0.7)
	fireFlash()

	sound.block_explosion:stop()
	sound.block_explosion:play()
end

function clearBlocks()
	gWorld = {}
end