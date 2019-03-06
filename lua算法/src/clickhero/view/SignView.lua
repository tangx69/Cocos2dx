-- 签到界面
zzy.BindManager:addFixedBind("task/W_sign",function(widget)
    local moneyType = {ch.MoneyModel.dataType.diamond,ch.MoneyModel.dataType.gold,
        ch.MoneyModel.dataType.sStone,ch.MoneyModel.dataType.star} -- 签到对应的奖励类型
    local statusEffectEvent = {}
    statusEffectEvent[ch.SignModel.dataChangeEventType] = false
    statusEffectEvent[ch.FirstSignModel.dataChangeEventType] = false
    
    local rewartEffectEvent = {}
    rewartEffectEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    widget:addDataProxy("status", function(evt)
        local status = {}
        if ch.FirstSignModel:isFirstSign() then
            status.signed = ch.FirstSignModel:getSignStatus()== 2
            status.noSigned = not status.signed
        else
            status.signed = ch.SignModel:getSignStatus()==1
            status.noSigned = not status.signed
        end
        return status
    end,statusEffectEvent)
    widget:addCommond("getReward",function()
        -- 签到类型
        local type = ch.FirstSignModel:getSignType()
        local sc = {}
        if type == 1 then
            sc = GameConfig.SignConfig:getData(type,ch.FirstSignModel:getSignDays())
            ch.NetworkController:firstSign(sc.rewardType,sc.rewardId,sc.rewardValue)
        else
            sc = GameConfig.SignConfig:getData(type,ch.SignModel:getSignDays() + 1)
            ch.NetworkController:sign(sc.rewardType,sc.rewardId,sc.rewardValue)
        end
    end)
end)
-- 签到单元
zzy.BindManager:addCustomDataBind("task/W_signunit",function(widget,data)
    local id = tonumber(data)
    local statusEffectEvent = {}
    statusEffectEvent[ch.SignModel.dataChangeEventType] = false
    statusEffectEvent[ch.FirstSignModel.dataChangeEventType] = false
    local rewartEffectEvent = {}
    rewartEffectEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    rewartEffectEvent[ch.SignModel.dataChangeEventType] = false
    rewartEffectEvent[ch.FirstSignModel.dataChangeEventType] = false
    
    local type = ch.FirstSignModel:getSignType()

    widget:addDataProxy("status", function(evt)
        local status = {}
        type = ch.FirstSignModel:getSignType()
        if type == 1 then
            status.signed = ch.FirstSignModel:getSignStatus(id) == 2 or ch.FirstSignModel:getSignStatus(id) == 0
            status.noSigned = not status.signed
            if ch.FirstSignModel:getSignStatus(id) == 0 then
                status.miss = "aaui_common/state_out.png"
            else
                status.miss = "aaui_common/ui_common_fragment_tag.png"
            end
            if id == ch.FirstSignModel:getSignDays() and ch.FirstSignModel:getSignStatus(id) == 1 then
                widget:playEffect("signUnitEffect",true)
            else
                widget:stopEffect("signUnitEffect")
            end
        else
            status.signed = ch.SignModel:getSignDays() >= id
            status.noSigned = not status.signed
            status.miss = "aaui_common/ui_common_fragment_tag.png"
            if ch.SignModel:getSignStatus()==ch.SignModel.status.noSigned and id == ch.SignModel:getSignDays() + 1 then
                widget:playEffect("signUnitEffect",true)
            else
                widget:stopEffect("signUnitEffect")
            end
        end
        return status
    end,statusEffectEvent)
    widget:addDataProxy("isMask", function(evt)
        local isMask = false
        if type == 1 then
            isMask = ch.FirstSignModel:getSignStatus(id) == 0
--        else
--            if id > ch.SignModel:getSignDays() + 1 then
--                isMask = true
--            elseif id == ch.SignModel:getSignDays() + 1 then
--                isMask = ch.SignModel:getSignStatus() == ch.SignModel.status.signed
--            end
        end
        return isMask
    end,statusEffectEvent)
    widget:addDataProxy("rewardIcon", function(evt)
--        return ch.SignModel:getRewardIcon(type,id)
        local tmpData = GameConfig.SignConfig:getData(type,id)
        return ch.CommonFunc:getRewardIcon(tmpData.rewardType,tmpData.rewardId)
    end,statusEffectEvent)
    widget:addDataProxy("icon", function(evt)
        return GameConfig.SignConfig:getData(type,id).icon
    end,statusEffectEvent)
    widget:addDataProxy("isGold",function(evt)
        return GameConfig.SignConfig:getData(type,id).rewardType == 4
    end,statusEffectEvent)
    widget:addDataProxy("isNoGold",function(evt)
        return GameConfig.SignConfig:getData(type,id).rewardType ~= 4
    end,statusEffectEvent)    
    widget:addDataProxy("money", function(evt)
--        return ch.SignModel:getRewardValue(type,id)
        local tmpData = GameConfig.SignConfig:getData(type,id)
        return ch.CommonFunc:getRewardValue(tmpData.rewardType,tmpData.rewardId,tmpData.rewardValue)
    end,rewartEffectEvent)
end)


