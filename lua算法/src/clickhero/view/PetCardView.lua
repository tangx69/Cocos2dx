local PAGEVIEW_CHANGE_CARD_EVENT = "PAGEVIEW_CHANGE_CARD"
local CARD_DETAIL_OPEN_EVENT = "CARD_DETAIL_OPEN"

-- 固有绑定
-- 魔宠卡牌界面
zzy.BindManager:addFixedBind("card/W_card_list", function(widget)
    local petCardChangeEvent = {}
    petCardChangeEvent[ch.PetCardModel.dataChangeEventType] = false
    
    local myCardListChangeEvent = {}
    myCardListChangeEvent[ch.ArenaModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ArenaModel.dataType.myCardList
    end
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.runic
    end
    local cardLevelChangeEvent = {}
    cardLevelChangeEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.PetCardModel.dataType.level
    	       or evt.dataType == ch.PetCardModel.dataType.talent
    end
    
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_PetCardView_1
    end)
    
    widget:addDataProxy("desc",function(evt)
        if ch.StatisticsModel:getMaxLevel() > GameConst.ARENA_OPEN_LEVEL then
            return ""
        elseif ch.StatisticsModel:getMaxLevel() > GameConst.ALTAR_OPEN_LEVEL[1] then
            return string.format(GameConst.PETCARD_OPEN_DESC[3],GameConst.ARENA_OPEN_LEVEL) 
        elseif ch.StatisticsModel:getMaxLevel() > GameConst.PETCARD_OPEN_LEVEL then
            return string.format(GameConst.PETCARD_OPEN_DESC[2],GameConst.ALTAR_OPEN_LEVEL[1]) 
        else
            return string.format(GameConst.PETCARD_OPEN_DESC[1],GameConst.PETCARD_OPEN_LEVEL) 
        end
    end,petCardChangeEvent)

    widget:addDataProxy("runicNum",function(evt)
        return ch.MoneyModel:getRunic()
    end,moneyChangeEvent)
    
    widget:addDataProxy("ifOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel() > GameConst.ARENA_OPEN_LEVEL
    end)
    
    widget:addDataProxy("notOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel() <= GameConst.ARENA_OPEN_LEVEL
    end)
    
    if ch.StatisticsModel:getMaxLevel() <= GameConst.ARENA_OPEN_LEVEL then
        widget:listen(ch.LevelModel.dataChangeEventType,function(obj,evt)
            if evt.dataType == ch.LevelModel.dataType.curLevel then
                widget:noticeDataChange("ifOpen")
                widget:noticeDataChange("notOpen")
                widget:noticeDataChange("hasCard")
            end
        end)
    end
    
    widget:addDataProxy("hasCard",function(evt)
        return ch.StatisticsModel:getMaxLevel() > GameConst.PETCARD_OPEN_LEVEL
    end)

    widget:addDataProxy("lvNum",function(evt)
        return ch.PetCardModel:getAllPowerLV()
    end,cardLevelChangeEvent)
    widget:addDataProxy("powerNum",function(evt)
        return ch.PetCardModel:getAllPower()
    end,cardLevelChangeEvent)
    widget:addDataProxy("dpsRatio",function(evt)
        return "+"..ch.NumberHelper:multiple(ch.PetCardModel:getAllPowerDPS()*100,1000)
    end,cardLevelChangeEvent)
    widget:addDataProxy("exp",function(evt)
        local expPre = GameConst.CARD_POWER_LEVEL_EXP[ch.PetCardModel:getAllPowerLV()-1] or 0
        local expNext = GameConst.CARD_POWER_LEVEL_EXP[ch.PetCardModel:getAllPowerLV()]
        if expNext < 1 then
            return "0/0"
        else
            return string.format("%d/%d",ch.PetCardModel:getAllPower()-expPre,expNext-expPre)
        end
    end,cardLevelChangeEvent)
    widget:addDataProxy("expProgress",function(evt)
        local expPre = GameConst.CARD_POWER_LEVEL_EXP[ch.PetCardModel:getAllPowerLV()-1] or 0
        local expNext = GameConst.CARD_POWER_LEVEL_EXP[ch.PetCardModel:getAllPowerLV()]
        if expNext < 1 then
            return 100
        else
            return (ch.PetCardModel:getAllPower()-expPre)/(expNext-expPre)*100
        end
    end,cardLevelChangeEvent)
    
    widget:addCommond("changeGroup",function()
        ch.UIManager:showGamePopup("card/W_card_f_choose",{type=2})
    end)
    
    widget:addCommond("openArena",function()
        ch.NetworkController:arenaPanel()
        --结束引导
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10180 then
            ch.guide:endid(10180)
        end
    end)
    
    widget:addDataProxy("cardList",function(evt)
        local tmpTable = {}
        for k,v in pairs(ch.PetCardModel:getAllPetCardID()) do
            table.insert(tmpTable,{index=k,id=v})
        end
        return tmpTable
    end,petCardChangeEvent)
    
    widget:addDataProxy("direction",function(evt)
        return ccui.ListViewDirection.horizontalSnap
    end)
    
    widget:addCommond("popClose",function()
        ch.UIManager:closeBottomPopup("card/W_card_list")
        ch.SoundManager:play("close")
        ch.PetCardModel:cleanNewCardList()
        ch.PetCardModel:cleanNewChipList()
    end)
end)

