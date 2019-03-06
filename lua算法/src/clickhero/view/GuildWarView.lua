local teamSelectedEventType = "GUILDWAR_VIEW_TEAMS_SELECTED"
local curTeamId = 0
local isOpenCityDetail

-- 公会战界面
zzy.BindManager:addFixedBind("Guild/W_NewGuild_guildwar_mainbroad", function(widget)
    local scroll = widget:getChild("scroll_map")
    local map = widget:getChild("image_map")
    scroll:setSwallowTouches(false)
    local mapSize = GameConst.GUILD_WAR_SCENE_SIZE
    local cSize = scroll:getContentSize()  
    local scrollMidPoint = cc.p(cSize.width/2,cSize.height/2)
    local minScale = cSize.width/mapSize.width
    local maxScale = GameConst.GUILD_WAR_MAP_SCALE[#GameConst.GUILD_WAR_MAP_SCALE]
    local curScale = 1
    local curDistance = 0
    local checkPoint = function(p)
        p = scroll:convertToNodeSpace(p)
        return p.x >= 0 and p.x <= cSize.width and p.y >=0 and p.y <= cSize.height
    end
    local changeScale = function(scale,p)
        local pm = map:convertToNodeSpace(p)
        local ps = scroll:convertToNodeSpace(p)
        curScale = scale
        map:setScale(curScale)
        scroll:setInnerContainerSize(cc.size(mapSize.width*curScale,mapSize.height*curScale))
        if curScale - minScale < 0.001 then
            scroll:jumpToPercentBothDirection(cc.vertex2F(0,0))
        else
            local hx = (pm.x * curScale - ps.x)/(mapSize.width *curScale - cSize.width)
            hx = hx <= 0 and 0 or (hx>1 and 1 or hx)
            local hy = ((mapSize.height - pm.y) *curScale - cSize.height + ps.y)/(mapSize.height*curScale -cSize.height)
            hy = hy <= 0 and 0 or (hy>1 and 1 or hy)
            scroll:jumpToPercentBothDirection(cc.vertex2F(hx*100,hy*100))
        end
    end
    
    local p = scroll:convertToWorldSpace(scrollMidPoint)
    changeScale(curScale,p)
    
    local stp
    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(function(touch,event)
        stp = touch[1]:getLocation()
        if #touch == 2 and checkPoint(touch[1]:getLocation()) and 
            checkPoint(touch[2]:getLocation()) then
            local point1 = touch[1]:getLocation()
            local point2 = touch[2]:getLocation()
            curDistance = math.sqrt(math.pow(point1.x - point2.x,2) + math.pow(point1.y - point2.y,2))
            scroll:setTouchEnabled(false)
        end
    end,cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(function(touch,event)
        if #touch == 2 and checkPoint(touch[1]:getLocation()) and 
            checkPoint(touch[2]:getLocation()) then
            local p1 = touch[1]:getLocation()
            local p2 = touch[2]:getLocation()
            local dis = math.sqrt(math.pow(p1.x - p2.x,2) + math.pow(p1.y - p2.y,2))
            if curDistance == 0 then
                curDistance = dis
                scroll:setTouchEnabled(false)
            else
                local scale = dis/curDistance * curScale
                curDistance = dis
                scale = scale > maxScale and maxScale or (scale < minScale and minScale or scale)
                local p = cc.p((p1.x + p2.x)/2,(p1.y + p2.y)/2)
                changeScale(scale,p)
            end
        end
    end,cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(function(touch,event)
        curDistance = 0
        local ep = touch[1]:getLocation()
        if isOpenCityDetail then
            isOpenCityDetail = false
        elseif (stp and math.abs(ep.x - stp.x) < 5 and math.abs(ep.y - stp.y)< 5) or not checkPoint(touch[1]:getLocation()) then
            if curTeamId ~= 0 then
                curTeamId = 0
                local evt = {type = teamSelectedEventType}
                zzy.EventManager:dispatch(evt)
            end
        end
        stp = nil
        scroll:setTouchEnabled(true)
        scroll:setSwallowTouches(false)
    end,cc.Handler.EVENT_TOUCHES_ENDED)
    listener:registerScriptHandler(function(touch,event)
        curDistance = 0
        local ep = touch[1]:getLocation()
        if isOpenCityDetail then
            isOpenCityDetail = false
        elseif (stp and math.abs(ep.x - stp.x) < 5 and math.abs(ep.y - stp.y)< 5) or not checkPoint(touch[1]:getLocation()) then
            if curTeamId ~= 0 then
                curTeamId = 0
                local evt = {type = teamSelectedEventType}
                zzy.EventManager:dispatch(evt)
            end
        end
        stp = nil
        scroll:setTouchEnabled(true)
        scroll:setSwallowTouches(false)
    end,cc.Handler.EVENT_TOUCHES_CANCELLED)
    local panel = widget:getChild("panel_map")
    local eventDispatcher = panel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
    
    widget:addDataProxy("scene",function(evt)
        if ch.LevelController.GameMode.guildWar == ch.LevelController.mode then
            cc.Director:getInstance():getTextureCache():addImage("res/scene/guildWar.png")
            return "res/scene/guildWar.png"
        else
           return "aaui_common/dot1.png"
        end
    end)
    
    local A01Info = ch.GuildWarModel:getHomeCityInfo("A01")
    widget:addDataProxy("cityFlagA",function(evt)
        return A01Info and GameConst.GUILD_FLAG[A01Info.f] or "aaui_mgg/guild_8.png"
    end)
    widget:addDataProxy("cityNameA",function(evt)
        return A01Info and A01Info.n or "" 
    end)
    widget:addDataProxy("cityShowA",function(evt)
        return A01Info ~= nil
    end)
    
    local B01Info = ch.GuildWarModel:getHomeCityInfo("B01")
    widget:addDataProxy("cityFlagB",function(evt)
        return B01Info and GameConst.GUILD_FLAG[B01Info.f] or "aaui_mgg/guild_8.png"
    end)
    widget:addDataProxy("cityNameB",function(evt)
        return B01Info and B01Info.n or "" 
    end)
    widget:addDataProxy("cityShowB",function(evt)
        return B01Info ~= nil
    end)
    
    local C01Info = ch.GuildWarModel:getHomeCityInfo("C01")
    widget:addDataProxy("cityFlagC",function(evt)
        return C01Info and GameConst.GUILD_FLAG[C01Info.f] or "aaui_mgg/guild_8.png"
    end)
    widget:addDataProxy("cityNameC",function(evt)
        return C01Info and C01Info.n or ""
    end)
    widget:addDataProxy("cityShowC",function(evt)
        return C01Info ~= nil
    end)
    
    local D01Info = ch.GuildWarModel:getHomeCityInfo("D01")
    widget:addDataProxy("cityFlagD",function(evt)
        return D01Info and GameConst.GUILD_FLAG[D01Info.f] or "aaui_mgg/guild_8.png"
    end)
    widget:addDataProxy("cityNameD",function(evt)
        return D01Info and D01Info.n or "" 
    end)
    widget:addDataProxy("cityShowD",function(evt)
        return D01Info ~= nil
    end)
    
    local E01Info = ch.GuildWarModel:getHomeCityInfo("E01")
    widget:addDataProxy("cityFlagE",function(evt)
        return E01Info and GameConst.GUILD_FLAG[E01Info.f] or "aaui_mgg/guild_8.png"
    end)
    widget:addDataProxy("cityNameE",function(evt)
        return E01Info and E01Info.n or "" 
    end)
    widget:addDataProxy("cityShowE",function(evt)
        return E01Info ~= nil
    end)
    
    widget:addDataProxy("guildFlag",function(evt)
        return GameConst.GUILD_FLAG[ch.GuildModel:myGuildFlag()]
    end)
    widget:addDataProxy("homeCityFlag",function(evt)
        local cid = ch.GuildWarModel:getMyHomeCityId()
        return GameConst.GUILD_WAR_HOMECITY_ICON[cid]
    end)
    widget:addDataProxy("guildName",function(evt)
        return ch.GuildModel:myGuildName()
    end)
    
    local toten = ch.GuildWarModel:getToken()
    local rTimeId
    local rTimeText = "0s"..Language.GUILD_WAR_TOTEN_RECOVER
    local startCutDown = function()
        if rTimeId then return end
    	rTimeId = widget:listen(zzy.Events.TickEventType,function(obj,evt)
            local time = ch.GuildWarModel:getTokenRecoveTime() - os_time()
            time = time < 0 and 0 or time
            local text
            if time >= 60 then
                rTimeText = string.format("%dm%s",math.floor(time/60),Language.GUILD_WAR_TOTEN_RECOVER)
            else
                rTimeText = string.format("%ds%s",math.floor(time),Language.GUILD_WAR_TOTEN_RECOVER)
            end
            widget:noticeDataChange("rTime")
    	end)
    end
    local stopCutDown = function()
        if rTimeId then
            widget:unListen(rTimeId)
            rTimeId = nil
        end
    end
    if toten < GameConst.GUILD_WAR_MAX_TOTEN then
        startCutDown()
    end
    
    widget:listen(ch.GuildWarModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.GuildWarModel.dataType.CityCount then
            widget:noticeDataChange("jhCityCount")
            widget:noticeDataChange("lnCityCount")
        elseif evt.dataType == ch.GuildWarModel.dataType.ProdNumber then
            widget:noticeDataChange("jhProdNum")
            widget:noticeDataChange("lnProdNum")
        elseif evt.dataType == ch.GuildWarModel.dataType.exploits then
            widget:noticeDataChange("myValueNum")       
        elseif evt.dataType == ch.GuildWarModel.dataType.Toten then
            toten = ch.GuildWarModel:getToken()
            widget:noticeDataChange("tokenNum")
            widget:noticeDataChange("isShowRTime")
            if toten < GameConst.GUILD_WAR_MAX_TOTEN then
                startCutDown()
            else
                stopCutDown() 
            end  
        elseif evt.dataType == ch.GuildWarModel.dataType.MapData then
            A01Info = ch.GuildWarModel:getHomeCityInfo("A01")
            B01Info = ch.GuildWarModel:getHomeCityInfo("B01")
            C01Info = ch.GuildWarModel:getHomeCityInfo("C01")
            D01Info = ch.GuildWarModel:getHomeCityInfo("D01")
            E01Info = ch.GuildWarModel:getHomeCityInfo("E01")
            widget:noticeDataChange("cityFlagA")
            widget:noticeDataChange("cityNameA")
            widget:noticeDataChange("cityShowA")
            widget:noticeDataChange("cityFlagB")
            widget:noticeDataChange("cityNameB")
            widget:noticeDataChange("cityShowB")
            widget:noticeDataChange("cityFlagC")
            widget:noticeDataChange("cityNameC")
            widget:noticeDataChange("cityShowC")
            widget:noticeDataChange("cityFlagD")
            widget:noticeDataChange("cityNameD")
            widget:noticeDataChange("cityShowD")
            widget:noticeDataChange("cityFlagE")
            widget:noticeDataChange("cityNameE")
            widget:noticeDataChange("cityShowE")

            widget:noticeDataChange("jhCityCount")
            widget:noticeDataChange("jhProdNum")
            widget:noticeDataChange("lnCityCount")
            widget:noticeDataChange("lnProdNum")
            toten = ch.GuildWarModel:getToken()
            widget:noticeDataChange("tokenNum")
            widget:noticeDataChange("isShowRTime")
            widget:noticeDataChange("myValueNum")            
            if toten < GameConst.GUILD_WAR_MAX_TOTEN then
                startCutDown()
            else
                stopCutDown() 
            end
        end
    end)
    
    widget:addDataProxy("jhCityCount",function(evt)
        return ch.GuildWarModel:getJHCityCount()
    end)
    widget:addDataProxy("jhProdNum",function(evt)
        return ch.GuildWarModel:getJHNumber()
    end)
    widget:addDataProxy("lnCityCount",function(evt)
        return ch.GuildWarModel:getLNCityCount()
    end)
    widget:addDataProxy("lnProdNum",function(evt)
        return ch.GuildWarModel:getLNNumber()
    end)
    
    widget:addDataProxy("tokenNum",function(evt)
        return string.format("%d/%d",toten,GameConst.GUILD_WAR_MAX_TOTEN)
    end)
    widget:addDataProxy("isShowRTime",function(evt)
        return toten < GameConst.GUILD_WAR_MAX_TOTEN
    end)
    widget:addDataProxy("rTime",function(evt)
        return rTimeText
    end)
    widget:addDataProxy("myValueNum",function(evt)
        return ch.GuildWarModel:getExploits()
    end)
    
    
    local curTeamHomeCityId
    
    local showA01Dot = false
    local showB01Dot = false
    local showC01Dot = false
    local showD01Dot = false
    local showE01Dot = false
    
    local setDotStatus = function()
        showA01Dot = false
        showB01Dot = false
        showC01Dot = false
        showD01Dot = false
        showE01Dot = false
        for i = 1,5 do
            local cid = ch.GuildWarModel:getTeamCity(i)
            if cid == "A01" then
                showA01Dot = true
            elseif cid == "B01" then
                showB01Dot = true
            elseif cid == "C01" then
                showC01Dot = true
            elseif cid == "D01" then
                showD01Dot = true
            elseif cid == "E01" then
                showE01Dot = true  
            end
        end
    end
    
    setDotStatus()
    
    widget:addDataProxy("showA01Dot",function(evt)
        return showA01Dot
    end)
    widget:addDataProxy("showB01Dot",function(evt)
        return showB01Dot
    end)
    widget:addDataProxy("showC01Dot",function(evt)
        return showC01Dot
    end)
    widget:addDataProxy("showD01Dot",function(evt)
        return showD01Dot
    end)
    widget:addDataProxy("showE01Dot",function(evt)
        return showE01Dot
    end)
    
    widget:listen(ch.GuildWarModel.teamStatusChangedEventType,function(obj,evt)
        if evt.dataType == ch.GuildWarModel.teamDataType.status then
            setDotStatus()
            widget:noticeDataChange("showA01Dot")
            widget:noticeDataChange("showB01Dot")
            widget:noticeDataChange("showC01Dot")
            widget:noticeDataChange("showD01Dot")
            widget:noticeDataChange("showE01Dot")
        end
    end)
    
    
    widget:listen(teamSelectedEventType,function(obj,evt)
        local oldCid = curTeamHomeCityId
        if curTeamId > 0 then
            curTeamHomeCityId = ch.GuildWarModel:getTeamCity(curTeamId)
        else
            curTeamHomeCityId = nil
        end
        if curTeamHomeCityId == oldCid then return end
        if oldCid == "A01" then
            widget:stopEffect("A01TeamEffect")
        elseif oldCid == "B01" then
            widget:stopEffect("B01TeamEffect")
        elseif oldCid == "C01" then
            widget:stopEffect("C01TeamEffect")
        elseif oldCid == "D01" then
            widget:stopEffect("D01TeamEffect")
        elseif oldCid == "E01" then
            widget:stopEffect("E01TeamEffect")
        end
        
        if curTeamHomeCityId == "A01" then
            widget:playEffect("A01TeamEffect",true)
        elseif curTeamHomeCityId == "B01" then
            widget:playEffect("B01TeamEffect",true)
        elseif curTeamHomeCityId == "C01" then
            widget:playEffect("C01TeamEffect",true)
        elseif curTeamHomeCityId == "D01" then
            widget:playEffect("D01TeamEffect",true)
        elseif curTeamHomeCityId == "E01" then
            widget:playEffect("E01TeamEffect",true)
        end
    end)
    
    local selectEffectEvent = {}
    selectEffectEvent[teamSelectedEventType] = false
    widget:addDataProxy("tips",function(evt)
        if curTeamId ~= 0 and ch.GuildWarModel:getTeamStatus(curTeamId) > 0 then
            return Language.GUILD_WAR_MAIN_TIPS[ch.GuildWarModel:getTeamStatus(curTeamId)]
        else
            return ""
        end
    end,selectEffectEvent)
    widget:addDataProxy("showTips",function(evt)
        return curTeamId ~= 0 
            and ch.GuildWarModel:getTeamStatus(curTeamId) ~= 0
            and ch.GuildWarModel:getTeamStatus(curTeamId) ~= 2
    end,selectEffectEvent)
    
    local chatEffectEvent = {}
    chatEffectEvent[ch.ChatModel.dataChangeEventType] = false
    widget:addDataProxy("chat",function(evt)
        local data = {}
        data.content = ch.ChatModel:getChatContent()
        data.count = ch.ChatModel:getUnreadCount()
        data.isShow = ch.ChatModel:getUnreadCount() > 0
        return data
    end,chatEffectEvent)
    
    widget:addCommond("openTeams",function()
        if curTeamId ~= 0 then
            curTeamId = 0
            local evt = {type = teamSelectedEventType}
            zzy.EventManager:dispatch(evt)
        end
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_myarmy",{type=1}) 
    end)
    widget:addCommond("openRank",function()
        if curTeamId ~= 0 then
            curTeamId = 0
            local evt = {type = teamSelectedEventType}
            zzy.EventManager:dispatch(evt)
        end
        ch.GuildWarController:guildWarCurRank()
    end)
    local dailyChangeEvent = {}
    dailyChangeEvent[ch.GuildWarModel.dailyPrizeEventType] = false
    widget:addDataProxy("ifShowDot",function(evt)
        if ch.GuildWarModel:getDailyExploits() > 0 then
            for i=1,4 do
                if ch.GuildWarModel:getDailyPrizeState(i) == 1 then
                    return true
                end
            end
        end
        return false
    end,dailyChangeEvent)
    widget:addCommond("openReward",function()
        if curTeamId ~= 0 then
            curTeamId = 0
            local evt = {type = teamSelectedEventType}
            zzy.EventManager:dispatch(evt)
        end
        -- 打开每日领奖
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_dailyprize")
    end)
    widget:addCommond("openNPC",function()
        if curTeamId ~= 0 then
            curTeamId = 0
            local evt = {type = teamSelectedEventType}
            zzy.EventManager:dispatch(evt)
        end
        -- 打开NPC界面
    end)
    widget:addCommond("openFightRecord",function()
        if curTeamId ~= 0 then
            curTeamId = 0
            local evt = {type = teamSelectedEventType}
            zzy.EventManager:dispatch(evt)
        end
    end)
    widget:addCommond("openHelp",function()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_instruction")
        if curTeamId ~= 0 then
            curTeamId = 0
            local evt = {type = teamSelectedEventType}
            zzy.EventManager:dispatch(evt)
        end
    end)
    widget:addCommond("openChat",function()
        ch.ChatView:getInstanse():show()
        ch.ChatModel:clearUnreadCount()
        if curTeamId ~= 0 then
            curTeamId = 0
            local evt = {type = teamSelectedEventType}
            zzy.EventManager:dispatch(evt)
        end
    end)
    
    widget:addCommond("zoomIn",function()
        if curScale == maxScale then return end
        local scale = maxScale
        for i = 1,#GameConst.GUILD_WAR_MAP_SCALE do
            if curScale < GameConst.GUILD_WAR_MAP_SCALE[i] then
                scale = GameConst.GUILD_WAR_MAP_SCALE[i]
                break
            end
        end
        local p = scroll:convertToWorldSpace(scrollMidPoint)
        changeScale(scale,p)
--        if curTeamId ~= 0 then
--            curTeamId = 0
--            local evt = {type = teamSelectedEventType}
--            zzy.EventManager:dispatch(evt)
--        end
    end)
    
    widget:addCommond("zoomOut",function()
        if curScale == minScale then return end
        local scale = minScale
        for i=#GameConst.GUILD_WAR_MAP_SCALE,1,-1 do
            if curScale > GameConst.GUILD_WAR_MAP_SCALE[i] then
                scale = GameConst.GUILD_WAR_MAP_SCALE[i]
                break
            end
        end
        local p = scroll:convertToWorldSpace(scrollMidPoint)
        changeScale(scale,p)
--        if curTeamId ~= 0 then
--            curTeamId = 0
--            local evt = {type = teamSelectedEventType}
--            zzy.EventManager:dispatch(evt)
--        end
    end)
    
    local close = widget.destory
    widget.destory = function(view,cleanView)
        ch.LevelController.mode = nil
        widget:noticeDataChange("scene")
        close(widget,cleanView)
        ch.GuildWarModel:stopRecove()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        ch.UIManager:getActiveSkillLayer():setVisible(true)
        ch.UIManager:getMainViewLayer():setVisible(true)
        ch.UIManager:getAutoFightLayer():setVisible(true)
        ch.GuildWarController:stop()
        curTeamId = 0
        isOpenCityDetail = nil
        local evt = {type = teamSelectedEventType}
        zzy.EventManager:dispatch(evt)
    end
    widget:addCommond("close",function()
        widget:destory()
        ch.LevelController:startNormal()
    end)
end)


--公会战地图节点界面
zzy.BindManager:addCustomDataBind("Guild/N_newguild_guildwar_node", function(widget,data)
    local mapConfig = GameConfig.Guild_war_mapConfig:getData(data)
    local panel = widget:getChild("panel_touch")
    panel:setSwallowTouches(false)
    local cType = math.floor(mapConfig.type_level/10)
    local cLevel = mapConfig.type_level%10
    widget:addDataProxy("icon",function(evt)
        local hid = ch.GuildWarModel:getCityHomeCityId(data) or "A00"
        return string.format("res/icon/guildwarcity/%s_%d_%s.png",GameConst.GUILD_WAR_CITY_IOCN_HEAD[cType],cLevel,GameConst.GUILD_WAR_CITY_IOCN_TAIL[hid])
    end)
    widget:addDataProxy("name",function(evt)
        return data
    end)
    local cid = ch.GuildWarModel:getCityHomeCityId(data)
    widget:listen(ch.GuildWarModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.GuildWarModel.dataType.MapData then
            cid = ch.GuildWarModel:getCityHomeCityId(data)
            widget:noticeDataChange("icon")
            widget:noticeDataChange("isOwned")
            widget:noticeDataChange("isFighting")
        end
    end)
    
    widget:listen(ch.GuildWarModel.cityStatusChangedEventType,function(obj,evt)
        if evt.id == data then
            cid = ch.GuildWarModel:getCityHomeCityId(data)
            widget:noticeDataChange("icon")
            widget:noticeDataChange("isOwned")
            widget:noticeDataChange("isFighting")
        end
    end)
    
    widget:listen(teamSelectedEventType,function(obj,evt)
        if curTeamId == 0 then
            widget:stopEffect("curTeamEffect")
        else
            if data == ch.GuildWarModel:getTeamCity(curTeamId) then
                widget:playEffect("curTeamEffect",true)
            else
                widget:stopEffect("curTeamEffect")
            end
        end
    end)
    
    widget:addDataProxy("isSeized",function(evt)
        return cid ~= nil
    end)
    
    local teamEffectEvent = {}
    teamEffectEvent[ch.GuildWarModel.teamStatusChangedEventType] = function(evt)
        return evt.dataType == ch.GuildWarModel.teamDataType.status    	
    end
    widget:addDataProxy("isOwned",function(evt)
        for i = 1,5 do
            local cid = ch.GuildWarModel:getTeamCity(i)
            if cid == data then
                return true
            end
        end
        return false
    end,teamEffectEvent)
    widget:addDataProxy("isFighting",function(evt)
        return ch.GuildWarModel:getCityStatus(data) == 3
    end)
    local tmpID = 0
    widget:addCommond("onClicked",function(obj,type)   
        if type == ccui.TouchEventType.began then
            tmpID = curTeamId
            isOpenCityDetail = true
        elseif type == ccui.TouchEventType.ended then
            local tmpData = {}
            tmpData.teamId = tmpID
            tmpData.id = data
            ch.GuildWarController:guildWarPointTS(data)
            ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_ourconquest",tmpData)
        end
    end)
end)

-- 主界面战队情况单元
zzy.BindManager:addCustomDataBind("Guild/N_newguild_guildwarteam", function(widget,data)
    local id = tonumber(data)
    widget:addDataProxy("teamName",function(evt)
        return Language.GUILD_WAR_TEAM_NAME..data
    end)
    
    local rTimeId
    local rTimeText = "0s"
    local startCutDown = function()
        if rTimeId then return end
        rTimeId = widget:listen(zzy.Events.TickEventType,function(obj,evt)
            local time = 0
            if ch.GuildWarModel:getTeamStatus(id) == 6 then
                time = ch.GuildWarModel:getTeamArrTime(id) - os_time()
            elseif ch.GuildWarModel:getTeamStatus(id) == 2 then
                time = ch.GuildWarModel:getTeamDieTime(id) - os_time()
            end
            time = time < 0 and 0 or time
            local text
            if time >= 60 then
                rTimeText = string.format("%dm",math.floor(time/60))
            else
                rTimeText = string.format("%ds",math.floor(time))
            end
            widget:noticeDataChange("cdTime")
            widget:noticeDataChange("isCd")
        end)
    end
    local stopCutDown = function()
        if rTimeId then
            widget:unListen(rTimeId)
            rTimeId = nil
        end
    end
    if ch.GuildWarModel:getTeamArrTime(id) > os_time() 
        or ch.GuildWarModel:getTeamDieTime(id) > os_time() then
        startCutDown()
    end
    
    local team = ch.GuildWarModel:getTeamMember(id)

    widget:listen(ch.GuildWarModel.teamStatusChangedEventType,function(obj,evt)
        if evt.dataType == ch.GuildWarModel.teamDataType.status then
            widget:noticeDataChange("morale")
            widget:noticeDataChange("moraleIcon")
            widget:noticeDataChange("isExciting")
            widget:noticeDataChange("isNormal")
            widget:noticeDataChange("isShowStatusIcon")
            widget:noticeDataChange("status")
            widget:noticeDataChange("isCd")
            if ch.GuildWarModel:getTeamArrTime(id) > os_time() 
                or ch.GuildWarModel:getTeamDieTime(id) > os_time() then
                startCutDown()
            else
                stopCutDown() 
            end
        elseif evt.dataType == ch.GuildWarModel.teamDataType.member 
            or evt.dataType == ch.GuildWarModel.teamDataType.tid then
            team = ch.GuildWarModel:getTeamMember(id)
            widget:noticeDataChange("isShowTeam")
            widget:noticeDataChange("teamImage")
            widget:noticeDataChange("teamFrame")
            widget:noticeDataChange("combatNum")
        elseif evt.dataType == ch.GuildWarModel.teamDataType.morale then
            widget:noticeDataChange("morale")
            widget:noticeDataChange("moraleIcon")
        end
    end)
    widget:listen(ch.GuildWarModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.GuildWarModel.dataType.MapData then
            team = ch.GuildWarModel:getTeamMember(id)
            widget:noticeDataChange("morale")
            widget:noticeDataChange("moraleIcon")
            widget:noticeDataChange("isExciting")
            widget:noticeDataChange("isNormal")
            widget:noticeDataChange("isShowStatusIcon")
            widget:noticeDataChange("status")
            widget:noticeDataChange("isCd")
            widget:noticeDataChange("isShowTeam")
            widget:noticeDataChange("teamImage")
            widget:noticeDataChange("teamFrame")
            widget:noticeDataChange("combatNum")
            if ch.GuildWarModel:getTeamArrTime(id) > os_time() 
                or ch.GuildWarModel:getTeamDieTime(id) > os_time() then
                startCutDown()
            else
                stopCutDown() 
            end
        end
    end)
    
    
    
    widget:addDataProxy("isShowStatusIcon",function(evt) -- 该状态是否显示图片
        local status = ch.GuildWarModel:getTeamStatus(id)
        return status and GameConst.GUILD_WAR_TEAM_STATUS_ICON[status] ~= nil
    end)
    
    widget:addDataProxy("status",function(evt) -- 状态图片
        local status = ch.GuildWarModel:getTeamStatus(id)
        return GameConst.GUILD_WAR_TEAM_STATUS_ICON[status] or GameConst.GUILD_WAR_TEAM_STATUS_ICON[4]
    end)
    
    widget:addDataProxy("isShowTeam",function(evt) -- 是否有队伍
        if team and team[1] then
            return true
        else
            return false
        end
    end)
    
    widget:addDataProxy("teamImage",function(evt)
        return ch.GuildWarModel:getTeamShowIcon(id)
    end)
    
    widget:addDataProxy("teamFrame",function(evt)
        return ch.GuildWarModel:getTeamShowFrame(id)
    end)
    
    widget:addDataProxy("combatNum",function(evt) -- 战力
        if team and team[1] then
            return ch.GuildWarModel:getTeamCombatNum(id)
        else
            return "--"
        end
    end)

    widget:addDataProxy("morale",function(evt)
        if team and team[1] then
            local m = ch.GuildWarModel:getTeamMorale(id)
            return string.format("%d(%d%%)",m,ch.GuildWarModel:getMoralePercent(m)) 
        else
            return "--"
        end
    end)
    widget:addDataProxy("moraleIcon",function(evt)
        local m = ch.GuildWarModel:getTeamMorale(id)
        if ch.GuildWarModel:getMoralePercent(m) < 100 then
            return "aaui_icon/icon_guildwar_anger_1.png"
        else
            return "aaui_icon/icon_guildwar_anger_2.png"
        end
    end)
    widget:addDataProxy("isExciting",function(evt)
        return ch.GuildWarModel:getTeamMorale(id) >= 100
    end)
    widget:addDataProxy("isNormal",function(evt)
        return ch.GuildWarModel:getTeamMorale(id) < 100
    end)
    
    widget:addDataProxy("isCd",function(evt)
        if ch.GuildWarModel:getTeamStatus(id) == 6 then
            return ch.GuildWarModel:getTeamArrTime(id) > os_time()
        elseif ch.GuildWarModel:getTeamStatus(id) == 2 then
            return ch.GuildWarModel:getTeamDieTime(id) > os_time()
        else
            return false
        end
    end)
    widget:addDataProxy("cdTime",function(evt)
        local text_cdTime = zzy.CocosExtra.seekNodeByName(widget, "text_cdTime")
        if text_cdTime then
            text_cdTime:setGlobalZOrder(100)
        end
        
        return rTimeText
    end)
    
    local selectEffectEvent = {}
    selectEffectEvent[teamSelectedEventType] = false
    widget:addDataProxy("isSelect",function(evt)
        return curTeamId == id
    end,selectEffectEvent)
    
    widget:addCommond("onClicked",function()
        if team and team[1] then
            curTeamId = id
        else
            curTeamId = 0   
        end
        local evt = {type = teamSelectedEventType}
        zzy.EventManager:dispatch(evt)

        local status = ch.GuildWarModel:getTeamStatus(id)
        if status == 0 then
            ch.GuildWarModel:setCurTeamSelect(id)
            ch.UIManager:showGamePopup("card/W_card_f_choose",{type=6,teamIndex=id})
        elseif status == 1 then
        elseif status == 2 then
            ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_jijieshijian",id)
        elseif status == 3 then
        elseif status == 4 then
        elseif status == 5 then
        elseif status == 6 then
        end
    end)
end)

-- 公会战我的战队界面(1主城打开，2据点打开)
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_myarmy", function(widget,data)
    widget:addDataProxy("guildFlag",function(evt)
        return GameConst.GUILD_FLAG[ch.GuildModel:myGuildFlag()]
    end)
    widget:addDataProxy("guildName",function(evt)
        return ch.GuildModel:myGuildName()
    end)
    widget:addDataProxy("guildLevel",function(evt)
        return ch.GuildModel:myGuildLevel()
    end)
    
    local toten = ch.GuildWarModel:getToken()
    local rTimeId
    local rTimeText = "0s"..Language.GUILD_WAR_TOTEN_RECOVER
    local startCutDown = function()
        if rTimeId then return end
        rTimeId = widget:listen(zzy.Events.TickEventType,function(obj,evt)
            local time = ch.GuildWarModel:getTokenRecoveTime() - os_time()
            time = time < 0 and 0 or time
            local text
            if time >= 60 then
                rTimeText = string.format("%dm%s",math.floor(time/60),Language.GUILD_WAR_TOTEN_RECOVER)
            else
                rTimeText = string.format("%ds%s",math.floor(time),Language.GUILD_WAR_TOTEN_RECOVER)
            end
            widget:noticeDataChange("hornTime")
        end)
    end
    local stopCutDown = function()
        if rTimeId then
            widget:unListen(rTimeId)
            rTimeId = nil
        end
    end
    if toten < GameConst.GUILD_WAR_MAX_TOTEN then
        startCutDown()
    end

    widget:listen(ch.GuildWarModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.GuildWarModel.dataType.Toten then
            toten = ch.GuildWarModel:getToken()
            widget:noticeDataChange("hornNum")
            widget:noticeDataChange("isShowRTime")
            if toten < GameConst.GUILD_WAR_MAX_TOTEN then
                startCutDown()
            else
                stopCutDown() 
            end  
        elseif evt.dataType == ch.GuildWarModel.dataType.MapData then
            toten = ch.GuildWarModel:getToken()
            widget:noticeDataChange("hornNum")
            widget:noticeDataChange("isShowRTime")
            if toten < GameConst.GUILD_WAR_MAX_TOTEN then
                startCutDown()
            else
                stopCutDown() 
            end
        end
    end)

    widget:addDataProxy("hornNum",function(evt)
        return string.format("%d/%d",ch.GuildWarModel:getToken(),GameConst.GUILD_WAR_MAX_TOTEN)
    end)
    widget:addDataProxy("hornTime",function(evt)
        return rTimeText
    end)
    widget:addDataProxy("isShowRTime",function(evt)
        return toten < GameConst.GUILD_WAR_MAX_TOTEN
    end)
    widget:listen(ch.GuildWarModel.teamStatusChangedEventType,function(obj,evt)
        if evt.dataType == ch.GuildWarModel.teamDataType.initList 
            or evt.dataType == ch.GuildWarModel.teamDataType.member 
            or evt.dataType == ch.GuildWarModel.teamDataType.tid then
            widget:noticeDataChange("teamList")
        end
    end)
    widget:addDataProxy("teamList",function(evt)
        local ret = {}
        for i=1,5 do
            table.insert(ret,{id=i,value=ch.GuildWarModel:getTeamMember(i),type=data.type,cid=data.cid})
        end
        return ret
    end)
end)

-- 公会战我的战队单元
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_myarmy_1", function(widget,data)
    local tmpData = data.value
    
    local rTimeId
    local rTimeText = "0s"
    local startCutDown = function()
        if rTimeId then return end
        rTimeId = widget:listen(zzy.Events.TickEventType,function(obj,evt)
            local time = 0
            if ch.GuildWarModel:getTeamStatus(data.id) == 6 then
                time = ch.GuildWarModel:getTeamArrTime(data.id) - os_time()
            elseif ch.GuildWarModel:getTeamStatus(data.id) == 2 then
                time = ch.GuildWarModel:getTeamDieTime(data.id) - os_time()
            end
            time = time < 0 and 0 or time
            local text
            if time >= 60 then
                rTimeText = string.format("%dm",math.floor(time/60))
            else
                rTimeText = string.format("%ds",math.floor(time))
            end
            widget:noticeDataChange("time")
            widget:noticeDataChange("hasTime")
            widget:noticeDataChange("state")
            widget:noticeDataChange("seat")
            widget:noticeDataChange("movement")
        end)
    end
    local stopCutDown = function()
        if rTimeId then
            widget:unListen(rTimeId)
            rTimeId = nil
        end
    end
    if ch.GuildWarModel:getTeamArrTime(data.id) > os_time() 
        or ch.GuildWarModel:getTeamDieTime(data.id) > os_time() then
        startCutDown()
    end
    
    widget:listen(ch.GuildWarModel.teamStatusChangedEventType,function(obj,evt)
        if evt.dataType == ch.GuildWarModel.teamDataType.status then
            widget:noticeDataChange("morale")
            widget:noticeDataChange("moraleNum")
            widget:noticeDataChange("powerNum")
            widget:noticeDataChange("seat")
            widget:noticeDataChange("seatName")
            widget:noticeDataChange("movement")
            widget:noticeDataChange("time")
            widget:noticeDataChange("noTeam")
            widget:noticeDataChange("hasTeam")
            widget:noticeDataChange("ifCanGo")
            widget:noticeDataChange("state")
            widget:noticeDataChange("moveTimeText")
            if ch.GuildWarModel:getTeamArrTime(data.id) > os_time() 
                or ch.GuildWarModel:getTeamDieTime(data.id) > os_time() then
                startCutDown()
            else
                stopCutDown() 
            end
        elseif evt.dataType == ch.GuildWarModel.teamDataType.morale then
            widget:noticeDataChange("morale")
            widget:noticeDataChange("moraleNum")       
        end
    end)

    widget:addDataProxy("card1",function(evt)
        if tmpData[1] and tmpData[1].id then
            return {type=1,id=tmpData[1].id,l=tmpData[1].l,talent=tmpData[1].talent,isShow = true}
        else
            return {type=1,id=50001,l=1,talent=1,isShow = false}
        end
    end)
    widget:addDataProxy("card2",function(evt)
        if tmpData[2] and tmpData[2].id then
            return {type=1,id=tmpData[2].id,l=tmpData[2].l,talent=tmpData[2].talent,isShow = true}
        else
            return {type=1,id=50001,l=1,talent=1,isShow = false}
        end
    end)
    widget:addDataProxy("card3",function(evt)
        if tmpData[3] and tmpData[3].id then
            return {type=1,id=tmpData[3].id,l=tmpData[3].l,talent=tmpData[3].talent,isShow = true}
        else
            return {type=1,id=50001,l=1,talent=1,isShow = false}
        end
    end)
    widget:addDataProxy("card4",function(evt)
        if tmpData[4] and tmpData[4].id then
            return {type=1,id=tmpData[4].id,l=tmpData[4].l,talent=tmpData[4].talent,isShow = true}
        else
            return {type=1,id=50001,l=1,talent=1,isShow = false}
        end
    end)
    widget:addDataProxy("card5",function(evt)
        if tmpData[5] and tmpData[5].id then
            return {type=1,id=tmpData[5].id,l=tmpData[5].l,talent=tmpData[5].talent,isShow = true}
        else
            return {type=1,id=50001,l=1,talent=1,isShow = false}
        end
    end)

    

    widget:addDataProxy("index",function(evt)
        return Language.GUILD_WAR_TEAM_NAME..data.id
    end)
    widget:addDataProxy("morale",function(evt)
        if ch.GuildWarModel:getMoralePercent(ch.GuildWarModel:getTeamMorale(data.id)) < 100 then
            return "aaui_icon/icon_guildwar_anger_1.png"
        else
            return "aaui_icon/icon_guildwar_anger_2.png"
        end
    end)

    widget:addDataProxy("moraleNum",function(evt)
        if tmpData and tmpData[1] then
            local m = ch.GuildWarModel:getTeamMorale(data.id)
            m = m or 0
            return string.format("%d(%d%%)",m,ch.GuildWarModel:getMoralePercent(m))
        else
            return "--"
        end
    end)
    widget:addDataProxy("powerNum",function(evt)
        if tmpData and tmpData[1] then
            return ch.GuildWarModel:getTeamCombatNum(data.id)
        else
            return "--"
        end
    end)
    widget:addDataProxy("seat",function(evt)
        if ch.GuildWarModel:getTeamStatus(data.id) == 6 then
            return Language.GUILD_WAR_TEAM_CUR_POINT_TEXT[1]
        else
            return Language.GUILD_WAR_TEAM_CUR_POINT_TEXT[2]
        end
    end)
    widget:addDataProxy("seatName",function(evt)
        return ch.GuildWarModel:getTeamCity(data.id)
    end)
    widget:addDataProxy("movement",function(evt)
        if ch.GuildWarModel:getTeamStatus(data.id) == 6 then
            return Language.GUILD_WAR_TEAM_ARRIVE_TEXT[1]
        else
            return Language.GUILD_WAR_TEAM_ARRIVE_TEXT[2]
        end
    end)
    widget:addDataProxy("time",function(evt)
        return rTimeText
    end)
    widget:addDataProxy("hasTime",function(evt)
        if ch.GuildWarModel:getTeamStatus(data.id) == 6 then
            return ch.GuildWarModel:getTeamArrTime(data.id) > os_time()
        elseif ch.GuildWarModel:getTeamStatus(data.id) == 2 then
            return ch.GuildWarModel:getTeamDieTime(data.id) > os_time()
        else
            return false
        end
    end)
    widget:addDataProxy("state",function(evt)
        local status = ch.GuildWarModel:getTeamStatus(data.id)
        return Language.GUILD_WAR_TEAM_TIPS[status] or ""
    end)
    widget:addDataProxy("noTeam",function(evt)
        if tmpData and tmpData[1] then
            return false
        else
            return true
        end
    end)
    widget:addDataProxy("hasTeam",function(evt)
        if tmpData and tmpData[1] and data.type == 2 then
            return true
        else
            return false
        end
    end)
    widget:addDataProxy("moveTimeText",function(evt)
        if data.type == 2 then
            local status = ch.GuildWarModel:getTeamStatus(data.id)
            if (status == 1 or status == 5) and ch.GuildWarModel:getTeamCity(data.id)~= data.cid then
                local way = ch.GuildWarModel:getRoutine(ch.GuildWarModel:getTeamCity(data.id),data.cid)
                if way then
                    local time = (#way-1) * GameConst.GUILD_WAR_TEAM_MOVE_TIME
                    local moveTime = "0s"
                    if time >= 60 then
                        moveTime = string.format("%dm",math.floor(time/60))
                    else
                        moveTime = string.format("%ds",math.floor(time))
                    end
                    return string.format(Language.GUILD_WAR_PATH_TIME_TIP,moveTime)
                else
                    return Language.GUILD_WAR_PATH_INEXISTENCE_TIP
                end
            end
            return ""
        end
        return ""
    end)
    
    widget:addDataProxy("ifCanGo",function(evt)
        local status = ch.GuildWarModel:getTeamStatus(data.id)
        return (status == 1 or status == 5) and ch.GuildWarModel:getTeamCity(data.id)~= data.cid 
    end)
    widget:addCommond("setTeam",function()
        ch.GuildWarModel:setCurTeamSelect(data.id)
        ch.UIManager:showGamePopup("card/W_card_f_choose",{type=6,teamIndex=data.id})
    end)
    widget:addCommond("go",function()
        if ch.GuildWarModel:getTeamCity(data.id)== data.cid then
            cclog("起始点一样")
            return 
        end
        local way = ch.GuildWarModel:getRoutine(ch.GuildWarModel:getTeamCity(data.id),data.cid)
        if way then
            local str = ""
            for k,v in ipairs(way) do
                str = str .. v .. "_"
            end
            str = string.sub(str,1,-2)
            ch.GuildWarController:guildWarGo(ch.GuildWarModel:getTeamTid(data.id),str)
        else
            ch.UIManager:showUpTips(Language.GUILD_WAR_PATH_INEXISTENCE_TIP)
        end       
    end)
end)

-- 查看援军->据点详情
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_conquest_2", function(widget, cid)

    local gid = ch.GuildWarModel:getCityGuildId(cid)
    local status = ch.GuildWarModel:getCityStatus(cid)
    local cof = GameConfig.Guild_war_mapConfig:getData(cid)
    
    widget:listen(ch.GuildWarModel.arrivingTeamsEventType,function(obj,evt)
        if evt.id == cid then
            gid = ch.GuildWarModel:getCityGuildId(cid)
            status = ch.GuildWarModel:getCityStatus(cid)
            widget:noticeDataChange("guild_logo")
            widget:noticeDataChange("guild_name")
            widget:noticeDataChange("Lv_value")
            widget:noticeDataChange("isShowGuildLogoAndLevel")
            widget:noticeDataChange("team_num_left")
            widget:noticeDataChange("team_num_right")
            widget:noticeDataChange("teams_left")
            widget:noticeDataChange("teams_right")
        end
    end)
    
    
    --无工会占领时的显示性
    widget:addDataProxy("isShowGuildLogoAndLevel",function(evt)
        return gid ~= ""
    end)
    --工会图标
    widget:addDataProxy("guild_logo",function(evt)
        if gid ~= "" then
            return GameConst.GUILD_FLAG[ch.GuildWarModel:getGuildFlag(gid)]
        else
            return GameConst.GUILD_FLAG[8]
        end
    end)
    --工会名
    widget:addDataProxy("guild_name",function(evt)
        if gid ~= "" then
            return ch.GuildWarModel:getGuildName(gid)
        else
            return Language.GUILD_WAR_NO_CAPTURE
        end
    end)
    --工会等级
    widget:addDataProxy("Lv_value",function(evt)
        if gid ~= "" then
            return ch.GuildWarModel:getGuildLevel(gid)
        else
            return 0
        end
    end)
    --祭坛等级
    widget:addDataProxy("num_JT_level",function(evt)
        return cof.type_level%10 .. Language.MSG_LEVEL
    end)
    --祭坛名字
    local ct = math.floor(cof.type_level/10)
    widget:addDataProxy("jitan_name",function(evt)
        return Language.GUILD_WAR_CITY_TYPE_NAME[ct].name
    end)
    --祭坛产品
    widget:addDataProxy("jitan_production",function(evt)
        return Language.GUILD_WAR_CITY_TYPE_NAME[ct].proName
    end)
    --n/小时
    widget:addDataProxy("num_perhour",function(evt)
        return string.format("%d/%s",cof.productAmount,Language.MSG_HOUR)
    end)
    
    local cutDown
    cutDown =  function()
            widget:noticeDataChange("Text_time")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()    

    widget:addDataProxy("Text_time",function(evt)
        local time = 0
        time = ch.GuildWarModel:getCityPTime() - os_time()
        time = math.floor(time)
        time = time < 0 and 0 or time
        local min = math.floor(time/60)
        local second = time - min *60
        return string.format("%02d:%02d",min,second)
    end)
    
    widget:addDataProxy("isOther",function(evt)
        return math.floor(cof.type_level/10) ~= 1
    end)
    widget:addDataProxy("isMorale",function(evt)
        return math.floor(cof.type_level/10) == 1
    end)
    widget:addDataProxy("morale_desc",function(evt)
            local color = Language.GUILD_WAR_TEAM_COLOR_NAME[string.sub(cof.id,1,1)] or ""
            local num = cof.productAmount/cof.term * 3600
            return string.format(Language.GUILD_WAR_MORALE_DESC,color,num)
        end)

        --攻方数量
        widget:addDataProxy("team_num_left",function(evt)
            local team = ch.GuildWarModel:getArrivingTeamsAttack()
            return #team
        end)
        --守方数量
        widget:addDataProxy("team_num_right",function(evt)
            local team = ch.GuildWarModel:getArrivingTeamsDefend()
            return #team
        end)
    --影子战队按钮
    widget:addCommond("btn_team",function()
--        ch.GuildWarController:guildWarShadowCall(cid)
    end)
    --派遣战队按钮
        widget:addCommond("btn_send",function()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_myarmy",{type=2,cid=cid}) 
    end)
    --攻方列表(状态6行军中)
    widget:addDataProxy("teams_left",function(evt)
        local teams = ch.GuildWarModel:getArrivingTeamsAttack()
        for k,v in pairs(teams) do
            v.s = 6
        end
        return teams
    end)
    --守方列表(状态6行军中)
    widget:addDataProxy("teams_right",function(evt)
        local teams =  ch.GuildWarModel:getArrivingTeamsDefend()
        for k,v in pairs(teams) do
            v.s = 6
        end
        return teams
    end)
    
    ch.GuildWarModel:setCityDetailPageOpened(true)
    --关闭
    widget:addCommond("close",function()
        ch.GuildWarController:guildWarPointTS(cid)
        widget:destory()
        ch.GuildWarModel:setCityDetailPageOpened(false)
        ch.GuildWarModel:clearArrivingTeams()
    end)
end)


local totalRound = 10
local roundTime = 3
local totalFightTime = totalRound*roundTime
local attIntervalTime = 0.3
local hpEaseTime = 0.2

local getTeamStatus = function(k)
    if k == 1 then
        return 3
    elseif k== 2 or k == 3 then
        return 4
    else
        return 5
    end
end

-- 查看战斗
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_conquest_1", function(widget,data)
    local cof = GameConfig.Guild_war_mapConfig:getData(data)

    local gid = ch.GuildWarModel:getCityGuildId(data)
    if os_time() - ch.GuildWarModel:getFightTime() < totalFightTime then
        gid = ch.GuildWarModel:getFightDefender().gid
    end

    local status = ch.GuildWarModel:getCityStatus(data)
    local attacker = ch.GuildWarModel:getFightAttacker()
    local defender = ch.GuildWarModel:getFightDefender()


    widget:addDataProxy("guildName",function(evt)
        if gid ~= "" then
            return ch.GuildWarModel:getGuildName(gid)
        else
            return Language.GUILD_WAR_NO_CAPTURE
        end
    end)
    widget:addDataProxy("guildLevel",function(evt)
        if gid ~= "" then
            return ch.GuildWarModel:getGuildLevel(gid)
        else
            return 0
        end 
    end)
    widget:addDataProxy("guildFlag",function(evt)
        if gid ~= "" then
            return GameConst.GUILD_FLAG[ch.GuildWarModel:getGuildFlag(gid)]
        else
            return GameConst.GUILD_FLAG[8]
        end
    end)
    widget:addDataProxy("isShowGuildLevel",function(evt)
        return gid ~= ""
    end)

    widget:addDataProxy("isCityFree",function(evt)
        return gid == ""
    end)

    widget:addDataProxy("nLevel",function(evt)
        return cof.type_level%10 .. Language.MSG_LEVEL
    end)
    local ct = math.floor(cof.type_level/10)
    widget:addDataProxy("nName",function(evt)
        return Language.GUILD_WAR_CITY_TYPE_NAME[ct].name
    end)
    widget:addDataProxy("nProName",function(evt)
        return Language.GUILD_WAR_CITY_TYPE_NAME[ct].proName
    end)
    widget:addDataProxy("nProNum",function(evt)
        return string.format("%d/%s",cof.productAmount,Language.MSG_HOUR)
    end)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("rTime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()    

    widget:addDataProxy("rTime",function(evt)
        local time = 0
        time = ch.GuildWarModel:getCityPTime() - os_time()
        time = math.floor(time)
        time = time < 0 and 0 or time
        local min = math.floor(time/60)
        local second = time - min *60
        return string.format("%02d:%02d",min,second)
    end)
    
    widget:addDataProxy("isOther",function(evt)
        return math.floor(cof.type_level/10) ~= 1
    end)
    widget:addDataProxy("isMorale",function(evt)
        return math.floor(cof.type_level/10) == 1
    end)
    widget:addDataProxy("morale_desc",function(evt)
        local color = Language.GUILD_WAR_TEAM_COLOR_NAME[string.sub(cof.id,1,1)] or ""
        local num = cof.productAmount/cof.term * 3600
        return string.format(Language.GUILD_WAR_MORALE_DESC,color,num)
    end)
    
    widget:addDataProxy("attName",function(evt)
        return attacker and attacker.n or ""
    end)
    widget:addDataProxy("attCombatNum",function(evt)
        return attacker and attacker.cn or 0
    end)
    widget:addDataProxy("attMorale",function(evt)
        local m = attacker and attacker.mn or 0
        return string.format("%d(%d%%)",m,ch.GuildWarModel:getMoralePercent(m))
    end)
    widget:addDataProxy("attMoraleIcon",function(evt)
        local m = attacker and attacker.mn or 0
        if ch.GuildWarModel:getMoralePercent(m) < 100 then
            return "aaui_icon/icon_guildwar_anger_1.png"
        else
            return "aaui_icon/icon_guildwar_anger_2.png"
        end
    end)
    widget:addDataProxy("attHomeCityFlag",function(evt)
        local cid = attacker and ch.GuildWarModel:getGuildHomeCityId(attacker.gid) or "A01"
        return GameConst.GUILD_WAR_HOMECITY_ICON[cid]
    end)
    widget:addDataProxy("attTeamName",function(evt)
        if attacker and attacker.pid == ch.PlayerModel:getPlayerID() then
            if attacker.is == 1 then
                return Language.GUILD_WAR_SHADOW_TEAM
            else
                local index = ch.GuildWarModel:getTeamIndexByTID(attacker.tid)
                return Language.GUILD_WAR_TEAM_NAME..index
            end
        else
            return ""
        end
    end)
    widget:addDataProxy("attShowName",function(evt)
        return attacker and attacker.pid == ch.PlayerModel:getPlayerID()
    end)
    widget:addDataProxy("attTeamIcon",function(evt)
        if attacker then
            return GameConfig.CardConfig:getData(attacker.mid).mini
        else
            return GameConfig.CardConfig:getData(50001).mini
        end
    end)
    widget:addDataProxy("attTeamFrame",function(evt)
        if attacker then
            return GameConfig.CarduplevelConfig:getData(attacker.ml).iconFrame
        else
            return GameConfig.CarduplevelConfig:getData(1).iconFrame
        end
    end)
    
    widget:addDataProxy("defName",function(evt)
        return defender and defender.n or ""
    end)
    widget:addDataProxy("defCombatNum",function(evt)
        return defender and defender.cn or 0
    end)
    widget:addDataProxy("defMorale",function(evt)
        local m = defender and defender.mn or 0
        return string.format("%d(%d%%)",m,ch.GuildWarModel:getMoralePercent(m))
    end)
    widget:addDataProxy("defMoraleIcon",function(evt)
        local m = defender and defender.mn or 0
        if ch.GuildWarModel:getMoralePercent(m) < 100 then
            return "aaui_icon/icon_guildwar_anger_1.png"
        else
            return "aaui_icon/icon_guildwar_anger_2.png"
        end
    end)
    widget:addDataProxy("defHomeCityFlag",function(evt)
        local cid = defender and ch.GuildWarModel:getGuildHomeCityId(defender.gid) or "A01"
        return GameConst.GUILD_WAR_HOMECITY_ICON[cid]
    end)
    widget:addDataProxy("defTeamName",function(evt)
        if defender and defender.pid == ch.PlayerModel:getPlayerID() then
            if defender.is == 1 then
                return Language.GUILD_WAR_SHADOW_TEAM
            else
                local index = ch.GuildWarModel:getTeamIndexByTID(defender.tid)
                return Language.GUILD_WAR_TEAM_NAME..index
            end
        else
            return ""
        end
    end)
    widget:addDataProxy("defShowName",function(evt)
        return defender and defender.pid == ch.PlayerModel:getPlayerID()
    end)
    widget:addDataProxy("defTeamIcon",function(evt)
        if defender then
            return GameConfig.CardConfig:getData(defender.mid).mini
        else
            return GameConfig.CardConfig:getData(50001).mini
        end
    end)
    widget:addDataProxy("defTeamFrame",function(evt)
        if defender then
            return GameConfig.CarduplevelConfig:getData(defender.ml).iconFrame
        else
            return GameConfig.CarduplevelConfig:getData(1).iconFrame
        end
    end)
        
    local changeGuild = function()
        local newGid = ch.GuildWarModel:getCityGuildId(data)
        if newGid ~= gid then
            gid = newGid
            widget:noticeDataChange("guildName")
            widget:noticeDataChange("guildLevel")
            widget:noticeDataChange("guildFlag")
            widget:noticeDataChange("isShowGuildLevel")
            widget:noticeDataChange("cityFlag")
            widget:noticeDataChange("isCityFree")
        end
    end
    
    local curAttTeamId
    local curDefTeamId
    local fightStatus = -1 --0无战斗，1入场中， 2入场完成， 3战斗中，4等待下场战斗
    
    widget:addDataProxy("isShowAttacker",function(evt)
        return curAttTeamId ~= nil
    end)
    widget:addDataProxy("isShowDefender",function(evt)
        return curDefTeamId ~= nil
    end)
    
    -- 战斗表现
    local attWidget = widget:getChild("pro_team_att")
    local defWidget = widget:getChild("pro_team_def")
    local attDefaultPos = cc.p(attWidget:getPosition())
    local defDefaultPos = cc.p(defWidget:getPosition())
    local attListView = widget:getChild("ListView_att")
    local defListView = widget:getChild("ListView_def")
    ch.RoleResManager:loadEffect("tx_kapaizhandouxiaoguo")
    attWidget.effect = ccs.Armature:create("tx_kapaizhandouxiaoguo")
    attWidget.effect:setVisible(false)
    attWidget:addChild(attWidget.effect)
    defWidget.effect = ccs.Armature:create("tx_kapaizhandouxiaoguo")
    defWidget.effect:setVisible(false)
    defWidget:addChild(defWidget.effect)
    local bombEffect = ccs.Armature:create("tx_kapaizhandouxiaoguo")
    bombEffect:setVisible(false)
    widget:addChild(bombEffect)
    local waitEffect
    local lastAttackeRole
    local roleAttack = function(attRole,isDead,onAttack,onComp)
        lastAttackeRole = attRole
        local defRole = attWidget
        local x = -1
        local attRoleEndP = defDefaultPos
        local defRoleEndP = attDefaultPos
        if attRole == attWidget then
            defRole = defWidget
            x = 1
            attRoleEndP = attDefaultPos
            defRoleEndP = defDefaultPos
        end
        local sAct = cc.ScaleTo:create(0.15,1.3)
        local dAct = cc.DelayTime:create(0.15)
        attRole:setLocalZOrder(1)
        defRole:setLocalZOrder(0)
        attRole.effect:setVisible(true)
        attRole.effect:getAnimation():play("xiaokafaguangchuxian",-1,0)
--        local onScaleCompleted = cc.CallFunc:create(function()
--            attRole.effect:getAnimation():play("xiaokafaguang",-1,1)
--        end)
        local seq = cc.Sequence:create(sAct,dAct,cc.CallFunc:create(function()
            attRole.effect:setVisible(false)
            local rAct = cc.RotateTo:create(0.13,45*x)
            local mAct = cc.MoveBy:create(0.13,cc.p(180*x,0))
            local seq = cc.Sequence:create(mAct,cc.CallFunc:create(function()
                --碰撞特效
                bombEffect:setVisible(true)
                bombEffect:getAnimation():play("bomb",-1,0)
                if attRole == attWidget then
                    bombEffect:setPosition(415,685)
                else
                    bombEffect:setPosition(245,685)
                end
                if onAttack then onAttack() end
                local rbAct = cc.RotateTo:create(0.3,0)
                local mbAct = cc.EaseExponentialOut:create(cc.MoveTo:create(0.3,attRoleEndP))
                local sbAct = cc.ScaleTo:create(0.15,1)
                local seq1 = cc.Sequence:create(mbAct,sbAct,cc.CallFunc:create(function()
                    defRole.effect:setVisible(false)
                    bombEffect:setVisible(false)
                    attRole:setLocalZOrder(0)
                    if onComp then onComp() end
                end))
                attRole:runAction(rbAct)
                attRole:runAction(seq1)
                defRole.effect:getAnimation():play("shouji",-1,0)
                defRole.effect:setVisible(true)
                
                if isDead then
                    local dmAct = cc.MoveBy:create(0.3,cc.p(260*x,180))
                    local seq2 = cc.Sequence:create(cc.RotateBy:create(0.3,2160),cc.CallFunc:create(function()
                        defRole:setRotation(0)
                    end))
                    defRole:runAction(dmAct)
                    defRole:runAction(seq2)
                else
                    defRole:setRotation(15*x)
                    defRole:setPosition(defRoleEndP.x+ x*100,defRoleEndP.y+100)
                    local dmAct = cc.EaseBackOut:create(cc.MoveTo:create(0.2,defRoleEndP))
                    local drAct = cc.RotateTo:create(0.2,0)
                    defRole:runAction(dmAct)
                    defRole:runAction(drAct)
                end
            end))
            attRole:runAction(rAct)
            attRole:runAction(seq)
        end))
        attRole:runAction(seq)
    end
    
    local roleEntrance = function(isAttacker,onTeamEntrance,onCompleted)
        widget:setTimeOut(0,function() -- 延迟一帧以保证listView被刷新
            local role = isAttacker and attWidget or defWidget
            role:setOpacity(0)
            local p = cc.p(role:getPosition())
            role:setPosition(p.x,p.y+120)
            local listView = isAttacker and attListView or defListView
            local item = listView:getItem(0)
            if not item then return end
            local size = item:getContentSize()
            local anc = item:getAnchorPoint()
            local sp = item:convertToWorldSpace(cc.p(size.width*anc.x,size.height*anc.y))
            local np = widget:convertToNodeSpace(sp)
            local rt = item:clone()
            rt:setCascadeOpacityEnabled(true)
            item:setVisible(false)
            rt:setPosition(np)
            widget:addChild(rt)
            local team = listView:getItems()
            local tCount = team and #team or 0
            if tCount < 4 then
                for i=1,4-tCount do
                    local ly = ccui.Layout:create()
                    ly:setContentSize(size)
                    listView:insertCustomItem(ly,tCount + i-1)
                end
            end
            local seq = cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(0,180)),cc.CallFunc:create(function()
                listView:doLayout()
                local percent = size.height * 100/(listView:getInnerContainerSize().height - listView:getContentSize().height)
                listView:scrollToPercentVertical(percent,0.15,false)
                widget:setTimeOut(0.15,function()
                    rt:removeFromParent()
                    if tCount < 4 then
                        for i = 1,4-tCount do
                            listView:removeItem(4 - i)
                        end
                    end
                    if onTeamEntrance then onTeamEntrance(isAttacker) end
                    listView:jumpToPercentVertical(0)
                    local moveBy = cc.MoveTo:create(0.2,p)
                    local seq = cc.Sequence:create(cc.FadeIn:create(0.2),cc.CallFunc:create(function()
                        if onCompleted then onCompleted(isAttacker) end
                    end))
                    role:runAction(moveBy)
                    role:runAction(seq)
                end)
            end))
            rt:runAction(seq)
            rt:runAction(cc.FadeOut:create(0.3))
        end)
    end
    
    local curRound = -1
    local curAttHp = 0
    local curDefHp = 0
    local curShowAttHp = 0
    local curShowDefHp = 0
    local attHpCompletedTime
    local defHpCompletedTime
    local offensiveTime
    
    local fightTime = ch.GuildWarModel:getFightTime()
    
    local rId
    local requestTime
   
    local lastRequestTime
    local startRequestInfo = function()
        local team = ch.GuildWarModel:getFightAttactTeams()
        if team and team[1] then
            local curTime = os_time()
            if curTime - fightTime > 60 then -- 一分钟一场，但是服务器轮询不一定1分钟整发生战斗
                requestTime = curTime + 6
            else
                requestTime = fightTime + 66
            end
            if lastRequestTime and requestTime - lastRequestTime < 6 then
                requestTime = lastRequestTime + 6
            end
            if not rId then
                rId = widget:listen(zzy.Events.TickEventType,function(obj,evt)
                    if os_time() > requestTime then
                        lastRequestTime = requestTime
                        widget:unListen(rId)
                        rId = nil
                        ch.GuildWarController:requestFightInfo(data)
                    end
                end)
            end
        elseif rId then
            widget:unListen(rId)
            rId = nil
        end
    end
    
    local initHp = function(round)
    	curAttHp = attacker.shp + (round - 1)*(attacker.ehp-attacker.shp)/totalRound
        curDefHp = defender.shp + (round - 1)*(defender.ehp-defender.shp)/totalRound
        curShowAttHp = curAttHp * 100/attacker.thp
        curShowDefHp = curDefHp * 100/defender.thp
    end
    
    local updateFightStatusOnEnded = function()
        local aTeam = ch.GuildWarModel:getFightAttactTeams()
        if aTeam and aTeam[1] then
            fightStatus = 4
            if attacker and aTeam[1].tid == attacker.tid then
                curAttTeamId = attacker.tid
            else
                curAttTeamId = nil
            end
            local dTeam = ch.GuildWarModel:getFightDefendTeams()
            if dTeam and dTeam[1] and defender and dTeam[1].tid == defender.tid then
                curDefTeamId = defender.tid
            else
                curDefTeamId = nil
            end
        else
            curDefTeamId = nil
            curAttTeamId = nil
            fightStatus = 0
        end
    end

    local onTeamEntranced = function(isAttacker)
        fightStatus = 2
        if isAttacker then
            curAttTeamId = attacker.tid
            widget:noticeDataChange("attTeamsCount")
            widget:noticeDataChange("attTeams")
            widget:noticeDataChange("isShowAttacker")
        else
            curDefTeamId = defender.tid
            widget:noticeDataChange("defTeamsCount")
            widget:noticeDataChange("defTeams")
            widget:noticeDataChange("isShowDefender")
        end
    end
    local onEntranceCompleted = function()
        local t = os_clock() + 0.3
        attHpCompletedTime = t
        defHpCompletedTime = t
        offensiveTime = t
        fightStatus = 3
    end
    
    local updateFightStatus = function()
        local time = os_time() - fightTime
        if time < 8 then -- 有入场
            fightStatus = 1
        else
            if time < totalFightTime then
                fightStatus = 3
                curDefTeamId = defender.tid
                curAttTeamId = attacker.tid 
            else
                updateFightStatusOnEnded()
            end
        end
    end
    
    local showWaitEffect = function()
        if not waitEffect then
            ch.RoleResManager:loadEffect("tx_dengdaizhandou")
            waitEffect = ccs.Armature:create("tx_dengdaizhandou")
            waitEffect:setPosition(320,665)
            widget:addChild(waitEffect)
        end
        waitEffect:setVisible(true)
        waitEffect:getAnimation():play("chuxian",-1,0)
    end
    
    local startFight = function()
        attWidget:setPosition(attDefaultPos.x,attDefaultPos.y)
        defWidget:setPosition(defDefaultPos.x,defDefaultPos.y)
        if fightStatus == 0 then
            if waitEffect then
                waitEffect:setVisible(false)
            end
        elseif fightStatus == 1 then -- 有入场
            curRound = 1
            initHp(1)
            curShowAttHp = 0
            curShowDefHp = 0
            if curDefTeamId ~= defender.tid then
                if curAttTeamId == attacker.tid then
                    roleEntrance(false,onTeamEntranced,onEntranceCompleted)
                else
                    roleEntrance(false,onTeamEntranced,nil)
                end                
            end
            if curAttTeamId ~= attacker.tid then
                roleEntrance(true,onTeamEntranced,onEntranceCompleted)
            end
            if waitEffect then
                waitEffect:setVisible(false)
            end
        elseif fightStatus == 3 then
            curRound = math.floor((os_time() - fightTime)/roundTime)
            initHp(curRound)
            offensiveTime = os_clock()
            if waitEffect then
                waitEffect:setVisible(false)
            end
        elseif fightStatus == 4 then
            showWaitEffect()
        end
        widget:noticeDataChange("isShowAttacker")
        widget:noticeDataChange("isShowDefender")
        widget:noticeDataChange("attHp")
        widget:noticeDataChange("defHp")
    end
    
    updateFightStatus()
    
    widget:setTimeOut(0.4,startFight)
    
    startRequestInfo()
    
    if fightStatus == 0 or fightStatus == 4 then
        if attacker then
            curShowAttHp = attacker.ehp *100/attacker.thp
        end
        if defender then
            curShowDefHp = defender.ehp *100/defender.thp
        end
    end
    
    local refreshPage = function()
        widget:noticeDataChange("attTeamsCount")
        widget:noticeDataChange("attTeams")
        widget:noticeDataChange("defTeamsCount")
        widget:noticeDataChange("defTeams")
        widget:noticeDataChange("isShowAttacker")
        widget:noticeDataChange("isShowDefender")
        widget:noticeDataChange("isIdle")
        changeGuild()
    end
    
    local onFightEnd = function()
        offensiveTime = nil
        lastAttackeRole = nil
        updateFightStatusOnEnded()
        if curDefTeamId then
            defender.mn = defender.mn > GameConst.GUILD_WAR_MORALE_CONSUME and defender.mn - GameConst.GUILD_WAR_MORALE_CONSUME or 0
            widget:noticeDataChange("defMorale")
            widget:noticeDataChange("defMoraleIcon")
        elseif curAttTeamId then
            attacker.mn = attacker.mn > GameConst.GUILD_WAR_MORALE_CONSUME and attacker.mn - GameConst.GUILD_WAR_MORALE_CONSUME or 0
            widget:noticeDataChange("attMorale")
            widget:noticeDataChange("attMoraleIcon")
        end
        if ch.GuildWarModel:getFightResult() == 0 then --攻方胜利
            if attacker.gid == ch.GuildWarModel:getCityGuildId(data) then --换了所有权
                widget:playEffect("seizeCityEffect",false,function()
                    widget:playEffect("fullScreenEffect",false,function()
                        if fightStatus == 4 then
                            showWaitEffect()
                        end
                    end)
                    widget:setTimeOut(0.67,refreshPage)
                end)
        else
            widget:playEffect("defFailureEffect",false)
            widget:playEffect("attVictoryBehindEffect",false)
                widget:playEffect("attVictoryFrontEffect",false,function()
                    refreshPage()
                    showWaitEffect()
                end)
            end
        else
            if fightStatus == 0 then  -- 守方真正胜利
                widget:playEffect("defendCityEffect",false,function()
                    refreshPage()
                end)
            else
                widget:playEffect("attFailureEffect",false)
                widget:playEffect("defVictoryBehindEffect",false)
                widget:playEffect("defVictoryFrontEffect",false,function()
                    refreshPage()
                    showWaitEffect()
                end)
            end
        end
    end
    
    widget:listen(zzy.Events.TickEventType,function(obj,evt)
        local now = os_clock()
        if offensiveTime and now > offensiveTime then --角色出手攻击
            offensiveTime = nil
            local isDead = curRound == totalRound
            if lastAttackeRole == defWidget then --进攻方攻击
                roleAttack(attWidget,isDead, function()
                    defHpCompletedTime = os_clock() + hpEaseTime
                    curDefHp = defender.shp + curRound*(defender.ehp-defender.shp)/totalRound
                end,function()
                    if isDead then
                        onFightEnd()
                    else
                        offensiveTime = os_clock() + attIntervalTime
                        curRound = curRound + 1
                    end
                end)
            else -- 防守方
                local isDead = false
                if curRound == totalRound then
                    isDead = ch.GuildWarModel:getFightResult() == 1
                end
                roleAttack(defWidget,isDead,function()
                    attHpCompletedTime = os_clock() + hpEaseTime
                    curAttHp = attacker.shp + curRound *(attacker.ehp-attacker.shp)/totalRound
                end,function()
                	if isDead then
                        onFightEnd()
                	else
                        offensiveTime = os_clock() + attIntervalTime
                	end
                end)
            end
        end
        if attHpCompletedTime then
            local posHp = curAttHp*100/attacker.thp
            if now > attHpCompletedTime then
                attHpCompletedTime = nil
                curShowAttHp = posHp
            else
                local sign = posHp <= curShowAttHp and 1 or -1
                curShowAttHp = curShowAttHp+(posHp - curShowAttHp)/30/(attHpCompletedTime -now)
                local newSign = posHp <= curShowAttHp and 1 or -1
                if sign ~= newSign then
                    curShowAttHp = posHp
                end
            end
            widget:noticeDataChange("attHp")
        end
        if defHpCompletedTime then
            local posHp = curDefHp*100/defender.thp
            if now > defHpCompletedTime then
                defHpCompletedTime = nil
                curShowDefHp = posHp
            else
                local sign = posHp <= curShowDefHp and 1 or -1
                curShowDefHp = curShowDefHp+(posHp- curShowDefHp)/30/(defHpCompletedTime -now)
                local newSign = posHp <= curShowDefHp and 1 or -1
                if sign ~= newSign then
                    curShowDefHp = posHp
                end
            end
            widget:noticeDataChange("defHp")
        end
    end)
    

    widget:listen(ch.GuildWarModel.cityStatusChangedEventType,function(obj,evt)
        if evt.id == data then
            local oldStatus = status
            status = ch.GuildWarModel:getCityStatus(data)
            if not (oldStatus == 3 and status == 2) then --不是战斗完成变成占领
                ch.GuildWarController:requestFightInfo(data)
            end
        end
    end)
    
    widget:listen(ch.GuildWarModel.fightDataChangedEventType,function(obj,evt)
        if evt.dataType == ch.GuildWarModel.fightDataType.fightInfo then
            local oldTime = fightTime
            fightTime = ch.GuildWarModel:getFightTime()
            if math.abs(oldTime - fightTime) > 0.0001 and fightTime > 0 then  --不是同一场战斗且有有战斗数据
                attacker = ch.GuildWarModel:getFightAttacker()
                defender = ch.GuildWarModel:getFightDefender()
                updateFightStatus()
                widget:noticeDataChange("attName")
                widget:noticeDataChange("attCombatNum")
                widget:noticeDataChange("attMorale")
                widget:noticeDataChange("attMoraleIcon")
                widget:noticeDataChange("attHomeCityFlag")
                widget:noticeDataChange("attTeamName")
                widget:noticeDataChange("attShowName")
                widget:noticeDataChange("attTeamIcon")
                widget:noticeDataChange("attTeamFrame")
                widget:noticeDataChange("defName")
                widget:noticeDataChange("defCombatNum")
                widget:noticeDataChange("defMorale")
                widget:noticeDataChange("defMoraleIcon")
                widget:noticeDataChange("defHomeCityFlag")
                widget:noticeDataChange("defTeamName")
                widget:noticeDataChange("defShowName")
                widget:noticeDataChange("defTeamIcon")
                widget:noticeDataChange("defTeamFrame")
                if fightStatus == 4 then
                    changeGuild()
                end
                startFight()
                widget:noticeDataChange("attTeamsCount")
                widget:noticeDataChange("attTeams")
                widget:noticeDataChange("defTeamsCount")
                widget:noticeDataChange("defTeams")
                widget:noticeDataChange("isIdle")
                widget:noticeDataChange("isFighting")
            else  -- 不发生战斗公会归属也可能发生变化比如没有防守方
                if gid ~= ch.GuildWarModel:getCityGuildId(data) then
                    attacker = nil
                    defender = nil
                    if waitEffect then
                        waitEffect:setVisible(false)
                    end
                    updateFightStatusOnEnded()
                    widget:playEffect("seizeCityEffect",false,function()
                        widget:playEffect("fullScreenEffect",false,function()
                            if fightStatus == 4 then
                                showWaitEffect()
                            end
                        end)
                        widget:setTimeOut(0.67,refreshPage)
                    end)
                else
                    widget:noticeDataChange("attTeamsCount") -- 需要放到战斗后面
                    widget:noticeDataChange("attTeams")
                    widget:noticeDataChange("defTeamsCount")
                    widget:noticeDataChange("defTeams")
                end
            end
            
            startRequestInfo()
        elseif evt.dataType == ch.GuildWarModel.fightDataType.shadowInfo then
            if fightStatus == 1 or fightStatus == 2 or fightStatus == 3 then
                if evt.shadowTeam.pft == 1 then
                    widget:noticeDataChange("attTeamsCount")
                    widget:noticeDataChange("attTeams")
                elseif evt.shadowTeam.pft == 2 then
                    widget:noticeDataChange("defTeamsCount")
                    widget:noticeDataChange("defTeams")
                end
            elseif fightStatus == 0 or fightStatus == 4 then
                if evt.shadowTeam.aft == 1 then
                    widget:noticeDataChange("attTeamsCount")
                    widget:noticeDataChange("attTeams")
                elseif evt.shadowTeam.aft == 2 then
                    widget:noticeDataChange("defTeamsCount")
                    widget:noticeDataChange("defTeams")
                end
            end
        end
    end)
     
    widget:addDataProxy("attHp",function(evt)
        return curShowAttHp
    end)
    widget:addDataProxy("defHp",function(evt)
        return curShowDefHp
    end)
    
    widget:addDataProxy("attTeamsCount",function(evt)
        if fightStatus == -1 then return 0 end
        local count = 0
        local ts
        if fightStatus>=1 and fightStatus <= 3 then
            ts = ch.GuildWarModel:getFightPreAttactTeams()
        else
            ts = ch.GuildWarModel:getFightAttactTeams()
        end
        if ts and ts[1] then
            count = #ts
            if curAttTeamId then
                count = count -1
            end
        end
        return count
    end)

    widget:addDataProxy("defTeamsCount",function(evt)
        if fightStatus == -1 then return 0 end
        local count = 0
        local ts
        if fightStatus>=1 and fightStatus <= 3 then
            ts = ch.GuildWarModel:getFightPreDefendTeams()
        else
            ts = ch.GuildWarModel:getFightDefendTeams()
        end
        if ts and ts[1] then
            count = #ts
            if curDefTeamId then
                count = count -1
            end
        end
        return count
    end)

    widget:addDataProxy("attTeams",function(evt)
        if fightStatus == -1 then return {} end
        local teams = {}
        local ts
        if fightStatus>=1 and fightStatus <= 3 then
            ts = ch.GuildWarModel:getFightPreAttactTeams()
        else
            ts = ch.GuildWarModel:getFightAttactTeams()
        end
        if ts and ts[1] then
            local si = 2
            if not curAttTeamId then
                si = 1
            end
            for i=si,#ts do
                ts[i].s = getTeamStatus(i)
                table.insert(teams,ts[i])
            end
        end
        return teams
    end)

    widget:addDataProxy("defTeams",function(evt)
        if fightStatus == -1 then return {} end
        local teams = {}
        local ts
        if fightStatus>=1 and fightStatus <= 3 then
            ts = ch.GuildWarModel:getFightPreDefendTeams()
        else
            ts = ch.GuildWarModel:getFightDefendTeams()
        end
        if ts and ts[1] then
            local si = 2
            if not curDefTeamId then
                si = 1
            end
            for i=si,#ts do
                local at = ch.GuildWarModel:getFightAttactTeams()
                if at and at[1] then
                    ts[i].s = getTeamStatus(i)
                else    
                    ts[i].s = getTeamStatus(4)
                end
                table.insert(teams,ts[i])
            end
        end
        return teams
    end)
    
    widget:addDataProxy("isIdle",function(evt)
        return fightStatus == 0
    end)
    widget:addDataProxy("isFighting",function(evt)
        return fightStatus ~= 0
    end)
    
    widget:addDataProxy("cityFlag",function(evt)
        local cid = "A01"
        if gid ~= "" then
            cid = ch.GuildWarModel:getGuildHomeCityId(gid)
        end
        return GameConst.GUILD_WAR_HOMECITY_BIG_ICON[cid]
    end)
    widget:addDataProxy("idleBG",function(evt)
        return "res/icon/guildwar_battle_back_1.png"
    end)
    
    ch.GuildWarModel:setFightPageCid(data)
    local close = widget.destory
    widget.destory = function(view,cleanView)
        close(widget,cleanView)
        ch.GuildWarModel:setFightPageCid(nil)
        ch.GuildWarModel:clearFightInfo()
        ch.RoleResManager:releaseEffect("tx_kapaizhandouxiaoguo")
        if waitEffect then
            ch.RoleResManager:releaseEffect("tx_dengdaizhandou")
        end
    end
    widget:addCommond("close",function()
        ch.GuildWarController:guildWarPointTS(data)
        widget:destory()
    end)
    
    local getPlayerTeamId = function(pid,teams)
        if teams then
            for k,v in ipairs(teams) do
                if pid == v.pid and v.is == 0 then
                    return v.tid
                end
            end
        end
    end
    
    widget:addCommond("openShadowTeam",function()
        local num = ch.GuildWarModel:getShadowCallNum()
        if num < GameConst.GUILD_WAR_SHADOW_MAX_COUNT then
            local tid = nil
            local teams = ch.GuildWarModel:getFightAttactTeams()
            local pid = ch.PlayerModel:getPlayerID()
            tid = getPlayerTeamId(pid,teams)
            if not tid then
                teams = ch.GuildWarModel:getFightDefendTeams()
                tid = getPlayerTeamId(pid,teams)
            end
            if tid then
                if num < GameConst.GUILD_WAR_SHADOW_FREE_COUNT then
                    local text = string.format(Language.GUILD_WAR_SHADOW_FREE_TIPS,GameConst.GUILD_WAR_SHADOW_FREE_COUNT-num,GameConst.GUILD_WAR_SHADOW_FREE_COUNT)
                    ch.UIManager:showMsgBox(2,true,text,function()
                        ch.GuildWarController:guildWarShadowCall(data)
                    end) 
                else
                    local price = ch.GuildWarModel:callShadowPrice(num+1)
                    local num1 = GameConst.GUILD_WAR_SHADOW_MAX_COUNT-num
                    local num2 = GameConst.GUILD_WAR_SHADOW_MAX_COUNT-GameConst.GUILD_WAR_SHADOW_FREE_COUNT
                    local text = string.format(Language.GUILD_WAR_SHADOW_DIAMOND_TIPS,price,num1,num2)
                    ch.UIManager:showMsgBox(2,true,text,function()
                        if ch.MoneyModel:getDiamond() >= price then
                            ch.GuildWarController:guildWarShadowCall(data)
                        else
                            ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
                        end
                    end)
                end
            else
                ch.UIManager:showUpTips(Language.GUILD_WAR_SHADOW_TEAM_TIPS[2])
            end
        else
            ch.UIManager:showMsgBox(1,true,Language.GUILD_WAR_SHADOW_TEAM_TIPS[3])
        end
    end)
    widget:addCommond("sendTeam",function()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_myarmy",{type=2,cid=data}) 
    end)
