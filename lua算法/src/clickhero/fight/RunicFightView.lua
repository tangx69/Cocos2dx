---
-- @module RunicFightView
local RunicFightView = {
    -- 一些固定的常数
    runicRatio = 36,    --符文的半径
    runicMargin = 8,   --符文的间隔
    eachDistance = 8,   --每帧移动的距离
    radarPositionX = 158,  --雷达的中心位置
    runicStartPointX = 798,  -- 符文起始点
    _armature = nil, 
    
    _view = nil,
    _runicContainer = nil,
    _fontContainer = nil,
    _touchPanel = nil,
    _prePoint = nil,
    _seriesPanel = nil,
    _seriesText = nil,
    _emitter = nil,
    
    _seriesTime = nil,
    _seriesSchedulerId = nil,
    
    _radar = nil,       --雷达的相关属性
    _runicDistance = nil,     -- 两个符文之间的距离
    _runicLeftBorderPointX = nil, -- 符文删除的左边界
    
    
    _isPlaying = nil,
    _isTouching = nil,
    
    _gesture = nil,
    _totalRatio = nil,    --出现的符文类型总权重
    
    _hasMoved = nil,
    _seriesCount = nil,  -- 连接数
    _runics = nil,
    
    _schedulerId = nil,
    _levelChangedId = nil,
}

---
-- 创建界面
-- @function [parent=#RunicFightView] create
-- @param #RunicFightView self
-- @return #Node
function RunicFightView:create()
    self:_render()
    math.randomseed(os_clock())
    self._totalRatio = self:_getTotalRatio()
    self._gesture = ch.Gesture:new()
    self:_initRadarPositionInfo()
    self:_initRunicPositionInfo()
    return self._view
end

local lastTime = nil

---
-- 开始游戏
-- @function [parent=#RunicFightView] start
-- @param #RunicFightView self
function RunicFightView:start()
	self._isPlaying = true
	self:_init()
	self:_addRunics()
	self._schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self:_update()
	end,0,false)
    lastTime = os_clock()
    self:_playMusic()
    self._levelChangedId = zzy.EventManager:listen(ch.LevelModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.LevelModel.dataType.curLevel then
            self:reStart()
        end
    end)
end

---
-- 开始游戏
-- @function [parent=#RunicFightView] reStart
-- @param #RunicFightView self
function RunicFightView:reStart()
    self._runicContainer:removeAllChildren()
    --self._fontContainer:removeAllChildren(true)
    self:_init()
    self:_addRunics()
    lastTime = os_clock()
    self:_playMusic()
end

---
-- 结束游戏
-- @function [parent=#RunicFightView] ended
-- @param #RunicFightView self
function RunicFightView:ended()
    self._runicContainer:removeAllChildren()
    --self._fontContainer:removeAllChildren(true)
    self._runics = nil
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schedulerId)
    self._isPlaying = false
    ch.MusicManager:stopMusic()
    lastTime = nil
    if self._levelChangedId then
        zzy.EventManager:unListen(self._levelChangedId)
    end
end

---
-- 随机播放背景音乐
-- @function [parent=#RunicFightView] _playMusic
-- @param #RunicFightView self
function RunicFightView:_playMusic()
    local num = math.random(1,2)
    if num == 1 then
        ch.MusicManager:playRunicMusic1(true)
    else
        ch.MusicManager:playRunicMusic2(true)
    end
end


---
-- 初始化一些数据
-- @function [parent=#RunicFightView] _init
-- @param #RunicFightView self
function RunicFightView:_init()
    self._runics = {}
    self._hasMoved = 0
    self._seriesCount = 0
end

---
-- 每帧更新
-- @function [parent=#RunicFightView] _update
-- @param #RunicFightView self
function RunicFightView:_update()
    local time = os_clock()
    local distance = (time - lastTime) * 30 * self.eachDistance
    lastTime = time
    self._hasMoved = self._hasMoved + distance
	local removeRunics = {}
	for k,v in ipairs(self._runics) do
       local pointX = v:getPositionX()
       pointX = pointX - distance
	   if pointX < self._runicLeftBorderPointX then
	       v:removeFromParent()
           table.insert(removeRunics,k)
	   else
    	   v:setPositionX(pointX)
       end
       if v.isAlive and pointX < self._radar.commonLeftX then
           v.isAlive = false
           self._seriesCount = 0
           self:_grayRunic(v)
        end
	end
	for k,v in ipairs(removeRunics) do
        table.remove(self._runics,v-k+1)
	end
	local maxDistance = self._runicDistance * 4
	while self._hasMoved >=  maxDistance do
       self._hasMoved = self._hasMoved - maxDistance
       self:_addRunics(self._hasMoved)
	end 
end

---
-- 渲染，添加触摸监听
-- @function [parent=#RunicFightView] _render
-- @param #RunicFightView self
function RunicFightView:_render()
    self._view = cc.CSLoader:createNode("res/ui/MainScreen/W_FuwenArea.csb","res/ui/")
    self._runicContainer = self._view:getChildByName("runicContainer")
    self._fontContainer = self._view:getChildByName("fontContainer")
    self._touchPanel = self._view:getChildByName("panel_touch")
    self._armature = ccs.Armature:create("fuwen_pingji")
    self._seriesPanel = self._view:getChildByName("Panel_combo")
    self._seriesText = self._seriesPanel:getChildByName("num_combo")
    self._seriesPanel:setVisible(false)
    self._armature:setPosition(self.radarPositionX,0)
    self._armature:setVisible(false)
    self._armature:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
        if movementType == ccs.MovementEventType.complete then
            self._armature:setVisible(false)
        end
    end)
    self._fontContainer:addChild(self._armature)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch,event)
        if self._isTouching then return end
        self:_onTouchBegin(touch,event)
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch,event)
        self:_onTouchMove(touch,event)
    end,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch,event)
        self:_onTouchEnded(touch,event)
    end,cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch,event)
        self:_onTouchEnded(touch,event)
    end,cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self._touchPanel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._touchPanel)
