local commands = {
	f1 = function()
		Powerup:new()
	end
}

function command(k)
	if type(commands[k])=='function' then commands[k]() end
end