end)

-- 进攻方队伍
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_conquest_3", function(widget,data)
    widget:addDataProxy("name",function(evt)
        return data.n
    end)
    widget:addDataProxy("combatNum",function(evt)
        return data.cn
    end)
    widget:addDataProxy("morale",function(evt)
        return string.format("%d(%d%%)",data.mn,ch.GuildWarModel:getMoralePercent(data.mn))
    end)
    widget:addDataProxy("moraleIcon",function(evt)
        if ch.GuildWarModel:getMoralePercent(data.mn) < 100 then
            return "aaui_icon/icon_guildwar_anger_1.png"
        else
            return "aaui_icon/icon_guildwar_anger_2.png"
        end
    end)
    widget:addDataProxy("homeCityFlag",function(evt)
        return GameConst.GUILD_WAR_HOMECITY_ICON[ch.GuildWarModel:getGuildHomeCityId(data.gid)]
    end)
    widget:addDataProxy("icon",function(evt)
        return GameConfig.CardConfig:getData(data.mid).mini
    end)
    widget:addDataProxy("frame",function(evt)
        return GameConfig.CarduplevelConfig:getData(data.ml).iconFrame
    end)
    widget:addDataProxy("status",function(evt)
        return GameConst.GUILD_WAR_TEAM_STATUS_ICON[data.s] or GameConst.GUILD_WAR_TEAM_STATUS_ICON[4]
    end)
    widget:addDataProxy("isShowStatus",function(evt)
        return GameConst.GUILD_WAR_TEAM_STATUS_ICON[data.s] ~= nil
    end)
    widget:addDataProxy("isShadow",function(evt)
        return data.is == 1
    end)
    widget:addDataProxy("isNPC",function(evt)
        return data.is == 2
    end)
    widget:addDataProxy("isShowTime",function(evt)
        return data.s == 6
    end)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    if data.s == 6 then
        cutDown()
    end

    widget:addDataProxy("time",function(evt)
        if not data.atm then
            return ""
        end
        local timeText = ""
        local time = 0
        time = data.atm - os_time()
        time = math.floor(time)
        time = time < 0 and 0 or time
        if time == 0 then
            timeText = Language.GUILD_WAR_TEAM_ARRIVE_TEXT[3]
        else
            if time >= 60 then
                timeText = string.format("%dm",math.floor(time/60))
            else
                timeText = string.format("%ds",math.floor(time))
            end
        end
        return timeText
    end)
