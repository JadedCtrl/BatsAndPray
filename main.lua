animx  = require "lib/animx"
class  = require "lib/middleclass"

----------------------------------------
-- CONSTANTS
----------------------------------------
left = 0;  right = 1;  up = 2;  down = 3
upleft = 4; downleft = 5; upright = 6; downright = 7
menu = 0; game = 1; gameover = 2


----------------------------------------
-- LOVE
----------------------------------------
-- LOAD
--------------------
function love.load ()
	mode = menu
	vScale = 0
	maxScore = 0

	psystem = nil
	love.graphics.setDefaultFilter("nearest", "nearest", 0)
	bg = love.graphics.newImage("art/bg/sky.png")
	a_ttf = love.graphics.newFont("art/font/alagard.ttf")

	lifeText = love.graphics.newText(a_ttf, "Press Enter")
	waveText = love.graphics.newText(a_ttf, "")
	bigText  = love.graphics.newText(a_ttf, "Bats & Pray")

	-- for compliance with Statute 43.5 (2019); all birds must report births to local Officials
	birdRegistry = {}
end

--------------------
-- UPDATE
--------------------
function love.update ( dt )
	if ( mode == menu ) then
		menu_update( dt )
	elseif ( mode == game ) then
		game_update( dt )
	elseif ( mode == gameover ) then
		gameover_update( dt )
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

	love.graphics.draw(waveText, 200, 220, 0, 2, 2)
	love.graphics.draw(lifeText, 125, 225, 0, 1.3, 1.3)
	love.graphics.draw(bigText, 300, 200, 0, 3.5, 3.5)

	if ( mode == menu ) then
		menu_draw()
	elseif ( mode == game ) then
		game_draw()
	elseif ( mode == gameover ) then
		gameover_draw()
	end
end

function love.resize ( width, height )
	vScale = height / 600
end

----------------------------------------
-- INPUT
----------------------------------------
function love.keypressed ( key )
	if ( mode == menu ) then
		menu_keypressed( key )
	elseif ( mode == game ) then
		game_keypressed( key )
	elseif ( mode == gameover ) then
		gameover_keypressed( key )
	end
end

function love.keyreleased (key)
	if ( mode == menu ) then
		menu_keyreleased( key )
	elseif ( mode == game ) then
		game_keyreleased( key )
	elseif ( mode == gameover ) then
		gameover_keyreleased( key )
	end
end


----------------------------------------
-- MENU
----------------------------------------
-- LOAD
--------------------
function menu_load ()
	mode = menu
	psystem = nil
	waveText:set("[Enter]")
	lifeText:set("")
	bigText:set("Bats & Pray")
end

--------------------
-- UPDATE
--------------------
function menu_update ( dt )
end

--------------------
-- DRAW
--------------------
function menu_draw ()
end

--------------------
-- INPUT
--------------------
function menu_keypressed ( key )
--	if ( key == "enter" ) then
		game_load()
--	end
end

function menu_keyreleased ( key )
end


----------------------------------------
-- GAMEOVER
----------------------------------------
-- LOAD
--------------------
function gameover_load ()
	mode = gameover
	psystem = nil
	lifeText:set("High Score")
	waveText:set("  " .. maxScore)
	bigText:set("Game Over")
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
--	if ( key == "enter" ) then
		game_load()
--	end
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
	ded = love.graphics.newImage("art/sprites/particle.png")
	psystem = love.graphics.newParticleSystem(ded, 30)
	psystem:setParticleLifetime(1) -- Particles live at least 2s and at most 5s.
	psystem:setSizeVariation(1)
	psystem:setEmissionRate(0)
	psystem:setLinearAcceleration(-200, -200, 200, 200) -- Random movement in all directions.
	psystem:setSpeed(40, 50)
	psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) 
end

--------------------
-- UPDATE
--------------------
function game_update ( dt )
	bird_n = table.maxn( birdRegistry )
	psystem:update ( dt )

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

	if ( psystem ) then
		love.graphics.draw(psystem)
	end
end

--------------------
-- INPUT
--------------------
function game_keypressed ( key )
	if ( key == "right" ) then
		player.moving = true
		player.direction = right
	elseif ( key == "left" ) then
		player.moving = true
		player.direction = left
	elseif ( key == "space" ) then
		player.flying = 2
	elseif ( key == "escape" ) then
		gameover_load()
	end
end

function game_keyreleased (key)
	if ( key == "right"  and  player.direction == right ) then
		if ( love.keyboard.isDown("left") ) then
			player.direction = left
		else
			player.moving = false
		end
	elseif ( key == "left"  and  player.direction == left ) then
		if ( love.keyboard.isDown("right") ) then
			player.direction = right
		else
			player.moving = false
		end
	end
end


----------------------------------------
-- FLIER	entity superclass
----------------------------------------
-- birds and bats both fly. fliers.
Flier = class('Flier')

