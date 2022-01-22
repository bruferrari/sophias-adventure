player = world:newRectangleCollider(360, 100, 40, 40, nil)
player.speed = 200
player.direction = 1
player.jumping = false
player.animation = animations.idle

function playerUpdate(dt)
    player.animation = animations.idle

    if player.body then
        local colliders = world:queryRectangleArea(
            player:getX() - 20,
            player:getY() + 20,
            40,
            2,
            {'platform'}
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
            player.animation = animations.happy
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
    player.animation:draw(sprites.player, px, py, nil, 0.25 * player.direction, 0.25, 100, 190)
end