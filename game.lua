local game = Gamestate.new()

function game:enter(old_state,players,ais)
	local settings = loadSettings()

	startTimer = 3
	gameTime = settings.gametime*60 + startTimer
	timerPulse = 1
	endTick = 10
	PauseState = nil
	gTime = 0
	gTick = newTick()

	SpawnHuman()
	SpawnAI(ais)

	clearDelays()

	for i=0, startTimer-1 do
		delay(i,function()
			timerPulse = 1
			sound.timer_tick:stop()
			sound.timer_tick:play()
		end)
	end
	delay(startTimer,function()
		sound.timer_start:stop()
		sound.timer_start:play()
	end)
end

function game:update(dt)
	updateShake(dt)
	updateCamera(dt)
	updateBounds(dt)
	if gameTime < 0 then gameTime = 0 PauseState = 'endgame' end
	if PauseState then return end
	resetPauseMenu()
	
	updateDelays(dt)

	startTimer = startTimer - dt
	gameTime = gameTime - dt
	timerPulse = math.max(timerPulse-dt*10,0)

	if gameTime < endTick and endTick ~= 0 then
		timerPulse = 1
		sound.timer_tick:stop()
		sound.timer_tick:play()
		endTick = endTick - 1
	end

	if startTimer > 0 then return end

	gTime = gTime + dt
	if gTime > gTick then
		gTick = gTick+newTick()
		if Effects.freeze==nil then
			spawnBlocks()
		end
	end

	updateEffects(dt)
	updateP1(dt)
	updateAi(dt)

	if Effects.freeze then return end
	updatePowerups(dt)
	updateBlocks(dt)
	updateParticles(dt)
	updateCleaner(dt)
end

function game:draw()
	love.graphics.push()

	drawEffects()
	drawCamera()

	drawCleaner()
	drawPlayers()
	drawBlocks()
	drawParticles()
	drawBounds()
	drawFloor()
	drawPlayerNames()
	drawPowerups()

	love.graphics.pop()
	drawEffectNotes()
	drawTimer()
	drawPauseMenu()
end

function game:keypressed(k,uni)
	if PauseState then keyPauseMenu(k) return end
	keyP1(k)
	command(k)

	if k=='escape' then Paused = true end
end

function game:keyreleased(k,uni)
	keyLiftP1(k)
end

function game:joystickpressed(joy,b)
	keyP1(b)
end

function game:joystickreleased(joy,b)
	keyLiftP1(b)
end

function game:leave()
	clearPlayers()
	clearAi()
	clearBlocks()
	clearShake()
	clearPowerups()
	clearParticles()
	clearEffects()
end

function drawTimer()
	local function zeroTrail(s)
		if string.len(tostring(s)) == 1 then return '0'..s
		else return s end
	end

	local minutes = math.floor(gameTime/60)
	local seconds = zeroTrail(math.floor(gameTime%60))
	local milliseconds = zeroTrail(math.floor((gameTime*100)%100))
	local str = minutes..':'..seconds..'.'..milliseconds
	local color = gameTime < 10 and {255,0,0} or {255,255,255}

	love.graphics.setFont(Fonts.large)
	shadowText(str,0,20 + timerPulse*10,screen.width,'center',color)
end

return game