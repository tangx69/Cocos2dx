---
-- 每日限购model层
--@module BuyLimitModel
local BuyLimitModel = {
    _data = nil,
    _day = 0,
    isEnd = true,
    isEffect = false,
    dataChangeEventType = "BUY_LIMIT_MODEL_DATA_CHANGE", --{type=,}
    status = {
        count = 0,
        nextday = 1
    }
}

---
-- @function [parent=#BuyLimitModel] init
-- @param #BuyLimitModel self
-- @param #table data
function BuyLimitModel:init(data)
    self._data = data.buylimit or {}   
    if self._data and self._data.openTime then
        self._day = 1 + math.ceil((os_time()-ch.CommonFunc:getAppointedTime(self._data.openTime,24))/(24*3600))
    else
        self._data = {}
        self._day = 1
    end
end

---
-- 清理
-- @function [parent=#BuyLimitModel] clean
-- @param #BuyLimitModel self
function BuyLimitModel:clean()
    self._data = nil
    self._day = 0
    self.isEnd = true
    self.isEffect = false
end

function BuyLimitModel:_raiseDataChangeEvent()
    local evt = {
        type = self.dataChangeEventType,
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 获得活动开始数据
-- @function [parent=#BuyLimitModel] setStartData
-- @param #BuyLimitModel self
-- @param #table data
function BuyLimitModel:setStartData(data)
    self._data = data
    self._day = 1+math.ceil((os_time()-ch.CommonFunc:getAppointedTime(self._data.openTime,24))/(24*3600))
    self.isEffect = true
    self:_raiseDataChangeEvent()
end

---
-- 获得活动开始时间
-- @function [parent=#BuyLimitModel] getOpenTime
-- @param #BuyLimitModel self
-- @return #number
function BuyLimitModel:getOpenTime()
    return self._data.openTime or -1
end

---
-- 获得活动结束时间
-- @function [parent=#BuyLimitModel] getEndTime
-- @param #BuyLimitModel self
-- @return #number
function BuyLimitModel:getEndTime()
    return self._data.endTime or -1
end

---
-- 获得活动方案号
-- @function [parent=#BuyLimitModel] getCfgid
-- @param #BuyLimitModel self
-- @return #string 
function BuyLimitModel:getCfgid()
    return self._data.cfgid or "mrxg01"
end

---
-- 获得今日是活动第几天
-- @function [parent=#BuyLimitModel] getDay
-- @param #BuyLimitModel self
-- @return #number 
function BuyLimitModel:getDay()
    return self._day or 1
end

---
-- 获得活动剩余天数
-- @function [parent=#BuyLimitModel] getLastDay
-- @param #BuyLimitModel self
-- @return #number 
function BuyLimitModel:getLastDay()
    return math.ceil((self._data.endTime-os_time())/(24*3600))
end

---
-- 获得今日刷新剩余时间
-- @function [parent=#BuyLimitModel] getRefreshTime
-- @param #BuyLimitModel self
-- @return #table {hour = 1,mintue =1,second =20}
function BuyLimitModel:getRefreshTime()
    local time = 0
    if self:getLastDay() > 1 then
        time = ch.CommonFunc:getZeroTime()-os_time()
    elseif self._data.endTime > os_time() then
        time = self._data.endTime-os_time()
    else
        if self.isEnd then
            self.isEnd = false
            self:_raiseDataChangeEvent()
        end
        return {hour=0,minute=0,second=0}
    end
    local tm = {}
    tm.hour = math.floor(time/3600)
    tm.minute = math.floor((time%3600)/60)
    tm.second = math.floor(time%60)
    return tm
end


---
-- 增加今日购买次数
-- @function [parent=#BuyLimitModel] addCountByIndex
-- @param #BuyLimitModel self
-- @param #string index
-- @param #number num
function BuyLimitModel:addCountByIndex(index,num)
    if self._data and self._data.count then
        if self._data.count[tostring(index)] then
            self._data.count[tostring(index)] = self._data.count[tostring(index)] + num
        else
            self._data.count[tostring(index)] = num 
        end
        self:_raiseDataChangeEvent()
    end
end

---
-- 获得今日购买次数
-- @function [parent=#BuyLimitModel] getCountByIndex
-- @param #BuyLimitModel self
-- @param #string index
-- @return #number 
function BuyLimitModel:getCountByIndex(index)
    if self._data and self._data.count and self._data.count[tostring(index)] then
        return self._data.count[tostring(index)]
    end
    return 0
end

---
-- 获得今日数据
-- @function [parent=#BuyLimitModel] getTodayData
-- @param #BuyLimitModel self
-- @param #number index
-- @return #table 
function BuyLimitModel:getTodayData(index)
    return GameConfig.MrxgConfig:getData(ch.BuyLimitModel:getCfgid(),ch.BuyLimitModel:getDay(),index)
end

---
-- 获得奖励图标
-- @function [parent=#BuyLimitModel] getRewardIcon
-- @param #BuyLimitModel self
-- @param #number cfgid
-- @param #number day
-- @param #number index
-- @return #string
function BuyLimitModel:getRewardIcon(cfgid,day,index)
    local data = GameConfig.MrxgConfig:getData(cfgid,day,index)
    local type = data.rewardType
    local index =""
    if type == 1 then
        index = "db"..data.rewardId
    elseif type == 2 then
        index = "cw"..data.rewardId
    elseif type == 3 then
        index = "bf"..data.rewardId
    elseif type == 4 then    
        return GameConst.MSG_FJ_ICON[1]["db90002"]
    elseif type == 5 then
        if data.rewardId >51000 then
            return GameConst.CARD_GET_ICON.chips
        else
            return GameConst.CARD_GET_ICON.card
        end
    elseif type == 6 then
        if data.rewardId == 40100 then
            return GameConst.MSG_FJ_ICON[1]["db90004"]
        elseif data.rewardId == 40101 then
            return GameConst.MSG_FJ_ICON[1]["db90003"]
        end
    elseif type == 7 then
        return "res/icon/icon_boss.png"
    end
    return GameConst.MSG_FJ_ICON[type][index]
end

---
-- 获得奖励数量
-- @function [parent=#BuyLimitModel] getRewardValue
-- @param #BuyLimitModel self
-- @param #number cfgid
-- @param #number day
-- @param #number index
-- @return #string
function BuyLimitModel:getRewardValue(cfgid,day,index)
    local type = GameConfig.MrxgConfig:getData(cfgid,day,index).rewardType
    local num = GameConfig.MrxgConfig:getData(cfgid,day,index).rewardValue
    if type == 3 then
        return string.format(Language.MSG_G_HOUR,num/3600)
    elseif type == 4 then
        local tmpNum = ch.CommonFunc:getOffLineGold(num)
        return ch.NumberHelper:toString(tmpNum)
    elseif type == 6 then
        local level = math.floor(ch.StatisticsModel:getMaxLevel()/5)*5
        local tmpNum = math.floor(ch.LevelController:getPrimalHeroSoulRewards(level)*num)
        if tmpNum < 1 then
            tmpNum = 1
        end
        return tmpNum
    else
        return ch.NumberHelper:toString(num)
    end
end

---
-- 商品名称
-- @function [parent=#BuyLimitModel] getName
-- @param #BuyLimitModel self
-- @param #number index
-- @return #string 
function BuyLimitModel:getName(index)
    local data = ch.BuyLimitModel:getTodayData(1)
    local num = self:getRewardValue(ch.BuyLimitModel:getCfgid(),ch.BuyLimitModel:getDay(),index)
    if data.rewardId == 40001 then
        return data.name .. "("..num..GameConst.MSG_FJ_NAME[1]["db90002"]..")"
    elseif data.rewardId == 40100 then
        return data.name .. "("..num..GameConst.MSG_FJ_NAME[1]["db90004"]..")"
    elseif data.rewardId == 40101 then
        return data.name .. "("..num..GameConst.MSG_FJ_NAME[1]["db90003"]..")"
    else
        return string.format(data.name,ch.CommonFunc:getRewardName(data.rewardType,data.rewardId))
    end
end

---
-- 打开过限购界面
-- @function [parent=#BuyLimitModel] openPanel
-- @param #BuyLimitModel self
function BuyLimitModel:openPanel()
    self.isEffect = false
    self:_raiseDataChangeEvent()
end

---
-- 过天刷新
-- @function [parent=#BuyLimitModel] onNextDay
-- @param #BuyLimitModel self
function BuyLimitModel:onNextDay()
    if self._data then
        if self._data.endTime and self._data.endTime > os_time() then
            self._day = self._day + 1
            self._data.count = {}
        end
        self.isEffect = true
        self:_raiseDataChangeEvent()
    end  
end

return BuyLimitModel