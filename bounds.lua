local bound = {
	left = 0,
	right = 0
}

--pass "left" or "right"

function updateBounds(dt)
	bound.left = math.clamp(0,bound.left - dt*2,1)
	bound.right = math.clamp(0,bound.right - dt*2,1)
end

function drawBounds()
	love.graphics.setColor(255,255,255,bound.left*255)
	love.graphics.setLine(4,'smooth')
	love.graphics.line(
		0,0,
		0,field.height
	)

	love.graphics.setColor(255,255,255,bound.right*255)
	love.graphics.line(
		field.width,0,
		field.width,field.height
	)
end

function triggerBound(dir)
	assert(bound[dir]~=nil,'Direction '..dir..' does not exist.')
	bound[dir]=1
end
