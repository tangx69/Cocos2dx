local selectId = 1
---
-- 消息界面
zzy.BindManager:addFixedBind("msg/W_Msg",function(widget)
    ch.MsgModel.objwebView = nil
    local dataChangeEvent = {}
    dataChangeEvent[ch.MsgModel.dataChangeEventType] = false
    
    widget:addDataProxy("selectId",function(evt)
        for i=1,3 do
            if ch.MsgModel:ifShowType(tostring(i)) then
                selectId = i
                return i
            end
        end
        selectId = 1
        return 1
    end)
    
--    widget:addDataProxy("tab_data1",function(evt)
--        local ifShow = ch.MsgModel:ifShowType("1")
--        if ifShow then
--            selectId = 1
--        end
--        return ifShow
--    end)
--    widget:addDataProxy("tab_data2",function(evt)
--        local ifShow = ch.MsgModel:ifShowType("2")
--        if ifShow then
--            selectId = 2
--        end
--        return ifShow
--    end)
--    widget:addDataProxy("tab_data3",function(evt)
--        local ifShow = ch.MsgModel:ifShowType("3")
--        if ifShow then
--            selectId = 3
--        end
--        return ifShow
--    end)
    
    widget:addDataProxy("new_yes_notice",function(evt)
        return ch.MsgModel:ifHaveNewType("1")
    end, dataChangeEvent)
    
    widget:addDataProxy("new_num_notice",function(evt)
        return ch.MsgModel:numNewType("1")
    end, dataChangeEvent)
    widget:addDataProxy("new_yes_system",function(evt)
        return ch.MsgModel:ifHaveNewType("2")
    end, dataChangeEvent)
    widget:addDataProxy("new_num_system",function(evt)
        return ch.MsgModel:numNewType("2")
    end, dataChangeEvent)
    widget:addDataProxy("new_yes_friend",function(evt)
        return ch.MsgModel:ifHaveNewType("3")
    end, dataChangeEvent)
    widget:addDataProxy("new_num_friend",function(evt)
        return ch.MsgModel:numNewType("3")
    end, dataChangeEvent)
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_MsgView_1
    end)
    widget:addCommond("gotoSystem",function()
        if selectId ~= 2 then
            if ch.MsgModel:getDataState(2) then
                ch.NetworkController:msgPanel(2)
            end
            selectId = 2
        end
    end)
    widget:addCommond("gotoActivity",function()
        cclog("切换到活动消息")
    end)
    widget:addCommond("gotoFriend",function()
        if selectId ~= 3 then
            if ch.MsgModel:getDataState(3) then
                ch.NetworkController:msgPanel(3)
            end
            selectId = 3
        end
    end)
    
    widget:listen(ch.GameLoaderModel.closeNoticeEventType,function(obj,evt)
        ch.UIManager.isMsgOpen = false
        widget:destory()
    end)
    widget:addCommond("close",function()
        ch.UIManager.isMsgOpen = false
        widget:destory()
    end)
end)

---
--活动公告列表界面
zzy.BindManager:addFixedBind("msg/W_MsgIn1",function(widget)
    local platform = cc.Application:getInstance():getTargetPlatform() 
    if platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_ANDROID   then
        if not ch.MsgModel.objwebView then
            local webView = WebView:create()
            webView:setScalesPageToFit(true)
            ch.MsgModel.objwebView = webView
            widget:addChild(ch.MsgModel.objwebView)
            --webView:setAnchorPoint(0,0)
            webView:setContentSize(cc.size(580,644))
            webView:setPosition(320,557)
            webView:setVisible(true)
            webView:loadURL(_G_URL_NOTICE)
        end
    end
   
--    local dataChangeEvent = {}
--    dataChangeEvent[ch.MsgModel.dataChangeEventType] = false
--    
--    widget:addDataProxy("msg_list", function(evt)
--        local ret = {}
--        for k,v in ipairs(ch.MsgModel:listType("1")) do
--            table.insert(ret,{index = 1, value = v, isMultiple = false})
--        end
--        return ret
--    end, dataChangeEvent)
--    widget:addCommond("getAllAttachments",function()
--        ch.MsgModel:getAllAttachments()
--    end)
end)

