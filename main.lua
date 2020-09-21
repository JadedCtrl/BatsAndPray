animx  = require "lib/animx"
class  = require "lib/middleclass"

----------------------------------------
-- CONSTANTS
----------------------------------------
left = 1;  right = 2;  up = 10;  down = 20
upleft = 11; downleft = 21; upright = 12; downright = 22
mainmenu = 0; game = 1; gameover = 2; pause = 3

--------------------------------------------------------------------------------
-- GAME STATES
--------------------------------------------------------------------------------
-- LOVE
----------------------------------------
-- LOAD
--------------------
function love.load ()
	vScale = 0
	maxScore = 0
	math.randomseed(os.time())

	dieParticle = nil
	love.graphics.setDefaultFilter("nearest", "nearest", 0)
	a_ttf = love.graphics.newFont("art/font/alagard.ttf", nil, "none")
	bg = love.graphics.newImage("art/bg/sky.png")
	bgm = nil
	flapSfx = love.audio.newSource( "art/sfx/flap.wav", "static")
	cpuFlapSfx = love.audio.newSource( "art/sfx/cpuflap.wav", "static")
	bounceSfx = love.audio.newSource( "art/sfx/bounce.wav", "static")
	waveSfx = love.audio.newSource( "art/sfx/wave.wav", "static")

	lifeText = love.graphics.newText(a_ttf, "Press Enter")
	waveText = love.graphics.newText(a_ttf, "")
	bigText  = love.graphics.newText(a_ttf, "Bats & Pray")
	frontMenu = nil

	-- for compliance with Statute 43.5 (2019); all birds must report births to local Officials
	birdRegistry = {}
	mainmenu_load()
end

--------------------
-- UPDATE
--------------------
function love.update ( dt )
	if ( mode == mainmenu ) then
		mainmenu_update( dt )
	elseif ( mode == game ) then
		game_update( dt )
	elseif ( mode == gameover ) then
		gameover_update( dt )
	elseif ( mode == pause ) then
		pause_update( dt )
	end
end

--------------------
-- DRAW 
--------------------
function love.draw ()
	if ( vScale > 0 ) then
		love.graphics.scale( vScale, vScale )
	end
	love.graphics.draw(bg, 0, 0)
	love.graphics.draw(bg, 512, 0)

	love.graphics.draw(waveText, 200, 340, 0, 2, 2)
	love.graphics.draw(lifeText, 125, 355, 0, 1.3, 1.3)
	love.graphics.draw(bigText, 300, 300, 0, 3.5, 3.5)

	if ( mode == mainmenu ) then
		mainmenu_draw()
	elseif ( mode == game ) then
		game_draw()
	elseif ( mode == gameover ) then
		gameover_draw()
	elseif ( mode == pause ) then
		pause_draw()
	end
end

function love.resize ( width, height )
	vScale = height / 600
end

----------------------------------------
-- INPUT
----------------------------------------
function love.keypressed ( key )
	if ( mode == mainmenu ) then
		mainmenu_keypressed( key )
	elseif ( mode == game ) then
		game_keypressed( key )
	elseif ( mode == gameover ) then
		gameover_keypressed( key )
	elseif ( mode == pause ) then
		pause_keypressed( key )
	end
end

function love.keyreleased (key)
	if ( mode == mainmenu ) then
		mainmenu_keyreleased( key )
	elseif ( mode == game ) then
		game_keyreleased( key )
	elseif ( mode == gameover ) then
		gameover_keyreleased( key )
	elseif ( mode == pause ) then
		pause_keyreleased( key )
	end
end


