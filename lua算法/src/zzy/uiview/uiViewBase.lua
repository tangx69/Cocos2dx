local uiViewBase = {}
local _cache = {}

uiViewBase.DEFAULT_CSB_PATH_BASE = "res/"

function uiViewBase:new(csb, data, widget, basePath, cacheKey,isOnlyCache)
    if cacheKey and _cache[cacheKey] then
        local obj = _cache[cacheKey]
        obj:reOpen()
        obj:noticeAllDataChange()
        return obj
    end

    local pathBase,obj
    if zzy.config.RUN_DEMO_UI then
        obj = ccui.ListView:create()
        obj:setContentSize(cc.Director:getInstance():getVisibleSize())
    else
        pathBase = basePath or self.DEFAULT_CSB_PATH_BASE or uiViewBase.DEFAULT_CSB_PATH_BASE or ""
        obj = widget or cc.CSLoader:createNode(pathBase..csb..".csb", pathBase)
        obj:setName("")
    end

    for key, var in pairs(self) do obj[key] = var end
    obj._childs = {}
    obj._vchilds = {}
    obj._vchildKey = 1
    obj:setCache(cacheKey ~= nil)
    obj._isOnlyCache = isOnlyCache
    if obj._cache then
        obj:retain()
        _cache[cacheKey] = obj
    end
    obj._csb = csb
    obj._pathBase = pathBase

    obj._dataProxys = {}
    obj._cmdProxys = {}
    obj._mask = nil
    
    obj._effectContent = {}
    obj._effectCount = {}
    obj._loopEffect = {}
    obj._cancelEffect = {}
    
    obj._destoryThings = {}
    
    obj._listenEvent = {}
    
    if csb == "MainScreen/W3_Skill" then
        --添加主城的神坛按钮
        local jtBtn = zzy.CocosExtra.seekNodeByName(obj, "btn_altar")
        _G_ST_BTN = jtBtn:clone()
        jtBtn:getParent():addChild(_G_ST_BTN)
        _G_ST_BTN:setPositionY(jtBtn:getPositionY() - 90)
        _G_ST_BTN:loadTexture("res/icon/icon_shentang.png")
        _G_ST_BTN:setName("btn_shentan")
        _G_ST_BTN:setScale(0.85)
        
        local isShentanOpen = GameConst.SHENTAN_OPEN_LEVEL and (GameConst.SHENTAN_OPEN_LEVEL <= ch.StatisticsModel:getMaxLevel())
        if isShentanOpen then
            _G_ST_BTN:setVisible(true)
        else
            _G_ST_BTN:setVisible(false)
        end
    end

    zzy.BindManager:doFixedBind(csb, obj)
    zzy.BindManager:doDataBind(csb, obj, data)
    
    if zzy.config.RUN_DEMO_UI then
        for dataName,_ in pairs(obj._dataProxys) do
            local option = cc.CSLoader:createNode("res/demoui/DEMOUI_DATA.csb")
            obj:pushBackCustomItem(option)
            zzy.CocosExtra.seekNodeByName(option, "name"):setString(dataName)
            local vText = zzy.CocosExtra.seekNodeByName(option, "value")
            obj:addDataViewer(dataName, function(data)
                if data == nil then
                    vText:setString("nil")
                else
                    vText:setString(json.encode(data))
                end
            end)
        end
        for cmdName,_ in pairs(obj._cmdProxys) do
            local option = cc.CSLoader:createNode("res/demoui/DEMOUI_CMD.csb")
            obj:pushBackCustomItem(option)
            local vText = zzy.CocosExtra.seekNodeByName(option, "cmdValue")
            local cmdBtn = zzy.CocosExtra.seekNodeByName(option, "cmdBtn")
            cmdBtn:setTitleText(cmdName)
            cmdBtn:addTouchEventListener(function(cmdBtn, evtType)
                if evtType == ccui.TouchEventType.ended then
                    local cmd = cmdName
                    local cmdParam = vText:getString()
                    if string.len(cmdParam) > 0 then
                        cmd = cmd .. "(".. cmdParam ..")"
                    end
                    obj:exeCommond(cmd)
                end
            end)
        end
    else
        obj:applyConfigBind()
    end
    obj._isOnlyCache = false
    return obj
