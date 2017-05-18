local GuideHandler = class("GuideHandler")

local InteractUser = require("sg.interact.InteractUser")
local PubModel = require("sg.model.PubModel")
local PubFunction = require("gsg.pub.PubFunction")
local InteractInfo = require("sg.interact.InteractInfo")
local GuideHandler = require("sg.model.GuideHandler")
local EMFunction = require("gsg.em.EMFunction")

local GuideWidgetClickLayer = require("sg.layer.guide.GuideWidgetClickLayer")
local GuideNpcTalkLayer = require("sg.layer.guide.GuideNpcTalkLayer")
local EventManager = require("sg.util.EventManager")
local EMMissionStatus = require("gsg.em.EMMissionStatus")

--将被点击物品名字显示在屏幕上
--GuideHandler.LOG2SCREEN = true

---------
--新号引导
GuideHandler.NEWBIE_GUIDE1 = 4
GuideHandler.NEWBIE_GUIDE2 = 110
GuideHandler.NEWBIE_GUIDE3 = 1

---------
--快速换装引导
GuideHandler.NEW_EQUIP_GUIDE = 99
--任务引导
GuideHandler.NEW_EQUIP_GUIDE = 110

---------
--命令类型

--箭头指向某一个UI组件
GuideHandler.COMMAND_TYPE_1 = 1
--其他需求程序可额外添加，例如弹出引导女，兵说一段话
GuideHandler.COMMAND_TYPE_2 = 2
--等待N秒
GuideHandler.COMMAND_TYPE_3 = 3
--等待事件发生
GuideHandler.COMMAND_TYPE_4 = 4
--等待动画播放完毕
GuideHandler.COMMAND_TYPE_5 = 5
--播放声音
GuideHandler.COMMAND_TYPE_6 = 6

---------
--完成条件类型

--UI组件被点击
GuideHandler.CONDITION_TYPE_1 = 1
--NPC说完话
GuideHandler.CONDITION_TYPE_2 = 2
--定时器超时
GuideHandler.CONDITION_TYPE_3 = 3
--事件发生
GuideHandler.CONDITION_TYPE_4 = 4
--动画播放完毕
GuideHandler.CONDITION_TYPE_5 = 5


--引导相关事件
--组件点击事件由GuideHandler监听,由功能模块发出
GuideHandler.EVENT_WIDGET_CLICK = "EVENT_WIDGET_CLICK"
GuideHandler.EVENT_TALK_OVER = "EVENT_TALK_OVER"
GuideHandler.EVENT_TIME_OVER = "EVENT_TIME_OVER"
GuideHandler.EVENT_STENCIL_CLICK = "EVENT_STENCIL_CLICK"
GuideHandler.EVENT_DONE = "EVENT_DONE" --参数done="事件名"
GuideHandler.EVENT_ANIMATION_OVER = "EVENT_ANIMATION_OVER" --参数animation="动画名"

function GuideHandler:getInstance()
    local o = _G.GuideHandler
    if o then return o end
    o = GuideHandler.new()
    _G.GuideHandler = o 
    setmetatable(o, self)
    self.__index = self
    return o
end

function GuideHandler:ctor()
    require("api.EventProtocol").extend(self)
    
    --监听GuideHandler发出事件
    self:addEventListener(GuideHandler.EVENT_WIDGET_CLICK, handler(self, self.widgetClickHander))
    --self:addEventListener(GuideHandler.EVENT_STENCIL_CLICK, handler(self, self.stencilClickHander))
    self:addEventListener(GuideHandler.EVENT_TALK_OVER, handler(self, self.talkOverHandler))
    self:addEventListener(GuideHandler.EVENT_TIME_OVER, handler(self, self.timeOverHandler))
    self:addEventListener(GuideHandler.EVENT_DONE, handler(self, self.doneHandler))
    self:addEventListener(GuideHandler.EVENT_ANIMATION_OVER, handler(self, self.animationOverHandler))
    
	--C++发出自定义事件
    self:listenCustomEvent()
end