-- 每日限购界面
zzy.BindManager:addFixedBind("activity/W_meirixg",function(widget)
    local buyLimitChangeEvent = {}
    buyLimitChangeEvent[ch.BuyLimitModel.dataChangeEventType] = false
    buyLimitChangeEvent[ch.LevelModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    
    widget:addDataProxy("title", function(evt)
        return Language.src_clickhero_view_SignView_1
    end)
    widget:addDataProxy("name", function(evt)
        return ch.BuyLimitModel:getName(1)
    end,buyLimitChangeEvent)
    widget:addDataProxy("desc", function(evt)
        local tmpData = ch.BuyLimitModel:getTodayData(1)
        local desc = string.format(tmpData.desc,ch.CommonFunc:getRewardName(tmpData.rewardType,tmpData.rewardId))
        return desc.."\n"..string.format(Language.src_clickhero_view_SignView_2,ch.BuyLimitModel:getTodayData(1).max-ch.BuyLimitModel:getCountByIndex(1))
    end,buyLimitChangeEvent)
    widget:addDataProxy("icon", function(evt)
        return ch.BuyLimitModel:getTodayData(1).icon
    end,buyLimitChangeEvent)
    widget:addDataProxy("lastTime", function(evt)
--        return string.format("本期惊喜限购剩余 %d 天",ch.BuyLimitModel:getLastDay())
        return ch.BuyLimitModel:getLastDay()
    end,buyLimitChangeEvent)
    
    local cutDown
    cutDown =  function()

        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("time", function(evt)
        local time = ch.BuyLimitModel:getRefreshTime()
        return string.format("%02d:%02d:%02d",time.hour,time.minute,time.second)
    end)
    
    widget:addDataProxy("changeDesc", function(evt)
        if ch.BuyLimitModel:getLastDay() > 1 then
            return Language.src_clickhero_view_SignView_5
        else
            return Language.src_clickhero_view_SignView_6
        end
    end,buyLimitChangeEvent)
    
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[2][1]
    end)
    widget:addDataProxy("btnPressed",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[2][2]
    end)
    widget:addDataProxy("costIcon",function(evt)
        return GameConst.SHOP_COST_ICON_IMAGE[2]
    end)
    widget:addDataProxy("costNum",function(evt)
        return ch.BuyLimitModel:getTodayData(1).price
    end,buyLimitChangeEvent)
    
    widget:addDataProxy("diamondEnough", function(evt)
        return ch.MoneyModel:getDiamond() >= ch.BuyLimitModel:getTodayData(1).price
    end,buyLimitChangeEvent)
    widget:addDataProxy("ifCanBuy", function(evt)
        return ch.BuyLimitModel:getCountByIndex(1) < ch.BuyLimitModel:getTodayData(1).max
    end,buyLimitChangeEvent)
    
    widget:addCommond("buy",function()
        local buy = function()
            cclog("购买")
            ch.NetworkController:buyLimitBuyOne(ch.BuyLimitModel:getDay(),1)
            ch.CommonFunc:addItems({{id=ch.BuyLimitModel:getTodayData(1).rewardId,t=ch.BuyLimitModel:getTodayData(1).rewardType,num=ch.BuyLimitModel:getTodayData(1).rewardValue}})
            ch.BuyLimitModel:addCountByIndex(1,1)
        end
        local tmp = {price = ch.BuyLimitModel:getTodayData(1).price,buy = buy}
        ch.ShopModel:getCostTips(tmp)        
    end) 
end)

