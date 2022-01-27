enemies = {}

function enemies:spawn(x, y, width, height, type)
    enemy = world:newRectangleCollider(x, y, width, height, {collision_class='danger'})
    enemy.id = #enemies + 1
    enemy.speed = 150
    enemy.direction = -1
    enemy.animation = enemies:getAnimation(type)

    enemy:setFixedRotation(true)

    table.insert(enemies, enemy)
end

function enemies:getAnimation(enemyType)
    if enemyType == 1 then
        return animations.blueEnemyWalking
    elseif enemyType == 2 then
        return animations.redEnemyWalking
    else
        return animations.greenEnemyWalking
    end
end

function enemies:update(dt)
    for _, enemy in ipairs(enemies) do
        local ex, ey = enemy:getPosition()
        local pColliders = world:queryRectangleArea(ex + 20 * enemy.direction, ey + 30, 10, 2, {'platform'})
        local tColliders = world:queryRectangleArea(ex + 35 * enemy.direction, ey + 30, 10, 10, {'threshold'})

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