function GuideHandler:hasNewBieGuide()
    if InteractUser:getInstance().user:getLevel() > 1 then
        return false
    end
    
    if InteractUser:getInstance():isGuideComplete(GuideHandler.NEWBIE_GUIDE1) ~= true then
        return true
    end
    if InteractUser:getInstance():isGuideComplete(GuideHandler.NEWBIE_GUIDE2) ~= true then
        return true
    end
    if InteractUser:getInstance():isGuideComplete(GuideHandler.NEWBIE_GUIDE3) ~= true then
        return true
    end
    
    return false 
end

--引导模块总入口
function GuideHandler:start()
    --如果是作弊模式,跳过引导
    if NO_GUIDE == true then
        return
    end

    --需找引导
    local guideIds = self:checkGuides()
    --执行引导
    self:startGuides(guideIds)
end

--检查是否有引导需要执行
function GuideHandler:checkGuides()
    if NO_GUIDE == true then
        return {}
    end
    
    local guideIds = {}

    --新注册用户的引导
    local newbieGuides = self:getGuideFromNewbie()
    for k,newbieGuide in pairs(newbieGuides) do
        table.insert(guideIds, newbieGuide)
    end

    --换装引导+任务引导
    if #guideIds == 0 then
        local quickEquipGuides = self:getGuideFromQuickEquip()
        for k,quickEquipGuide in pairs(quickEquipGuides) do
            table.insert(guideIds, quickEquipGuide)
        end

        local missionGuides = self:getGuidesFromMission()
        for k,missionGuide in pairs(missionGuides) do
            table.insert(guideIds, missionGuide)
        end
    end
    
    --如果是ios,遇到基金引导48，本次引导全部放弃
    if PubModel:getInstance():getConfig().noFund == true then
        for k,v in pairs(guideIds) do
            if v == 48 then
                guideIds = {}
                break
            end
        end
    end

    return guideIds
end

--onebyone执行当前搜索到的所有引导
function GuideHandler:startGuides(guideIds)
    cclog("-------将要执行下面引导--------")
    for k,v in pairs(guideIds) do
        cclog(v)
    end
    cclog("------------------------------")
    
    self.guideIds = guideIds
    if #self.guideIds > 0 then
        self.guideIndex = 1
        self:startDoGuideOneByOne()
    end
end

function GuideHandler:startDoGuideOneByOne()
    if self.guideIds == nil then
        return
    end

    --隐藏手指动画
    local fingerLayer = GuideHandler:getInstance().fingerLayer
    if fingerLayer then
        fingerLayer:setVisible(false)
    end
	
	--隐藏接任务等级不足提示
    local missionPromotionLayer = GuideHandler:getInstance().missionPromotionLayer
    if missionPromotionLayer then
        missionPromotionLayer:setVisible(false)
    end

    local ItemUnEnough = require("sg.component.ItemUnEnough")
    ItemUnEnough:getInstance():Close()
	
    if self.guideIndex <= #self.guideIds then
        local guideId = self.guideIds[self.guideIndex]
        self:startGuide(guideId)
        self.guideIndex = self.guideIndex + 1
    else
        self:endDoGuideOneByOne()
    end
end

function GuideHandler:endDoGuideOneByOne()
    --重新开启手指动画
    local fingerLayer = GuideHandler:getInstance().fingerLayer
    if fingerLayer then
        fingerLayer:setVisible(true)
    end

    self.guideIds = nil
    self.guideIndex = nil
end

--调用本函数,看是否有新手引导需要做
function GuideHandler:getGuideFromNewbie()
	if InteractUser:getInstance().user:getLevel() > 1 then
        return {}
    end
	
    local guidesNeedToDo = {}
    
    local curMissionId = InteractUser:getInstance():getMissionId()
    local curMissonState = InteractUser:getInstance():getMissionState()
    
    if InteractUser:getInstance():isGuideComplete(GuideHandler.NEWBIE_GUIDE1) ~= true then
        table.insert(guidesNeedToDo, GuideHandler.NEWBIE_GUIDE1)
    end
    if InteractUser:getInstance():isGuideComplete(GuideHandler.NEWBIE_GUIDE2) ~= true then
        if curMissionId == 1 and curMissonState == EMMissionStatus.ACCEPTABLE then
            table.insert(guidesNeedToDo, GuideHandler.NEWBIE_GUIDE2)
            table.insert(guidesNeedToDo, GuideHandler.NEWBIE_GUIDE3)
        end
    end
    if InteractUser:getInstance():isGuideComplete(GuideHandler.NEWBIE_GUIDE3) ~= true then
        if curMissionId == 1 and curMissonState == EMMissionStatus.ACCEPTED_UNFINISH then
            table.insert(guidesNeedToDo, GuideHandler.NEWBIE_GUIDE3)
        end
    end
    
    return guidesNeedToDo