-- 卡牌单元
zzy.BindManager:addCustomDataBind("card/W_card_1", function(widget,data)
    local petCardChangeEvent = {}
    petCardChangeEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.id == data.id
    end
    
    local openDetailEvent = {}
    openDetailEvent[CARD_DETAIL_OPEN_EVENT] = false
    openDetailEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.id == data.id
    end

    local config = GameConfig.CardConfig:getData(data.id)
    widget:addDataProxy("isCard",function(evt)
        return ch.PetCardModel:getLevel(data.id) > 0
    end,petCardChangeEvent)
    
    widget:addDataProxy("isChip",function(evt)
        return ch.PetCardModel:getLevel(data.id) < 1
    end,petCardChangeEvent)
    
    widget:addDataProxy("isChipDB1",function(evt)
        if ch.PetCardModel:getLevel(data.id) < 1 then
            return "aaui_card/db_bw4card_no.png"
        else
            return "aaui_card/db_bw4card.png"
        end
    end,petCardChangeEvent)
    
    widget:addDataProxy("isChipDB2",function(evt)
        if ch.PetCardModel:getLevel(data.id) < 1 then
            return "aaui_card/db_card_s_f_no.png"
        else
            return "aaui_card/db_card_s_f.png"
        end
    end,petCardChangeEvent)
    
    widget:addDataProxy("isChipDB3",function(evt)
        if ch.PetCardModel:getLevel(data.id) < 1 then
            return "aaui_card/db_barframe_no.png"
        else
            return "aaui_rank/db_barframe.png"
        end
    end,petCardChangeEvent)
    
    widget:addDataProxy("cardName",function(evt)
        if ch.PetCardModel:getStar(data.id) < 1 then
            return config.name
        else
            return config.name.."+"..ch.PetCardModel:getStar(data.id)
        end
    end,petCardChangeEvent)
    
    widget:addDataProxy("cardNameColor",function(evt)
        return GameConst.PETCARD_COLOR[GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).color]
    end,petCardChangeEvent)
    
    widget:addDataProxy("cardIcon",function(evt)
        return config.mini
    end)
    widget:addDataProxy("flagHeight",function(evt)
        if GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).star < 3 then
            return 110
        else
            return 110+34*(GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).star-2)
        end
    end,petCardChangeEvent)

    widget:addDataProxy("jobIcon",function(evt)
        return GameConst.PETCARD_JOB[config.job].icon
    end)
    
    widget:addDataProxy("chipNum",function(evt)
        return ch.PetCardModel:getChipNum(data.id).."/"..ch.PetCardModel:getChipCost(data.id)
    end,petCardChangeEvent)
    
    widget:addDataProxy("chipNumColor",function(evt)
        if ch.PetCardModel:getChipNum(data.id) < ch.PetCardModel:getChipCost(data.id) or ch.PetCardModel:getChipCost(data.id) < 1 then
            widget:stopEffect("playCardUp")
--            return cc.c3b(255,0,0)
        else
            widget:playEffect("playCardUp",true)
--            return cc.c3b(0,255,0)
        end
        return cc.c3b(255,255,255)
    end,petCardChangeEvent)
    
    widget:addDataProxy("chipEnough",function(evt)
        return ch.PetCardModel:getChipNum(data.id) >= ch.PetCardModel:getChipCost(data.id)
    end,petCardChangeEvent)
    
    widget:addDataProxy("chipNotEnough",function(evt)
        return ch.PetCardModel:getChipNum(data.id) < ch.PetCardModel:getChipCost(data.id)
    end,petCardChangeEvent)
    
    widget:addDataProxy("chipProgress",function(evt) 
        if not ch.PetCardModel:getChipCost(data.id) or ch.PetCardModel:getChipCost(data.id) < 1 or ch.PetCardModel:getChipNum(data.id) > ch.PetCardModel:getChipCost(data.id) then
            return 1
        else
            return ch.PetCardModel:getChipNum(data.id)/ch.PetCardModel:getChipCost(data.id)
        end
    end,petCardChangeEvent)

    widget:addDataProxy("magicIcon",function(evt)
        return GameConfig.MagicConfig:getData(config.magic).icon
    end)
    
    widget:addDataProxy("getNewEffect",function(evt)
        if ch.PetCardModel:getNewCardList(data.id) or (ch.PetCardModel:getLevel(data.id) < 1 and ch.PetCardModel:getChipNum(data.id) >= ch.PetCardModel:getChipCost(data.id))then
            widget:playEffect("playCardGet",true)
        else
            widget:stopEffect("playCardGet")
        end
    end,openDetailEvent)
    
    widget:addCommond("openDetail",function()
        ch.PetCardModel:setNewCardList(data.id)
        local evt = {type = CARD_DETAIL_OPEN_EVENT}
        zzy.EventManager:dispatch(evt)
        ch.UIManager:showGamePopup("card/W_card_detaillist",data.id)
        -- 直接打开界面，无特殊处理了
--        if ch.PetCardModel:getLevel(data.id) < 1 then
--            if ch.PetCardModel:getChipNum(data.id) >= ch.PetCardModel:getChipCost(data.id) then
--                ch.UIManager:showMsgBox(1,true,"当前可合成新的魔宠卡牌",function()
--                    ch.NetworkController:getNewCard(data.id)
--                    local costChip = ch.PetCardModel:getChipCost(data.id)
--                    ch.PetCardModel:addLevel(data.id)
--                    ch.PetCardModel:addChip(data.id,-costChip)
--                    ch.UIManager:showGamePopup("card/W_card_get",{id=data.id,auto=false})
--                end,nil,"准奏",1)
--            else
--                ch.UIManager:showUpTips("碎片不足~~")
--            end
--        else
--            ch.UIManager:showGamePopup("card/W_card_detaillist",data.id)
--        end
    end)
end)