end)

-- 防守方队伍
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_conquest_4", function(widget,data)
    widget:addDataProxy("name",function(evt)
        return data.n
    end)
    widget:addDataProxy("combatNum",function(evt)
        return data.cn
    end)
    widget:addDataProxy("morale",function(evt)
        return string.format("%d(%d%%)",data.mn,ch.GuildWarModel:getMoralePercent(data.mn))
    end)
    widget:addDataProxy("moraleIcon",function(evt)
        if ch.GuildWarModel:getMoralePercent(data.mn) < 100 then
            return "aaui_icon/icon_guildwar_anger_1.png"
        else
            return "aaui_icon/icon_guildwar_anger_2.png"
        end
    end)
    widget:addDataProxy("homeCityFlag",function(evt)
        return GameConst.GUILD_WAR_HOMECITY_ICON[ch.GuildWarModel:getGuildHomeCityId(data.gid)]
    end)
    widget:addDataProxy("icon",function(evt)
        return GameConfig.CardConfig:getData(data.mid).mini
    end)
    widget:addDataProxy("frame",function(evt)
        return GameConfig.CarduplevelConfig:getData(data.ml).iconFrame
    end)
    widget:addDataProxy("status",function(evt)
        return GameConst.GUILD_WAR_TEAM_STATUS_ICON[data.s] or GameConst.GUILD_WAR_TEAM_STATUS_ICON[4]
    end)
    widget:addDataProxy("isShowStatus",function(evt)
        return GameConst.GUILD_WAR_TEAM_STATUS_ICON[data.s] ~= nil
    end)
    widget:addDataProxy("isShadow",function(evt)
        return data.is == 1
    end)
    widget:addDataProxy("isNPC",function(evt)
        return data.is == 2
    end)
    widget:addDataProxy("isShowTime",function(evt)
        return data.s == 6
    end)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("time")
        widget:setTimeOut(1,cutDown)
    end
    if data.s == 6 then
        cutDown()
    end

    widget:addDataProxy("time",function(evt)
        if not data.atm then
            return ""
        end
        local timeText = ""
        local time = 0
        time = data.atm - os_time()
        time = math.floor(time)
        time = time < 0 and 0 or time
        if time == 0 then
            timeText = Language.GUILD_WAR_TEAM_ARRIVE_TEXT[3]
        else
            if time >= 60 then
                timeText = string.format("%dm",math.floor(time/60))
            else
                timeText = string.format("%ds",math.floor(time))
            end
        end
        return timeText
    end)
