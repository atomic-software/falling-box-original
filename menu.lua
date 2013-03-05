local menu = Gamestate.new()

local options = {
	{
		text='Start Game',
		info='Get in the game!',
		action=function() Gamestate.switch(States.game,1,3) end
	},
	{
		text='Profile',
		info='Set your name and color.',
		action=function() Gamestate.switch(States.profile) end
	},
	{
		text='Settings',
		info='Change options such as screen resolution.',
		action=function() Gamestate.switch(States.settings) end
	},
	{
		text='Exit',
		info='Well what do you think?',
		action=function() love.event.quit() end
	}
}

local font = Fonts.large
local textHeight = 40
local selection = 1
local selectObj = {x=0, y=0, width=0, height=0}
local offset = {x=100, y=100}
local padding = {x=8, y=0}
local glowfx = 0
local scrolltime = 0.2

function menu:enter()
end

function menu:update(dt)
	glowfx = glowfx + dt
	menuAnimUpdate(dt)

	local _, aY = love.joystick.getAxes(1)
end

function menu:draw()
	menuAnimDraw()
	
	selectObj.x = offset.x - padding.x

	love.graphics.setLine(1,'smooth')
	love.graphics.setColor(255,255,255,100 + math.sin(glowfx*4)*30)
	love.graphics.rectangle('fill',selectObj.x,selectObj.y,selectObj.width,selectObj.height)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('line',selectObj.x,selectObj.y,selectObj.width,selectObj.height)

	local shadow = 2
	for i,v in pairs(options) do
		local x,y = offset.x, offset.y + (i-1)*textHeight
		local width = font:getWidth(v.text) + padding.x*2
		local height = font:getHeight(v.text) + padding.y*2

		if selection == i then
			selectObj.y = y
			selectObj.width = width
			selectObj.height = height

			local infoheight = Fonts.small:getHeight(v.info)
			love.graphics.setFont(Fonts.small)
			love.graphics.print(
				v.info, 
				x + width + padding.x
				, y + height/2 - infoheight/2
			)
		end

		love.graphics.setFont(font)

		love.graphics.setColor(0,0,0,100)
		love.graphics.print(v.text,x+shadow,y+shadow)

		love.graphics.setColor(255,255,255)
		love.graphics.print(v.text,x,y)
	end
end

function menu:keypressed(k,uni)
	if k=='down' then
		selection = (selection<#options and selection+1 or 1)
	elseif k=='up' then
		selection = (selection>1 and selection-1 or #options)
	elseif k=='return' then
		local option = options[selection]
		option:action()
	elseif k=='escape' then
		love.event.quit()
	end
end

function menu:joystickpressed(joy,b)
end

return menu