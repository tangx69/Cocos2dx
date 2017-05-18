local Layer = require("sg.layer.Layer")
local FunctionOpenLayer = class("FunctionOpenLayer", Layer)

local Utils = require("sg.util.Utils")
local EMQuality = require("gsg.em.EMQuality")
local DataWarehouse = require("sg.model.DataWarehouse")
local GuideHandler = require("sg.model.GuideHandler")
local SoundManager = require("sg.model.SoundManager")
local HeroShowUnit=require("sg.component.HeroShowUnit")

local EMFunction = require("gsg.em.EMFunction")
local FunctionOpenManager = require("sg.layer.guide.FunctionOpenManager")
local FunctionManager = require("sg.model.FunctionManager")

function FunctionOpenLayer:ctor(emFunctions)
    self.super.ctor(self)

    local scene = cc.Director:getInstance():getRunningScene()
    self:setColor(cc.c3b(255,0 ,0))
    scene:addChild(self)
    
	--添加点击屏蔽
	GuideHandler:getInstance():addTouchMask()
	
	self.icons, self.funcBtns = {}, {}
	
	--先放背景光
    self:showEffectLight(emFunctions)
	--再放按钮
    self:showIcon(emFunctions)
	--再放文字
    self:showEffectText(emFunctions)
	
	local function onTimerEnd()
		if self.timer ~= nil then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		end
		self.effect1:setVisible(false)
		self.effect2:setVisible(false)
		for k,icon in pairs(self.icons) do
            --local goalPos = self:getIconTargetPos(emFunctions,k)
            local goalPos = self.funcBtns[k]:getWorldPosition()
            
			local actionTo = cc.MoveTo:create(0.7, cc.p(goalPos.x, goalPos.y))
			local actionFadeOut = cc.FadeOut:create(0.2)
			
			local function close()
				--显示按钮层（在进主城时，处理UI的时候关闭）
				for k,funcBtn in pairs(self.funcBtns) do
					funcBtn:getParent():setVisible(true)
				end
				
				self:close()
				
				--任务引导->功能开放->功能引导
				GuideHandler:getInstance():startDoGuideOneByOne()
			end
			local callFunc = cc.CallFunc:create(close)
		
			icon:runAction(cc.Sequence:create(actionTo, actionFadeOut, callFunc))
		end
	end        
	self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onTimerEnd, 2, false)
end

function FunctionOpenLayer:dtor()
	if self.timer ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
    end 
end

function FunctionOpenLayer:close()
    self:removeFromParent()
	--去掉屏蔽点击
	GuideHandler:getInstance():removeTouchMask()
end

function FunctionOpenLayer:showIcon(emFunctions)
	local framesize = cc.Director:getInstance():getWinSize()
    local FunctionOpenManager = require("sg.layer.guide.FunctionOpenManager")
	for k,emFunction in pairs(emFunctions) do
		self.icons[k], self.funcBtns[k] = FunctionOpenManager:getInstance():findBtnByFunc(emFunction)
		--添加ICON
		self.icons[k]:setTouchEnabled(false)
		self:addChild(self.icons[k])
		self.icons[k]:setPosition(framesize.width/2,framesize.height/2)
	end
end

function FunctionOpenLayer:showEffectLight(emFunctions)
    self.effect1 = cc.SLUIDisplayAPI:createWithName("ui_guangmang", "animation", true, "sl_ui_ui_guangmang")
    local framesize = cc.Director:getInstance():getWinSize()
    self.effect1:setPosition(framesize.width/2,framesize.height/2)
    self:addChild(self.effect1)
    SoundManager:getInstance():playEffect("ui_new_func")
    for k,emFunction in pairs(emFunctions) do
        if emFunction == EMFunction.melee or
            emFunction == EMFunction.activityChangAn or
            emFunction == EMFunction.activitySupremacy then
            return
        end
    end
	SoundManager:getInstance():playEffect("jq_31")
end

function FunctionOpenLayer:showEffectText(emFunctions)
    for k,emFunction in pairs(emFunctions) do
        if emFunction == EMFunction.melee or  emFunction == EMFunction.activityChangAn or
           emFunction == EMFunction.activitySupremacy then
            self.effect2 = cc.SLUIDisplayAPI:createWithName("ui_kaiqitishi", "animation3", true, "sl_ui_ui_text")
            local framesize = cc.Director:getInstance():getWinSize()
            self.effect2:setPosition(framesize.width/2,framesize.height/2)
            self:addChild(self.effect2)
            return
        end
    end
    self.effect2 = cc.SLUIDisplayAPI:createWithName("ui_kaiqitishi", "animation", true, "sl_ui_ui_text")
    local framesize = cc.Director:getInstance():getWinSize()
    self.effect2:setPosition(framesize.width/2,framesize.height/2)
    self:addChild(self.effect2)
end

function FunctionOpenLayer:getIconTargetPos(emFunctions,index)
    local goalPos = self.funcBtns[index]:getWorldPosition()
    if table.v2k(emFunctions,EMFunction.melee) == index then
        goalPos = FunctionOpenManager:getInstance():getFuntionTargetPos(EMFunction.melee)
    elseif table.v2k(emFunctions,EMFunction.activityChangAn) == index then
        goalPos = FunctionOpenManager:getInstance():getFuntionTargetPos(EMFunction.activityChangAn)
    elseif table.v2k(emFunctions,EMFunction.activitySupremacy) == index then
        goalPos = FunctionOpenManager:getInstance():getFuntionTargetPos(EMFunction.activitySupremacy)
    end
    --[[
    if table.v2k(emFunctions,EMFunction.melee) == index and DataWarehouse:getInstance().T_Panel_Giving:isVisible() == false then
        goalPos = FunctionOpenManager:getInstance():getFuntionTargetPos(EMFunction.melee)
    elseif table.v2k(emFunctions,EMFunction.activityChangAn) == index and DataWarehouse:getInstance().T_Panel_Giving:isVisible() == false then
        goalPos = FunctionOpenManager:getInstance():getFuntionTargetPos(EMFunction.activityChangAn)
    elseif table.v2k(emFunctions,EMFunction.activitySupremacy) == index and DataWarehouse:getInstance().T_Panel_Giving:isVisible() == false then
        goalPos = FunctionOpenManager:getInstance():getFuntionTargetPos(EMFunction.activitySupremacy)
    end
    ]]
    return goalPos
end

return FunctionOpenLayer
