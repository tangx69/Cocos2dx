local FunctionOpenManager = class("FunctionOpenManager")

local FunctionManager = require("sg.model.FunctionManager")
local EMFunction = require("gsg.em.EMFunction")
local DataWarehouse = require("sg.model.DataWarehouse")
local LocaleGlobal = require("src.gsg.locale.LocaleGlobal")

local EM_PANEL = {}
EM_PANEL.userInfo = 1
EM_PANEL.sysLeft = 2
EM_PANEL.sysUp = 3
EM_PANEL.Chat = 4
EM_PANEL.Right = 5
EM_PANEL.Reward = 6
EM_PANEL.Recharge = 7
EM_PANEL.List = 8
EM_PANEL.Hypotenuse = 9
EM_PANEL.Announcement = 10
EM_PANEL.Melee = 11
EM_PANEL.Society = 12
EM_PANEL.ChangAn = 13
EM_PANEL.HuangCheng = 14

function FunctionOpenManager:getInstance()
    local o = _G.FunctionOpenManager
    if o then return o end
    o = FunctionOpenManager.new()
    _G.FunctionOpenManager = o 
    setmetatable(o, self)
    self.__index = self
    return o
end

function FunctionOpenManager:ctor()
    self.listeners = {}
    self.listeners[1] = FunctionManager:getInstance():addEventListener(FunctionManager.FUNCTION_OPEN, handler(self, self.openFunction))
end

function FunctionOpenManager:registMainUI(mainUILayer)
    self.mainUILayer = mainUILayer
end

function FunctionOpenManager:openFunction(_event)
    local emFunctions = _event.emFunctions
    self:hdAllPanels(emFunctions)
    
    for k,emFunction in pairs(emFunctions) do
        if emFunction == EMFunction.guild then
            if  DataWarehouse:getInstance().societysShow == false then
                DataWarehouse:getInstance().societysShow = true
                self.mainUILayer.panels[EM_PANEL.Society]:setVisible(true)
            end
            break
        end
    end
    local FunctionOpenLayer = require("sg.layer.guide.FunctionOpenLayer")
	FunctionOpenLayer.new(emFunctions)
end

--处理所有
function FunctionOpenManager:hdAllPanels(emFunctions)
    self:hdPanelDownRight(emFunctions)
    self:hdPanelRightDown(emFunctions)
    self:hdPanelTop(emFunctions)
	self:hdPanelDownRight2(emFunctions)
    self:hdPenelTimingActivity(emFunctions)
    self:hdPanelMelee(emFunctions)
    self:hdPanelChangAn(emFunctions)
    self:hdPanelSociety(emFunctions)
    self:hdPanelList(emFunctions)
end

--处理sysleft面板,隐藏未开放的功能  
function FunctionOpenManager:hdPanelDownRight(emFunctions)
    --功能
    local funtions = {EMFunction.role, EMFunction.skill, EMFunction.beauty, EMFunction.hero, EMFunction.equip, EMFunction.style}

    --从面板下移动下来的button,存放起来备用(功能开放时重新放回)
    self.mainUILayer.tempBtnsSysLeft = {}
    self.mainUILayer.btnsSysLeft = {}

    for i=1,#funtions do
        --找到功能对应的btn
        self.mainUILayer.tempBtnsSysLeft[funtions[i]] = self.mainUILayer.panels[EM_PANEL.sysLeft].btns[funtions[i]]
        --从小层上取下该btn
        if self.mainUILayer.tempBtnsSysLeft[funtions[i]]:getParent() ~= nil then
            --self.mainUILayer.tempBtnsSysLeft[funtions[i]]:retain()
            self.mainUILayer.tempBtnsSysLeft[funtions[i]]:removeFromParent()
        end
    end

    local addFunctions = {}
    for i=#funtions,1,-1 do
        local panel = ccui.Helper:seekWidgetByName(self.mainUILayer.widgetUI, "Panel_Botton_"..i)
        for j=#funtions,1,-1 do
			local isOpend = (FunctionManager:isFunctionOpened(funtions[j]) == true)
			local isOpening = (table.v2k(emFunctions, funtions[j]) ~= nil)
			local notAdded = (addFunctions[j] ~= true)
            if (isOpend == true or isOpening == true) and notAdded == true then
                local btn = self.mainUILayer.tempBtnsSysLeft[funtions[j]]
                if btn:getParent() ~= nil then
                    btn:removeFromParent()
                end
                
                panel:addChild(btn)
                table.insert(self.mainUILayer.btnsSysLeft, btn)
                addFunctions[j] = true
                if isOpening then
                    self.mainUILayer.tempBtnsSysLeft[funtions[j]]:getParent():setVisible(false)
                end
                break
            end
        end
    end
