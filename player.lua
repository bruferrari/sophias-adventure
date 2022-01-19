player = world:newRectangleCollider(360, 100, 40, 100, nil)
player.speed = 200
player.direction = 1

function playerUpdate(dt)
    if player.body then
        local px, py = player:getPosition()

        if love.keyboard.isDown('left') then
            player:setX(px - player.speed * dt)
            player.direction = -1
        end
   
        if love.keyboard.isDown('right') then
            player:setX(px + player.speed * dt)
            player.direction = 1
        end
    end
end