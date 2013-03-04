-- editor.lua
-- Author: Kingdaro

local editor = {
	enabled = false;
	target = nil;
	code = nil;
	cursor = {x=0, y=1};
	scroll = {x=0, y=0};
	cursorBlink = 0;
}

local window

local padding = 8
local textcolor = {220, 220, 220}

function editor.enable(robot)
	editor.enabled = true
	editor.target = robot
	editor.code = robot:loadCode()
	editor.cursor.y = math.clamp(1, editor.cursor.y, #robot.code)
	editor.cursor.x = math.clamp(0, editor.cursor.x, #robot.code[editor.cursor.y])
	editor.scroll.y = 0
	
	window = gui.window{
		width = 500;
		height = 300;
	}
	window:center()
	
	love.keyboard.setKeyRepeat(.3, 0.035)
end

function editor.draw()
	window:draw()
	
	local g = love.graphics
	local w,h = g.getMode()
	local left, top = window.x, window.y
	local font = g.getFont()
	
	local code = editor.code
	local cursor = editor.cursor
	local curline = code[cursor.y]
	
	-- draw code
	g.setStencil(window:stencil())
	g.setColor(textcolor)
	g.print(table.concat(editor.code,'\n'), left + padding - editor.scroll.x, top + padding - editor.scroll.y)
	if math.floor(math.sin(editor.cursorBlink*15)/2 + 1) == 1 then
		local lineheight = font:getHeight(curline) * font:getLineHeight()
		local x = left + padding + font:getWidth(curline:sub(1, cursor.x)) - editor.scroll.x
		local y = top + padding + lineheight*(cursor.y - 1) - editor.scroll.y
		
		g.print('_', x,y)
	end
	
	g.setStencil()
end

function editor.update(dt)
	editor.cursorBlink = editor.cursorBlink + dt
end

function editor.keypressed(k, uni)
	local code = editor.code
	local cursor = editor.cursor
	
	local line = code[cursor.y]
	local left = line:sub(1, cursor.x)
	local right = line:sub(cursor.x + 1)
	
	local font = love.graphics.getFont()
	
	if uni > 31 and uni < 127 then
		code[cursor.y] = left..string.char(uni)..right
		cursor.x = cursor.x + 1
	end
	
	if k == 'up' then
		cursor.y = math.clamp(1, cursor.y - 1, #code)
	elseif k == 'down' then
		cursor.y = math.clamp(1, cursor.y + 1, #code)
	elseif k == 'left' then
		if cursor.x > 0 then
			cursor.x = cursor.x - 1
		elseif cursor.y > 1 then
			cursor.y = cursor.y - 1
			cursor.x = #code[cursor.y]
		end
	elseif k == 'right' then
		if cursor.x < #line then
			cursor.x = cursor.x + 1
		elseif cursor.y < #code then
			cursor.y = cursor.y + 1
			cursor.x = 0
		end
	elseif k == 'return' then
		if love.keyboard.isDown 'lctrl' then
			--editor.enabled = false
			editor.target:saveCode()
			editor.target:exec()
		else
			local whitespace = line:match('^%s*')
			if cursor.x > 0 then
				code[cursor.y] = left
				cursor.y = cursor.y + 1
				table.insert(code, cursor.y, whitespace..right)
				cursor.x = #whitespace
			else
				table.insert(code, cursor.y, whitespace)
				cursor.y = cursor.y + 1
			end
		end
	elseif k == 'tab' then
		code[cursor.y] = '  '..line
		cursor.x = cursor.x + 2
	elseif k == 'backspace' then
		if cursor.x > 0 then
			code[cursor.y] = left:sub(1, -2)..right
			cursor.x = cursor.x - 1
		elseif cursor.y > 1 then
			code[cursor.y-1] = code[cursor.y-1] .. code[cursor.y]
			cursor.x = #code[cursor.y-1] - #code[cursor.y]
			table.remove(code, cursor.y)
			cursor.y = cursor.y - 1
		end
	elseif k == 'delete' then
		if #code > 1 then
			if cursor.x < #line then
				code[cursor.y] = left..right:sub(2)
			elseif cursor.y < #code then
				table.remove(code, cursor.y)
			end
		end
	elseif k == 'end' then
		cursor.x = #line
	elseif k == 'home' then
		cursor.x = 0
	end
	
	
	cursor.x = math.clamp(0, cursor.x, #code[cursor.y])
	cursor.y = math.clamp(1, cursor.y, #code)
	
	local scroll = editor.scroll
	local cw, ch = font:getWidth('h'), font:getHeight('h')
	
	if (cursor.y + 1) * ch > scroll.y + window.height then
		scroll.y = scroll.y + ch
	elseif (cursor.y - 1) * ch < scroll.y then
		scroll.y = scroll.y - ch
	end
	
	if (cursor.x + 1) * cw > scroll.x + window.width then
		scroll.x = scroll.x + cw
	elseif (cursor.x - 1) * cw < scroll.x then
		scroll.x = scroll.x - cw
	end
	
	editor.cursorBlink = 0
	editor.limitScroll()
end

function editor.mousepressed(x, y, b)
	local scroll = editor.scroll
	local lineheight = love.graphics.getFont():getHeight(' ')
	if b == 'wu' then
		editor.scroll.y = scroll.y - lineheight
	elseif b == 'wd' then
		editor.scroll.y = scroll.y + lineheight
	end
	editor.limitScroll()
end

function editor.limitScroll()
	local scroll = editor.scroll 
	scroll.x = math.max(scroll.x, 0)
	scroll.y = math.clamp(0, scroll.y, font:getHeight('h')*#code)
end

return editor