--选中旗帜
local selectId = 0
local CHANGE_SELECT_EVENT = "FLAG_CHANGE_SELECT"

local getTime = function(time)
    if time > 0 then
        local day = time /(24*3600)
        if day > 1 then
            return string.format(Language.src_clickhero_view_GuildView_1,math.floor(day))
        else
            local second = math.floor(time%60)
            time = time /60
            local minute = math.floor(time%60)
            local hour = math.floor(time/60)
            return string.format("%02d:%02d:%02d",hour,minute,second)
        end
    end
end

-- 固有绑定
-- 公会界面（抽屉式）
zzy.BindManager:addFixedBind("Guild/W_GuildList", function(widget)
    local honourChangeEvent = {}
    honourChangeEvent[ch.MoneyModel.dataChangeEventType] =  function(evt)
        return evt.dataType == ch.MoneyModel.dataType.honour
    end
    local levelChangeEvent = {}
    levelChangeEvent[ch.LevelModel.dataChangeEventType] =  function(evt)
        return evt.dataType == ch.LevelModel.dataType.curLevel
    end
    local panelChangeEvent = {}
    panelChangeEvent[ch.GuildModel.dataChangeEventType] = false    
    
    widget:listen(ch.WarpathModel.dataChangeEventType,function(obj,evt)
        if not ch.WarpathModel:isShow() then
            ch.NetworkController:guildPanel()
        end
    end)
    
    widget:addDataProxy("num_honour",function(evt)
        return ch.MoneyModel:getHonour()
    end,honourChangeEvent)
    
    widget:addDataProxy("openDesc",function(evt)
        return string.format(Language.src_clickhero_view_GuildView_2,GameConst.GUILD_OPEN_LEVEL)
    end)
    
    widget:addDataProxy("if_notOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel() <= GameConst.GUILD_OPEN_LEVEL
    end,levelChangeEvent)
    
    widget:addDataProxy("if_open",function(evt)
        return ch.StatisticsModel:getMaxLevel() > GameConst.GUILD_OPEN_LEVEL
    end,levelChangeEvent)
    
    widget:addDataProxy("if_join",function(evt)
        return ch.GuildModel:ifJoinGuild()
    end,panelChangeEvent)
    
    widget:addDataProxy("if_noJoin",function(evt)
        return not ch.GuildModel:ifJoinGuild() and not ch.WarpathModel:isShow()
    end,panelChangeEvent)
    
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(ch.GuildModel:myGuildName())
    end,panelChangeEvent)
    
    widget:addDataProxy("num",function(evt)
        return ch.GuildModel:myGuildNum()
    end,panelChangeEvent)
    
    widget:addDataProxy("memberList",function(evt)
        local item = {}
        if ch.GuildModel:ifJoinGuild() then
            for k,v in pairs(ch.GuildModel:myGuildMemberList()) do
                table.insert(item,{index = 1,value ={index = k,value = ch.GuildModel:myGuildList(k)},isMultiple = true})
            end
            table.insert(item,{index = 2,value = "1",isMultiple = true})
        end
        return item
    end,panelChangeEvent)
    
    widget:addCommond("openJoin",function()
--        if ch.GuildModel:myJoinCount() < GameConst.GUILD_JOIN_COUNT then
            ch.NetworkController:refreshGuild()
--            ch.UIManager:showGamePopup("Guild/W_GuildJoinlist")
            ch.UIManager:showGamePopup("Guild/W_NewGuild_join")
--        else
--            ch.UIManager:showMsgBox(1,true,string.format(Language.src_clickhero_view_GuildView_3,GameConst.GUILD_JOIN_COUNT),nil,nil,Language.MSG_BUTTON_YESOK)
--        end
    end)
    
    widget:addCommond("openCreate",function()
        ch.UIManager:showGamePopup("Guild/W_GuildBuilding")
    end)
    
    -- 抽屉页处理
    local guildOpenEvent = {}
    guildOpenEvent[ch.UIManager.viewPopEventType] = function(evt)
        return evt.view == "Guild/W_GuildList"
    end
    -- 上按钮可见
    widget:addDataProxy("upVisible", function(evt)
        if evt then
            return evt.popType == ch.UIManager.popType.HalfOpen
        else
            return true
        end
    end,guildOpenEvent)
    -- 下按钮可见
    widget:addDataProxy("downVisible", function(evt)
        if evt then
            return evt.popType ~= ch.UIManager.popType.HalfOpen
        else
            return false
        end
    end,guildOpenEvent)
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
    end,guildOpenEvent)
