local guide = {
    obj = nil,
    timer = nil,
    timer2 = nil,
    timer3 = nil,
    timer4 = nil,
    _data = {},
    guide10020timer = nil,
    guide10050timer = nil,
    guide10080timer = nil,
    guide10170timer = nil,
    guide10250timer = nil,
    guide10270timer = nil,
    guide10300timer = nil,
    guide9010count = 1,
    guide9010count2 = 1,
    firstIn = true,
    curGuideId = nil,
    _effectRes = {}
}

local _guide = nil
local obj_widget = nil
local _layerBtm = nil
local imageQuYu = nil
local armature = nil
local armature2 = nil
local armature3 = nil
local armature4 = nil
local imageLayer = nil
local item4 = nil
local layerMask = {}
local tmpMask = nil
-- 描述文字
local textWidget = nil
local textPanel = nil
-- 透明等待
local waitingLayer = nil

function guide:init()
    if _guide then return end
    _guide = ccui.Layout:create()
    _guide:setContentSize(cc.Director:getInstance():getWinSize())
    ch.UIManager:getNavigationLayer():addChild(_guide)
    _guide:setTouchEnabled(true)
    _guide:setVisible(false)
    
    _layerBtm = ccui.Layout:create()
    _layerBtm:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    _layerBtm:setBackGroundColor(cc.c3b(0,0,0))
    _layerBtm:setOpacity(140)
    _layerBtm:setContentSize(cc.size(cc.Director:getInstance():getWinSize().width, cc.Director:getInstance():getWinSize().height))
    _guide:addChild(_layerBtm)
    _layerBtm:setTouchEnabled(true)
    _layerBtm:setVisible(false)
    
--    zzy.EffectResManager:loadResource("effect_tx_leida")
--    zzy.EffectResManager:loadResource("effect_tx_shouzhi")
    
    local guideData = ch.GuideModel:getGuideData()
    for k,v in ipairs(guideData) do
        self._data["guide"..tostring(v)] = 1
    end
    if self._data["guide9010"] ~= 1 then
        self.firstIn = true
        self:play_guide(9010)
    else
        self.firstIn = false
    end
    
    if self._data["guide10020"] ~= 1 or self._data["guide10030"] ~= 1 then
        self.guide10020timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
            if ch and ch.MoneyModel and ch.MoneyModel:getGold() and self._data["guide9010"] == 1 and self._data["guide9020"] == 1 then
                local curmoney = ch.MoneyModel:getGold()
                if curmoney >= ch.LongDouble:new(6) then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.guide10020timer)
                    self:armatureStop(self.obj)
                    local bottomPanel = ch.UIManager:getBottomWidget("fuwen/W_FuwenList")
                    if not bottomPanel then
                        self:play_guide(10020)
                    else
                        self:play_guide(10030)
                    end
                end
            end
        end, 1, false)
    end 
    if self._data["guide10050"] ~= 1 or self._data["guide10060"] ~= 1 then
        self.guide10050timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
            if ch and ch.MoneyModel and ch.MoneyModel:getGold() and self._data["guide9010"] == 1 and self._data["guide9020"] == 1 then
                local curmoney = ch.MoneyModel:getGold()
                if curmoney >= ch.MagicModel:getLevelUpCost(1,1) and self._data["guide10030"] == 1 then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.guide10050timer)
                    local bottomPanel = ch.UIManager:getBottomWidget("baowu/W_BaowuList")
                    if not bottomPanel then
                        self:play_guide(10050)
                    else
                        self:play_guide(10060)
                    end
                end
            end
        end, 1, false)
    end
    if self._data["guide10070"] ~= 1 and false then
        self.guide10080timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
            if ch and ch.TotemModel and self._data["guide9010"] == 1 and self._data["guide9020"] == 1 then
                local totenOpen = ch.TotemModel:getTotemOpen()
                if totenOpen then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.guide10080timer)
                    self:play_guide(10070)
                end
            end
        end, 1, false)
    elseif (self._data["guide10080"] ~= 1 or self._data["guide10090"] ~= 1) and ch.TotemModel:getOwnTotemNum() == 0 and false then
        self.guide10080timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
            if ch and ch.TotemModel and self._data["guide9010"] == 1 and self._data["guide9020"] == 1 then
                local totenOpen = ch.TotemModel:getTotemOpen()
                if totenOpen then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.guide10080timer)
                    local bottomPanel = ch.UIManager:getBottomWidget("tuteng/W_TutengList")
                    if not bottomPanel then
                        self:play_guide(10080)
                    else
                        self:play_guide(10090)
                    end
                end
            end
        end, 1, false)
    elseif self._data["guide10170"] ~= 1 or self._data["guide10180"] ~= 1 then
        self.guide10170timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
            if ch and ch.StatisticsModel and self._data["guide9010"] == 1 and self._data["guide9020"] == 1 then
                local arenaOpen = ch.StatisticsModel:getMaxLevel() > GameConst.ARENA_OPEN_LEVEL
                if arenaOpen then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.guide10170timer)
                    local bottomPanel = ch.UIManager:getBottomWidget("card/W_card_list")
                    if not bottomPanel then
                        self:play_guide(10170)
                    else
                        self:play_guide(10180)
                    end
                end
            end
        end, 1, false)
    elseif self._data["guide10250"] ~= 1 or self._data["guide10260"] ~= 1 and table.maxn(ch.AltarModel:getAltarListInit(1)) < 1 then
        self.guide10250timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
            if ch and ch.StatisticsModel and self._data["guide9010"] == 1 and self._data["guide9020"] == 1 then
                local arenaOpen = ch.StatisticsModel:getMaxLevel() > GameConst.ALTAR_OPEN_LEVEL[1]
                if arenaOpen then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.guide10250timer)
                    local bottomPanel = ch.UIManager:getBottomWidget("card/W_jt_main")
                    if not bottomPanel then
                        self:play_guide(10250)
                    else
                        self:showWait(1.5,function()
                            self:play_guide(10260)
                        end)
                    end
                end
            end
        end, 1, false)
