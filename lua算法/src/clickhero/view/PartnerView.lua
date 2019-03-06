local PAGEVIEW_CHANGE_PET_EVENT = "PAGEVIEW_CHANGE_PET"
local PAGEVIEW_FIGHT_PET_EVENT = "PAGEVIEW_FIGHT_PET"

local petCardData = {}


---
-- 领取奖励界面
zzy.BindManager:addFixedBind("fuwen/W_FuwenGetbonus",function(widget)
    local jiangliChangeEvent = {}
    jiangliChangeEvent[ch.PartnerModel.dataChangeEventType] = false
    jiangliChangeEvent[ch.OffLineModel.dataChangeEventType] = false
--    jiangliChangeEvent[ch.ShareModel.dataChangeEventType] = false
    jiangliChangeEvent[ch.FamiliarModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FamiliarModel.dataType.get or evt.dataType == ch.FamiliarModel.dataType.clean
    end
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_PartnerView_1
    end)
    widget:addDataProxy("items", function(evt)
        local ret = {}
        for k,v in ipairs(ch.PartnerModel:getLJPartner()) do
            table.insert(ret,{index = 1, value = v, isMultiple = true})
        end
        for k,v in pairs(ch.PetCardModel:getCardList()) do
            table.insert(ret,{index = 2, value ={id=k,num=v}, isMultiple = true})
        end
        --无尽征途
        for k,v in pairs(ch.OffLineModel:getRewardList()) do
            table.insert(ret,{index = 3, value = v, isMultiple = true})
        end
        -- 侍宠获得
        for k,v in pairs(ch.FamiliarModel:getSeeFamiliars()) do
            table.insert(ret,{index = 4,value = {type=2,value=GameConfig.FamiliarConfig:getData(v)},isMultiple = true})
        end
        -- 分享奖励
       -- if zzy.Sdk.getFlag()=="HDIOS" then
       --     local shareAwardData = ch.ShareModel:getShareAwardData()
       --     if shareAwardData and table.maxn(shareAwardData) > 0 then
       --         table.insert(ret,{index = 3, value = {type = -1, items = shareAwardData}, isMultiple = true})
       --     end
       -- end
        return ret
    end,jiangliChangeEvent)
    -- 全领完后关闭
    widget:addDataProxy("isGetReward",function(evt)
        if not ch.PartnerModel:isGetReward() and table.maxn(ch.PetCardModel:getCardList())<1 and table.maxn(ch.OffLineModel:getRewardList())<1 then
            widget:destory()
        end
        return ""
    end,jiangliChangeEvent)
    widget:addCommond("close",function()
        ch.PetCardModel:cleanCardList()
        widget:destory()
    end)
end)