end)

-- 公会列表按钮单元
zzy.BindManager:addCustomDataBind("Guild/W_GuildLBtn", function(widget,data)
    
    widget:addDataProxy("ifAtevent",function(evt)
        return ch.GuildModel:ifAtevent()
    end)
    
    widget:addDataProxy("notAtevent",function(evt)
        return not ch.GuildModel:ifAtevent()
    end)
    
    widget:addCommond("settingGuild",function()
        ch.UIManager:showGamePopup("Guild/W_GuildSetting")
    end)
    
    widget:addCommond("quitGuild",function()
        ch.UIManager:showGamePopup("Guild/W_GuildQuitpop")
    end)
    -- 公会商店
    widget:addCommond("openShop",function()
        ch.UIManager:showGamePopup("Guild/W_GuildShop",1)
    end)
end)

-- 待加入公会列表页
zzy.BindManager:addFixedBind("Guild/W_GuildJoinlist", function(widget)
    local searchChangeEvent = {}
    searchChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.search
    end
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_GuildView_4
    end)
    
    widget:addDataProxy("desc",function(evt)
        return string.format(Language.src_clickhero_view_GuildView_5,GameConst.GUILD_JOIN_COUNT)
    end)
    
    widget:addDataProxy("not_have",function(evt)
        return false
    end,searchChangeEvent)
    
    widget:addDataProxy("if_have",function(evt)
        return true
    end,searchChangeEvent)
    
    widget:addDataProxy("list",function(evt)
        local tmpTable = {}
        for k,v in pairs(ch.GuildModel:getGuildMemberList()) do
            table.insert(tmpTable,{index = k,value = ch.GuildModel:getGuildList(k)})
        end
        return tmpTable
    end,searchChangeEvent)
    
    widget:addCommond("refresh",function()
        ch.NetworkController:refreshGuild()
    end)
    
    widget:addCommond("research",function()
        ch.NetworkController:refreshGuild()
    end)
end)

-- 待加入公会卡片单元
zzy.BindManager:addCustomDataBind("Guild/W_GuildJoinlistunit", function(widget,data)
    local searchChangeEvent = {}
    searchChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.search
    end
    widget:addDataProxy("flag",function(evt)
        return GameConst.GUILD_FLAG[data.value.flag]
    end,searchChangeEvent)
    
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(data.value.name)
    end,searchChangeEvent)
    
    widget:addDataProxy("num",function(evt)
        return data.value.num
    end,searchChangeEvent)
    
    widget:addCommond("join",function()
        ch.UIManager:showGamePopup("Guild/W_GuildJoinpop",data.index)
    end)
    widget:addCommond("openDetail",function()
        ch.NetworkController:guildDetail(data.value.id,nil,2)
    end)
end)

-- 加入公会二次确认
zzy.BindManager:addCustomDataBind("Guild/W_GuildJoinpop", function(widget,data)
--    local tmpData = ch.GuildModel:getGuildList(data)
    local tmpData = data
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_GuildView_6
    end)
    
    widget:addDataProxy("ifFix",function(evt)
        return true
    end)

    widget:addDataProxy("not_fix",function(evt)
        return false
    end)
    
    widget:addDataProxy("notJoin",function(evt)
        return true
    end)
    
    widget:addDataProxy("flag",function(evt)
        return GameConst.GUILD_FLAG[tmpData.flag]
    end)
    
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(tmpData.name)
    end)
    
    widget:addCommond("join",function()
        ch.NetworkController:joinGuild(tmpData.id)
    end)
end)

