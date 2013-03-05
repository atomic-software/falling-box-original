local function resume()
	Paused = false
end

local function restart()
	Gamestate.switch(States.menu)
	Gamestate.switch(States.game)
	Paused = false
end

local function quit()
	Gamestate.switch(States.menu)
end

local pauseOptions = {
	{'Resume',resume},
	{'Restart',restart},
	{'Quit',quit}
}

local endOptions = {
	{'New Game',restart},
	{'Quit',quit}
}


local endMsg = {
	'Good game!',
	'That was intense.',
	'...Wow.',
	'Anyone else have a headache?',
	'I hope that wasn\'t too hard.',
	'Addicted yet?',
	'That ONE powerup.',
	'Gotta love that cleaner.',
	'YES. ...YES.',
	'Fun fact - falling blocks kill you.',
	'ON THE M' .. string.rep('O',100) --11
}
local endSelect

local selection = 1

local function getMenu()
	local options = {
		['paused'] = pauseOptions;
		['endgame'] = endOptions;
	}
	return options[PauseState]
end

function drawPauseMenu()
	if PauseState then
		love.graphics.setColor(255,255,255,20)
		love.graphics.rectangle('fill',0,0,screen.width,screen.height)
		
		local font = Fonts.large
		local options = getMenu()
		local indheight = 60
		local offsetx = -screen.width/2 - 50
		local offsety = screen.height/2 - (#options*indheight)/2

		love.graphics.setFont(Fonts.large)
		for i,v in pairs(options) do
			local t = v[1]
			if selection == i then
				t = '> ' .. t
			end
			shadowText(t,offsetx,offsety + (i-1)*indheight,screen.width,'right')
		end

		if PauseState == 'endgame' then
			love.graphics.setFont(Fonts.title)
			local text = endMsg[endSelect]

			if endSelect == 11 then
				love.graphics.printf(text, screen.width*0.375, 50, 9999)
			else
				love.graphics.printf(text, 0, 50, screen.width, 'center')
			end
		end

		drawStats()
	end
end

function keyPauseMenu(k)
	local options = getMenu()

	if k=='down' then
		selection = selection < #options and selection+1 or 1
	elseif k=='up' then
		selection = selection > 1 and selection-1 or #options
	elseif k=='return' then
		options[selection][2]()
		PauseState = nil
	end
end

function resetPauseMenu()
	selection = 1
	endSelect = math.random(#endMsg)
end

function drawStats()
	local font = Fonts.normal

	local players = getPlayers()

	table.sort(players,function(a,b)
		return a.score > b.score
	end)

	local statsize = 50
	local offsetx = screen.width/2
	local offsety = screen.height/2 - #players*statsize/2

	love.graphics.setFont(font)
	for i,v in pairs(players) do
		local text = v.id .. ' - ' .. v.score
		local theight = font:getHeight(text)
		local y = offsety + (i-1)*statsize
		local r,g,b = HSL(v.hue,v.sat,v.value)
		if i==1 then
			r,g,b = HSL((gFX*255 / 2) % 255, 150,150)
		end

		love.graphics.setColor(r,g,b)
		love.graphics.draw(img.player, offsetx, y, 0, statsize/25)
		shadowText(
			text,
			offsetx + statsize, y + statsize/2 - theight/2 - 4,
			screen.width, 'left',
			{r,g,b}
		)
	end
end