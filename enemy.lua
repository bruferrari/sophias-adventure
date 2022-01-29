require('utils/timer')
local enemyFixtureCategory = 2

enemies = {}

local enemyClass = {
    ['blue'] = {
        type = 1,
        speed = 100,
        animation = animations.blueEnemyWalking,
        collision_classes = {collision_class = 'danger'}
    },
    ['red'] = {
        type = 2,
        speed = 200,
        animation = animations.redEnemyWalking,
        collision_classes = {collision_class = 'danger'}
    },
    ['green'] = {
        type = 3,
        speed = 75,
        animation = animations.greenEnemyWalking,
        collision_classes = {collision_class = 'danger'}
    }
}

function enemies:spawn(x, y, width, height, type)
    local class = nil

    if type == enemyClass['blue'].type then
        class = enemyClass['blue']
    elseif type == enemyClass['red'].type then
        class = enemyClass['red']
    elseif type == enemyClass['green'].type then
        class = enemyClass['green']
    else
        print('could not create an enemy with type=' .. type)
    end

    if class ~= nil then
        local enemy = world:newRectangleCollider(x, y, width, height, class.collision_classes)
        enemy.type = type
        enemy.speed = class.speed
        enemy.animation = class.animation
        enemy.id = #enemies + 1
        enemy.direction = -1
        enemy.dead = false
        enemy.colliding = false

        enemy:setFixedRotation(true)
        enemy:setCategory(enemyFixtureCategory)
        enemy:setMask(enemyFixtureCategory)

        table.insert(enemies, enemy)
    end
end

function enemies:update(dt)
    if game.debugMode then
        print("player available lives: " .. player.lives)
        log()
    end

    enemies:destroy()
    for _, enemy in ipairs(enemies) do
        local ex, ey = enemy:getPosition()
        local pColliders = world:queryRectangleArea(ex + 20 * enemy.direction, ey + 30, 10, 2, {'platform'})
        local tColliders = world:queryRectangleArea(ex + 35 * enemy.direction, ey + 30, 10, 10, {'threshold'})
        local playerColliders = world:queryRectangleArea(ex + 35 * enemy.direction, ey + 30, 10, 10, {'player'})

        if #playerColliders > 0 then
            if not enemy.colliding then
                player:hurt()
            end

            enemy.colliding = true
        
            if enemy.type == 1 then
                enemy.speed = 0
                enemy.animation = animations.blueEnemyDying
            end
         
            local readyToDie = wait(dt, 2)
            if game.debugMode then
                print("ready to die: " .. tostring(readyToDie))
            end

            if readyToDie then
                enemy.dead = true
            end
        else
            enemy.colliding = false
        end

        if #tColliders > 0 or #pColliders == 0 then
            local oldDirection = enemy.direction
            enemy.direction = enemy.direction * -1

            if game.debugMode then
                if oldDirection ~= enemy.direction then
                    print("enemy" .. enemy.id .. " direction: " .. enemy.direction)
                end
            end
        end

        enemy:setX(ex + enemy.speed * dt * enemy.direction)
        enemy.animation:update(dt)
    end
end

function enemies:draw()
    for _, enemy in ipairs(enemies) do
        local ex, ey = enemy:getPosition()
        enemy.animation:draw(sprites.enemies, ex, ey, nil, 4 * enemy.direction * -1, 4, 8, 7.5)
    end
end

function enemies:destroy()
    for i, enemy in ipairs(enemies) do
        if enemy.dead then
            enemy:destroy()
            table.remove(enemies, i)
        end
    end
end