--    elseif self._data["guide10270"] ~= 1 or self._data["guide10280"] ~= 1 then
--        self.guide10270timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
--            if ch and ch.StatisticsModel and self._data["guide9010"] == 1 and self._data["guide9020"] == 1 then
--                local arenaOpen = table.maxn(ch.AltarModel:getAltarListInit(1)) > 0 and ch.AltarModel:getAltarByType(1).level == 1 and ch.AltarModel:getPanelData(1).exp < 1
--                if arenaOpen then
--                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.guide10270timer)
--                    local bottomPanel = ch.AltarModel:getPanelData(1).exp > 0
--                    if not bottomPanel then
--                        self:play_guide(10270)
--                    else
--                        self:play_guide(10280)
--                    end
--                end
--            end
--        end, 1, false)
    elseif self._data["guide10300"] ~= 1 or self._data["guide10310"] ~= 1 then
        self.guide10300timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
            if ch and ch.StatisticsModel and self._data["guide9010"] == 1 and self._data["guide9020"] == 1 then
                local arenaOpen = ch.AltarModel:getAltarByType(ch.AltarModel:getCurAltarSelect()).level >= GameConst.ALTAR_ROB_LEVEL 
                if arenaOpen then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.guide10300timer)
                    local bottomPanel = ch.UIManager:getBottomWidget("card/W_jt_lveduo")
                    if not bottomPanel then
                        self:play_guide(10300)
                    else
                        self:play_guide(10310)
                    end
                end
            end
        end, 1, false)
    end
    if string.sub(zzy.Sdk.getFlag(),1,2)=="TJ" and 
        ch.StatisticsModel:getMaxLevel() <= GameConst.KOR_LEVEL_GUILD.level[#GameConst.KOR_LEVEL_GUILD.level] then
        local lid
        lid = zzy.EventManager:listen(ch.StatisticsModel.maxLevelChangeEventType,function(obj,evt)
            if ch.StatisticsModel:getMaxLevel() == GameConst.KOR_LEVEL_GUILD.level[1] + 1 then
                ch.fightRoleLayer:pause()
                self:showKorGUild(GameConst.KOR_LEVEL_GUILD.image[1],ch.UIManager:getNavigationLayer(),function()
                    ch.fightRoleLayer:resume()
                end)
            elseif ch.StatisticsModel:getMaxLevel() == GameConst.KOR_LEVEL_GUILD.level[2] + 1 then
                ch.fightRoleLayer:pause()
                self:showKorGUild(GameConst.KOR_LEVEL_GUILD.image[2],ch.UIManager:getNavigationLayer(),function()
                    ch.fightRoleLayer:resume()
                end)
                zzy.EventManager:unListen(lid)
            end
        end)
    end
end

function guide:showKorGUild(image,parent,func)
	local startTime = os_clock()
    local view = ccui.ImageView:create(image,ccui.TextureResType.localType)
    local size = cc.Director:getInstance():getVisibleSize()
    view:setPosition(size.width/2,size.height/2)
    view:setTouchEnabled(true)
    local id
    id = zzy.EventManager:listen(zzy.Events.TickEventType,function(obj,evt)
        if os_clock() - startTime > 5 then
            zzy.EventManager:unListen(id)
            local seq = cc.Sequence:create(cc.ScaleTo:create(0.2,0),cc.CallFunc:create(function()
                view:removeFromParent()
                cc.Director:getInstance():getTextureCache():removeTextureForKey(image)
                zzy.TimerUtils:setTimeOut(0,function()
                    func()
                end)
            end))
            view:runAction(seq)
        end
    end)
    view:addTouchEventListener(function(obj,evt)
        if evt == ccui.TouchEventType.ended then
            if os_clock() - startTime > 0.5 then
                zzy.EventManager:unListen(id)
                local seq = cc.Sequence:create(cc.ScaleTo:create(0.3,0),cc.CallFunc:create(function()
                    view:removeFromParent()
                    cc.Director:getInstance():getTextureCache():removeTextureForKey(image)
                    zzy.TimerUtils:setTimeOut(0,function()
                        func()
                    end)
                end))
                view:runAction(seq)
            end
        end
    end)
    view:setLocalZOrder(1001)
    parent:addChild(view)
end

function guide:savestate(_id)
    if self._data["guide" .. tostring(_id)] ~= 1 then
        self._data["guide" .. tostring(_id)] = 1
        ch.NetworkController:saveGuide(_id)
    end
end

function guide:play_guide(_id)
    cclog("引导id: " .. _id)
--    if self.curGuideId ~= nil and self._data["guide" .. tostring(self.curGuideId)] ~= 1 and _id ~= self.curGuideId then
--        if obj_widget then
--            obj_widget:removeFromParent()
--            _guide:setVisible(false)
--            _guide:setTouchEnabled(false)
--        end
--        self:endid(self.curGuideId)
--    end
--    self.curGuideId = _id
    
    self.obj = GameConfig.GuideConfig:getData(_id)
    if self.obj.showbtm == 1 then
        _layerBtm:setVisible(true)
    else
        _layerBtm:setVisible(false)
    end
    if self.obj.type == 1 then
        self:playEffect(self.obj)
    elseif self.obj.type == 2 then
        self:directionTo(self.obj)
    elseif self.obj.type == 3 then
        self:openPanel(self.obj)
    elseif self.obj.type == 4 then
        self:firstPanel(self.obj)
    else
        self.obj = nil
    end
end
function guide:playEffect(obj)
    if zzy.CocosExtra.isCobjExist(obj_widget) and obj_widget:getParent() ~= nil then
        obj_widget:removeFromParent()
        _guide:setVisible(false)
        _guide:setTouchEnabled(false)
    end
    _guide:setVisible(true)
    _guide:setTouchEnabled(false)
    zzy.EffectResManager:loadResource(obj.effpath)
    armature = ccs.Armature:create(obj.eff)
    _guide:addChild(armature)
    armature:setPosition(cc.Director:getInstance():getWinSize().width/2, cc.Director:getInstance():getWinSize().height/2)
    if obj.etime > 0 then
        armature:getAnimation():play(obj.effa,-1,1)
        zzy.TimerUtils:setTimeOut(obj.etime,function()
            self:armatureStop(obj)
        end)
    elseif obj.etime == -1 then
        armature:getAnimation():play(obj.effa,-1,0)
        armature:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
            if movementType == ccs.MovementEventType.complete then
                armature:getAnimation():stop()
                armature:removeFromParent()
                zzy.EffectResManager:releaseResource(obj.effpath)
                self:endid(obj.id)
            end
        end)
    elseif obj.etime == -2 then
        armature:setPosition(cc.Director:getInstance():getWinSize().width/2, cc.Director:getInstance():getWinSize().height/2 - 92)
        armature:getAnimation():play(obj.effa,-1,1)
    end
end
function guide:armatureStop(obj)
    if armature then
        armature:getAnimation():stop()
        armature:removeFromParent()
        zzy.EffectResManager:releaseResource(obj.effpath)
        self:endid(obj.id)
        armature = nil
    end
end

function guide:directionTo(obj)
    _guide:setVisible(true)
    _guide:setTouchEnabled(false)

    local bottomBtn = nil
    -- 宠物相关（10020，10030）
    if obj.id == 10020 then
        bottomBtn = ch.UIManager._mainView:getChildByName("Panel_screen"):getChildByName("BarMenu"):getChildByName("dibanPanel"):getChildByName("MainMenuPanel"):getChildByName("MainMenu_1")
        if bottomBtn then
            self:directionShow(obj,bottomBtn)
        end
    elseif obj.id == 10030 then
        local bottomPanel = ch.UIManager:getBottomWidget("fuwen/W_FuwenList")
        _guide:setTouchEnabled(true)
        if bottomPanel then
--            local weighto = zzy.CocosExtra.seekNodeByName(bottomPanel,"checkbox_lv")
--            bottomPanel:getCommond("check")(weighto, "-10")
            zzy.TimerUtils:setTimeOut(0.5,function()
                item4 = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
                item4:scrollToPercentVertical(0,0.1,true)
                zzy.TimerUtils:setTimeOut(0.1,function()
                    --item4:setInertiaScrollEnabled(false)
                    local item = item4:getItem(0)
                    if item then
                        bottomBtn = zzy.CocosExtra.seekNodeByName(item,"Image_guide")
                        if bottomBtn then
                            self:directionShow(obj,bottomBtn)
                        end
                    end
                end)
            end)
        else
            self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
                bottomPanel = ch.UIManager:getBottomWidget("fuwen/W_FuwenList")
                if bottomPanel then
