---
-- 日常任务model层         结构{{num = 0,s = 1},...}
--@module TaskModel
local TaskModel = {
    _data = nil,
    _taskType = nil,
    _curTask = nil,
    _typeEventId = nil,
    _todayTask = nil,
    _oldTask = nil,
    refreshPlay = nil,
    dataChangeEventType = "TaskModelDataChange", --{type = ,id=,dataType =}
    dataType = {
        state = 1,
        curNum = 2,
        get = 3
    }
}

-- 任务监听的事件
local taskTypeEvent = {
    ch.PlayerModel.offLineGetEventType, -- 收取挂机奖励
    ch.LevelModel.dataChangeEventType, -- 挑战魔王（无关成功失败）
    ch.LevelModel.dataChangeEventType, -- 通过关卡数
    ch.clickLayer.CLICK_EVENT_TYPE, -- 累计点击次数
    ch.clickLayer.CLICK_EVENT_TYPE, -- 完成每秒点击次数
    ch.MagicModel.dataChangeEventType, -- 累计提升宝物等级
    ch.RunicModel.dataChangeEventType, -- 累计提升宠物等级
    ch.TotemModel.dataChangeEventType, -- 累计提升图腾等级
    ch.RunicModel.SkillDurationStatusChangedEventType, -- 使用任意主动技能
    ch.fightRole.DEAD_EVENT_TYPE, -- 消灭宝箱怪
    ch.fightRole.DEAD_EVENT_TYPE, -- 累计消灭怪物
    ch.fairyLayer.GET_BOX_EVENT, -- 获得小仙女的宝箱
    ch.MoneyModel.dataChangeEventType -- 获得魂石个数
}

