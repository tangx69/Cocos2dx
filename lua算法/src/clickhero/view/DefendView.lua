zzy.BindManager:addFixedBind("MainScreen/W_JSZDmain",function(widget)
    local dataEffectEvent = {}
    dataEffectEvent[ch.DefendModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.DefendModel.dataType.hp or
    	   evt.dataType == ch.DefendModel.dataType.crystals or 
    	   evt.dataType == ch.DefendModel.dataType.killedCount
    end
    
    local levelEffectEvent = {}
    levelEffectEvent[ch.DefendModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.DefendModel.dataType.level
    end
    
    local canLevelUpEffectEvent = {}
    canLevelUpEffectEvent[ch.DefendModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.DefendModel.dataType.crystals
    end
    canLevelUpEffectEvent[ch.DefendModel.getRewardEventType] = false
    
    local critLevelChangedEvent = {}
    critLevelChangedEvent[ch.DefendModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.DefendModel.dataType.critLevel
    end
    critLevelChangedEvent[ch.DefendModel.getRewardEventType] = false
    local attackLevelChangedEvent = {}
    attackLevelChangedEvent[ch.DefendModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.DefendModel.dataType.attackLevel
    end
    attackLevelChangedEvent[ch.DefendModel.getRewardEventType] = false
    local powerDropLevelChangedEvent = {}
    powerDropLevelChangedEvent[ch.DefendModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.DefendModel.dataType.PowerDropLevel
    end
    powerDropLevelChangedEvent[ch.DefendModel.getRewardEventType] = false
    local powerChangedEvent = {}
    powerChangedEvent[ch.DefendModel.powChangeEventType] = false
    widget:addDataProxy("data", function(evt)
        local data = {}
        data.hp = ch.DefendModel:getHP()
        data.isMoreHp = ch.DefendModel:getHP() > 10
        data.isLessHp = ch.DefendModel:getHP() <= 10
        data.crystals = ch.DefendModel:getCrystals()
        data.killed = ch.DefendModel:getkilledCount()
        return data
    end,dataEffectEvent)
    widget:addDataProxy("curLevel", function(evt)
        return string.format(Language.src_clickhero_view_DefendView_1,ch.DefendModel:getCurLevel()) 
    end,levelEffectEvent)
    
    widget:addDataProxy("critText", function(evt)
        local cr = ch.DefendModel:getCritAddt()
        cr = cr > 1 and 1 or cr
        return string.format(Language.src_clickhero_view_DefendView_2,cr*100)
    end,critLevelChangedEvent)
    widget:addDataProxy("critLevel", function(evt)
        local data = {}
        if ch.DefendModel:getCritAddt() < 1 then
            data.count = "-"..ch.DefendModel:getCritLevelUpCost()
            data.showIcon = true
        else
            data.count =  Language.src_clickhero_view_DefendView_3
            data.showIcon = false
        end
        return data
    end,critLevelChangedEvent)
    widget:addDataProxy("critCanLevelUp", function(evt)
        return ch.DefendModel:getCrystals()>=ch.DefendModel:getCritLevelUpCost() and 
                ch.DefendModel:getCritAddt() < 1
    end,canLevelUpEffectEvent)
    
    widget:addDataProxy("attackText", function(evt)
        return string.format(Language.src_clickhero_view_DefendView_4,ch.DefendModel:getDPSAddt()*100)
    end,attackLevelChangedEvent)
    widget:addDataProxy("attackLevelCount", function(evt)
        return "-"..ch.DefendModel:getAttackLevelUpCost()
    end,attackLevelChangedEvent)
    widget:addDataProxy("attackCanLevelUp", function(evt)
        return ch.DefendModel:getCrystals()>=ch.DefendModel:getAttackLevelUpCost()
    end,canLevelUpEffectEvent)
    
    widget:addDataProxy("speedText", function(evt) -- 改为能量掉落
        return string.format(Language.src_clickhero_view_DefendView_5,ch.DefendModel:getPowerDropAddt()*100)  
    end,powerDropLevelChangedEvent)
    widget:addDataProxy("speedLevel", function(evt)
        local data = {}
        if ch.DefendModel:getPowerRate() < 1 then
            data.count = "-"..ch.DefendModel:getPowerDropLVCost()
            data.showIcon = true
        else
            data.count = Language.src_clickhero_view_DefendView_3
            data.showIcon = false 
        end
        return data
    end,powerDropLevelChangedEvent)
    widget:addDataProxy("speedCanLevelUp", function(evt)
        return ch.DefendModel:getCrystals()>=ch.DefendModel:getPowerDropLVCost() and
                ch.DefendModel:getPowerRate() < 1
    end,canLevelUpEffectEvent)
    
    widget:addCommond("critLevelUp", function(evt)
        local num = ch.DefendModel:getCritLevelUpCost()
        ch.DefendModel:addCritLevel(1)
        ch.DefendModel:addCrystals(-num)
    end)
    widget:addCommond("attackLevelUp", function(evt)
        local num = ch.DefendModel:getAttackLevelUpCost()
        ch.DefendModel:addAttackLevel(1)
        ch.DefendModel:addCrystals(-num)
    end)
    widget:addCommond("speedLevelUp", function(evt)
        local num = ch.DefendModel:getPowerDropLVCost()
        ch.DefendModel:addPowerDropLevel(1)
        ch.DefendModel:addCrystals(-num)
    end)
    
    widget:addDataProxy("powerNum", function(evt)
        return ch.DefendModel:getPower()
    end,powerChangedEvent)
    
    local showBtn = false
    widget:addDataProxy("showPauseBtn", function(evt)
        return showBtn
    end)
    
    widget:addCommond("pause", function(evt)
        ch.DefendMap:pause()
        ch.UIManager:showGamePopup("MainScreen/W_JSZDpause")
    end)
    
    widget:listen(ch.DefendMap.ReadyCompletedEvent,function()
        showBtn = true
        widget:noticeDataChange("showPauseBtn")
    end)
end)

zzy.BindManager:addFixedBind("MainScreen/W_JSZDpause",function(widget)
    widget:addDataProxy("killedCount", function(evt)
        return ch.DefendModel:getkilledCount()
    end)
    widget:addDataProxy("goldNum", function(evt)
        return ch.NumberHelper:toString(ch.DefendModel:getTotalGold())
    end)
    widget:addDataProxy("goldHour", function(evt)
        local num = ch.DefendModel:getTotalGoldTime()/60
        local hour = math.floor(num/60)
        local min = math.floor(num%60)
        return string.format(Language.src_clickhero_view_DefendView_10,hour,min)
    end)
    
    widget:addCommond("exit", function(evt)
        ch.DefendMap:fail()
        widget:destory()
    end)
    widget:addCommond("resume", function(evt)
        ch.DefendMap:resume()
        widget:destory()
    end)
    
end)

local createProgressTimer = function(widget,name)
    local sprite = widget:getChild(name)
    local spriteParent = sprite:getParent()
    sprite:removeFromParent()
    local spriteTimer = cc.ProgressTimer:create(sprite)
    spriteTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    spriteTimer:setReverseDirection(true)
    spriteParent:addChild(spriteTimer)
    return spriteTimer
end

zzy.BindManager:addCustomDataBind("MainScreen/N_JSZD_Skill",function(widget,data)
    local id = tonumber(data)
    local cdProgressChangedEvent = {}
    cdProgressChangedEvent[ch.DefendModel.SkillCDProgressChangedEventType] = function(evt)
        return evt.id == id
    end
    local cdStatusChangedEvent = {}
    cdStatusChangedEvent[ch.DefendModel.SkillCDStatusChangedEventType] = function(evt)
        return evt.id == id
    end
    local powerNumChanged = {}
    powerNumChanged[ch.DefendModel.powChangeEventType] = false
    
    local canUsedEffectEvent={}
    canUsedEffectEvent[ch.DefendModel.powChangeEventType] = false
    canUsedEffectEvent[ch.DefendModel.SkillCDStatusChangedEventType] = function(evt)
        return evt.id == id
    end
    
    local config = GameConfig.SkillConfig:getData(id)
    local maskTimer = createProgressTimer(widget,"skill_icon_mask")
    local cdTimer = createProgressTimer(widget,"Sprite_cd")
    
    widget:addDataProxy("powerNum", function(evt)
        return config.cost
    end)
    widget:addDataProxy("powerColor", function(evt)
        return ch.DefendModel:getPower() >= config.cost and cc.c3b(0,244,241) or cc.c3b(255,0,0)
    end,powerNumChanged)
    widget:addDataProxy("icon", function(evt)
        return config.icon
    end)
    widget:addDataProxy("isMask", function(evt)
        return ch.DefendModel:getSkillCD(id) >= 0
    end,cdStatusChangedEvent)
    widget:addDataProxy("unUsed", function(evt)
        return ch.DefendModel:getSkillCD(id) < 0 and ch.DefendModel:getPower() < config.cost
    end,canUsedEffectEvent)
    widget:addDataProxy("isCd", function(evt)
        local cdLeftTime = ch.DefendModel:getSkillCD(id)
        if cdLeftTime == -1 then
            cdTimer:setPercentage(0)
            maskTimer:setPercentage(0)
        end
        return cdLeftTime >= 0
    end,cdStatusChangedEvent)
    widget:addDataProxy("cdTime", function(evt)
        local time = ch.DefendModel:getSkillCD(id)
        if time ~= -1 then
            local percent = time * 100/ch.DefendModel:getSkillTotalCD(id)
            cdTimer:setPercentage(percent)
            maskTimer:setPercentage(percent)
        end
        time = math.ceil(time)
        local minute = math.floor(time/60)
        local second = time%60
        return string.format("%02d:%02d",minute,second)
    end,cdProgressChangedEvent)

    local showTip = false
    local totalCD = ch.DefendModel:getSkillTotalCD(id)
    local config = GameConfig.SkillConfig:getData(id)
    widget:addDataProxy("isShowLeft", function(evt)
        return showTip and id <= 14
    end)
    widget:addDataProxy("isShowRight", function(evt)
        return showTip and id > 14
    end)
    widget:addDataProxy("leftTip1", function(evt)
        return config.desc
    end)
    widget:addDataProxy("leftTip2", function(evt)
        return string.format(Language.src_clickhero_view_DefendView_6,totalCD)
    end)
    widget:addDataProxy("rightTip1", function(evt)
        return config.desc
    end)
    widget:addDataProxy("rightTip2", function(evt)
        return string.format(Language.src_clickhero_view_DefendView_6,totalCD)
    end)
    local touchTime 
    widget:addCommond("useSkill", function(evt)
        if os_clock() - touchTime > 0.2 then return end
        if ch.DefendModel:getSkillCD(id)>=0 then
            ch.UIManager:showUpTips(GameConst.DEFEND_SKILL_ERROR_TIPS[1])
        elseif ch.DefendModel:getPower() < config.cost then
            ch.UIManager:showUpTips(GameConst.DEFEND_SKILL_ERROR_TIPS[2])
        else
            ch.DefendMap:useSkill(id)
            ch.DefendModel:addPower(-config.cost)
        end
    end)
    widget:addCommond("showTip", function(obj,type)
        if type == ccui.TouchEventType.began then
            touchTime = os_clock()
            widget:setTimeOut(0.3,function()
                if touchTime then
                    showTip = true
                    widget:noticeDataChange("isShowLeft")
                    widget:noticeDataChange("isShowRight")
                end
            end)

        elseif type == ccui.TouchEventType.ended or type == ccui.TouchEventType.canceled then
            touchTime = nil
            showTip = false
            widget:noticeDataChange("isShowLeft")
            widget:noticeDataChange("isShowRight")
        end 
    end)
end)

zzy.BindManager:addFixedBind("Guild/W_JSZDresult",function(widget)
    widget:addDataProxy("gold", function(evt)
        return ch.NumberHelper:toString(ch.DefendModel:getTotalGold())
    end)
    widget:addDataProxy("killed", function(evt)
        return ch.DefendModel:getkilledCount()
    end)
    widget:addDataProxy("goldTime", function(evt)
        local num = ch.DefendModel:getTotalGoldTime()/60
        local hour = math.floor(num/60)
        local min = math.floor(num%60)
        return string.format(Language.src_clickhero_view_DefendView_7,hour,min)
    end)
    widget:addCommond("ok", function(evt)
        widget:destory()
        ch.DefendMap:destory()
        ch.LevelController:startNormal()
        ch.NetworkController:RewardInDefend(ch.DefendModel:getCurLevel(),
            ch.DefendModel:getkilledCount(),ch.DefendModel:getTotalGold())
    end)
end)

zzy.BindManager:addFixedBind("Guild/W_JSZDwaveresult",function(widget)
    local curIndex = nil
    local chestStatue = {0,0,0} -- 0为关闭，1正在打开，2 打开
    local getRewardText = function(value,type)
        local num = value
    	if type == 1 or type == 2 or type == 3 or type == 6 then
    	   num = num * 100
    	end
    	return string.format("%s: +%d %s",GameConst.DEFEND_REWARD_FRONT_TEXT[type],num,
    	                      GameConst.DEFEND_REWARD_AFTER_TEXT[type] )
    end
    
    local canTouchEvent = {}
    canTouchEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    
    widget:addDataProxy("title", function(evt)
        return string.format(GameConst.DEFEND_LEVEL_REWARD_VIEW_TITLE,ch.DefendModel:getCurLevel())
    end)
    widget:addDataProxy("isShowTips", function(evt)
        return curIndex == nil
    end)
    widget:addDataProxy("isShowBtn", function(evt)
        return curIndex ~= nil
    end)
    
    widget:addDataProxy("rewardText1", function(evt)
        local content = ch.DefendModel:getRewardContent(1)
        return getRewardText(content.l,content.t)
    end)
    widget:addDataProxy("isShowReward1", function(evt)
        return chestStatue[1] == 2
    end)
    widget:addDataProxy("rewardText2", function(evt)
        local content = ch.DefendModel:getRewardContent(2)
        return getRewardText(content.l,content.t)
    end)
    widget:addDataProxy("isShowReward2", function(evt)
        return chestStatue[2] == 2
    end)
    widget:addDataProxy("rewardText3", function(evt)
        local content = ch.DefendModel:getRewardContent(3)
        return getRewardText(content.l,content.t)
    end)
    widget:addDataProxy("isShowReward3", function(evt)
        return chestStatue[3] == 2
    end)
    widget:addDataProxy("price", function(evt)
        return GameConst.DEFEND_LEVEL_REWARD_COST
    end)
    widget:addDataProxy("moneyIcon", function(evt)
        return GameConst.SHOP_COST_ICON_IMAGE[2]
    end)
    widget:addDataProxy("btnNormal",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[2][1]
    end)
    widget:addDataProxy("btnPressed",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[2][2]
    end)
    widget:addDataProxy("canRewardAll",function(evt)
        return ch.MoneyModel:getDiamond() >= GameConst.DEFEND_LEVEL_REWARD_COST
    end,canTouchEvent)
    
    widget:addDataProxy("chestY1",function(evt)
        return (curIndex and curIndex == 1) and 20 or 0
    end)
    widget:addDataProxy("chestY2",function(evt)
        return (curIndex and curIndex == 2) and 20 or 0
    end)
    widget:addDataProxy("chestY3",function(evt)
        return (curIndex and curIndex == 3) and 20 or 0
    end)
    widget:addDataProxy("chestIcon1",function(evt)
        return chestStatue[1] == 0 and "aaui_button/cb_chest_1.png" or "aaui_button/cb_chest_2.png"
    end)
    widget:addDataProxy("chestIcon2",function(evt)
        return chestStatue[2] == 0 and "aaui_button/cb_chest_1.png" or "aaui_button/cb_chest_2.png"
    end)
    widget:addDataProxy("chestIcon3",function(evt)
        return chestStatue[3] == 0 and "aaui_button/cb_chest_1.png" or "aaui_button/cb_chest_2.png"
    end)
    widget:addDataProxy("isShowChest1",function(evt)
        return chestStatue[1] ~= 1
    end)
    widget:addDataProxy("isShowChest2",function(evt)
        return chestStatue[2] ~= 1
    end)
    widget:addDataProxy("isShowChest3",function(evt)
        return chestStatue[3] ~= 1
    end)
    widget:addDataProxy("okText",function(evt)
        return Language.src_clickhero_view_DefendView_8
    end)
    widget:addDataProxy("buyAllText",function(evt)
        return Language.src_clickhero_view_DefendView_9
    end)
    local isShow = true
    local text = GameConst.DEFEND_VIEW_AUTO_TIPS[1]
    local scheduleId = nil
    local leftTime = 0
    
    widget:addDataProxy("leftTime",function(evt)
        return math.ceil(leftTime)
    end)
    widget:addDataProxy("leftTimeTip",function(evt)
        return text
    end)
    widget:addDataProxy("isShowCutDown",function(evt)
        return isShow
    end)
    
    local startCountDown = function(time,func)
        leftTime = time
        local startTime = os_clock()
        widget:noticeDataChange("leftTime")
        scheduleId = widget:listen(zzy.Events.TickEventType,function()
            leftTime = time - os_clock() + startTime
            if leftTime > 0 then
                widget:noticeDataChange("leftTime")
            else
                widget:unListen(scheduleId)
                scheduleId = nil
                if func then func() end
            end
        end)
    end

    local touchChest = function(index)
        if scheduleId then
            widget:unListen(scheduleId)
            scheduleId = nil
        end
        isShow = false
        widget:noticeDataChange("isShowCutDown")
        curIndex = index
        chestStatue[index] = 1
        widget:noticeDataChange("chestY"..index)
        widget:noticeDataChange("chestIcon"..index)
        widget:noticeDataChange("isShowChest"..index)
        local function callBack() -- tgx 开箱子特效丢失.导致不回调,无法继续.暂时不播放特效
            chestStatue[index] = 2
            widget:noticeDataChange("isShowChest"..index)
            widget:noticeDataChange("isShowReward"..index)
            widget:noticeDataChange("isShowTips")
            widget:noticeDataChange("isShowBtn")
            for i=1,3 do
                if i ~= index then
                    chestStatue[i] = 2
                    widget:noticeDataChange("chestIcon"..i)
                    widget:noticeDataChange("isShowChest"..i)
                    widget:noticeDataChange("isShowReward"..i)
                end 
            end
            isShow = true
            widget:noticeDataChange("isShowCutDown")
            text = GameConst.DEFEND_VIEW_AUTO_TIPS[2]
            widget:noticeDataChange("leftTimeTip")
            startCountDown(5,function()
                widget:exeCommond("getReward")
            end)
        end
        widget:playEffect("chestEffect"..index,false, callBack)
        callBack()
    end
    startCountDown(5,function()
    	local num = math.random(1,3)
        touchChest(num)
    end)
    widget:addCommond("reward1", function(evt)
        if curIndex then return end
        touchChest(1)
    end)
    widget:addCommond("reward2", function(evt)
        if curIndex then return end
        touchChest(2)
    end)
    widget:addCommond("reward3", function(evt)
        if curIndex then return end
        touchChest(3)
    end)
    widget:addCommond("getReward", function(evt)
        ch.NetworkController:defendChooseReward(curIndex)
        widget:destory()
        local evt = {type = ch.DefendMap.rewardGetEvent}
        zzy.EventManager:dispatch(evt)
    end)
    widget:addCommond("getAllReward", function(evt)
        ch.NetworkController:defendChooseReward(0)
        widget:destory()
        local evt = {type = ch.DefendMap.rewardGetEvent}
        zzy.EventManager:dispatch(evt)
    end)
end)



