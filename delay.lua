local delays = {}

function delay(s,f,n)
	assert(s~=nil,"Time (in seconds) expected.")
	assert(f~=nil,"Function expected.")
	for i,v in pairs(delays) do
		if v.name ~= nil
		and v.name == n then
			return
		end
	end

	table.insert(delays,{
		time = 0,
		delay = s,
		funct = f,
		name = n
	})
end

function updateDelays(dt)
	for i,v in pairs(delays) do
		v.time = v.time + dt
		if v.time >= v.delay then
			v.funct()
			table.remove(delays,i)
		end
	end
end

function drawDelays()
	for i,v in pairs(delays) do
		love.graphics.draw(v.name..': '..v.time,i*15,0)
	end
end

function clearDelays()
	delays = {}
end