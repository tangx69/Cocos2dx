local selectId = 1
local selectJSZD = 1

local titleGroup = {Language.src_clickhero_view_ActivityView_1,Language.src_clickhero_view_ActivityView_2,Language.src_clickhero_view_ShopView_7,Language.src_clickhero_view_ActivityView_22}
local iconGroup = {"res/icon/pop_sign.png","res/icon/pop_time.png","aaui_icon/icon_black.png","res/icon/icon_arena.png"}
local btnTextGroup = {Language.src_clickhero_view_ActivityView_3,Language.src_clickhero_view_ActivityView_4,Language.src_clickhero_view_ActivityView_4,Language.MINE_OPEN_BTNTEXT}
local getImageGroup = {"aaui_common/state_signed.png","aaui_common/state_sold.png","aaui_common/dot1.png","aaui_common/dot1.png"}
local openGroup = {"task/W_sign","activity/W_meirixg","Guild/W_GuildShop","card/W_tt"}

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

local getTimeLast = function(time)
    if time > 0 then
        local day = time /(24*3600)
        local day = math.floor(day)
        local second = math.floor(time%60)
        time = time /60
        local minute = math.floor(time%60)
        local hour = math.floor(time/60)
        hour = math.floor(hour%24)
--        return string.format("%d     %02d    %02d    %02d",day,hour,minute,second)
        return string.format(Language.src_clickhero_view_ActivityView_5,day,hour,minute,second)
    else
        return 0
    end
end

-- 固有绑定
-- 精彩活动界面
zzy.BindManager:addFixedBind("MainScreen/W_Activity", function(widget)
    --结束坚守阵地引导
    if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10150 then
        ch.guide:endid(10150)
    end
    --结束卡牌副本引导
    if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10320 then
        ch.guide:endid(10320)
    end
    --结束矿区争夺战引导
    if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10340 then
        ch.guide:endid(10340)
    end
    local levelChangeEvent = {}
    levelChangeEvent[ch.StatisticsModel.maxLevelChangeEventType] = false
    levelChangeEvent[ch.WarpathModel.dataChangeEventType] = false
    levelChangeEvent[ch.BuyLimitModel.dataChangeEventType] = false
    levelChangeEvent[ch.SettingModel.fbdataChangeEventType] = false
    widget:addDataProxy("title",function(evt)
        ch.BuyLimitModel:openPanel()
        ch.SignModel:setShowEffect(false)
        return Language.src_clickhero_view_ActivityView_6
    end)
    
    widget:addDataProxy("items",function(evt)
        local tmpTable = {}
        local sign = {icon = iconGroup[1],name=titleGroup[1],btnText=btnTextGroup[1],getImage=getImageGroup[1],openPanel=openGroup[1],type=1}
        table.insert(tmpTable,{index = 1,value = sign,isMultiple = true})
        -- 必须第二个（与引导相关）
        if ch.StatisticsModel:getMaxLevel()>GameConst.DEFEND_OPEN_LEVEL then
            table.insert(tmpTable,{index = 3,value = "0",isMultiple = true})
        end
        -- 必须第三个（与引导相关）
        if ch.StatisticsModel:getMaxLevel() > GameConst.CARD_FB_OPEN_LEVEL then
            table.insert(tmpTable,{index=4,value=1,isMultiple= true})
            table.insert(tmpTable,{index=4,value=2,isMultiple= true})
        end
        -- 必须第五个（与引导相关）
        if ch.StatisticsModel:getMaxLevel() > GameConst.MINE_OPEN_LEVEL then
            table.insert(tmpTable,{index=6,value=1,isMultiple= true})
        end
        if ch.WarpathModel:isShow() then
            table.insert(tmpTable,{index = 2,value = "0",isMultiple = true})
        end
        
        local blackShop = {icon = iconGroup[3],name=titleGroup[3],btnText=btnTextGroup[3],getImage=getImageGroup[3],openPanel=openGroup[3],type=4}
        if ch.StatisticsModel:getMaxLevel() > GameConst.RANDOM_SHOP_BLACK_OPEN_LEVEL then
            table.insert(tmpTable,{index = 1,value = blackShop,isMultiple = true})
        end
        local arenaOpen = {icon = iconGroup[4],name=titleGroup[4],btnText=btnTextGroup[4],getImage=getImageGroup[4],openPanel=openGroup[4],type=5}
        if ch.StatisticsModel:getMaxLevel() > GameConst.ARENA_OPEN_LEVEL then
            table.insert(tmpTable,{index = 1,value = arenaOpen,isMultiple = true})
        end
        
        local buyLimit = {icon = iconGroup[2],name=titleGroup[2],btnText=btnTextGroup[2],getImage=getImageGroup[2],openPanel=openGroup[2],type=2}
        if ch.BuyLimitModel:getEndTime()>os_time() then
            table.insert(tmpTable,{index = 1,value = buyLimit,isMultiple = true})
        end
        if ch.MatchRankModel:getOpenData() and table.maxn(ch.MatchRankModel:getOpenData())>0 then
            for k,v in pairs(ch.MatchRankModel:getOpenData()) do
                table.insert(tmpTable,{index=1,value=v,isMultiple= true})
            end
        end

        --暂时屏蔽掉分享
		if zzy.Sdk.getFlag()=="HDIOS"  then
            if zzy.cUtils.getVersion()~="1.11.5" then
				table.insert(tmpTable,{index = 5,value = "0",isMultiple = true})
             end
        elseif zzy.Sdk.getFlag() == "CYAND" or zzy.Sdk.getFlag() == "CYIOS" then
            table.insert(tmpTable,{index = 5,value = "0",isMultiple = true})
        end
		
		if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" and zzy.config.loginData.fbid==nil then
			table.insert(tmpTable,{index = 7,value = "0",isMultiple = true})
        end

        return tmpTable 
    end,levelChangeEvent)
end)

