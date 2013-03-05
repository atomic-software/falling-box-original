local host = Gamestate.new()
local server = lube.server
local players = {}

local function connect(ip, port)
	--tell the server host that someone connected
	PromptMsg:new('Connection from '..ip)

	--register the player
	players[ip] = Player:new{}
	
	--for convenience
	local send = players[ip]

	--set the command for creation and the IP to clients
	send.cmd = 'create'
	send.ip = ip
end

local function receive(data, ip, port)
	--unpack our data
	data = lube.bin:unpack(data)

	--convenience
	local player = players[ip]

	--handle movement
	if data.cmd == 'move' then
		player:move(data.dir)
	end

	--jumping
	if data.cmd == 'jump' then
		player:jump()
	end
end

local function disconnect(ip, port)
	players[ip]:remove()
	PromptMsg:new(ip..' disconnected.')
end

function host:enter()
	server:Init(22222)
	server:setHandshake('Hello!')
	server:setCallback(receive, connect, disconnect)
end

function host:update(dt)
	server:update(dt)
	updateCamera(dt)
	updatePlayers(dt)

	for i,v in pairs(players) do
		--get ready for sending
		v.cmd = 'update'

		--send an update for the packed player
		server:send(lube.bin:pack(v))
	end
end

function host:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(Fonts.normal)
	local text =
[[
currently hosting server
start the game again and join 127.0.0.1
]]
	love.graphics.print(text,10,10)

	drawCamera()
	drawPlayers()
	drawFloor()
end

function host:keypressed(k)
	if k=='escape' then Gamestate.switch(States.menu) end
end

function host:leave()
	
end

host.quit = host.leave

return host