---
--系统消息列表界面
zzy.BindManager:addFixedBind("msg/W_MsgIn2",function(widget)
    local dataChangeEvent = {}
    dataChangeEvent[ch.MsgModel.dataChangeEventType] = false
    
    widget:addDataProxy("msg_list", function(evt)
--        local items = {}
--        for k,v in pairs(ch.MsgModel:listType("2")) do
--            table.insert(items,v)
--        end
        local ret = {}
        for k,v in ipairs(ch.MsgModel:listType("2")) do
            table.insert(ret,{index = 1, value = v, isMultiple = false})
        end
        return ret
    end, dataChangeEvent)
    widget:addDataProxy("allattachments_yes",function(evt)
--        return ch.MsgModel:ifAttachments("2")
        return ch.MsgModel:ifHaveNewType("2") or ch.MsgModel:ifAttachments("2")
    end, dataChangeEvent)
    widget:addCommond("getAllAttachments",function()
        -- 一键已读并领取
        ch.MsgModel:allMsgRead("2")
        if ch.MsgModel:ifAttachments("2") then
            ch.MsgModel:getAllAttachments("2")
        end
    end)
end)

---
--社交消息列表界面
zzy.BindManager:addFixedBind("msg/W_MsgIn3",function(widget)
    local dataChangeEvent = {}
    dataChangeEvent[ch.MsgModel.dataChangeEventType] = false

    widget:addDataProxy("msg_list", function(evt)
--        local items = {}
--        for k,v in pairs(ch.MsgModel:listType("3")) do
--            table.insert(items,v)
--        end
        local ret = {}
        for k,v in ipairs(ch.MsgModel:listType("3")) do
            table.insert(ret,{index = 1, value = v, isMultiple = false})
        end
        return ret
    end, dataChangeEvent)
    widget:addDataProxy("allattachments_yes",function(evt)
--        return ch.MsgModel:ifAttachments("3")
        return ch.MsgModel:ifHaveNewType("3") or ch.MsgModel:ifAttachments("3")
    end, dataChangeEvent)
    widget:addCommond("getAllAttachments",function()
        -- 一键已读并领取
        ch.MsgModel:allMsgRead("3")
        if ch.MsgModel:ifAttachments("3") then
            ch.MsgModel:getAllAttachments("3")
        end
    end)
end)

---
-- 社交消息单元
zzy.BindManager:addCustomDataBind("msg/W_MsgFriend",function(widget,data)
    local config = ch.MsgModel:msgData("3",tostring(data.value))
    widget:listen(ch.MsgModel.dataChangeEventType,function(obj,evt)
        config = ch.MsgModel:msgData("3",tostring(data.value))
        widget:noticeDataChange("msgid")
        widget:noticeDataChange("icon")
        widget:noticeDataChange("title")
        widget:noticeDataChange("read_no")
        widget:noticeDataChange("read_yes")
        widget:noticeDataChange("attachments_yes")
        widget:noticeDataChange("attachments_get")
        widget:noticeDataChange("link_yes")
    end)

    widget:addDataProxy("msgid",function(evt)
        return {type=3,id = config.id}
    end)
    widget:addDataProxy("icon",function(evt)
--        return GameConst.MSG_ICON[tonumber(config.icon)]
        return ch.MsgModel:getMsgIcon("3",tostring(data.value))
    end)
    widget:addDataProxy("title",function(evt)
        return config.title or config.text --fix bug
    end)
    widget:addDataProxy("read_no",function(evt)
        if tostring(config.dq) == "1" then
            widget:playEffect("tagMsgFriendNew",true)
        else
            widget:stopEffect("tagMsgFriendNew")
        end
        return tostring(config.dq) == "1"
    end)
    widget:addDataProxy("read_yes",function(evt)
        return tostring(config.dq) == "2"
    end)
    widget:addDataProxy("attachments_yes",function(evt)
        local attachments_yes = false
        if config.fjs and config.fjs == 2 then
            attachments_yes = true
        end
        return attachments_yes
    end)
    widget:addDataProxy("attachments_get",function(evt)
        local attachments_get = false
        if config.fjs and config.fjs == 3 then
            attachments_get = true
        end
        return attachments_get
    end)
    widget:addDataProxy("link_yes",function(evt)
        return tostring(config.tz) ~= "0"
    end)
end)