--                    local weighto = zzy.CocosExtra.seekNodeByName(bottomPanel,"checkbox_lv")
--                    bottomPanel:getCommond("check")(weighto, "-10")
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
                    zzy.TimerUtils:setTimeOut(0.5,function()
                        item4 = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
                        item4:scrollToPercentVertical(0,0.1,true)
                        zzy.TimerUtils:setTimeOut(0.1,function()
                            local item = item4:getItem(0)
                            if item then
                                bottomBtn = zzy.CocosExtra.seekNodeByName(item,"Image_guide")
                                if bottomBtn then
                                    self:directionShow(obj,bottomBtn)
                                end
                            end
                        end)
                    end)
                end
            end, 0.1, false)
        end
    -- 宝物相关（10050，10060）
    elseif obj.id == 10050 then
        bottomBtn = ch.UIManager._mainView:getChildByName("Panel_screen"):getChildByName("BarMenu"):getChildByName("dibanPanel"):getChildByName("MainMenuPanel"):getChildByName("MainMenu_2")
        if bottomBtn then
            self:directionShow(obj,bottomBtn)
        end
    elseif obj.id == 10060 then
        local bottomPanel = ch.UIManager:getBottomWidget("baowu/W_BaowuList")
        _guide:setTouchEnabled(true)
        if bottomPanel then
--            local weighto = zzy.CocosExtra.seekNodeByName(bottomPanel,"checkbox_lv")
--            bottomPanel:getCommond("check")(weighto, "-10")
            zzy.TimerUtils:setTimeOut(0.5,function()
                item4 = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
                item4:scrollToPercentVertical(0,0.1,true)
                zzy.TimerUtils:setTimeOut(0.1,function()
                    local item = item4:getItem(0)
                    if item then
                        bottomBtn = zzy.CocosExtra.seekNodeByName(item,"Image_guide")
                        if bottomBtn then
                            self:directionShow(obj,bottomBtn)
                        end
                    end
                end)
            end)
        else
            self.timer2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
                bottomPanel = ch.UIManager:getBottomWidget("baowu/W_BaowuList")
                if bottomPanel then
