--
-- Author: Carl
-- Date: 2015-05-15 20:26:30
--

local countdown = {}
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local handler

-- 运行计时器
function countdown.run(duration, callback)
    countdown._pause = false
    local function onTimer(dt)
        if countdown._pause then
            return
        end
        duration = duration - dt

        if DEBUG > 0 then
            printInfo("countdown  @倒计时%d秒", math.round(duration))
        end

        if duration <= 0 then
            scheduler.unscheduleGlobal(handler)
            callback({timeout=true, remains=0})
        else
            callback({timeout=false, remains=math.round(duration)})
        end
    end
    if handler then
        scheduler.unscheduleGlobal(handler)
    end
    handler = scheduler.scheduleGlobal(onTimer, 1.0)
end

-- 恢复倒计时
function countdown.resume()
    countdown._pause = false
end

-- 暂停倒计时
function countdown.pause()
    countdown._pause = true
end

-- 停止计时器
function countdown.stop()
    if handler then
        if DEBUG > 0 then
            printInfo("@停止倒计时")
        end
        scheduler.unscheduleGlobal(handler)
    end
end

return countdown