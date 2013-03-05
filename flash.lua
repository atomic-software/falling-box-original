local flash = {
	alpha = 0
}

function updateFlash(dt)
	flash.alpha = math.clamp(0,flash.alpha-dt,1)
end

function drawFlash()
	love.graphics.setColor(255,255,255,flash.alpha*255)
	love.graphics.rectangle('fill',0,0,screen.width,screen.height)
end

function fireFlash()
	flash.alpha = 1
end