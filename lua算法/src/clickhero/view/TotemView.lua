local CHANG_DIAMOND_EVENT = "CHANG_DIAMOND_COST"
local isDiamond = false

local upNum = 1
local upNumTable = {1,25,100}
local tmpNum = 0
local CHANG_UPNUM_EVENT = "TOTEM_CHANG_UPNUM"

local rotateUnit = function(widget,func)
    local ani = cc.RotateBy:create(0.15,cc.Vertex3F(90,0,0))
    local seq = cc.Sequence:create(ani,cc.CallFunc:create(function()
        local spr = cc.Sprite:createWithSpriteFrameName("aaui_diban/Totem_Bg02.png")
        spr:setRotation(180)
        widget:addChild(spr)
        widget:noticeDataChange("data")
        local ani = cc.RotateBy:create(0.3,cc.Vertex3F(180,0,0))
        local seq = cc.Sequence:create(ani,cc.CallFunc:create(function()
            spr:removeFromParent()
            local ani = cc.RotateBy:create(0.15,cc.Vertex3F(90,0,0))
            if func then
                local seq = cc.Sequence:create(ani,cc.CallFunc:create(function()
                    func()
                end))
                widget:runAction(seq)
            else
                widget:runAction(ani) 
            end
        end))
        widget:runAction(seq)
    end))
    widget:runAction(seq)
end 

local TotemRefreshViewType = "TOTEM_REFRESH_VIEW_TYPE"

-- 固有绑定
-- 图腾选择 W_TutengXuanze
zzy.BindManager:addFixedBind("tuteng/W_TutengXuanze", function(widget)
    --版号
    TT_LEFT_REFRESH_TIMES = TT_LEFT_REFRESH_TIMES or 20
    
    local totemChangeEvent = {}
    totemChangeEvent[ch.TotemModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.TotemModel.dataType.level
        return ret
    end
    totemChangeEvent[ch.TotemModel.refreshChangeEventType] = function(evt)
        local ret = evt.dataType == ch.TotemModel.dataType.refresh
        return ret
    end
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
            or evt.dataType == ch.MoneyModel.dataType.soul
    end
    
    local isRefreshing = false
    -- 界面标题 "图腾召唤"
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_TotemView_1
    end)
    -- 钻石刷新价格
    widget:addDataProxy("diamondPrice",function(evt)
        return "-"..tostring(ch.TotemModel:getRefreshDiamondPrice())
    end)
    -- 魂刷新价格
    widget:addDataProxy("soulPrice",function(evt)
        return "-"..tostring(ch.TotemModel:getRefreshSoulPrice())
    end)
    -- 钻石是否充足
    widget:addDataProxy("diamondEnough",function(evt)
        return not isRefreshing and ch.TotemModel:getRefreshDiamondPrice()<=ch.MoneyModel:getDiamond() and TT_LEFT_REFRESH_TIMES > 0
    end,moneyChangeEvent)
    -- 魂是否充足
    widget:addDataProxy("soulEnough",function(evt)
        return not isRefreshing and ch.TotemModel:getRefreshSoulPrice()<=ch.MoneyModel:getSoul() and TT_LEFT_REFRESH_TIMES > 0
    end,moneyChangeEvent)
    -- 是否可刷新
    widget:addDataProxy("canRefresh",function(evt)
--        return ch.TotemModel:getrestTotemsNum()>4
        return ch.TotemModel:getAllTotemNum(1)>ch.TotemModel:getOwnTotemNum(1)+4
    end)
    -- 是否不可刷新
    widget:addDataProxy("canNoRefresh",function(evt)
        return ch.TotemModel:getAllTotemNum(1)<=ch.TotemModel:getOwnTotemNum(1)+4
    end)
    
    --版号
    local Text_buy_limite_title = zzy.CocosExtra.seekNodeByName(widget, "Text_buy_limite_title")
    local Text_buy_limite_value = zzy.CocosExtra.seekNodeByName(widget, "Text_buy_limite_value")
    if IS_BANHAO then
        if Text_buy_limite_title then
            Text_buy_limite_title:setVisible(true)
        end
        
        if Text_buy_limite_value then
            Text_buy_limite_value:setVisible(true)
            Text_buy_limite_value:setString(tostring(TT_LEFT_REFRESH_TIMES))
        end
    end
    
    -- 图腾刷新
    widget:addCommond("refresh",function(widget,arg)
        local buy = function()
            if IS_BANHAO and Text_buy_limite_value then --版号
                TT_LEFT_REFRESH_TIMES = TT_LEFT_REFRESH_TIMES - 1
                Text_buy_limite_value:setString(tostring(TT_LEFT_REFRESH_TIMES))
            end
            ch.NetworkController:totemRefresh(arg)
            isRefreshing = true
            widget:noticeDataChange("diamondEnough")
            widget:noticeDataChange("soulEnough")
            local evt = {type = TotemRefreshViewType}
            evt.isRefreshing = true
            zzy.EventManager:dispatch(evt)
        end
        if arg == "1" then
            buy()
        else
            local tmp = {price = ch.TotemModel:getRefreshDiamondPrice(),buy = buy}
            ch.ShopModel:getCostTips(tmp)
        end
    end)
    
    widget:listen(ch.TotemModel.refreshChangeEventType,function()
        for i= 1,4 do
            local delay = (i-1) * 0.15
            if delay > 0 then
                widget:setTimeOut(delay,function()
                    local unit = widget:getChild("N_TutengXUnit"..i)
                    if i == 4 then
                        rotateUnit(unit,function()
                            isRefreshing = false
                            widget:noticeDataChange("diamondEnough")
                            widget:noticeDataChange("soulEnough")
                            local evt = {type = TotemRefreshViewType}
                            evt.isRefreshing = false
                            zzy.EventManager:dispatch(evt)
                        end)
                    else
                        rotateUnit(unit)
                    end
                end)
            else
                local unit = widget:getChild("N_TutengXUnit"..i)
                rotateUnit(unit)
            end
        end
    end)
    
end)

