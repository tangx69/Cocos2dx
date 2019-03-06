local ZHUANPAN_END_CHANGE_EVENT = "ZHUANPAN_END_CHANGE"
--转盘
zzy.BindManager:addFixedBind("Christmas/W_zhuanpan", function(widget)
    local timesChangeEvent = {}
    timesChangeEvent[ch.ChristmasModel.wheelChangeEventType] = false
    ch.ChristmasModel:setWheelReward(nil)
--    widget:addDataProxy("leftTime",function(evt)
--        local time = math.floor(ch.ChristmasModel:getEndTimeByType(1006) - os_time())
--        if time<0 then
--            return "0"
--        end
--        local second = time%60
--        time = math.floor(time/60)
--        if time < 1 then
--            return string.format("%02d",second)
--        end
--        local min = time%60
--        time = math.floor(time/60)
--        if time < 1 then
--            return string.format("%02d:%02d",min,second)
--        end
--        return string.format("%02d:%02d:%02d",time,min,second)
--    end)
    
    widget:addDataProxy("leftTime",function(evt)
--        local str = os.date(Language.src_clickhero_view_WheelView_1,tonumber(ch.ChristmasModel:getOpenTimeByType(1006)))
--        str = str .. os.date(Language.src_clickhero_view_WheelView_2,tonumber(ch.ChristmasModel:getEndTimeByType(1006)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1006)) - os_time()
        return Language.HOLIDAY_DIAMOND_WHEEL_CDTIME..ch.NumberHelper:cdTimeToString(time)
    end)
    
    local curTimesIndex = 1
    local maxTimesIndex = #GameConst.HOLIDAY_WHEEL_TIMES
    local cfg = ch.ChristmasModel:getCSVDataByType(1006)
    local canStart = true
    
    local speed = 720
    local n = 2       -- 减速要多走的圈数
    local minTime = 0 -- 匀速运动的最小时间
    
    local lastTime = os_clock()
    local lastRefrashTime = lastTime
    local startWheelTime
    local startReduceTime
    local statue = 0
    local curRotation = 0
    local posRotation
    local totalTime =0
    local a=0 --加速度
    local isWheeling = false
    local panel = widget:getChild("panel_zhuanpan")
    widget:listen(zzy.Events.TickEventType,function(evt)
        local now = os_clock()
        if now - lastRefrashTime > 0.2 then
            widget:noticeDataChange("leftTime")
            lastRefrashTime = now
        end
        if statue > 0 then
            local dt = now - lastTime
            if statue == 1 then
                if ch.ChristmasModel:getWheelReward() and now - startWheelTime >minTime then
                    statue = 2
                    local id = ch.ChristmasModel:getWheelId()
                    local minr = 45*(8-id) + 22.5
                    local r = math.random(0,35)
                    posRotation = minr + r + 5
                    if posRotation >= 360 then
                        posRotation = posRotation - 360
                    end
                    local disR = 0
                    if curRotation > posRotation then
                        disR = 360 - curRotation + posRotation
                    else
                        disR = posRotation - curRotation
                    end
                    if disR < 90 then
                        disR = disR + 360
                    end
                    disR = disR + 360 *n
                    a = math.pow(speed,3)/(2*disR*disR)
                    totalTime = math.sqrt(2*speed/a)
                    posRotation = curRotation + disR
                    startReduceTime = os_clock()
                end
            end
            if statue == 1 then
                curRotation = curRotation + speed*dt
            elseif statue == 2 then
                local t = totalTime -os_clock() + startReduceTime
                if t > 0 then
                    local s = 0.25*a*math.pow(t,3)
                    curRotation = posRotation - s
                else
                    statue = 0
                    curRotation = posRotation
                    widget:setTimeOut(0.2,function()
                        widget:noticeDataChange("rewardIcon")
                        widget:noticeDataChange("rewardNum")
                        widget:noticeDataChange("rewardName")
                        widget:noticeDataChange("rewardVisible")
                        canStart = true
                        widget:noticeDataChange("canStart")
                    end)    
                end
             end
             if curRotation >= 360 then
                curRotation = curRotation %360
             end
            panel:setRotation(curRotation)
        end
        lastTime = now
    end)
    
    widget:addDataProxy("wheelTimes",function(evt)
        return "X"..GameConst.HOLIDAY_WHEEL_TIMES[curTimesIndex]
    end)
    
    widget:addDataProxy("canStart",function(evt)
        return canStart
    end)
    
    widget:addDataProxy("cost",function(evt)
        local funcName = "HOLIDAY_WHEEL_PRICING_"..cfg[1].formula
        local cost = GameConst[funcName](ch.ChristmasModel:getWheelCount()+1-GameConst.HOLIDAY_WHEEL_FREE_COUNT)
        return cost*GameConst.HOLIDAY_WHEEL_TIMES[curTimesIndex]
    end,timesChangeEvent)
    
    widget:addDataProxy("freeCount",function(evt)
        return GameConst.HOLIDAY_WHEEL_FREE_COUNT - ch.ChristmasModel:getWheelCount()
    end,timesChangeEvent)
    
    widget:addDataProxy("freeVisible",function(evt)
        return ch.ChristmasModel:getWheelCount() < GameConst.HOLIDAY_WHEEL_FREE_COUNT
    end,timesChangeEvent)
    
    widget:addDataProxy("costVisible",function(evt)
        return ch.ChristmasModel:getWheelCount() >= GameConst.HOLIDAY_WHEEL_FREE_COUNT
    end,timesChangeEvent)
    
    widget:addDataProxy("image1",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[1].type,cfg[1].award_id)
    end)
    
    widget:addDataProxy("num1",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[1].type,cfg[1].award_id,cfg[1].num)
    end)
    
    widget:addDataProxy("image2",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[2].type,cfg[2].award_id)
    end)

    widget:addDataProxy("num2",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[2].type,cfg[2].award_id,cfg[2].num)
    end)
    
    widget:addDataProxy("image3",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[3].type,cfg[3].award_id)
    end)

    widget:addDataProxy("num3",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[3].type,cfg[3].award_id,cfg[3].num)
    end)
    
    widget:addDataProxy("image4",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[4].type,cfg[4].award_id)
    end)

    widget:addDataProxy("num4",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[4].type,cfg[4].award_id,cfg[4].num)
    end)
    
    widget:addDataProxy("image5",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[5].type,cfg[5].award_id)
    end)

    widget:addDataProxy("num5",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[5].type,cfg[5].award_id,cfg[5].num)
    end)
    
    widget:addDataProxy("image6",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[6].type,cfg[6].award_id)
    end)

    widget:addDataProxy("num6",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[6].type,cfg[6].award_id,cfg[6].num)
    end)
    
    widget:addDataProxy("image7",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[7].type,cfg[7].award_id)
    end)

    widget:addDataProxy("num7",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[7].type,cfg[7].award_id,cfg[7].num)
    end)
    
    widget:addDataProxy("image8",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[8].type,cfg[8].award_id)
    end)

    widget:addDataProxy("num8",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[8].type,cfg[8].award_id,cfg[8].num)
    end)
    
    widget:addDataProxy("rewardIcon",function(evt)
        local reward = ch.ChristmasModel:getWheelReward()
        if reward then
            return ch.CommonFunc:getRewardBigIcon(reward.t,reward.id) 
        end
        return ""
    end)
    
    widget:addDataProxy("rewardNum",function(evt)
        local reward = ch.ChristmasModel:getWheelReward()
        if reward then
            return "X"..ch.CommonFunc:getRewardValue(reward.t,reward.id,reward.num)
        end
        return ""
    end)
    
    widget:addDataProxy("rewardName",function(evt)
        local reward = ch.ChristmasModel:getWheelReward()
        if reward then
            return ch.CommonFunc:getRewardName(reward.t,reward.id)
        end
        return ""
    end)
    
    widget:addDataProxy("rewardVisible",function(evt)
        return ch.ChristmasModel:getWheelReward() ~= nil
    end)
    
    widget:addCommond("addTimes",function()
        curTimesIndex = curTimesIndex + 1
        if curTimesIndex > maxTimesIndex then
            curTimesIndex = 1
        end
        widget:noticeDataChange("wheelTimes")
        widget:noticeDataChange("cost")
        if canStart then
            ch.ChristmasModel:setWheelReward(nil)
            widget:noticeDataChange("rewardVisible")
        end
    end)
    
    widget:addCommond("start",function()
        if canStart then
            ch.ChristmasModel:setWheelReward(nil)
            widget:noticeDataChange("rewardVisible")
        end
        if ch.ChristmasModel:getWheelCount() < GameConst.HOLIDAY_WHEEL_FREE_COUNT then
            canStart = false
            widget:noticeDataChange("canStart")
            ch.ChristmasModel:setWheelCost(0,1)
            ch.NetworkController:startWheel(1)
            statue = 1
            startWheelTime = os_clock()
        else
            local funcName = "HOLIDAY_WHEEL_PRICING_"..cfg[1].formula
            local cost = GameConst[funcName](ch.ChristmasModel:getWheelCount()+1-GameConst.HOLIDAY_WHEEL_FREE_COUNT)
            cost = cost*GameConst.HOLIDAY_WHEEL_TIMES[curTimesIndex]
            if ch.MoneyModel:getDiamond() >= cost then
                ch.UIManager:showMsgBox(2,true,string.format(GameConst.HOLIDAY_WHEEL_TIPS[1],cost),function()
                    canStart = false
                    widget:noticeDataChange("canStart")
                    ch.ChristmasModel:setWheelCost(cost,GameConst.HOLIDAY_WHEEL_TIMES[curTimesIndex])
                    ch.NetworkController:startWheel(GameConst.HOLIDAY_WHEEL_TIMES[curTimesIndex])
                    statue = 1
                    startWheelTime = os_clock()
                end)
            else
                ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_WHEEL_TIPS[2])
            end
        end
    end)
    
    widget:addCommond("closeReward",function()
        if canStart then
            ch.ChristmasModel:setWheelReward(nil)
            widget:noticeDataChange("rewardVisible")
        end
    end)
    
    -- 提示
    local isShowTips = false
    local tipName = ""
    local tipDesc = ""
    widget:addDataProxy("isShowTip",function(evt)
        return isShowTips
    end)
    
    widget:addDataProxy("nameTip",function(evt)
        return tipName
    end)
    
    local descLabel = zzy.CocosExtra.seekNodeByName(widget, "tip_desc")
    descLabel:setMaxLineWidth(310)
    widget:addDataProxy("descTip",function(evt)
        return tipDesc
    end)
    
    widget:addCommond("showTip1",function(obj,type,point)
        if type == ccui.TouchEventType.began then
            if canStart then
                ch.ChristmasModel:setWheelReward(nil)
                widget:noticeDataChange("rewardVisible")
            end
            isShowTips = true
            tipName = string.format(cfg[1].name,ch.CommonFunc:getRewardName(cfg[1].type,cfg[1].award_id))
            tipDesc = cfg[1].script
            widget:noticeDataChange("isShowTip")
            widget:noticeDataChange("nameTip")
            widget:noticeDataChange("descTip")
        elseif type == ccui.TouchEventType.ended or
            type == ccui.TouchEventType.canceled then
            isShowTips = false
            widget:noticeDataChange("isShowTip")
        end
    end)
    
    widget:addCommond("showTip2",function(obj,type,point)
        if type == ccui.TouchEventType.began then
            if canStart then 
                ch.ChristmasModel:setWheelReward(nil)
                widget:noticeDataChange("rewardVisible")
            end
            isShowTips = true
            tipName = string.format(cfg[2].name,ch.CommonFunc:getRewardName(cfg[2].type,cfg[2].award_id))
            tipDesc = cfg[2].script
            widget:noticeDataChange("isShowTip")
            widget:noticeDataChange("nameTip")
            widget:noticeDataChange("descTip")
        elseif type == ccui.TouchEventType.ended or
            type == ccui.TouchEventType.canceled then
            isShowTips = false
            widget:noticeDataChange("isShowTip")
        end
    end)
    
    widget:addCommond("showTip3",function(obj,type,point)
        if type == ccui.TouchEventType.began then
            if canStart then
                ch.ChristmasModel:setWheelReward(nil)
                widget:noticeDataChange("rewardVisible")
            end
            isShowTips = true
            tipName = string.format(cfg[3].name,ch.CommonFunc:getRewardName(cfg[3].type,cfg[3].award_id))
            tipDesc = cfg[3].script
            widget:noticeDataChange("isShowTip")
            widget:noticeDataChange("nameTip")
            widget:noticeDataChange("descTip")
        elseif type == ccui.TouchEventType.ended or
            type == ccui.TouchEventType.canceled then
            isShowTips = false
            widget:noticeDataChange("isShowTip")
        end
    end)
    
    widget:addCommond("showTip4",function(obj,type,point)
        if type == ccui.TouchEventType.began then
            if canStart then
                ch.ChristmasModel:setWheelReward(nil)
                widget:noticeDataChange("rewardVisible")
            end
            isShowTips = true
            tipName = string.format(cfg[4].name,ch.CommonFunc:getRewardName(cfg[4].type,cfg[4].award_id))
            tipDesc = cfg[4].script
            widget:noticeDataChange("isShowTip")
            widget:noticeDataChange("nameTip")
            widget:noticeDataChange("descTip")
        elseif type == ccui.TouchEventType.ended or
            type == ccui.TouchEventType.canceled then
            isShowTips = false
            widget:noticeDataChange("isShowTip")
        end
    end)
    
    widget:addCommond("showTip5",function(obj,type,point)
        if type == ccui.TouchEventType.began then
            if canStart then
                ch.ChristmasModel:setWheelReward(nil)
                widget:noticeDataChange("rewardVisible")
            end
            isShowTips = true
            tipName = string.format(cfg[5].name,ch.CommonFunc:getRewardName(cfg[5].type,cfg[5].award_id))
            tipDesc = cfg[5].script
            widget:noticeDataChange("isShowTip")
            widget:noticeDataChange("nameTip")
            widget:noticeDataChange("descTip")
        elseif type == ccui.TouchEventType.ended or
            type == ccui.TouchEventType.canceled then
            isShowTips = false
            widget:noticeDataChange("isShowTip")
        end
    end)
    
    widget:addCommond("showTip6",function(obj,type,point)
        if type == ccui.TouchEventType.began then
            if canStart then
                ch.ChristmasModel:setWheelReward(nil)
                widget:noticeDataChange("rewardVisible")
            end
            isShowTips = true
            tipName = string.format(cfg[6].name,ch.CommonFunc:getRewardName(cfg[6].type,cfg[6].award_id))
            tipDesc = cfg[6].script
            widget:noticeDataChange("isShowTip")
            widget:noticeDataChange("nameTip")
            widget:noticeDataChange("descTip")
        elseif type == ccui.TouchEventType.ended or
            type == ccui.TouchEventType.canceled then
            isShowTips = false
            widget:noticeDataChange("isShowTip")
        end
    end)
    
    widget:addCommond("showTip7",function(obj,type,point)
        if type == ccui.TouchEventType.began then
            if canStart then
                ch.ChristmasModel:setWheelReward(nil)
                widget:noticeDataChange("rewardVisible")
            end
            isShowTips = true
            tipName = string.format(cfg[7].name,ch.CommonFunc:getRewardName(cfg[7].type,cfg[7].award_id))
            tipDesc = cfg[7].script
            widget:noticeDataChange("isShowTip")
            widget:noticeDataChange("nameTip")
            widget:noticeDataChange("descTip")
        elseif type == ccui.TouchEventType.ended or
            type == ccui.TouchEventType.canceled then
            isShowTips = false
            widget:noticeDataChange("isShowTip")
        end
    end)
    
    widget:addCommond("showTip8",function(obj,type,point)
        if type == ccui.TouchEventType.began then
            if canStart then
                ch.ChristmasModel:setWheelReward(nil)
                widget:noticeDataChange("rewardVisible")
            end
            isShowTips = true
            tipName = string.format(cfg[8].name,ch.CommonFunc:getRewardName(cfg[8].type,cfg[8].award_id))
            tipDesc = cfg[8].script
            widget:noticeDataChange("isShowTip")
            widget:noticeDataChange("nameTip")
            widget:noticeDataChange("descTip")
        elseif type == ccui.TouchEventType.ended or
            type == ccui.TouchEventType.canceled then
            isShowTips = false
            widget:noticeDataChange("isShowTip")
        end
    end)
