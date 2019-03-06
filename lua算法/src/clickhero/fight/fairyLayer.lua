local fairyLayer = {
    _layer = nil,
    _fairys = nil,
    _nextRefreshTime = nil,
    _lastRandomTime =  nil,
    _eventId = nil,
    _backgroundTime = nil,
}

fairyLayer.GET_BOX_EVENT = "FAIRYLAYER_GET_BOX_EVENT"

local xRang = {40,610}
local yRang = {840,900}
local xSpeed = 3
local ySpeed = 1.5


local disappearTime = 3
local backgroundMaxTime = 120


local nextMinInterval = 60
local nextMaxInterval = 300
local randomInterval = 60
local firstLoginTimeInterval = 600


--local nextMinInterval = 11
--local nextMaxInterval = 12
--local randomInterval = 1
--local firstLoginTimeInterval = 0

local maxCount = GameConst.FAIRY_GET_MAX_COUNT

function fairyLayer:init()
	self._layer = ccui.Layout:create()
    ch.UIManager:getAutoFightLayer():addChild(self._layer, 7)
    self._fairys = {}
    self:start()
    zzy.EventManager:listen(zzy.Events.BackgroundEventType,function(obj,evt)
        if evt.isBack then
            self._nextRefreshTime = nil
            if self._eventId then
                zzy.EventManager:unListen(self._eventId)
            end
            self._backgroundTime = os_time()
        else
            if os_time() - self._backgroundTime > backgroundMaxTime then
                self:removeAllFairy()
            end
            self:start()
        end
    end)
end

function fairyLayer:start()
    if self._eventId then
        zzy.EventManager:unListen(self._eventId)
        self._eventId = nil
    end
    if ch.FairyModel:getCount() >= maxCount then return end
    self:_initRefreshTime()
    self._eventId = zzy.EventManager:listen(zzy.Events.TickEventType,function()
        if not zzy.NetManager:getInstance():isWorking() then
            local now = os_time()
            if self._nextRefreshTime and now > self._nextRefreshTime then
                self._nextRefreshTime = now
            end
            return
        end
        self:_update()
        self:_refreshFairy()
    end)
end

function fairyLayer:stop()
	self:removeAllFairy()
    if self._eventId then
        zzy.EventManager:unListen(self._eventId)
        self._eventId = nil
    end
end

function fairyLayer:_refreshFairy()
    local now = math.floor(os_time())
    if self._nextRefreshTime and  now > self._nextRefreshTime then
        if not self._lastRandomTime or now - self._lastRandomTime > randomInterval then
            if math.random(1,(nextMaxInterval - nextMinInterval)/60) == 1 then
                self:addFairy()
                ch.FairyModel:addCount(1)
                self._nextRefreshTime = nil
                self._lastRandomTime = nil
            else
                self._lastRandomTime = now
            end
        end
        if self._nextRefreshTime and now - self._nextRefreshTime > nextMaxInterval then -- 大于十分钟必添加
            self:addFairy()
            ch.FairyModel:addCount(1)
            self._nextRefreshTime = nil
            self._lastRandomTime = nil
        end
    end
end

function fairyLayer:addFairy()
    if #self._fairys > 0 then
        local fairy = self:_createFairy()
        self._layer:addChild(fairy)
        table.insert(self._fairys,fairy)
    else
        ch.RoleResManager:load("xiaoxiannv",function()
            local fairy = self:_createFairy()
            self._layer:addChild(fairy)
            table.insert(self._fairys,fairy)
        end)
    end
    ch.NetworkController:fairyAppear()
end

function fairyLayer:_update()
    for _,fairy in ipairs(self._fairys) do
        if not fairy.hasDropped then
            self:_updateFairy(fairy)
        end
    end
end

function fairyLayer:_initRefreshTime()
    if #self._fairys == 0 then
        if ch.StatisticsModel:getPlayTime() < 30 then
            self._nextRefreshTime = math.floor(os_time()) + nextMinInterval + firstLoginTimeInterval
        else
            self._nextRefreshTime = math.floor(os_time()) + nextMinInterval
        end
    else
        self._nextRefreshTime = nil
    end
    self._lastRandomTime = nil
end

function fairyLayer:_createFairy()
    local body = ccs.Armature:create("xiaoxiannv")
    body:setName("body")
    local size = body:getContentSize()
    local fairy = ccui.Layout:create()
    fairy:setTouchEnabled(true)
    fairy:setContentSize(size)
    fairy:setAnchorPoint(0.5,0.5)
    fairy:setPosition(xRang[1],yRang[1])
    fairy.xOri = 1
    fairy.yOri = 1
    body:setPosition(size.width*body:getAnchorPoint().x,size.height*body:getAnchorPoint().y)
    body:getAnimation():play("move",-1,1)
    fairy:addChild(body)
    fairy:addTouchEventListener(function(obj,evt)
        if evt == ccui.TouchEventType.ended then
            fairy:setTouchEnabled(false)
            self:_dropBox(fairy)
        end
    end)
    --fairy.startTime = os_time()
    return fairy
end

