player = world:newRectangleCollider(360, 100, 50, 60, { collision_class = 'player' })
player:setFixedRotation(true)
player.speed = 200
player.lives = 3
player.direction = 1
player.jumping = false
player.celebrating = false
player.animation = Animations.idle
player.hurtingFrames = 0

function player:update(dt)
    player.animation = Animations.idle
    local px, py = player:getPosition()

    if player.body then
        local colliders = world:queryRectangleArea(
            px - 20,
            py + 30,
            40,
            2,
            {'platform', 'enemy'}
        )

        if love.keyboard.isDown('left') then
            player:setX(px - player.speed * dt)
            player.direction = -1
            player.animation = Animations.walking
        end

        if love.keyboard.isDown('right') then
            player:setX(px + player.speed * dt)
            player.direction = 1
            player.animation = Animations.walking
        end

        if love.keyboard.isDown('space') then
            if player.animation == Animations.idle then
                player.animation = Animations.celebrating
            end
        end

        if #colliders == 0 then
            player.jumping = true
            player.animation = Animations.jumping
        else
            player.jumping = false
        end
    end

    player.animation:update(dt)
end

function player:draw()
    local px, py = player:getPosition()
    if player.hurtingFrames == 0 then
        player.animation:draw(Sprites.player, px, py, nil, 0.25 * player.direction, 0.25, 100, 150)
    elseif player.hurtingFrames > 0 then
        if math.fmod(player.hurtingFrames, 4) ~= 0 then
            player.animation:draw(Sprites.player, px, py, nil, 0.25 * player.direction, 0.25, 100, 150)
        end
        player.hurtingFrames = player.hurtingFrames - 1
    end
end

function player:hurt()
    player.hurtingFrames = 120
    player.lives = player.lives - 1
end

function player:drawLives()
    local hx = 0
    for index = 1, player.lives do
        hx = hx + 40
        love.graphics.draw(Sprites.heart, hx, 30)
    end
end