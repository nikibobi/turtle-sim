-- font-mgr.lua
-- Author: Kingdaro

local fonts = {}
local path = 'res/whitrabt.ttf'

function getFont(size)
	if size then
		if not fonts[size] then
			fonts[size] = love.graphics.newFont(path, size)
		end
		return fonts[size]
	else
		return love.graphics.getFont()
	end
end

local default = getFont(22)
default:setLineHeight(1.3)
love.graphics.setFont(default)