-- 签到活动卡片
zzy.BindManager:addCustomDataBind("task/W_SignActivityCard", function(widget,data)
    local signChangeEvent = {}
    signChangeEvent[ch.FirstSignModel.dataChangeEventType] = false
    signChangeEvent[ch.SignModel.dataChangeEventType] = false
    signChangeEvent[ch.BuyLimitModel.dataChangeEventType] = false
    
    local dotChangeEvent = {}
    dotChangeEvent[ch.SignModel.dataChangeEventType] = false
    dotChangeEvent[ch.FirstSignModel.dataChangeEventType] = false
    dotChangeEvent[ch.RandomShopModel.dataBlackChangeEventType] = false
    dotChangeEvent[ch.SignModel.effectChangeEventType] = false
    
    widget:addDataProxy("name",function(evt)
        return data.name
    end)
    widget:addDataProxy("icon",function(evt)
        return data.icon
    end)
    widget:addDataProxy("isTag",function(evt)
        if data.type == 1 then
            return ch.SignModel:getRedPointByType(1)
        elseif data.type == 4 then
            return ch.SignModel:getRedPointByType(6)
        elseif data.type == 5 then
            return ch.SignModel:getRedPointByType(7)
        end
        return false
    end,dotChangeEvent)
    widget:addDataProxy("btnText",function(evt)
        return data.btnText
    end)
    widget:addDataProxy("getImage",function(evt)
        return data.getImage
    end)
    widget:addDataProxy("noSign",function(evt)
        if data.type == 1 then
            if ch.FirstSignModel:isFirstSign() then
                return ch.FirstSignModel:getSignStatus() ~= 2
            else
                return ch.SignModel:getSignStatus() == 0
            end
        elseif data.type == 2 then
            return ch.BuyLimitModel:getCountByIndex(1) < ch.BuyLimitModel:getTodayData(1).max
        end
        return true
    end,signChangeEvent)
    
    widget:addDataProxy("isSign",function(evt)
        if data.type == 1 then
            if ch.FirstSignModel:isFirstSign() then
                return ch.FirstSignModel:getSignStatus() == 2
            else
                return ch.SignModel:getSignStatus() == 1
            end
        elseif data.type == 2 then
            return ch.BuyLimitModel:getCountByIndex(1) >= ch.BuyLimitModel:getTodayData(1).max
        end
        return false
    end,signChangeEvent)
    
    widget:addCommond("openSign",function()
        if data.type==3 then
            ch.NetworkController:matchRankList(data.typeId,data.cfgId)
        elseif data.type == 5 then
            ch.NetworkController:arenaPanel()
        elseif data.type == 4 then
            ch.UIManager:showGamePopup(data.openPanel,3)
        else
            ch.UIManager:showGamePopup(data.openPanel)
        end
    end)
end)