-- 查看待加入公会详情界面
zzy.BindManager:addCustomDataBind("Guild/W_GuildJoindetail", function(widget,data)
    local detailChangeEvent = {}
    detailChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.detail
    end
    local tmpData = data.value

    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_GuildView_7
    end)
    
    widget:addDataProxy("flag",function(evt)
        return GameConst.GUILD_FLAG[tmpData.flag]
    end)
    
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(tmpData.name)
    end)
    
    widget:addDataProxy("num",function(evt)
        return tmpData.num
    end)
    
    widget:addDataProxy("list",function(evt)
--        return ch.GuildModel:getDetailMemberList()
        local tmpData = {}
        if ch.GuildModel:getDetailMemberList() then
            for k,v in pairs(ch.GuildModel:getDetailMemberList()) do
--                table.insert(tmpData,{rank = k,value = ch.GuildModel:getDetailList(v)})
                table.insert(tmpData,{rank = k,value = v})
            end
        end
        return tmpData
    end,detailChangeEvent)
    
    widget:addDataProxy("ifJoin",function(evt)
        return not ch.GuildModel:ifJoinGuild() and not ch.WarpathModel:isShow() and ch.GuildModel:myJoinCount() < GameConst.GUILD_JOIN_COUNT
    end)
    
    widget:addCommond("join",function()
        ch.NetworkController:joinGuild(tmpData.id)
    end)
    
end)

-- 待加入公会成员卡片单元
zzy.BindManager:addCustomDataBind("Guild/W_GuildJoinmember", function(widget,data)
    local detailChangeEvent = {}
    detailChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.detail
    end
--    local tmpData = ch.GuildModel:getDetailList(data)
    local tmpData = data.value
    widget:addDataProxy("ifAtevent",function(evt)
        return tonumber(data.rank)-1 == 0
    end)
    
    widget:addDataProxy("notAtevent",function(evt)
        return tonumber(data.rank)-1 ~= 0
    end)
    
    widget:addDataProxy("rank",function(evt)
        return tonumber(data.rank)-1
    end)
    
    widget:addDataProxy("r_icon",function(evt)
        if data.gender == 2 then
            return GameConst.PERSON_ICON[2]
        else
            return GameConst.PERSON_ICON[1]
        end
    end,detailChangeEvent)
    
    widget:addDataProxy("p_icon",function(evt)
        return GameConfig.PartnerConfig:getData(tostring(tmpData.pet)).icon
    end,detailChangeEvent)
    
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(tmpData.name)
    end,detailChangeEvent)
    -- 称号图标
    widget:addDataProxy("titleIcon",function(evt)
        return ch.UserTitleModel:getTitle(tmpData.maxLevel-1,tmpData.userID).icon
    end,detailChangeEvent)
    
    widget:addDataProxy("maxLevel",function(evt)
        return tmpData.maxLevel
    end,detailChangeEvent)
    
    widget:addDataProxy("flag",function(evt)
        return GameConst.GUILD_FLAG[ch.GuildModel:getDetailFlag()]
    end,detailChangeEvent)
    
    widget:addDataProxy("ifyk",function(evt)
        return tmpData.yueka == 1
    end,detailChangeEvent)
end)

-- 本公会成员卡片单元
zzy.BindManager:addCustomDataBind("Guild/W_GuildListmember", function(widget,data)
    local panelChangedEvent = {}
    panelChangedEvent[ch.GuildModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.GuildModel.dataType.panel
    end
    local flagChangedEvent = {}
    flagChangedEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.panel or evt.dataType == ch.GuildModel.dataType.flag
    end
    widget:addDataProxy("ifAtevent",function(evt)
        return tonumber(data.index)-1 == 0
    end)
    
    widget:addDataProxy("notAtevent",function(evt)
        return tonumber(data.index)-1 ~= 0
    end)
    
    widget:addDataProxy("rank",function(evt)
        return tonumber(data.index)-1
    end)
    
    widget:addDataProxy("r_icon",function(evt)
        if data.gender == 2 then
            return GameConst.PERSON_ICON[2]
        else
            return GameConst.PERSON_ICON[1]
        end
    end,panelChangedEvent)
    
    widget:addDataProxy("p_icon",function(evt)
        return GameConfig.PartnerConfig:getData(tostring(data.value.pet)).icon
    end,panelChangedEvent)
    
    widget:addDataProxy("flag",function(evt)
        return GameConst.GUILD_FLAG[ch.GuildModel:myGuildFlag()]
    end,flagChangedEvent)
    
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(data.value.name)
    end,panelChangedEvent)
    -- 称号图标
    widget:addDataProxy("titleIcon",function(evt)
        return ch.UserTitleModel:getTitle(data.value.maxLevel-1,data.value.userID).icon
    end,panelChangedEvent)
    
    widget:addDataProxy("maxLevel",function(evt)
        return data.value.maxLevel
    end,panelChangedEvent)
    
    widget:addDataProxy("ifyk",function(evt)
        return data.value.yueka == 1
    end,panelChangedEvent)
    
    widget:addDataProxy("if_friend",function(evt)
        return data.value.userID ~= ch.PlayerModel:getPlayerID()
    end,panelChangedEvent)
    widget:addCommond("openDetail",function()
        local tmpData = ch.GuildModel:myGuildList(data.index)
        tmpData.guild = ch.GuildModel:myGuildName()
        ch.UIManager:showGamePopup("Guild/W_Guildmemberdetail",{type = 1,value = tmpData})
    end)
end)

