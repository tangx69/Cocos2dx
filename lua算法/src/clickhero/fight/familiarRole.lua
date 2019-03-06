local familiarRole = {
    _id = nil,
    _ani = nil,
    _state = nil, -- 0空闲，1走路
    _lastTime = nil,
    _target = nil,
    _lanuage = nil,
    _sayTime = nil,
    _textPanel = nil,
    _eventId = nil,
    _orientation = nil,
    Orientation = {
        right = -1,
        left = 1,
    }
}

local minDistance = 100 -- 距离主角的位置
local maxDistance = 150 -- 开始跟随距离
local speed = 180  -- 移动速度
local minSpan = 15 -- 泡泡最小间隔 时间
local maxSpan = 30 -- 泡泡最大间隔时间 
local textDurtion = 4 -- 泡泡显示时间

function familiarRole:create(id,orientation)
    local obj = cc.Node:create()
    for k,v in pairs(self) do
        obj[k] = v
    end
    local config = GameConfig.FamiliarConfig:getData(id)
    obj._id = id

    if USE_SPINE then
        config.avatar = config.spine
    end
    obj._ani = ch.CommonFunc:createAnimation(config.avatar)
    
    if ch.CommonFunc:isSpine(obj._ani) then
        obj._ani:setScaleX(-obj._ani:getScaleX()*orientation)
    else
        obj._ani:setScaleX(config.scale*orientation)
        obj._ani:setScaleY(config.scale)
    end
    obj._orientation = orientation

    ch.CommonFunc:speedAni(obj._ani, 1.5)
    obj._lastTime = os_clock()
    obj._sayTime = obj._lastTime + math.random(5,10)
    obj:_initLanguage()
    obj._eventId = zzy.EventManager:listen(zzy.Events.TickEventType,function()
        obj:update()
    end)
    obj:addChild(obj._ani)
    return obj
end

function familiarRole:_initLanguage()
	self._lanuage = {}
	local lang = GameConfig.FamiliarLangConfig:getTable1(0)
	for k,tab in pairs(lang) do
        if not ((tab.sid == 0 or tab.sid == 1) and  tab.to < ch.LevelModel:getMaxLevel()) then
           table.insert(self._lanuage,tab)
	   end
	end
    lang = GameConfig.FamiliarLangConfig:getTable1(self._id)
    for k,tab in pairs(lang or {}) do
        if not ((tab.sid == 0 or tab.sid == 1) and  tab.to < ch.LevelModel:getMaxLevel()) then
            table.insert(self._lanuage,tab)
        end
    end
end

function familiarRole:initTarget(target)
    self._target = target
    local posX = 0
    if target then
        posX = target:getPositionX() + minDistance * self._orientation
    end
    self:setPositionX(posX)
    self:playStand()
end

function familiarRole:getAvatarName()
	return GameConfig.FamiliarConfig:getData(self._id).avatar
end

function familiarRole:update()
    local now = os_clock()
    local dt = now - self._lastTime
    self:_updatePosition(dt)
    if now > self._sayTime then
        self:say()
    end
    if self._showTime and now > self._showTime + textDurtion then
        self._showTime = nil
        local seq = cc.Sequence:create(cc.FadeOut:create(0.5),cc.CallFunc:create(function()
            self._textPanel:removeFromParent()
            self._textPanel = nil
        end))
        self._textPanel:runAction(seq)
    end
	self._lastTime = now
end

function familiarRole:destroy()
	if self._eventId then
	   zzy.EventManager:unListen(self._eventId)
	end
    self:removeFromParent()
end

function familiarRole:_updatePosition(dt)
    if  self._target then
        local mp = self._target:getPositionX()
        local minX = mp + minDistance * self._orientation
        local moveX = mp + maxDistance * self._orientation
        if (self:getPositionX() - mp) *self._orientation <= 0 then
            self:setPositionX(minX)
            self:playStand()
        elseif (self:getPositionX() - minX)*self._orientation > 0 then
            if self._state == 1 or (self._state == 0 and (self:getPositionX() - moveX)*self._orientation >0) then
                local posX = self:getPositionX() - speed * dt *self._orientation
                posX = (posX - minX) *self._orientation < 0 and minX or posX
                self:setPositionX(posX)
                self:playMove()
            end
        else
            self:playStand()   
        end
    end
end

function familiarRole:say()
	local langs,weight = self:getLanguage()
    local rand = math.random(1,weight)
    local cur = 0
    local text
    for k,l in ipairs(langs) do
        cur = cur + l.weight
        if rand <= cur then
            text = l.language
            break
        end
    end
    self:showText(text)
    self._sayTime = os_clock() + math.random(minSpan,maxSpan)
end

function familiarRole:showText(text)
    if self._textPanel then
        self._textPanel:removeFromParent()
        self._textPanel = nil
    end
    local textWidget = ccui.Text:create(text,"res/ui/aaui_font/ch.ttf",18)
    textWidget:ignoreContentAdaptWithSize(true)
    textWidget:setMaxLineWidth(140)
    local height = textWidget:getContentSize().height
    self._textPanel = ccui.ImageView:create("aaui_diban/fpao.png",ccui.TextureResType.plistType)
    self._textPanel:setScale9Enabled(true)
    self._textPanel:setCapInsets(cc.rect(10,10,21,16))
    self._textPanel:setContentSize(cc.size(152,height+38))
    textWidget:setPosition(76, (height+20)/2 + 18)
    self._textPanel:addChild(textWidget)
    self._textPanel:setAnchorPoint(cc.p(0.5,0))
    local p = self:getBoneOffset("top")
    self._textPanel:setPosition(p.x,p.y+5)
    self:addChild(self._textPanel)
    self._showTime = os_clock()
end

function familiarRole:getBoneOffset(boneName)
    if ch.CommonFunc:getHpBarPos(self, boneName) then
        local newX = 0
        local newY = 200 or self:getContentSize().height --TODO 获取spine大小
        return cc.p(newX,newY)
    else
        local boneP = self._ani:getBone(boneName):getWorldInfo():getPosition()
        local newX = boneP.x * self._ani:getScaleX()
        --local newY = boneP.y * self._ani:getScaleY()
        local newY = self._ani:getContentSize().height*self._ani:getScaleY() --tgx
        return cc.p(newX,newY)
    end
end

function familiarRole:getLanguage()
    local langs = {}
    local weight = 0
	if ch.LevelController.mode == ch.LevelController.GameMode.cardFight then
	   for k,l in ipairs(self._lanuage) do
	       if l.sid == 0 or l.sid == 2 then
               weight = weight + l.weight
               table.insert(langs,l)
	       end
	   end
	else
	   local level = ch.LevelModel:getMaxLevel()
       for k,l in ipairs(self._lanuage) do
            if (l.sid == 0 or l.sid == 1) and level >= l.from and level <= l.to then
               weight = weight + l.weight
               table.insert(langs,l)
           end
       end
	end
    return langs,weight
end

function familiarRole:playStand()
	if self._state == 0 then return end
	self._state = 0

    if ch.CommonFunc:isSpine(self._ani) then
        self._ani:setAnimation(0, "idle", true)
    else
        self._ani:getAnimation():play("move",-1,1)
    end
end

function familiarRole:playMove()
    if self._state == 1 then return end
    self._state = 1

    if ch.CommonFunc:isSpine(self._ani) then
        self._ani:setAnimation(0, "walk", true)
    else
        self._ani:getAnimation():play("move",-1,1)
    end
end

function familiarRole:getDistance()
    return minDistance
end


return familiarRole