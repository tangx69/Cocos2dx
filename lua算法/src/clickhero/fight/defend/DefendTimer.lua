local DefendTimer = {
    _deltaTime = nil,
    _startTime = nil,
    _pauseTime = nil,
    _totalPauseTime = nil,
    _lastFrameTime = nil,
}

---
-- 初始化
-- @function [parent=#DefendTimer] init
-- @param #DefendTimer self
function DefendTimer:init()
	self._startTime = os_clock()
    self._deltaTime = 0
    self._totalPauseTime = 0
    self._lastFrameTime = self._startTime
end

---
-- 获得游戏时间
-- @function [parent=#DefendTimer] getGameTime
-- @param #DefendTimer self
-- @return #number
function DefendTimer:getGameTime()
    return os_clock() - self._startTime - self._totalPauseTime
end

---
-- 获得帧间隔时间
-- @function [parent=#DefendTimer] getDeltaTime
-- @param #DefendTimer self
-- @return #number
function DefendTimer:getDeltaTime()
    return self._deltaTime
end

---
-- 每帧更新
-- @function [parent=#DefendTimer] update
-- @param #DefendTimer self
function DefendTimer:update()
    local now = os_clock()
    self._deltaTime = now - self._lastFrameTime
    self._lastFrameTime = now
end

---
-- 暂停
-- @function [parent=#DefendTimer] pause
-- @param #DefendTimer self
function DefendTimer:pause()
    self._pauseTime = os_clock()
end

---
-- 恢复
-- @function [parent=#DefendTimer] resume
-- @param #DefendTimer self
function DefendTimer:resume()
    if not self._pauseTime then return end
    local now = os_clock()
    self._totalPauseTime = self._totalPauseTime + now - self._pauseTime
    self._lastFrameTime = now
    self._deltaTime = 0
    self._pauseTime = nil
end


return DefendTimer