---
-- 无尽征途
--@module WarpathModel

local WarpathModel = {
    _data = nil,
    _totalHarm = nil,
    _totalHonour = nil,
    _reportData = nil,
    _memberRankData = nil,
    _guildRankData = nil,
    _guildDetail = nil,
    _myRankData = nil,
    _dataStateTime = nil,
    _gold = nil,
    ifMemberData = nil,
    ifGuildData = nil,
    ifDetailData = nil,
    dataChangeEventType = "WarpathModelDataChange",
    panelChangeEventType = "WarpathPanelDataChange",
    dataType = {
        report = 1,
        member = 2,
        rank = 3,
        guild = 4
    }
}

---
-- @function [parent=#WarpathModel] init
-- @param #WarpathModel self
-- @param #table data
function WarpathModel:init(data)
    self._data = data.warpath
    if self._data and self._data.index == GameConst.WARPATH_BOSS_MAX_COUNT 
        and self._data.hp == 0 then
        self._data.stage = self._data.stage + 1
        self._data.index = 1
        self._data.hp = ch.fightRoleLayer:getWarpathLife(self._data.stage,self._data.index)
    elseif self._data and self._data.hp then
        self._data.hp = ch.LongDouble:new(self._data.hp)
    end
    self._reportData = {}
    self._memberRankData = {}
    self._guildRankData = {}
    self._myRankData = {}
    self._guildDetail = {}
    self._dataStateTime = 0
end


---
-- @function [parent=#WarpathModel] clean
-- @param #WarpathModel self
function WarpathModel:clean()
    self._data = nil
    self._totalHarm = nil
    self._totalHonour = nil
    self._reportData = nil
    self._memberRankData = nil
    self._guildRankData = nil
    self._guildDetail = nil
    self._myRankData = nil
    self._dataStateTime = nil
    self._gold = nil
    self.ifMemberData = nil
    self.ifGuildData = nil
    self.ifDetailData = nil
end

function WarpathModel:_raiseDataChangeEvent()
    local evt = {
        type = self.dataChangeEventType,
    }
    zzy.EventManager:dispatch(evt)
end

-- 战报等面板信息
function WarpathModel:_raisePanelDataChangeEvent(type)
    local evt = {
        type = self.panelChangeEventType,
        dataType = type
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 无尽征途卡片是否显示
-- @function [parent=#WarpathModel] isShow
-- @param #WarpathModel self
-- @return #bool
function WarpathModel:isShow()
    if self._data and self._data.openTime then
        return true
    end
    return false
end

---
-- 获得今天无尽征途是否开启
-- @function [parent=#WarpathModel] isOpen
-- @param #WarpathModel self
-- @return #bool
function WarpathModel:isOpen()
    if self._data and self._data.openTime then
        return os_time() >= self._data.openTime
    end
    return false
end 

---
-- 获得活动开启时间
-- @function [parent=#WarpathModel] getOpenTime
-- @param #WarpathModel self
-- @return #number
function WarpathModel:getOpenTime()
    if self._data then
        return self._data.openTime
    end
    return nil
end

---
-- 获得活动开启倒计时
-- @function [parent=#WarpathModel] getOpenTimeCD
-- @param #WarpathModel self
-- @return #number
function WarpathModel:getOpenTimeCD()
    if self._data and self._data.openTime then
        local leftTime = self._data.openTime - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---
-- 获得传送门关闭倒计时
-- @function [parent=#WarpathModel] getCloseTimeCD
-- @param #WarpathModel self
-- @return #number
function WarpathModel:getCloseTimeCD()
    if self._data and self._data.openTime then
        local leftTime = self._data.openTime+7*24*60*60 - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---
-- 获得今天已参与次数
-- @function [parent=#WarpathModel] getTimes
-- @param #WarpathModel self
-- @return #number
function WarpathModel:getTimes()
    if self._data then
	   return self._data.times
	end
	return nil
end

---
-- 获得当前是否正在空闲
-- @function [parent=#WarpathModel] isIdle
-- @param #WarpathModel self
-- @return #bool
function WarpathModel:isIdle()
    if self._data then
        return self._data.statue == 0
    end
    return true
end

---
-- 获得当前的阶段
-- @function [parent=#WarpathModel] getCurStage
-- @param #WarpathModel self
-- @return #number
function WarpathModel:getCurStage()
    if self._data then
        return self._data.stage or 0
    end
    return 0
end

---
-- 获得当前阶段的位置
-- @function [parent=#WarpathModel] getCurIndex
-- @param #WarpathModel self
-- @return #number
function WarpathModel:getCurIndex()
    if self._data then
        return self._data.index or 0
    end
    return 0
end

---
-- 获得当前boss的id
-- @function [parent=#WarpathModel] getBossId
-- @param #WarpathModel self
-- @param #number index
-- @return #number
function WarpathModel:getBossId(index)
    if self._data then
        index = index or self._data.index
        return self._data.bosses[index]
    end
    return nil
end

---
-- 获得当前boss的hp
-- @function [parent=#WarpathModel] getCurHP
-- @param #WarpathModel self
-- @return #number
function WarpathModel:getCurHP()
    if self._data then
        return self._data.hp or ch.LongDouble.zero
    end
    return ch.LongDouble.zero
end

---
-- 设置获得进度信息
-- @function [parent=#WarpathModel] setProgress
-- @param #WarpathModel self
-- @param #table data
function WarpathModel:setProgress(data)
    self._data = self._data or {}
    local isNoticed = false
    if data.statue then
        if data.statue == 2 then
            self._data = nil
            self._reportData = {}
            self._memberRankData = {}
            self._guildRankData = {}
            self._myRankData = {}
            self._guildDetail = {}
            return self:_raiseDataChangeEvent()
        else
            self._data.statue = data.statue
        end
    end
    if data.stage then
        if self._data.stage ~= data.stage then
            self._data.stage = data.stage
            isNoticed = true
        end
    end
    if data.index then
        if self._data.index ~= data.index then
            self._data.index = data.index
            isNoticed = true
        end
    end
    if data.hp then
        self._data.hp = ch.LongDouble:new(data.hp)
        isNoticed = true
    end
    if data.openTime then
        self._data.openTime = data.openTime
        isNoticed = true
    end
    if data.times then
        self._data.times = data.times
    end
    if data.bosses then
        self._data.bosses = data.bosses
    end
    if self._data.index == GameConst.WARPATH_BOSS_MAX_COUNT and 
         self._data.hp == ch.LongDouble.zero then
         self:openNextStage()
         self:_raiseDataChangeEvent()
    end
    if isNoticed then
        self:_raiseDataChangeEvent()
    end
end

---
-- 添加活动参与次数
-- @function [parent=#WarpathModel] addTimes
-- @param #WarpathModel self 
function WarpathModel:addTimes()
    self._data.times = self._data.times + 1
    self._totalHarm = 0
    self._totalHonour = 0
end

---
-- 获取活动期间累计的伤害量
-- @function [parent=#WarpathModel] getTotalHarm
-- @param #WarpathModel self
-- @return #number harm
function WarpathModel:getTotalHarm()
    return self._totalHarm
end

---
-- 获取活动期间累计应奖励的金钱数
-- @function [parent=#WarpathModel] getRewardGold
-- @param #WarpathModel self
-- @return #number
function WarpathModel:getRewardGold()
--    local r = self._totalHarm/ch.fightRoleLayer:getWarpathLife(self:getCurStage(),1)
--    local gold = r * ch.fightRoleLayer:getWarpathGold(self:getCurStage(),self:getCurIndex())
--    gold = gold * GameConst.WARPATH_GOLD_RATIO
--    return math.ceil(gold)
    return self._gold
end

---
-- 设置活动期间累计应奖励的金钱数
-- @function [parent=#WarpathModel] getRewardGold
-- @param #WarpathModel self
-- @param #number gold
function WarpathModel:setRewardGold(gold)
    self._gold = gold
end

---
-- 获取活动期间累计的荣誉值
-- @function [parent=#WarpathModel] getRewardHonour
-- @param #WarpathModel self
-- @return #number
function WarpathModel:getRewardHonour()
    return self._totalHonour
end

---
-- 设置活动期间累计的荣誉值
-- @function [parent=#WarpathModel] setRewardHonour
-- @param #WarpathModel self
-- @param #number honour
function WarpathModel:setRewardHonour(honour)
    self._totalHonour = honour
end

---
-- 杀死boss或者活动结束更新活动信息
-- @function [parent=#WarpathModel] AttackBoss
-- @param #WarpathModel self
-- @param #number harm 伤害量
-- @param #number hp 当前剩余boss血量
function WarpathModel:AttackBoss(harm,hp)
    self._totalHarm = self._totalHarm + harm
    local totalLife = ch.fightRoleLayer:getWarpathLife(self._data.stage,self._data.index)
--    local honour = math.ceil((harm/totalLife)*100)
--    honour = honour > 100 and 100 or honour
--
--    self._totalHonour = self._totalHonour + honour
    if hp == ch.LongDouble.zero then
        if self._data.index < GameConst.WARPATH_BOSS_MAX_COUNT then
            self._data.index = self._data.index + 1
            self._data.hp = ch.fightRoleLayer:getWarpathLife(self._data.stage,self._data.index)
        else
            self._data.hp = ch.LongDouble.zero
    	end
        self:_raiseDataChangeEvent()
	else
        self._data.hp = hp
	end
end

---
-- 下一阶段
-- @function [parent=#WarpathModel] openNextStage
-- @param #WarpathModel self
function WarpathModel:openNextStage()
    self._data.stage = self._data.stage + 1
    self._data.index = 1
    self._data.hp = ch.fightRoleLayer:getWarpathLife(self._data.stage,self._data.index)
    self._data.openTime = ch.CommonFunc:getZeroTime()
end

---
-- 设置战报信息
-- @function [parent=#WarpathModel] setReport
-- @param #WarpathModel self 
-- @param #table data
function WarpathModel:setReport(data)
--    self._reportData= data
    self:addReport(data)
--    if data[1] and data[1].time then
--        self._dataStateTime = data[1].time
--    end
    self:_raisePanelDataChangeEvent(self.dataType.report)
end

---
-- 获得战报信息
-- @function [parent=#WarpathModel] getReport
-- @param #WarpathModel self 
-- @param #number index
-- @return #table
function WarpathModel:getReport(index)
    return self._reportData[index] or {}
end

---
-- 获得所有战报信息
-- @function [parent=#WarpathModel] getAllReport
-- @param #WarpathModel self 
-- @return #table
function WarpathModel:getAllReport()
    return self._reportData
end

---
-- 增加战报信息
-- @function [parent=#WarpathModel] addReport
-- @param #WarpathModel self 
-- @param #table data
function WarpathModel:addReport(data)
    if not data or table.maxn(data) < 1 then
        return
    end
    local num = table.maxn(data)
    while num > 0 do
        if data[num].time > self._dataStateTime then
            table.insert(self._reportData,1,data[num])
            if table.maxn(self._reportData) > 50 then
                table.remove(self._reportData)
            end
            if data[num].isKill == 1 and
                data[num].bossNum[table.maxn(data[num].bossNum)] == GameConst.WARPATH_BOSS_MAX_COUNT then
                table.insert(self._reportData,1,{time=data[num].time,name=data[num].name,isKill=-1})
                if table.maxn(self._reportData) > 50 then
                    table.remove(self._reportData)
                end
            end
        end
        num = num - 1
    end
    if data[1] and data[1].time then
        self._dataStateTime = data[1].time
    end
    self:_raisePanelDataChangeEvent(self.dataType.report)
end

---
-- 设置公会成员排名
-- @function [parent=#WarpathModel] setMemberRank
-- @param #WarpathModel self 
-- @param #table data
function WarpathModel:setMemberRank(data)
    self._memberRankData = data
    self.ifMemberData = true
    self:_raisePanelDataChangeEvent(self.dataType.member)
end

---
-- 获得公会成员排名
-- @function [parent=#WarpathModel] getMemberRank
-- @param #WarpathModel self 
-- @param #number index
-- @return #table
function WarpathModel:getMemberRank(index)
    return self._memberRankData[index] or {}
end

---
-- 获得全部公会成员排名
-- @function [parent=#WarpathModel] getAllMemberRank
-- @param #WarpathModel self 
-- @return #table
function WarpathModel:getAllMemberRank()
    return self._memberRankData
end

---
-- 设置公会详情
-- @function [parent=#WarpathModel] setGuildDetail
-- @param #WarpathModel self 
-- @param #table data
function WarpathModel:setGuildDetail(data)
    self._guildDetail = data
    self.ifDetailData = true
    self:_raisePanelDataChangeEvent(self.dataType.guild)
end

---
-- 获得公会详情
-- @function [parent=#WarpathModel] getGuildDetail
-- @param #WarpathModel self 
-- @return #table
function WarpathModel:getGuildDetail()
    return self._guildDetail
end

---
-- 设置公会排名
-- @function [parent=#WarpathModel] setGuildRank
-- @param #WarpathModel self 
-- @param #table data
function WarpathModel:setGuildRank(data)
    self._guildRankData = data.list
    self:setMyGuildName(data.name)
    self:setMyGuildFlag(data.flag)
    self:setMyGuildRank(data.rank)
    self.ifGuildData = true
    self:_raisePanelDataChangeEvent(self.dataType.rank)
end

---
-- 获得公会排名
-- @function [parent=#WarpathModel] getGuildRank
-- @param #WarpathModel self 
-- @param #number index
-- @return #table
function WarpathModel:getGuildRank(index)
    return self._guildRankData[index] or {}
end

---
-- 获得全部公会排名
-- @function [parent=#WarpathModel] getAllGuildRank
-- @param #WarpathModel self 
-- @return #table
function WarpathModel:getAllGuildRank()
    return self._guildRankData
end

---
-- 设置本公会名字
-- @function [parent=#WarpathModel] setMyGuildName
-- @param #WarpathModel self 
-- @param #string name
function WarpathModel:setMyGuildName(name)
    self._myRankData.name = name
end

---
-- 设置本公会排名
-- @function [parent=#WarpathModel] setMyGuildRank
-- @param #WarpathModel self 
-- @param #number rank
function WarpathModel:setMyGuildRank(rank)
    self._myRankData.rank = rank
end

---
-- 设置本公会旗帜
-- @function [parent=#WarpathModel] setMyGuildFlag
-- @param #WarpathModel self 
-- @param #number flag
function WarpathModel:setMyGuildFlag(flag)
    self._myRankData.flag = flag
end

---
-- 获得本公会排名信息
-- @function [parent=#WarpathModel] getMyGuildRank
-- @param #WarpathModel self 
-- @return #table
function WarpathModel:getMyGuildRank()
    return self._myRankData
end

---
-- 获得数据可请求状态
-- @function [parent=#WarpathModel] getDataStateTime
-- @param #WarpathModel self 
-- @return #number
function WarpathModel:getDataStateTime()
    return self._dataStateTime
end

return WarpathModel