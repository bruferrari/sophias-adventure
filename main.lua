wf = require('libs/windfield/windfield')
anim8 = require('libs/anim8/anim8')
sti = require('libs/Simple-Tiled-Implementation/sti')
camera = require('libs/hump/camera')
timer = require('utils/timer')

Animations = {}
Sprites = {}
local platforms = {}
local thresholds = {}

State = {
    ['playing'] = 0,
    ['paused'] = 1
}

Game = {
    width = 1024,
    height = 768,
    debugMode = false,
    currentMap = 'level_one',
    current_state = State['playing']
}

function love.load()
    love.window.setMode(Game.width, Game.height)
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

    Sprites.player = love.graphics.newImage('sprites/baby-running.png')
    Sprites.nightBg = love.graphics.newImage('sprites/night_bg.png')
    Sprites.forestBg = love.graphics.newImage('sprites/forest_bg.png')
    Sprites.enemies = love.graphics.newImage('sprites/enemies.png')
    Sprites.heart = love.graphics.newImage('sprites/heart.png')

    Sprites.enemies:setFilter('nearest')

    local playerAnimGrid = anim8.newGrid(228, 278, Sprites.player:getWidth(), Sprites.player:getHeight())
    local enemyAnimGrid = anim8.newGrid(16, 16, Sprites.enemies:getWidth(), Sprites.enemies:getHeight())

    local playerAnimTime = 0.25
    local playerCelbAnimTime = 0.15

    Animations.walking = anim8.newAnimation(playerAnimGrid('1-4', 4), playerAnimTime)
    Animations.idle = anim8.newAnimation(playerAnimGrid('1-1', 4), playerAnimTime)
    Animations.jumping = anim8.newAnimation(playerAnimGrid('4-4', 4), playerAnimTime)
    Animations.celebrating = anim8.newAnimation(playerAnimGrid('2-4', 1), playerCelbAnimTime)

    local enemyAnimTime = 0.08
    Animations.blueEnemyWalking = anim8.newAnimation(enemyAnimGrid('2-6', 3), enemyAnimTime)
    Animations.redEnemyWalking = anim8.newAnimation(enemyAnimGrid('2-6', 5), enemyAnimTime)
    Animations.greenEnemyWalking = anim8.newAnimation(enemyAnimGrid('2-6', 7), enemyAnimTime)

    local enemyDyingAnimTime = 0.50
    Animations.blueEnemyDying = anim8.newAnimation(enemyAnimGrid('2-5', 2), enemyDyingAnimTime)
    Animations.blueEnemySmashed = anim8.newAnimation(enemyAnimGrid('4-6', 2), enemyDyingAnimTime)

    Animations.redEnemyDying = anim8.newAnimation(enemyAnimGrid('2-5', 4), enemyDyingAnimTime)
    Animations.redEnemySmashed = anim8.newAnimation(enemyAnimGrid('4-6', 4), enemyDyingAnimTime)

    Animations.greenEnemyDying = anim8.newAnimation(enemyAnimGrid('2-5', 6), enemyDyingAnimTime)
    Animations.greenEnemySmashed = anim8.newAnimation(enemyAnimGrid('4-6', 6), enemyDyingAnimTime)

    require('main_menu')
    require('player')
    require('enemy')

    Menu:load()

    loadMap('level_one')
end

function love.draw()
    love.graphics.draw(Sprites.forestBg, 0, 0, 0, 0.55, 0.55)
    player:drawLives()
    cam:attach()

    if Game.debugMode then
        world:draw()
    end

    gameMap:drawLayer(gameMap.layers['Tile Layer 1'])
    player:draw()
    enemies:draw()
    cam:detach()

    if Game.current_state == State['paused'] then
        Menu:draw()
    end
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)

    if Game.current_state == State['playing'] then
        timer:getPool():update(dt)
        player:update(dt)
        enemies:update(dt)
    end

    if Game.debugMode then
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
        if Game.current_state == State['playing'] then
            Game.current_state = State['paused']
        elseif Game.current_state == State['paused'] then
            Game.current_state = State['playing']
        end
    end

    if key == 'up' then
        if not player.jumping then
            player:applyLinearImpulse(0, -3500)
        end
    end

    if key == 'g' then
        Game.debugMode = not Game.debugMode
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
    loadMap(Game.currentMap)
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