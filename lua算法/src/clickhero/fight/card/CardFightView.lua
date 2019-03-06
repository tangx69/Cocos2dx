local CardFightView = {
    _renderer = nil,
    _card = nil,
--    _attNamePanel = nil,
--    _defNamePanel = nil,
    _recordList = nil,
    _hpProgress = nil,
    _hpProgressAni = nil,
    _btnClose = nil,
}
local itemSize= cc.size(116,210)

function CardFightView:init(attacker,defender)
    self._renderer = cc.CSLoader:createNode("res/ui/card/W_card_f.csb","res/ui/")
    self._renderer:setTouchEnabled(true)
    self._renderer:setPositionY(-ch.editorConfig:getSceneGlobalConfig().roleh)
    self:initBuffer()
    self:initCard(attacker,defender)
    self:initName(attacker,defender)
    self._recordList = zzy.CocosExtra.seekNodeByName(self._renderer,"lv_chat")
    self._btnClose = zzy.CocosExtra.seekNodeByName(self._renderer, "Button_close")
    self._btnClose:addTouchEventListener(function(sender,evt)
        if evt == ccui.TouchEventType.ended then
            ch.CardFightMap:skipFight()
        end
    end)
--    local button = zzy.CocosExtra.seekNodeByName(self._renderer,"Button_1")
--    button:addTouchEventListener(function(obj,evt)
--        if evt == ccui.TouchEventType.ended then
--            ch.UIManager:getActiveSkillLayer():setVisible(true)
--            ch.UIManager:getMainViewLayer():setVisible(true)
--            ch.CardFightMap:destroy()
--            ch.LevelController:startNormal()
--        end
--    end)
end

function CardFightView:getRenderer()
	return self._renderer
end

function CardFightView:initBuffer()
    local attbuffer = zzy.CocosExtra.seekNodeByName(self._renderer,"lv_att_buff")
    local defbuffer = zzy.CocosExtra.seekNodeByName(self._renderer,"lv_def_buff")
    ch.CardBufferManager:init(attbuffer,defbuffer)
end

function CardFightView:initName(attacker,defender)
    local attNamePanel = zzy.CocosExtra.seekNodeByName(self._renderer,"self_hp_panel")
    local defNamePanel = zzy.CocosExtra.seekNodeByName(self._renderer,"enemy_hp_panel")
    local aName = zzy.CocosExtra.seekNodeByName(attNamePanel,"attackerName")
    local dName = zzy.CocosExtra.seekNodeByName(defNamePanel,"defenderName")
    aName:setString(attacker.role.name)
    dName:setString(defender.role.name)
    self._hpProgress = {}
    self._hpProgressAni = {}
    local sp1 = zzy.CocosExtra.seekNodeByName(attNamePanel,"s_hp_progress")
    local sp2 = zzy.CocosExtra.seekNodeByName(defNamePanel,"e_hp_progress")
    self._hpProgress[ch.CardFightMap.RoleType.attacker] = self:createProgressTime(sp1)
    self._hpProgress[ch.CardFightMap.RoleType.defender] = self:createProgressTime(sp2)
end

function CardFightView:createProgressTime(sprite)
    local parent = sprite:getParent()
    sprite:removeFromParent()
    local timer = cc.ProgressTimer:create(sprite)
    timer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    timer:setMidpoint(cc.vertex2F(0,0))
    timer:setBarChangeRate(cc.vertex2F(1, 0))
    timer:setPercentage(100)
    local x,y = sprite:getPosition()
    timer:setPosition(x,y)
    local anchor = sprite:getAnchorPoint()
    timer:setAnchorPoint(anchor)
    parent:addChild(timer)
    return timer
end

function CardFightView:initCard(attacker,defender)
    self._card = {{},{}}
    self._widgets = {{},{}}
    local attPanel = zzy.CocosExtra.seekNodeByName(self._renderer,"attack_Panel")
    for i= 1,5 do
        local widget = zzy.CocosExtra.seekNodeByName(attPanel,"W_card_f_xk_w"..i)
                
        if attacker.sk[i] then
            self:setUnit(widget,attacker.sk[i])
            widget.order = i
            self._card[1][GameConfig.CardConfig:getData(attacker.sk[i].id).skillid] = widget
            
            INFO("[CARD][卡牌战][自己]")
            local aniPanel = ccui.Helper:seekWidgetByName(widget, "Panel_layer")
            if attacker.sk[i].id then
                ch.CommonFunc:showCardSke(aniPanel, attacker.sk[i].id, 0.25, 55, -100)
            end
        
        else
            widget:setVisible(false)
        end
    end
    local defPanel = zzy.CocosExtra.seekNodeByName(self._renderer,"defender_panel")
    for i=1,5 do
        local widget = zzy.CocosExtra.seekNodeByName(defPanel,"W_card_f_xk_d"..i)
        if defender.sk[i] then
            self:setUnit(widget,defender.sk[i])
            widget.order = i
            self._card[2][GameConfig.CardConfig:getData(defender.sk[i].id).skillid] = widget
             
            INFO("[CARD][卡牌战][对手]")
            local aniPanel = ccui.Helper:seekWidgetByName(widget, "Panel_layer")
            if defender.sk[i].id then
                ch.CommonFunc:showCardSke(aniPanel, defender.sk[i].id, 0.25, 55, -100)
            end
        else
            widget:setVisible(false)
        end
    end
