---
-- 天梯 model层 
--@module ArenaModel
local ArenaModel = {
    _data = nil,
    _playerDetail = nil,
    _myCardList = nil,
    _isWin = nil,
    _pkLogData = nil,
    dataChangeEventType = "ArenaModelDataChange", --{type = ,id=,dataType =}
    dataType = {
        challenge = 1,
        reset = 2,
        all = 3,
        myCardList = 4,
        state = 5
    }
}

---
-- @function [parent=#ArenaModel] init
-- @param #ArenaModel self
-- @param #table data
function ArenaModel:init(data)
    self._data = data.arena
    self._playerDetail = {}
    self._pkLogData = {}
    self:setMyCardListInit()
end

---
-- 清理
-- @function [parent=#ArenaModel] clean
-- @param #ArenaModel self
function ArenaModel:clean()
    self._data = nil
    self._playerDetail = nil
    self._myCardList = nil
    self._isWin = nil
    self._pkLogData = nil
end

function ArenaModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 头像边框
-- @function [parent=#ArenaModel] getFrameByRank
-- @param #ArenaModel self
-- @param #number rank
-- @return #string
function ArenaModel:getFrameByRank(rank)
    if rank == -1 then
        return GameConst.ARENA_FRAME[6]
    elseif rank < 4 then
        return GameConst.ARENA_FRAME[rank]
    elseif rank < 11 then
        return GameConst.ARENA_FRAME[4]
    else
        return GameConst.ARENA_FRAME[5]
    end
end

---
-- 是否战斗胜利
-- @function [parent=#ArenaModel] isWin
-- @param #ArenaModel self
-- @return #bool
function ArenaModel:isWin()
    return self._isWin
end

---
-- 设置是否战斗胜利
-- @function [parent=#ArenaModel] setWin
-- @param #ArenaModel self
-- @param #bool isWin
function ArenaModel:setWin(isWin)
    self._isWin = isWin
end

---
-- 界面信息
-- @function [parent=#ArenaModel] setPanelData
-- @param #ArenaModel self
-- @param #table data
function ArenaModel:setPanelData(data)
    self._data.myrank = data.myrank
    self._data.myrankOld = data.myrankOld
    self._data.state = data.state
    self._data.cdTIME = data.cdTIME
    self:setFirstData(data.first)
    self:setCurData(data.cur)
    self:_raiseDataChangeEvent(self.dataType.all)
end

---
-- 前十名信息处理
-- @function [parent=#ArenaModel] setFirstData
-- @param #ArenaModel self
-- @param #table data
function ArenaModel:setFirstData(data)
    self._data.first = data
    for k,v in ipairs(self._data.first) do
        v.canFight = false
        v.frame = v.rank
    end
end

---
-- 前十名信息
-- @function [parent=#ArenaModel] getFirstData
-- @param #ArenaModel self
-- @return #table
function ArenaModel:getFirstData()
    return self._data.first
end

---
-- 当前十名信息处理
-- @function [parent=#ArenaModel] setCurData
-- @param #ArenaModel self
-- @param #table data
function ArenaModel:setCurData(data)
    self._data.cur = data
    for k,v in ipairs(self._data.cur) do
        if v.id == ch.PlayerModel:getPlayerID() then
            v.canFight = false
            v.frame = -1
        else
            v.canFight = true
            v.frame = v.rank
        end
    end
end

---
-- 当前十名信息
-- @function [parent=#ArenaModel] getCurData
-- @param #ArenaModel self
function ArenaModel:getCurData()
    return self._data.cur
end

---
-- 展示信息
-- @function [parent=#ArenaModel] getItemDataByIndex
-- @param #ArenaModel self
-- @param #number index
function ArenaModel:getItemDataByIndex(index)
    if index < 11 then
        return self._data.first[index] or {id="",rank=0,person=1,canFight=false,frame=11,vis=true}
    else
        return self._data.cur[index-10] or {id="",rank=0,person=1,canFight=false,frame=11,vis=true}
    end
end

---
-- 我的排名
-- @function [parent=#ArenaModel] getMyRank
-- @param #ArenaModel self
-- @return #number
function ArenaModel:getMyRank()
    return self._data.myrank
end

---
-- 我的昨日排名
-- @function [parent=#ArenaModel] getMyRankOld
-- @param #ArenaModel self
-- @return #number
function ArenaModel:getMyRankOld()
    return self._data.myrankOld
end

---
-- 我的奖励领取状态
-- @function [parent=#ArenaModel] getMyState
-- @param #ArenaModel self
-- @return #number
function ArenaModel:getMyState()
    return self._data.state
end

---
-- 我的奖励领取状态
-- @function [parent=#ArenaModel] setMyState
-- @param #ArenaModel self
-- @param #number state
function ArenaModel:setMyState(state)
    self._data.state = state
    self:_raiseDataChangeEvent(self.dataType.state)
end

---
-- cd时间
-- @function [parent=#ArenaModel] getCDTime
-- @param #ArenaModel self
-- @return #table
function ArenaModel:getCDTime()
    if self._data and self._data.cdTIME then
        local leftTime = self._data.cdTIME - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---
-- 剩余挑战次数
-- @function [parent=#ArenaModel] getChallengeNum
-- @param #ArenaModel self
-- @return #number
function ArenaModel:getChallengeNum()
    return self._data.pkNum
end

---
-- 增加挑战次数
-- @function [parent=#ArenaModel] addChallengeNum
-- @param #ArenaModel self
-- @param #number num
function ArenaModel:addChallengeNum(num)
    if num ~= 0 then
        self._data.pkNum = self._data.pkNum + num
        self:_raiseDataChangeEvent(self.dataType.challenge)
    end
end

---
-- 剩余补充次数
-- @function [parent=#ArenaModel] getResetNum
-- @param #ArenaModel self
-- @return #number
function ArenaModel:getResetNum()
    return self._data.reset
end

---
-- 增加补充次数
-- @function [parent=#ArenaModel] addResetNum
-- @param #ArenaModel self
-- @param #number num
function ArenaModel:addResetNum(num)
    if num ~= 0 then
        self._data.reset = self._data.reset + num
        self:_raiseDataChangeEvent(self.dataType.reset)
    end
end

---
-- 玩家阵容详情
-- @function [parent=#ArenaModel] getPlayerDetail
-- @param #ArenaModel self
-- @return #table
function ArenaModel:getPlayerDetail()
    return self._playerDetail
end

---
-- 玩家阵容详情
-- @function [parent=#ArenaModel] setPlayerDetail
-- @param #ArenaModel self
-- @param #table data
function ArenaModel:setPlayerDetail(data)
    self._playerDetail = data
    self:setCardList(self._playerDetail.cardList,data)
end

---
-- 设置阵容列表
-- @function [parent=#ArenaModel] setCardList
-- @param #ArenaModel self
-- @param #table myData
-- @param #table data
function ArenaModel:setCardList(myData,data)
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
-- 我的阵容列表(存储)
-- @function [parent=#ArenaModel] setMyCardListInit
-- @param #ArenaModel self
function ArenaModel:setMyCardListInit()
    self._myCardList = {}
    if not self._data.cardList then
        self._data.cardList = {}
    end
    for i=1,5 do
        if self._data.cardList[i] then
            self._myCardList[i] = {index = i, id=self._data.cardList[i],l=ch.PetCardModel:getLevel(self._data.cardList[i]),talent=ch.PetCardModel:getTalent(self._data.cardList[i]),vis=true,canSelect = true}
        else
            self._myCardList[i] = {index = i,id=50001,l=1,talent=1,vis=false,canSelect = false}
        end
    end
end

---
-- 确认修改阵容
-- @function [parent=#ArenaModel] changeMyCardList
-- @param #ArenaModel self
function ArenaModel:changeMyCardList()
    self._data.cardList = {}
    for k,v in pairs(self._myCardList) do
        if v.vis then
            table.insert(self._data.cardList,v.id)
        end
    end
end

---
-- 当前阵容列表是否不为空
-- @function [parent=#ArenaModel] ifMyCardList
-- @param #ArenaModel self
function ArenaModel:ifMyCardList()
    for k,v in pairs(self._myCardList) do
        if v.vis then
            return true
        end
    end
    return false
end

---
-- 我的阵容列表(存储)
-- @function [parent=#ArenaModel] getMyCardListInit
-- @param #ArenaModel self
-- @return #table
function ArenaModel:getMyCardListInit()
    return self._data.cardList
end

---
-- 我的阵容列表(显示)
-- @function [parent=#ArenaModel] getMyCardList
-- @param #ArenaModel self
-- @return #table
function ArenaModel:getMyCardList()
    return self._myCardList or {}
end

---
-- 修改我的阵容列表(显示)
-- @function [parent=#ArenaModel] setMyCardList
-- @param #ArenaModel self
-- @param #number index
-- @param #number id
function ArenaModel:setMyCardList(index,id)
    if id then
        self._myCardList[index].id = id
        self._myCardList[index].l = ch.PetCardModel:getLevel(id)
        self._myCardList[index].talent = ch.PetCardModel:getTalent(id)
    else
        self._myCardList[index] = {index = index,id=50001,l=1,talent = 1,vis=false,canSelect = false}
    end
    self:_raiseDataChangeEvent(self.dataType.myCardList)
end

---
-- 修改我的阵容列表(显示)
-- @function [parent=#ArenaModel] changeMyCardListById
-- @param #ArenaModel self
-- @param #number id
function ArenaModel:changeMyCardListById(id)
    for k,v in pairs(self._myCardList) do
        if v.id == id and v.vis then
            v.id = 50001
            v.l = 1
            v.talent = 1
            v.vis = false
            v.canSelect = false
            self:_raiseDataChangeEvent(self.dataType.myCardList)
            return 
        end
    end
end

---
-- 修改我的阵容列表(显示)
-- @function [parent=#ArenaModel] addMyCardList
-- @param #ArenaModel self
-- @param #number id
function ArenaModel:addMyCardList(id)
    for i=1,5 do
        if not self._myCardList[i].vis then
            self._myCardList[i].index = i
            self._myCardList[i].id = id
            self._myCardList[i].l = ch.PetCardModel:getLevel(id)
            self._myCardList[i].talent = ch.PetCardModel:getTalent(id)
            self._myCardList[i].vis = true
            self._myCardList[i].canSelect = true
            self:_raiseDataChangeEvent(self.dataType.myCardList)
            return
        end
    end
end
---
-- 阵容列表里是否有空位
-- @function [parent=#ArenaModel] ifNotFull
-- @param #ArenaModel self
-- @return #boolean
function ArenaModel:ifNotFull()
    for i=1,5 do
        if not self._myCardList[i].vis then
            return true
        end
    end
    return false
end
---
-- 该卡牌是否在阵容内(显示)
-- @function [parent=#ArenaModel] isInGroup
-- @param #ArenaModel self
-- @param #number id
-- @return #boolean
function ArenaModel:isInGroup(id)
    for k,v in pairs(self._myCardList) do
        if v.vis and v.id == id then
            return true
        end
    end
    return false
end
---
-- 排名奖励
-- @function [parent=#ArenaModel] getRewardByRank
-- @param #ArenaModel self
-- @param #number rank
-- @return #table
function ArenaModel:getRewardByRank(rank)
    for k,v in pairs(GameConfig.Arena_awardConfig:getTable()) do
        if v.from <= rank and rank <= v.to then
            return v
        end
    end
    return {}
end

---
-- 天梯战斗记录
-- @function [parent=#ArenaModel] setPKLogData
-- @param #ArenaModel self
-- @param #table data
function ArenaModel:setPKLogData(data)
    self._pkLogData = data
end

---
-- 天梯战斗记录
-- @function [parent=#ArenaModel] getPKLogData
-- @param #ArenaModel self
-- @return #table data
function ArenaModel:getPKLogData()
    return self._pkLogData or {}
end


---
-- 过天逻辑
-- @function [parent=#ArenaModel] onNextDay
-- @param #ArenaModel self
function ArenaModel:onNextDay()
    self._data["pkNum"] = GameConst.ARENA_CHALLENGE_MAX
    self._data["reset"] = GameConst.ARENA_RESET_ADD
    
    self:_raiseDataChangeEvent(self.dataType.all)
end

return ArenaModel