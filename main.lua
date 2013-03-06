-- main.lua
-- Author: Kingdaro

screenScale = 2
gameTime = 0

local gamestate = {}

function setState(state, ...)
	gamestate = state
	local f = function() end;
	setmetatable(state, { __index = {
			update = f;
			draw = f;
			keypressed = f;
			mousepressed = f;
			quit = f;
		}
	})
	if state.init then
		state.init(...)
	end
end

function love.load()
	love.graphics.setCaption('TurtleSim by Kingdaro')
	love.graphics.setDefaultImageFilter('linear', 'nearest')
	love.filesystem.setIdentity('TurtleSim')
	
	_=				require 'lib.math'
	tween = 		require 'lib.tween'
	timer = 		require 'lib.hump.timer'
--	moonscript =	require 'lib.moonscript'
	
	_=				require 'image-loader'
--	_=				require 'keypressed'
	_=				require 'font-mgr'
	_=				require 'extras'
		
	gui = 			require 'gui'
	camera = 		require 'camera'
	console =		require 'console'
	objects =		require 'objects'
	robots = 		require 'robots'
	robotapi = 		require 'robotapi'
	gameplay = 		require 'gameplay'
	editor = 		require 'editor'
	
	loadImages('img/')
	console.init()
	setState(gameplay)
end

function love.update(dt)
	gameTime = gameTime + dt
	
	tween.update(dt)
	timer.update(dt)
	gamestate.update(dt)
end

function love.keypressed(...)
	gamestate.keypressed(...)
end

function love.mousepressed(...)
	gamestate.mousepressed(...)
end

function love.draw()
	gamestate.draw()
end

function love.quit()
	gamestate.quit()
end