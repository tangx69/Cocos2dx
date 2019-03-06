local UIManager = {
    viewPopEventType = "VIEW_POP_EVENT",--{type = ,popType=,view =,}
    popType = {
        HalfOpen = 1,
        Open = 2,
        Close = 3
    },
    bottomPopup = {},   --{layout,status}  status 1正在打开动画，2为半开，3为全开，4正在关闭
    bottomPopupOffsetY = {},
    _fontEventId = nil,
    _mainView = nil,
    _activeSkillView = nil,
    _waitShowCount = nil,
    _waitEventId = nil,
    onePoup=false,--是否是单独的弹出 如果为true不再弹出其余的弹出框
    isTipOpen = false, -- 当前是否有系统提示界面
    isMsgOpen = false, -- 当前是否开着邮件界面
}

UIManager.bottomPopupOffsetY["fuwen/W_FuwenList"] = GameConst.MAINVIEW_OPEN_HALF_POSITION_Y
UIManager.bottomPopupOffsetY["baowu/W_BaowuList"] = GameConst.MAINVIEW_OPEN_HALF_POSITION_Y
UIManager.bottomPopupOffsetY["tuteng/W_TutengList"] = GameConst.MAINVIEW_OPEN_HALF_POSITION_Y
UIManager.bottomPopupOffsetY["Shop/W_shop"] = GameConst.MAINVIEW_OPEN_HALF_POSITION_Y
UIManager.bottomPopupOffsetY["task/W_TaskList"] = GameConst.MAINVIEW_OPEN_HALF_POSITION_Y
UIManager.bottomPopupOffsetY["Guild/W_GuildList"] = GameConst.MAINVIEW_OPEN_HALF_POSITION_Y

local raisePopEvent = function(popType,view)
    local evt = {type = UIManager.viewPopEventType}
    evt.popType = popType
    evt.view = view
    zzy.EventManager:dispatch(evt)
end

local inited = false

local autoFightLayer     -- 自动战斗
local defendLayer        -- 坚守阵地的界面
local activeSkillLayer   -- 技能  
local gamePopupLayer     -- 主界面弹出窗口
local mainViewLayer      -- 主界面
local sysPopupLayer      -- 系统弹框
local navigationLayer    -- 引导 


local noticeShowLayer    -- 滚动屏幕
local waitingLayer       -- 等待圆圈
local msgLayer           -- 消息

function UIManager:loadUIRes(processFunc, completeFunc)
    local plistList = {
        "res/ui/aaui_png/common01",
        "res/ui/aaui_png/common02",
        "res/ui/aaui_png/common03",
        "res/ui/aaui_png/plist_rank",
        "res/ui/aaui_png/plist_mgg",
        "res/ui/aaui_png/plist_card",
        "res/ui/aaui_png/plist_icon",        
    --"res/effect/effect_fuwen_pingji",
    }

    local textureList = {
        "res/ui/aaui_font/font_red.png",
        "res/ui/aaui_font/font_yellow.png",
        "res/ui/aaui_font/font_crtical.png",
        "res/ui/aaui_font/num_boss.png"
    }

    local loadNum = 0
    local totalNum = #plistList + #textureList
    for _,filePath in ipairs(plistList) do
        cc.Director:getInstance():getTextureCache():addImage(filePath..".png", function(texture)
            cc.SpriteFrameCache:getInstance():addSpriteFrames(filePath..".plist")
            loadNum = loadNum + 1
            processFunc(loadNum / totalNum)
            if loadNum == totalNum then
                completeFunc()
            end
        end)
    end

    for _,filePath in ipairs(textureList) do
        cc.Director:getInstance():getTextureCache():addImage(filePath, function(texture)
            texture:retain()
            loadNum = loadNum + 1
            processFunc(loadNum / totalNum)
            if loadNum == totalNum then
                completeFunc()
            end
        end)
    end
    --    -- 加载符文特效
    --    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/effect/effect_fuwen_pingji.xml")
end

function UIManager:init(scene)
    if inited then return end
    inited = true
    
    autoFightLayer = cc.Layer:create()
    scene:addChild(autoFightLayer)
    defendLayer = cc.Layer:create()
    scene:addChild(defendLayer)
    activeSkillLayer = cc.Layer:create()
    scene:addChild(activeSkillLayer)
    
    gamePopupLayer = cc.Layer:create()
    scene:addChild(gamePopupLayer)
    mainViewLayer = cc.Layer:create()
    scene:addChild(mainViewLayer)
    
    sysPopupLayer = cc.Layer:create()
    scene:addChild(sysPopupLayer)
    navigationLayer = cc.Layer:create()
    scene:addChild(navigationLayer)
    
    noticeShowLayer = self:_createNoticeLayout()
    scene:addChild(noticeShowLayer)
    waitingLayer = self:_createWaitingLayout()
    scene:addChild(waitingLayer, 2000)
    self._waitShowCount = 0
    msgLayer = cc.Layer:create()
    scene:addChild(msgLayer)
