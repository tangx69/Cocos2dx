local upNum = 1
local upNumTable = {1,25,100,1000}
local tmpNum = 0
local CHANG_UPNUM_EVENT = "MAGIC_CHANG_UPNUM"
-- 复选框
local is10 = false
local is100 = false
--镀金选中宝物
local selectId = 0
local CHANGE_SELECT_EVENT = "MAGIC_CHANGE_SELECT"
local magicSelectId = "1"

--转移圣光界面
local showPanel = false
local SHOW_PANEL_EVENT = "SHOW_PANEL"
-- 转移界面播光效
local EFFECT_PLAY_TRANS_EVENT = "EFFECT_PLAY_TRANS"
-- 镀金转移界面复选框
local select10 = false
local select100 = false
local removeNum = 1
local CHANG_REMOVENUM_EVENT = "MAGIC_CHANG_REMOVENUM"

-- 固有绑定
-- 宝物打开界面
zzy.BindManager:addFixedBind("baowu/W_BaowuList", function(widget)
    local totalDpsChangedEvent = {}
    totalDpsChangedEvent[ch.MagicModel.dataChangeEventType] = false
    
    totalDpsChangedEvent[ch.RunicModel.SkillDurationStatusChangedEventType] = function(evt)
        return evt.id == 1 or evt.id == "1"
    end
    totalDpsChangedEvent[ch.RunicModel.dataChangeEventType] = false
    
    totalDpsChangedEvent[ch.BuffModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.BuffModel.dataType.card or 
    	   evt.dataType == ch.BuffModel.dataType.inspire
    end
    totalDpsChangedEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.PetCardModel.dataType.level
    end
    
    local magicChangedEvent = {}
    magicChangedEvent[ch.MagicModel.dataChangeEventType] = false
    magicChangedEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.star
        return ret
    end
    
    local checkedChangedEvent = {}
    checkedChangedEvent[CHANG_UPNUM_EVENT] = false
    
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.gold
        return ret
    end
    local magicOpenEvent = {}
    magicOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
        return evt.view == "baowu/W_BaowuList"
    end
    
    local oldDPS = ch.MagicModel:getTotalDPS()
    --总DPS
    widget:addDataProxy("allDPS-num", function(evt)
        return  ch.LongDouble:floor(ch.MagicModel:getTotalDPS())
    end,totalDpsChangedEvent)
    widget:addScrollData("allDPS-num", "allDPS", 1, function(v)
        return ch.NumberHelper:toString(v)
    end,"num_dps")
    -- 总DMG
    widget:addDataProxy("allDMG-num",function(evt)
        return ch.LongDouble:floor(ch.RunicModel:getDPS(ch.RunicModel:getLevel()))
    end,totalDpsChangedEvent)
    widget:addScrollData("allDMG-num", "allDMG", 1, function(v)
        return ch.NumberHelper:toString(v)
    end,"num_dmg")
--    -- 10倍复选框
--    widget:addDataProxy("ifCheck1",function(evt)
--        return is10
--    end,checkedChangedEvent)
--    widget:addDataProxy("ifnotCheck1",function(evt)
--        return not is10
--    end,checkedChangedEvent)
--    
--    -- 100倍复选框
--    widget:addDataProxy("ifCheck2",function(evt)
--        return is100
--    end,checkedChangedEvent)
    -- 宝物列表    
    local listInited = false
    widget:addDataProxy("magicList", function(evt)
        local data = {}
        for k,v in ipairs(ch.MagicModel:getCurMagics()) do
            table.insert(data,{index = 1,value = v,isMultiple = true})
        end
        -- 圣光守护（可能不用了）
--        if ch.MagicModel:getTotalStar() > 0 then
--            table.insert(data,{index = 2,value = 0,isMultiple = true})
--        end
        data.autoScrollDown = listInited
        listInited = true
        return data
    end,magicChangedEvent)
    widget:addDataProxy("ifOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel() > 10
    end)
    -- 一次升级等级
    widget:addDataProxy("upNum",function(evt)
        return "X "..upNum
    end,checkedChangedEvent)
    widget:addCommond("check",function(widget,arg)
        tmpNum = tmpNum + 1
        upNum = upNumTable[tmpNum%4+1]
        zzy.EventManager:dispatchByType(CHANG_UPNUM_EVENT) 
    end)
    if ch.StatisticsModel:getMaxLevel() <= 10 then
        widget:listen(ch.LevelModel.dataChangeEventType,function(obj,evt)
            if evt.dataType == ch.LevelModel.dataType.curLevel then
                widget:noticeDataChange("ifOpen")
            end
        end)
    end
    
  -- 选中取消复选框10状态 对应操作
--    widget:addCommond("check",function(widget,arg)
--        if arg == "-10" then
--            is10 = false
--            if not is100 then
--                upNum = 1
--                zzy.EventManager:dispatchByType(CHANG_UPNUM_EVENT)
--            end
--        elseif arg == "10" then
--            is100 = false
--            is10 = true
--            upNum = GameConst.MGAIC_UPNUM
--            zzy.EventManager:dispatchByType(CHANG_UPNUM_EVENT)
--        elseif arg == "-100" then
--            is100 = false
--            if not is10 then
--                upNum = 1
--                zzy.EventManager:dispatchByType(CHANG_UPNUM_EVENT)
--            end
--        elseif arg == "100" then
--            is10 = false
--            is100 = true
--            upNum = 100
--            zzy.EventManager:dispatchByType(CHANG_UPNUM_EVENT)
--        end
--    end)
    -- 上按钮可见
    widget:addDataProxy("upVisible", function(evt)
        if evt then
            return evt.popType == ch.UIManager.popType.HalfOpen
        else
            return true
        end
    end,magicOpenEvent)
    -- 下按钮可见
    widget:addDataProxy("downVisible", function(evt)
        if evt then
            return evt.popType ~= ch.UIManager.popType.HalfOpen
        else
            return false
        end
    end,magicOpenEvent)
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
    end,magicOpenEvent)
end)

