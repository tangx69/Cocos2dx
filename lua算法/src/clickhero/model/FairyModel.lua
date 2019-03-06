---
-- 小仙女 model层     结构 {numrefresh = 3}
--@module FairyModel
local FairyModel = {
    _data = nil
}

---
-- @function [parent=#FairyModel] init
-- @param #FairyModel self
-- @param #table data
function FairyModel:init(data)
    self._data = data.fairy
end

---
-- @function [parent=#FairyModel] clean
-- @param #FairyModel self
function FairyModel:clean()
    self._data = nil
end

---
-- 获得已经刷新的次数
-- @function [parent=#FairyModel] getCount
-- @param #FairyModel self
-- @return #number
function FairyModel:getCount()
    return self._data["count"]
end

---
-- 添加已经刷新的次数
-- @function [parent=#FairyModel] addCount
-- @param #FairyModel self
-- @param #number count
function FairyModel:addCount(count)
    count = count or 1
    self._data["count"] = self._data["count"] + count
end

---
-- 过天逻辑
-- @function [parent=#FairyModel] onNextDay
-- @param #FairyModel self
function FairyModel:onNextDay()
    self._data["count"] = 0
end

return FairyModel