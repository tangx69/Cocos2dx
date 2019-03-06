---
-- 统计model层
--@module StatisticsModel

local StatisticsModel = {
    _data = nil,
    _orderData = nil,
    _recentGold = nil,
    _recentGotGold = nil,
    _sid = nil,
    dataChangeEventType = "STATISTICS_MODEL_DATA_CHANGE", --{type=,dataType=,}
    maxLevelChangeEventType = "STATISTICS_MODEL_MAX_LEVEL",
    samsaraAddRTimesEventType = "SAMSARA_ADD_RTIMES",  -- 转生次数增加
    dataType = {
        rank = 1
    }
}

ENCODE_NUM = ENCODE_NUM or function(num)
    return num
end

DECODE_NUM = DECODE_NUM or function(num)
    return num
end

---
-- @function [parent=#StatisticsModel] init
-- @param #StatisticsModel self
-- @param #table data
function StatisticsModel:init(data)
    data.statistics.maxdps = ch.LongDouble:toLongDouble(tostring(data.statistics.maxdps))
    data.statistics.maxdps.num = ENCODE_NUM(data.statistics.maxdps.num)
    data.statistics.maxdps.exp = ENCODE_NUM(data.statistics.maxdps.exp)
    
    data.statistics.gotGold = ch.LongDouble:toLongDouble(tostring(data.statistics.gotGold))
    self._data = data.statistics
    self._recentGotGold = 0
    if self._data.playTime == 0 then
        self._data.playTime = os_time()
    end
    if not self._data.maxLevel or  self._data.maxLevel == 0 then
        self._data.maxLevel = 1
    end
    self:_order()
    self:_recordRecentGold()
end

---
-- 清理
-- @function [parent=#StatisticsModel] clean
-- @param #StatisticsModel self
function StatisticsModel:clean()
    self._data = nil
    self._orderData = nil
    self._recentGold = nil
    self._recentGotGold = nil
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sid)
    self._sid = nil
end

function StatisticsModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType =  dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 获取显示顺序的id
-- @function [parent=#StatisticsModel] getOrderData
-- @param #StatisticsModel self
-- @return #table
function StatisticsModel:getOrderData()
   return self._orderData
end

---
-- 获取有效的宠物出击数
-- @function [parent=#StatisticsModel] getClickTimes
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getClickTimes()
    return self._data.clickTimes or 0
end

---
-- 是否为新账户
-- @function [parent=#StatisticsModel] isNewPlayer
-- @param #StatisticsModel self
-- @return #Bool
function StatisticsModel:isNewPlayer()
    return os_time() - self._data.playTime < 15
end

---
-- 添加有效的宠物出击数
-- @function [parent=#StatisticsModel] addClickTimes
-- @param #StatisticsModel self
-- @param #number times
function StatisticsModel:addClickTimes(times)
    times = times or 1
    --    if not self._data.clickTimes then
    --        self._data.clickTimes = 0
    --    end
    self._data.clickTimes = self._data.clickTimes + times
end

---
-- 获取宠物最大秒速
-- @function [parent=#StatisticsModel] getMaxClickSpeed
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getMaxClickSpeed()
    return self._data.maxClickSpeed or 0
end

---
-- 设置宠物最大秒速
-- @function [parent=#StatisticsModel] setMaxClickSpeed
-- @param #StatisticsModel self
-- @param #number times
function StatisticsModel:setMaxClickSpeed(times)
    --    if not self._data.maxClickSpeed then
    --        self._data.maxClickSpeed = 0
    --    end
    if times > self._data.maxClickSpeed then
        self._data.maxClickSpeed = math.floor(times)
    end
end

--
-----
---- 获取有效的符文操作数
---- @function [parent=#StatisticsModel] getRunicTimes
---- @param #StatisticsModel self
---- @return #number
--function StatisticsModel:getRunicTimes()
--    return self._data.runicTimes or 0
--end
--
-----
---- 添加有效的符文操作数
---- @function [parent=#StatisticsModel] addRunicTimes
---- @param #StatisticsModel self
---- @param #number times
--function StatisticsModel:addRunicTimes(times)
--    times = times or 1
----    if not self._data.runicTimes then
----        self._data.runicTimes = 0
----    end
--    self._data.runicTimes = self._data.runicTimes + times
--end

---
-- 获取宠物操作暴击数
-- @function [parent=#StatisticsModel] getRunicCritTimes
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getRunicCritTimes()
    return self._data.runicCritTimes or 0
end

---
-- 添加宠物操作暴击数
-- @function [parent=#StatisticsModel] addRunicCritTimes
-- @param #StatisticsModel self
-- @param #number times
function StatisticsModel:addRunicCritTimes(times)
    times = times or 1
    --    if not self._data.runicTimes then
    --        self._data.runicTimes = 0
    --    end
    self._data.runicCritTimes = self._data.runicCritTimes + times
end

---
-- 获取符文最大连击数
-- @function [parent=#StatisticsModel] getMaxSeriesTimes
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getMaxSeriesTimes()
    return self._data.maxSeriesTimes or 0
end

---
-- 设置符文最大连击数
-- @function [parent=#StatisticsModel] setMaxSeriesTimes
-- @param #StatisticsModel self
-- @param #number times
function StatisticsModel:setMaxSeriesTimes(times)
--    if not self._data.maxSeriesTimes then
--        self._data.maxSeriesTimes = 0
--    end
    if times > self._data.maxSeriesTimes then
        self._data.maxSeriesTimes = times
    end
end

---
-- 获取击杀的小怪数
-- @function [parent=#StatisticsModel] getKilledMonsters
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getKilledMonsters()
    return self._data.killedMonsters or 0
end

---
-- 添加击杀的小怪数
-- @function [parent=#StatisticsModel] addKilledMonsters
-- @param #StatisticsModel self
-- @param #number count
function StatisticsModel:addKilledMonsters(count)
    count = count or 1
--    if not self._data.killedMonsters then
--        self._data.killedMonsters = 0
--    end
    self._data.killedMonsters = self._data.killedMonsters + count
end

---
-- 获取击杀的BOSS数
-- @function [parent=#StatisticsModel] getKilledBosses
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getKilledBosses()
    return self._data.killedBosses or 0
end

---
-- 添加击杀的Boss数
-- @function [parent=#StatisticsModel] addKilledBosses
-- @param #StatisticsModel self
-- @param #number count
function StatisticsModel:addKilledBosses(count)
    count = count or 1
--    if not self._data.killedBosses then
--        self._data.killedBosses = 0
--    end
    self._data.killedBosses = self._data.killedBosses + count
end

---
-- 获取击杀的宝箱数
-- @function [parent=#StatisticsModel] getKilledBoxes
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getKilledBoxes()
    return self._data.killedBoxes or 0
end

---
-- 添加击杀的宝箱数
-- @function [parent=#StatisticsModel] addKilledBoxes
-- @param #StatisticsModel self
-- @param #number count
function StatisticsModel:addKilledBoxes(count)
    count = count or 1
--    if not self._data.killedBoxes then
--        self._data.killedBoxes = 0
--    end
    self._data.killedBoxes = self._data.killedBoxes + count
end

---
-- 获取达到的最高关卡
-- @function [parent=#StatisticsModel] getMaxLevel
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getMaxLevel()
    return self._data.maxLevel
end

---
-- 设置达到的最高关卡
-- @function [parent=#StatisticsModel] setMaxLevel
-- @param #StatisticsModel self
-- @param #number level
function StatisticsModel:setMaxLevel(level)
    --    if not self._data.maxLevel then
    --        self._data.maxLevel = 0
    --    end
    if level > self._data.maxLevel then
        if role_info_t then
            role_info_t.roleLevel = tostring(level)
            role_info_t.roleLevelUpTime = tostring(os.time())
            local role_info_s = json.encode(role_info_t)
            DEBUG("[report]"..role_info_s)
            cc.libPlatform:getInstance():report("levelup", role_info_s)
        end
        self._data.maxLevel = level
        zzy.EventManager:dispatch({type = self.maxLevelChangeEventType})
    end
end

---
-- 获取轮回次数
-- @function [parent=#StatisticsModel] getRTimes
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getRTimes()
    return self._data.rTimes or 0
end

---
-- 添加轮回次数
-- @function [parent=#StatisticsModel] addRTimes
-- @param #StatisticsModel self
-- @param #number count
function StatisticsModel:addRTimes(count)
    count = count or 1
    --    if not self._data.rTimes then
    --        self._data.rTimes = 0
    --    end
    self._data.rTimes = self._data.rTimes + count
    local evt = {type = self.samsaraAddRTimesEventType}
    zzy.EventManager:dispatch(evt)
end

---
-- 获取累计游戏时间
-- @function [parent=#StatisticsModel] getPlayTime
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getPlayTime()
    return math.floor(os_time() - self._data.playTime)
end

---
-- 获取上一次轮回后的游戏时长
-- @function [parent=#StatisticsModel] getRTime
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getRTime()
    if self._data.rTime == 0 then
        return 0
    else
        return math.floor(os_time() - self._data.rTime)
    end
end

---
-- 设置轮回时间
-- @function [parent=#StatisticsModel] setRTime
-- @param #StatisticsModel self
-- @param #number time
function StatisticsModel:setRTime(time)
    time = time or os_time()
    self._data.rTime = time
end

---
-- 获取累计获得的金币
-- @function [parent=#StatisticsModel] getGotGold
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getGotGold()
    return self._data.gotGold or 0
end

---
-- 获取最近一分钟获得的金币
-- @function [parent=#StatisticsModel] getRecentGotGold
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getRecentGotGold()
    local maxn = table.maxn(self._recentGold)
    if maxn > 1 then
        return self._recentGold[maxn] - self._recentGold[1]
    else
        return 0 
    end
end

---
-- 添加 获取的累计获得的金币
-- @function [parent=#StatisticsModel] addGotGold
-- @param #StatisticsModel self
-- @param #number addMoney
function StatisticsModel:addGotGold(addMoney)
    self._data.gotGold = self._data.gotGold + addMoney
    self._recentGotGold = self._recentGotGold + addMoney
end

---
-- 添加 最近一分钟获得的金币
-- @function [parent=#StatisticsModel] _recordRecentGold
-- @param #StatisticsModel self
function StatisticsModel:_recordRecentGold()
    self._recentGold = {}
    self._sid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        table.insert(self._recentGold,self._recentGotGold)
        local maxn = table.maxn(self._recentGold)
        if maxn > 60 then
            table.remove(self._recentGold,1)
        end
    end,1,false)
end

---
-- 添加 获取的累计获得的魂
-- @function [parent=#StatisticsModel] addGotSoul
-- @param #StatisticsModel self
-- @param #number addSoul
function StatisticsModel:addGotSoul(addSoul)
    self._data.gotSoul = self._data.gotSoul + addSoul
end

---
-- 获取累计获得的魂
-- @function [parent=#StatisticsModel] getGotSoul
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getGotSoul()
    return self._data.gotSoul or 0
end

---
-- 获取宝物累计升级次数
-- @function [parent=#StatisticsModel] getMagicGotLevel
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getMagicGotLevel()
    return self._data.magicGotLevel or 0
end

---
-- 添加 获取宝物累计升级次数
-- @function [parent=#StatisticsModel] addMagicGotLevel
-- @param #StatisticsModel self
-- @param #number addLevel
function StatisticsModel:addMagicGotLevel(addLevel)
    if not self._data.magicGotLevel then
        self._data.magicGotLevel = 0
    end
    self._data.magicGotLevel = self._data.magicGotLevel + addLevel
end

---
-- 获取历史最高排名
-- @function [parent=#StatisticsModel] getMaxRank
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getMaxRank()
    return self._data.maxRank or 0
end

---
-- 设置历史最高排名
-- @function [parent=#StatisticsModel] setMaxRank
-- @param #StatisticsModel self
-- @param #number rank
function StatisticsModel:setMaxRank(rank)
    if not self._data.maxRank then
        self._data.maxRank = 0
    end
    if rank < self._data.maxRank then
        self._data.maxRank = rank
        self:_raiseDataChangeEvent(self.dataType.rank)
    end
end

---
-- 获取历史最高dps
-- @function [parent=#StatisticsModel] getMaxDPS
-- @param #StatisticsModel self
-- @return #number
function StatisticsModel:getMaxDPS()
    self._data.maxdps.num = DECODE_NUM(self._data.maxdps.num)
    self._data.maxdps.exp = DECODE_NUM(self._data.maxdps.exp)
    return self._data.maxdps or 0
end

---
-- 设置历史最高dps
-- @function [parent=#StatisticsModel] setMaxDPS
-- @param #StatisticsModel self
-- @param #number dps
function StatisticsModel:setMaxDPS(dps)
    local maxDps = self:getMaxDPS()
    if dps > maxDps then
        self._data.maxdps.num = DECODE_NUM(dps.num)
        self._data.maxdps.exp = DECODE_NUM(dps.exp)
    end
end

---
-- @function [parent=#StatisticsModel] _order
-- @param #StatisticsModel self
function StatisticsModel:_order()
    self._orderData = {}
    local configs = GameConfig.StatisticsConfig:getTable()
    local temp = {}
    for k,v in pairs(configs) do
        table.insert(temp,{id = v.id,index = v.index})
    end
    table.sort(temp,function(b1,b2)
        return b2.index > b1.index
    end)
    for k,v in ipairs(temp) do
        table.insert(self._orderData,v.id)
    end
end

---
-- 计算魂对攻击力的加成
-- @function [parent=#StatisticsModel] getSoulRatio
-- @param #StatisticsModel self
-- @param #number soulNum
-- @param #number rTimes
-- @return #number
function StatisticsModel:getSoulRatio(soulNum,rTimes)
    soulNum = soulNum or 1
    rTimes = rTimes or self:getRTimes()
    local soulAdd = 0
    if rTimes > GameConst.SOUL_RATIO_SAMSARA then
        soulAdd = GameConst.SOUL_RATIO_ADD*(rTimes-GameConst.SOUL_RATIO_SAMSARA)
    end
    local value = GameConst.MGAIC_SOUL_RATIO + ch.TotemModel:getTotemSkillData(1,6)+soulAdd
    if ch.AltarModel:getAltarByType(2).level > 0 then
        return value*soulNum*ch.AltarModel:getFinalEffect(2)
    else
        return value*soulNum
    end
end

---
-- 关于轮回
-- @function [parent=#StatisticsModel] onSamsara
-- @param #StatisticsModel self
function StatisticsModel:onSamsara()
    --最近一分钟获得金币
    self._recentGold = {}
    self._recentGotGold = 0
end

return StatisticsModel