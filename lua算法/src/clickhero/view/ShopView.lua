-- 商城
local minGold = 10
local heightItem = 0
local cardID = 1

local getTime = function(time)
    if time > 0 then
        local day = time /(24*3600)
        if day > 1 then
            return string.format(Language.src_clickhero_view_ShopView_1,math.floor(day))
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

local costType = function(type,price,config)
    if type == 1 then
        ch.NetworkController:charge(config.itemId,config.name,1,config.price,config.oldPrice,config.reward,config)
        cclog("扣人民币")
    elseif type == 2 then
        ch.MoneyModel:addDiamond(price)
    elseif type == 3 then
        ch.MoneyModel:addHonour(price)
    else
        cclog("类型不对")
    end
end

local ifCanBuy = function(type,price)
    if type == 1 then
        return true
    elseif type == 2 then
        return ch.MoneyModel:getDiamond() >= price
    elseif type == 3 then
        return ch.MoneyModel:getHonour() >= price
    else
        cclog("类型不对")
        return false
    end
end
-- 普通商店界面
zzy.BindManager:addFixedBind("Shop/W_shop", function(widget)
    local shopOpenEvent = {}
    shopOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
        return evt.view == "Shop/W_shop"
    end
    local diamondChangeEvent = {}
    diamondChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    local getPartnerEvent = {}
    getPartnerEvent[ch.PartnerModel.czChangeEventType] = function(evt)
        return evt.dataType == ch.PartnerModel.dataType.get
    end
    getPartnerEvent[ch.ShopModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ShopModel.dataType.firstPay
    end
    
    widget:addDataProxy("listHeight", function(evt)
        if evt then
            if evt.popType == ch.UIManager.popType.HalfOpen then
                return GameConst.MAINVIEW_OPEN_LISTVIEW_HEIGHT[1] 
            else
                return GameConst.MAINVIEW_OPEN_LISTVIEW_HEIGHT[2]
            end
        else
            return GameConst.MAINVIEW_OPEN_LISTVIEW_HEIGHT[1]
        end
    end,shopOpenEvent)
    -- 上按钮可见
    widget:addDataProxy("upVisible", function(evt)
        if evt then
            return evt.popType == ch.UIManager.popType.HalfOpen
        else
            return true
        end
    end,shopOpenEvent)
    -- 下按钮可见
    widget:addDataProxy("downVisible", function(evt)
        if evt then
            return evt.popType ~= ch.UIManager.popType.HalfOpen
        else
            return false
        end
    end,shopOpenEvent)
    widget:addDataProxy("items", function(evt)
        local items = {}
		local curFlag=zzy.Sdk.getFlag()..zzy.config.subpack
		--local flag= string.sub(zzy.Sdk.getFlag(),1,2)
		--if flag~="WY" and flag~="TJ" and flag~="CY"  and flag~="WE" and zzy.Sdk.getFlag()~="HDIOS" and zzy.Sdk.getFlag()~="HDXGS" then
        if "ANYSDK" == curFlag or "YIJIE" == curFlag or "DEFAULT" == curFlag then
			curFlag="DEFAULT" --tgx 这里curFlag = "1", 决定了取哪个渠道的商品id
		end
        
        local packageName = zzy.cUtils.getPackageName()
        if packageName == "com.funyou.bxxy" or packageName == "com.funyou.gjyxy2" then
            curFlag = "DEFAULT_1"
        end

        if USE_SPINE then
            curFlag = "DEFAULT_SG"
        end
        
        INFO("curFlag = "..curFlag)
        for k,v in pairs(GameConfig.ShopConfig:getTable()) do
            if v.channelId == curFlag and v.shopType == 1 then
                if (IS_IN_REVIEW and tonumber(v.check) == 1) or ((not IS_IN_REVIEW) and v.index == 12)  then --IOS审核不显示v.check == 1的商品

                else
                    table.insert(items,v)
                end
            end
        end
        table.sort(items,function(t1,t2)
            if t1.index == 22 or t1.index == 23 then --tgx
                t1.index = 1 + t1.index / 100
            end
            
            if t2.index == 22 or t2.index == 23 then
                t2.index = 1 + t2.index / 100
            end
            
            return t1.index < t2.index
        end)
        local ret = {}
        heightItem = 1
        if ch.ShopModel:getfirstPay() ~= 2 then
            table.insert(ret,{index = 6,value = {},isMultiple = true})
        else
            table.insert(ret,{index = 7,value = 1,isMultiple = true})    
        end
       -- if flag=="WY" and  cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_IPHONE 
		--	and cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_IPAD and ch.StatisticsModel:getMaxLevel()>70   then
		  --   table.insert(ret,{index = 8, value = {},isMultiple = true})
            -- heightItem =heightItem+ 1
		--end
        local isRMB = true
        for k,v in ipairs(items) do
            --local templetId = v.id < 4 and v.id or 4
            --table.insert(ret,{index =templetId, value = v.id,isMultiple = true})
            if v.type_get == 4 then
                isRMB = false
            end
            if isRMB then
                heightItem = heightItem + 1
            end
            local isIn = true
            if v.type_get == 5 and ch.PartnerModel:ifHavePartner(tostring(v.reward)) then
                isIn = false
            end
            if isIn then
                table.insert(ret,{index = tonumber(v.type_get), value = v.id,isMultiple = true})
            end
            
        end
        return ret
    end, getPartnerEvent)
    widget:addDataProxy("diamond-num", function(evt)
        return ch.MoneyModel:getDiamond()
    end,diamondChangeEvent)
    widget:addScrollData("diamond-num", "title", 1, function(v)
        return tostring(math.floor(v))
    end,"N_MoneyDiamonds:num_Diamond")
    
    widget:listen(ch.PlayerModel.payOpenShopEventType,function(obj,evt)
        widget:setTimeOut(0.1, function()
            local list = widget:getChild("ListView_1")
            local height = 0
            for i=1,heightItem do
                height = height + list:getItem(i-1):getContentSize().height
            end
            local percent = 100*height/(list:getInnerContainerSize().height -list:getContentSize().height)
            list:scrollToPercentVertical(percent,0.1,true)
        end)
    end)
end)


zzy.BindManager:addCustomDataBind("Shop/W_shop_buycard",function(widget,data)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.diamond or evt.dataType == ch.MoneyModel.dataType.honour
        return ret
    end
    cardID = data
    local config = GameConfig.ShopConfig:getData(data)
    widget:addDataProxy("icon", function(evt)
        return config.icon        
    end)
    widget:addDataProxy("name", function(evt)
        return config.name
    end)
    widget:addDataProxy("isHot",function(evt)
        return config.type == 1
    end)
    widget:addDataProxy("isNew",function(evt)
        return config.type == 2
    end)
    
    widget:addDataProxy("desc",function(evt)
        return string.format(GameConst.SHOP_BUY_YUEKA_DESC[1],config.reward/24)
    end)
    
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][1]
    end)
    widget:addDataProxy("btnPressed",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][2]
    end)
    widget:addDataProxy("costIcon",function(evt)
        local icon = GameConst.SHOP_COST_ICON_IMAGE[config.type_cost]
        if icon == "res/icon/dot1.png" then
            local iconImg = zzy.CocosExtra.seekNodeByName(widget, "btn_icon")
            iconImg:setVisible(false)
        end
        return icon
    end)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("leftTime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    widget:addDataProxy("leftTime", function(evt)
        return getTime(ch.BuffModel:getCardBuffTime(config.type_item))
    end)
    widget:addDataProxy("ifCanBuy",function(evt)
        return ifCanBuy(config.type_cost,config.price)
    end,moneyChangeEvent)
    widget:addDataProxy("price", function(evt)
        if config.type_cost==1 then
            return config.price.."    "..ch.CommonFunc:getCoinName()
        else
            return string.format("-%d",config.price)
        end
    end)
    widget:addCommond("openCard",function()
        cardID = config.id
        ch.UIManager:showGamePopup("Shop/W_shop_buycard2")
    end)
    widget:addCommond("buy",function()
        local buy = function()
            ch.NetworkController:shopBuy(data)
            costType(config.type_cost,-config.price,config)
            ch.BuffModel:addCardBuff(config.reward*3600)
            ch.UIManager:showMsgBox(1,true,string.format(Language.src_clickhero_view_ShopView_3,config.reward/24),nil,nil,Language.MSG_BUTTON_HUMOROK)
            if config.tip_type and config.tip_type == 2 then
                ch.UIManager:showNotice(config.tip_desc)
            end
        end
        
        if config.type_cost==1 then
            buy = function()
                costType(config.type_cost,-config.price,config)
                if config.tip_type and config.tip_type == 2 then
                    ch.UIManager:showNotice(config.tip_desc)
                end
            end
        end
        
        if ch.BuffModel:getCardBuffTime(config.type_item) > 0 then
            ch.UIManager:showMsgBox(2,true,GameConst.SHOP_YUEKA_TIP,function()
--                if not ch.ShopModel:getSelectState() and config.type_cost == 2 then
                if config.type_cost == 2 then
                    ch.UIManager:showGamePopup("Shop/W_shop_confirm",{name = config.name,price=config.price,buy=buy})
                else
                    buy()
                end
            end,nil,Language.MSG_BUTTON_OK,2)
        else
--            if not ch.ShopModel:getSelectState() and config.type_cost == 2 then
            if config.type_cost == 2 then
                ch.UIManager:showGamePopup("Shop/W_shop_confirm",{name = config.name,price=config.price,buy=buy})
            else
                buy()
            end
        end
    end)
