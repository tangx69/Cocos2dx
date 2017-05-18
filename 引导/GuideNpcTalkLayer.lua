local Layer = require("sg.layer.Layer")
local GuideNpcTalkLayer = class("GuideNpcTalkLayer", Layer)

local DataWarehouse = require("sg.model.DataWarehouse")
local InteractUser = require("sg.interact.InteractUser")
local PubModel = require("sg.model.PubModel")
local InteractInfo = require("sg.interact.InteractInfo")

--uiString:"画布名+组件名"
function GuideNpcTalkLayer:ctor(talks, npcPosition)
    local GuideHandler = require("sg.model.GuideHandler")
    GuideHandler:getInstance():removeTouchMask()
    
    --关闭自动调用dtor释放资源
    self.super.ctor(self)
    
    self.talks = talks
    self.npcPosition = npcPosition
    
    self.talkIndex = 1
    
    self.mainUI = cc.SLGameDataCache:getInstance():widgetFromFile("CocoStudio/UI/NewbieGuideUI_TextBox3.json")
	self:addChild(self.mainUI)
	
	--播放动画
    ccs.ActionManagerEx:getInstance():playActionByName("NewbieGuideUI_TextBox3.json", "Animation0")
	
    local panelLeft = ccui.Helper:seekWidgetByName(self.mainUI, "Panel_All")
    local panelRight = ccui.Helper:seekWidgetByName(self.mainUI, "Panel_Text_Box_R")
    if panelRight then
        panelRight:setVisible(false)
    end
    panelLeft:setScale(0.8,0.8)
--    panelLeft:se
    self.panel = panelLeft
    
	
	--触摸监听
	local function onTouched(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
        self:doTalks()
       end
    end
    self.mainUI:addTouchEventListener(onTouched)

    --说话
    self:doTalks()
end

function GuideNpcTalkLayer:touchDisable()
    cclog("touchDisable")
end

function GuideNpcTalkLayer:doTalks()
    if self.talkIndex <= #self.talks then
        
        local T_Text_Detail = ccui.Helper:seekWidgetByName(self.panel, "T_Text_Detail")
        T_Text_Detail:setString(self.talks[self.talkIndex])
        
        self.talkIndex = self.talkIndex + 1
    else
        self:talksOver()
    end
end

function GuideNpcTalkLayer:talksOver()
    local GuideHandler = require("sg.model.GuideHandler")
    GuideHandler:getInstance():dispatchEvent({name="EVENT_TALK_OVER"})
    
    self:Close()
end

function GuideNpcTalkLayer:Close()
    self:removeFromParent()
end

function GuideNpcTalkLayer:dtor()
    ccs.ActionManagerEx:getInstance():releaseActionsByKey("NewbieGuideUI_TextBox3.json", true)
end

return GuideNpcTalkLayer