-- 无尽征途卡片
zzy.BindManager:addFixedBind("Guild/W_ElActivityCard", function(widget)
    local changeEvent = {}
    changeEvent[ch.WarpathModel.dataChangeEventType] = false

    local dotChangeEvent = {}
    dotChangeEvent[ch.SignModel.effectChangeEventType] = false

    widget:addDataProxy("icon",function(evt)
        return "aaui_icon/icon_wxzt.png"
    end)

    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_ActivityView_7
    end)

    widget:addDataProxy("curStage",function(evt)
        return ch.WarpathModel:getCurStage() or 1
    end,changeEvent)

    widget:addDataProxy("curBossNum",function()
        if ch.WarpathModel:isOpen() then
            return ch.WarpathModel:getCurIndex() or 0
        else
            return 0
        end
    end,changeEvent)
    widget:addDataProxy("isTag",function(evt)
        return ch.SignModel:getRedPointByType(5)
    end,dotChangeEvent)
    
    widget:addDataProxy("notOpen",function()
        return not ch.WarpathModel:isOpen()
    end,changeEvent)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("openTime")
        widget:noticeDataChange("notOpen")
        widget:noticeDataChange("isOpen")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    widget:addDataProxy("openTime",function(evt)
        local time = ch.WarpathModel:getOpenTimeCD()
        return getTime(time)
    end)
    
    widget:addDataProxy("isOpen",function()
        return ch.WarpathModel:isOpen() and ch.WarpathModel:getTimes() < 1 and ch.WarpathModel:isIdle()
    end,changeEvent)
    
    widget:addDataProxy("isJoin",function()
        return ch.WarpathModel:isOpen() and ch.WarpathModel:getTimes() > 0
    end,changeEvent)
    
    widget:addDataProxy("isOther",function()
        return ch.WarpathModel:isOpen() and ch.WarpathModel:getTimes() < 1 and not ch.WarpathModel:isIdle()
    end,changeEvent)
    
    widget:addDataProxy("waitTime",function()
        return 0
    end,changeEvent)
    
    widget:addCommond("openEL",function()
        selectId = 4
--        ch.NetworkController:warpathMemberRank()
        ch.UIManager:showGamePopup("Guild/W_El")
    end)
    
    widget:addCommond("join",function()
        ch.UIManager:cleanGamePopupLayer(true)
        ch.NetworkController:startWarpath()
    end)
end)

-- 坚守阵地卡片
zzy.BindManager:addFixedBind("Guild/W_JSActivityCard", function(widget)
    local levelChangeEvent = {}
    levelChangeEvent[ch.LevelModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    
    local timesChangeEvent = {}
    timesChangeEvent[ch.DefendModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.DefendModel.dataType.Times
    end
    
    local dotChangeEvent = {}
    dotChangeEvent[ch.SignModel.effectChangeEventType] = false
    
    widget:addDataProxy("icon",function(evt)
        return "aaui_icon/icon_jszd.png"
    end)

    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_ActivityView_8
    end)
    widget:addDataProxy("countNum",function(evt)
        local countNum = GameConst.DEFEND_DAY_MAX_COUNT-ch.DefendModel:getTimes()
        if countNum > 0 then
            return string.format(Language.src_clickhero_view_ActivityView_23,countNum,GameConst.DEFEND_DAY_MAX_COUNT)
        else
            return Language.src_clickhero_view_ActivityView_24
        end
    end,timesChangeEvent)
    widget:addDataProxy("isOpen",function()
        return ch.StatisticsModel:getMaxLevel()>GameConst.DEFEND_OPEN_LEVEL
    end,levelChangeEvent)

    widget:addDataProxy("isJoin",function()
        return ch.DefendModel:getTimes() < GameConst.DEFEND_DAY_MAX_COUNT 
                and ch.DefendModel:getTimeCD() <= 0
    end,timesChangeEvent)
    
    widget:addDataProxy("notJoin",function()
--        return ch.DefendModel:getTimes() >= GameConst.DEFEND_DAY_MAX_COUNT
        return ch.DefendModel:getTimeCD() > 0
    end,timesChangeEvent)
    widget:addDataProxy("isTag",function(evt)
        return ch.SignModel:getRedPointByType(2)
    end,dotChangeEvent)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("cdTime")
        widget:noticeDataChange("isJoin")
        widget:noticeDataChange("notJoin")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    widget:addDataProxy("cdTime",function(evt)
        local time = ch.DefendModel:getTimeCD()
        return getTime(time)
    end)
    
    widget:addDataProxy("joinNum",function()
        return ch.DefendModel:getTimes()
    end)

    widget:addDataProxy("allJoinNum",function()
        return GameConst.DEFEND_DAY_MAX_COUNT
    end)

    widget:addCommond("openJSZD",function()
--        ch.NetworkController:defendMemberRank()
        selectJSZD = 2
        ch.UIManager:showGamePopup("Guild/W_JSZD")
    end)

    widget:addCommond("join",function()
        ch.UIManager:cleanGamePopupLayer(true)
        if ch.guide._data["guide9080"] ~= 1 then
            ch.LevelController:startDefend(true)
            ch.guide:play_guide(9080)
        else
            ch.LevelController:startDefend(false)
        end
    end)
end)

-- 无尽征途首页
zzy.BindManager:addFixedBind("Guild/W_El", function(widget)
    -- 每日提醒一次
    cc.UserDefault:getInstance():setStringForKey("ifOpenWarpath",ch.CommonFunc:getZeroTime(os_time()))
    ch.SignModel:effectDataChangeEvent()

    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_ActivityView_7
    end)
    
    widget:addCommond("openIn1",function()
        if selectId ~= 1 then
            if ch.WarpathModel:getDataStateTime() and ch.WarpathModel:getDataStateTime() > 0 then
                ch.NetworkController:warpathReportAdd(ch.WarpathModel:getDataStateTime())
            else
                ch.NetworkController:warpathReport()
            end
        end
        selectId = 1
        cclog("成员战绩")
    end)
    
    widget:addCommond("openIn2",function()
        if selectId ~= 2 then
            ch.WarpathModel.ifMemberData = false
            ch.NetworkController:warpathMemberRank()
        end
        selectId = 2
        cclog("成员排行")
    end)
    
    widget:addCommond("openIn3",function()
        if selectId ~= 3 then
            ch.WarpathModel.ifGuildData = false
            ch.NetworkController:warpathGuildRank()
        end
        selectId = 3
        cclog("公会排名")
    end)
    
    widget:addCommond("openIn4",function()
        selectId = 4
        cclog("查看规则")
    end)
end)