--    self:initClickLayer(scene)
end

--function UIManager:initClickLayer(scene)
--    local layer = cc.Layer:create()
--    scene:addChild(layer)
--    local listener = cc.EventListenerTouchOneByOne:create()
--    listener:setSwallowTouches(false)
--    local emitter = cc.ParticleSystemQuad:create("res/effect/clickEffect.plist")
--    layer:addChild(emitter)
--    
--    listener:registerScriptHandler(function(touch,event)
--        emitter:setPosition(touch:getLocation())
--        emitter:resetSystem()
--        return false
--    end,cc.Handler.EVENT_TOUCH_BEGAN)
--    local eventDispatcher = layer:getEventDispatcher()
--    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
--end

function UIManager:getDefendLayer()
    return defendLayer
end

function UIManager:getAutoFightLayer()
    return autoFightLayer
end

function UIManager:getActiveSkillLayer()
    return activeSkillLayer
end

function UIManager:getGamePopupLayer()
    return gamePopupLayer
end

function UIManager:getMainViewLayer()
    return mainViewLayer
end

function UIManager:getNavigationLayer()
    return navigationLayer
end

function UIManager:getSysPopupLayer()
    return sysPopupLayer
end

---
-- @function [parent=#UIManager] showMsgBox
-- @param #number type 1为只有“确认”， 2为有"确认"和"取消'
-- @param #boolean isClose true确认后关闭，false确认后不关闭
-- @param #string message 要显示的文字
-- @param #function func1 回调函数 确认
-- @param #function func2 回调函数 取消 
-- @param #string text 按钮显示文字
-- @param #number txtType 只有2有效
function UIManager:showMsgBox(type,isClose,msg,func1,func2,text,txtType)
    if self.onePoup then
        cclog("exist onePoup")
        return
    end
    
    cclog("showMsgBox:"..tostring(ch.GameLoaderModel.loadingCom))
    text = text or Language.MSG_BUTTON_OK
    self.isTipOpen = true
    if ch.GameLoaderModel.loadingCom then   
        local widget = nil
        if type == 1 then
            if widget then
                widget:destory()
            end
            widget = zzy.uiViewBase:new("Common/W_reconnect",{isClose=isClose,msg=msg,func1=func1,text=text})
            self:getNavigationLayer():addChild(widget)
        elseif type == 2 then
            if widget then
                widget:destory()
            end
            widget = zzy.uiViewBase:new("Common/W_Poperror",{isClose=isClose,msg=msg,func1=func1,text=text,txtType=txtType})
            self:getNavigationLayer():addChild(widget)
            _G_SHOW_EXIT = widget
        end
    else
        self:showPopTips(msg,func1,text,isClose)
    end
    
    if ch.GameLoaderModel.isShowNotice or self.isMsgOpen then
        zzy.EventManager:dispatch( {type = ch.GameLoaderModel.closeNoticeEventType})
        cclog("关掉WebView界面")
    end
end

function UIManager:closeMsgBox()
    ch.UIManager.isTipOpen = false
    for k,v in pairs(self:getNavigationLayer():getChildren()) do
        if v.destory then
            v:destory()
        end
    end
    --self:getNavigationLayer():removeAllChildren()
    zzy.EventManager:dispatch( {type = ch.GameLoaderModel.closeNoticeEventType})
end

---
--弹出W_tips的提示  只有loading之前使用
-- @function [parent=#UIManager] showPopTips
-- @param #string message 要显示的文字
-- @param #function func 回调函数
-- @param #string text 按钮显示文字
-- @param #boolean isClose
function UIManager:showPopTips(message,func,text,isClose)
    text = text or Language.MSG_BUTTON_OK
    cc.Director:getInstance():getTextureCache():addImage("res/ui/tips/plist_tips.png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/tips/plist_tips.plist")
    local render = cc.CSLoader:createNode("res/ui/tips/W_tips.csb","res/ui/")
    local label = zzy.CocosExtra.seekNodeByName(render, "text_message")
    label:setString(message)
    local btn = zzy.CocosExtra.seekNodeByName(render,"Button_qingchu")
    btn:setTitleText(text)    
    btn:addTouchEventListener(function(sender, evnentType)
        if evnentType == ccui.TouchEventType.ended then
            if isClose then
                self.isTipOpen = false
                render:removeFromParent()
            end
            if func then
                func()
            end
        end
    end)
    --    self:addPage(render,true)
    ch.LoginView.gameScene:addChild(render)
--    cc.Director:getInstance():getRunningScene():addChild(render)
    render:setLocalZOrder(1002)
end

function UIManager:showGamePopup(...)
    local args = {...}
    
    
    if args[1] == "card/W_card_get" then
        return --tgx 不显示长安弹出的大图
    end
    
    local layout,widget = self:_addPopup(...)
    widget:setScale(0.5,0.5)
    widget:setAnchorPoint(0.5,0.5)
    local size = layout:getContentSize()
    widget:setPosition(size.width/2,size.height/2)
    local animation = cc.EaseElasticOut:create(cc.ScaleTo:create(0.6,1),0.5)
    widget:runAction(animation)
    layout.csbName = args[1]
    if not layout:getParent() then
        sysPopupLayer:addChild(layout)
    end
end

function UIManager:showBottomPopup(...)
    local args = {...}
    if self.bottomPopup[args[1]] and self.bottomPopup[args[1]].status ~= 4 then --打开
        self:closeBottomPopup(args[1])
    else
        for k,v in pairs(self.bottomPopup) do -- 关闭其他
            if k ~= args[1] then
                self:closeBottomPopup(k)
            end
        end
        local layout,widget = nil,nil
        if self.bottomPopup[args[1]] then
            layout = self.bottomPopup[args[1]].layout
            if self.bottomPopup[args[1]].status == 4 then -- 正在关闭
                self.bottomPopup[args[1]].layout:stopAllActions()
            end
            self.bottomPopup[args[1]].status = 1
        else
            args[5] = args[1]
            layout,widget = self:_addPopup(unpack(args,1,5))
            if not layout:getParent() then
                gamePopupLayer:addChild(layout)
            end
            layout:setTouchEnabled(false)
            layout:setOpacity(0)
            self.bottomPopup[args[1]] = {layout = layout,status = 1}
        end
        layout.isBottomPop = true
        local y = 0
        if self.bottomPopupOffsetY[args[1]] then
            y = self.bottomPopupOffsetY[args[1]]
        end
        local x = layout:getPositionX()
        local size = layout:getContentSize()
        layout:setPositionY(-size.height)
        local animation = cc.MoveTo:create(0.3,cc.p(x,y))
        animation = cc.EaseBackOut:create(animation)
        local callf = cc.CallFunc:create(function()
            self.bottomPopup[args[1]].status = y == 0 and 3 or 2
        end)
        layout:runAction(cc.Sequence:create(animation,callf))
        local popType = y == 0 and self.popType.Open or self.popType.HalfOpen
        raisePopEvent(popType,args[1])
    end
end

function UIManager:getBottomWidget(name)
    if self.bottomPopup[name] and self.bottomPopup[name].layout:getChildren()[1] then
        return self.bottomPopup[name].layout:getChildren()[1]
    end
    for _,w in pairs(sysPopupLayer:getChildren()) do
        if w.csbName == name then
            return w:getChildren()[1]
        end
    end
end

function UIManager:addActiveSkillView()
    if not self._activeSkillView then
        self._activeSkillView = zzy.uiViewBase:new("MainScreen/W3_Skill")
        ch.UIManager:getActiveSkillLayer():addChild(self._activeSkillView)
    end
end

function UIManager:getActiveSkillView()
    return self._activeSkillView
end

function UIManager:addMainView()
    if not self._mainView then
        self._mainView = zzy.uiViewBase:new("MainScreen/S_MainScene")
        ch.UIManager:getMainViewLayer():addChild(self._mainView)
    end
end

function UIManager:getMainView()
    return self._mainView
end

function UIManager:closeBottomPopup(csb)
    if not self.bottomPopup[csb] or self.bottomPopup[csb].status == 4 then return end
    local layout = self.bottomPopup[csb].layout
    if layout then
        if self.bottomPopup[csb].status == 1 then
            layout:stopAllActions()
        end
        self.bottomPopup[csb].status = 4
        local size = layout:getContentSize()
        local x = layout:getPositionX()
        local animation = cc.MoveTo:create(0.3,(cc.p(x,-size.height)))
        local callf = cc.CallFunc:create(function()
            layout:destory()
            self.bottomPopup[csb] = nil
            raisePopEvent(self.popType.Close,csb)
        end)
        local seq = cc.Sequence:create(animation,callf)
        layout:runAction(seq)
    end
end

function UIManager:BottomUp(csb)
    local layout = self.bottomPopup[csb].layout
    local x = layout:getPositionX()
    self.bottomPopup[csb].status = 1
    self.bottomPopupOffsetY[csb] = 0
    local animation = cc.MoveTo:create(0.3,(cc.p(x,0)))
    animation = cc.EaseBackOut:create(animation)
    local callf = cc.CallFunc:create(function()
        self.bottomPopup[csb].status = 3
    end)
    layout:runAction(cc.Sequence:create(animation,callf))
    raisePopEvent(self.popType.Open,csb)
end

function UIManager:BottomDown(csb)
    local layout = self.bottomPopup[csb].layout
    local x = layout:getPositionX()
    self.bottomPopup[csb].status = 1
    self.bottomPopupOffsetY[csb] = GameConst.MAINVIEW_OPEN_HALF_POSITION_Y
    local animation = cc.MoveTo:create(0.3,(cc.p(x,GameConst.MAINVIEW_OPEN_HALF_POSITION_Y)))
    animation = cc.EaseBackOut:create(animation)
    local callf = cc.CallFunc:create(function()
        raisePopEvent(self.popType.HalfOpen,csb)
        self.bottomPopup[csb].status = 2
    end)
    local seq = cc.Sequence:create(animation,callf)
    layout:runAction(seq)
end

function UIManager:_addPopup(...)
    local widget = zzy.uiViewBase:new(...)
    local layout = ccui.Layout:create()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local widgetSize = widget:getContentSize()
    local x = (visibleSize.width - widgetSize.width)/2
    local y = (visibleSize.height - widgetSize.height)/2
    widget:setPosition(x,y)
    layout:setContentSize(visibleSize)
    layout:setTouchEnabled(true)
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    layout:setBackGroundColor(cc.c3b(0,0,0))
    layout:setOpacity(150)
    widget:addMask(layout)
    layout.destory = function()
        widget:destory()
    end
    return layout,widget
end

function UIManager:_addPopupOverMain(...)
    local widget = zzy.uiViewBase:new(...)
    local layout = ccui.Layout:create()
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    layout:setBackGroundColor(cc.c3b(0,0,0))
    layout:setOpacity(150)
    widget:setScale(0.5,0.5)
    widget:setAnchorPoint(0.5,0.5)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    widget:setPosition(visibleSize.width/2,visibleSize.height/2)
    layout:setContentSize(visibleSize)
    layout:setTouchEnabled(true)
    widget:addMask(layout)
    local animation = cc.EaseElasticOut:create(cc.ScaleTo:create(0.6,1),0.5)
    widget:runAction(animation)
    if not layout:getParent() then
        msgLayer:addChild(layout)
    end
    layout.destory = function()
        widget:destory()
    end
    return layout,widget
end

-- isForce 为真时，底部弹出框无动画关闭，为false，会有动画
-- onlyPop 为真时，仅关闭非底部弹出的界面
function UIManager:cleanGamePopupLayer(isForce,onlyPop)
    if inited then
        for _,pop in ipairs(sysPopupLayer:getChildren()) do
            if pop.destory then
                pop:destory()
            end
        end
        for _,pop in ipairs(gamePopupLayer:getChildren()) do
            if not pop.isBottomPop then
                pop:destory()
            end
        end
        for _,pop in ipairs(msgLayer:getChildren()) do
            if not pop.isBottomPop then
                pop:destory()
            end
        end
        if not onlyPop then
            if isForce then
                for k,v in pairs(self.bottomPopup) do
                    local widget = self.bottomPopup[k].layout
                    self.bottomPopup[k] = nil
                    widget:destory()
                    raisePopEvent(self.popType.Close,k) 
                end
            else
                for k,v in pairs(self.bottomPopup) do
                    self:closeBottomPopup(k)
                end
            end
        end
        if ch.ChatView:hasInstanse() then
            ch.ChatView:getInstanse():close()
        end
    end
end

-- 关闭指定界面
function UIManager:closeGamePopupLayer(csbName)
    if inited then
        for _,pop in ipairs(sysPopupLayer:getChildren()) do
            if pop.destory and pop.csbName == csbName then
                pop:destory()
                break
            end
        end
        for _,pop in ipairs(gamePopupLayer:getChildren()) do
            if pop.destory and pop.csbName == csbName then                
                pop:destory()
                break
            end
        end
        for _,pop in ipairs(msgLayer:getChildren()) do
            if pop.destory and pop.csbName == csbName then                
                pop:destory()
                break
            end
        end
    end
end

local textList = {}

function UIManager:showNotice(text,c4b)
    noticeShowLayer:setVisible(true)
    noticeShowLayer:runAction(cc.FadeTo:create(1,112))
    if not self._fontEventId then
        local font = self:_createFont(text,c4b)
        noticeShowLayer:addChild(font)
        self._fontEventId = zzy.EventManager:listen(zzy.Events.TickEventType,function()
            local children = noticeShowLayer:getChildren()
            if #children > 0 then
                for _,c in ipairs(children) do
                    local x = c:getPositionX() - 5
                    if x + c:getContentSize().width/2 < 0 then
                        c:removeFromParent()
                    else
                        c:setPositionX(x)
                    end
                end
            else
                if #textList > 0 then
                    local data = textList[1]
                    local font = self:_createFont(data.t,data.c)
                    noticeShowLayer:addChild(font)
                    table.remove(textList,1)
                else
                    noticeShowLayer:setVisible(false)
                    noticeShowLayer:setOpacity(0)
                    zzy.EventManager:unListen(self._fontEventId)
                    self._fontEventId = nil
                end
            end
        end)
    else
        table.insert(textList,{t=text,c=c4b})  
    end
end

function UIManager:showWaiting(ifShow,cleanAll)
    if cleanAll then
        self._waitShowCount = 0
    elseif ifShow then
        self._waitShowCount = self._waitShowCount + 1
    else
        self._waitShowCount = self._waitShowCount - 1
        if self._waitShowCount < 0 then
            self._waitShowCount = 0
        end
    end
    if ifShow and self._waitShowCount == 1 then -- 打开
        waitingLayer:setVisible(true)
        waitingLayer:setTouchEnabled(true)
        self._waitEventId = zzy.TimerUtils:setTimeOut(0.2,function()
            self._waitEventId = nil
            zzy.EffectResManager:loadResource("effect_tx_dengdai")
            local armatureZQ = ccs.Armature:create("tx_dengdai")
            armatureZQ:getAnimation():play("Animation1",-1,1)
            local winSize = cc.Director:getInstance():getWinSize()
            armatureZQ:setPosition(winSize.width/2, winSize.height/2)
            waitingLayer:addChild(armatureZQ)
        end)
    elseif self._waitShowCount == 0 then        -- 关闭
        waitingLayer:setVisible(false)
        waitingLayer:setTouchEnabled(false)
        if self._waitEventId then
            zzy.TimerUtils:cancelTimeOut(self._waitEventId)
        else
            waitingLayer:removeAllChildren()
            zzy.EffectResManager:releaseResource("effect_tx_dengdai")
        end
    end
end

function UIManager:_createNoticeLayout()
    local layer = ccui.Layout:create()
    layer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    layer:setBackGroundColor(cc.c3b(0,0,0))
    layer:setOpacity(112)
    layer:setContentSize(cc.size(640,55))
    if USE_SPINE then
        layer:setPosition(0,925)
    else
        layer:setPosition(0,825)
    end
    
    layer:setVisible(false)
    return layer
end

function UIManager:_createWaitingLayout()
    local layer = ccui.Layout:create()
    layer:setContentSize(cc.Director:getInstance():getWinSize())
    layer:setVisible(false)
    return layer
end

function UIManager:_createFont(text,c4b)
    local font = ccui.Text:create("",nil,27)
    font:setString(text)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local x = visibleSize.width+font:getContentSize().width/2
    local y = noticeShowLayer:getContentSize().height/2
    font:setPosition(x,y)
    if c4b then
        font:setTextColor(c4b)
    end
    return font
end

--tip提示
function UIManager:showUpTips(text)
    local render = cc.CSLoader:createNode("res/ui/tips/W_tips2.csb","res/ui/")
    local label = zzy.CocosExtra.seekNodeByName(render, "text_msg")
    label:setString(text)
    self:getSysPopupLayer():addChild(render)
    render:setPosition(120,100)

    local moveTip = cc.MoveTo:create(0.6,cc.p(120,400))
    local easeMove = cc.EaseSineOut:create(moveTip)
    local tipFadeOut = cc.FadeOut:create(0.4)
    local moveTipSq = cc.Sequence:create(easeMove,tipFadeOut,cc.CallFunc:create(function()
        render:removeFromParent()
        render = nil
    end))
    render:runAction(moveTipSq)
end

-- 带标题的通用框btn1单按钮2双按钮，isClose确定关闭，title标题，tips提示信息，func1确定，func2取消
function UIManager:showTitleTips(btn,isClose,title,tips,func1,func2)
    local tmp = {btn=btn,isClose=isClose,title=title,tips=tips,func1=func1,func2=func2}

    ch.UIManager:showGamePopup("Common/W_title_tips",tmp)
end



return UIManager