end)

zzy.BindManager:addCustomDataBind("Shop/W_shop_buygold",function(widget,data)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.diamond or evt.dataType == ch.MoneyModel.dataType.honour
        return ret
    end
    
    local goldChangeEvent = {}
    goldChangeEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    goldChangeEvent[ch.PartnerModel.czChangeEventType] = function(evt)
        return evt.dataType == ch.PartnerModel.dataType.get
    end
    
    local countChangeEvent = {}
    countChangeEvent[ch.ShopModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ShopModel.dataType.gold or evt.dataType == ch.ShopModel.dataType.all
    end
    
    local config = GameConfig.ShopConfig:getData(data)
    local money = 0
    widget:addDataProxy("icon", function(evt)
        return config.icon
    end)
    widget:addDataProxy("name", function(evt)
        return config.name
    end)
    widget:addDataProxy("isHot",function(evt)
        return config.type == 1
    end)
    widget:addDataProxy("isNew",function(evt)
        return config.type == 2
    end)
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][1]
    end)
    widget:addDataProxy("btnPressed",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][2]
    end)
    widget:addDataProxy("costIcon",function(evt)
        return GameConst.SHOP_COST_ICON_IMAGE[config.type_cost]
    end)
    
    widget:addDataProxy("reward", function(evt)
        money = ch.CommonFunc:getOffLineGold(config.reward*3600)
        money = money == 0 and minGold or money
        return "+"..ch.NumberHelper:toString(money)
    end,goldChangeEvent)
    widget:addDataProxy("price", function(evt)
        return string.format("-%d",ch.ShopModel:getGoldPrice(data))
    end,countChangeEvent)
    widget:addDataProxy("ifCanBuy",function(evt)
        return ifCanBuy(config.type_cost,ch.ShopModel:getGoldPrice(data))
    end,moneyChangeEvent)
    widget:addDataProxy("isNoMax",function(evt)
        return ch.ShopModel:getGoldCount() < GameConst.SHOP_BUY_GOLD_MAX_COUNT
    end,countChangeEvent)
    widget:addDataProxy("goldCount",function(evt)
        return GameConst.SHOP_BUY_GOLD_MAX_COUNT-ch.ShopModel:getGoldCount()
    end,countChangeEvent)
    widget:addCommond("buy",function()
        -- 购买
        local buy = function()
            ch.NetworkController:shopBuy(data,money)
            ch.MoneyModel:addGold(money)
            costType(config.type_cost,-ch.ShopModel:getGoldPrice(data),config)
            ch.ShopModel:addGoldCount(1)
            if config.tip_type and config.tip_type == 2 then
                ch.UIManager:showNotice(config.tip_desc)
            end
            local button = widget:getChild("N_BTNbuy")
            local startP = button:convertToWorldSpace(cc.p(0,0))
            ch.CommonFunc:showCollectGold(startP,money)
        end
--        if not ch.ShopModel:getSelectState() and config.type_cost == 2 then
        if config.type_cost == 2 then
            ch.UIManager:showGamePopup("Shop/W_shop_confirm",{name = config.name,price=ch.ShopModel:getGoldPrice(data),buy=buy})
        else
            buy()
        end
    end)
