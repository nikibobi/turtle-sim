-- console.lua
-- Author: Kingdaro

local console = {
	open = false;
	scroll = 0;
}

local text = ''

local window
local canvas

function console.init()
	local w,h = love.graphics.getMode()
	
	window = gui.window{
		x = 0;
		y = h;
		width = w;
		height = h/2;
		border = 6;
		trans = 'outCubic';
		speed = 0.5;
		tween = nil;
	}
	
	canvas = love.graphics.newCanvas()
end

function console.write(...)
	text = text .. table.concat{...}
	
	canvas:clear()
	canvas:renderTo(function()
		local g = love.graphics
		g.print(text, 10, 10)
	end)
end

function console.print(...)
	console.write(..., '\n')
end

function console.show()
	if console.open then return end
	
	local w,h = love.graphics.getMode()
	if window.tween then tween.stop(window.tween) end
	window.tween = tween(window.speed, window, {y = h - 200}, window.trans)
end

function console.hide()
	if not console.open then return end
	
	local w,h = love.graphics.getMode()
	if window.tween then tween.stop(window.tween) end
	window.tween = tween(window.speed, window, {y = h}, window.trans)
end

function console.toggle()
	if not console.open then
		console.show()
		console.open = true
	else
		console.hide()
		console.open = false
	end
end

function console.update(dt)
	--???
end

function console.draw()
	if not window then return end
	
	local g = love.graphics
	local w,h = g.getMode()
	
	if window.x < h then
		window:draw()
	end
	
	console.scroll = console.scroll < 0 and 0 or console.scroll
	
	g.setStencil(window:stencil())
	g.setColor(255, 255, 255)
	g.draw(canvas, window.x, window.y - console.scroll)
	g.setStencil()
end

--print = console.print
return console