--                    local weighto = zzy.CocosExtra.seekNodeByName(bottomPanel,"checkbox_lv")
--                    bottomPanel:getCommond("check")(weighto, "-10")
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer2)
                    zzy.TimerUtils:setTimeOut(0.6,function()
                        item4 = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
                        item4:scrollToPercentVertical(0,0.1,true)
                        zzy.TimerUtils:setTimeOut(0.1,function()
                            local item = item4:getItem(0)
                            if item then
                                bottomBtn = zzy.CocosExtra.seekNodeByName(item,"Image_guide")
                                if bottomBtn then
                                    self:directionShow(obj,bottomBtn)
                                end
                            end
                        end)
                    end)
                end
            end, 0.1, false)
        end
    -- 图腾相关（10080，10090，10110）
    elseif obj.id == 10080 then
        bottomBtn = ch.UIManager._mainView:getChildByName("Panel_screen"):getChildByName("BarMenu"):getChildByName("dibanPanel"):getChildByName("MainMenuPanel"):getChildByName("MainMenu_3")
        if bottomBtn then
            self:directionShow(obj,bottomBtn)
        end
    elseif obj.id == 10090 then
        local bottomPanel = ch.UIManager:getBottomWidget("tuteng/W_TutengList")
        _guide:setTouchEnabled(true)
        if bottomPanel then
            zzy.TimerUtils:setTimeOut(0.6,function()
                bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"Button_callnew2")
                if bottomBtn then
                    self:directionShow(obj,bottomBtn)
                end
            end)
        else
            self.timer3 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
                bottomPanel = ch.UIManager:getBottomWidget("tuteng/W_TutengList")
                if bottomPanel then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer3)
                    zzy.TimerUtils:setTimeOut(0.6,function()
                        bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"Button_callnew2")
                        if bottomBtn then
                            self:directionShow(obj,bottomBtn)
                        end
                    end)
                end
            end, 0.1, false)
        end
    elseif obj.id == 10110 then
        _guide:setTouchEnabled(true)
        local tutengPanel
        self.timer4 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
            tutengPanel = ch.UIManager:getBottomWidget("tuteng/W_TutengXuanze")
            if tutengPanel then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer4)
                zzy.TimerUtils:setTimeOut(0.5,function()
                    bottomBtn = zzy.CocosExtra.seekNodeByName(tutengPanel,"Panel_guide")
                    if bottomBtn then
                        self:directionShow(obj,bottomBtn)
                    end
                end)
            end
        end, 0.1, false)
    -- 镀金相关（10120，10130，10140）
    elseif obj.id == 10120 then
        local bottomPanel = ch.UIManager:getBottomWidget("baowu/W_BaowuStarget")
        bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_open")
        if bottomBtn then
            self:directionShow(obj,bottomBtn)
        end
    elseif obj.id == 10130 then
        zzy.TimerUtils:setTimeOut(0.6,function()
            local bottomPanel = ch.UIManager:getBottomWidget("baowu/W_BaowuStar")
            local tmpWidget = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
            zzy.TimerUtils:setTimeOut(0.1,function()
                local item = tmpWidget:getItem(tonumber(ch.MagicModel:getRandMagicID())-1)
                if item then
                    bottomBtn = zzy.CocosExtra.seekNodeByName(item,"cb_select")
                    if bottomBtn then
                        self:directionShow(obj,bottomBtn)
                    end
                end
            end)
        end)
    elseif obj.id == 10140 then
        local bottomPanel = ch.UIManager:getBottomWidget("baowu/W_BaowuStar")
        bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_starremovePanel")
        if bottomBtn then
            self:directionShow(obj,bottomBtn)
        end
    -- 坚守阵地相关（10150，10160）
    elseif obj.id == 10150 then
        bottomBtn = zzy.CocosExtra.seekNodeByName(ch.UIManager._activeSkillView,"btn_sign")
        if bottomBtn then
            -- 锚点在(0.5,0.5)
            self:directionShow(obj,bottomBtn,1)
        end
    elseif obj.id == 10160 then
        local bottomPanel = ch.UIManager:getBottomWidget("MainScreen/W_Activity")
        _guide:setTouchEnabled(true)
        if bottomPanel then
            zzy.TimerUtils:setTimeOut(0.5,function()
                item4 = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
                item4:scrollToPercentVertical(0,0.1,true)
                zzy.TimerUtils:setTimeOut(0.1,function()
                    local item = item4:getItem(1)
                    if item then
                        bottomBtn = zzy.CocosExtra.seekNodeByName(item,"btn_touch")
                        if bottomBtn then
                            self:directionShow(obj,bottomBtn)
                        end
                    end
                end)
            end)
        else
            self.timer2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
                bottomPanel = ch.UIManager:getBottomWidget("MainScreen/W_Activity")
                if bottomPanel then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer2)
                    zzy.TimerUtils:setTimeOut(0.6,function()
                        item4 = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
                        item4:scrollToPercentVertical(0,0.1,true)
                        zzy.TimerUtils:setTimeOut(0.1,function()
                            local item = item4:getItem(1)
                            if item then
                                bottomBtn = zzy.CocosExtra.seekNodeByName(item,"btn_touch")
                                if bottomBtn then
                                    self:directionShow(obj,bottomBtn)
                                end
                            end
                        end)
                    end)
                end
            end, 0.1, false)
        end
    --天梯相关（10170，10180）
    elseif obj.id == 10170 then
        bottomBtn = ch.UIManager._mainView:getChildByName("Panel_screen"):getChildByName("BarMenu"):getChildByName("dibanPanel"):getChildByName("MainMenuPanel"):getChildByName("MainMenu_4")
        if bottomBtn then
            self:directionShow(obj,bottomBtn)
        end
    elseif obj.id == 10180 then
        local bottomPanel = ch.UIManager:getBottomWidget("card/W_card_list")       
        if bottomPanel then
            zzy.TimerUtils:setTimeOut(0.6,function()
                bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_tt")
                if bottomBtn then
                    self:directionShow(obj,bottomBtn)
                end
            end)
        else
            self.timer5 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
                bottomPanel = ch.UIManager:getBottomWidget("card/W_card_list")
                if bottomPanel then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer5)
                    zzy.TimerUtils:setTimeOut(0.6,function()
                        bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_tt")
                        if bottomBtn then
                            self:directionShow(obj,bottomBtn)
                        end
                    end)
                end
            end, 0.1, false)
        end
    --上阵相关（10190，10200，10210，10220，10230，10240）
    elseif obj.id == 10190 then
        zzy.TimerUtils:setTimeOut(0.6,function()
            local bottomPanel = ch.UIManager:getBottomWidget("card/W_card_chakan")
            bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_change")
            if bottomBtn then
                self:directionShow(obj,bottomBtn)
            end
        end)
    elseif obj.id == 10200 then
        zzy.TimerUtils:setTimeOut(0.6,function()
            local bottomPanel = ch.UIManager:getBottomWidget("card/W_card_f_choose")
            local tmpWidget = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
            zzy.TimerUtils:setTimeOut(0.1,function()
                local item = tmpWidget:getItem(0)
                if item then
                    bottomBtn = zzy.CocosExtra.seekNodeByName(item,"cb_select")
                    if bottomBtn then
                        self:directionShow(obj,bottomBtn)
                    end
                end
            end)
        end)
    elseif obj.id == 10210 then
        local bottomPanel = ch.UIManager:getBottomWidget("card/W_card_f_choose")
        local tmpWidget = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
        local item = tmpWidget:getItem(1)
        if item then
            bottomBtn = zzy.CocosExtra.seekNodeByName(item,"cb_select")
            if bottomBtn then
                self:directionShow(obj,bottomBtn)
            end
        end
    elseif obj.id == 10220 then
        local bottomPanel = ch.UIManager:getBottomWidget("card/W_card_f_choose")
        local tmpWidget = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
        local item = tmpWidget:getItem(2)
        if item then
            bottomBtn = zzy.CocosExtra.seekNodeByName(item,"cb_select")
            if bottomBtn then
                self:directionShow(obj,bottomBtn)
            end
        end
    elseif obj.id == 10230 then
        local bottomPanel = ch.UIManager:getBottomWidget("card/W_card_f_choose")
        bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_changeGroup")
        if bottomBtn then
            self:directionShow(obj,bottomBtn)
        end
    elseif obj.id == 10240 then
        local bottomPanel = ch.UIManager:getBottomWidget("card/W_card_chakan")
        bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_PK")
        if bottomBtn then
            self:directionShow(obj,bottomBtn)
        end
    -- 祭坛开放（10250，10260，10200，10210，10220，10230）
    elseif obj.id == 10250 then
        bottomBtn = zzy.CocosExtra.seekNodeByName(ch.UIManager._activeSkillView,"btn_altar")
        if bottomBtn then
            -- 锚点在(0.5,0.5)
            self:directionShow(obj,bottomBtn,1)
        end
    elseif obj.id == 10260 then
        zzy.TimerUtils:setTimeOut(0.6,function()
            local bottomPanel = ch.UIManager:getBottomWidget("card/W_jt_main")
            bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_team")
            if bottomBtn then
                self:directionShow(obj,bottomBtn)
            end
        end)
    -- 祭坛领取升级退出（10270，10280，10290）
    elseif obj.id == 10270 then
        zzy.TimerUtils:setTimeOut(0.6,function()
            local bottomPanel = ch.UIManager:getBottomWidget("card/W_jt_main")
            bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_getExp")
            if bottomBtn then
                self:directionShow(obj,bottomBtn)
            end
        end)
    elseif obj.id == 10280 then
        local bottomPanel = ch.UIManager:getBottomWidget("card/W_jt_main")
        bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_up")
        if bottomBtn then
            self:directionShow(obj,bottomBtn)
        end
    elseif obj.id == 10290 then
        local bottomPanel = ch.UIManager:getBottomWidget("card/W_jt_main")
        bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_quit")
        if bottomBtn then
            self:directionShow(obj,bottomBtn)
        end
    -- 祭坛掠夺（10300，10310）
    elseif obj.id == 10300 then
        zzy.TimerUtils:setTimeOut(0.6,function()
            local bottomPanel = ch.UIManager:getBottomWidget("card/W_jt_main")
            bottomBtn = zzy.CocosExtra.seekNodeByName(bottomPanel,"btn_lveduo")
            if bottomBtn then
                self:directionShow(obj,bottomBtn,1)
            end
        end)
    elseif obj.id == 10310 then
        zzy.TimerUtils:setTimeOut(0.6,function()
            local bottomPanel = ch.UIManager:getBottomWidget("card/W_jt_lveduo")
            local tmpWidget = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
            zzy.TimerUtils:setTimeOut(0.1,function()
                local item = tmpWidget:getItem(0)
                if item then
                    bottomBtn = zzy.CocosExtra.seekNodeByName(item,"btn_rob")
                    if bottomBtn then
                        self:directionShow(obj,bottomBtn)
                    end
                end
            end)
        end)
    -- 卡牌副本引导
    elseif obj.id == 10320 then
        bottomBtn = zzy.CocosExtra.seekNodeByName(ch.UIManager._activeSkillView,"btn_sign")
        if bottomBtn then
            -- 锚点在(0.5,0.5)
            self:directionShow(obj,bottomBtn,1)
        end
    elseif obj.id == 10330 then
        local bottomPanel = ch.UIManager:getBottomWidget("MainScreen/W_Activity")
        _guide:setTouchEnabled(true)
        if bottomPanel then
            zzy.TimerUtils:setTimeOut(0.5,function()
                item4 = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
                item4:scrollToPercentVertical(0,0.1,true)
                zzy.TimerUtils:setTimeOut(0.1,function()
                    local item = item4:getItem(2)
                    if item then
                        bottomBtn = zzy.CocosExtra.seekNodeByName(item,"btn_join")
                        if bottomBtn then
                            self:directionShow(obj,bottomBtn,1)
                        end
                    end
                end)
            end)
        else
            self.timer2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
                bottomPanel = ch.UIManager:getBottomWidget("MainScreen/W_Activity")
                if bottomPanel then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer2)
                    zzy.TimerUtils:setTimeOut(0.6,function()
                        item4 = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
                        item4:scrollToPercentVertical(0,0.1,true)
                        zzy.TimerUtils:setTimeOut(0.1,function()
                            local item = item4:getItem(2)
                            if item then
                                bottomBtn = zzy.CocosExtra.seekNodeByName(item,"btn_join")
                                if bottomBtn then
                                    self:directionShow(obj,bottomBtn,1)
                                end
                            end
                        end)
                    end)
                end
            end, 0.1, false)
        end
    -- 矿区争夺战引导
    elseif obj.id == 10340 then
        bottomBtn = zzy.CocosExtra.seekNodeByName(ch.UIManager._activeSkillView,"btn_sign")
        if bottomBtn then
            -- 锚点在(0.5,0.5)
            self:directionShow(obj,bottomBtn,1)
        end
    elseif obj.id == 10350 then
        local bottomPanel = ch.UIManager:getBottomWidget("MainScreen/W_Activity")
        _guide:setTouchEnabled(true)
        if bottomPanel then
            zzy.TimerUtils:setTimeOut(0.5,function()
                item4 = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
                item4:scrollToPercentVertical(0,0.1,true)
                zzy.TimerUtils:setTimeOut(0.1,function()
                    local item = item4:getItem(4)
                    if item then
                        bottomBtn = zzy.CocosExtra.seekNodeByName(item,"btn_join")
                        if bottomBtn then
                            self:directionShow(obj,bottomBtn,1)
                        end
                    end
                end)
            end)
        else
            self.timer2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()  
                bottomPanel = ch.UIManager:getBottomWidget("MainScreen/W_Activity")
                if bottomPanel then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer2)
                    zzy.TimerUtils:setTimeOut(0.6,function()
                        item4 = zzy.CocosExtra.seekNodeByName(bottomPanel,"ListView_1")
                        item4:scrollToPercentVertical(0,0.1,true)
                        zzy.TimerUtils:setTimeOut(0.1,function()
                            local item = item4:getItem(4)
                            if item then
                                bottomBtn = zzy.CocosExtra.seekNodeByName(item,"btn_join")
                                if bottomBtn then
                                    self:directionShow(obj,bottomBtn,1)
                                end
                            end
                        end)
                    end)
                end
            end, 0.1, false)
        end
    end