-- 高级图腾选择 W_TutengXuanze_gaoji
zzy.BindManager:addFixedBind("tuteng/W_TutengXuanze_gaoji", function(widget)
    local totemChangeEvent = {}
    totemChangeEvent[ch.TotemModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.TotemModel.dataType.level
        return ret
    end
    totemChangeEvent[ch.TotemModel.refreshChangeEventType] = function(evt)
        local ret = evt.dataType == ch.TotemModel.dataType.refresh
        return ret
    end
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.diamond
    end

    local isRefreshing = false
    -- 界面标题 "图腾召唤"
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_TotemView_1
    end)
    -- 钻石刷新价格
    widget:addDataProxy("diamondPrice",function(evt)
        return "-"..tostring(ch.TotemModel:getRefreshDiamondPrice(2))
    end)
    -- 钻石是否充足
    widget:addDataProxy("diamondEnough",function(evt)
        return not isRefreshing and ch.TotemModel:getRefreshDiamondPrice(2)<=ch.MoneyModel:getDiamond()
    end,moneyChangeEvent)
    -- 是否可刷新
    widget:addDataProxy("canRefresh",function(evt)
        return ch.TotemModel:getAllTotemNum(2)>ch.TotemModel:getOwnTotemNum(2)+4
    end)
    -- 是否不可刷新
    widget:addDataProxy("canNoRefresh",function(evt)
        return ch.TotemModel:getAllTotemNum(2)<=ch.TotemModel:getOwnTotemNum(2)+4
    end)

    -- 图腾刷新
    widget:addCommond("refresh",function(widget,arg)
        local buy = function()
            ch.NetworkController:totemRefresh_senior(arg)
            isRefreshing = true
            widget:noticeDataChange("diamondEnough")
            local evt = {type = TotemRefreshViewType}
            evt.isRefreshing = true
            zzy.EventManager:dispatch(evt)
        end
        if arg == "1" then
            buy()
        else
            local tmp = {price = ch.TotemModel:getRefreshDiamondPrice(2),buy = buy}
            ch.ShopModel:getCostTips(tmp)
        end
    end)

    widget:listen(ch.TotemModel.refreshChangeEventType,function()
        for i= 1,4 do
            local delay = (i-1) * 0.15
            if delay > 0 then
                widget:setTimeOut(delay,function()
                    local unit = widget:getChild("N_TutengXUnit"..i)
                    if i == 4 then
                        rotateUnit(unit,function()
                            isRefreshing = false
                            widget:noticeDataChange("diamondEnough")
                            local evt = {type = TotemRefreshViewType}
                            evt.isRefreshing = false
                            zzy.EventManager:dispatch(evt)
                        end)
                    else
                        rotateUnit(unit)
                    end
                end)
            else
                local unit = widget:getChild("N_TutengXUnit"..i)
                rotateUnit(unit)
            end
        end
    end)
end)