end)

zzy.BindManager:addCustomDataBind("Shop/W_shop_buystone",function(widget,data)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.diamond or evt.dataType == ch.MoneyModel.dataType.honour
        return ret
    end
    
    local config = GameConfig.ShopConfig:getData(data)
    local descIndex = 1
    local buffType = 0
    if config.type_get == 3 then
        descIndex = 1
        buffType = GameConst.SHOP_BUY_SSTONE_RATIO*100
    elseif config.type_get == 6 then
        descIndex = 2
        buffType = 1+GameConst.BUFF_EFFECT_VALUE[3]
    elseif config.type_get == 7 then
        descIndex = 3
        buffType = 1+GameConst.BUFF_EFFECT_VALUE[4]
    end
    
    widget:addDataProxy("icon", function(evt)
        return config.icon
    end)
    widget:addDataProxy("name", function(evt)
        return config.name
    end)
    widget:addDataProxy("isHot",function(evt)
        return config.type == 1
    end)
    widget:addDataProxy("isNew",function(evt)
        return config.type == 2
    end)
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][1]
    end)
    widget:addDataProxy("btnPressed",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][2]
    end)
    widget:addDataProxy("costIcon",function(evt)
        return GameConst.SHOP_COST_ICON_IMAGE[config.type_cost]
    end)
    
    widget:addDataProxy("rewardIcon", function(evt)
        return GameConst.SHOP_BUY_BUFF_ICON[descIndex]
    end)
    
    widget:addDataProxy("reward", function(evt)
        return string.format(GameConst.SHOP_BUY_BUFF_DESC[descIndex],buffType,config.reward)
    end)
    widget:addDataProxy("price", function(evt)
        return string.format("-%d",config.price)
    end)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("leftTime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    widget:addDataProxy("leftTime", function(evt)
        if config.type_get == 3 then
            return getTime(ch.BuffModel:getSStoneTime())
        elseif config.type_get == 6 then
            return getTime(ch.BuffModel:getManyGoldTime())
        elseif config.type_get == 7 then
            return getTime(ch.BuffModel:getInspireTime())
        else
            return 0
        end
    end)
    widget:addDataProxy("ifCanBuy",function(evt)
        return ifCanBuy(config.type_cost,config.price)
    end,moneyChangeEvent)
    widget:addCommond("buy",function()
        -- 购买
        local buy = function()
            ch.NetworkController:shopBuy(data)
            if config.type_get == 3 then
                ch.BuffModel:addSStoneBuff(config.reward*3600)
            elseif config.type_get == 6 then
                ch.BuffModel:addManyGoldBuff(config.reward*3600)
            elseif config.type_get == 7 then
                ch.BuffModel:addInspireBuff(config.reward*3600)
            end
            costType(config.type_cost,-config.price,config)
            if config.tip_type and config.tip_type == 2 then
                ch.UIManager:showNotice(config.tip_desc)
            end
        end
--        if not ch.ShopModel:getSelectState() and config.type_cost == 2 then
        if config.type_cost == 2 then
            ch.UIManager:showGamePopup("Shop/W_shop_confirm",{name = config.name,price=config.price,buy=buy})
        else
            buy()
        end
    end)