-- 成员战绩页（挑战记录）
zzy.BindManager:addFixedBind("Guild/W_ELIn1", function(widget)
    local reportEvent = {}
    reportEvent[ch.WarpathModel.panelChangeEventType] = function(evt)
        return evt.dataType == ch.WarpathModel.dataType.report
    end
    widget:addDataProxy("curStage",function(evt)
        return ch.WarpathModel:getCurStage()
    end)
    
    widget:addDataProxy("curBossNum",function(evt)
        return ch.WarpathModel:getCurIndex()-1 .."/"..GameConst.WARPATH_BOSS_MAX_COUNT
    end)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("ltime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    widget:addDataProxy("ltime",function(evt)
        local time = ch.WarpathModel:getCloseTimeCD()
--        return getTime(time)
        return ch.NumberHelper:cdTimeToString(time)
    end)
        
    widget:addDataProxy("gainList",function(evt)
        local tmpData = {}
--        if ch.WarpathModel:getAllReport() then
--            for k,v in pairs(ch.WarpathModel:getAllReport()) do
--                table.insert(tmpData,{type = 1,value = v})
--            end
--        end
        widget:getChild("ListView_1"):removeAllItems()

        for k,v in pairs(ch.WarpathModel:getAllReport()) do
            local richText = ccui.RichText:create()
            
            
            local tm
            if ch.CommonFunc:getAppointedTime(os_time(),0) == ch.CommonFunc:getAppointedTime(tonumber(v.time),0) then
                tm = os.date("%H:%M",tonumber(v.time))
            else
                tm = os.date("%m/%d",tonumber(v.time))
            end
            local re1 = ccui.RichElementText:create(1,cc.c3b(51,246,207),255,tm,"res/ui/aaui_font/ch.ttf",20)
            local re2 = ccui.RichElementText:create(2,cc.c3b(179,60,8),255," ".. ch.CommonFunc:getNameNoSever(v.name) .." ",nil,20)
            local re3
            local re4
            local re5
            local re6
            local re7

            if v.isKill == 1 then
                re3 = ccui.RichElementText:create(3,cc.c3b(112,46,12),255,Language.src_clickhero_view_ActivityView_9,"res/ui/aaui_font/ch.ttf",20)
                if table.maxn(v.bossNum) > 1 then
                    re4 = ccui.RichElementText:create(4,cc.c3b(179,60,8),255,v.bossNum[1].."-"..v.bossNum[table.maxn(v.bossNum)],"res/ui/aaui_font/ch.ttf",20)
                else
                    re4 = ccui.RichElementText:create(4,cc.c3b(179,60,8),255,v.bossNum[1],"res/ui/aaui_font/ch.ttf",20)
                end
                re5 = ccui.RichElementText:create(5,cc.c3b(112,46,12),255,Language.src_clickhero_view_ActivityView_10,"res/ui/aaui_font/ch.ttf",20)
            elseif v.isKill == 0 then
                re3 = ccui.RichElementText:create(3,cc.c3b(112,46,12),255,Language.src_clickhero_view_ActivityView_11,"res/ui/aaui_font/ch.ttf",20)
                re4 = ccui.RichElementText:create(4,cc.c3b(179,60,8),255,v.bossNum[1],"res/ui/aaui_font/ch.ttf",20)
                re5 = ccui.RichElementText:create(5,cc.c3b(112,46,12),255,Language.src_clickhero_view_ActivityView_12,"res/ui/aaui_font/ch.ttf",20)
                re6 = ccui.RichElementText:create(5,cc.c3b(179,60,8),255,v.harm,"res/ui/aaui_font/ch.ttf",20)
                re7 = ccui.RichElementText:create(5,cc.c3b(112,46,12),255,Language.src_clickhero_view_ActivityView_13,"res/ui/aaui_font/ch.ttf",20)
            else
                re3 = ccui.RichElementText:create(3,cc.c3b(112,46,12),255,Language.src_clickhero_view_ActivityView_14,"res/ui/aaui_font/ch.ttf",20)
            end
            richText:pushBackElement(re1)
            richText:pushBackElement(re2)
            richText:pushBackElement(re3)
            if re4 then richText:pushBackElement(re4) end
            if re5 then richText:pushBackElement(re5) end
            if re6 then richText:pushBackElement(re6) end
            if re7 then richText:pushBackElement(re7) end
            
            -- 适应多语言排布
            richText:ignoreContentAdaptWithSize(true)
            richText:formatText()
            local size = richText:getVirtualRendererSize()
            if size.width > 550 then
                richText:setContentSize(cc.size(550,40))
            else
                richText:setContentSize(cc.size(550,20))
            end
            richText:ignoreContentAdaptWithSize(false)
            
            widget:getChild("ListView_1"):pushBackCustomItem(richText)
        end
        return tmpData
    end,reportEvent)
end)