end

--调用本函数,看是否有换装引导需要做
function GuideHandler:getGuideFromQuickEquip()
    local guidesNeedToDo = {}
    
    local curMissionId = InteractUser:getInstance():getMissionId()
    if curMissionId <= 5 then
        local quickEquipUI = GuideHandler:getInstance():findWiget("MainScene_NewEquip+T_Btn_Equip")
        if quickEquipUI then
            guidesNeedToDo =  {GuideHandler.NEW_EQUIP_GUIDE}
        end
    end
    
    return guidesNeedToDo
end

--调用本函数,看是否有任务引导需要做
function GuideHandler:getGuidesFromMission()
    local guideNeedToDo = {}

    --查看前一个任务有没有未完成的引导
    local curMissonState = InteractUser:getInstance():getMissionState()
    local curMissionId = InteractUser:getInstance():getMissionId()
    local missionDM = PubModel:getInstance():getMission(curMissionId)
    
    --如果当前任务可接受,或者已接受未完成,或者已完成未领取奖励.则检查前一个任务中有没有引导未完成
    if curMissonState ~= EMMissionStatus.FINISHED_UNREWARD then --已完成未交任务
        curMissionId  = curMissionId - 1
    end
    
    local missionDM = PubModel:getInstance():getMission(curMissionId)
    if missionDM then
        for k, guide in pairs(missionDM.guides or {}) do
            --判断引导是否完成
            if InteractUser:getInstance():isGuideComplete(guide) ~= true then
                if guide < 100 then
                    table.insert(guideNeedToDo, guide)
                end
                
                --如果是交任务的引导,则看任务是否处于可交状态
                if guide >= 100 then
                    if curMissonState == EMMissionStatus.FINISHED_UNREWARD then
                        table.insert(guideNeedToDo, guide)
                    end
                end
            end
        end
    end
    
    return guideNeedToDo
end

--主城中:调用guiGuideId后如果不是0,则调用本函数开始一个引导
--任务完成后:如果有功能开启,直接调用本函数
function GuideHandler:startGuide(guideId)
    if guideId == 0 then return end
    self.isInGuide = true

    --添加屏蔽
    self:addTouchMask()
   
    --取得guide信息
    local guide = PubModel:getInstance():getGuide(guideId)
    self.guide = guide
    
    self.stepIndex = 0
    
    self:doSteps()
end

function GuideHandler:endGuide()
    if self.guideLayer ~= nil then
        self.guideLayer:removeFromParent()
        self.guideLayer = nil
    end

    --通知服务器引导已完成
	if self.guide then
		self:finishGuide(self.guide.id)
	end
    
    self.isInGuide = false
    local guideId = self.guide.id
    self.guide = nil
    self.guideLayer = nil
    
    self:removeTouchMask()
    
    --一个引导结束,检查引导队列中是否有还有引导需要继续
    --如果是交任务引导，则看是否有功能要开放
    
    --如果是任务引导，则功能开放放在任务引导和功能引导中间，功能开放之后再调用引导
    if guideId >= 100 then
        local FunctionManager = require("sg.model.FunctionManager")
        FunctionManager:getInstance():start()
    else
        self:startDoGuideOneByOne()
    end
end

--执行引导,引导刚开始或者上一步结束时候调用
function GuideHandler:doSteps()
    if self.guideLayer ~= nil then
        self.guideLayer:removeFromParent()
        self.guideLayer = nil
    end

    self.stepIndex = self.stepIndex + 1
    if self.stepIndex <= #self.guide.steps then
        self:addTouchMask()
        self:doStep(self.guide.steps[self.stepIndex])
    else
        self:endGuide()
    end
end