end

function uiViewBase:runAnimation(loop, onComplete, onFrame, startFrameIndex, endFrameIndex)
    loop = loop or false
    startFrameIndex = startFrameIndex or 0

    if not self._csbAction or not zzy.CocosExtra.isCobjExist(self._csbAction) then
        self._csbAction = ccs.ActionTimelineCache:createAction(self._pathBase .. self._csb .. ".csb")
        self:runAction(self._csbAction)
    end

    if endFrameIndex then
        self._csbAction:gotoFrameAndPlay(startFrameIndex, endFrameIndex, loop)
    else
        self._csbAction:gotoFrameAndPlay(startFrameIndex, loop)
    end

    if onComplete then
        self._csbAction:setLastFrameCallFunc(onComplete)
    else
        self._csbAction:clearLastFrameCallFunc()
    end
    if onFrame then
        self._csbAction:setFrameEventCallFunc(onFrame)
    else
        self._csbAction:clearFrameEventCallFunc()
    end
end

function uiViewBase:addCacheRefreshFunc(onReopen, onClose)
   -- if not self._cache then return end
    if onReopen then
        local oldReopen = self._onReopen
        self._onReopen = function()
            onReopen()
            return oldReopen and oldReopen()
        end
    end
    if onClose then
        local oldClose = self._onClose
        self._onClose = function()
            onClose()
            return oldClose and oldClose()
        end
    end
end

function uiViewBase:getChild(key)
    if self._childs[key] then
        return self._childs[key]
    end

    local keyArr = zzy.StringUtils:split(key, ":")
    local ret = self
    --[[
    for k, v in ipairs(keyArr) do
        ret = zzy.CocosExtra.seekNodeByName(ret, v)
        if not ret then
            error(string.format("ui错误，在[%s]界面找不到[%s]控件", self._csb, key))
        end
    end
    ]]--
    for i=1,#keyArr do
        ret = zzy.CocosExtra.seekNodeByName(ret, keyArr[i])
        if not ret then
            error(string.format("ui错误，在[%s]界面寻找[%s]控件，[%s]找不到", self._csb, key, keyArr[i]))
        end
    end
    
    self._childs[key] = ret
    zzy.UIUtils:changeTouchEventListenerToList(ret)
    zzy.UIUtils:changeEventListenerToList(ret)
    return ret
end

function uiViewBase:noticeAllDataChange()
    for dataName,proxy in pairs(self._dataProxys) do
        self:noticeDataChange(dataName)
    end
    for _,child in pairs(self._vchilds) do
        child:noticeAllDataChange()
    end
end

function uiViewBase:getCsbStr()
    return self._csb
end

local AUTO_NOTICE_DATA_META_TABLE = {
    __index = function(t, k)
        if k ~= "v" then return end
        return t.__v
    end,
    __newindex = function(t, k, v)
        if k ~= "v" then return end
        rawset(t, "__v", v)
        t.__owner:noticeDataChange(t.__dn)
    end
}

function uiViewBase:createAutoNoticeData(dataName, initValue)
    local ret = {
        __dn = dataName,
        __v = initValue,
        __owner = self
    }
    setmetatable(ret, AUTO_NOTICE_DATA_META_TABLE)
    self:addDataProxy(dataName, function() return ret.__v end)
    return ret
end

function uiViewBase:applyConfigBind()
    local bindConfig = GameConfig.UiConfig:getTable1(self._csb) or GameConfig.EditoruiConfig:getTable1(self._csb)
    if not bindConfig then return end
    for _, config in pairs(bindConfig) do
        config = zzy.BindManager:applyConfigParamTrans(self,config)
        zzy.BindManager:doConfigBind(self, config)
    end
end

function uiViewBase:reOpen()
    if self._onReopen then
        self._onReopen()
    end
    for k,v in ipairs(self._listenEvent) do
        self:listen(v.eventType,v.handler,v.priority,v.obj,v.once,true)
    end
    for _,child in pairs(self._vchilds) do
        child:reOpen()
    end
end

