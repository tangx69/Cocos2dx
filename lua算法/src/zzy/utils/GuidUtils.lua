---
-- guid工具
-- @module GuidUtils
local GuidUtils = {
    _clock = 0,
    _num = 0,
    _orderIndex=0,
}

---
-- 获取一个Guid
-- @function [parent=#GuidUtils] getGuid
-- @param self
-- @return #string ret
function GuidUtils:getGuid()
    local clock = tostring(os_clock())
    if clock == self._clock then
        self._num = self._num + 1
    else
        self._num = 0
    end
    self._clock = clock
    local str = string.format("%s_%d", self._clock, self._num)
--    return md5.sumhexa(str)
    return str
end

---
-- 获取一个指令序号 每次加1
-- @function [parent=#GuidUtils] getOrderIndex
-- @param self
-- @return #string ret
function GuidUtils:getOrderIndex()
    self._orderIndex = self._orderIndex + 1
    return self._orderIndex
end

---
-- 清理指令序号
-- @function [parent=#GuidUtils] cleanOrderIndex
-- @param self
function GuidUtils:cleanOrderIndex()
    self._orderIndex = 0
end


return GuidUtils