---
-- 活动公告单元(废弃)
zzy.BindManager:addCustomDataBind("msg/W_MsgNotice",function(widget,data)
    local config = ch.MsgModel:msgData("1",tostring(data.value))
    widget:listen(ch.MsgModel.dataChangeEventType,function(obj,evt)
        config = ch.MsgModel:msgData("1",tostring(data.value))
        widget:noticeDataChange("msgid")
        widget:noticeDataChange("icon")
        widget:noticeDataChange("title")
        widget:noticeDataChange("read_no")
        widget:noticeDataChange("read_yes")
        widget:noticeDataChange("attachments_yes")
        widget:noticeDataChange("attachments_get")
        widget:noticeDataChange("link_yes")
        widget:noticeDataChange("open_yes")
        widget:noticeDataChange("close_yes")
    end)
       
    widget:addDataProxy("icon",function(evt)
--        return GameConst.MSG_ICON[tonumber(config.icon)]
        return ch.MsgModel:getMsgIcon("1",tostring(data.value))
    end)
    widget:addDataProxy("title",function(evt)
        return config.title
    end)
    widget:addDataProxy("text",function(evt)
        return config.text
    end)
    widget:addDataProxy("read_no",function(evt)
        return tostring(config.dq) == "1"
    end)
    widget:addDataProxy("read_yes",function(evt)
        return tostring(config.dq) == "2"
    end)
    widget:addDataProxy("attachments_yes",function(evt)
        local attachments_yes = false
        if config.fj and table.maxn(config.fj) > 0 then
        	attachments_yes = true
        end
        return attachments_yes
    end)
    widget:addDataProxy("attachments_get",function(evt)
        local attachments_get = true
        if config.fj and table.maxn(config.fj) > 0 then
            attachments_get = false
        end
        return attachments_get
    end)
    widget:addDataProxy("link_yes",function(evt)
        return tostring(config.tz) ~= "0"
    end)
    widget:addDataProxy("open_yes",function(evt)
        return config.open
    end)
    widget:addDataProxy("close_yes",function(evt)
        return config.open == false
    end)
    widget:addCommond("openCard",function()
        ch.MsgModel:openCard(1,tostring(data), true)
    end)
    widget:addCommond("getAttachments",function()
        ch.MsgModel:getAttachments(1,tostring(data))
    end)
    widget:addCommond("closeCard",function()
        ch.MsgModel:openCard(1,tostring(data), false)
    end)
    widget:addCommond("goTo",function()
        cclog("前往")
    end)
end)

