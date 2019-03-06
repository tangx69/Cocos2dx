local getTime = function(time)
    if time > 0 then
        local second = math.floor(time%60)
        time = time /60
        local minute = math.floor(time%60)
        return string.format("%02d:%02d",minute,second)
    else
        return 0
    end
end

local groupDesc = {
    "",
    Language.src_clickhero_view_CardActivityView_1,
    Language.src_clickhero_view_CardActivityView_2,
    Language.src_clickhero_view_CardActivityView_3,
    Language.src_clickhero_view_CardActivityView_4,
    Language.src_clickhero_view_CardActivityView_16
}

-- 卡牌战斗阵容替换界面（2为天梯进攻阵容界面(和阵容调整),3祭坛防守界面,4祭坛掠夺界面,5卡牌副本界面,6公会战界面）
zzy.BindManager:addCustomDataBind("card/W_card_f_choose", function(widget,data)
    local myCardListChangeEvent = {}
    myCardListChangeEvent[ch.ArenaModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ArenaModel.dataType.myCardList
    end
    myCardListChangeEvent[ch.AltarModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.AltarModel.dataType.myCardList
    end
    myCardListChangeEvent[ch.GuildWarModel.teamStatusChangedEventType] = function(evt)
        return evt.dataType == ch.GuildWarModel.teamDataType.myCardList
    end
    
    local cardOrderChangeEvent = {}
    cardOrderChangeEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.PetCardModel.dataType.order
    end
    local cs = ch.ArenaModel:getPlayerDetail()
    
    widget:addDataProxy("title",function(evt)
        if data.type and data.type == 3 then
            return Language.src_clickhero_view_CardActivityView_5
        else
            return Language.src_clickhero_view_CardActivityView_6
        end
    end)
    
    widget:addDataProxy("cardList",function(evt)
        local tmpTable = {}
        for k,v in pairs(ch.PetCardModel:getCardID()) do
            table.insert(tmpTable,{index=k,id=v,type=data.type,altarType=data.altarType,teamIndex=data.teamIndex})
        end
        return tmpTable
    end,cardOrderChangeEvent)
    widget:addDataProxy("direction",function(evt)
        return ccui.ListViewDirection.horizontalSnap
    end)
    
    widget:addDataProxy("desc",function(evt)
        return groupDesc[data.type]
    end)
    widget:addDataProxy("num",function(evt)
        if data.type == 2 or data.type == 4 or data.type == 5 then
            return ch.PetCardModel:getTeamData(ch.ArenaModel:getMyCardList())
        elseif data.type == 6 then
            return ch.PetCardModel:getTeamData(ch.GuildWarModel:getMyCardList(data.teamIndex))  -- 公会战
        else
            return ch.PetCardModel:getTeamData(ch.AltarModel:getMyCardList(data.altarType))
        end
    end,myCardListChangeEvent)
    
--    widget:addCommond("qualitySort",function()
--        ch.PetCardModel:orderMyCard()
--    end)
    widget:addCommond("changeGroup",function()
        --先改值再发指令
        if data.type == 2 then
            if ch.ArenaModel:ifMyCardList() then
                ch.ArenaModel:changeMyCardList()
                ch.NetworkController:changeMyCardList(ch.ArenaModel:getMyCardListInit())
                -- 关闭界面
                ch.ArenaModel:setMyCardListInit()
                widget:destory()
            else
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_CardActivityView_7,nil,nil,Language.src_clickhero_view_CardActivityView_8,2)
            end
        elseif data.type == 3 then
            if ch.AltarModel:ifMyCardList(data.altarType) then
                ch.AltarModel:changeMyCardList(data.altarType)
                ch.NetworkController:changeMyAltarList(data.altarType,ch.AltarModel:getAltarListInit(data.altarType))
                ch.NetworkController:altarPanel(data.altarType)
                -- 关闭界面
                ch.AltarModel:setMyCardListInit(data.altarType)
                widget:destory()
            else
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_CardActivityView_7,nil,nil,Language.src_clickhero_view_CardActivityView_8,2)
            end
        elseif data.type == 4 then
            if ch.ArenaModel:ifMyCardList() then
                ch.ArenaModel:changeMyCardList()
                ch.NetworkController:changeMyCardList(ch.ArenaModel:getMyCardListInit())
                -- 关闭界面
                ch.ArenaModel:setMyCardListInit()
                ch.NetworkController:altarRob(data.userid,data.altarType)
                widget:destory()
            else
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_CardActivityView_9,nil,nil,Language.src_clickhero_view_CardActivityView_8,2)
            end
        elseif data.type == 5 then
            if ch.ArenaModel:ifMyCardList() then
                ch.ArenaModel:changeMyCardList()
                ch.NetworkController:changeMyCardList(ch.ArenaModel:getMyCardListInit())
                -- 关闭界面
                ch.ArenaModel:setMyCardListInit()
                ch.NetworkController:cardFBFight(data.fbId)
                widget:destory()
            else
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_CardActivityView_9,nil,nil,Language.src_clickhero_view_CardActivityView_8,2)
            end
        elseif data.type == 6 then
            if ch.GuildWarModel:ifMyCardList(data.teamIndex) then
                ch.GuildWarModel:changeMyCardList(data.teamIndex)
                local team = {}
                for k,v in pairs(ch.GuildWarModel:getTeamMember(data.teamIndex)) do
                    table.insert(team,v.id)
                end
                ch.GuildWarController:changeMyCardList(data.teamIndex,team)
                -- 关闭界面
                ch.GuildWarModel:setMyCardListInit(data.teamIndex)
                widget:destory()
            else
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_CardActivityView_7,nil,nil,Language.src_clickhero_view_CardActivityView_8,2)
            end
        end
        -- 结束换阵引导
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10230 then
            ch.guide:endid(10230)
            if data.type == 3 then
                ch.guide:showWait(6,function()
                    ch.guide:play_guide(10270)
                end)
            else
                ch.guide:play_guide(10240)
            end
        end
    end)
    widget:addCommond("close",function()
        if data.type == 2 or data.type == 4 or data.type == 5 then
            ch.ArenaModel:setMyCardListInit()
        elseif data.type == 6 then
            ch.GuildWarModel:setMyCardListInit(data.teamIndex) -- 公会战
        else
            ch.AltarModel:setMyCardListInit(data.altarType)
        end
        widget:destory()
    end)
   
    widget:addDataProxy("card1",function(evt)
        return {type = data.type,id=1,altarType=data.altarType,teamIndex=data.teamIndex}
    end)
    widget:addDataProxy("card2",function(evt)
        return {type = data.type,id=2,altarType=data.altarType,teamIndex=data.teamIndex}
    end)
    widget:addDataProxy("card3",function(evt)
        return {type = data.type,id=3,altarType=data.altarType,teamIndex=data.teamIndex}
    end)
    widget:addDataProxy("card4",function(evt)
        return {type = data.type,id=4,altarType=data.altarType,teamIndex=data.teamIndex}
    end)
    widget:addDataProxy("card5",function(evt)
        return {type = data.type,id=5,altarType=data.altarType,teamIndex=data.teamIndex}
    end)