-- 宝物Item
zzy.BindManager:addCustomDataBind("baowu/W_BaowuUnitStar",function(widget,data)
    widget:addCommond("openStar",function()
        ch.UIManager:cleanGamePopupLayer(true)
        if ch.MoneyModel:getStar()>0 then
            ch.UIManager:showGamePopup("baowu/W_BaowuStarget")
        else
            ch.UIManager:showGamePopup("baowu/W_BaowuStar")
        end
    end)
end)

-- 自定义数据绑定
-- 宝物Item
zzy.BindManager:addCustomDataBind("baowu/W_BaowuUnit",function(widget,data)
    local magicChangedEvent = {}
    magicChangedEvent[ch.MagicModel.dataChangeEventType] = false
--    local touchChangeEvent = {}
--    touchChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
--    	return evt.dataType == ch.MoneyModel.dataType.gold
--    end
--    touchChangeEvent[CHANG_UPNUM_EVENT] = false
    
--    local numChangeEvent ={}
--    numChangeEvent[CHANG_UPNUM_EVENT] = false
    
    local levelUpChangeEvent = {}
    levelUpChangeEvent[ch.MagicModel.dataChangeEventType] = function(evt)
        return evt.id == data or evt.id == 0 
    end
    levelUpChangeEvent[CHANG_UPNUM_EVENT] = false
    local cardChangeEvent = {}
    cardChangeEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.PetCardModel.dataType.level
    end
    
    -- 宝物ID
    widget:addDataProxy("magicId",function(evt)
        return tostring(data)
    end)
    -- 宝物图标
    widget:addDataProxy("magicIcon",function(evt)
        return GameConfig.MagicConfig:getData(data).icon
    end)
    -- 是否有对应卡牌
    widget:addDataProxy("ifCard",function(evt)
        return ch.PetCardModel:addMagicRatio(data)>1
    end,cardChangeEvent)
    -- 宝物星级
    widget:addDataProxy("magicStar",function(evt)
        return ch.MagicModel:getStar(data)
    end,levelUpChangeEvent)
    -- 宝物名称
    widget:addDataProxy("magicName",function(evt)
        local per = ch.LongDouble:floor(ch.MagicModel:getDPS(data))/ch.MagicModel:getTotalDPSWithoutBuff()
        per = per:toNumber()
        per =  math.floor(1000*per)/10
        return string.format("%s(%.1f%%)",GameConfig.MagicConfig:getData(data).name,per)
    end,magicChangedEvent)
    -- 宝物等级
    widget:addDataProxy("magicLv",function(evt)
        return ch.MagicModel:getLevel(data)
    end,levelUpChangeEvent)
    -- 宝物DPS
    widget:addDataProxy("magicDPS",function(evt)
        return ch.NumberHelper:toString(
            ch.LongDouble:floor(ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data))))
    end,levelUpChangeEvent)
    -- 宝物是否获得
    widget:addDataProxy("ifNoGet",function(evt)
        return ch.MagicModel:getLevel(data) < 1
    end,levelUpChangeEvent)
    -- 宝物是否镀金
    widget:addDataProxy("ifGold",function(evt)
        return ch.MagicModel:getStar(data) > 0
    end,levelUpChangeEvent)
    -- 技能0图标
    local icon = ch.MagicModel:getSkillIcon1(data)
    widget:addDataProxy("skillIcon0",function(evt)
        return icon
    end,levelUpChangeEvent)
    -- 技能1图标
    widget:addDataProxy("skillIcon1",function(evt)
        return ch.MagicModel:getSkillIcon1(data)
    end,levelUpChangeEvent)
    -- 技能1解锁等级
--    widget:addDataProxy("skillNum1",function(evt)
--        if ch.MagicModel:_getCurSkill(data)<7 then
--        	return GameConst.MGAIC_CONFIG_SKILL_LEVELS[ch.MagicModel:_getCurSkill(data)]
--        else
--            return ch.MagicModel:getAutoSkillUnlockLevel(data)
--        end
--    end,magicChangedEvent)
    -- 技能2图标
    widget:addDataProxy("skillIcon2",function(evt)
--        local skillType = GameConfig.MagicConfig:getData(data).sk6type
--        return GameConst.SKILL_ICON[skillType]
        return ch.MagicModel:getUnlockIcon(data)
    end,levelUpChangeEvent)
    -- 技能2解锁等级
    widget:addDataProxy("skillNum2",function(evt)
--        return GameConst.MGAIC_CONFIG_SKILL_LEVELS[6]   
        return ch.MagicModel:getUnlockLevel(data) 
    end,levelUpChangeEvent)
    -- 技能2是否解锁
    widget:addDataProxy("ifNoOpen2",function(evt)
--        return ch.MagicModel:getLevel(data) < GameConst.MGAIC_CONFIG_SKILL_LEVELS[6]
        return true
    end)
    
    -- 升级提升DPS
    widget:addDataProxy("lvUpDPS",function(evt)
        if ch.MagicModel:getLevel(data) <= 0 then
            return "+"..ch.NumberHelper:toString(
                ch.LongDouble:floor(
            ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data)+1)-ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data))))
        else
            return "+"..ch.NumberHelper:toString(
            ch.LongDouble:floor(
            ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data)+upNum)-ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data))))
        end
    end,levelUpChangeEvent)
    -- 点击一次升几级
    widget:addDataProxy("upNum",function(evt)
        return Language.LV.."+"..upNum
    end)
    
    local textAction = {}
    -- 宝物升级
    widget:addCommond("levelUp",function()
        local upDPS = "+"..ch.NumberHelper:toString(ch.LongDouble:floor(ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data)+upNum)-ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data))))
        local tmpa = 1
        if ch.MagicModel:_getCurSkill(data)~= -1 and ch.MagicModel:_getCurSkill(data) ~= -2 then
            tmpa = GameConst.MGAIC_CONFIG_SKILL_LEVELS[ch.MagicModel:_getCurSkill(data)]
        else
            tmpa = ch.MagicModel:getAutoSkillUnlockLevel(data)
        end
