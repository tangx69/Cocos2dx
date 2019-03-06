local ChatView = {
    _renderer = nil,
    _worldRenderer = nil,
    _guildRenderer = nil,
    _worldBtn = nil,
    _worldCheckBox = nil,
    _worldTipImage = nil,
    _worldListView = nil,
    _guildBtn = nil,
    _guildCheckBox = nil,
    _guildTipImage = nil,
    _guildListView = nil,
    _closeBtn = nil,
    _textFild = nil,
    _worldFreeBtn = nil,
    _worldDiamondBtn = nil,
    _guildFreeBtn = nil,
    _worldBtnPanel = nil,
    _guildBtnPanel = nil,
    _leftCountText = nil,
    
    _curChannel = nil,
    _curText = nil,
    
    _isOpen = nil,
    _chatCountEventId = nil,
    
    ChanenlList = {
        World = 2,
        Guild = 3
    }
}

local instanse = nil
local itemClone = nil

ChatView.__index = ChatView

function ChatView:create()
	local o = {}
	setmetatable(o,self)
	o:_init()
	return o
end

function ChatView:getInstanse()
	if instanse == nil then
       itemClone = cc.CSLoader:createNode("res/ui/MainScreen/W_chat_unit.csb", "res/ui/")
       itemClone:retain()
	   instanse = self:create()
	end
    return instanse
end

function ChatView:hasInstanse()
    return instanse ~= nil
end

function ChatView:destroyInstanse()
    if instanse ~= nil then
        zzy.EventManager:unListen(instanse._chatCountEventId)
        instanse._renderer:removeFromParent()
        instanse = nil
    end
    if itemClone ~= nil then
        itemClone:release()
        itemClone = nil
    end
end

function ChatView:_init()
    IS_IN_GAME = true

    DEBUG("IS_IN_GAME = true")
	self:_initRenderer()
	self:_initData()
	self:_addBtnListen()
    local data = ch.ChatModel:getCacheData()
    for k,v in pairs(data) do
        v.c = zzy.StringUtils:FilterSensitiveChar(v.c)
        self:addItem(v)
        ch.ChatModel:addChatCount()
    end
    if table.maxn(data) > 0 then
        ch.ChatModel:setChatContent(data[table.maxn(data)])
    end
end

function ChatView:getRenderer()
	return self._renderer
end

function ChatView:_initRenderer()
    self._renderer = cc.CSLoader:createNode("res/ui/MainScreen/W_chat.csb", "res/ui/")
    self._worldRenderer = cc.CSLoader:createNode("res/ui/MainScreen/W_chat_1.csb", "res/ui/")
    self._guildRenderer = cc.CSLoader:createNode("res/ui/MainScreen/W_chat_2.csb", "res/ui/")
    self._renderer:addChild(self._worldRenderer)
    self._renderer:addChild(self._guildRenderer)
    self._guildRenderer:setVisible(false)
    self._worldBtn = zzy.CocosExtra.seekNodeByName(self._renderer, "btn_1")
    self._guildBtn = zzy.CocosExtra.seekNodeByName(self._renderer, "btn_2")
    self._guildBtn:setSelected(false)
    self._worldTipImage = zzy.CocosExtra.seekNodeByName(self._worldBtn, "img_numdb")
    self._worldTipImage:setVisible(false)
    self._guildTipImage = zzy.CocosExtra.seekNodeByName(self._guildBtn, "img_numdb")
    self._guildTipImage:setVisible(false)
    self._worldListView = zzy.CocosExtra.seekNodeByName(self._worldRenderer, "ListView_1")
    self._guildListView = zzy.CocosExtra.seekNodeByName(self._guildRenderer, "ListView_1")
    self._closeBtn = zzy.CocosExtra.seekNodeByName(self._renderer, "Btn_close")
    local node = zzy.CocosExtra.seekNodeByName(self._renderer, "N_chat_input")
    --self._textFild = zzy.CocosExtra.seekNodeByName(node, "textField")
    local convertToEditBox = function ()
       local m_textField = zzy.CocosExtra.seekNodeByName(node, "textField")
       local m_editBoxSize = m_textField:getContentSize()