---
-- @function [parent=#TaskModel] init
-- @param #TaskModel self
-- @param #table data
function TaskModel:init(data)
    self._data = data.task
    self._taskType = {}
    self._typeEventId = {}
    self:getShowTask()
--    self:_getTaskIDByType()
--    self:_getRandTask()
    math.randomseed(os_clock()) 
end

---
-- @function [parent=#TaskModel] clean
-- @param #TaskModel self
function TaskModel:clean()
    self._data = nil
    self._taskType = nil
    self._curTask = nil
    for k,v in pairs(self._typeEventId) do
        zzy.EventManager:unListen(v)
    end
    self._typeEventId = nil
    self._todayTask = nil
    self._oldTask = nil
    self.refreshPlay = nil
end

function TaskModel:_raiseDataChangeEvent(id,dataType)
    local evt = {
        type = self.dataChangeEventType,
        id = id,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end


---
-- 日常任务当前任务总数
-- @function [parent=#TaskModel] getTaskNum
-- @param #TaskModel self
-- @param #number state  0为全部，1为未完成，2为可领取，3为已完成（可刷新）
-- @return #number
function TaskModel:getTaskNum(state)
    state = state or 0
    local num = 0
    if state == 0 then
        for k,v in pairs(self._data.showTask) do
            num = num + 1
        end
    else
        for k,v in pairs(self._data.showTask) do
            if v.s == state then
                num = num + 1
            end
        end
    end
    return num
end

---
-- 日常任务当前任务(按照213排序)
-- @function [parent=#TaskModel] getShowTask
-- @param #TaskModel self
-- @return #table
function TaskModel:getShowTask()
    self._curTask = {}
    for k,v in pairs(self._data.showTask) do
        table.insert(self._curTask,k)
        self:_getCurNum(tostring(k))
    end
    -- 卡顿，暂时屏蔽
    table.sort(self._curTask,function(t1,t2)
        local t1state = self:getState(t1)
        local t2state = self:getState(t2)
        if t1state == t2state then
            return tonumber(t1)< tonumber(t2)
        elseif t1state == 2 and t2state ~= 2 then
            return true
        elseif t1state ~= 2 and t2state == 2 then
            return false
        elseif t1state ~= 2 and t2state ~= 2 then
            return t1state < t2state
        end
    end)
    return self._curTask
end

---
-- 今天是否刷新过
-- @function [parent=#TaskModel] getTodaySign
-- @param #TaskModel self
-- @return #number
function TaskModel:getTodaySign()
    if self._data.sign then
        return self._data.sign
    else
        return 0
    end
end

---
-- 增加刷新次数
-- @function [parent=#TaskModel] addTodaySign
-- @param #TaskModel self
-- @param #number num
function TaskModel:addTodaySign(num)
    if self._data.sign then
        self._data.sign = self._data.sign + num
    else
        self._data.sign = num
    end
end

-- 增加刷新次数
-- @function [parent=#TaskModel] addTodaySign
-- @param #TaskModel self
-- @param #number num
function TaskModel:setTodaySign(num)
    self._data.sign = num
end

---
-- 今天完成任务数
-- @function [parent=#TaskModel] getTodayTaskDoneNum
-- @param #TaskModel self
-- @return #number
function TaskModel:getTodayTaskDoneNum()
    if self._data.taskNum then
        return self._data.taskNum
    else
        return 0
    end
end

---
-- 增加今天完成任务数
-- @function [parent=#TaskModel] addTodayTaskDoneNum
-- @param #TaskModel self
-- @param #number num
function TaskModel:addTodayTaskDoneNum(num)
    self._data.taskNum = self._data.taskNum + num
end

---
-- 本次转生前已获得力量源泉
-- @function [parent=#TaskModel] getCurPowerNum
-- @param #TaskModel self
-- @return #number
function TaskModel:getCurPowerNum()
    return self._data.power
end

---
-- 获得力量源泉
-- @function [parent=#TaskModel] addPowerNum
-- @param #TaskModel self
-- @param #number num
function TaskModel:addPowerNum(num)
    self._data.power = self._data.power + num
    if self._data.power > GameConst.TASK_TOTAL_PROWER then
        self._data.power = GameConst.TASK_TOTAL_PROWER
    end
end

---
-- 本次转生前已获得力量源泉加成比
-- @function [parent=#TaskModel] getCurPowerRatio
-- @param #TaskModel self
-- @return #number
function TaskModel:getCurPowerRatio()
    local num = self:getCurPowerNum()
    return 0.1*num+1
end


local tmpIds = {}
local tmpLevel = {}
---
-- 任务进度当前(进度)
-- @function [parent=#TaskModel] _getCurNum
-- @param #TaskModel self
-- @param #string id
function TaskModel:_getCurNum(id)
    if self:getState(id) > 1 then
        self._data.showTask[id].num = GameConfig.TaskConfig:getData(id).goal
        return 
    end
    
    local evtType = nil
    local func = nil
    local type = GameConfig.TaskConfig:getData(id).taskType
    local addNum = function(num)
        if num == nil or self._data == nil or self._data.showTask == nil or self._data.showTask[id] == nil or self._data.showTask[id].num==nil then
            DEBUG("id="..id)
           return
        end
        
        self._data.showTask[id].num = self._data.showTask[id].num + num
        self:_raiseDataChangeEvent(id,self.dataType.curNum)
        self:changeState(id)
    end
    
    if type == "1" then   -- 收取挂机奖励
        func = function(obj,evt)
            addNum(1)
        end
    elseif type == "2" then  -- 挑战魔王
        func = function(obj,evt)
            if evt.dataType == ch.LevelModel.dataType.curLevel and ch.LevelModel:getCurLevel()%5 == 0 then
                addNum(1)
            end
        end
    elseif type == "3" then   -- 通过关卡数
        func = function(obj,evt)
            if not tmpLevel[id] then
                tmpLevel[id] = ch.LevelModel:getMaxLevel()
            end
            if evt.dataType == ch.LevelModel.dataType.curLevel and ch.LevelModel:getCurLevel()== ch.LevelModel:getMaxLevel() then
                if ch.LevelModel:getMaxLevel() > tmpLevel[id] then
                    addNum(1)
                end
                tmpLevel[id] = ch.LevelModel:getMaxLevel()    
            end
        end
    elseif type == "4" then   -- 累计点击次数
        func = function(obj,evt)
            addNum(1)
        end    
    elseif type == "5" then   -- 完成每秒点击次数
        func = function(obj,evt)
            if math.floor(ch.clickLayer:getClickSpeed())>self._data.showTask[id].num then
                self._data.showTask[id].num = math.floor(ch.clickLayer:getClickSpeed())
                self:_raiseDataChangeEvent(id,self.dataType.curNum)
                self:changeState(id)
            end
        end  
    elseif type == "6" then   -- 累计提升宝物等级
        func = function(obj,evt)
            if evt.dataType == ch.MagicModel.dataType.level and evt.value > 0 then
                addNum(evt.value)
            end
        end
    elseif type == "7" then  -- 累计提升宠物等级
        func = function(obj,evt)
            if evt.value > 0 then
                addNum(evt.value)
            end
        end
    elseif type == "8" then    -- 累计提升图腾等级
        func = function(obj,evt)
            if evt.dataType == ch.TotemModel.dataType.level and evt.value > 0 then
                addNum(evt.value)
            end
        end
    elseif type == "9" then   -- 使用任意主动技能
        func = function(obj,evt)
            if evt.statusType == ch.RunicModel.StatusType.began then
                addNum(1)
            end
        end
    elseif type == "10" then  -- 消灭宝箱怪
        func = function(obj,evt)
            if evt.roleType == 3 then
                addNum(1)
            end
        end
    elseif type == "11" then  -- 累计消灭怪物
        func = function(obj,evt)
            if evt.roleType == 1 then
                addNum(1)
            end
        end
    elseif type == "12" then  -- 获得小仙女的宝箱
        func = function(obj,evt)
            addNum(1)
        end
    elseif type == "13" then  -- 获得魂石个数
        func = function(obj,evt)
            if evt.dataType == ch.MoneyModel.dataType.sStone and evt.value > 0 then
                addNum(evt.value)
            end
        end
    else
        evtType = ""
        func = function(obj,evt)
            cclog("其他")
        end
    end
    
    evtType = taskTypeEvent[tonumber(type)]
    if not self._typeEventId[id] then
        self._typeEventId[id] = zzy.EventManager:listen(evtType,func)
    end
    self:_raiseDataChangeEvent(id,self.dataType.curNum)
    self:changeState(id)
end


---
-- 任务进度当前(进度)
-- @function [parent=#TaskModel] changeState
-- @param #TaskModel self
-- @param #string id
function TaskModel:changeState(id)
    local goal = GameConfig.TaskConfig:getData(id).goal
    if self._data.showTask[id].s == 1 and self._data.showTask[id].num >= goal then
        self._data.showTask[id].s = 2
        self._data.showTask[id].num = goal
        if self._typeEventId[id] then
            zzy.EventManager:unListen(self._typeEventId[id])
            self._typeEventId[id] = nil
        end
        self:_raiseDataChangeEvent(id,self.dataType.state)
    end
end

---
-- 任务进度当前(进度)
-- @function [parent=#TaskModel] getCurNum
-- @param #TaskModel self
-- @param #string id
-- @return #number
function TaskModel:getCurNum(id)
    if self._data.showTask[id] then
        return self._data.showTask[id].num
    else
        return 0
    end
end

---
-- 是否可领奖
-- @function [parent=#TaskModel] getState
-- @param #TaskModel self
-- @param #string id
-- @return #number
function TaskModel:getState(id)
    if self._data.showTask[id] then
        return self._data.showTask[id].s
    else
        return 1
    end
end

local sendNum = {}
---
-- 定时发送数据（4,5,10）
-- @function [parent=#TaskModel] taskTimeData
-- @param #TaskModel self
-- @return #table
function TaskModel:taskTimeData()
    sendNum = {}
    if not self._data.showTask then 
        return sendNum
    end
    for k,v in pairs(self._data.showTask) do
        if v.s < 3 then
           -- local type = GameConfig.TaskConfig:getData(k).taskType
           -- if type == "4" or type == "5" or type == "10" then
                sendNum[k] = self:getCurNum(k)
           -- end
       -- else
        --    sendNum[k] = nil
        end
    end
    return sendNum
end


---
-- 按照难度类型取得任务ID
-- @function [parent=#TaskModel] _getTaskIDByType
-- @param #TaskModel self
function TaskModel:_getTaskIDByType()
    local tmp = GameConfig.TaskConfig:getTable()
    for k,v in pairs(tmp) do
        if not self._taskType[v.taskGrade] then
            self._taskType[v.taskGrade] = {}
        end
        table.insert(self._taskType[v.taskGrade],v.id)
    end
end

---
-- 取得任务ID(排重)
-- @function [parent=#TaskModel] _getRandTask
-- @param #TaskModel self
function TaskModel:_getRandTask()
    if table.maxn(self._curTask) < 1 then
        cc.UserDefault:getInstance():setIntegerForKey("taskTime",math.ceil(os_clock()))
        self:_getRandTaskByType(1)
        self:_getRandTaskByType(2)
        self:_getRandTaskByType(3)
        self:getShowTask()
    end
end


---
-- 随机取得不同难度任务ID(排重)
-- @function [parent=#TaskModel] _getRandTaskByType
-- @param #TaskModel self
-- @param #number type
function TaskModel:_getRandTaskByType(type)
    local randNum = math.random(1,table.maxn(self._taskType[type]))
    local newId = self._taskType[type][randNum]
    self._data.showTask[newId] = {num = 0,s=1}
end

---
-- 任务奖励
-- @function [parent=#TaskModel] getRewardNum
-- @param #TaskModel self
-- @param #string id
-- @return #number 
function TaskModel:getRewardNum(id)
    local config = GameConfig.TaskConfig:getData(id)
    if config.rewardType == "1" then
        return ch.CommonFunc:getOffLineGold(config.rewardValue/10000)
    else
        return config.rewardValue/10000
    end
end

---
-- 领取任务奖励
-- @function [parent=#TaskModel] getTaskReward
-- @param #TaskModel self
-- @param #string id
function TaskModel:getTaskReward(id)
    if self._data.showTask[id].s == 2 then
        self._data.showTask[id].s = 3
        local config = GameConfig.TaskConfig:getData(id)
        if config.rewardType == "1" then
            local gold = ch.CommonFunc:getOffLineGold(config.rewardValue/10000)
            ch.MoneyModel:addGold(gold)
            ch.CommonFunc:playGoldSound(gold)
        elseif config.rewardType == "2" then
            ch.MoneyModel:addDiamond(config.rewardValue/10000)
        elseif config.rewardType == "3" then
            ch.BuffModel:addInspireBuff(config.rewardValue/10000)
        elseif config.rewardType == "4" then
            ch.BuffModel:addManyGoldBuff(config.rewardValue/10000)
        end
    end
    self:addTodayTaskDoneNum(1)
    -- 获得今日的力量源泉
    if self:getTodayTaskDoneNum()~=0 and self:getTodayTaskDoneNum()%3 == 0 then
        ch.TaskModel:addPowerNum(1)
        ch.MagicModel:resetDPS()
    end
    self:_raiseDataChangeEvent(id,self.dataType.state)
end

---
-- 不同难度任务剩余个数
-- @function [parent=#TaskModel] gradeTaskNumTable
-- @param #TaskModel self
-- @return #table
function TaskModel:gradeTaskNumTable()
    local gradeTable = {}
    for k,v in pairs(self._data.showTask) do
        if v.s ~= 3 then
            local grade = GameConfig.TaskConfig:getData(k).taskGrade
            gradeTable[grade] = gradeTable[grade] or 0
            gradeTable[grade] = gradeTable[grade]+1
        end
    end
    for i = 1,3 do -- 难度级别
        gradeTable[i] = gradeTable[i] or 0
    end
    return gradeTable
end

---
-- 必刷任务
-- @function [parent=#TaskModel] refreshTaskMust
-- @param #TaskModel self
-- @return #table
function TaskModel:refreshTaskMust()
    local tmpTable = {}
    local gradeTable = self:gradeTaskNumTable()
    for i = 1,3 do 
        if gradeTable[i] < 1 then
            table.insert(tmpTable,i)
        end
    end
    return tmpTable
end

---
-- 可刷任务
-- @function [parent=#TaskModel] refreshTaskOK
-- @param #TaskModel self
-- @return #table
function TaskModel:refreshTaskOK()
    local tmpTable = {}
    local gradeTable = self:gradeTaskNumTable()
    for k,v in pairs(gradeTable) do 
        if k == 1 or k == 2 then
            if gradeTable[k] < 2 then
                table.insert(tmpTable,k)
            end
        else 
            if gradeTable[3] < 1 then
                table.insert(tmpTable,3)
            end
        end
    end

    return tmpTable
end

---
-- 处理完成的任务
-- @function [parent=#TaskModel] cleanDoneData
-- @param #TaskModel self
function TaskModel:cleanDoneData()
    for k,v in pairs(self._data.showTask) do
        if v.s == 3 then
            self._data.showTask[k] = nil
        end
    end
end

---
-- 关闭领取界面
-- @function [parent=#TaskModel] sendGetTaskEvent
-- @param #TaskModel self
function TaskModel:sendGetTaskEvent()
    self:_raiseDataChangeEvent("0",self.dataType.get)
end

---
-- 过天刷新(显示主界面图标)
-- @function [parent=#TaskModel] onNextDay
-- @param #TaskModel self
function TaskModel:onNextDay()
    self._data.taskNum = 0
    if (self:getTaskNum(1)+self:getTaskNum(2))<5 then
        self._data.sign = 0
    end
    self:_raiseDataChangeEvent("0",self.dataType.state)
end

---
-- 过天刷新（刷新任务）接收服务器数据
-- @function [parent=#TaskModel] onNextDayData
-- @param #TaskModel self
-- @param #table task
function TaskModel:onNextDayData(task)
    -- 取出今天刷新出的任务
    self._todayTask = {}
    self._oldTask = {}
    self.refreshPlay = true
    if self:getTodaySign() < 1 then
        for k,v in pairs(task) do
            if not self._data.showTask[k] then
                table.insert(self._todayTask,k)
            elseif self._data.showTask[k].s == 3 then
                table.insert(self._todayTask,k)
            else
                table.insert(self._oldTask,k)
            end
        end
    end
    sendNum = {}
    self._data.showTask = {}
    for k,v in pairs(self._typeEventId) do 
        zzy.EventManager:unListen(v)
    end
    self._typeEventId = {}
    for k,v in pairs(task) do
        self._data.showTask[k] = v
        if self:getTodaySign() > 0 then
            table.insert(self._todayTask,k)
        end
    end
    self:getShowTask()
    self:addTodaySign(1)
    self:_raiseDataChangeEvent("0",self.dataType.state)
end

---
-- 得到今天的新任务和昨天的旧任务
-- @function [parent=#TaskModel] getTaskNewAndOld
-- @param #TaskModel self
-- @return #table
function TaskModel:getTaskNewAndOld()
    local tmpTable = {}
    for k,v in pairs(self._todayTask) do
        table.insert(tmpTable,v)
    end
    for k,v in pairs(self._oldTask) do
        table.insert(tmpTable,v)
    end
    return tmpTable
end

---
-- 得到今天任务数
-- @function [parent=#TaskModel] getTodayTaskNum
-- @param #TaskModel self
-- @return #number
function TaskModel:getTodayTaskNum()
    return table.maxn(self._todayTask) or 0
end

---
-- 得到今天任务Icon
-- @function [parent=#TaskModel] getTodayTaskIcon
-- @param #TaskModel self
-- @param #number index 第几个任务
-- @param #string
function TaskModel:getTodayTaskIcon(index)
    if self._todayTask[index] then
        return GameConfig.TaskConfig:getData(self._todayTask[index]).icon
    else
        return "aaui_card/baowu0001.png"
    end
end

---
-- 得到今天任务Grade
-- @function [parent=#TaskModel] getTodayTaskGrade
-- @param #TaskModel self
-- @param #number index 第几个任务
-- @return #number
function TaskModel:getTodayTaskGrade(index)
    if self._todayTask[index] then
        return GameConfig.TaskConfig:getData(self._todayTask[index]).taskGrade
    else
        return 3
    end
end

---
-- 是否有2，3任务
-- @function [parent=#TaskModel] getTodayTaskVis
-- @param #TaskModel self
-- @param #number index 第几个任务
-- @return #boolean
function TaskModel:getTodayTaskVis(index)
    if self._todayTask[index] then
        return true
    else
        return false
    end
end

---
-- 今天是否需要刷新任务（免费次数）
-- @function [parent=#TaskModel] isTodayRefresh
-- @param #TaskModel self
function TaskModel:isTodayRefresh()
    if ch.StatisticsModel:getMaxLevel()>GameConst.TASK_OPEN_LEVEL and self:getTodaySign() == 0 and (self:getTaskNum(1)+self:getTaskNum(2))<5 then 
        return true
    end
    return false
end

---
-- 关于轮回(清除力量源泉)
-- @function [parent=#TaskModel] onSamsara
-- @param #TaskModel self
function TaskModel:onSamsara()
    ch.MoneyModel:addSoul(self._data.power)
    self._data.power = 0
    ch.MagicModel:resetDPS()
    self:_raiseDataChangeEvent("0",self.dataType.state)
end

return TaskModel