----------------------------------------
-- MENU
----------------------------------------
-- LOAD
--------------------
function mainmenu_load ()
	mode = mainmenu
	selection = 1
	dieParticle = nil
	waveText:set("[Enter]")
	lifeText:set("")
	bigText:set("Bats & Pray")
	helpScreen = false

	if ( bgm ) then
		bgm:stop()
	end
	if ( bgm ) then
		bgm:stop()
	end
	bgm = love.audio.newSource( "art/music/menu.ogg", "static")
	bgm:play()
	bgm:setLooping( true )
	bgm:setVolume( 1.5 )

	p_over = nil; p_under = nil; p_bounce = nil; p_dash = nil; p_block = nil; p_bg = nil
	helpOver = nil; helpBounce = nil; helpDash = nil; helpBlock = nil
	helpScreen_setup()

	frontMenu = Menu:new( 100, 100, 30, 50, 2, 
			      { { love.graphics.newText(a_ttf, "Play Game"),
				  function () game_load() end },
				{ love.graphics.newText(a_ttf, "Help"),
				  function () helpScreen = true end },
				{ love.graphics.newText(a_ttf, "Quit"),
				  function () love.event.quit( 0 ) end } } )
end

--------------------
-- UPDATE
--------------------
function mainmenu_update ( dt )
end

--------------------
-- DRAW
--------------------
function mainmenu_draw ()
	if ( helpScreen == true ) then
		helpScreen_draw()
	elseif ( frontMenu ) then
		frontMenu:draw()
	end
end

--------------------
-- INPUT
--------------------
function mainmenu_keypressed ( key )
	if ( helpScreen == true) then
		helpScreen = false
	else
		frontMenu:keypressed( key )
	end
end

function mainmenu_keyreleased ( key )
	frontMenu:keyreleased( key )
end

--------------------
-- HELP SCREEN
--------------------

function helpScreen_setup ()
	p_over = love.graphics.newImage("art/sprites/p-over.png")
	p_under = love.graphics.newImage("art/sprites/p-under.png")
	p_bounce = love.graphics.newImage("art/sprites/p-bounce.png")
	p_dash = love.graphics.newImage("art/sprites/p-dash.png")
	p_block = love.graphics.newImage("art/sprites/p-block.png")
	p_block = love.graphics.newImage("art/sprites/p-block.png")
	h_bg = love.graphics.newImage("art/bg/help.png")

	helpOver = love.graphics.newText(a_ttf, "He on top, wins.")
	helpBounce = love.graphics.newText(a_ttf, "Meet equals,\npart equals.")
	helpBlock = love.graphics.newText(a_ttf, "Guard yourself.")
	helpDash = love.graphics.newText(a_ttf, "Move with\n   grace.")

	helpLuck = love.graphics.newText(a_ttf, "Godspeed!")
	helpControls = love.graphics.newText(a_ttf, "Arrows - Point   Space - Flap   A/Z - Dash   S/X - Block")
end

function helpScreen_draw ()
	love.graphics.draw(h_bg)
	love.graphics.draw(p_over, 100, 50, 0, 1.5, 1.5)
	love.graphics.draw(p_under, 535, 50, 0, 1.5, 1.5)
	love.graphics.draw(helpOver, 285, 110, 0, 2.3)

	love.graphics.draw(p_bounce, 50, 200, 0, 1.5, 1.5)
	love.graphics.draw(helpBounce, 225, 250, 0, 2)

	love.graphics.draw(p_dash, 585, 200, 0, 1.5, 1.5)
	love.graphics.draw(helpDash, 440, 250, 0, 2)

	love.graphics.draw(p_block, 320, 350, 0, 1.5, 1.5)
	love.graphics.draw(helpBlock, 120, 420, 0, 2)
	love.graphics.draw(helpLuck, 500, 420, 0, 2)
	love.graphics.draw(helpControls, 205, 550, 0, 1.2)
end


----------------------------------------
-- PAUSE
----------------------------------------
-- LOAD
--------------------
function pause_load ()
	mode = pause
	waveText:set("[Enter]")
	lifeText:set("")
	bigText:set("Paused")

	love.audio.pause()
	sfx = love.audio.newSource( "art/sfx/pause.wav", "static")
	sfx:play()
end

--------------------
-- UPDATE
--------------------
function pause_update ( dt )
end

--------------------
-- DRAW
--------------------
function pause_draw ()
end

--------------------
-- INPUT
--------------------
function pause_keypressed ( key )
	if ( key == "return"  or  key == "a" ) then
		sfx:stop()
		sfx:play()
		unpauseGame()
	elseif ( key == "escape" ) then
		mainmenu_load()
	end
