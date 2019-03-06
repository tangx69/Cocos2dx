zzy.BindManager:addFixedBind("autofight/W_autofight_1",function(widget)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    
    local level,totalTime = ch.AFKModel:getAFKLevelAndTime()
    local timeSpan = ch.CommonFunc:timeToTimeSpan(totalTime)
    widget:addDataProxy("level", function(evt)
        return level
    end)
    widget:addDataProxy("hour", function(evt)
--        return timeSpan.hour
        return string.format("%02d:%02d:%02d",timeSpan.hour,timeSpan.minute,timeSpan.second)
    end)
    widget:addDataProxy("minute", function(evt)
        return timeSpan.minute
    end)
    widget:addDataProxy("second", function(evt)
        return timeSpan.second
    end)
    widget:addDataProxy("ifVip", function(evt)
        return ch.BuffModel:getCardBuffTime() > 0
    end,moneyChangeEvent)
    widget:addDataProxy("ifNoVip", function(evt)
        return ch.BuffModel:getCardBuffTime() <= 0
    end,moneyChangeEvent)
    widget:addDataProxy("buyPirce", function(evt)
        return GameConst.AUTO_FIGHT_UNCARDAFK_COST
    end)
    widget:addDataProxy("ifEnoughBuy", function(evt)
        return ch.MoneyModel:getDiamond() >= GameConst.AUTO_FIGHT_UNCARDAFK_COST
    end,moneyChangeEvent)
    
    widget:addDataProxy("desc", function(evt)
        ch.AFKModel:setShowEffect(false)
        return GameConst.AUTO_FIGHT_DESC
    end)
    
    widget:addDataProxy("okText", function(evt)
        return Language.src_clickhero_view_AFKView_1
    end)
    widget:addDataProxy("cancelText", function(evt)
        return Language.src_clickhero_view_AFKView_2
    end)
    widget:addCommond("startAFK",function()
        local buy = function()
            local type = ch.BuffModel:getCardBuffTime()>=0 and 1 or 0
            ch.NetworkController:startAFK(type)
            ch.fightRoleLayer:pause()
        end
        if ch.BuffModel:getCardBuffTime()>=0 then
            buy()
        else
            local tmp = {price = GameConst.AUTO_FIGHT_UNCARDAFK_COST,buy = buy}
            ch.ShopModel:getCostTips(tmp)
        end
--        ch.LevelController:startAFK()
--        widget:destory()
    end)
    widget:addCommond("openCardBuy",function()
        SHOP_VIEW_CARD_ID = 1
        ch.UIManager:showGamePopup("Shop/W_shop_buycard2")
    end)
    
    local goumaiTxt = zzy.CocosExtra.seekNodeByName(widget,"text_time_0")
    goumaiTxt:setString(Language.BUY_CARD_FREE_AUTOFIGHT or "")
end)