-- 广告页
zzy.BindManager:addCustomDataBind("msg/W_ad",function(widget,data)
    widget:addDataProxy("img", function(evt)
        return GameConst.OPEN_AD_IMAGE[data]
    end)

    widget:addCommond("close",function()
        widget:destory()
    end) 
end)


-- 新手突破10关弹的限时购买界面
zzy.BindManager:addFixedBind("activity/W_Novice",function(widget)
    
    ch.ShopModel:showGiftBagEffect(false)--打开界面即停止转圈
    
    widget:addCommond("close", function()
        widget:destory()
    end)
    
    widget:addCommond("buy",function()
        if  tonumber(ch.ShopModel:getGiftBagTime()) <= os_time() then
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController_2,function()
                widget:destory()
            end)
        else
            if ch.MoneyModel:getDiamond() >= GameConst.LEVEL10_GIFT_BAG.currentPrice then
                local buy = function()
                    widget:destory()
                    ch.NetworkController:buyGiftBag()
                end
                local tmp = {price = GameConst.LEVEL10_GIFT_BAG.currentPrice, buy = buy}
                ch.ShopModel:getCostTips(tmp)
            else
                ch.UIManager:showMsgBox(2,true,Language.MSG_UNENOUGH_PAYCOIN,function()
                    ch.UIManager:cleanGamePopupLayer(true)
                    ch.UIManager:showBottomPopup("Shop/W_shop")
                end,nil,Language.MSG_BUTTON_GOTO_SHOP,2)
            end
        end
    end)
    
    widget:addDataProxy("currentPrice", function(evt)
        return "" .. GameConst.LEVEL10_GIFT_BAG.currentPrice
    end)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    
    widget:addDataProxy("time", function(evt)
        local time = tonumber(ch.ShopModel:getGiftBagTime()) - os_time()
        time = time > 0 and time or 0
        return ch.NumberHelper:cdTimeToString(time)
    end)
    widget:addDataProxy("text", function(evt)
        return Language.LEVEL10_GIFT_BAG_TIPS
    end)
    widget:addDataProxy("originalPrice", function(evt)
        return Language.LEVEL10_GIFT_BAG_PRICE .. GameConst.LEVEL10_GIFT_BAG.originalPrice
    end)
    widget:addDataProxy("list",function(evt)
        local items = {}
        for k,v in ipairs(GameConst.LEVEL10_GIFT_BAG.items) do
            table.insert(items,{index=k,value=v})
        end
        return items 
    end)

end)

-- 新手突破10关可购买项目
zzy.BindManager:addCustomDataBind("activity/N_Novice_1",function(widget,data)

    local item = data.value
    
    widget:addDataProxy("icon", function(evt)
        return GameConst.LEVEL10_GIFT_BAG.icon[tonumber(data.index)] or ch.CommonFunc:getRewardBigIcon(item.t, item.id)
    end)
    widget:addDataProxy("name", function(evt)
        return ch.CommonFunc:getRewardName(item.t, item.id)
    end)
    widget:addDataProxy("describe", function(evt)
        return Language.ITEMS_DESC_TIPS["g" .. item.id]
    end)
end)