end

function pause_keyreleased ( key )
end


----------------------------------------
-- GAMEOVER
----------------------------------------
-- LOAD
--------------------
function gameover_load ()
	mode = gameover
	dieParticle = nil
	lifeText:set("Best " .. maxScore)
	bigText:set("Game Over")
	bgm:stop()
	bgm = love.audio.newSource( "art/music/gameover.ogg", "static")
	bgm:play()

end

--------------------
-- UPDATE
--------------------
function gameover_update ( dt )
end

--------------------
-- DRAW
--------------------
function gameover_draw ()
	game_draw()
end

--------------------
-- INPUT
--------------------
function gameover_keypressed ( key )
	if ( key == "return"  or  key == "escape" ) then
		mainmenu_load()
	end
end

function gameover_keyreleased ( key )
end


----------------------------------------
-- GAME
----------------------------------------
-- LOAD
--------------------
function game_load ()
	mode = game
	lives = 4
	wave = 0
	waveText:set( "Wave " .. wave )
	lifeText:set( "Lives " .. lives )
	bigText:set( "" )

	player = Bat:new()
	birdRegistry = {}

	-- death particles
	diePArt = love.graphics.newImage("art/sprites/heart.png")
	dieParticle = love.graphics.newParticleSystem(diePArt, 30)
	dieParticle:setParticleLifetime(.5) -- Particles live at least 2s and at most 5s.
	dieParticle:setSizeVariation(1); dieParticle:setEmissionRate(0)
	dieParticle:setLinearAcceleration(-200, -200, 200, 200) -- Random movement in all directions.
	dieParticle:setSpeed(40, 50); dieParticle:setColors(1, 1, 1, 1, 1, 1, 1, 0) 

--	bgm = love.audio.newSource( "art/music/game.ogg", "static")
--	bgm:play()
end

--------------------
-- UPDATE
--------------------
function game_update ( dt )
	bird_n = table.maxn( birdRegistry )
	dieParticle:update ( dt )

	if ( bird_n == 0 ) then
		nextWave()
	end

	for i = 1,bird_n do
		if ( false == birdRegistry[i]:update( dt ) ) then
			break
		end
	end

	player:update( dt )
	animx.update(dt)
end

--------------------
-- DRAW
--------------------
function game_draw ()
	for i = 1,table.maxn(birdRegistry) do
		birdRegistry[i]:draw()
	end
	player:draw()

	if ( dieParticle ) then
		love.graphics.draw(dieParticle)
	end
end

--------------------
-- INPUT
--------------------
function game_keypressed ( key )
	if ( key == "right" ) then
		player.moving = true
		player.direction = right
		player.pointing = setRight( player.pointing )
	elseif ( key == "left" ) then
		player.moving = true
		player.direction = left
		player.pointing = setLeft( player.pointing )
	elseif ( key == "up" ) then
		player.pointing = setUp( player.pointing )
	elseif ( key == "down" ) then
		player.pointing = setDown( player.pointing )
	elseif ( key == "space" ) then
		player.flying = 2
	elseif ( key == "a"  or  key == "z" ) then
		player:dash()
	elseif ( key == "escape" ) then
		pause_load()
	end
end

function game_keyreleased (key)
	if ( key == "right"  and  player.direction == right ) then
		if ( love.keyboard.isDown("left") ) then
			player.direction = left
		else
			player.moving = false
		end
		player.pointing = unsetRight( player.pointing )
	elseif ( key == "left"  and  player.direction == left ) then
		if ( love.keyboard.isDown("right") ) then
			player.direction = right
		else
			player.moving = false
		end
		player.pointing = unsetLeft( player.pointing )
	elseif ( key == "up" ) then
		player.pointing = unsetUp( player.pointing )
	elseif ( key == "down" ) then
		player.pointing = unsetDown( player.pointing )
	end
end



--------------------------------------------------------------------------------
-- ENTITY CLASSES
--------------------------------------------------------------------------------
-- FLIER	entity superclass
----------------------------------------
-- birds and bats both fly. fliers.
Flier = class('Flier')