-- 查看会员界面 
-- type为1是公会成员信息，type为2是其他位置打开的玩家信息
zzy.BindManager:addCustomDataBind("Guild/W_Guildmemberdetail", function(widget,data)
    local tmpData = data.value
    widget:addDataProxy("r_path",function(evt)
        return GameConst.PERSON_PATH[1]
    end)
    if zzy.config.check then
        widget:getChild("text_last"):setVisible(false)
    end
    
    widget:addDataProxy("p_path",function(evt)
        return GameConfig.PartnerConfig:getData(tostring(tmpData.pet)).icon
    end)
    
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_GuildView_8
    end)
    
    widget:addDataProxy("name",function(evt)
        return tmpData.name
    end)
    -- 称号图标
    widget:addDataProxy("titleIcon",function(evt)
        return ch.UserTitleModel:getTitle(tmpData.maxLevel-1,tmpData.userID).icon
    end)
    widget:addDataProxy("titleName",function(evt)
        return ch.UserTitleModel:getTitle(tmpData.maxLevel-1,tmpData.userID).name
    end)
    
    widget:addDataProxy("guild",function(evt)
        if tmpData.guild == nil or tmpData.guild == "" then
            return tmpData.guild
        else
            return "[".. ch.CommonFunc:getNameNoSever(tmpData.guild) .."]"
        end
    end)
    
    widget:addDataProxy("maxDPS",function(evt)
        return ch.NumberHelper:toString(ch.LongDouble:toLongDouble(tmpData.maxDPS))
    end)
    
    widget:addDataProxy("starNum",function(evt)
        return tmpData.starNum
    end)
    
    widget:addDataProxy("maxLevel",function(evt)
        return tmpData.maxLevel
    end)
    
    widget:addDataProxy("zs_num",function(evt)
        return tmpData.rtime
    end)
    
    widget:addDataProxy("petList",function(evt)
        if table.maxn(tmpData.petList) > 6 then
            table.remove(tmpData.petList,1)
            return tmpData.petList
        else
            return tmpData.petList
        end
    end)
    
    widget:addDataProxy("direction",function(evt)
        return ccui.ListViewDirection.horizontalSnap
    end)
    
    widget:addDataProxy("last_time",function(evt)
        if tmpData.ltime > 0 then
            return os.date("%Y-%m-%d %H:%M:%S",tonumber(tmpData.ltime))
        else
            return Language.src_clickhero_view_GuildView_9
        end
    end)

    widget:addDataProxy("ifAtevent",function(evt)
        return data.type == 1 and ch.GuildModel:ifAtevent() and tmpData.userID ~= ch.PlayerModel:getPlayerID()
    end)
    
    widget:addCommond("kick",function()
        ch.NetworkController:kickGuild(ch.GuildModel:myGuildID(),tmpData.userID)
        ch.UIManager:cleanGamePopupLayer(true)
        ch.NetworkController:guildPanel()
        ch.UIManager:showBottomPopup("Guild/W_GuildList")
    end)
    
    local roleName,weapon = ch.UserTitleModel:getAvatarByLevel(tmpData.maxLevel - 1,tmpData.gender)
    
    local playerPanel = widget:getChild("icon_player")
    
    ch.CommonFunc:showRoleAvatar(playerPanel,roleName,weapon)
    
    widget:addCommond("close",function()
        widget:destory()
        if roleName ~= ch.UserTitleModel:getAvatar() then
            ch.RoleResManager:release(roleName)
        end
    end)
end)