-- 卡牌单元
zzy.BindManager:addCustomDataBind("card/W_card_bg", function(widget,data)
    local petCardChangeEvent = {}
    petCardChangeEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.id == data.id
    end

    local openDetailEvent = {}
    openDetailEvent[CARD_DETAIL_OPEN_EVENT] = false
    openDetailEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.id == data.id
    end

    local fightingChangeEvent = {}
    fightingChangeEvent[ch.ArenaModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ArenaModel.dataType.myCardList
    end

    local config = GameConfig.CardConfig:getData(data.id)
       
    widget:addDataProxy("isFighting",function(evt)
        return ch.ArenaModel:isInGroup(data.id)
    end,fightingChangeEvent)
    
    widget:addDataProxy("isCard",function(evt)
        return ch.PetCardModel:getLevel(data.id) > 0
    end,petCardChangeEvent)

    widget:addDataProxy("isChip",function(evt)
        return ch.PetCardModel:getLevel(data.id) < 1
    end,petCardChangeEvent)

    widget:addDataProxy("isChipDB",function(evt)
        if ch.PetCardModel:getLevel(data.id) < 1 then
            return "aaui_card/card_bg_no.png"
        else
            return "aaui_card/card_bg_have.png"
        end
    end,petCardChangeEvent)            
    
    widget:addDataProxy("cardName",function(evt)
        if ch.PetCardModel:getStar(data.id) < 1 then
            return config.name
        else
            return config.name.."+"..ch.PetCardModel:getStar(data.id)
        end
    end,petCardChangeEvent)

    widget:addDataProxy("cardNameColor",function(evt)
        if ch.PetCardModel:getLevel(data.id) < 1 then
            return cc.c3b(230,230,230)
        else
            return GameConst.PETCARD_COLOR[GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).color]
        end
    end,petCardChangeEvent)

    widget:addDataProxy("cardIcon",function(evt)
        return config.mini
    end)

    widget:addDataProxy("iconFrame",function(evt)
        return GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).iconFrame
    end,petCardChangeEvent)

    widget:addDataProxy("jobIcon",function(evt)
        return GameConst.PETCARD_JOB[config.job].icon
    end)

    widget:addDataProxy("chipNum",function(evt)
        return ch.PetCardModel:getChipNum(data.id).."/"..ch.PetCardModel:getChipCost(data.id)
    end,petCardChangeEvent)

    widget:addDataProxy("chipEnough",function(evt)
        return ch.PetCardModel:getChipNum(data.id) >= ch.PetCardModel:getChipCost(data.id)
    end,petCardChangeEvent)

    widget:addDataProxy("chipNotEnough",function(evt)
        return ch.PetCardModel:getChipNum(data.id) < ch.PetCardModel:getChipCost(data.id)
    end,petCardChangeEvent)

    widget:addDataProxy("chipProgress",function(evt) 
        if not ch.PetCardModel:getChipCost(data.id) or ch.PetCardModel:getChipCost(data.id) < 1 or ch.PetCardModel:getChipNum(data.id) > ch.PetCardModel:getChipCost(data.id) then
            return 1
        else
            return ch.PetCardModel:getChipNum(data.id)/ch.PetCardModel:getChipCost(data.id)
        end
    end,petCardChangeEvent)

    widget:addDataProxy("magicIcon",function(evt)
        return GameConfig.MagicConfig:getData(config.magic).icon
    end)
    widget:addDataProxy("talentImg",function(evt)
        return GameConst.CARD_TALENT_IMAGE[ch.PetCardModel:getTalent(data.id)]
    end,petCardChangeEvent)
    -- csb部分
    widget:addDataProxy("data",function(evt)
        local ret = {}
        local quality = ch.PetCardModel:getQuality(data.id)
        -- 星星变化
        local maxStar = GameConfig.CarduplevelConfig:getData(quality).max_star
        ret.star1 = maxStar == 4
        ret.star2 = maxStar == 3
        ret.star3 = maxStar == 4 or maxStar == 2
        ret.star4 = maxStar == 3 or maxStar == 1
        ret.star5 = maxStar == 4 or maxStar == 2
        ret.star6 = maxStar == 3
        ret.star7 = maxStar == 4
        
        local star = ch.PetCardModel:getStar(data.id)
        ret.starImg1 = (maxStar == 4 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg2 = (maxStar == 3 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg3 = ((maxStar == 4 and star >= 2) or (maxStar == 2 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg4 = ((maxStar == 3 and star >= 2) or (maxStar == 1 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg5 = ((maxStar == 4 and star >= 3) or (maxStar == 2 and star >= 2)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg6 = (maxStar == 3 and star >= 3) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg7 = (maxStar == 4 and star >= 4) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        
        return ret
    end,petCardChangeEvent)

    widget:addDataProxy("getNewEffect",function(evt)
        if ch.PetCardModel:getNewCardList(data.id) or (ch.PetCardModel:getLevel(data.id) < 1 and ch.PetCardModel:getChipNum(data.id) >= ch.PetCardModel:getChipCost(data.id))then
            widget:playEffect("playCardGet",true)
        else
            widget:stopEffect("playCardGet")
        end
    end,openDetailEvent)

    widget:addCommond("openDetail",function()
        ch.PetCardModel:setNewCardList(data.id)
        local evt = {type = CARD_DETAIL_OPEN_EVENT}
        zzy.EventManager:dispatch(evt)
        ch.UIManager:showGamePopup("card/W_card_detaillist",data.id)
        -- 直接打开，不加其他判断
--        if ch.PetCardModel:getLevel(data.id) < 1 then
--            if ch.PetCardModel:getChipNum(data.id) >= ch.PetCardModel:getChipCost(data.id) then
--                local str = "当前可合成"..GameConfig.CardConfig:getData(data.id).name
--                ch.UIManager:showMsgBox(2,true,str,function()
--                    ch.NetworkController:getNewCard(data.id)
--                    local costChip = ch.PetCardModel:getChipCost(data.id)
--                    ch.PetCardModel:addLevel(data.id)
--                    ch.PetCardModel:addChip(data.id,-costChip)
--                    ch.RoleResManager:loadEffect("tx_kapaichuxian")
--                    local ani = ccs.Armature:create("tx_kapaichuxian")
--                    ani:getAnimation():play("chuxian",-1,0)
--                    local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
--                    ani:setPosition(size.width/2,size.height/2)
--                    ch.UIManager:getNavigationLayer():addChild(ani,1)
--                    ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
--                        if movementType == ccs.MovementEventType.complete then
--                            ani:removeFromParent()
--                            ch.RoleResManager:releaseEffect("tx_kapaichuxian")
--                        end
--                    end)
--                    zzy.TimerUtils:setTimeOut(0.6,function()
--                        local path = GameConfig.CardConfig:getData(data.id).img
--                        local spr = cc.Sprite:create(path)
--                        local scale = 640/spr:getContentSize().width
--                        spr:setScale(scale)
--                        spr:setPosition(size.width/2,size.height/2)
--                        ch.UIManager:getNavigationLayer():addChild(spr)
--                        zzy.TimerUtils:setTimeOut(1.2,function()
--                            local act1 = cc.FadeOut:create(0.3)
--                            local seq = cc.Sequence:create(act1,cc.CallFunc:create(function()
--                                spr:removeFromParent()
--                            end))
--                            spr:runAction(seq)
--                            local scale = spr:getScale()*1.5
--                            local act2 = cc.EaseExponentialIn:create(cc.ScaleTo:create(0.3,scale))
--                            spr:runAction(act2)
--                        end)
--                    end)
--                   -- ch.UIManager:showGamePopup("card/W_card_get",{id=data.id,auto=false})
--                end,nil,"立即合成",1)
--            else
--                ch.UIManager:showUpTips("碎片不足~~")
--            end
--        else
--            ch.UIManager:showGamePopup("card/W_card_detaillist",data.id)
--        end
    end)
end)

-- 卡牌详情界面
zzy.BindManager:addCustomDataBind("card/W_card_detaillist", function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[PAGEVIEW_CHANGE_CARD_EVENT] = false

    local petCardChangeEvent = {}
    petCardChangeEvent[ch.PetCardModel.dataChangeEventType] = false
    petCardChangeEvent[PAGEVIEW_CHANGE_CARD_EVENT] = false
    
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.runic
    end
    
    local talentChangeEvent = {}
    talentChangeEvent[ch.PetCardModel.dataChangeEventType] = false
    talentChangeEvent[PAGEVIEW_CHANGE_CARD_EVENT] = false
    talentChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.spirit
    end
    
        
--    local cardList = ch.PetCardModel:getCardID()
    local cardList = ch.PetCardModel:getAllPetCardID()
--    local cardList = ch.PetCardModel:getDetailCardID()
    local maxPage = table.maxn(cardList)
    local curID = tonumber(data)
    local index = ch.PetCardModel:getIndexByCardID(cardList,curID)
    
    local maxStar = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(curID)).max_star
    local star = ch.PetCardModel:getStar(curID)
    local level = ch.PetCardModel:getLevel(curID)
    local isUp = true
    if level < #GameConfig.CarduplevelConfig:getTable() then
        isUp = GameConfig.CarduplevelConfig:getData(level + 1).upgrade_Jdg == 1
    end
    
    local turnPage = function(page)
        index = page
        curID = cardList[index]
        maxStar = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(curID)).max_star
        star = ch.PetCardModel:getStar(curID)
        level = ch.PetCardModel:getLevel(curID)
        if level < #GameConfig.CarduplevelConfig:getTable() then
            isUp = GameConfig.CarduplevelConfig:getData(level + 1).upgrade_Jdg == 1
        end
        local evt = {type = PAGEVIEW_CHANGE_CARD_EVENT}
        zzy.EventManager:dispatch(evt)
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end
    
    local costType = 0
    local runicNumCost = 0
    
    widget:addDataProxy("notFirst",function(evt)
        return index > 1
    end,pageChangeEvent)
    widget:addDataProxy("notLast",function(evt)
        return index < maxPage
    end,pageChangeEvent)
    
    widget:addCommond("prevCard",function()
        turnPage(index-1)
    end)
    widget:addCommond("nextCard",function()
        turnPage(index+1)
    end)
    
    widget:addCommond("getCard",function()
        local colorChanged = isUp
        level = level + 1
        if level < #GameConfig.CarduplevelConfig:getTable() then
            isUp = GameConfig.CarduplevelConfig:getData(level + 1).upgrade_Jdg == 1
        end
        if ch.PetCardModel:getLevel(curID) > 0 then
            ch.NetworkController:cardLevelUp(curID,costType,runicNumCost)
            local costChip = ch.PetCardModel:getChipCost(curID)            
            ch.MoneyModel:addRunic(-runicNumCost)
            ch.PetCardModel:addChip(curID,-costChip+runicNumCost)
            ch.PetCardModel:addLevel(curID)
           -- ch.UIManager:showGamePopup("card/W_card_get",{id=curID,auto=false})
            maxStar = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(curID)).max_star
            star = ch.PetCardModel:getStar(curID)
            if colorChanged then
                widget:playEffect("advancedStart",false,function()
                    widget:noticeDataChange("isSenior")
                    widget:noticeDataChange("isBasic")
                    widget:noticeDataChange("bgFrame")
                    widget:noticeDataChange("bgFrameTag")
                                      
                    widget:playEffect("advancedEnd")
                    for i= 1,7 do
                        widget:noticeDataChange("starImg"..i)
                    end
                end)
            else
                local num = ch.PetCardModel:getStarIndex(level)
                widget:playEffect("star"..num,false,function()
                    widget:noticeDataChange("starImg"..num)
                end)
            end
        else
            ch.NetworkController:getNewCard(curID)
            local costChip = ch.PetCardModel:getChipCost(curID)
            ch.PetCardModel:addLevel(curID)
            ch.PetCardModel:addChip(curID,-costChip)
            ch.CommonFunc:cardDropEffect(curID)
        end
    end)
    
    widget:addCommond("openFB",function()
        ch.UIManager:cleanGamePopupLayer(true)
        ch.UIManager:showGamePopup("cardInstance/W_cardins",nil,nil,nil,"cardInstance/W_cardins")
        -- 定位
        ch.CardFBModel.cardOpenIndex = curID
        local evt = {type = ch.CardFBModel.cardPopOpenEventType}
        zzy.EventManager:dispatch(evt)
    end)
    
    widget:addCommond("select",function(widget,arg)
        -- 1是选中，0为取消选中
        if arg == "0" then
            ch.PetCardModel:setRunicSelect(curID,false)
        else
            ch.PetCardModel:setRunicSelect(curID,true)
        end
    end)
    
    widget:addDataProxy("starImg1",function()
        return (maxStar == 4 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
    end,pageChangeEvent)
    widget:addDataProxy("starImg2",function()
        return (maxStar == 3 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
    end,pageChangeEvent)
    widget:addDataProxy("starImg3",function()
        return ((maxStar == 4 and star >= 2) or (maxStar == 2 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
    end,pageChangeEvent)
    widget:addDataProxy("starImg4",function()
        return ((maxStar == 3 and star >= 2) or (maxStar == 1 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
    end,pageChangeEvent)
    widget:addDataProxy("starImg5",function()
        return ((maxStar == 4 and star >= 3) or (maxStar == 2 and star >= 2)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
    end,pageChangeEvent)
    widget:addDataProxy("starImg6",function()
        return (maxStar == 3 and star >= 3) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
    end,pageChangeEvent)
    widget:addDataProxy("starImg7",function()
        return (maxStar == 4 and star >= 4) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
    end,pageChangeEvent)
    widget:addDataProxy("bgFrame",function()
        return GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(curID)).bgFrame
    end,pageChangeEvent)
    widget:addDataProxy("bgFrameTag",function()
        local tag = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(curID)).bgFrame_tag
        if tag and tag ~= "" then
            return tag
        else
            return "res/icon/dot1.png"
        end
    end,pageChangeEvent)
    widget:addDataProxy("isBasic",function()
        return ch.PetCardModel:getLevel(curID) <= GameConst.PETCARD_LEVEL_TAG
    end,pageChangeEvent)
    widget:addDataProxy("isSenior",function()
        return ch.PetCardModel:getLevel(curID) > GameConst.PETCARD_LEVEL_TAG
    end,pageChangeEvent)
    
    widget:addDataProxy("runicNum",function()
        return 0
    end)

    widget:addDataProxy("runicNum",function()
        return "0/"..ch.MoneyModel:getRunic()
    end,moneyChangeEvent)
    
    -- csb部分
    widget:addDataProxy("data",function(evt)
        local ret = {}
        ret.cardId = cardList[index]
        local config = GameConfig.CardConfig:getData(ret.cardId)
        local quality = ch.PetCardModel:getQuality(ret.cardId)
        if ch.PetCardModel:getStar(ret.cardId) < 1 then
            ret.cardName = config.name
        else
            ret.cardName = config.name.." +"..ch.PetCardModel:getStar(ret.cardId)
        end
--        ret.cardNameColor = GameConst.PETCARD_COLOR[GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(ret.cardId)).color]
        ret.cardNameColor = cc.c3b(255,255,255)
        ret.titleImg = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(ret.cardId)).title_img
        ret.talentIcon = GameConst.CARD_TALENT_IMAGE[ch.PetCardModel:getTalent(ret.cardId)]
        ret.cardIcon = config.img
        ret.talentText = ch.PetCardModel:getTalent(ret.cardId)
        if GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(ret.cardId)).star < 3 then
            ret.flagHeight = 110
        else
            ret.flagHeight = 110+34*(GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(ret.cardId)).star-2)
        end
        ret.jobIcon = GameConst.PETCARD_JOB[config.job].icon
        ret.jobName = GameConst.PETCARD_JOB[config.job].name
        ret.nameVis = false
        ret.talentImg = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(ret.cardId)).talent_img
        -- 星星变化
        local maxStar = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(ret.cardId)).max_star

        ret.star1 = maxStar == 4
        ret.star2 = maxStar == 3
        ret.star3 = maxStar == 4 or maxStar == 2
        ret.star4 = maxStar == 3 or maxStar == 1
        ret.star5 = maxStar == 4 or maxStar == 2
        ret.star6 = maxStar == 3
        ret.star7 = maxStar == 4
        -- 属性
        ret.pvpPower = math.floor(ch.PetCardModel:getTeamPower({{id=ret.cardId,l=ch.PetCardModel:getQuality(ret.cardId),talent= ch.PetCardModel:getTalent(ret.cardId)}})) 
        ret.pvpHP = math.floor(ch.PetCardModel:getHP(ret.cardId,quality))
        ret.pvpAP = math.floor(ch.PetCardModel:getAP(ret.cardId,quality))
        ret.pvpCR = math.floor(ch.PetCardModel:getCR(ret.cardId,quality))
        ret.pvpAC = math.floor(ch.PetCardModel:getAC(ret.cardId,quality))
        ret.pvpDC = math.floor(ch.PetCardModel:getDC(ret.cardId,quality))
        ret.skillName = GameConfig.CardskillConfig:getData(config.skillid).name
        ret.skillDes = GameConfig.CardskillConfig:getData(config.skillid).desc
--        ret.chipNum = ch.PetCardModel:getChipNum(ret.cardId).."/"..ch.PetCardModel:getChipCost(ret.cardId)
--        ret.needChipNum = "/"..ch.PetCardModel:getChipCost(ret.cardId)
        if not ch.PetCardModel:getChipCost(ret.cardId) or ch.PetCardModel:getChipCost(ret.cardId) < 1 then
            ret.chipProgress = 1
        else
            ret.chipProgress = ch.PetCardModel:getChipNum(ret.cardId)/ch.PetCardModel:getChipCost(ret.cardId)
        end
        ret.runicProgress = 1
        ret.chipEnough = ch.PetCardModel:getChipNum(ret.cardId) >= ch.PetCardModel:getChipCost(ret.cardId)
        ret.chipNotEnough = ch.PetCardModel:getChipNum(ret.cardId) < ch.PetCardModel:getChipCost(ret.cardId)
--        if ch.PetCardModel:getChipNum(ret.cardId) < ch.PetCardModel:getChipCost(ret.cardId) then
--            ret.chipNumColor = cc.c3b(255,0,0)
--        else
--            ret.chipNumColor = cc.c3b(0,255,0)
--        end
        ret.chipNumColor = cc.c3b(255,255,255)
        ret.notMaxLevel = ch.PetCardModel:getLevel(ret.cardId) < GameConst.PETCARD_LEVEL_MAX
        ret.magicIcon = GameConfig.MagicConfig:getData(config.magic).icon
        ret.magicName = GameConfig.MagicConfig:getData(config.magic).name
        ret.magicAddRatio = string.format("+%.2f%%",(ch.PetCardModel:addMagicRatio(config.magic)-1)*100)
        ret.outputNum = ch.AltarModel:getOutput(ch.PetCardModel:getQuality(ret.cardId))
        local level = ch.PetCardModel:getLevel(ret.cardId)
        
        ret.barFrame = isUp and "aaui_card/db_bar_0.png" or "aaui_card/db_bar.png"
        ret.btnNormal=  isUp and "aaui_button/btn_c_gboss1.png" or "aaui_button/btn_c_freeb1.png"
        ret.btnPressed = isUp and "aaui_button/btn_c_gboss2.png" or "aaui_button/btn_c_freeb2.png"
        ret.ifSelect = ch.PetCardModel:isRunicSelect(ret.cardId)
        local runicChipNum = ch.PetCardModel:getChipNum(ret.cardId)
        if ret.ifSelect then
            runicChipNum = runicChipNum + ch.MoneyModel:getRunic()
        end
        ret.isCard = level > 0
        if ret.isCard then
            ret.btnText = isUp and Language.src_clickhero_view_PetCardView_2 or Language.src_clickhero_view_PetCardView_3
            ret.ifCanUp = runicChipNum >= ch.PetCardModel:getChipCost(curID)
        else
            ret.btnText = Language.src_clickhero_view_PetCardView_4
            ret.ifCanUp = ch.PetCardModel:getChipNum(curID) >= ch.PetCardModel:getChipCost(curID)
        end
        ret.noCard = level < 1
        ret.canOpenFB = ch.StatisticsModel:getMaxLevel() > GameConst.CARD_FB_OPEN_LEVEL and level > 0 and level < GameConst.PETCARD_LEVEL_MAX
        
        runicNumCost = ch.PetCardModel:getChipCost(curID) - ch.PetCardModel:getChipNum(curID)
        if runicNumCost < 0 or not ret.ifSelect then
            runicNumCost = 0
        elseif runicNumCost > ch.MoneyModel:getRunic() then
            runicNumCost = ch.MoneyModel:getRunic()
        end
        ret.runicNum = runicNumCost.."/"..ch.MoneyModel:getRunic()
        
        ret.chipNum = runicChipNum.."/"..ch.PetCardModel:getChipCost(ret.cardId)
        if not ch.PetCardModel:getChipCost(ret.cardId) or ch.PetCardModel:getChipCost(ret.cardId) < 1 then
            ret.runicProgress = 1
        else
            ret.runicProgress = runicChipNum/ch.PetCardModel:getChipCost(ret.cardId)
        end
        costType = (ret.ifSelect and runicNumCost>0) and 1 or 0
        
        -- tgx
        INFO("[CARD][我的卡牌列表][卡牌详情]")
        local img_card = widget:getChild("img_card")
        img_card:setVisible(false)
        
        local aniPanel = widget:getChild("panel_card")
        ch.CommonFunc:showCardSke(aniPanel, ret.cardId, nil, nil, -20)
        -- tgx
    
        return ret
    end,petCardChangeEvent)
    widget:addCommond("openBigImage", function(evt)
        -- ch.UIManager:showGamePopup("card/W_card_get",{auto = false,id = curID}) -- tgx
    end)
    
    widget:addDataProxy("spiritNum",function()
        local cost = GameConst.CARD_TALENT_UP_COST[ch.PetCardModel:getTalent(curID)] or 0
        return string.format("%d/%d",ch.MoneyModel:getSpirit(),cost)
    end,talentChangeEvent)
    widget:addDataProxy("spiritBar",function()
        local cost = GameConst.CARD_TALENT_UP_COST[ch.PetCardModel:getTalent(curID)] or 0
        return ch.MoneyModel:getSpirit()/cost*100
    end,talentChangeEvent)
    widget:addDataProxy("talentImg1",function()
        return GameConst.CARD_TALENT_IMAGE[ch.PetCardModel:getTalent(curID)]
    end,talentChangeEvent)
    widget:addDataProxy("talentImg2",function()
        return GameConst.CARD_TALENT_IMAGE[ch.PetCardModel:getTalent(curID)+1]
            or GameConst.CARD_TALENT_IMAGE[ch.PetCardModel:getTalent(curID)]
    end,talentChangeEvent)
    
    widget:addDataProxy("ifCanTalentUp",function()
        local cost = GameConst.CARD_TALENT_UP_COST[ch.PetCardModel:getTalent(curID)] or 0
        return level > 0 and ch.MoneyModel:getSpirit()>=cost
    end,talentChangeEvent)
    widget:addDataProxy("notMaxTalent",function()
        return ch.PetCardModel:getTalent(curID)<GameConfig.CardConfig:getData(curID).talent_final
    end,talentChangeEvent)
    widget:addDataProxy("isMaxTalent",function()
        return ch.PetCardModel:getTalent(curID)>=GameConfig.CardConfig:getData(curID).talent_final
    end,talentChangeEvent)
    -- 升阶
    widget:addCommond("talentUp",function()
        ch.NetworkController:talentUp(curID)
        local cost = GameConst.CARD_TALENT_UP_COST[ch.PetCardModel:getTalent(curID)] or 0
        ch.MoneyModel:addSpirit(-cost)
        ch.PetCardModel:talentUp(curID)
        ch.UIManager:showGamePopup("card/W_card_tupojiesuan",curID)
        cclog("升阶")
    end)
    
end)

-- 获得整卡
zzy.BindManager:addCustomDataBind("card/W_card_get", function(widget,data)
    local stayTime = 2
    local leftTime = 0
    local startCountDown = function()
        local startTime = os_clock()
        widget:listen(zzy.Events.TickEventType,function()
            leftTime = stayTime - os_clock() + startTime
            if leftTime <= 0 then
                widget:destory()
            end
        end)
    end
    if data.auto then
        startCountDown()
    end
    
    widget:addDataProxy("title",function(evt)
        local config = GameConfig.CardConfig:getData(data.id)
        return config.name
--        if ch.PetCardModel:getQuality(data.id) < 2 then
--            return "获得魔宠"
--        else
--            return "魔宠进阶"
--        end
    end)

    widget:addDataProxy("data",function(evt)
        local ret = {}
        local config = GameConfig.CardConfig:getData(data.id)
        ret.cardName = ""
--        if ch.PetCardModel:getStar(data.id) < 1 then
--            ret.cardName = config.name
--        else
--            ret.cardName = config.name.." +"..ch.PetCardModel:getStar(data.id)
--        end
--        ret.cardNameColor = GameConst.PETCARD_COLOR[GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).color]
        ret.cardNameColor = cc.c3b(255,255,255)
        ret.cardIcon = config.img        
        ret.talentText = ch.PetCardModel:getTalent(data.id)
        ret.talentIcon = GameConst.CARD_TALENT_IMAGE[ch.PetCardModel:getTalent(data.id)]
        ret.jobIcon = GameConst.PETCARD_JOB[config.job].icon
        ret.bgFrame = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).bgFrame
        local tag = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).bgFrame_tag
        if tag and tag ~= "" then
            ret.bgFrameTag = tag
        else
            ret.bgFrameTag =  "res/icon/dot1.png"
        end
        ret.isBasic = ch.PetCardModel:getLevel(data.id) <= GameConst.PETCARD_LEVEL_TAG
        ret.isSenior = ch.PetCardModel:getLevel(data.id) > GameConst.PETCARD_LEVEL_TAG
        ret.talentImg = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).talent_img
        -- 星星变化
        local star = ch.PetCardModel:getStar(data.id)
        local maxStar = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).max_star
        ret.starImg1 = (maxStar == 4 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg2 = (maxStar == 3 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg3 = ((maxStar == 4 and star >= 2) or (maxStar == 2 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg4 = ((maxStar == 3 and star >= 2) or (maxStar == 1 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg5 = ((maxStar == 4 and star >= 3) or (maxStar == 2 and star >= 2)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg6 = (maxStar == 3 and star >= 3) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg7 = (maxStar == 4 and star >= 4) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"

        ret.star1 = maxStar == 4
        ret.star2 = maxStar == 3
        ret.star3 = maxStar == 4 or maxStar == 2
        ret.star4 = maxStar == 3 or maxStar == 1
        ret.star5 = maxStar == 4 or maxStar == 2
        ret.star6 = maxStar == 3
        ret.star7 = maxStar == 4
    
        return ret
    end)

    widget:addCommond("close", function(evt)
        widget:destory()
    end)
end)

-- 整卡转化成碎片
zzy.BindManager:addCustomDataBind("card/W_card_tochip", function(widget,data)
    local config = GameConfig.CardConfig:getData(data)
    widget:addDataProxy("cardName",function(evt)
        return config.name
    end)

    widget:addDataProxy("cardIcon",function(evt)
        return config.img
    end)
    widget:addDataProxy("flagHeight",function(evt)
        if GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data)).star < 3 then
            return 110
        else
            return 110+34*(GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data)).star-2)
        end
    end)

    widget:addDataProxy("jobIcon",function(evt)
        return GameConst.PETCARD_JOB[config.job].icon
    end)
end)

-- 品质提升界面
zzy.BindManager:addCustomDataBind("card/W_card_qualityup", function(widget,data)
    local config = GameConfig.CardConfig:getData(data)
    
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_PetCardView_5
    end)
    
    widget:addDataProxy("cardName",function(evt)
        if ch.PetCardModel:getStar(data) < 2 then
            return config.name
        else
            return config.name.."+"..ch.PetCardModel:getStar(data)-1
        end
    end)
    
    widget:addDataProxy("cardNameColor",function(evt)
        return GameConst.PETCARD_COLOR[GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data)).color]
    end)
    
    widget:addDataProxy("cardIcon",function(evt)
        return config.img
    end)
    
    widget:addDataProxy("flagHeight",function(evt)
        if GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data)).star < 3 then
            return 110
        else
            return 110+34*(GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data)).star-2)
        end
    end)

    widget:addDataProxy("jobIcon",function(evt)
        return GameConst.PETCARD_JOB[config.job].icon
    end)
    
    widget:addDataProxy("jobName",function(evt)
        return GameConst.PETCARD_JOB[config.job].name
    end)
    
    widget:addDataProxy("pvpHP",function(evt)
        return math.floor(ch.PetCardModel:getHP(data))
    end)
    
    widget:addDataProxy("pvpAP",function(evt)
        return math.floor(ch.PetCardModel:getAP(data))
    end)
    
    widget:addDataProxy("pvpCR",function(evt)
        return math.floor(ch.PetCardModel:getCR(data))
    end)
    
    widget:addDataProxy("chipNum",function(evt)
        return ch.PetCardModel:getChipNum(data)
    end)
    
    widget:addDataProxy("chipVis",function(evt)
        return false
    end)
    
    widget:addDataProxy("magicIcon",function(evt)
        return GameConfig.MagicConfig:getData(config.magic).icon
    end)