-- 图腾打开界面
zzy.BindManager:addFixedBind("tuteng/W_TutengList", function(widget)
    local totemChangeEvent = {}
    totemChangeEvent[ch.TotemModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.TotemModel.dataType.level
        return ret
    end
    totemChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.soul or evt.dataType == ch.MoneyModel.dataType.diamond    	
    end
    
    if ch.StatisticsModel:getMaxLevel() < GameConst.SSTONE_LEVEL then
        totemChangeEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        	return evt.dataType == ch.LevelModel.dataType.curLevel
        end
    end
    
    local checkedChangedEvent = {}
    checkedChangedEvent[CHANG_DIAMOND_EVENT] = false
    checkedChangedEvent[CHANG_UPNUM_EVENT] = false
    
    widget:addDataProxy("imgBg",function(evt)
        return "res/img/db_b_tuteng.png"
    end)
    -- 魂数量
    widget:addDataProxy("soul-num",function(evt)
        return ch.MoneyModel:getSoul()
    end,totemChangeEvent)
    widget:addScrollData("soul-num", "soul", 1, function(v)
        return ch.NumberHelper:toString(v)
    end,"N_MoneySouls:num_Soul")
    -- 魂石数量
    widget:addDataProxy("stone-num",function(evt)
        return ch.MoneyModel:getsStone()
    end,totemChangeEvent)
    widget:addScrollData("stone-num", "stone", 1, function(v)
        return ch.NumberHelper:toString(v)
    end,"N_MoneyStones:num_Stone")
    -- 已拥有图腾ID列表
    local listInited = false
    widget:addDataProxy("tuTengList", function(evt)
        local data = {}
        for k,v in ipairs(ch.TotemModel:getCurTotem()) do
            table.insert(data,{index = 1,value = v,isMultiple = true})
        end
        if ch.TotemModel:getOwnTotemNum(1)>0 then
            table.insert(data,{index = 2,value = 0,isMultiple = true})
        end
        data.autoScrollDown = listInited
        listInited = true
        return data
    end,totemChangeEvent)
    -- 已经拥有图腾数量
    widget:addDataProxy("ownTuTeng", function(evt)
        return tostring(ch.TotemModel:getOwnTotemNum(1))
    end,totemChangeEvent)
    
    -- 所有图腾数量
    widget:addDataProxy("allTuTeng", function(evt)
        return tostring(ch.TotemModel:getAllTotemNum())
    end,totemChangeEvent)
    -- 是否可召唤新图腾
    widget:addDataProxy("ifCall",function(evt)
        return ch.TotemModel:getTotemOpen() and ch.TotemModel:getOwnTotemNum(1)<ch.TotemModel:getAllTotemNum(1)
    end,totemChangeEvent)
    -- 是否可清除图腾
    widget:addDataProxy("ifClean",function(evt)
        return ch.TotemModel:getOwnTotemNum(1)>0
    end,totemChangeEvent)
    -- 是否开启图腾功能
    widget:addDataProxy("ifNoOpen",function(evt)
        return not ch.TotemModel:getTotemOpen()
    end,totemChangeEvent)
    -- 是否开启图腾功能
    widget:addDataProxy("ifOpen",function(evt)
        return ch.TotemModel:getTotemOpen()
    end,totemChangeEvent)
    -- 已开启图腾且数量为0
    widget:addDataProxy("ifOpenCall",function(evt)
        return ch.TotemModel:getOwnTotemNum(1)== 0 and ch.TotemModel:getTotemOpen()
    end,totemChangeEvent)
    widget:addCommond("openXuanze",function(widget,arg)
        ch.UIManager:showGamePopup("tuteng/W_TutengXuanze")
        --结束引导
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10090 then
            ch.TotemModel:_refreshChangeEvent(ch.TotemModel.dataType.refresh)
            ch.guide:endid(10090)
        end
    end)
    -- 图腾清除界面打开
    widget:addCommond("cleanTotem",function()
        if ch.TotemModel:getCleanDiamondPrice() > 0 then
            ch.UIManager:showGamePopup("tuteng/W_TutengQingchu2")
        else
            ch.UIManager:showGamePopup("tuteng/W_TutengQingchu3")
        end
    end)

    -- 钻石复选框
    widget:addDataProxy("ifSelect",function(evt)
        return isDiamond
    end,checkedChangedEvent)
    widget:addDataProxy("ifNotSelect",function(evt)
        return not isDiamond
    end,checkedChangedEvent)
    
    -- 选中取消钻石复选框状态 对应操作 0钻石1魂
    widget:addCommond("select",function(widget,arg)
        if arg == "1" then
            isDiamond = false
            zzy.EventManager:dispatchByType(CHANG_DIAMOND_EVENT)
        elseif arg == "0" then
            isDiamond = true
            zzy.EventManager:dispatchByType(CHANG_DIAMOND_EVENT)
        end
    end)
    
    -- 一次升级等级
    widget:addDataProxy("ButtomUpNum",function(evt)       
        local Button_level_upNum = zzy.CocosExtra.seekNodeByName(widget, "Button_level_upNum")
        Button_level_upNum:setString("X "..upNum)
        
        return "X "..upNum
    end,checkedChangedEvent)
    
    widget:addCommond("changeLevel",function(widget,arg)
        local tablecount = #upNumTable
        tmpNum = tmpNum + 1
        upNum = upNumTable[tmpNum%tablecount+1]
        zzy.EventManager:dispatchByType(CHANG_UPNUM_EVENT) 
    end)
    
    local tuTengOpenEvent = {}
    tuTengOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
        return evt.view == "tuteng/W_TutengList"
    end
    -- 上按钮可见
    widget:addDataProxy("upVisible", function(evt)
        if evt then
            return evt.popType == ch.UIManager.popType.HalfOpen
        else
            return true
        end
    end,tuTengOpenEvent)
    -- 下按钮可见
    widget:addDataProxy("downVisible", function(evt)
        if evt then
            return evt.popType ~= ch.UIManager.popType.HalfOpen
        else
            return false
        end
    end,tuTengOpenEvent)
    -- listView高度
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
    end,tuTengOpenEvent)
end)