end)

zzy.BindManager:addCustomDataBind("Shop/W_shop_buydiamond",function(widget,data)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.diamond or evt.dataType == ch.MoneyModel.dataType.honour
        return ret
    end
    local firsIDChangeEvent = {}
    firsIDChangeEvent[ch.ShopModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ShopModel.dataType.firstID
    end
    
    local config = GameConfig.ShopConfig:getData(data)
    widget:addDataProxy("icon", function(evt)
        return config.icon
    end)
    widget:addDataProxy("name", function(evt)
        return config.name
    end)
    widget:addDataProxy("isHot",function(evt)
        return config.type == 1
    end)
    widget:addDataProxy("isNew",function(evt)
        return config.type == 2
    end)
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][1]
    end)
    widget:addDataProxy("btnPressed",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][2]
    end)
    widget:addDataProxy("costIcon",function(evt)
        if config.type_cost == 1 then
            local btn_icon = zzy.CocosExtra.seekNodeByName(widget, "btn_icon")
            btn_icon:setVisible(false) -- tgx 商品左上角图标隐藏
        end
        return GameConst.SHOP_COST_ICON_IMAGE[config.type_cost]
    end)
    widget:addDataProxy("costType",function(evt)
        if config.type_cost==1 then
            return ch.CommonFunc:getCoinName()
        else
            return ""
        end
    end)
    widget:addDataProxy("ifCanBuy",function(evt)
        local Text_DayLimiteTitle = zzy.CocosExtra.seekNodeByName(widget, "Text_DayLimiteTitle")
        local Text_DayLimiteValue = zzy.CocosExtra.seekNodeByName(widget, "Text_DayLimiteValue")
        if IS_BANHAO and Text_DayLimiteValue then
            Text_DayLimiteTitle:setVisible(true)
            Text_DayLimiteValue:setVisible(true)
        else
            Text_DayLimiteTitle:setVisible(false)
            Text_DayLimiteValue:setVisible(false)
        end
        local ifcan = ifCanBuy(config.type_cost,config.price)
        return 
    end,moneyChangeEvent)
    
    widget:addDataProxy("reward", function(evt)
--        local diamond = ch.CommonFunc:getDiamondByMoney(config.price)
        local diamond = config.diamondNum
        -- 首充翻倍屏蔽
        if ch.ShopModel:getFirstID(config.index) == 0 then
            return string.format(" %d"..Language.MSG_PAYCOIN..Language.src_clickhero_view_ShopView_5.."\n"..Language.src_clickhero_view_ShopView_8,diamond,config.firstNum)
        else
            if config.reward == diamond then
                return " "..config.reward..Language.MSG_PAYCOIN
            else
                return string.format(" %d"..Language.MSG_PAYCOIN..Language.src_clickhero_view_ShopView_5,diamond,config.reward-diamond)
            end
        end
    end,firsIDChangeEvent)

    widget:addDataProxy("price", function(evt)
        return string.format("%s",config.price)
    end)
    widget:addCommond("buy",function()
        -- 购买
        local buy = function()
            costType(config.type_cost,-config.price,config)
            if config.tip_type and config.tip_type == 2 then
                ch.UIManager:showNotice(config.tip_desc)
            end
        end
        -- 只有韩国有
--        if not ch.ShopModel:getSelectState() and config.type_cost == 1 and string.sub(zzy.Sdk.getFlag(),1,2)=="TJ" then
        if config.type_cost == 1 and string.sub(zzy.Sdk.getFlag(),1,2)=="TJ" then
            local money = config.price .. ch.CommonFunc:getCoinName()
            ch.UIManager:showGamePopup("Shop/W_shop_confirm",{name = config.name,price=money,rmb=true,buy=buy})
        else
            buy()
        end
    end)
