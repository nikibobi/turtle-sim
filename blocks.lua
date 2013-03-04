-- blocks.lua
-- Author: Kingdaro

local blocks = {}

function blocks.create(x, y, z)
	local block = objects.new{
		type = 'block';
		x=x; y=y; z=z;
		
		draw = function(self)
			local g = love.graphics
			g.setColor(self.color)
			g.draw(getImage 'block.png', self:screenCoords())
		end;
	}
	
	objects.add(block)
end

return blocks