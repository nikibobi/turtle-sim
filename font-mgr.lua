-- font-mgr.lua
-- Author: Kingdaro

local fonts = {}
local path = 'res/whitrabt.ttf'

function getFont(size)
	size = size or 20
	if not fonts[size] then
		fonts[size] = love.graphics.newFont(path, size)
	end
	return fonts[size]
end

local default = getFont(22)
default:setLineHeight(1.3)
love.graphics.setFont(default)