end

--处理sysleft面板,隐藏未开放的功能  
function FunctionOpenManager:hdPanelDownRight2(emFunctions)
    --功能
    local funtions = {EMFunction.activity_secret_shop,EMFunction.morph,EMFunction.protoss}

    --从面板下移动下来的button,存放起来备用(功能开放时重新放回)
    self.mainUILayer.tempBtnsSysLeft2 = {}
    self.mainUILayer.btnsSysLeft2 = {}

    for i=1,#funtions do
        --找到功能对应的btn
        self.mainUILayer.tempBtnsSysLeft2[funtions[i]] = self.mainUILayer.panels[EM_PANEL.Hypotenuse].btns[funtions[i]]
        --从小层上取下该btn
        if self.mainUILayer.tempBtnsSysLeft2[funtions[i]]:getParent() ~= nil then
            --self.mainUILayer.tempBtnsSysLeft2[funtions[i]]:retain()
            self.mainUILayer.tempBtnsSysLeft2[funtions[i]]:removeFromParent()
        end
    end

    local addFunctions = {}
    for i=#funtions,1,-1 do
        local panelBig = ccui.Helper:seekWidgetByName(self.mainUILayer.widgetUI, "systemPanelHypotenuse")
		local panel = ccui.Helper:seekWidgetByName(panelBig, "Panel_Botton_"..i)
        for j=#funtions,1,-1 do
			local isOpend = (FunctionManager:isFunctionOpened(funtions[j]) == true)
			local isOpening = (table.v2k(emFunctions, funtions[j]) ~= nil)
			local notAdded = (addFunctions[j] ~= true)
            if (isOpend == true or isOpening == true) and notAdded == true then
                local btn = self.mainUILayer.tempBtnsSysLeft2[funtions[j]]
                if btn:getParent() ~= nil then
                    btn:removeFromParent()
                end
                
                panel:addChild(btn)
                table.insert(self.mainUILayer.btnsSysLeft2, btn)
                addFunctions[j] = true
                if isOpening then
                    self.mainUILayer.tempBtnsSysLeft2[funtions[j]]:getParent():setVisible(false)
                end
                break
            end
        end
    end
end

--处理sysUp面板,隐藏未开放的功能
function FunctionOpenManager:hdPanelTop(emFunctions)
    --功能
    local funtions = {EMFunction.seige, EMFunction.shilian, EMFunction.activity, EMFunction.bar, EMFunction.research, EMFunction.pvp, EMFunction.fight}

    --从面板下移动下来的button,存放起来备用(功能开放时重新放回)
    self.mainUILayer.tempBtnsTop = {}
    self.mainUILayer.btnsTop = {}

    for i=1,#funtions do
        --找到功能对应的btn
        self.mainUILayer.tempBtnsTop[funtions[i]] = self.mainUILayer.panels[EM_PANEL.Right].btns[funtions[i]]
        --从小层上取下该btn
        if self.mainUILayer.tempBtnsTop[funtions[i]]:getParent() ~= nil then
            --self.mainUILayer.tempBtnsTop[funtions[i]]:retain()
            self.mainUILayer.tempBtnsTop[funtions[i]]:removeFromParent()
        end
    end

    local addFunctions = {}
    for i=#funtions,1,-1 do
        local panel = ccui.Helper:seekWidgetByName(self.mainUILayer.widgetUI, "Panel_Top_"..i)
        for j=#funtions,1,-1 do
            local isOpend = (FunctionManager:isFunctionOpened(funtions[j]) == true)
            local isOpening = (table.v2k(emFunctions, funtions[j]) ~= nil)
            local notAdded = (addFunctions[j] ~= true)
            if (isOpend == true or isOpening == true) and notAdded == true then
                local btn = self.mainUILayer.tempBtnsTop[funtions[j]]
                if btn:getParent() ~= nil then
                    btn:removeFromParent()
                end
                panel:addChild(btn)
                table.insert(self.mainUILayer.btnsTop, btn)
                addFunctions[j] = true
                if isOpening then
                    self.mainUILayer.tempBtnsTop[funtions[j]]:getParent():setVisible(false)
                end
                break
            end
        end
    end
