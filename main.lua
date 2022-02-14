wf = require('libs/windfield/windfield')
anim8 = require('libs/anim8/anim8')
sti = require('libs/Simple-Tiled-Implementation/sti')
camera = require('libs/hump/camera')
timer = require('utils/timer')

sprites = {}
animations = {}
platforms = {}
thresholds = {}
game = {
    state = 0,
    width = 1024,
    height = 768,
    debugMode = false,
    currentMap = 'level_one'
}

function love.load()
    love.window.setMode(game.width, game.height)
    love.window.setTitle("Sophia's Adventure")
    font = love.graphics.newFont(30)
    world = wf.newWorld(0, 800, false)

    world:setQueryDebugDrawing(true)

    world:addCollisionClass('player')
    world:addCollisionClass('platform')
    world:addCollisionClass('enemy')
    world:addCollisionClass('threshold')
    world:addCollisionClass('menu_item')

    cam = camera()

    sprites.player = love.graphics.newImage('sprites/baby-running.png')
    sprites.nightBg = love.graphics.newImage('sprites/night_bg.png')
    sprites.forestBg = love.graphics.newImage('sprites/forest_bg.png')
    sprites.enemies = love.graphics.newImage('sprites/enemies.png')
    sprites.heart = love.graphics.newImage('sprites/heart.png')

    sprites.enemies:setFilter('nearest')

    local playerAnimGrid = anim8.newGrid(228, 278, sprites.player:getWidth(), sprites.player:getHeight())
    local enemyAnimGrid = anim8.newGrid(16, 16, sprites.enemies:getWidth(), sprites.enemies:getHeight())

    local playerAnimTime = 0.25
    local playerCelbAnimTime = 0.15

    animations.walking = anim8.newAnimation(playerAnimGrid('1-4', 4), playerAnimTime)
    animations.idle = anim8.newAnimation(playerAnimGrid('1-1', 4), playerAnimTime)
    animations.jumping = anim8.newAnimation(playerAnimGrid('4-4', 4), playerAnimTime)
    animations.celebrating = anim8.newAnimation(playerAnimGrid('2-4', 1), playerCelbAnimTime)

    local enemyAnimTime = 0.08
    animations.blueEnemyWalking = anim8.newAnimation(enemyAnimGrid('2-6', 3), enemyAnimTime)
    animations.redEnemyWalking = anim8.newAnimation(enemyAnimGrid('2-6', 5), enemyAnimTime)
    animations.greenEnemyWalking = anim8.newAnimation(enemyAnimGrid('2-6', 7), enemyAnimTime)

    local enemyDyingAnimTime = 0.50
    animations.blueEnemyDying = anim8.newAnimation(enemyAnimGrid('2-5', 2), enemyDyingAnimTime)
    animations.blueEnemySmashed = anim8.newAnimation(enemyAnimGrid('4-6', 2), enemyDyingAnimTime)

    animations.redEnemyDying = anim8.newAnimation(enemyAnimGrid('2-5', 4), enemyDyingAnimTime)
    animations.redEnemySmashed = anim8.newAnimation(enemyAnimGrid('4-6', 4), enemyDyingAnimTime)

    animations.greenEnemyDying = anim8.newAnimation(enemyAnimGrid('2-5', 6), enemyDyingAnimTime)
    animations.greenEnemySmashed = anim8.newAnimation(enemyAnimGrid('4-6', 6), enemyDyingAnimTime)

    require('main_menu')
    require('player')
    require('enemy')

    Menu:load()

    loadMap('level_one')
end

function love.draw()
    love.graphics.draw(sprites.forestBg, 0, 0, 0, 0.55, 0.55)
    player:drawLives()
    cam:attach()
    if game.debugMode then
        world:draw()
    end
    gameMap:drawLayer(gameMap.layers['Tile Layer 1'])
    player:draw()
    enemies:draw()
    cam:detach()
    if game.state == 0 then
        Menu:draw()
    end
end

function love.update(dt)
    timer:getPool():update(dt)
    world:update(dt)
    gameMap:update(dt)
    player:update(dt)
    enemies:update(dt)

    if game.debugMode then
        displayDebugInfo()
    end

    if player.lives == 0 then
        resetMap()
    end

    local px, _ = player:getPosition()
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
            player:applyLinearImpulse(0, -3500)
        end
    end

    if key == 'g' then
        game.debugMode = not game.debugMode
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local mouseColliders = world:queryCircleArea(x, y, 30, { collision_class='menu_item' })
        if #mouseColliders > 0 then
            print('MENU ITEM CLICKED!')
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

function spawnMapThreshold(x, y, width, height)
    if width > 0 and height > 0 then
        local threshold = world:newRectangleCollider(x, y, width, height, { collision_class='threshold' })
        threshold:setType('static')
        table.insert(thresholds, threshold)
    end
end

function loadMap(map)
    gameMap = sti('maps/' .. map .. '.lua')

    for _, platform in ipairs(gameMap.layers['Baseline'].objects) do
        spawnPlatform(platform.x, platform.y, platform.width, platform.height)
    end

    for _, platform in ipairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(platform.x, platform.y, platform.width, platform.height)
    end

    for _, enemy in ipairs(gameMap.layers['Enemies'].objects) do
        enemies:spawn(enemy.x, enemy.y, enemy.width, enemy.height, enemy.properties['enemy_type'])
    end

    for _, threshold in ipairs(gameMap.layers["Thresholds"].objects) do
        spawnMapThreshold(threshold.x, threshold.y, threshold.width, threshold.height)
    end
end

function resetMap()
    destroyPlatforms()
    destroyEnemies()
    loadMap(game.currentMap)
    player:setPosition(360, 100)
    player.lives = 3
end

function destroyPlatforms()
    for i, platform in ipairs(platforms) do
        platform:destroy()
        table.remove(platforms, i)
    end
end

function destroyEnemies()
    timer:getPool():clear()
    for i, enemy in ipairs(enemies) do
        enemy:destroy()
        table.remove(enemies, i)
    end
end

function displayDebugInfo()
    local px, py = player:getPosition()
    print("px: " .. px)
    print("py: " .. py)
    print("screen width: " .. love.graphics.getWidth())
    print("screen height: " .. love.graphics.getHeight())
end