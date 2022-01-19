wf = require('libs/windfield/windfield')

function love.load()
    world = wf.newWorld(0, 800, false)
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
end

function spawnPlatform()
    local platform = world:newRectangleCollider(100, 200, 300, 100, nil)
    platform:setType('static')
end