end)

-- 据点详情（队伍数量）
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_ourconquest", function(widget,data)
    local gid = ch.GuildWarModel:getCityGuildId(data.id)
    local status = ch.GuildWarModel:getCityStatus(data.id)
    local cof = GameConfig.Guild_war_mapConfig:getData(data.id)

    widget:listen(ch.GuildWarModel.cityStatusChangedEventType,function(obj,evt)
        if evt.id == data.id then
            gid = ch.GuildWarModel:getCityGuildId(data.id)
            status = ch.GuildWarModel:getCityStatus(data.id)
            widget:noticeDataChange("guildName")
            widget:noticeDataChange("guildLevel")
            widget:noticeDataChange("guildFlag")
            widget:noticeDataChange("isShowGuildLevel")
            widget:noticeDataChange("Num_Attacker_team")
            widget:noticeDataChange("Num_Attacker_reinforcements")
            widget:noticeDataChange("Num_Defender_team")
            widget:noticeDataChange("Num_Defender_reinforcements")
        end
    end)

    widget:addDataProxy("guildFlag",function(evt)
        if gid ~= "" then
            return GameConst.GUILD_FLAG[ch.GuildWarModel:getGuildFlag(gid)]
        else
            return GameConst.GUILD_FLAG[8]
        end
    end)
    widget:addDataProxy("guildName",function(evt)
        if gid ~= "" then
            return ch.GuildWarModel:getGuildName(gid)
        else
            return Language.GUILD_WAR_NO_CAPTURE
        end
    end)
    widget:addDataProxy("guildLevel",function(evt)
        if gid ~= "" then
            return ch.GuildWarModel:getGuildLevel(gid)
        else
            return 0
        end
    end)
    widget:addDataProxy("isShowGuildLevel",function(evt)
        return gid ~= ""
    end) 
    widget:addDataProxy("nLevel",function(evt)
        return cof.type_level%10 .. Language.MSG_LEVEL
    end)
    local ct = math.floor(cof.type_level/10)
    widget:addDataProxy("nName",function(evt)
        return Language.GUILD_WAR_CITY_TYPE_NAME[ct].name
    end)
    widget:addDataProxy("nProName",function(evt)
        return Language.GUILD_WAR_CITY_TYPE_NAME[ct].proName
    end)
    widget:addDataProxy("nProIcon",function(evt)
        return GameConst.GUILD_WAR_CITY_TYPE_ICON[ct]
    end)
    widget:addDataProxy("nProNum",function(evt)
        return string.format("%d/%s",cof.productAmount,Language.MSG_HOUR)
    end)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("rTime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()    
    
    widget:addDataProxy("rTime",function(evt)
        local time = 0
        time = ch.GuildWarModel:getCityPTime() - os_time()
        time = math.floor(time)
        time = time < 0 and 0 or time
        if ch.GuildWarModel:getCityPTime()>0 and time == 0 then
            ch.GuildWarModel:setCityPTime(os_time()+3600)
        end
        local min = math.floor(time/60)
        local second = time - min *60
        return string.format("%02d:%02d",min,second)
    end)
    
    widget:addDataProxy("isOther",function(evt)
        return math.floor(cof.type_level/10) ~= 1
    end)
    widget:addDataProxy("isMorale",function(evt)
        return math.floor(cof.type_level/10) == 1
    end)
    widget:addDataProxy("morale_desc",function(evt)
        local color = Language.GUILD_WAR_TEAM_COLOR_NAME[string.sub(cof.id,1,1)] or ""
        local num = cof.productAmount/cof.term * 3600
        return string.format(Language.GUILD_WAR_MORALE_DESC,color,num)
    end)
    
    widget:addDataProxy("ifCanGo",function(evt)
        if data.teamId and data.teamId ~= 0 then
            local status = ch.GuildWarModel:getTeamStatus(data.teamId)
            return (status == 1 or status == 5) and ch.GuildWarModel:getTeamCity(data.teamId)~= data.id
        else
            return false
        end
    end)
    
    widget:addDataProxy("ifSelect",function(evt)
        return data.teamId and data.teamId ~= 0
    end)
    widget:addDataProxy("isNoSelect",function(evt)
        return not data.teamId or data.teamId == 0
    end)
    
    widget:addDataProxy("Num_Attacker_team",function(evt)
        return ch.GuildWarModel:getCityAttactTeams().fNum or 0
    end)
    widget:addDataProxy("Num_Attacker_reinforcements",function(evt)
        return ch.GuildWarModel:getCityAttactTeams().aidNum or 0
    end)
    widget:addDataProxy("Num_Defender_team",function(evt)
        return ch.GuildWarModel:getCityDefendTeams().fNum or 0
    end)
    widget:addDataProxy("Num_Defender_reinforcements",function(evt)
        return ch.GuildWarModel:getCityDefendTeams().aidNum or 0
    end)

    widget:addCommond("Button_CheckReinforcements",function()
        ch.GuildWarController:cityDetailFromCheckReinforcements(data.id)
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_conquest_2",data.id)
    end)
    widget:addCommond("Button_CheckBattle",function()
        ch.GuildWarController:requestFightInfo(data.id)
    end)
    widget:addCommond("Button_GoFight",function()
        if ch.GuildWarModel:getTeamCity(data.teamId)== data.id then
            cclog("起始点一样")
            return 
        end
        local way = ch.GuildWarModel:getRoutine(ch.GuildWarModel:getTeamCity(data.teamId),data.id)
        if way then
            local str = ""
            for k,v in ipairs(way) do
                str = str .. v .. "_"
            end
            str = string.sub(str,1,-2)
            ch.GuildWarController:guildWarGo(ch.GuildWarModel:getTeamTid(data.teamId),str)        
            widget:destory()
            if curTeamId ~= 0 then
                curTeamId = 0
                local evt = {type = teamSelectedEventType}
                zzy.EventManager:dispatch(evt)
            end
        else
            ch.UIManager:showUpTips(Language.GUILD_WAR_PATH_INEXISTENCE_TIP)
        end
    end)
    
    widget:addCommond("openTeams",function()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_myarmy",{type=2,cid=data.id})
        widget:destory()
    end)
    widget:addCommond("close",function()
        if curTeamId ~= 0 then
            curTeamId = 0
            local evt = {type = teamSelectedEventType}
            zzy.EventManager:dispatch(evt)
        end
        widget:destory()
    end)
end)


