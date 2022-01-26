enemies = {}

function spawnEnemy(x, y, width, height)
    enemy = world:newRectangleCollider(x, y, width, height, {collision_class='danger'})
    enemy.id = #enemies + 1
    enemy.speed = 150
    enemy.direction = -1

    table.insert(enemies, enemy)
end

function enemiesUpdate(dt)
    for _, enemy in ipairs(enemies) do
        -- todo: update enemy animation
        local ex, ey = enemy:getPosition()
        local colliders = world:queryRectangleArea(ex + 35 * enemy.direction, ey + 30, 10, 10, {'threshold'})

        if #colliders > 0 then
            local oldDirection = enemy.direction
            enemy.direction = enemy.direction * -1
            if oldDirection ~= enemy.direction then
                print("enemy" .. enemy.id .. " direction: " .. enemy.direction)
            end
        end

        enemy:setX(ex + enemy.speed * dt * enemy.direction)
    end
end

function drawEnemies()
    for i, enemy in ipairs(enemies) do
        -- local ex, ey = enemy:getPosition()
        -- todo: draw enemy here
    end
end

