local itemData = {
    ['play'] = {
        x = nil,
        y = nil,
        displayName = 'Play',
        collision_classes = {collision_class = 'menu_item'}
    },
    ['settings'] = {
        x = nil,
        y = nil,
        displayName = 'Settings',
        collision_classes = {collision_class = 'menu_item'}
    },
    ['quit'] = {
        x = nil,
        y = nil,
        displayName = 'Quit',
        collision_classes = {collision_class = 'menu_item'}
    }
}

Menu = {'play', 'settings', 'quit'}

local yOffset = 50
local x, y = 0, love.graphics.getHeight() / 2 - (#Menu * yOffset)
local r, g, b, a = love.graphics.getColor()

function Menu:load()
    love.graphics.setFont(font)
    for _, key in ipairs(Menu) do
        if itemData[key] == nil then
            return
        end

        itemData[key].x = x
        itemData[key].y = y
        print('menu ' .. itemData[key].displayName .. ' x: ' .. x .. ' y: ' .. y + yOffset)
        yOffset = yOffset + 50
    end
    yOffset = 50
end

function Menu:draw()
    local rect_w, rect_h = 300, 100
    local h_center = love.graphics.getWidth() / 2
    local xOffset = rect_w / 2
    local mouse_first = 1

    for _, key in ipairs(Menu) do
        local color = {0, 0, 0, 0.38}
        local rect_x, rect_y = h_center - xOffset, y + yOffset
        local text_x, text_y = x, y + yOffset + 35
        local item = itemData[key]

        local mouse_x, mouse_y = love.mouse.getX(), love.mouse.getY()
        local hover = mouse_x > rect_x and mouse_x < rect_x + rect_w and
                      mouse_y > rect_y and mouse_y < rect_y + rect_h

        if hover then
            color = {0.5, 0.5, 0.5, 0.38}

            if love.mouse.isDown(mouse_first) then
                if key == 'quit' then
                    love.event.quit()
                elseif key == 'play' then
                    Game.current_state = State['playing']
                elseif key == 'settings' then
                    print('settings clicked')
                end
            end
        end

        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("fill", rect_x, rect_y, rect_w, rect_h)
        love.graphics.setColor(r, g, b, a)
        love.graphics.printf(item.displayName, text_x, text_y, love.graphics.getWidth(), 'center')

        if Game.debugMode then
            print(
                'mouse x: ' .. mouse_x ..
                ' mouse y: ' .. mouse_y ..
                ' item x: ' .. item.x ..
                ' item y ' .. item.y
                )
        end

        yOffset = yOffset + 110
    end
    yOffset = 50
end

function Menu:update(dt)
    -- todo: update menu items
end