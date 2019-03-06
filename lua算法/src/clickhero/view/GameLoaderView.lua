local showSerList = false
local curSverName=""
-- 固有绑定
-- 设置界面  loading
zzy.BindManager:addFixedBind("loading/loading", function(widget) 
    local switchSelPanelEvent = {}
    switchSelPanelEvent[ch.GameLoaderModel.switchServerEventType] =  false
    switchSelPanelEvent[ch.GameLoaderModel.selServerEventType] =  false
    
	
	local settingChangeEvent = {}
    settingChangeEvent[ch.SettingModel.dataChangeEventType] = false
	
    local switchServerEvent = {}
    switchServerEvent[ch.GameLoaderModel.selServerEventType] =  false
    
    
    widget:addDataProxy("visible",function(evt)
        return ch.GameLoaderModel.loadingShow
    end)
    -- 如果不想显示名字，return "loading/loading_dot1.png"
    widget:addDataProxy("titleImage",function(evt)
        local logo = "loading/loading_dot1.png"
        return logo
    end)
    
    widget:addDataProxy("txt_selName",function(evt)
        if evt then
            return evt.data.name
        end
        return  "" 
    end,switchServerEvent)
    
    widget:addDataProxy("tips",function(evt)
        local id = math.random(1,table.maxn(GameConfig.TipsConfig:getTable()))
        return GameConfig.TipsConfig:getData(id).desc
    end)
    
    widget:addDataProxy("progress",function(evt)
        return ch.GameLoaderModel:getProgress()*100
    end)
    
    widget:addDataProxy("serverSelectedVis",function(evt)
        return ch.GameLoaderModel.selectedSerShow
    end) 
    widget:addDataProxy("serverListVis",function(evt)
        return showSerList
    end,switchSelPanelEvent)
    widget:addCommond("openServerSel",function()
        showSerList=true
        zzy.EventManager:dispatch( {type = ch.GameLoaderModel.switchServerEventType})
    end)
    widget:addDataProxy("items1",function(evt)
        return  ch.GameLoaderModel:getLastlySvridList()
    end,switchSelPanelEvent)
    widget:addDataProxy("items2",function(evt)
        return  ch.GameLoaderModel:getSvridList()
    end,switchSelPanelEvent) 
    widget:addDataProxy("txt_loading",function(evt)
        return ch.GameLoaderModel:getLoadingTxt()
    end)
        
    widget:addDataProxy("txt_ver",function(evt)
        return ch.GameLoaderModel:getShowVersion()
    end)
    
    widget:addDataProxy("btnVis",function(evt)
        return ch.GameLoaderModel.btnStartShow
    end)
--    widget:addDataProxy("last1",function(evt)
--        return "last1"
--    end)
--    widget:addDataProxy("last2",function(evt)
--        return "last2"
--    end)
    
    widget:addCommond("startGame",function()
        ch.GameLoaderModel:startGame()
    end)
    
    widget:listen(ch.GameLoaderModel.progressEventType,function(obj,evt)
        widget:noticeDataChange("progress") 
    end)
    
    widget:listen(ch.GameLoaderModel.loadingTxtChangeEventType,function(obj,evt)
        widget:noticeDataChange("txt_loading")
    end) 
    
    widget:listen(ch.GameLoaderModel.loadingShowChangeEventType,function(obj,evt)
        widget:noticeDataChange("visible")
    end) 
    widget:listen(ch.GameLoaderModel.versionChangeEventType,function(obj,evt)
        widget:noticeDataChange("txt_ver")
    end) 
    widget:listen(ch.GameLoaderModel.btnStartShowChangeEventType,function(obj,evt)
        widget:noticeDataChange("btnVis")
    end)
    
    widget:listen(ch.GameLoaderModel.btnLoginShowChangeEventType,function(obj,evt)
        widget:noticeDataChange("showloginBtn")
        widget:noticeDataChange("isLogin")
        widget:noticeDataChange("canChange")
        widget:noticeDataChange("canChangeFB")
        widget:noticeDataChange("isYYB")
        widget:noticeDataChange("canStart")
    end)
    
    widget:listen(ch.GameLoaderModel.selectedSerShowChangeEventType,function(obj,evt)
        widget:noticeDataChange("serverSelectedVis")
    end)
    
    widget:listen(ch.GameLoaderModel.closeNoticeEventType,function(obj,evt)
        widget:noticeDataChange("closeNoticePanel")
    end)
    
    ch.GameLoaderModel.isShowNotice = false
    local webView = nil
    local showWebView = function()
        if (cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE --tgx
            or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD
            or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID) then
            if not webView and  not ch.UIManager.isTipOpen then
                local panel = widget:getChild("Panel_noticeopen:Panel_msgin")
                webView = WebView:create()
                webView:setScalesPageToFit(true)
                panel:addChild(webView)
            
                webView:setAnchorPoint(0,0)
                --webView:setPosition(panel:convertToWorldSpace(cc.p(0,0)))
                webView:setContentSize(cc.size(519,620))
                webView:setPositionX(webView:getPositionX()-9)
                
                webView:loadURL(_G_URL_NOTICE)
            end
        end
        ch.GameLoaderModel.isShowNotice = true
        widget:noticeDataChange("isShowNotice")
    end
    
    local closeWebView = function()
        ch.GameLoaderModel.isShowNotice = false
        widget:noticeDataChange("isShowNotice")
        if webView then
            webView:removeFromParent()
            webView = nil
        end
    end
    
    widget:listen("sdk_event_flashDone",function(obj,evt)
        FLASH_DONE = true
        if LOGIN_DONE then
            showWebView()
        end
    end)
    
    widget:listen("sdk_event_loginDone",function(obj,evt)
        LOGIN_DONE = true
        if FLASH_DONE then
            showWebView()
        end
    end)
    
    widget:addDataProxy("closeNoticePanel",function(evt)
        closeWebView()
        return 0
    end)
    
    widget:addDataProxy("isShowNotice",function(evt)
        return not ch.UIManager.isTipOpen and ch.GameLoaderModel.isShowNotice
    end)
    
    widget:addCommond("changeID",function()
        closeWebView()
       ch.GameLoaderModel:setBtnStartVis(true)
       ch.GameLoaderModel:setBtnLoginVis(true)
       ch.GameLoaderModel:setLoadingShow(false)
	   if cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() then
			zzy.Sdk.changeAccount()
			return 
		end
	    if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" then
			 local info={
              f="fbswitch"
			}
          zzy.Sdk.extendFunc(json.encode(info))
          cclog(json.encode(info))
		else
			 zzy.Sdk.changeAccount()
		end
    end)
    
    widget:addCommond("closeNotice",function()
        closeWebView()
    end)
    
    widget:addCommond("openNotice",function()
        if ch.GameLoaderModel.isShowNotice then return end
        showWebView()
    end)
    
    widget:addCommond("closeServerSel",function(evt)
        showSerList=false
        zzy.EventManager:dispatch( {type = ch.GameLoaderModel.switchServerEventType})
    end)
    
    
    -- 开始游戏按钮出现
    widget:addDataProxy("canStart",function(evt)
        return not ch.GameLoaderModel.btnLoginShow
    end)
    
    widget:addDataProxy("isYYB",function(evt)
        if zzy.Sdk.getFlag()=="HDYYB" or zzy.Sdk.getFlag()=="HDTX" then
             return true
          else  
            return false
          end
    end)
    
    widget:addDataProxy("showloginBtn",function(evt)
        if zzy.Sdk.getFlag()=="HDYYB" or zzy.Sdk.getFlag()=="HDTX" then
            return false
        else  
            return true
        end
    end)
    
    -- 出现登陆按钮界面
    widget:addDataProxy("isLogin",function(evt)
        return ch.GameLoaderModel.btnLoginShow
    end)
    -- 可以切换帐号
    widget:addDataProxy("canChange",function(evt)
	    if cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() then
			return true
		end
        if zzy.Sdk.getFlag()=="HDYYB" or 
           zzy.Sdk.getFlag()=="HDCC"  or 
           zzy.Sdk.getFlag()=="TJIOS" or 
           zzy.Sdk.getFlag()=="HDZY"  or 
           zzy.Sdk.getFlag()=="HDTX" or 
           zzy.Sdk.getFlag()=="HDSG" or 
           zzy.Sdk.getFlag()=="HD7K" or 
           zzy.Sdk.getFlag()=="HDYYH" or 
           zzy.Sdk.getFlag()=="HDOPO"  or 
           zzy.Sdk.getFlag()=="HDMI"  or 
           zzy.Sdk.getFlag()=="HDLEN" or 
		   zzy.Sdk.getFlag()=="HD49" or 
           zzy.Sdk.getFlag()=="HDJL" or
		   string.sub(zzy.Sdk.getFlag(),1,2)=="TJ" or
		   string.sub(zzy.Sdk.getFlag(),1,2)=="WY" or
		   string.sub(zzy.Sdk.getFlag(),1,2)=="CY" or
		   string.sub(zzy.Sdk.getFlag(),1,2)=="WE" or
           zzy.Sdk.getFlag()=="HDMZ" then
            return false
        elseif ch.GameLoaderModel.btnLoginShow then
            return false
        else
			return true
        end
    end)
	 -- 可以切换fb帐号
    widget:addDataProxy("canChangeFB",function(evt)
	    if ch.GameLoaderModel.btnLoginShow then
			return false
		end
		if  string.sub(zzy.Sdk.getFlag(),1,2)=="CY" and cc.PLATFORM_OS_WINDOWS ~= cc.Application:getInstance():getTargetPlatform() then
			return true
		 end
		 return false
	 end,settingChangeEvent)
    widget:addCommond("loginWX",function(evt)
        cclog("微信登陆")
        local loginInfo={
            f="login",
            data={t="WX"}
        }
        zzy.Sdk.extendFunc(json.encode(loginInfo))
    end)
    widget:addCommond("loginQQ",function(evt)
        cclog("QQ登陆")
        local loginInfo={
           f="login",
           data={t="QQ"}
        }
        zzy.Sdk.extendFunc(json.encode(loginInfo))
    end)
    
    widget:addCommond("login",function(evt)
        cclog("sdk登陆")
        zzy.Sdk.openLogin()
    end)
end)
-- 选服单元
zzy.BindManager:addCustomDataBind("loading/W_Serverunit", function(widget,data)
    local switchServerEvent = {}
    switchServerEvent[ch.GameLoaderModel.selServerEventType] =  false
    widget:addDataProxy("unitVis",function(evt)
        return ch.GameLoaderModel:getServerInfoByInd(data).status~=nil  
    end,switchServerEvent)
    widget:addDataProxy("freeVis",function(evt)
        return ch.GameLoaderModel:getServerInfoByInd(data).status==1 
    end,switchServerEvent) 
    widget:addDataProxy("fullVis",function(evt)
        return ch.GameLoaderModel:getServerInfoByInd(data).status==2
    end,switchServerEvent)
    widget:addDataProxy("weihuVis",function(evt)
        return ch.GameLoaderModel:getServerInfoByInd(data).status==0
    end,switchServerEvent)
    widget:addDataProxy("txt_serverName",function(evt)
        return (ch.GameLoaderModel:getServerInfoByInd(data).index).."-"..(ch.GameLoaderModel:getServerInfoByInd(data).name) or ""
    end,switchServerEvent)   
     
    widget:addDataProxy("txt_guanming",function(evt)
        local tag_guanming_Copy = zzy.CocosExtra.seekNodeByName(widget,"tag_guanming_Copy")
        local server = ch.GameLoaderModel:getServerInfoByInd(data)
        if server.title and type(server.title) == "table" and server.title.na then
            tag_guanming_Copy:setString(Language.src_clickhero_view_GameLoaderView_2)
            return string.format(Language.src_clickhero_view_GameLoaderView_1, server.title.na)
        else
            tag_guanming_Copy:setString("")
            return ""
        end
    end)
    widget:addCommond("unitTouch",function()
        cclog("touch unit")
        local info= ch.GameLoaderModel:getServerInfoByInd(data)
        zzy.config.host = info.host
        zzy.config.port = info.port
        zzy.config.svrid = info.svrid
        zzy.config.svrname = info.name
        showSerList=false
        curSverName=info.name
        zzy.EventManager:dispatch( {type = ch.GameLoaderModel.selServerEventType,data=info})
    end)
end)


