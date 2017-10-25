---
-- 时间工具
-- @module TimerUtils
local TimerUtils = {
    timeOutSpans = {},
    timeOutCallBacks = {}
}

---
-- 添加能量增长回调
-- @function [parent=#TimerUtils] addStrengthCallBack
-- @param self
-- @param #number lastRecTime 上次恢复能量的时间，从1970年1月1日到现在的秒数
-- @param #number enterval 时间间隔，单位秒，可以是小数
-- @param #int addE 每次增加的能量值
-- @param #function getMaxE 查询能量值上限
-- @param #function getE 查询函数，需要返回当前能量值
-- @param #function callBack 回调函数，参数（时间，恢复后能量值）
function TimerUtils:addStrengthCallBack(lastRecTime, enterval, addE, getMaxE, getE, callBack)
	local now = os_time()
	local recTimes = math.floor((now - lastRecTime) / enterval)
	if recTimes > 0 then
        local curE = getE()
        curE = math.max(math.min(curE + addE * recTimes, getMaxE()), curE)
        lastRecTime = lastRecTime + enterval * recTimes
        callBack(lastRecTime, curE)
	end
	
	local timeOutCallBack
	timeOutCallBack = function()
        local curE = getE()
        curE = math.max(math.min(curE + addE, getMaxE()), curE)
        lastRecTime = lastRecTime + enterval
        callBack(lastRecTime, curE)
        
        TimerUtils:setTimeOut(lastRecTime + enterval - os_time(), timeOutCallBack)
	end
	
	TimerUtils:setTimeOut(lastRecTime + enterval - now, timeOutCallBack)
end

---
-- 倒计时执行
-- @function [parent=#TimerUtils] countDown
-- @param #TimerUtils self
-- @param #function getTimeOut 截止时间
-- @param #function callBack 回调函数
function TimerUtils:countDown(getTimeOut,callBack)
	local now = os_time()
    local recTimes = math.ceil(getTimeOut() - now)
    if recTimes >= 0 then
        callBack(recTimes)
    end
    
    local timeOutCallBack
    timeOutCallBack = function()
        local now = os_time()
        local recTimes = math.ceil(getTimeOut() - now)
        if recTimes >= 0 then
            callBack(recTimes)
        end
        TimerUtils:setTimeOut(1, timeOutCallBack)
    end
    TimerUtils:setTimeOut(1, timeOutCallBack)
end

---
-- 超时执行
-- @function [parent=#TimerUtils] setTimeOut
-- @param self
-- @param #number timeSpan 延迟时间，单位秒，可以使用小数
-- @param #function callBack
-- @return key
function TimerUtils:setTimeOut(timeSpan, callBack)
    local key = os_clock() + timeSpan
    while TimerUtils.timeOutCallBacks[key] do
        key = key + 0.0001
    end
    TimerUtils.timeOutCallBacks[key] = callBack
    table.insert(TimerUtils.timeOutSpans, key)
    table.sort(TimerUtils.timeOutSpans)
    return key
end

---
-- 撤销超时执行事件
-- @function [parent=#TimerUtils] cancelTimeOut
-- @param self
-- @param key
function TimerUtils:cancelTimeOut(key)
	TimerUtils.timeOutCallBacks[key] = nil
end

---
-- 更新
-- @function [parent=#TimerUtils] update
function TimerUtils:update()
    local now = os_clock()
    while TimerUtils.timeOutSpans[1] and TimerUtils.timeOutSpans[1] < now do
        local call = TimerUtils.timeOutCallBacks[TimerUtils.timeOutSpans[1]]
        TimerUtils.timeOutCallBacks[TimerUtils.timeOutSpans[1]] = nil
        table.remove(TimerUtils.timeOutSpans, 1)
        if call then call() end
    end
end


return TimerUtils