function uiViewBase:addDataProxy(dataName, getFunc, effectEvt)
    local info = {
        getFunc = getFunc,
        tempData = getFunc(),
        vufs = {}
    }
    self._dataProxys[dataName] = info
    --table.insert(self._listenEvent,{effectEvt=effectEvt,info = info,dataName = dataName})
    
    for eventType, func in pairs(effectEvt or {}) do
        self:listen(eventType, function(obj, evt)
            if self:getParent() == nil then return end
            if not func or func(evt) then
                local newData = info.getFunc(evt)
                if newData ~= info.tempData then
                    info.tempData = newData
                    self:_updateViewsByData(dataName)
                end
            end
        end)
    end
end

function uiViewBase:getDataProxy(dataName)
    if dataName then
        return self._dataProxys[dataName]
    else
        return self._dataProxys
    end
end

function uiViewBase:noticeDataChange(dataName)
    local info = self._dataProxys[dataName]
    if not info then return end
    local newData = info.getFunc()
    if newData ~= info.tempData then
        info.tempData = newData
        self:_updateViewsByData(dataName)
    end
end

function uiViewBase:addMask(mask)
    local parent = self:getParent()
    if parent then
        self:removeFromParent()
        parent:addChild(mask)
    end
    mask:addChild(self)
    self._mask = mask
end

function uiViewBase:_updateViewsByData(dataName)
    if not self._dataProxys[dataName] then return end
    local data = self._dataProxys[dataName].tempData
    for _,func in ipairs(self._dataProxys[dataName].vufs) do
        func(data)
    end
end

function uiViewBase:addScrollData(realFlag, newFlag, scrollTs, exchangeFunc,widgetName)
    exchangeFunc = exchangeFunc or (function(a) return a end)
    local data
    local tov
    local curv
    local endTime
    
    local scrollFunc
    scrollFunc = function()
        local now = os_clock()
        if endTime < now or math.abs(endTime - now) < 0.001 then
            curv = tov
            endTime = nil
        else
            curv = curv + (tov - curv) / 30 / (endTime - now)
            self:setTimeOut(0, scrollFunc)
        end
        data.v = exchangeFunc(curv)
    end
    
    self:addDataViewer(realFlag, function(v)
        tov = v
        local startScroll = endTime == nil
        endTime = os_clock() + scrollTs
        if startScroll then scrollFunc() end
    end, function(v)
        tov = v
        curv = v
        data = self:createAutoNoticeData(newFlag, exchangeFunc(v))
    end)
end

function uiViewBase:addDataViewer(dataFlag, update, init)
    local info = self._dataProxys[dataFlag]
    local getUseData = nil
    if not info then
        local dataNameArr = zzy.StringUtils:split(dataFlag, ":")
        local dataName = dataNameArr[1]
        info = self._dataProxys[dataName]
        if not info then
            error(self._csb .."界面数据代理不存在" .. dataName)
        end
        if #dataNameArr > 1 then
            getUseData = function(data)
                for i=2,#dataNameArr do
                    data = data and data[dataNameArr[i]]
                end
                return data
            end
        end
    end


    if init then
        if getUseData then
            init(getUseData(info.tempData))
        else
            init(info.tempData)
        end
    end
    if update then
        if getUseData then
            local _update = update
            update = function(wholeData)
                _update(getUseData(wholeData))
            end
        end

        table.insert(info.vufs, update)
        update(info.tempData)
    end
end

function uiViewBase:addCommond(cmdName, func)
    self._cmdProxys[cmdName] = func
end

function uiViewBase:getCommond(cmdName)
    return self._cmdProxys[cmdName]
end

function uiViewBase:addDefaultCommond(func)
    self._cmdProxys["DEFAULT"] = func
end

function uiViewBase:exeCommond(cmdName, ...)
    local cmd = cmdName
    local args = {...}
    
    local psPos = string.find(cmdName, "%(")
    if psPos then
        cmd = string.sub(cmdName, 1, psPos - 1)
        local pArr = zzy.StringUtils:split(string.sub(cmdName, psPos + 1, -2), ",")
        for _,v in ipairs(args) do
            table.insert(pArr, v)
        end
        args = pArr
    end

    if self._cmdProxys[cmd] then
        return self._cmdProxys[cmd](self, unpack(args))
    elseif zzy.BindManager:getCommondCmd(cmd) then
        return zzy.BindManager:getCommondCmd(cmd)(self, unpack(args))
    elseif self._cmdProxys["DEFAULT"] then
        return self._cmdProxys["DEFAULT"](self, cmd, unpack(args))
    else
        error("在界�?"..self._csb.." 找不到指�?"..cmdName)
    end
