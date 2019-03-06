local getTime = function(time)
    if time > 0 then
        local day = time /(24*3600)
        if day > 1 then
            local day = math.floor(day)
            local second = math.floor(time%60)
            time = time /60
            local minute = math.floor(time%60)
            local hour = math.floor(time/60)
            hour = math.floor(hour%24)
            return string.format(Language.src_clickhero_view_ActivityView_5,day,hour,minute,second)
        else
            local second = math.floor(time%60)
            time = time /60
            local minute = math.floor(time%60)
            local hour = math.floor(time/60)
            return string.format("%02d:%02d:%02d",hour,minute,second)
        end
    else
        return 0
    end
end

zzy.BindManager:addFixedBind("cardInstance/W_cardins",function(widget)
    local staminaEffectEvent = {}
    staminaEffectEvent[ch.CardFBModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.CardFBModel.dataType.stamina
    end
    
    widget:addDataProxy("stamina",function(evt)
        return ch.CardFBModel:getStamina().."/"..GameConst.CARD_FB_MAX_STAMINA
    end,staminaEffectEvent)
    widget:addDataProxy("leftTime",function(evt)
        local time =0
        if ch.CardFBModel:getRecoverTime() then
            time = ch.CardFBModel:getRecoverTime() - os_time()
            time = math.floor(time)
            time = time < 0 and 0 or time
        end
        local min = math.floor(time/60)
        local second = time - min *60
        return string.format("%02d:%02d",min,second)
    end)
    
    widget:addDataProxy("isShowLeftTime",function(evt)
        return ch.CardFBModel:getStamina() < GameConst.CARD_FB_MAX_STAMINA
    end,staminaEffectEvent)

    widget:addDataProxy("fbList",function(evt)
        local items = {}
        if ch.CardFBModel:getFBList() then
            for k,v in pairs(ch.CardFBModel:getFBList()) do
                table.insert(items,k)
            end
        end
        table.sort(items,function(t1,t2)
            return t1<t2
        end)
        return items
    end)
    
    widget:listen(zzy.Events.TickEventType,function()
        if ch.CardFBModel:getStamina() < 80 then
            widget:noticeDataChange("leftTime")
        end
    end)
    
    widget:addCommond("close",function()
        widget:destory()
    end)
    widget:addCommond("buyStamina",function()
        local diamond = ch.CardFBModel:getBuyCost()
        ch.UIManager:showMsgBox(2,true,string.format(GameConst.CARD_FB_BUY_TEXT,diamond,GameConst.CARD_FB_MAX_STAMINA),function()
            if ch.MoneyModel:getDiamond() >= diamond then
                ch.MoneyModel:addDiamond(-diamond)
                ch.CardFBModel:addStamina(GameConst.CARD_FB_MAX_STAMINA)
                ch.CardFBModel:addBuyCount(1)
                ch.NetworkController:cardFBBuy()
            else
                ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
            end
        end,nil,Language.MSG_BUTTON_OK,2)
    end)
    local index = 1
    widget:listen(ch.CardFBModel.cardPopOpenEventType,function(obj,evt)
        index = ch.CardFBModel:getIndexById(ch.CardFBModel.cardOpenIndex)
        widget:setTimeOut(0.2, function()
            local list = widget:getChild("ListView_1")
            local height = list:getItem(0):getContentSize().height*(index-1)
            if list:getInnerContainerSize().height > list:getContentSize().height then
                local percent = 100*height/(list:getInnerContainerSize().height -list:getContentSize().height)
                percent = percent > 100 and 100 or percent
                list:requestDoLayout()
                list:jumpToPercentVertical(percent)
            end
        end)
    end)
end)


zzy.BindManager:addCustomDataBind("cardInstance/W_CardPop",function(widget,data)
    local LevelChangedEvent = {}
    LevelChangedEvent[ch.CardFBModel.FBChangeEventType] = function(evt)
    	return (evt.id == data or evt.id == nil) and evt.dataType == ch.CardFBModel.dataType.FBLevel
    end
    local countChangedEvent = {}
    countChangedEvent[ch.CardFBModel.FBChangeEventType] = function(evt)
        return (evt.id == data or evt.id == nil) and (evt.dataType == ch.CardFBModel.dataType.fightCount or
            evt.dataType == ch.CardFBModel.dataType.resetCount)
    end
    
    local canFightEvent = {}
    canFightEvent[ch.CardFBModel.FBChangeEventType] = function(evt)
        return (evt.id == data or evt.id == nil) and (evt.dataType == ch.CardFBModel.dataType.fightCount or
            evt.dataType == ch.CardFBModel.dataType.resetCount)
    end
    canFightEvent[ch.CardFBModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.CardFBModel.dataType.stamina
    end
    
    local doubleChangedEvent = {}
    doubleChangedEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.open
            or evt.dataType == ch.ChristmasModel.dataType.stop
            or evt.dataType == ch.ChristmasModel.dataType.nextday
    end
    
--    widget:addDataProxy("fightButtonText",function(evt)
--        return string.format(GameConst.CARD_FB_FIGHT_BUTTON_TEXT,ch.CardFBModel:getFBLevelName(data)) 
--    end)
    
    widget:addDataProxy("levelName",function(evt)
        return ch.CardFBModel:getFBLevelName(data)
    end) --
    widget:addDataProxy("leftTimes",function(evt)
        local leftTimes = GameConst.CARD_FB_MAX_FIGHT_COUNT - ch.CardFBModel:getFightCount(data)
        return string.format(GameConst.CARD_FB_LEFT_TIMES,leftTimes,GameConst.CARD_FB_MAX_FIGHT_COUNT)
    end,countChangedEvent)
    widget:addDataProxy("staminaCost",function(evt)
        local cost = ch.CardFBModel:getStaminaCost(data)
        return string.format(GameConst.CARD_FB_STAMINA_COST,cost)
    end)
    widget:addDataProxy("fightText",function(evt)
        local level = ch.CardFBModel:getFBLevel(data)
        if level <= #GameConst.CARD_FB_LEVLE_NAME then
            local boxId = GameConfig.CardFBConfig:getData(data,level).boxId
            local numStr = GameConfig.BoxConfig:getData(tonumber(boxId.."001")).num1
            local num = tonumber(zzy.StringUtils:split(numStr,"|")[1])
            -- 开启双倍活动
            if ch.ChristmasModel:isOpenByType(1008) then
                num = num*ch.ChristmasModel:getHDataByType(1008).ratio
            elseif ch.ChristmasModel:isDoubleCard(data).isDouble then
                num = num*ch.ChristmasModel:isDoubleCard(data).ratio
            end
            return string.format(GameConst.CARD_FB_FIGHT_TEXT ,ch.CardFBModel:getFBLevelName(data),num)
        end
        return ""
    end,doubleChangedEvent) --
    widget:addDataProxy("fetchText",function(evt)
        local level = ch.CardFBModel:getFBLevel(data) - 1
        if level >= 1 and level <= #GameConst.CARD_FB_LEVLE_NAME then
            local boxId = GameConfig.CardFBConfig:getData(data,level).boxId
            local numStr = GameConfig.BoxConfig:getData(tonumber(boxId.."001")).num1
            local num = tonumber(zzy.StringUtils:split(numStr,"|")[1])
            -- 开启双倍活动
            if ch.ChristmasModel:isOpenByType(1008) then
                num = num*ch.ChristmasModel:getHDataByType(1008).ratio
            elseif ch.ChristmasModel:isDoubleCard(data).isDouble then
                num = num*ch.ChristmasModel:isDoubleCard(data).ratio 
            end
            return string.format(GameConst.CARD_FB_FETCH_TEXT,num)
        end
        return ""
    end,doubleChangedEvent)--
    widget:addDataProxy("isDouble",function(evt)
        -- 开启双倍活动
        if ch.ChristmasModel:isOpenByType(1008) then
            return true
        elseif ch.ChristmasModel:isDoubleCard(data).isDouble then
            return true
        end
        return false
    end,doubleChangedEvent)
    widget:addDataProxy("showFightButton",function(evt)
        local level = ch.CardFBModel:getFBLevel(data)
        return level <= #GameConst.CARD_FB_LEVLE_NAME and level>1
    end)
    widget:addDataProxy("showFightText",function(evt)
        return ch.CardFBModel:getFBLevel(data) <= #GameConst.CARD_FB_LEVLE_NAME
    end)
    widget:addDataProxy("showFirstFight",function(evt)
        return ch.CardFBModel:getFBLevel(data) == 1
    end)
    widget:addDataProxy("showFetchText",function(evt)
        return ch.CardFBModel:getFBLevel(data) > 1
    end)
    widget:addDataProxy("showFightComplete",function(evt)
        return ch.CardFBModel:getFBLevel(data) > #GameConst.CARD_FB_LEVLE_NAME
    end)
    widget:addDataProxy("canFight",function(evt)
        local cost = ch.CardFBModel:getStaminaCost(data)
        local leftTimes = GameConst.CARD_FB_MAX_FIGHT_COUNT - ch.CardFBModel:getFightCount(data)
        return ch.CardFBModel:getStamina()>= cost and leftTimes > 0
    end,canFightEvent)
    widget:addDataProxy("canFetch",function(evt)
        local cost = ch.CardFBModel:getStaminaCost(data)
        local leftTimes = GameConst.CARD_FB_MAX_FIGHT_COUNT - ch.CardFBModel:getFightCount(data)
        return ch.CardFBModel:getStamina()>= cost and leftTimes > 0 and ch.CardFBModel:getFBLevel(data) > 1
    end,canFightEvent)
    widget:addDataProxy("canBuy",function(evt)
        local leftTimes = GameConst.CARD_FB_MAX_FIGHT_COUNT - ch.CardFBModel:getFightCount(data)
        return leftTimes == 0
    end,countChangedEvent)
    widget:addDataProxy("icon",function(evt)
        return GameConfig.CardConfig:getData(data).mini
    end)
    widget:addDataProxy("frame",function(evt)
        return ch.CardFBModel:getFBLevelFrame(data)
    end)
    widget:addDataProxy("name",function(evt)
        return GameConfig.CardFBConfig:getData(data,1).name
    end)
    widget:addCommond("fight",function()
        local level = ch.CardFBModel:getFBLevel(data)
        if level > #GameConst.CARD_FB_LEVLE_NAME then
            level = #GameConst.CARD_FB_LEVLE_NAME
        end
        local conf = GameConfig.CardFBConfig:getData(data,level)
        local fd = {type=5,fbId = data,userId = 0,person = 1,rank = "---"}
        fd.maxLevel = conf.maxLevel
        fd.name = conf.name
        fd.cardList = {}
        for i = 1,5 do
            if conf["card"..i] > 0 then
                local t = {id=conf["card"..i],l= conf["level"..i],talent=GameConfig.CardConfig:getData(conf["card"..i]).talent,vis = true}
                table.insert(fd.cardList,t) 
            end
        end
        ch.UIManager:showGamePopup("card/W_card_chakan",fd)
        -- 定位
        ch.CardFBModel.cardOpenIndex = data
    end)
    widget:addCommond("fetch",function()
        local cost = ch.CardFBModel:getStaminaCost(data)
        ch.CardFBModel:addStamina(-cost)
        ch.CardFBModel:addFightCount(data,1)
        ch.NetworkController:cardFBFetch(data)
    end)
    widget:addCommond("buy",function() -- 重置fb次数
        local diamond = ch.CardFBModel:getResetCost(data)
        ch.UIManager:showMsgBox(2,true,string.format(GameConst.CARD_FB_RESET_TEXT,diamond),function()
            if ch.MoneyModel:getDiamond() >= diamond then
                ch.MoneyModel:addDiamond(-diamond)
                ch.CardFBModel:addResetCount(data,1)
                ch.NetworkController:cardFBReset(data)
            else
                ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
            end
        end,nil,Language.MSG_BUTTON_OK,2)
    end)
    
    widget:addDataProxy("talentImg",function(evt)
        return GameConst.CARD_TALENT_IMAGE[ch.PetCardModel:getTalent(data)]
    end)
    widget:addCommond("openDetail",function()
        ch.UIManager:showGamePopup("card/W_card_detaillist",data)
    end)
end)

zzy.BindManager:addFixedBind("cardInstance/W_Result",function(widget)
    local item = ch.CardFBModel:getReward()
    widget:addDataProxy("number",function(evt)
        if item then
            local name = GameConfig.CardConfig:getData(item.chipId).name
            return string.format(GameConst.CARD_FB_GET_REWARD_TEXT,name,item.num) 
        end
    end)
    widget:addDataProxy("title",function(evt)
        if item then
            return GameConst.CARD_FB_GET_TITLE_TEXT[item.type]
        end
    end)
    widget:addDataProxy("levelName",function(evt)
        if item and item.type == 1 then
            local level = ch.CardFBModel:getFBLevel(item.id) - 1
            local max = #GameConst.CARD_FB_LEVLE_NAME
            level = level > max and max or level
            return GameConst.CARD_FB_LEVLE_NAME[level]
        end
    end)
    widget:addDataProxy("showLevelName",function(evt)
        if item then
            return item.type == 1
        end
        return false
    end)
    widget:addDataProxy("isDouble",function(evt)
        if item then
           local level = ch.CardFBModel:getFBLevel(item.id) - 1
            if level >= 1 and level <= #GameConst.CARD_FB_LEVLE_NAME then
                local boxId = GameConfig.CardFBConfig:getData(item.id,level).boxId
                local numStr = GameConfig.BoxConfig:getData(tonumber(boxId.."001")).num1
                local num = tonumber(zzy.StringUtils:split(numStr,"|")[1])
                -- 开启双倍活动
                if ch.ChristmasModel:isOpenByType(1008) then
                    return item.num/(num*ch.ChristmasModel:getHDataByType(1008).ratio) == 2
                elseif ch.ChristmasModel:isDoubleCard(item.id).isDouble then
                    return item.num/(num*ch.ChristmasModel:isDoubleCard(item.id).ratio) == 2
                else
                    return item.num/num == 2 
                end
            end
        end
        return false
    end)
    widget:addCommond("ok",function()
        widget:destory()
    end)
    ch.CardFBModel:setReward(nil)
end)

zzy.BindManager:addCustomDataBind("cardInstance/W_ActivityCard",function(widget,data) -- 1为魔宠副本，2为领取体力
    local staminaEffevt = {}
    staminaEffevt[ch.CardFBModel.dataChangeEventType] =function(evt)
        return evt.dataType == ch.CardFBModel.dataType.fetchStamina
    end
    
    local dotChangeEvent = {}
    dotChangeEvent[ch.CardFBModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.CardFBModel.dataType.fetchStamina
    end
    
    widget:addDataProxy("title",function(evt)
        return GameConst.CARD_FB_ACT_TITLE[data]
    end)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("desc")
        widget:noticeDataChange("canTouch")
        widget:setTimeOut(1,cutDown)
    end
--    if data == 2 then
        cutDown()
--    end

    widget:addDataProxy("desc",function(evt)
        if data == 1 then
            return GameConst.CARD_FB_ACT_DESC[data]
        else
            local num = GameConst.CARD_FB_FREE_TL
            if ch.ChristmasModel:isOpenByType(1010) then
                num = GameConst.CARD_FB_FREE_TL * ch.ChristmasModel:getHDataByType(1010).ratio
            end
            if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" then
                local str = string.format(Language.CARD_FB_ACT_DESC_EN[3],3-ch.CardFBModel:getLQNum(1),3)
                str = str .. "\n"
--                if ch.CardFBModel:canFetched() then
                if ch.CardFBModel:getLQNum(1) < 3 then
                    if ch.CardFBModel:getCDTime() < 1 then
                        str = str..string.format(Language.CARD_FB_ACT_DESC_EN[1],num)
                    else
                        str = str..Language.CARD_FB_ACT_DESC_EN[4]..getTime(ch.CardFBModel:getCDTime())
                    end
                else
                    str = str..Language.CARD_FB_ACT_DESC_EN[2]
                end
                return str
            else
                return string.format(GameConst.CARD_FB_ACT_DESC[data],
                    GameConst.FORMAT_NUM_TO_TIME(GameConst.CARD_FB_TL_TIME[1].startTime),
                    GameConst.FORMAT_NUM_TO_TIME(GameConst.CARD_FB_TL_TIME[1].endTime),
                    GameConst.FORMAT_NUM_TO_TIME(GameConst.CARD_FB_TL_TIME[2].startTime),
                    GameConst.FORMAT_NUM_TO_TIME(GameConst.CARD_FB_TL_TIME[2].endTime),
                    GameConst.FORMAT_NUM_TO_TIME(GameConst.CARD_FB_TL_TIME[3].startTime),
                    GameConst.FORMAT_NUM_TO_TIME(GameConst.CARD_FB_TL_TIME[3].endTime)) .. 
                    string.format(Language.src_clickhero_view_CardFBView_1,num)
            end
        end
    end)
    widget:addDataProxy("icon",function(evt)
        return data == 1 and "aaui_icon/card_fb_icon.png" or "aaui_icon/card_tl_icon.png"
    end)
    widget:addDataProxy("btnText",function(evt)
        return GameConst.CARD_FB_ACT_BTNTEXT[data]
    end)
    widget:addDataProxy("canTouch",function(evt)
        if data == 1 then
            return true
        else
            return ch.CardFBModel:canFetched()
        end
    end,staminaEffevt)
    widget:addDataProxy("isTag",function(evt)
        if data == 1 then
            return ch.SignModel:getRedPointByType(3)
        elseif data == 2 then
            return ch.SignModel:getRedPointByType(4)
        end
        return false
    end,dotChangeEvent)
    widget:addCommond("fight",function()
        if data == 1 then
            ch.UIManager:showGamePopup("cardInstance/W_cardins",nil,nil,nil,"cardInstance/W_cardins")
            --结束引导
            if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10330 then
                ch.guide:endid(10330)
            end
        else
            ch.NetworkController:cardFBFetchStamina()
        end
    end)
end)