-- 退出公会二次确认
zzy.BindManager:addFixedBind("Guild/W_GuildQuitpop", function(widget)
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_GuildView_10
    end)

    widget:addDataProxy("flag",function(evt)
        return GameConst.GUILD_FLAG[ch.GuildModel:myGuildFlag()]
    end)
    
    widget:addDataProxy("name",function(evt)
        return ch.CommonFunc:getNameNoSever(ch.GuildModel:myGuildName())
    end)
    
    widget:addDataProxy("ifJoin",function(evt)
        return true
    end)
    
    widget:addCommond("quit",function()
        ch.NetworkController:quitGuild(ch.GuildModel:myGuildID())
        ch.UIManager:cleanGamePopupLayer(true)
        ch.NetworkController:guildPanel()
--        ch.UIManager:showBottomPopup("Guild/W_GuildList")
    end)
end)

-- 设置公会界面
zzy.BindManager:addFixedBind("Guild/W_GuildSetting", function(widget)
    local selectedChangedEvent = {}
    selectedChangedEvent[CHANGE_SELECT_EVENT] = false
    selectedChangedEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    
    local callNumChangedEvent = {}
    callNumChangedEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.call
    end
    
    local nameChangedEvent = {}
    nameChangedEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    selectId = 0
    local oldName = ch.GuildModel:myGuildName()
    local oldFlag = ch.GuildModel:myGuildFlag()
    local name = ch.GuildModel:myGuildName()
    local id = ch.GuildModel:myGuildID()
    local say = name..Language.src_clickhero_view_GuildView_11
    widget:addDataProxy("name",function(evt)
        return name
    end)
    
    widget:addDataProxy("priceName",function(evt)
        return GameConst.GUILD_CHANGE_NAME_PRICE
    end)
    -- widget:addCommond("inputName",function(obj,str)
    --     name = str
    --     widget:noticeDataChange("ifName")
    -- end)
    local m_editBox
    local function editboxEventHandler(eventType)
        if eventType == "began" then
        elseif eventType == "ended" then
            name = m_editBox:getText()
            widget:noticeDataChange("ifName")
        elseif eventType == "changed" then
        elseif eventType == "return" then
            name = m_editBox:getText()
            widget:noticeDataChange("ifName")
        end
    end

    local ctr = widget:getChild("textField_guildid")
    local ctrName = ctr:getDescription()
    if ctrName == "TextField" then
        local m_editBoxSize = ctr:getContentSize()
        m_editBox = ccui.EditBox:create(m_editBoxSize, ccui.Scale9Sprite:create())
        m_editBox:setPosition(cc.p(ctr:getPositionX(), ctr:getPositionY()))
        m_editBox:setFontSize(ctr:getFontSize())
        m_editBox:setAnchorPoint(ctr:getAnchorPoint())
        m_editBox:setPlaceHolder(ctr:getPlaceHolder())
        m_editBox:setInputMode(6)
        m_editBox:setMaxLength(ctr:getMaxLength())
        m_editBox:registerScriptEditBoxHandler(editboxEventHandler)
        ctr:getParent():addChild(m_editBox)
        ctr:getParent():removeChild(ctr,true)
    end
    
    widget:addCommond("changeName",function()
        ch.NetworkController:guildChangeName(id,name)
        oldName = name
        widget:noticeDataChange("ifName")
    end)
    
    widget:addCommond("changeFlag",function()
        ch.NetworkController:guildChangeFlag(id,selectId)
        oldFlag = selectId
        widget:noticeDataChange("ifCanChange")
    end)
    
    
    widget:addDataProxy("say",function(evt)
        return say
    end)
    widget:addDataProxy("priceCall",function(evt)
        return GameConst.CHAT_GUILD_JOIN_COST
    end)
    -- widget:addCommond("inputSay",function(obj,str)
    --     say = str
    --     widget:noticeDataChange("ifCall")
    -- end)

    local m_inputSayBox
    local function inputSayEventHandler(eventType)
        if eventType == "began" then
        elseif eventType == "ended" then
            say = m_inputSayBox:getText()
            widget:noticeDataChange("ifCall")
        elseif eventType == "changed" then
        elseif eventType == "return" then
            say = m_inputSayBox:getText()
            widget:noticeDataChange("ifCall")
        end
    end
    
    local m_inputText = widget:getChild("textField_guildid_2")
    local m_viewName = m_inputText:getDescription()
    if m_viewName == "TextField" then
        local m_inputBoxSize = m_inputText:getContentSize()
        m_inputSayBox = ccui.EditBox:create(m_inputBoxSize, ccui.Scale9Sprite:create())
        m_inputSayBox:setPosition(cc.p(m_inputText:getPositionX(), m_inputText:getPositionY()))
        m_inputSayBox:setFontSize(m_inputText:getFontSize())
        m_inputSayBox:setAnchorPoint(m_inputText:getAnchorPoint())
        m_inputSayBox:setPlaceHolder(m_inputText:getPlaceHolder())
        m_inputSayBox:setMaxLength(m_inputText:getMaxLength())
        m_inputSayBox:setInputMode(6)
        m_inputSayBox:registerScriptEditBoxHandler(inputSayEventHandler)
        m_inputText:getParent():addChild(m_inputSayBox)
        m_inputText:getParent():removeChild(m_inputText,true)
    end
    
    widget:addDataProxy("noFreeCall",function(evt)
        return GameConst.CHAT_GUILD_JOIN_FREE_COUNT<=ch.GuildModel:getCallNum()
    end,callNumChangedEvent)
    widget:addDataProxy("ifFreeCall",function(evt)
        return GameConst.CHAT_GUILD_JOIN_FREE_COUNT>ch.GuildModel:getCallNum()
    end,callNumChangedEvent)
    widget:addDataProxy("callNum",function(evt)
        return string.format(Language.src_clickhero_view_GuildView_12,GameConst.CHAT_GUILD_JOIN_FREE_COUNT-ch.GuildModel:getCallNum())
    end,callNumChangedEvent)
    
    widget:addDataProxy("noFull",function(evt)
        return ch.GuildModel:myGuildNum()<GameConst.GUILD_MEMBER_NUM+1 and say ~= ""
    end,nameChangedEvent)
    -- 钱够且有话说
    widget:addDataProxy("ifCall",function(evt)
        return ch.GuildModel:myGuildNum()<GameConst.GUILD_MEMBER_NUM+1 and ch.MoneyModel:getDiamond() >= GameConst.CHAT_GUILD_JOIN_COST and say ~= ""
    end,nameChangedEvent)
    
    widget:addCommond("callWorld",function()
        ch.NetworkController:guildCallWorld(id,say)
    end)
    
    widget:addCommond("dissolve",function()
        ch.UIManager:showMsgBox(2,true,Language.src_clickhero_view_GuildView_13,function()
            ch.NetworkController:deleteGuild(id)
            ch.UIManager:cleanGamePopupLayer(true)
            ch.NetworkController:guildPanel()
            ch.UIManager:showBottomPopup("Guild/W_GuildList")
        end,nil,Language.src_clickhero_view_GuildView_14,2)
    end)
    
    widget:addDataProxy("text_error",function(evt)
        return ""
    end)
    
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_GuildView_15
    end)
    widget:addDataProxy("direction",function(evt)
        return ccui.ListViewDirection.horizontalSnap
    end)
    -- 名称有修改且不为空
    widget:addDataProxy("ifName",function(evt)
        return ch.MoneyModel:getDiamond() >= GameConst.GUILD_CHANGE_NAME_PRICE and oldName ~= name and name ~= ""
    end,nameChangedEvent)
    
    widget:addDataProxy("flagList",function(evt)
        return ch.GuildModel:getFlagList()
    end)
    -- 旗帜有修改
    widget:addDataProxy("ifCanChange",function(evt)
        return ch.MoneyModel:getDiamond() >= GameConst.GUILD_CHANGE_FLAG_PRICE and oldFlag ~= selectId and selectId ~= 0
    end,selectedChangedEvent)
    
    widget:addDataProxy("priceFlag",function(evt)
        return GameConst.GUILD_CHANGE_FLAG_PRICE
    end)
    
    widget:addDataProxy("notValidity",function(evt)
        return ch.GuildModel:myGuildVTime() <= 0
    end)
    
    widget:addDataProxy("isValidity",function(evt)
        return ch.GuildModel:myGuildVTime() > 0
    end)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("validityTime")
        widget:noticeDataChange("notValidity")
        widget:noticeDataChange("isValidity")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    widget:addDataProxy("validityTime",function(evt)
        local time = ch.GuildModel:myGuildVTime()
        return getTime(time)
    end)
    
    widget:addCommond("close",function()
        ch.UIManager:cleanGamePopupLayer(true)
        ch.NetworkController:guildPanel()
        ch.UIManager:showBottomPopup("Guild/W_GuildList")
    end)