end)

-- 卡牌资质提升结算面板
zzy.BindManager:addCustomDataBind("card/W_card_tupojiesuan", function(widget,data)
    widget:addDataProxy("card_1",function(evt)
        return {id=data,talent=ch.PetCardModel:getTalent(data)-1,noTouch = true}
    end)
    
    widget:addDataProxy("card_2",function(evt)
        return {id=data,talent=ch.PetCardModel:getTalent(data),noTouch = true}
    end)

    widget:addDataProxy("data",function(evt)
        local ret = {}
        ret.cardId = data 
        ret.cardLevel = ch.PetCardModel:getLevel(ret.cardId)
        ret.cardTalent = ch.PetCardModel:getTalent(ret.cardId)
        ret.pvpPower = math.floor(ch.PetCardModel:getTeamPower({{id=ret.cardId,l=ret.cardLevel,talent = ret.cardTalent}})) 
        ret.pvpPower_1 = math.floor(ch.PetCardModel:getTeamPower({{id=ret.cardId,l=ret.cardLevel,talent = ret.cardTalent-1}})) 
        ret.pvpPower_2 = string.format("+%d",ret.pvpPower-ret.pvpPower_1)
        ret.pvpHP = math.floor(ch.PetCardModel:getHP(ret.cardId,ret.cardLevel,ret.cardTalent))
        ret.pvpHP_1 = math.floor(ch.PetCardModel:getHP(ret.cardId,ret.cardLevel,ret.cardTalent-1))
        ret.pvpHP_2 = string.format("+%d",ret.pvpHP-ret.pvpHP_1)
        ret.pvpAP = math.floor(ch.PetCardModel:getAP(ret.cardId,ret.cardLevel,ret.cardTalent))
        ret.pvpAP_1 = math.floor(ch.PetCardModel:getAP(ret.cardId,ret.cardLevel,ret.cardTalent-1))
        ret.pvpAP_2 = string.format("+%d",ret.pvpAP-ret.pvpAP_1)
        ret.pvpCR = math.floor(ch.PetCardModel:getCR(ret.cardId,ret.cardLevel,ret.cardTalent))
        ret.pvpCR_1 = math.floor(ch.PetCardModel:getCR(ret.cardId,ret.cardLevel,ret.cardTalent-1))
        ret.pvpCR_2 = string.format("+%d",ret.pvpCR-ret.pvpCR_1)
        ret.pvpAC = math.floor(ch.PetCardModel:getAC(ret.cardId,ret.cardLevel,ret.cardTalent))
        ret.pvpAC_1 = math.floor(ch.PetCardModel:getAC(ret.cardId,ret.cardLevel,ret.cardTalent-1))
        ret.pvpAC_2 = string.format("+%d",ret.pvpAC-ret.pvpAC_1)
        ret.pvpDC = math.floor(ch.PetCardModel:getDC(ret.cardId,ret.cardLevel,ret.cardTalent))
        ret.pvpDC_1 = math.floor(ch.PetCardModel:getDC(ret.cardId,ret.cardLevel,ret.cardTalent-1))
        ret.pvpDC_2 = string.format("+%d",ret.pvpDC-ret.pvpDC_1)

        return ret
    end)
end)