-- 图腾召唤和清除  W_TutengLBtn
zzy.BindManager:addFixedBind("tuteng/W_TutengLBtn", function(widget)
    local totemChangeEvent = {}
    totemChangeEvent[ch.TotemModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.TotemModel.dataType.level
        return ret
    end
    -- 图腾清除界面打开
    widget:addCommond("cleanTotem",function()
        if ch.TotemModel:getCleanDiamondPrice() > 0 then
            ch.UIManager:showGamePopup("tuteng/W_TutengQingchu2")
        else
            ch.UIManager:showGamePopup("tuteng/W_TutengQingchu3")
        end
    end)
    widget:addCommond("openXuanze",function(widget,arg)
        ch.UIManager:showGamePopup("tuteng/W_TutengXuanze")
    end)
    local Button_gaoji = zzy.CocosExtra.seekNodeByName(widget, "Button_gaoji")
    Button_gaoji:loadTextures("res/icon/btn/aaui_button_btn_c_free1.png", "res/icon/btn/aaui_button_btn_c_free2.png", "res/icon/btn/aaui_button_btn_c_free3.png")
    widget:addCommond("openXuanze_gaoji",function(widget,arg)
        if ch.StatisticsModel:getMaxLevel() > GameConst.TOTEM_SENIOR_OPEN_LEVEL then
            ch.UIManager:showGamePopup("tuteng/W_TutengXuanze_gaoji")
        else
            ch.UIManager:showMsgBox(1,true,string.format(Language.SHENTAN_OPENLEVEL, GameConst.TOTEM_SENIOR_OPEN_LEVEL))
        end
    end)
    widget:addCommond("openTj",function(widget,arg)
        ch.UIManager:showGamePopup("tuteng/W_Tuteng_tujian")
    end)
    -- 是否可召唤新图腾
    widget:addDataProxy("ifCall",function(evt)
        return ch.TotemModel:getTotemOpen() and ch.TotemModel:getOwnTotemNum(1)<ch.TotemModel:getAllTotemNum(1)
    end,totemChangeEvent)
    -- 是否可召唤新高级图腾
    widget:addDataProxy("ifCall_gaoji",function(evt)
        return ch.TotemModel:getTotemOpen() and ch.TotemModel:getOwnTotemNum(2)<ch.TotemModel:getAllTotemNum(2)
    end,totemChangeEvent)
end)

-- 图腾清除  W_TutengQingchu3
zzy.BindManager:addFixedBind("tuteng/W_TutengQingchu3", function(widget)
    local totemChangeEvent = {}
    totemChangeEvent[ch.TotemModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.TotemModel.dataType.level
        return ret
    end
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.gold
        return ret
    end
    -- 界面标题 "图腾清除"
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_TotemView_2
    end)
    -- 免费清除次数
    widget:addDataProxy("freeCount",function(evt)
        return GameConst.TOTEM_CLEAN..tostring(ch.TotemModel:getFreeCount().."/"..GameConst.TOTEM_FREE_COUNT)
    end,totemChangeEvent)
    -- 免费清除返还魂的数
    widget:addDataProxy("freeSoul",function(evt)
        return tostring(ch.TotemModel:getReturnSoulFree())
    end,totemChangeEvent)
    -- 免费清除返还钻石数
    widget:addDataProxy("freeDiamond",function(evt)
        return tostring(ch.TotemModel:getReturnDiamondFree())
    end,totemChangeEvent)
    -- 清除图腾
    widget:addCommond("clean",function(widget,arg)
        ch.NetworkController:totemReset(arg)
        ch.UIManager:cleanGamePopupLayer(true)
--        ch.UIManager:showBottomPopup("tuteng/W_TutengXuanze")
        ch.UIManager:showBottomPopup("tuteng/W_TutengList")
--        widget:destory()
        ch.SoundManager:play("cleantuteng")
    end)
end)


-- 图腾清除  W_TutengQingchu2
zzy.BindManager:addFixedBind("tuteng/W_TutengQingchu2", function(widget)
    local totemChangeEvent = {}
    totemChangeEvent[ch.TotemModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.TotemModel.dataType.level
        return ret
    end
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.gold
        return ret
    end
    -- 界面标题 "图腾清除"
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_TotemView_2
    end)
    -- 免费清除返还魂的数
    widget:addDataProxy("freeSoul",function(evt)
        return "+"..tostring(ch.TotemModel:getReturnSoulFree())
    end,totemChangeEvent)
    -- 免费清除返还钻石数
    widget:addDataProxy("freeDiamond",function(evt)
        return "+"..tostring(ch.TotemModel:getReturnDiamondFree())
    end,totemChangeEvent)
    -- 钻石清除返还魂数
    widget:addDataProxy("diamondSoul", function(evt)
        return "+"..tostring(ch.TotemModel:getReturnSoul())
    end,totemChangeEvent)
    -- 钻石清除返还钻石数
    widget:addDataProxy("diamondReturn", function(evt)
        return "+"..tostring(ch.TotemModel:getReturnDiamond())
    end,totemChangeEvent)
    -- 钻石清除价格
    widget:addDataProxy("diamondPrice", function(evt)
        return "-"..tostring(ch.TotemModel:getCleanDiamondPrice())
    end,totemChangeEvent)
    -- 钻石是否充足
    widget:addDataProxy("diamondEnough",function(evt)
        return ch.TotemModel:getCleanDiamondPrice()<=ch.MoneyModel:getDiamond()
    end,moneyChangeEvent)
    -- 清除图腾
    widget:addCommond("clean",function(widget,arg)
        ch.NetworkController:totemReset(arg)
        ch.UIManager:cleanGamePopupLayer(true)
--        ch.UIManager:showBottomPopup("tuteng/W_TutengXuanze")
        ch.UIManager:showBottomPopup("tuteng/W_TutengList")
--        widget:destory()
        ch.SoundManager:play("cleantuteng")
    end)
end)

-- 自定义数据绑定
-- 图腾Item
zzy.BindManager:addCustomDataBind("tuteng/W_TutengLUnit",function(widget,data)
    local totemChangeEvent = {}
    totemChangeEvent[ch.TotemModel.dataChangeEventType] = function(evt)
        if evt.id == data then
            return true
        else
            return false
        end
    end
    local touchChangeEvent = {}
    touchChangeEvent[ch.TotemModel.dataChangeEventType] = function(evt)
        if evt.id == data then
            return true
        else
            return false
        end
    end
    touchChangeEvent[ch.MoneyModel.dataChangeEventType] = false
    touchChangeEvent[CHANG_DIAMOND_EVENT] = false
    touchChangeEvent[CHANG_UPNUM_EVENT] = false
    
    widget:addDataProxy("data",function(evt)
        local tmpPrice1,tmpPrice2 = ch.TotemModel:getLevelUpCost(data,upNum)
        local ret = {}
        ret.ttIcon = GameConfig.TotemConfig:getData(data).icon
        ret.ttName = GameConfig.TotemConfig:getData(data).name
        ret.ttDes = ch.TotemModel:getDesData(data)
        ret.ttDesText = GameConfig.TotemConfig:getData(data).desc
        ret.isSenior = GameConfig.TotemConfig:getData(data).type == 2
        ret.ttLv = ch.TotemModel:getLevel(data)
        ret.ttLvMax = ch.TotemModel:getMaxLevel(data)
        ret.ifLvMax = ch.TotemModel:ifLvMax(data)
        ret.ttLvUpPrice = "-"..ch.NumberHelper:toString(tmpPrice1)
        ret.soulEnough = (tmpPrice1 <= ch.MoneyModel:getSoul()) and (type(ret.ttLvMax) == "string" or ret.ttLv + upNum <= ret.ttLvMax)
        ret.ttLvUpPrice2 = "-"..ch.NumberHelper:toString(tmpPrice2)
        ret.diamondEnough = (tmpPrice2 <= ch.MoneyModel:getDiamond()) and (type(ret.ttLvMax) == "string" or ret.ttLv + upNum <= ret.ttLvMax)
        ret.isSoul = ret.ifLvMax and (not isDiamond) and (not ret.isSenior)
        ret.isDiamond = not ret.isSoul and ret.ifLvMax
        ret.ttId = data
        ret.backImage = ret.isSenior and "res/icon/card/aaui_diban_db_gaoji.png" or "res/icon/card/aaui_diban_db_putong.png"
        ret.descImg = "res/icon/dot1.png"
        local tmpData = GameConfig.TotemConfig:getData(data)
        if tmpData.bigType == 7 or tmpData.bigType == 8 then
            ret.descImg = GameConst.PETCARD_JOB[tmpData.smallType].icon_s
        end
        return ret
    end,touchChangeEvent)
    if data == ch.TotemModel:getTotemNewID() then
        widget:playEffect("totemUpEffect",false)
    end
    
    -- 升级0为钻石1为魂
    widget:addCommond("levelUp",function(widget,arg)
        local buy = function()
            ch.NetworkController:totemLevelUp(data,arg,upNum)
            -- 首次钻石升级邮件
            if ch.guide._data["guide9101"] ~= 1 and tonumber(arg) == 0 then
                ch.guide._data["guide9101"] = 1
                ch.NetworkController:reGuideMsg("9101", "8")
            end
            ch.SoundManager:play("ttlvup")
        end
        if arg == "1" then
            buy()
        else
            local tmpPrice1,tmpPrice2 = ch.TotemModel:getLevelUpCost(data,upNum)
            local tmp = {price = tmpPrice2,buy = buy}
            ch.ShopModel:getCostTips(tmp)
        end
    end)
    
    -- 点击一次升几级
    widget:addDataProxy("upNum",function(evt)
        return Language.LV.."+"..upNum
    end, touchChangeEvent)
end)

-- 图腾详情 W_TutengXiangqing
zzy.BindManager:addCustomDataBind("tuteng/W_TutengXiangqing",function(widget,data)
    local totemChangeEvent = {}
    totemChangeEvent[ch.TotemModel.dataChangeEventType] = function(evt)
        if evt.id == data then
            return true
        else
            return false
        end
    end
    -- 图腾图标
    widget:addDataProxy("ttIcon",function(evt)
        return GameConfig.TotemConfig:getData(data).icon
    end)
    -- 图腾名字
    --暂时用宝物名称代替
    widget:addDataProxy("ttName",function(evt)
        return GameConfig.TotemConfig:getData(data).name
    end)
    -- 图腾描述
    widget:addDataProxy("ttDes",function(evt)
        return ch.TotemModel:getDesData(data)
    end)
    -- 图腾下一级描述
    widget:addDataProxy("ttNextDes",function(evt)
        if ch.TotemModel:ifLvMax(data) then
            return ch.TotemModel:getDesData(data,ch.TotemModel:getLevel(data)+1)
        else
            return ch.TotemModel:getDesData(data)
        end
    end)
    -- 图腾描述
    widget:addDataProxy("ttDesText",function(evt)
        return GameConfig.TotemConfig:getData(data).desc
    end)
    widget:addDataProxy("descImg",function(evt)
        local descImg = "res/icon/dot1.png"
        local tmpData = GameConfig.TotemConfig:getData(data)
        if tmpData.bigType == 7 or tmpData.bigType == 8 then
            descImg = GameConst.PETCARD_JOB[tmpData.smallType].icon_s
        end
        return descImg
    end)
    
    -- 图腾当前等级
    widget:addDataProxy("ttLv",function(evt)
        return ch.TotemModel:getLevel(data)
    end)
    -- 图腾等级上限
    widget:addDataProxy("ttLvMax",function(evt)
        return ch.TotemModel:getMaxLevel(data)
    end)
    -- 图腾描述2
    widget:addDataProxy("ttDes2",function(evt)
        return GameConfig.TotemConfig:getData(data).desc2
    end)
    widget:addDataProxy("isSenior",function(evt)
        return GameConfig.TotemConfig:getData(data).type == 2
    end)
    widget:addDataProxy("isBasic",function(evt)
        return GameConfig.TotemConfig:getData(data).type ~= 2
    end)
    widget:addDataProxy("curNoMax",function(evt)
        return ch.TotemModel:ifLvMax(data)
    end)
    widget:addDataProxy("curMax",function(evt)
        return not ch.TotemModel:ifLvMax(data)
    end)
end)


-- 图腾刷新项  N_TutengXUnit
zzy.BindManager:addCustomDataBind("tuteng/N_TutengXUnit",function(widget,data)
    local canTouchEvent = {}
    canTouchEvent[TotemRefreshViewType] = false
    widget:addDataProxy("data",function(evt)
        local ret = {}
        local totemid = "0"
        if data > 10 then
            totemid = ch.TotemModel:getrandTotems_senior()[data-10]
        else
            totemid = ch.TotemModel:_getrandTotems()[data]
        end
        ret.ttIdOk = totemid ~= "0"
        if totemid ~= "0" and totemid ~= nil then
            ret.ttIcon = GameConfig.TotemConfig:getData(totemid).icon
            ret.ttName = GameConfig.TotemConfig:getData(totemid).name
            ret.ttDes = ch.TotemModel:getDesData(totemid)
            ret.ttDesText = GameConfig.TotemConfig:getData(totemid).desc
            ret.ttId = totemid
            ret.isSenior = GameConfig.TotemConfig:getData(totemid).type == 2
            ret.price = ch.TotemModel:getCallDiamondPrice(GameConfig.TotemConfig:getData(totemid).type)
            ret.descImg = "res/icon/dot1.png"
            ret.backImage = ret.isSenior and "res/icon/card/aaui_diban_db_gaoji_xz.png" or "aaui_diban/Totem_Bg01.png"
            local tmpData = GameConfig.TotemConfig:getData(totemid)
            if tmpData.bigType == 7 or tmpData.bigType == 8 then
                ret.descImg = GameConst.PETCARD_JOB[tmpData.smallType].icon_s
            end
        else
            ret.ttIcon = GameConfig.TotemConfig:getData("1").icon
            ret.ttName = GameConfig.TotemConfig:getData("1").name
            ret.ttDes = ch.TotemModel:getDesData("1")
            ret.ttDesText = GameConfig.TotemConfig:getData("1").desc
            ret.ttId = totemid
            ret.isSenior = false
            ret.price = 0
            ret.descImg = "res/icon/dot1.png"
            ret.backImage = "aaui_diban/Totem_Bg01.png"
        end
        return ret
    end)
    
    widget:addDataProxy("canTouch",function(evt)
        if evt then
            return not evt.isRefreshing
        end
        return true
    end,canTouchEvent)
    
    widget:addDataProxy("canGet",function(evt)
        local totemid = "0"
        if data > 10 then
            totemid = ch.TotemModel:getrandTotems_senior()[data-10]
        else
            totemid = ch.TotemModel:_getrandTotems()[data]
        end
        if totemid == "0" then
            return false
        end
        local isEnough = ch.MoneyModel:getDiamond() >= ch.TotemModel:getCallDiamondPrice(GameConfig.TotemConfig:getData(totemid).type)
        if evt then
            return not evt.isRefreshing and isEnough
        end
        return isEnough
    end,canTouchEvent)
    -- 召唤图腾
    widget:addCommond("callNew",function(widget1,arg)
        local totemid = "0"
        if data > 10 then
            totemid = ch.TotemModel:getrandTotems_senior()[data-10]
        else
            totemid = ch.TotemModel:_getrandTotems()[data]
        end
        local buy = function()
            if GameConfig.TotemConfig:getData(totemid).type == 2 then
                ch.NetworkController:totemGet_senior(totemid,arg)
            elseif GameConfig.TotemConfig:getData(totemid).type == 1 then
                ch.NetworkController:totemGet(totemid,arg)
            end
            ch.UIManager:cleanGamePopupLayer(true,true)
            ch.SoundManager:play("gettuteng")
        end
        if arg == "1" then
            buy()
        else
            local tmp = {price = ch.TotemModel:getCallDiamondPrice(GameConfig.TotemConfig:getData(totemid).type),buy = buy}
            ch.ShopModel:getCostTips(tmp)
        end
    end)  
end)

-- 图腾召唤 W_TutengZhaohuan
zzy.BindManager:addCustomDataBind("tuteng/W_TutengZhaohuan",function(widget,data)
    --结束引导
    if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 9040 then
        ch.guide:endid(9040)
    end
    local totemChangeEvent = {}
    totemChangeEvent[ch.TotemModel.dataChangeEventType] = function(evt)
        if evt.id == data then
            return true
        else
            return false
        end
    end
    
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_TotemView_1
    end)
    
    -- 图腾图标
    widget:addDataProxy("ttIcon",function(evt)
        return GameConfig.TotemConfig:getData(data).icon
    end)
    -- 图腾名字
    widget:addDataProxy("ttName",function(evt)
        return GameConfig.TotemConfig:getData(data).name
    end)
    -- 图腾描述
    widget:addDataProxy("ttDes",function(evt)
        return ch.TotemModel:getDesData(data)
    end)
    -- 图腾描述
    widget:addDataProxy("ttDesText",function(evt)
        return GameConfig.TotemConfig:getData(data).desc
    end)
    -- 图腾当前等级
    widget:addDataProxy("ttLv",function(evt)
        return "1"
    end)
    -- 图腾等级上限
    widget:addDataProxy("ttLvMax",function(evt)
        return ch.TotemModel:getMaxLevel(data)
    end)
    -- 图腾描述2
    widget:addDataProxy("ttDes2",function(evt)
        return GameConfig.TotemConfig:getData(data).desc2
    end)
    widget:addDataProxy("descImg",function(evt)
        local descImg = "res/icon/dot1.png"
        local tmpData = GameConfig.TotemConfig:getData(data)
        if tmpData.bigType == 7 or tmpData.bigType == 8 then
            descImg = GameConst.PETCARD_JOB[tmpData.smallType].icon_s
        end
        return descImg
    end) 
    widget:addDataProxy("isSenior",function(evt)
        return GameConfig.TotemConfig:getData(data).type == 2
    end) 
    widget:addDataProxy("isBasic",function(evt)
        return GameConfig.TotemConfig:getData(data).type ~= 2
    end)
    -- 魂召唤价格
    widget:addDataProxy("soulPrice",function(evt)
        return "-"..ch.TotemModel:getCallSoulPrice(GameConfig.TotemConfig:getData(data).type)
    end)
    -- 钻石召唤价格
    widget:addDataProxy("diamondPrice",function(evt)
        return "-"..ch.TotemModel:getCallDiamondPrice(GameConfig.TotemConfig:getData(data).type)
    end)
    -- 魂是否充足
    widget:addDataProxy("soulEnough",function(evt)
        return ch.TotemModel:getCallSoulPrice(GameConfig.TotemConfig:getData(data).type)<= ch.MoneyModel:getSoul()
    end)
    -- 钻石是否充足
    widget:addDataProxy("diamondEnough",function(evt)
        return ch.TotemModel:getCallDiamondPrice(GameConfig.TotemConfig:getData(data).type)<=ch.MoneyModel:getDiamond()
    end)
    -- 召唤图腾
    widget:addCommond("callNew",function(widget1,arg)
        local buy = function()
            if GameConfig.TotemConfig:getData(data).type == 2 then
                ch.NetworkController:totemGet_senior(data,arg)
                ch.UIManager:cleanGamePopupLayer(true,true)
                ch.SoundManager:play("gettuteng")
            elseif GameConfig.TotemConfig:getData(data).type == 1 then
                ch.NetworkController:totemGet(data,arg)
                ch.UIManager:cleanGamePopupLayer(true,true)
                ch.SoundManager:play("gettuteng")
                if ch.TotemModel:getOwnTotemNum(1) == 1 then
                    ch.guide:play_guide(9100)
                end
            end
        end
        if arg == "1" then
            buy()
        else
            local tmp = {price = ch.TotemModel:getCallDiamondPrice(GameConfig.TotemConfig:getData(data).type),buy = buy}
            ch.ShopModel:getCostTips(tmp)
        end
    end)
end)