end
-- 默认控件锚点在(0,0)
function guide:directionShow(obj, bottomBtn, btnPointData)
    local objBtn = {100, 900, 500, 500}
    --local bottomBtn = ch.UIManager._mainView:getChildByName("Panel_screen")
    local screenSize = {cc.Director:getInstance():getWinSize().width,cc.Director:getInstance():getWinSize().height}
    local sizeBtn = bottomBtn:getContentSize()
    local pointBtn = {bottomBtn:getPositionX(), bottomBtn:getPositionY()}
    local pointBtnWorld = bottomBtn:convertToWorldSpace(pointBtn)
    objBtn ={pointBtnWorld.x-sizeBtn.width*0.1, pointBtnWorld.y-sizeBtn.height*0.1, sizeBtn.width*1.2, sizeBtn.height*1.2}
    -- 锚点在(0.5,0.5)
    if btnPointData == 1 then
        objBtn[1] = pointBtnWorld.x-sizeBtn.width*0.2
        objBtn[2] = pointBtnWorld.y-sizeBtn.height*0.2
    end
    if obj.id == 10130 then
        objBtn ={pointBtnWorld.x+sizeBtn.width*0.1, pointBtnWorld.y+sizeBtn.height*0.1, sizeBtn.width*0.8, sizeBtn.height*0.8}
    end
    if obj.id == 10200 or obj.id == 10210 or obj.id == 10220 then
        objBtn ={pointBtnWorld.x+sizeBtn.width*0.1, pointBtnWorld.y+sizeBtn.height*0.1, sizeBtn.width*0.8, sizeBtn.height*0.8}
    end
    cclog("sizeBtn.width:"..sizeBtn.width..",".."sizeBtn.height:"..sizeBtn.height)
    --    for i=1, 4 do
    --      cclog("i="..i.."   "..objBtn[i]);
    --    end
    
    if imageLayer == nil then
        imageLayer = ccui.Layout:create()
        _guide:addChild(imageLayer)
        
        --添加可点击区域