-- 卡牌获得界面
zzy.BindManager:addCustomDataBind("card/N_card_result", function(widget,data)
    widget:addDataProxy("btnText",function(evt)
        if data.id > 51000 then
            return Language.MSG_BUTTON_OK
        else
            return Language.MSG_BUTTON_VIEW
        end
    end)
    local config = GameConfig.CardConfig:getData(data.id)
    widget:addDataProxy("cardName",function(evt)
        return config.name
    end)
    
    widget:addDataProxy("cardIcon",function(evt)
        if data.id > 51000 then
            return GameConfig.CardConfig:getData(config.enid).mini
        else
            return config.mini
        end
    end)
    
    widget:addDataProxy("isChip",function(evt)
        return data.id > 51000
    end)
    
    widget:addDataProxy("isCard",function(evt)
        return data.id < 51000
    end)
    
    widget:addDataProxy("chipNum",function(evt)
        return data.num
    end)
    
    widget:addCommond("openCard",function(evt)
        ch.UIManager:cleanGamePopupLayer(true,true)
        if data.id > 51000 then
            ch.PetCardModel:cleanCardList()
            return 
        end
        
        local i = 0
        for k,v in pairs(ch.PetCardModel:getCardList()) do
            if k < 51000 then
                zzy.TimerUtils:setTimeOut(2.1*i,function()
                    --ch.UIManager:showGamePopup("card/W_card_get",{id=k,auto=true}) --tgx
                end)
                i = i+1
            end
        end
        if i>0 then
            i = i-1
        end
        zzy.TimerUtils:setTimeOut(2.1*i,function()        
            ch.UIManager:showBottomPopup("card/W_card_list")
        end)
        ch.PetCardModel:cleanCardList()
    end)
end)