function Flier:initialize ( x, y, actor )
	self.x = x
	self.y = y
	self.y_vel = 0
	self.x_vel = 0
	self.pointing = right
	self.moving = false
	self.flying = 0
	self.dashTime = 0
	self.actor = actor
	self.living = true
end

-- generic flier update: physics
function Flier:update ( dt )
	self:physics( dt )
	if ( self.dashTime > 0 ) then
		self.dashTime = self.dashTime - dt
	end
end

-- drawing the flier (ofc)
function Flier:draw ( )
	if ( self.living == false ) then
		self.actor:switch('die')
	elseif ( self.flying > 0 ) then
		self.actor:switch('flap')
		self.actor:getAnimation():restart()
		self.flying = self.flying - 1
	end
	if ( self.direction == right ) then
		self.actor:flipX(true)
	elseif (self.direction == left) then
		self.actor:flipX(false)
	end
	self.actor:draw( self.x, self.y )
end

--------------------
-- "physics"
--------------------
function Flier:physics ( dt )
	gravity = 1
	floor = 500
	ceiling = 0
	max_vel = 300
	min_vel = -300
	turn = 150

	if ( self.living ) then
		self:physics_x( dt )
		self:physics_y( dt )
		return true
	else
		return self:physics_dead( dt )
	end
end

-- physics on the x-axis
function Flier:physics_x ( dt )
	if ( self.species ) then -- if bird
		max_vel = 280
		min_vel = -280
	end

	-- holding arrow-key
	if ( self.moving ) then
	 	if ( self.x_vel < max_vel and self.direction == right ) then
			self.x_vel = self.x_vel + (max_vel / turn)
	 	elseif ( self.x_vel > min_vel and self.direction == left ) then
			self.x_vel = self.x_vel - (max_vel / turn)
		end
	else
		if ( self.x_vel > 0 ) then
			self.x_vel = self.x_vel - (max_vel / (turn * 3))
		elseif ( self.x_vel < 0 ) then
			self.x_vel = self.x_vel + (max_vel / (turn * 3))
		end
	end

	if ( self.x_vel >= max_vel ) then
		self.x_vel = self.x_vel - (max_vel / (turn * 3))
	elseif ( self.x_vel <= min_vel ) then
		self.x_vel = self.x_vel + (max_vel / (turn * 3))
	end

	if ( self.x < -5 ) then
		self.x = 800
	elseif ( self.x > 805 ) then
		self.x = 0
	end

	self.x = self.x + self.x_vel * dt
end

-- physics on the y-axis
function Flier:physics_y ( dt )
	-- wing-flap
	if ( self.flying > 0 ) then
		self.y_vel = -200
		self.flying = self.flying - 1
		if ( self.species ) then
			love.audio.play(cpuFlapSfx)
		else
			flapSfx:stop()
			flapSfx:play()
		end
	end
	-- gravity 
	if ( self.y < floor ) then
		self.y_vel = self.y_vel + gravity
	end

	-- atmosphere (ceiling)
	if ( self.y < ceiling ) then
		self.y_vel = self.y_vel * -1
		self.y = ceiling + 1
	end

	-- too speedy
	if ( self.y_vel >= max_vel ) then
		self.y_vel = self.y_vel - (max_vel / (turn * 3))
	elseif ( self.x_vel <= min_vel ) then
		self.y_vel = self.y_vel + (max_vel / (turn * 3))
	end

	-- if on ground; flap your wings
	if ( self.y > floor ) then
		self.y = floor
		self.flying = 2
	end

	self.y = self.y + self.y_vel * dt
end

-- if not living; in death-spiral
function Flier:physics_dead ( dt )
	-- ignore all input, fall through bottom
	gravity = 2

	if ( self.x_vel > 0 ) then
		self.x_vel = self.x_vel - (max_vel / (turn * 3))
	elseif ( self.x_vel < 0 ) then
		self.x_vel = self.x_vel + (max_vel / (turn * 3))
	end

	if ( self.x < -10 ) then
		self.x = 800
	elseif ( self.x > 810 ) then
		self.x = 0
	end

	self.y_vel = self.y_vel + gravity
	self.y = self.y + self.y_vel * dt
	self.x = self.x + self.x_vel * dt

	if ( self.y > 700 ) then
		self:killFinalize()
		return false
	else
		return true
	end