--       if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD then
--            m_editBoxSize = cc.size(395, 50)
--       end
       local m_editBox = ccui.EditBox:create(m_editBoxSize, ccui.Scale9Sprite:create())
       m_editBox:setPosition(cc.p(m_textField:getPositionX(),m_textField:getPositionY()))
       m_editBox:setFontSize(m_textField:getFontSize())
       m_editBox:setInputMode(6)
       m_editBox:setAnchorPoint(m_textField:getAnchorPoint())
       m_editBox:setPlaceHolder(m_textField:getPlaceHolder())
       if cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_IPHONE or cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_IPAD then
            m_editBox:setMaxLength(GameConst.CHAT_MAX_CHAR_COUNT)
       end
       m_textField:getParent():addChild(m_editBox)
       m_textField:getParent():removeChild(m_textField,true)
        
       return m_editBox
    end
    self._textFild = convertToEditBox()
    self._worldBtnPanel = zzy.CocosExtra.seekNodeByName(node, "Panel_world")
    self._guildBtnPanel = zzy.CocosExtra.seekNodeByName(node, "Panel_guild")
    self._worldFreeBtn = zzy.CocosExtra.seekNodeByName(self._worldBtnPanel, "btn_send1")
    self._worldDiamondBtn = zzy.CocosExtra.seekNodeByName(self._worldBtnPanel, "btn_send2")
    self._guildFreeBtn = zzy.CocosExtra.seekNodeByName(self._guildBtnPanel, "btn_send3")
    self._leftCountText = zzy.CocosExtra.seekNodeByName(self._worldBtnPanel, "text_num")
    local costText = zzy.CocosExtra.seekNodeByName(self._worldDiamondBtn, "num_Diamond")
    costText:setString(GameConst.CHAT_WORLD_COST)
    self._guildBtnPanel:setVisible(false)
    self._leftCountText:setString(GameConst.CHAT_FREE_WORLD_COUND - ch.ShopModel:getChatCount())
    self:_checkWorldBtnStatue()
    
    if IS_BANHAO then
        local text_num_0 = zzy.CocosExtra.seekNodeByName(self._renderer, "text_num_0")
        local text_num = zzy.CocosExtra.seekNodeByName(self._renderer, "text_num")
        
        text_num_0:setVisible(false)
        text_num:setVisible(false)
    end
end

function ChatView:_initData()
	self._curChannel = self.ChanenlList.World
	self._isOpen = false
end

function ChatView:_addBtnListen()
    self._worldBtn:addEventListener(function(sender,evt)
        if evt == ccui.CheckBoxEventType.selected then
            self:_changeChannel(self.ChanenlList.World)
        elseif evt == ccui.CheckBoxEventType.unselected then
            if self._curChannel == self.ChanenlList.World then
                self._worldBtn:setSelected(true)
            end
        end
	end)
    self._guildBtn:addEventListener(function(sender,evt)
        if ch.WarpathModel:isShow() then
            if evt == ccui.CheckBoxEventType.selected then
                self:_changeChannel(self.ChanenlList.Guild)
            elseif evt == ccui.CheckBoxEventType.unselected then
                if self._curChannel == self.ChanenlList.Guild then
                    self._guildBtn:setSelected(true)
                end
            end
        else
            if evt == ccui.CheckBoxEventType.selected then 
                self._guildBtn:setSelected(false)
                ch.UIManager:showMsgBox(1,true,GameConst.CHAT_NO_GUILD_TIP)
            end
        end
    end)
    self._closeBtn:addTouchEventListener(function(sender,evt)
        if evt == ccui.TouchEventType.ended then
            self:close()
        end
    end)
    self._worldFreeBtn:addTouchEventListener(function(sender,evt)
        if evt == ccui.TouchEventType.ended then
            if ch.StatisticsModel:getMaxLevel() > GameConst.CHAT_OPEN_LEVEL then
                if ch.PlayerModel:getPlayerGender() and ch.PlayerModel:getPlayerGender() ~= 0 then
                    self:_send(true)
                else
                    ch.UIManager:showGamePopup("setting/W_SettingCName_1")
                end
            else
                ch.UIManager:showMsgBox(1,true,string.format(GameConst.CHAT_UNLOCK_TIP,GameConst.CHAT_OPEN_LEVEL))
            end
        end
    end)
    self._worldDiamondBtn:addTouchEventListener(function(sender,evt)
        if evt == ccui.TouchEventType.ended then
            if ch.StatisticsModel:getMaxLevel() > GameConst.CHAT_OPEN_LEVEL then
                if ch.MoneyModel:getDiamond()>= GameConst.CHAT_WORLD_COST then
                    local buy = function()
                        self:_send(false)
                    end
                    self._curText = self._textFild:getText()
                    if self._curText == "" or self._curText == nil then 
                        ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_SettingView_4)
                    else
                        local tmp = {price = GameConst.CHAT_WORLD_COST,buy = buy}
                        ch.ShopModel:getCostTips(tmp)
                    end
                else
                    ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
                end
            else
                ch.UIManager:showMsgBox(1,true,string.format(GameConst.CHAT_UNLOCK_TIP,GameConst.CHAT_OPEN_LEVEL))
            end
        end
    end)
    self._guildFreeBtn:addTouchEventListener(function(sender,evt)
        if evt == ccui.TouchEventType.ended then
            self:_send(true)
        end
    end)
    -- self._textFild:addEventListener(function(sender,evt)
    --     if evt == ccui.TextFiledEventType.insert_text then
    --         self._curText = zzy.StringUtils:strMaxLimit(self._textFild:getString(), GameConst.CHAT_MAX_CHAR_COUNT)
    --         self._textFild:setString(self._curText)
    --     elseif evt == ccui.TextFiledEventType.delete_backward then
            
    --         self._curText = self._textFild:getString()
    --     end
    -- end)
   -- self._textFild:registerScriptEditBoxHandler(function(strEventName,pSender)
   --     local strFmt = string.format("%s",pSender:getText())
   --     cclog(strFmt);
   --     if strEventName == "began" then
   --     elseif strEventName == "ended" then
   --     elseif strEventName == "return" then
   --     elseif strEventName == "changed" then
   --     end
   -- end)
    self._chatCountEventId = zzy.EventManager:listen(ch.ShopModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.ShopModel.dataType.chat or evt.dataType == ch.ShopModel.dataType.all then
            self:_checkWorldBtnStatue()
            self._leftCountText:setString(GameConst.CHAT_FREE_WORLD_COUND - ch.ShopModel:getChatCount())
        end
    end)
