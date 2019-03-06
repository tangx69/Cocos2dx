-- 固有绑定
-- 成就打开界面
zzy.BindManager:addFixedBind("achievement/W_Achievelist", function(widget)
    --
    widget:addDataProxy("visGamecenter",function(evt)
        if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" and (cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD ) then
			 return true
		else
			return false
	    end
    end)
	 widget:addDataProxy("visPlaygames",function(evt)
        if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" and cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
			return true
		else
			return false
	    end
    end)
    
    -- 点击gamecenter按钮
    widget:addCommond("btn_gamecenter",function()
         local info={
            f="openrank",
            data={t=2 }
        }
        zzy.Sdk.extendFunc(json.encode(info))
        cclog(json.encode(info))
    end)
    
    -- 点击playgames按钮
    widget:addCommond("btn_playgames",function()
        local info={
            f="openrank",
            data={t=2 }
        }
        zzy.Sdk.extendFunc(json.encode(info))
        cclog(json.encode(info))
    end)


    local achievementChangeEvent = {}
    achievementChangeEvent[ch.AchievementModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.AchievementModel.dataType.state
    end
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_AchievementView_1
    end)
    -- 已获得的成就数量
    widget:addDataProxy("ownAchievement",function(evt)
--        cclog("总攻击力加成："..ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_ATTACK))
--        cclog("基础攻击："..ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_BASE))
        return ch.AchievementModel:getOwnAchievementNum()
    end,achievementChangeEvent)
    -- 成就总数
    widget:addDataProxy("allAchievement",function(evt)
        return ch.AchievementModel:getAllAchievementNum()
    end)
    -- 已经获得的钻石奖励
    widget:addDataProxy("diamondNum",function(evt)
        return ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_DIAMOND)
    end,achievementChangeEvent)
    -- 已经获得的总攻击奖励
    widget:addDataProxy("attackNumDes",function(evt)
        return string.format(Language.src_clickhero_view_AchievementView_2,(ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_ATTACK)-1)*100)
    end,achievementChangeEvent)
    -- 已经获得的基础攻击奖励
    widget:addDataProxy("baseNum",function(evt)
        return ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_BASE)
    end,achievementChangeEvent)
    -- 成就列表
    widget:addDataProxy("achievementList",function(evt)
        return ch.AchievementModel:getAchievementList()
    end)
end)

