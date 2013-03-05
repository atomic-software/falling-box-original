local active = {}

class 'Effect' {
	name = '',
	time = 0,
	maxtime = 0,
	start = function() end,
	stop = function() end,
	update = function() end,
	draw = function() end
}

function Effect:__init(t)
	for i,v in pairs(t) do
		self[i] = v
	end
	self.maxtime = self.time
end

function fireEffect(player)
	local effects = {
		
		Effect:new{
			name = 'Freeze',
			time = 10,
			update = function() Effects.freeze = player end,
			stop = function() Effects.freeze = nil end
		},

		Effect:new{
			name = 'Wall of Doom',
			time = 1,
			start = function()
				for i=-3, 3 do
					local f = ((i-1)*60)

					Block:new{
						x = player.x + 50,
						y = player.y - f,
						xvel = 1000,
						yvel = 0,
						state = 'bullet',
						stop = 0,
						maxhit = 3,
						fadefx = 1,
						owner = player
					}

					Block:new{
						x = player.x - 50,
						y = player.y - f,
						xvel = -1000,
						yvel = 0,
						state = 'bullet',
						stop = 0,
						maxhit = 3,
						fadefx = 1,
						owner = player
					}
				end
			end
		},
		Effect:new{
			name = 'Rapid Fire',
			time = 10,
			update = function() player.rapidfire = true end,
			stop = function() player.rapidfire = nil end
		},
		
		Effect:new{
			name = 'Euphoria',
			time = 15,
			update = function()
				love.graphics.setBackgroundColor(HSL((gTime*255)%255,255,150))
				for i,v in pairs(sound) do
					v:setPitch(0.5)
				end
				Effects.weed = true
			end,
			stop = function()
				love.graphics.setBackgroundColor(0,0,0)
				for i,v in pairs(sound) do
					v:setPitch(1)
				end
				Effects.weed = false
			end
		},
		
		Effect:new{
			name = 'Vertigo',
			time = 20,
			draw = function(t)
				love.graphics.translate(screen.width/2,screen.height/2)
				love.graphics.rotate(math.sin(t*2)*0.3)
				love.graphics.translate(-screen.width/2,-screen.height/2)
				
			end
		},
		Effect:new{
			name = 'Moonjump',
			time = 15,
			update = function() player.grav = 1000 end,
			stop = function() player.grav = 3000 end
		},

		Effect:new{
			name = 'Melee',
			time = 30,
			update = function() player.melee = true end,
			stop = function() player.melee = false end
		},
		Effect:new{
			name = 'Cleaner',
			time = 2,
			start = function() 
				delay(2, function()
					Cleaner:new(player)
				end)
			end
		}
		
	}

	local choice = effects[math.random(#effects)]

	choice.player = player
	choice:start()

	table.insert(active, choice)

	PromptMsg:new(player.id .. ' picked up ' .. choice.name .. '!',{255,255,0})
end

function updateEffects(dt)
	for i,v in pairs(active) do
		v.update(dt)

		v.time = v.time-dt
		if v.time < 0 then
			v.stop()
			table.remove(active,i)
		end
	end
end

function drawEffects()
	for i,v in pairs(active) do
		v.draw(v.time)
	end
end

function drawEffectNotes()
	for i,v in pairs(active) do
		local padding = 4
		local spacing = 4

		local ratio = v.time/v.maxtime
		local x = 10
		local y = 10 + (i-1) * (19 + padding*2 + spacing)
		local width = ratio*400 + padding
		local height = 19 + padding*2

		love.graphics.setFont(Fonts.small)
		love.graphics.setColor(0,0,255,150)
		love.graphics.rectangle('fill',x,y,width,height)
		shadowText(v.name .. ' - ' ..tostring(v.player.id),x+padding,y+padding,field.width)
	end
end

function clearEffects()
	for i,v in pairs(active) do
		v.time = 0
		v.stop()
	end
	active = {}
end