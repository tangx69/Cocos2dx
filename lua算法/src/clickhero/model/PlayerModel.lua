---
-- PlayerModel     结构 {name = "无名勇者"}
--@module PlayerModel
local PlayerModel = {
    _data = nil,
    dataChangeEventType = "PlayModelDataChange", --{type = ,dataType =}
    offLineGetEventType = "OffLineGetGold", -- 领取挂机奖励事件
    samsaraCleanOffLineEventType = "samsaraCleanOffLine", -- 转生清除离线收益
    allDPSChangeEventType = "AllDPSChange",  -- dps改变事件
    payOpenShopEventType = "payOpenShopEventType", -- 充值打开商店
    channeluser=0,--平台的userid
    usertype=0,  --0 普通用户 1 测试用户（可以看见测试服务器） 
    dataType = {
        name = 1,
        gender = 2
    }
}

---
-- @function [parent=#PlayerModel] init
-- @param self #PlayerModel
-- @param #table data
function PlayerModel:init(data)
    self._data = data.player
    self._data.pid = data.id
end

function PlayerModel:getPid()
    return self._data.pid
end

---
-- @function [parent=#PlayerModel] clean
-- @param #PlayerModel self
function PlayerModel:clean()
    self._data = nil
end

function PlayerModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 设置玩家名字
-- @function [parent=#PlayerModel] setPlayerName
-- @param #PlayerModel self
-- @param #string name
function PlayerModel:setPlayerName(name)
    self._data.name = name
    self:addChangeNum(1)
    PlayerModel:_raiseDataChangeEvent(self.dataType.name)
end

---
-- 获得玩家名字
-- @function [parent=#PlayerModel] getPlayerName
-- @param #PlayerModel self
-- @return #string name
function PlayerModel:getPlayerName()
    return self._data.name
end

---
-- 设置玩家性别
-- @function [parent=#PlayerModel] setPlayerGender
-- @param #PlayerModel self
-- @param #number gender
function PlayerModel:setPlayerGender(gender)
    self._data.gender = gender
    ch.UserTitleModel:_computeTitle(ch.StatisticsModel:getMaxLevel()-1,self._data.gender)
    ch.fightRoleLayer:changeMainRoleAvatar(ch.UserTitleModel:getAvatar(),ch.UserTitleModel:getWeapon())
    PlayerModel:_raiseDataChangeEvent(self.dataType.gender)
end

---
-- 获得玩家性别
-- @function [parent=#PlayerModel] getPlayerGender
-- @param #PlayerModel self
-- @return #number
function PlayerModel:getPlayerGender()
    if self._data.gender == 0 then
        self._data.gender = nil
    end
    return self._data.gender
end

---
-- 获得玩家服id
-- @function [parent=#PlayerModel] getZoneID
-- @param #PlayerModel self
-- @return #string zoneId
function PlayerModel:getZoneID()
    return self._data.zoneId
end

---
-- 获得玩家唯一ID
-- @function [parent=#PlayerModel] getPlayerUnid
-- @param #PlayerModel self
-- @return #string name
function PlayerModel:getPlayerUnid()
    return self._data.unid or ""
end

---
-- 获得玩家账号id
-- @function [parent=#PlayerModel] getPlayerID
-- @param #PlayerModel self
-- @return #string id
function PlayerModel:getPlayerID()
    local userid
    if self._data.id then
        --userid = self._data.pid --tgx
        userid = self._data.pid --tgx
    else
        userid = "ididid"
    end
    return userid
end

---
-- 设置改名次数
-- @function [parent=#PlayerModel] setChangeNum
-- @param #PlayerModel self
-- @param #number num
function PlayerModel:setChangeNum(num)
    self._data.changeNum = num
    PlayerModel:_raiseDataChangeEvent(self.dataType.name)
end

---
-- 获得改名次数
-- @function [parent=#PlayerModel] getChangeNum
-- @param #PlayerModel self
-- @return #number num
function PlayerModel:getChangeNum()
    return self._data.changeNum
end

---
-- 增加改名次数
-- @function [parent=#PlayerModel] addChangeNum
-- @param #PlayerModel self
-- @param #number num
function PlayerModel:addChangeNum(num)
    self._data.changeNum = self._data.changeNum + num
end

function PlayerModel:getLastLoginTime()
    return self._data.lastLoginTime or 0
end

function PlayerModel:getRegTime()
    return self._data.registerTime or 0
end

return PlayerModel