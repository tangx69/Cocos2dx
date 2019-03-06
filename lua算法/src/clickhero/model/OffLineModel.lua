---
-- OffLineModel
--@module OffLineModel
local OffLineModel = {
    _data = nil,
    dataChangeEventType = "OffLineRewardDataChange", --{type = ,dataType =}
    dataType = {
        gold = 1,
        reward = 2
    }
}

---
-- @function [parent=#OffLineModel] init
-- @param self #OffLineModel
-- @param #table data
function OffLineModel:init(data)
    self._data = data.offLineGold
    if self._data.num then
        self._data.num = ch.LongDouble:toLongDouble(tostring(self._data.num))
    end
    if self._data.reward then
        for k,it in pairs(self._data.reward) do
            ch.CommonFunc:formateItems(it.items)
        end
    end
end

---
-- @function [parent=#OffLineModel] clean
-- @param #OffLineModel self
function OffLineModel:clean()
    self._data = nil
end

function OffLineModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 获取奖励列表
-- @function [parent=#OffLineModel] test
-- @param #OffLineModel self
-- @return #table
function OffLineModel:test()
    self._data={}
    self._data.reward = {type=1,items={{id=90002,num=10000000,t=1}}}
    self:_raiseDataChangeEvent(self.dataType.reward)
end





---
-- 获取奖励列表
-- @function [parent=#OffLineModel] getRewardList
-- @param #OffLineModel self
-- @return #table
function OffLineModel:getRewardList()
    return self._data.reward
end

---
-- 领取奖励后移除卡片
-- @function [parent=#OffLineModel] clearRewardList
-- @param #OffLineModel self
-- @param #number type
function OffLineModel:clearRewardList(type)
    for i,v in ipairs(self._data.reward) do
        if v.type == type then
            self._data.reward[i] = nil
            break
        end
    end
    self:_raiseDataChangeEvent(self.dataType.reward)
end

---
-- 关于轮回
-- @function [parent=#OffLineModel] onSamsara
-- @param #OffLineModel self
function OffLineModel:onSamsara()
    self._data.reward = {}
    self:_raiseDataChangeEvent(self.dataType.reward)
end
return OffLineModel