end)


zzy.BindManager:addFixedBind("Shop/W_shop_buycard2",function(widget)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.diamond or evt.dataType == ch.MoneyModel.dataType.honour
        return ret
    end
    local config = GameConfig.ShopConfig:getData(SHOP_VIEW_CARD_ID or cardID)
    widget:addDataProxy("icon", function(evt)
        return config.icon
    end)
    widget:addDataProxy("name", function(evt)
        return config.name
    end)
    widget:addDataProxy("desc",function(evt)
        return string.format(GameConst.SHOP_BUY_YUEKA_DESC[2],config.reward/24)
    end)
    widget:addDataProxy("detailDesc",function(evt)
        local detailDesc = string.format(GameConst.SHOP_YUEKA_DETAIL_DESC,GameConst.BUFF_EFFECT_VALUE[1][1]*100,
            GameConst.BUFF_EFFECT_VALUE[1][2]*100,GameConst.BUFF_EFFECT_VALUE[1][4]*100) 
            
        if config.type_item==10 then
            detailDesc = string.format(GameConst.SHOP_MONEY_YUEKA_DETAIL_DESC, config.dayReward)
        elseif config.type_item==11 then
            detailDesc = string.format(GameConst.SHOP_GOLD_YUEKA_DETAIL_DESC, config.dayReward) 
        end
        
        return detailDesc
    end)
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][1]
    end)
    widget:addDataProxy("btnPressed",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][2]
    end)
    widget:addDataProxy("costIcon",function(evt)
        local icon = GameConst.SHOP_COST_ICON_IMAGE[config.type_cost]
        if icon == "res/icon/dot1.png" then
            local iconImg = zzy.CocosExtra.seekNodeByName(widget, "btn_icon")
            iconImg:setVisible(false)
        end
        return icon
    end)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("leftTime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    widget:addDataProxy("leftTime", function(evt)
        return getTime(ch.BuffModel:getCardBuffTime(config.type_item))
    end)
    widget:addDataProxy("ifCanBuy",function(evt)
        return ifCanBuy(config.type_cost,config.price)
    end,moneyChangeEvent)
    widget:addDataProxy("price", function(evt)
        if config.type_cost==1 then
            return config.price.."    "..ch.CommonFunc:getCoinName()
        else
            return string.format("-%d",config.price)
        end
    end)
    widget:addCommond("buy",function()
        local buy = function()
            ch.NetworkController:shopBuy(config.id)
            costType(config.type_cost,-config.price)
            ch.BuffModel:addCardBuff(config.reward*3600)
            ch.UIManager:showMsgBox(1,true,string.format(Language.src_clickhero_view_ShopView_3,config.reward/24),nil,nil,Language.MSG_BUTTON_HUMOROK)
            if config.tip_type and config.tip_type == 2 then
                ch.UIManager:showNotice(config.tip_desc)
            end
            widget:destory()
        end
        
        if config.type_cost == 1 then
            buy = function()
                costType(config.type_cost,-config.price,config)
                if config.tip_type and config.tip_type == 2 then
                    ch.UIManager:showNotice(config.tip_desc)
                end
            end
        end
            
        if ch.BuffModel:getCardBuffTime(config.type_item) > 0 then
            ch.UIManager:showMsgBox(2,true,GameConst.SHOP_YUEKA_TIP,buy,nil,Language.MSG_BUTTON_OK,2)
        else
            buy()
        end
    end)
