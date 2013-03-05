local editprofile = Gamestate.new()
local selection = 1
local profile
local fxtime = 0

local function saveProfile()
	saveHumanData(profile)
	PromptMsg:new('Data saved!')
	Gamestate.switch(States.menu)
end

class 'Option' {
	x = 0,
	y = 0,
	width = 0,
	height = 0,
	update = function() end,
	draw = function() end,
	keypressed = function() end
}

function Option:__init(t)
	for i,v in pairs(t) do
		self[i] = v
	end
end

local nameInput = Option:new{
	x = 100,
	y = 200,
	width = 300,
	height = 25,
	draw = function(self)
		local text = 'Name: '..profile.name..(math.sin(fxtime*5)>0 and '_' or '')

		love.graphics.setFont(Fonts.normal)
		love.graphics.printf(text,self.x+8,self.y-2,screen.width)
	end,
	keypressed = function(self,k,uni)
		local len = string.len(profile.name)
		if uni > 31 and uni < 127 then
			if len < 32 then
				profile.name = profile.name .. string.char(uni)
			end
		elseif k=='backspace' then
			profile.name = string.sub(profile.name,1,len-1)
		end
	end
}

local slider = {
	hue = Option:new{
		x = 100,
		y = 250,
		width = 200,
		height = 25,
		draw = function(self)
			local f = (profile.hue/255)*195
			love.graphics.setColor(HSL(profile.hue,255,150))
			love.graphics.rectangle('fill',self.x,self.y,f + 5,self.height)

			love.graphics.setFont(Fonts.normal)
			shadowText('Color', self.x, self.y, self.width, 'center')
		end,
		update = function(v,dt)
			local change = (255 * (dt/3))
			if love.keyboard.isDown('right') then
				profile.hue = profile.hue + change
			elseif love.keyboard.isDown('left') then
				profile.hue = profile.hue - change
			end
			profile.hue = math.clamp(0,profile.hue,255)
		end
	},

	sat = Option:new{
		x = 100,
		y = 280,
		width = 200,
		height = 25,
		draw = function(self)
			local f = (profile.sat/255)*195
			love.graphics.setColor(HSL(profile.hue,profile.sat,150))
			love.graphics.rectangle('fill',self.x,self.y,f + 5,self.height)

			love.graphics.setFont(Fonts.normal)
			shadowText('Saturation', self.x, self.y, self.width, 'center')
		end,
		update = function(v,dt)
			local change = (255 * (dt/1.5))
			if love.keyboard.isDown('right') then
				profile.sat = profile.sat + change
			elseif love.keyboard.isDown('left') then
				profile.sat = profile.sat - change
			end
			profile.sat = math.clamp(0,profile.sat,255)
		end
	},

	value = Option:new{
		x = 100,
		y = 310,
		width = 200,
		height = 25,
		draw = function(self)
			local f = (profile.value/255)*195
			love.graphics.setColor(HSL(0,0,profile.value))
			love.graphics.rectangle('fill',self.x,self.y,f + 5,self.height)

			love.graphics.setFont(Fonts.normal)
			shadowText('Brightness', self.x, self.y, self.width, 'center')
		end,
		update = function(v,dt)
			local change = (255 * (dt/1.5))
			if love.keyboard.isDown('right') then
				profile.value = profile.value + change
			elseif love.keyboard.isDown('left') then
				profile.value = profile.value - change
			end
			profile.value = math.clamp(20,profile.value,255)
		end
	}
}

local exitText = 'Save and Exit...'
local exit = Option:new{
	x = 100,
	y = screen.height-50,
	width = 200,
	height = 25,
	draw = function(self)
		self.y = screen.height-100
		love.graphics.print(exitText,self.x+8,self.y-2)
	end,
	keypressed = function(self,k,uni)
		if k=='return' then
			saveProfile()
		end
	end
}

local optionTable = {
	nameInput,
	slider.hue,
	slider.sat,
	slider.value,
	exit
}

function editprofile:enter()
	selection = 1
	profile = loadHumanData()
	love.keyboard.setKeyRepeat(0.3,0.03)
end

function editprofile:leave()
	love.keyboard.setKeyRepeat(0,0)
end

function editprofile:update(dt)
	fxtime = fxtime+dt
	for i,v in pairs(optionTable) do
		if selection==i then
			v:update(dt)
		end
	end
end

function editprofile:draw()
	love.graphics.setColor(HSL(profile.hue,profile.sat,profile.value))
	love.graphics.draw(img.player, 150, 50, 0, 4, 4)
	love.graphics.setColor(255,255,255)

	for i,v in pairs(optionTable) do
		v:draw()
		if selection == i then
			borderRect(v.x,v.y,v.width,v.height)
		end
	end
end

function editprofile:keypressed(k,uni)
	for i,v in pairs(optionTable) do
		if selection==i then
			v:keypressed(k,uni)
		end
	end

	if k=='down' then
		selection = selection<#optionTable and selection+1 or 1
	elseif k=='up' then
		selection = selection>1 and selection-1 or #optionTable
	end

	if k=='escape' then
		saveProfile()
--		love.event.quit()
	end
end

return editprofile