end)

-- 创建公会界面
zzy.BindManager:addFixedBind("Guild/W_GuildBuilding", function(widget)
    local selectedChangedEvent = {}
    selectedChangedEvent[CHANGE_SELECT_EVENT] = false
    selectedChangedEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    selectId = 0
    local name = ""
    local m_editBox
    -- widget:addCommond("inputName",function(obj,str)
    --     name = str
    --     widget:noticeDataChange("ifName")
    -- end)

    local m_editBox
    local function editboxEventHandler(eventType)
        if eventType == "began" then
        elseif eventType == "ended" then
            name = m_editBox:getText()
            widget:noticeDataChange("ifName")
        elseif eventType == "changed" then
        elseif eventType == "return" then
            name = m_editBox:getText()
            widget:noticeDataChange("ifName")
        end
    end

    -- 修改
    local ctr = widget:getChild("textField_guildid")
    local ctrName = ctr:getDescription()
    if ctrName == "TextField" then
        local m_editBoxSize = ctr:getContentSize()
        m_editBox = ccui.EditBox:create(m_editBoxSize, ccui.Scale9Sprite:create())
        m_editBox:setPosition(cc.p(ctr:getPositionX(), ctr:getPositionY()))
        m_editBox:setFontSize(ctr:getFontSize())
--        m_editBox:setFontColor(cc.c3b(145,138,138))
        m_editBox:registerScriptEditBoxHandler(editboxEventHandler)
        m_editBox:setAnchorPoint(ctr:getAnchorPoint())
        m_editBox:setPlaceHolder(ctr:getPlaceHolder())
        m_editBox:setMaxLength(GameConst.CHAT_MAX_CHAR_COUNT)
 		 m_editBox:setInputMode(6)
        m_editBox:setText("")
        ctr:getParent():addChild(m_editBox)
        ctr:getParent():removeChild(ctr,true)
    end

    widget:addCommond("create",function()
        local buy = function()
            name = m_editBox:getText()
            cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
            widget:noticeDataChange("ifName")

            ch.NetworkController:buildGuild(name,selectId)
            ch.GuildModel:setGuildName(name)
            ch.GuildModel:setGuildFlag(selectId)
        end
        local tmp = {price = GameConst.GUILD_BUILD_PRICE,buy = buy}
        ch.ShopModel:getCostTips(tmp)
    end)
    
    widget:addDataProxy("text_error",function(evt)
        return ""
    end)
    
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_GuildView_16
    end)
    widget:addDataProxy("direction",function(evt)
        return ccui.ListViewDirection.horizontalSnap
    end)
    widget:addDataProxy("ifName",function(evt)
        name=m_editBox:getText()
        return name ~= "" and selectId ~= 0 and ch.MoneyModel:getDiamond() >= GameConst.GUILD_BUILD_PRICE
    end,selectedChangedEvent)
    
    widget:addDataProxy("price",function(evt)
        return GameConst.GUILD_BUILD_PRICE
    end)
    
    widget:addDataProxy("flagList",function(evt)
        return ch.GuildModel:getFlagList()
    end)
