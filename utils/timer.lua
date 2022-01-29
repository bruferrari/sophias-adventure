local timer = {
    ellapsed = 0
}

function timer.wait(dt, seconds)
    timer.ellapsed = timer.ellapsed + dt
    if timer.ellapsed > seconds then
        return true
    end
    return false
end

function timer.log()
    print("timer: " .. timer.ellapsed)
end

return timer