-- 召唤影子战队
zzy.BindManager:addFixedBind("Guild/W_NewGuild_guildwar_shadowarmy", function(widget)
    local id = 1
    widget:addDataProxy("teamName",function(evt)
        return Language.GUILD_WAR_TEAM_NAME..id
    end)
    widget:addDataProxy("teamImage",function(evt)
        return ch.GuildWarModel:getTeamShowIcon(id)
    end)
    widget:addDataProxy("teamFrame",function(evt)
        return ch.GuildWarModel:getTeamShowFrame(id)
    end)

    widget:addDataProxy("price",function(evt)
        return 100
    end)
    widget:addDataProxy("freeCount",function(evt)
        return 5
    end)
    widget:addDataProxy("isFree",function(evt)
        return true
    end)
    widget:addDataProxy("noFree",function(evt)
        return false
    end)
    widget:addDataProxy("ifCanCall",function(evt)
        return true
    end)
    widget:addCommond("call",function()
        cclog("影子战队")
        widget:destory()
    end)
end)

-- 战利品
zzy.BindManager:addFixedBind("Guild/W_NewGuild_guildwar_prize", function(widget)
    local stateChangeEvent = {}
    stateChangeEvent[ch.GuildWarModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.GuildWarModel.dataType.reward
    end
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    
    local tmpData = ch.GuildWarModel:getGuildWarRewardPanel()
    widget:addDataProxy("num_YingLing",function(evt)
        return tmpData.lnValue
    end)

    widget:addDataProxy("num_JingHua",function(evt)
        return tmpData.jhValue
    end)
    widget:addDataProxy("PlayerName",function(evt)
        return tmpData.first.name
    end)
    widget:addDataProxy("title_icon",function(evt)
        return ch.UserTitleModel:getTitle(tmpData.first.l-1,tmpData.first.id).icon
    end)
    widget:addDataProxy("title_name",function(evt)
        return ch.UserTitleModel:getTitle(tmpData.first.l-1,tmpData.first.id).name
    end)
    widget:addDataProxy("num_Reward",function(evt)
        return tmpData.first.value
    end)
    widget:addDataProxy("num_MyRank",function(evt)
        return tmpData.myRank
    end)
    widget:addDataProxy("num_MyReward",function(evt)
        return tmpData.myValue
    end)
    widget:addDataProxy("reward_YingLing",function(evt)
        local num = ch.GuildWarModel:getSpiritNum(tmpData.lnValue,tmpData.myRank,tmpData.myValue)
        return string.format("%s%d", Language.MSG_TIMES_SIGN, num)
    end)

    widget:addDataProxy("reward_JingHua",function(evt)
        local num = ch.GuildWarModel:getJingHuaPrize(tmpData.jhValue, tmpData.myRank,tmpData.myValue)
        return string.format("%s%d", Language.MSG_TIMES_SIGN, num)
    end)
    widget:addCommond("close",function()
        widget:destory()
    end)

    widget:addDataProxy("diamondPrice1",function(evt)
        return GameConst.GUILD_WAR_REWARD_PRICE
    end)
    widget:addDataProxy("diamondPrice2",function(evt)
        return GameConst.GUILD_WAR_REWARD_PRICE
    end)
    
    widget:addDataProxy("Visible_Btn_YingLing",function(evt)
        return ch.GuildWarModel:getRewardInfo().ylNum == 0
    end,stateChangeEvent)
    widget:addDataProxy("Visible_Btn_JingHua",function(evt)
        return ch.GuildWarModel:getRewardInfo().jhNum == 0
    end,stateChangeEvent)
    widget:addDataProxy("Visible_Btn_diamond_1",function(evt)
        return false
--        return ch.GuildWarModel:getRewardInfo().ylNum == 1
    end,stateChangeEvent)
    widget:addDataProxy("Visible_Btn_diamond_2",function(evt)
        return false
--        return ch.GuildWarModel:getRewardInfo().jhNum == 1
    end,stateChangeEvent)
    widget:addDataProxy("ifCanBuy1",function(evt)
--        return ch.MoneyModel:getDiamond() >= GameConst.GUILD_WAR_REWARD_PRICE
        return false
    end,moneyChangeEvent)
    widget:addDataProxy("ifCanBuy2",function(evt)
--        return ch.MoneyModel:getDiamond() >= GameConst.GUILD_WAR_REWARD_PRICE
        return false
    end,moneyChangeEvent)
    widget:addDataProxy("ifCanGet1",function(evt)
        if tmpData.myRank > 0 then
            local num = ch.GuildWarModel:getSpiritNum(tmpData.lnValue,tmpData.myRank)
            return num > 0
        else
            return false
        end
    end)
    widget:addDataProxy("ifCanGet2",function(evt)
        local num = ch.GuildWarModel:getJingHuaPrize(tmpData.jhValue, tmpData.myRank)
        return num > 0
    end)
    
    --0钻石1免费
    widget:addCommond("Button_Get_YingLing",function(widget,arg)
        ch.GuildWarController:guildWarGetReward(1,tonumber(arg))
    end)
    widget:addCommond("Button_Get_JingHua",function(widget,arg)
        ch.GuildWarController:guildWarGetReward(2,tonumber(arg))
    end)
    
    widget:addCommond("openYL",function()
        ch.GuildWarController:guildWarRank()
    end)
    widget:addCommond("openJH",function()
        --ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_prize_creamdata")
        ch.GuildWarController:guildWarRank_JH()
    end)    
end)


-- 战功排行榜 1奖励排行2战功排行
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_top", function(widget,data)
    local tmpData = {}
    if data == 1 or data == 3 then
        tmpData = ch.GuildWarModel:getGuildWarRewardPanel()
    elseif data == 2 then
        tmpData = ch.GuildWarModel:getGuildWarCurRank()
    end
    widget:addDataProxy("myRank",function(evt)
        return tmpData.myRank
    end)
    widget:addDataProxy("harmText",function(evt)
        return Language.GUILD_WAR_RANK_TEXT[2][data]
    end)
    widget:addDataProxy("myHarm",function(evt)
        local num = 0
        if data == 1 then
            if tmpData.myRank > 0 then
                num = ch.GuildWarModel:getSpiritNum(tmpData.lnValue,tmpData.myRank)
            end
        elseif data == 3 then
            if tmpData.myRank > 0 then
                num = ch.GuildWarModel:getJingHuaPrize(tmpData.jhValue, tmpData.myRank)
            end
        elseif data == 2 then
            num = tmpData.myValue
        end
        return num
    end)
    widget:addDataProxy("rankList",function(evt)
        local items = {}
        local tmpTable = {}
        if data == 1 or data == 3 then
            tmpTable = ch.GuildWarModel:getGuildWarRank()
        elseif data == 2 then
            tmpTable = tmpData.pl
        end
        for k,v in ipairs(tmpTable) do
            table.insert(items,{rank=k,type=data,value=v})
        end
        return items
    end)    
end)