end

function ChatView:_changeChannel(channelId)
    if self._curChannel == channelId then return end
    self._curChannel = channelId
    if channelId == self.ChanenlList.World then
        self._worldTipImage:setVisible(false)
        self._worldRenderer:setVisible(true)
        self._guildRenderer:setVisible(false)
        self._guildBtn:setSelected(false)
        self._worldBtnPanel:setVisible(true)
        self._guildBtnPanel:setVisible(false)
    elseif channelId == self.ChanenlList.Guild then
        self._guildTipImage:setVisible(false)
        self._guildRenderer:setVisible(true)
        self._worldRenderer:setVisible(false)
        self._worldBtn:setSelected(false)
        self._worldBtnPanel:setVisible(false)
        self._guildBtnPanel:setVisible(true)
    end
end

function ChatView:_checkWorldBtnStatue()
    if ch.ShopModel:getChatCount() >= GameConst.CHAT_FREE_WORLD_COUND and (not IS_BANHAO) then
        self._worldFreeBtn:setVisible(false)
        self._worldDiamondBtn:setVisible(true)
    else
        self._worldFreeBtn:setVisible(true)
        self._worldDiamondBtn:setVisible(false)
    end
end

function ChatView:_send(isFree)
   self._curText = self._textFild:getText()
    if self._curText == "" or self._curText == nil then return end
    self._curText = zzy.StringUtils:FilterSpecialChar(self._curText)
    if self._curChannel == self.ChanenlList.World then
        if isFree or IS_BANHAO then
            ch.ShopModel:addChatCount()
            ch.NetworkController:sendChat(self._curChannel,self._curText)
        else
            ch.MoneyModel:addDiamond(-GameConst.CHAT_WORLD_COST)
            ch.NetworkController:sendChat(self._curChannel,self._curText)
        end
    elseif self._curChannel == self.ChanenlList.Guild then
        ch.NetworkController:sendChat(self._curChannel,self._curText)
    end
    self._curText = ""
    -- self._textFild:setString("")
    self._textFild:setText("")
end