--        local tmpb = ch.MagicModel:getLevel(data) < GameConst.MGAIC_CONFIG_SKILL_LEVELS[6]
        
        ch.NetworkController:magicLevelUp(data,upNum)
        
        widget:playEffect("levelUpBWEffect",false)

        ch.SoundManager:play("levup")
        local level = ch.MagicModel:getLevel(data)
        if level >= tmpa then
            local action = cc.CSLoader:createTimeline("res/ui/baowu/W_BaowuUnit.csb")
            widget:runAction(action)
            --action:gotoFrameAndPlay(0,20,false) --tgx 连续点击升级宝物.会因为动画崩溃
            icon = ch.MagicModel:getSkillIcon1(data)
            widget:playEffect("unlockSkillbBWEffect",false)          
        end
        
        if ch.fightRoleLayer:getMainRole() then
            if level >= tmpa then 
                ch.fightRoleLayer:getMainRole():showMagicEffect("tx_shengjitexiao","lvlup")
            else
                ch.fightRoleLayer:getMainRole():showMagicEffect("tx_jueseshengji","Animation1")
            end
        end
        -- 战斗力提升飘字
        local text = ccui.TextBMFont:create(upDPS, "res/ui/aaui_font/font_flow.fnt")
        table.insert(textAction,text)
        widget:addChild(text)
        text:setPosition(230,10)
        text:setAnchorPoint(0,0)
        text:setScale(1)
        local time = 1
        local delayTime = cc.DelayTime:create(0.5)
        text:runAction(cc.EaseOut:create(cc.MoveTo:create(1, cc.p(230,80)), 1))
        text:runAction(cc.Sequence:create(delayTime,cc.EaseOut:create(cc.FadeOut:create(1), 0.5), cc.CallFunc:create(function()
                text:removeFromParent()
                for k,v in pairs(textAction) do
                if v == text then
                    table.remove(textAction,k)
                    return
                end
            end
            end)))
        text:setLocalZOrder(1000)
        
--        if ch.MagicModel:getLevel(data) >= GameConst.MGAIC_CONFIG_SKILL_LEVELS[6] and tmpb then
--            widget:playEffect("unlockSkillbBWEffect",false)
--        end
        --结束引导(防止出错)
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10060 then
            ch.guide:endid(10060)
        end
   end)
    -- 购买价格
    
    
    local lastLevel = ch.MagicModel:getLevel(data)
    local lastNum = upNum
    local levelCost1 = ch.MagicModel:getLevelUpCost(data,1)
    local levelCostNum = levelCost1
    if upNum ~= 1 then
        levelCostNum = ch.MagicModel:getLevelUpCost(data,upNum)
    end
    widget:addCacheRefreshFunc(function()
        levelCost1 = ch.MagicModel:getLevelUpCost(data,1)
        if upNum == 1 then
            levelCostNum = levelCost1
        else
            levelCostNum = ch.MagicModel:getLevelUpCost(data,upNum)
        end
    end)

    -- 升级价格
    widget:addDataProxy("lvUpPrice",function(evt)
        return "-"..ch.NumberHelper:toString(levelCostNum)
    end)

    widget:addDataProxy("buyPirce",function(evt)
        return "-"..ch.NumberHelper:toString(levelCost1)
    end)

    widget:listen(ch.MoneyModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.MoneyModel.dataType.gold then
            if lastLevel ~= ch.MagicModel:getLevel(data) then
                lastLevel = ch.MagicModel:getLevel(data)
                levelCost1 = ch.MagicModel:getLevelUpCost(data,1)
                levelCostNum = levelCost1
                if upNum ~= 1 then
                    levelCostNum = ch.MagicModel:getLevelUpCost(data,upNum)
                end
                widget:noticeDataChange("lvUpPrice")
            end
            widget:noticeDataChange("ifCanBuy")
        end
    end)
    widget:listen(CHANG_UPNUM_EVENT,function(obj,evt)
        if lastNum ~= upNum then
            lastNum = upNum
            if upNum == 1 then
                levelCostNum = levelCost1
            else
                levelCostNum = ch.MagicModel:getLevelUpCost(data,upNum)
            end
            widget:noticeDataChange("ifCanBuy")
            widget:noticeDataChange("lvUpPrice")
            widget:noticeDataChange("upNum")
        end
    end)
    
    -- 是否达到购买价格
    widget:addDataProxy("ifCanBuy",function(evt)
        
        if ch.MagicModel:getLevel(data)<1 then
        -- 购买
            if ch.MoneyModel:getGold() >= levelCost1 then
                widget:playEffect("tagNew",true)
                return true
            end
            widget:stopEffect("tagNew")
            return false
        else
        -- 升级
            return ch.MoneyModel:getGold() >= levelCostNum
        end
    end)
    -- 宝物购买
    widget:addCommond("buyNew",function()
        local upDPS = "+"..ch.NumberHelper:toString(ch.LongDouble:floor(ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data)+1)-ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data))))
        ch.NetworkController:magicLevelUp(data,1)
        widget:playEffect("getBaoWuEffect",false)
        ch.SoundManager:play("getbaowu")
        if ch.fightRoleLayer:getMainRole() then
            ch.fightRoleLayer:getMainRole():showMagicEffect("tx_juesehuode","Animation1")
        end
        
        -- 战斗力提升飘字
        local text = ccui.TextBMFont:create(upDPS, "res/ui/aaui_font/font_flow.fnt")
        table.insert(textAction,text)
        widget:addChild(text)
        text:setPosition(230,10)
        text:setAnchorPoint(0,0)
        text:setScale(1)
        local time = 1
        local delayTime = cc.DelayTime:create(0.5)
        text:runAction(cc.EaseOut:create(cc.MoveTo:create(1, cc.p(230,80)), 1))
        text:runAction(cc.Sequence:create(delayTime,cc.EaseOut:create(cc.FadeOut:create(1), 0.5), cc.CallFunc:create(function()
            text:removeFromParent()
            for k,v in pairs(textAction) do
                if v == text then
                    table.remove(textAction,k)
                    return
                end
            end
        end)))
        text:setLocalZOrder(1000)
        
        --结束引导
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10060 then
            ch.guide:endid(10060)
        end
    end)
    
    -- 关闭界面时移除上飘动画
    widget:addCacheRefreshFunc(nil,function()
        for k,v in pairs(textAction) do
            v:removeFromParent()
        end
        textAction = {}
    end)
    
    local Panel_skill = zzy.CocosExtra.seekNodeByName(widget, "Panel_skill")
    Panel_skill:setVisible(not IS_BANHAO)
    
    -- 第一个技能是否解锁
    widget:addDataProxy("ifOpenOne",function(evt)
        return ch.MagicModel:getLevel(data) >= GameConst.MGAIC_CONFIG_SKILL_LEVELS[1] and (not IS_BANHAO)
    end,levelUpChangeEvent)
    -- 技能a是否显示
    widget:addDataProxy("ifUnlockOne",function(evt)
        return ch.MagicModel:getUnlockLevel(data) ~= GameConst.MGAIC_CONFIG_SKILL_LEVELS[2] and (not IS_BANHAO)
    end,levelUpChangeEvent)