-- 自定义数据绑定
-- 成就Item
zzy.BindManager:addCustomDataBind("achievement/W_AchieveUnit",function(widget,data)
    local achievementChangeEvent = {}
    achievementChangeEvent[ch.AchievementModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.AchievementModel.dataType.state
    end
    local achievementValueChangeEvent = {}
    achievementValueChangeEvent[ch.AchievementModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.AchievementModel.dataType.value
    end

    -- 成就图标
    widget:addDataProxy("achievementIcon",function(evt)
        return ch.AchievementModel:getIcon(data)
    end,achievementChangeEvent)
    -- 成就类名字
    widget:addDataProxy("achievementName",function(evt)
        return ch.AchievementModel:getName(data)
    end,achievementChangeEvent)
    -- 成就描述(例如拥有%s金币)
    widget:addDataProxy("achievementDes",function(evt)   
        return ch.AchievementModel:getDes(data)
    end,achievementChangeEvent)
    -- 已获得此类成就的数量
    widget:addDataProxy("ownAchievement",function(evt)
        return ch.AchievementModel:getOwnTypeNum(data)
    end,achievementChangeEvent)
    -- 此类成就的总数
    widget:addDataProxy("allAchievement",function(evt)
        return ch.AchievementModel:getAllTypeNum(data)
    end,achievementChangeEvent)
    -- 此成就从未获得过
    widget:addDataProxy("ifNoGetOne",function(evt)
        return not ch.AchievementModel:getCanReceive(data)
    end,achievementChangeEvent)
    -- 此类成就是否已经达成至少1个(可领奖)
    widget:addDataProxy("ifGetOne",function(evt)
        return ch.AchievementModel:getCanReceive(data)
    end,achievementChangeEvent)
    -- 是否已经领取完所有奖励(已领奖)
    widget:addDataProxy("ifNoAllGet",function(evt)
        return not ch.AchievementModel:getOverReceive(data)
    end,achievementChangeEvent)
    -- 是否已经领取完所有奖励(已领奖)
    widget:addDataProxy("ifAllGet",function(evt)
        return ch.AchievementModel:getOverReceive(data)
    end,achievementChangeEvent)
    -- 当前获得的目标数量(进度)
    widget:addDataProxy("curNum",function(evt)
        if data == "13" then
            if ch.AchievementModel:getCurNoReceive(data) then
                return 1
            else
                return 0
            end
        else
            return ch.NumberHelper:toString(ch.AchievementModel:getCurNum(data))
        end
    end,achievementChangeEvent)
    -- 获得成就的目标总数(进度)
    widget:addDataProxy("goalNum",function(evt)
        if data == "13" then
            return 1
        else
            return ch.NumberHelper:toString(ch.AchievementModel:getGoalNum(data))
        end
    end,achievementChangeEvent)
    -- 进度
    widget:addDataProxy("progress",function(evt)
        if data == "13" then
            if ch.AchievementModel:getCurNoReceive(data) then
                return 100
            else
                return 0
            end
        else
            return ch.AchievementModel:getProgress(data)*100
        end
    end,achievementChangeEvent)
    -- 是否显示钻石奖励
    widget:addDataProxy("ifDiamond",function(evt)
        return ch.AchievementModel:getRewardType(data) == GameConst.ACHIEVEMENT_REWARD_DIAMOND
    end,achievementChangeEvent)
    -- 是否显示加总攻击奖励
    widget:addDataProxy("ifAttack",function(evt)
        return ch.AchievementModel:getRewardType(data) == GameConst.ACHIEVEMENT_REWARD_ATTACK
    end,achievementChangeEvent)
    -- 是否显示加基础攻击奖励
    widget:addDataProxy("ifBase",function(evt)
        return ch.AchievementModel:getRewardType(data) == GameConst.ACHIEVEMENT_REWARD_BASE
    end,achievementChangeEvent)
    -- 完成当前成就可获得的奖励
    widget:addDataProxy("rewardNum",function(evt)
        return ch.AchievementModel:getRewardText(data)
    end,achievementChangeEvent)
    -- 是否已经领取奖励
    widget:addDataProxy("ifCurNoGet",function(evt)
        return ch.AchievementModel:getCurNoReceive(data)
    end,achievementChangeEvent)
    -- 领取奖励
    widget:addCommond("receiveReward",function()
		if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID and string.sub(zzy.Sdk.getFlag(),1,2)=="WY"  then
			if GameConst.ACHIEVEMENT_GAMES["WY"]["ae"..ch.AchievementModel:getID(data)] and  ch.AchievementModel:getCurNoReceive(data)  then
				local info={
					f="achievements",
					data={
							achieveid_google=GameConst.ACHIEVEMENT_GAMES["WY"]["ae"..ch.AchievementModel:getID(data)].google
						 }
				}
				zzy.Sdk.extendFunc(json.encode(info))
				cclog(json.encode(info))
			end
		end
			if  string.sub(zzy.Sdk.getFlag(),1,2)=="CY"  then
				if GameConst.ACHIEVEMENT_GAMES["CY"]["ae"..ch.AchievementModel:getID(data)] and  ch.AchievementModel:getCurNoReceive(data)  then
					local	info={
						f="achievements",
						data={
							achieveid_google=GameConst.ACHIEVEMENT_GAMES["CY"]["ae"..ch.AchievementModel:getID(data)].google,
							achieveid_appstore=GameConst.ACHIEVEMENT_GAMES["CY"]["ae"..ch.AchievementModel:getID(data)].appstore
						}
					}
					zzy.Sdk.extendFunc(json.encode(info))
					cclog(json.encode(info))
				end
			end
		ch.NetworkController:getAchievementReward(data,ch.AchievementModel:getID(data))
        widget:playEffect("getAchieveEffect",false)
    end)
    
    if data == "1" or data == "2" then
        widget:listen(ch.MoneyModel.dataChangeEventType,function(obj,evt)
            if evt.dataType == ch.MoneyModel.dataType.gold then
                widget:noticeDataChange("curNum")
                widget:noticeDataChange("progress")
                widget:noticeDataChange("ifCurNoGet")
            end
        end)
    elseif data == "3" or data == "4" then
        widget:listen(ch.LevelModel.dataChangeEventType,function(obj,evt)
            if evt.dataType == ch.LevelModel.dataType.curLevel then
                widget:noticeDataChange("curNum")
                widget:noticeDataChange("progress")
                widget:noticeDataChange("ifCurNoGet")
            end
        end)
    elseif data == "10" then
        widget:listen(ch.fightRole.DEAD_EVENT_TYPE,function(obj,evt)
            if evt.roleType == ch.fightRole.roleType.monster then
                widget:noticeDataChange("curNum")
                widget:noticeDataChange("progress")
                widget:noticeDataChange("ifCurNoGet")
            end
        end)
    elseif data == "5" then
        widget:listen(ch.fightRole.DEAD_EVENT_TYPE,function(obj,evt)
            if evt.roleType == ch.fightRole.roleType.boss then
                widget:noticeDataChange("curNum")
                widget:noticeDataChange("progress")
                widget:noticeDataChange("ifCurNoGet")
            end
        end)
    elseif data == "11" then
        widget:listen(ch.fightRole.DEAD_EVENT_TYPE,function(obj,evt)
            if evt.roleType == ch.fightRole.roleType.chest then
                widget:noticeDataChange("curNum")
                widget:noticeDataChange("progress")
                widget:noticeDataChange("ifCurNoGet")
            end
        end)
    end
end)