end)


-- 公会设置界面
zzy.BindManager:addFixedBind("Guild/W_NewGuild_change", function(widget)
    local selectedChangedEvent = {}
    selectedChangedEvent[CHANGE_SELECT_EVENT] = false
    selectedChangedEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.diamond
    end

    selectId = 0
    local oldName = ch.GuildModel:myGuildName()
    local oldFlag = ch.GuildModel:myGuildFlag()
    local name = ch.GuildModel:myGuildName()
    local id = ch.GuildModel:myGuildID()
    widget:addCommond("inputName",function(obj,str)
        name = str
        widget:noticeDataChange("ifName")
    end)
    
    local m_editBox
    local function editboxEventHandler(eventType)
        if eventType == "began" then
        elseif eventType == "ended" then
            name = m_editBox:getText()
            widget:noticeDataChange("ifName")
        elseif eventType == "changed" then
        elseif eventType == "return" then
            name = m_editBox:getText()
            widget:noticeDataChange("ifName")
        end
    end
    -- 修改
    local ctr = widget:getChild("textField_guildid")
    local ctrName = ctr:getDescription()
    if ctrName == "TextField" then
        local m_editBoxSize = ctr:getContentSize()
        m_editBox = ccui.EditBox:create(m_editBoxSize, ccui.Scale9Sprite:create())
        m_editBox:setPosition(cc.p(ctr:getPositionX(), ctr:getPositionY()))
        m_editBox:setFontSize(ctr:getFontSize())
        --        m_editBox:setFontColor(cc.c3b(145,138,138))
        m_editBox:registerScriptEditBoxHandler(editboxEventHandler)
        m_editBox:setAnchorPoint(ctr:getAnchorPoint())
        m_editBox:setPlaceHolder(ctr:getPlaceHolder())
        m_editBox:setMaxLength(GameConst.CHAT_MAX_CHAR_COUNT)
        m_editBox:setText("")
        ctr:getParent():addChild(m_editBox)
        ctr:getParent():removeChild(ctr,true)
    end
    
    widget:addDataProxy("name",function(evt)
        return name
    end)
    
    widget:addCommond("create",function()
        local buy = function()
            name = m_editBox:getText()
            cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
            widget:noticeDataChange("ifName")

            if name ~= "" and name ~= oldName then
                if selectId ~= 0 and selectId ~= oldFlag then
                    ch.NetworkController:guildChangeName(ch.GuildModel:myGuildID(),name,selectId)
                else
                    ch.NetworkController:guildChangeName(ch.GuildModel:myGuildID(),name,nil)
                end
            else
                if selectId ~= 0 and selectId ~= oldFlag then
                    ch.NetworkController:guildChangeName(ch.GuildModel:myGuildID(),nil,selectId)            
                end
            end
            widget:destory()
        end
        local tmp = {price = GameConst.GUILD_CHANGE_NAME_PRICE,buy = buy}
        ch.ShopModel:getCostTips(tmp)
    end)

    widget:addDataProxy("text_error",function(evt)
        return ""
    end)

    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_GuildView_21
    end)
    widget:addDataProxy("direction",function(evt)
        return ccui.ListViewDirection.horizontalSnap
    end)
    widget:addDataProxy("ifName",function(evt)
        return ((name ~= "" and name ~= oldName) 
                or (selectId ~= 0 and selectId ~= oldFlag)) 
            and ch.MoneyModel:getDiamond() >= GameConst.GUILD_CHANGE_NAME_PRICE
    end,selectedChangedEvent)

    widget:addDataProxy("price",function(evt)
        return GameConst.GUILD_CHANGE_NAME_PRICE
    end)

    widget:addDataProxy("flagList",function(evt)
        return ch.GuildModel:getFlagList()
    end)
