local getTime = function(time)
    if time > 0 then
        local day = time /(24*3600)
        if day > 1 then
            return string.format(Language.src_clickhero_view_ActiveSkillView_1,math.floor(day))
        else
            local second = math.floor(time%60)
            time = time /60
            local minute = math.floor(time%60)
            local hour = math.floor(time/60)
            return string.format("%02d:%02d:%02d",hour,minute,second)
        end
    end
end

local iconListDot = false
local iconListEffect = false
local iconListDotList = {}
local iconListEffectList = {}

local levelCount = table.maxn(GameConfig.LevelConfig:getTable())

zzy.BindManager:addFixedBind("MainScreen/W3_Skill",function(widget)
    if IS_IN_REVIEW and (not USE_SPINE) then
        local Sprite_diban1 = zzy.CocosExtra.seekNodeByName(widget, "Sprite_diban1")
        Sprite_diban1:loadTexture("res/iosReview/aaui_diban_db_bottom2.png")

        local Sprite_diban2 = zzy.CocosExtra.seekNodeByName(widget, "Sprite_diban2")
        Sprite_diban2:loadTexture("res/iosReview/aaui_diban_db_bottom1.png")

        local ListView_icon = zzy.CocosExtra.seekNodeByName(widget, "ListView_icon")
        ListView_icon:setVisible(false)

        local btn_sign = zzy.CocosExtra.seekNodeByName(widget, "btn_sign")
        btn_sign:setVisible(false)

        local btn_closed = zzy.CocosExtra.seekNodeByName(widget, "btn_closed")
        btn_closed:setVisible(false)
    end

    --debug--
    local function onClick(sender,eventType)
        if  eventType == ccui.TouchEventType.ended then
            if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
                local function cbPostImage(isOk, msg)
                    local _msg = msg or ""
                    INFO("[cbPostImage]"..msg)
                    local msgTable = json.decode(msg)
                    ch.UIManager:showMsgBox(1,true,msgTable.error,function()
                        end,nil,nil,nil)
                    return
                end
                local imageData  ="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HNVpYCKCQSszgY6CsDxB/rIvoa6VVSMYUACuR1m5jnuFWI5CDBI9aT30EvMx6KKKQwooooA//9Pm6KKKACiiigBVyWAHGattbyj7rZqnRQBZaGVV3bs4GetVqKKACiiigAooooAmjhMilgcYIGPrTjBIq7sjA9Priq9LubG3PB7UAWTFIpClzzngZ7UptpiMbgQPU1UoyaAJJImjAJxg5xj2qOiigAooooAKmjhMilwwGKhooAtPCVBIfODineQe749j1qnRQFyZ4HVS7EcVDRRQAUUUUAFFFFADgzL90kVdaB1ZR5h5H+H+NUKXc3qaAHuzglSxP41HRRQAUUUUAFFFFAH/1ObooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA/9Xm6KKKACiiigDXhtIfKDSDOR1HPPpitC1s7QA+aoY96pqpjXZyxxzinx3Xly7icHoc9/qKIxe7NpWtyotNb23DrGhUkjA61mXtpEiGWHt1HatQ3ELoxzgAg47c1Tu12wMzNyy8jt94YqmjN2MKiiipJCiiigCe3iEjEv8AdRdxxWhbNFI4QwJt/HP5k1Ws/uT/APXP/wBmFaFnHhWcjIxUydjWnFWbZOY7PaGWJcjqKpT+SuB5SEHrjIP4c1ekEbR7lJyR+VVZ0UKMccVLlYunFSbTMm4i8mTaOQQGGfQ81DWhfLloyP8Anmv8qoqpatLGLjrYAO9OK8U8LzzTiKuxaiVq1LazV4SxG52GRnoM8VnOMHNa9vI6NEiY+aMdemecVDv0M7a2M1IWeTykG5s44rQOnTwDzmVWUdR1rQhTyENxHH879QOe9XJbnZCCy/eByOam5VjmWWOVXXaEkQE/L0IHWqNamzbKT/sN/KsurasZp3CiiikMKcql22im1ZtF33CoO+R+lAGlbWO8dAfUkf41I9tbA4Dpx1IXIH41LdTfZxFBjORub3PbNFsq3DMrYAbH86zhrJXOjktByKc9sqruUKynuorMlj2YI6NXSywJbyiNTlH4IrEv08sonpn+ddU4q10ccZa2ZQooorE0CiiigD//1ubooooAKKKKAOggkaP5jkDIz74q1EltO7NNjgZ/DtmqEN6GhEfU9wSB/hViORVyjlG2nKsCB16j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"
                local channelType = zzy.cUtils.getCustomParam()
                local playerId = tostring(PLAYER_ID)
                local playerUnid = tostring(ch.PlayerModel:getPlayerUnid())
                local jsonTable = 
                {
                    imgSrc = imageData
                }
                local jsonImageStr = json.encode(jsonTable)
                
                --POST_URL = "http://192.168.1.161:11001/AppManager/addReview"
                POST_URL = "http://gjlogin.hzfunyou.com:11001/AppManager/addReview"
                postReq = string.format("%s?appId=%s&playerId=%s&playerUnid=%s", POST_URL,channelType,playerId,playerUnid)

                zzy.cUtils.post(postReq, jsonImageStr, cbPostImage)
            end
        end
        
    end

    local Panel_normal = zzy.CocosExtra.seekNodeByName(widget,"Panel_normal")
    local nodeStage = zzy.CocosExtra.seekNodeByName(Panel_normal,"nodeStage")
    local db_stages2 = zzy.CocosExtra.seekNodeByName(nodeStage,"db_stages2")
    db_stages2:setTouchEnabled(true)
    db_stages2:addTouchEventListener(onClick)
    --debug--
    
    local levelEffectEvent =  {}
    levelEffectEvent[ch.LevelController.GO_NEXT_LEVEL] = false
    levelEffectEvent[ch.PlayerModel.samsaraCleanOffLineEventType] = false
    levelEffectEvent[ch.LevelController.GAME_MODE_CHANGE] = false
    
    local killedEffectEvent = {}
    killedEffectEvent[ch.LevelController.GO_NEXT_LEVEL] = false
    killedEffectEvent[ch.PlayerModel.samsaraCleanOffLineEventType] = false
    killedEffectEvent[ch.LevelController.GAME_MODE_CHANGE] = false
    killedEffectEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        if evt.dataType == ch.LevelModel.dataType.killedCount then
            return ch.LevelModel:getCurLevel() == ch.LevelModel:getMaxLevel()
        end
        return false
    end
    local curBossEffectEvent =  {}
    curBossEffectEvent[ch.LevelController.GO_NEXT_LEVEL] = false
    curBossEffectEvent[ch.PlayerModel.samsaraCleanOffLineEventType] = false
    curBossEffectEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        if evt.dataType == ch.LevelModel.dataType.killedCount then
            return ch.LevelModel:getCurLevel() == ch.LevelModel:getMaxLevel()
        end
        return false
    end
    curBossEffectEvent[ch.LevelController.GAME_MODE_CHANGE] = false
    curBossEffectEvent[ch.WarpathModel.dataChangeEventType] = false
    
    local giveUpBossEffectEvent =  {}
    giveUpBossEffectEvent[ch.LevelController.GO_NEXT_LEVEL] = false
    giveUpBossEffectEvent[ch.LevelController.GAME_MODE_CHANGE] = false
    giveUpBossEffectEvent[ch.PlayerModel.samsaraCleanOffLineEventType] = false
    giveUpBossEffectEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        if evt.dataType == ch.LevelModel.dataType.killedCount then
            return ch.LevelModel:getCurLevel() == ch.LevelModel:getMaxLevel()
        end
        return false
    end
    
    local getConfig = function(id)
        id = math.floor(id % levelCount)
        id = id == 0 and levelCount or id
        return GameConfig.LevelConfig:getData(id)
    end
    widget:addDataProxy("curLevelId", function(evt)
        return ch.LevelModel:getCurLevel()
    end,levelEffectEvent)
    widget:addDataProxy("curLevelIcon", function(evt)
        return getConfig(ch.LevelModel:getCurLevel()).icon
    end,levelEffectEvent)
    widget:addDataProxy("curBossIcon",function(evt)
        if ch.LevelController.mode == ch.LevelController.GameMode.warpath then
            local bossId = ch.WarpathModel:getBossId()
            if bossId then
               return GameConst.BOSS_ICON[GameConfig.WarpathConfig:getData(bossId).property]
            end
        else
            return GameConst.BOSS_ICON[ch.LevelModel:getRestrain(ch.LevelModel:getCurLevel())]
        end
    end,curBossEffectEvent)
    widget:addDataProxy("isShowBossImage", function(evt)
        local id = ch.LevelModel:getCurLevel()
        return getConfig(id).type == 2
    end,levelEffectEvent)
    widget:addDataProxy("isCurBoss", function(evt)
        if ch.LevelController.mode == ch.LevelController.GameMode.normal then
            local id = ch.LevelModel:getCurLevel()
            if getConfig(id).type == 2 then
                return ch.LevelModel:getKilledCount() == 0
            end
        elseif ch.LevelController.mode == ch.LevelController.GameMode.warpath or
            ch.LevelController.mode == ch.LevelController.GameMode.goldBoss or
            ch.LevelController.mode == ch.LevelController.GameMode.sStoneBoss then
            return true
        end
        return false
    end,curBossEffectEvent)
    widget:addDataProxy("preLevelId", function(evt)
        return ch.LevelModel:getCurLevel() - 1
    end,levelEffectEvent)
    widget:addDataProxy("preLevelIcon", function(evt)
        if ch.LevelModel:getCurLevel() == 1 then
            return getConfig(1).icon
        else
            return getConfig(ch.LevelModel:getCurLevel() - 1).icon
        end
    end,levelEffectEvent)
    widget:addDataProxy("preBossIcon",function(evt)
        return GameConst.BOSS_ICON[ch.LevelModel:getRestrain(ch.LevelModel:getCurLevel() - 1)]
    end,levelEffectEvent)
    widget:addDataProxy("isPreBoss", function(evt)
        local id = ch.LevelModel:getCurLevel() - 1
        if id ~= 0 then
            return getConfig(id).type == 2
        else
            return false
        end
    end,levelEffectEvent)
    widget:addDataProxy("isFirst", function(evt) -- 第一关时隐藏前一关卡
        return ch.LevelModel:getCurLevel() ~= 1
    end,levelEffectEvent)
    widget:addDataProxy("nextLevelId", function(evt)
        return ch.LevelModel:getCurLevel() + 1
    end,levelEffectEvent)
    widget:addDataProxy("nextLevelIcon", function(evt)
        return getConfig(ch.LevelModel:getCurLevel() + 1).icon
    end,levelEffectEvent)
    widget:addDataProxy("nextBossIcon",function(evt)
        return GameConst.BOSS_ICON[ch.LevelModel:getRestrain(ch.LevelModel:getCurLevel() + 1)]
    end,levelEffectEvent)
    widget:addDataProxy("isNextBoss", function(evt)
        local id = ch.LevelModel:getCurLevel() + 1
        return getConfig(id).type == 2
    end,levelEffectEvent)
    widget:addDataProxy("killedCount", function(evt) -- 小怪击杀数量
        local id = ch.LevelModel:getCurLevel()
        local totalCount = ch.LevelModel:getTotalCount(id)
        local killedCount = ch.LevelModel:getKilledCount()
        return string.format("%d/%d",killedCount,totalCount)
    end,killedEffectEvent)
    widget:addDataProxy("isShowLabel", function(evt)
        local id = ch.LevelModel:getCurLevel()
        local levelType = getConfig(id).type
        if levelType == 2 then
            return false
        else
            return ch.LevelModel:getCurLevel() == ch.LevelModel:getMaxLevel()
        end
    end,levelEffectEvent)
    widget:addDataProxy("isShowGiveUpBoss", function(evt)
        if ch.LevelController.mode == ch.LevelController.GameMode.normal then
            local id = ch.LevelModel:getCurLevel()
            if getConfig(id).type == 2 then
                return ch.LevelModel:getKilledCount() == 0
            end
        end
        return false
    end,giveUpBossEffectEvent)
    
    widget:addDataProxy("isShowFightBoss", function(evt)
        local id = ch.LevelModel:getCurLevel()
        local levelType = getConfig(id).type
        if levelType == 2 then
            return false
        else
            if ch.guide._data["guide10040"] == 1 and ch.guide._data["guide8001"] ~= 1 then
                widget:playEffect("fightEffect",true)
            else
                widget:stopEffect("fightEffect")
            end
            return ch.LevelModel:getCurLevel() ~= ch.LevelModel:getMaxLevel()
        end
    end,levelEffectEvent)
    
    widget:addCommond("fightBoss", function(evt)
        if ch.guide._data["guide10040"] == 1 and ch.guide._data["guide8001"] ~= 1 then
            ch.guide:savestate(8001)
        end
        ch.NetworkController:sendCacheData(1)
        ch.LevelModel:nextLevel()
        ch.LevelController:goNextLevel(false)
    end)
    widget:addCommond("giveUpBoss", function(evt)
        ch.NetworkController:clearLevelData()
        ch.NetworkController:sendCacheData(-1)
        ch.LevelController:goPreLevel(false,true)
    end)
    widget:addCommond("opensign", function(evt)
        ch.SoundManager:play("click")
        ch.UIManager:cleanGamePopupLayer(true)
        ch.UIManager:showGamePopup("MainScreen/W_Activity")
    end)
    widget:addDataProxy("canGiveUp", function(evt)
        return ch.LevelController:getState() == 2
    end,levelEffectEvent)
    widget:addDataProxy("canFight", function(evt)
        if ch.LevelController:getState() == 2 then
            return true
        else
           widget:setTimeOut(0,function()
               widget:noticeDataChange("canFight")
           end)
           return false
        end 
    end,levelEffectEvent)
    local totalTime = GameConst.BOSS_FIGHT_TIME
    local leftTime = 0
    local curHp = ch.LongDouble:new(1)
    local maxHp = ch.LongDouble:new(1)
    widget:addDataProxy("hp", function(evt)
        local hp = (curHp/maxHp):toNumber()
        return hp < 0 and 0 or hp
    end)
    widget:addDataProxy("hpColor", function(evt)
        local per = (curHp/maxHp):toNumber()
        for _, opt in ipairs(GameConst.FIGHT_HP_COLOR) do
            if opt.r < per then
                return opt.c
            end
        end
        return GameConst.FIGHT_HP_COLOR[1].c
    end)
    widget:listen(ch.fightRole.BOSS_HP_CHANGE_EVENT_TYPE,function(obj,evt)
        curHp = evt.curhp
        maxHp = evt.maxhp
        widget:noticeDataChange("hp")
        widget:noticeDataChange("hpColor")
    end)
   
    widget:addDataProxy("leftTime", function(evt)
        return string.format("%.01f",leftTime)
    end)
    widget:addDataProxy("leftTimePercent", function(evt)
        return leftTime/totalTime
    end)
    local scheduleId = nil -- 正常计时
    local warpathSId = nil -- 无尽征途计�?
    local startPauseTime = nil
    local totalPauseTime = 0
    local pause = function()
        ch.fightRoleLayer:pause()
        startPauseTime = os_clock()
    end
    
    local startCountDown = function()
        totalTime = GameConst.BOSS_FIGHT_TIME
        leftTime = totalTime
        startPauseTime = nil
        totalPauseTime = 0
        curHp = ch.LongDouble:new(1)
        maxHp = ch.LongDouble:new(1)
        widget:noticeDataChange("leftTime")
        widget:noticeDataChange("leftTimePercent")
        widget:noticeDataChange("hp")
        widget:noticeDataChange("hpColor")
        widget:noticeDataChange("canGiveUp")
        local hasStarted = false
        scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            if not hasStarted then
               widget:noticeDataChange("canGiveUp")
            end
            if ch.LevelController:getState() ~= 2 then return end
            hasStarted = true
            local now = os_clock()
            if ch.fightRoleLayer:isPause() then
                if not startPauseTime then
                    startPauseTime = now
                end
                return
            end
            if startPauseTime then
                totalPauseTime = totalPauseTime + now - startPauseTime
                startPauseTime = nil
            end
            if ch.fightRoleAI.bossStartAtkTime and now > ch.fightRoleAI.bossStartAtkTime then
                leftTime = totalTime - now + ch.fightRoleAI.bossStartAtkTime + totalPauseTime
            end
            if leftTime > 0 then
                widget:noticeDataChange("leftTime")
                widget:noticeDataChange("leftTimePercent")
            else
                if ch.LevelModel:getCurLevel() >= GameConst.SHOP_BUY_BOSS_UNLOCKLEVEL and
                    ch.LevelModel:getBuyCount() < #GameConst.SHOP_BUY_BOSS_COST and
                    ch.SettingModel:isBossTimeRemind() then -- 不在提醒
                    pause()
                    ch.UIManager:showGamePopup("Shop/W_shop_buybosstime")
                else
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
                    scheduleId = nil
                    if ch.LevelController.mode == ch.LevelController.GameMode.normal then
                        ch.NetworkController:sendCacheData(-1)
                        ch.LevelController:goPreLevel(false)
                    elseif ch.LevelController.mode == ch.LevelController.GameMode.goldBoss then
                        local level = math.floor(ch.LevelModel:getCurLevel()/5)*5
                        ch.fightRoleLayer:pause()
                        ch.LevelController:openResultGoldBoss(false,level,maxHp - curHp)
                    elseif ch.LevelController.mode == ch.LevelController.GameMode.sStoneBoss then
                        ch.NetworkController:killedGoldBoss(0,2,0,ch.LevelController:getGoldBossTime(),maxHp - curHp)
                        ch.LevelController:startNormal()
                    end
                end
            end
        end,0,false)
    end
    local levelType = getConfig(ch.LevelModel:getCurLevel()).type
    if levelType == 2 then
        startCountDown()
    end
    
    local stopAllCutDown = function()
        if scheduleId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
            scheduleId = nil
        end
        if warpathSId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(warpathSId)
            warpathSId = nil
        end
    end
    --boss 死亡立即停止计时
    widget:listen(ch.fightRole.BOSS_PASS_EVENT_TYPE,function(obj,evt)
        stopAllCutDown()
    end)
    
    widget:listen(ch.LevelController.GO_NEXT_LEVEL,function(obj,evt)
        local id = ch.LevelModel:getCurLevel()
        local levelType = getConfig(id).type
        if scheduleId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
            scheduleId = nil
        end
        if levelType == 2 then
            startCountDown()
        end
    end)
    
    widget:listen(ch.PlayerModel.samsaraCleanOffLineEventType,function(obj,evt)
        local id = ch.LevelModel:getCurLevel()
        local levelType = getConfig(id).type
        stopAllCutDown()
        if levelType == 2 then
            startCountDown()
        end
    end)
    
    
    widget:listen(ch.LevelModel.buyCountEventType,function(obj,evt)
        if evt.dataType == ch.LevelModel.buyDataType.buy then
            totalTime = totalTime + GameConst.SHOP_BUY_BOSS_TIME
            ch.fightRoleLayer:resume()
        else
            stopAllCutDown()
            if ch.LevelController.mode == ch.LevelController.GameMode.normal then
                ch.NetworkController:sendCacheData(-1)
                ch.LevelController:goPreLevel(false)
                ch.fightRoleLayer:resume()
            elseif ch.LevelController.mode == ch.LevelController.GameMode.goldBoss then
                local level = math.floor(ch.LevelModel:getCurLevel()/5)*5
                ch.LevelController:openResultGoldBoss(false,level,maxHp - curHp)
            elseif ch.LevelController.mode == ch.LevelController.GameMode.sStoneBoss then    
                ch.NetworkController:killedGoldBoss(0,2,0,ch.LevelController:getGoldBossTime(),maxHp - curHp)
                ch.LevelController:startNormal()
            end
        end
    end)

    local dropEvent = {}
    dropEvent[ch.LevelModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.LevelModel.dataType.sstone or evt.dataType == ch.LevelModel.dataType.curLevel
    end
    dropEvent[ch.LevelController.GAME_MODE_CHANGE] = false
    -- 是否有魂石掉�?
    widget:addDataProxy("ifGetSStone",function(evt)
        if ch.LevelController.mode == ch.LevelController.GameMode.warpath then
            return false
        end
        local num = ch.LevelModel:getSStoneDropData(ch.LevelModel:getCurLevel()) or 0
        return num > 0 
    end,dropEvent)
    
    -- 掉落魂石数量
    widget:addDataProxy("getSStoneNum",function(evt)
        return ch.LevelModel:getSStoneDropData(ch.LevelModel:getCurLevel()) or 0
    end,dropEvent)
    
    local restrainEvent = {}
    restrainEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    restrainEvent[ch.PartnerModel.czChangeEventType] = function(evt)
    	return evt.dataType == ch.PartnerModel.dataType.fight
    end
    restrainEvent[ch.LevelController.GAME_MODE_CHANGE] = false
    restrainEvent[ch.WarpathModel.dataChangeEventType] = false
    
    -- 是否属性相�?
    widget:addDataProxy("isRestrain",function(evt)
        local petRestrain = GameConst.PET_ATTRIBUTE_RESTRAIN[ch.PartnerModel:getCurPartnerRestrain()]
        if ch.LevelController.mode == ch.LevelController.GameMode.normal then
            return petRestrain == 0 or petRestrain == ch.LevelModel:getRestrain(ch.LevelModel:getCurLevel())
        elseif ch.LevelController.mode == ch.LevelController.GameMode.warpath then
            local bossId = ch.WarpathModel:getBossId()
            if bossId then
                local bossRestrain = GameConfig.WarpathConfig:getData(bossId).property
                return petRestrain == 0 or petRestrain == bossRestrain
            else
                return false
            end
        else
            return petRestrain == 0 or petRestrain == 1
        end
    end,restrainEvent)

    -- 宠物克制加成
    widget:addDataProxy("restrain",function(evt)
        local value = GameConst.PET_RESTRAIN_HARM_RATIO
        local partnerId = ch.PartnerModel:getCurPartner()
        if (partnerId == "20007" or partnerId == 20007) and GameConst.PET_RESTRAIN_HARM_RATIO_1 then
            value = GameConst.PET_RESTRAIN_HARM_RATIO_1
        elseif (partnerId == "20008" or partnerId == 20008) and GameConst.PET_RESTRAIN_HARM_RATIO_2 then
            value = GameConst.PET_RESTRAIN_HARM_RATIO_2
        else
            value = GameConst.PET_RESTRAIN_HARM_RATIO
        end

        return "+".. value*100 .."%"
    end, restrainEvent)
    
    local dpsEffect = {}
    dpsEffect[ch.RunicModel.dataChangeEventType] = false
    dpsEffect[ch.MagicModel.dataChangeEventType] = false
    dpsEffect[ch.TotemModel.dataChangeEventType] = false
    dpsEffect[ch.RunicModel.SkillDurationStatusChangedEventType] =false
    dpsEffect[ch.AchievementModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.AchievementModel.dataType.state
    end
    dpsEffect[ch.BuffModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.BuffModel.dataType.card or 
            evt.dataType == ch.BuffModel.dataType.inspire
    end
    dpsEffect[ch.MoneyModel.dataChangeEventType] = function (evt)
        return evt.dataType == ch.MoneyModel.dataType.soul
    end
    dpsEffect[ch.TaskModel.dataChangeEventType] = function (evt)
        return evt.dataType == ch.TaskModel.dataType.state
    end
    dpsEffect[ch.PartnerModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.PartnerModel.dataTypelj.lq
    end
    dpsEffect[ch.PartnerModel.czChangeEventType] = function(evt)
        return evt.dataType == ch.PartnerModel.dataType.get
    end
    dpsEffect[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.PetCardModel.dataType.level
    end
    dpsEffect[ch.AltarModel.dataChangeEventType] = false
    dpsEffect[ch.ShentanModel.dataChangeEventType] = false
    dpsEffect[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.enchantment
    end

    widget:addDataProxy("magicDPS", function(evt)
        local evt = {type = ch.PlayerModel.allDPSChangeEventType}
        zzy.EventManager:dispatch(evt)
        return ch.NumberHelper:toString(ch.MagicModel:getTotalDPS())
    end,dpsEffect)
    widget:addDataProxy("runicDPS", function(evt)
        return ch.NumberHelper:toString(ch.RunicModel:getDPS())
    end,dpsEffect)
    local soulEvent = {}
    soulEvent[ch.MoneyModel.dataChangeEventType] = function (evt)
    	return evt.dataType == ch.MoneyModel.dataType.soul or evt.dataType == ch.MoneyModel.dataType.sStone
    end
    local soulAddDPSEvent = {}
    soulAddDPSEvent[ch.MoneyModel.dataChangeEventType] = function (evt)
        return evt.dataType == ch.MoneyModel.dataType.soul or evt.dataType == ch.MoneyModel.dataType.sStone
    end
    soulAddDPSEvent[ch.TotemModel.dataChangeEventType] = false
    soulAddDPSEvent[ch.StatisticsModel.samsaraAddRTimesEventType] = false
    soulAddDPSEvent[ch.AltarModel.dataChangeEventType] = false
    soulAddDPSEvent[ch.ShentanModel.dataChangeEventType] = false
    
    widget:addDataProxy("soulNum", function(evt)
        return ch.NumberHelper:toString(ch.MoneyModel:getSoul())
    end,soulEvent)
    widget:addDataProxy("soulAddDPS", function(evt)
        return "+"..ch.NumberHelper:multiple(ch.StatisticsModel:getSoulRatio(ch.MoneyModel:getSoul())*100,1000)
    end,soulAddDPSEvent)
    widget:addDataProxy("sstoneNum", function(evt)
        return ch.NumberHelper:toString(ch.MoneyModel:getsStone())
    end,soulEvent)
    
    -- buff剩余时间显示
    local buffEffectEvent = {}
    buffEffectEvent[ch.BuffModel.dataChangeEventType] = false
    widget:addDataProxy("isShowCard",function(evt)
        local isShow = {}
        isShow.card = ch.BuffModel:getCardBuffTime()>0
        isShow.sStone = ch.BuffModel:getSStoneTime()>0
        isShow.inspire = ch.BuffModel:getInspireTime()>0
        isShow.manyGold = ch.BuffModel:getManyGoldTime()>0
        if isShow.card then
            widget:playEffect("guangEffect1",true)
        else
            widget:stopEffect("guangEffect1")
        end
        if isShow.sStone then
            widget:playEffect("guangEffect2",true)
        else
            widget:stopEffect("guangEffect2")
        end
        if isShow.inspire then
            widget:playEffect("guangEffect3",true)
        else
            widget:stopEffect("guangEffect3")
        end
        if isShow.manyGold then
            widget:playEffect("guangEffect4",true)
        else
            widget:stopEffect("guangEffect4")
        end
        return isShow
    end,buffEffectEvent)
    
    local names = {}
    names[ch.BuffModel.dataType.card] = "cardTime"
    names[ch.BuffModel.dataType.sStone] = "sStoneTime"
    names[ch.BuffModel.dataType.inspire] = "inspireTime"
    names[ch.BuffModel.dataType.manyGold] = "manyGoldTime"
    
    local noticeList = {}
    if ch.BuffModel:getCardBuffTime() > 0 then
        noticeList["cardTime"] = true
    end
    if ch.BuffModel:getSStoneTime() > 0 then
        noticeList["sStoneTime"] = true
    end
    if ch.BuffModel:getInspireTime() > 0 then
        noticeList["inspireTime"] = true
    end
    if ch.BuffModel:getManyGoldTime() > 0 then
        noticeList["manyGoldTime"] = true
    end
    widget:listen(zzy.Events.TickEventType,function()
        for k,v in pairs(noticeList) do
            widget:noticeDataChange(k)
        end
        -- 祭坛提醒
        if ch.StatisticsModel:getMaxLevel() > GameConst.ALTAR_OPEN_LEVEL[1] then
            widget:noticeDataChange("ifAltarExp")
        end
        if ch.StatisticsModel:getMaxLevel()>GameConst.RANDOM_SHOP_BLACK_OPEN_LEVEL and ch.RandomShopModel:ifBlackRefresh() then
            widget:noticeDataChange("ifNoSign")
        end
        local flag= string.sub(zzy.Sdk.getFlag(),1,2)
        if flag=="CY" and ch.ShopModel:getGiftBagTime()>0 and ch.ShopModel:getGiftBagTime()<= os_time() then
            ch.ShopModel:setGiftBagState(2)
        end
        
        iconListEffect = false
        for k,v in pairs(iconListEffectList) do
            if v then
                iconListEffect = true
                break
            end
        end
        iconListDot = false
        if not iconListEffect then
            for k,v in pairs(iconListDotList) do
                if v then
                    iconListDot = true
                    break
                end
            end
        end

        widget:noticeDataChange("ifIconListDot")
        widget:noticeDataChange("ifIconListEffect")
        
    end)
    widget:listen(ch.BuffModel.dataChangeEventType,function(obj,evt)
        if evt.statue == ch.BuffModel.statue.began then
            noticeList[names[evt.dataType]] = true
        else
            noticeList[names[evt.dataType]] = nil
        end
    end)
    widget:addDataProxy("cardTime",function(evt)
        local time = ch.BuffModel:getCardBuffTime()
        return getTime(time)
    end)
    
    widget:addDataProxy("sStoneTime",function(evt)
        local time = ch.BuffModel:getSStoneTime()
        return getTime(time)
    end)
    widget:addDataProxy("inspireTime",function(evt)
        local time = ch.BuffModel:getInspireTime()
        return getTime(time)
    end)
    widget:addDataProxy("manyGoldTime",function(evt)
        local time = ch.BuffModel:getManyGoldTime()
        return getTime(time)
    end)
    
    local signEvent = {}
    signEvent[ch.SignModel.dataChangeEventType] = false
    signEvent[ch.FirstSignModel.dataChangeEventType] = false
    signEvent[ch.WarpathModel.dataChangeEventType] = false
    signEvent[ch.DefendModel.dataChangeEventType] = false
    signEvent[ch.BuyLimitModel.dataChangeEventType] = false
    signEvent[ch.CardFBModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.CardFBModel.dataType.fetchStamina
    end
    signEvent[ch.MineModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MineModel.dataType.state 
            or evt.dataType == ch.MineModel.dataType.occupy
    end
    if ch.StatisticsModel:getMaxLevel() <= GameConst.MINE_OPEN_LEVEL then
        signEvent[ch.LevelModel.dataChangeEventType] = function(evt)
            return evt.dataType == ch.LevelModel.dataType.curLevel
        end
    end
    signEvent[ch.RandomShopModel.dataBlackChangeEventType] = false
    signEvent[ch.SignModel.effectChangeEventType] = false
    
    -- 签到,无尽征�?坚守阵地,每日限购
    widget:addDataProxy("ifNoSign",function(evt)
--        if ch.SignModel:getSignStatus() == 0 or ch.SignModel:getShowEffect() then
--            ch.BuyLimitModel.isEffect and 
--            ((ch.WarpathModel:isOpen() and ch.WarpathModel:getTimes() < 1) or 
--            (ch.StatisticsModel:getMaxLevel()>GameConst.DEFEND_OPEN_LEVEL and ch.DefendModel:getTimes() < GameConst.DEFEND_DAY_MAX_COUNT)) then
        -- 转圈太频繁，暂时去掉
--        if ch.FirstSignModel:isFirstSign() and ch.FirstSignModel:getSignStatus() ~= 2 then
--            widget:playEffect("signEffect",true)
--        elseif not ch.FirstSignModel:isFirstSign() and ch.SignModel:getSignStatus() == 0 then
--            widget:playEffect("signEffect",true)
--        elseif ch.CardFBModel:canFetched() then
--            widget:playEffect("signEffect",true)   
--        elseif ch.SignModel:getShowEffect() and 
--            ((ch.WarpathModel:isOpen() and ch.WarpathModel:getTimes() < 1) or 
--            (ch.StatisticsModel:getMaxLevel()>GameConst.DEFEND_OPEN_LEVEL and ch.DefendModel:getTimes() < GameConst.DEFEND_DAY_MAX_COUNT)) then
--            widget:playEffect("signEffect",true)
--        elseif ch.StatisticsModel:getMaxLevel()>GameConst.MINE_OPEN_LEVEL and ch.MineModel:getMyMineId() <= 0 and ch.MineModel:getAttNum() > 0 then
--            widget:playEffect("signEffect",true)
--        elseif ch.StatisticsModel:getMaxLevel()>GameConst.RANDOM_SHOP_BLACK_OPEN_LEVEL and ch.RandomShopModel:ifBlackRefresh() then
--            widget:playEffect("signEffect",true)
--        else
--            widget:stopEffect("signEffect")
--        end
        -- 每天提醒一�?
        if IS_IN_REVIEW  and (not USE_SPINE) and ch.SignModel:getShowEffect() then
            widget:playEffect("signEffect",true)
        else
            widget:stopEffect("signEffect")
        end
    end,signEvent)
    -- 转圈不出红点
    widget:addDataProxy("ifNoSignDot",function(evt)
--        if ch.SignModel:getSignStatus() ~= 0 and 
--            not ch.SignModel:getShowEffect() and 
--            ((ch.WarpathModel:isOpen() and ch.WarpathModel:getTimes() < 1) or 
--            (ch.StatisticsModel:getMaxLevel()>GameConst.DEFEND_OPEN_LEVEL and ch.DefendModel:getTimes() < GameConst.DEFEND_DAY_MAX_COUNT)) 
--            or (ch.StatisticsModel:getMaxLevel()>GameConst.RANDOM_SHOP_BLACK_OPEN_LEVEL and not ch.RandomShopModel:ifBlackRefresh() and ch.RandomShopModel:ifCanBuyBlack())  then
--            return true
--        else
--            return false
--        end
        return ch.SignModel:getRedPointALL() and not ch.SignModel:getShowEffect()
    end,signEvent)
    
    local messageEvent = {}
    messageEvent[ch.MsgModel.dataChangeEventType] = false
    
    -- 消息
    widget:addDataProxy("isNoRead",function(evt)
        local state = ch.MsgModel:numNew() > 0
        if state then
            widget:playEffect("msgEffect",true)
        else
            widget:stopEffect("msgEffect")
        end
        return false
    end,messageEvent)
    -- 未读消息�?
    widget:addDataProxy("msgNum",function(evt)
        return ch.MsgModel:numNew()
    end,messageEvent)
    widget:addCommond("openMessage",function()
        if ch.MsgModel:ifShowType("2") and ch.MsgModel:getDataState(2) then
            ch.NetworkController:msgPanel(2)
        elseif ch.MsgModel:ifShowType("3") and ch.MsgModel:getDataState(3) then
            ch.NetworkController:msgPanel(3)
        end
        ch.UIManager:cleanGamePopupLayer(true)
        if not ch.UIManager.isTipOpen then
            ch.UIManager.isMsgOpen = true
            ch.UIManager:_addPopupOverMain("msg/W_Msg")
        end
    end)
    
    local altarEvent = {}
    altarEvent[ch.StatisticsModel.maxLevelChangeEventType] = false
    
    widget:addDataProxy("ifNoAltar",function(evt)
        return ch.StatisticsModel:getMaxLevel() > GameConst.ALTAR_OPEN_LEVEL[1]
    end,altarEvent)
    widget:addDataProxy("ifAltarExp",function(evt)
        if ch.AltarModel:getEffectTime() > 0 then
            widget:stopEffect("altarEffect")
        else
            widget:playEffect("altarEffect",true)
        end
        return false
    end)
    widget:addCommond("openAltar", function(evt)
        ch.UIManager:cleanGamePopupLayer(true,true)
        ch.NetworkController:altarPanel(ch.AltarModel:getCurAltarSelect())
        ch.UIManager:showGamePopup("card/W_jt_main")
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10250 then
            ch.guide:endid(10250)
        end
    end)

    local isOpen = true     
    widget:addDataProxy("isOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel() > 10 and isOpen
    end,altarEvent)
    widget:addDataProxy("isClose",function(evt)
        return ch.StatisticsModel:getMaxLevel() > 10 and not isOpen
    end,altarEvent)
    widget:addCommond("openList", function(evt)
        isOpen = true
        widget:noticeDataChange("isOpen")
        widget:noticeDataChange("isClose")
    end)
    widget:addCommond("closeList", function(evt)
        isOpen = false
        widget:noticeDataChange("isOpen")
        widget:noticeDataChange("isClose")        
    end)
    
    widget:addDataProxy("ifIconListDot",function(evt)
        return iconListDot and not iconListEffect
    end)
    
    widget:addDataProxy("ifIconListEffect",function(evt)
        if iconListEffect then
            widget:playEffect("iconListEffect",true)
        else
            widget:stopEffect("iconListEffect")
        end
        return iconListEffect
    end)
    
    
    
    -- 图标列表
    local showEvent = {}
    if ch.StatisticsModel:getMaxLevel() <= GameConst.DEFEND_OPEN_LEVEL then
        showEvent[ch.LevelModel.dataChangeEventType] = function(evt)
            return evt.dataType == ch.LevelModel.dataType.curLevel
        end
    end
    -- 活动按钮和消息按钮是否出�?
    widget:addDataProxy("ifIconShow",function(evt)
        return ch.StatisticsModel:getMaxLevel() > 10
    end,showEvent)
    -- 消息按钮不显示（挪到列表了）
    widget:addDataProxy("ifIconShowMsg",function(evt)
        return false
    end)  
    widget:addDataProxy("ifSignOpen",function(evt)
        if ch.SignModel:getSignStatus() == 0 and ch.StatisticsModel:getMaxLevel() > 10 then
            if (ch.FirstSignModel:isFirstSign() and ch.FirstSignModel:getLoginCount() == 0) or (not ch.FirstSignModel:isFirstSign() and ch.SignModel:getLoginCount() == 0) then
                ch.UIManager:showGamePopup("task/W_sign")
            end
        end
        if zzy.config.openADItems then
            for k,v in pairs(zzy.config.openADItems) do
                if v.type == "img" then
                    ch.UIManager:showGamePopup("msg/W_ad",k)
                end
            end
        end
    end)
    widget:addDataProxy("direction",function(evt)
        return ccui.ListViewDirection.verticalSnap
    end)
    -- 图标列表
    local listEvent = {}
    listEvent[ch.PlayerModel.offLineGetEventType] = false
    listEvent[ch.PlayerModel.samsaraCleanOffLineEventType] = false
    listEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.star
    end
    listEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    listEvent[ch.TaskModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.TaskModel.dataType.state
    end
    listEvent[ch.PartnerModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.PartnerModel.dataTypelj.lq
    end
    listEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.PetCardModel.dataType.clean or evt.dataType == ch.PetCardModel.dataType.drop
    end
    
    listEvent[ch.FestivityModel.dataChangeEventType] = false
    
    listEvent[ch.LevelController.GAME_MODE_CHANGE] = false

    listEvent[ch.AFKModel.dataChangeEventType] = false
    
    listEvent[ch.AFKModel.dataChangeEventType] = false

    listEvent[ch.OffLineModel.dataChangeEventType] = false
    
    listEvent[ch.FamiliarModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FamiliarModel.dataType.get or evt.dataType == ch.FamiliarModel.dataType.clean
    end
    
    listEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.ChristmasModel.dataType.open or evt.dataType == ch.ChristmasModel.dataType.stop
    end
    
    listEvent[ch.ShopModel.dataChangeEventType_GiftBag] = false
    
    widget:addDataProxy("iconList",function(evt)
        local items = {}
        if ch.StatisticsModel:getMaxLevel() > 10 then
            table.insert(items,"13")
        end
        if ch.StatisticsModel:getMaxLevel() > GameConst.TASK_OPEN_LEVEL then
            table.insert(items,"2")
        end
        if ch.StatisticsModel:getMaxLevel() > GameConst.MGAIC_STAR_LEVEL and (ch.MagicModel:getTotalStar() > 0 or ch.MoneyModel:getStar()>0) then
            table.insert(items,"1")
        end
        if ch.ModelManager:getOffLineGold()> ch.LongDouble.zero then
            table.insert(items,"3")
        end
        if ch.PartnerModel:isGetReward() or table.maxn(ch.PetCardModel:getCardList())>0 or table.maxn(ch.OffLineModel:getRewardList()) > 0 or table.maxn(ch.FamiliarModel:getSeeFamiliars()) >0 then
            table.insert(items,"4")
        end
        if ch.UserTitleModel:isOpenNewStage() then
            table.insert(items,"5")
        end
        if (ch.FestivityModel:getWeek() == 1 or ch.FestivityModel:getWeek() == 3) and ch.StatisticsModel:getMaxLevel() > 10 then
            table.insert(items,"6")
        end
        if (ch.FestivityModel:getWeek() == 2 or ch.FestivityModel:getWeek() == 4) and ch.StatisticsModel:getMaxLevel() > 10 then
            table.insert(items,"7")
        end
        if ch.StatisticsModel:getRTimes() >0 and not ch.AFKModel:isAFKing() and ch.LevelModel:getCurLevel() < ch.AFKModel:getAFKLevelAndTime() then
            table.insert(items,"8")
        end
        if ch.StatisticsModel:getRTimes() >0 and ch.AFKModel:getLastReward() then
            table.insert(items,"9")
        end
        if ch.ChristmasModel:isOpen() and ch.StatisticsModel:getMaxLevel() > 10 then
            table.insert(items,"10")
        end
		local flag= string.sub(zzy.Sdk.getFlag(),1,2)
		if flag=="WY" or flag=="CY" or flag=="WE" then
			table.insert(items,"11")
		end
		if flag=="TJ" then
			--Cafe SDK要在安卓4.2版本以上才显�?
			local androidSDKVer = zzy.cUtils.getDeviceSystem()
			local result = ch.UpdateManager:_compareVersion(androidSDKVer, "4.2.0")
			if  result >= 0 then
				table.insert(items,"12")
			end
		end
		--if flag=="CY" then
			--table.insert(items,"14")
		--end
		-- 新手礼包按钮
--        if flag=="CY" and ch.ShopModel:isGiftBagCanBuy() then
        if ch.ShopModel:isGiftBagCanBuy() then
            table.insert(items,"15")
        end
        local tmpDotList = {}
        local tmpEffectList = {}
        for k,v in pairs(items) do
            tmpDotList[tonumber(v)] = iconListDotList[tonumber(v)]
            tmpEffectList[tonumber(v)] = iconListEffectList[tonumber(v)]
        end
        iconListEffectList = tmpEffectList
        iconListDotList = tmpDotList
        return items
    end,listEvent)
    
    -- 以下为无尽征�?   
    local gameModelChangeEvent = {}
    gameModelChangeEvent[ch.LevelController.GAME_MODE_CHANGE] = false
    widget:addDataProxy("gameModel",function(evt)
        local data = {}
        data.isNormal = ch.LevelController.mode == ch.LevelController.GameMode.normal or 
            ch.LevelController.mode == ch.LevelController.GameMode.goldBoss or
            ch.LevelController.mode == ch.LevelController.GameMode.sStoneBoss or
            ch.LevelController.mode == ch.LevelController.GameMode.AFK
        data.isWarpath = ch.LevelController.mode == ch.LevelController.GameMode.warpath
        return data
    end,gameModelChangeEvent)
    
    local getBossIcon = function(index)
    	if index >=1 and index<= GameConst.WARPATH_BOSS_MAX_COUNT then
            local bossId = ch.WarpathModel:getBossId(index)
            if bossId then
                return string.format("res/icon/boss_%d.png",GameConfig.WarpathConfig:getData(bossId).property)
            end
    	end
        return nil
    end
    
    local warpathChangedEvent = {}
    warpathChangedEvent[ch.WarpathModel.dataChangeEventType] = function()
        return ch.WarpathModel:isOpen()
    end
    widget:addDataProxy("warpath",function(evt)
        local data = {}
        if ch.WarpathModel:isOpen() then
            data.stage = string.format(Language.src_clickhero_view_ActiveSkillView_2,ch.WarpathModel:getCurStage())
            data.isShowFirst = ch.WarpathModel:getCurIndex() > 1
            data.isShowLast = ch.WarpathModel:getCurIndex() < GameConst.WARPATH_BOSS_MAX_COUNT
            data.preId = ch.WarpathModel:getCurIndex() - 1
            data.curId = ch.WarpathModel:getCurIndex()
            data.nextId = ch.WarpathModel:getCurIndex() + 1
            data.preBossIcon = getBossIcon(data.preId)
            data.curBossIcon = getBossIcon(data.curId)
            data.nextBossIcon = getBossIcon(data.nextId)
        end
        return data
    end,warpathChangedEvent)
    
    local warpathLeftTime = GameConst.WARPATH_TOTAL_TIME
    widget:addDataProxy("warpathleftTime",function(evt)
        return string.format("%.01f",warpathLeftTime)
    end)
    
    local startWarpathCutDown = function()
        warpathLeftTime = GameConst.WARPATH_TOTAL_TIME
        widget:noticeDataChange("warpathleftTime")
    	local lastTime = os_clock()
    	warpathSId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            local now = os_clock()
            local dt = now - lastTime
            lastTime = now
            if not ch.LevelController:wStartTime() then return end
            warpathLeftTime = warpathLeftTime - dt
            if warpathLeftTime >= 0 then
                widget:noticeDataChange("warpathleftTime")
            else
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(warpathSId)
                local enemy = ch.fightRoleLayer:getNewestAliveEnemy()
                if enemy then
                    ch.NetworkController:killedInWarpath(ch.WarpathModel:getCurIndex(),enemy.curhp,ch.LongDouble.zero)
                    ch.WarpathModel:AttackBoss(enemy.realhp-enemy.curhp,enemy.curhp)
                end
                ch.LevelController:openResultWarpath()
            end
    	end,0,false)
    end
    
    
    
    widget:listen(ch.LevelController.GAME_MODE_CHANGE,function(obj,evt)
        stopAllCutDown()
        if evt.mode == ch.LevelController.GameMode.warpath then
            startWarpathCutDown()
        elseif evt.mode == ch.LevelController.GameMode.normal then
            local id = ch.LevelModel:getCurLevel()
            local levelType = getConfig(id).type
            if levelType == 2 then
                startCountDown()
            end
        elseif evt.mode == ch.LevelController.GameMode.goldBoss or
            evt.mode == ch.LevelController.GameMode.sStoneBoss then
            startCountDown()
        --elseif evt.mode == ch.LevelController.GameMode.defend then
        end
    end)
    
    widget:addCommond("OpenChat", function(evt)
--        if ch.StatisticsModel:getMaxLevel() > GameConst.CHAT_OPEN_LEVEL then
            ch.ChatView:getInstanse():show()
            ch.ChatModel:clearUnreadCount()
--        else
--            ch.UIManager:showMsgBox(1,true,string.format(GameConst.CHAT_UNLOCK_TIP,GameConst.CHAT_OPEN_LEVEL))
--        end
    end)
    
    local chatEffectEvent = {}
    chatEffectEvent[ch.ChatModel.dataChangeEventType] = false
    widget:addDataProxy("chat",function(evt)
        local data = {}
        data.content = ch.ChatModel:getChatContent()
        data.count = ch.ChatModel:getUnreadCount()
        data.isShow = ch.ChatModel:getUnreadCount() > 0

        local isSysMsg = (not data.i) or (data.i == "")
        local sysColor = nil
        if  isSysMsg and data.rgb and string.len(data.rgb) >= 6 then
            sysColor = ch.CommonFunc:hexStringToColor3b(data.rgb)
        end
        local chatPanel = zzy.CocosExtra.seekNodeByName(widget, "panel_chat")
        local chatText = zzy.CocosExtra.seekNodeByName(chatPanel, "text_name")
        if sysColor then
            chatText:setColor(sysColor)
        end

        return data
    end,chatEffectEvent)
    
    local powerEffectEvent = {}
    powerEffectEvent[ch.PowerModel.dataChangeEventType] = false
    widget:addDataProxy("power", function(evt)
        local data = {}
        data.progress = ch.PowerModel:getPower()*100/GameConst.POWER_MAX_NUMBER
        data.num = string.format("%d/%d",ch.PowerModel:getPower(),GameConst.POWER_MAX_NUMBER)
        if not USE_SPINE then
            for _, opt in ipairs(GameConst.POWER_PROGRESS_COLOR) do
                if opt.r <= data.progress then
                    data.color = opt.c
                    break
                end
            end
        end
--        if data.progress >= 1 then
--            widget:playEffect("powerFull",true)
--        else
--            widget:stopEffect("powerFull")
--            if data.progress <= 0.05 then
--                widget:playEffect("powerLess",true)
--            else
--                widget:stopEffect("powerLess")
--            end
--        end
        return data
    end,powerEffectEvent)
    
    
    widget:addDataProxy("powerTipText", function(evt)
        return string.format(GameConst.POWER_RECOVER_TIP_TEXT,GameConst.POWER_RECOVER_NUMBER)
    end)
    
    local isShowPowerTips = false
    widget:addDataProxy("isShowPowerTips", function(evt)
        return isShowPowerTips
    end)
    
    widget:addCommond("showPowerTip", function(obj,type)
        if type == ccui.TouchEventType.began then
            isShowPowerTips = true
            widget:noticeDataChange("isShowPowerTips")
        elseif type == ccui.TouchEventType.ended or type == ccui.TouchEventType.canceled then
            isShowPowerTips = false
            widget:noticeDataChange("isShowPowerTips")
        end 
    end)
    
    
    -- 以下为调�?
--    local dps = widget:createAutoNoticeData("dps")
--    local dpsRefresh
--    dpsRefresh = function()
--        dps.v = ch.NumberHelper:toString(ch.fightRoleLayer:getDps())
--        widget:setTimeOut(1, dpsRefresh)
--    end
--    dpsRefresh()
--    
--    local speed = widget:createAutoNoticeData("speedClick")
--    local speedRefresh
--    speedRefresh = function()
--        speed.v =  ch.NumberHelper:toString(ch.clickLayer:getClickSpeed())
--        widget:setTimeOut(1, speedRefresh)
--    end
--    speedRefresh()
    
    widget:addCommond("openShentan", function(evt)
        ch.UIManager:cleanGamePopupLayer(true,true)
        ch.NetworkController:altarPanel(ch.AltarModel:getCurAltarSelect())
        ch.UIManager:showGamePopup("tuteng/W_ShentanList")
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

zzy.BindManager:addCustomDataBind("MainScreen/N_BTNSkill",function(widget,data)
    local id = tonumber(data)
    local cdProgressChangedEvent = {}
    cdProgressChangedEvent[ch.RunicModel.SkillCDProgressChangedEventType] = function(evt)
        return evt.id == id
    end
    local cdStatusChangedEvent = {}
    cdStatusChangedEvent[ch.RunicModel.SkillCDStatusChangedEventType] = function(evt)
        return evt.id == id
    end
    cdStatusChangedEvent[ch.RunicModel.SkillDurationStatusChangedEventType] = function(evt)
        return evt.id == id
    end
    local canUsedChangedEvent = {}
    canUsedChangedEvent[ch.RunicModel.SkillCDStatusChangedEventType] = function(evt)
        return evt.id == id
    end
    canUsedChangedEvent[ch.RunicModel.dataChangeEventType] = false
    local durationProgressChangedEvent = {}
    durationProgressChangedEvent[ch.RunicModel.SkillDurationProgressChangedEventType] = function(evt)
        return evt.id == id
    end
    local durationStatusChangedEvent = {}
    durationStatusChangedEvent[ch.RunicModel.SkillDurationStatusChangedEventType] = function(evt)
        return evt.id == id
    end
    local runicShowEffectEvent = {}
    runicShowEffectEvent[ch.RunicModel.dataChangeEventType] = false
    local config = GameConfig.SkillConfig:getData(data)
    local maskTimer = createProgressTimer(widget,"skill_icon_mask")
    local cdTimer = createProgressTimer(widget,"Sprite_cd")
    local durTimer = createProgressTimer(widget,"Sprite_dur")
    
    widget:addDataProxy("icon", function(evt)
        return config.icon
    end)
    widget:addDataProxy("isLock", function(evt)
        return ch.RunicModel:getLevel() < ch.RunicModel:getActiveSkillUnlockLv(data)
    end,runicShowEffectEvent)
    widget:addDataProxy("isShow", function(evt)
--        return ch.RunicModel:getLevel() >= config.unlocklv
--        return ch.RunicModel:getLevel() >= ch.RunicModel:getActiveSkillUnlockLv(data)
        return true
    end,runicShowEffectEvent)
    widget:addDataProxy("isMask", function(evt)
        return ch.RunicModel:getSkillCD(id) >= 0
    end,cdStatusChangedEvent)
    widget:addDataProxy("isCd", function(evt)
        local cdLeftTime = ch.RunicModel:getSkillCD(id)
        if cdLeftTime == -1 then
            cdTimer:setPercentage(0)
            maskTimer:setPercentage(0)
            durTimer:setPercentage(0)
        end
        return ch.RunicModel:getSkillDuration(id) == -1 and cdLeftTime >= 0
    end,cdStatusChangedEvent)
    widget:addDataProxy("cdTime", function(evt)
        local time = ch.RunicModel:getSkillCD(id)
        if ch.RunicModel:getSkillDuration(id) == -1 and time ~= -1 then
            local percent = time * 100/ch.RunicModel:getSkillTotalCD(id)
            cdTimer:setPercentage(percent)
            maskTimer:setPercentage(percent)
            durTimer:setPercentage(0)
        end
        time = math.ceil(time)
        local minute = math.floor(time/60)
        local second = time%60
        return string.format("%02d:%02d",minute,second)
    end,cdProgressChangedEvent)
    widget:addDataProxy("isUsed", function(evt)--技能在被使�?
        local leftTime = ch.RunicModel:getSkillDuration(id)
        if leftTime ~= -1 then
            cdTimer:setPercentage(100)
        end
        return leftTime >= 0
    end,durationStatusChangedEvent)
    widget:addDataProxy("durationTime", function(evt)
        local time = ch.RunicModel:getSkillDuration(id)
        local percent = time * 100/ch.RunicModel:getSkillTotalDuration(id)
        time = math.ceil(time)
        durTimer:setPercentage(percent)
        maskTimer:setPercentage(percent)
        return string.format("%ds",time)
    end,durationProgressChangedEvent)
    widget:addDataProxy("canUsed", function(evt)
--        return ch.RunicModel:getLevel() >= config.unlocklv
--        return ch.RunicModel:getLevel() >= ch.RunicModel:getActiveSkillUnlockLv(data)
        return true
    end,canUsedChangedEvent)
    
    local showTip = false
    local totalCD = ch.RunicModel:getSkillTotalCD(id)
    local totalDuration = ch.RunicModel:getSkillTotalDuration(id)
    local config = GameConfig.SkillConfig:getData(id)
    widget:addDataProxy("isShowLeft", function(evt)
        return showTip and id <= 4
    end)
    widget:addDataProxy("isShowRight", function(evt)
        return showTip and id > 4
    end)
    widget:addDataProxy("leftTip1", function(evt)
        return config.desc
    end)
    widget:addDataProxy("leftTip2", function(evt)
        return string.format(Language.src_clickhero_view_ActiveSkillView_3,totalDuration,totalCD)
    end)
    widget:addDataProxy("leftTip0", function(evt)
        if ch.RunicModel:getLevel() < ch.RunicModel:getActiveSkillUnlockLv(data) then
            return string.format(Language.src_clickhero_view_ActiveSkillView_9,ch.RunicModel:getActiveSkillUnlockLv(data))
        else
            return Language.src_clickhero_view_ActiveSkillView_8
        end
    end,runicShowEffectEvent)
    widget:addDataProxy("rightTip1", function(evt)
        return config.desc
    end)
    widget:addDataProxy("rightTip2", function(evt)
        return string.format(Language.src_clickhero_view_ActiveSkillView_3,totalDuration,totalCD)
    end)
    widget:addDataProxy("rightTip0", function(evt)
        if ch.RunicModel:getLevel() < ch.RunicModel:getActiveSkillUnlockLv(data) then
            return string.format(Language.src_clickhero_view_ActiveSkillView_9,ch.RunicModel:getActiveSkillUnlockLv(data))
        else
            return Language.src_clickhero_view_ActiveSkillView_8
        end
    end,runicShowEffectEvent)

    local touchTime 
    widget:addCommond("useSkill", function(evt)
        if os_clock() - touchTime > 0.2 then return end
        if ch.LevelController.mode == ch.LevelController.GameMode.warpath then return end
        if ch.RunicModel:getLevel() < ch.RunicModel:getActiveSkillUnlockLv(data) then return end       
        if ch.RunicModel:getSkillCD(id) == -1 then
            ch.NetworkController:skillUsed(id)
        else
            --弹出清技能CD界面
            if ch.RunicModel:ifSkillCD(id) then
                ch.UIManager:showGamePopup("Shop/W_shop_cdclean")
            end
        end   
    end)
    widget:addCommond("showTip", function(obj,type)
        if type == ccui.TouchEventType.began then
            touchTime = os_clock()
            zzy.TimerUtils:setTimeOut(0.3,function()
                if touchTime then
                    showTip = true
                    local cd = ch.RunicModel:getSkillTotalCD(id)
                    local duration = ch.RunicModel:getSkillTotalDuration(id)
                    if cd~= totalCD or duration ~= totalDuration then
                        totalCD = cd
                        totalDuration = duration
                        widget:noticeDataChange("leftTip2")
                        widget:noticeDataChange("rightTip2")
                    end
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
    
    
    
    if id == ch.RunicModel.skillId.zhudongchuji then
        widget:listen(ch.RunicModel.SkillDurationStatusChangedEventType,function(obj,evt)
            if evt.id == id then
                local tmp = 0
                if ch.PartnerModel:getCurPartnerClickSpeed()>0 then
                    tmp = ch.PartnerModel:getCurPartnerClickSpeed()
                end
                if evt.statusType == ch.RunicModel.StatusType.began then
                --秒速记得加入宠物的
                    ch.clickLayer:autoClick(ch.RunicModel:getSkillEffect(id)+tmp)
                else
                    ch.clickLayer:autoClick(tmp)
                end
            end
        end)
    elseif id == ch.RunicModel.skillId.kuaidaxuanfeng then
        widget:listen(ch.RunicModel.SkillDurationStatusChangedEventType,function(obj,evt)
            if evt.id == id then
                if evt.statusType == ch.RunicModel.StatusType.began then
                    ch.fightRoleLayer:setMainRoleActionSpeed(1 + ch.RunicModel:getSkillEffect(id))
                else
                    ch.fightRoleLayer:setMainRoleActionSpeed(1)
                end
            end
        end)
    end
end)

zzy.BindManager:addFixedBind("Shop/W_shop_cdclean",function(widget)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.diamond
        return ret
    end
    widget:addCommond("clearCD", function(evt)
        if ch.RunicModel:haveSkillCD() then
            ch.NetworkController:clearAllSkillCD()
        end 
        widget:destory()
        ch.SoundManager:play("close")
    end)
    -- 花费类型控制按钮和图�?
    widget:addDataProxy("btnNormal",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[2][1]
    end)
    widget:addDataProxy("btnPressed",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[2][2]
    end)
    widget:addDataProxy("costIcon",function(evt)
        return GameConst.SHOP_COST_ICON_IMAGE[2]
    end)
    widget:addDataProxy("ifCanBuy",function(evt)
        return ch.MoneyModel:getDiamond() >= GameConst.RUNIC_CLEARCD_COST 
    end,moneyChangeEvent)
    widget:addDataProxy("costNum", function(evt)
        return GameConst.RUNIC_CLEARCD_COST
    end)
end)

zzy.BindManager:addCustomDataBind("MainScreen/W_icongroup",function(widget,data)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.star
    end
    moneyChangeEvent[ch.TaskModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.TaskModel.dataType.state
    end
    moneyChangeEvent[ch.UserTitleModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.UserTitleModel.dataType.show
    end
    moneyChangeEvent[ch.AFKModel.dataChangeEventType] = false 
    
    moneyChangeEvent[ch.FestivityModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FestivityModel.dataType.state
    end
    moneyChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.state
            or evt.dataType == ch.ChristmasModel.dataType.czxl
            or evt.dataType == ch.ChristmasModel.dataType.xhfl
            or evt.dataType == ch.ChristmasModel.dataType.open
    end
    
    moneyChangeEvent[ch.ChristmasModel.wheelChangeEventType] = false
    moneyChangeEvent[ch.ChristmasModel.redbagOpenEventType] = false
    moneyChangeEvent[ch.ChristmasModel.redbagChangeEventType] = false
    moneyChangeEvent[ch.ChristmasModel.hyggChangeEventType] = false
    moneyChangeEvent[ch.ChristmasModel.effectDataChangeEventType] = false
    moneyChangeEvent[ch.MsgModel.dataChangeEventType] = false
    moneyChangeEvent[ch.ShopModel.dataChangeEventType_GiftBag] = false
    
    local taskChangeEvent = {}
    taskChangeEvent[ch.TaskModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.TaskModel.dataType.state
    end
    taskChangeEvent[ch.AFKModel.dataChangeEventType] = false

    widget:addDataProxy("icon",function(evt)
        return GameConst.MAIN_ICON_GROUP[tonumber(data)][1]
    end)
    widget:addCommond("openWiget", function(evt)
        ch.UIManager:cleanGamePopupLayer(true)
        if tonumber(data) == 1 then
            if ch.MoneyModel:getStar()>0 then
                ch.UIManager:showGamePopup("baowu/W_BaowuStarget")
            else
                ch.UIManager:showGamePopup("baowu/W_BaowuStar")
            end
        else
			if tonumber(data) ==11 then
				local flag= string.sub(zzy.Sdk.getFlag(),1,2)
			    if flag=="WY" then 
					zzy.cUtils.openUrl("https://www.facebook.com/%E5%8D%81%E8%90%AC%E5%80%8B%E5%A4%A7%E9%AD%94%E7%8E%8B-1035807116477441")
				elseif flag=="CY" then
					zzy.cUtils.openUrl("https://www.facebook.com/tapstormtrials/")
				elseif flag=="WE" then
					zzy.cUtils.openUrl("https://business.facebook.com/Tap-Slayers-1707525762793812/?business_id=777295315711107")
				end
			elseif  tonumber(data) ==12 then
				 local extendInfo={
					f="navercafesdk",
					data={t="navercafesdk"}
				}
				zzy.Sdk.extendFunc(json.encode(extendInfo))
			elseif  tonumber(data) ==14 then
			     local paid_user=0
				 if ch.ShopModel:getTotalCharge()>0 then
					paid_user=1
				 end
				 local extendInfo={
					f="helpshift",
					data={
						paid_user=paid_user,--是否是付费用�?�? 1�?
						facebook_user="",--facebook id
						tzs=ch.ShopModel:getTotalCharge(),--充值钻石数
						first_session_date=ch.StatisticsModel._data.playTime,--首次启动游戏时间
						maxlevel=ch.StatisticsModel:getMaxLevel(),
						uin=zzy.config.loginData.userid,
						svrid_short=tonumber(string.match(ch.PlayerModel:getZoneID(), "([%d]?[%d]?[%d]?)$")),
						svrid=ch.PlayerModel:getZoneID(),
						roleid=ch.PlayerModel:getPlayerID(),
						rolename=ch.PlayerModel:getPlayerName(),
						svrname=zzy.config.svrname
					}
				}
				zzy.Sdk.extendFunc(json.encode(extendInfo))
			else
				if  tonumber(data) == 10 then -- 表示获得，需要加载图�?
					cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/aaui_png/plist_holiday.plist")
					if ch.ChristmasModel:getCurPage() == 1003 then
						ch.NetworkController:getSdxgPanel()
					else if ch.ChristmasModel:getCurPage() == 1021 then
					    ch.NetworkController:sendGloryGold()
					   end
					end
				end
				ch.UIManager:showGamePopup(GameConst.MAIN_ICON_GROUP[tonumber(data)][2])
				if tonumber(data) == 2 then
					-- 若没有任务则请求刷新
					if ch.TaskModel:isTodayRefresh() then
						ch.NetworkController:taskRefresh()
	--                    ch.UIManager:showGamePopup("task/W_Taskrefrash")
					elseif ch.StatisticsModel:getMaxLevel()>GameConst.TASK_OPEN_LEVEL and ch.TaskModel:getTodaySign() == 0 and (ch.TaskModel:getTaskNum(1)+ch.TaskModel:getTaskNum(2))>=5 then 
						ch.NetworkController:taskRefresh()
					end
				end
			end
            -- 邮件打开
            if tonumber(data) == 13 then
                if ch.MsgModel:ifShowType("2") and ch.MsgModel:getDataState(2) then
                    ch.NetworkController:msgPanel(2)
                elseif ch.MsgModel:ifShowType("3") and ch.MsgModel:getDataState(3) then
                    ch.NetworkController:msgPanel(3)
                end
                ch.UIManager:cleanGamePopupLayer(true)
                if not ch.UIManager.isTipOpen then
                    ch.UIManager.isMsgOpen = true
                    ch.UIManager:_addPopupOverMain("msg/W_Msg")
                end
            end
        end
    end)
    
    widget:addDataProxy("isTag",function(evt)
        local ifDot = false
        if tonumber(data) == 2 and ch.TaskModel:getTodaySign()>0 and ch.TaskModel:getTaskNum(2)<=0 and ch.TaskModel:getTaskNum(1)>0 then
            ifDot = true
        elseif tonumber(data) == 8 and not ch.AFKModel:getShowEffect() then
            ifDot = true
        else
            ifDot = false
        end
        iconListDotList[tonumber(data)] = ifDot
        return ifDot
    end,taskChangeEvent)
    
    widget:addDataProxy("isMask",function(evt)
        if tonumber(data) == 2 and ch.TaskModel:getTaskNum(1)+ch.TaskModel:getTaskNum(2)<=0 and ch.TaskModel:getTodaySign() >= GameConst.TASK_TOTAL_REFRESH then
            return true
        else
            return false
        end
    end,taskChangeEvent)
        
    widget:addDataProxy("ifShow",function(evt)
        iconListEffectList[tonumber(data)] = false
        if tonumber(data) == 1 and ch.MoneyModel:getStar() <= 0 then
            widget:stopEffect("playAlways")
        elseif tonumber(data) == 2 and ch.TaskModel:getTodaySign()>0 and ch.TaskModel:getTaskNum(2)<=0 then
            widget:stopEffect("playAlways")
        elseif tonumber(data) == 5 and not ch.UserTitleModel:getShowEffect() then
            widget:stopEffect("playAlways")
        elseif tonumber(data) == 6 and (ch.FestivityModel:getWeek() == 1 or ch.FestivityModel:getWeek() == 3) and ch.FestivityModel:getCurCanNum(0) <= 0 then
            widget:stopEffect("playAlways")
        elseif tonumber(data) == 7 and (ch.FestivityModel:getWeek() == 2 or ch.FestivityModel:getWeek() == 4) and ch.FestivityModel:getCurCanNum(0) <= 0 then
            widget:stopEffect("playAlways")
        elseif tonumber(data) == 8 and not ch.AFKModel:getShowEffect() then
            widget:stopEffect("playAlways")
        elseif tonumber(data) == 10 and (not (ch.ChristmasModel:getAllCan() or ch.ChristmasModel.isEffect)) then
            widget:stopEffect("playAlways")
		elseif tonumber(data) == 11  then
			 widget:stopEffect("playAlways")
		elseif tonumber(data) == 12  then
			 widget:stopEffect("playAlways")
        elseif tonumber(data) == 13 and ch.MsgModel:numNew() < 1 then
            widget:stopEffect("playAlways")
		elseif tonumber(data) == 14  then
            widget:stopEffect("playAlways")
        elseif tonumber(data) == 15 and (not ch.ShopModel:isShowGiftBagEffect()) then
            widget:stopEffect("playAlways")
        else
            widget:playEffect("playAlways",true)
            iconListEffectList[tonumber(data)] = true
        end
        return true
    end,moneyChangeEvent)
end)

-- 无尽征途战斗结算界�?
zzy.BindManager:addFixedBind("Guild/W_ELresult",function(widget)
    local gold = ch.LongDouble.zero
    local honour = 0
    widget:addDataProxy("gold",function(evt)
        gold = ch.WarpathModel:getRewardGold()
        return ch.NumberHelper:toString(gold)
    end)
    widget:addDataProxy("honour",function(evt)
        honour = ch.WarpathModel:getRewardHonour()
        return honour
    end)
    widget:addCommond("getReward", function(evt)
        widget:destory()
        ch.SoundManager:play("close")
        ch.LevelController:startNormal()
        ch.CommonFunc:showGoldRain(gold)
    end)
end)

-- 黄金大魔王战斗结算界�?
zzy.BindManager:addCustomDataBind("MainScreen/W_TBossresult",function(widget,data)
    local stayTime = 5
    local leftTime = 0
    local startCountDown = function()
        local startTime = os_clock()
        widget:listen(zzy.Events.TickEventType,function()
            leftTime = stayTime - os_clock() + startTime
            if leftTime <= 0 then
                if not data.sstoneNum then
                    ch.NetworkController:killedGoldBoss(data.victory,1,data.gold,data.totalTime,data.hp)
                end
                widget:destory()
                zzy.TimerUtils:setTimeOut(1,function()
                    if ch.LevelController.mode == ch.LevelController.GameMode.goldBoss or 
                        ch.LevelController.mode == ch.LevelController.GameMode.sStoneBoss then
                        ch.LevelController:startNormal()
                    end
                end)
            end
        end)
    end
    startCountDown()
    widget:addDataProxy("isVictory",function(evt)
        return data.victory == 1
    end)
    widget:addDataProxy("isLost",function(evt)
        return data.victory == 0
    end)
    widget:addDataProxy("gold",function(evt)
        if not data.sstoneNum then
            return ch.NumberHelper:toString(data.gold)
        else
            return ch.NumberHelper:toString(data.sstoneNum)
        end
    end)
    widget:addDataProxy("getRewardText",function(evt)
        if not data.sstoneNum then
            return Language.src_clickhero_view_ActiveSkillView_4
        else
            return Language.src_clickhero_view_ActiveSkillView_5
        end
    end)
    widget:addDataProxy("successText",function(evt)
        if not data.sstoneNum then
            return Language.src_clickhero_view_ActiveSkillView_6
        else
            return Language.src_clickhero_view_ActiveSkillView_7
        end
    end)
    widget:addDataProxy("moneyIcon",function(evt)
        if not data.sstoneNum then
            return "aaui_icon/moneyGold.png"
        else
            return "aaui_icon/moneyStone.png"
        end
    end)
    widget:addCommond("ok", function(evt)
        if not data.sstoneNum then
            ch.NetworkController:killedGoldBoss(data.victory,1,data.gold,data.totalTime,data.hp)
        end
        widget:destory()
        zzy.TimerUtils:setTimeOut(1,function()
            if ch.LevelController.mode == ch.LevelController.GameMode.goldBoss or 
                ch.LevelController.mode == ch.LevelController.GameMode.sStoneBoss then
                ch.LevelController:startNormal()
            end
        end)
    end)
end)

