player = world:newRectangleCollider(360, 100, 50, 60, nil)
player:setFixedRotation(true)
player.speed = 200
player.direction = 1
player.jumping = false
player.celebrating = false
player.animation = animations.idle

function playerUpdate(dt)
    player.animation = animations.idle

    if player.body then
        local colliders = world:queryRectangleArea(
            player:getX() - 20,
            player:getY() + 30,
            40,
            2,
            {'platform', 'danger'}
        )

        local px, py = player:getPosition()

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

        if #colliders > 0 then
            player.jumping = false
        else
            player.jumping = true
            player.animation = animations.jumping
        end
    end

    player.animation:update(dt)
end

function drawPlayer()
    local px, py = player:getPosition()
    player.animation:draw(sprites.player, px, py, nil, 0.25 * player.direction, 0.25, 100, 150)
end