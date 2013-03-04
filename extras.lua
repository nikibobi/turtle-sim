function shadowText(text, x, y, red, green, blue, alpha)
	local g = love.graphics
	
	if not (red and green and blue) then
		red, green, blue, alpha = g.getColor()
	end
	
	g.setColor(0, 0, 0, 150)
	g.print(text, x+2, y+2)
	
	g.setColor(red, green, blue, alpha)
	g.print(text, x, y)
end

function shadowTextf(text, x, y, limit, align, red, green, blue, alpha)
	local g = love.graphics
	
	if not (red and green and blue) then
		red, green, blue, alpha = g.getColor()
	end
	
	g.setColor(0, 0, 0, 150)
	g.printf(text, x+2, y+2, limit, align)
	
	g.setColor(red, green, blue, alpha)
	g.printf(text, x, y, limit, align)
end

function protect(f, ...)
	
end