function Flier:initialize ( x, y, actor )
	self.x = x
	self.y = y
	self.y_vel = 0
	self.x_vel = 0
	self.moving = false
	self.flying = 0
	self.actor = actor
	self.living = true
end

-- generic flier update: physics
function Flier:update ( dt )
	self:physics( dt )
end

-- drawing the flier (ofc)
function Flier:draw ( )
	if ( self.flying > 0 ) then
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
	max_vel = 300
	min_vel = -300
	turn = 150

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

	if ( self.x < -10 ) then
		self.x = 800
	elseif ( self.x > 810 ) then
		self.x = 0
	end

	self.x = self.x + self.x_vel * dt
end

-- physics on the y-axis
function Flier:physics_y ( dt )
	gravity = 1
	floor = 500

	-- wing-flap
	if ( self.flying > 0 ) then
		self.y_vel = -200
		self.flying = self.flying - 1
	end

	-- gravity 
	if ( self.y < floor ) then
		self.y_vel = self.y_vel + gravity
	end

	-- if on ground; flap your wings
	if ( self.y > floor ) then
		self.y = floor
		self.flying = 2
	end

	self.y = self.y + self.y_vel * dt
end

function Flier:physics_dead ( dt )
	-- ignore all input, fall through bottom
	gravity = 2
	self.y_vel = self.y_vel + gravity
	self.y = self.y + self.y_vel * dt
	if ( self.y > 610 ) then
		self:killFinalize()
		return false
	else
		return true
	end
end



----------------------------------------
-- BAT  	player characters
----------------------------------------
Bat = class('Bat', Flier)

function Bat:initialize ()
	-- animations
	batSheet = love.graphics.newImage("art/sprites/bat.png")

	batFlapAnim = animx.newAnimation{
		img = batSheet,
		tileWidth = 32,
		frames = { 2, 3, 4, 5 }
	}:onAnimOver( function()
		player.actor:switch('idle')
	end )

	batIdleAnim = animx.newAnimation {
		img = batSheet,
		tileWidth = 32,
		frames = { 1 }
	}

	batActor = animx.newActor {
		['idle'] = batIdleAnim,
		['flap'] = batFlapAnim
	}:switch('idle')

	Flier.initialize( self, 50, 100, batActor )
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

function Bat:update ( dt )
	self:physics( dt )
	self:checkBirdCollisions()
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

function Bat:kill ()
	self.living = false
	psystem:moveTo(self.x, self.y)
	psystem:emit(30)
end

----------------------------------------
-- BIRD  	enemy characters
----------------------------------------
Bird = class('Bird', Flier)

function Bird:initialize ( x, y )
	-- animations

	self.species = math.random(2,3)

	if ( self.species == 3 ) then
		flapFrames = { 2, 3, 4, 5 }
		idleFrames = { 1 }
	elseif ( self.species == 2  or  self.species == 3 ) then
		flapFrames = { 7, 8, 9, 10 }
		idleFrames = { 6 }
	end
	if ( self.species == 3 ) then
		self.direction = math.random(left, right)
	else
		self.direction = right
	end

	birdSheet = love.graphics.newImage("art/sprites/bird.png")
	birdFlapAnim = animx.newAnimation{
		img = birdSheet,
		tileWidth = 32,
		tileHeight = 32,
		frames = flapFrames
	}:onAnimOver( function()
		self.actor:switch('idle')
	end )

	birdIdleAnim = animx.newAnimation {
		img = birdSheet,
		tileWidth = 32,
		tileHeight = 32,
		frames = idleFrames
	}

	birdActor = animx.newActor {
		['idle'] = birdIdleAnim,
		['flap'] = birdFlapAnim
	}:switch('idle')

	Flier.initialize( self, x, y, birdActor )
end

function Bird:update ( dt )
	self:destiny()
	return self:physics( dt )
end

function Bird:killFinalize()
	index = indexOf(birdRegistry, self)
	table.remove( birdRegistry, index )
end
	
function Bird:kill ()
	self.living = false
	psystem:moveTo(self.x, self.y)
	psystem:emit(30)
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


----------------------------------------
-- GAME LOGIC
----------------------------------------
function nextWave ( )
	wave = wave + 1
	waveText:set("Wave " .. wave)
	if ( wave > maxScore) then
		maxScore = wave
	end

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
	if ( a.y < b.y - 5  and  a.living ) then
		b:kill()
	elseif ( a.y > b.y + 5  and  b.living ) then
		a:kill()
	else
		a.x_vel = a.x_vel * -1
		b.x_vel = b.x_vel * -1
	end
end
	
	


----------------------------------------
-- UTIL  	blah blah blah
----------------------------------------
-- return whether or not two objects are colliding/overlapping
function colliding ( a, b )
	if ( inRange(a.x, b.x - 16, b.x + 16)  and  inRange(a.y, b.y - 16, b.y + 16) ) then
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

function indexOf ( list, item )
	for i = 1,table.maxn(list) do
		if ( list[i] == item ) then
			return i
		end
	end
	return 0
end
