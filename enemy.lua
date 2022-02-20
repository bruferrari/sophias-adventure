local enemyFixtureCategory = 2

enemies = {}

local enemyClass = {
    ['blue'] = {
        type = 'blue',
        speed = 100,
        animation = Animations.blueEnemyWalking,
        dying_animation = Animations.blueEnemyDying,
        smash_animation = Animations.blueEnemySmashed,
        collision_classes = {collision_class = 'enemy'}
    },
    ['red'] = {
        type = 'red',
        speed = 200,
        animation = Animations.redEnemyWalking,
        dying_animation = Animations.redEnemyDying,
        smash_animation = Animations.redEnemySmashed,
        collision_classes = {collision_class = 'enemy'}
    },
    ['green'] = {
        type = 'green',
        speed = 75,
        animation = Animations.greenEnemyWalking,
        dying_animation = Animations.greenEnemyDying,
        smash_animation = Animations.greenEnemySmashed,
        collision_classes = {collision_class = 'enemy'}
    }
}

local enemyDyingAnimTime = {
    ['smash'] = 1,
    ['default'] = 2
}

local function setDead(enemy, deathType)
    local smashDeathAnim = enemyClass[enemy.type].smash_animation
    local defaultDeathAnim = enemyClass[enemy.type].dying_animation

    timer:schedule{
        id = enemy.id,
        ellapsed = 0,
        limit = deathType == 'smash' and enemyDyingAnimTime['smash'] or enemyDyingAnimTime['default']
    }

    enemy.dead = true
    enemy.speed = 0
    enemy.animation = deathType == 'smash' and smashDeathAnim or defaultDeathAnim
end

function enemies:spawn(x, y, width, height, type)
    local class = enemyClass[type]

    if class ~= nil then
        local enemy = world:newRectangleCollider(x, y, width, height, class.collision_classes)
        enemy.type = type
        enemy.width = width
        enemy.height = height
        enemy.speed = class.speed
        enemy.animation = class.animation
        enemy.id = #enemies + 1
        enemy.direction = -1
        enemy.dead = false

        enemy:setFixedRotation(true)
        enemy:setCategory(enemyFixtureCategory)
        enemy:setMask(enemyFixtureCategory)

        table.insert(enemies, enemy)
    end
end

function enemies:update(dt)
    if Game.debugMode then
        print("player available lives: " .. player.lives)
        local timerPool = timer:getPool()
        timerPool:log()
    end

    enemies:destroy(dt)

    for _, enemy in ipairs(enemies) do
        local ex, ey = enemy:getPosition()
        local pColliders = world:queryRectangleArea(ex + 20 * enemy.direction, ey + 30, 10, 2, {'platform'})
        local tColliders = world:queryRectangleArea(ex + 35 * enemy.direction, ey + 30, 10, 10, {'threshold'})
        local playerColliders = world:queryRectangleArea(ex - 30, ey - 15, enemy.width, enemy.height - 15, {'player'})
        local kColliders = world:queryRectangleArea(ex - 30, ey - 35, enemy.width, 2, {'player'})

        if #playerColliders > 0 then
            if not enemy.dead then
                player:hurt()
            end

            setDead(enemy, 'default')
        end

        if #tColliders > 0 or #pColliders == 0 then
            local oldDirection = enemy.direction
            enemy.direction = enemy.direction * -1

            if Game.debugMode then
                if oldDirection ~= enemy.direction then
                    print("enemy" .. enemy.id .. " direction: " .. enemy.direction)
                end
            end
        end

        if #kColliders > 0 then
            setDead(enemy, 'smash')
        end

        enemy:setX(ex + enemy.speed * dt * enemy.direction)
        enemy.animation:update(dt)
    end
end

function enemies:draw()
    for _, enemy in ipairs(enemies) do
        local ex, ey = enemy:getPosition()
        enemy.animation:draw(Sprites.enemies, ex, ey, nil, 4 * enemy.direction * -1, 4, 8, 7.5)
    end
end

local animationFinishedCallback = function(enemy, index)
    enemy:destroy()
    table.remove(enemies, index)
end

function enemies:destroy(dt)
    for i, enemy in ipairs(enemies) do
        local onAnimationFinish = function()
            animationFinishedCallback(enemy, i)
        end

        if enemy.dead then
            local pool = timer:getPool()
            for _, t in ipairs(pool) do
                t:executeAfter(t.limit, onAnimationFinish)
            end
        end
    end
end