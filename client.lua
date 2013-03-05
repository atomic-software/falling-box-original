local multi = Gamestate.new()
local client = lube.client
local sendtick = 0.1
local addtick = sendtick
local time = 0
local players = {}
local data

local function receive(data)
	--unpack our data
	data = lube.bin:unpack(data)

	--player updating for other clients (and you)
	if data.cmd == 'update' then
		--if the player doesn't exist, make it
		if players[data.ip] == nil then
			players[data.ip] = Player:new(data)
		end

		--convenience
		local player = players[data.ip]

		--player updating
		for i,v in pairs(data) do
			player[i] = v
		end
	end
end

function multi:enter(oldState,ip,port)
	--get important stuff loaded
	humandata = loadHumanData()

	--init and connect
	client:Init()
	client:setHandshake('Hello!')
	client:setCallback(receive)
	client:connect(ip,port)
end

function multi:update(dt)
	updateCamera(dt)
	client:update(dt)

	local left = love.keyboard.isDown(humandata.controls.left)
	local right = love.keyboard.isDown(humandata.controls.right)

	local dir = 0
	if left then
		dir = dir-1
	end
	if right then
		dir = dir+1
	end
	client:send(lube.bin:pack({cmd='move',dir=dir}))
end

function multi:draw()
	drawCamera()
	drawPlayers()
	drawFloor()
end

function multi:keypressed(k)
	if k==humandata.controls.jump then
		client:send(lube.bin:pack({cmd='jump'}))
	end

	if k=='escape' then Gamestate.switch(States.menu) end
end

function multi:keyreleased(k)

end

function multi:leave()
	client:disconnect()
end

multi.quit = multi.leave

return multi