-- 卡牌布阵界面打开的详情界面
zzy.BindManager:addCustomDataBind("card/W_card_detail1", function(widget,data)
    -- csb部分
    widget:addDataProxy("data",function(evt)
        local ret = {}
        ret.cardId = data 
        local config = GameConfig.CardConfig:getData(ret.cardId)
        if ch.PetCardModel:getStar(ret.cadId) < 1 then
            ret.cardName = config.name
        else
            ret.cardName = config.name.." +"..ch.PetCardModel:getStar(ret.cardId)
        end
        ret.titleImg = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(ret.cardId)).title_img
        ret.cardIcon = config.img
        ret.talentText = ch.PetCardModel:getTalent(ret.cardId)
        ret.jobIcon = GameConst.PETCARD_JOB[config.job].icon
        ret.jobName = GameConst.PETCARD_JOB[config.job].name
        ret.talentIcon = GameConst.CARD_TALENT_IMAGE[ch.PetCardModel:getTalent(ret.cardId)]
        ret.nameVis = false
        ret.bgFrame = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(ret.cardId)).bgFrame
        local tag = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(ret.cardId)).bgFrame_tag
        if tag and tag ~= "" then
            ret.bgFrameTag = tag
        else
            ret.bgFrameTag =  "res/icon/dot1.png"
        end
        ret.isBasic = ch.PetCardModel:getLevel(ret.cardId) <= GameConst.PETCARD_LEVEL_TAG
        ret.isSenior = ch.PetCardModel:getLevel(ret.cardId) > GameConst.PETCARD_LEVEL_TAG
        ret.talentImg = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(ret.cardId)).talent_img
        -- 星星变化
        local star = ch.PetCardModel:getStar(ret.cardId)
        local maxStar = GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(ret.cardId)).max_star
        ret.starImg1 = (maxStar == 4 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg2 = (maxStar == 3 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg3 = ((maxStar == 4 and star >= 2) or (maxStar == 2 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg4 = ((maxStar == 3 and star >= 2) or (maxStar == 1 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg5 = ((maxStar == 4 and star >= 3) or (maxStar == 2 and star >= 2)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg6 = (maxStar == 3 and star >= 3) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg7 = (maxStar == 4 and star >= 4) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"

        ret.star1 = maxStar == 4
        ret.star2 = maxStar == 3
        ret.star3 = maxStar == 4 or maxStar == 2
        ret.star4 = maxStar == 3 or maxStar == 1
        ret.star5 = maxStar == 4 or maxStar == 2
        ret.star6 = maxStar == 3
        ret.star7 = maxStar == 4
        -- 属性
        ret.pvpPower = math.floor(ch.PetCardModel:getTeamPower({{id=ret.cardId,l=ch.PetCardModel:getLevel(ret.cardId),talent = ch.PetCardModel:getTalent(ret.cardId)}})) 
        ret.pvpHP = math.floor(ch.PetCardModel:getHP(ret.cardId))
        ret.pvpAP = math.floor(ch.PetCardModel:getAP(ret.cardId))
        ret.pvpCR = math.floor(ch.PetCardModel:getCR(ret.cardId))
        ret.pvpAC = math.floor(ch.PetCardModel:getAC(ret.cardId))
        ret.pvpDC = math.floor(ch.PetCardModel:getDC(ret.cardId))
        ret.skillName = GameConfig.CardskillConfig:getData(config.skillid).name
        ret.skillDes = GameConfig.CardskillConfig:getData(config.skillid).desc
        ret.outputNum = ch.AltarModel:getOutput(ch.PetCardModel:getLevel(ret.cardId))
        
        
        -- tgx
        local img_card = widget:getChild("img_card")
        img_card:setVisible(false)
        
        INFO("[CARD][阵容][卡牌详情]")
        local aniPanel = widget:getChild("panel_card")
        ch.CommonFunc:showCardSke(aniPanel, ret.cardId, nil, nil, -20)
        -- tgx
    
        return ret
    end)
end)

-- 卡牌阵容选择单元(1公会战战队)
zzy.BindManager:addCustomDataBind("card/N_card_mini",function(widget,data)
    widget:addDataProxy("cardIcon",function(evt)
        return GameConfig.CardConfig:getData(data.id).mini
    end)

    widget:addDataProxy("iconFrame",function(evt)
        local level = data.l or ch.PetCardModel:getQuality(data.id)
        return GameConfig.CarduplevelConfig:getData(level).iconFrame
    end)

    widget:addDataProxy("isCard",function(evt)
        return data.isShow
    end)
    widget:addDataProxy("talentImg",function(evt)
        if data.talent then
            return GameConst.CARD_TALENT_IMAGE[data.talent]
        else
            return GameConst.CARD_TALENT_IMAGE[ch.PetCardModel:getTalent(data.id)]
        end
    end)
        -- csb部分
    widget:addDataProxy("data",function(evt)
        local ret = {}
        local quality = data.l or ch.PetCardModel:getQuality(data.id)
        -- 星星变化S
        local maxStar = GameConfig.CarduplevelConfig:getData(quality).max_star
        ret.star1 = maxStar == 4
        ret.star2 = maxStar == 3
        ret.star3 = maxStar == 4 or maxStar == 2
        ret.star4 = maxStar == 3 or maxStar == 1
        ret.star5 = maxStar == 4 or maxStar == 2
        ret.star6 = maxStar == 3
        ret.star7 = maxStar == 4

        local star = GameConfig.CarduplevelConfig:getData(quality).star
        ret.starImg1 = (maxStar == 4 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg2 = (maxStar == 3 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg3 = ((maxStar == 4 and star >= 2) or (maxStar == 2 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg4 = ((maxStar == 3 and star >= 2) or (maxStar == 1 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg5 = ((maxStar == 4 and star >= 3) or (maxStar == 2 and star >= 2)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg6 = (maxStar == 3 and star >= 3) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg7 = (maxStar == 4 and star >= 4) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"

        return ret
    end)
end)