function GuideHandler:doStep(step)
    if step == nil then return end

    if step.complete == true then
        --通知服务器引导已完成
        cclog("向服务器记录完成引导"..self.guide.id)
        self:finishGuide(self.guide.id)
    end
    --判断引导类型
    if step.command.guideCommand == GuideHandler.COMMAND_TYPE_1 then
        --箭头指向某一个UI组件,创建引导层
        self.guideLayer = GuideWidgetClickLayer.new(self.guide.steps[self.stepIndex].command.stringValues[1])
        --当前场景添加引导层
        --local scene = cc.Director:getInstance():getRunningScene()
        local scene = cc.Director:getInstance():getRunningScene()
        if self.guideLayer ~= nil then
            scene:addChild(self.guideLayer, 199,199)
        end
        
        cclog("===COMMAND_TYPE_1===")
    elseif step.command.guideCommand == GuideHandler.COMMAND_TYPE_2 then
    --其他需求程序可额外添加，例如弹出引导女说一段话
        local npcTalkLayer = GuideNpcTalkLayer.new(self.guide.steps[self.stepIndex].command.stringValues, self.guide.steps[self.stepIndex].command.numValues[1])
        
        --当前场景添加引导层
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(npcTalkLayer, 110)
        
        cclog("===COMMAND_TYPE_2===")
    elseif step.command.guideCommand == GuideHandler.COMMAND_TYPE_3 then
        --添加遮罩，等待超时
        --self:addTouchMask()
        local time = self.guide.steps[self.stepIndex].command.numValues[1]
        self.timer1 = nil
        local function onTimerEnd(sender, eventType)
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer1)
            self.timer1 = nil
            --新手引导:抛出事件
            GuideHandler:getInstance():dispatchEvent({name="EVENT_TIME_OVER"})
        end
        self.timer1 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, onTimerEnd), time, false)
        
        cclog("===COMMAND_TYPE_3===")
    elseif step.command.guideCommand == GuideHandler.COMMAND_TYPE_4 then
        --添加遮罩，等待事件发生
        self:addTouchMask()
        
        cclog("===COMMAND_TYPE_4===")
    elseif step.command.guideCommand == GuideHandler.COMMAND_TYPE_5 then
		--if step.command.numValues then
			--if step.command.numValues[1] == 1 then
				--添加遮罩,等待动画播放完成
				self:addTouchMask()
			--end
		--end

        cclog("===COMMAND_TYPE_5===")
    elseif step.command.guideCommand == GuideHandler.COMMAND_TYPE_6 then
        --播放声音
        local musicName = self.guide.steps[self.stepIndex].command.stringValues[1]
        cc.SLGameDataCache:getInstance():playEffect(musicName, false)
        cclog("===COMMAND_TYPE_6===")
		
		--语音播放无需等待，继续下面的步骤
		self:doSteps()
    end
end

function GuideHandler:addTouchMask()
    if self.touchMask == nil then
        local jsonFile = cc.SLGameDataCache:getInstance():widgetFromFile("CocoStudio/UI/NewbieGuideUI_Shade.json")
        local stencil = ccui.Helper:seekWidgetByName(jsonFile, "Panel_Shade")
        stencil:setVisible(false)
        self.touchMask = jsonFile
        self.touchMask:setOpacity(0)
        
        self.touchListener = cc.EventListenerTouchOneByOne:create()
        self.touchListener:setSwallowTouches(true)
        self.touchListener:registerScriptHandler(handler(self, self.touchDisable),cc.Handler.EVENT_TOUCH_BEGAN)
        local eventDispatcher = self.touchMask:getEventDispatcher()
        eventDispatcher:addEventListenerWithFixedPriority(self.touchListener, -10)
    
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(self.touchMask, 999,999)
        self.touchMask:retain()
        self.touchMask:registerScriptHandler(function(eventType)
            if eventType == "enter" then
                --do nothing
            elseif eventType == "cleanup" then
                self.touchMask:unregisterScriptHandler()
                if self.touchListener ~= nil then
                    cc.Director:getInstance():getEventDispatcher():removeEventListener(self.touchListener)
                    self.touchListener = nil
                end
                self.touchMask:release()
                self.touchMask = nil
            end
        end)
   end
end

function GuideHandler:touchDisable()
    cclog("引导中屏蔽点击！！！！！！！！！！！！")
end

function GuideHandler:removeTouchMask()
    if self.touchMask~=nil then
        self.touchMask:removeFromParent()
    end
end