end)


-- 钻石转盘
zzy.BindManager:addFixedBind("Christmas/W_ZSZP", function(widget)
    local timesChangeEvent = {}
    timesChangeEvent[ch.ChristmasModel.diamondWheelChangeEventType] = false
    
    local zhuanpanChangeEvent = {}
    zhuanpanChangeEvent[ZHUANPAN_END_CHANGE_EVENT] = false
    
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    ch.ChristmasModel:setDiamondWheelReward(nil)

    widget:addDataProxy("leftTime",function(evt)
--        local time = math.floor(ch.ChristmasModel:getEndTimeByType(1016) - os_time())
--        if time<0 then
--            return "0"
--        end
--        local second = time%60
--        time = math.floor(time/60)
--        local min = time%60
--        time = math.floor(time/60)
--        local hour = time%24
--        time = math.floor(time/24)
--        return string.format(Language.HOLIDAY_DIAMOND_WHEEL_CDTIME,time,hour,min,second)
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1016)) - os_time()
        return Language.HOLIDAY_DIAMOND_WHEEL_CDTIME..ch.NumberHelper:cdTimeToString(time)
    end)

    local cfg = ch.ChristmasModel:getCSVDataByType(1016)
    local canStart = true

    local speed = 720
    local n = 2       -- 减速要多走的圈数
    local minTime = 0 -- 匀速运动的最小时间

    local lastTime = os_clock()
    local lastRefrashTime = lastTime
    local startWheelTime
    local startReduceTime
    local statue = 0
    local curRotation = 0
    local posRotation
    local totalTime =0
    local a=0 --加速度
    local isWheeling = false
    local panel = widget:getChild("panel_zhuanpan")
    widget:listen(zzy.Events.TickEventType,function(evt)
        local now = os_clock()
        if now - lastRefrashTime > 0.2 then
            widget:noticeDataChange("leftTime")
            lastRefrashTime = now
        end
        if statue > 0 then
            local dt = now - lastTime
            if statue == 1 then
                if ch.ChristmasModel:getDiamondWheelReward() and now - startWheelTime >minTime then
                    statue = 2
                    local id = ch.ChristmasModel:getDiamondWheelId()
                    local minr = 45*(8-id) + 22.5
                    local r = math.random(0,35)
                    posRotation = minr + r + 5
                    if posRotation >= 360 then
                        posRotation = posRotation - 360
                    end
                    local disR = 0
                    if curRotation > posRotation then
                        disR = 360 - curRotation + posRotation
                    else
                        disR = posRotation - curRotation
                    end
                    if disR < 90 then
                        disR = disR + 360
                    end
                    disR = disR + 360 *n
                    a = math.pow(speed,3)/(2*disR*disR)
                    totalTime = math.sqrt(2*speed/a)
                    posRotation = curRotation + disR
                    startReduceTime = os_clock()
                end
            end
            if statue == 1 then
                curRotation = curRotation + speed*dt
            elseif statue == 2 then
                local t = totalTime -os_clock() + startReduceTime
                if t > 0 then
                    local s = 0.25*a*math.pow(t,3)
                    curRotation = posRotation - s
                else
                    statue = 0
                    curRotation = posRotation
                    widget:setTimeOut(0.2,function()
                        widget:noticeDataChange("rewardIcon")
                        widget:noticeDataChange("rewardNum")
                        widget:noticeDataChange("rewardName")
                        widget:noticeDataChange("rewardVisible")
                        canStart = true
--                        widget:noticeDataChange("canStart")
                    end)    
                end
            end
            if curRotation >= 360 then
                curRotation = curRotation %360
            end
            panel:setRotation(curRotation)
        end
        lastTime = now
    end)

    widget:addDataProxy("canStart",function(evt)
        local moneyEnough = ch.MoneyModel:getDiamond() >= ch.ChristmasModel:getDiamondWheelCost()
        local chargeEnough = ch.ChristmasModel:getDiamondWheelCharge() >= ch.ChristmasModel:getDiamondWheelNeed()
        return canStart and moneyEnough and chargeEnough
    end,moneyChangeEvent)
    widget:addDataProxy("isEnd",function(evt)
        return ch.ChristmasModel:getHDataByType(1016)>=GameConst.HOLIDAY_DIAMOND_WHEEL_MAX
    end,timesChangeEvent)
    widget:addDataProxy("noEnd",function(evt)
        return ch.ChristmasModel:getHDataByType(1016)<GameConst.HOLIDAY_DIAMOND_WHEEL_MAX
    end,timesChangeEvent)
    widget:addDataProxy("needMore",function(evt)
        local needMore = ch.ChristmasModel:getDiamondWheelNeed() - ch.ChristmasModel:getDiamondWheelCharge()
        if needMore < 0 then
            needMore = 0
        end
        return needMore
    end,moneyChangeEvent)
    widget:addDataProxy("cost",function(evt)
        return ch.ChristmasModel:getDiamondWheelCost()
    end,zhuanpanChangeEvent)
    widget:addDataProxy("charge",function(evt)
        return ch.ChristmasModel:getDiamondWheelCharge()
    end,moneyChangeEvent)
    widget:addDataProxy("costIcon",function(evt)
        return ch.CommonFunc:getRewardIcon(cfg[1].type,cfg[1].token_id)
    end)
    widget:addDataProxy("hasCount",function(evt)
        return ch.ChristmasModel:getHDataByType(1016)<GameConst.HOLIDAY_DIAMOND_WHEEL_MAX
    end,zhuanpanChangeEvent)
    widget:addDataProxy("count",function(evt)
        return GameConst.HOLIDAY_DIAMOND_WHEEL_MAX - ch.ChristmasModel:getHDataByType(1016)
    end,zhuanpanChangeEvent)

    widget:addDataProxy("image1",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[1].type,cfg[1].token_id)
    end)

    widget:addDataProxy("num1",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[1].type,cfg[1].token_id,ch.ChristmasModel:getDiamondWheelNum(cfg[1]))
    end,zhuanpanChangeEvent)

    widget:addDataProxy("image2",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[2].type,cfg[2].token_id)
    end)

    widget:addDataProxy("num2",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[2].type,cfg[2].token_id,ch.ChristmasModel:getDiamondWheelNum(cfg[2]))
    end,zhuanpanChangeEvent)

    widget:addDataProxy("image3",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[3].type,cfg[3].token_id)
    end)

    widget:addDataProxy("num3",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[3].type,cfg[3].token_id,ch.ChristmasModel:getDiamondWheelNum(cfg[3]))
    end,zhuanpanChangeEvent)

    widget:addDataProxy("image4",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[4].type,cfg[4].token_id)
    end)

    widget:addDataProxy("num4",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[4].type,cfg[4].token_id,ch.ChristmasModel:getDiamondWheelNum(cfg[4]))
    end,zhuanpanChangeEvent)

    widget:addDataProxy("image5",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[5].type,cfg[5].token_id)
    end)

    widget:addDataProxy("num5",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[5].type,cfg[5].token_id,ch.ChristmasModel:getDiamondWheelNum(cfg[5]))
    end,zhuanpanChangeEvent)

    widget:addDataProxy("image6",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[6].type,cfg[6].token_id)
    end)

    widget:addDataProxy("num6",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[6].type,cfg[6].token_id,ch.ChristmasModel:getDiamondWheelNum(cfg[6]))
    end,zhuanpanChangeEvent)

    widget:addDataProxy("image7",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[7].type,cfg[7].token_id)
    end)

    widget:addDataProxy("num7",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[7].type,cfg[7].token_id,ch.ChristmasModel:getDiamondWheelNum(cfg[7]))
    end,zhuanpanChangeEvent)

    widget:addDataProxy("image8",function(evt)
        return ch.CommonFunc:getRewardBigIcon(cfg[8].type,cfg[8].token_id)
    end)

    widget:addDataProxy("num8",function(evt)
        return "X"..ch.CommonFunc:getRewardValue(cfg[8].type,cfg[8].token_id,ch.ChristmasModel:getDiamondWheelNum(cfg[8]))
    end,zhuanpanChangeEvent)

    widget:addDataProxy("rewardIcon",function(evt)
        local reward = ch.ChristmasModel:getDiamondWheelReward()
        if reward then
            return ch.CommonFunc:getRewardBigIcon(reward.t,reward.id) 
        end
        return ""
    end)

    widget:addDataProxy("rewardNum",function(evt)
        local reward = ch.ChristmasModel:getDiamondWheelReward()
        if reward then
            return "X"..ch.CommonFunc:getRewardValue(reward.t,reward.id,reward.num)
        end
        return ""
    end)

    widget:addDataProxy("rewardName",function(evt)
        local reward = ch.ChristmasModel:getDiamondWheelReward()
        if reward then
            return ch.CommonFunc:getRewardName(reward.t,reward.id)
        end
        return ""
    end)

    widget:addDataProxy("rewardVisible",function(evt)
        return ch.ChristmasModel:getDiamondWheelReward() ~= nil
    end)

    widget:addCommond("start",function()
--        if canStart then
--            ch.ChristmasModel:setDiamondWheelReward(nil)
--            widget:noticeDataChange("rewardVisible")
--        end
        if ch.ChristmasModel:getHDataByType(1016) < GameConst.HOLIDAY_DIAMOND_WHEEL_MAX then
            local buy = function()
                canStart = false
                widget:noticeDataChange("canStart")
                ch.NetworkController:startDiamondWheel()
                statue = 1
                startWheelTime = os_clock()
            end
            local tmp = {price = ch.ChristmasModel:getDiamondWheelCost(),buy = buy}
            ch.ShopModel:getCostTips(tmp)
        end
    end)

    widget:addCommond("closeReward",function()
        if canStart then
            ch.ChristmasModel:setDiamondWheelReward(nil)
            widget:noticeDataChange("rewardVisible")
        end
        panel:setRotation(0)
        widget:noticeDataChange("canStart")
        zzy.EventManager:dispatchByType(ZHUANPAN_END_CHANGE_EVENT)
    end)
