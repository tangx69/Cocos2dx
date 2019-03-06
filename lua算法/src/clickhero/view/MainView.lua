zzy.BindManager:addFixedBind("MainScreen/S_MainScene", function(widget)
    if IS_IN_REVIEW  and (not USE_SPINE) then
        local db_manu_l = zzy.CocosExtra.seekNodeByName(widget, "db_manu_l")
        db_manu_l:loadTexture("res/iosReview/aaui_diban_db_navi.png")

        local db_top = zzy.CocosExtra.seekNodeByName(widget, "db_top")
        db_top:loadTexture("res/iosReview/aaui_diban_db_topbar2.png")
    end
    
    local goldChangeEvent = {}
    goldChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.gold
    end
    local diamondChangeEvent = {}
    diamondChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    local soulChangeEvent = {}
    soulChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.soul
    end
    local runicOpenEvent = {}
    runicOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
    	return evt.view == "fuwen/W_FuwenList"
    end
    runicOpenEvent[ch.PartnerModel.czChangeEventType] = function(evt)
        return evt.dataType == ch.PartnerModel.dataType.fight 
    end

    local magicOpenEvent = {}
    magicOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
        return evt.view == "baowu/W_BaowuList"
    end
    magicOpenEvent[ch.PlayerModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.PlayerModel.dataType.gender 
    end
    local tuTengOpenEvent = {}
    tuTengOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
        --return evt.view == "tuteng/W_TutengList" or evt.view == "tuteng/W_TutengXuanze"
        return evt.view == "tuteng/W_TutengList"
    end
    local cardOpenEvent = {}
    cardOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
        return evt.view == "card/W_card_list"
    end
    local friendOpenEvent = {}
    friendOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
--        return evt.view == "Guild/W_GuildList"
        return evt.view == "Guild/W_NewGuild_my" or evt.view == "Guild/W_NewGuild_cover"
    end
    local shopOpenEvent = {}
    shopOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
        return evt.view == "Shop/W_shop"
    end
    widget:addDataProxy("gold-num", function(evt)
        return ch.MoneyModel:getGold()
    end,goldChangeEvent)
    widget:addScrollData("gold-num", "gold", 1, function(v)
        return ch.NumberHelper:toString(v)
    end,"nodeMGold:num_Gold")
    widget:addDataProxy("diamond-num", function(evt)
        return ch.MoneyModel:getDiamond()
    end,diamondChangeEvent)
    widget:addScrollData("diamond-num", "diamond", 1, function(v)
        return ch.NumberHelper:toString(v)
    end,"nodeMDiamond:num_Diamond")
    widget:addDataProxy("soul", function(evt)
        return ch.NumberHelper:toString(ch.MoneyModel:getSoul())
    end,soulChangeEvent)
    local getIcon = function(evt,index)
        if not evt or evt.popType == ch.UIManager.popType.Close then
            if index == 1 then
                return GameConst.MAINVIEW_PET_BUTTON_ICON[ch.PartnerModel:getCurPartner()][1]
            elseif index == 2 and ch.PlayerModel:getPlayerGender() == 2 then
                return "aaui_button/menu_02_0_1.png"
            else
                return GameConst.MAINVIEW_BOTTOM_BUTTON_ICON[index][1]
            end
        end
        if index == 1 then
            return GameConst.MAINVIEW_PET_BUTTON_ICON[ch.PartnerModel:getCurPartner()][2]
        elseif index == 2 and ch.PlayerModel:getPlayerGender() == 2 then
            return "aaui_button/menu_02_0_2.png"
        else
            return GameConst.MAINVIEW_BOTTOM_BUTTON_ICON[index][2]
        end
    end
    widget:addDataProxy("canRunicOpen", function(evt)
        if not USE_SPINE then
            return getIcon(evt,1)
        end
    end,runicOpenEvent)
--    widget:listen(ch.PartnerModel.czChangeEventType,function(obj,evt)
--        if evt.dataType == ch.PartnerModel.dataType.fight then
--            widget:noticeDataChange("canRunicOpen")
--        end
--    end)
    widget:addDataProxy("canMagicOpen", function(evt)
        if not USE_SPINE then
            return getIcon(evt,2)
        end
    end,magicOpenEvent)
--    local count = 0
--    local openCount = 0
    widget:addDataProxy("canTutengOpen", function(evt)
--        if evt then        
--            if evt.popType == ch.UIManager.popType.Close then
--                count = count - 1
--                if evt.view == "tuteng/W_TutengList" then
--                    openCount = 0
--                end
--            else
--                if evt.view == "tuteng/W_TutengList" then
--                    if evt.popType == ch.UIManager.popType.HalfOpen then
--                        count = count + 1 - openCount
--                        openCount = 0
--                    elseif evt.popType == ch.UIManager.popType.Open then
--                        openCount = openCount + 1  
--                    end
--                else
--                    if evt.popType == ch.UIManager.popType.Open then
--                        count = count + 1
--                    end
--                end 
--            end
--            cclog(count)
--            return count == 0
--        end    
--        return true
        return getIcon(evt,3)
    end,tuTengOpenEvent)
    widget:addDataProxy("canCardOpen", function(evt)
        return getIcon(evt,4)
    end,cardOpenEvent)
    widget:addDataProxy("canFriendOpen", function(evt)
        return getIcon(evt,5)
    end,friendOpenEvent)
    widget:addDataProxy("canShopOpen", function(evt)
        return getIcon(evt,6)
    end,shopOpenEvent)

    local petCardChangeEvent = {}
    petCardChangeEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.PetCardModel.dataType.chip or evt.dataType == ch.PetCardModel.dataType.level
    end
    widget:addDataProxy("ifCanCardUp",function(evt)
        if ch.PetCardModel:ifEnoughPlayEffect() then
            widget:playEffect("cardNew",true)
        else
            widget:stopEffect("cardNew")
        end
        return false
    end,petCardChangeEvent)
    
    local magicId = ch.MagicModel:getNewMagicId()
    local upCost = 0
    if magicId then
        upCost = ch.MagicModel:getLevelUpCost(magicId,1)
    end
    
    -- 开始的判断
    widget:addDataProxy("ifPlayEffect",function(evt)
        if magicId and ch.MoneyModel:getGold() >= upCost then
            widget:playEffect("tagBWNew",true)
        else
            widget:stopEffect("tagBWNew")
        end
--        if ch.TaskModel:getTaskNum(2) > 0 then
--            widget:playEffect("tagTaskNew",true)
--        else
--            widget:stopEffect("tagTaskNew")
--        end
        if ch.AchievementModel:getCurNoReceiveNum() > 0 then
            widget:playEffect("tagAchievementNew",true)
        else
            widget:stopEffect("tagAchievementNew")
        end
        return true
    end)
    -- 宝物可购买
    widget:listen(ch.MoneyModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.MoneyModel.dataType.gold then
            if magicId and ch.MoneyModel:getGold() >= upCost then
                widget:playEffect("tagBWNew",true)
            else
                widget:stopEffect("tagBWNew")
            end
        end
    end)
    widget:listen(ch.MagicModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.MagicModel.dataType.level then
            local id = ch.MagicModel:getNewMagicId()
            if id ~= magicId then
                magicId = id
                if magicId then
                    upCost = ch.MagicModel:getLevelUpCost(magicId,1)
                else
                    upCost = 0    
                end
                if magicId and ch.MoneyModel:getGold() >= upCost then
                    widget:playEffect("tagBWNew",true)
                else
                    widget:stopEffect("tagBWNew")
                end
            end
        end
    end)
    
    widget:listen(ch.TotemModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.TotemModel.dataType.level then
            if evt.id == "3" then
                if magicId then
                    upCost = ch.MagicModel:getLevelUpCost(magicId,1)
                end
                if magicId and ch.MoneyModel:getGold() >= upCost then
                    widget:playEffect("tagBWNew",true)
                else
                    widget:stopEffect("tagBWNew")
                end
            end
        end
    end)
    widget:listen(ch.PartnerModel.czChangeEventType,function(obj,evt)
        if evt.dataType == ch.PartnerModel.dataType.get then
            local partner = GameConfig.PartnerConfig:getData(evt.value)
            if partner and partner.up_type == 2 then
                if magicId then
                    upCost = ch.MagicModel:getLevelUpCost(magicId,1)
                end
                if magicId and ch.MoneyModel:getGold() >= upCost then
                    widget:playEffect("tagBWNew",true)
                else
                    widget:stopEffect("tagBWNew")
                end
            end
        end
    end)
    
    -- 获得魂石（播放特效）
    widget:listen(ch.MoneyModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.MoneyModel.dataType.sStone and evt.value > 0 then
            widget:playEffect("getHunShi",false)
        end
    end)
    
    -- 获得卡牌及碎片（播放特效）
    widget:listen(ch.PetCardModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.PetCardModel.dataType.drop then
            widget:playEffect("getCard",false)
        end
    end)
    
    -- 获得新宠物
    widget:listen(ch.PartnerModel.czChangeEventType,function(obj,evt)
        if evt.dataType == ch.PartnerModel.dataType.get then
            if not ch.UIManager:getBottomWidget("fuwen/W_FuwenList") then
                widget:playEffect("tagCWNew",true)
            else
                widget:stopEffect("tagCWNew")
            end
        end
    end)
    
    widget:listen(ch.UIManager.viewPopEventType,function(obj,evt)
        if evt and evt.view == "fuwen/W_FuwenList" then
            widget:stopEffect("tagCWNew")
        end
    end)
    
    -- 任务领取光效
--    widget:listen(ch.TaskModel.dataChangeEventType,function(obj,evt)
--        if evt.dataType == ch.TaskModel.dataType.get then
--            widget:playEffect("taskGetEffect",false) 
--        end
--    end)
    
    -- 任务的可领奖和未完成
--    widget:addDataProxy("ifUndone", function(evt)
--    	return ch.TaskModel:getTaskNum(2) <= 0 and ch.TaskModel:getTaskNum(1)+ch.TaskModel:getTaskNum(2) > 0
--    end)
--    widget:addDataProxy("undoneTaskNum",function(evt)
--        return ch.TaskModel:getTaskNum(1)+ch.TaskModel:getTaskNum(2)
--    end)
    
--    widget:listen(ch.TaskModel.dataChangeEventType,function(obj,evt)
--        if evt.dataType == ch.TaskModel.dataType.state then
--            widget:noticeDataChange("ifUndone")
--            widget:noticeDataChange("undoneTaskNum")
--            if ch.TaskModel:getTaskNum(2) > 0 then
--                widget:playEffect("tagTaskNew",true)
--            else
--                widget:stopEffect("tagTaskNew")
--            end
--        end
--    end)
    
    --公会有新成员加入
--    widget:listen(ch.GuildModel.dataChangeEventType,function(obj,evt)
--        if evt.dataType == ch.GuildModel.dataType.new or evt.dataType == ch.GuildModel.dataType.panel then
--            if ch.GuildModel:ifHaveNew() then
--                widget:playEffect("tagGuildNew",true)
--            else
--                widget:stopEffect("tagGuildNew")
--            end
--        end
--    end)
    if ch.StatisticsModel:getMaxLevel() <= GameConst.GUILD_OPEN_LEVEL then
        widget:listen(ch.LevelModel.dataChangeEventType,function(obj,evt)
            if evt.dataType == ch.LevelModel.dataType.curLevel then
                if ch.StatisticsModel:getMaxLevel()-1==GameConst.GUILD_OPEN_LEVEL then
                    widget:playEffect("tagGuildNew",true)
                    ch.NetworkController:guildPanel()
                end
            end
        end)
    end
    
    -- 成就可领奖
    widget:listen(ch.AchievementModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.AchievementModel.dataType.state then
            if ch.AchievementModel:getCurNoReceiveNum() > 0 then
                widget:playEffect("tagAchievementNew",true)
            else
                widget:stopEffect("tagAchievementNew")
            end
        end
    end)
    
     
--    widget:addCommond("openTuteng",function(widget,arg)
--        ch.UIManager:cleanGamePopupLayer()
----        if ch.TotemModel:getOwnTotemNum() > 0 then
--            ch.UIManager:showBottomPopup("tuteng/W_TutengList")
----        else
----            ch.UIManager:showBottomPopup("tuteng/W_TutengXuanze")
----        end
--        ch.SoundManager:play("click")
--    end)
--    widget:addCommond("openAchievement",function(widget,arg)
--        ch.UIManager:cleanGamePopupLayer(true)
--        ch.UIManager:showGamePopup("achievement/W_Taps_achieve")
--        ch.SoundManager:play("click")
--    end)

--    widget:addCommond("openTask",function(widget,arg)
--        ch.UIManager:showBottomPopup("task/W_TaskList")
--        -- 若没有任务则请求刷新
--        if ch.TaskModel:isTodayRefresh() then
--            ch.NetworkController:taskRefresh()
--            ch.UIManager:showGamePopup("task/W_Taskrefrash")
--        elseif ch.StatisticsModel:getMaxLevel()>GameConst.TASK_OPEN_LEVEL and ch.TaskModel:getTodaySign() == 0 and (ch.TaskModel:getTaskNum(1)+ch.TaskModel:getTaskNum(2))>=5 then 
--            ch.NetworkController:taskRefresh()
--        end
--        ch.SoundManager:play("click")
--    end)
    
    widget:addCommond("openCard",function(widget,arg)
        ch.UIManager:showBottomPopup("card/W_card_list")
        ch.SoundManager:play("click")
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10170 then
            ch.guide:endid(10170)
        end
    end)
    
    widget:addCommond("openGuild",function(widget,arg)
        if ch.StatisticsModel:getMaxLevel() > GameConst.GUILD_OPEN_LEVEL then
            ch.NetworkController:guildPanel()
        else
            ch.UIManager:showBottomPopup("Guild/W_NewGuild_cover")
        end
--        ch.UIManager:showBottomPopup("Guild/W_GuildList")
        ch.SoundManager:play("click")
    end)

    widget:addCommond("openSetting",function(widget,arg)
        ch.SoundManager:play("click")
        ch.UIManager:cleanGamePopupLayer(true)
        ch.UIManager:showGamePopup("setting/W_SettingList")
    end)
    
    widget:addCommond("openAchievement",function(widget,arg)
        ch.SoundManager:play("click")
        ch.UIManager:cleanGamePopupLayer(true)
        ch.UIManager:showGamePopup("achievement/W_Achievelist", nil, nil, nil, "achievement/W_Achievelist")
    end)
    
    -- 审批隐藏排行榜入口
    if zzy.config.check then
        if zzy.Sdk.getFlag()=="WYIOS" or zzy.Sdk.getFlag()=="WEIOS" then
            widget:getChild("btn_achievement"):setVisible(false)
        end
    end

    widget:addCommond("openTop",function(widget,arg)
        ch.SoundManager:play("click")
        ch.UIManager:cleanGamePopupLayer(true)
        ch.NetworkController:rankList()
        ch.UIManager:showGamePopup("achievement/N_Top", nil, nil, nil, "achievement/N_Top")		
		--发送关卡信息
		if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID and string.sub(zzy.Sdk.getFlag(),1,2)=="WY"  then
			 local info={
				f="leaderboards",
				data={level=ch.StatisticsModel:getMaxLevel(),rankid="CgkI9LTE9r0FEAIQDA"}
			}
			zzy.Sdk.extendFunc(json.encode(info))
		end
    end)
    
    widget:addCommond("openShop",function(widget,arg)
        ch.SoundManager:play("click")
        ch.UIManager:cleanGamePopupLayer(true)
        ch.UIManager:showBottomPopup("Shop/W_shop")
    end)
    
end)