end)

local stayTime = 10
zzy.BindManager:addFixedBind("Shop/W_shop_buybosstime", function(widget)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    local leftTime = 0
    widget:addDataProxy("leftTime",function(evt)
        return string.format("%d",leftTime)
    end)
    local scheduleId = nil
    local startCountDown = function()
        leftTime = stayTime
        local startTime = os_clock()
        widget:noticeDataChange("leftTime")
        widget:listen(zzy.Events.TickEventType,function()
            leftTime = stayTime - os_clock() + startTime
            if leftTime > 0 then
                widget:noticeDataChange("leftTime")
            else
                local evt = {
                    type = ch.LevelModel.buyCountEventType,
                    dataType = ch.LevelModel.buyDataType.giveUp
                }
                zzy.EventManager:dispatch(evt)
                widget:destory()
            end
        end)
    end
    startCountDown()
    widget:addDataProxy("addTime", function(evt)
        return string.format(Language.src_clickhero_view_ShopView_4,GameConst.SHOP_BUY_BOSS_TIME)
    end)
    widget:addDataProxy("leftTimes", function(evt)
        return #GameConst.SHOP_BUY_BOSS_COST - ch.LevelModel:getBuyCount()
    end)
    widget:addDataProxy("price", function(evt)
        return GameConst.SHOP_BUY_BOSS_COST[ch.LevelModel:getBuyCount()+1]
    end)
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
    
    widget:addDataProxy("ifCanBuy",function(evt)
        return ch.MoneyModel:getDiamond() >= GameConst.SHOP_BUY_BOSS_COST[ch.LevelModel:getBuyCount()+1]
    end,moneyChangeEvent)
    widget:addCommond("buy",function()
        ch.NetworkController:buyBossTime()
        local evt = {
            type = ch.LevelModel.buyCountEventType,
            dataType = ch.LevelModel.buyDataType.buy
        }
        zzy.EventManager:dispatch(evt)
        widget:destory()
    end)
    widget:addCommond("close",function()
        local evt = {
            type = ch.LevelModel.buyCountEventType,
            dataType = ch.LevelModel.buyDataType.giveUp
        }
        zzy.EventManager:dispatch(evt)
        widget:destory()
    end)
    widget:addCommond("select",function()
        ch.SettingModel:setBossTimeRemind(false)
    end)
    widget:addCommond("unSelect",function()
        ch.SettingModel:setBossTimeRemind(true)
    end)
    
end)

--购买宠物(详情)
zzy.BindManager:addCustomDataBind("Shop/W_shop_buypet2",function(widget,data)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.diamond or evt.dataType == ch.MoneyModel.dataType.honour
        return ret
    end
    local config = GameConfig.ShopConfig:getData(tonumber(data))
    local cs = GameConfig.PartnerConfig:getData(tostring(config.reward))
    widget:addDataProxy("apath", function(evt)
        return cs.spath
    end)
    widget:addDataProxy("partnerlist", function(evt)
        local petID = tostring(config.reward)
        local clickSpeed = GameConfig.PartnerConfig:getData(petID).clickSpeed or 0
        local upType = GameConfig.PartnerConfig:getData(petID).up_type or 0
        local items = {}
        table.insert(items,{index =1,value = {id = petID},isMultiple = true})
        table.insert(items,{index = 2,value = petID,isMultiple = true})
        if clickSpeed > 0 then
            table.insert(items,{index =1,value = {id = petID,click = clickSpeed},isMultiple = true})
        end
        if upType ~= 0 then
            table.insert(items,{index =1,value = {id = petID,upType = upType},isMultiple = true})
        end
        return items
    end)
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][1]
    end)
    widget:addDataProxy("btnPressed",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][2]
    end)
    widget:addDataProxy("costIcon",function(evt)
        return GameConst.SHOP_COST_ICON_IMAGE[config.type_cost]
    end)
    widget:addDataProxy("name", function(evt)
        return cs.name
    end)
    widget:addDataProxy("ifCanBuy",function(evt)
        return ifCanBuy(config.type_cost,config.price)
    end,moneyChangeEvent)
    widget:addDataProxy("price", function(evt)
        return string.format("-%d",config.price)
    end)
    widget:addCommond("buy",function()
        -- 购买
        ch.NetworkController:shopBuy(data)
        ch.PartnerModel:getOne(tostring(config.reward))
        costType(config.type_cost,-config.price,config)
        if config.tip_type and config.tip_type == 2 then
            ch.UIManager:showNotice(config.tip_desc)
        end
        widget:destory()
    end)