end)


-- 好运滚滚（老虎机）
zzy.BindManager:addFixedBind("Christmas/W_HYGG", function(widget)
    local hyggChangeEvent = {}
    hyggChangeEvent[ch.ChristmasModel.hyggChangeEventType] = false
    
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    moneyChangeEvent[ch.ChristmasModel.hyggChangeEventType] = false

    widget:addDataProxy("time",function(evt)
--        local str = os.date(Language.src_clickhero_view_ChristmasView_6,tonumber(ch.ChristmasModel:getOpenTimeByType(1019)))
--        str = str .. os.date(Language.src_clickhero_view_ChristmasView_7,tonumber(ch.ChristmasModel:getEndTimeByType(1019)))
--        return str
        local time = tonumber(ch.ChristmasModel:getEndTimeByType(1019)) - os_time()
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("list",function(evt)
        local items = {}
        local tmpData = ch.ChristmasModel:getCSVDataByType(1019)
        if tmpData then
            for k,v in pairs(tmpData) do
                table.insert(items,{type=ch.ChristmasModel:getCurPage(),value=v})
            end
        end
        return items
    end)
    
    widget:addDataProxy("freeCount",function(evt)
        local num = GameConst.HOLIDAY_HYGG_FREE_COUNT-ch.ChristmasModel:getHDataByType(1019).."/"..GameConst.HOLIDAY_HYGG_FREE_COUNT
        return string.format(Language.src_clickhero_view_ChristmasView_14,num)
    end,hyggChangeEvent)
    widget:addDataProxy("costNum",function(evt)
        return ch.ChristmasModel:getHYGGCost()
    end,hyggChangeEvent)
    widget:addDataProxy("ifFree",function(evt)
        return ch.ChristmasModel:getHDataByType(1019) < GameConst.HOLIDAY_HYGG_FREE_COUNT
    end,hyggChangeEvent)
    widget:addDataProxy("noFree",function(evt)
        return ch.ChristmasModel:getHDataByType(1019) >= GameConst.HOLIDAY_HYGG_FREE_COUNT
    end,hyggChangeEvent)
    
    -- 老虎机部分
    local imageLayer = {}
    imageLayer[1] = widget:getChild("Panel_1")
    imageLayer[2] = widget:getChild("Panel_2")
    imageLayer[3] = widget:getChild("Panel_3")
    local imgTable = {}
    for k=1,3 do
        imgTable[k] = {}
        for i=1,4 do
            imgTable[k][i] = ccui.ImageView:create()
            imgTable[k][i]:loadTexture(GameConst.HOLIDAY_HYGG_IMAGE[i],ccui.TextureResType.plistType)
            imgTable[k][i]:setAnchorPoint(cc.p(0.5,0.5))
            imageLayer[k]:addChild(imgTable[k][i])
            local size = imgTable[k][i]:getContentSize()
            imgTable[k][i]:setPosition(0,(3-i)*(size.height+20))
        end
    end
    
    local addHeight = imgTable[1][1]:getContentSize().height + 20
    local panelTop = widget:getChild("Panel_4")
    local panelTopY = panelTop:getPositionY()-panelTop:getContentSize().height-addHeight-20
    local panelTopCur = panelTop:getPositionY()-panelTop:getContentSize().height/2-addHeight/2
    local speed = {2400,2400,2400}
    local slowN = {500,550,500}       -- 减速要多走的路程
    local isWheeling = {false,false,false}

    local curState = false
    local minTime = 2 -- 匀速运动的最小时间
    
    local tmpStr = nil
    local tmpTable = nil
    local randNum = nil
    
    local lastTime = os_clock()
    local lastRefrashTime = lastTime
    local lastTimeChange = lastTime
    local startReduceTime = 0
    local curPosition = {0,0,0}
    local posPosition = {0,0,0}
    local totalTime = 2
    local a= {40,40,40} --加速度
    local minTime2 = {1,2,3} -- 匀速运动的最小时间
    local statue = 0
    
    widget:listen(zzy.Events.TickEventType,function(evt)
        local now = os_clock()
        if now - lastTimeChange > 0.2 then
            widget:noticeDataChange("time")
            lastTimeChange = now
        end
        if curState then
            local dt = now - lastTime
            local stopNum = 0
            
            for k=1,3 do
                local s = 0
                if statue == 1 then
                    s = speed[k]*dt
                    curPosition[k] = imageLayer[k]:getPositionY() - s
                elseif statue == 2 then
                    local t = totalTime -os_clock() + startReduceTime
                    if t > 0 then
                        s = a[k]*t > slowN[k]*dt and a[k]*t or slowN[k]*dt
                        curPosition[k] = imageLayer[k]:getPositionY()- s
                    else
                        statue = 3
                        lastRefrashTime = now
                    end
                elseif statue == 3 then
                    s = slowN[k]*dt
                    curPosition[k] = imageLayer[k]:getPositionY() - s
                end
                local maxPoint = panelTopCur + speed[k]
                local minPoint = panelTopCur
                local tmppoint = {imageLayer[k]:getPositionX(), imageLayer[k]:getPositionY()}
                local tmppointWorld = imageLayer[k]:convertToWorldSpace(tmppoint)
                local tmp = nil
                if ch.ChristmasModel:getHYGGId() and tmpTable then
                    tmp = tonumber(string.sub(tmpTable[randNum],k,k))
                end
                for i = 1,4 do
                    local tmppointBtn = {imgTable[k][i]:getPositionX(), imgTable[k][i]:getPositionY()}
                    local tmppointBtnWorld = imgTable[k][i]:convertToWorldSpace(tmppointBtn)
                    if statue == 1 and lastRefrashTime + minTime < now then
                        if ch.ChristmasModel:getHYGGId() then
                            tmpStr = ch.ChristmasModel:getCSVDataByType(1019)[ch.ChristmasModel:getHYGGId()].combination
                            tmpTable = zzy.StringUtils:split(tmpStr,"|")
                            randNum = math.random(1,table.maxn(tmpTable))
                            statue = 2
                            startReduceTime = os_clock()
                        end
                    end
                    if statue == 3 and lastRefrashTime + minTime2[k] < now then
                        if i == tmp and tmppointBtnWorld.y >= panelTopCur and tmppointBtnWorld.y - s <= panelTopCur then
                            stopNum = stopNum + 1
                            isWheeling[k] = false
                            posPosition[k] = imageLayer[k]:getPositionY()-(tmppointBtnWorld.y-panelTopCur)
                        end
                    end
                    if tmppointBtnWorld.y < panelTopY then
                        imgTable[k][i]:setPositionY(imgTable[k][i]:getPositionY()+4*addHeight)
                    end
                end
                if isWheeling[k] then 
                    imageLayer[k]:setPositionY(curPosition[k])
                else
                    imageLayer[k]:setPositionY(posPosition[k])
                end
            end
            if stopNum == 3 then
                cclog(tmpTable[randNum])
                curState = false
                statue = 0
                -- 结束转动展示奖励
                local items = ch.ChristmasModel:getHYGGReward()
                if ch.ChristmasModel:getCSVDataByType(1019)[ch.ChristmasModel:getHYGGId()].tag_notice == 2 then
                    local tmpData = {}
                    tmpData.title = Language.src_clickhero_controller_NetworkController_4
                    tmpData.desc = Language.src_clickhero_controller_NetworkController_5
                    tmpData.list = {items}
                    ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
                else
                    local tmpStr = string.format("%sX %s",ch.CommonFunc:getRewardName(items.t,items.id),ch.CommonFunc:getRewardValue(items.t,items.id,items.num))
                    ch.UIManager:showUpTips(tmpStr)
                end
                ch.ChristmasModel:setHYGGId(nil)
                ch.ChristmasModel:setHYGGReward(nil)
                widget:noticeDataChange("ifCanStart")
                widget:noticeDataChange("ifCanBuy")
            end
            lastTime = now
        end
    end)
    
    widget:addDataProxy("ifCanStart",function(evt)
        return not curState
    end,hyggChangeEvent)
    widget:addDataProxy("ifCanBuy",function(evt)
        return not curState and ch.MoneyModel:getDiamond() >= ch.ChristmasModel:getHYGGCost()
    end,moneyChangeEvent)
    
    widget:addCommond("start",function()
        local buy = function()
            ch.NetworkController:startHYGG()

            isWheeling = {true,true,true}
            curState = true
            lastTime = os_clock()
            lastRefrashTime = lastTime
            statue = 1
            widget:noticeDataChange("ifCanStart")
            widget:noticeDataChange("ifCanBuy")
        end
        local tmp = {price = ch.ChristmasModel:getHYGGCost(),buy = buy}
        ch.ShopModel:getCostTips(tmp)
    end)
end)


-- 好运滚滚（老虎机）奖励项单元
zzy.BindManager:addCustomDataBind("Christmas/W_HYGG_1", function(widget,data)
    widget:addDataProxy("name",function(evt)
        return string.format("：%s X%s",ch.CommonFunc:getRewardName(data.value.type,data.value.award_id),ch.CommonFunc:getRewardValue(data.value.type,data.value.award_id,data.value.num))
    end)
    widget:addDataProxy("rewardName",function(evt)
        if data.value.display == "0" then
            return Language.src_clickhero_view_ChristmasView_15
        else
            return ""
        end
    end)
    widget:addDataProxy("image1",function(evt)
        local strTable = tonumber(string.sub(data.value.display,1,1))
        if strTable and strTable ~= 0 then
            return GameConst.HOLIDAY_HYGG_IMAGE[strTable]
        else
            return GameConst.HOLIDAY_HYGG_IMAGE[5]
        end
    end)
    widget:addDataProxy("image2",function(evt)
        local strTable = tonumber(string.sub(data.value.display,2,2))
        if strTable then
            return GameConst.HOLIDAY_HYGG_IMAGE[strTable]
        else
            return GameConst.HOLIDAY_HYGG_IMAGE[5]
        end
    end)
    widget:addDataProxy("image3",function(evt)
        local strTable = tonumber(string.sub(data.value.display,3,3))
        if strTable then
            return GameConst.HOLIDAY_HYGG_IMAGE[strTable]
        else
            return GameConst.HOLIDAY_HYGG_IMAGE[5]
        end
    end)
end)
