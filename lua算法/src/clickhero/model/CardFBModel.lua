---
-- 卡牌副本 model层 
--@module CardFBModel
local CardFBModel = {
    _data = nil,
    dataChangeEventType = "CardFBModelDataChange", --{type = ,dataType =}
    FBChangeEventType = "CardFBModelFBChange",--{type = ,id=,dataType =}
    cardPopOpenEventType = "CardPopOpenChange",
    cardOpenIndex = 0,
    _eventId = nil,  -- 体力恢复监听
    _levelEventId = nil,
    _cardID = nil,
    _ftEventId = nil,
    _reward = nil,
    dataType = {
        buyCount = 1,  -- 体力购买
        resetCount = 2, -- 副本次数购买
        fightCount = 3,
        stamina = 4,
        FBLevel = 5,
        fetchStamina = 6,
    }
}

function CardFBModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType,
    }
    zzy.EventManager:dispatch(evt)
end

function CardFBModel:_raiseFBChangeEvent(dataType,id)
    local evt = {
        type = self.FBChangeEventType,
        dataType = dataType,
        id = id
    }
    zzy.EventManager:dispatch(evt)
end

---
-- @function [parent=#CardFBModel] init
-- @param #CardFBModel self
-- @param #table data
function CardFBModel:init(data)
    self._data = data.cardFB
    self._cardIds = {}
    if self._data.rtime then
        self._data.rtime = self._data.rtime + 10
    end
    if self._data.tl >= GameConst.CARD_FB_MAX_STAMINA then
        self._data.rtime = nil
    else
        self:startRecove()
    end
    if self._data.fb then
        local fb = {}
        for k,v in pairs(self._data.fb) do
            fb[tonumber(k)] = v
        end
        self._data.fb = fb
    end
    self._data.lq = self._data.lq or {0,0,0}
    self._data.cdtime = self._data.cdtime or 0
    if ch.StatisticsModel:getMaxLevel() > GameConst.CARD_FB_OPEN_LEVEL then
        self:listenEvent()
    else
        self._levelEventId = zzy.EventManager:listen(ch.StatisticsModel.maxLevelChangeEventType,function(obj,evt)
            if ch.StatisticsModel:getMaxLevel() > GameConst.CARD_FB_OPEN_LEVEL then
                self:open()
                zzy.EventManager:unListen(self._levelEventId)
                self._levelEventId = nil
            end
        end,1)
    end
end

---
-- 清理
-- @function [parent=#CardFBModel] clean
-- @param #CardFBModel self
function CardFBModel:clean()
    self._data = nil
    self.cardOpenIndex = 0
    if self._levelEventId then
        zzy.EventManager:unListen(self._levelEventId)
        self._levelEventId = nil
    end
    if self._eventId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._eventId)
        self._eventId = nil
    end
    if self._cardID then
        zzy.EventManager:unListen(self._cardID)
        self._cardID = nil
    end
    if self._ftEventId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._ftEventId)
        self._ftEventId = nil
    end
    self._reward = nil
end

