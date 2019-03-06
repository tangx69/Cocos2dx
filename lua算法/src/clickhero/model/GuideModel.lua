---
-- 引导 model层     结构 "guide":{guide:{10010,10020}}
--@module GuideModel
local GuideModel = {
    _data = nil,
}

---
-- @function [parent=#GuideModel] init
-- @param #GuideModel self
-- @param #table data
function GuideModel:init(data)
    if data and data.guide and data.guide.guide then
        self._data = data.guide.guide
    else
        self._data = {guide={}}
    end
end

---
-- @function [parent=#GuideModel] clean
-- @param #GuideModel self
function GuideModel:clean()
    self._data = nil
end

---
-- 获取引导数据
-- @function [parent=#GuideModel] getGuideData
-- @param #GuideModel self
-- @return #table
function GuideModel:getGuideData()
    return self._data
end

return GuideModel