-- 战功排行榜单元
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_top_unit", function(widget,data)
    widget:addDataProxy("name",function(evt)
        return data.value.n
    end)
    widget:addDataProxy("rankImg",function(evt)
        if data.rank < 4 then
            return GameConst.RANKLIST_ICON[data.rank]
        else
            local backGroud = zzy.CocosExtra.seekNodeByName(widget,"img_rank")
            backGroud:setVisible(false)
            return "aaui_common/dot1.png"
        end
    end)
    widget:addDataProxy("harmText",function(evt)
        return Language.GUILD_WAR_RANK_TEXT[1][data.type]
    end)
    widget:addDataProxy("rankNum",function(evt)
        return data.rank
    end)
    -- 自己的底板特殊标记
    widget:addDataProxy("dbImage",function(evt)
        if ch.PlayerModel:getPlayerID() == data.value.id then
            return "aaui_diban/db_itemrank_my.png"
        else
            return "aaui_diban/db_itemrank.png"
        end
    end) 
    -- 称号图标
    widget:addDataProxy("titleIcon",function(evt)
        return ch.UserTitleModel:getTitle(data.value.l-1,data.value.id).icon
    end)
    widget:addDataProxy("harm",function(evt)
        local num = 0
        if data.type == 1 then
            if data.rank > 0 then
                local tmpData = ch.GuildWarModel:getGuildWarRewardPanel()
                num = ch.GuildWarModel:getSpiritNum(tmpData.lnValue, data.rank, data.value.num)
            end
        elseif data.type == 3 then
            if data.rank > 0 then
                local tmpData = ch.GuildWarModel:getGuildWarRewardPanel()
                num = ch.GuildWarModel:getJingHuaPrize(tmpData.jhValue, data.rank, data.value.num)
            end
        elseif data.type == 2 then
            num = data.value.score
        end
        return num
    end)
