-- camera.lua
-- Author: Kingdaro

local camera = {}

local x = 0
local y = 0
local xdest = 0
local ydest = 0
local speed = 15
local scale = 1

function camera.update(dt)
	x = x - (x - xdest)*dt*speed
	y = y - (y - ydest)*dt*speed
end

function camera.draw()
	local g = love.graphics
	
	g.translate(math.floor(x), math.floor(y))
	g.scale(scale)
end

function camera.move(x, y)
	xdest = xdest + x
	ydest = ydest + y
end

function camera.setScale(s)
	scale = s
end

function camera.coords()
	return x, y
end

function camera.resolve(_x, _y)
	local w,h = love.graphics.getMode()
	return x + _x*screenScale, y + _y*screenScale
end

return camera