end)

-- 宝物详情界面
zzy.BindManager:addCustomDataBind("baowu/W_BaowuDetail",function(widget,data)
    local magicChangeEvent = {}
    magicChangeEvent[ch.MagicModel.dataChangeEventType] = function(evt)
        return evt.id == data
    end
    local cardChangeEvent = {}
    cardChangeEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.PetCardModel.dataType.level
    end
    
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_MagicView_1
    end)
    
    -- 宝物ID
    widget:addDataProxy("magicId",function(evt)
        return tostring(data)
    end)
    -- 宝物图标
    widget:addDataProxy("magicIcon",function(evt)
        return GameConfig.MagicConfig:getData(data).icon
    end)
    -- 宝物名称
    widget:addDataProxy("magicName",function(evt)
        return GameConfig.MagicConfig:getData(data).name
    end)
    -- 宝物等级
    widget:addDataProxy("magicLv",function(evt)
        return ch.MagicModel:getLevel(data)
    end,magicChangeEvent)
    -- 宝物DPS
    widget:addDataProxy("magicDPS",function(evt)
        return ch.NumberHelper:toString(ch.LongDouble:floor(ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data))))
    end,magicChangeEvent)
    -- 宝物下级DPS
    widget:addDataProxy("magicNextDPS",function(evt)
        return ch.NumberHelper:toString(ch.LongDouble:floor(ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data)+1)))
    end,magicChangeEvent)
    -- 宝物DPS占比
    widget:addDataProxy("magicRatioDPS",function(evt)
        local per = ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data))/ch.MagicModel:getTotalDPSWithoutBuff()
        per = per:toNumber()
        return string.format("%.1f%%", math.floor(1000*per)/10)
    end,magicChangeEvent)
    -- 宝物描述2
    widget:addDataProxy("magicDes",function(evt)
        return GameConfig.MagicConfig:getData(data).desc
    end)
    -- 宝物星级
    widget:addDataProxy("magicStar",function(evt)
        return ch.MagicModel:getStar(data)
    end,magicChangeEvent)
    -- 宝物星级提供DPS
    widget:addDataProxy("starDPS",function(evt)
--        return ch.NumberHelper:toString(math.floor(ch.MagicModel:getDPS(data,ch.MagicModel:getLevel(data))))

        local ratio = GameConst.MGAIC_STAR_RATIO + ch.TotemModel:getTotemSkillData(1,7)
        if ch.AltarModel:getAltarByType(3).level > 0 then
            ratio = ratio * ch.AltarModel:getFinalEffect(3)
        end
        return "+"..ch.NumberHelper:multiple(ratio*ch.MagicModel:getStar(data)*100,1000)
        
--return "+"..ch.NumberHelper:multiple((GameConst.MGAIC_STAR_RATIO + ch.TotemModel:getTotemSkillData(1,7))*ch.MagicModel:getStar(data)*100,1000)
    end,magicChangeEvent)
    -- 卡牌提供DPS
    widget:addDataProxy("cardDPS",function(evt)
        return string.format("+%.2f%%",(ch.PetCardModel:addMagicRatio(data)-1)*100)
    end,cardChangeEvent)
    -- 是否有对应卡牌
    widget:addDataProxy("ifCard",function(evt)
        return ch.PetCardModel:addMagicRatio(data)>1
    end,cardChangeEvent)
    -- 转移镀金魂价格
    widget:addDataProxy("removePrice",function(evt)
        return "200"
    end,magicChangeEvent)
    -- 宝物技能列表
    widget:addDataProxy("skillList",function(evt)
        return {{id=data,index=1},{id=data,index=2},{id=data,index=3},{id=data,index=4},{id=data,index=5},{id=data,index=6},{id=data,index = 7},{id=data,index = 8},{id=data,index=-1},{id = data,index=-2}}
    end,magicChangeEvent)
    -- 是否镀金
    widget:addDataProxy("ifGold",function(evt)
        return ch.MagicModel:getStar(data) > 0
    end,magicChangeEvent)
    -- 转移镀金
    widget:addCommond("removeStar",function()
        ch.MagicModel:getRemoveMagic(data)
        ch.MagicModel:addStar(ch.MagicModel:getRemoveMagicID(),1)
        ch.MagicModel:addStar(data, -1)
        ch.UIManager:showGamePopup("baowu/W_BaowuStarremove", data)
    end)
end)