-- 成员战绩单元卡片
zzy.BindManager:addCustomDataBind("Guild/W_ELIn1unit", function(widget,data)
    local tmpData = data.value
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(tmpData.name)
    end)

    widget:addDataProxy("warTime",function(evt)
        return os.date("%H:%M",tonumber(tmpData.time))
    end)

    widget:addDataProxy("stage",function(evt)
        return tmpData.bossNum
    end)

    widget:addDataProxy("harm",function(evt)
        return tmpData.harm .. "%"
    end)
    
    widget:addDataProxy("isSuccess",function(evt)
        return data.type == 2
    end)
    
    widget:addDataProxy("isFailed",function(evt)
        return data.type == 1
    end)
end)

-- 本公会成员排行页
zzy.BindManager:addFixedBind("Guild/W_ELIn2", function(widget)
    local memberEvent = {}
    memberEvent[ch.WarpathModel.panelChangeEventType] = function(evt)
        return evt.dataType == ch.WarpathModel.dataType.member
    end
    
    widget:addDataProxy("noData",function(evt)
        return table.maxn(ch.WarpathModel:getAllMemberRank()) < 1
    end,memberEvent)
    
    widget:addDataProxy("loadDes",function(evt)
        if ch.WarpathModel.ifMemberData then
            return Language.src_clickhero_view_ActivityView_15
        else
            return Language.src_clickhero_view_ActivityView_16
        end
    end,memberEvent)
    
    widget:addDataProxy("memberList",function(evt)
        local tmpData = {}
        if ch.WarpathModel:getAllMemberRank() then
            for k,v in pairs(ch.WarpathModel:getAllMemberRank()) do
                v.rank = k
                table.insert(tmpData,{type = 1,value = v})
            end
        end
        return tmpData
    end,memberEvent)
end)

