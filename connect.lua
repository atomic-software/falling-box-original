local connect = Gamestate.new()
local settings
local fxtime = 0

function connect:enter()
	settings = loadSettings()
	if settings.ip == nil then settings.ip = '127.0.0.1' end
end

function connect:update(dt)
	fxtime = fxtime+dt
end

function connect:draw()
	local font = Fonts.normal
	local width,height = 300,24
	local x = screen.width/2 - width/2
	local y = screen.height/2 - height/2
	local text = 'Enter an IP to connect to.'

	borderRect(x,y,width,height)
	love.graphics.setFont(font)
	love.graphics.printf(text, 0, screen.height/2 - 50, screen.width, 'center')
	shadowText(
		settings.ip..(math.sin(fxtime*10)>0 and '_' or ''), 
		x+8, y-2, screen.width
	)
end

function connect:keypressed(k,uni)
	local len = string.len(settings.ip)
	if uni>31 and uni<126 then
		settings.ip = settings.ip..string.char(uni)
	elseif k=='backspace' then
		settings.ip = string.sub(settings.ip,1,len-1)
	end

	if k=='return' then
		saveSettings(settings)
		Gamestate.switch(States.join,settings.ip,22222)
	end

	if k=='escape' then
		Gamestate.switch(States.menu)
	end
end

function connect:leave()
	saveSettings(settings)
end

connect.exit = connect.leave

return connect