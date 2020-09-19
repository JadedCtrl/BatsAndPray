animx = require "lib/animx"
class = require "lib/middleclass"

----------------------------------------
-- LOAD
----------------------------------------
function love.load ()
	left = 0;  right = 1;  up = 2;  down = 3
	upleft = 4; downleft = 5; upright = 6; downright = 7

	player = Bat:new( )
--
	-- for compliance with Statute 43.5 (2019); all birds must report births to local Officials
	birdRegistry = {}
end

----------------------------------------
-- UPDATE
----------------------------------------
function love.update ( dt )
--	player.x = player.x + 100 * dt
	
	player:update( dt )
	animx.update(dt)
end

----------------------------------------
-- DRAW
----------------------------------------
function love.draw ()
	love.graphics.print('Hello World!', 400, 300)
	player:draw()
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
		player.flying = true
		player.actor:switch('flap')
		player.actor:getAnimation():restart()
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
-- FLIERS
----------------------------------------
-- birds and bats both fly. fliers.

Flier = class('Flier')

function Flier:initialize ( x, y, actor )
	self.x = x
	self.y = y
	self.y_vel = 0
	self.x_vel = 0
	self.moving = false
	self.flying = false
	self.actor = actor
end

-- generic flier update: physics + changing position
function Flier:update ( dt )
	self:physics( dt )
end

function Flier:draw ( )
	if ( self.direction == right ) then
		self.actor:flipX(true)
	elseif (self.direction == left) then
		self.actor:flipX(false)
	end
	self.actor:draw( self.x, self.y )
end

----------------------------------------
-- "PHYSICS"
----------------------------------------
-- "physics" being used verryyyyy lightly here

-- does basics physics work (determines velocity) for a flier
function Flier:physics ( dt )
	self:physics_x( dt )
	self:physics_y( dt )
end

function Flier:physics_x ( dt )
	max_vel = 300
	min_vel = -300
	turn = 300

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

function Flier:physics_y ( dt )
	gravity = .85
	floor = 500

	-- wing-flap
	if ( self.flying ) then
		self.y_vel = -175
		self.flying = false
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

Bat = class('Bat', Flier)

function Bat:initialize()
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