end

--处理sysUp面板,隐藏未开放的功能
function FunctionOpenManager:hdPanelRightDown(emFunctions)
    --功能
    local funtions = {EMFunction.dailytask, EMFunction.society, EMFunction.cimelia}
    if  FunctionManager:isFunctionOpened(EMFunction.cimelia) ~= true and
        FunctionManager:isFunctionOpened(EMFunction.society) == true and
        FunctionManager:isFunctionOpened(EMFunction.dailytask) == true then
        --只有日常和社交时 社交放上面
        funtions = {EMFunction.cimelia, EMFunction.society, EMFunction.dailytask}
    end

    --从面板下移动下来的button,存放起来备用(功能开放时重新放回)
    self.mainUILayer.tempBtnsSysUp = {}
    self.mainUILayer.btnsSysUp = {}

    for i=1,#funtions do
        --找到功能对应的btn
        self.mainUILayer.tempBtnsSysUp[funtions[i]] = self.mainUILayer.panels[EM_PANEL.sysUp].btns[funtions[i]]
        --从小层上取下该btn
        if self.mainUILayer.tempBtnsSysUp[funtions[i]]:getParent() ~= nil then
            --self.mainUILayer.tempBtnsSysUp[funtions[i]]:retain()
            self.mainUILayer.tempBtnsSysUp[funtions[i]]:removeFromParent()
        end
    end

    local addFunctions = {}
    for i=#funtions,1,-1 do
        local panel = ccui.Helper:seekWidgetByName(self.mainUILayer.widgetUI, "Panel_Right_"..i)
        for j=#funtions,1,-1 do
            local isOpend = (FunctionManager:isFunctionOpened(funtions[j]) == true)
            local isOpening = (table.v2k(emFunctions, funtions[j]) ~= nil)
            local notAdded = (addFunctions[j] ~= true)
            if (isOpend == true or isOpening == true) and notAdded == true then
                local btn = self.mainUILayer.tempBtnsSysUp[funtions[j]]
                if btn:getParent() ~= nil then
                    btn:removeFromParent()
                end
                panel:addChild(btn)
                table.insert(self.mainUILayer.btnsSysUp, btn)
                addFunctions[j] = true
                if isOpening then
                    self.mainUILayer.tempBtnsSysUp[funtions[j]]:getParent():setVisible(false)
                end
                break
            end
        end
    end
end

function FunctionOpenManager:hdPenelTimingActivity(emFunctions)
    self:hdPanelMelee(emFunctions)
    self:hdPanelChangAn(emFunctions)
    self:hdPanelHuangCheng(emFunctions)
end

function FunctionOpenManager:hdPanelMelee(emFunctions)
    --功能
    local funtions = {EMFunction.melee}

    --从面板下移动下来的button,存放起来备用(功能开放时重新放回)
    self.mainUILayer.tempBtnsMelee = {}
    self.mainUILayer.btnsMelee = {}

    for i=1,#funtions do
        --找到功能对应的btn
        self.mainUILayer.tempBtnsMelee[funtions[i]] = self.mainUILayer.panels[EM_PANEL.Melee].btns[funtions[i]]
        --从小层上取下该btn
        if self.mainUILayer.tempBtnsMelee[funtions[i]]:getParent() ~= nil then
            --self.mainUILayer.tempBtnsMelee[funtions[i]]:retain()
            self.mainUILayer.tempBtnsMelee[funtions[i]]:removeFromParent()
        end
    end

    local addFunctions = {}
    for i=#funtions,1,-1 do
        local panel = ccui.Helper:seekWidgetByName(self.mainUILayer.widgetUI, "T_Panel_Melee")
        for j=#funtions,1,-1 do
            local isOpend = (FunctionManager:isFunctionOpened(funtions[j]) == true)
            local isOpening = (table.v2k(emFunctions, funtions[j]) ~= nil)
            local notAdded = (addFunctions[j] ~= true)
            if (isOpend == true or isOpening == true) and notAdded == true then
                local btn = self.mainUILayer.tempBtnsMelee[funtions[j]]
                if btn:getParent() ~= nil then
                    btn:removeFromParent()
                end
                panel:addChild(btn)
                table.insert(self.mainUILayer.btnsMelee, btn)
                addFunctions[j] = true
                if isOpening then
                    self.mainUILayer.tempBtnsMelee[funtions[j]]:getParent():setVisible(false)
                end
                break
            end
        end
    end