end)

--购买宠物(卡片)
zzy.BindManager:addCustomDataBind("Shop/W_shop_buypet",function(widget,data)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.diamond or evt.dataType == ch.MoneyModel.dataType.honour
        return ret
    end
    local config = GameConfig.ShopConfig:getData(data)
    local cs = GameConfig.PartnerConfig:getData(tostring(config.reward))
    widget:addDataProxy("name", function(evt)
        return cs.name
    end)
    widget:addDataProxy("des", function(evt)
        return cs.des
    end)
    widget:addDataProxy("icon", function(evt)
        return cs.icon
    end)
    widget:addDataProxy("id",function(evt)
        return tostring(data)
    end)
    widget:addDataProxy("isHot",function(evt)
        return config.type == 1
    end)
    widget:addDataProxy("isNew",function(evt)
        return config.type == 2
    end)
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][1]
    end)
    widget:addDataProxy("btnPressed",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[config.type_cost][2]
    end)
    widget:addDataProxy("costIcon",function(evt)
        return GameConst.SHOP_COST_ICON_IMAGE[config.type_cost]
    end)
    widget:addDataProxy("price", function(evt)
        return string.format("-%d",config.price)
    end)
    widget:addDataProxy("ifCanBuy",function(evt)
        return ifCanBuy(config.type_cost,config.price)
    end,moneyChangeEvent)
    
--    widget:addCommond("openPetCard",function()
--        ch.UIManager:showGamePopup("fuwen/W_FuwenPetChange",cs.id)
--    end)
    
    widget:addCommond("openPetCard",function()
         ch.UIManager:showGamePopup("fuwen/W_FuwenPetChange",{type = 1,id = tostring(config.reward)})
    end)

    widget:addCommond("buy",function()
        -- 购买
        local buy = function()
            ch.NetworkController:shopBuy(data)
            ch.PartnerModel:getOne(tostring(config.reward))
            costType(config.type_cost,-config.price,config)
            if config.tip_type and config.tip_type == 2 then
                ch.UIManager:showNotice(config.tip_desc)
            end
        end
--        if not ch.ShopModel:getSelectState() and config.type_cost == 2 then
        if config.type_cost == 2 then
            ch.UIManager:showGamePopup("Shop/W_shop_confirm",{name = config.name,price=config.price,buy=buy})
        else
            buy()
        end
    end)
end)