end

---
-- 触摸开始
-- @function [parent=#RunicFightView] _onTouchBegin
-- @param #RunicFightView self
-- @param #Touch touch
-- @param #Event event
function RunicFightView:_onTouchBegin(touch,event)
    if not self._isPlaying then return end
    self._isTouching = true
    local point = touch:getLocation()
	self._gesture:init()
    self._gesture:addPoint(point)  
    self:_addEmitter(point.x,point.y)
    --self._prePoint = point
end

---
-- 触摸移动
-- @function [parent=#RunicFightView] _onTouchMove
-- @param #RunicFightView self
-- @param #Touch touch
-- @param #Event event
function RunicFightView:_onTouchMove(touch,event)
    if not self._isPlaying then return end
    local point = touch:getLocation()
    self._gesture:addPoint(point)
    self._emitter:setPosition(point)
end

---
-- 触摸结束
-- @function [parent=#RunicFightView] _onTouchEnded
-- @param #RunicFightView self
-- @param #Touch touch
-- @param #Event event
function RunicFightView:_onTouchEnded(touch,event)
    if not self._isPlaying then return end
    self._isTouching = false
    local point = touch:getLocation()
    self._gesture:addPoint(point)
    self._emitter:setPosition(point)
    self._emitter:stopSystem()
    local points,type = self._gesture:calculate()
    type = self:_converterType(type)
    if not type then return end
    self:_runicJudge(type)
end

---
-- 符文判定
-- @function [parent=#RunicFightView] _runicJudge
-- @param #RunicFightView self
-- @param #number type 手势方向
function RunicFightView:_runicJudge(type)
    local harmType = nil
    local runic = nil
    local runicIndex = nil
    for k,v in ipairs(self._runics) do
        if v.isAlive then
            runic = v
            runicIndex = k
            local pointX = v:getPositionX()
            --if v.type == type then
                if pointX >= self._radar.perfectLeftX and pointX <= self._radar.perfectRightX then
                    if v.type == type then
                        harmType = 1
                    else
                        harmType = 2
                    end
                    self._seriesCount = self._seriesCount + 1
                elseif pointX >= self._radar.goodLeftX and pointX <= self._radar.goodRightX then
                    harmType = 2
                    self._seriesCount = self._seriesCount + 1
                elseif pointX >= self._radar.commonLeftX and pointX <= self._radar.commonRightX then
                    harmType = 3
                    self._seriesCount = 0
                else
                    self._seriesCount = 0    
                end
--            else
--                self._seriesCount = 0
--                if pointX <= self._radar.commonRightX then
--                    v.isAlive = false
--                    self:_grayRunic(v)
--                end
--            end
            break
        end
    end
    if harmType then
        self:_flyFont(harmType,type)
        runic:removeFromParent()
        table.remove(self._runics,runicIndex)
        if harmType == 1 or harmType == 2 then -- 设置最大连击数
            ch.StatisticsModel:setMaxSeriesTimes(self._seriesCount)
        end
        ch.StatisticsModel:addRunicTimes(1)  --添加有效符文操作
        local harm,isCrit = self:_getRunicHarmData(harmType)
        if isCrit then
            ch.StatisticsModel:addRunicCritTimes(1)
        end
        ch.fightRoleLayer:fuwenAttack(harm,type,isCrit)
    else
        self._seriesPanel:setVisible(false)
        if self._seriesSchedulerId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._seriesSchedulerId)
            self._seriesSchedulerId = nil
        end    
    end
end

---
-- 计算符文伤害
-- @function [parent=#RunicFightView] _getRunicHarmData
-- @param #RunicFightView self
-- @param #number harmType
-- @return #number
function RunicFightView:_getRunicHarmData(harmType)
    local isCrit = false
    local dps = ch.RunicModel:getDPS()
    local r = math.random(1,10000)
    if r <= ch.RunicModel:getCritRate()*10000 then
        isCrit = true
        dps = dps * ch.RunicModel:getCritTimes()
    end
	
	dps = dps * GameConst.RUNIC_GESTURE_HARM_FACTOR[harmType]
    cclog("手势伤害加成为："..GameConst.RUNIC_GESTURE_HARM_FACTOR[harmType])
	if self._seriesCount >= GameConst.RUNIC_SERIES_STEP then
        local index = math.floor(self._seriesCount/GameConst.RUNIC_SERIES_STEP)
        if index > table.maxn(GameConst.RUNIC_SERIES_HARM_FACTOR) then
            index = table.maxn(GameConst.RUNIC_SERIES_HARM_FACTOR)
        end
        dps = dps * GameConst.RUNIC_SERIES_HARM_FACTOR[index]
        cclog("连接伤害加成为："..GameConst.RUNIC_SERIES_HARM_FACTOR[index])
	end
    return dps,isCrit
end

---
-- 初始化雷达位置信息
-- @function [parent=#RunicFightView] _initRadarPositionInfo
-- @param #RunicFightView self
function RunicFightView:_initRadarPositionInfo()
    self._radar = {}
    self._radar.centerX = self.radarPositionX
    self._radar.radius = self.runicRatio
    self._radar.perfectLeftX = self._radar.centerX - GameConst.RUNIC_GESTURE_HARM_JUDGE[1]
    self._radar.perfectRightX = self._radar.centerX + GameConst.RUNIC_GESTURE_HARM_JUDGE[1]
    self._radar.goodLeftX =  self._radar.centerX - GameConst.RUNIC_GESTURE_HARM_JUDGE[2]
    self._radar.goodRightX =  self._radar.centerX + GameConst.RUNIC_GESTURE_HARM_JUDGE[2]
    self._radar.commonLeftX = self._radar.centerX - GameConst.RUNIC_GESTURE_HARM_JUDGE[3]
    self._radar.commonRightX = self._radar.centerX + GameConst.RUNIC_GESTURE_HARM_JUDGE[3]
end

---
-- 初始化符文位置信息
-- @function [parent=#RunicFightView] _initRunicPositionInfo
-- @param #RunicFightView self
function RunicFightView:_initRunicPositionInfo()
    local director = cc.Director:getInstance()
    self._runicLeftBorderPointX = - self.runicRatio
    self._runicDistance = self.runicRatio * 2 + self.runicMargin
end

---
-- 获得符文类型总权重
-- @function [parent=#RunicFightView] _onTouchEnded
-- @param #RunicFightView self
function RunicFightView:_getTotalRatio()
	local ratio = 0
	for _,v in ipairs(GameConst.RUNIC_MAP_RATIO) do
	   ratio = ratio + v
	end
	return ratio
end

---
-- 随机获得符文类型
-- @function [parent=#RunicFightView] _getRandomMap
-- @param #RunicFightView self
-- @return #table
function RunicFightView:_getRandomMap()
    local num = math.random(1,self._totalRatio)
    local totalValue = 0
    local type = nil
    for k,v in ipairs(GameConst.RUNIC_MAP_RATIO) do
        totalValue = totalValue + v
        if num <= totalValue then
            type = k
            break
        end
    end
    return GameConst.RUNIC_MAP[type]
end

---
-- 添加新的符文
-- @function [parent=#RunicFightView] _addRunics
-- @param #RunicFightView self
-- @param #number shifting 起始点 左偏移量
function RunicFightView:_addRunics(shifting)
    if not shifting then shifting = 0 end
	local map = self:_getRandomMap()
	for k,v in ipairs(map) do
       local runic = nil
	   if v == 2 then
	       local type = math.random(1,4)
	       runic = self:createRunic(type)  
	   elseif v == 1 then
            runic = self:createRunic(5) 
	   end
	   if runic then
           runic:setPositionX(self.runicStartPointX - shifting + (k-1)*self._runicDistance)
           self._runicContainer:addChild(runic)
           table.insert(self._runics,runic)
       end
	end
end

---
-- 添加新的符文, 1为横，2为竖，3为左上，4为右下,5为点
-- @function [parent=#RunicFightView] createRunic
-- @param #RunicFightView self
-- @param #number type 
-- @return #Sprite
function RunicFightView:createRunic(type)
    local fileName = string.format("aaui_fuwen/fuwen%d.png",type)
    local sprite = cc.Sprite:createWithSpriteFrameName(fileName)
	sprite.type = type
	sprite.isAlive = true
	return sprite
end

---
-- 添加判定文字，并执行动画
-- @function [parent=#RunicFightView] _flyFont
-- @param #RunicFightView self
-- @param #number harmType
-- @param #number runicType
function RunicFightView:_flyFont(harmType,runicType)
    self._armature:setVisible(true)
    local name = string.format("%s_%s",GameConst.RUNIC_RESULT[harmType],GameConst.RUNIC_COLOR[runicType])
    self._armature:getAnimation():play(name)
    if self._seriesCount > 1 then
        self._seriesTime = os_clock()
        self._seriesText:setString(self._seriesCount)
        if not self._seriesSchedulerId then
            self._seriesPanel:setVisible(true)
            self._seriesSchedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
                if os_clock() - self._seriesTime > 1 then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._seriesSchedulerId)
                    self._seriesSchedulerId = nil
                    self._seriesPanel:setVisible(false)
                end
            end,1,false)
        end
    end
end

---
-- 在指定位置添加新的粒子特效
-- @function [parent=#RunicFightView] _addEmitter
-- @param #RunicFightView self
-- @param #number x
-- @param #number y
function RunicFightView:_addEmitter(x,y)
    self._emitter = cc.ParticleSystemQuad:create("res/effect/fuwen.plist")
    self._emitter:setAutoRemoveOnFinish(true)
    self._emitter:setPosition(x,y)
    self._touchPanel:addChild(self._emitter)
end

---
-- 让符文变灰
-- @function [parent=#RunicFightView] _grayRunic
-- @param #RunicFightView self
-- @param #Sprite sprite
function RunicFightView:_grayRunic(sprite)
    local fileName = string.format("aaui_fuwen/fuwen%dg.png",sprite.type)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(fileName)
    sprite:setSpriteFrame(frame)
end

---
-- 转换类型
-- @function [parent=#RunicFightView] _converterType
-- @param #RunicFightView self
-- @param #number type
-- @return #number
function RunicFightView:_converterType(type)
    if not type then return nil end
    if type == ch.Gesture.type.up or type == ch.Gesture.type.down then
        return 2
    elseif type == ch.Gesture.type.right or type == ch.Gesture.type.left then
        return 1
    elseif type == ch.Gesture.type.rightUp or type == ch.Gesture.type.leftDown then
        return 4
    elseif type == ch.Gesture.type.rightDown or type == ch.Gesture.type.leftUp then
        return 3
    elseif type == ch.Gesture.type.click then
        return 5   
    end
    return nil
end


return RunicFightView