end

function Flier:dash ()
	if ( self.dashTime > 0 ) then
		return
	end
	self.dashTime = 1

	if ( isUp(self.pointing) ) then
		self.y_vel = max_vel * -1.5
	elseif ( isDown(self.pointing) ) then
		self.y_vel = max_vel * 1.5
	end

	if ( isRight(self.pointing) ) then
		self.x_vel = max_vel * 2
	elseif ( isLeft(self.pointing) ) then
		self.x_vel = max_vel * -2
	end
end

-- kill the Flier, show cool particles
function Flier:kill ( murderer )
	self.living = false
	if ( murderer ) then
		self.x_vel = murderer.x_vel
	end

	dieParticle:moveTo( self.x, self.y )
	dieParticle:emit( 30 )

	if ( self.species ) then
		sfx = love.audio.newSource( "art/sfx/fall.wav", "static")
	else
		sfx = love.audio.newSource( "art/sfx/lose.wav", "static")
	end
	sfx:play()
end

-- run after Flier falls through screen
function Flier:killFinalize ()
end



----------------------------------------
-- BAT  	player characters
----------------------------------------
Bat = class('Bat', Flier)

function Bat:initialize ()
	-- animations
	batSheet = love.graphics.newImage("art/sprites/bat.png")

	batFlapAnim = animx.newAnimation{
		img = batSheet, tileWidth = 32, frames = {2,3,4,5}
	}:onAnimOver( function()
		self.actor:switch('idle')
	end )
	batIdleAnim = animx.newAnimation {
		img = batSheet, tileWidth = 32, frames = {1}
	}
	batDieAnim = animx.newAnimation {
		img = batSheet, tileWidth = 32, frames = {6}
	}
	batBlockAnim = animx.newAnimation {
		img = batSheet, tileWidth = 32, frames = {7}
	}

	batActor = animx.newActor {
		['idle'] = batIdleAnim, ['flap'] = batFlapAnim, ['die'] = batDieAnim
	}:switch('idle')

	Flier.initialize( self, 50, 100, batActor )
end

function Bat:update ( dt )
	self:physics( dt )
	self:checkBirdCollisions()
	if ( self.dashTime > 0 ) then
		self.dashTime = self.dashTime - dt
	end
end


-- return whether or not the Bat's colliding with given object
function Bat:checkCollision ( other )
	if ( colliding( self, other ) )  then
		return true
	else
		return false
	end
end

-- check collisions with every bird
function Bat:checkBirdCollisions ()
	for i = 1,table.maxn( birdRegistry ) do
		if ( self:checkCollision(birdRegistry[i]) ) then
			judgeCollision( self, birdRegistry[i] )
			return birdRegistry[i]
		end
	end
	return nil
end


-- called after dead Bat falls through screen
function Bat:killFinalize()
	lives = lives - 1
	lifeText:set("Life " .. lives)

	if ( lives <= 0 ) then
		gameover_load()
	else
		self.y = -5
		self.x = 300
		self.living = true
	end
end



----------------------------------------
-- BIRD  	enemy characters
----------------------------------------
Bird = class('Bird', Flier)

function Bird:initialize ( x, y )
	self.species = math.random(1,3)

	-- animations
	birdSheet = love.graphics.newImage("art/sprites/bird.png")
	flapFrames  = { {2,3,4,5}, {9,10,11,12}, {16,17,18,19} }
	idleFrames  = { {1}, {8}, {15} }
	dieFrames   = { {6}, {13}, {20} }
	blockFrames = { {7}, {14}, {21} }

	birdFlapAnim = animx.newAnimation{
		img = birdSheet, tileWidth = 32, tileHeight = 32, frames = flapFrames[self.species]
	}:onAnimOver( function()
		self.actor:switch('idle')
	end )

	birdIdleAnim = animx.newAnimation {
		img = birdSheet, tileWidth = 32, tileHeight = 32, frames = idleFrames[self.species]
	}

	birdDieAnim = animx.newAnimation {
		img = birdSheet, tileWidth = 32, tileHeight = 32, frames = dieFrames[self.species]
	}

	birdBlockAnim = animx.newAnimation {
		img = birdSheet, tileWidth = 32, tileHeight = 32, frames = blockFrames[self.species]
	}

	birdActor = animx.newActor {
		['idle'] = birdIdleAnim, ['flap'] = birdFlapAnim, ['die'] = birdDieAnim,
		['block'] = birdBlockAnim
	}:switch('idle')

	self.actor = birdActor


	if ( self.species == 3 ) then
		self.direction = math.random(left, right)
	else
		self.direction = right
	end

	Flier.initialize( self, x, y, birdActor )
