wf = require('libs/windfield/windfield')
anim8 = require('libs/anim8/anim8')

sprites = {}
animations = {}
game = {
    width = 1024,
    height = 768
}

function love.load()
    love.window.setMode(game.width, game.height)
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)
    world:addCollisionClass('platform')

    sprites.player = love.graphics.newImage('sprites/baby-running.png')
    local animGrid = anim8.newGrid(228, 278, sprites.player:getWidth(), sprites.player:getHeight())

    animations.walking = anim8.newAnimation(animGrid('1-4', 4), 0.3)
    animations.idle = anim8.newAnimation(animGrid('1-1', 4), 0.3)

    spawnPlatform()
    require('player')
end

function love.draw()
    world:draw()
    drawPlayer()
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