end

function uiViewBase:create(csb, data, widget, pathFormat)
    local obj = zzy.uiViewBase:new(csb, data, widget, pathFormat,nil,self._isOnlyCache)
    obj._ck = self._vchildKey 
    self._vchilds[obj._ck] = obj
    self._vchildKey = self._vchildKey + 1
    obj._parent = self
    obj:setCache(self._cache)
    return obj
end

function uiViewBase:setCache(isCache)
    self._cache = isCache
    for k,child in pairs(self._vchilds) do
        child:setCache(isCache)
    end
end

function uiViewBase:addEffect(name,widget,fileName,armatureName,animationName)
    if self._effectContent[name] then
        local data = self._effectContent[name]
        if not data.widget then data.widget = widget end
        if not data.fileName then data.fileName = fileName end
        if not data.bName then data.bName = armatureName end
        if not data.aName then data.aName = animationName end
       --  cclog("警告：当前已有该特效，只会更新没有的部分信息...")
	else
        local data = {widget = widget,fileName = fileName,
            bName = armatureName,aName = animationName,autoRelease = true,
            effs = {}}
        self._effectContent[name] = data
	end
end

function uiViewBase:changeEffect(name,fileName,armatureName,animationName)
    self._effectContent[name] = self._effectContent[name] or {effs = {}}
    if fileName then self._effectContent[name].fileName = fileName end
    if armatureName then self._effectContent[name].bName = armatureName end
    if animationName then self._effectContent[name].aName = animationName end
end

function uiViewBase:isAutoReleaseEffect(name)
    if self._effectContent[name] then
        return self._effectContent[name].autoRelease
    end
    return nil
end

function uiViewBase:setAutoReleaseEffect(name,isAuto)
    if self._effectContent[name] then
        self._effectContent[name].autoRelease = isAuto
    end
end

function uiViewBase:playEffect(name,isLoop,func)
    local play = function(name,isLoop)
        if isLoop and self._effectCount[name] and self._effectCount[name] > 0 then return end
        local fileName = self._effectContent[name].fileName
        local autoRelease = self._effectContent[name].autoRelease
        zzy.EffectResManager:loadResource(self._effectContent[name].fileName,function()
            if not zzy.CocosExtra.isCobjExist(self) or self._cancelEffect[name] then
                zzy.EffectResManager:releaseResource(fileName,autoRelease)
                return
            end
            if isLoop and self._effectCount[name] and self._effectCount[name] > 0 then
                zzy.EffectResManager:releaseResource(fileName,autoRelease)
                return
            end
            self._effectCount[name] = self._effectCount[name] or 0
            self._effectCount[name] = self._effectCount[name] + 1
            local armature = ccs.Armature:create(self._effectContent[name].bName)
            table.insert(self._effectContent[name].effs,armature)
            if self._effectContent[name].widget then
                self._effectContent[name].widget:addChild(armature)
            else
                local layout = ch.UIManager:getNavigationLayer()
                local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
                armature:setPosition(size.width/2,size.height/2)
                layout:addChild(armature)
            end
            if isLoop then
                self._loopEffect[name] = armature
            else
                armature:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
                    if movementType == ccs.MovementEventType.complete then
                        if self._effectCount and self._effectCount[name]  then
                            self._effectCount[name] = self._effectCount[name] - 1
                            if self._effectCount[name] == 0 then
                                self._effectCount[name] = nil
                            end
                            for k,v in ipairs(self._effectContent[name].effs) do
                                if v == armature then
                                    table.remove(self._effectContent[name].effs,k)
                                    break
                                end
                            end
                        end
                        if func then func()end
                        armature:removeFromParent()
                        zzy.EffectResManager:releaseResource(fileName,autoRelease)
                    end
                end)
            end
            armature:getAnimation():play(self._effectContent[name].aName,-1,isLoop and 1 or 0)
        end)
    end
    if isLoop then
        self._cancelEffect[name] = nil
    end
    if not self._effectContent[name] or not self._effectContent[name].widget then
        self:setTimeOut(0,function()
            if not self._effectContent[name] then
                error("该动画数据在ui表中不存在："..name)
            end
            play(name,isLoop)
        end)
    else
        play(name,isLoop)
    end