end)

-- 公会战奖励获得详情
zzy.BindManager:addFixedBind("Guild/W_NewGuild_guildwar_prize_creamdata", function(widget)
    widget:addDataProxy("list",function(evt)
        local tmpTable = {}
        for k,v in ipairs(GameConst.GUILD_WAR_JINGHUA_PRIZE) do
            table.insert(tmpTable,{chips=v[1],jh=v[2]})
        end
        return tmpTable
    end)
end)

-- 公会战奖励获得单元
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_prize_creamdata_1",function(widget,data)
    widget:addDataProxy("chipsNum",function(evt)
        return data.chips
    end) 
    widget:addDataProxy("jhNum",function(evt)
        return data.jh
    end)
    widget:addDataProxy("isMine",function(evt)
        local tmpData = ch.GuildWarModel:getGuildWarRewardPanel()
        return data.jh == ch.GuildWarModel:getJingHuaPrize(tmpData.jhValue, tmpData.myRank)
    end)
end)


-- 清除战队集结状态
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_jijieshijian", function(widget,data)
    local curTeamIndex=data --当前战队的index
    local EventTimeID   --当前集合倒计时
    local cutDownTime=0 --当前集合的倒计时，默认为0
    local rTimeText = "0s"  --显示当前集合时间的text
    local stopCutDown = function()
        if EventTimeID  then
            widget:unListen(EventTimeID)
            EventTimeID = nil
        end
    end
    
    --倒计时方法
    local startCutDown = function()
        if EventTimeID then return end
        --倒计时方法注册
        EventTimeID = widget:listen(zzy.Events.TickEventType,function(obj,evt)
            local nPreTime=cutDownTime
            cutDownTime= ch.GuildWarModel:getTeamDieTime(curTeamIndex) - os_time()
                --倒计时时间判断最新的与之前的时间是否一致,以秒为单位
--            if((nPreTime-cutDownTime)>1) then
                cutDownTime = cutDownTime < 0 and 0 or cutDownTime
                if cutDownTime >= 60 then
                    rTimeText = string.format("%dm",math.floor(cutDownTime/60))
                else
                    rTimeText = string.format("%ds",math.floor(cutDownTime))
                end
                widget:noticeDataChange("cdTime")
                widget:noticeDataChange("diamondPrice")
                widget:noticeDataChange("ifDiamond")
                if cutDownTime <= 0 or ch.GuildWarModel:getTeamStatus(curTeamIndex) == 1 then
                    stopCutDown()
                    widget:destory()
                end
--            end
        end)
    end
    --在界面加载打开的时候开始倒计时
    startCutDown()
    
    widget:addDataProxy("cdTime",function(evt)
        return rTimeText
    end)
    --号角花费一次一个
    widget:addDataProxy("tokenNum",function(evt)
        return ch.GuildWarModel:getToken()
    end)
    --钻石花费，五分钟一个（和当前战队的时间有关）
    widget:addDataProxy("diamondCost",function(evt)
        return string.format("%d/%dm",GameConst.GUILD_WAR_CLEANCD_PERIOD_TOKENPRICE,GameConst.GUILD_WAR_CLEANCD_PERIOD/60)
    end)
    
    widget:addDataProxy("tokenPrice",function(evt)
        return GameConst.GUILD_WAR_CLEANCD_TOKENPRICE
    end)
    widget:addDataProxy("diamondPrice",function(evt)
        local diffTime = math.ceil(cutDownTime/GameConst.GUILD_WAR_CLEANCD_PERIOD)
        local nCostNum = diffTime*GameConst.GUILD_WAR_CLEANCD_PERIOD_TOKENPRICE
            nCostNum=(nCostNum<=0 and GameConst.GUILD_WAR_CLEANCD_PERIOD_TOKENPRICE) or nCostNum
        return nCostNum
    end)
    
    widget:addDataProxy("ifToken",function(evt)
        return ch.GuildWarModel:getToken()>=GameConst.GUILD_WAR_CLEANCD_TOKENPRICE
    end)
    widget:addDataProxy("ifDiamond",function(evt)
        local diffTime = math.ceil(cutDownTime/GameConst.GUILD_WAR_CLEANCD_PERIOD)
        local nCostNum = diffTime*GameConst.GUILD_WAR_CLEANCD_PERIOD_TOKENPRICE
            nCostNum=(nCostNum<=0 and GameConst.GUILD_WAR_CLEANCD_PERIOD_TOKENPRICE) or nCostNum
        return ch.GuildWarModel:getToken()<GameConst.GUILD_WAR_CLEANCD_TOKENPRICE and ch.MoneyModel:getDiamond()>=nCostNum
    end)
    
    
    -- 0为钻石 ，1为号角
    widget:addCommond("clean",function(widget,arg)
        local nCostNum
        if arg == "0" then
            local diffTime = math.ceil(cutDownTime/GameConst.GUILD_WAR_CLEANCD_PERIOD)
            nCostNum = diffTime*GameConst.GUILD_WAR_CLEANCD_PERIOD_TOKENPRICE
            nCostNum=(nCostNum<=0 and GameConst.GUILD_WAR_CLEANCD_PERIOD_TOKENPRICE) or nCostNum
        elseif arg == "1" then
            nCostNum=GameConst.GUILD_WAR_CLEANCD_TOKENPRICE
        end
        --发送清除时间协议
        ch.GuildWarController:sendMsgGatherCD(ch.GuildWarModel:getTeamTid(curTeamIndex),tonumber(arg),nCostNum)
    end)
    
    
   
    --停止倒计时，并且更新cd时间,并且关闭窗口。
    widget:listen(ch.GuildWarModel.ged_gatherCDSuccessEventType,function(obj,evt)
        stopCutDown()
        widget:destory()
    end)