-- 图腾图鉴
zzy.BindManager:addFixedBind("tuteng/W_Tuteng_tujian", function(widget)
    widget:addDataProxy("items",function(evt)
        local items = {}
        for k,v in pairs(GameConfig.TotemConfig:getTable()) do
            table.insert(items,v.id)
        end
        table.sort(items,function(t1,t2)
            return tonumber(t1) < tonumber(t2)
        end)
        return items
    end)
end)

-- 图腾图鉴项
zzy.BindManager:addCustomDataBind("tuteng/W_Tuteng_jtItem",function(widget,data)
    local conf = GameConfig.TotemConfig:getData(data)
    widget:addDataProxy("icon",function(evt)
        return conf.icon
    end)
    widget:addDataProxy("name",function(evt)
        return conf.name
    end)
    widget:addDataProxy("desc",function(evt)
        return conf.desc0
    end)
    widget:addDataProxy("own",function(evt)
        return ch.TotemModel:isOwn(data)
    end)
    widget:addDataProxy("isSenior",function(evt)
        return conf.type == 2
    end)
    widget:addDataProxy("backImage",function(evt)
        if ch.TotemModel:isOwn(data) then
            if conf.type == 2 then
                return "res/icon/card/aaui_diban_db_gaoji_xz.png"
            else
                return "res/icon/card/aaui_diban_db_putong_xz_have.png"
            end
        else
            return "aaui_diban/Totem_Bg01.png"
        end
    end)
    widget:addDataProxy("descImg",function(evt)
        local descImg = "res/icon/dot1.png"
        local tmpData = GameConfig.TotemConfig:getData(data)
        if tmpData.bigType == 7 or tmpData.bigType == 8 then
            descImg = GameConst.PETCARD_JOB[tmpData.smallType].icon_s
        end
        return descImg
    end) 
end)