end

--处理Melee面板,隐藏未开放的功能
function FunctionOpenManager:hdPanelChangAn(emFunctions)
    --功能
    local funtions = {EMFunction.activityChangAn}

    --从面板下移动下来的button,存放起来备用(功能开放时重新放回)
    self.mainUILayer.tempBtnsChangAn = {}
    self.mainUILayer.btnsChangAn = {}

    for i=1,#funtions do
        --找到功能对应的btn
        if self.mainUILayer.tempBtnsChangAn[funtions[i]]==nil then
            self.mainUILayer.tempBtnsChangAn[funtions[i]] = self.mainUILayer.panels[EM_PANEL.ChangAn].btns[funtions[i]]
            --self.mainUILayer.tempBtnsChangAn[funtions[i]]:retain()
        end

        --从小层上取下该btn
        self.mainUILayer.tempBtnsChangAn[funtions[i]]:removeFromParent()
    end

    local addFunctions = {}
    for i=#funtions,1,-1 do
        local panel = ccui.Helper:seekWidgetByName(self.mainUILayer.widgetUI, "T_Panel_ChangAn")
        for j=#funtions,1,-1 do
            local isOpend = (FunctionManager:isFunctionOpened(funtions[j]) == true)
            local isOpening = (table.v2k(emFunctions, funtions[j]) ~= nil)
            local notAdded = (addFunctions[j] ~= true)
            if (isOpend == true or isOpening == true) and notAdded == true then
                local btn = self.mainUILayer.tempBtnsChangAn[funtions[j]]
                if btn:getParent() ~= nil then
                    btn:removeFromParent()
                end
                panel:addChild(btn)
                table.insert(self.mainUILayer.btnsChangAn, btn)
                addFunctions[j] = true
                if isOpening then
                    self.mainUILayer.tempBtnsChangAn[funtions[j]]:getParent():setVisible(false)
                end
                break
            end
        end
    end
end

function FunctionOpenManager:hdPanelHuangCheng(emFunctions)
    --功能
    local funtions = {EMFunction.activitySupremacy}

    --从面板下移动下来的button,存放起来备用(功能开放时重新放回)
    self.mainUILayer.tempBtnsHuangCheng = {}
    self.mainUILayer.btnsHuangCheng = {}

    for i=1,#funtions do
        --找到功能对应的btn
        self.mainUILayer.tempBtnsHuangCheng[funtions[i]] = self.mainUILayer.panels[EM_PANEL.HuangCheng].btns[funtions[i]]
        --从小层上取下该btn
        if self.mainUILayer.tempBtnsHuangCheng[funtions[i]]:getParent() ~= nil then
            --self.mainUILayer.tempBtnsHuangCheng[funtions[i]]:retain()
            self.mainUILayer.tempBtnsHuangCheng[funtions[i]]:removeFromParent()
        end
    end

    local addFunctions = {}
    for i=#funtions,1,-1 do
        local panel = ccui.Helper:seekWidgetByName(self.mainUILayer.widgetUI, "T_Panel_Emperor")
        for j=#funtions,1,-1 do
            local isOpend = (FunctionManager:isFunctionOpened(funtions[j]) == true)
            local isOpening = (table.v2k(emFunctions, funtions[j]) ~= nil)
            local notAdded = (addFunctions[j] ~= true)
            if (isOpend == true or isOpening == true) and notAdded == true then
                local btn = self.mainUILayer.tempBtnsHuangCheng[funtions[j]]
                if btn:getParent() ~= nil then
                    btn:removeFromParent()
                end
                panel:addChild(btn)
                table.insert(self.mainUILayer.btnsHuangCheng, btn)
                addFunctions[j] = true
                if isOpening then
                    self.mainUILayer.tempBtnsHuangCheng[funtions[j]]:getParent():setVisible(false)
                end
                break
            end
        end
    end
end