---
-- 首次开放
-- @function [parent=#CardFBModel] open
-- @param #CardFBModel self
function CardFBModel:open()
	self._data = {}
	self._data.tl = 80
	self._data.buyCount = 0
	self._data.fb = {}
	self._data.lq = {0,0,0}
	self._data.cdtime = 0
	for k,id in pairs(ch.PetCardModel:getAllPetCardID()) do
	   if ch.PetCardModel:getLevel(id) > 0 then
	       self._data.fb[id] = {c=0,l=1,b=0}
	   end
	end
    self:listenEvent()
end

---
-- 监听相关事件
-- @function [parent=#CardFBModel] listenEvent
-- @param #CardFBModel self
function CardFBModel:listenEvent()
    local count = 0
    for k,v in pairs(self._data.fb or {}) do
        count = count + 1
    end
    local maxCount = 0
    for k,v in pairs(GameConfig.CardConfig:getTable()) do
        if v.ty == 1 then
            maxCount = maxCount + 1
        end
    end
    if count < maxCount then
        self._cardID = zzy.EventManager:listen(ch.PetCardModel.dataChangeEventType,function(obj,evt)
            if evt.dataType == ch.PetCardModel.dataType.level then
                if not self._data.fb[evt.id] then
                    self._data.fb[evt.id] = {c=0,l=1,b=0} 
                    count = count + 1
                    if count >= maxCount then
                        zzy.EventManager:unListen(self._cardID)
                        self._cardID = nil
                    end
                end
            end
        end)
    end
    local lastTime = 0
    self._ftEventId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        local tb = os.date("*t",os_time())
        local time = tb.hour + tb.min/60
        for i=1,#GameConst.CARD_FB_TL_TIME do
            if time>= GameConst.CARD_FB_TL_TIME[i].startTime and lastTime<GameConst.CARD_FB_TL_TIME[i].startTime then
                self:_raiseDataChangeEvent(self.dataType.fetchStamina)
                break
            end
            if time >= GameConst.CARD_FB_TL_TIME[i].endTime and lastTime < GameConst.CARD_FB_TL_TIME[i].endTime then
                self:_raiseDataChangeEvent(self.dataType.fetchStamina)
                break
            end
        end
        lastTime = time
    end,1,false)
end

---
-- 获得当前体力
-- @function [parent=#CardFBModel] getStamina
-- @param #CardFBModel self
-- @return #number
function CardFBModel:getStamina()
	return self._data.tl
end

---
-- 获得当前副本列表
-- @function [parent=#CardFBModel] getFBList
-- @param #CardFBModel self
-- @return #table
function CardFBModel:getFBList()
    return self._data.fb
end


---
-- 体力恢复时间
-- @function [parent=#CardFBModel] getRecoverTime
-- @param #CardFBModel self
-- @return #number
function CardFBModel:getRecoverTime()
	return self._data.rtime
end


---
-- 添加当前体力
-- @function [parent=#CardFBModel] addStamina
-- @param #CardFBModel self
-- @param #number stamina
function CardFBModel:addStamina(stamina)
    self._data.tl = self._data.tl + stamina
    if self._data.tl >= GameConst.CARD_FB_MAX_STAMINA then
        self:stopRecove()
    else
        self:startRecove()
    end
    self:_raiseDataChangeEvent(self.dataType.stamina)
end

---
-- 获得当前购买体力次数
-- @function [parent=#CardFBModel] getBuyCount
-- @param #CardFBModel self
-- @return #number
function CardFBModel:getBuyCount()
    return self._data.buyCount
end

---
-- 添加当前购买体力次数
-- @function [parent=#CardFBModel] addBuyCount
-- @param #CardFBModel self
-- @param #number count
function CardFBModel:addBuyCount(count)
    self._data.buyCount = self._data.buyCount + count
end

---
-- 获得当前购买体力的花费
-- @function [parent=#CardFBModel] getBuyCost
-- @param #CardFBModel self
-- @return #number
function CardFBModel:getBuyCost()
    return GameConst.CARD_FB_BUY_STAMINA_COST(self._data.buyCount + 1)
end

---
-- 添加体力购买次数
-- @function [parent=#CardFBModel] addBuyCost
-- @param #CardFBModel self
function CardFBModel:addBuyCost()
    self._data.buyCount = self._data.buyCount + 1
    self:_raiseDataChangeEvent(self.dataType.buyCount)
end

---
-- 获得当前副本已挑战次数
-- @function [parent=#CardFBModel] getFightCount
-- @param #CardFBModel self
-- @param #number id
-- @return #number
function CardFBModel:getFightCount(id)
    return self._data.fb[id].c
end
    
---
-- 添加副本挑战次数
-- @function [parent=#CardFBModel] addFightCount
-- @param #CardFBModel self
-- @param #number id
-- @param #number count
function CardFBModel:addFightCount(id,count)
    self._data.fb[id].c = self._data.fb[id].c + count
    self:_raiseFBChangeEvent(self.dataType.fightCount,id)
end

---
-- 获得当前最高副本难度
-- @function [parent=#CardFBModel] getMAXFBLevel
-- @param #CardFBModel self
-- @return #number
function CardFBModel:getMAXFBLevel()
    local max = 1
    if self._data.fb and table.maxn(self._data.fb)>0 then
        for k,v in pairs(self._data.fb) do
            if v.l > max then
                max = v.l
            end
        end
    end
    return max
end

---
-- 获得当前副本难度
-- @function [parent=#CardFBModel] getFBLevel
-- @param #CardFBModel self
-- @param #number id
-- @return #number
function CardFBModel:getFBLevel(id)
    return self._data.fb[id].l
end

local MAXCOUNT = #GameConst.CARD_FB_LEVLE_NAME
---
-- 获得当前副本难度
-- @function [parent=#CardFBModel] getFBLevelName
-- @param #CardFBModel self
-- @param #number id
-- @return #string
function CardFBModel:getFBLevelName(id)
    local l = self._data.fb[id].l > MAXCOUNT and MAXCOUNT or self._data.fb[id].l
    return GameConst.CARD_FB_LEVLE_NAME[l]
end

---
-- 获得当前副本难度
-- @function [parent=#CardFBModel] getFBLevelFrame
-- @param #CardFBModel self
-- @param #number id
-- @return #string
function CardFBModel:getFBLevelFrame(id)
    local l = self._data.fb[id].l > MAXCOUNT and MAXCOUNT or self._data.fb[id].l
    return GameConst.CARD_FB_LEVLE_FRAME[l]
end

---
-- 添加副本难度
-- @function [parent=#CardFBModel] addFBLevel
-- @param #CardFBModel self
-- @param #number id
function CardFBModel:addFBLevel(id)
    self._data.fb[id].l = self._data.fb[id].l + 1
    self:_raiseFBChangeEvent(self.dataType.FBLevel,id)
end

---
-- 获取已重置副本次数
-- @function [parent=#CardFBModel] getResetCount
-- @param #CardFBModel self
-- @param #number id
-- @return #number
function CardFBModel:getResetCount(id)
	return self._data.fb[id].b
end

---
-- 获取挑战副本需要的体力消耗数
-- @function [parent=#CardFBModel] getStaminaCost
-- @param #CardFBModel self
-- @param #number id
-- @return #number
function CardFBModel:getStaminaCost(id)
    local level = self._data.fb[id].l > MAXCOUNT and MAXCOUNT or self._data.fb[id].l
    return GameConfig.CardFBConfig:getData(id,level).staminaCost
end

---
-- 获取重置副本需要的钻石数
-- @function [parent=#CardFBModel] getResetCost
-- @param #CardFBModel self
-- @param #number id
-- @return #number
function CardFBModel:getResetCost(id)
    return GameConst.CARD_FB_RESET_COST(self._data.fb[id].b + 1) 
end

---
-- 添加重置副本次数
-- @function [parent=#CardFBModel] addResetCount
-- @param #CardFBModel self
-- @param #number id
-- @param #number count
function CardFBModel:addResetCount(id,count)
    self._data.fb[id].c = 0
    self._data.fb[id].b = self._data.fb[id].b + count
    self:_raiseFBChangeEvent(self.dataType.resetCount,id)
end

---
-- 设置副本奖励
-- @function [parent=#CardFBModel] setReward
-- @param #CardFBModel self
-- @param #table reward {id =chipId,num = evt.data.count}
function CardFBModel:setReward(reward)
    self._reward = reward
end

---
-- 获得副本奖励
-- @function [parent=#CardFBModel] getReward
-- @param #CardFBModel self
-- @return #table  {id =chipId,num = evt.data.count}
function CardFBModel:getReward()
    return self._reward
end

---
-- 启动恢复体力
-- @function [parent=#CardFBModel] startRecove
-- @param #CardFBModel self
function CardFBModel:startRecove()
	if not self._eventId then
        self._data.rtime = self._data.rtime or os_time()
        self._data.rtime = self._data.rtime + GameConst.CARD_FB_STAMINA_RECOVER_TIME
        self._eventId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            local now = os_time()
            if now > self._data.rtime then
                local count = math.floor((now - self._data.rtime)/GameConst.CARD_FB_STAMINA_RECOVER_TIME) + 1
                self._data.rtime = self._data.rtime + count * GameConst.CARD_FB_STAMINA_RECOVER_TIME
                local s = self:getStamina()
                if s < GameConst.CARD_FB_MAX_STAMINA then
                    local canR = GameConst.CARD_FB_MAX_STAMINA - s
                    count = count > canR and canR or count
                    self:addStamina(count)
                end
            end
        end,1,false)
	end
end

---
-- 停止 恢复体力
-- @function [parent=#CardFBModel] stopRecove
-- @param #CardFBModel self
function CardFBModel:stopRecove()
    if self._eventId then
        self._data.rtime = nil
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._eventId)
        self._eventId = nil
    end
end

---
-- 获得当前可领取的时间段，若果可领取返回index，如果不在时间段返回-1
-- @function [parent=#CardFBModel] getCurFetchIndex
-- @param #CardFBModel self
-- @return #number 如果在领取时间返回index，如果不在时间段返回-1
function CardFBModel:getCurFetchIndex()
    if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" then
        return 1
    end
	local tb = os.date("*t",os_time() + ch.CommonFunc:getTimeZoneDiff())
    local time = tb.hour + tb.min/60
    --DEBUG("time="..time)
	for i=1,#GameConst.CARD_FB_TL_TIME do
       if GameConst.CARD_FB_TL_TIME[i].startTime <=time and GameConst.CARD_FB_TL_TIME[i].endTime > time then
	       return i
	   end
	end
    return -1
end

---
-- 获得下一次的可领取的时间段
-- @function [parent=#CardFBModel] getNextFetchIndex
-- @param #CardFBModel self
-- @return #number 下一次领取时间的index,-1表示为明天的第一次领取时间段
function CardFBModel:getNextFetchIndex()
    if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" then
        return 1
    end
    local tb = os.date("*t",os_time())
    local time = tb.hour + tb.min/60
    for i=1,#GameConst.CARD_FB_TL_TIME do
        if time < GameConst.CARD_FB_TL_TIME[i].startTime then
            return i
        end
    end
    return -1
end

---
-- 时间段里的是否已经领取了体力
-- @function [parent=#CardFBModel] isFetched
-- @param #CardFBModel self
-- @param #number index 时间段的索引
-- @return #bool 领取过返回true，否则为false
function CardFBModel:isFetched(index)
--    return self._data.lq[index] == 1
    return self._data.lq[index] > 0
end

---
-- 时间段里的是否已经领取了体力
-- @function [parent=#CardFBModel] isFetched
-- @param #CardFBModel self
-- @param #number index 时间段的索引
-- @param #bool isFetched true为领取过，否则为false
function CardFBModel:setFetched(index,isFetched)
    local oldState = self._data.lq[index]
    if isFetched then
        if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" then
            self._data.lq[index] = self._data.lq[index] + 1
            self._data.cdtime = os_time() + 7200
        else
            self._data.lq[index] = 1
        end
    else
        self._data.lq[index] = 0
    end
    if oldState ~= self._data.lq[index] then
        self:_raiseDataChangeEvent(self.dataType.fetchStamina)
    end
end

---
-- 当前是否可以领取体力
-- @function [parent=#CardFBModel] canFetched
-- @param #CardFBModel self
-- @return #bool true可领，false不可领
function CardFBModel:canFetched()
    if ch.StatisticsModel:getMaxLevel()<= GameConst.CARD_FB_OPEN_LEVEL then
        return false
    end
    if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" then
        return self._data.lq[1] < 3 and self:getCDTime() < 1
    end
    local index = self:getCurFetchIndex()
    if index < 0 then return false end
    return self._data.lq[index] == 0
end

---
-- 体力领取倒计时
-- @function [parent=#CardFBModel] getCDTime
-- @param #CardFBModel self
-- @return #number
function CardFBModel:getCDTime()
    if string.sub(zzy.Sdk.getFlag(),1,2)~="CY" then
        return -1
    end

    local now = os_time()
    if now < self._data.cdtime then
        return math.floor(self._data.cdtime-now)
    else
        return -1
    end
end

---
-- 该时间段体力领取次数
-- @function [parent=#CardFBModel] getLQNum
-- @param #CardFBModel self
-- @param #number index
-- @return #number
function CardFBModel:getLQNum(index)
    return self._data.lq[index]
end

---
-- 通过ID获得当前副本列表Index
-- @function [parent=#CardFBModel] getIndexById
-- @param #CardFBModel self
-- @param #number id
-- @return #number
function CardFBModel:getIndexById(id)
    local num = 0 
    if self._data.fb and self._data.fb[id] then
        for k,v in pairs(self._data.fb) do
            if id >= k then
                num = num + 1
            end
        end
    end
    return num
end




---
-- 过天刷新
-- @function [parent=#FirstSignModel] onNextDay
-- @param #FirstSignModel self
function CardFBModel:onNextDay()
    if self._data then
        self._data.buyCount = 0
        self._data.lq = {0,0,0}
        self:_raiseDataChangeEvent(self.dataType.buyCount)
        if self._data.fb then
            for k,v in pairs(self._data.fb) do
                v.c = 0
                v.b = 0
            end
        end
        self:_raiseFBChangeEvent(self.dataType.fightCount)
        self:_raiseFBChangeEvent(self.dataType.resetCount)
    end
end

return CardFBModel