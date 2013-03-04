-- keypressed.lua
-- Author: Kingdaro

local keys = {
	pressed = {};
	released = {};
}

function love.keypressed(k, ...)
	keys.pressed[k] = {...}
end

function love.keyreleased(k, ...)
	keys.released[k] = {...}
end

function love.keyboard.pressed(k)
	if keys.pressed[k] then
		local args = keys.pressed[k]
		keys.pressed[k] = nil
		return true, unpack(args)
	end
end

function love.keyboard.released(k)
	if keys.released[k] then
		local args = keys.released[k]
		keys.released[k] = nil
		return true, unpack(args)
	end
end

local mouse = {
	pressed = {};
	released = {};
}

function love.mousepressed(b, ...)
	mouse.pressed[b] = {...}
end

function love.mousereleased(b, ...)
	mouse.released[b] = {...}
end

function love.mouse.pressed(k)
	if mouse.pressed[k] then
		local args = mouse.pressed[k]
		mouse.pressed[k] = nil
		return true, unpack(args)
	end
end

function love.mouse.released(k)
	if mouse.released[k] then
		local args = mouse.released[k]
		mouse.released[k] = nil
		return true, unpack(args)
	end
end