-- 成员排行单元卡片
zzy.BindManager:addCustomDataBind("Guild/W_ELIn2unit", function(widget,data)
    local tmpData = data.value
    widget:addDataProxy("isSelf",function(evt)
        return tmpData.userId == ch.PlayerModel:getPlayerID()
    end)
    widget:addDataProxy("notSelf",function(evt)
        return tmpData.userId ~= ch.PlayerModel:getPlayerID()
    end)
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(tmpData.name)
    end)
    -- 称号图标
    widget:addDataProxy("titleIcon",function(evt)
        return ch.UserTitleModel:getTitle(tmpData.maxLevel-1,tmpData.userId).icon
    end)
    widget:addDataProxy("r_icon",function(evt)
        if tmpData.gender == 2 then
            return GameConst.PERSON_ICON[2]
        else
            return GameConst.PERSON_ICON[1]
        end
    end)
    
    widget:addDataProxy("p_icon",function(evt)
        return GameConfig.PartnerConfig:getData(tostring(tmpData.pet)).icon
    end)
    
    widget:addDataProxy("rank",function(evt)
        return tmpData.rank
    end)
    
    widget:addDataProxy("score",function(evt)
        return ch.NumberHelper:toString(tmpData.score or 0)
    end)
    
    widget:addDataProxy("isMyGuild",function(evt)
        return data.type == 1
    end)
    
    widget:addCommond("openDetail",function()
        ch.UIManager:showGamePopup("Guild/W_Guildmemberdetail",{type = 2,value = tmpData})
    end)
    
end)

-- 公会排行页
zzy.BindManager:addFixedBind("Guild/W_ELIn3", function(widget)
    local rankEvent = {}
    rankEvent[ch.WarpathModel.panelChangeEventType] = function(evt)
        return evt.dataType == ch.WarpathModel.dataType.rank
    end
    local myData = ch.WarpathModel:getMyGuildRank()
    
    widget:addDataProxy("noData",function(evt)
        return table.maxn(ch.WarpathModel:getAllGuildRank()) < 1
    end,rankEvent)
    
    widget:addDataProxy("loadDes",function(evt)
        if ch.WarpathModel.ifGuildData then
            return Language.src_clickhero_view_ActivityView_17
        else
            return Language.src_clickhero_view_ActivityView_16
        end
    end,rankEvent)
    
    widget:addDataProxy("rankList",function(evt)
        local tmpData = {}
        if ch.WarpathModel:getAllGuildRank() then
            for k,v in pairs(ch.WarpathModel:getAllGuildRank()) do
                table.insert(tmpData,k)
            end
        end
        return tmpData
    end,rankEvent)
    
    widget:addDataProxy("rank",function(evt)
        return myData.rank
    end,rankEvent)
    
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(myData.name)
    end,rankEvent)
    
    widget:addDataProxy("flag",function(evt)
        return GameConst.GUILD_FLAG[myData.flag]
    end,rankEvent)
    
    widget:addDataProxy("stage",function(evt)
        return ch.WarpathModel:getCurStage()
    end,rankEvent)
    
    widget:addDataProxy("bossNum",function(evt)
        return ch.WarpathModel:getCurIndex()
    end,rankEvent)
end)

-- 公会排行单元卡片
zzy.BindManager:addCustomDataBind("Guild/W_ELIn3unit", function(widget,data)
    local tmpData = ch.WarpathModel:getGuildRank(data)
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(tmpData.name)
    end)

    widget:addDataProxy("flag",function(evt)
        return GameConst.GUILD_FLAG[tmpData.flag]
    end)
    
    widget:addDataProxy("rank",function(evt)
        return data
    end)
    
    widget:addDataProxy("curStage",function(evt)
        return tmpData.stage
    end)

    widget:addDataProxy("curBossNum",function(evt)
        return tmpData.bossNum
    end)
    
    widget:addCommond("openDetail",function()
        ch.WarpathModel.ifDetailData = false
        ch.NetworkController:warpathGuildDetail(tmpData.id)
        ch.UIManager:showGamePopup("Guild/W_ELIn2other",{value=tmpData})
    end)
end)

-- 其他公会成员排行页
zzy.BindManager:addCustomDataBind("Guild/W_ELIn2other", function(widget,data)
    local guildEvent = {}
    guildEvent[ch.WarpathModel.panelChangeEventType] = function(evt)
        return evt.dataType == ch.WarpathModel.dataType.guild
    end
    local tmpData = data.value
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_ActivityView_18
    end)
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(tmpData.name)
    end)

    widget:addDataProxy("flag",function(evt)
        return GameConst.GUILD_FLAG[tmpData.flag]
    end)
    widget:addDataProxy("noData",function(evt)
        return table.maxn(ch.WarpathModel:getGuildDetail()) < 1
    end,guildEvent)
    
    widget:addDataProxy("loadDes",function(evt)
        if ch.WarpathModel.ifDetailData then
            return Language.src_clickhero_view_ActivityView_19
        else
            return Language.src_clickhero_view_ActivityView_16
        end
    end,guildEvent)
    
    widget:addDataProxy("rankList",function(evt)
        local tmpData = {}
        if ch.WarpathModel:getGuildDetail() then
            for k,v in pairs(ch.WarpathModel:getGuildDetail()) do
                v.rank = k
                table.insert(tmpData,{type = 2,value = v})
            end
        end
        return tmpData
    end,guildEvent)
