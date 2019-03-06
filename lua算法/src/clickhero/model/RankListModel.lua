---
-- 排行榜 model层 
--@module RankListModel
local RankListModel = {
    _data = nil,
    _playerData = nil,
    _initData = nil,
    dataChangeEventType = "RankListModelDataChange", --{type = ,id=,dataType =}
    dataType = {
        level = 1,
        list = 2,
        player = 3,
        time = 4,
        arena = 5,
        guild = 6,
        kfph = 7
    }
}

---
-- @function [parent=#RankListModel] inits
-- @param #RankListModel self
-- @param #table
function RankListModel:init(data)
    self._initData = data.rank
    self._data = {}
    self._data.pl = {}
    self._data.al = {} --竞技榜单
    self._data.gl = {}
    self._data.kl = {} --开服排行
    self._playerData = {}
    for i = 1,50 do
        local data = {}
        data["n"] = Language.INIT_PLAYER_NAME
        data["l"] = GameConst.RANKLIST_LEVEL
        data["num"] = 0
        table.insert(self._data.pl,data)
        table.insert(self._data.al,data)
    end
end

---
-- @function [parent=#RankListModel] clean
-- @param #RankListModel self
function RankListModel:clean()
    self._data = nil
    self._playerData = nil
    self._initData = nil
end

function RankListModel:_raiseDataChangeEvent(typeId,dataType)
    local evt = {
        type = self.dataChangeEventType,
        id = typeId,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 更新数据
-- @function [parent=#RankListModel] setInitData
-- @param #RankListModel self
-- @param #table data
function RankListModel:setInitData(data)
    if not self._initData then
        self._initData = {}
    end
    self._initData.rankTime = data.rankTime and data.rankTime or self._initData.rankTime
    self._initData.arenaTime = data.arenaTime and data.arenaTime or self._initData.arenaTime
    self._initData.rankTop = data.rankTop and data.rankTop or self._initData.rankTop
    self._initData.arenaTop = data.arenaTop and data.arenaTop or self._initData.arenaTop
    
    self:_raiseDataChangeEvent(0,self.dataType.time)
end

---
-- 设置公会榜前几名信息
-- @function [parent=#RankListModel] setGuildListData
-- @param #RankListModel self
-- @param #table data
function RankListModel:setGuildListData(data)
    if not self._data.gl then
        self._data.gl = {}
    end
    self._data.guildNum = data.num
    self._data.guildID = data.guildId
    for k,v in pairs(data.pl) do
        self._data.gl[k] = v
    end
    self:_raiseDataChangeEvent(0,self.dataType.guild)
end

---
-- 获得公会榜自己的名次
-- @function [parent=#RankListModel] getMyGuildNum
-- @param #RankListModel self
-- @return #number
function RankListModel:getMyGuildNum()
    return self._data.guildNum or 0
end

---
-- 获得公会榜自己的ID
-- @function [parent=#RankListModel] getMyGuildID
-- @param #RankListModel self
-- @return #number percent
function RankListModel:getMyGuildID()
    return self._data.guildID or 0
end

---
-- 获取公会榜数据
-- @function [parent=#RankListModel] getGuildList
-- @param #RankListModel self
-- @return #table
function RankListModel:getGuildList()
    return self._data.gl or {}
end

---
-- 设置竞技榜前几名信息
-- @function [parent=#RankListModel] setArenaListData
-- @param #RankListModel self
-- @param #table data
function RankListModel:setArenaListData(data)
    if not self._data.al then
        self._data.al = {}
    end
    self._data.arenaNum = data.num
    self._data.arenaPer = data.per
    for k,v in pairs(data.pl) do
        self._data.al[k] = v
    end
    self:_raiseDataChangeEvent(0,self.dataType.arena)
end

---
-- 获得竞技榜自己的名次
-- @function [parent=#RankListModel] getMyArena
-- @param #RankListModel self
-- @return #number rank
function RankListModel:getMyArena()
    return self._data.arenaNum or 0
end

---
-- 获得竞技榜自己打败玩家的比例
-- @function [parent=#RankListModel] getMyArenaPercent
-- @param #RankListModel self
-- @return #number percent
function RankListModel:getMyArenaPercent()
    return self._data.arenaPer or 0
end

---
-- 获得竞技榜结算时间
-- @function [parent=#RankListModel] getArenaTime
-- @param #RankListModel self
-- @return #number percent
function RankListModel:getArenaTime()
    if self._initData.arenaTime then
        local leftTime = self._initData.arenaTime - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---
-- 获得排行榜结算时间
-- @function [parent=#RankListModel] getRankTime
-- @param #RankListModel self
-- @return #number percent
function RankListModel:getRankTime()
    if self._initData.rankTime then
        local leftTime = self._initData.rankTime - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---
-- 获得排行榜前三名ID
-- @function [parent=#RankListModel] getRankTop
-- @param #RankListModel self
-- @return #table
function RankListModel:getRankTop()
    return self._initData.rankTop or {}
end

---
-- 获得竞技榜第一名ID
-- @function [parent=#RankListModel] getArenaTop
-- @param #RankListModel self
-- @return #table
function RankListModel:getArenaTop()
    return self._initData.arenaTop or {}
end
---
-- 获取排行榜数量
-- @function [parent=#RankListModel] getRankListNum
-- @param #RankListModel self
-- @return #number
function RankListModel:getRankListNum()
    return table.maxn(self._data.pl)
end

---
-- 获取排行榜前几名的玩家ID(1排行榜2竞技榜)
-- @function [parent=#RankListModel] getUserIdByRank
-- @param #RankListModel self
-- @param #number rank
-- @param #number type
-- @return #string
function RankListModel:getUserIdByRank(rank,type)
    if type == 1 then
        if self._data.pl[rank] and self._data.pl[rank].id then
            return self._data.pl[rank].id
        end
    elseif type == 2 then
        if self._data.al[rank] and self._data.al[rank].id then
            return self._data.al[rank].id
        end
    elseif type == 3 then
        if self._data.gl[rank] and self._data.gl[rank].id then
            return self._data.gl[rank].id
        end
    elseif type == 4 then
        if self._data.kl[rank] and self._data.kl[rank].id then
            return self._data.kl[rank].id
        end
    end
    return ""
end

---
-- 获取排行榜前几名的昵称(1排行榜2竞技榜)
-- @function [parent=#RankListModel] getNameByRank
-- @param #RankListModel self
-- @param #number rank
-- @param #number type
-- @return #string
function RankListModel:getNameByRank(rank,type)
    if type == 1 then
        if self._data.pl[rank] and self._data.pl[rank].n then
            return self._data.pl[rank].n
        end
    elseif type == 2 then
        if self._data.al[rank] and self._data.al[rank].n then
            return self._data.al[rank].n
        end
    elseif type == 3 then
        if self._data.gl[rank] and self._data.gl[rank].n then
            return self._data.gl[rank].n
        end
    elseif type == 4 then
        if self._data.kl[rank] and self._data.kl[rank].n then
            return self._data.kl[rank].n
        end
    end
    return Language.INIT_PLAYER_NAME
end

---
-- 获取排行榜第几名的最高关卡数(1排行榜2竞技榜)
-- @function [parent=#RankListModel] getMaxLevelByRank
-- @param #RankListModel self
-- @param #number rank
-- @param #number type
-- @return #number
function RankListModel:getMaxLevelByRank(rank,type)
    if type == 1 then
        if self._data.pl[rank] and self._data.pl[rank].l then
            return self._data.pl[rank].l
        end
    elseif type == 2 then
        if self._data.al[rank] and self._data.al[rank].l then
            return self._data.al[rank].l
        end
    elseif type == 3 then
        if self._data.gl[rank] and self._data.gl[rank].l then
            return self._data.gl[rank].l
        end
    elseif type == 4 then
        if self._data.kl[rank] and self._data.kl[rank].l then
            return self._data.kl[rank].l
        end
    end
    return GameConst.RANKLIST_LEVEL
end

---
-- 获取排行榜第几名的显示数据(1排行榜2竞技榜)
-- @function [parent=#RankListModel] getNumByRank
-- @param #RankListModel self
-- @param #number rank
-- @param #number type
-- @return #number
function RankListModel:getNumByRank(rank,type)
    if type == 1 then
        if self._data.pl[rank] and self._data.pl[rank].l then
            return self._data.pl[rank].l
        end
    elseif type == 2 then
        if self._data.al[rank] and self._data.al[rank].num then
            return ch.NumberHelper:toString(self._data.al[rank].num)
        end
    elseif type == 3 then
        if self._data.gl[rank] and self._data.gl[rank].l then
            return self._data.gl[rank].l
        end
    elseif type == 4 then
        if self._data.kl[rank] and self._data.kl[rank].l then
            return self._data.kl[rank].l
        end
    end
    return GameConst.RANKLIST_LEVEL
end

function RankListModel:geRewardByRank(rank,type)
    if type == 4 then
        
    end
    return ""
end

---
-- 设置排行榜自己的名次
-- @function [parent=#RankListModel] setMyRank
-- @param #RankListModel self
-- @param #number rank
function RankListModel:setMyRank(rank)
    self._data.num = rank
    self:_raiseDataChangeEvent("0",self.dataType.level)
end

---
-- 获得排行榜自己的名次
-- @function [parent=#RankListModel] getMyRank
-- @param #RankListModel self
-- @return #number rank
function RankListModel:getMyRank()
    return self._data.num or 0
end

---
-- 获得排行榜自己打败玩家的比例
-- @function [parent=#RankListModel] getMyRankPercent
-- @param #RankListModel self
-- @return #number percent
function RankListModel:getMyRankPercent()
    return self._data.per or 0
end

---
-- 设置排行榜自己打败玩家的比例
-- @function [parent=#RankListModel] setMyRankPercent
-- @param #RankListModel self
-- @param #number percent
function RankListModel:setMyRankPercent(percent)
    self._data.per = percent
    self:_raiseDataChangeEvent("0",self.dataType.level)
end

---
-- 设置排行榜前几名的玩家ID
-- @function [parent=#RankListModel] setUserIdByRank
-- @param #RankListModel self
-- @param #number rank
-- @param #string id
function RankListModel:setUserIdByRank(rank,id)
    self._data.pl[rank].id = id
    self:_raiseDataChangeEvent(rank,self.dataType.list)
end

---
-- 设置排行榜前几名昵称
-- @function [parent=#RankListModel] setNameByRank
-- @param #RankListModel self
-- @param #number rank
-- @param #string name
function RankListModel:setNameByRank(rank,name)
    self._data.pl[rank].n = name
    self:_raiseDataChangeEvent(rank,self.dataType.list)
end

---
-- 设置排行榜前几名最高关卡
-- @function [parent=#RankListModel] setMaxLevelByRank
-- @param #RankListModel self
-- @param #number rank
-- @param #number level
function RankListModel:setMaxLevelByRank(rank,level)
    self._data.pl[rank].l = level
    self:_raiseDataChangeEvent(rank,self.dataType.list)
end

---
-- 设置排行榜前几名信息
-- @function [parent=#RankListModel] setRankListData
-- @param #RankListModel self
-- @param #table rankListData
function RankListModel:setRankListData(rankListData)
    if not self._data.pl then
        self._data.pl = {}
    end
    for k,v in pairs(rankListData) do
        self._data.pl[k] = {}
        self:setNameByRank(k,v.n)
        self:setMaxLevelByRank(k,v.l)
        self:setUserIdByRank(k,v.id)
    end
end

---
-- 设置玩家信息
-- @function [parent=#RankListModel] setRankPlayer
-- @param #RankListModel self
-- @param #table data
function RankListModel:setRankPlayer(data)
    self._playerData = data
    self:_raiseDataChangeEvent("0",self.dataType.player) 
end

---
-- 获取玩家信息
-- @function [parent=#RankListModel] getRankPlayer
-- @param #RankListModel self
-- @return #table
function RankListModel:getRankPlayer()
    return self._playerData or {} 
end

---
-- 设置开服排行前几名信息
-- @function [parent=#RankListModel] setArenaListData
-- @param #RankListModel self
-- @param #table data
function RankListModel:setKfphListData(data)
    if not self._data.kl then
        self._data.kl = {}
    end

    for k,v in pairs(data.list) do
        self._data.kl[k] = v
    end
    self:_raiseDataChangeEvent(0,self.dataType.kfph)
end

return RankListModel