function ChatView:addItem(data)
	if data.t == self.ChanenlList.World then
	   self._worldListView:insertCustomItem(self:_createItem(data),0)
	   local items = self._worldListView:getItems()
        if #items > GameConst.CHAT_MAX_ITEMS_COUNT then
            self._worldListView:removeItem(#items-1)
	   end
	   if self._curChannel ~= self.ChanenlList.World then
	       self._worldTipImage:setVisible(true)
	   end
	elseif data.t == self.ChanenlList.Guild then
        self._guildListView:insertCustomItem(self:_createItem(data),0)
        local items = self._guildListView:getItems()
        if #items > GameConst.CHAT_MAX_ITEMS_COUNT then
            self._guildListView:removeItem(#items-1)
        end
        if self._curChannel ~= self.ChanenlList.Guild then
            self._guildTipImage:setVisible(true)
        end
	end
end

function ChatView:_createItem(data)
    local isSysMsg = (not data.i) or (data.i == "")
    local sysColor = nil
    if  isSysMsg and data.rgb and string.len(data.rgb) >= 6 then
        sysColor = ch.CommonFunc:hexStringToColor3b(data.rgb)
    end
    
    local item = itemClone:clone()
    local openBtn = zzy.CocosExtra.seekNodeByName(item, "btn_openGuild")
    local content = zzy.CocosExtra.seekNodeByName(item, "text_line")
    local maxWidth = 520
    openBtn:setVisible(false)
    if data.guild then
        maxWidth = 390
        openBtn:setVisible(true)
        openBtn:addTouchEventListener(function(sender,evt)
            if evt == ccui.TouchEventType.ended then
                if ch.StatisticsModel:getMaxLevel()>GameConst.GUILD_OPEN_LEVEL then
                    ch.NetworkController:guildDetail(data.guild,nil,2)
                else
                    ch.UIManager:showMsgBox(1,true,string.format(GameConst.CHAT_NO_OPEN_GUILD_TIP,GameConst.GUILD_OPEN_LEVEL))
                end
            end
        end)
    end
    
    content:setMaxLineWidth(maxWidth)
    local textInfo = ccui.Text:create()
    textInfo:setFontName(content:getFontName())
    textInfo:setFontSize(content:getFontSize())
    content:setString(self:_strLineBreak(textInfo, data.c, maxWidth))
    textInfo = nil
    local titleIcon = zzy.CocosExtra.seekNodeByName(item, "img_title")
    if data.l then
        titleIcon:loadTexture(ch.UserTitleModel:getTitle(data.l-1,data.id).icon,ccui.TextureResType.localType)
    else
        titleIcon:setVisible(false)
    end
    local gender = "aaui_common/dot1.png"
    if data.g == 1 then
        gender = "aaui_icon/icon_boy1.png"
    elseif data.g == 2 then 
        gender = "aaui_icon/icon_girl1.png"
    end
    local genderIcon = zzy.CocosExtra.seekNodeByName(item, "Image_sex")
    genderIcon:loadTexture(gender,ccui.TextureResType.plistType)
    if isSysMsg then
        data.i = Language.src_clickhero_model_ChatModel_3
    end

    local name = zzy.CocosExtra.seekNodeByName(item, "text_name")
    name:setString(data.i)
    local panel1 = zzy.CocosExtra.seekNodeByName(item, "Panel_1")
    panel1:setVisible(not ch.UserTitleModel:isRankTop(data.id))
    
    local name2 = zzy.CocosExtra.seekNodeByName(item, "text_name_1")
    name2:setString(data.i)
    
    local genderIcon2 = zzy.CocosExtra.seekNodeByName(item, "Image_sex1")
    genderIcon2:loadTexture(gender,ccui.TextureResType.plistType)
    local panel2 = zzy.CocosExtra.seekNodeByName(item, "Panel_2")
    panel2:setVisible(ch.UserTitleModel:isRankTop(data.id))
    
    local time = zzy.CocosExtra.seekNodeByName(item, "text_time")
    time:setString(os.date("%H:%M",data.tm))
    local textHeight = content:getContentSize().height + 10
--    local contentBack = zzy.CocosExtra.seekNodeByName(item, "diban_list")
--    contentBack:setContentSize(cc.size(contentBack:getContentSize().width,textHeight))
    local namePanel = zzy.CocosExtra.seekNodeByName(item, "Panel_player")
--    local nameHeight = zzy.CocosExtra.seekNodeByName(item, "img_diban_2"):getContentSize().height
    local nameHeight = 35
    local imgDB = zzy.CocosExtra.seekNodeByName(item, "Image_1")
    local imgHeight = textHeight+10
    if data.guild then
        imgHeight = imgHeight > 55 and imgHeight or 55
    end
    namePanel:setPositionY(imgHeight)
    imgDB:setContentSize(item:getContentSize().width,imgHeight+5)
    item:setContentSize(item:getContentSize().width,nameHeight+imgHeight+5)

    if sysColor then
        name:setColor(sysColor)
        name2:setColor(sysColor)
        time:setColor(sysColor)
        content:setColor(sysColor)
    end
    return item
end

function ChatView:_strLineBreak(node, str, maxWidth)
    local getFontWidth = function(_str, node)
        node:setString(_str)
        return node:getContentSize().width
    end

    local len = #str
    local curWidth = 0
    local curStr = ""
    local beforeCount = 1
    local curLen = 0
    for i=1, len do
        local curByte = string.byte(str,beforeCount)
        local byteCount = 1
        if curByte>=0 and curByte<=127 then
            byteCount = 1
            curLen = curLen + 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
            curLen = curLen + 2
        elseif curByte>=224 and curByte<=239 then
            byteCount = 3
            curLen = curLen + 2
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
            curLen = curLen + 2
        end

        local curChar = string.sub(str, beforeCount, beforeCount + byteCount - 1)
        local fontWidth = getFontWidth(curChar, node)
        curWidth = curWidth + fontWidth
        if curChar=="\n" then
            curWidth = 0
        end

        if curWidth>maxWidth then
            curWidth = fontWidth
            curStr = curStr.."\n"
        end
        curStr = curStr..curChar

        beforeCount = beforeCount + byteCount
        if beforeCount > len then
            break
        end
    end

    return curStr
end

function ChatView:show()
    self._renderer:setVisible(true)
    self._isOpen = true
end

function ChatView:close()
    self._renderer:setVisible(false)
    self._isOpen = false
end

function ChatView:isOpen()
    return self._isOpen
end


return ChatView