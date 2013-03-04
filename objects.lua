-- objects.lua
-- Author: Kingdaro
-- WIP

local objects = {}

local zdist = 32

function objects.init()
	objects.base = {
		type = 'default';
		
		-- defaults
		x = 0;
		y = 0;
		z = 0;
		color = {255, 255, 255};
		image = getImage 'block.png';
		
		name = '';
		nameColor = {255, 255, 255};
		
		-- returns it's position as screen coordinates for drawing
		screenCoords = function(self)
			local x = (self.y + self.x) * 31 + 30
			local y = (self.x - self.y) * 16 - self.z*zdist-- - zoffset
			return x, y
		end;
		
		-- empty draw functions just because
		draw = function() end;
		drawShadow = function() end;
	}
end

function objects.new(t)
	local obj = setmetatable(t or {}, {__index = objects.base})
	return obj
end

function objects.add(obj)
	table.insert(objects, obj)
end

function objects.getType(t)
	local acc = {}
	for i=1, #objects do
		if objects[i].type == t then
			table.insert(acc, objects[i])
		end
	end
	return acc
end

function objects.nearest(x, y, dist, type)
	dist = dist or math.huge
	local nearest
	for i=1, #objects do
		local obj = objects[i]
		local ox, oy = camera.resolve(obj:screenCoords())
		if not nearest then
			if (not type or obj.type == type)
			and math.dist(x, y, ox, oy) < dist then
				nearest = obj
			end
		else
			if math.dist(x, y, nearest:screenCoords()) < math.dist(x, y, ox, oy)
			and (not type or obj.type == type)
			and math.dist(x, y, ox, oy) < dist then
				nearest = obj
			end
		end
	end
	return nearest
end

function objects.checkSpace(x, y, z)
	local function r(n) return math.floor(n + 0.5) end
	for i=1, #objects do
		local obj = objects[i]
		if r(obj.x) == x
		and r(obj.y) == y
		and r(obj.z) == z then
			return obj
		end
	end
	return false
end

function objects.draw()
	-- sort for correct z-indexing
	table.sort(objects, function(a,b)
		return a.x - a.y + a.z < b.x - b.y + b.z
	end)
	
	-- draw 'dem objects
	for i=1, #objects do
		objects[i]:draw()
	end
end

function objects.shadows()
	-- draw 'dem shadows
	for i=1, #objects do
		objects[i]:drawShadow()
	end
end

return objects