end

function Bird:update ( dt )
	self:destiny()
	if ( self.dashTime > 0 ) then
		self.dashTime = self.dashTime - dt
	end
	return self:physics( dt )
end


-- basic "ai" (determines where the bird should go)
function Bird:destiny ()
	self:destiny_x()
	self:destiny_y()
end

-- "ai" on x-axis of species 1
function Bird:destiny_x ()
	if ( self.species == 1 ) then
		-- fly around the screen, left to right, right to left
		if ( self.x > 450 ) then
			self.direction = left
		elseif ( self.x < 250 ) then
			self.direction = right
		end
	elseif ( self.species == 2 ) then
		-- follow the player bat
		if ( self.x > player.x + 25  and  math.random(0,50) == 25 ) then
			self.direction = left
		elseif ( self.x < player.x - 25  and  math.random(0,50) == 25 ) then
			self.direction = right
		end
	end
		
	self.moving = true
end

-- "ai" on y-axis of species 1
function Bird:destiny_y ()
	if ( self.y > player.y + 50  and  math.random(0,100) == 25 ) then
		self.flying = 2
	end
end


-- after dead bird falls through screen
function Bird:killFinalize()
	index = indexOf(birdRegistry, self)
	table.remove( birdRegistry, index )
end



--------------------------------------------------------------------------------
-- MENUS  	blah blah blah
--------------------------------------------------------------------------------
Menu = class("Menu")

function Menu:initialize( x, y, offset_x, offset_y, scale, menuItems )
	self.x = x; self.y = y
	self.offset_x = offset_x; self.offset_y = offset_y
	self.scale = scale
	self.options = menuItems
	self.selected = 1
	self.enter = false
	self.up = false
	self.down = false
end

function Menu:draw ( )
	for i = 1,table.maxn(self.options) do
		this_y = self.y + ( self.offset_y * i )

		love.graphics.draw( self.options[i][1],
				    self.x, this_y, 0, self.scale, self.scale )
		if ( i == self.selected ) then
			love.graphics.draw( love.graphics.newText(a_ttf, ">>"),
					    self.x - self.offset_x, this_y, 0,
					    self.scale, self.scale)
		end
	end
end

function Menu:keypressed ( key )
	maxn = table.maxn( self.options )

	if ( key == "return"  and  self.enter == false ) then
		self.enter = true
		if ( self.options[self.selected][2] ) then
			self.options[self.selected][2]()
		end
	elseif ( key == "up"  and  self.selected > 1  and  self.up == false ) then
		self.up = true
		self.selected = self.selected - 1
	elseif ( key == "up"  and  self.up == false ) then
		self.up = true
		self.selected = maxn
	elseif ( key == "down" and self.selected < maxn  and  self.down == false ) then
		self.down = true
		self.selected = self.selected + 1
	elseif ( key == "down" and  self.down == false ) then
		self.down = true
		self.selected = 1
	end
end

function Menu:keyreleased ( key )
	if ( key == "return" ) then
		self.enter = false
	elseif ( key == "up" ) then
		self.up = false
	elseif ( key == "down" ) then
		self.down = false
	end
end



