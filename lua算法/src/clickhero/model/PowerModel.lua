---
-- 能量model
--@module PowerModel
local PowerModel = {
    _data = nil,
    _eventId = nil,
    _usedNum = nil,
    _recoveTime = nil,
    dataChangeEventType = "POWER_MODEL_DATA_CHANGE", --{type=}
}

function PowerModel:_raiseDataChangeEvent()
    local evt = {type = self.dataChangeEventType}
    zzy.EventManager:dispatch(evt)
end

---
-- 初始化
-- @function [parent=#PowerModel] init
-- @param #PowerModel self
-- @param #table data
function PowerModel:init(data)
    self._data = data.power
    --self._data = {num=5000}
    self._usedNum = 0
    if self._data.num < GameConst.POWER_MAX_NUMBER then
        self:_startRecover()
    end
end

---
-- @function [parent=#PowerModel] clean
-- @param #PowerModel self
function PowerModel:clean()
    self._data = nil
    if self._eventId then
        zzy.EventManager:unListen(self._eventId)
        self._eventId = nil
    end
    self._usedNum = nil
    self._recoveTime = nil
end

---
-- 添加能量值
-- @function [parent=#PowerModel] addPower
-- @param #PowerModel self
-- @param #number num
function PowerModel:addPower(num)
    self._data.num = self._data.num + num
	if num < 0 then
        self._usedNum = self._usedNum - num
        self:_startRecover()
	elseif self._data.num >= GameConst.POWER_MAX_NUMBER then
        self._data.num = GameConst.POWER_MAX_NUMBER
	    self:_endRecover()
	end
	self:_raiseDataChangeEvent()
end

---
-- 获取能量值
-- @function [parent=#PowerModel] getPower
-- @param #PowerModel self
-- @return #number
function PowerModel:getPower()
    return self._data.num
end

---
-- 启动恢复
-- @function [parent=#PowerModel] _startRecover
-- @param #PowerModel self
function PowerModel:_startRecover()
	if self._eventId then return end
	self._recoveTime = os_time() + 30
	self._eventId = zzy.EventManager:listen(zzy.Events.TickEventType,function()
	   local now = os_time()
	   if now >= self._recoveTime then
          local count = math.floor((now - self._recoveTime)/30) + 1
          local power = GameConst.POWER_RECOVER_NUMBER *(count)
          self:addPower(power)
          ch.NetworkController:PowerCheck(self:getPower(),self._usedNum)
          self._usedNum = 0
          self._recoveTime = self._recoveTime + count * 30
	   end
	end)
end

---
-- 结束恢复
-- @function [parent=#PowerModel] _endRecover
-- @param #PowerModel self
function PowerModel:_endRecover()
    if self._eventId then
        zzy.EventManager:unListen(self._eventId)
        self._eventId = nil
    end
end

return PowerModel