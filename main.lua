wf = require('libs/windfield/windfield')

function love.load()
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('platform')

    spawnPlatform()
    require('player')
end

function love.draw()
    world:draw()
end

function love.update(dt)
    world:update(dt)
    playerUpdate(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'up' then
        if not player.jumping then
            player:applyLinearImpulse(0, -1500)
        end
    end
end

function spawnPlatform()
    local platform = world:newRectangleCollider(200, 400, 300, 100, { collision_class='platform' })
    platform:setType('static')
end