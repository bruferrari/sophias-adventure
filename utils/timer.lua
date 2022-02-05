local Timer = {
    id = nil,
    ellapsed = 0
}

local Pool = {}

function Pool:log()
    if #Pool > 0 then
        for _, t in ipairs(self) do
            print("pool: " .. #Pool .. " timers scheduled")
            print("id: " .. tostring(t.id) .. " timer: " .. t.ellapsed)
        end
    else
        print("pool: no timers scheduled")
    end
end

function Pool:clear()
    local i = #Pool
    while i > -1 do
        table.remove(Pool, i)
        i = i - 1
    end
end

function Pool:update(dt)
    for _, timer in ipairs(Pool) do
        timer:update(dt)
    end
end

function Pool:find(timer)
    for i, t in ipairs(Pool) do
        return t.id == timer.id and i or -1
    end
end

function Timer:new(t)
    t = t or {
        id = nil,
        ellapsed = 0
    }
    setmetatable(t, self)
    self.__index = self

    return t
end

function Timer:schedule(timer)
    local scheduled = false
    for _, t in ipairs(Pool) do
        if t.id == timer.id then
            scheduled = true
        end
    end

    if not scheduled then
        local toSchedule = Timer:new(timer)
        table.insert(Pool, toSchedule)
        return toSchedule
    end
    return nil
end

function Timer:wait(seconds)
    if self.ellapsed > seconds then
        self:reset()
        return true
    end
    return false
end

function Timer:executeAfter(seconds, closure, loop)
    loop = loop or false

    if self.ellapsed > seconds then
        closure()
        if loop then
            self:reset()
        else
            local index = Pool:find(self)
            if index > 0 then
                table.remove(Pool, index)
            end
        end
    end
end

function Timer:repeatEach(seconds, fn)
    self:executeAfter(seconds, fn, true)
end

function Timer:update(dt)
    self.ellapsed = self.ellapsed + dt
end

function Timer:reset()
    self.ellapsed = 0
end

function Timer:getPool()
    return Pool
end

return Timer