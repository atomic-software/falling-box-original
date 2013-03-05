local function newAiTick() return math.random()*0.8 end
local function newAiTarget() return getPlayers()[math.random(#getPlayers())] end
local function rapidFireTick() return math.random()*0.3+0.1 end

local aiTable = {}

local names = {
	'Your Mother',
	'A Moose',
	'That One Guy',
	'Chairs',
	'Therapist',
	'Badspot',
	'Notch',
	'Kompressor',
	'Rotondo',
	'Shadow Mario',
	'Tables',
	'Dub Steppin',
	'A Block',
	'Anonymous',
	'Mr. Miller',
	'couldn\'t think of a name sorry',
	'Boredom',
	'The US Government',
	'Strings',
	'Plot',
	'Same.',
	'Kingdaro\'s laziness',
	'Ded Mow Five',
	'Railyx',
	'Knife Party'
}

function actions(dt,ai)
	local blocked = false

	if ai.dead then return end
	
	for i,v in pairs(gWorld) do
		local diffX = ai.x - v.x
		local diffY = ai.y - v.y
		if math.abs(diffY) < 25 then
			if v.state ~= 'bullet' then
				if not ai.holding then
					if math.abs(diffX) < 75 then
						delay(math.random()*0.1,function()
							ai:grab()
							delay(math.random()*0.3, function()
								ai:jump()
							end, 'ai jump')
						end,'ai grab')

						blocked = true
					end
				else
					ai:jump()
				end
			else
				if math.abs(diffX) < 150 then
					ai:jump()
				end
			end
		end
	end

	local diffX = ai.target.x - ai.x
	local diffY = math.abs(ai.target.y - ai.y)
	
	if not ai.holding then
		if ai.search == nil then ai.search = math.rsign() end

		ai.xvel = ai.speed*ai.search
		ai.dir = ai.search

		if ai.x >= field.width-50 then
			ai.search = -1
		elseif ai.x <= 0 then
			ai.search = 1
		end
	else
		ai.search = nil
	
		if math.abs(diffX) > (ai.melee and 50 or 150) then
			ai.xvel = ai.speed*math.sign(diffX)
		else
			ai.xvel = 0
		end
		ai.dir = math.sign(diffX)~=0 and math.sign(diffX) or ai.dir
	
		if not blocked then
			delay(math.random()*0.3,function()
				ai.dir = math.sign(diffX)~=0 and math.sign(diffX) or ai.dir
			end, 'ai turn')
			if not ai.melee then
				delay(math.random()*0.3 + 0.4,function() ai:release() end,'ai release')
			end
		end
	end
	
	--random jumping for the win?
	ai.time = ai.time+dt
	if ai.time > ai.tick then
		ai.tick = ai.tick + newAiTick()
	
		if math.random()*20 > 10 then
			ai:jump()
		end

		ai.target = newAiTarget()
	end

	if ai.time > ai.rftick then
		ai.rftick = ai.rftick + rapidFireTick()
		if ai.rapidfire then
			ai:release()
		end
	end

	if ai.target.dead then ai.target = newAiTarget() end
end

function SpawnAI()
	local num = loadSettings().ai
	for i=1, num do
		local ai = Player:new{
			id=names[math.random(#names)],
			hue=math.random(0,255),
			sat=math.random(50,200),
			value=math.random(50,200)
		}

		ai.time = 0
		ai.tick = newAiTick()
		ai.search = nil
		ai.target = newAiTarget()
		ai.rftick = rapidFireTick()

		table.insert(aiTable,ai)
	end
end

function updateAi(dt)
	for i,v in pairs(aiTable) do
		v:update(dt)
		actions(dt,v)
	end
end

function clearAi()
	for i,v in pairs(aiTable) do
		v.holding = false
	end
	aiTable = {}
end