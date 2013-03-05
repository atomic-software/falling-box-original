local path = love.filesystem.getUserDirectory() .. 'falling-box-profile'

function loadHumanData()
	local def = {
		name = 'You',
		hue = 0,
		sat = 200,
		value = 100,
		
		controls = {
			right = 'right',
			left = 'left',
			down = 'down',
			jump = 'up',
			grab = 'z',
			pause = 'return'
		},

		joy = {
			jump = 3,
			grab = 4,
			pause = 10
		}
	}

	local data,msg = table.load(path)
	if data==nil then
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
	end
	checkTable(data,def)

	return data
end

function saveHumanData(t)
	table.save(t,path)
end

local data
local human

function SpawnHuman()
	data = loadHumanData()
	human = Player:new{
		id=data.name,
		hue=data.hue,
		sat=data.sat,
		value=data.value
	}
	return human
end

function getHuman()
	return human
end

function updateP1(dt)
	if PauseState then return end

	human:update(dt)
	
	local left = love.keyboard.isDown(data.controls.left)
	local right = love.keyboard.isDown(data.controls.right)
	local down = love.keyboard.isDown(data.controls.down)
	local axis, vert = love.joystick.getAxes(1)
	local dir = 0

	if axis~=nil then
		dir = axis
	end
	if left then
		dir = -1
	elseif right then
		dir = 1
	end
	human:move(dir)

	if vert ~= nil and math.sign(vert) == 1 or down then
		if human.yvel < 0 then human.yvel = 0 end
		human.yvel = human.yvel + human.grav*dt
	end
end

function keyP1(k)
	if PauseState then return end

	if k==data.controls.jump or k==data.joy.jump then
		human:jump()
	end

	if k==data.controls.grab or k==data.joy.grab then
		human:grab()
	end

	if k=='escape' then
		if not PauseState then
			PauseState = 'paused'
		elseif PauseState == 'paused' then
			PauseState = nil
		end
	end
end

function keyLiftP1(k)
	if k==data.controls.grab or k==data.joy.grab then
		human:release()
	end
end

