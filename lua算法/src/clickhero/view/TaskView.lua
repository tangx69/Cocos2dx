local rotateUnit = function(widget,func)
    local ani = cc.RotateBy:create(0.15,cc.Vertex3F(90,0,0))
    local seq = cc.Sequence:create(ani,cc.CallFunc:create(function()
        local spr = cc.Sprite:createWithSpriteFrameName("aaui_diban/Task_Bg.png")
        spr:setRotation(180)
        widget:addChild(spr)
        spr:setPosition(303,58)
        widget:noticeDataChange("data")
        local ani = cc.RotateBy:create(0.3,cc.Vertex3F(180,0,0))
        local seq = cc.Sequence:create(ani,cc.CallFunc:create(function()
            spr:removeFromParent()
            local ani = cc.RotateBy:create(0.15,cc.Vertex3F(90,0,0))
            if func then
                local seq = cc.Sequence:create(ani,cc.CallFunc:create(function()
                    func()
                end))
                widget:runAction(seq)
            else
                widget:runAction(ani) 
            end
        end))
        widget:runAction(seq)
    end))
    widget:runAction(seq)
end 

-- 固有绑定
-- 日常任务界面
zzy.BindManager:addFixedBind("task/W_TaskList", function(widget)
    local taskChangeEvent = {}
    taskChangeEvent[ch.TaskModel.dataChangeEventType] =  function(evt)
        return evt.dataType == ch.TaskModel.dataType.state
    end
    
    local levelChangeEvent = {}
    levelChangeEvent[ch.LevelModel.dataChangeEventType] =  function(evt)
        return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    
    local refreshChangeEvent = {}
    refreshChangeEvent[ch.LevelModel.dataChangeEventType] =  function(evt)
        return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    refreshChangeEvent[ch.TaskModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.TaskModel.dataType.state
    end
    
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    moneyChangeEvent[ch.TaskModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.TaskModel.dataType.state
    end
    
    -- 标题
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_TaskView_1
    end)
    -- 刷新描述
    widget:addDataProxy("refreshDesc",function(evt)
        if ch.TaskModel:getTaskNum(0) ~= 0 and ch.TaskModel:getTaskNum(0) == ch.TaskModel:getTaskNum(3) and ch.TaskModel:getTodaySign() == GameConst.TASK_TOTAL_REFRESH then
            return GameConst.TASK_TODAY_REFRESH_DESC[2]
        else
            return GameConst.TASK_TODAY_REFRESH_DESC[1]
        end
    end,taskChangeEvent)
    -- 未开启系统描述
    widget:addDataProxy("NoOpenDesc",function(evt)
        return GameConst.TASK_OPEN_DESC
    end)
    -- 未开启系统
    widget:addDataProxy("ifNoOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel()<= GameConst.TASK_OPEN_LEVEL
    end,levelChangeEvent)
    -- 已开启系统
    widget:addDataProxy("ifOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel()> GameConst.TASK_OPEN_LEVEL
    end,levelChangeEvent)

    -- 当前获得力量源泉数
    widget:addDataProxy("curPowerNum",function(evt)
        return ch.TaskModel:getCurPowerNum()
    end,taskChangeEvent)
    -- 一次转生内获得力量源泉上限
    widget:addDataProxy("allPowerNum",function(evt)
        return GameConst.TASK_TOTAL_PROWER
    end)
    -- 一次转生内获得力量源泉加成
    widget:addDataProxy("curPowerRatio-num", function(evt)
        return ch.TaskModel:getCurPowerNum()*10
    end,taskChangeEvent)
    -- 一次转生内获得力量源泉加成
    widget:addScrollData("curPowerRatio-num", "curPowerRatio",1, function(v)
--        if v == 0 then
--            return "+"..v
--        else
        return "+"..string.format("%d",v).."%"
--        end
    end,"powernum")
    widget:addScrollData("curPowerRatio-num", "curPowerRatio_0",1, function(v)
        return "+"..string.format("%d",v).."%"
    end,"powernum_0")
    -- 当前已刷新次数
    widget:addDataProxy("refreshNum",function(evt)
        return ch.TaskModel:getTodaySign()<1 and 0 or ch.TaskModel:getTodaySign()-1
    end,refreshChangeEvent)
    widget:addDataProxy("allRefreshNum",function(evt)
        return GameConst.TASK_TOTAL_REFRESH - 1
    end)
    
    widget:addDataProxy("price",function(evt)
        return GameConst.TASK_REFRESH_COST
    end)

    widget:addDataProxy("ifCanBuy",function(evt)
        return ch.TaskModel:getTodaySign() < GameConst.TASK_TOTAL_REFRESH and ch.MoneyModel:getDiamond() >= GameConst.TASK_REFRESH_COST 
    end,moneyChangeEvent)

    widget:addCommond("refresh",function()
        local buy = function()
            ch.NetworkController:taskRefresh()
            ch.MoneyModel:addDiamond(-GameConst.TASK_REFRESH_COST)
        end
        local tmp = {price = GameConst.TASK_REFRESH_COST,buy = buy}
        ch.ShopModel:getCostTips(tmp)
    end)
    
    widget:addDataProxy("ifCanRefrash",function(evt)
        return ch.TaskModel:getTaskNum(0) ~= 0 and ch.TaskModel:getTaskNum(0) == ch.TaskModel:getTaskNum(3) and ch.TaskModel:getTodaySign() < GameConst.TASK_TOTAL_REFRESH
    end,taskChangeEvent) 
    
    -- 显示Tips
    local showTip = false
    widget:addDataProxy("isShowTip",function(evt)
        return showTip
    end)
    widget:addCommond("showTip",function(obj,type)
        if type == ccui.TouchEventType.began then
            showTip = true
            widget:noticeDataChange("isShowTip")
        elseif type == ccui.TouchEventType.ended or type == ccui.TouchEventType.canceled then
            showTip = false
            widget:noticeDataChange("isShowTip")
        end 
    end)
    
    -- 任务单元列表
    widget:addDataProxy("items", function(obj,evt)
        local tmpData = {}
--        if ch.TaskModel:getTodaySign() < GameConst.TASK_TOTAL_REFRESH and ch.TaskModel:getTaskNum(0) ~= 0 and ch.TaskModel:getTaskNum(0) == ch.TaskModel:getTaskNum(3) then
--            table.insert(tmpData,{index =2,value = "0",isMultiple = true})
--        end
        if ch.TaskModel.refreshPlay then
            for k,v in pairs(ch.TaskModel:getTaskNewAndOld()) do
                table.insert(tmpData,{index =1,value = v,isMultiple = true})
            end
            ch.TaskModel:sendGetTaskEvent()
        else
            for k,v in pairs(ch.TaskModel:getShowTask()) do
                table.insert(tmpData,{index =1,value = v,isMultiple = true})
            end
        end
        return tmpData
    end,refreshChangeEvent)
    
    widget:listen(ch.TaskModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.TaskModel.dataType.get then
            if not ch.TaskModel.refreshPlay then
                return
            end
            zzy.TimerUtils:setTimeOut(0,function()
                ch.TaskModel.refreshPlay = false
                if ch.TaskModel:getTodayTaskNum() > 0 then
                    local listView = widget:getChild("ListView_1")
                    for i= 1,ch.TaskModel:getTodayTaskNum() do
                        local delay = i * 0.15
                        if delay > 0 then
                            widget:setTimeOut(delay,function()
                                local unit = listView:getItem(i-1)
                                rotateUnit(unit)
                            end)
                        else
                            local unit = listView:getItem(i-1)
                            rotateUnit(unit)
                        end
                    end
                end
            end)
        end
    end)

    
--    local taskOpenEvent = {}
--    taskOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
--        return evt.view == "task/W_TaskList"
--    end
--    -- 上按钮可见
--    widget:addDataProxy("upVisible", function(evt)
--        if evt then
--            return evt.popType == ch.UIManager.popType.HalfOpen
--        else
--            return true
--        end
--    end,taskOpenEvent)
--    -- 下按钮可见
--    widget:addDataProxy("downVisible", function(evt)
--        if evt then
--            return evt.popType ~= ch.UIManager.popType.HalfOpen
--        else
--            return false
--        end
--    end,taskOpenEvent)
--    -- listView高度
--    widget:addDataProxy("listHeight", function(evt)
--        if evt then
--            if evt.popType == ch.UIManager.popType.HalfOpen then
--                return GameConst.MAINVIEW_OPEN_LISTVIEW_HEIGHT[1] 
--            else
--                return GameConst.MAINVIEW_OPEN_LISTVIEW_HEIGHT[2]
--            end
--        else
--            return GameConst.MAINVIEW_OPEN_LISTVIEW_HEIGHT[1]
--        end
--    end,taskOpenEvent)
end)

---
-- 日常任务单元
zzy.BindManager:addCustomDataBind("task/W_TaskListunit",function(widget,data)
    local taskChangeEvent = {}
    taskChangeEvent[ch.TaskModel.dataChangeEventType] = function(evt)
    	return evt.id == data
    end
    
    local goldChangeEvent = {}
    goldChangeEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    
    local config = GameConfig.TaskConfig:getData(data)
    -- 任务名称
    widget:addDataProxy("taskName",function(evt)
        return config.name
    end)
    -- 任务图标
    widget:addDataProxy("taskIcon",function(evt)
        return config.icon
    end)
    -- 任务难度级别
    widget:addDataProxy("taskGrade",function(evt)
        return GameConst.TASK_GRADE_ICON[tonumber(config.taskGrade)]
    end)
    -- 任务进度当前
    widget:addDataProxy("curNum",function(evt)
        return ch.TaskModel:getCurNum(data)
    end,taskChangeEvent)
    -- 任务进度总数
    widget:addDataProxy("goalNum",function(evt)
        return config.goal
    end)
    -- 任务描述
    widget:addDataProxy("taskDes",function(evt)
        return config.desc
    end)
    -- 奖励类型1金币
    widget:addDataProxy("rewardType1",function(evt)
        return config.rewardType == "1"
    end)
    -- 奖励类型2钻石
    widget:addDataProxy("rewardType2",function(evt)
        return config.rewardType == "2"
    end)
    -- 奖励类型3buff
    widget:addDataProxy("rewardType3",function(evt)
        return config.rewardType == "3" or config.rewardType == "4"
    end)
    -- buff类型
    widget:addDataProxy("buffType",function(evt)
        if config.rewardType == "3" then
            return Language.src_clickhero_view_TaskView_2
        elseif config.rewardType == "4" then
            return Language.src_clickhero_view_TaskView_3
        else
            return Language.src_clickhero_view_TaskView_2
        end 
    end)
    -- 奖励数量
    widget:addDataProxy("rewardNum",function(evt)
        if config.rewardType == "3" or config.rewardType == "4" then
            return ch.NumberHelper:toString(ch.TaskModel:getRewardNum(data))..Language.src_clickhero_utils_NumberHelper_7
        else
            return ch.NumberHelper:toString(ch.TaskModel:getRewardNum(data))
        end
    end,goldChangeEvent)
    -- 奖励说明
    widget:addDataProxy("rewardDes",function(evt)
        return GameConst.TASK_REWARD_DESC[tonumber(config.rewardType)]
    end)
    -- 可领奖
    widget:addDataProxy("ifCanGet",function(evt)
        return ch.TaskModel:getState(data) == 2
    end,taskChangeEvent)
    -- 底板显示（金色）
    widget:addDataProxy("ifGold",function(evt)
        return ch.TaskModel:getState(data) ~= 1
    end,taskChangeEvent)
    -- 底板显示（灰色）
    widget:addDataProxy("ifNoGold",function(evt)
        return ch.TaskModel:getState(data) == 1
    end,taskChangeEvent)
    -- 已领奖(不显示按钮)
    widget:addDataProxy("ifGetReward",function(evt)
        return ch.TaskModel:getState(data) ~= 3
    end,taskChangeEvent)
    -- 已领奖(显示图片)
    widget:addDataProxy("ifNoGetReward",function(evt)
        return ch.TaskModel:getState(data) == 3
    end,taskChangeEvent) 
    -- 领奖
    widget:addCommond("receiveReward",function()
        local tmpNum = ch.TaskModel:getCurPowerNum()
        local gold = 0
        if config.rewardType == "1" then
            gold = ch.TaskModel:getRewardNum(data)
        end
        ch.NetworkController:getTaskReward(data,gold)
        widget:playEffect("taskRewardEffect",false)
        local taskNum = ch.TaskModel:getTodayTaskDoneNum()
        -- 获得今日的力量源泉
        if taskNum ~=0 and taskNum%3 == 0 then
            if tmpNum == GameConst.TASK_TOTAL_PROWER then
                ch.UIManager:showNotice(Language.src_clickhero_view_TaskView_4,cc.c4b(255,0,0,255))
            else
                widget:playEffect("liliangyuanquan")
            end
        end
    end)
end)

---
-- 日常任务刷新按钮
zzy.BindManager:addCustomDataBind("task/W_TaskListBtn",function(widget,data)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    widget:addDataProxy("price",function(evt)
        return GameConst.TASK_REFRESH_COST
    end)
    
    widget:addDataProxy("ifCanBuy",function(evt)
        return ch.MoneyModel:getDiamond() >= GameConst.TASK_REFRESH_COST
    end,moneyChangeEvent)
    
    widget:addCommond("refresh",function()
        ch.NetworkController:taskRefresh()
        ch.MoneyModel:addDiamond(-GameConst.TASK_REFRESH_COST)
--        ch.UIManager:showGamePopup("task/W_Taskrefrash")
--        cclog("刷新")
--        ch.TaskModel:_raiseDataChangeEvent("1",ch.TaskModel.dataType.get)
    end)
end)

-- 日常任务领取界面
zzy.BindManager:addFixedBind("task/W_Taskrefrash", function(widget)
    local refreshChangeEvent = {}
    refreshChangeEvent[ch.TaskModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.TaskModel.dataType.state
    end
    -- 任务1图标
    widget:addDataProxy("taskIcon1",function(evt)
        return ch.TaskModel:getTodayTaskIcon(1)
    end,refreshChangeEvent)
    -- 任务1难度
    widget:addDataProxy("taskGrade1",function(evt)
        return GameConst.TASK_GRADE_ICON[tonumber(ch.TaskModel:getTodayTaskGrade(1))]
    end,refreshChangeEvent)
    -- 任务2图标
    widget:addDataProxy("taskIcon2",function(evt)
        return ch.TaskModel:getTodayTaskIcon(2)
    end,refreshChangeEvent)
    -- 任务2难度
    widget:addDataProxy("taskGrade2",function(evt)
        return GameConst.TASK_GRADE_ICON[tonumber(ch.TaskModel:getTodayTaskGrade(2))]
    end,refreshChangeEvent)
    widget:addDataProxy("taskGradeVis2",function(evt)
        return ch.TaskModel:getTodayTaskVis(2)
    end,refreshChangeEvent)
    -- 任务3图标
    widget:addDataProxy("taskIcon3",function(evt)
        return ch.TaskModel:getTodayTaskIcon(3)
    end,refreshChangeEvent)
    -- 任务3难度
    widget:addDataProxy("taskGrade3",function(evt)
        return GameConst.TASK_GRADE_ICON[tonumber(ch.TaskModel:getTodayTaskGrade(3))]
    end,refreshChangeEvent)
    widget:addDataProxy("taskGradeVis3",function(evt)
        return ch.TaskModel:getTodayTaskVis(3)
    end,refreshChangeEvent)
    -- 描述
    widget:addDataProxy("desc",function(evt)
        return GameConst.TASK_REFRESH_DESC
    end)
    widget:addCommond("getTask",function()
        ch.TaskModel:sendGetTaskEvent()
        widget:destory()
    end)
end)
