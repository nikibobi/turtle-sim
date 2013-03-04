-- gameplay.lua
-- Author: Kingdaro

local gameplay = {}
local delete = false

local grassImg
local grassBg

local robotPrompt
local control

function gameplay.init(save)
	local g = love.graphics
	local w,h = g.getMode()
	
	grassImg = getImage 'grass-bg.png'
	grassBg = g.newSpriteBatch(grassImg)
	
	for x=0, w, grassImg:getWidth() do
		for y=0, h, grassImg:getHeight() do
			grassBg:add(x, y)
		end
	end
	
	local w,h = love.graphics.getMode()
	camera.move(w/2/screenScale, h/2/screenScale)
	camera.setScale(screenScale)
	
	robotPrompt = gui.window{
		enabled = true;
		input = '0';
	}
	robotPrompt:center()
end

function gameplay.update(dt)
	camera.update(dt)
	
	if editor.enabled then editor.update(dt) return end
	if robotPrompt.enabled then return end
	
	local k = love.keyboard
	
	local speed = 500
	if k.isDown 'a' then
		camera.move(speed*dt, 0)
	end
	if k.isDown 'd' then
		camera.move(-speed*dt, 0)
	end
	if k.isDown 'w' then
		camera.move(0, speed*dt)
	end
	if k.isDown 's' then
		camera.move(0, -speed*dt)
	end
	
	if control then
		if k.isDown 'i' or k.isDown 'kp8' then
			control:forward()
		end
		if k.isDown 'k' or k.isDown 'kp2' then
			control:back()
		end
		if k.isDown 'o' or k.isDown 'kp+' then
			control:up()
		end
		if k.isDown 'u' or k.isDown 'kp5' or k.isDown 'kp-' then
			control:down()
		end
	end
	
	local m = love.mouse
	local mx, my = m.getPosition()
	-- needs to be done manually, so everything not hovered over is reverted
	for i=1, #objects do
		local obj = objects[i]
		local rx, ry = camera.resolve(obj:screenCoords())
		if math.dist(mx - 64, my - 64, rx, ry) < 45 then
			obj.color = delete and {210, 100, 100} or {210, 210, 210}
			if m.isDown('l','r') then
				obj.color = delete and {210, 50, 50} or {150, 150, 150}
			end
			
			if obj.type == 'robot' then
				obj.showDir = obj.showDir + dt*5
			end
		else
			if obj.type == 'robot' then
				obj.showDir = obj.showDir - dt*5
			end
			obj.color = {255, 255, 255}
		end
		
		if control == obj then
			obj.nameColor = {100, 150, 255}
		else
			obj.nameColor = {255, 255, 255}
		end
	end
	
	if k.isDown('lalt', 'ralt') then
		delete = true
	else
		delete = false
	end
end

function gameplay.keypressed(k, uni)
	if editor.enabled then
		if k == 'escape' then
			editor.enabled = false
			editor.target:saveCode()
			love.keyboard.setKeyRepeat(0, 10)
		else
			editor.keypressed(k, uni)
		end
		return
	end
	
	if k == '`' then
		console.toggle()
	end
	
	if robotPrompt.enabled then
		if uni > 31 and uni < 127 then
			local num = tonumber(string.char(uni))
			if num then
				robotPrompt.input = robotPrompt.input .. num
			end
		end
		
		if k == 'backspace' then
			robotPrompt.input = robotPrompt.input:sub(1, -2)
		end
		
		if k == 'return' then
			robots.new{
				x = math.random(-3, 3);
				y = math.random(-3, 3);
				id = tonumber(robotPrompt.input);
			}
			robotPrompt.enabled = false
		end
		
		if k == 'escape' then
			robotPrompt.enabled = false
		end
		return
	end
	
	if control then
		if k == 'kp4' or k == 'j' then
			control:turn 'left'
		elseif k == 'kp6' or k == 'l' then
			control:turn 'right'
		end
	end
	
	if k == 'n' then
		robotPrompt.enabled = true
	end
	
	if k == 'escape' then
		love.event.quit()
	end
end

function gameplay.mousepressed(x, y, b)
	if editor.enabled then
		editor.mousepressed(x,y,b)
		return
	end
	
	if b == 'wd' then
		console.scroll = console.scroll + 22
	elseif b == 'wu' then
		console.scroll = console.scroll - 22
	end
	
	local robot = robots.nearest(x, y, 23*screenScale)
	local shift = love.keyboard.isDown('lshift','rshift')
	local alt = love.keyboard.isDown('lalt','ralt')
	
	if robot then
		if not alt then
			if b == 'l' then
				if shift then
					control = robot
					return
				else
					robot:exec()
					return
				end
			elseif b == 'r' then
				editor.enable(robot)
				return
			end
		else
			if b == 'l' then
				robots.remove(robot)
				return
			elseif b == 'r' then
				-- make a backup before erasing
				local fs = love.filesystem
				if not fs.exists('backups') then
					fs.mkdir('backups')
				end
				local str = table.concat(robot.code, '\n')
				if #str > 0 then
					fs.write('backups/'..os.time(), str)
					fs.write(robot:saveDir()..'/code', '')
					robot.code = {''}
				end
				return
			end
		end
	else
		if b == 'l' and shift then
			control = nil
		end
	end
end

function gameplay.draw()
	-- localization
	local g = love.graphics
	local x,y = camera.coords()
	local w,h = grassImg:getWidth(), grassImg:getHeight()
	
	-- store graphics settings (i guess???? i dunno i just know you have to push lol)
	g.push()
	
	-- move everything by the camera n stuff
	camera.draw()
	
	-- draw that nice infinite grass
	g.draw(
		grassBg,
		-(math.floor(x / (w*2)) + 1) * w, 
		-(math.floor(y / (h*2)) + 1) * h
	)
	
	-- draw the shadows to make z position clearer
	objects.shadows()
	
	-- draw ALL THE THINGS
	objects.draw()
	
	-- and ends everything that is of the game
	-- start the GUIs!
	g.pop()
	
	-- draw the names and such for robots
	robots.gui()
	
	-- draw that one window that lets you make a new robot
	if robotPrompt.enabled then
		local window = robotPrompt
		local blink = math.floor(math.sin(gameTime*15)/2 + 1) == 1
		window:draw()
		g.setColor(255, 255, 255)
		g.setStencil(window:stencil())
		g.printf('Load Robot ID', window.x, window.y + 8, window.width, 'center')
		g.printf(
			window.input .. (blink and '_' or ''),
			window.x + 16,
			window.y + 50,
			window.width
		)
		g.setStencil()
	end
	
	-- change the cursor to the red x when you wanna delete somefin
	if delete then
		love.mouse.setVisible(false)
		local img = getImage 'delete.png'
		local x, y = love.mouse.getPosition()
		x = x - img:getWidth()/2
		y = y - img:getHeight()/2
		g.setColor(255, 255, 255)
		g.draw(img, x, y)
	else
		love.mouse.setVisible(true)
	end
	
	-- draw the editor
	if editor.enabled then
		editor.draw()
	end
	
	-- 'dat console
	console.draw()
	
	-- for debugging
	local vars = {
		fps = love.timer.getFPS(),
		robots = #robots
	}
	
	local varstr = ''
	for k, v in pairs(vars) do
		varstr = varstr..k..': '..tostring(v)..'\n'
	end
	
	shadowText(varstr, 10, 10, 255, 255, 255)
end

function gameplay.quit()
	robots.quit()
end

return gameplay
