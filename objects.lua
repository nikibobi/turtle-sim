-- objects.lua
-- Author: Kingdaro
-- WIP

local objects = {}

local zdist = 32
local zoffset = 8

local base = {
	-- defaults
	x = 0;
	y = 0;
	z = 0;
	color = {255, 255, 255};
	image = getImage 'block.png';
	
	-- returns it's position as screen coordinates for drawing
	screenCoords = function(self)
		local x = (self.y + self.x) * 31 + 30
		local y = (self.x - self.y) * 16 - self.z*zdist - zoffset
		return x, y
	end;
	
	-- empty draw function just because
	draw = function(self) end;
}

function objects.new(t)
	obj = setmetatable(t or {}, {__index = base})
	table.insert(objects, obj)
	print(obj.image)
	return obj
end

function objects.update(dt)
	
end

function objects.draw()
	local g = love.graphics
	
	-- sort for correct z-indexing
	table.sort(objects, function(a,b)
		local _, ay = a:screenCoords()	
		local _, by = b:screenCoords()
		return a.x - a.y + a.z < b.x - b.y + b.z
	end)
	
	for i=1, #objects do
		objects[i]:draw()
	end
end

return objects