end

function uiViewBase:stopEffect(name)
    self._cancelEffect[name] = true
    if self._loopEffect[name] then
        self._loopEffect[name]:removeFromParent()
        self._loopEffect[name] = nil
        self._effectCount[name] = nil
        zzy.EffectResManager:releaseResource(self._effectContent[name].fileName,self._effectContent[name].autoRelease)
    end
end

function uiViewBase:releaseEffects()
    for k,v in pairs(self._effectCount) do
        if self._loopEffect[k] then
            self:stopEffect(k)
        else
            if self._effectContent[k].widget then
                for k,v in ipairs(self._effectContent[k].effs) do
                    v:removeFromParent()
                end
                self._effectContent[k].effs = {}
                zzy.EffectResManager:releaseResource(self._effectContent[k].fileName,self._effectContent[k].autoRelease,self._effectCount[k])
                self._effectCount[k] = nil
            end
        end
    end
end

function uiViewBase:destory(cleanView)
    if cleanView == nil then cleanView = true end
    if self._cache then
        if self._onClose then
            self._onClose()
        end
        if cleanView then
            if self._mask then
                self._mask:removeFromParent()
                self._mask = nil
            elseif self:getParent() then
                self:removeFromParent()
            end
            if self._ck then
                self._parent._vchilds[self._ck] = nil
            end
        end
        self:_removeDestroyThings()
        self:releaseEffects()
        for _,child in pairs(self._vchilds) do
            child:destory(false)
        end
        return
    end
    
    if self._ck then
        self._parent._vchilds[self._ck] = nil
    end

    for _,child in pairs(self._vchilds) do
        child:destory(false)
    end

    self:_removeDestroyThings()
    self:releaseEffects()
    
    if cleanView then
        if self._mask then
            self._mask:removeFromParent()
            self._mask = nil
        elseif self:getParent() then
            self:removeFromParent()
        end
    end
end

local timeoutCancelFunc = function(key)
    zzy.TimerUtils:cancelTimeOut(key)
end

function uiViewBase:setTimeOut(timeSpan, callBack)
    if not self._destoryThings["timeout"] then
        self._destoryThings["timeout"] = {
            func = timeoutCancelFunc
        }
    end
    table.insert(self._destoryThings["timeout"], zzy.TimerUtils:setTimeOut(timeSpan, callBack))
end

local eventListenCancelFunc = function(key)
    zzy.EventManager:unListen(key)
end

function uiViewBase:_removeDestroyThings()
    for key,thing in pairs(self._destoryThings) do
        if not self._cache or key ~= "timeout" then
            for _,var in ipairs(thing) do
                thing.func(var)
            end
            self._destoryThings[key] = {func =thing.func}
        end
    end
end

function uiViewBase:unListen(id)
    zzy.EventManager:unListen(id)
    for k,v in ipairs(self._destoryThings["eventListen"]) do
        if id == v then
            table.remove(self._destoryThings["eventListen"],k)
            break
        end
    end
end

function uiViewBase:listen(eventType, handler, priority, obj, once,isReOpen)
    if not self._destoryThings["eventListen"] then
        self._destoryThings["eventListen"] = {
            func = eventListenCancelFunc
        }
    end
    if not isReOpen then
        table.insert(self._listenEvent,{eventType=eventType,handler = handler,
            priority = priority,obj = obj,once = once})
    end 
    if self._isOnlyCache then return end
    local id =  zzy.EventManager:listen(eventType, handler, priority, obj, once)
    table.insert(self._destoryThings["eventListen"], id)
    return id
end

function uiViewBase:destoryCache()
	for _,widget in pairs(_cache) do
	   widget:setCache(false)
	   widget:destory()
	   widget:release()
	end
	_cache = {}
end

return uiViewBase