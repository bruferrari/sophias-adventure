player = world:newRectangleCollider(360, 100, 50, 60, { collision_class = 'player' })
player:setFixedRotation(true)
player.speed = 200
player.lives = 3
player.direction = 1
player.jumping = false
player.celebrating = false
player.animation = animations.idle

function player:update(dt)
    player.animation = animations.idle
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
            player.animation = animations.walking
        end

        if love.keyboard.isDown('right') then
            player:setX(px + player.speed * dt)
            player.direction = 1
            player.animation = animations.walking
        end

        if love.keyboard.isDown('space') then
            if player.animation == animations.idle then
                player.animation = animations.celebrating
            end
        end

        if #colliders == 0 then
            player.jumping = true
            player.animation = animations.jumping
        else
            player.jumping = false
        end
    end

    player.animation:update(dt)
end

function player:draw()
    local px, py = player:getPosition()
    player.animation:draw(sprites.player, px, py, nil, 0.25 * player.direction, 0.25, 100, 150)
end

function player:hurt()
    player.lives = player.lives - 1
end

function player:drawLives()
    local hx = 0
    for index = 1, player.lives do
        hx = hx + 40
        love.graphics.draw(sprites.heart, hx, 30)
    end
end