--处理社交面板
function FunctionOpenManager:hdPanelSociety(emFunctions)
    --功能
    local funtions = {EMFunction.battleSupremacy,EMFunction.battleChangAn,EMFunction.guild}

    --从面板下移动下来的button,存放起来备用(功能开放时重新放回)
    self.mainUILayer.tempBtnsSociety = {}
    self.mainUILayer.btnsSociety = {}

    for i=1,#funtions do
        --找到功能对应的btn
        self.mainUILayer.tempBtnsSociety[funtions[i]] = self.mainUILayer.panels[EM_PANEL.Society].btns[funtions[i]]
        --从小层上取下该btn
        if self.mainUILayer.tempBtnsSociety[funtions[i]]:getParent() ~= nil then
            --self.mainUILayer.tempBtnsSociety[funtions[i]]:retain()
            self.mainUILayer.tempBtnsSociety[funtions[i]]:removeFromParent()
        end
    end

    local addFunctions = {}
    for i=#funtions,1,-1 do
        local panelBig = ccui.Helper:seekWidgetByName(self.mainUILayer.widgetUI, "systemSocial")
        local panel = ccui.Helper:seekWidgetByName(panelBig, "Panel_Botton_"..i)
        for j=#funtions,1,-1 do
            local isOpend = (FunctionManager:isFunctionOpened(funtions[j]) == true)
            local isOpening = (table.v2k(emFunctions, funtions[j]) ~= nil)
            local notAdded = (addFunctions[j] ~= true)
            if (isOpend == true or isOpening == true) and notAdded == true then
                local btn = self.mainUILayer.tempBtnsSociety[funtions[j]]
                if btn:getParent() ~= nil then
                    btn:removeFromParent()
                end
                panel:addChild(btn)
                
                --如果公会战功能开关是关闭的，皇城争霸/围攻长安按钮隐藏
                local PubModel = require("sg.model.PubModel")
                if (funtions[j] == EMFunction.battleSupremacy or funtions[j] == EMFunction.battleChangAn) 
                and PubModel:getInstance():getConfig().noGuildWar == true then
                    btn:setVisible(false)
                end
                
                table.insert(self.mainUILayer.btnsSociety, btn)
                addFunctions[j] = true
                if isOpening then
                    self.mainUILayer.tempBtnsSociety[funtions[j]]:getParent():setVisible(false)
                end
                break
            end
        end
    end
end

--处理List面板,隐藏未开放的功能
function FunctionOpenManager:hdPanelList(emFunctions)
    --功能
    local funtions = {EMFunction.list}

    --从面板下移动下来的button,存放起来备用(功能开放时重新放回)
    self.mainUILayer.tempBtnsList = {}
    self.mainUILayer.btnsList = {}

    for i=1,#funtions do
        --找到功能对应的btn
        self.mainUILayer.tempBtnsList[funtions[i]] = self.mainUILayer.panels[EM_PANEL.List].btns[funtions[i]]
        --从小层上取下该btn
        if self.mainUILayer.tempBtnsList[funtions[i]]:getParent() ~= nil then
            --self.mainUILayer.tempBtnsList[funtions[i]]:retain()
            self.mainUILayer.tempBtnsList[funtions[i]]:removeFromParent()
        end
    end

    local addFunctions = {}
    for i=#funtions,1,-1 do
        local panel = ccui.Helper:seekWidgetByName(self.mainUILayer.widgetUI, "Panel_List")
        for j=#funtions,1,-1 do
            local isOpend = (FunctionManager:isFunctionOpened(funtions[j]) == true)
            local isOpening = (table.v2k(emFunctions, funtions[j]) ~= nil)
            local notAdded = (addFunctions[j] ~= true)
            if (isOpend == true or isOpening == true) and notAdded == true then
                local btn = self.mainUILayer.tempBtnsList[funtions[j]]
                if btn:getParent() ~= nil then
                    btn:removeFromParent()
                end
                panel:addChild(btn)
                table.insert(self.mainUILayer.btnsList, btn)
                addFunctions[j] = true
                if isOpening then
                    self.mainUILayer.tempBtnsList[funtions[j]]:getParent():setVisible(false)
                end
                break
            end
        end
    end
end

