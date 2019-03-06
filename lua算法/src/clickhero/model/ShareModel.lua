---
-- ShareModel
-- @module src.clickhero.model.ShareModel
-- @param _todayShareState bool 今日分享是否满足条件
local ShareModel = {
    _data = nil,
    _todayShareState = nil,
    _curShareData = nil,
    _curShareJsonStr = nil,
    _shareAwardData = nil,
    dataChangeEventType = "SHARE_DATA_CHANGE", --{type = ,dataType =}
}

---
--@function [parent=#ShareModel] init
--@param self ShareModel
--@param #table data
function ShareModel:init(data)
	self._data = data.share
end

---
-- @function [parent=#ShareModel] clean
-- @param #ShareModel self
function ShareModel:clean()
    self._data = nil
    self._todayShareState = nil
    self._curShareData = nil
    self._shareAwardData = nil
end

---
--获取今日分享
--@function [parent=#ShareModel] init
--@param self ShareModel
--@param #table data
function ShareModel:getTodayShare()
	return self._data.today
end

---
--获取成就分享
--@function [parent=#ShareModel] init
--@param self ShareModel
--@param #table data
function ShareModel:getAchievementShare()
    return self._data.achi
end

---
--设置今日分享是否达成条件
--@function [parent=#ShareModel] setTodayShareState
--@param self ShareModel
--@param #table data
function ShareModel:setTodayShareState(state)
    self._todayShareState = state
end

---
--获取今日分享是否达成条件
--@function [parent=#ShareModel] getTodayShareState
--@param self ShareModel
--@param #table data
function ShareModel:getTodayShareState()
    return self._todayShareState
end

---
--设置当前分享的数据
--@function [parent=#ShareModel] setCurShareData
--@param self ShareModel
--@param #table data
function ShareModel:setCurShareData(data)
    self._curShareData = data
end

---
--获取当前分享的数据
--@function [parent=#ShareModel] getCurShareData
--@param self ShareModel
--@param #table data
function ShareModel:getCurShareData()
    return self._curShareData
end

---
--设置分享奖励的数据
--@function [parent=#ShareModel] setShareAwardData
--@param self ShareModel
--@param #table data
function ShareModel:setShareAwardData(data)
    self._shareAwardData = data
    self:_raiseDataChangeEvent()
end

---
--获取分享奖励的数据
--@function [parent=#ShareModel] getCurShareData
--@param self ShareModel
--@return #table data
function ShareModel:getShareAwardData()
    return self._shareAwardData
end

---
--设置当前要分享的json字符串
--@function [parent=#ShareModel] setShareJsonStr
--@param self ShareModel
--@param #table data
function ShareModel:setShareJsonStr(data)
    self._curShareJsonStr = data
end

---
--获取分享奖励的数据
--@function [parent=#ShareModel] getShareJsonStr
--@param self ShareModel
--@return #string
function ShareModel:getShareJsonStr()
    return self._curShareJsonStr
end

---
--清除领取分享奖励的数据
--@function [parent=#ShareModel] clearShareAwardData
--@param self ShareModel
--@return #table data
function ShareModel:clearShareAwardData()
	self._shareAwardData = {}
    self:_raiseDataChangeEvent()
end

---
--更新分享的数据
--@function [parent=#ShareModel] updateShareData
--@param self ShareModel
function ShareModel:updateShareData(udata)
    if udata ~= nil then
        if udata.f == "today" then
            if udata.type == 0 then --微信
                self._data.today[1] = 1
            elseif udata.type == 1 then --微博
                self._data.today[2] = 1
            elseif udata.type == 2 then --Facebook
                self._data.today[1] = 1
            else
            end
        elseif udata.f == "achi" then
            if udata.type == 0 then --微信
                self._data.achi[udata.id][1] = 1
            elseif udata.type == 1 then --微博
                self._data.achi[udata.id][2] = 1
            elseif udata.type == 2 then --Facebook
                self._data.achi[udata.id][1] = 1
            end
        end
    end
end

function ShareModel:_raiseDataChangeEvent()
    local evt = {
        type = self.dataChangeEventType,
    }
    
    zzy.EventManager:dispatch(evt)
end

function ShareModel:onNextDay()
    ch.ShopModel:updateLocalSvrDays()
    self:_raiseDataChangeEvent()
end

return ShareModel