function fairyLayer:_getReward()
    --计算id权重总数
    local maxV = 0
    for i,v in ipairs(GameConst.FAIRY_REWARD_TYPE_VALUE) do
        maxV = maxV + v.weight;
    end
    --随机一个值
    local id = 1
    local randomNum = math.random(1,maxV)
    local cometo = 0
    for i,v in ipairs(GameConst.FAIRY_REWARD_TYPE_VALUE) do
        cometo = cometo + v.weight;
        if cometo >= randomNum then
        	id = i
        	break
        end
    end
    local value = 0
    if id == 1 then
        value = ch.CommonFunc:getOffLineGold(GameConst.FAIRY_REWARD_TYPE_VALUE[1].value)
    elseif id == 2 or id == 3 then
        value = GameConst.FAIRY_REWARD_TYPE_VALUE[id].value
    else
        --计算钻石权重总数
        maxV = 0
        for i,v in ipairs(GameConst.FAIRY_REWARD_TYPE_VALUE[4].value) do
            maxV = maxV + v.weight;
        end
        --随机一个值
        local idZuanShi = 1
        randomNum = math.random(1,maxV)
        cometo = 0
        for i,v in ipairs(GameConst.FAIRY_REWARD_TYPE_VALUE[4].value) do
            cometo = cometo + v.weight;
            if cometo >= randomNum then
                idZuanShi = i
                break
            end
        end
        value = GameConst.FAIRY_REWARD_TYPE_VALUE[4].value[idZuanShi].value
    end
    return id,value
end

function fairyLayer:_AddReward()
	local id,value = self:_getReward()
	ch.NetworkController:fairyDropItem(id,value)
	-- 先给服务器发指令再抛事件（保证任务领奖同步）
    zzy.EventManager:dispatch({type = self.GET_BOX_EVENT})
    local count = ch.FairyModel:getCount()
    local text
    if id == 2 or id == 3 then
        value = value/60
        text = string.format(GameConst.FAIRY_REWARD_TYPE_DESC[id],
            count,GameConst.FAIRY_GET_MAX_COUNT,
            1+GameConst.BUFF_EFFECT_VALUE[id+1],ch.NumberHelper:toString(value))
    else
        text = string.format(GameConst.FAIRY_REWARD_TYPE_DESC[id],
            count,GameConst.FAIRY_GET_MAX_COUNT,
           ch.NumberHelper:toString(value))  
    end
	ch.UIManager:showNotice(text)
end

function fairyLayer:_dropBox(fairy)
    fairy.hasDropped = true
    if ch.FairyModel:getCount() >= maxCount then
        zzy.EventManager:unListen(self._eventId)
        self._eventId = nil
    else
        self._nextRefreshTime = math.floor(os_time()) + nextMinInterval
    end
    self:_AddReward()
    local body = fairy:getChildByName("body")
    body:stopAllActions()
    body:setOpacity(255)
    local boxAni = ccs.Armature:create("xiaoxiannv")
    boxAni:setName("box")
    boxAni:setPosition(body:getPositionX(),body:getPositionY())
    fairy:addChild(boxAni)
    boxAni:getAnimation():play("open")
    boxAni:getAnimation():setMovementEventCallFunc(function(armature,movementType,movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            if movementID == "open" then
                self:removeFairy(fairy)
            end
        end
    end)
    body:getAnimation():play("happy")
    body:getAnimation():setMovementEventCallFunc(function(armature,movementType,movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            if movementID == "happy" then
                body:getAnimation():stop()
                local animation = cc.FadeOut:create(0.5)
                body:runAction(animation)
            end
        end
    end)
    
end

function fairyLayer:removeFairy(fairy)
	for i,f in ipairs(self._fairys) do
	   if f == fairy then
           table.remove(self._fairys,i)
           break
	   end
	end
	fairy:removeFromParent()
	if #self._fairys == 0 then
        ch.RoleResManager:release("xiaoxiannv")
	end
end

function fairyLayer:removeAllFairy()
    for i,f in ipairs(self._fairys) do
        f:removeFromParent()
    end
    self._fairys = {}
    ch.RoleResManager:release("xiaoxiannv")
end

function fairyLayer:onNextDay()
    ch.FairyModel:onNextDay()
	if #self._fairys ~= 0 then
        ch.FairyModel:addCount(1)
	end
	if not self._eventId and ch.LevelController.mode ~= ch.LevelController.GameMode.defend then
	   self:start()
	end
end

function fairyLayer:_updateFairy(fairy)
    local x = fairy:getPositionX()
    local y = fairy:getPositionY()
    x =  x + fairy.xOri * xSpeed
    if x > xRang[2] or x < xRang[1] then
        fairy.xOri = fairy.xOri * -1
        fairy:setScaleX(fairy.xOri)
    end
    x= x > xRang[2] and xRang[2] or x
    x= x < xRang[1] and xRang[1] or x

    y =  y + fairy.yOri * ySpeed
    if y > yRang[2] or y < yRang[1] then
        fairy.yOri = fairy.yOri * -1
    end
    y= y > yRang[2] and yRang[2] or y
    y= y < yRang[1] and yRang[1] or y
    fairy:setPosition(x,y)
end

return fairyLayer