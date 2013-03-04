-- image-loader.lua
-- Author: Kingdaro

local imgList = {}
local allowedExtensions = 'png; jpeg; gif;'

function loadImages( path )
	local g, fs = love.graphics, love.filesystem
	for _,file in pairs(fs.enumerate(path)) do
		local ext = file:match('%.(.+)$')
		if allowedExtensions:find(ext..';') then
			imgList[file] = g.newImage(path .. file)
		end
	end
end

function getImage( imgName )
	return imgList[imgName]
end