--------------------------------------------------------------------------------
-- MISC GAME LOGIC
--------------------------------------------------------------------------------
-- set up a new wave of birds
function nextWave ( )
	wave = wave + 1
	waveText:set("Wave " .. wave)
	if ( wave > maxScore) then
		maxScore = wave
	end

	love.audio.play(waveSfx)

	bird_n = wave * 3
	
	for i = 1,bird_n do
		if ( i % 2 == 0 ) then
			birdRegistry[i] = Bird:new( math.random(-20, 0), math.random(0, 600) )
		else
			birdRegistry[i] = Bird:new( math.random(800, 820), math.random(0, 600) )
		end
	end
end

-- assuming a and b are colliding, act accordingly
-- aka, bounce-back or kill one
function judgeCollision ( a, b )
	if ( a.y < b.y - 9  and  ( b.living )  and  ( a.living  or  a.class() == "Bat" ) ) then
		b:kill( a )
	elseif ( a.y > b.y + 9  and  ( a.living )  and  ( b.living  or  a.class() == "Bat" ) ) then
		a:kill( b )
	elseif (  a.living  and  b.living  ) then
		if ( a.x_vel > 300  or  a.x_vel < -300 ) then
			a.kill( b )
		elseif ( b.x_vel > 300  or  b.x_vel < -300 ) then
			b.kill( a )
		else
			a.x_vel = a.x_vel * -1
			b.x_vel = b.x_vel * -1
		end
		bounceSfx:stop()
		bounceSfx:play()
	end
end

function pauseGame ()
	pause_load()
end

function unpauseGame ()
	mode = game
	love.audio.play(bgm)
	waveText:set( "Wave " .. wave )
	lifeText:set( "Lives " .. lives )
	bigText:set( "" )
end






--------------------------------------------------------------------------------
-- UTIL  	blah blah blah
--------------------------------------------------------------------------------
-- return whether or not two objects are colliding/overlapping
function colliding ( a, b )
	if ( inRange(a.x, b.x - 16, b.x + 16) and  inRange(a.y, b.y + -16, b.y + 16) ) then
		return true
	else
		return false
	end
end

-- return whether or not 'a' is within range 
function inRange ( a, min, max )
	if ( min < a  and  a < max ) then
		return true
	else
		return false
	end
end

-- return the num with greatest absolute value
function greatestAbs ( a, b )
	if ( abs(a) > abs(b) ) then
		return a
	else
		return b

	end
end

-- return index of given item in list
function indexOf ( list, item )
	for i = 1,table.maxn(list) do
		if ( list[i] == item ) then
			return i
		end
	end
	return 0
end

--------------------
-- RIDICULOUS DIRECTION FUNCTIONS
--------------------
-- idk if Lua has macros, if it does, that'd be *WAY* better than this shit

function isRight ( direction )
	return ( direction == 2  or  direction == 12  or  direction == 22 )
end

function isLeft ( direction )
	return ( direction == 1  or  direction == 11  or  direction == 21 )
end

function isUp ( direction )
	return ( 10 <= direction  and  direction < 20 )
end

function isDown ( direction )
	return ( 20 <= direction  and  direction < 30 )
end

function setLeft ( direction )
	if ( isLeft(direction) ) then
		return direction
	elseif ( isRight(direction) ) then
		return direction - 1
	else
		return direction + 1
	end
end

function unsetLeft ( direction )
	if ( isLeft(direction ) ) then
		return direction - left
	else
		return direction
	end
end
		
function setRight ( direction )
	if ( isRight(direction) ) then
		return direction
	elseif ( isLeft(direction) ) then
		return direction + 1
	else
		return direction + 2
	end
end

function unsetRight ( direction )
	if ( isRight(direction ) ) then
		return direction - right
	else
		return direction
	end
end

function setUp ( direction )
	if ( isUp(direction) == true ) then
		return direction
	elseif ( isDown(direction) == true ) then
		return direction - 10
	else
		return direction + up
	end
end

function unsetUp ( direction )
	if ( isUp(direction ) ) then
		return direction - up
	else
		return direction
	end
end

function setDown ( direction )
	if ( isDown(direction) ) then
		return direction
	elseif ( isUp(direction) ) then
		return direction + 10
	else
		return direction + down
	end
end

function unsetDown ( direction )
	if ( isDown( direction ) ) then
		return direction - down
	else
		return direction
	end
end