end)

-- 规则
zzy.BindManager:addFixedBind("Guild/W_ELIn4", function(widget)
    local changeEvent = {}
    changeEvent[ch.WarpathModel.dataChangeEventType] = false
    
    widget:addDataProxy("desc",function(evt)
        return GameConst.WARPATH_DESC
    end)
    widget:addDataProxy("curStage",function(evt)
        return ch.WarpathModel:getCurStage()
    end)

    widget:addDataProxy("curBossNum",function(evt)
        return ch.WarpathModel:getCurIndex()-1 .."/"..GameConst.WARPATH_BOSS_MAX_COUNT
    end)
    widget:addDataProxy("notOpen",function()
        return not ch.WarpathModel:isOpen()
    end,changeEvent)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("openTime")
        widget:noticeDataChange("notOpen")
        widget:noticeDataChange("isOpen")
        widget:noticeDataChange("ltime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    widget:addDataProxy("openTime",function(evt)
        local time = ch.WarpathModel:getOpenTimeCD()
--        return getTime(time)
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("ltime",function(evt)
        local time = ch.WarpathModel:getCloseTimeCD()
--        return getTimeLast(time)
        return ch.NumberHelper:cdTimeToString(time)
    end)
    widget:addDataProxy("isOpen",function()
        return ch.WarpathModel:isOpen() and ch.WarpathModel:getTimes() < 1 and ch.WarpathModel:isIdle()
    end,changeEvent)

    widget:addDataProxy("isJoin",function()
        return ch.WarpathModel:isOpen() and ch.WarpathModel:getTimes() > 0
    end,changeEvent)

    widget:addDataProxy("isOther",function()
        return ch.WarpathModel:isOpen() and ch.WarpathModel:getTimes() < 1 and not ch.WarpathModel:isIdle()
    end,changeEvent)
    
    widget:addCommond("join",function()
        ch.UIManager:cleanGamePopupLayer(true)
        ch.NetworkController:startWarpath()
    end)
end)

-- 坚守阵地首页
zzy.BindManager:addFixedBind("Guild/W_JSZD", function(widget)
    --结束引导
    if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10160 then
        ch.guide:endid(10160)
    end
    -- 每日提醒一次
    cc.UserDefault:getInstance():setStringForKey("ifOpenDefend",ch.CommonFunc:getZeroTime(os_time()))
    ch.SignModel:effectDataChangeEvent()

    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_ActivityView_8
    end)

    widget:addCommond("openIn1",function()
        if selectJSZD ~= 1 then
            ch.DefendModel.ifRankData = false
            ch.NetworkController:defendMemberRank()
        end
        selectJSZD = 1
        cclog("个人战绩排行")
    end)

    widget:addCommond("openIn2",function()
        selectJSZD = 2
        cclog("查看规则")
    end)
end)

-- 坚守阵地排行页
zzy.BindManager:addFixedBind("Guild/W_JSZDin1", function(widget)
    local rankEvent = {}
    rankEvent[ch.DefendModel.panelDataChangeEventType] = false
    
    local myData = ch.DefendModel:getMyRankData()
    widget:addDataProxy("noData",function(evt)
        return table.maxn(ch.DefendModel:getAllRankData()) < 1
    end,rankEvent)
    
    widget:addDataProxy("loadDes",function(evt)
        if ch.DefendModel.ifRankData then
            return Language.src_clickhero_view_ActivityView_20
        else
            return Language.src_clickhero_view_ActivityView_16
        end
    end,rankEvent)
    
    widget:addDataProxy("memberList",function(evt)
        local tmpData = {}
        if ch.DefendModel:getAllRankData() then
            for k,v in pairs(ch.DefendModel:getAllRankData()) do
                v.rank = k
                table.insert(tmpData,{value = v})
            end
        end
        return tmpData
    end,rankEvent)

    widget:addDataProxy("rank",function(evt)
        return myData.rank
    end,rankEvent)

    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(ch.PlayerModel:getPlayerName())
    end)

    widget:addDataProxy("r_icon",function(evt)
        if ch.PlayerModel:getPlayerGender() == 2 then
            return GameConst.PERSON_ICON[2]
        else
            return GameConst.PERSON_ICON[1]
        end
    end)

    widget:addDataProxy("p_icon",function(evt)
        return GameConfig.PartnerConfig:getData(ch.PartnerModel:getCurPartner()).icon
    end)

    widget:addDataProxy("score",function(evt)
        return ch.NumberHelper:toString(myData.score or 0)
    end,rankEvent)
