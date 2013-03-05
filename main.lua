math.randomseed(os.time())
function love.load()
	--presettings or whatever
	love.mouse.setVisible(false)
	love.graphics.setPoint(3,'smooth')

	--important addonss
	require 'secs'
	require 'LUBE'
	require '32log'
	require 'save'
	require 'delay'
	require 'extra'
	Gamestate = require 'gamestate'

	--declaring our screen
	screen = {
		width = love.graphics.getWidth(),
		height = love.graphics.getHeight()
	}

	--other variables
	gWorld = {}
	gTime = 0
	gFX = 0
	Paused = false
	Focused = true

	--images
	img = {
		block = love.graphics.newImage('img/block.png');
		player = love.graphics.newImage('img/player.png');
		add = love.graphics.newImage('img/add.png');
		powerup = love.graphics.newImage('img/powerup.png');
	}

	--sound
	sound = {
		block_destroy = love.audio.newSource('sound/block-destroy.wav');
		box_fall = love.audio.newSource('sound/box-fall.wav');
--		menu_select = love.audio.newSource('sound/menu-select.wav');
		player_death = love.audio.newSource('sound/player-death.wav');
		player_jump = love.audio.newSource('sound/player-jump.wav');
		powerup_collect = love.audio.newSource('sound/powerup-collect.wav');
		powerup_spawn = love.audio.newSource('sound/powerup-spawn.wav');
		music = love.audio.newSource('sound/music.ogg');
		timer_start = love.audio.newSource('sound/timer-start.wav');
		timer_tick = love.audio.newSource('sound/timer-tick.wav');
		block_explosion = love.audio.newSource('sound/block-explosion.wav')
	}

	--declaring our field -- the field height is the screen height
	field = {
		width = 3200,
		height = 1000
	}

	--our font(s)
	local fontDir = 'res/minecraft.ttf'
	Fonts = {
		small = love.graphics.newFont(fontDir,14),
		normal = love.graphics.newFont(fontDir,18),
		large = love.graphics.newFont(fontDir,24),
		title = love.graphics.newFont(fontDir,36)
	}

	--gamestates
	States = {
		game = require 'game',
		menu = require 'menu',
		profile = require 'profile',
		settings = require 'settings',
		host = require 'server',
		join = require 'client',
		connect = require 'connect'
	}

	--powerup effects
	Effects = {
		freeze = nil,
		weed = false
	}

	--load my scripts
	require 'camera'
	require 'camerashake'
	require 'block'
	require 'player'
	require 'human'
	require 'ai'
	require 'particles'
	require 'commands'
	require 'prompt'
	require 'flash'
	require 'bounds'
	require 'stars' 	--to do
	require 'powerups'
	require 'effects'
	require 'menuanimation'
	require 'cleaner'
	require 'pausemenu'

	--set our display mode
	function setResolution(w,h,fs)
		local curw, curh, curfs = love.graphics.getMode()
		w = w==nil and curw or w
		h = h==nil and curh or h
		fs = fs==nil and curfs or fs

		love.graphics.setMode(w,h,fs)
		--important to set filters for scaling
		for i,v in pairs(img) do v:setFilter('linear','nearest') end
	end

	local data = loadSettings()
	setResolution(data.res.width,data.res.height,data.fullscreen)

	--throw us into the main menu :D
	Gamestate.switch(States.menu)

	--tocar la música
	sound.music:setLooping('true')
	sound.music:play()
end

function love.update(dt)
	if not Focused then return end
	if Effects.weed then dt = dt/2 end

	gFX = gFX + dt

	updatePrompt(dt)
	updateFlash(dt)
	Gamestate.update(dt)
	love.graphics.setCaption('That Falling Box Game - FPS '..love.timer.getFPS())

end

function love.draw()
	local w,h = love.graphics.getMode()
	screen = {width=w,height=h}

	love.graphics.push()

	drawShake()
	Gamestate.draw()

	love.graphics.pop()
	drawPrompt()
	drawFlash()
end

function love.keypressed(k,uni)
	Gamestate.keypressed(k,uni)
end

function love.keyreleased(k,uni)
	Gamestate.keyreleased(k,uni)
end

function love.joystickpressed(joy,b)
	Gamestate.joystickpressed(joy,b)
end

function love.joystickreleased(joy,b)
	Gamestate.joystickreleased(joy,b)
end

function love.focus(f)
	Focused = f
	if f then
		sound.music:play()
	else
		sound.music:pause()
	end
end

function love.quit()
	Gamestate.quit()
end

function newTick() return math.random() + 0.5 end
function drawFloor()
	love.graphics.setColor(100,150,200)
	love.graphics.rectangle('fill',0,field.height,field.width,100)
end