-- 宝物技能items
zzy.BindManager:addCustomDataBind("baowu/W_BaowuSkillunit",function(widget,data)
    local config = GameConfig.MagicConfig:getData(data.id)
    --local index = data.index > 6 and 1 or data.index
    --local skillType = config["sk".. index .."type"]
    
    local index = data.index
    local skillType = 1
    local value = 0
    if data.index == -1 then
        skillType = table.maxn(GameConst.SKILL_ICON)-1
    elseif data.index == -2 then
        skillType = table.maxn(GameConst.SKILL_ICON)
    else
        skillType = config["sk".. index .."type"]
        value = config["sk".. index .."value"]/100
    end    
    
    -- 技能图标
    widget:addDataProxy("skillIcon",function(evt)
        return ch.MagicModel:getSkillIconByType(skillType,value)
    end) 
    -- 技能名称
    widget:addDataProxy("skillName",function(evt)
        return GameConst.SKILL_NAME[skillType]
    end) 
    -- 技能解锁等级
    widget:addDataProxy("skillNum",function(evt)
--        if data.index ~= GameConst.MGAIC_AUTO_ADD_SKILL_INDEX1 then
--            return GameConst.MGAIC_CONFIG_SKILL_LEVELS[tonumber(data.index)]
--        else
--            return ch.MagicModel:getAutoSkillUnlockLevel(data.id)
--        end
        if data.index == GameConst.MGAIC_AUTO_ADD_SKILL_INDEX1 then
            return GameConst.MGAIC_AUTO_ADD_SKILL[1].level
        elseif data.index == GameConst.MGAIC_AUTO_ADD_SKILL_INDEX2 then
            return GameConst.MGAIC_AUTO_ADD_SKILL[2].level
        else
            return GameConst.MGAIC_CONFIG_SKILL_LEVELS[tonumber(data.index)]
        end
    end)
    -- 技能是否解锁
    widget:addDataProxy("ifNoOpen",function(evt)
        if data.index == GameConst.MGAIC_AUTO_ADD_SKILL_INDEX1 then
            return ch.MagicModel:getLevel(data.id)< GameConst.MGAIC_AUTO_ADD_SKILL[1].level
        elseif data.index == GameConst.MGAIC_AUTO_ADD_SKILL_INDEX2 then
            return ch.MagicModel:getLevel(data.id)< GameConst.MGAIC_AUTO_ADD_SKILL[2].level
        else
            return ch.MagicModel:getLevel(data.id) < GameConst.MGAIC_CONFIG_SKILL_LEVELS[tonumber(data.index)]
        end
    end)
    -- 技能描述
    widget:addDataProxy("skillDes",function(evt)
        return ch.MagicModel:getSkillDesc(data.id,data.index,1)
    end)
    
    --版号
    local unlocktext_0 = zzy.CocosExtra.seekNodeByName(widget, "unlocktext_0")
    if IS_BANHAO and unlocktext_0 then
        unlocktext_0:setFontSize(18)
        unlocktext_0:setFontName("aaui_font/ch.ttf")
        unlocktext_0:setString(Language.LV)
    end
end)

