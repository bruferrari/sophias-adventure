wf = require('libs/windfield/windfield')
anim8 = require('libs/anim8/anim8')
sti = require('libs/Simple-Tiled-Implementation/sti')
camera = require('libs/hump/camera')

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

    cam = camera()

    sprites.player = love.graphics.newImage('sprites/baby-running.png')
    local animGrid = anim8.newGrid(228, 278, sprites.player:getWidth(), sprites.player:getHeight())

    local playerAnimTime = 0.09

    animations.walking = anim8.newAnimation(animGrid('1-4', 4), playerAnimTime)
    animations.idle = anim8.newAnimation(animGrid('1-1', 4), playerAnimTime)
    animations.jumping = anim8.newAnimation(animGrid('4-4', 4), playerAnimTime)
    animations.happy = anim8.newAnimation(animGrid('2-4', 1), 0.15)

    require('player')

    loadMap()
end

function love.draw()
    cam:attach()
    world:draw()
    gameMap:drawLayer(gameMap.layers['Tile Layer 1'])
    drawPlayer()
    cam:detach()
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)

    local px, py = player:getPosition()
    cam:lookAt(px, love.graphics.getHeight() / 2)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'up' then
        if not player.jumping then
            player:applyLinearImpulse(0, -3000)
        end
    end
end

function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, { collision_class='platform' })
        platform:setType('static')
    end
end

function loadMap()
    gameMap = sti('maps/level_one.lua')

    for _, platform in ipairs(gameMap.layers['Platforms'].objects) do
        spawnPlatform(platform.x, platform.y, platform.width, platform.height)
    end
end