end

function CardFightView:startAction(func)
--    self._attNamePanel:setPosition(0,self._attNamePanel.p.y)
--    self._defNamePanel:setPosition(640,self._defNamePanel.p.y)
    self:cardStartAction(ch.CardFightMap.RoleType.attacker,function()
--        local act = cc.EaseExponentialOut:create(cc.MoveTo:create(0.5,self._attNamePanel.p))
--        self._attNamePanel:runAction(act)
--        local act1 = cc.EaseExponentialOut:create(cc.MoveTo:create(0.5,self._defNamePanel.p))
--        self._defNamePanel:runAction(act1)
        if func then func() end
    end)
    self:cardStartAction(ch.CardFightMap.RoleType.defender)
end

function CardFightView:cardStartAction(roleType,func)
    local max = 1
    for _,widget in pairs(self._card[roleType]) do
        if widget.order > max then
            max = widget.order
        end
    end
    local isAttacker = roleType == ch.CardFightMap.RoleType.attacker
    local startX = isAttacker and 720 or -120
    local disY = isAttacker and 30 or -30
    for k,widget in pairs(self._card[roleType]) do
        local posY = widget.p.y + disY
        widget:setPosition(startX,posY)
        widget:setScale(1.2)
        local width = 0.2 * widget:getContentSize().width
        local posX = widget.p.x +(widget.order - 3)*width
        local delayTime = roleType == ch.CardFightMap.RoleType.attacker and 0.15*(widget.order - 1) or 0.15*(max - widget.order) 
        local delay = cc.DelayTime:create(delayTime)
        local move = cc.EaseExponentialOut:create(cc.MoveTo:create(0.75-delayTime,cc.p(posX,posY)))
        local delayTime2 = roleType == ch.CardFightMap.RoleType.attacker and 0.1*(widget.order - 1) or 0.1*(max - widget.order)
        local delay2 = cc.DelayTime:create(delayTime2)
        local move2 = cc.Spawn:create(cc.MoveTo:create(0.1,widget.p),cc.ScaleTo:create(0.1,1))
        local seq
        if func and widget.order == max then
            seq = cc.Sequence:create(delay,move,delay2,move2,cc.CallFunc:create(function()
                func()
            end))
        else
            seq = cc.Sequence:create(delay,move,delay2,move2)
        end
        widget:runAction(seq)
    end
end

function CardFightView:showHP(roleType,hpRatio)
    hpRatio = hpRatio *100
    local curPercent = self._hpProgress[roleType]:getPercentage()
    if self._hpProgressAni[roleType] then
        self._hpProgressAni[roleType]:removeFromParent()
        self._hpProgressAni[roleType] = nil
    end
    self._hpProgress[roleType]:stopAllActions()
    if curPercent > hpRatio then
        local ani = ccs.Armature:create("tx_xuetiaoxiaoguo")
        ani:getAnimation():play("play",-1,0)
        local width = self._hpProgress[roleType]:getContentSize().width * curPercent/100
        ani:setPosition(width,0)
        ani:setScaleX((curPercent - hpRatio)/50) --特效做的0.5个长度
        ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete then
                ani:removeFromParent()
                self._hpProgressAni[roleType] = nil
            end
        end)
        self._hpProgressAni[roleType] = ani
        self._hpProgress[roleType]:addChild(ani)
        local act = cc.ProgressTo:create(0.2,hpRatio)
        self._hpProgress[roleType]:runAction(act)
    else
        self._hpProgress[roleType]:setPercentage(hpRatio)
    end
end

function CardFightView:raiseSkill(role,id,func)
    local widget = self._card[role][id]
    widget:setLocalZOrder(1)
    local dis = role == ch.CardFightMap.RoleType.attacker and 40 or -40
    local scaleAct = cc.ScaleTo:create(0.2,1.5)
    local seq = cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(0,dis)),cc.CallFunc:create(function()
        scaleAct = cc.ScaleTo:create(0.15,1)
        local act = cc.EaseExponentialIn:create(cc.MoveBy:create(0.15,cc.p(0,-dis)))
        local seq1 = cc.Sequence:create(act,cc.CallFunc:create(function()
            if func then func() end
            widget:setLocalZOrder(0)
            widget:setPosition(widget.p)
        end))
        widget:runAction(scaleAct)
        widget:runAction(seq1)
    end))
    widget:runAction(scaleAct)
    widget:runAction(seq)
    local ani = ccs.Armature:create("tx_kapaishifang")
    ani:getAnimation():play("play",-1,0)
    ani:getAnimation():setMovementEventCallFunc(function(...)
        ani:removeFromParent()
    end)
    local size = widget:getContentSize()
    ani:setPosition(widget:getContentSize().width/2,widget:getContentSize().height/2)
    widget:addChild(ani)
    ch.CardBufferManager:addBuffer(role,id)