-- 宝物镀金
zzy.BindManager:addFixedBind("baowu/W_BaowuStar",function(widget)
    local magicChangedEvent = {}
    magicChangedEvent[CHANGE_SELECT_EVENT] = false
    magicChangedEvent[ch.MagicModel.dataChangeEventType] = function(evt)
        return evt.id == magicSelectId
    end
    
    local selectedChangedEvent = {}
    selectedChangedEvent[CHANGE_SELECT_EVENT] = false
    selectId = 0
    local showChangedEvent = {}
    showChangedEvent[SHOW_PANEL_EVENT] = false
    showChangedEvent[CHANGE_SELECT_EVENT] = false
    showPanel = false
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.star or evt.dataType == ch.MoneyModel.dataType.diamond or evt.dataType == ch.MoneyModel.dataType.soul 
    end
    moneyChangeEvent[CHANG_REMOVENUM_EVENT] = false
    moneyChangeEvent[CHANGE_SELECT_EVENT] = false
    moneyChangeEvent[ch.MagicModel.dataChangeEventType] = function(evt)
        return evt.id == magicSelectId
    end
    
    local starSoulChangeEvent = {}
    starSoulChangeEvent[ch.ShopModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ShopModel.dataType.star or evt.dataType == ch.ShopModel.dataType.all
    end
    starSoulChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.soul
    end
    
    local starRemoveBtnEvent = {}
    starRemoveBtnEvent[ch.ShopModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ShopModel.dataType.star or evt.dataType == ch.ShopModel.dataType.all
    end
    starRemoveBtnEvent[CHANGE_SELECT_EVENT] = false
    
    local selectRemoveEvent = {}
    selectRemoveEvent[CHANG_REMOVENUM_EVENT] = false
    
    -- 标题
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_MagicView_2
    end)
    -- 总圣光数量
    widget:addDataProxy("starNum",function(evt)
        return ch.MagicModel:getTotalStar()
    end)
    
    -- 免费转移按钮
    widget:addDataProxy("ifCost",function(evt)
        return ch.MagicModel:getStar(magicSelectId)>0 and ch.ShopModel:getStarSoulCount() > 0
    end,starRemoveBtnEvent)
    -- 钻石转移按钮
    widget:addDataProxy("ifDiamond",function(evt)
        return ch.MagicModel:getStar(magicSelectId)>0 and ch.ShopModel:getStarSoulCount() <= 0
    end,starRemoveBtnEvent)
    -- 复选框
    widget:addDataProxy("ifCanCheck",function(evt)
        return ch.MagicModel:getStar(magicSelectId)>0
    end,starRemoveBtnEvent)
    
    -- 选中转移10次
    widget:addDataProxy("ifSelect1",function(evt)
        return select10
    end,selectRemoveEvent)
    -- 选中转移全部
    widget:addDataProxy("ifSelect2",function(evt)
        return select100
    end,selectRemoveEvent)
    
    -- 复选框
    widget:addCommond("select",function(widget,arg)
        if arg == "-10" then
            select10 = false
            if not select100 then
                removeNum = 1
                zzy.EventManager:dispatchByType(CHANG_REMOVENUM_EVENT)
            end
        elseif arg == "10" then
            select100 = false
            select10 = true
            removeNum = 10
            zzy.EventManager:dispatchByType(CHANG_REMOVENUM_EVENT)
        elseif arg == "-100" then
            select100 = false
            if not select10 then
                removeNum = 1
                zzy.EventManager:dispatchByType(CHANG_REMOVENUM_EVENT)
            end
        elseif arg == "100" then
            select10 = false
            select100 = true
            removeNum = 100
            zzy.EventManager:dispatchByType(CHANG_REMOVENUM_EVENT)
        end
    end)
    
    
    -- 是否有分配的镀金次数
    widget:addDataProxy("ifStar",function(evt)
        return ch.MoneyModel:getStar() > 0
    end,moneyChangeEvent)
    -- 随机加上圣光
    widget:addCommond("randStars",function()
        ch.NetworkController:magicStar()
    end)
    -- 描述1
    widget:addDataProxy("desc1",function(evt)
        return GameConst.MGAIC_STAR_DESC1
    end)
    -- 描述2
    widget:addDataProxy("desc2",function(evt)
        return GameConst.MGAIC_STAR_DESC2
    end)
    -- 宝物ID
    widget:addDataProxy("magicId",function(evt)
        return selectId
    end,selectedChangedEvent)
    -- 宝物图标
    widget:addDataProxy("magicIcon",function(evt)
        return GameConfig.MagicConfig:getData(magicSelectId).icon
    end,selectedChangedEvent)
    -- 宝物名称
    widget:addDataProxy("magicName",function(evt)
        return GameConfig.MagicConfig:getData(magicSelectId).name
    end,selectedChangedEvent)
    -- 宝物星级
    widget:addDataProxy("magicStar",function(evt)
        return ch.MagicModel:getStar(magicSelectId)
    end,magicChangedEvent)
    -- 宝物DPS
    widget:addDataProxy("magicDPS",function(evt)
--        return ch.NumberHelper:toString(math.floor(ch.MagicModel:getDPS(magicSelectId,ch.MagicModel:getLevel(magicSelectId))))
        -- 镀金加成
        local ratio = GameConst.MGAIC_STAR_RATIO + ch.TotemModel:getTotemSkillData(1,7)
        if ch.AltarModel:getAltarByType(3).level > 0 then
            ratio = ratio * ch.AltarModel:getFinalEffect(3)
        end
        return "+"..ch.NumberHelper:multiple(ratio*ch.MagicModel:getStar(magicSelectId)*100,1000)
    end,magicChangedEvent)
    -- 选中
    widget:addDataProxy("ifSelect",function(evt)
        return selectId ~= 0 and not showPanel
    end,showChangedEvent)
    -- 未选中
    widget:addDataProxy("ifNoSelect",function(evt)
        return selectId == 0
    end,selectedChangedEvent)
    -- 原宝物是否可转移镀金
    widget:addDataProxy("ifNoGold",function(evt)
        return ch.MagicModel:getStar(magicSelectId)<=0
    end,selectedChangedEvent)
    -- 原宝物是否可转移镀金
    widget:addDataProxy("ifGold",function(evt)
        return ch.MagicModel:getStar(magicSelectId)>0
    end,selectedChangedEvent)
    -- 原宝物是否可转移镀金(镀金按钮)
    widget:addDataProxy("ifGoldBtn",function(evt)
        return selectId ~= 0 and not showPanel and ch.MagicModel:getStar(magicSelectId)>0
    end,selectedChangedEvent)
    widget:addDataProxy("direction",function(evt)
        return ccui.ListViewDirection.horizontalSnap
    end)
    -- 宝物list
    widget:addDataProxy("items",function(evt)        
        return ch.MagicModel:getAllMagicsID()
    end)
    
    -- 宝物描述3
    widget:addDataProxy("desc3",function(evt)
        return GameConst.MGAIC_STAR_DESC3
    end)
    -- 转移镀金魂价格
    widget:addDataProxy("soulPrice",function(evt)
        return "-"..GameConst.MGAIC_STAR_PRICE
    end)
    
    -- 当日魂转移次数
    widget:addDataProxy("soulCount",function(evt)
        return "(" ..ch.ShopModel:getStarSoulCount() .. ")"
    end,starSoulChangeEvent)
    
    -- 魂数量是否满足条件且未达到次数上限
    widget:addDataProxy("soulEnough",function(evt)
        return ch.MoneyModel:getSoul() >= GameConst.MGAIC_STAR_PRICE and ch.ShopModel:getStarSoulCount() > 0
    end,starSoulChangeEvent)
    -- 魂数量是否不满足条件或达到次数上限
    widget:addDataProxy("soulNoEnough",function(evt)
        return ch.MoneyModel:getSoul() < GameConst.MGAIC_STAR_PRICE or ch.ShopModel:getStarSoulCount() <= 0
    end,starSoulChangeEvent)
    
    -- 转移镀金钻石价格
    widget:addDataProxy("diamondPrice",function(evt)
        local num = removeNum 
        if num == 100 then
            num = ch.MagicModel:getStar(selectId)
        else
            num = num < ch.MagicModel:getStar(selectId) and num or ch.MagicModel:getStar(selectId)
        end
        return "-"..GameConst.MGAIC_STAR_PRICE_DIAMOND*num
    end,moneyChangeEvent)
    -- 钻石数量是否满足条件
    widget:addDataProxy("diamondEnough",function(evt)
        local num = removeNum
        if num == 100 then
            num = ch.MagicModel:getStar(selectId)
        else
            num = num < ch.MagicModel:getStar(selectId) and num or ch.MagicModel:getStar(selectId)
        end
        return ch.MoneyModel:getDiamond() >= GameConst.MGAIC_STAR_PRICE_DIAMOND*num
    end,moneyChangeEvent)
    -- 钻石数量是否不满足条件
    widget:addDataProxy("diamondNoEnough",function(evt)
        local num = removeNum
        if num == 100 then
            num = ch.MagicModel:getStar(selectId)
        else
            num = num < ch.MagicModel:getStar(selectId) and num or ch.MagicModel:getStar(selectId)
        end
        return ch.MoneyModel:getDiamond() < GameConst.MGAIC_STAR_PRICE_DIAMOND*num
    end,moneyChangeEvent)
    
    widget:addCommond("changePanel",function()
        showPanel = true
        zzy.EventManager:dispatchByType(SHOW_PANEL_EVENT)
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10140 then
            ch.guide:endid(10140)
        end
    end)
    widget:addDataProxy("showBtnPanel",function(evt)
        return showPanel
    end,showChangedEvent)
    
    -- 转移镀金操作
    widget:addCommond("removeStar",function(widget,arg)
        if ch.MagicModel:getStar(selectId) < 1 then
            return
        end        
        local starNum = ch.MagicModel:getStar(selectId)
        local starCount = ch.ShopModel:getStarSoulCount()
        local num = removeNum
        if num == 1 then
            starCount = 1
            local buy = function()
                ch.fightRoleLayer:pause()
                ch.NetworkController:magicStarTrans(selectId,arg)
                if ch.MagicModel:getStar(selectId) < 1+starCount then
                    selectId = 0
                    showPanel = false
                    zzy.EventManager:dispatchByType(CHANGE_SELECT_EVENT)
                    zzy.EventManager:dispatchByType(SHOW_PANEL_EVENT)
                end
            end
            if arg == "1" then
                buy()
            else
                local tmp = {price = GameConst.MGAIC_STAR_PRICE_DIAMOND,buy = buy}
                ch.ShopModel:getCostTips(tmp)
            end
        else
            if num == 100 then
                num = starNum
            end
            if arg == "0" then
                starCount = num < starNum and num or starNum
                ch.UIManager:showMsgBox(2,true,string.format(Language.MAGIC_REMOVE_SELECT_DESC[2],starCount*GameConst.MGAIC_STAR_PRICE_DIAMOND,starCount),function()
                    ch.fightRoleLayer:pause()
                    ch.NetworkController:magicStarTransNum(selectId,arg,starCount)
                        
                    if ch.MagicModel:getStar(selectId) < 1+starCount then
                        selectId = 0
                        showPanel = false
                        zzy.EventManager:dispatchByType(CHANGE_SELECT_EVENT)
                        zzy.EventManager:dispatchByType(SHOW_PANEL_EVENT)
                    end
                end,nil,nil,2)
            else
                starCount = starCount < num and starCount or num
                starCount = starCount < starNum and starCount or starNum
                ch.UIManager:showMsgBox(2,true,string.format(Language.MAGIC_REMOVE_SELECT_DESC[1],starCount,starCount),function()
                    ch.fightRoleLayer:pause()
                    ch.NetworkController:magicStarTransNum(selectId,arg,starCount)

                    if ch.MagicModel:getStar(selectId) < 1+starCount then
                        selectId = 0
                        showPanel = false
                        zzy.EventManager:dispatchByType(CHANGE_SELECT_EVENT)
                        zzy.EventManager:dispatchByType(SHOW_PANEL_EVENT)
                    end
                end,nil,nil,2)
            end
        end
        -- 首次钻石转移镀金邮件
        if ch.guide._data["guide9091"] ~= 1 and tonumber(arg) == 0 then
            ch.guide._data["guide9091"] = 1
            ch.NetworkController:reGuideMsg("9091", "7")
        end
    end)
    
    widget:listen(ch.MagicModel.dataChangeEventType, function(obj,evt)
        if evt.id ~= magicSelectId then
            ch.fightRoleLayer:resume()
            local start = tonumber(magicSelectId)
            local last = tonumber(ch.MagicModel:getRemoveMagicID())
            local x = -3
            local y = 970
            local tmpXY = {}
            local movetoStar = {}
            for i = 1,4 do
                tmpXY[i] = math.random(1,25)
                local tmpX = math.fmod(tmpXY[i],5)==0 and 5 or math.fmod(tmpXY[i],5)

                movetoStar[i] = cc.MoveTo:create(0.1,cc.p(x+tmpX*110,y-math.ceil(tmpXY[i]/5)*110))
            end
            local tmpXX = math.fmod(last,5)==0 and 5 or math.fmod(last,5)
            movetoStar[5] = cc.MoveTo:create(0.2,cc.p(x+tmpXX*110,y-math.ceil(last/5)*110))
            ch.RoleResManager:loadEffect("tx_shengguangzhuanyi")
            local loadingAni = ccs.Armature:create("tx_shengguangzhuanyi")
            loadingAni:getAnimation():play("play1",1,-1)
            local tmpXXX = math.fmod(start,5)==0 and 5 or math.fmod(start,5)
            loadingAni:setPosition(x+tmpXXX*110,y-math.ceil(start/5)*110)
            widget:addChild(loadingAni)
            local time = cc.DelayTime:create(0.1)
            local movetoStarS = cc.Sequence:create(time,movetoStar[1],time,movetoStar[2],time,movetoStar[3],time,movetoStar[4],time,movetoStar[5],time,cc.CallFunc:create(function()
                ch.RoleResManager:releaseEffect("tx_shengguangzhuanyi")
                loadingAni:removeFromParent()
                loadingAni = nil
                zzy.EventManager:dispatchByType(EFFECT_PLAY_TRANS_EVENT)
            end))
            loadingAni:runAction(movetoStarS)
        end
    end)
end)

-- 宝物单元
zzy.BindManager:addCustomDataBind("baowu/W_BaowuStarlist",function(widget,data)
    local selectedChangedEvent = {}
    selectedChangedEvent[CHANGE_SELECT_EVENT] = false
    local effectPlayEvent = {}
    effectPlayEvent[EFFECT_PLAY_TRANS_EVENT] = false
    -- 宝物图标
    widget:addDataProxy("magicIcon",function(evt)
        return GameConfig.MagicConfig:getData(data).icon
    end)
    -- 宝物尚未获得
    widget:addDataProxy("noHave",function(evt)
        return ch.MagicModel:getLevel(data) < 1
    end)
    -- 宝物星级
    local starNum = ch.MagicModel:getStar(data)
    widget:addDataProxy("magicStar",function(evt)
        if starNum < ch.MagicModel:getStar(data) then
            widget:playEffect("getStarEffect",false)
        end
        starNum = ch.MagicModel:getStar(data)
        return ch.MagicModel:getStar(data)
    end,effectPlayEvent)
    -- 是否镀金
    widget:addDataProxy("ifGold",function(evt)
        return ch.MagicModel:getStar(data)>0
    end,effectPlayEvent)
    -- 选中、取消
    widget:addDataProxy("ifSelect",function(evt)
        return data == selectId
    end,selectedChangedEvent)
    -- 选中、取消
    widget:addCommond("select",function(widget,arg)
            --[[
            for k1,v1 in ipairs(widget:getChildren()) do
                for k2,v2 in ipairs(v1:getChildren()) do
                    if v2:getName() then
                        DEBUG(v2:getName())
                        if v2:getName() == "cb_select" then
                            --v2:setVisible(false)
                            for k3,v3 in ipairs(v2:getChildren()) do
                                if v3:getName() then
                                    DEBUG(v3:getName())
                                end
                            end
                        end
                    end
                end
            end
            ]]
        if arg == "1" then
            selectId = data
            magicSelectId = data
            showPanel = false
            zzy.EventManager:dispatchByType(CHANGE_SELECT_EVENT)
            zzy.EventManager:dispatchByType(SHOW_PANEL_EVENT)
            --结束引导
            if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10130 then
                ch.guide:endid(10130)
            end
        elseif arg == "0" then
            if selectId == data then
                selectId = 0
                magicSelectId = "1"
                showPanel = false
                zzy.EventManager:dispatchByType(CHANGE_SELECT_EVENT)
                zzy.EventManager:dispatchByType(SHOW_PANEL_EVENT)
            end
        end
    end)
end)

-- 宝物圣光分配
zzy.BindManager:addFixedBind("baowu/W_BaowuStarget",function(widget)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.star
    end
    local starChangeEvent = {}
    starChangeEvent[ch.MagicModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MagicModel.dataType.star
    end
    local first = true
    local btnState = true
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_MagicView_3
    end)
    -- 未分配圣光数量
    widget:addDataProxy("starNum",function(evt)
        return ch.MoneyModel:getStar()
    end,moneyChangeEvent)
    widget:addDataProxy("desc1",function(evt)
        -- 镀金加成
        local ratio = GameConst.MGAIC_STAR_RATIO + ch.TotemModel:getTotemSkillData(1,7)
        if ch.AltarModel:getAltarByType(3).level > 0 then
            ratio = ratio * ch.AltarModel:getFinalEffect(3)
        end
        return string.format(GameConst.MGAIC_STAR_DESC1,ch.NumberHelper:multiple(ratio*100,1000))
    end)
--    widget:addDataProxy("magicIcon",function(evt)
--        local id = ch.MagicModel:getRandMagicID()
--        if id == "0" then
--            return "aaui_card/baowu0001.png"
--        else
--            return GameConfig.MagicConfig:getData(id).icon
--        end
--    end,starChangeEvent)
    -- 是否有分配的镀金次数
    widget:addDataProxy("ifStar",function(evt)
        return ch.MoneyModel:getStar() > 0
    end,moneyChangeEvent)
    widget:addDataProxy("ifNoStar",function(evt)
        if ch.guide._data["guide10120"] ~= 1 and ch.MoneyModel:getStar() < 1 then
--        if ch.MoneyModel:getStar() < 1 then
            ch.guide:play_guide(10120)
        end
        return ch.MoneyModel:getStar() < 1
    end,moneyChangeEvent)
    -- 初始状态
    widget:addDataProxy("openFirst",function(evt)
        return first
    end)
    widget:addDataProxy("openFirstNo",function(evt)
        return not first
    end)
    
    local icon = "aaui_card/baowu0001.png"
    local count = 1
    local evtId = nil
    local noHave = true
    widget:addDataProxy("magicIcon",function(evt)
        return icon
    end)
    widget:addDataProxy("ifCanStar",function(evt)
        return btnState
    end)
    -- 宝物尚未获得
    widget:addDataProxy("noHave",function(evt)
        return noHave
    end)
    local loaded = false
    widget:listen(ch.MagicModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.MagicModel.dataType.playGet then
    -- 延时播放光效
    for k,v in pairs(ch.MagicModel:getPlayGetList()) do
    widget:setTimeOut(0.5*k,function()
            first = false
            btnState = false
            widget:noticeDataChange("ifCanStar")
            -- 光效
            ch.RoleResManager:loadEffect("tx_shengguanghuode")
            loaded = true
            local loadingAni = ccs.Armature:create("tx_shengguanghuode")
            loadingAni:getAnimation():play("play")
            --loadingAni:getAnimation():setSpeedScale(2)
            loadingAni:setPosition(342,650)
            widget:addChild(loadingAni)
            loadingAni:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
                if movementType == ccs.MovementEventType.complete then
                    if string.find(movementID, "play") then
                        loadingAni:removeFromParent()
                        loadingAni = nil
                        loaded = false
                        ch.RoleResManager:releaseEffect("tx_shengguanghuode")
                        widget:noticeDataChange("openFirst")
                        widget:noticeDataChange("openFirstNo")
--                        icon = GameConfig.MagicConfig:getData(ch.MagicModel:getRandMagicID()).icon
                        
                        v = tostring(v)
                        if GameConfig.MagicConfig:getData(v) then
                            icon = GameConfig.MagicConfig:getData(tostring(v)).icon
                        else
                            ERROR("dj dest index="..v)
                        end
                        widget:noticeDataChange("magicIcon")
--                        noHave = ch.MagicModel:getLevel(ch.MagicModel:getRandMagicID()) < 1
                        noHave = ch.MagicModel:getLevel(v) < 1
                        widget:noticeDataChange("noHave")
                        widget:playEffect("starGetEffect")
                        widget:setTimeOut(0.4,function()
                            btnState = true
                            if zzy.CocosExtra.isCobjExist(widget) then
                                widget:noticeDataChange("ifCanStar")
                            end
                        end)
                        -- 老虎机（暂时屏蔽）
                        --                    evtId = widget:listen(zzy.Events.TickEventType,function()
                        --                        if count > 0 and count <10 then
                        --                            icon = "aaui_card/baowu000"..count..".png"
                        --                            count = count+1
                        --                        elseif count >9 and count < 25 then
                        --                            icon = "aaui_card/baowu00"..count..".png"
                        --                            count = count+1
                        --                        else
                        --                            widget:unListen(evtId)
                        --                            count = 1
                        --                            icon = "aaui_card/baowu0022.png"
                        --                            widget:playEffect("starGetEffect")
                        --                        end
                        --                        widget:noticeDataChange("magicIcon")
                        --                    end)
                    end
                end
            end)
    end)
    end
        end
    end)
    
    local close = widget.destory
    widget.destory = function(cleanView)
        close(widget,cleanView)
        if loaded then
            ch.RoleResManager:releaseEffect("tx_shengguanghuode")
        end
    end

    -- 随机加上圣光
    widget:addCommond("randStars",function()
--        ch.NetworkController:magicStar()
        ch.NetworkController:magicStarNum(ch.MoneyModel:getStar())
    end)
    -- 打开圣光管理界面
    widget:addCommond("openStarList",function()
        widget:destory()
        ch.UIManager:showGamePopup("baowu/W_BaowuStar")
        --结束引导
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10120 then
            ch.guide:endid(10120)
        end
    end)
end)