--        local layer = ccui.Layout:create()
--        layer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
--        layer:setBackGroundColor(cc.c3b(0,0,0))
--        layer:setOpacity(140)
--        layer:setContentSize(cc.size(cc.Director:getInstance():getWinSize().width, cc.Director:getInstance():getWinSize().height))
--        local stencil = cc.Node:create()
--        imageQuYu = ccui.ImageView:create()
--        imageQuYu:loadTexture("aaui_common/mask.png",ccui.TextureResType.plistType)
--        imageQuYu:ignoreContentAdaptWithSize(false)
--        stencil:addChild(imageQuYu)
--        local clippingNode = cc.ClippingNode:create(stencil)
--        clippingNode:setStencil(stencil)
--        clippingNode:setInverted(true)
--        clippingNode:setAlphaThreshold(0.05)
--        imageLayer:addChild(clippingNode) 
--        clippingNode:addChild(layer, -1);
        
        --添加不可点击区域
        for i=1, 4 do
            local layerTmp = ccui.Layout:create()
            layerTmp:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
            layerTmp:setBackGroundColor(cc.c3b(0,0,0))
            layerTmp:setOpacity(190)
            layerTmp:setContentSize(cc.size(screenSize[1], screenSize[2]))
            layerTmp:setTouchEnabled(true)
            imageLayer:addChild(layerTmp)
            table.insert(layerMask,layerTmp)
        end
        
        tmpMask = ccui.ImageView:create()
        tmpMask:loadTexture("res/icon/mask.png",ccui.TextureResType.localType)
        tmpMask:setAnchorPoint(0,0)
        tmpMask:ignoreContentAdaptWithSize(false)
        tmpMask:setTouchEnabled(false)
        imageLayer:addChild(tmpMask)
        table.insert(layerMask,tmpMask)
        
        -- 描述
        self:creatText(layerMask)

        --添加按钮光效
        self:loadEffect("effect_tx_shengjianniu")
        armature3 = ccs.Armature:create("tx_shengjianniu")
        imageLayer:addChild(armature3)
        armature3:getAnimation():play("Animation1",-1,1)
        --armature3:getAnimation():setSpeedScale(2)
        
        --添加雷达效果
        self:loadEffect("effect_tx_leida")
        armature4 = ccs.Armature:create("tx_leida")
        imageLayer:addChild(armature4)
        armature4:getAnimation():play("Animation1",-1,1)
        armature4:getAnimation():setSpeedScale(0.75)
        
        --添加箭头
        self:loadEffect("effect_tx_shouzhi")
        armature2 = ccs.Armature:create("tx_shouzhi")
        imageLayer:addChild(armature2)
        --armature2:setPosition(cc.Director:getInstance():getWinSize().width/2, cc.Director:getInstance():getWinSize().height/2)
        armature2:getAnimation():play("Animation1",-1,1)
        --armature2:getAnimation():setSpeedScale(2)
    end
    imageLayer:setVisible(true)
    if obj.showsz == 1 then
        armature4:setVisible(false)
        armature2:setVisible(false)
	else
        armature4:setVisible(true)
        armature2:setVisible(true)
    end
    layerMask[1]:setPosition(objBtn[1], objBtn[2] + objBtn[4])
    layerMask[1]:setContentSize(cc.size(objBtn[3],screenSize[2]))
    layerMask[2]:setPosition(objBtn[1], objBtn[2]-screenSize[2])
    layerMask[2]:setContentSize(cc.size(objBtn[3],screenSize[2]))
    layerMask[3]:setPosition(objBtn[1]-screenSize[1], 0)
    layerMask[4]:setPosition(objBtn[1] + objBtn[3], 0)
    tmpMask:setPosition(objBtn[1],objBtn[2])
    tmpMask:setContentSize(cc.size(objBtn[3],objBtn[4]))
    
    armature3:setPosition(objBtn[1] + objBtn[3] / 2, objBtn[2] + objBtn[4] / 2)    
    armature3:setVisible(false)
    if obj.id == 10020 then
        armature2:setRotation(-135)
        armature2:setPosition(objBtn[1] + objBtn[3] / 2 + 30, objBtn[2] + objBtn[4] + 5)
        objBtn[2] = objBtn[2] + 10
        objBtn[4] = objBtn[4] - 20
        ch.UIManager:cleanGamePopupLayer(false,true)
    elseif obj.id == 10030 then
        armature2:setRotation(45)
        armature2:setPosition(objBtn[1] + objBtn[3] / 2 - 25, objBtn[2] - 20)
        objBtn[1] = objBtn[1] - 10
        objBtn[2] = objBtn[2] - 30
        objBtn[3] = objBtn[3] + 20
        objBtn[4] = objBtn[4] + 60
        ch.UIManager:cleanGamePopupLayer(false,true)
        --armature3:setVisible(true)
    elseif obj.id == 10050 then
        armature2:setRotation(-135)
        armature2:setPosition(objBtn[1] + objBtn[3] / 2 + 30, objBtn[2] + objBtn[4] + 5)
        objBtn[2] = objBtn[2] + 10
        objBtn[4] = objBtn[4] - 20
        ch.UIManager:cleanGamePopupLayer(false,true)
    elseif obj.id == 10060 then
        armature2:setRotation(45)
        armature2:setPosition(objBtn[1] + objBtn[3] / 2 - 25, objBtn[2] - 20)
        objBtn[1] = objBtn[1] - 10
        objBtn[2] = objBtn[2] - 30
        objBtn[3] = objBtn[3] + 20
        objBtn[4] = objBtn[4] + 60
        ch.UIManager:cleanGamePopupLayer(false,true)
        --armature3:setVisible(true)
    elseif obj.id == 10080 then
        armature2:setRotation(-135)
        armature2:setPosition(objBtn[1] + objBtn[3] / 2 + 30, objBtn[2] + objBtn[4] + 5)
        objBtn[2] = objBtn[2] + 10
        objBtn[4] = objBtn[4] - 20
        ch.UIManager:cleanGamePopupLayer(false,true)
    elseif obj.id == 10090 then
        armature2:setRotation(45)
        armature2:setPosition(objBtn[1] + objBtn[3] / 2 - 25, objBtn[2] - 20)
        objBtn[1] = objBtn[1] - 10
        objBtn[2] = objBtn[2] - 30
        objBtn[3] = objBtn[3] + 20
        objBtn[4] = objBtn[4] + 60
        ch.UIManager:cleanGamePopupLayer(false,true)
        --armature3:setVisible(true)
    elseif obj.id == 10110 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2] + objBtn[4]/2 - 30)
    elseif obj.id == 10120 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2] + objBtn[4]/2 - 30)
    elseif obj.id == 10130 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2] + objBtn[4]/2 - 30)
        --armature2:setPosition(objBtn[1], objBtn[2])
    elseif obj.id == 10140 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2] + objBtn[4]/2 - 30)
    elseif obj.id == 10150 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2] + objBtn[4]/2 - 30)
        objBtn[2] = objBtn[2]-10
        ch.UIManager:cleanGamePopupLayer(false,true)
    elseif obj.id == 10160 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2]+objBtn[4]/2 - 30)
    elseif obj.id == 10170 then
        armature2:setRotation(-135)
        armature2:setPosition(objBtn[1] + objBtn[3] / 2 + 30, objBtn[2] + objBtn[4] + 5)
        objBtn[2] = objBtn[2] + 10
        objBtn[4] = objBtn[4] - 20
        ch.UIManager:cleanGamePopupLayer(false,true)
    elseif obj.id == 10180 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2]+objBtn[4]/2 - 30)
    elseif obj.id == 10190 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2]+objBtn[4]/2 - 30)
    elseif obj.id == 10200 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2]+objBtn[4]/2 - 30)
    elseif obj.id == 10210 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2]+objBtn[4]/2 - 30)
    elseif obj.id == 10220 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2]+objBtn[4]/2 - 30)
    elseif obj.id == 10230 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2]+objBtn[4]/2 - 30)
    elseif obj.id == 10240 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2]+objBtn[4]/2 - 30)
        -- 祭坛相关10250，10260，10200，10210，10220，10230
    elseif obj.id == 10250 then
        armature2:setRotation(45)
        armature2:setPosition(objBtn[1] + objBtn[3] / 2 - 25, objBtn[2] - 20)
        objBtn[2] = objBtn[2] - 20
        objBtn[3] = objBtn[3] + 20
        objBtn[4] = objBtn[4] + 60
        ch.UIManager:cleanGamePopupLayer(false,true)
        self:showText(Language.src_clickhero_guide_guide_1,objBtn[2])
    elseif obj.id == 10260 then
        armature2:setRotation(45)
        armature2:setPosition(objBtn[1] + objBtn[3] / 2 - 25, objBtn[2] - 20)
        objBtn[1] = objBtn[1] - 10
        objBtn[2] = objBtn[2] - 30
        objBtn[3] = objBtn[3] + 20
        objBtn[4] = objBtn[4] + 60
        self:showText(Language.src_clickhero_guide_guide_2,objBtn[2])
    elseif obj.id == 10270 then
        armature2:setRotation(45)
        armature2:setPosition(objBtn[1] + objBtn[3] / 2 - 25, objBtn[2] - 20)
        objBtn[1] = objBtn[1] - 10
        objBtn[2] = objBtn[2] - 30
        objBtn[3] = objBtn[3] + 20
        objBtn[4] = objBtn[4] + 60
        self:showText(Language.src_clickhero_guide_guide_3,objBtn[2])
    elseif obj.id == 10280 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2]+objBtn[4]/2 - 30)
        self:showText(Language.src_clickhero_guide_guide_4,objBtn[2])
    elseif obj.id == 10290 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2]+objBtn[4]/2 - 30)
        self:showText(Language.src_clickhero_guide_guide_5,objBtn[2])
    elseif obj.id == 10300 then
        armature2:setRotation(45)
        armature2:setPosition(objBtn[1] + objBtn[3] / 2 - 25, objBtn[2] - 20)
        objBtn[1] = objBtn[1]-20
        objBtn[2] = objBtn[2]-25
    elseif obj.id == 10310 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2]+objBtn[4]/2 - 30)
    elseif obj.id == 10320 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2] + objBtn[4]/2 - 30)
        objBtn[2] = objBtn[2]-10
        ch.UIManager:cleanGamePopupLayer(false,true)
    elseif obj.id == 10330 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2] + objBtn[4]/2 - 30)
    elseif obj.id == 10340 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2] + objBtn[4]/2 - 30)
        objBtn[2] = objBtn[2]-10
        ch.UIManager:cleanGamePopupLayer(false,true)
        self:showText(Language.src_clickhero_guide_guide_6,objBtn[2])
    elseif obj.id == 10350 then
        armature2:setRotation(0)
        armature2:setPosition(objBtn[1] + objBtn[3]/2 + 25, objBtn[2] + objBtn[4]/2 - 30)         
    end
    armature4:setPosition(objBtn[1] + objBtn[3] / 2, objBtn[2] + objBtn[4]/2)
    