zzy.BindManager:addFixedBind("autofight/W_autofight_2",function(widget)
    local bossLevelTime = GameConst.AUTO_FIGHT_BOSS_TIME
    local commonLevelTime = ch.LevelModel:getTotalCount(1)
    local level,totalTime = ch.AFKModel:getAFKLevelAndTime()
    local timeSpan = ch.CommonFunc:timeToTimeSpan(totalTime)
    local progress = 0
    widget:addDataProxy("level", function(evt)
        return "/"..level
    end)
    widget:addDataProxy("curLevel", function(evt)
        return ch.LevelModel:getCurLevel()
    end)
    widget:addDataProxy("hour", function(evt)
--        return timeSpan.hour
        return string.format("%02d:%02d:%02d",timeSpan.hour,timeSpan.minute,timeSpan.second)
    end)
    widget:addDataProxy("minute", function(evt)
        return timeSpan.minute
    end)
    widget:addDataProxy("second", function(evt)
        return timeSpan.second
    end)
    widget:addDataProxy("progress", function(evt)
        return progress
    end)
    widget:addDataProxy("sliderImg", function(evt)
        if ch.PlayerModel:getPlayerGender() == 2 then
            return "aaui_common/bar_autofightdot_2.png"
        else
            return "aaui_common/bar_autofightdot.png"
        end
    end)
    widget:addDataProxy("stopText", function(evt)
        return Language.src_clickhero_view_AFKView_3
    end)
    widget:addDataProxy("skipLevelText", function(evt)
        return Language.src_clickhero_view_AFKView_4
    end)
    local endTime = os_clock() + totalTime
    local LevelTotalTime = ch.LevelModel:getCurLevel() %5 == 0 and bossLevelTime or commonLevelTime
    local levelEndTime = os_clock() + LevelTotalTime
    widget:listen(zzy.Events.TickEventType,function()
        local now = os_clock()
        if now < endTime then
            timeSpan = ch.CommonFunc:timeToTimeSpan(endTime - now)
            if now < levelEndTime then
                progress = 100-(levelEndTime - now)/LevelTotalTime*100
            else
                ch.LevelModel:nextLevel()
                widget:noticeDataChange("curLevel")
                LevelTotalTime = ch.LevelModel:getCurLevel() %5 == 0 and bossLevelTime or commonLevelTime
                levelEndTime = levelEndTime + LevelTotalTime
                progress = 100
                local evt = {type = ch.LevelController.GO_NEXT_LEVEL}
                zzy.EventManager:dispatch(evt)
            end
            widget:noticeDataChange("hour")
--            widget:noticeDataChange("minute")
--            widget:noticeDataChange("second")
            widget:noticeDataChange("progress")
        else
            ch.LevelModel:setCurLevel(level)
            local evt = {type = ch.LevelController.GO_NEXT_LEVEL}
            zzy.EventManager:dispatch(evt)
            ch.NetworkController:autoStopAFK()
            widget:destory()
        end
    end)
    
    widget:addCommond("skipLevel",function(widget,arg)
        local diamond = math.ceil((level - ch.LevelModel:getCurLevel())*GameConst.AUTO_FIGHT_DIAMOND_RATIO)
        diamond = diamond <= GameConst.AUTO_FIGHT_DIAMOND_MAX and diamond or GameConst.AUTO_FIGHT_DIAMOND_MAX
        ch.UIManager:showMsgBox(2,true,string.format(Language.src_clickhero_view_AFKView_5,diamond),function()
            if ch.MoneyModel:getDiamond() >= diamond then
                ch.MoneyModel:addDiamond(-diamond)
                ch.NetworkController:AFKSkipLevel(0)
                ch.LevelModel:setCurLevel(level)
                local evt = {type = ch.LevelController.GO_NEXT_LEVEL}
                zzy.EventManager:dispatch(evt)
                widget:destory()
            else
                ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
            end
        end,nil,Language.src_clickhero_view_AFKView_4,2)
    end)
    widget:addCommond("stop",function(widget,arg)
        ch.UIManager:showMsgBox(2,true,Language.src_clickhero_view_AFKView_6,function()
            widget:destory()
            ch.NetworkController:stopAFK()
        end,nil,Language.src_clickhero_view_AFKView_7,2)
    end)
    widget:playEffect("AFKEffect",true)
end)

--zzy.BindManager:addCustomDataBind("autofight/W_autofight_3",function(widget,data)
--    widget:addDataProxy("level", function(evt)
--        return data.level
--    end)
--    widget:addDataProxy("gold", function(evt)
--        return ch.NumberHelper:toString(data.reward.gold)
--    end)
--    widget:addDataProxy("stone", function(evt)
--        return data.reward.sstone
--    end)
--    local cardCount = 0
--    local chipCount = 0
--    for id,c in pairs(data.reward.card) do
--        local cid = tonumber(id)
--        if cid < 51000 then 
--            cardCount = cardCount + c
--        else
--            chipCount = chipCount + c
--        end
--    end
--    widget:addDataProxy("cardCount", function(evt)
--        return cardCount
--    end)
--    widget:addDataProxy("chipCount", function(evt)
--        return chipCount
--    end)
--    widget:addDataProxy("okText", function(evt)
--        return "确定"
--    end)
--    widget:addDataProxy("cancelText", function(evt)
--        return "取消"
--    end)
--    
--    widget:addCommond("ok",function(widget,arg)
--        ch.UIManager:cleanGamePopupLayer(true,true)
--        ch.NetworkController:stopAFK()
--    end)
--end)