---
--领取界面unit
zzy.BindManager:addCustomDataBind("fuwen/W_FuwenGetUnit",function(widget,data)
    local id = tostring(data)
    local jiangliChangeEvent = {}
    jiangliChangeEvent[ch.PartnerModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.PartnerModel.dataTypelj.gb
        return ret
    end
    local config = GameConfig.PartnerConfig:getData(id)
    widget:addDataProxy("petName", function(evt)
        return config.name
    end)
    widget:addDataProxy("des", function(evt)
        return config.deslj
    end)
    widget:addDataProxy("icon",function(evt)
        return config.icon
    end)
    widget:addDataProxy("num_dmg",function(evt)
        return tostring(ch.PartnerModel:getShuXing(id) * config.arg / 100) .. "%"
    end)
    widget:addDataProxy("num_gold",function(evt)
        return ch.NumberHelper:toString(ch.PartnerModel:getShuXing(id))
    end)
    widget:addDataProxy("num_star",function(evt)
        return ch.NumberHelper:toString(ch.PartnerModel:getShuXing(id))
    end)
    widget:addDataProxy("num_soul",function(evt)
        return ch.NumberHelper:toString(ch.PartnerModel:getShuXing(id))
    end)
    widget:addDataProxy("if_dmg",function(evt)
        return ch.PartnerModel:ifShowMoney(id,"dmg")
    end)
    widget:addDataProxy("if_gold",function(evt)
        return ch.PartnerModel:ifShowMoney(id,"gold")
    end)
    widget:addDataProxy("if_star",function(evt)
        return ch.PartnerModel:ifShowMoney(id,"star")
    end)
    widget:addDataProxy("if_soul",function(evt)
        return ch.PartnerModel:ifShowMoney(id,"soul")
    end)
    widget:addDataProxy("ifCanGet",function(evt)
        local partner = GameConfig.PartnerConfig:getData(id)
        if partner and (partner.add_type == 3 or partner.add_type == 6) then
            return ch.PartnerModel:getShuXing(id) > ch.LongDouble.zero
        else
            return ch.PartnerModel:getShuXing(id) > 0
        end
        
    end, jiangliChangeEvent)
    widget:addCommond("get",function()
        if id == "20004" then
            ch.CommonFunc:showGoldRain(ch.PartnerModel:getShuXing(id))
        end
		ch.NetworkController:getPartnerReward(id) 
    end)
end)

---
-- 宠物替换单元(1为宠物，2为侍宠)
zzy.BindManager:addCustomDataBind("fuwen/W_FuwenPetChange",function(widget,data)
    local curID = ""
    local index = 1
    local cs = {}
    local costType,price,shopID = 1,0,1
    local curDesc,nextDesc = "",""
    local maxPage = 1
    
    if data.type == 1 then
        curID = tostring(data.id)
        index = ch.PartnerModel:getCurPartnerIndex(curID)
        cs = GameConfig.PartnerConfig:getData(curID)
        costType,price,shopID = ch.PartnerModel:getPartnerPrice(curID)
        curDesc,nextDesc = ch.PartnerModel:getRewardDesc(curID)
        maxPage = table.maxn(GameConst.PET_ORDER)
    else
        curID = tonumber(data.id)
        index = ch.FamiliarModel:getCurFamiliarIndex(curID)
        cs = GameConfig.FamiliarConfig:getData(curID)
        costType,price,shopID = ch.FamiliarModel:getFamiliarPrice(curID)
        curDesc,nextDesc = ch.FamiliarModel:getRewardDesc(curID)
        nextDesc = string.format(Language.LV..". %d",ch.FamiliarModel:getFamiliarLevel(curID))
        maxPage = table.maxn(GameConst.FAMILIAR_ORDER)
        -- 魅族专属获得才显示
        if ch.FamiliarModel:hasFamiliar(25100) then
            --maxPage = maxPage + 1
        end
    end
    
    local PageChangedEvent ={}
    PageChangedEvent[PAGEVIEW_CHANGE_PET_EVENT] = false
    
    local petChangedEvent ={}
    petChangedEvent[PAGEVIEW_CHANGE_PET_EVENT] = false
    if data.type == 1 then
        petChangedEvent[ch.PartnerModel.czChangeEventType] = false
    else
        petChangedEvent[ch.FamiliarModel.dataChangeEventType] = false
    end

    local turnPage = function(page)
        index = page
--        curID = ch.PartnerModel:getAllPartner()[index+1]
        if data.type == 1 then
            curID = GameConst.PET_ORDER[index+1]
            cs = GameConfig.PartnerConfig:getData(curID)
            costType,price,shopID = ch.PartnerModel:getPartnerPrice(curID)
            curDesc,nextDesc = ch.PartnerModel:getRewardDesc(curID)
            
        else
            -- 魅族专属获得才显示
            if index+1 > table.maxn(GameConst.FAMILIAR_ORDER) then
                --curID = 25100
            else
                curID = GameConst.FAMILIAR_ORDER[index+1]
            end
            cs = GameConfig.FamiliarConfig:getData(curID)
            costType,price,shopID = ch.FamiliarModel:getFamiliarPrice(curID)
            curDesc,nextDesc = ch.FamiliarModel:getRewardDesc(curID)
            nextDesc = string.format(Language.LV..". %d",ch.FamiliarModel:getFamiliarLevel(curID))
        end
        local evt = {type = PAGEVIEW_CHANGE_PET_EVENT}
        evt.curPetId = curID
        evt.dataType = data.type 
        zzy.EventManager:dispatch(evt)
    end
    
    widget:addDataProxy("title",function(evt)
        if data.type == 1 then
            return Language.src_clickhero_view_PartnerView_2
        else
            return Language.src_clickhero_view_PartnerView_3
        end
    end)
    widget:addDataProxy("petText",function(evt)
        if data.type == 1 then
            return Language.src_clickhero_view_PartnerView_4
        else
            return Language.src_clickhero_view_PartnerView_5
        end
    end)
    widget:addDataProxy("fightText",function(evt)
        if data.type == 1 then
            return Language.src_clickhero_view_PartnerView_6
        else
            return Language.src_clickhero_view_PartnerView_7
        end
    end)
    widget:addDataProxy("fightImg",function(evt)
        if data.type == 1 then
            return "aaui_common/state_fight.png"
        else
            return "aaui_common/state_summon.png"
        end
    end)
    widget:addDataProxy("piclist",function(evt)
--        return ch.PartnerModel:getAllPartner()
        if data.type == 1 then
            return GameConst.PET_ORDER
        else
            local tmpData = {}
            for k,v in pairs(GameConst.FAMILIAR_ORDER) do
                table.insert(tmpData,v)
            end
            -- 魅族专属获得才显示
            if ch.FamiliarModel:hasFamiliar(25100) then
                --table.insert(tmpData,25100)
            end
            return tmpData
        end
    end)
    
    widget:addDataProxy("partnerlist",function(evt)
        local items = {}
        if data.type == 1 then
            local clickSpeed = GameConfig.PartnerConfig:getData(curID).clickSpeed or 0
            local upType = GameConfig.PartnerConfig:getData(curID).up_type or 0
            table.insert(items,{index =1,value = {id = curID},isMultiple = true})
            --        for k,v in ipairs(ch.RunicModel:getOrderRunics()) do
            table.insert(items,{index = 2,value = {id=curID},isMultiple = true})
            --        end
            if clickSpeed > 0 then
                table.insert(items,{index =1,value = {id = curID,click = clickSpeed},isMultiple = true})
            end
            if upType ~= 0 then
                table.insert(items,{index =1,value = {id = curID,upType = upType},isMultiple = true})
            end
        else
            table.insert(items,{index =1,value = {id = curID,familiar=1},isMultiple = true})
            local tmpData = GameConfig.FamiliarConfig:getData(curID)
            if tmpData.pType > 0 then
                table.insert(items,{index =2,value = {id = curID,familiar=tmpData.pType,ratio=ch.FamiliarModel:getFamiliarRatio(curID)*100},isMultiple = true})
            end
        end
        return items
    end,PageChangedEvent)
    widget:addDataProxy("name",function(evt)
        return cs.name
    end,PageChangedEvent)
    widget:addDataProxy("next_reward",function(evt)
        return nextDesc
    end,PageChangedEvent)
    widget:addDataProxy("cur_reward",function(evt)
        return curDesc
    end,PageChangedEvent)
    widget:addDataProxy("apath", function(evt)
        return cs.icon
    end,PageChangedEvent)
    -- 描述显示
    widget:addDataProxy("if_have_desc",function(evt)
        if data.type == 1 then
            return not ch.PartnerModel:ifHavePartner(curID)
        else
            return not ch.FamiliarModel:hasFamiliar(curID)
        end
    end,petChangedEvent)
    widget:addDataProxy("if_have",function(evt)
        if data.type == 1 then
            return ch.PartnerModel:ifHavePartner(curID)
        else
            return ch.FamiliarModel:hasFamiliar(curID)
        end
    end,petChangedEvent)
    widget:addDataProxy("no_have",function(evt)
        if data.type == 1 then
            return not ch.PartnerModel:ifHavePartner(curID) and cs.source<2
        else
            return not ch.FamiliarModel:hasFamiliar(curID) and cs.source < 1
        end
    end,petChangedEvent)
    
    -- 花费类型控制按钮和图标
    widget:addDataProxy("btnNormal",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[costType][1]
    end,PageChangedEvent)
    widget:addDataProxy("btnPressed",function(evt)
        return GameConst.SHOP_COST_BTN_IMAGE[costType][2]
    end,PageChangedEvent)
    widget:addDataProxy("costIcon",function(evt)
        return GameConst.SHOP_COST_ICON_IMAGE[costType]
    end,PageChangedEvent)
    widget:addDataProxy("price",function(evt)
        return "-"..price
    end,PageChangedEvent)
    widget:addDataProxy("ifCanBuy",function(evt)
        if costType == 1 then
            return true
        elseif costType == 2 then
            return ch.MoneyModel:getDiamond() >= price
        elseif costType == 3 then
            return ch.MoneyModel:getHonour() >= price
        else
            cclog("类型不对")
            return false
        end
    end,PageChangedEvent)
    widget:addCommond("buy",function()
        -- 购买
        local buy = function()
            ch.NetworkController:shopBuy(shopID)
            if data.type == 1 then
                ch.PartnerModel:getOne(curID)
            else
                cclog("获得侍宠")
            end
            local config = GameConfig.ShopConfig:getData(shopID)
            if costType == 1 then
                ch.NetworkController:charge(config.itemId,config.name,1,config.price,config.oldPrice,config.reward)
                cclog("扣人民币")
            elseif costType == 2 then
                ch.MoneyModel:addDiamond(-price)
            elseif costType == 3 then
                ch.MoneyModel:addHonour(-price)
            else
                cclog("类型不对")
            end
            if config.tip_type and config.tip_type == 2 then
                ch.UIManager:showNotice(config.tip_desc)
            end
        end
        local tmp = {price = price,buy = buy}
        ch.ShopModel:getCostTips(tmp)
    end)

    widget:addDataProxy("fight_no",function(evt)
        if data.type == 1 then
            return curID ~= ch.PartnerModel:getCurPartner()
        else
            return curID ~= ch.FamiliarModel:getCurFamiliar()
        end
    end,petChangedEvent)
    widget:addCommond("setFight",function()
        if data.type == 1 then
            ch.PartnerModel:setCurPartner(curID)
            ch.NetworkController:curPartner(curID)
        else
            ch.FamiliarModel:setCurFamiliar(curID)
            ch.NetworkController:curFamiliar(curID)
        end
        local evt = {type = PAGEVIEW_FIGHT_PET_EVENT}
        evt.curPetId = curID
        evt.dataType = data.type
        zzy.EventManager:dispatch(evt)
    end)
    widget:addDataProxy("fight_yes",function(evt)
        if data.type == 1 then
            return curID == ch.PartnerModel:getCurPartner()
        else
            return curID == ch.FamiliarModel:getCurFamiliar()
        end
    end,petChangedEvent)
    widget:addDataProxy("notFirst",function(evt)
        return index > 0
    end,PageChangedEvent)
    widget:addDataProxy("notLast",function(evt)
--        return index < table.maxn(ch.PartnerModel:getAllPartner())-1
        return index < maxPage-1
    end,PageChangedEvent)
    widget:addCommond("nextPet",function()
        turnPage(index+1)
    end)
    widget:addCommond("prevPet",function()
        turnPage(index-1)
    end)
    widget:addDataProxy("curPage",function(evt)
        return index
    end,PageChangedEvent)
    widget:addCommond("changePet",function(obj,page)
        turnPage(page)
    end)
    widget:addCommond("close",function(obj,page)
        if table.maxn(ch.FamiliarModel:getSeeFamiliars())>0 then 
            ch.NetworkController:cleanSeeFamiliar()
            ch.FamiliarModel:cleanSeeFamiliar()
        end
        widget:destory()
    end)
end)

---
-- 宠物特殊奖励单元
zzy.BindManager:addCustomDataBind("fuwen/W_PetBonusunit",function(widget,data)
    widget:addDataProxy("icon",function(evt)
        if data.click and data.click>0 then
            return GameConst.PET_REWARD_ICON[2]
        elseif data.upType and data.upType ~= 0 then
            return GameConst.PET_UPNUM_ICON[data.upType]
        elseif data.familiar and data.familiar ~= 0 then
            return "res/icon/dot1.png"
        else
            return GameConst.PET_REWARD_ICON[tonumber(GameConfig.PartnerConfig:getData(tostring(data.id)).add_type + 1)]
        end
    end)
    widget:addDataProxy("des",function(evt)
        if data.click and data.click>0 then
            return string.format(Language.src_clickhero_view_PartnerView_8,data.click)
        elseif data.upType and data.upType ~= 0 then
            return GameConst.PET_UPNUM_DESC[data.upType]
        elseif data.familiar and data.familiar ~= 0 then
            return GameConfig.FamiliarConfig:getData(data.id).desc
        else
            return GameConfig.PartnerConfig:getData(tostring(data.id)).des
        end
    end)
end)

---
-- 宠物特殊属性单元
zzy.BindManager:addCustomDataBind("fuwen/W_PetSpecialunit",function(widget,data)
    widget:addDataProxy("icon",function(evt)
        if data.familiar and data.familiar ~= 0 then
            return "aaui_card/output.png"
        else
            return GameConst.PET_RESTRAIN_ICON[GameConfig.PartnerConfig:getData(tostring(data.id)).shuxing]
        end
    end)
    widget:addDataProxy("des",function(evt)
        if data.familiar and data.familiar ~= 0 then
            return string.format(GameConst.FAMILIAR_RESTRAIN_DES[data.familiar],data.ratio)
        else
            return GameConst.PET_RESTRAIN_DES[GameConfig.PartnerConfig:getData(tostring(data.id)).shuxing]
        end
    end)
end)

---
-- 宠物翻页单元
zzy.BindManager:addCustomDataBind("fuwen/W_FuwenPetView",function(widget,data)
    local armatureName = ""
    local animationName = ""
    local curID = ""
    if tonumber(data) < 25000 then
        armatureName = GameConfig.PartnerConfig:getData(data).apath
        animationName = "stand"
        curID = ch.PartnerModel:getCurPartner()
    else
        armatureName = GameConfig.FamiliarConfig:getData(data).avatar
        animationName = "move"
        curID = ch.FamiliarModel:getCurFamiliar()
    end
    
    widget:addDataProxy("scaleX",function(evt)
        if tonumber(data) < 25000 then
            return 1 
        else
            return -GameConfig.FamiliarConfig:getData(data).scale * 1.2
        end 
    end)
    widget:addDataProxy("scaleY",function(evt)
        if tonumber(data) < 25000 then
            return 1 
        else
            return GameConfig.FamiliarConfig:getData(data).scale * 1.2
        end 
    end)

    if USE_SPINE then
        if tonumber(data) > 25000 then
            armatureName = GameConfig.FamiliarConfig:getData(data).spine --身后跟随的美人读取配置中的spine字段，天上飞的宠物名字跟原来一样
        end
    end

    if ch.CommonFunc:useSpine("role_"..armatureName) then
        ch.CommonFunc:showCardSke(widget, 0.7, 0.4, 0, 320, armatureName, "stand")
    else
        widget:changeEffect("chongwuStand","res/role/role_"..armatureName,armatureName,animationName)
    end
    
    if curID == data then
        widget:setAutoReleaseEffect("chongwuStand",false)
    else
        widget:setAutoReleaseEffect("chongwuStand",true)
    end
    widget:playEffect("chongwuStand",true)
    widget:listen(PAGEVIEW_FIGHT_PET_EVENT,function(obj,evt)
        widget:noticeDataChange("scaleX")
        if evt.curPetId == data then
            widget:setAutoReleaseEffect("chongwuStand",false)
        else
            widget:setAutoReleaseEffect("chongwuStand",true)
        end
    end)
end)

---
-- 宠物出战卡片
zzy.BindManager:addCustomDataBind("fuwen/W_FuwenPetunit",function(widget,data)
    local petData = data
    widget:addDataProxy("name",function(evt)
        return petData.name
    end)
    widget:addDataProxy("icon",function(evt)
        return petData.icon
    end)
    widget:addDataProxy("clickSpeed",function(evt)
        return petData.clickSpeed or 0
    end)
    widget:addDataProxy("ifAutoClick",function(evt)
        return petData.clickSpeed > 0
    end)
    widget:addDataProxy("restrain",function(evt)
        local value = GameConst.PET_RESTRAIN_HARM_RATIO
        local partnerId = petData.id
        if (partnerId == "20007" or partnerId == 20007) and GameConst.PET_RESTRAIN_HARM_RATIO_1 then
            value = GameConst.PET_RESTRAIN_HARM_RATIO_1
        elseif (partnerId == "20008" or partnerId == 20008) and GameConst.PET_RESTRAIN_HARM_RATIO_2 then
            value = GameConst.PET_RESTRAIN_HARM_RATIO_2
        else
            value = GameConst.PET_RESTRAIN_HARM_RATIO
        end

        return (value*100).."%"
    end)
    widget:addDataProxy("petIcon",function(evt)
        return GameConst.PET_RESTRAIN_ICON[petData.shuxing]
    end)
    widget:addDataProxy("bossIcon",function(evt)
        return GameConst.BOSS_ICON[petData.shuxing]
    end)
    widget:addDataProxy("isRestrain",function(evt)
        return petData.shuxing ~= 1
    end)
    widget:addDataProxy("isNoRestrain",function(evt)
        return petData.shuxing == 1
    end)
    widget:addDataProxy("desc",function(evt)
        return GameConst.PET_RESTRAIN_DES[petData.shuxing]
    end)
    widget:addCommond("setFight",function()
        ch.PartnerModel:setCurPartner(petData.id)
        ch.NetworkController:curPartner(petData.id)
        local evt = {type = PAGEVIEW_FIGHT_PET_EVENT}
        evt.curPetId = petData.id
        zzy.EventManager:dispatch(evt)
    end)
    widget:addCommond("openPetCard",function()
        ch.UIManager:showGamePopup("fuwen/W_FuwenPetChange",{id = petData.id,type=1})
    end)
end)

---
-- 侍宠入口卡片(1宠物内入口，2过关奖励入口 获得和升级)
zzy.BindManager:addCustomDataBind("fuwen/W_FuwenPetunit2",function(widget,data)
    local petChangeEvent = {}
    petChangeEvent[ch.LevelModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    petChangeEvent[ch.FamiliarModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.FamiliarModel.dataType.get
    end
    
    local petSwitchEvent = {}
    petSwitchEvent[ch.FamiliarModel.dataChangeEventType] = function(evt)
        if evt.dataType == ch.FamiliarModel.dataType.fight then
            data.value = ch.FamiliarModel:getCurFamiliarCardData()
        end
    	return evt.dataType == ch.FamiliarModel.dataType.fight
    end
    
    widget:addDataProxy("petDesc",function(evt) 
        if data.type == 2 and ch.FamiliarModel:getFamiliarLevel(data.value.id) > 1 then
            if data.value.pType ~= 0 then
                return string.format(GameConst.FAMILIAR_RESTRAIN_DES[data.value.pType],ch.FamiliarModel:getFamiliarRatio(data.value.id)*100)
            else
                return string.format(data.value.desc,GameConst.FAMILIAR_OPEN_LEVEL)
            end
        end
        return string.format(data.value.desc,GameConst.FAMILIAR_OPEN_LEVEL)
    end, petSwitchEvent)
    widget:addDataProxy("petDB",function(evt)
        return "aaui_diban/db_pet1.png"
    end)
    widget:addDataProxy("petFrame",function(evt)
        return "aaui_diban/db_petframe1.png"
    end)
    widget:addDataProxy("btnText",function(evt)
        if data.type == 1 then
            return Language.src_clickhero_view_PartnerView_9
        else
            return Language.src_clickhero_view_PartnerView_10
        end
    end)
    widget:addDataProxy("name",function(evt)
        if data.type == 2 and ch.FamiliarModel:getFamiliarLevel(data.value.id) > 1 then
            return data.value.name .. Language.LV.."." .. ch.FamiliarModel:getFamiliarLevel(data.value.id)
        end
        return data.value.name
    end, petSwitchEvent)
    widget:addDataProxy("icon",function(evt)
        return data.value.icon
    end, petSwitchEvent)
    widget:addDataProxy("ifOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel() > GameConst.FAMILIAR_OPEN_LEVEL or table.maxn(ch.FamiliarModel:getAllFamiliars())>0
    end,petChangeEvent)
    widget:addCommond("openPetCard",function()
        if data.type == 2 then
            ch.UIManager:cleanGamePopupLayer(true)
        end
        ch.UIManager:showGamePopup("fuwen/W_FuwenPetChange",{id=data.value.id,type=2})
    end)
end)

-- 离线奖励
zzy.BindManager:addCustomDataBind("Guild/W_ELGetUnit",function(widget,data)
    widget:addDataProxy("icon", function(evt)
        if data.type == -1 then
            return "aaui_icon/icon_wxzt.png"
        elseif data.type == 2 then
            return "aaui_icon/icon_wxzt.png"
        else
            return "aaui_icon/icon_wxzt.png"
        end
    end)
    widget:addDataProxy("title", function(evt)
        if data.type == -1 then
            return Language.src_clickhero_view_PartnerView_11
        elseif data.type == 2 then
            return Language.src_clickhero_view_PartnerView_12
        else
            return Language.src_clickhero_view_PartnerView_13
        end
    end)
    widget:addDataProxy("des",function(evt)
        if data.type == -1 then
            return ""
        elseif data.type == 2 then
            return Language.src_clickhero_view_PartnerView_14
        else
            return Language.src_clickhero_view_PartnerView_15
        end
    end)
    widget:addDataProxy("reward1",function(evt)
        return true
    end)
    widget:addDataProxy("reward2",function(evt)
        return false
    end)
   widget:addDataProxy("rewardIcon1",function(evt)
        return ch.CommonFunc:getRewardIcon(data.items[1].t,data.items[1].id)
   end)
   widget:addDataProxy("rewardIcon2",function(evt)
         return ch.CommonFunc:getRewardIcon(data.items[1].t,data.items[1].id)
    end)
    widget:addDataProxy("rewardNum1",function(evt)
            return ch.CommonFunc:getRewardValue(data.items[1].t,data.items[1].id,data.items[1].num)
    end)
    widget:addDataProxy("rewardNum2",function(evt)
            return ch.CommonFunc:getRewardValue(data.items[1].t,data.items[1].id,data.items[1].num)
    end)
    widget:addCommond("openReward",function()
         if data.type == -1 then
            ch.ShareModel:clearShareAwardData()
         else
            ch.OffLineModel:clearRewardList(data.type)
            ch.NetworkController:getOffRewardGold(data)
         end
    end)
end)
