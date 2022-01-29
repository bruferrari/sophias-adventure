local timer = 0

function wait(dt, s)
    timer = timer + dt
    if timer > s then
        return true
    end
    return false
end

function log()
    print("timer: " .. timer)
end