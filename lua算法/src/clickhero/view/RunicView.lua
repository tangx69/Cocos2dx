local upNum = 1
local upNumTable = {1,25,100,1000}
local tmpNum = 0
local CHANG_UPNUM_EVENT = "RUNIC_CHANG_UPNUM"
-- 复选框
local is10 = false
local is100 = false

---
-- 符文界面
zzy.BindManager:addFixedBind("fuwen/W_FuwenList",function(widget)
    local effect = {}
    effect[ch.RunicModel.dataChangeEventType] = false
    effect[ch.MagicModel.dataChangeEventType] = false
    
    effect[ch.BuffModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.BuffModel.dataType.card or 
            evt.dataType == ch.BuffModel.dataType.inspire
    end
    effect[ch.PartnerModel.czChangeEventType] = function(evt)
        return evt.dataType == ch.PartnerModel.dataType.get
    end
    effect[ch.TaskModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.TaskModel.dataType.state
    end
    effect[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.PetCardModel.dataType.level
    end
    
    local selectChangedEffectEvent ={}
    selectChangedEffectEvent[CHANG_UPNUM_EVENT] = false
    
    local petChangedEvent = {}
    petChangedEvent[ch.PartnerModel.czChangeEventType] = false
    
    widget:addDataProxy("allDMG-num",function(evt)
        return ch.LongDouble:floor(ch.RunicModel:getDPS(ch.RunicModel:getLevel()))
    end,effect)
    widget:addScrollData("allDMG-num", "allDMG", 1, function(v)
        return ch.NumberHelper:toString(v)
    end,"num_dmg")
    widget:addDataProxy("allDPS-num",function(evt)
        return  ch.LongDouble:floor(ch.MagicModel:getTotalDPS())
    end,effect)
    widget:addScrollData("allDPS-num", "allDPS", 1, function(v)
        return ch.NumberHelper:toString(v)
    end,"num_dps")
    widget:addDataProxy("items",function(evt)
        local items = {}
        table.insert(items,{index =1,value = 0,isMultiple = true})
        table.insert(items,{index=5,value = {type = 1,value = ch.FamiliarModel:getCurFamiliarCardData()},isMultiple = true})
        for k,v in ipairs(ch.PartnerModel:getCanFightPartner()) do
            table.insert(items,{index =2,value = GameConfig.PartnerConfig:getData(tostring(v)),isMultiple = true})
        end
        table.insert(items,{index = 3,value = 7,isMultiple = true})
        for k,v in ipairs(ch.RunicModel:getOrderRunics()) do
            if v < ch.RunicModel.skillId.wujinzhuansheng then
                table.insert(items,{index = 4,value = v,isMultiple = true})
            end
        end
        return items
    end,petChangedEvent)
--    widget:addDataProxy("ifCheck1",function(evt)
--        return is10
--    end,selectChangedEffectEvent)
--    widget:addDataProxy("ifnotCheck1",function(evt)
--        return not is10
--    end,selectChangedEffectEvent)
    
--    -- 100倍复选框
--    widget:addDataProxy("ifCheck2",function(evt)
--        return is100
--    end,selectChangedEffectEvent)

    widget:addDataProxy("ifOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel() > 10
    end)
    -- 一次升级等级
    widget:addDataProxy("upNum",function(evt)
        return "X "..upNum
    end,selectChangedEffectEvent)
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
    
    local runicOpenEvent = {}
    runicOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
        return evt.view == "fuwen/W_FuwenList"
    end
    -- 上按钮可见
    widget:addDataProxy("upVisible", function(evt)
        if evt then
            return evt.popType == ch.UIManager.popType.HalfOpen
        else
            return true
        end
    end,runicOpenEvent)
    -- 下按钮可见
    widget:addDataProxy("downVisible", function(evt)
        if evt then
            return evt.popType ~= ch.UIManager.popType.HalfOpen
        else
            return false
        end
    end,runicOpenEvent)
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
    end,runicOpenEvent)
end)

zzy.BindManager:addCustomDataBind("fuwen/W_FuwenDmg",function(widget,data)
    local runicLevelChangedEvent = {}
    runicLevelChangedEvent[ch.RunicModel.dataChangeEventType] = false
    local levelOrNumberChangedEvent ={}
    levelOrNumberChangedEvent[ch.RunicModel.dataChangeEventType] = false
    levelOrNumberChangedEvent[CHANG_UPNUM_EVENT] = false
    local canLevelUpEffectEvent = {}
    canLevelUpEffectEvent[ch.RunicModel.dataChangeEventType] = false
    canLevelUpEffectEvent[CHANG_UPNUM_EVENT] = false
    canLevelUpEffectEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.gold
    end
    local petChangeEvent = {}
    petChangeEvent[ch.PartnerModel.czChangeEventType] = false
    widget:addDataProxy("icon",function(evt)
        return GameConfig.PartnerConfig:getData(ch.PartnerModel:getCurPartner()).icon
    end,petChangeEvent)
    widget:addDataProxy("name",function(evt)
        return GameConfig.PartnerConfig:getData(ch.PartnerModel:getCurPartner()).name
    end,petChangeEvent)
    widget:addDataProxy("level",function(evt)
        return ch.RunicModel:getLevel()
    end,runicLevelChangedEvent)
    widget:addDataProxy("dps",function(evt)
        return ch.NumberHelper:toString(ch.LongDouble:floor(ch.RunicModel:getBaseDPS()))
    end,runicLevelChangedEvent)
    widget:addDataProxy("upNum",function(evt)
        return Language.LV.."+"..upNum
    end,levelOrNumberChangedEvent)
    widget:addDataProxy("partnerid",function(evt)
        return ch.PartnerModel:getCurPartner()
    end)
    -- 技能0图标
    local icon = ch.RunicModel:getSkillIcon1()
    widget:addDataProxy("skillIcon0",function(evt)
        return icon
    end,runicLevelChangedEvent)
    -- 技能1图标
    widget:addDataProxy("skillIcon1",function(evt)
        return ch.RunicModel:getSkillIcon1()
    end,runicLevelChangedEvent)
    -- 技能2图标
    widget:addDataProxy("skillIcon2",function(evt)
        return ch.RunicModel:getUnlockIcon()
    end,runicLevelChangedEvent)
    -- 技能2解锁等级
    widget:addDataProxy("skillNum2",function(evt)
        return ch.RunicModel:getUnlockLevel()
    end,runicLevelChangedEvent)
    -- 技能2是否解锁
    widget:addDataProxy("ifNoOpen2",function(evt)
        return true
    end)
    
    -- 第一个技能是否解锁
    widget:addDataProxy("ifOpenOne",function(evt)
        return ch.RunicModel:getLevel() >= GameConst.RUNIC_CONFIG_SKILL_LEVELS[1]
    end,runicLevelChangedEvent)
    -- 技能a是否显示
    widget:addDataProxy("ifUnlockOne",function(evt)
        return ch.RunicModel:getUnlockLevel() ~= GameConst.RUNIC_CONFIG_SKILL_LEVELS[2]
    end,runicLevelChangedEvent)

    widget:addDataProxy("levelUpCost",function(evt)
        return "-"..ch.NumberHelper:toString(ch.RunicModel:getCostLevelUp(upNum))
    end,levelOrNumberChangedEvent)
    widget:addDataProxy("addDps",function(evt)
        local newDps = ch.RunicModel:getBaseDPS(ch.RunicModel:getLevel()+ upNum)
        local curDps = ch.RunicModel:getBaseDPS(ch.RunicModel:getLevel())
        local dps = ch.LongDouble:floor(newDps - curDps)
        return "+"..ch.NumberHelper:toString(dps)
    end,levelOrNumberChangedEvent)
    widget:addDataProxy("canLevelUp",function(evt)
        return ch.MoneyModel:getGold() >= ch.RunicModel:getCostLevelUp(upNum)
    end,canLevelUpEffectEvent)
    widget:addCommond("openPetCard",function()
        ch.UIManager:showGamePopup("fuwen/W_FuwenPetChange",{id=ch.PartnerModel:getCurPartner(),type=1})
    end)
    
    local textAction = {}
    widget:addCommond("levelUp",function()
        local upDPS = "+"..ch.NumberHelper:toString(ch.LongDouble:floor(ch.RunicModel:getBaseDPS(ch.RunicModel:getLevel()+ upNum)-ch.RunicModel:getBaseDPS(ch.RunicModel:getLevel())))
        local tmpa = 1
        if ch.RunicModel:_getCurSkill()~= -1 and ch.RunicModel:_getCurSkill() ~= -2 then
            tmpa = GameConst.RUNIC_CONFIG_SKILL_LEVELS[ch.RunicModel:_getCurSkill()]
        else
            tmpa = ch.RunicModel:getAutoSkillUnlockLevel()
        end
        ch.NetworkController:runicLevelUp(upNum)
        widget:playEffect("levelUpFWEffect",false)
        if ch.fightRoleLayer:getMainRole() then
            ch.fightRoleLayer:getMainRole():addChongwuEffect("tx_chongwushengji","Animation1")
        end
        ch.SoundManager:play("levup")
        local level = ch.RunicModel:getLevel()
        local tmp = ch.RunicModel:getAutoSkillUnlockLevel()
        if level >= tmpa then
            local action = cc.CSLoader:createTimeline("res/ui/fuwen/W_FuwenDmg.csb")
            widget:runAction(action)
            --action:gotoFrameAndPlay(0,20,false) -- tgx
            icon = ch.RunicModel:getSkillIcon1()
            widget:playEffect("unlockSkillFWEffect",false)
        end
--        if level-upNum < GameConfig.SkillConfig:getData(7).unlocklv then
        if level - upNum < ch.RunicModel:getActiveSkillUnlockLv(6) then
            for i = 1,6 do
--                local tmpLv = GameConfig.SkillConfig:getData(i).unlocklv
                local tmpLv = ch.RunicModel:getActiveSkillUnlockLv(i)
                if level - upNum < tmpLv and level >= tmpLv then
                    widget:playEffect("skill_"..tostring(i),false) 
                end
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
        
        --结束引导
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10030 then
            ch.guide:endid(10030)
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
    if IS_BANHAO and Panel_skill then
        Panel_skill:setVisible(false)
    end
end)

zzy.BindManager:addCustomDataBind("fuwen/W_FuwenSkillunit",function(widget,data)
    local runicLevelChangedEvent = {}
    runicLevelChangedEvent[ch.RunicModel.dataChangeEventType] = false
    local config = GameConfig.SkillConfig:getData(data)
    widget:addDataProxy("icon",function(evt)
        return config.icon
    end)
    widget:addDataProxy("desc",function(evt)
        return config.desc
    end)
    widget:addDataProxy("name",function(evt)
        return config.name
    end)
    widget:addDataProxy("isShowIUL",function(evt) -- 图标上的解锁等级不显示
        return false
    end)
    widget:addDataProxy("isActivation",function(evt)
--        return ch.RunicModel:getLevel() < config.unlocklv
        if data == 7 then
            return ch.LevelModel:getCurLevel() < ch.RunicModel:getActiveSkillUnlockLv(data)
        else
            return ch.RunicModel:getLevel() < ch.RunicModel:getActiveSkillUnlockLv(data)
        end
    end,runicLevelChangedEvent)
    widget:addDataProxy("unlockLevel",function(evt)
--        return config.unlocklv
        return ch.RunicModel:getActiveSkillUnlockLv(data)
    end,runicLevelChangedEvent)
    widget:addDataProxy("isResurrection",function(evt)
--        return data == 7 and ch.RunicModel:getLevel() >= config.unlocklv
        return data == 7 and ch.LevelModel:getCurLevel() >= ch.RunicModel:getActiveSkillUnlockLv(data)
    end,runicLevelChangedEvent)
    widget:addDataProxy("notResurrection",function(evt)
        return data ~= 7
    end)
    widget:addDataProxy("cdDes",function(evt)
        return string.format(Language.src_clickhero_view_RunicView_1,ch.RunicModel:getSkillTotalDuration(data),ch.RunicModel:getSkillTotalCD(data))
    end)
end)
-- 转生技能卡片
zzy.BindManager:addCustomDataBind("fuwen/W_Prestigecard",function(widget,data)
    local runicLevelChangedEvent = {}
    runicLevelChangedEvent[ch.LevelModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    runicLevelChangedEvent[ch.PlayerModel.samsaraCleanOffLineEventType] = false
    
    local config = GameConfig.SkillConfig:getData(data)
    widget:addDataProxy("icon",function(evt)
        return config.icon
    end)
    widget:addDataProxy("desc",function(evt)
        return config.desc
    end)
    widget:addDataProxy("name",function(evt)
        return config.name
    end)
    widget:addDataProxy("isActivation",function(evt)
        return ch.LevelModel:getMaxLevel()-1 < ch.RunicModel:getActiveSkillUnlockLv(data)
    end,runicLevelChangedEvent)
    widget:addDataProxy("noActivation",function(evt)
        return ch.LevelModel:getMaxLevel()-1 >= ch.RunicModel:getActiveSkillUnlockLv(data)
    end,runicLevelChangedEvent)
    widget:addDataProxy("unlockLevel",function(evt)
        return ch.RunicModel:getActiveSkillUnlockLv(data)
    end,runicLevelChangedEvent)
    widget:addCommond("openDetail",function()
        if ch.LevelController.mode == ch.LevelController.GameMode.normal then
            ch.UIManager:showGamePopup("fuwen/W_Prestige")
        else
            ch.UIManager:showUpTips(Language.src_clickhero_view_RunicView_2)
        end
    end)
    widget:addDataProxy("noOpenDesc",function(evt)
        return ch.LevelModel:getMaxLevel()-1 >= ch.RunicModel:getActiveSkillUnlockLv(data) and ch.ShopModel:getSamsaraCount() > 0
    end,runicLevelChangedEvent)
    widget:addDataProxy("countTimes",function(evt)
        return ch.ShopModel:getSamsaraCount()
    end,runicLevelChangedEvent)
    widget:addCommond("openDes",function()
        ch.UIManager:showMsgBox(1,true,string.format(GameConst.SAMSARA_COUNT_TIP,ch.ShopModel:getSamsaraCount()),nil,nil,Language.MSG_BUTTON_OK)
    end)
end)

---
-- 符文详情界面界面
zzy.BindManager:addFixedBind("fuwen/W_FuwenDetail",function(widget)
    local petChangeEvent = {}
    petChangeEvent[ch.PartnerModel.czChangeEventType] = false
    widget:addDataProxy("icon",function(evt)
        return GameConfig.PartnerConfig:getData(ch.PartnerModel:getCurPartner()).icon
    end,petChangeEvent)
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_RunicView_3
    end)
    widget:addDataProxy("level",function(evt)
        return ch.RunicModel:getLevel()
    end)
end)

---
-- 符文详情界面界面1
zzy.BindManager:addCustomDataBind("fuwen/W_FuwenDetail1",function(widget,data)
    local config = GameConfig.PartnerConfig:getData(tostring(data))
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_RunicView_4
    end)
    
    local petChangeEvent = {}
    petChangeEvent[ch.PartnerModel.czChangeEventType] = false
    widget:addDataProxy("icon",function(evt)
        return GameConfig.PartnerConfig:getData(ch.PartnerModel:getCurPartner()).icon
    end,petChangeEvent)
    widget:addDataProxy("name",function(evt)
        return GameConfig.PartnerConfig:getData(ch.PartnerModel:getCurPartner()).name
    end,petChangeEvent)
    widget:addDataProxy("des",function(evt)
        return config.des
    end,petChangeEvent)
    widget:addDataProxy("level",function(evt)
        return ch.RunicModel:getLevel()
    end)
    widget:addDataProxy("dps",function(evt)
        return ch.NumberHelper:toString(ch.LongDouble:floor(ch.RunicModel:getDPS(ch.RunicModel:getLevel())))
    end)
    widget:addDataProxy("nextdps",function(evt)
        return ch.NumberHelper:toString(ch.LongDouble:floor(ch.RunicModel:getDPS(ch.RunicModel:getLevel()+1)))
    end)
--    widget:addDataProxy("desc1",function(evt)
--        local t1 = GameConst.RUNIC_AUTO_ADD_SKILL[2].step
--        local t2 = GameConst.RUNIC_AUTO_ADD_SKILL[2].skValue
--        return string.format(GameConst.RUNIC_AUTO_ADD_SKILL_DESC,t1,t2)
--    end)
--    widget:addDataProxy("desc2",function(evt)
--        local t1 = GameConst.RUNIC_AUTO_ADD_SKILL[1].step
--        local t2 = GameConst.RUNIC_AUTO_ADD_SKILL[1].skValue
--        return string.format(GameConst.RUNIC_AUTO_ADD_SKILL_DESC,t1,t2)
--    end)
    widget:addDataProxy("items",function(evt)
        local tmpList = {}
        for i = 1,table.maxn(GameConst.RUNIC_CONFIG_SKILL_LEVELS) do
            table.insert(tmpList,tostring(i))
        end
        table.insert(tmpList,"-1")
        table.insert(tmpList,"-2")
        return tmpList
    end)
end)

---
-- 符文详情里的技能列表被动技item
zzy.BindManager:addCustomDataBind("fuwen/W_FuwenSkillunit1",function(widget,data)
    local index = tonumber(data)
    local skillType = 1
    local desc = ""
    if index == -1 then
        skillType = table.maxn(GameConst.RUNIC_SKILL_ICON)-1
        desc = string.format(GameConst.RUNIC_AUTO_ADD_SKILL_DESC,GameConst.RUNIC_AUTO_ADD_SKILL[2].step,GameConst.RUNIC_AUTO_ADD_SKILL[2].skValue/100+1)
    elseif index == -2 then
        skillType = table.maxn(GameConst.RUNIC_SKILL_ICON)
        desc = string.format(GameConst.RUNIC_AUTO_ADD_SKILL_DESC,GameConst.RUNIC_AUTO_ADD_SKILL[1].step,GameConst.RUNIC_AUTO_ADD_SKILL[1].skValue/100+1)
    else
        skillType = GameConst.RUNIC_CONFIG_SKILL_RATIO[index]
        desc = string.format(Language.src_clickhero_view_RunicView_5,GameConst.RUNIC_CONFIG_SKILL_TYPE[skillType]*100)
    end    

    -- 技能图标
    widget:addDataProxy("skillIcon",function(evt)
        return GameConst.RUNIC_SKILL_ICON[skillType]
    end) 
    -- 技能名称
    widget:addDataProxy("skillName",function(evt)
        return Language.src_clickhero_view_RunicView_6
    end) 
    -- 技能解锁等级
    widget:addDataProxy("skillNum",function(evt)
        if index == GameConst.RUNIC_AUTO_ADD_SKILL_INDEX1 then
            return GameConst.RUNIC_AUTO_ADD_SKILL[1].level
        elseif index == GameConst.RUNIC_AUTO_ADD_SKILL_INDEX2 then
            return GameConst.RUNIC_AUTO_ADD_SKILL[2].level
        else
            return GameConst.RUNIC_CONFIG_SKILL_LEVELS[index]
        end
    end)
    -- 技能是否解锁
    widget:addDataProxy("ifNoOpen",function(evt)
        if index == GameConst.RUNIC_AUTO_ADD_SKILL_INDEX1 then
            return ch.RunicModel:getLevel()< GameConst.RUNIC_AUTO_ADD_SKILL[1].level
        elseif index == GameConst.RUNIC_AUTO_ADD_SKILL_INDEX2 then
            return ch.RunicModel:getLevel() < GameConst.RUNIC_AUTO_ADD_SKILL[2].level
        else
            return ch.RunicModel:getLevel() < GameConst.RUNIC_CONFIG_SKILL_LEVELS[index]
        end
    end)
    -- 技能描述
    widget:addDataProxy("skillDes",function(evt)
        return desc
    end)
    
    --版号
    local unlocktext_0 = zzy.CocosExtra.seekNodeByName(widget, "unlocktext_0")
    if IS_BANHAO and unlocktext_0 then
        unlocktext_0:setFontName("aaui_font/ch.ttf")
        unlocktext_0:setFontSize(18)
        unlocktext_0:setString(Language.LV)
    end
end)

---
-- 符文详情里的技能列表
zzy.BindManager:addCustomDataBind("fuwen/N_FuwenDetailunit",function(widget,data)
    local cdTimeEvent = {}
    cdTimeEvent[ch.PartnerModel.czChangeEventType] = function(evt)
        return evt.dataType == ch.PartnerModel.dataType.get
    end 
    local config = GameConfig.SkillConfig:getData(data)
    widget:addDataProxy("icon",function(evt)
        return config.icon
    end)
    widget:addDataProxy("desc",function(evt)
        return config.desc
    end)
    widget:addDataProxy("name",function(evt)
        return config.name
    end)
    widget:addDataProxy("isActivation",function(evt)
--        return ch.RunicModel:getLevel() < config.unlocklv
        if tonumber(data) == 7 then
            return ch.LevelModel:getCurLevel() < ch.RunicModel:getActiveSkillUnlockLv(data)
        else
            return ch.RunicModel:getLevel() < ch.RunicModel:getActiveSkillUnlockLv(data)
        end
    end)
    widget:addDataProxy("unlockLevel",function(evt)
--        return config.unlocklv
        return ch.RunicModel:getActiveSkillUnlockLv(data)
    end)
    widget:addDataProxy("cdTime",function(evt)
        return ch.RunicModel:getSkillTotalCD(data)
    end,cdTimeEvent)
    widget:addDataProxy("durationTime",function(evt)
        return ch.RunicModel:getSkillTotalDuration(data)
    end)
end)

---
-- 转生界面
zzy.BindManager:addFixedBind("fuwen/W_Prestige",function(widget)
    local config = GameConfig.SkillConfig:getData(7)
    widget:addDataProxy("name",function(evt)
        return config.name
    end)
    widget:addDataProxy("icon",function(evt)
        return config.icon
    end)
    widget:addDataProxy("desc",function(evt)
        local gold = "0"
        if ch.TotemModel:getTotemSkillData(2,1) > GameConst.RUNIC_SAMSARA_GOLD then
            gold = ch.NumberHelper:toString(ch.TotemModel:getTotemSkillData(2,1))
        else
            gold = ch.NumberHelper:toString(GameConst.RUNIC_SAMSARA_GOLD)
        end
        return config.desc..string.format(Language.src_clickhero_view_RunicView_7,gold)
    end)
    -- 不显示图标的解锁等级和蒙灰
    widget:addDataProxy("isActivation",function(evt)
        return ch.LevelModel:getCurLevel() < ch.RunicModel:getActiveSkillUnlockLv(7)
    end)
    widget:addDataProxy("soulLevel",function(evt)
        return math.floor((ch.RunicModel:getLevel()+ch.MagicModel:getTotalLevel())/GameConst.SOUL_LEVEL)
    end)
    widget:addDataProxy("soulStone",function(evt)
        return ch.NumberHelper:toString(ch.MoneyModel:getsStone())
    end)
    widget:addDataProxy("powerSoul",function(evt)
        return ch.TaskModel:getCurPowerNum()
    end)
    widget:addDataProxy("countTimes",function(evt)
        return string.format(Language.src_clickhero_view_RunicView_8,ch.StatisticsModel:getRTimes()+1)
    end)

    local num = math.floor((ch.RunicModel:getLevel()+ch.MagicModel:getTotalLevel())/GameConst.SOUL_LEVEL)+ch.MoneyModel:getsStone()+ch.TaskModel:getCurPowerNum()
    widget:addDataProxy("allSoulNum",function(evt)
        return ch.NumberHelper:toString(num)
    end)
    widget:addDataProxy("soulRatio",function(evt)
        return "+"..ch.NumberHelper:multiple(ch.StatisticsModel:getSoulRatio(num,ch.StatisticsModel:getRTimes()+1)*100,1000)
    end)
    widget:addCommond("Resurrect",function()
        ch.UIManager:showGamePopup("fuwen/W_gjzs")
        widget:destory()
    end)
    widget:addDataProxy("petName",function(evt)
        return Language.src_clickhero_view_RunicView_9
    end)
    widget:addDataProxy("curPetLevel",function(evt)
        return ch.RunicModel:getLevel()
    end)
    widget:addDataProxy("petLevel",function(evt)
        return 1
    end)
    widget:addDataProxy("petIcon",function(evt)
        return "res/icon/icon_boss.png"
    end)
    
    widget:addDataProxy("magicNumName",function(evt)
        return Language.src_clickhero_view_RunicView_10
    end)
    widget:addDataProxy("curMagicNum",function(evt)
        return table.maxn(ch.MagicModel:getCurMagics())
    end)
    widget:addDataProxy("magicNum",function(evt)
        return 1
    end)
    widget:addDataProxy("magicIcon",function(evt)
        return "res/icon/icon_hero.png"
    end)
    
    widget:addDataProxy("magicLevelName",function(evt)
        return Language.src_clickhero_view_RunicView_11
    end)
    widget:addDataProxy("curMagicLevel",function(evt)
        return ch.MagicModel:getTotalLevel()
    end)
    widget:addDataProxy("magicLevel",function(evt)
        return 1
    end)
    
    widget:addDataProxy("levelName",function(evt)
        return Language.src_clickhero_view_RunicView_12
    end)
    widget:addDataProxy("curLevel",function(evt)
        return ch.LevelModel:getCurLevel()
    end)
    widget:addDataProxy("level",function(evt)
        return ch.TotemModel:getTotemSkillData(2,3)+1 == 0 and 1 or ch.TotemModel:getTotemSkillData(2,3)+1
    end)
    widget:addDataProxy("levelIcon",function(evt)
        return "res/icon/icon_stage.png"
    end)
    
    widget:addDataProxy("goldName",function(evt)
        return Language.MSG_COIN
    end)
    widget:addDataProxy("curGold",function(evt)
        return ch.NumberHelper:toString(ch.MoneyModel:getGold())
    end)
    widget:addDataProxy("gold",function(evt)
        if ch.TotemModel:getTotemSkillData(2,1) > GameConst.RUNIC_SAMSARA_GOLD then
            return ch.NumberHelper:toString(ch.TotemModel:getTotemSkillData(2,1))
        else
            return ch.NumberHelper:toString(GameConst.RUNIC_SAMSARA_GOLD)
        end
    end)
    widget:addDataProxy("goldIcon",function(evt)
        return "res/icon/moneyGolds.png"
    end)
    
    widget:addDataProxy("sstoneName",function(evt)
        return Language.MSG_HEROSTONE
    end)
    widget:addDataProxy("curSStoneNum",function(evt)
        return ch.NumberHelper:toString(ch.MoneyModel:getsStone())
    end)
    widget:addDataProxy("sStoneNum",function(evt)
        return 0
    end)
    widget:addDataProxy("sstoneIcon",function(evt)
        return "res/icon/moneyStones.png"
    end)
    
    widget:addDataProxy("soulName",function(evt)
        return Language.MSG_HEROSOUL
    end)
    widget:addDataProxy("curSoulNum",function(evt)
        return ch.NumberHelper:toString(ch.MoneyModel:getSoul())
    end)
    widget:addDataProxy("soulNum",function(evt)
        return ch.NumberHelper:toString(ch.MoneyModel:getSoul()+num)
    end)
    widget:addDataProxy("soulIcon",function(evt)
        return "res/icon/moneySouls.png"
    end)
    
    widget:addDataProxy("godName",function(evt)
        return Language.MSG_GOD
    end)
    widget:addDataProxy("curGodNum",function(evt)
        return ch.NumberHelper:toString(ch.MoneyModel:getGods())
    end)
    widget:addDataProxy("godNum",function(evt)
        return ch.NumberHelper:toString(ch.MoneyModel:getGods() + GameConst.REBORN_GODS_NUM)
    end)
    widget:addDataProxy("godIcon",function(evt)
        return "res/icon/icon_shenling_2.png"
    end)
    
    -- 显示Tips
    local showTip = false
    widget:addDataProxy("isShowTip",function(evt)
        return showTip
    end)
    widget:addCommond("showTip",function(obj,type)
        if type == ccui.TouchEventType.began then
            showTip = true
            widget:noticeDataChange("isShowTip")
        elseif type == ccui.TouchEventType.ended or type == ccui.TouchEventType.canceled then
            showTip = false
            widget:noticeDataChange("isShowTip")
        end 
    end)
end)

---
-- 转生方式选择界面
zzy.BindManager:addFixedBind("fuwen/W_gjzs",function(widget)
    local num = math.floor((ch.RunicModel:getLevel()+ch.MagicModel:getTotalLevel())/GameConst.SOUL_LEVEL)+ch.MoneyModel:getsStone()+ch.TaskModel:getCurPowerNum()
    
    --普通转生
    local function ptsz()
        ch.fightRoleLayer:pause()
        ch.NetworkController:samsara()
        local tmpDPS = ch.StatisticsModel:getSoulRatio(num,ch.StatisticsModel:getRTimes()+1)      
        ch.RunicModel:setSamsaraData({num=num,ratio=tmpDPS})
        if tmpDPS > 1 then
            ch.fightBackground:playDoubleDPSEffect(ch.NumberHelper:harmToString(tmpDPS),function()
                ch.UIManager:showGamePopup("fuwen/W_Prestigepop")
            end)
        else
            ch.UIManager:showGamePopup("fuwen/W_Prestigepop")
        end
        widget:destory()
    end
    
    widget:addCommond("ptzs",function()
        if ch.MoneyModel:getsStone() < GameConst.SAMSARA_SSTONE_NUM then
            ch.UIManager:showMsgBox(2,true,GameConst.SAMSARA_SSTONE_TIP,ptsz,nil,Language.MSG_BUTTON_OK,2)
        else
            ptsz()
        end
    end)
    
    --高级转生
    local function gjzs()
        ch.fightRoleLayer:pause()
        ch.NetworkController:superSamsara()
        local tmpDPS = ch.StatisticsModel:getSoulRatio(num,ch.StatisticsModel:getRTimes()+1)      
        ch.RunicModel:setSamsaraData({num=num,ratio=tmpDPS})
        if tmpDPS > 1 then
            ch.fightBackground:playDoubleDPSEffect(ch.NumberHelper:harmToString(tmpDPS),function()
                ch.UIManager:showGamePopup("fuwen/W_Prestigepop")
            end)
        else
            ch.UIManager:showGamePopup("fuwen/W_Prestigepop")
        end
        widget:destory()
    end
    widget:addCommond("gjzs",function()
        if ch.MoneyModel:getsStone() < GameConst.SAMSARA_SSTONE_NUM then
            ch.UIManager:showMsgBox(2,true,GameConst.SAMSARA_SSTONE_TIP,gjzs,nil,Language.MSG_BUTTON_OK,2)
        else
            gjzs()
        end
    end)
    
    --高级转生是否可用
    widget:addDataProxy("gjzsEnabled",function()
        local timesEnough = ch.StatisticsModel:getRTimes() >= 30
        local isYueka = ch.BuffModel:getCardBuffTime() > 0
        
        return timesEnough and isYueka
    end)
    
    --关闭
    widget:addCommond("close",function()
        widget:destory()
    end)
    
    widget:addDataProxy("countTimes",function(evt)
        return string.format(Language.src_clickhero_view_RunicView_8,ch.StatisticsModel:getRTimes()+1)
    end)
end)

---
-- 首次转生提醒界面
zzy.BindManager:addFixedBind("fuwen/W_Prestigepop",function(widget)
    local tmpData = ch.RunicModel:getSamsaraData()
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_RunicView_13
    end)
    widget:addDataProxy("desc",function(evt)
        local gold = "0"
        if ch.TotemModel:getTotemSkillData(2,1) > GameConst.RUNIC_SAMSARA_GOLD then
            gold = ch.NumberHelper:toString(ch.TotemModel:getTotemSkillData(2,1))
        else
            gold = ch.NumberHelper:toString(GameConst.RUNIC_SAMSARA_GOLD)
        end
        return string.format(Language.src_clickhero_view_RunicView_14,gold)
    end)
    widget:addDataProxy("allSoulNum",function(evt)
        return ch.NumberHelper:toString(tmpData.num)
    end)
    
    widget:addDataProxy("soulRatio",function(evt)
        local tmpDPS = ch.StatisticsModel:getSoulRatio(1,ch.StatisticsModel:getRTimes())
        return "+"..ch.NumberHelper:multiple(tmpDPS*100,1000)
    end)
end)