--处理左下角的预开放
function FunctionOpenManager:showNextFunction()
    local T_Panel_Icon_Wait = ccui.Helper:seekWidgetByName(self.mainUILayer.widgetUI, "T_Panel_Icon_Wait")
    T_Panel_Icon_Wait:setVisible(false)
    
	--根据功能找到按钮
    local nextFunction  = FunctionManager:getInstance():getNextOpenFunction()
    local newBtn = self:findBtnByFunc(nextFunction)
    
	--添加按钮和点击事件
    if newBtn then
        T_Panel_Icon_Wait:setVisible(true)
        T_Panel_Icon_Wait:addChild(newBtn)
        
        local function hdTouch(sender, eventType)
            if  eventType  == ccui.TouchEventType.ended then
                local PubModel = require("sg.model.PubModel")
                local func2Mission = DataWarehouse:getInstance().func2Mission
                local missionId = func2Mission[nextFunction]
                local missionDM = PubModel:getInstance():getMission(missionId)
				local mission_level = LocaleGlobal.missionLevel(missionDM:getLevel())
                DataWarehouse:getInstance():showCommonTip(nil, LocaleGlobal.openFunctionTip(missionDM:getName())..mission_level)
            end
        end
        newBtn:addTouchEventListener(hdTouch)
    end
end

--获取功能开放图标位置
function FunctionOpenManager:getFuntionTargetPos(emfunction)
    local T_Panel_Icon_Wait = DataWarehouse:getInstance().T_Panel_Giving
    local contentSize = T_Panel_Icon_Wait:getContentSize()
    local pos = T_Panel_Icon_Wait:getWorldPosition()
    if   T_Panel_Icon_Wait:isVisible() == true then
        pos.x = pos.x + contentSize.width + contentSize.width/2
        pos.y = contentSize.height/2 + pos.y
    else
        pos.x = contentSize.width/2 + pos.x
        pos.y = contentSize.height/2 + pos.y
    end
    
    local posEmfunctions = {}
    
    local totalNum = 0
    if  DataWarehouse:getInstance().isShowActivityMelee then
        local tmpPosX = contentSize.width*totalNum + pos.x
        local tmpPosY = pos.y
        posEmfunctions[EMFunction.melee] = cc.p(tmpPosX,tmpPosY)
        totalNum = totalNum + 1
    end
    if DataWarehouse:getInstance().isShowBattleChangAn then
        local tmpPosX = contentSize.width*totalNum + pos.x
        local tmpPosY = pos.y
        posEmfunctions[EMFunction.activityChangAn] = cc.p(tmpPosX,tmpPosY)
        totalNum = totalNum + 1
    end
    if DataWarehouse:getInstance().isShowBattleHuangCheng then
        local tmpPosX = contentSize.width*totalNum + pos.x
        local tmpPosY = pos.y
        posEmfunctions[EMFunction.activitySupremacy] = cc.p(tmpPosX,tmpPosY)
        totalNum = totalNum + 1
    end
    
    if posEmfunctions[emfunction] then
        return posEmfunctions[emfunction]
    else
        return pos
    end
end
function FunctionOpenManager:getFuntionTargetPanelPos(emfunction)
    local T_Panel_Icon_Wait = DataWarehouse:getInstance().T_Panel_Giving
    local contentSize = T_Panel_Icon_Wait:getContentSize()
    local pos = T_Panel_Icon_Wait:getWorldPosition()
    if   T_Panel_Icon_Wait:isVisible() == true then
        pos.x = pos.x + contentSize.width
    else
        
    end

    local posEmfunctions = {}
    
    local totalNum= 0
    if  DataWarehouse:getInstance().isShowActivityMelee then
        local tmpPosX = contentSize.width*totalNum + pos.x
        local tmpPosY = pos.y
        posEmfunctions[EMFunction.melee] = cc.p(tmpPosX,tmpPosY)
        totalNum = totalNum + 1
    end
    if DataWarehouse:getInstance().isShowBattleChangAn then
        local tmpPosX = contentSize.width*totalNum + pos.x
        local tmpPosY = pos.y
        posEmfunctions[EMFunction.activityChangAn] = cc.p(tmpPosX,tmpPosY)
        totalNum = totalNum + 1
    end
    if DataWarehouse:getInstance().isShowBattleHuangCheng then
        local tmpPosX = contentSize.width*totalNum + pos.x
        local tmpPosY = pos.y
        posEmfunctions[EMFunction.activitySupremacy] = cc.p(tmpPosX,tmpPosY)
        totalNum = totalNum + 1
    end

    if posEmfunctions[emfunction] then
        return posEmfunctions[emfunction]
    else
        return pos
    end
