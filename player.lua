player = world:newRectangleCollider(360, 100, 40, 40, nil)
player.speed = 200
player.direction = 1
player.jumping = false
player.animation = animations.walking

function playerUpdate(dt)
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
        end
   
        if love.keyboard.isDown('right') then
            player:setX(px + player.speed * dt)
            player.direction = 1
        end

        if #colliders > 0 then
            player.jumping = false
        else
            player.jumping = true
        end
    end

    player.animation:update(dt)
end

function drawPlayer()
    local px, py = player:getPosition()
    player.animation:draw(sprites.player, px, py, nil, 0.25 * player.direction, 0.25, 100, 190)
end