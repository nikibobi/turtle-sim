-- robotapi.lua
-- Author: Kingdaro

local api = {}

function api:sleep(sec)
	timer.add(sec, function()
		if self.routine then
			coroutine.resume(self.routine)
		end
	end)
	coroutine.yield(self.routine)
end

function api:forward()
	return self:forward(), api.sleep(self, 0.5)
end

function api:back()
	return self:back(), api.sleep(self, 0.5)
end

function api:up()
	return self:up(), api.sleep(self, 0.5)
end

function api:down()
	return self:down(), api.sleep(self, 0.5)
end

function api:left()
	self:turn 'left'
	api.sleep(self, 0.2)
end

function api:right()
	self:turn 'right'
	api.sleep(self, 0.2)
end

function api:setName(name)
	self.name = name
end

return api