-- 神坛
zzy.BindManager:addFixedBind("tuteng/W_ShentanList", function(widget)
    local shentanChangeEvent = {}
    shentanChangeEvent[ch.ShentanModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.ShentanModel.dataType.level
        return ret
    end
    shentanChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.gods or evt.dataType == ch.MoneyModel.dataType.diamond    	
    end
    
    if ch.StatisticsModel:getMaxLevel() < GameConst.SSTONE_LEVEL then
        shentanChangeEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        	return evt.dataType == ch.LevelModel.dataType.curLevel
        end
    end
    
    local ListView_1 = zzy.CocosExtra.seekNodeByName(widget,"ListView_1")
    ListView_1:setPositionY(ListView_1:getPositionY())
    
    -- 升级消耗货币名字
    widget:addDataProxy("costName",function(evt)
        return GameConst.MSG_FJ_NAME[1].db90032
    end,shentanChangeEvent)
    
    -- 升级消耗货币图标
    widget:addDataProxy("costIcon",function(evt)
        return "res/icon/icon_shenling_3.png"
    end,shentanChangeEvent)
    
    -- 升级消耗货币图标
    widget:addDataProxy("costIconScale",function(evt)
        return 1.4
    end,shentanChangeEvent)
    
    -- 神灵数量
    widget:addDataProxy("gods",function(evt)
        local gods = ch.MoneyModel:getGods()
        --DEBUG("gods="..gods)
        return ch.MoneyModel:getGods()
    end,shentanChangeEvent)
    
    -- 重置
    widget:addCommond("godsReset",function()
        ch.UIManager:showMsgBox(2,true,GameConst.SHENTAN_RESET_TIP,function()
            local cost = 500
            local resetTimes = ch.ShentanModel:getResetTimes() or 0
            if resetTimes == 0 then
                cost = 0
            end
            
            ch.NetworkController:shentanReset(cost)
        end,nil,Language.MSG_BUTTON_OK,2)
    end)
    -- 重置价格
    widget:addDataProxy("resetCost",function(evt)
        local cost = 500
        local resetTimes = ch.ShentanModel:getResetTimes() or 0
        if resetTimes == 0 then
            cost = 0
        end
        
        return "x"..cost
    end,shentanChangeEvent)

    --[[
    widget:addScrollData("gods-num", "gods", 1, function(v)
        return ch.NumberHelper:toString(v)
    end,"N_MoneySouls:num_Soul")
    ]]
    
    -- 已拥有神坛ID列表
    local listInited = false
    widget:addDataProxy("ShentanList", function(evt)
         local items = {}
        for k,v in pairs(GameConfig.ShentanConfig:getTable()) do
            table.insert(items,v.sort)
        end
        
        items = {"4","5","2","3","1"}
        return items
    end,shentanChangeEvent)
    
    local shenTanOpenEvent = {}
    shenTanOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
        return evt.view == "tuteng/W_ShentanList"
    end

    -- listView高度
    widget:addDataProxy("listHeight", function(evt)
        return 600
    end,shenTanOpenEvent)
    
    --帮助按钮
    widget:addCommond("openHelp",function(widget,arg)
        ch.UIManager:showGamePopup("tuteng/W_ShentanFaq")
    end)
    
    --关闭按钮
    widget:addCommond("popClose",function(widget,arg)
        widget:destory()
    end)
end)

-- 自定义数据绑定
-- 神坛Item
zzy.BindManager:addCustomDataBind("tuteng/W_ShentanUnit",function(widget,data)
    --DEBUG("[W_ShentanUnit]data="..data)
    local shentanChangeEvent = {}
    shentanChangeEvent[ch.ShentanModel.dataChangeEventType] = function(evt)
        if evt.id == data then
            return true
        else
            return false
        end
    end
    local touchChangeEvent = {}
    touchChangeEvent[ch.ShentanModel.dataChangeEventType] = function(evt)
        if evt.id == data then
            return true
        else
            return false
        end
    end
    touchChangeEvent[ch.MoneyModel.dataChangeEventType] = false
    touchChangeEvent[CHANG_DIAMOND_EVENT] = false
    touchChangeEvent[CHANG_UPNUM_EVENT] = false
    
    -- 升级消耗货币图标
    widget:addDataProxy("costIcon",function(evt)
        return "res/icon/icon_shenling_3.png"
    end,shentanChangeEvent)
    
    local labelDesc = zzy.CocosExtra.seekNodeByName(widget,"Text_des1")
    labelDesc:setMaxLineWidth(250)
    
    widget:addDataProxy("data",function(evt)
        local tmpPrice1 = ch.ShentanModel:getLevelUpCost(data)
        local ret = {}
        ret.ttIcon = GameConfig.ShentanConfig:getData(data).icon
        ret.ttName = GameConfig.ShentanConfig:getData(data).name
        ret.ttDes = ch.ShentanModel:getDesData(data)
        ret.ttDesText = GameConfig.ShentanConfig:getData(data).desc
        ret.ttLv = ch.ShentanModel:getLevel(data)
        ret.ttLvMax = ch.ShentanModel:getMaxLevel(data)
        ret.ifLvMax = ch.ShentanModel:ifLvMax(data)
        ret.ttLvUpPrice = "-"..ch.NumberHelper:toString(tmpPrice1)
        ret.ifOpen = ch.ShentanModel:getMaxLevel(data) > 0
        ret.ifNotOpen = ch.ShentanModel:getMaxLevel(data) == 0
        ret.openLevel = string.format(Language.SHENTAN_OPENLEVEL, ch.ShentanModel:getNextMaxLevel(data))
        ret.canup = (tmpPrice1 <= ch.MoneyModel:getGods()) and (not ret.ifLvMax)
        ret.isGods = not ret.ifLvMax
        ret.isDiamond = not ret.isGods
        ret.stId = data
        
        return ret
    end,touchChangeEvent)
    
    -- 升级0为钻石1为神灵
    widget:addCommond("levelUp",function(widget,arg)
        ch.NetworkController:shentanLevelUp(data,arg)
        ch.SoundManager:play("ttlvup")
    end)
end)

-- 神坛详情
zzy.BindManager:addCustomDataBind("tuteng/W_ShentanXiangqing",function(widget,data)
    local shentanChangeEvent = {}
    shentanChangeEvent[ch.ShentanModel.dataChangeEventType] = function(evt)
        if evt.id == data then
            return true
        else
            return false
        end
    end
    -- 神坛图标
    widget:addDataProxy("ttIcon",function(evt)
        return GameConfig.ShentanConfig:getData(data).icon
    end)
    -- 神坛名字
    --暂时用宝物名称代替
    widget:addDataProxy("ttName",function(evt)
        return GameConfig.ShentanConfig:getData(data).name
    end)
    -- 神坛描述
    widget:addDataProxy("ttDes",function(evt)
        return ch.ShentanModel:getDesData(data)
    end)
    -- 神坛下一级描述
    widget:addDataProxy("ttNextDes",function(evt)
        if not ch.ShentanModel:ifLvMax(data) then
            return ch.ShentanModel:getDesData(data,ch.ShentanModel:getLevel(data)+1)
        else
            return ch.ShentanModel:getDesData(data)
        end
    end)
    -- 神坛描述
    widget:addDataProxy("ttDesText",function(evt)
        return GameConfig.ShentanConfig:getData(data).desc
    end)
    -- 神坛当前等级
    widget:addDataProxy("ttLv",function(evt)
        return ch.ShentanModel:getLevel(data)
    end)
    -- 神坛等级上限
    widget:addDataProxy("ttLvMax",function(evt)
        return ch.ShentanModel:getMaxLevel(data)
    end)
    -- 神坛描述2
    widget:addDataProxy("ttDes2",function(evt)
        return string.format(Language.SHENTAN_MAXLEVEL, ch.ShentanModel:getNextMaxLevel(data))
    end)
    widget:addDataProxy("curNoMax",function(evt)
        return not ch.ShentanModel:ifLvMax(data)
    end)
    widget:addDataProxy("curMax",function(evt)
        return ch.ShentanModel:ifLvMax(data)
    end)
end)

-- 自定义数据绑定
-- 神坛Item
zzy.BindManager:addFixedBind("tuteng/W_ShentanFaq",function(widget)
    --关闭按钮
    widget:addCommond("popClose",function(widget,arg)
        widget:destory()
    end)
    widget:addDataProxy("desc",function(evt)
        --return string.format(Language.SHENTAN_GUIZE_DESC, GameConfig.SHENTAN_OPEN_LEVEL, GameConst.REBORN_GODS_NUM, GameConst.GUILDWAR_GODS_NUM)
        return Language.SHENTAN_GUIZE_DESC
    end)
end)