-- 累计充值项
zzy.BindManager:addFixedBind("Shop/W_shop_chongzhi", function(widget)
    local chargeChange = {}
    chargeChange[ch.ShopModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.ShopModel.dataType.totalCharge
    end
    widget:addDataProxy("data",function(evt)
        local data = {}
        local curC = ch.ShopModel:getTotalCharge()
        for k,v in ipairs(GameConfig.Charge_levelConfig:getTable()) do
            if curC < v.val then
                data.diamond = v.val - curC
--                data.diamond = ch.CommonFunc:getMoneyByDiamond(v.val - curC)
                data.desc = v.sDesc
                data.showReward = true
                data.completed = false
                break
            end
        end
        if not data.desc then
            data.diamond = 0
            data.desc = ""
            data.showReward = false
            data.completed = true
        end
        return data
    end,chargeChange)
    widget:addCommond("openDetail",function()
        ch.UIManager:showGamePopup("Shop/W_shop_shuoming")
    end)
	widget:addDataProxy("txt_coinname",function(evt)
--        return ch.CommonFunc:getCoinName()
		return Language.MSG_PAYCOIN
    end)
end)

-- 充值详情
zzy.BindManager:addFixedBind("Shop/W_shop_shuoming", function(widget)
    widget:addDataProxy("items",function(evt)
        local items = {}
        for k,v in ipairs(GameConfig.Charge_levelConfig:getTable()) do
            table.insert(items,k)
        end
        return items
    end)
end)

-- 充值详情项
zzy.BindManager:addCustomDataBind("Shop/W_Shop_ChongZhiItem",function(widget,data)
    widget:addDataProxy("title",function(evt)
        if data ==0 then
            return GameConst.SHOP_FIRST_CHARGE_TITLE
        else
--            local val = ch.CommonFunc:getMoneyByDiamond(GameConfig.Charge_levelConfig:getData(data).val)
--            return string.format(GameConst.SHOP_CHARGE_TITLE,val,ch.CommonFunc:getCoinName()) 
            local val = GameConfig.Charge_levelConfig:getData(data).val
            return string.format(GameConst.SHOP_CHARGE_TITLE,val,Language.MSG_PAYCOIN)
        end
    end)
    widget:addDataProxy("content",function(evt)
        if data == 0 then
            local d = GameConst.SHOP_FIRST_PAY_REWARD
            return string.format(GameConst.SHOP_FIRST_CHARGE_CONTNENT,d.diamond*100,
                GameConfig.PartnerConfig:getData(d.pet).name) 
        else
            return GameConfig.Charge_levelConfig:getData(data).lDesc
        end
    end)
end)
-- 其它方式充值
zzy.BindManager:addFixedBind("Shop/W_shop_HWCZ", function(widget)
	 widget:addCommond("btn_charge",function()
        local orderdata={
			channelid=zzy.config.ChannelID,
			userid=zzy.config.loginData.userid,
			svrid=ch.PlayerModel:getZoneID(),
			ordermold="short",
            paychannelid=2
        }
		local url="http://bill."
		url=url..ch.CommonFunc:getProductName().."."..ch.CommonFunc:getDomain().."/"
        --url="http://bill.test.dmw.sail2world.com/"
		url=url.."order_report_few.php?orderdata="..json.encode(orderdata)
		local chargeFunc=nil
		chargeFunc=function()
			ch.CommonFunc:getNetString(url, function(err, str)
				if err==0 then
					 local  content=json.decode(str)
					 if content.ret==0 then
						 local orderInfo = content.params
						 local svrid_short=tonumber(string.match(ch.PlayerModel:getZoneID(), "([%d]?[%d]?[%d]?)$"))
						 orderInfo.svrid_short = svrid_short
						 orderInfo.time=os_clock()
						 local tb_sig={
                            order=zzy.config.ChannelID.."_"..svrid_short.."_"..zzy.config.loginData.userid.."_"..orderInfo.orderid 
							 ,time=orderInfo.time
						}
						orderInfo.sig=ch.CommonFunc:getWYSig(tb_sig)
						zzy.Sdk.openCharge(json.encode(orderInfo))
					 else
						ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController2_2..content.ret,nil,nil,Language.MSG_BUTTON_OK)
					 end
				else
					 ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[1].."("..GameConst.NET_ERROR[5]..err..")",
						function() 
							chargeFunc() 
					end,nil,Language.MSG_BUTTON_RETRY)
				end
		 end)
	  end
	  chargeFunc()
    end)
end)

-- 钻石购买二次确认(商店用)
zzy.BindManager:addCustomDataBind("Shop/W_shop_confirm",function(widget,data)
--    local isSelect = ch.ShopModel:getSelectState()
    widget:getChild("CheckBox"):setVisible(false)
    widget:getChild("Text_77"):setVisible(false)
    if data.rmb then
        widget:getChild("img_Diamond"):setVisible(false)
    end
    
    widget:addDataProxy("name",function(evt)
        return data.name
    end)
    widget:addDataProxy("price",function(evt)
        return data.price
    end)
    widget:addDataProxy("ifSelect",function(evt)
--        return ch.ShopModel:getSelectState()
        return false
    end)

    widget:addCommond("select",function(widget,arg)
--        if arg == "0" then
--            isSelect = true
--        else
--            isSelect = false
--        end
    end)
    widget:addCommond("buy",function()
        data.buy()
--        ch.ShopModel:setSelectState(isSelect)
        widget:destory()
    end)
    widget:addCommond("cancel",function()
        widget:destory()
    end)
end)

-- 花费钻石二次确认
zzy.BindManager:addCustomDataBind("Shop/W_shop_confirm_diamond",function(widget,data)
    local isSelect = ch.ShopModel:getSelectState()

    widget:addDataProxy("price",function(evt)
        return data.price
    end)
    widget:addDataProxy("ifSelect",function(evt)
        return ch.ShopModel:getSelectState()
    end)

    widget:addCommond("select",function(widget,arg)
        if arg == "0" then
            isSelect = true
        else
            isSelect = false
        end
    end)
    widget:addCommond("buy",function()
        widget:destory()
        ch.ShopModel:setSelectState(isSelect)
        data.buy()
    end)
    widget:addCommond("cancel",function()
        widget:destory()
    end)
end)
