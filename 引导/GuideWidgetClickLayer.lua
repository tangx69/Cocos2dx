local Layer = require("sg.layer.Layer")
local GuideWidgetClickLayer = class("GuideWidgetClickLayer", Layer)

local DataWarehouse = require("sg.model.DataWarehouse")
local PubModel = require("sg.model.PubModel")
local TipsWnd=require("sg.component.TipsWnd")

--下面这些点击对象是层，锚点在左下(按钮在正中)，因此需要修正手指的位置
local layer_widgets = {
	"TipsRecruit_Hero+T_Panel_HeroProperty",
	"HeroesMainUI_New+T_Select+FIRST_MONEY_RECRUIT_HERO_ID",
	"HeroesMainUI_New+T_Select+FIRST_COIN_RECRUIT_HERO_ID",
	"EquipContainer+ItemUnitUI_Accessory+6",
	"EquipContainer+ItemUnitUI_Accessory+7",
	"EquipContainer+ItemUnitUI_Accessory+15",
	"EnchantressUI_Lingering+T_Btn_Enchantress+1",
	"Panel_AscensionBtn+BtnDaliy+1",
	"MainScene+T_Panel_VIP",
}

--uiString:"画布名+组件名"
function GuideWidgetClickLayer:ctor(uiString)
    local GuideHandler = require("sg.model.GuideHandler")
    
    cclog("新手引导层需要点击按钮:"..uiString)
    if uiString == "MainScene+btnGuild" then
        if  DataWarehouse:getInstance().societysShow == false then
            DataWarehouse:getInstance().societysShow = true
            local panel = DataWarehouse:getInstance():findWiget("MainScene+panelSociety")
            panel:setVisible(true)
        end
    end
    
    --关闭自动调用dtor释放资源
    self.super.ctor(self)
    
    self.timeout = 0
    
    --创建遮蔽遮罩
    GuideHandler:getInstance():addTouchMask()
    
    --director_after_draw事件
    local _listener
    local function _handler(event)
        cclog("director_after_draw事件触发之后,显示引导")
        cc.Director:getInstance():getEventDispatcher():removeEventListener(_listener)
        _listener = nil
        self.director_after_draw = true
    end

    local eventName = "director_after_draw"
    _listener = cc.EventListenerCustom:create(eventName, _handler)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(_listener, 1)
    
    --从资源池中根据画布名+组件名找到组件句柄
    --local widget = DataWarehouse:getInstance():findWiget(uiString)
    local widget = nil
    if widget == nil then
        GuideWidgetClickLayerTimer = nil
        local function onTimerEnd(sender, eventType)
            if self.timeout ~= nil then
                self.timeout = self.timeout+1
            else
                --处理意外,释放资源
                GuideHandler:getInstance().guideLayer = nil
                cclog("[INFO]<GuideWidgetClickLayer.lua line46:self.timeout == nil> endGuide")
                GuideHandler:getInstance():endGuide()
                GuideHandler:getInstance():removeTouchMask()
                if GuideWidgetClickLayerTimer ~= nil then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(GuideWidgetClickLayerTimer)
                    GuideWidgetClickLayerTimer = nil
                end
                
                return
            end
            
            --超时退出
            if self.timeout >= 50 then
                --处理意外,释放资源
                cclog("[ERROR]<GuideWidgetClickLayer :找不到按钮%s == nil> endGuide", uiString)
                if GuideWidgetClickLayerTimer ~= nil then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(GuideWidgetClickLayerTimer)
                    GuideWidgetClickLayerTimer = nil
                end
                
                GuideHandler:getInstance().guideLayer = nil
                GuideHandler:getInstance():endGuide()
                
                GuideHandler:getInstance():removeTouchMask()
                
                return
            end
            --未超时,寻找UI组件
            if self.director_after_draw == true and self.timeout >= 2 then
                widget = DataWarehouse:getInstance():findWiget(uiString)
                --widget = GuideHandler:getInstance():findWiget(uiString)
                if widget ~= nil then
                    if GuideWidgetClickLayerTimer ~= nil then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(GuideWidgetClickLayerTimer)
                        GuideWidgetClickLayerTimer = nil
                    end
                    self:showGuideLayer(uiString)
                end
             end
        end
        GuideWidgetClickLayerTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, onTimerEnd), 0.1, false)
    else
        self:showGuideLayer(uiString)
    end
end

function GuideWidgetClickLayer:close()
    self:removeFromParent()
end

