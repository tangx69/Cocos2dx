---
-- 公会战 model层     结构 {{type = 1,index = 1,s = 0}, ... }
--@module GuildWarModel

local GuildWarModel = {
    _data = nil,
    _myCardList = nil,
    _mapRoutine = nil,
    _guildMap = nil,
    _fightPageCid = nil,
    _isCityDetailPageOpen = nil,
    _fightInfo = nil,
    _cityTeamNum = nil,
    _rankData = nil,
    _curRankData = nil,
    _rewardData = nil,
    _eventId = nil,             -- 令牌恢复的定时器
    _arrivingTeams = nil,       -- 据点详请界面攻守双方列表(未到达的队伍)
    dataChangeEventType = "GuildWarModelDataChanged",
    cityStatusChangedEventType = "GuildWarModelCityStatusChanged",
    teamStatusChangedEventType = "GuildWarModelTeamStatusChanged",
    fightDataChangedEventType = "GuildWarModelFightInfoChanged",
    arrivingTeamsEventType = "GuildWarModelArrivingTeamsEvent",
    ged_gatherCDSuccessEventType = "GuildWarModelGatherCDSuccess", --清除集合时间的时间type
    dailyPrizeEventType = "GuildWarModelDailyPrizeEvent",  -- 日常战功奖励
    dataType = {
        open = 1,
        CityCount = 2,           -- 精华和灵能据点数量
        ProdNumber = 3,          -- 精华和灵能产出数量变化
        MapData = 4,             -- 总体更新 
        Toten = 5,               -- 令牌
        apply = 6,               -- 报名状态
        reward = 7,              -- 领奖状态
        exploits = 8             -- 战功
    },
    teamDataType = {
        member = 101,
        status = 102,
        tid = 103,
        initList = 104,
        myCardList = 105,
        select = 106,
        morale = 107
    },
    fightDataType = {
        fightInfo = 201,   --战斗信息事件
        shadowInfo = 202,
    },
}