function GuideHandler:stencilClickHander(_event)
    if self.guide == nil then
        return
    end
    
    --引导完成条件是点击
    local step = self.guide.steps[self.stepIndex]
    if step.completeCondition.guideCondition ~= GuideHandler.CONDITION_TYPE_1 then
        return
    end

    self:doSteps()
end

function GuideHandler:widgetClickHander(_event)
    if GuideHandler.LOG2SCREEN then
        self:log2Screen("[引导调试信息]:".._event.widget)
    end
    
    if self.isInGuide == true then
        cclog("新手引导收到按钮被点击:".._event.widget)
    end
    
    --有引导
    if self.guide == nil then
        return
    end
    
    --引导完成条件是点击
    local step = self.guide.steps[self.stepIndex]
    if step.completeCondition.guideCondition ~= GuideHandler.CONDITION_TYPE_1 then
        return
    end
    
    --是否是当前步骤完成条件中要求点击的widget被点击
    local widget = self.guide.steps[self.stepIndex].command.stringValues[1]
    if string.sub(widget, 1, string.len("MainScene+btn"))  ~= "MainScene+btn" then
        if widget ~= _event.widget then
            return
        end
    end

    self:doSteps()
end

function GuideHandler:talkOverHandler(_event)
    --有引导
    if self.guide == nil then
        return
    end
    
    --引导完成条件是说完话
    local step = self.guide.steps[self.stepIndex]
    if step.completeCondition.guideCondition ~= GuideHandler.CONDITION_TYPE_2 then
        return
    end
    
    self:doSteps()
end

function GuideHandler:timeOverHandler(_event)
    --有引导
    if self.guide == nil then
        return
    end
    
    local step = self.guide.steps[self.stepIndex]
    if step.completeCondition.guideCondition ~= GuideHandler.CONDITION_TYPE_3 then
        return
    end
    
    self:removeTouchMask()
    self:doSteps()
end

function GuideHandler:walkToCompleteHandler(_event)
    if self.guide == nil then
        return
    end
    
    local step = self.guide.steps[self.stepIndex]
    if step.completeCondition.guideCondition ~= GuideHandler.CONDITION_TYPE_4 then
        return
    end

    if step.completeCondition.stringValues[1] ~= "SL_GAME_EVENT_WALK_TO_COMPLETE" then
        return
    end
    
    self:removeTouchMask()
    self:doSteps()
end

function GuideHandler:cameraFocusHandler(_event)
    if self.guide == nil then
        return
    end
    
    local step = self.guide.steps[self.stepIndex]
    if step.completeCondition.guideCondition ~= GuideHandler.COMMAND_TYPE_4 then
        return
    end

    if step.completeCondition.stringValues[1] ~= "SL_GAME_EVENT_FOCUS_COMPLETE" then
        return
    end
    
    self:removeTouchMask()
    self:doSteps()
end

function GuideHandler:cameraUnfocusHandler(_event)
    if self.guide == nil then
        return
    end
    
    local step = self.guide.steps[self.stepIndex]
    if step.completeCondition.guideCondition ~= GuideHandler.COMMAND_TYPE_4 then
        return
    end

    if step.completeCondition.stringValues[1] ~= "SL_GAME_EVENT_UNFOCUS_COMPLETE" then
        return
    end
    
    self:removeTouchMask()
    self:doSteps()
end

function GuideHandler:doneHandler(_event)
    if self.guide == nil then
        return
    end
    
    local step = self.guide.steps[self.stepIndex]
    if step.completeCondition.guideCondition ~= GuideHandler.COMMAND_TYPE_4 then
        return
    end
    
    if step.completeCondition.stringValues[1] ~= _event.done then
        return
    end
    
    self:removeTouchMask()
    self:doSteps()
end

function GuideHandler:animationOverHandler(_event)
    if self.guide == nil then
        return
    end
    
    local step = self.guide.steps[self.stepIndex]
    if step.completeCondition.guideCondition ~= GuideHandler.COMMAND_TYPE_5 then
        return
    end
    
    if step.completeCondition.stringValues[1] ~= _event.animation then
        return
    end
    
    self:removeTouchMask()
    self:doSteps()
end

function GuideHandler:finishGuide(guide_id)
    if guide_id ~= nil and guide_id > 0 and guide_id < 100 then
        cclog("向服务器记录引导#"..guide_id)
        InteractInfo:getInstance():finishGuide(guide_id)
    end
end

