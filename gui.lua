-- gui.lua
-- Author: Kingdaro

local gui = {}

local colors = {
	bg = {10, 10, 10, 200};			-- window background
	border = {180, 180, 180, 220};	-- window border
	outline = {60, 60, 60};			-- window border outline
}

local defWindow = {
	x = 0;
	y = 0;
	width = 200;
	height = 100;
	border = 16;
	
	center = function(self)
		local w,h = love.graphics.getMode()
		self.x = w/2 - self.width/2
		self.y = h/2 - self.height/2
	end;
	
	draw = function(self)
		local g = love.graphics
		local w,h = g.getMode()
		
		-- draw border
		g.setInvertedStencil(self:stencil())
		g.setColor(colors.border)
		g.rectangle('fill', 
			self.x - self.border,
			self.y - self.border,
			self.width + self.border*2,
			self.height + self.border*2
		)
		
		-- draw outlines
		g.setInvertedStencil()
		g.setColor(colors.outline)
		g.rectangle('line', 
			self.x - self.border,
			self.y - self.border,
			self.width + self.border*2,
			self.height + self.border*2
		)
		g.rectangle('line', self.x, self.y, self.width, self.height)
		
		-- draw background
		g.setColor(colors.bg)
		g.rectangle('fill', self.x, self.y, self.width, self.height)
	end;
	
	stencil = function(self)
		local g = love.graphics
		local w,h = g.getMode()
		return function()
			g.rectangle('fill', self.x, self.y, self.width, self.height)
		end
	end;
}

function gui.window(obj)
	obj = obj or {}
	setmetatable(obj, {__index = defWindow})
	return obj
end

return gui