end)

-- 卡牌阵容单元 (type:1天梯阵容展示，2自己天梯阵容,3自己祭坛防守阵容,4祭坛掠夺界面,5卡牌副本界面,6公会战界面)
zzy.BindManager:addCustomDataBind("card/W_card_f_xk",function(widget,data)
    local myCardListChangeEvent = {}
    myCardListChangeEvent[ch.ArenaModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ArenaModel.dataType.myCardList
    end  
    myCardListChangeEvent[ch.AltarModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.AltarModel.dataType.myCardList
    end
    myCardListChangeEvent[ch.GuildWarModel.teamStatusChangedEventType] = function(evt)
        return evt.dataType == ch.GuildWarModel.teamDataType.myCardList
    end
    
    local cardId
    widget:addDataProxy("data",function(evt)
        local ret = {}
        local value = {}
        if data.value then
            value = data.value
        elseif data.type == 2 then
            value = ch.ArenaModel:getMyCardList()[data.id]
        else
            value = {id=50001,l=1,talent=1,vis=false}
        end
        if data.type == 3 then
            value = ch.AltarModel:getMyCardList(data.altarType)[data.id]
        end
        if data.type == 6 then -- 公会战
            value = ch.GuildWarModel:getMyCardList(data.teamIndex)[data.id]
        end
        cardId = value.id
        local config = GameConfig.CardConfig:getData(value.id)
        local qualityData = GameConfig.CarduplevelConfig:getData(value.l)
        local star = qualityData.star
        local maxStar = qualityData.max_star
        if value.vis then
            ret.cardIcon = config.icon
        else
            ret.cardIcon = "aaui_common/dot1.png"
        end
        ret.cardVis = value.vis
        if star < 1 then
            ret.cardName = config.name
        else
            ret.cardName = config.name.." +"..star
        end
        ret.cardNameColor = GameConst.PETCARD_COLOR[qualityData.color]
        ret.talentIcon = GameConst.CARD_TALENT_IMAGE[value.talent]
        ret.jobIcon = GameConst.PETCARD_JOB[config.job].icon
        ret.bgFrame = qualityData.bgFrame_mini
        -- 星星变化      
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
        
        
        local img_card = widget:getChild("img_card")
        img_card:setVisible(false)
        
        local config = GameConfig.CardConfig:getData(cardId)
        INFO("[CARD][通用][更换队伍/显示对手天梯队伍]"..config.avatar)
        local aniPanel = widget:getChild("Panel_layer")
        if cardId then
            ch.CommonFunc:showCardSke(aniPanel, cardId, 0.25, 55, -100)
        end
        
        return ret
    end,myCardListChangeEvent)
    -- 是否在阵容内
    widget:addDataProxy("notInGroup",function(evt)
        if data.type == 2 or data.type == 4 or data.type == 5 then
            return ch.ArenaModel:getMyCardList()[data.id].vis and ch.ArenaModel:getMyCardList()[data.id].canSelect
        elseif data.type == 3 then
            return ch.AltarModel:getMyCardList(data.altarType)[data.id].vis and ch.AltarModel:getMyCardList(data.altarType)[data.id].canSelect
        elseif data.type == 6 then
            return ch.GuildWarModel:getMyCardList(data.teamIndex)[data.id].vis and ch.GuildWarModel:getMyCardList(data.teamIndex)[data.id].canSelect
        else
            return false
        end
    end,myCardListChangeEvent)

    -- 点击选中、取消
    local touchTime 
    widget:addCommond("select",function(widget,arg)
        if os_clock() - touchTime > 0.2 then return end
        if data.type == 2 or data.type == 4 or data.type == 5 then
            ch.ArenaModel:setMyCardList(ch.ArenaModel:getMyCardList()[data.id].index)
        elseif data.type == 3 then
            ch.AltarModel:setMyCardList(data.altarType,ch.AltarModel:getMyCardList(data.altarType)[data.id].index)
        elseif data.type == 6 then
            ch.GuildWarModel:setMyCardList(data.teamIndex,ch.GuildWarModel:getMyCardList(data.teamIndex)[data.id].index)
        end
    end)
    -- 长按打开详情
    widget:addCommond("openDetail",function(widget,type)
        if type == ccui.TouchEventType.began then
            touchTime = os_clock()
        elseif type == ccui.TouchEventType.ended or type == ccui.TouchEventType.canceled then 
            if os_clock() - touchTime > 0.2 then
                ch.UIManager:showGamePopup("card/W_card_detail1",cardId)
            end
            touchTime = nil
        end 
    end)
end)

-- 卡牌阵容选择单元
zzy.BindManager:addCustomDataBind("card/W_card_select",function(widget,data)
    local myCardListChangeEvent = {}
    myCardListChangeEvent[ch.ArenaModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.ArenaModel.dataType.myCardList
    end
    myCardListChangeEvent[ch.AltarModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.AltarModel.dataType.myCardList
    end
    myCardListChangeEvent[ch.GuildWarModel.teamStatusChangedEventType] = function(evt)
        return evt.dataType == ch.GuildWarModel.teamDataType.myCardList
    end
    
    widget:addDataProxy("cardIcon",function(evt)
        return GameConfig.CardConfig:getData(data.id).mini
    end)
    
    widget:addDataProxy("iconFrame",function(evt)
        local level = data.l or ch.PetCardModel:getQuality(data.id)
        return GameConfig.CarduplevelConfig:getData(level).iconFrame
    end)
    -- 是否在阵容内
--    widget:addDataProxy("signImg",function(evt)
--        if data.type and data.type == 3 then
--            return ch.AltarModel:isInGroupType(data.id)
--        else
--            return "aaui_common/ui_common_fragment_tag.png"
--        end
--    end,myCardListChangeEvent)
    widget:addDataProxy("isMy",function(evt)
        if data.type and data.type == 3 then
            return ch.AltarModel:isInGroup(data.altarType,data.id)
        elseif data.type and data.type == 6 then
            return ch.GuildWarModel:isInGroup(data.teamIndex,data.id)
        else
            return ch.ArenaModel:isInGroup(data.id)
        end
    end,myCardListChangeEvent)
    widget:addDataProxy("groupText",function(evt)
        if data.type and data.type == 6 then
            return Language.GUILD_WAR_TEAM_NAME..ch.GuildWarModel:isInGroupTypeNum(data.id)
        else
            return Language.src_clickhero_view_CardActivityView_17
        end
    end,myCardListChangeEvent)
    widget:addDataProxy("isOther",function(evt)
        if data.type and data.type == 3 then
            return ch.AltarModel:isInOtherGroup(data.altarType,data.id)
        elseif data.type and data.type == 6 then
            return ch.GuildWarModel:isInOtherGroup(data.teamIndex,data.id)
        else
            return false
        end
    end,myCardListChangeEvent)
    widget:addDataProxy("isInGroup",function(evt)
        if data.type and data.type == 3 then
            return ch.AltarModel:isInAllGroup(data.id)
--            return ch.AltarModel:isInGroup(data.altarType,data.id)
        elseif data.type and data.type == 6 then
            return ch.GuildWarModel:isInAllGroup(data.id)
        else
            return ch.ArenaModel:isInGroup(data.id)
        end
    end,myCardListChangeEvent)
    widget:addDataProxy("notInGroup",function(evt)
--        if data.type and data.type == 3 then
--            return not ch.AltarModel:isInOtherGroup(data.altarType,data.id)
--        else
--            return true
--        end
        if data.noTouch then
            return false
        else
            return true
        end
    end,myCardListChangeEvent)
    
    
    widget:addDataProxy("isCard",function(evt)
        return true
    end,myCardListChangeEvent)    
    widget:addDataProxy("talentImg",function(evt)
        if data.talent then
            return GameConst.CARD_TALENT_IMAGE[data.talent]
        else
            return GameConst.CARD_TALENT_IMAGE[ch.PetCardModel:getTalent(data.id)]
        end
    end,myCardListChangeEvent)
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
    end,myCardListChangeEvent)

    -- 选中、取消
    local touchTime 
    widget:addCommond("select",function(widget,arg)
        if ch.guide and ch.guide.obj and ch.guide.obj.id and (ch.guide.obj.id == 10200 
           or ch.guide.obj.id == 10210 or ch.guide.obj.id == 10220 or ch.guide.obj.id == 10230) then
        else
            if os_clock() - touchTime > 0.2 then return end
        end
        if data.type and data.type == 3 then
            if ch.AltarModel:isInOtherGroup(data.altarType,data.id) then 
                return 
            elseif ch.AltarModel:isInGroup(data.altarType,data.id) then
                ch.AltarModel:changeMyCardListById(data.altarType,data.id)
            elseif ch.AltarModel:ifNotFull(data.altarType) then
                ch.AltarModel:addMyCardList(data.altarType,data.id)
            end
        elseif data.type and data.type == 6 then
            if ch.GuildWarModel:isInOtherGroup(data.teamIndex,data.id) then 
                return 
            elseif ch.GuildWarModel:isInGroup(data.teamIndex,data.id) then
                ch.GuildWarModel:changeMyCardListById(data.teamIndex,data.id)
            elseif ch.GuildWarModel:ifNotFull(data.teamIndex) then
                ch.GuildWarModel:addMyCardList(data.teamIndex,data.id)
            end   
        else
            if ch.ArenaModel:isInGroup(data.id) then
                ch.ArenaModel:changeMyCardListById(data.id)
            elseif ch.ArenaModel:ifNotFull() then
                ch.ArenaModel:addMyCardList(data.id)
            end
        end
        --结束引导第一张卡
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10200 then
            ch.guide:endid(10200)
            --结束引导第二张卡
        elseif ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10210 then
            ch.guide:endid(10210)
            --结束引导第三张卡
        elseif ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10220 then
            ch.guide:endid(10220)
        end
    end)
    -- 长按打开详情
    widget:addCommond("openDetail",function(widget,type)
        if type == ccui.TouchEventType.began then
            touchTime = os_clock()
        elseif type == ccui.TouchEventType.ended then 
            if os_clock() - touchTime > 0.2 then
                if ch.guide and ch.guide.obj and ch.guide.obj.id and (ch.guide.obj.id == 10200 
                    or ch.guide.obj.id == 10210 or ch.guide.obj.id == 10220 or ch.guide.obj.id == 10230) then
                else
                    ch.UIManager:showGamePopup("card/W_card_detail1",data.id)
                end
            end
        end
    end)
end)


-- 天梯界面
zzy.BindManager:addFixedBind("card/W_tt", function(widget)
    local arenaDataChangeEvent = {}
    arenaDataChangeEvent[ch.ArenaModel.dataChangeEventType] = false
    
    -- 每日提醒一次
    cc.UserDefault:getInstance():setStringForKey("ifOpenArena",ch.CommonFunc:getZeroTime(os_time()))
    ch.SignModel:effectDataChangeEvent()
    
    local reward = {}
    if ch.ArenaModel:getMyRankOld() and ch.ArenaModel:getMyRankOld() > 0 then
        reward=ch.ArenaModel:getRewardByRank(ch.ArenaModel:getMyRankOld())
    else
        reward=ch.ArenaModel:getRewardByRank(ch.ArenaModel:getMyRank())
    end
    widget:addDataProxy("bgImage",function(evt)
        return "res/img/card_tt_bg.png"
    end)
    widget:addDataProxy("resetNum",function(evt)
        return ch.ArenaModel:getResetNum()
    end,arenaDataChangeEvent)
    widget:addDataProxy("challengeNum",function(evt)
        return ch.ArenaModel:getChallengeNum()
    end,arenaDataChangeEvent)
    widget:addDataProxy("twoReward",function(evt)
        return reward.id2 ~= nil
    end)
    
    widget:addDataProxy("rewardIcon1",function(evt)
        return  ch.CommonFunc:getRewardIcon(reward.idty1,reward.id1)
    end)
    widget:addDataProxy("rewardNum1",function(evt)
        return ch.CommonFunc:getRewardValue(reward.idty1,reward.id1,reward.num1)
    end)
    
    widget:addDataProxy("rewardIcon2",function(evt)
        if reward.id2 then
            return ch.CommonFunc:getRewardIcon(reward.idty2,reward.id2)
        else
            return ch.CommonFunc:getRewardIcon(reward.idty1,reward.id1)
        end
    end)
    widget:addDataProxy("rewardNum2",function(evt)
        if reward.id2 then
            return ch.CommonFunc:getRewardValue(reward.idty2,reward.id2,reward.num2)
        else
            return ch.CommonFunc:getRewardValue(reward.idty1,reward.id1,reward.num1)
        end
    end)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:noticeDataChange("isCd")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()    
    widget:addDataProxy("time",function(evt)
        local time = ch.ArenaModel:getCDTime()
        return getTime(time)
    end,arenaDataChangeEvent)
    widget:addDataProxy("isCd",function(evt)
        return ch.ArenaModel:getCDTime() > 0
    end,arenaDataChangeEvent)
    
    widget:addDataProxy("myRank",function(evt)
        return ch.ArenaModel:getMyRank()
    end,arenaDataChangeEvent)
    widget:addDataProxy("canPK",function(evt)
        return ch.ArenaModel:getChallengeNum() < 1
    end,arenaDataChangeEvent)
    widget:addDataProxy("canReset",function(evt)
        return ch.ArenaModel:getResetNum() > 0
    end,arenaDataChangeEvent)
    widget:addDataProxy("list",function(evt)
        local items = {}
        table.insert(items,{index = 1,value = 0,isMultiple = true})
        table.insert(items,{index = 2,value = 0,isMultiple = true})
        items.autoScrollDown = true
        return items
    end)
    
    widget:addDataProxy("myRankOld",function(evt)
        return ch.ArenaModel:getMyRankOld()
    end,arenaDataChangeEvent)
    widget:addDataProxy("ifGetReward",function(evt)
        return ch.ArenaModel:getMyState() < 2
    end,arenaDataChangeEvent)
    widget:addDataProxy("canGet",function(evt)
        return ch.ArenaModel:getMyState() == 1
    end,arenaDataChangeEvent)
 
    
    widget:addCommond("reset",function()
        ch.UIManager:showMsgBox(2,true,string.format(Language.src_clickhero_view_CardActivityView_10,GameConst.ARENA_CHALLENGE_COST,GameConst.ARENA_CHALLENGE_ADD),function()
            if ch.MoneyModel:getDiamond() >= GameConst.ARENA_CHALLENGE_COST then
                ch.NetworkController:arenaReset()
            else
                ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
            end
        end,nil,Language.src_clickhero_view_CardActivityView_11,2)
    end)
    widget:addCommond("openLog",function()
        ch.NetworkController:arenaPKLog()
    end)
    -- 天梯商店
    widget:addCommond("openShop",function()
        ch.UIManager:showGamePopup("Guild/W_GuildShop",2)
    end)
    
    widget:addCommond("getReward",function()
        ch.NetworkController:arenaGetReward()
    end)
    local isShow = false
    widget:addDataProxy("winBack",function(evt)
        return isShow
    end)
    
    if ch.ArenaModel:isWin() then
        ch.ArenaModel:setWin(false)
        widget:setTimeOut(0.8,function()
            isShow = true
            ch.RoleResManager:loadEffect("tx_tiantiguangxiao")
            widget:noticeDataChange("winBack")
            local beforeAni = ch.CommonFunc:createAnimation("tx_tiantiguangxiao")
            local afterAni = ch.CommonFunc:createAnimation("tx_tiantiguangxiao")
            beforeAni:setPosition(320,600)
            afterAni:setPosition(320,600)
            ch.CommonFunc:playAni(beforeAni, "guang", true)
            ch.CommonFunc:playAni(afterAni, "guangquan", true)

            local ani = ch.CommonFunc:createRoleAvatar(ch.UserTitleModel:getAvatar(),ch.UserTitleModel:getWeapon())
            ani:setPosition(320,600)
            ch.CommonFunc:playAni(ani, "victory", false)

            ch.CommonFunc:speedAni(ani, 2)
            local effani = ch.CommonFunc:createAnimation("mainRoleEffect")
            effani:setPosition(320,600)
            ch.CommonFunc:playAni(effani, "victory", false)
            ch.CommonFunc:speedAni(effani, 2)

            widget:addChild(afterAni)
            widget:addChild(ani)
            widget:addChild(effani)
            widget:addChild(beforeAni)
            ch.CommonFunc:setAniCb(ani, function(...)
                local node = cc.Node:create()
                local sprite = cc.Sprite:create("res/ui/aaui_font/rankUp.png")
                local text = ccui.TextAtlas:create(ch.ArenaModel:getMyRank(),"res/ui/aaui_font/num_boss.png",34,64,"0")
                text:setAnchorPoint(cc.p(0,0.5))
                text:setPosition(sprite:getContentSize().width/2 + 10,0)
                node:setPosition(320 - text:getContentSize().width/2 - 5,200)
                widget:addChild(node)
                node:addChild(sprite)
                node:addChild(text)
                local act = cc.Sequence:create(cc.MoveBy:create(0.6,cc.p(0,350)),cc.DelayTime:create(1),cc.CallFunc:create(function()
                    ani:removeFromParent()
                    afterAni:removeFromParent()
                    beforeAni:removeFromParent()
                    effani:removeFromParent()
                    node:removeFromParent()
                    isShow = false
                    widget:noticeDataChange("winBack")
                end))
                node:runAction(act)
            end)
        end)
    end
end)

-- 天梯界面
zzy.BindManager:addCustomDataBind("card/W_tt_frame", function(widget,data)
    INFO("[天梯战斗界面]")
    local panelDataChangeEvent = {}
    panelDataChangeEvent[ch.ArenaModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.ArenaModel.dataType.all
    end
    
    local config = ch.ArenaModel:getItemDataByIndex(tonumber(data))
    widget:addDataProxy("playerIcon",function(evt)
        if config.gender == 2 then
            return GameConst.PERSON_ICON[2]
        else
            return GameConst.PERSON_ICON[1]
        end
    end,panelDataChangeEvent)
    widget:addDataProxy("frameIcon",function(evt)
        return ch.ArenaModel:getFrameByRank(config.frame)
    end,panelDataChangeEvent)
    widget:addDataProxy("rank",function(evt)
        return config.rank
    end,panelDataChangeEvent)
    widget:addDataProxy("name",function(evt)
        return config.name
    end,panelDataChangeEvent)
    widget:addDataProxy("notSelf",function(evt)
        return config.frame ~= -1
    end,panelDataChangeEvent)
    widget:addCommond("openDetail",function()
        ch.NetworkController:arenaPlayer(config.id,config.rank,math.ceil(tonumber(data)/10))
    end)
    -- 没有的隐藏
    widget:addDataProxy("ifHave",function(evt)
        return not config.vis
    end,panelDataChangeEvent)
end)

-- 天梯界面(1为不显示挑战的查看界面，其余为进入战斗的界面2天梯4掠夺5副本,6抢矿)
zzy.BindManager:addCustomDataBind("card/W_card_chakan", function(widget,data)
    if data.type ~= 1 and table.maxn(ch.ArenaModel:getMyCardListInit()) < 1 then
        ch.guide:play_guide(10190)
    end
    local cs = data
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_CardActivityView_12
    end)
    widget:addDataProxy("name",function(evt)
        return cs.name
    end)
    widget:addDataProxy("lrank",function(evt)
--        return cs.rank
        return ch.NumberHelper:toString(ch.PetCardModel:getTeamPower(cs.cardList))
    end)
    widget:addDataProxy("maxLevel",function(evt)
        return cs.maxLevel
    end)
    widget:addDataProxy("arank",function(evt)
        return cs.arena or "---"
    end)
    widget:addDataProxy("canPK",function(evt)
        return cs.type ~= 1
    end)
    widget:addDataProxy("titleIcon",function(evt)
        if type(cs.maxLevel) == "string" then
            return ch.UserTitleModel:getTitle(1,cs.userId).icon
        else
            return ch.UserTitleModel:getTitle(cs.maxLevel-1,cs.userId).icon
        end
    end)
    widget:addDataProxy("titleName",function(evt)
        if type(cs.maxLevel) == "string" then
            return ch.UserTitleModel:getTitle(1,cs.userId).name
        else
            return ch.UserTitleModel:getTitle(cs.maxLevel-1,cs.userId).name
        end
    end)
    widget:addDataProxy("num",function(evt)
        return Language.src_clickhero_view_CardActivityView_13.. ch.NumberHelper:toString(ch.PetCardModel:getTeamPower(cs.cardList))
    end)
    
    widget:addCommond("pk",function()
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10240 then
            ch.guide:endid(10240)
        end
        if cs.type == 2 then
            if not ch.ArenaModel:ifMyCardList() then
                ch.UIManager:showGamePopup("card/W_card_f_choose",{type=2})
            elseif ch.ArenaModel:getCDTime() > 0 then
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_CardActivityView_14,nil,nil,Language.src_clickhero_view_CardActivityView_8,2)
            elseif ch.ArenaModel:getChallengeNum() < 1 then
                if ch.ArenaModel:getResetNum() > 0 then
                    ch.UIManager:showMsgBox(2,true,string.format(Language.src_clickhero_view_CardActivityView_10,GameConst.ARENA_CHALLENGE_COST,GameConst.ARENA_CHALLENGE_ADD),function()
                        if ch.MoneyModel:getDiamond() >= GameConst.ARENA_CHALLENGE_COST then
                            ch.NetworkController:arenaReset()
                            ch.NetworkController:arenaPK(cs.userId,cs.arena)
                            widget:destory()
                        else
                            ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
                        end
                    end,nil,Language.src_clickhero_view_CardActivityView_11,2)
                else
                    ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_CardActivityView_15,nil,nil,Language.src_clickhero_view_CardActivityView_8,2)
                end
            else
                ch.NetworkController:arenaPK(cs.userId,cs.arena)
                widget:destory()
            end
        elseif cs.type == 4 then 
            if not ch.ArenaModel:ifMyCardList() then
                ch.UIManager:showGamePopup("card/W_card_f_choose",{type=2})
            else
                ch.NetworkController:altarRob(cs.userId,cs.altarType)
                widget:destory()
                ch.UIManager:closeGamePopupLayer("card/W_jt_lveduo")
            end
        elseif cs.type == 5 then
            if not ch.ArenaModel:ifMyCardList() then
                ch.UIManager:showGamePopup("card/W_card_f_choose",{type=2})
            else
                ch.NetworkController:cardFBFight(cs.fbId)
                widget:destory()
            end
        elseif cs.type == 6 then
            if not ch.ArenaModel:ifMyCardList() then
                ch.UIManager:showGamePopup("card/W_card_f_choose",{type=2})
            else
                ch.NetworkController:attackMine(ch.MineModel:getCurMineId(),cs.userId)
                widget:destory()
            end
        end
    end)
    widget:addCommond("change",function()
        ch.UIManager:showGamePopup("card/W_card_f_choose",{type=2})
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10190 then
            ch.guide:endid(10190)
        end
    end)
    
    -- tgx
    INFO("[CARD][天梯][敌方阵容]")
    for i=1,5 do
        INFO("i=%d",i)
        local Panel_card = widget:getChild("Panel_card")
        
        local cardI = ccui.Helper:seekWidgetByName(Panel_card, "card_"..i)
        
        local img_card = ccui.Helper:seekWidgetByName(cardI, "img_card")
        img_card:setVisible(false)
        
        local aniPanel = ccui.Helper:seekWidgetByName(cardI, "Panel_layer")
        
        if cs.cardList[i] then
            --ch.CommonFunc:showCardSke(aniPanel, cs.cardList[i].id, 0.25, 55, -100) --天梯敌方阵容 --重复了去掉
        end
    end
    -- tgx

    widget:addDataProxy("card1",function(evt)
        return {type = 1,id=1,value = cs.cardList[1]}
    end)
    widget:addDataProxy("card2",function(evt)
        return {type = 1,id=2,value = cs.cardList[2]}
    end)
    widget:addDataProxy("card3",function(evt)
        return {type = 1,id=3,value = cs.cardList[3]}
    end)
    widget:addDataProxy("card4",function(evt)
        return {type = 1,id=4,value = cs.cardList[4]}
    end)
    widget:addDataProxy("card5",function(evt)
        return {type = 1,id=5,value = cs.cardList[5]}
    end)
    
    local roleName,weapon = ch.UserTitleModel:getAvatarByLevel(cs.maxLevel - 1,cs.gender)

    local playerPanel = widget:getChild("icon_player")

    ch.CommonFunc:showRoleAvatar(playerPanel,roleName,weapon)
    
end)


-- 天梯战斗记录
zzy.BindManager:addFixedBind("card/W_tt_zhandoujilu",function(widget)
    widget:addDataProxy("list",function()
        return ch.ArenaModel:getPKLogData()
    end)
end)

-- 天梯战斗记录单元
zzy.BindManager:addCustomDataBind("card/N_tt_zhandoujilu",function(widget,data)
    widget:addDataProxy("icon",function()
        return GameConst.ARENA_PK_LOG_DATA[data.ltype].icon
    end)

    widget:addDataProxy("textJitan",function()
        return GameConst.ARENA_PK_LOG_DATA[data.ltype].jitan
    end)

    widget:addDataProxy("textWin",function()
        return string.format(GameConst.ARENA_PK_LOG_DATA[data.ltype].win,ch.CommonFunc:getNameNoSever(data.name))
    end)
    widget:addDataProxy("textGet",function()
        return GameConst.ARENA_PK_LOG_DATA[data.ltype].get
    end)
    widget:addDataProxy("rank",function()
        return data.rank or 0
    end)
    widget:addDataProxy("rankChange",function()
        return data.ltype == 1 or data.ltype == 4
    end)
    widget:addDataProxy("isUp",function()
        return data.ltype == 1
    end)
    widget:addDataProxy("isDown",function()
        return data.ltype == 4
    end)
    widget:addCommond("play",function()
        ch.NetworkController:arenaPlay(data.fty,data.ftime,data.id1,data.id2)
    end)
end)