--    imageQuYu:setContentSize(cc.size(objBtn[3], objBtn[4]))
--    imageQuYu:setPosition(objBtn[1] + objBtn[3] / 2, objBtn[2] + objBtn[4] / 2)
    
    --imageQuYu:setPosition(cc.Director:getInstance():getWinSize().width/2, cc.Director:getInstance():getWinSize().height/2)
    --ccui.Layout:create():getTouchEndPosition()
    --ccui.Layout:create():getContentSize()
    --ccui.Layout:create():convertToWorldSpace(nodePoint)
    --ccui.ListView:create():getItem(index)
    --ccui.ImageView:create():ignoreContentAdaptWithSize(false)
    --ccui.ImageView:create():setScale(float)
    
    if obj.id == 10110 then
        self:play_guide(9040)
    else
        _guide:setTouchEnabled(false)
    end
end

function guide:loadEffect(name)
    zzy.EffectResManager:loadResource(name)
    if self._effectRes[name] then
        self._effectRes[name] = self._effectRes[name] + 1
    else
        self._effectRes[name] = 1
    end
end

function guide:firstPanel(obj)
    _guide:setVisible(true)
    _guide:setTouchEnabled(true)
    
    self:savestate(obj.id)
    local pathBase = "res/ui/"
    obj_widget = cc.CSLoader:createNode(pathBase..obj["csb"]..".csb", pathBase)
    obj_widget:setName("")
    --local btnTmp = obj_widget:getChildByName("btn_ok")
    local btnTmp = zzy.CocosExtra.seekNodeByName(obj_widget,"btn_ok")
    --ccui.ImageView:create():getChildByName(name)
    if btnTmp then
        btnTmp:addTouchEventListener(function(objtager, evt)
            if evt == ccui.TouchEventType.began then
                obj_widget:removeFromParent()
                _guide:setVisible(false)
                _guide:setTouchEnabled(false)
                self:endid(obj.id)
            end
        end)
    end
    _guide:addChild(obj_widget)
    if obj.entime > 0 then
        zzy.TimerUtils:setTimeOut(tonumber(obj.entime), function()
            _guide:setTouchEnabled(false)
        end)
    end
    if obj.tName and obj.tName ~= "" then
        local childName = zzy.StringUtils:split(obj.tName,"|")
        local imagePath = zzy.StringUtils:split(obj.tImage,"|")
        for i=1,#childName do
            local image =  zzy.CocosExtra.seekNodeByName(obj_widget,childName[i])
            if image then
                image:loadTexture("res/guide/"..imagePath[i],ccui.TextureResType.localType)
            end
        end
    end
    
    local objUnits = {}
    local dtype = zzy.StringUtils:split(obj.dtype,"|")
    local dtime = zzy.StringUtils:split(obj.dtime,"|")
    local btime = zzy.StringUtils:split(obj.btime,"|")
    local layer_panel
    local layer_dtype
    local layer_eff
    self.guide9010count = 1
    for k,v in ipairs(dtype) do
        layer_panel = zzy.CocosExtra.seekNodeByName(obj_widget,"Panel_"..tostring(k))
        table.insert(objUnits,layer_panel)
    	if tonumber(v) == 1 then
            layer_dtype = zzy.CocosExtra.seekNodeByName(layer_panel,"dtype_1")
            --layer_eff = self:getShouZhi()
            --layer_dtype:addChild(layer_eff)
    	end
        layer_panel:setVisible(false)
        zzy.TimerUtils:setTimeOut(tonumber(dtime[k]), function()
            objUnits[self.guide9010count]:setVisible(true)
            objUnits[self.guide9010count]:setOpacity(0)
            local animation = cc.FadeIn:create(0.5)
            --local seq = cc.Sequence:create(animation)
            objUnits[self.guide9010count]:runAction(animation)
            self.guide9010count = self.guide9010count + 1
        end)
    end
    
    local bgUnits = {}
    local layer_mask
    self.guide9010count2 = 1
    for k,v in ipairs(btime) do
        layer_mask = zzy.CocosExtra.seekNodeByName(obj_widget,"Image_mask_"..tostring(k))
        if layer_mask then
            table.insert(bgUnits,layer_mask)
            if k == 1 then
                layer_mask:setVisible(true)
        	else
                layer_mask:setVisible(false)
            end
        end
    end
    for k,v in ipairs(bgUnits) do
        zzy.TimerUtils:setTimeOut(tonumber(btime[k]), function()
            for i=1,table.maxn(bgUnits) do
                if i == self.guide9010count2 then
                    bgUnits[i]:setVisible(true)
                else
                    bgUnits[i]:setVisible(false)
                end
            end
            self.guide9010count2 = self.guide9010count2 + 1
        end)
    end
end

function guide:getShouZhi()
    local layer = cc.Layer:create();
    --添加雷达效果
    --zzy.EffectResManager:loadResource("effect_tx_leida")
    self:loadEffect("effect_tx_leida")
    local armatureld = ccs.Armature:create("tx_leida")
    layer:addChild(armatureld)
    armatureld:getAnimation():play("Animation1",-1,1)
    armatureld:getAnimation():setSpeedScale(0.75)
    
    --zzy.EffectResManager:loadResource("effect_tx_shouzhi")
    self:loadEffect("tx_shouzhi")
    local armaturesz = ccs.Armature:create("tx_shouzhi")
    layer:addChild(armaturesz)
    --armature2:setPosition(cc.Director:getInstance():getWinSize().width/2, cc.Director:getInstance():getWinSize().height/2)
    armaturesz:getAnimation():play("Animation1",-1,1)
    --armaturesz:getAnimation():setSpeedScale(2)
    
    return layer
end

function guide:openPanel(obj)
    _guide:setVisible(true)
    _guide:setTouchEnabled(true)
    
    self:savestate(obj.id)
    local pathBase,obj_widget_boss
    pathBase = "res/ui/"
    obj_widget_boss = cc.CSLoader:createNode(pathBase..obj["csb"]..".csb", pathBase)
    obj_widget_boss:setName("")
    --local btnTmp = obj_widget_boss:getChildByName("btn_ok")
    local btnTmp = zzy.CocosExtra.seekNodeByName(obj_widget_boss,"btn_ok")
    --ccui.ImageView:create():getChildByName(name)
    if btnTmp then
        btnTmp:addTouchEventListener(function(objtager, evt)
            if evt == ccui.TouchEventType.began then
                obj_widget_boss:removeFromParent()
                self:endid(obj.id)
                _guide:setVisible(false)
                _guide:setTouchEnabled(false)
            end
        end)
    end
    _guide:addChild(obj_widget_boss)