end)


-- 公会旗帜单元
zzy.BindManager:addCustomDataBind("Guild/W_Guildicon", function(widget,data)
    local selectedChangedEvent = {}
    selectedChangedEvent[CHANGE_SELECT_EVENT] = false
    
    local flagChangedEvent = {}
    flagChangedEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.flag
    end
    widget:addDataProxy("flag",function(evt)
        return GameConst.GUILD_FLAG[tonumber(data)]
    end)
    
    widget:addDataProxy("isCurFlag",function(evt)
        return tonumber(data) == ch.GuildModel:myGuildFlag()
    end,flagChangedEvent)
    
    widget:addDataProxy("notCurFlag",function(evt)
        return tonumber(data) ~= ch.GuildModel:myGuildFlag()
    end,flagChangedEvent)
    
    -- 选中、取消
    widget:addDataProxy("ifSelect",function(evt)
        return data == selectId
    end,selectedChangedEvent)
    
    -- 选中、取消
    widget:addCommond("select",function(widget,arg)
        if arg == "1" then
            selectId = data
            zzy.EventManager:dispatchByType(CHANGE_SELECT_EVENT)
        elseif arg == "0" then
            if selectId == data then
                selectId = 0
                zzy.EventManager:dispatchByType(CHANGE_SELECT_EVENT)
            end
        end
    end)
end)

-- 宠物头像
zzy.BindManager:addCustomDataBind("Guild/N_GuildIconPet", function(widget,data)
    widget:addDataProxy("petIcon",function(evt)
        return GameConfig.PartnerConfig:getData(tostring(data)).icon
    end)
end)
