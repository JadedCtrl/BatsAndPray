animx = require "lib/animx"

----------------------------------------
-- LOAD
----------------------------------------
function love.load ()
	left = 0;  right = 1;  up = 2;  down = 3
	upleft = 4; downleft = 5; upright = 6; downright = 7

	aBatFly = animx.newAnimation{
		img = "art/sprites/bat.png",
		sprites_per_row = 5,
		noOfFrames = 5
	}:loop()

	bat = { x = 50, y = 200,
		y_vel = 0, x_vel = 0,
		moving = false,
		flying = false,
		direction = left,
		animation = aBatFly
	}

	-- for compliance with Statute 43.5 (2019); all birds must report births to local Officials
	birdRegistry = {}
end

----------------------------------------
-- UPDATE
----------------------------------------
function love.update ( dt )
--	bat.x = bat.x + 100 * dt
	
	flier_update( bat, dt )
	animx.update(dt)
end

----------------------------------------
-- DRAW
----------------------------------------
function love.draw ()
	love.graphics.print('Hello World!', 400, 300)
	flier_draw( bat )
end


----------------------------------------
-- INPUT
----------------------------------------
function love.keypressed ( key )
	if ( key == "right" ) then
		bat.moving = true
		bat.direction = right
		aBatFly:flipX(true)
	elseif ( key == "left" ) then
		bat.moving = true
		bat.direction = left
		aBatFly:flipX(false)
	elseif ( key == "space" ) then
		bat.flying = true
	end
end

function love.keyreleased (key)
	if ( key == "right"  and  bat.direction == right ) then
		if ( love.keyboard.isDown("left") ) then
			bat.direction = left
		else
			bat.moving = false
		end
	elseif ( key == "left"  and  bat.direction == left ) then
		if ( love.keyboard.isDown("right") ) then
			bat.direction = right
		else
			bat.moving = false
		end
	end
end


----------------------------------------
-- FLIERS
----------------------------------------
-- generic flier update: physics + changing position
function flier_update ( flier, dt )
	flier_physics( flier, dt )
end

function flier_draw ( flier )
	flier.animation:draw( flier.x, flier.y )
end

----------------------------------------
-- "PHYSICS"
----------------------------------------
-- "physics" being used verryyyyy lightly here

-- does basics physics work (determines velocity) for a flier
function flier_physics ( flier, dt )
	flier_physics_x( flier, dt )
	flier_physics_y( flier, dt )
end

function flier_physics_x ( flier, dt )
	max_vel = 300
	min_vel = -300

	if ( flier.moving ) then
	 	if ( flier.x_vel < max_vel and flier.direction == right ) then
			flier.x_vel = flier.x_vel + (max_vel / 300)
	 	elseif ( flier.x_vel > min_vel and flier.direction == left ) then
			flier.x_vel = flier.x_vel - (max_vel / 300)
		end
	else
		if ( flier.x_vel > 0 ) then
			flier.x_vel = flier.x_vel - (max_vel / 600)
		elseif ( flier.x_vel < 0 ) then
			flier.x_vel = flier.x_vel + (max_vel / 600)
		end
	end

	flier.x = flier.x + flier.x_vel * dt
end

function flier_physics_y ( flier, dt )
	gravity = .75
	floor = 500

	-- wing-flap
	if ( flier.flying ) then
		flier.y_vel = -200
		flier.flying = false
	end

	-- gravity 
	if ( flier.y < floor ) then
		flier.y_vel = flier.y_vel + gravity
	end

	-- if on ground; stop gravity
	if ( flier.y > floor ) then
		flier.y = floor
		flier.y_vel = 0
	end

	flier.y = flier.y + flier.y_vel * dt
end
