-- robotapi.lua
-- Author: Kingdaro

local api = {}

local function sleep(self, sec)
	timer.add(sec, function()
		if self.routine then
			coroutine.resume(self.routine)
		end
	end)
	coroutine.yield(self.routine)
end

function api:forward()
	return self:forward() , sleep(self, 0.5)
end

function api:back()
	return self:back(), sleep(self, 0.5)
end

function api:up()
	return self:up(), sleep(self, 0.5)
end

function api:down()
	return self:down(), sleep(self, 0.5)
end

function api:left()
	return self:turn 'left', sleep(self, 0.2)
end

function api:right()
	return self:turn 'right', sleep(self, 0.2)
end

function api:inFront()
	return objects.checkSpace(self:inFront()) and true
end

function api:above()
	return objects.checkSpace(self.x, self.y, self.z + 1) and true
end

function api:below()
	return objects.checkSpace(self.x, self.y, self.z - 1) and true
end

function api:deploy()
	local x, y, z = self:inFront()
	local res
	if objects.checkSpace(x,y,z) then
		res = false
	else
		blocks.create(x, y, z)
		res = true
	end
	sleep(self, 0.2)
	return res
end

function api:setName(name)
	self.name = name
end

function api:sleep(...)
	sleep(self, ...)
end

return api