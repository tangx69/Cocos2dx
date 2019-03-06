zzy.BindManager:addFixedBind("statistics/W_Statislist",function(widget)
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_StatisticsView_1
    end)
    widget:addDataProxy("items",function(evt)
        return ch.StatisticsModel:getOrderData()
    end)
end)

local getDataByid = nil

zzy.BindManager:addCustomDataBind("statistics/W_StatisItem",function(widget,data)
--    local iconImage = widget:getChild("img_icon")   -- 被逼的
--    iconImage:setPositionPercent(cc.p(1,0))
--    iconImage:setPositionType(ccui.PositionType.percent)
--    local desc = widget:getChild("Text_des")
--    desc:setPositionPercent(cc.p(1,0))
--    desc:setPositionType(ccui.PositionType.percent)
    
    local config = GameConfig.StatisticsConfig:getData(data)
    widget:addDataProxy("title",function(evt)
        return config.name .. ": "
    end)
    widget:addDataProxy("icon",function(evt)
        return config.icon
    end)
    widget:addDataProxy("number",function(evt)
        return getDataByid(data)
    end)
    if data == "4" or data == "17" or data == "18" then
        local id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            widget:noticeDataChange("number")
        end,1,false)
        local close = widget.destory
        widget.destory = function(cleanView,func)
        	close(widget,cleanView,func)
        	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(id)
        end
    elseif data == "3" then
        widget:listen(ch.MoneyModel.dataChangeEventType,function(obj,evt)
            if evt.dataType == ch.MoneyModel.dataType.gold then
                widget:noticeDataChange("number")
            end
        end)
    elseif data == "10" then
        widget:listen(ch.MoneyModel.dataChangeEventType,function(obj,evt)
            if evt.dataType == ch.MoneyModel.dataType.gold then
                widget:noticeDataChange("number")
            end
        end)
    elseif data == "22" then
        widget:listen(ch.MoneyModel.dataChangeEventType,function(obj,evt)
            if evt.dataType == ch.MoneyModel.dataType.sStone then
                widget:noticeDataChange("number")
            end
        end)
    elseif data == "7" then
        widget:listen(ch.fightRole.DEAD_EVENT_TYPE,function(obj,evt)
            if evt.roleType == ch.fightRole.roleType.monster then
                widget:noticeDataChange("number")
            end
        end)
    elseif data == "8" then
        widget:listen(ch.fightRole.DEAD_EVENT_TYPE,function(obj,evt)
            if evt.roleType == ch.fightRole.roleType.boss then
                widget:noticeDataChange("number")
            end
        end)
    elseif data == "9" then
        widget:listen(ch.fightRole.DEAD_EVENT_TYPE,function(obj,evt)
            if evt.roleType == ch.fightRole.roleType.chest then
                widget:noticeDataChange("number")
            end
        end)
    elseif data == "12" then
        widget:listen(ch.LevelModel.dataChangeEventType,function(obj,evt)
            if evt.dataType == ch.LevelModel.dataType.curLevel then
                widget:noticeDataChange("number")
            end
        end)
    elseif data == "24" then
        widget:listen(ch.StatisticsModel.dataChangeEventType,function(obj,evt)
            if evt.dataType == ch.StatisticsModel.dataType.rank then
                widget:noticeDataChange("number")
            end
        end)
    end
end)

local timeToString = function(time)
    local second = math.floor(time % 60)
    time = math.floor(time / 60)
    local minute = math.floor(time % 60)
    time = math.floor(time / 60)
    local hour = math.floor(time % 24)
    local day = math.floor(time / 24)
    local formatStr = nil
    if day > 0 then
        formatStr = Language.src_clickhero_view_StatisticsView_2
        return string.format(formatStr,day,hour,minute,second)
    elseif hour > 0 then
        formatStr = Language.src_clickhero_view_StatisticsView_3
        return string.format(formatStr,hour,minute,second)
    elseif minute > 0 then
        formatStr = Language.src_clickhero_view_StatisticsView_4
        return string.format(formatStr,minute,second)
    else
        formatStr = Language.src_clickhero_view_StatisticsView_5
        return string.format(formatStr,second)
    end
end


getDataByid = function(id)
	if id == "1" then
        return ch.NumberHelper:toString(ch.LongDouble:floor(ch.MagicModel:getTotalDPS()))
	elseif id == "2" then
        return ch.NumberHelper:toString(ch.LongDouble:floor(ch.RunicModel:getDPS()))
	elseif id == "3" then
	   return ch.NumberHelper:toString(ch.MoneyModel:getGold())
    elseif id == "4" then
       return ch.NumberHelper:toString(ch.StatisticsModel:getRecentGotGold())
    elseif id == "5" then
       return ch.NumberHelper:toString(ch.StatisticsModel:getRunicTimes())
    elseif id == "6" then
       return ch.StatisticsModel:getMaxSeriesTimes()
    elseif id == "7" then
       return ch.NumberHelper:toString(ch.StatisticsModel:getKilledMonsters())
    elseif id == "8" then
       return ch.NumberHelper:toString(ch.StatisticsModel:getKilledBosses())
    elseif id == "9" then
       return ch.NumberHelper:toString(ch.StatisticsModel:getKilledBoxes())
    elseif id == "10" then
       return ch.NumberHelper:toString(ch.StatisticsModel:getGotGold())
    elseif id == "11" then
       return ch.MagicModel:getTotalLevel()
    elseif id == "12" then
       return ch.StatisticsModel:getMaxLevel()
    elseif id == "13" then
        local num = ch.RunicModel:getCritRate()
--        if num == 0 then
--            return 0
--        else
            return string.format("%g%%",num*100)
--        end
    elseif id == "14" then
       return ch.RunicModel:getCritTimes()
    elseif id == "15" then
        return ch.StatisticsModel:getRunicCritTimes()
    elseif id == "16" then
       return ch.StatisticsModel:getRTimes()
    elseif id == "17" then
       return timeToString(ch.StatisticsModel:getPlayTime())
    elseif id == "18" then
       return timeToString(ch.StatisticsModel:getRTime())
    elseif id == "19" then
       return ch.NumberHelper:toString(ch.MoneyModel:getSoul())
    elseif id == "20" then
        return ch.NumberHelper:multiple(ch.StatisticsModel:getSoulRatio(1)*100,1000)
    elseif id == "21" then
        return ch.NumberHelper:multiple(ch.StatisticsModel:getSoulRatio(1)*100,1000)
    elseif id == "22" then
       return ch.NumberHelper:toString(ch.MoneyModel:getsStone())
    elseif id == "23" then
        return math.floor((ch.RunicModel:getLevel()+ch.MagicModel:getTotalLevel())/GameConst.SOUL_LEVEL)
    elseif id == "24" then
        return ch.StatisticsModel:getMaxRank()
	end
end