end)

-- 坚守阵地成员排行单元卡片
zzy.BindManager:addCustomDataBind("Guild/W_JSZDin1unit", function(widget,data)
    local tmpData = data.value
    widget:addDataProxy("isSelf",function(evt)
        return tmpData.userId == ch.PlayerModel:getPlayerID()
    end)
    widget:addDataProxy("notSelf",function(evt)
        return tmpData.userId ~= ch.PlayerModel:getPlayerID()
    end)
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(tmpData.name)
    end)
    -- 称号图标
    widget:addDataProxy("titleIcon",function(evt)
        return ch.UserTitleModel:getTitle(tmpData.maxLevel-1,tmpData.userId).icon
    end)
    widget:addDataProxy("r_icon",function(evt)
        if tmpData.gender == 2 then
            return GameConst.PERSON_ICON[2]
        else
            return GameConst.PERSON_ICON[1]
        end
    end)

    widget:addDataProxy("p_icon",function(evt)
        return GameConfig.PartnerConfig:getData(tostring(tmpData.pet)).icon
    end)

    widget:addDataProxy("rank",function(evt)
        return tmpData.rank
    end)

    widget:addDataProxy("score",function(evt)
        return ch.NumberHelper:toString(tmpData.score or 0)
    end)

    widget:addCommond("openDetail",function()
        ch.UIManager:showGamePopup("Guild/W_Guildmemberdetail",{type = 2,value = tmpData})
    end)
end)

-- 坚守阵地规则
zzy.BindManager:addFixedBind("Guild/W_JSZDin2", function(widget)
    local timesChangeEvent = {}
    timesChangeEvent[ch.DefendModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.DefendModel.dataType.Times
    end
    widget:addDataProxy("desc",function(evt)
        return GameConst.DEFEND_PET_DESC
    end)
    
    widget:addDataProxy("isJoin",function()
        return ch.DefendModel:getTimes() < GameConst.DEFEND_DAY_MAX_COUNT
                and ch.DefendModel:getTimeCD() < 0
    end,timesChangeEvent)

    widget:addDataProxy("countNum",function(evt)
        local countNum = GameConst.DEFEND_DAY_MAX_COUNT-ch.DefendModel:getTimes()
        if countNum > 0 or ch.DefendModel:getTimeCD() > 0 then
            return ""
        else
            return Language.src_clickhero_view_ActivityView_24
        end
    end,timesChangeEvent)

    widget:addDataProxy("notJoin",function()
        return ch.DefendModel:getTimeCD() > 0
    end,timesChangeEvent)

    local cutDown
    cutDown =  function()
        widget:noticeDataChange("cdTime")
        widget:noticeDataChange("isJoin")
        widget:noticeDataChange("countNum")
        widget:noticeDataChange("notJoin")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    widget:addDataProxy("cdTime",function(evt)
        local time = ch.DefendModel:getTimeCD()
        return getTime(time)
    end)
    
    widget:addCommond("join",function()
        ch.UIManager:cleanGamePopupLayer(true)
        if ch.guide._data["guide9080"] ~= 1 then
            ch.LevelController:startDefend(true)
            ch.guide:play_guide(9080)
        else
            ch.LevelController:startDefend(false)
        end
    end)
end)

-- 精彩活动－分享
zzy.BindManager:addCustomDataBind("share/W_ShareCard", function(widget,data)
    local dotChangeEvent = {}
    dotChangeEvent[ch.ShareModel.dataChangeEventType] = false
       
    widget:addDataProxy("shareIcon",function(evt)
        return "aaui_icon/icon_wxzt.png"
    end)
    
    widget:addDataProxy("shareDesc",function(evt)
        return Language.src_clickhero_view_ActivityView_21
    end)
    widget:addDataProxy("isTag",function(evt)
        return ch.SignModel:getRedPointByType(8)
    end,dotChangeEvent)
    widget:addCommond("openShare",function()
        ch.UIManager:cleanGamePopupLayer(true)
        ch.UIManager:showGamePopup("share/W_Share")
    end)
end)