---
--@function [parent=#GuildWarModel] init
--@param #GuildWarModel self
--@param #table data
function GuildWarModel:init(data)
    self._data = data.guildWar or {}
    self:initGuildMap()
	self:initMapRoutine()
    self._cityTeamNum = {att={},def={}}
	self._arrivingTeams = {att={},def={}}
    self._rankData = {}
    self._curRankData = {}
    
--    self._fightInfo = {fInfo={},tInfo={},ptInfo={att={},def={}}}
--    for k = 1,15 do
--        local p = {n="大魔王",pid ="xs11",gid="sj0001gB00001N4ZN1",tid="x012"..k,cn=200+k*300,mn = 80,mid = 50001 +k,ml=1+k,is=0 }
--        table.insert(self._fightInfo.ptInfo.att,p)
--    end
--    
--    for k = 1,2 do
--        local p = {n="大魔王",pid ="xs11",gid="sj0001gB00001N4ZN1",tid="x016"..k,cn=200+k*300,mn = 80,mid = 50001 +k,ml=1+k,is=0 }
--        table.insert(self._fightInfo.ptInfo.def,p)
--    end
--    
--    
--    local df = {n="大魔王",pid ="xs11",gid="sj0001gB00001N4ZN1",tid="x016"..1,cn=200+1*300,mn = 80,mid = 50001 +1,ml=1+1,is=0,shp=9000,ehp=1000,thp=9000}
--    local at = {n="大魔王",pid ="xs11",gid="sj0001gB00001N4ZN1",tid="x012"..1,cn=200+1*300,mn = 80,mid = 50001 +1,ml=1+1,is=0,shp=5000,ehp=0,thp=5000}
--    self._fightInfo.fInfo.att = at
--    self._fightInfo.fInfo.def = df
--    self._fightInfo.fInfo.fr  = 1
end

---
-- 清理
-- @function [parent=#GuildWarModel] clean
-- @param #GuildWarModel self
function GuildWarModel:clean()
    self._data = nil
    self._mapRoutine = nil
    self._fightPageCid = nil
    self._isCityDetailPageOpen = nil
    if self._eventId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._eventId)
        self._eventId = nil
    end
end

---更换公会刷新数据
--@function [parent=#GuildWarModel] updata
--@param #GuildWarModel self
--@param #table data
function GuildWarModel:updata(data)
    self:clean()
    self._data = data or {}
    self:initGuildMap()
    self:initMapRoutine()
    self._cityTeamNum = {att={},def={}}
    self._arrivingTeams = {att={},def={}}
    self._rankData = {}
    self._curRankData = {}
end

function GuildWarModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

function GuildWarModel:_raiseCityStatusChangedEvent(id)
    local evt = {
        type = self.cityStatusChangedEventType,
        id = id,
    }
    zzy.EventManager:dispatch(evt)
end

function GuildWarModel:_raiseTeamStatusChangedEvent(dataType)
    local evt = {
        type = self.teamStatusChangedEventType,
        dataType = dataType,
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 通知刷新数据
-- @function [parent=#GuildWarModel] raiseArrivingTeamsEvent
-- @param #GuildWarModel self
-- @param #number cid
function GuildWarModel:raiseArrivingTeamsEvent(cid)
    local evt = {
        type = self.arrivingTeamsEventType,
        id = cid,
    }
    zzy.EventManager:dispatch(evt)
end

function GuildWarModel:_raiseDailyPrizeChangedEvent()
    local evt = {
        type = self.dailyPrizeEventType
    }
    zzy.EventManager:dispatch(evt)
end


---
-- 刷新数据
-- @function [parent=#GuildWarModel] refreshData
-- @param #GuildWarModel self
-- @param #table data
function GuildWarModel:refreshData(data)
    self._data.hCity = data.hCity
    self:initGuildMap()
    self._data.nCity = data.nCity
    self._data.production = data.production
    self._data.token = data.token
    self._data.army = data.army
    self._data.shadow = data.shadow
    self._data.exploits = data.exploits
    self._data.dailyPrize = data.dailyPrize
    
    for k,v in pairs(GameConfig.Guild_war_mapConfig:getTable()) do
        if v.type_level == "40" then
            if self._data.hCity[k] then
                self._data.nCity[k] = {s=2,b=self._data.hCity[k].id}
            else
                self._data.nCity[k] = {s=1,b=""}
            end
        end
    end
    
    if self._data.token.rtime then
        self._data.token.rtime = self._data.token.rtime + 10
    end
    if self._data.token.num < GameConst.GUILD_WAR_MAX_TOTEN then
        self:startRecove()
    else
        self:stopRecove()
    end 
    self._myCardList = {}
    self:setMyCardListInit(1)
    self:setMyCardListInit(2)
    self:setMyCardListInit(3)
    self:setMyCardListInit(4)
    self:setMyCardListInit(5)
    
    self:_raiseDataChangeEvent(self.dataType.MapData)
end

---
-- 是否开始
-- @function [parent=#GuildWarModel] isOpen
-- @param #GuildWarModel self
-- @return #bool
function GuildWarModel:isOpen()
    return self._data.hCity
end

---
-- 获得领奖信息
-- @function [parent=#GuildWarModel] getRewardInfo
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getRewardInfo()
    return self._data.reward or {}
end

---
-- 修改领奖状态
-- @function [parent=#GuildWarModel] setRewardState
-- @param #GuildWarModel self
-- @param #number id
-- @param #number state
function GuildWarModel:setRewardState(id,state)
    local tmpData = ch.GuildWarModel:getGuildWarRewardPanel()
    if id == 1 then
        local num = self:getSpiritNum(tmpData.lnValue,tmpData.myRank)
        ch.MoneyModel:addSpirit(num)
        self._data.reward.ylNum = state
        self:_raiseDataChangeEvent(self.dataType.reward)
    elseif id == 2 then
        local num = ch.GuildWarModel:getJingHuaPrize(tmpData.jhValue, tmpData.myRank)
        ch.MoneyModel:addQuintessence(num)
        self._data.reward.jhNum = state
        self:_raiseDataChangeEvent(self.dataType.reward)
    end
end

---
-- 获得英灵数量
-- @function [parent=#GuildWarModel] getSpiritNum
-- @param #GuildWarModel self
-- @param #number value
-- @param #number rank
-- @return #number 
function GuildWarModel:getSpiritNum(value,rank,zg)
    if zg and zg == 0 then
        return 0
    end
    local num = math.floor(value*GameConst.ENERGY_SPIRIT_RATIO)
    -- 英灵值四舍五入计算
    num = math.floor(num*GameConst.GUILD_WAR_SPIRIT_RANK_RATIO[rank]+0.5)
    num = num + GameConst.GUILD_WAR_SPIRIT_BASE_VALUE
    return num
end

---
-- 获得报名信息
-- @function [parent=#GuildWarModel] getApplyInfo
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getApplyInfo()
    return self._data.apply or {}
end

---
-- 修改报名状态
-- @function [parent=#GuildWarModel] setApplyState
-- @param #GuildWarModel self
-- @param #number state
function GuildWarModel:setApplyState(state)
    self._data.apply.state = state
    self:_raiseDataChangeEvent(self.dataType.apply)
end

---
-- 获得开战信息
-- @function [parent=#GuildWarModel] getFightInfo
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getFightInfo()
    return self._data.fight or {}
end

---
-- 修改参战状态
-- @function [parent=#GuildWarModel] setFightState
-- @param #GuildWarModel self
-- @param #number state
function GuildWarModel:setFightState(state)
    self._data.fight.state = state
    self:_raiseDataChangeEvent(self.dataType.apply)
end

---
-- 设置主城信息
-- @function [parent=#GuildWarModel] setHomeCityData
-- @param #GuildWarModel self
-- @param #table info
function GuildWarModel:setHomeCityData(info)
    self._data.hCity = info
    self:initGuildMap()
    self:_raiseDataChangeEvent(self.dataType.open)
end

---
-- 
--@function [parent=#GuildWarModel] initGuildMap
--@param #GuildWarModel self
function GuildWarModel:initGuildMap()
    self._data.hCity = self._data.hCity or {}
    self._guildMap = {}
    for k,v in pairs(self._data.hCity) do
        self._guildMap[v.id] = {cid = k,flag = v.f,name = v.n,level = v.l}
    end
end

---
-- 获得自己的主城id
-- @function [parent=#GuildWarModel] getMyHomeCityId
-- @param #GuildWarModel self
-- @return #string
function GuildWarModel:getMyHomeCityId()
    local gid = ch.GuildModel:myGuildID()
    if not gid or gid == "" then
        return "A01"
    else
        return self._guildMap[gid].cid
    end
end

---
-- 获得据点所属公会的主城id
-- @function [parent=#GuildWarModel] getCityHomeCityId
-- @param #GuildWarModel self
-- @param #string cid
-- @return #string
function GuildWarModel:getCityHomeCityId(cid)
    if self._data.nCity then
        local gid = self._data.nCity[cid].b
        if gid and gid ~= "" then
            return self._guildMap[gid].cid
        end
    end
end

---
-- 获得主城的公会信息
-- @function [parent=#GuildWarModel] getHomeCityInfo
-- @param #GuildWarModel self
-- @param #string cid
-- @return #table
function GuildWarModel:getHomeCityInfo(cid)
    return self._data.hCity[cid]
end


---
-- 获得据点的状态
-- @function [parent=#GuildWarModel] getCityStatus
-- @param #GuildWarModel self
-- @param #string cid
-- @return #number
function GuildWarModel:getCityStatus(cid)
    return self._data.nCity and self._data.nCity[cid].s or 0
end

---
-- 获得据点的所属公会
-- @function [parent=#GuildWarModel] getCityGuildId
-- @param #GuildWarModel self
-- @param #string cid
-- @return #number
function GuildWarModel:getCityGuildId(cid)
    return self._data.nCity and self._data.nCity[cid].b
end

---
-- 设置据点的状态
-- @function [parent=#GuildWarModel] setCityData
-- @param #GuildWarModel self
-- @param #string cid
-- @param #number status
-- @param #number gid
function GuildWarModel:setCityData(cid,status,gid)
    if self._data.nCity[cid].s ~= status or self._data.nCity[cid].b ~= gid then
        self._data.nCity[cid].s = status
        self._data.nCity[cid].b = gid
        self:_raiseCityStatusChangedEvent(cid)
    end
end

---
-- 获得公会的主城id,gid为空默认取自己的公会id
-- @function [parent=#GuildWarModel] getGuildHomeCityId
-- @param #GuildWarModel self
-- @param #string gid
-- @return #string
function GuildWarModel:getGuildHomeCityId(gid)
    gid = gid or ch.GuildModel:myGuildID()
    return self._guildMap[gid].cid
end

---
-- 获得公会的旗帜,gid为空默认取自己的公会id
-- @function [parent=#GuildWarModel] getGuildFlag
-- @param #GuildWarModel self
-- @param #string gid
-- @return #number
function GuildWarModel:getGuildFlag(gid)
    gid = gid or ch.GuildModel:myGuildID()
    return self._guildMap[gid].flag
end

---
-- 获得公会的名字,gid为空默认取自己的公会id
-- @function [parent=#GuildWarModel] getGuildName
-- @param #GuildWarModel self
-- @param #string gid
-- @return #string
function GuildWarModel:getGuildName(gid)
    gid = gid or ch.GuildModel:myGuildID()
    return self._guildMap[gid].name
end

---
-- 获得公会的等级,gid为空默认取自己的公会id
-- @function [parent=#GuildWarModel] getGuildLevel
-- @param #GuildWarModel self
-- @param #string gid
-- @return #number
function GuildWarModel:getGuildLevel(gid)
    gid = gid or ch.GuildModel:myGuildID()
    return self._guildMap[gid].level
end

---
-- @field [parent=#GuildInfo] #String cid
---
-- @field [parent=#GuildInfo] #Number flag
---
-- @field [parent=#GuildInfo] #String name
---
-- @field [parent=#GuildInfo] #Number level

---
-- 获得公会的信息,gid为空默认取自己的公会id
-- @function [parent=#GuildWarModel] getGuildInfo
-- @param #GuildWarModel self
-- @param #string gid
-- @return #GuildInfo
function GuildWarModel:getGuildInfo(gid)
    gid = gid or ch.GuildModel:myGuildID()
    return self._guildMap[gid]
end

---
-- 获得自己公会灵能据点数量
-- @function [parent=#GuildWarModel] getLNCityCount
-- @param #GuildWarModel self
-- @return #number
function GuildWarModel:getLNCityCount()
    if self._data.production then
        return self._data.production.ln.c
    end
    return 0
end

---
-- 获得自己公会灵能产量
-- @function [parent=#GuildWarModel] getLNNumber
-- @param #GuildWarModel self
-- @return #number
function GuildWarModel:getLNNumber()
    if self._data.production then
        return self._data.production.ln.n
    end
    return 0
end

---
-- 获得自己公会精华据点数量
-- @function [parent=#GuildWarModel] getJHCityCount
-- @param #GuildWarModel self
-- @return #number
function GuildWarModel:getJHCityCount()
    if self._data.production then
        return self._data.production.jh.c
    end
    return 0
end

---
-- 获得自己公会精华产量
-- @function [parent=#GuildWarModel] getJHNumber
-- @param #GuildWarModel self
-- @return #number
function GuildWarModel:getJHNumber()
    if self._data.production then
        return self._data.production.jh.n
    end
    return 0
end

---
-- 设置精华和灵能据点的数量
-- @function [parent=#GuildWarModel] setCityCount
-- @param #GuildWarModel self
-- @param #number jhCount
-- @param #number lnCount
function GuildWarModel:setCityCount(jhCount,lnCount)
    if self._data.production.jh.c ~= jhCount 
        or self._data.production.ln.c ~= lnCount then
        self._data.production.jh.c = jhCount
        self._data.production.ln.c = lnCount
        self:_raiseDataChangeEvent(self.dataType.CityCount)
    end
end

---
-- 设置精华和灵能产出数量
-- @function [parent=#GuildWarModel] setProductionNumber
-- @param #GuildWarModel self
-- @param #number jhNum
-- @param #number lnNum
function GuildWarModel:setProductionNumber(jhNum,lnNum)
    if self._data.production.jh.n ~= jhNum 
        or self._data.production.ln.n ~= lnNum then
        self._data.production.jh.n = jhNum
        self._data.production.ln.n = lnNum
        self:_raiseDataChangeEvent(self.dataType.ProdNumber)
    end
end

---
-- 获得战功数值
-- @function [parent=#GuildWarModel] getExploits
-- @param #GuildWarModel self
-- @return #number num
function GuildWarModel:getExploits()
    return self._data.exploits or 0
end

---
-- 设置战功数值
-- @function [parent=#GuildWarModel] setExploits
-- @param #GuildWarModel self
-- @param #number num
function GuildWarModel:setExploits(num)
    self._data.exploits = num
    self:_raiseDataChangeEvent(self.dataType.exploits)
end

---
-- 获得今日战功数值
-- @function [parent=#GuildWarModel] getDailyExploits
-- @param #GuildWarModel self
-- @return #number num
function GuildWarModel:getDailyExploits()
    return self._data.dailyPrize and self._data.dailyPrize.num or 0
end

---
-- 设置今日战功数值
-- @function [parent=#GuildWarModel] setDailyExploits
-- @param #GuildWarModel self
-- @param #number num
function GuildWarModel:setDailyExploits(num)
    self._data.dailyPrize.num = num
    self:_raiseDailyPrizeChangedEvent()
end

---
-- 设置今日战功奖励已领取状态
-- @function [parent=#GuildWarModel] setDailyPrize
-- @param #GuildWarModel self
-- @param #table list
function GuildWarModel:setDailyPrize(list)
    self._data.dailyPrize.getReward = self._data.dailyPrize.getReward or {}
    for k,v in ipairs(list) do
        table.insert(self._data.dailyPrize.getReward,v)
    end
    self:_raiseDailyPrizeChangedEvent()
end

---
-- 今日战功奖励状态 0不可领1可领2已领
-- @function [parent=#GuildWarModel] getDailyPrizeState
-- @param #GuildWarModel self
-- @param #number index
-- @return #number
function GuildWarModel:getDailyPrizeState(index)
    self._data.dailyPrize.getReward = self._data.dailyPrize.getReward or {}
    for k,v in ipairs(self._data.dailyPrize.getReward) do
        if index == tonumber(v) then
            return 2
        end
    end
    if self._data.dailyPrize.num >= GameConst.GUILD_WAR_SCORE_DAY_PRIZE[index].score then
        return 1
    else
        return 0
    end
end


---
-- 获得令牌数量
-- @function [parent=#GuildWarModel] getToken
-- @param #GuildWarModel self
-- @return #number num
function GuildWarModel:getToken()
    return self._data.token and self._data.token.num or 0
end

---
-- 获得令牌恢复时间
-- @function [parent=#GuildWarModel] getTokenRecoveTime
-- @param #GuildWarModel self
-- @return #number num
function GuildWarModel:getTokenRecoveTime()
    return self._data.token and self._data.token.rtime or 0
end

---
-- 添加令牌数量
-- @function [parent=#GuildWarModel] addToken
-- @param #GuildWarModel self
-- @param #number num
function GuildWarModel:addToken(num)
    self._data.token.num = self._data.token.num + num
    if self._data.token.num >= GameConst.GUILD_WAR_MAX_TOTEN then
        self:stopRecove()
    else
        self:startRecove()
    end
    self:_raiseDataChangeEvent(self.dataType.Toten)
end

---
-- 设置令牌数量
-- @function [parent=#GuildWarModel] setToken
-- @param #GuildWarModel self
-- @param #number num
function GuildWarModel:setToken(num)
    if self._data.token.num ~= num then
        self._data.token.num = num
        if self._data.token.num >= GameConst.GUILD_WAR_MAX_TOTEN then
            self:stopRecove()
        else
            self:startRecove()
        end
        self:_raiseDataChangeEvent(self.dataType.Toten)
    end
end

---
-- 启动恢复令牌
-- @function [parent=#GuildWarModel] startRecove
-- @param #GuildWarModel self
function GuildWarModel:startRecove()
    if self._eventId then return end
    self._data.token.rtime = self._data.token.rtime or os_time()
    self._data.token.rtime = self._data.token.rtime + GameConst.GUILD_WAR_TOTEN_RECOVER_TIME
    self._eventId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        local now = os_time()
        if now > self._data.token.rtime then
            local count = math.floor((now - self._data.token.rtime)/GameConst.GUILD_WAR_TOTEN_RECOVER_TIME) + 1
            self._data.token.rtime = self._data.token.rtime + count * GameConst.GUILD_WAR_TOTEN_RECOVER_TIME
            local s = self:getToken()
            if s < GameConst.GUILD_WAR_MAX_TOTEN then
                local canR = GameConst.GUILD_WAR_MAX_TOTEN - s
                count = count > canR and canR or count
                self:addToken(count)
            end
        end
    end,1,false)
end

---
-- 停止 恢复令牌
-- @function [parent=#GuildWarModel] stopRecove
-- @param #GuildWarModel self
function GuildWarModel:stopRecove()
    if self._data.token then
        self._data.token.rtime = nil
    end
    if self._eventId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._eventId)
        self._eventId = nil
    end
end

---
-- 获得战队队伍信息
-- @function [parent=#GuildWarModel] getTeamMember
-- @param #GuildWarModel self
-- @param #Number index
-- @return #tabel {{id= 50001,l=12,t=1},...}
function GuildWarModel:getTeamMember(index)
    if self._data.army and self._data.army[index] and self._data.army[index].member then
        return self._data.army[index].member
    end
    return {}
end

---
-- 获得战队队伍ID
-- @function [parent=#GuildWarModel] getTeamTid
-- @param #GuildWarModel self
-- @param #Number index
-- @return #string
function GuildWarModel:getTeamTid(index)
    if self._data.army and self._data.army[index] then
        return self._data.army[index].tid
    end
end

---
-- 获得战队的战力
-- @function [parent=#GuildWarModel] getTeamCombatNum
-- @param #GuildWarModel self
-- @param #Number index
-- @return #Number
function GuildWarModel:getTeamCombatNum(index)
    if self._data.army and self._data.army[index].member and self._data.army[index].member[1] then
        local ts = {}
        for i= 1,5 do
            local p = self._data.army[index].member[i]
            if p then
                local t = {id=p.id,l=p.l,talent=p.talent}
                table.insert(ts,t)
            else
                break
            end
        end
        return math.floor(ch.PetCardModel:getTeamPower(ts))
    end
    return 0
end

---
-- 获得战队的显示icon
-- @function [parent=#GuildWarModel] getTeamShowIcon
-- @param #GuildWarModel self
-- @param #Number index
-- @return #string
function GuildWarModel:getTeamShowIcon(index)
    if self._data.army and self._data.army[index].member and self._data.army[index].member[1] then
        return GameConfig.CardConfig:getData(self._data.army[index].member[1].id).mini
    end
    return GameConfig.CardConfig:getData(50001).mini
end

---
-- 获得战队的显示frame
-- @function [parent=#GuildWarModel] getTeamShowFrame
-- @param #GuildWarModel self
-- @param #Number index
-- @return #string
function GuildWarModel:getTeamShowFrame(index)
    if self._data.army and self._data.army[index].member and self._data.army[index].member[1] then
        return GameConfig.CarduplevelConfig:getData(self._data.army[index].member[1].l).iconFrame
    end
    return GameConfig.CarduplevelConfig:getData(1).iconFrame
end


---
-- 设置战队队伍信息
-- @function [parent=#GuildWarModel] setTeamMember
-- @param #GuildWarModel self
-- @param #Number index
-- @param #tabel   {{id},...}
function GuildWarModel:setTeamMember(index,member)
    self._data.army[index].member = member
    self:_raiseTeamStatusChangedEvent(self.teamDataType.member)
end

---
-- 设置战队队伍ID
-- @function [parent=#GuildWarModel] setTeamTid
-- @param #GuildWarModel self
-- @param #Number index
-- @param #string tid
function GuildWarModel:setTeamTid(index,tid)
    self._data.army[index].tid = tid
    self:_raiseTeamStatusChangedEvent(self.teamDataType.tid)
end
 
---
-- 获得战队士气
-- @function [parent=#GuildWarModel] getTeamMorale
-- @param #GuildWarModel self
-- @param #Number index
-- @return #Number 
function GuildWarModel:getTeamMorale(index)
    if self._data.army then
        return self._data.army[index].morale or 0
    end
    return 0
end

---
-- 获得战队士气百分比（1~100）
-- @function [parent=#GuildWarModel] getMoralePercent
-- @param #GuildWarModel self
-- @param #Number morale
-- @return #Number 
function GuildWarModel:getMoralePercent(morale)
    return GameConst.GUILD_WAR_GET_MORALE_RATIO(morale)*100
end

---
-- 获得战队的索引通过队伍id
-- @function [parent=#GuildWarModel] getTeamIndexByTID
-- @param #GuildWarModel self
-- @param #string tid
-- @return #number 
function GuildWarModel:getTeamIndexByTID(tid)
    if self._data.army then
        for k,v in ipairs(self._data.army) do
            if tid == v.tid then
                return k
            end
        end
    end
    return 0
end

---
-- 获得战队状态
-- @function [parent=#GuildWarModel] getTeamStatus
-- @param #GuildWarModel self
-- @param #Number index
-- @return #Number
function GuildWarModel:getTeamStatus(index)
    if self._data.army then
        return self._data.army[index].status
    end
    return 0
end

---
-- 获得战队所在据点
-- @function [parent=#GuildWarModel] getTeamCity
-- @param #GuildWarModel self
-- @param #Number index
-- @return #String
function GuildWarModel:getTeamCity(index)
    if self._data.army then
        return self._data.army[index].cid
    end
end

---
-- 获得战队到达时间
-- @function [parent=#GuildWarModel] getTeamArrTime
-- @param #GuildWarModel self
-- @param #Number index
-- @return #number
function GuildWarModel:getTeamArrTime(index)
    local time = 0
    if self._data.army then
        time = self._data.army[index].arrtime or 0
    end
    time = time > 0 and time+5 or 0
    return time
end
---
-- 获得战队冷却时间
-- @function [parent=#GuildWarModel] getTeamDieTime
-- @param #GuildWarModel self
-- @param #Number index
-- @return #number
function GuildWarModel:getTeamDieTime(index)
    local time = 0
    if self._data.army then
        time = self._data.army[index].dietime or 0
    end
    time = time > 0 and time+5 or 0
    return time
end

---
-- 设置战队状态
-- @function [parent=#GuildWarModel] setTeamStatus
-- @param #GuildWarModel self
-- @param #Number index
-- @param #Number status
-- @param #Number morale
-- @param #Number cid
-- @param #Number arrtime
-- @param #Number dietime
function GuildWarModel:setTeamStatus(index,status,morale,cid,arrtime,dietime)
    self._data.army[index].status = status
    self._data.army[index].morale = morale
    self._data.army[index].cid  = cid 
    self._data.army[index].arrtime = arrtime or 0
    self._data.army[index].dietime = dietime or 0
    self:_raiseTeamStatusChangedEvent(self.teamDataType.status)
    if status == 2 then
        local ms = self._data.army[index].member
        for k,v in ipairs(ms) do
            ms[k].l = ch.PetCardModel:getLevel(ms[k].id)
            ms[k].talent = ch.PetCardModel:getTalent(ms[k].id)
        end
        self:setTeamMember(index,ms)
    end
end

---
-- 设置战队士气值
-- @function [parent=#GuildWarModel] setTeamMorale
-- @param #GuildWarModel self
-- @param #Number index
-- @param #Number morale
function GuildWarModel:setTeamMorale(index,morale)
    if self._data.army[index].morale ~= morale then
        self._data.army[index].morale = morale
        self:_raiseTeamStatusChangedEvent(self.teamDataType.morale)
    end
end

--
--
-- 清理集合状态后设置战队状态
-- @function [parent=#GuildWarModel] setTeamStatusAfterGatherCD
-- @param #GuildWarModel self
-- @param #Number index
-- @param #Number status
-- @param #Number dietime
function GuildWarModel:setTeamStatusAfterGatherCD(index,status,dietime)
    self._data.army[index].status = status
    self._data.army[index].dietime = dietime or 0
    --self:_raiseTeamStatusChangedEvent(self.teamDataType.status)

end

---
-- 设置战斗界面打开状态
-- @function [parent=#GuildWarModel] setFightPageOpened
-- @param #GuildWarModel self
-- @param #string cid
function GuildWarModel:setFightPageCid(cid)
    self._fightPageCid = cid
end

---
-- 获得战斗界面打开状态
-- @function [parent=#GuildWarModel] getFightPageCid
-- @param #GuildWarModel self
-- @return #bool 
function GuildWarModel:getFightPageCid()
    return self._fightPageCid
end

---
-- 我的阵容列表(显示)
-- @function [parent=#GuildWarModel] getMyCardList
-- @param #GuildWarModel self
-- @param #number index
-- @return #table
function GuildWarModel:getMyCardList(index)
    return self._myCardList[index]
end

---
-- 设置战斗信息
-- @function [parent=#GuildWarModel] setFightInfo
-- @param #GuildWarModel self
-- @param #table fInfo
-- @param #table tInfo
-- @param #table ptInfo
function GuildWarModel:setFightInfo(fInfo,tInfo,ptInfo)
    local teamMap = {}
    for k,v in ipairs(ptInfo.att) do
        teamMap[v.tid] = v
    end
    for k,v in ipairs(ptInfo.def) do
        teamMap[v.tid] = v
    end
    for k,v in ipairs(tInfo.att) do
        if not v.n then
            tInfo.att[k] = teamMap[v.tid]
        end
    end
    for k,v in ipairs(tInfo.def) do
        if not v.n then
            tInfo.def[k] = teamMap[v.tid]
        end
    end
    self._fightInfo = {fInfo = fInfo,tInfo = tInfo,ptInfo = ptInfo}
    local evt = {type = self.fightDataChangedEventType}
    evt.dataType = self.fightDataType.fightInfo
    zzy.EventManager:dispatch(evt)
end

---
-- 清除战斗信息
-- @function [parent=#GuildWarModel] clearFightInfo
-- @param #GuildWarModel self
function GuildWarModel:clearFightInfo()
    self._fightInfo = nil
end

---
-- 获得战斗时间
-- @function [parent=#GuildWarModel] getFightTime
-- @param #GuildWarModel self
-- @return #number 
function GuildWarModel:getFightTime()
    return self._fightInfo.fInfo and  self._fightInfo.fInfo.ft or 0
end

---
-- 获得战斗结果
-- @function [parent=#GuildWarModel] getFightResult
-- @param #GuildWarModel self
-- @return #number 0攻方胜利，1守方胜利
function GuildWarModel:getFightResult()
    return self._fightInfo.fInfo and  self._fightInfo.fInfo.fr or 0
end

---
-- 获得战斗攻击队伍信息
-- @function [parent=#GuildWarModel] getFightAttacker
-- @param #GuildWarModel self
-- @return #table 
function GuildWarModel:getFightAttacker()
    return self._fightInfo.fInfo and self._fightInfo.fInfo.att
end

---
-- 获得战斗防御队伍信息
-- @function [parent=#GuildWarModel] getFightDefender
-- @param #GuildWarModel self
-- @return #table 
function GuildWarModel:getFightDefender()
    return self._fightInfo.fInfo and self._fightInfo.fInfo.def
end

---
-- 获得攻击队伍列表
-- @function [parent=#GuildWarModel] getFightAttactTeams
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getFightAttactTeams()
    return self._fightInfo.tInfo.att
end

---
-- 获得防守队伍列表
-- @function [parent=#GuildWarModel] getFightDefendTeams
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getFightDefendTeams()
    return self._fightInfo.tInfo.def
end

---
-- 获得战斗发生前攻击队伍列表
-- @function [parent=#GuildWarModel] getFightPreAttactTeams
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getFightPreAttactTeams()
    return self._fightInfo.ptInfo.att
end

---
-- 获得战斗发生前防守队伍列表
-- @function [parent=#GuildWarModel] getFightPreDefendTeams
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getFightPreDefendTeams()
    return self._fightInfo.ptInfo.def
end

---
-- 当前阵容列表是否不为空
-- @function [parent=#GuildWarModel] ifMyCardList
-- @param #GuildWarModel self
-- @param #number index
function GuildWarModel:ifMyCardList(index)
    if self._myCardList[index] then
        for k,v in pairs(self._myCardList[index]) do
            if v.vis then
                return true
            end
        end
    end
    return false
end

---
-- 该卡牌是否在阵容内(显示)
-- @function [parent=#GuildWarModel] isInGroup
-- @param #GuildWarModel self
-- @param #number index 
-- @param #number id
-- @return #boolean
function GuildWarModel:isInGroup(index,id)
    if self._myCardList[index] then
        for k,v in pairs(self._myCardList[index]) do
            if v.vis and v.id == id then
                return true
            end
        end
    end
    return false
end

---
-- 该卡牌是否在其他阵容内(显示)
-- @function [parent=#GuildWarModel] isInOtherGroup
-- @param #GuildWarModel self
-- @param #number index 
-- @param #number id
-- @return #boolean
function GuildWarModel:isInOtherGroup(index,id)
    for i=1,5 do
        if i~= index and self._myCardList[i] then
            for k,v in pairs(self._myCardList[i]) do
                if v.vis and v.id == id then
                    return true
                end
            end
        end
    end
    return false
end

---
-- 该卡牌是否在现有阵容内(显示)
-- @function [parent=#GuildWarModel] isInAllGroup
-- @param #GuildWarModel self
-- @param #number id
-- @return #boolean
function GuildWarModel:isInAllGroup(id)
    for i=1,5 do
        if self._myCardList[i] then
            for k,v in pairs(self._myCardList[i]) do
                if v.vis and v.id == id then
                    return true
                end
            end
        end
    end
    return false
end

---
-- 该卡牌是否在哪个现有阵容内(显示)
-- @function [parent=#GuildWarModel] isInGroupTypeNum
-- @param #GuildWarModel self
-- @param #number id
-- @return #number
function GuildWarModel:isInGroupTypeNum(id)
    for i=1,5 do
        if self._myCardList[i] then
            for k,v in pairs(self._myCardList[i]) do
                if v.vis and v.id == id then
                    return i 
                end
            end
        end
    end
    return 0
end

---
-- 该卡牌是否在哪个现有阵容内(显示)
-- @function [parent=#GuildWarModel] isInGroupType
-- @param #GuildWarModel self
-- @param #number id
-- @return #string
function GuildWarModel:isInGroupType(id)
    for i=1,5 do
        if self._myCardList[i] then
            for k,v in pairs(self._myCardList[i]) do
                if v.vis and v.id == id then
                    if i == self:getCurTeamSelect() then
                        return "aaui_common/ui_common_fragment_tag.png"
                    else
                        return "aaui_common/dot1.png"
                    end
                end
            end
        end
    end
    return "aaui_common/dot1.png"
end

---
-- 修改我的阵容列表(显示)
-- @function [parent=#GuildWarModel] changeMyCardListById
-- @param #GuildWarModel self
-- @param #number index
-- @param #number id
function GuildWarModel:changeMyCardListById(index,id)
    if self._myCardList[index] then
        for k,v in pairs(self._myCardList[index]) do
            if v.id == id and v.vis then
                v.id = 50001
                v.l = 1
                v.talent=1
                v.vis = false
                v.canSelect = false
                self:_raiseTeamStatusChangedEvent(self.teamDataType.myCardList)
                return 
            end
        end
    end
end

---
-- 阵容列表里是否有空位
-- @function [parent=#GuildWarModel] ifNotFull
-- @param #GuildWarModel self
-- @param #number index
-- @return #boolean
function GuildWarModel:ifNotFull(index)
    if self._myCardList[index] then
        for i=1,5 do
            if not self._myCardList[index][i].vis then
                return true
            end
        end
    end
    return false
end

---
-- 修改我的阵容列表(显示)
-- @function [parent=#GuildWarModel] addMyCardList
-- @param #GuildWarModel self
-- @param #number index
-- @param #number id
function GuildWarModel:addMyCardList(index,id)
    if self._myCardList[index] then
        for i=1,5 do
            if not self._myCardList[index][i].vis then
                self._myCardList[index][i].index = i
                self._myCardList[index][i].id = id
                self._myCardList[index][i].l = ch.PetCardModel:getLevel(id)
                self._myCardList[index][i].talent = ch.PetCardModel:getTalent(id)
                self._myCardList[index][i].vis = true
                self._myCardList[index][i].canSelect = true
                self:_raiseTeamStatusChangedEvent(self.teamDataType.myCardList)
                return
            end
        end
    end
end

---
-- 设置阵容列表
-- @function [parent=#GuildWarModel] setCardList
-- @param #GuildWarModel self
-- @param #table myData
-- @param #table data
function GuildWarModel:setCardList(myData,data)
    if not myData then
        myData = {}
    end
    for i=1,5 do
        if myData[i] then
            myData[i].vis = true
        else
            myData[i] = {id=50001,l=1,vis=false}
        end
    end
end

---
-- 修改我的阵容列表(显示)
-- @function [parent=#GuildWarModel] setMyCardList
-- @param #GuildWarModel self
-- @param #number type
-- @param #number index
-- @param #number id
function GuildWarModel:setMyCardList(type,index,id)
    if id then
        self._myCardList[type][index].id = id
        self._myCardList[type][index].l = ch.PetCardModel:getLevel(id)
        self._myCardList[type][index].talent = ch.PetCardModel:getTalent(id)
    else
        self._myCardList[type][index] = {index = index,id=50001,l=1,talent=1,vis=false,canSelect = false}
    end
    self:_raiseTeamStatusChangedEvent(self.teamDataType.myCardList)
end

---
-- 我的阵容列表(存储)
-- @function [parent=#GuildWarModel] setMyCardListInit
-- @param #GuildWarModel self
-- @param #number index
function GuildWarModel:setMyCardListInit(index)
    self._myCardList[index] = {}
    if not self._data.army[index].member then
        self._data.army[index].member = {}
    end
    for i=1,5 do
        if self._data.army[index].member[i] then
            self._myCardList[index][i] = {index = i, id=self._data.army[index].member[i].id,l=self._data.army[index].member[i].l,talent=self._data.army[index].member[i].talent,vis=true,canSelect = true}
        else
            self._myCardList[index][i] = {index = i,id=50001,l=1,talent=1,vis=false,canSelect = false}
        end
    end
end

---
-- 确认修改阵容
-- @function [parent=#GuildWarModel] changeMyCardList
-- @param #GuildWarModel self
-- @param #number index
function GuildWarModel:changeMyCardList(index)
    self._data.army[index].member = {}
    for k,v in pairs(self._myCardList[index]) do
        if v.vis then
            table.insert(self._data.army[index].member,v)
        end
    end
    self:_raiseTeamStatusChangedEvent(self.teamDataType.initList)
end

---
-- 切换界面
-- @function [parent=#GuildWarModel] setCurTeamSelect
-- @param #GuildWarModel self
-- @param #number index
function GuildWarModel:setCurTeamSelect(index)
    self.curTeam = index
    self:_raiseTeamStatusChangedEvent(self.teamDataType.select)
end

---
-- 当前界面是哪个队伍
-- @function [parent=#GuildWarModel] getCurTeamSelect
-- @param #GuildWarModel self
-- @return #number type
function GuildWarModel:getCurTeamSelect()
    return self.curTeam
end

---
-- 设置据点队伍信息
-- @function [parent=#GuildWarModel] setCityTeamNum
-- @param #GuildWarModel self
-- @param #string cid
-- @param #table att
-- @param #table def
-- @param #number ptime
function GuildWarModel:setCityTeamNum(cid,att,def,ptime)
    self._cityTeamNum = {att = att,def = def,ptime=ptime}
    self:_raiseCityStatusChangedEvent(cid)
end

---
-- 清除据点队伍信息
-- @function [parent=#GuildWarModel] clearCityTeamNum
-- @param #GuildWarModel self
function GuildWarModel:clearCityTeamNum()
    self._cityTeamNum = nil
end

---
-- 获得攻击队伍数量(fNum队伍数，aidNum援军数)
-- @function [parent=#GuildWarModel] getCityAttactTeams
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getCityAttactTeams()
    return self._cityTeamNum.att
end

---
-- 获得防守队伍数量(fNum队伍数，aidNum援军数)
-- @function [parent=#GuildWarModel] getCityDefendTeams
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getCityDefendTeams()
    return self._cityTeamNum.def
end

---
-- 获得据点产出时间
-- @function [parent=#GuildWarModel] getCityPTime
-- @param #GuildWarModel self
-- @return #number
function GuildWarModel:getCityPTime()
    return self._cityTeamNum.ptime or 0
end

---
-- 修改据点产出时间
-- @function [parent=#GuildWarModel] setCityPTime
-- @param #GuildWarModel self
-- @param #number
function GuildWarModel:setCityPTime(time)
    time = time or 0
    self._cityTeamNum.ptime = time
end

---
-- 今日召唤影子次数
-- @function [parent=#GuildWarModel] getShadowCallNum
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getShadowCallNum()
    return self._data.shadow.callNum or 0
end

---
-- 召唤影子花费(默认为当前次数)
-- @function [parent=#GuildWarModel] callShadowPrice
-- @param #GuildWarModel self
-- @param #number count
-- @return #table
function GuildWarModel:callShadowPrice(count)
    count = count or self._data.shadow.callNum
    return GameConst.GUILD_WAR_SHADOW_COST[count - GameConst.GUILD_WAR_SHADOW_FREE_COUNT] or 0
end

---
-- 召唤影子
-- @function [parent=#GuildWarModel] addShadowCallNum
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:addShadowCallNum()
    self._data.shadow.callNum = self._data.shadow.callNum + 1
end

---
--初始化地图路径
--@function [parent=#GuildWarModel] initMapRoutine
--@param #GuildWarModel self
function GuildWarModel:initMapRoutine()
    self._mapRoutine = {}
	for k,v in pairs(GameConfig.Guild_war_mapConfig:getTable()) do
        self._mapRoutine[k] = zzy.StringUtils:split(v.routine,"|")
	end
end

---
-- 获得最优路径
--@function [parent=#GuildWarModel] getRoutine
--@param #GuildWarModel self
--@param #string from
--@param #string to
function GuildWarModel:getRoutine(from,to)
    local mt = {from}
    local it = {0} -- 记录mt里对应点的父坐标的索引
    local curP  = {1}  -- 记录当前树状结构的要遍历的节点坐标的索引
    local endP = nil
    local gid = ch.GuildModel:myGuildID()
    while not endP and #curP >0 do
        local newP = {}
        for k,pri in ipairs(curP) do
            for k2,sr in ipairs(self._mapRoutine[mt[pri]]) do
                if sr == to then
                    if mt[pri] ~= from or self._data.nCity[from].b == gid or   --不在自己的据点移动，只能先移动到自己的据点
                        self._data.nCity[to].b == gid or self._data.nCity[to].b == "" then
                        endP = pri
                        break
                    end
                elseif self._data.nCity[sr].b == gid then 
                    local contain = false
                    for k3,t in ipairs(mt) do
                        if t == sr then
                            contain = true
                            break
                        end
                    end
                    if not contain then
                        table.insert(mt,sr)
                        table.insert(newP,#mt)
                        table.insert(it,pri)
                    end
                end
            end
            if endP then
                break
            end
        end
        curP = newP
    end
    if endP then
        local r = {mt[endP],to}
        local index = it[endP]
        while index > 0 do
            table.insert(r,1,mt[index])
            index = it[index]
        end
        return r
    end
end



function GuildWarModel:cclogMapRoutine(from,to)
	local r = self:getRoutine(from,to)
	if r then
	   local s =""
	   for k,v in ipairs(r) do
	       s= s..v.." "
	   end
	   cclog(s)
	else
	   cclog("没有路径")
	end
end

---
-- 设置据点详情界面打开状态
-- @function [parent=#GuildWarModel] setCityDetailPageOpened
-- @param #GuildWarModel self
-- @param #bool isOpen
function GuildWarModel:setCityDetailPageOpened(isOpen)
    self._isCityDetailPageOpen = isOpen
end

---
-- 获得据点详情界面打开状态
-- @function [parent=#GuildWarModel] isCityDetailPageOpened
-- @param #GuildWarModel self
-- @return #bool 
function GuildWarModel:isCityDetailPageOpened()
    return self._isCityDetailPageOpen
end

---
-- 设置据点队伍信息
-- @function [parent=#GuildWarModel] setArrivingTeams
-- @param #GuildWarModel self
-- @param #string cid
-- @param #table att
-- @param #table def
function GuildWarModel:setArrivingTeams(att,def)
    self._arrivingTeams = {att = att, def = def}
end

---
-- 清除据点队伍信息
-- @function [parent=#GuildWarModel] clearArrivingTeams
-- @param #GuildWarModel self
function GuildWarModel:clearArrivingTeams()
    self._arrivingTeams = {att={},def={}}
end

---
-- 获得攻击队伍列表
-- @function [parent=#GuildWarModel] getArrivingTeamsAttack
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getArrivingTeamsAttack()
    return self._arrivingTeams.att
end

---
-- 获得防守队伍列表
-- @function [parent=#GuildWarModel] getArrivingTeamsDefend
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getArrivingTeamsDefend()
    return self._arrivingTeams.def
end

---
-- 设置召唤的影子队伍的结果
-- @function [parent=#GuildWarModel] addConjuringShadowTeam
-- @param #GuildWarModel self
-- @param #table team
function GuildWarModel:addConjuringShadowTeam(team)
    if not self._fightInfo and not self._fightPageCid then return end
    local pft = 0
    local aft = 0
    --if error == 0 then
        if self._fightInfo.ptInfo.def and self._fightInfo.ptInfo.def[1]
             and self._fightInfo.ptInfo.def[1].gid == team.gid then
            pft = 2
            table.insert(self._fightInfo.ptInfo.def,team)
        elseif self._fightInfo.ptInfo.att and self._fightInfo.ptInfo.att[1] then
            pft = 1
            table.insert(self._fightInfo.ptInfo.def,team)
        end
        local gid = self:getCityGuildId(self._fightPageCid)
        if gid == team.gid then
            self._fightInfo.tInfo.def = self._fightInfo.tInfo.def or {}
            table.insert(self._fightInfo.tInfo.def,team)
            aft = 2
        else
            self._fightInfo.tInfo.att = self._fightInfo.tInfo.att or {}
            table.insert(self._fightInfo.tInfo.att,team)
            aft = 1
        end
    --end
    local evt = {type = self.fightDataChangedEventType}
    evt.dataType = self.fightDataType.shadowInfo
    evt.shadowTeam = {error = error,pft = pft,aft = aft}
    zzy.EventManager:dispatch(evt)
end

---
-- 设置排行榜信息
-- @function [parent=#GuildWarModel] setGuildWarRank
-- @param #GuildWarModel self
-- @param #table data
function GuildWarModel:setGuildWarRank(data)
    self._rankData = data
end

---
-- 获得排行榜信息
-- @function [parent=#GuildWarModel] getGuildWarRank
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getGuildWarRank()
    return self._rankData or {}
end

---
-- 设置当前战功排行榜信息
-- @function [parent=#GuildWarModel] setGuildWarCurRank
-- @param #GuildWarModel self
-- @param #table data
function GuildWarModel:setGuildWarCurRank(data)
    self._curRankData = data
end

---
-- 获得当前战功排行榜信息
-- @function [parent=#GuildWarModel] getGuildWarCurRank
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getGuildWarCurRank()
    return self._curRankData or {}
end

---
-- 设置领奖界面信息
-- @function [parent=#GuildWarModel] setGuildWarRewardPanel
-- @param #GuildWarModel self
-- @param #table data
function GuildWarModel:setGuildWarRewardPanel(data)
    self._rewardData = data
end

---
-- 获得领奖界面信息
-- @function [parent=#GuildWarModel] getGuildWarRewardPanel
-- @param #GuildWarModel self
-- @return #table
function GuildWarModel:getGuildWarRewardPanel()
    return self._rewardData or {}
end

---
-- 获得魔晶数量
-- @function [parent=#GuildWarModel] getJingHuaPrize
-- @param #GuildWarModel self
-- @param #number num
-- @return #number
function GuildWarModel:getJingHuaPrize(num, rank, zg)
    if zg and zg == 0 then
        return 0
    end
    
    local value = 0
    for k,v in ipairs(GameConst.GUILD_WAR_JINGHUA_PRIZE) do
        if num < v[1] then
            break
        end
        value = v[2]
    end
    
    value = math.floor(value*GameConst.GUILD_WAR_JH_RANK_RATIO[rank]+0.5)
    
    return value
end

---
-- 过天逻辑
-- @function [parent=#GuildWarModel] onNextDay
-- @param #GuildWarModel self
function GuildWarModel:onNextDay()
    if self._data.shadow then
        self._data.shadow.callNum = 0
    end
    if self._data.dailyPrize then
        self._data.dailyPrize = {num = 0,getReward = {}}
        self:_raiseDailyPrizeChangedEvent()
    end
end

return GuildWarModel