zzy.BindManager:addFixedBind("autofight/W_autofight_5",function(widget)
    local data = ch.AFKModel:getLastReward()
    widget:addDataProxy("level", function(evt)
        return ch.AFKModel:getLastTargetLevel()
    end)
    widget:addDataProxy("gold", function(evt)
        return ch.NumberHelper:toString(data.gold)
    end)
    widget:addDataProxy("stone", function(evt)
        return data.sstone
    end)
    widget:addDataProxy("offGold", function(evt)
        return ch.NumberHelper:toString(data.offGold)
    end)
    widget:addDataProxy("okText", function(evt)
        return Language.MSG_BUTTON_OK
    end)
    local cardListView = widget:getChild("ListView_1")
    cardListView:setDirection(ccui.ListViewDirection.horizontalSnap)
    local chipListView = widget:getChild("ListView_2")
    chipListView:setDirection(ccui.ListViewDirection.horizontalSnap)
    local cards = {}
    local chips = {}
    for id,c in pairs(data.card) do
        local cid = tonumber(id)
        local data = {id = cid,count = c}
        if cid < 51000 then 
            table.insert(cards,data)
        else
            table.insert(chips,data)
        end
    end
    widget:addDataProxy("cards", function(evt)
        return cards
    end)
    widget:addDataProxy("chips", function(evt)
        return chips
    end)
    widget:addDataProxy("petGoldIcon", function(evt)
        return "res/icon/pets_05.png"
    end)
    widget:addDataProxy("petStoneIcon", function(evt)
        return "res/icon/pets_04.png"
    end)
    widget:addDataProxy("petGold", function(evt)
        return ch.NumberHelper:toString(data.petGold)
    end)
    widget:addDataProxy("petStone", function(evt)
        return data.petSstone
    end)
    widget:addDataProxy("ifGoldPet", function(evt)
        return ch.PartnerModel:ifHavePartner("20004")
    end)
    widget:addDataProxy("noGoldPet", function(evt)
        return not ch.PartnerModel:ifHavePartner("20004")
    end)
    widget:addDataProxy("ifStonePet", function(evt)
        return ch.PartnerModel:ifHavePartner("20006")
    end)
    widget:addDataProxy("noStonePet", function(evt)
        return not ch.PartnerModel:ifHavePartner("20006")
    end)
    widget:addCommond("ok",function(widget,arg)
        widget:destory()
        ch.AFKModel:cleanLastAFKInfo()
    end)
end)

zzy.BindManager:addCustomDataBind("autofight/W_autofight_4",function(widget,data)
    widget:addDataProxy("gold", function(evt)
        return ch.NumberHelper:toString(data.reward.gold) 
    end)
    widget:addDataProxy("stone", function(evt)
        return data.reward.sstone
    end)
    widget:addDataProxy("okText", function(evt)
        return Language.MSG_BUTTON_OK
    end)
    local cardListView = widget:getChild("ListView_1")
    cardListView:setDirection(ccui.ListViewDirection.horizontalSnap)
    local chipListView = widget:getChild("ListView_2")
    chipListView:setDirection(ccui.ListViewDirection.horizontalSnap)
    local cards = {}
    local chips = {}
    for id,c in pairs(data.reward.card) do
        local cid = tonumber(id)
        local data = {id = cid,count = c}
        if cid < 51000 then 
            table.insert(cards,data)
        else
            table.insert(chips,data)
        end
    end
    widget:addDataProxy("cards", function(evt)
        return cards
    end)
    widget:addDataProxy("chips", function(evt)
        return chips
    end)
    
    widget:addDataProxy("petGoldIcon", function(evt)
        return "res/icon/pets_05.png"
    end)
    widget:addDataProxy("petStoneIcon", function(evt)
        return "res/icon/pets_04.png"
    end)
    widget:addDataProxy("petGold", function(evt)
        return ch.NumberHelper:toString(data.reward.petGold)
    end)
    widget:addDataProxy("petStone", function(evt)
        return data.reward.petSstone
    end)
    widget:addDataProxy("ifGoldPet", function(evt)
        return ch.PartnerModel:ifHavePartner("20004")
    end)
    widget:addDataProxy("noGoldPet", function(evt)
        return not ch.PartnerModel:ifHavePartner("20004")
    end)
    widget:addDataProxy("ifStonePet", function(evt)
        return ch.PartnerModel:ifHavePartner("20006")
    end)
    widget:addDataProxy("noStonePet", function(evt)
        return not ch.PartnerModel:ifHavePartner("20006")
    end)
    
    widget:addCommond("ok",function(widget,arg)
        ch.LevelModel:setCurLevel(data.level)
        ch.NetworkController:getAFKReward()
        ch.AFKModel:setAFKing(false)
        ch.LevelController:startNormal()
        widget:destory()
    end)
end)

zzy.BindManager:addCustomDataBind("card/W_card_2",function(widget,data)
    local config = GameConfig.CardConfig:getData(data.id)
    widget:addDataProxy("icon", function(evt)
        if data.id >= 51000 then
            local tmpId = GameConfig.CardConfig:getData(data.id).enid
            return GameConfig.CardConfig:getData(tmpId).mini
        else
            return config.mini
        end
    end)
    widget:addDataProxy("isChip", function(evt)
        return data.id>=51000
    end)
    widget:addDataProxy("count", function(evt)
        return data.count
    end)
    widget:addDataProxy("name", function(evt)
        return config.name
    end)
end)

