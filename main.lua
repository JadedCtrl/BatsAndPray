animx  = require "lib/animx"
class  = require "lib/middleclass"


----------------------------------------
-- LOAD
----------------------------------------
function love.load ()
	left = 0;  right = 1;  up = 2;  down = 3
	upleft = 4; downleft = 5; upright = 6; downright = 7

	bg = love.graphics.newImage("art/bg/sky.png")

	player = Bat:new()
	birdo = Bird:new( 10, 100  )
	birdtwo = Bird:new( 600, 10 )
	birdthree = Bird:new( 500, 200)

	-- for compliance with Statute 43.5 (2019); all birds must report births to local Officials
	birdRegistry = {}
end


----------------------------------------
-- UPDATE
----------------------------------------
function love.update ( dt )
	player:update( dt )
	birdo:update( dt )
	birdtwo:update( dt )
	birdthree:update( dt )
	animx.update(dt)
end


----------------------------------------
-- DRAW
----------------------------------------
function love.draw ()
	love.graphics.draw(bg, 0, 0)
	love.graphics.draw(bg, 512, 0)
	player:draw()
	birdo:draw()
	birdtwo:draw()
	birdthree:draw()
end

function love.resize ( width, height )
end

----------------------------------------
-- INPUT
----------------------------------------
function love.keypressed ( key )
	if ( key == "right" ) then
		player.moving = true
		player.direction = right
	elseif ( key == "left" ) then
		player.moving = true
		player.direction = left
	elseif ( key == "space" ) then
		player.flying = 2
	end
end

function love.keyreleased (key)
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
	self:physics_x( dt )
	self:physics_y( dt )
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

	self.x = self.x + self.x_vel * dt
end

-- physics on the y-axis
function Flier:physics_y ( dt )
	gravity = 2
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

	-- if on ground; stop gravity
	if ( self.y > floor ) then
		self.y = floor
		self.y_vel = 0
	end

	self.y = self.y + self.y_vel * dt
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


----------------------------------------
-- BIRD  	enemy characters
----------------------------------------
Bird = class('Bird', Flier)

function Bird:initialize ( x, y )
	-- animations
	birdSheet = love.graphics.newImage("art/sprites/bat.png")

	birdFlapAnim = animx.newAnimation{
		img = birdSheet,
		tileWidth = 32,
		frames = { 2, 3, 4, 5 }
	}:onAnimOver( function()
		player.actor:switch('idle')
	end )

	birdIdleAnim = animx.newAnimation {
		img = birdSheet,
		tileWidth = 32,
		frames = { 1 }
	}

	birdActor = animx.newActor {
		['idle'] = birdIdleAnim,
		['flap'] = birdFlapAnim
	}:switch('idle')

	Flier.initialize( self, x, y, birdActor )
	self.direction=right
end

function Bird:update ( dt )
	self:destiny()
	self:physics( dt )
end

-- basic "ai" (determines where the bird should go)
function Bird:destiny ()
	self:destiny_x()
	self:destiny_y()
end

-- "ai" on x-axis
function Bird:destiny_x ()
	if ( self.x > 500 ) then
		self.direction = left
	elseif (self.x < 200) then
		self.direction = right
	end
	self.moving = true
end

-- "ai" on y-axis
function Bird:destiny_y ()
	if ( self.y > player.y  and  math.random(0,50) == 25 ) then
		self.flying = 2
	end
end