function GuideWidgetClickLayer:showGuideLayer(uiString)
    self.uiString = uiString
    
    local GuideHandler = require("sg.model.GuideHandler")
    GuideHandler:getInstance():removeTouchMask()
    
    --临时突出按钮,引导结束后恢复
    local widget = DataWarehouse:getInstance():findWiget(uiString)
	widget:retain()
    if self.widget~=nil then
        self.widget:release()
    end
    self.widget = widget
    self.widgetZOrder = widget:getGlobalZOrder()
	
	--if "TipsRecruit_Hero+T_Panel_HeroProperty" ~= uiString then
		widget:setGlobalZOrder(200)
	--end

    --创建镂空单元
    --local pos = widget:convertToWorldSpace(cc.p(0,0))
    
    local pos = widget:getWorldPosition()
	--普通层的锚点在0,0（按钮的锚点在0.5,0.5）,因此通过普通层定位时,需要往右上调整半个身位
    if table.v2k(layer_widgets, uiString) then
        local height = widget:getSize().height
		local width = widget:getSize().width
        pos.y = pos.y + height * 0.5
		pos.x = pos.x + width * 0.5
    end

    local stencilFile = cc.SLGameDataCache:getInstance():widgetFromFile("CocoStudio/UI/NewbieGuideUI_Shade_Only.json")
    local stencil = ccui.Helper:seekWidgetByName(stencilFile, "Panel_Shade")

    --[[stencil添加点击事件，任意区域都有效，暂时去掉
    self.touchListener = cc.EventListenerTouchOneByOne:create()
    self.touchListener:setSwallowTouches(false)
    self.touchListener:registerScriptHandler(handler(stencil, self.onStencilTouch),cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = stencil:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.touchListener, -1)
    ]]--

    local size = widget:getContentSize()
    stencil:setContentSize(size.width, size.height)
    stencil:ignoreAnchorPointForPosition(false)
    --stencil:setAnchorPoint(0,0)
    stencil:setAnchorPoint(0.5,0.5)
    stencil:setPosition(pos.x, pos.y)

    --计算设备UI缩放比例
    --local framesize = cc.Director:getInstance():getWinSize()
    --pos.x = pos.x+math.floor((framesize.width-framesize.height*1.5)/2)
    --stencil:setPosition(pos.x, pos.y)


    --设置引导层
    local clipper = cc.ClippingNode:create()
    clipper:setStencil(stencil)--设置裁剪模板 --3
    clipper:setInverted(true)--设置底板可见
    clipper:setAlphaThreshold(0) --设置绘制底板的Alpha值为0
    
    --添加遮罩遮罩
    local jsonFile = cc.SLGameDataCache:getInstance():widgetFromFile("CocoStudio/UI/NewbieGuideUI_Shade.json")
    local remove = ccui.Helper:seekWidgetByName(jsonFile, "Panel_Shade")
    remove:setVisible(false)
    local mask = jsonFile
    mask:removeFromParent()
    clipper:addChild(mask)--5
    self:addChild(clipper)
	clipper:setOpacity(0)

    --[[
    --添加模糊边缘
    local edgeJson = cc.SLGameDataCache:getInstance():widgetFromFile("CocoStudio/UI/NewbieGuideUI_Shade_Only.json")
    local edge = ccui.Helper:seekWidgetByName(edgeJson, "Panel_Shade")
    edge:setContentSize(size.width, size.height)
    edge:setScale(1.2)
    edge:setPosition(pos.x, pos.y)
    edge:removeFromParent()
    self:addChild(edge)
    ]]-- 

    --添加点击动画
    local fingerJson = cc.SLGameDataCache:getInstance():widgetFromFile("CocoStudio/UI/NewbieGuideUI_Finger.json")
    local Panel_Finger = ccui.Helper:seekWidgetByName(fingerJson, "Panel_Finger")
    self:turnFinger(Panel_Finger, pos)
    --Panel_Finger:setPosition(pos.x + size.width/2, pos.y+size.height/2)
    Panel_Finger:setPosition(pos.x, pos.y)
    Panel_Finger:removeFromParent()
    self:addChild(Panel_Finger)
    ccs.ActionManagerEx:getInstance():playActionByName("NewbieGuideUI_Finger.json","AnimationFinger")
end

function GuideWidgetClickLayer:onStencilTouch()
    local GuideHandler = require("sg.model.GuideHandler")
    GuideHandler:getInstance():dispatchEvent({_evt=GuideHandler.EVENT_STENCIL_CLICK})
    cclog("GuideWidgetClickLayer:onStencilTouch!!!")
    
    --self:close()
end

function GuideWidgetClickLayer:turnFinger(finger, pos)
    --获取动画尺寸
    local size = finger:getContentSize()
    
    --获取屏幕尺寸
    local winSize = cc.Director:getInstance():getVisibleSize()
    
    --如果动画最高处超出屏幕上边缘,则旋转180度
    if pos.y + size.height > winSize.height then
        finger:setRotation(180)
    end
end

function GuideWidgetClickLayer:dtor()
    ccs.ActionManagerEx:getInstance():releaseActionsByKey("NewbieGuideUI_Finger.json", true)
    
    --恢复组件的ZOrder
    if  self.widget ~= nil then
        if self.uiString == "DialogueUI+T_DialogContent" 
		or self.uiString == "TipsRecruit_Hero+T_Panel_HeroProperty" then
        else
            self.widget:setGlobalZOrder(self.widgetZOrder)
        end
		
        self.widget:release()
    end

    --释放触摸监听
    if self.touchListener ~= nil then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.touchListener)
        self.touchListener = nil
    end
    
    --释放定时器
    if GuideWidgetClickLayerTimer ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(GuideWidgetClickLayerTimer)
        GuideWidgetClickLayerTimer = nil
    end
end

return GuideWidgetClickLayer
