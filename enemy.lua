local enemyFixtureCategory = 2

enemies = {}

local enemyClass = {
    ['blue'] = {
        type = 'blue',
        speed = 100,
        animation = animations.blueEnemyWalking,
        dying_animation = animations.blueEnemyDying,
        smash_animation = animations.blueEnemySmashed,
        collision_classes = {collision_class = 'enemy'}
    },
    ['red'] = {
        type = 'red',
        speed = 200,
        animation = animations.redEnemyWalking,
        dying_animation = animations.redEnemyDying,
        smash_animation = animations.redEnemySmashed,
        collision_classes = {collision_class = 'enemy'}
    },
    ['green'] = {
        type = 'green',
        speed = 75,
        animation = animations.greenEnemyWalking,
        dying_animation = animations.greenEnemyDying,
        smash_animation = animations.greenEnemySmashed,
        collision_classes = {collision_class = 'enemy'}
    }
}

local function setDead(enemy, deathType, animDuration)
    local smashDeathAnim = enemyClass[enemy.type].smash_animation
    local defaultDeathAnim = enemyClass[enemy.type].dying_animation

    timer:schedule{
        id = enemy.id,
        ellapsed = 0
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
    if game.debugMode then
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

            setDead(enemy, 'default', 2)
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

        if #kColliders > 0 then
            setDead(enemy, 'smash', 1)
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

local onAnimationFinish = function(enemy)
    -- todo: impl
end

function enemies:destroy(dt)
    for i, enemy in ipairs(enemies) do
        local destroyEnemy = function()
            enemy:destroy()
            table.remove(enemies, i)
        end

        if enemy.dead then
            local pool = timer:getPool()
            for _, t in ipairs(pool) do
                t:executeAfter(2, destroyEnemy)
            end
        end
    end
end