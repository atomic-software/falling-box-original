local msgTable = {}
local msgHeight = 24
local speed = 20

class 'PromptMsg' {
	text = '',
	color = {255,255,255},
	life = 5,
	fade = 1
}

function PromptMsg:__init(text,color)
	self.text = text
	self.color = color~=nil and color or {255,255,255}

	table.insert(msgTable,self)
	if #msgTable>6 then
		table.remove(msgTable,1)
	end

	print(text)
end

function PromptMsg:update(dt,i)
	if self.life > 0 then
		self.life = self.life - dt
	elseif self.fade > 0 then
		self.fade = self.fade - dt
	else
		table.remove(msgTable,i)
	end
	self.color[4] = math.min(math.max(self.fade*255,0),255)
end

function PromptMsg:draw(i)
	local x,y = 12, screen.height - i*msgHeight - 12
	local shadow = 2

	love.graphics.setColor(0,0,0,255/3)
	love.graphics.printf(self.text,x+shadow,y+shadow,screen.width)
	love.graphics.setColor(self.color)
	love.graphics.printf(self.text,x,y,screen.width)
end


function updatePrompt(dt)
	for i,v in pairs(msgTable) do
		if v ~= nil then
			v:update(dt,i)
		end
	end
end

function drawPrompt()
	love.graphics.setFont(Fonts.normal)
	for i,v in pairs(msgTable) do
		if v ~= nil then
			v:draw(i)
		end
	end
end