end


--根据功能编号查找按钮
function FunctionOpenManager:findBtnByFunc(emFunction)

    local funcBtn = nil
    
    for func,btn in pairs(self.mainUILayer.tempBtnsSysLeft) do
        if func == emFunction then
            funcBtn = btn
            break
        end
    end
	
	for func,btn in pairs(self.mainUILayer.tempBtnsSysLeft2) do
        if func == emFunction then
            funcBtn = btn
            break
        end
    end
    
    if funcBtn == nil then
        for func,btn in pairs(self.mainUILayer.tempBtnsTop) do
            if func == emFunction then
                funcBtn = btn
                break
            end
        end 
    end
    
    if funcBtn == nil then
        for func,btn in pairs(self.mainUILayer.tempBtnsSysUp) do
            if func == emFunction then
                funcBtn = btn
                break
            end
        end
    end
    
    if funcBtn == nil then
        for func,btn in pairs(self.mainUILayer.tempBtnsMelee) do
            if func == emFunction then
                funcBtn = btn
                break
            end
        end
    end
    
    if funcBtn == nil then
        for func,btn in pairs(self.mainUILayer.tempBtnsChangAn) do
            if func == emFunction then
                funcBtn = btn
                break
            end
        end
    end

    if funcBtn == nil then
        for func,btn in pairs(self.mainUILayer.tempBtnsHuangCheng) do
            if func == emFunction then
                funcBtn = btn
                break
            end
        end
    end
    
    if funcBtn == nil then
        for func,btn in pairs(self.mainUILayer.tempBtnsList) do
            if func == emFunction then
                funcBtn = btn
                break
            end
        end
    end
    
    if funcBtn == nil then
        for func,btn in pairs(self.mainUILayer.tempBtnsSociety) do
            if func == emFunction then
                funcBtn = btn
                break
            end
        end
    end
	
	if funcBtn then
		local newBtn = funcBtn:clone()
		
		--local newBtn = cc.Sprite:createWithSpriteFrameName("CommonFiles/Icon_Enchantress.png")
		local newBtn = funcBtn:clone()
		return newBtn, funcBtn
	else
		return nil
	end
end

function FunctionOpenManager:showFuncOpenAnimation(newBtn)
    
end
function FunctionOpenManager:releaseRef(holder)
    if holder~=nil then
        for k,v in pairs(holder) do
            v:release()
        end
    end
end
function FunctionOpenManager:shine(widget)
	local actionFade1 = cc.FadeOut:create(0.1)
	local actionFade2 = cc.DelayTime:create(2.5)
	local actionFade3 = cc.FadeIn:create(0.1)
	local actionFade4 = cc.FadeOut:create(0.5)
	local actionFade5 = cc.FadeIn:create(0.5)
	local actionFade6 = cc.FadeOut:create(0.5)
	local actionFade7 = cc.FadeIn:create(0.5)
	widget:runAction(cc.Sequence:create(actionFade1, actionFade2,actionFade3, actionFade4, actionFade5, actionFade6, actionFade7))
end

function FunctionOpenManager:release()
    --[[
    for k,v in pairs(self.mainUILayer.tempBtnsSysLeft) do
        v:release()
    end

    for k,v in pairs(self.mainUILayer.tempBtnsSysUp) do
        v:release()
    end

    for k,v in pairs(self.mainUILayer.tempBtnsTop) do
        v:release()
    end

    for k,v in pairs(self.mainUILayer.tempBtnsSysLeft2) do
        v:release()
    end

    for k,v in pairs(self.mainUILayer.tempBtnsMelee) do
        v:release()
    end
    
    for k,v in pairs(self.mainUILayer.tempBtnsChangAn) do
        cclog("self.mainUILayer.tempBtnsChangAn:"..v:getReferenceCount())
        v:release()
    end
    
    for k,v in pairs(self.mainUILayer.tempBtnsHuangCheng) do
        v:release()
    end

    for k,v in pairs(self.mainUILayer.tempBtnsList) do
        v:release()
    end
    --]]
    self.mainUILayer = nil
end

return FunctionOpenManager