end)

-- 公会战战功日常奖励
zzy.BindManager:addFixedBind("Guild/W_NewGuild_guildwar_dailyprize", function(widget)
    local dailyChangeEvent = {}
    dailyChangeEvent[ch.GuildWarModel.dailyPrizeEventType] = false
    
    widget:addDataProxy("ifCanGet",function(evt)
        for i=1,4 do
            if ch.GuildWarModel:getDailyPrizeState(i) == 1 then
                return true
            end
        end
        return false
    end,dailyChangeEvent)
    widget:addDataProxy("progress",function(evt)
        local max = GameConst.GUILD_WAR_SCORE_DAY_PRIZE[4].score
        return 100*ch.GuildWarModel:getDailyExploits()/max
    end,dailyChangeEvent)
    widget:addDataProxy("myDayExploits",function(evt)
        return ch.GuildWarModel:getDailyExploits()
    end,dailyChangeEvent)
    widget:addDataProxy("num1",function(evt)
        return GameConst.GUILD_WAR_SCORE_DAY_PRIZE[1].reward[1].num
    end)
    widget:addDataProxy("num2",function(evt)
        return GameConst.GUILD_WAR_SCORE_DAY_PRIZE[2].reward[1].num
    end)
    widget:addDataProxy("num3",function(evt)
        return GameConst.GUILD_WAR_SCORE_DAY_PRIZE[3].reward[1].num
    end)
    widget:addDataProxy("num4",function(evt)
        return GameConst.GUILD_WAR_SCORE_DAY_PRIZE[4].reward[1].num
    end)
    widget:addDataProxy("full_1",function(evt)
        return ch.GuildWarModel:getDailyPrizeState(1) == 1
    end,dailyChangeEvent)
    widget:addDataProxy("full_2",function(evt)
        return ch.GuildWarModel:getDailyPrizeState(2) == 1
    end,dailyChangeEvent)
    widget:addDataProxy("full_3",function(evt)
        return ch.GuildWarModel:getDailyPrizeState(3) == 1
    end,dailyChangeEvent)
    widget:addDataProxy("full_4",function(evt)
        return ch.GuildWarModel:getDailyPrizeState(4) == 1
    end,dailyChangeEvent)
    widget:addDataProxy("get_1",function(evt)
        return ch.GuildWarModel:getDailyPrizeState(1) == 2
    end,dailyChangeEvent)
    widget:addDataProxy("get_2",function(evt)
        return ch.GuildWarModel:getDailyPrizeState(2) == 2
    end,dailyChangeEvent)
    widget:addDataProxy("get_3",function(evt)
        return ch.GuildWarModel:getDailyPrizeState(3) == 2
    end,dailyChangeEvent)
    widget:addDataProxy("get_4",function(evt)
        return ch.GuildWarModel:getDailyPrizeState(4) == 2
    end,dailyChangeEvent)
    widget:addDataProxy("icon_1",function(evt)
        if ch.GuildWarModel:getDailyPrizeState(1) == 2 then
            return "aaui_icon/icon_guildwar_cream_5.png"
        else
            return "aaui_icon/icon_guildwar_cream_2.png"
        end
    end,dailyChangeEvent)
    widget:addDataProxy("icon_2",function(evt)
        if ch.GuildWarModel:getDailyPrizeState(2) == 2 then
            return "aaui_icon/icon_guildwar_herosoul_4.png"
        else
            return "aaui_icon/icon_guildwar_herosoul_2.png"
        end
    end,dailyChangeEvent)
    widget:addDataProxy("icon_3",function(evt)
        if ch.GuildWarModel:getDailyPrizeState(3) == 2 then
            return "aaui_icon/icon_guildwar_cream_5.png"
        else
            return "aaui_icon/icon_guildwar_cream_2.png"
        end
    end,dailyChangeEvent)
    widget:addDataProxy("icon_4",function(evt)
        if ch.GuildWarModel:getDailyPrizeState(4) == 2 then
            return "aaui_icon/icon_guildwar_herosoul_4.png"
        else
            return "aaui_icon/icon_guildwar_herosoul_2.png"
        end
    end,dailyChangeEvent)
    
    widget:addCommond("getReward",function()
        ch.GuildWarController:guildWarGetDailyReward()
    end)
end)