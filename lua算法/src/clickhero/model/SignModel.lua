---
-- 签到model层
--@module SignModel

local SignModel = {
    _data = nil,
    dataChangeEventType = "SIGN_MODEL_DATA_CHANGE", --{type=,}
    effectChangeEventType = "EFFECT_SIGN_DATA_CHANGE",
    _killedCount = nil,
    showEffect = false,
    status = {
        noSigned = 0,
        signed = 1
    }
}

---
-- @function [parent=#SignModel] init
-- @param #SignModel self
-- @param #table data
function SignModel:init(data)
    self._data = data.sign
    self._data.days = self._data.days or 0
    self._data.status = self._data.status or 0
    self._data.count = self._data.count or 0
end

---
-- @function [parent=#SignModel] clean
-- @param #SignModel self
function SignModel:clean()
    self._data = nil
    self._killedCount = nil
    self.showEffect = nil
end

function SignModel:_raiseDataChangeEvent()
    local evt = {
        type = self.dataChangeEventType,
    }
    zzy.EventManager:dispatch(evt)
end

function SignModel:effectDataChangeEvent()
    local evt = {
        type = self.effectChangeEventType,
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 获得签到的天数
-- @function [parent=#SignModel] getSignDays
-- @param #SignModel self
-- @return #number
function SignModel:getSignDays()
    return self._data.days
end

---
-- 获得签到的状态
-- @function [parent=#SignModel] getSignStatus
-- @param #SignModel self
-- @return #number 0 为未签到，1为已签到
function SignModel:getSignStatus()
    return self._data.status
end

---
-- 获得今天的第几次登陆
-- @function [parent=#SignModel] getLoginCount
-- @param #SignModel self
-- @return #number
function SignModel:getLoginCount()
    return self._data.count
end

---
-- @function [parent=#SignModel] sign
-- @param #SignModel self
function SignModel:sign()
    if SignModel._data.status == 1 then return end
    SignModel._data.days = SignModel._data.days + 1
    SignModel._data.status = 1
    self:_raiseDataChangeEvent()
end

---
-- 获得奖励图标
-- @function [parent=#SignModel] getRewardIcon
-- @param #SignModel self
-- @param #number ty
-- @param #number id
-- @return #string
function SignModel:getRewardIcon(ty,id)
    local data = GameConfig.SignConfig:getData(ty,id)
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
-- @function [parent=#SignModel] getRewardValue
-- @param #SignModel self
-- @param #number ty
-- @param #number id
-- @return #string
function SignModel:getRewardValue(ty,id)
    local type = GameConfig.SignConfig:getData(ty,id).rewardType
    local num = GameConfig.SignConfig:getData(ty,id).rewardValue
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
-- 过天刷新（刷新任务）
-- @function [parent=#SignModel] onNextDay
-- @param #SignModel self
function SignModel:onNextDay()
    if self._data.days == 7 then
        self._data.days = 0
    end
    self._data.status = 0
    self:_raiseDataChangeEvent()
end

---
-- 是否要显示光效
-- @function [parent=#SignModel] setShowEffect
-- @param #SignModel self
-- @param #boolean isShow
function SignModel:setShowEffect(isShow)
    self.showEffect = isShow
    self:_raiseDataChangeEvent()
end

---
-- 是否要显示光效
-- @function [parent=#SignModel] getShowEffect
-- @param #SignModel self
-- @return #boolean
function SignModel:getShowEffect()
    return self.showEffect
end

---
-- 红点显示条件1签到2坚守阵地3魔宠试炼4骑士盛宴5无尽征途6黑市商店7天梯挑战8分享9淘金矿区
-- @function [parent=#SignModel] getRedPointByType
-- @param #SignModel self
-- @param #number type
-- @return #boolean
function SignModel:getRedPointByType(type)
    if type == 1 then
        return (ch.FirstSignModel:isFirstSign() and ch.FirstSignModel:getSignStatus() ~= 2) 
            or (not ch.FirstSignModel:isFirstSign() and ch.SignModel:getSignStatus() == 0)
    elseif type == 2 then
        local ifOpenDefend = cc.UserDefault:getInstance():getStringForKey("ifOpenDefend")
        -- 活动提醒每天一次
        return ch.StatisticsModel:getMaxLevel()>GameConst.DEFEND_OPEN_LEVEL 
            and ch.DefendModel:getTimes() < GameConst.DEFEND_DAY_MAX_COUNT
            and tonumber(ifOpenDefend) ~= ch.CommonFunc:getZeroTime(os_time())
    elseif type == 3 then
        return ch.StatisticsModel:getMaxLevel()>GameConst.CARD_FB_OPEN_LEVEL 
            and ch.CardFBModel:getStamina() >= GameConst.CARD_FB_MAX_STAMINA
    elseif type == 4 then
        return ch.StatisticsModel:getMaxLevel()>GameConst.CARD_FB_OPEN_LEVEL 
            and ch.CardFBModel:canFetched()
    elseif type == 5 then
        local ifOpenWarpath = cc.UserDefault:getInstance():getStringForKey("ifOpenWarpath")
        -- 活动提醒每天一次
        return ch.WarpathModel:isOpen() 
            and ch.WarpathModel:getTimes() < 1
            and tonumber(ifOpenWarpath) ~= ch.CommonFunc:getZeroTime(os_time())
    elseif type == 6 then
        return ch.StatisticsModel:getMaxLevel()>GameConst.RANDOM_SHOP_BLACK_OPEN_LEVEL 
            and ch.RandomShopModel:ifBlackRefresh() 
    elseif type == 7 then
        local ifOpenArena = cc.UserDefault:getInstance():getStringForKey("ifOpenArena")
        -- 活动提醒每天一次
        return ch.StatisticsModel:getMaxLevel()>GameConst.ARENA_OPEN_LEVEL
            and ch.ArenaModel:getChallengeNum() > 0 
            and tonumber(ifOpenArena) ~= ch.CommonFunc:getZeroTime(os_time())
    elseif type == 8 then
        return (zzy.Sdk.getFlag()=="HDIOS" or zzy.Sdk.getFlag()=="HDXGS")
            and zzy.cUtils.getVersion()~="1.11.5" 
            and ch.ShareModel:getTodayShareState()
    elseif type == 9 then
        local ifOpenMine = cc.UserDefault:getInstance():getStringForKey("ifOpenMine")
        -- 活动提醒每天一次
        return ch.StatisticsModel:getMaxLevel()>GameConst.MINE_OPEN_LEVEL 
            and ch.MineModel:getMyMineId() <= 0 and ch.MineModel:getAttNum() > 0
            and tonumber(ifOpenMine) ~= ch.CommonFunc:getZeroTime(os_time())
    end
    return false
end

---
-- 主界面红点显示条件
-- @function [parent=#SignModel] getRedPointALL
-- @param #SignModel self
-- @return #boolean
function SignModel:getRedPointALL()
    for i = 1,9 do
        if self:getRedPointByType(i) then
            return true
        end
    end
    return false
end

return SignModel