---
-- 系统消息单元
zzy.BindManager:addCustomDataBind("msg/W_MsgSystem",function(widget,data)    
    local config = ch.MsgModel:msgData("2",tostring(data.value))
    widget:listen(ch.MsgModel.dataChangeEventType,function(obj,evt)
        config = ch.MsgModel:msgData("2",tostring(data.value))
        widget:noticeDataChange("msgid")
        widget:noticeDataChange("icon")
        widget:noticeDataChange("title")
        widget:noticeDataChange("read_no")
        widget:noticeDataChange("read_yes")
        widget:noticeDataChange("attachments_yes")
        widget:noticeDataChange("attachments_get")
        widget:noticeDataChange("link_yes")
    end)
    widget:addDataProxy("msgid",function(evt)
        return {type=2,id = config.id}
    end)
    widget:addDataProxy("icon",function(evt)
--        return GameConst.MSG_ICON[tonumber(config.icon)]
        return ch.MsgModel:getMsgIcon("2",tostring(data.value))
    end)
    widget:addDataProxy("title",function(evt)
        return config.title
    end)
    widget:addDataProxy("read_no",function(evt)
        if tostring(config.dq) == "1" then
            widget:playEffect("tagMsgSysNew",true)
        else
            widget:stopEffect("tagMsgSysNew")
        end
        return tostring(config.dq) == "1"
    end)
    widget:addDataProxy("read_yes",function(evt)
        return tostring(config.dq) == "2"
    end)
    widget:addDataProxy("attachments_yes",function(evt)
        local attachments_yes = false
        if config.fjs and config.fjs == 2 then
            attachments_yes = true
        end
        return attachments_yes
    end)
    widget:addDataProxy("attachments_get",function(evt)
        local attachments_get = false
        if config.fjs and config.fjs == 3 then
            attachments_get = true
        end
        return attachments_get
    end)
    widget:addDataProxy("link_yes",function(evt)
        return tostring(config.tz) ~= "0"
    end)
    widget:addCommond("goTo",function()
        cclog("前往")
    end)
end)
---
-- 单元内容
zzy.BindManager:addCustomDataBind("msg/W_MsgContent2",function(widget,data)
    local config = ch.MsgModel:msgData(tostring(data.type),tostring(data.id))
    widget:listen(ch.MsgModel.dataChangeEventType,function(obj,evt)
        config = ch.MsgModel:msgData(tostring(data.type),tostring(data.id))
        widget:noticeDataChange("content_change")
        widget:noticeDataChange("title")
        widget:noticeDataChange("attachments_yes")
        widget:noticeDataChange("attachments_get")
        widget:noticeDataChange("link_yes")
    end)
    if tostring(config.dq) == "1" then
        ch.MsgModel:openCard(data.type,tostring(data.id), true)
    end
    
    widget:addDataProxy("title",function(evt)
        return config.title
    end)
    widget:addDataProxy("attachments_yes",function(evt)
        local attachments_yes = false
        if config.fjs and config.fjs == 2 then
            attachments_yes = true
        end
        return attachments_yes
    end)
    widget:addDataProxy("attachments_get",function(evt)
        local attachments_get = false
        if config.fjs and config.fjs == 3 then
            attachments_get = true
        end
        return attachments_get
    end)
    widget:addDataProxy("link_yes",function(evt)
        return tostring(config.tz) ~= "0"
    end)
    widget:addCommond("getAttachments",function()
        ch.MsgModel:getAttachments(data.type,tostring(data.id))
        widget:destory()
    end)
    widget:addCommond("goTo",function()
        ERROR("前往功能还没有")
        
    end)
    widget:addCommond("close",function()
        widget:destory()
    end)
    
    local content_func = function(widget,config)
        local listView_1 = zzy.CocosExtra.seekNodeByName(widget,"ListView_1")
        --listView_1:removeAllItems()
        local item = listView_1:getItem(0)
        if item then
            item:removeFromParent()
            listView_1:removeItem(0)
        end
        --local str = "    从第70关开始，每个魔王都可能掉落英雄魂石。关卡数越高，可能掉落的英雄魂石也越多。\n    英雄魂石不可直接使用，但在转生后，你的所有英雄魂石都将等量转化为英雄之魂。\n    消耗英雄之魂可以用来召唤图腾，或用于升级图腾。\n    另外，你保存的每一个英雄之魂，都会使你的英雄攻击力和宠物攻击力各+10%哦。\n    对了，当你转生时，你的宠物和所有宝物的等级之和，会按照每2000折算为1魂石的比例在转生后形成英雄之魂。所以转生前请别忘记尽量升级你的宠物和宝物。\n    嗯，谢谢你看完这封信，送上2个英雄之魂，请继续勇敢的挑战大魔王们吧！"
        local str = config.text
        --local str = "    从第u001a70关u001a开"
        str = string.gsub(str, "u001a", "\n")
        local textsize = zzy.StringUtils:countTextHeight(22,440,str)
        --textsize = textsize * 0.94
        --local textsize = textFieldT:getContentSize().height
        local content = ccui.Layout:create()
        local img_bg = ccui.ImageView:create()
        img_bg:loadTexture("aaui_mgg/msgdb_1.png", ccui.TextureResType.plistType)
        content:addChild(img_bg)
        local textField = ccui.Text:create()
        textField:ignoreContentAdaptWithSize(false)
        textField:setAnchorPoint(0,1)
        textField:setContentSize(cc.size(440,textsize))
        textField:setFontSize(22)
        textField:setFontName("res/ui/aaui_font/ch.ttf")
        --textField:setString(config.text)
        textField:setString(str)
        
        
        content:addChild(textField)
        --local textsize = textField:getContentSize()
        --local textsize = zzy.StringUtils:countTextHeight(22,480,tostring(config.text))
        
        local textH = 0
        local initX = 5
        local iconX = 0
        local count = 0
        local unit = {}
        local unitH = {}
        if config.fj and table.maxn(config.fj) > 0 then
            local layer
            for kf,vf in ipairs(config.fj) do
                layer,iconX = ch.MsgModel:getIconUnit(ch.CommonFunc:getRewardIcon(tonumber(vf.t),vf.id),ch.CommonFunc:getRewardName(tonumber(vf.t),vf.id).." "..ch.CommonFunc:getRewardValue(tonumber(vf.t),vf.id,vf.num))
                table.insert(unitH,iconX)
                table.insert(unit,layer)
                content:addChild(layer)
                count = count + 1
                
--                if tostring(vf.t) == "1" then --代币
--                    iconType = GameConst.MSG_FJ_ICON[1]["db"..tonumber(vf.id)]
--                    layer,iconX = ch.MsgModel:getIconUnit(iconType, ch.NumberHelper:toString(vf.num))
--                    table.insert(unitH,iconX)
--                    table.insert(unit,layer)
--                    content:addChild(layer)
--                    count = count + 1
--                elseif tostring(vf.t) == "2" then --宠物
--                    for i = 1, tonumber(vf.num) do
--                        iconType = GameConst.MSG_FJ_ICON[2]["cw"..tonumber(vf.id)]
--                        layer,iconX = ch.MsgModel:getIconUnit(iconType, vf.num)
--                        table.insert(unitH,iconX)
--                        table.insert(unit,layer)
--                        content:addChild(layer)
--                        count = count + 1
--                end
--                elseif tostring(vf.t) == "3" then --buff
--                    iconType = GameConst.MSG_FJ_ICON[3]["bf"..tonumber(vf.id)]
--                    layer,iconX = ch.MsgModel:getIconUnit(iconType, vf.num.."秒")
--                    table.insert(unitH,iconX)
--                    table.insert(unit,layer)
--                    content:addChild(layer)
--                    count = count + 1
--                end
            end
            textH = count*35 + 40
            for k,v in ipairs(unit) do
                v:setPosition(initX,textH)
                textH = textH - unitH[k]
            end
        end
        textField:setPosition(10,textsize+count*35 + 80 - 5)
        --img.setSize(cc.size(300,200)); 
        --img.setScale9Enabled(true); 
        --img.setCapInsets( cc.rect(30,30,30,30) ); 
        img_bg:setScale9Enabled(true)
        img_bg:setContentSize(cc.size(460,textsize+count*35 + 80))
        img_bg:setAnchorPoint(0,1)
        img_bg:setPosition(0,textsize+count*35 + 80)
        content:setContentSize(cc.size(480,textsize+count*35 + 80))
        content:setAnchorPoint(0,1)
        listView_1:insertCustomItem(content,0)
        --ccui.ListView:create()
    end
    
    widget:addDataProxy("content_change", function(evt)
        content_func(widget,config)
    end)
end)