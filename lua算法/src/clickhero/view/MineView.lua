local getTime = function(time)
    if time > 0 then
        local second = math.floor(time%60)
        time = time /60
        local minute = math.floor(time%60)
        local hour = math.floor(time/60)
        return string.format("%02d:%02d:%02d",hour,minute,second)
    else
        return "00:00:00"
    end
end


-- 矿场入口
zzy.BindManager:addFixedBind("CardPit/W_pit", function(widget)
    local pageChangeEvent = {}
    pageChangeEvent[ch.MineModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MineModel.dataType.curPage
    end
    local mineDataChangeEvent = {}
    mineDataChangeEvent[ch.MineModel.dataChangeEventType] = false
    mineDataChangeEvent[ch.ChristmasModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ChristmasModel.dataType.open
            or evt.dataType == ch.ChristmasModel.dataType.stop
            or evt.dataType == ch.ChristmasModel.dataType.nextday
    end
    
    local berylChangeEvent = {}
    berylChangeEvent[ch.MineModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MineModel.dataType.beryl
            or evt.dataType == ch.MineModel.dataType.panel
    end
    
    -- 每日提醒一次
    cc.UserDefault:getInstance():setStringForKey("ifOpenMine",ch.CommonFunc:getZeroTime(os_time()))
    ch.SignModel:effectDataChangeEvent()
    
    local page = ch.MineModel:getCurPage()
    widget:addDataProxy("bgImage",function(evt)
        ch.MineModel.isOpen = true
        return "res/img/card_pit_bg.png"
    end)
    widget:addDataProxy("title",function(evt)
        if page ~= ch.MineModel:getCurPage() then
            widget:playEffect("playYunCai")
            page = ch.MineModel:getCurPage()
        end
        return string.format(Language.MINE_PANEL_TITLE,ch.MineModel:getCurPage())
    end,pageChangeEvent)
    widget:addDataProxy("myMineIcon",function(evt)
        return ch.MineModel:getLvDataByID(ch.MineModel:getMyMineId()).icon
    end,mineDataChangeEvent)
    widget:addDataProxy("getText",function(evt)
        if ch.MineModel:getMyMineId() > 0 then
            return Language.MINE_PANEL_GET_TEXT
        else
            return Language.MINE_PANEL_NO_GET_TEXT
        end
    end,mineDataChangeEvent)
    widget:addDataProxy("output_digit",function(evt)
        -- 开启双倍活动
        local num = ch.MineModel:getLvDataByID(ch.MineModel:getMyMineId()).num*60
        if ch.ChristmasModel:isOpenByType(1020) then
            num = num*ch.ChristmasModel:getHDataByType(1020).ratio
        end
        return num
    end,mineDataChangeEvent)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("occTime")
        widget:noticeDataChange("defTime")
        widget:noticeDataChange("output_digit_get")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()    

    widget:addDataProxy("occTime",function(evt)
        local time = ch.MineModel:getOccTimeCD()
        return getTime(time)
    end,mineDataChangeEvent)
    widget:addDataProxy("defTime",function(evt)
        local time = ch.MineModel:getDefTimeCD()
        return getTime(time)
    end,mineDataChangeEvent)
    widget:addDataProxy("output_digit_get",function(evt)
        if ch.MineModel:getOccTimeCD() == -1 then
           return 0
        else
            local time = GameConst.MINE_OCCUPATION_TIME - ch.MineModel:getOccTimeCD()
            time = math.floor(time/60)
            time = time>0 and time or 0
            -- 开启双倍活动
            local num = ch.MineModel:getLvDataByID(ch.MineModel:getMyMineId()).num*time
            if ch.ChristmasModel:isOpenByType(1020) then
                num = num*ch.ChristmasModel:getHDataByType(1020).ratio
            end
            return num
        end
    end,mineDataChangeEvent)
    
    
    widget:addDataProxy("seat",function(evt)
        local id = ch.MineModel:getMyMineId()
        if id > 0 then
            return string.format(Language.MINE_PANEL_TITLE,GameConfig.Mine_zoneConfig:getData(id).zone)
        else
--            return ch.MineModel:getLvDataByID(id).name
            return ""
        end
    end,mineDataChangeEvent)
    widget:addDataProxy("attNum",function(evt)
        return ch.MineModel:getAttNum()
    end,mineDataChangeEvent)
    widget:addDataProxy("occNum",function(evt)
        return ch.MineModel:getOccNum()
    end,mineDataChangeEvent)
    widget:addDataProxy("output",function(evt)
        return ch.MineModel:getBerylNum()
    end,berylChangeEvent)
    widget:addDataProxy("price",function(evt)
        return string.format(Language.BERYL_TO_GOLD_DESC,math.floor(3600/GameConst.BERYL_TO_GOLD))
    end)
    
    widget:addDataProxy("isDouble",function(evt)
        return ch.ChristmasModel:isOpenByType(1020)
    end,mineDataChangeEvent)
    widget:addDataProxy("ifCanAdd",function(evt)
        return ch.MineModel:getOccNum()<GameConst.MINE_OCCUPATION_MAX and ch.MineModel:getResetOccNum() > 0
    end,mineDataChangeEvent)
    widget:addDataProxy("ifCanAddFull",function(evt)
        return true
    end,mineDataChangeEvent)
    widget:addDataProxy("ifCanLog",function(evt)
        return true
    end)
    widget:addDataProxy("pages",function(evt)
        local items = {}
        for i=1,20 do
            table.insert(items,i)
        end
        return items
    end)
    
    widget:addDataProxy("mine1",function(evt)
        return 1
    end)
    widget:addDataProxy("mine2",function(evt)
        return 2
    end)
    widget:addDataProxy("mine3",function(evt)
        return 3
    end)
    widget:addDataProxy("mine4",function(evt)
        return 4
    end)
    widget:addDataProxy("mine5",function(evt)
        return 5
    end)
    widget:addDataProxy("sellText20",function(evt)
        if ch.MineModel:getBerylNum()>=100 then
            return Language.MINE_SELL_TEXT[1]
        else
            return Language.MINE_SELL_TEXT[3]
        end
    end,berylChangeEvent)
    widget:addDataProxy("sellText100",function(evt)
        return Language.MINE_SELL_TEXT[2]
    end,berylChangeEvent)
    widget:addDataProxy("ifCanSell20",function(evt)
        return ch.MineModel:getBerylNum()>=100
    end,berylChangeEvent)
    widget:addDataProxy("ifCanSell100",function(evt)
        return ch.MineModel:getBerylNum()>1
    end,berylChangeEvent)
    -- 小于100不让兑换20%，只允许兑换偶数个
    widget:addCommond("sell",function(widget,arg)
        local ratio = 1
        if arg == "0" then
            ratio = 0.2
        end
        local beryl = math.floor(ch.MineModel:getBerylNum()*ratio)
        beryl = math.fmod(beryl,2) == 0 and beryl or beryl-1
        local shentanEffect = 1+ch.ShentanModel:getSkillData(5)
		local tutengEffect = (1+ch.TotemModel:getTotemSkillData(1,12))
        local num = math.floor(beryl * GameConst.BERYL_TO_GOLD/60)
        local hour = math.floor(num/60)
        local min = math.floor(num%60)
        local gold = ch.CommonFunc:getOffLineGold(beryl * GameConst.BERYL_TO_GOLD)*shentanEffect
        local goldDesc = string.format(Language.src_clickhero_view_DefendView_7,hour,min)
        --gold = tostring(gold)
        --gold = string.format("%.2e", gold)
        --gold = string.gsub(gold, "+", "")
        gold = gold*shentanEffect*tutengEffect
        DEBUG("gold="..tostring(gold))
        ch.UIManager:showMsgBox(2,true,string.format(Language.BERYL_TO_GOLD_SELL_DESC,ratio*100,goldDesc,tostring(gold)),function()
            ch.NetworkController:sellBeryl(beryl,gold)
        end,nil,Language.BERYL_TO_GOLD_SELL_BTNTEXT,2)
    end)
    widget:addCommond("addTimes",function()
        ch.UIManager:showMsgBox(2,true,string.format(Language.MINE_OCCUPATION_ADD_DESC,GameConst.MINE_OCCUPATION_RESET_COST,GameConst.MINE_OCCUPATION_ADD),function()
            if ch.MoneyModel:getDiamond() >= GameConst.MINE_OCCUPATION_RESET_COST then
                ch.NetworkController:occAddMine()
            else
                ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
            end
        end,nil,Language.src_clickhero_view_AltarView_14,2)
    end) 
    widget:addCommond("openLog",function()
        ch.NetworkController:mineAttLog()
    end)
    widget:addCommond("help",function()
        ch.UIManager:showGamePopup("CardPit/W_pit_rule")
    end)
    widget:addCommond("close",function()
        ch.NetworkController:minePanelClose()
        ch.MineModel.isOpen = false
        widget:destory()
    end)
    -- 滑动翻页
    local pitspace = widget:getChild("Panel_pitspace")
    pitspace:addTouchEventListener(function(sender,evt)
        if evt == ccui.TouchEventType.began then

        elseif evt == ccui.TouchEventType.ended then
            cclog(sender:getTouchBeganPosition().x)
            cclog(sender:getTouchEndPosition().x)
            if sender:getTouchEndPosition().x - sender:getTouchBeganPosition().x < -10 then
                if ch.MineModel:getCurPage() < 20 then
                    ch.NetworkController:minePageData(ch.MineModel:getCurPage()+1)
                end
            elseif sender:getTouchEndPosition().x - sender:getTouchBeganPosition().x > 10 then
                if ch.MineModel:getCurPage() > 1 then
                    ch.NetworkController:minePageData(ch.MineModel:getCurPage()-1)
                end
            end
        end
    end)
    
    local index = 1
    widget:listen(ch.MineModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.MineModel.dataType.curPage then
            index = ch.MineModel:getCurPage()
            local list = widget:getChild("ListView_1")
            local width = list:getItem(0):getContentSize().width*(index-4)

            if index > 3 and list:getInnerContainerSize().width > list:getContentSize().width then
                local percent = 100*width/(list:getInnerContainerSize().width -list:getContentSize().width)
                percent = percent > 100 and 100 or percent
                list:requestDoLayout()
                list:jumpToPercentHorizontal(percent)
            end
        end
    end)

end)

zzy.BindManager:addCustomDataBind("CardPit/W_pit_seat",function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[ch.MineModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MineModel.dataType.curPage
    end
    
    widget:addDataProxy("pageNum",function(evt)
        return data
    end)
    widget:addDataProxy("noSelect",function(evt)
        return data ~= ch.MineModel:getCurPage()
    end,pageChangeEvent)
    widget:addDataProxy("isSelect",function(evt)
        return data == ch.MineModel:getCurPage()
    end,pageChangeEvent)
    widget:addCommond("changePage",function()
--        ch.MineModel:setCurPage(tonumber(data))
        ch.NetworkController:minePageData(tonumber(data))
    end)
end)

zzy.BindManager:addCustomDataBind("CardPit/W_pit_unit",function(widget,data)
    local pageChangeEvent = {}
    pageChangeEvent[ch.MineModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MineModel.dataType.page
    end
    local id = ch.MineModel:getPageDataByPos(data).id
    widget:addDataProxy("data",function(evt)
        local ret = {}
        local pageData = ch.MineModel:getPageDataByPos(data)
        local lvData = ch.MineModel:getLvDataByID(pageData.id)
        ret.mineName = lvData.name
        ret.mineIcon = lvData.icon
        ret.playerName = pageData.name
        if ch.PlayerModel:getPlayerGender() == 2 then
            ret.playerIcon = GameConst.PERSON_ICON[2]
        else
            ret.playerIcon = GameConst.PERSON_ICON[1]
        end
        if pageData.guildFlag then
            ret.guildIcon = GameConst.GUILD_FLAG[pageData.guildFlag]
        else
            ret.guildIcon = "res/icon/guild_1.png"
        end
        ret.guildName = pageData.guildName or ""
        ret.ifGuild = ch.MineModel:getPageDataByPos(data).guildId ~= nil
        ret.isSelf = ch.PlayerModel:getPlayerID() == pageData.userid
        ret.isBusy = pageData.userid ~= nil
        ret.isHave = true 
        return ret
    end,pageChangeEvent)

    local cutDown
    cutDown =  function()
        widget:noticeDataChange("safeTime")
        widget:noticeDataChange("isSafe")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()    

    widget:addDataProxy("safeTime",function(evt)
        if ch.MineModel:getPageDataByPos(data) and ch.MineModel:getPageDataByPos(data).ptime then
            local leftTime = ch.MineModel:getPageDataByPos(data).ptime - os_time()
            if leftTime > 0 then return getTime(math.floor(leftTime)) end
        end
        if ch.MineModel:getPageDataByPos(data).stime and ch.MineModel:getPageDataByPos(data).stime <= os_time() then
            ch.NetworkController:minePageData(ch.MineModel:getCurPage())
        end
        return "00:00:00"
    end,pageChangeEvent)
    widget:addDataProxy("isSafe",function(evt)
        return ch.MineModel:getPageDataByPos(data).ptime and ch.MineModel:getPageDataByPos(data).ptime > os_time()
    end,pageChangeEvent)

    widget:addCommond("openDetail",function()
        if ch.MineModel:getPageDataByPos(data).userid ~= ch.PlayerModel:getPlayerID() then
            ch.MineModel:setCurMineId(ch.MineModel:getPageDataByPos(data).id)
            ch.UIManager:showGamePopup("CardPit/W_pit_att",ch.MineModel:getPageDataByPos(data))
        end
    end)
    
    -- 滑动翻页
    local pitspace = widget:getChild("Panel_touch")
    pitspace:addTouchEventListener(function(sender,evt)
        if evt == ccui.TouchEventType.began then

        elseif evt == ccui.TouchEventType.canceled then
            cclog(sender:getTouchBeganPosition().x)
            cclog(sender:getTouchEndPosition().x)
            if sender:getTouchEndPosition().x - sender:getTouchBeganPosition().x < -10 then
                if ch.MineModel:getCurPage() < 20 then
                    ch.NetworkController:minePageData(ch.MineModel:getCurPage()+1)
                end
            elseif sender:getTouchEndPosition().x - sender:getTouchBeganPosition().x > 10 then
                if ch.MineModel:getCurPage() > 1 then
                    ch.NetworkController:minePageData(ch.MineModel:getCurPage()-1)
                end
            end
        end
    end)
    
end)

zzy.BindManager:addCustomDataBind("CardPit/W_pit_att",function(widget,data)
    widget:addDataProxy("mineName",function(evt)
        return ch.MineModel:getLvDataByID(data.id).name
    end)
    widget:addDataProxy("mineIcon",function(evt)
        return ch.MineModel:getLvDataByID(data.id).icon
    end)
    widget:addDataProxy("output_digit",function(evt)
        -- 开启双倍活动
        local num = ch.MineModel:getLvDataByID(data.id).num*60
        if ch.ChristmasModel:isOpenByType(1020) then
            num = num*ch.ChristmasModel:getHDataByType(1020).ratio
        end
        return num
    end)
    widget:addDataProxy("playerName",function(evt)
        return data.name or ""
    end)
    widget:addDataProxy("guildIcon",function(evt)
        if data.guildFlag then
            return GameConst.GUILD_FLAG[data.guildFlag]
        else
            return "res/icon/guild_1.png"
        end
    end)
    widget:addDataProxy("guildName",function(evt)
        return data.guildName or ""
    end)
    widget:addDataProxy("ifGuild",function(evt)
        return data.guildId ~= nil
    end)
    widget:addDataProxy("isBusy",function(evt)
        return data.userid ~= nil
    end)
    widget:addDataProxy("powerNum",function(evt)
        return data.power
    end)
    widget:addDataProxy("attNum",function(evt)
        return ch.MineModel:getAttNum()
    end)
    widget:addDataProxy("ifCanAtt",function(evt)
        return ch.MineModel:getAttNum() > 0
    end)
    widget:addCommond("fight",function()
        if data.userid ~= nil then
            if data.ptime and data.ptime > os_time() then
                ch.UIManager:showMsgBox(1,true,Language.MINE_ATTACK_ERROR[4],nil,nil,Language.MSG_BUTTON_YESOK,2)
            else
                ch.NetworkController:arenaPlayer(data.userid,data.rank,6)
            end
        else
            ch.NetworkController:attackMine(ch.MineModel:getCurMineId())
--            ch.UIManager:showGamePopup("CardPit/W_pit_occ",data.id)
        end
        widget:destory()
    end)
end)
 
zzy.BindManager:addCustomDataBind("CardPit/W_pit_occ",function(widget,data)
    local stayTime = 30
    local leftTime = 0
    local startCountDown = function()
        local startTime = os_clock()
        widget:listen(zzy.Events.TickEventType,function()
            leftTime = stayTime - os_clock() + startTime
            if leftTime > 0 then
                widget:noticeDataChange("leftTime")
            else
                widget:exeCommond("close")
            end
        end)
    end
    startCountDown()
    widget:addDataProxy("leftTime",function(evt)
        return string.format("%d",leftTime)
    end)
    widget:addDataProxy("mineName",function(evt)
        return ch.MineModel:getLvDataByID(ch.MineModel:getMyMineId()).name
    end)
    widget:addDataProxy("mineIcon",function(evt)
        return ch.MineModel:getLvDataByID(ch.MineModel:getMyMineId()).icon
    end)
    widget:addDataProxy("mineLv",function(evt)
        local id = ch.MineModel:getMyMineId()
        if id > 0 then
            return string.format(Language.MINE_PANEL_TITLE,GameConfig.Mine_zoneConfig:getData(id).zone)
        else
            return ch.MineModel:getLvDataByID(id).name
        end
    end)
    widget:addDataProxy("output_digit",function(evt)
        -- 开启双倍活动
        local num = ch.MineModel:getLvDataByID(ch.MineModel:getMyMineId()).num*60
        if ch.ChristmasModel:isOpenByType(1020) then
            num = num*ch.ChristmasModel:getHDataByType(1020).ratio
        end
        return num
    end)
    widget:addDataProxy("isOwn",function(evt)
        return ch.MineModel:getMyMineId() > 0
    end)
    widget:addDataProxy("mineNameNew",function(evt)
        return ch.MineModel:getLvDataByID(data).name
    end)
    widget:addDataProxy("mineIconNew",function(evt)
        return ch.MineModel:getLvDataByID(data).icon
    end)
    widget:addDataProxy("mineLvNew",function(evt)
        return string.format(Language.MINE_PANEL_TITLE,GameConfig.Mine_zoneConfig:getData(data).zone)
    end)
    widget:addDataProxy("output_digit_new",function(evt)
        -- 开启双倍活动
        local num = ch.MineModel:getLvDataByID(data).num*60
        if ch.ChristmasModel:isOpenByType(1020) then
            num = num*ch.ChristmasModel:getHDataByType(1020).ratio
        end
        return num
    end)
    widget:addDataProxy("occNum",function(evt)
        return ch.MineModel:getOccNum()
    end)
    widget:addDataProxy("ifCanOcc",function(evt)
        return ch.MineModel:getOccNum()>0 or ch.MineModel:getResetOccNum()>0
    end)
    widget:addCommond("occupy",function()
        if ch.MineModel:getOccNum() > 0 then
            ch.NetworkController:occupyMine(data)
            widget:destory()
        else
            ch.UIManager:showMsgBox(2,true,string.format(Language.MINE_OCCUPATION_ADD_DESC,GameConst.MINE_OCCUPATION_RESET_COST,GameConst.MINE_OCCUPATION_ADD),function()
                if ch.MoneyModel:getDiamond() >= GameConst.MINE_OCCUPATION_RESET_COST then
                    ch.NetworkController:occAddMine()
                    ch.NetworkController:occupyMine(data)
                    widget:destory()
                else
                    ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
                end
            end,nil,Language.src_clickhero_view_AltarView_14,2)
        end
    end)
    widget:addCommond("close",function()
        ch.NetworkController:occupyMine(data,1)
        widget:destory()
    end)
end)

-- 矿区占领收获记录
zzy.BindManager:addFixedBind("CardPit/W_pit_jilu",function(widget)
    widget:addDataProxy("list",function()
        return ch.MineModel:getAttLogData()
    end)
end)

-- 矿区占领收获记录单元
zzy.BindManager:addCustomDataBind("CardPit/N_pit_gzjilu",function(widget,data)
    widget:addDataProxy("icon",function()
        return GameConst.MINE_FIGHT_LOG_DATA[data.ltype].icon
    end)

    widget:addDataProxy("textJitan",function()
        return GameConst.MINE_FIGHT_LOG_DATA[data.ltype].jitan
    end)

    widget:addDataProxy("textWin",function()
        if data.ltype == 3 or data.ltype == 4 then
            return string.format(GameConst.MINE_FIGHT_LOG_DATA[data.ltype].win,data.name)
        elseif data.ltype == 1 then
            return string.format(GameConst.MINE_FIGHT_LOG_DATA[data.ltype].win,math.floor(GameConst.MINE_OCCUPATION_TIME/3600))
        else
            return GameConst.MINE_FIGHT_LOG_DATA[data.ltype].win
        end
    end)
    widget:addDataProxy("textGet",function()
        if data.ltype == 1 or data.ltype == 2 or data.ltype == 4 then
            return string.format(GameConst.MINE_FIGHT_LOG_DATA[data.ltype].get,data.num)
        else
            return GameConst.MINE_FIGHT_LOG_DATA[data.ltype].get
        end
    end)

    widget:addDataProxy("ifCanPlay",function()
        return data.ltype == 3 or data.ltype == 4
    end)
    widget:addCommond("play",function()
        ch.NetworkController:arenaPlay(data.fty,data.ftime,data.id1,data.id2)
    end)
end)




zzy.BindManager:addCustomDataBind("CardPit/W_ActivityMine",function(widget,data)
    local dotChangeEvent = {}
    dotChangeEvent[ch.SignModel.effectChangeEventType] = false
    
    widget:addDataProxy("title",function(evt)
        return Language.MINE_OPEN_NAME
    end)
    widget:addDataProxy("desc",function(evt)
        return Language.MINE_OPEN_DESC
    end)
    widget:addDataProxy("icon",function(evt)
        return "aaui_icon/icon_mine_open.png"
    end)
    widget:addDataProxy("btnText",function(evt)
        return Language.MINE_OPEN_BTNTEXT
    end)
    widget:addDataProxy("canTouch",function(evt)
        return true
    end)
    widget:addDataProxy("isTag",function(evt)
        return ch.SignModel:getRedPointByType(9)
    end,dotChangeEvent)
    widget:addCommond("fight",function()
        --结束引导
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10350 then
            ch.guide:endid(10350)
        end
        ch.NetworkController:minePanel()
        ch.NetworkController:minePageData(ch.MineModel:getMyMineZone())
        ch.UIManager:showGamePopup("CardPit/W_pit")
    end)
end)