wf = require('libs/windfield/windfield')
anim8 = require('libs/anim8/anim8')
sti = require('libs/Simple-Tiled-Implementation/sti')
camera = require('libs/hump/camera')

sprites = {}
animations = {}
platforms = {}
game = {
    width = 1024,
    height = 768
}

function love.load()
    love.window.setMode(game.width, game.height)
    love.window.setTitle("Sophia's Adventure")
    world = wf.newWorld(0, 800, false)

    world:setQueryDebugDrawing(true)

    world:addCollisionClass('platform')
    world:addCollisionClass('danger')

    cam = camera()

    sprites.player = love.graphics.newImage('sprites/baby-running.png')
    local animGrid = anim8.newGrid(228, 278, sprites.player:getWidth(), sprites.player:getHeight())

    local playerAnimTime = 0.25
    local playerCelbAnimTime = 0.15

    animations.walking = anim8.newAnimation(animGrid('1-4', 4), playerAnimTime)
    animations.idle = anim8.newAnimation(animGrid('1-1', 4), playerAnimTime)
    animations.jumping = anim8.newAnimation(animGrid('4-4', 4), playerAnimTime)
    animations.celebrating = anim8.newAnimation(animGrid('2-4', 1), playerCelbAnimTime)

    require('player')
    require('enemy')

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
    enemiesUpdate(dt)

    local px, py = player:getPosition()

    print("px: " .. px)
    print("py: " .. px)
    print("screen width: " .. love.graphics.getWidth())

    local pov = px
    local mapW = gameMap.layers['Baseline'].objects[1].width

    if px <= love.graphics.getWidth() / 2 then
        pov = love.graphics.getWidth() / 2
    elseif mapW - px <= love.graphics.getWidth() / 2 then
        pov = mapW - love.graphics.getWidth() / 2
    else
        pov = px
    end

    cam:lookAt(pov, love.graphics.getHeight() / 2)
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
        table.insert(platforms, platform)
    end
end

function loadMap()
    gameMap = sti('maps/level_one.lua')

    for _, platform in ipairs(gameMap.layers['Baseline'].objects) do
        spawnPlatform(platform.x, platform.y, platform.width, platform.height)
    end

    for _, enemy in ipairs(gameMap.layers['Enemies'].objects) do
        spawnEnemy(enemy.x, enemy.y, enemy.width, enemy.height)
    end
end