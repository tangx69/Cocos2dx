local maxProb = 25
local liftTime = 30

local xRang = {40,610}
local yRang = {840,900}
local xSpeed = 3
local ySpeed = 1.5

local ResName = {"baoxiang_NPC","baoxiang_NPC02"}

local flyBox = {
    _curFlyBox = nil,
    _curFlyBoxType = nil,
    FlyBoxType = {
        GoldBoss = 1,
        SStone = 2
    },
    _debugType = nil,
}

---
--debug指令下一次必出
--@function [parent=#flyBox] setDebugType
--@param #flyBox self
--@param #number type 1为黄金大魔王，2为魂石大魔王
function flyBox:setDebugType(type)
    self._debugType = type
end


---
--是否出现
--@function [parent=#flyBox] isAppear
--@param #flyBox self
--@param #number time
--@return #number 1为黄金大魔王，2为魂石大魔王，nil不出现
function flyBox:isAppear(time)
    if self._debugType then
        local ty
        if ch.LevelModel:getCurLevel() > 200 then
            if self._debugType == 1 then
                ty = 1
            else
                ty = 2
            end
        else
            ty = 1
        end 
        self._debugType = nil
        return ty
    else
        local isAppear = false
        if ch.StatisticsModel:getMaxLevel() < GameConst.GOLD_BOSS_OPEN_LEVEL + 1 then
            isAppear = false
        elseif ch.StatisticsModel:getMaxLevel() == GameConst.GOLD_BOSS_OPEN_LEVEL + 1 or
            ch.StatisticsModel:getMaxLevel() == GameConst.GOLD_BOSS_OPEN_LEVEL + 6 then
            isAppear = true
        elseif ch.StatisticsModel:getMaxLevel() == GameConst.DEFEND_OPEN_LEVEL+1 then  
            isAppear = false
        else
            local prob = 0
            if time <= 10 then
                prob = 5
            else
                prob = (time - 10) +5
            end
            prob = prob >maxProb and maxProb or prob
            isAppear = prob>=math.random(1,100)     
        end

        if true then
            DEBUG("=========1111111111========")
            return 0
        end

        if isAppear then
            if ch.LevelModel:getCurLevel() > 200 then
                return math.random(1,2)
            else
                return 1
            end
        end
    end
end

function flyBox:addFlyBox(type)
    if self._curFlyBox then return end
    self._curFlyBoxType = type
    ch.RoleResManager:load(ResName[type],function()
        if ch.LevelController.mode == ch.LevelController.GameMode.normal then
            self._curFlyBox = self:_create(ResName[type])
            ch.UIManager:getAutoFightLayer():addChild(self._curFlyBox, 7)
        else
            ch.RoleResManager:release(ResName[type])  
        end
    end)
end

function flyBox:clearFlyBox()
	if self._curFlyBox then
        self:destroyFlyBox(self._curFlyBox)
	end
end

function flyBox:_create(name)
    local body = ch.CommonFunc:createAnimation(name)
    body:setScaleX(-body:getScaleX())
    body:setName("body")
    local size = body:getContentSize()
    local box = ccui.Layout:create()
    box:setTouchEnabled(true)
    --body:setTouchEnabled(false)
    box:setContentSize(70, 70)
    box:setAnchorPoint(0.5,0.5)
    box:setPosition(xRang[1],yRang[1])
    box.xOri = 1
    box.yOri = 1
    body:setScaleX(box.xOri*-1)
    body:setPosition(size.width*body:getAnchorPoint().x,size.height*body:getAnchorPoint().y)

    ch.CommonFunc:playAni(body, "move", true) --body:getAnimation():play("move",-1,1)
    box:addChild(body)
    local text = ccui.TextBMFont:create(30, "res/ui/aaui_font/font_yellow.fnt")
    text:setPosition(50,20)
    box:addChild(text)
    box.endTime = os_clock() + liftTime
    box.eventId = nil
    box.eventId = zzy.EventManager:listen(zzy.Events.TickEventType,function()
        self:_updateFlyBox(box)
        local leftTime = box.endTime - os_clock()
        text:setString(math.floor(leftTime))
        if leftTime <= 0 then
            self:destroyFlyBox()
        end
    end)
    box:addTouchEventListener(function(obj,evt)
        if evt == ccui.TouchEventType.ended then
            local type = self._curFlyBoxType
            self:destroyFlyBox()
            ch.LevelController:startGoldBoss(type)
        end
    end)
    return box
end

function flyBox:destroyFlyBox()
    zzy.EventManager:unListen(self._curFlyBox.eventId)
    self._curFlyBox:removeFromParent()
    ch.RoleResManager:release(ResName[self._curFlyBoxType])
    self._curFlyBox = nil
    self._curFlyBoxType = nil
end

function flyBox:_updateFlyBox(flyBox)
    local x = flyBox:getPositionX()
    local y = flyBox:getPositionY()
    x =  x + flyBox.xOri * xSpeed
    if x > xRang[2] or x < xRang[1] then
        flyBox.xOri = flyBox.xOri * -1
        local body = flyBox:getChildByName("body")
        body:setScaleX(flyBox.xOri*-1)
    end
    x= x > xRang[2] and xRang[2] or x
    x= x < xRang[1] and xRang[1] or x

    y =  y + flyBox.yOri * ySpeed
    if y > yRang[2] or y < yRang[1] then
        flyBox.yOri = flyBox.yOri * -1
    end
    y= y > yRang[2] and yRang[2] or y
    y= y < yRang[1] and yRang[1] or y
    flyBox:setPosition(x,y)
end

return flyBox