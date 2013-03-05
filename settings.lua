--file stuff
local path = love.filesystem.getUserDirectory() .. 'falling-box-settings'
function loadSettings()
	local def = {
		ai = 3,
		res = {width=800,height=600},
		fullscreen = false,
		gametime = 1
	}

	local data = table.load(path)
	if not data then
		table.save(def,path)
	end
	data = table.load(path)

	local function checkTable(check,t)
		for i,v in pairs(t) do
			if type(v) ~= table then
				if check[i] == nil then
					check[i] = v
				end
			else
				checkTable(check[i],v)
			end
		end
		return check
	end
	data = checkTable(data,def)
	saveSettings(data)

	return data
end

function saveSettings(data)
	table.save(data,path)
end

local data = loadSettings()
local settings = Gamestate.new()
local selection = 1
local fxtime = 0

--settings
local spawnAi = Option:new{
	x=100,
	y=100,
	width=210,
	height=25,
	draw = function(self)
		local text = '< Spawn AI: '..data.ai..' >'
		love.graphics.print(text,self.x+8,self.y-2)
	end,
	keypressed = function(self,k,uni)
		if k=='right' then
			data.ai = data.ai + 1
		elseif k=='left' then
			data.ai = data.ai - 1
		end
		data.ai = math.clamp(1,data.ai,8)
	end
}

local displayModes = love.graphics.getModes()
local find
for i,v in pairs(displayModes) do
	if v.width == data.res.width
	and v.height == data.res.height then
		find = i
		break
	end
end
local displaySelect = find==nil and 1 or find
local setMode = Option:new{
	x=100,
	y=130,
	width=340,
	height=25,
	draw = function(self)
		local w,h = data.res.width, data.res.height
		local text = '< Display Mode: '..w..'x'..h..' >'
		love.graphics.print(text,self.x+8,self.y-2)
	end,
	keypressed = function(self,k,uni)
		if k=='left' or k=='right' then
			if k=='left' then
				displaySelect = displaySelect<#displayModes and displaySelect+1 or 1
			elseif k=='right' then
				displaySelect = displaySelect>1 and displaySelect-1 or #displayModes
			end
			data.res.width = displayModes[displaySelect].width
			data.res.height = displayModes[displaySelect].height
			setResolution(data.res.width,data.res.height)
		end
	end
}

local fullscreen = Option:new{
	x=100,
	y=160,
	width=140,
	height=25,
	draw = function(self)
		local fs = (data.fullscreen and 'Fullscreen' or 'Windowed')
		love.graphics.print(fs,self.x+8,self.y-2)
	end,
	keypressed = function(self,k)
		if k == 'return' then
			data.fullscreen = not data.fullscreen
			setResolution(nil,nil,data.fullscreen)
		end
	end
}

local time = Option:new{
	x = 100,
	y = 190,
	width = 335,
	height = 25,
	draw = function(self)
		local text = '< Game Time: '..(data.gametime)..' Minute(s) >'
		love.graphics.print(text,self.x+8,self.y-2)
	end,
	keypressed = function(self,k)
		local v = data.gametime
		local limit = 10
		if k=='left' then
			v = v>1 and v-1 or limit
		elseif k=='right' then
			v = v<limit and v+1 or 1
		end
		data.gametime = v
	end
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
			saveSettings(data)
			Gamestate.switch(States.menu)
			PromptMsg:new('Data saved!')
		end
	end
}

local settingTable = {
	spawnAi,
	setMode,
	fullscreen,
	time,
	exit
}

--gamestate callbacks
function settings:enter()
	loadSettings()
	selection = 1
	love.keyboard.setKeyRepeat(0.3,0.03)
end

function settings:leave()
	love.keyboard.setKeyRepeat(0,0)
end

function settings:update(dt)
	fxtime = fxtime+dt
	for i,v in pairs(settingTable) do
		if selection==i then
			v.update(v,dt)
		end
	end
end

function settings:draw()
	for i,v in pairs(settingTable) do
		love.graphics.setColor(255,255,255)
		v.draw(v)
		if selection == i then
			borderRect(v.x,v.y,v.width,v.height)
		end
	end
end

function settings:keypressed(k,uni)
	for i,v in pairs(settingTable) do
		if selection==i then
			v.keypressed(v,k,uni)
		end
	end

	if k=='down' then
		selection = selection<#settingTable and selection+1 or 1
	elseif k=='up' then
		selection = selection>1 and selection-1 or #settingTable
	end

	if k=='escape' then
		saveSettings(data)
		Gamestate.switch(States.menu)
		PromptMsg:new('Data saved!')
--		love.event.quit()
	end
end

--do this or it will throw a complete fit
return settings