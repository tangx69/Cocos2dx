---
-- 大任务分帧处理工具
-- @module BigTaskUtils
local BigTaskUtils = {
    _tasks = {}
}
local MAX_RUN_TIME_PER_FRAME = 0.08

---
-- 初始化
-- @function [parent=#BigTaskUtils] loop
-- @param self
function BigTaskUtils:loop()
    local startTime = os_clock()
    for pos,task in pairs(self._tasks) do
    	local stop = task.func(task.param)
    	if stop then
    	   table.remove(self._tasks,pos)
    	end
    	if os_clock() - startTime > MAX_RUN_TIME_PER_FRAME then
    	   break
    	end
    end
end


function BigTaskUtils:addPairsTask(obj, data, flag, func)
    local nextFunc = pairs(data)
    local curK = nil
    local curV = nil
    local continueFlag = obj[flag]
    BigTaskUtils:addTask(function()
        if continueFlag ~= obj[flag] then return true end
        curK,curV = nextFunc(data, curK)
        if not curK then return true end
        func(curK, curV)
    end)
end

---
-- 添加任务
-- @function [parent=#BigTaskUtils] addTask
-- @param self
-- @param #function loop 返回true来结束任务
-- @param #table param 循环参数
function BigTaskUtils:addTask(loop, param)
    local task = {}
    task.func = loop
    task.param = param
    zzy.TimerUtils:setTimeOut(0, function()
        table.insert(self._tasks, task)
    end)
end

return BigTaskUtils