end

function guide:endid(id)
    if self.obj and self.obj.id and id == self.obj.id then
        _guide:setVisible(false)
        if imageLayer then
            imageLayer:removeFromParent()
            imageLayer = nil
            textPanel = nil
            layerMask = {}
        end
        for k,v in pairs(self._effectRes) do
            zzy.EffectResManager:releaseResource(k,true,v)
            self._effectRes[k] = nil
        end
        self.obj = nil
        self:savestate(id)
        
        if id == 9010 then
            ch.StatisticsManager:sendGuideStep(1)
            self:play_guide(9020)
        elseif id == 9020 then
            ch.StatisticsManager:sendGuideStep(2)
            ch.LevelController:startAddEnemy()
            self:play_guide(10010)
            ch.StatisticsManager:sendGuideStep(3)
        elseif id == 9030 then
            ch.LevelController:startFightBoss()
        elseif id == 10020 then
            ch.StatisticsManager:sendGuideStep(4)
        	self:play_guide(10030)
        elseif id == 10030 then
            if item4 then
                item4 = nil
            end 
            self:savestate(10020)
            ch.StatisticsManager:sendGuideStep(5)
        elseif id == 10050 then
            ch.StatisticsManager:sendGuideStep(6)
            self:play_guide(10060)
        elseif id == 10060 then
            if item4 then
                item4 = nil
            end 
            self:savestate(10050)
            ch.StatisticsManager:sendGuideStep(7)
        elseif id == 10070 then
            if ch.TotemModel:getOwnTotemNum() == 0 then
                local bottomPanel = ch.UIManager:getBottomWidget("tuteng/W_TutengList")
                if not bottomPanel then
                    self:play_guide(10080)
                else
                    cclog("图腾界面已打开，跳过引导：10080")
                    self:play_guide(10090)
                end
            end
        elseif id == 10080 then
            self:play_guide(10090)
        elseif id == 10090 then
            if item4 then
                item4 = nil
            end 
            self:savestate(10080)
--            self:play_guide(10100)
            self:play_guide(10110)
        elseif id == 9040 then
--            self:savestate(10100)
            self:savestate(10110)
--            local obj10100 = GameConfig.GuideConfig:getData(10100)
--            if armature then
--                armature:getAnimation():stop()
--                armature:removeFromParent()
--                zzy.EffectResManager:releaseResource(obj10100.effpath)
--            end
            if obj_widget then
                obj_widget:removeFromParent()
                _guide:setVisible(false)
                _guide:setTouchEnabled(false)
            end
        elseif id == 10120 then
            self:play_guide(10130)
        elseif id == 10130 then
--            self:play_guide(10140)
--        elseif id == 10140 then
            self:play_guide(9090)
        elseif id == 9060 then
            self:play_guide(10150)
        elseif id == 10150 then
            self:play_guide(10160)
        elseif id == 10160 then
            self:play_guide(9070)
        elseif id == 9080 then
            ch.DefendMap:endGuide()
        -- 天梯相关
        elseif id == 10170 then
            self:play_guide(10180)
        elseif id == 10180 then
            if item4 then
                item4 = nil
            end 
            self:savestate(10170)
        -- 引导上阵
        elseif id == 10190 then
            self:play_guide(10200)
        elseif id == 10200 then
            self:play_guide(10210)
        elseif id == 10210 then
            self:play_guide(10220)
        elseif id == 10220 then
            self:play_guide(10230)
        elseif id == 10240 then
            if item4 then
                item4 = nil
            end 
            self:savestate(10190)
        -- 祭坛引导
        elseif id == 10250 then
            self:showWait(1.5,function()
                self:play_guide(10260)
            end)
        elseif id == 10260 then
            self:play_guide(10200)
        elseif id == 10270 then
            self:showWait(1.5,function()
                self:play_guide(10280)
            end)
        elseif id == 10280 then
            self:showWait(1.5,function()
                self:play_guide(10290)
            end)
        elseif id == 10290 then
            if item4 then
                item4 = nil
            end 
            self:savestate(10270)
        elseif id == 10300 then
            self:play_guide(10310)
        elseif id == 10310 then
            if item4 then
                item4 = nil
            end 
            self:savestate(10300)
        elseif id == 10320 then
            self:play_guide(10330)
        elseif id == 10330 then
            if item4 then
                item4 = nil
            end 
            self:savestate(10320)
        elseif id == 10340 then
            self:play_guide(10350)
        elseif id == 10350 then
            if item4 then
                item4 = nil
            end 
            self:savestate(10340)
        end
    end
end

function guide:creatText(layerTable)
    textWidget = ccui.Text:create("","res/ui/aaui_font/ch.ttf",20)
    textWidget:setColor(cc.c3b(112,46,12))
    textWidget:ignoreContentAdaptWithSize(true)
    textWidget:setMaxLineWidth(400)

    textWidget:setAnchorPoint(cc.p(0,0.5))
    local height = textWidget:getContentSize().height
    local width = textWidget:getContentSize().width
    textPanel = ccui.ImageView:create("aaui_mgg/db_guide.png",ccui.TextureResType.plistType)
    textPanel:setScale9Enabled(true)
    textPanel:setCapInsets(cc.rect(110,80,30,30))
    local heightAll = height+100
    local widthAll = width+100
    if heightAll < 160 then
       heightAll = 160
    end
    if widthAll < 254 then
        widthAll = 254
    end
    textWidget:setPosition(widthAll/2,heightAll/2)
    textPanel:setContentSize(cc.size(widthAll,heightAll))
    textPanel:addChild(textWidget)
    textPanel:setAnchorPoint(cc.p(0.5,0.5))
    textPanel:setPosition(0,0)
    imageLayer:addChild(textPanel)
    table.insert(layerTable,textPanel)
    textPanel:setVisible(false)
end

function guide:showText(text,pointY)
    if not text or text == "" then
        textPanel:setVisible(false)
        return 
    end
    textPanel:setVisible(true)
    textWidget:setString(text)
    local height = textWidget:getContentSize().height
    local width = textWidget:getContentSize().width
    textPanel:setScale9Enabled(true)
    local heightAll = height+100
    local widthAll = width+100
    if heightAll < 160 then
        heightAll = 160
    end
    if widthAll < 254 then
        widthAll = 254
    end
    textWidget:setPosition(50,heightAll-80)
    textPanel:setContentSize(cc.size(widthAll,heightAll))
    if pointY > 568 then
        textPanel:setPosition(320,pointY-heightAll/2-100)
    else
        textPanel:setPosition(320,pointY+heightAll/2+100)
    end
end

function guide:createWait()
    waitingLayer = ccui.Layout:create()
    waitingLayer:setOpacity(0)
    waitingLayer:setContentSize(cc.Director:getInstance():getWinSize())
    waitingLayer:setTouchEnabled(true)
    waitingLayer:setVisible(false)
    _guide:addChild(waitingLayer,1)
end

function guide:showWait(time,func)
    if not waitingLayer then
        self:createWait()
    end
    _guide:setVisible(true)
    waitingLayer:setVisible(true)
    zzy.TimerUtils:setTimeOut(time,function()
        func()
        waitingLayer:setVisible(false)
    end)
end

return guide