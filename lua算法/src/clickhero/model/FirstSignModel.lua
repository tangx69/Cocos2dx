---
-- 第一周签到model层
--@module FirstSignModel

local FirstSignModel = {
    _data = nil,
    dataChangeEventType = "FIRSTSIGN_MODEL_DATA_CHANGE", --{type=,}
    _killedCount = nil,
    showEffect = true,
    _stateData = nil,
    status = {
        noSigned = 0,
        signed = 1
    }
}

---
-- @function [parent=#FirstSignModel] init
-- @param #FirstSignModel self
-- @param #table data
function FirstSignModel:init(data)
    self._data = data.firstSign
    if self._data.days then
        ch.FirstSignModel:setStateData()
    end
end

---
-- @function [parent=#FirstSignModel] clean
-- @param #FirstSignModel self
function FirstSignModel:clean()
    self._data = nil
    self._killedCount = nil
    self.showEffect = true
    self._stateData = nil
end

function FirstSignModel:_raiseDataChangeEvent()
    local evt = {
        type = self.dataChangeEventType,
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 是否是第一周活动
-- @function [parent=#FirstSignModel] isFirstSign
-- @param #FirstSignModel self
-- @return #boolean
function FirstSignModel:isFirstSign()
    if self._data.endTime and self._data.endTime > os_time() then
        return true
    end
    return false
end

---
-- 签到类型
-- @function [parent=#FirstSignModel] getSignType
-- @param #FirstSignModel self
-- @return #number
function FirstSignModel:getSignType()
    if self._data.endTime and self._data.endTime > os_time() then
        return 1
    end
    return 2
end

---
-- 获得今天是第几天
-- @function [parent=#FirstSignModel] getSignDays
-- @param #FirstSignModel self
-- @return #number
function FirstSignModel:getSignDays()
    return self._data.days
end



---
-- 获得今天的第几次登陆
-- @function [parent=#FirstSignModel] getLoginCount
-- @param #FirstSignModel self
-- @return #number
function FirstSignModel:getLoginCount()
    return self._data.count
end

---
-- 获得签到的状态(默认当天)
-- @function [parent=#FirstSignModel] getSignStatus
-- @param #FirstSignModel self
-- @param #number day
-- @return #number  0不可领1可领奖2已领奖3不到时间
function FirstSignModel:getSignStatus(day)
    local index = day or self._data.days
    return self._stateData[index]
end

---
-- 设置当前活动完成状态 0不可领1可领奖2已领奖3不到时间
-- @function [parent=#FirstSignModel] setStateData
-- @param #FirstSignModel self
function FirstSignModel:setStateData()
    self._stateData = {}
    if self._data.getReward and table.maxn(self._data.getReward) > 0 then
        for k,v in pairs(self._data.getReward) do
            self._stateData[tonumber(v)] = 2
        end
    end
    for i = 1,7 do
        if i>self._data.days then
            self._stateData[i] = 3
        elseif i == self._data.days then
            if self._stateData[i] and self._stateData[i] == 2 then
                self._stateData[i] = 2
            else
                self._stateData[i] = 1
            end
        elseif not self._stateData[i] then
            self._stateData[i] = 0
        end
    end
end


--- 签到
-- @function [parent=#FirstSignModel] sign
-- @param #FirstSignModel self
function FirstSignModel:sign()
    if self._stateData[self._data.days] == 2 then
        return
    end
    self._stateData[self._data.days] = 2
    table.insert(self._data.getReward,self._data.days)
    self:_raiseDataChangeEvent()
end

---
-- 过天刷新（刷新任务）
-- @function [parent=#FirstSignModel] onNextDay
-- @param #FirstSignModel self
function FirstSignModel:onNextDay()
    if self._data.endTime and self._data.endTime > os_time() then
        if self._data.days == 7 then
            self._data.endTime = 0
        else
            self._data.days = self._data.days + 1
            ch.FirstSignModel:setStateData()
        end
        self:_raiseDataChangeEvent()
    end
end

return FirstSignModel