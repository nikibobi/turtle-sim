-- robots.lua
-- Author: Kingdaro

local robots = {}
local zoffset = 8
local savepath = 'robots/'

function robots.init()
	robots.def = {
		type = 'robot';
		-- defaults
		id = 1;
		dir = 4;
		showDir = 0;
		
		busy = false;
		
		-- images for each direction
		dirImg = {
			'robot-topright.png',
			'robot-topleft.png',
			'robot-bottomleft.png',
			'robot-bottomright.png'
		};
		arrowImg = {
			'arrow-topright.png',
			'arrow-topleft.png',
			'arrow-bottomleft.png',
			'arrow-bottomright.png'
		};
		
		-- movement stuff
		move = function(self, x, y, z)
			if self.busy then return end
			z = z or 0
			
			local newx = self.x + x
			local newy = self.y + y
			local newz = self.z + z
			
			if objects.checkSpace(newx, newy, newz) then
				return false
			end
			
			self.busy = true
			tween(0.5, self, {x=newx, y=newy, z=newz}, 'linear', function()
				local r = function(n) return math.floor(n+0.5) end
				self.x = r(self.x)
				self.y = r(self.y)
				self.z = r(self.z)
				self.busy = false
			end)
			
			return true
		end;
		
		turn = function(self, dir)
			if self.busy then return end
			
			if dir == 'left' then
				self.dir = self.dir < 4 and self.dir + 1 or 1
			elseif dir == 'right' then
				self.dir = self.dir > 1 and self.dir - 1 or 4
			end
			self.image = getImage(self.dirImg[self.dir])
		end;
		
		inFront = function(self)
			local dx, dy
			
			do dx =
				(self.dir == 1 or self.dir == 3) and 0 or
				self.dir == 2 and -1 or
				self.dir == 4 and 1
			end
			
			do dy =
				(self.dir == 2 or self.dir == 4) and 0 or
				self.dir == 1 and 1 or
				self.dir == 3 and -1
			end
			
			return self.x + dx, self.y + dy, self.z
		end;
		
		forward = function(self)
			-- because the inFront function returns absolute coords
			-- and not relative ones
			local x, y, z = self:inFront()
			return self:move(x - self.x, y - self.y, 0)
		end;
		
		back = function(self)
			local mx, my
			
			do mx =
				(self.dir == 1 or self.dir == 3) and 0 or
				self.dir == 2 and 1 or
				self.dir == 4 and -1
			end
			
			do my =
				(self.dir == 2 or self.dir == 4) and 0 or
				self.dir == 1 and -1 or
				self.dir == 3 and 1
			end
				
			return self:move(mx, my)
		end;
		
		up = function(self)
			return self:move(0, 0, 1)
		end;
		
		down = function(self)
			if self.z > 0 then
				return self:move(0, 0, -1)
			else
				return false
			end
		end;
		
		-- return the directory for the robot's data
		saveDir = function(self)
			return savepath .. self.id
		end;
		
		-- load and return robot's code
		loadCode = function(self)
			local fs = love.filesystem
			local path = self:saveDir()..'/code'
			if fs.exists(path) then
				self.code = {}
				local codestr = fs.read(path)
				for line in codestr:gmatch('[^\n]+') do
					table.insert(self.code, line)
				end
				if #self.code == 0 then
					self.code = {''}
				end
			end
			return self.code
		end;
		
		-- saves the robot's code
		saveCode = function(self)
			local fs = love.filesystem
			local folder = self:saveDir()
			if not fs.exists(folder) then
				fs.mkdir(folder)
			end
			fs.write(folder..'/code', table.concat(self.code, '\n'))
		end;
		
		-- runs the robot's code
		exec = function(self)
			if self.routine and coroutine.status(self.routine) ~= 'dead' then
				self.routine = nil
				return
			end
			self.routine = nil
			
			local env = {
				math = math;
				print = console.print;
				write = console.write;
			}
			
			for fname, func in pairs(robotapi) do
				env[fname] = function(...) return func(self, ...) end
			end
			
			local code, err = loadstring(table.concat(self.code, '\n'), self.name)
			
			if code then
				setfenv(code, env)
				
				self.routine = coroutine.create(code)
				
				local ok, res = pcall(coroutine.resume, self.routine)
				if not ok then
					console.print(res)
				end
			else
				console.print(err)
			end
		end;
		
		draw = function(self)
			local g = love.graphics
			local sx, sy = self:screenCoords()
			local sin = math.sin 
			local hover = (sin(gameTime*3) / 2 + 0.5) * 4 + zoffset
		
			g.setColor(self.color)
			g.draw(self.image, sx, sy - hover)
			
			self.showDir = math.clamp(0, self.showDir, 1)
			if self.showDir > 0 then
				g.setColor(255, 255, 255, self.showDir*255)
				g.draw(getImage(self.arrowImg[self.dir]), sx, sy - hover)
			end
		end;
		
		drawShadow = function(self)
			local g = love.graphics
			local sx, sy = self:screenCoords()
			g.setColor(0, 0, 0, 50)
			g.draw(getImage 'robot-shadow.png', sx, sy + self.z * 32)
		end;
	}
	
	setmetatable(robots.def, {__index = objects.base})
end

function robots.new(t)
	assert(t.id, 'Please provide a valid robot ID')
	
	local fs = love.filesystem
	local name, code = 'AwesomeRobot'..t.id, {''}
	local folder = savepath..t.id
	
	if fs.exists(folder) then
		local infopath, codepath = folder..'/info', folder..'/code'
		
		if fs.exists(infopath) then
			local info = fs.read(infopath)
			
			if info then
				local ok, res = pcall(loadstring(info))
				if ok then
					name = res.name
				else
					print('Error loading info for '..t.id..': '..res)
				end
			end
		end
	end
	
	for i,v in pairs(robots.def) do
		if not t[i] then
			t[i] = v
		end
	end
	
	local new = objects.new(t)
	
	new:loadCode()
	new.name = name
	new.image = getImage(new.dirImg[new.dir])
	
	table.insert(robots, new)
	objects.add(new)
	return new
end

function robots.nearest(x, y, dist)
	dist = dist or math.huge
	for i=1, #robots do
		local robot = robots[i]
		local rx, ry = camera.resolve(robot:screenCoords())
		if math.dist(x, y, rx + 32*screenScale, ry + 32*screenScale) < dist then
			return robot
		end
	end
	return false
end

function robots.gui()
	-- draw robot names above their heads
	local g = love.graphics
	for i=1, #robots do
		local robot = robots[i]
		local sx, sy = camera.resolve(robot:screenCoords())
		local w = robot.image:getWidth()
		
		robot.nameColor[4] = 200
		shadowTextf(robot.name, sx - w, sy - 10, w*4, 'center', unpack(robot.nameColor))
	end
end

function robots.remove(robot)
	for i=1, #robots do
		if robot == robots[i] then
			table.remove(robots, i)
			return
		end
	end
end

function robots.quit()
	local fs = love.filesystem
	for i=1, #robots do
		local robot = robots[i]
		local folder = savepath..robot.id
		
		-- create robot save folder
		if not fs.exists(folder) then
			fs.mkdir(folder)
		end
		
		-- write robot info
		local str = [[return {name = %q}]]
		str = str:format(robot.name)
		fs.write(folder..'/info', str)
		
		-- write the robot code
		robot:saveCode()
	end
end

return robots