function GuideHandler:findWiget(uiString)
    local GuideHandler = require("sg.model.GuideHandler")
    local widgetString = self:stringParseEx(uiString)
    local widget = nil
    for k,widgetName in pairs(widgetString) do
        if widgetName == "MainScene" then
            widget = GuideHandler:getInstance().layMainUI
        else
            local widgetTemp = ccui.Helper:seekWidgetByName(widget, widgetName)
            widget = widgetTemp
        end
    end
    
    return widget
end

function GuideHandler:stringParseEx(stringValue)
    local stringTmp = stringValue
    local s = {}
    while (string.len(stringTmp) > 0) do
        local plusPos = string.find(stringTmp, "+")
        if plusPos then
            table.insert(s, string.sub(stringTmp, 1, plusPos-1))
            stringTmp = string.sub(stringTmp, plusPos+1)
        else
            table.insert(s, stringTmp)
            break
        end
    end
    
    return s
end
function GuideHandler:listenCustomEvent()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

    local function walkToCompleteHandler(event)
        self:walkToCompleteHandler()
    end
    local walkCompleteListener = cc.EventListenerCustom:create("SL_GAME_EVENT_WALK_TO_COMPLETE", walkToCompleteHandler)
    eventDispatcher:addEventListenerWithFixedPriority(walkCompleteListener, 1)

    local function cameraFocusHandler(event)
        self:cameraFocusHandler()
    end
    local cameraFocusListener = cc.EventListenerCustom:create("SL_GAME_EVENT_FOCUS_COMPLETE", cameraFocusHandler)
    eventDispatcher:addEventListenerWithFixedPriority(cameraFocusListener, 1)

    local function cameraUnfocusHandler(event)
        self:cameraUnfocusHandler()
    end
    local cameraFocusListenerListener = cc.EventListenerCustom:create("SL_GAME_EVENT_UNFOCUS_COMPLETE", cameraUnfocusHandler)
    eventDispatcher:addEventListenerWithFixedPriority(cameraFocusListenerListener, 1)
end

function GuideHandler.stringParse(stringValue)
    --找到加号位置
    local plusPos = string.find(stringValue, "+")
    
    --将stringValue切分成ui+widget的形式
    local s = {}
    s.ui = string.sub(stringValue, 1, plusPos-1)
    s.widget = string.sub(stringValue, plusPos+1)
    
    return s
end


function GuideHandler:log2Screen(...)
    self.logLabels = self.logLabels or {}
    self.totalHeight = self.totalHeight or 0
    self.logIndex = self.logIndex or 1

    if self.logIndex >= 15 then
        for k,label in pairs(self.logLabels) do
            label:removeFromParent()
        end

        self.logLabels = {}
        self.logIndex = 1
        self.totalHeight = 0
    end

    if cc.Director:getInstance():getRunningScene() == nil then
        cc.Director:getInstance():runWithScene(cc.Scene:create())
    end
    local scene = cc.Director:getInstance():getRunningScene()
    local label = cc.Label:createWithSystemFont("", "", 18)
    label:setColor(GuideHandler.ColorBlue)
    --label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setString(string.format(...))
    label:setPosition(label:getContentSize().width/2,480-label:getContentSize().height/2-self.totalHeight)
    self.totalHeight = self.totalHeight + label:getContentSize().height
    scene:addChild(label)
    self.logLabels[self.logIndex] = label
    self.logIndex = self.logIndex + 1
end

function GuideHandler:setWidgetTouchEnabled(bTouch)
	if self.guideLayer and self.guideLayer.widget then
		self.guideLayer.widget:setTouchEnabled(bTouch)
		cclog("引导按钮设置")
	end
end


--组件注册和寻找：用于新手引导
function GuideHandler:registWiget(widget, name, index)
    self.widget = self.widget or {}
    
    if index == nil then
        self.widget[name] = widget
    else
        self.widget[name] = {}
        self.widget[name][index] = widget
    end
end

function GuideHandler:unRegistWiget(name)
    if self.widget then
		self.widget[name] = nil
	end
end

function GuideHandler:unRegistAllWigets()
    self.widget = nil
end

function GuideHandler:findWiget(name, index)
    if index == nil then
        return self.widget[name]
    else
        return self.widget[name][index]
    end
end

return GuideHandler
