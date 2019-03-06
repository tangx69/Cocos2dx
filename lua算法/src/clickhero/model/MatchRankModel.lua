---
-- 特殊排行榜 model层 
--@module MatchRankModel
local MatchRankModel = {
    _data = nil,
    _timeData = nil,
    _playerData = nil,
    _myData = nil,
    dataChangeEventType = "MatchRankModelDataChange", --{type = ,id=,dataType =}
    dataType = {
        level = 1,
        list = 2,
        player = 3
    }
}

---
-- @function [parent=#MatchRankModel] init
-- @param #MatchRankModel self
-- @param #table data
function MatchRankModel:init(data)
    self._data = data.matchrank
    self._timeData = {}
    if self._data and self._data.reward then
        for k,v in pairs(self._data.reward) do
            self._timeData[v.typeId] = v
        end
    end
    self._myData = {}
    self._playerData = {}
end

---
-- @function [parent=#MatchRankModel] clean
-- @param #MatchRankModel self
function MatchRankModel:clean()
    self._data = nil
    self._timeData = nil
    self._playerData = nil
    self._myData = nil
end

function MatchRankModel:_raiseDataChangeEvent(typeId,dataType)
    local evt = {
        type = self.dataChangeEventType,
        id = typeId,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---接收到开始活动数据
-- @function [parent=#MatchRankModel] setTime
-- @param #MatchRankModel self
-- @param #table data
function MatchRankModel:setTime(data)
    if not self._timeData then
        self._timeData = {}
    end
    self._timeData[data.typeId] = data
    
end

---活动时间
-- @function [parent=#MatchRankModel] getTime
-- @param #MatchRankModel self
-- @return #table
function MatchRankModel:getTime(typeId)
    return self._timeData[typeId]
end

---
-- 获得活动结束倒计时
-- @function [parent=#MatchRankModel] getEndTimeCD
-- @param #MatchRankModel self
-- @return #number
function MatchRankModel:getEndTimeCD(typeId)
    if self._timeData and self._timeData[typeId] then
        local leftTime = self._timeData[typeId].endTime - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---卡片信息
-- @function [parent=#MatchRankModel] getOpenData
-- @param #MatchRankModel self
-- @return #table
function MatchRankModel:getOpenData()
    local tmpData = {}
    for k,v in pairs(self._timeData) do
        if v.openTime < os_time() and v.endTime > os_time() then
            local config = GameConfig.Rank_cfgConfig:getData(v.typeId,v.cfgId)
            local card = {icon = config.icon,name=config.name,btnText=Language.src_clickhero_model_MatchRankModel_1,getImage="aaui_common/dot1.png",typeId=v.typeId,cfgId=v.cfgId,type=3}
            table.insert(tmpData,card)
        end
    end
    return tmpData
end

---排行榜列表
-- @function [parent=#MatchRankModel] setListData
-- @param #MatchRankModel self
-- @param #table data
function MatchRankModel:setListData(data)
    self._myData = {}
    self._myData.rank = data.num
    self._myData.percent = data.per
    local harmText = GameConfig.Rank_cfgConfig:getData(data.typeId,data.cfgId).harmText
    self._playerData = {}
    for k,v in pairs(data.pl) do
        self._playerData[k] = v
        self._playerData[k].harmText = harmText
    end
end

---排行榜列表
-- @function [parent=#MatchRankModel] getListData
-- @param #MatchRankModel self
-- @return #table
function MatchRankModel:getListData()
    return self._playerData
end

---我的排名
-- @function [parent=#MatchRankModel] getMyRank
-- @param #MatchRankModel self
-- @return #number
function MatchRankModel:getMyRank()
    return self._myData.rank
end

---我打败的百分比
-- @function [parent=#MatchRankModel] getMyPercent
-- @param #MatchRankModel self
-- @return #number
function MatchRankModel:getMyPercent()
    return self._myData.percent
end

---奖励展示信息
-- @function [parent=#MatchRankModel] getRewardData
-- @param #MatchRankModel self
-- @param #number rewardId
-- @param #number myRank
-- @return #table
function MatchRankModel:getRewardData(rewardId,myRank)
    local rewardData = {}
    rewardData.all = {}
    local tmpTable = GameConfig.Rank_awardConfig:getTable1(rewardId)
    for k,v in ipairs(tmpTable) do
        local tmpData = v
        if v.from == v.to then
        	tmpData.rank = string.format(Language.src_clickhero_model_MatchRankModel_2,v.to)
        else
            tmpData.rank = string.format(Language.src_clickhero_model_MatchRankModel_3,v.to)
        end
        if v.idty2 and v.idty2 >0 then
            v.vis2 = true
        else
            v.vis2 = false
        end
        if v.idty3 and v.idty3 > 0 then
            v.vis3 = true
        else
            v.vis3 = false
        end
        table.insert(rewardData.all,tmpData)
        if myRank <= v.to and myRank >= v.from then
            rewardData.myData = tmpData
            rewardData.myData.vis1 = true
        end
    end
    if not rewardData.myData then
        rewardData.myData = {rank = 0,idty1=0,id1=0,num1=0,idty2=0,id2=0,num2=0,idty3=0,id3=0,num3=0}
        rewardData.myData.vis1=false
        rewardData.myData.vis2=false
        rewardData.myData.vis3=false
     end
    return rewardData
end


---
-- 获得奖励图标
-- @function [parent=#MatchRankModel] getRewardIcon
-- @param #MatchRankModel self
-- @param #number type
-- @param #number id
-- @return #string
function MatchRankModel:getRewardIcon(type,id)
    if type == 0 then
        return "res/icon/moneyGolds.png"
    end
    local index =""
    if type == 1 then
        index = "db"..id
    elseif type == 2 then
        index = "cw"..id
    elseif type == 3 then
        index = "bf"..id
    elseif type == 4 then
        return GameConst.MSG_FJ_ICON[1]["db90002"]
    elseif type == 5 then
        if id >51000 then
            return GameConst.CARD_GET_ICON.chips
        else
            return GameConst.CARD_GET_ICON.card
        end
    elseif type == 6 then
        if id == 40100 then
            return GameConst.MSG_FJ_ICON[1]["db90004"]
        elseif id == 40101 then
            return GameConst.MSG_FJ_ICON[1]["db90003"]
        end
    elseif type == 7 then
        return "res/icon/icon_boss.png"
    end
    return GameConst.MSG_FJ_ICON[type][index]
end

---
-- 获得奖励名称
-- @function [parent=#MatchRankModel] getRewardName
-- @param #MatchRankModel self
-- @param #number type
-- @param #number id
-- @return #string
function MatchRankModel:getRewardName(type,id)
    if type == 0 then
        return ""
    end
    local index =""
    if type == 1 then
        index = "db"..id
    elseif type == 2 then
        index = "cw"..id
    elseif type == 3 then
        index = "bf"..id
    elseif type == 4 then
        return GameConst.MSG_FJ_NAME[1]["db90002"]
    elseif type == 5 then
        return GameConfig.CardConfig:getData(id).name
    elseif type == 6 then
        if id == 40100 then
            return GameConst.MSG_FJ_NAME[1]["db90004"]
        elseif id == 40101 then
            return GameConst.MSG_FJ_NAME[1]["db90003"]
        end
    elseif type == 7 then
        return GameConfig.FamiliarConfig:getData(id).name
    end
    return GameConst.MSG_FJ_NAME[type][index]
end

---
-- 获得奖励数量
-- @function [parent=#MatchRankModel] getRewardValue
-- @param #MatchRankModel self
-- @param #number type
-- @param #number id
-- @param #number num
-- @return #string
function MatchRankModel:getRewardValue(type,id,num)
    if type == 3 then
        return string.format(Language.MSG_G_HOUR,num/3600)
    elseif type == 4 then
        return string.format(Language.MSG_G_HOUR,num/3600)
--        local tmpNum = ch.CommonFunc:getOffLineGold(num)
--        return ch.NumberHelper:toString(tmpNum)
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


return MatchRankModel