end

local timeOutId = nil
function CardFightView:showRecord(type,text)
    --cclog( string.gsub(text,"%%","%%%%"))
    local rt = self:createText(type,text)
    self._recordList:pushBackCustomItem(rt)
    if timeOutId then
        zzy.TimerUtils:cancelTimeOut(timeOutId)
    end
    timeOutId = zzy.TimerUtils:setTimeOut(0.1,function()
        if zzy.CocosExtra.isCobjExist(self._recordList) then
            self._recordList:jumpToBottom()
        end
    end)
end

local colors = {
    cc.c3b(255,0,72),
    cc.c3b(34,239,0),
    cc.c3b(219,103,0),
    cc.c3b(144,0,255)
}

function CardFightView:createText(type,text)
    local rt = ccui.Text:create(text,"res/ui/aaui_font/ch.ttf",16)
    rt:setColor(colors[type])
    rt:setMaxLineWidth(560)
    return rt
end

function CardFightView:close()
    self._card = nil
    self._renderer = nil
    self._attNamePanel = nil
    self._defNamePanel = nil
end

function CardFightView:setUnit(widget,skill)
    local px,py = widget:getPosition()
    if widget:getContentSize().width == 0 then
        widget:setContentSize(itemSize)
    end
    local x = px + widget:getContentSize().width*widget:getScaleX()/2
    local y = py + widget:getContentSize().height * widget:getScaleY()/2
    widget:setAnchorPoint(0.5,0.5)
    local p = cc.p(x,y)
    widget:setPosition(p)
    widget.p = p
    local config = GameConfig.CardConfig:getData(skill.id)
    local icon = zzy.CocosExtra.seekNodeByName(widget,"img_card")
    cc.Director:getInstance():getTextureCache():addImage(config.icon,function()
        if zzy.CocosExtra.isCobjExist(icon) then
            icon:loadTexture(config.icon,ccui.TextureResType.localType)
        end
    end)
    local jobIcon = zzy.CocosExtra.seekNodeByName(widget,"img_job")
    jobIcon:loadTexture(GameConst.PETCARD_JOB[config.job].icon,ccui.TextureResType.plistType)
    local talentIcon = zzy.CocosExtra.seekNodeByName(widget,"img_talent")
    local talent = skill.talent or config.talent
    
    
    if GameConst.CARD_TALENT_IMAGE[talent] == "icon/card/aaui_card_talent_SSS.png" then
        talentIcon:loadTexture(GameConst.CARD_TALENT_IMAGE[talent])
    else
        talentIcon:loadTexture(GameConst.CARD_TALENT_IMAGE[talent],ccui.TextureResType.plistType)
    end
    
    local select = zzy.CocosExtra.seekNodeByName(widget,"cb_select")
    select:setTouchEnabled(false)
    local pzConfig = GameConfig.CarduplevelConfig:getData(skill.l)
    local star = pzConfig.star
    local color = pzConfig.max_star
    for i= 1,7 do
        local starW = zzy.CocosExtra.seekNodeByName(widget,"quality_star_"..i)
        local texture
        if i == 1 then
            starW:setVisible(color == 4)
            texture = (color == 4 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        elseif i == 2 then
            starW:setVisible(color == 3)
            texture = (color == 3 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        elseif i == 3 then
            starW:setVisible(color == 4 or color == 2)
            texture = ((color == 4 and star >= 2) or (color == 2 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        elseif i == 4 then
            starW:setVisible(color == 3 or color == 1)
            texture = ((color == 3 and star >= 2) or (color == 1 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        elseif i == 5 then
            starW:setVisible(color == 4 or color == 2)
            texture = ((color == 4 and star >= 3) or (color == 2 and star >= 2)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        elseif i == 6 then
            starW:setVisible(color == 3)
            texture = (color == 3 and star >= 3) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        elseif i == 7 then
            starW:setVisible(color == 4)
            texture = (color == 4 and star >= 4) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        end
        starW:loadTexture(texture,ccui.TextureResType.plistType)
    end
    local pzIcon = GameConfig.CarduplevelConfig:getData(skill.l).bgFrame_mini
    local pz = zzy.CocosExtra.seekNodeByName(widget,"db_card_02")
    cc.Director:getInstance():getTextureCache():addImage(pzIcon,function()
        pz:loadTexture(pzIcon,ccui.TextureResType.localType)
    end)
end


return CardFightView