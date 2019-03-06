local moveTimeRange = {1,5}
local standTimeRange = {2,3}
local speedRange = {130,180}
local a = -6500 -- 石头加速度
local stoneSpeedRange = {1200,1400}

local getTopPosition = function(ani)
    local boneP = ch.CommonFunc:getHpBarPos(ani, "top")
    local newX = boneP.x * ani:getScaleX()
    local newY = boneP.y * ani:getScaleY() + 50
    return cc.p(newX,newY)
end

local createRole = function(c,route)
	local ani = ch.CommonFunc:createAnimation(c.avatar)
    ch.CommonFunc:playAni(ani, "move", true)

    local scale = c.scale * (0.75-route/30)
    ani:setScaleX(scale*(math.random(0,1) == 0 and 1 or -1))
    ani:setScaleY(scale)
    if ch.CommonFunc:isSpine(ani) then
        ani:setScaleX(ani:getScaleX()*1.5)
        ani:setScaleY(ani:getScaleY()*1.5)
    end
    
    ani.baseSpeed = math.random(speedRange[1],speedRange[2])
    ani.curSpeed = ani.baseSpeed
    ani.changeTime = os_clock() + math.random(moveTimeRange[1],moveTimeRange[2])
    return ani
end

local addStone = function(role,layer,stones,endP)
    local ani = ccs.Armature:create("tx_jitanxiaoguo")
    ani:setPosition(getTopPosition(role.ani))
    ani:getAnimation():play("chuxian",-1,0)
    ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.complete then
            if movementID == "chuxian" then
                local wp = ani:convertToWorldSpace(cc.p(0,0))
                local startP = layer:convertToNodeSpace(wp)
                ani:retain()
                ani:removeFromParent()
                layer:addChild(ani)
                ani:release()
                ani:getAnimation():play("fly",-1,1)
                ani:setPosition(startP)
                table.insert(stones,ani)
                ani.startTime = os_clock()
                ani.startP = startP
                ani.vy = math.random(stoneSpeedRange[1],stoneSpeedRange[2])
                local t = math.sqrt(2*(endP.y - startP.y)/a + math.pow(ani.vy/a,2))
                t = t - ani.vy/a
                ani.vx = (endP.x - startP.x)/t
            elseif movementID == "shanguang" then
                ani:removeFromParent()        
            end
        end
    end)
    role:addChild(ani)
end

local doStoneAction = function(stoneButton)
	if stoneButton.isActioning then return end
	local act1 = cc.EaseExponentialOut:create(cc.ScaleTo:create(0.3,1.5))
	local act2 = cc.DelayTime:create(0.1)
    local act3 = cc.EaseExponentialOut:create(cc.ScaleTo:create(0.3,1))
    local seq = cc.Sequence:create(act1,act2,act3,cc.CallFunc:create(function()
        stoneButton.isActioning = nil
    end))
    stoneButton.isActioning = true
    stoneButton:runAction(seq)
end

local updateStones = function(stones,curTime,dt,endP,stoneButton)
    local removeK={}
    for k,stone in ipairs(stones) do
        local t = curTime - stone.startTime
        local x = stone.startP.x + stone.vx * t
        local y = stone.startP.y + stone.vy *t + 0.5*a*t*t
        if y < endP.y then
            x = endP.x
            y = endP.y
            table.insert(removeK,1,k)
            stone:getAnimation():play("shanguang",-1,0)
            doStoneAction(stoneButton)
        end
        stone:setPosition(x,y)
	end
	for k,sk in ipairs(removeK) do
        table.remove(stones,sk)
	end
end

local updateRole = function(role,curTime,dt)
    if curTime > role.ani.changeTime then
        local ct = 0
        if role.ani.curSpeed > 0 then
            role.ani.curSpeed = 0
            ct = math.random(standTimeRange[1],standTimeRange[2])
            if math.random(0,1) == 0 then
                role.ani:setScaleX(role.ani:getScaleX() * -1)
            end
        else
            role.ani.curSpeed = role.ani.baseSpeed
            ct = math.random(moveTimeRange[1],moveTimeRange[2])
        end
        role.ani.changeTime = curTime + ct
    end
    if role.ani.curSpeed > 0 then
		local flip = ch.CommonFunc:isSpine(role.ani) and -1 or 1
        local distance = role.ani.curSpeed*dt* (role.ani:getScaleX()*flip>0 and -1 or 1)
        local x = role:getPositionX() + distance
        if role.ani:getScaleX()*flip > 0 and x < 50 then
            x = 50
            role.ani:setScaleX(role.ani:getScaleX() * -1)
        end
        if role.ani:getScaleX()*flip < 0 and x > 600 then
            x = 600
            role.ani:setScaleX(role.ani:getScaleX() * -1)
        end
        role:setPositionX(x)
    end
end

local playFly = function(pro,com,widget,layer,startP,endP,count)
    local intervalX = endP.x - startP.x
    local curIndex = 0
    for i = 1,count do
        widget:setTimeOut(2*(i-1)/30,function()
            local ani = ccs.Armature:create("tx_jitanfly")
            ani:getAnimation():play("play")
            ani:setScale(math.random(100,150)/100)
            ani:setPosition(startP)
            layer:addChild(ani)
            local r1 = math.random(15,50)/100 * intervalX
            local sx = math.random(1,2) == 1 and r1 or -r1
            local p1 = cc.p(startP.x - sx,startP.y)
            local p2 = cc.p(endP.x + sx,endP.y)
            local bezier = cc.BezierTo:create(1.5,{p1,p2,endP})
            local bezierEase = cc.EaseIn:create(bezier,1.8)
            local seq = cc.Sequence:create(bezierEase,cc.CallFunc:create(function()
                ani:removeFromParent()
                curIndex = curIndex + 1
                if pro then pro(curIndex) end
                if curIndex == count and com then
                   com()
                end
            end))
            ani:runAction(seq)
        end)
    end
end

local lvUpEffectName = {"tx_jinbixiaolvtisheng","tx_yingxiongzhihuntisheng","tx_shengguangshouhutisheng"}
local curUseLvUpEffect = {}
local playLvUpEffect = function(layer,type,res,text)
    local name = lvUpEffectName[type]
    ch.RoleResManager:loadEffect(name)
    res[name] = true
    local node = cc.Node:create()
    local ani = ccs.Armature:create(name)
    ani:getAnimation():setSpeedScale(0.3)
    ani:getAnimation():play("play")
    local text = ccui.TextBMFont:create(text, "res/ui/aaui_font/font_red.fnt")
    text:setPosition(-20,-45)
    text:setAnchorPoint(0.5,0.5)
    node:addChild(ani)
    node:addChild(text)
    ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.complete then
            node:removeFromParent()
            ch.RoleResManager:releaseEffect(name)
            res[name] = nil
        end
    end)
    layer:addChild(node)
end

local altarBtn={
    {normal="res/icon/aaui_card/jt_cb_caifu1.png",pressed="res/icon/aaui_card/jt_cb_caifu2.png"},
    {normal="res/icon/aaui_card/jt_cb_linhun1.png",pressed="res/icon/aaui_card/jt_cb_linhun2.png"},
    {normal="res/icon/aaui_card/jt_cb_guanghui1.png",pressed="res/icon/aaui_card/jt_cb_guanghui2.png"}
}
local altarBtnGetExp = {
    {normal="aaui_card/jt_btn_kj_2.png",pressed="aaui_card/jt_btn_kj_1.png",disabled="aaui_card/jt_btn_kj_1.png"},
    {normal="aaui_card/jt_btn_lh_2.png",pressed="aaui_card/jt_btn_lh_1.png",disabled="aaui_card/jt_btn_lh_1.png"},
    {normal="aaui_card/jt_btn_gh_2.png",pressed="aaui_card/jt_btn_gh_1.png",disabled="aaui_card/jt_btn_gh_1.png"}
}

local altarOrder = {{3,1,2},{1,2,3},{2,3,1}}
local altarName = {Language.src_clickhero_view_AltarView_1,Language.src_clickhero_view_AltarView_2,Language.src_clickhero_view_AltarView_3}
local altarGetDes = {Language.src_clickhero_view_AltarView_4,Language.src_clickhero_view_AltarView_5,Language.src_clickhero_view_AltarView_6}

-- 卡牌祭坛主界面
zzy.BindManager:addFixedBind("card/W_jt_main", function(widget)
        local curAltar = ch.AltarModel:getCurAltarSelect()
        local cb_jitan1 = zzy.CocosExtra.seekNodeByName(widget,"cb_jitan1")
        cb_jitan1:loadTextures(altarBtn[altarOrder[curAltar][1]].normal, altarBtn[altarOrder[curAltar][1]].pressed, altarBtn[altarOrder[curAltar][1]].disabled)
        local cb_jitan2 = zzy.CocosExtra.seekNodeByName(widget,"cb_jitan2")
        cb_jitan2:loadTexture(altarBtn[altarOrder[curAltar][2]].pressed)
        local cb_jitan3 = zzy.CocosExtra.seekNodeByName(widget,"cb_jitan3")
        cb_jitan3:loadTextures(altarBtn[altarOrder[curAltar][3]].normal, altarBtn[altarOrder[curAltar][3]].pressed, altarBtn[altarOrder[curAltar][3]].disabled)
        
        local res = {}
        local roles = {}
        local stones = {}
        local effectRes = {}
        local layer = widget:getChild("Panel_move")
        local stoneButton = widget:getChild("panel_button")
        local stoneLayer = widget:getChild("Panel_Stone")
        local endP = stoneLayer:convertToNodeSpace(stoneButton:convertToWorldSpace(cc.p(0,0)))
        ch.RoleResManager:loadEffect("tx_jitanxiaoguo")
        local close = widget.destory
        widget.destory = function(widget,cleanView)
            close(widget,cleanView)
            for k,v in ipairs(res) do
                ch.RoleResManager:release(v)
            end
            for k,v in pairs(effectRes) do
                ch.RoleResManager:releaseEffect(k)
            end
            ch.RoleResManager:releaseEffect("tx_jitanxiaoguo")
            ch.RoleResManager:releaseEffect("tx_jitanfly")
        end
        local count =0
        local changeCards = function(cards)
            if roles then
                for k,v in pairs(roles) do
                    v:removeFromParent()
                end
            end
            roles = {}
            if res and #res >1 then
                for k,v in ipairs(res) do
                    ch.RoleResManager:release(v)
                end
            end
            res = {}
            count = count + 1
            local routes = {1,2,3,4,5}
            for k,v in pairs(cards) do
                local c = GameConfig.CardConfig:getData(v)
                local cur = count
                ch.RoleResManager:load(c.avatar,function()
                    if zzy.CocosExtra.isCobjExist(widget) and cur == count then
                        local key = math.random(1,#routes)
                        local route = routes[key]
                        table.remove(routes,key)
                        local node = cc.Node:create()
                        local ani = createRole(c,route)
                        node:addChild(ani)
                        node:setPosition(math.random(50,600),route*30)
                        node.ani = ani
                        layer:addChild(node,6-route)
                        roles[v] = node
                        table.insert(res,c.avatar)
                    else
                        ch.RoleResManager:release(c.avatar)
                    end
                end)
            end
        end
        local produce = function(id)
            if roles[id] then
                if zzy.CocosExtra.isCobjExist(widget) then
                    addStone(roles[id],stoneLayer,stones,endP)
                end
            end
        end

        local startTime = os_clock()   

        widget:listen(zzy.Events.TickEventType,function() 
            local time = os_clock()
            local dt = time - startTime
            startTime = time
            updateStones(stones,time,dt,endP,stoneButton)
            for k,role in pairs(roles) do
                updateRole(role,time,dt)
            end
        end)

    local altarSelectChangeEvent = {}
    altarSelectChangeEvent[ch.AltarModel.dataChangeEventType] = false

    widget:addDataProxy("data",function(evt)
        local curAltar = ch.AltarModel:getCurAltarSelect()
        local data = ch.AltarModel:getAltarByType(curAltar)
        local cs = GameConfig.Altar_levelConfig:getData(data.level)
        local panel = ch.AltarModel:getPanelData(curAltar)
        
        local ret = {}
        ret.jtLevel = Language.LV..data.level
        
        local nowAddPercent = cs.ratio/100 -100
        local nextAddPercent = (cs.ratio + cs.ratio_Inc)/100 - 100
        
        if ch.ShentanModel then
            nowAddPercent = nowAddPercent * (1+ch.ShentanModel:getSkillData(curAltar))
            nextAddPercent = nextAddPercent * (1+ch.ShentanModel:getSkillData(curAltar))
        end
        
        ret.getGoldType = string.format(altarGetDes[curAltar], ch.NumberHelper:multiple(nowAddPercent,1000))
        if cs.ratio_Inc > 0 then
            ret.getGoldType = ret.getGoldType .. string.format(Language.src_clickhero_view_AltarView_7,ch.NumberHelper:multiple(nextAddPercent, 1000))
        end
        ret.ifCanRob = data.level >= GameConst.ALTAR_ROB_LEVEL
        ret.ifCanUp = panel.exp>=cs.exp and data.level < #GameConfig.Altar_levelConfig:getTable()
        ret.robNum = Language.src_clickhero_view_AltarView_8..ch.AltarModel:getRobNum()
        ret.resetNum = string.format(Language.src_clickhero_view_AltarView_18,ch.AltarModel:getResetNum())
        ret.bgImage = GameConst.ALTAR_IMAGE_BG[curAltar].bg[1]
        --ret.bgImage_0 = GameConst.ALTAR_IMAGE_BG[curAltar].bg_0[1]
        ret.powerNum = ch.PetCardModel:getTeamPower(ch.AltarModel:getMyCardList(curAltar))
        ret.stoneNum = string.format("%d/%d",panel.stoneNum,data.maxNum)
        ret.outputAll = ch.AltarModel:getAllOutput(ch.AltarModel:getMyCardList(curAltar),true)
        ret.outputType = GameConst.ALTAR_EXP_NAME[curAltar]
        ret.btnImg1 = altarBtn[altarOrder[curAltar][1]]
        ret.btnImg2 = altarBtn[altarOrder[curAltar][2]]
        ret.btnImg3 = altarBtn[altarOrder[curAltar][3]]
        ret.btnGetImg = altarBtnGetExp[curAltar]
        ret.ifCanBuy = data.maxNum < GameConst.ALTAR_EXP_LIMIT_MAX
        ret.ifCanGet = panel.stoneNum/data.maxNum >= GameConst.ALTAR_GET_EXP_RATIO
                    or (ch.AltarModel:getAllOutput(ch.AltarModel:getMyCardList(curAltar),true) > 0
                    and panel.stoneNum >= ch.AltarModel:getAllOutput(ch.AltarModel:getMyCardList(curAltar),true))
        if ret.ifCanGet then
            widget:playEffect("getExpEffect",true)
        else
            widget:stopEffect("getExpEffect")
        end
        ret.ifOutputRatio = ch.FamiliarModel:getAltarAdd(curAltar)>0
        ret.noOutputRatio = not ret.ifOutputRatio
        local tmpRatio = ch.FamiliarModel:getAltarAdd(curAltar)
        if curAltar == 1 then
            tmpRatio = tmpRatio + ch.TotemModel:getTotemSkillData(1,15)
        elseif curAltar == 2 then
            tmpRatio = tmpRatio + ch.TotemModel:getTotemSkillData(1,14)
        elseif curAltar == 3 then
            tmpRatio = tmpRatio + ch.TotemModel:getTotemSkillData(1,13)
        end
        ret.outputRatio = tmpRatio*100 .."%"
                
        ret.outputNoAll = ch.AltarModel:getAllOutput(ch.AltarModel:getMyCardList(curAltar),false)
        if tmpRatio > 0 then
            ret.output = ret.outputNoAll .."+"..(ret.outputAll-ret.outputNoAll)
        else
            ret.output = ret.outputAll
        end
--        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10270 then
--            ret.stoneNum = 0
--        end
--        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10280 then
--            ret.jtLevel = Language.LV..".0"
--            ret.ifCanUp = true
--        end
        
        return ret
    end,altarSelectChangeEvent)
    
    changeCards(ch.AltarModel:getAltarListInit(ch.AltarModel:getCurAltarSelect()))
    widget:playEffect("playAltar"..ch.AltarModel:getCurAltarSelect(),true)
    
    local curAltar = ch.AltarModel:getCurAltarSelect()
    local data = ch.AltarModel:getAltarByType(curAltar)
    local cs = GameConfig.Altar_levelConfig:getData(data.level)
    local panel = ch.AltarModel:getPanelData(curAltar)
    local curExp,targetExp = panel.exp,panel.exp
    local isFlying = false
     widget:addDataProxy("exp",function(evt)
        return string.format(Language.src_clickhero_view_AltarView_9,panel.exp,cs.exp)
     end)
     
    widget:addDataProxy("expProgress",function(evt)
        return 100*panel.exp/cs.exp 
    end)
    
    widget:listen(ch.AltarModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.AltarModel.dataType.select then
            curAltar = ch.AltarModel:getCurAltarSelect()
            data = ch.AltarModel:getAltarByType(curAltar)
            cs = GameConfig.Altar_levelConfig:getData(data.level)
            panel = ch.AltarModel:getPanelData(curAltar)
            curExp = panel.exp
            targetExp = panel.exp
            if isFlying then
                isFlying = false
            end
            widget:noticeDataChange("exp")
            widget:noticeDataChange("expProgress")
        elseif evt.dataType == ch.AltarModel.dataType.panel
            or evt.dataType == ch.AltarModel.dataType.exp  then
            curAltar = ch.AltarModel:getCurAltarSelect()
            data = ch.AltarModel:getAltarByType(curAltar)
            cs = GameConfig.Altar_levelConfig:getData(data.level)
            panel = ch.AltarModel:getPanelData(curAltar)
            if isFlying then
                targetExp = panel.exp
            else
                curExp = panel.exp
                targetExp = panel.exp
                widget:noticeDataChange("exp")
                widget:noticeDataChange("expProgress")
            end
        end
    end)
    
    local playCount = 0
    widget:addCommond("getStone",function()
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10270 then
            ch.guide:endid(10270)
        end
        isFlying = true
        ch.NetworkController:altarAddExp(ch.AltarModel:getCurAltarSelect())
        ch.AltarModel:getExp(ch.AltarModel:getCurAltarSelect(),ch.AltarModel:getPanelData(ch.AltarModel:getCurAltarSelect()).stoneNum,true)
        ch.NetworkController:altarPanel(ch.AltarModel:getCurAltarSelect())
        ch.RoleResManager:loadEffect("tx_jitanfly")
        local startFlyP = endP
        local progress = widget:getChild("Panel_exp")
        local endFlyP = stoneLayer:convertToNodeSpace(progress:convertToWorldSpace(cc.p(0,0)))
        local ra = ch.AltarModel:getPanelData(ch.AltarModel:getCurAltarSelect()).stoneNum/ch.AltarModel:getAltarByType(ch.AltarModel:getCurAltarSelect()).maxNum
        local count = 5
        playCount = playCount + 1
        for k,v in ipairs(GameConst.ALTAR_FLY_COUNT) do
            if ra <= v.ratio then
                count = v.num
                break
            end 
        end
        playFly(function(index)
                widget:playEffect("collectEffect")
                if isFlying then
                    curExp = curExp + (targetExp - curExp)/(count + 1 - index)
                    widget:noticeDataChange("exp")
                    widget:noticeDataChange("expProgress")
                end
            end,function()
                playCount = playCount - 1
                if playCount == 0 then
                    isFlying = false
                    ch.RoleResManager:releaseEffect("tx_jitanfly")
                end
            end,widget,stoneLayer,startFlyP,endFlyP,count)
    end)
    widget:addCommond("upLevel",function()
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10280 then
--            ch.NetworkController:altarPanel(ch.AltarModel:getCurAltarSelect())
--            widget:playEffect("lvUpEffect")
--            local layer = widget:getChild("Panel_LvupTip")
--            local levelConfig = GameConfig.Altar_levelConfig:getData(ch.AltarModel:getAltarByType(curAltar).level)
--            playLvUpEffect(layer,curAltar,effectRes,levelConfig.ratio/10000)
            ch.guide:endid(10280)
        end
        isFlying = false
        local curAltar = ch.AltarModel:getCurAltarSelect()
        ch.NetworkController:altarUpLevel(curAltar)
        local levelConfig = GameConfig.Altar_levelConfig:getData(ch.AltarModel:getAltarByType(curAltar).level)
        ch.AltarModel:addLevel(curAltar,levelConfig.exp)
        ch.NetworkController:altarPanel(curAltar)
        widget:playEffect("lvUpEffect")
        local layer = widget:getChild("Panel_LvupTip")
        levelConfig = GameConfig.Altar_levelConfig:getData(ch.AltarModel:getAltarByType(curAltar).level)
        local num = levelConfig.ratio/10000 - 1
        if num > 999 then
            num = math.floor(num)
        end
        playLvUpEffect(layer,curAltar,effectRes,num)
--		end    
    end)
    widget:addCommond("close",function()
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10290 then
            ch.guide:endid(10290)
        end
        widget:destory()
    end)
    
    widget:addCommond("select",function(widget,arg)
        local type = ch.AltarModel:getCurAltarSelect()
        if ch.StatisticsModel:getMaxLevel() > GameConst.ALTAR_OPEN_LEVEL[altarOrder[type][tonumber(arg)]] then
            widget:stopEffect("playAltar"..type)
            if arg == "1" then
--                data = ch.AltarModel:getAltarByType(altarOrder[type][1])
--                cs = GameConfig.Altar_levelConfig:getData(data.level)
--                panel = ch.AltarModel:getPanelData(altarOrder[type][1])
                ch.AltarModel:setCurAltarSelect(altarOrder[type][1])
            elseif arg == "2" then
--                data = ch.AltarModel:getAltarByType(altarOrder[type][2])
--                cs = GameConfig.Altar_levelConfig:getData(data.level)
--                panel = ch.AltarModel:getPanelData(altarOrder[type][2])
                ch.AltarModel:setCurAltarSelect(altarOrder[type][2])
            elseif arg == "3" then
--                data = ch.AltarModel:getAltarByType(altarOrder[type][3])
--                cs = GameConfig.Altar_levelConfig:getData(data.level)
--                panel = ch.AltarModel:getPanelData(altarOrder[type][3])
                ch.AltarModel:setCurAltarSelect(altarOrder[type][3])
            end 
            changeCards(ch.AltarModel:getAltarListInit(ch.AltarModel:getCurAltarSelect()))
            ch.NetworkController:altarPanel(ch.AltarModel:getCurAltarSelect())
            widget:playEffect("playAltar"..ch.AltarModel:getCurAltarSelect(),true)
        else
            ch.UIManager:showUpTips(string.format(Language.src_clickhero_view_AltarView_10,altarName[altarOrder[type][tonumber(arg)]],GameConst.ALTAR_OPEN_LEVEL[altarOrder[type][tonumber(arg)]]))
        end
    end)
    
    widget:addCommond("help",function()
        ch.UIManager:showGamePopup("card/W_jt_guize")
    end)
    widget:addCommond("openLog",function()
        ch.NetworkController:altarRobLog()
    end)
    widget:addCommond("buyLimit",function()
        local num = ch.AltarModel:getAltarByType(ch.AltarModel:getCurAltarSelect()).exnum
        ch.UIManager:showMsgBox(2,true,string.format(Language.src_clickhero_view_AltarView_11,GameConst.ALTAR_EXP_LIMIT_ADD_COST[num+1],GameConst.ALTAR_EXP_LIMIT_ADD_BUY+ch.AltarModel:getAltarByType(ch.AltarModel:getCurAltarSelect()).maxNum),function()
            if ch.MoneyModel:getDiamond() >= GameConst.ALTAR_EXP_LIMIT_ADD_COST[num+1] then
                ch.NetworkController:upStoneLimit(ch.AltarModel:getCurAltarSelect())
                ch.MoneyModel:addDiamond(-GameConst.ALTAR_EXP_LIMIT_ADD_COST[num+1])
                ch.AltarModel:addExnum(ch.AltarModel:getCurAltarSelect(),1)
                ch.AltarModel:addStoneLimit(ch.AltarModel:getCurAltarSelect(),GameConst.ALTAR_EXP_LIMIT_ADD_BUY)
            else
                ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
            end
        end,nil,Language.src_clickhero_view_AltarView_12,2)
    end)
    widget:addCommond("rob",function()
        if ch.AltarModel:getRobNum() > 0 then
            ch.NetworkController:altarRobPanel(ch.AltarModel:getCurAltarSelect())
        elseif ch.AltarModel:getResetNum() > 0 then
            ch.UIManager:showMsgBox(2,true,string.format(Language.src_clickhero_view_AltarView_13,GameConst.ALTAR_ROB_COST,GameConst.ALTAR_ROB_ADD),function()
                if ch.MoneyModel:getDiamond() >= GameConst.ALTAR_ROB_COST then
                    ch.NetworkController:altarReset()
                    ch.MoneyModel:addDiamond(-GameConst.ALTAR_ROB_COST)
                    ch.AltarModel:addResetNum(-1)
                    ch.AltarModel:addRobNum(GameConst.ALTAR_ROB_ADD)
                else
                    ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
                end
            end,nil,Language.src_clickhero_view_AltarView_14,2)
        else
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_AltarView_15)
        end
    end)

    widget:addCommond("changePanel",function()
        ch.UIManager:showGamePopup("card/W_card_f_choose",{type=3,altarType=ch.AltarModel:getCurAltarSelect()})
        --结束引导
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10260 then
            ch.guide:endid(10260)
        end
    end)
    widget:addDataProxy("ifCanLog",function(evt)
        for i=1,3 do
            if ch.AltarModel:getAltarByType(i).level >= GameConst.ALTAR_ROB_LEVEL then
                return true
            end
        end
        return false
    end,altarSelectChangeEvent)
    widget:addDataProxy("card1",function(evt)
        return {type = 3,id=1}
    end)
    widget:addDataProxy("card2",function(evt)
        return {type = 3,id=2}
    end)
    widget:addDataProxy("card3",function(evt)
        return {type = 3,id=3}
    end)
    widget:addDataProxy("card4",function(evt)
        return {type = 3,id=4}
    end)
    widget:addDataProxy("card5",function(evt)
        return {type = 3,id=5}
    end)   
    -- 领取引导
    if ch.AltarModel:getPanelData(1) and ch.guide._data["guide10260"] == 1 and ch.guide._data["guide10240"] == 1 
        and (not ch.guide._data["guide10270"] or ch.guide._data["guide10270"] ~= 1) then
        zzy.TimerUtils:setTimeOut(0, function()
            for k,v in pairs(ch.AltarModel:getAltarListInit(1)) do
                produce(v)
            end
            ch.guide:showWait(1.5,function()
                ch.guide:play_guide(10270)
            end)
        end)
    end
    
    -- 掠夺引导
    if ch.AltarModel:getAltarByType(ch.AltarModel:getCurAltarSelect()).level >= GameConst.ALTAR_ROB_LEVEL and ch.guide._data["guide10300"] ~= 1 then
        zzy.TimerUtils:setTimeOut(0, function()
            ch.guide:play_guide(10300)
        end)
    end
    widget:listen(ch.AltarModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.AltarModel.dataType.initList then
            changeCards(ch.AltarModel:getAltarListInit(ch.AltarModel:getCurAltarSelect()))
            if not ch.guide._data["guide10270"] or ch.guide._data["guide10270"] ~= 1 then
                zzy.TimerUtils:setTimeOut(1.5,function()
                    for k,v in pairs(ch.AltarModel:getAltarListInit(ch.AltarModel:getCurAltarSelect())) do
                        produce(v)
                    end
                end)
            end
--            ch.NetworkController:altarPanel(ch.AltarModel:getCurAltarSelect())
        end
    end)
    
    local cutDown
    cutDown =  function()
        for k,v in pairs(ch.AltarModel:getIdProduce()) do
            produce(v)
        end
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
end)


-- 卡牌祭坛阵容单元
zzy.BindManager:addCustomDataBind("card/N_card_jt",function(widget,data)    
    local altarSelectChangeEvent = {}
    altarSelectChangeEvent[ch.AltarModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.AltarModel.dataType.initList or evt.dataType == ch.AltarModel.dataType.select
    end
        
    widget:addDataProxy("cardIcon",function(evt)
        return GameConfig.CardConfig:getData(ch.AltarModel:getMyCardList(ch.AltarModel:getCurAltarSelect())[data.id].id).mini
    end,altarSelectChangeEvent)
    widget:addDataProxy("iconFrame",function(evt)
        return GameConfig.CarduplevelConfig:getData(ch.AltarModel:getMyCardList(ch.AltarModel:getCurAltarSelect())[data.id].l).iconFrame
    end,altarSelectChangeEvent)
    widget:addDataProxy("ifCard",function(evt)
        return ch.AltarModel:getMyCardList(ch.AltarModel:getCurAltarSelect())[data.id].vis
    end,altarSelectChangeEvent)
    widget:addDataProxy("output",function(evt)
        if ch.AltarModel:getMyCardList(ch.AltarModel:getCurAltarSelect())[data.id].vis then
            local output = ch.AltarModel:getOutput(ch.AltarModel:getMyCardList(ch.AltarModel:getCurAltarSelect())[data.id].l)
            return math.floor(output)
--            return math.floor(output*(1+ch.FamiliarModel:getAltarAdd(ch.AltarModel:getCurAltarSelect())))
        else
            return 0
        end
    end,altarSelectChangeEvent)
end)

-- 卡牌祭坛掠夺列表
zzy.BindManager:addCustomDataBind("card/W_jt_lveduo",function(widget,data) 
    if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10300 then
        ch.guide:endid(10300)
    end
    widget:addDataProxy("title",function(evt)
        return altarName[data]
    end)
    
    widget:addDataProxy("robList",function(evt)
        local tmpTable = {}
        for k,v in pairs(ch.AltarModel:getRobPanelData(data)) do
            table.insert(tmpTable,{type=data,value=v})
        end
        return tmpTable
    end)
end)

-- 卡牌掠夺队伍单元（旧）
zzy.BindManager:addCustomDataBind("card/W_jt_lveduounit",function(widget,data)
    local tmpData = data.value
    widget:addCommond("rob",function()
--        ch.UIManager:showGamePopup("card/W_card_f_choose",{type=4,altarType=data.type,userid=data.value.id})
        tmpData.type = 4
        tmpData.userId = tmpData.id
        tmpData.altarType = data.type
        ch.UIManager:showGamePopup("card/W_card_chakan",tmpData)
    end)
    widget:addDataProxy("name",function()
        return Language.INIT_PLAYER_NAME
    end)
    widget:addDataProxy("card1",function(evt)
        return {type = 2,id=1}
    end)
    widget:addDataProxy("card2",function(evt)
        return {type = 2,id=2}
    end)
    widget:addDataProxy("card3",function(evt)
        return {type = 2,id=3}
    end)
    widget:addDataProxy("card4",function(evt)
        return {type = 2,id=4}
    end)
    widget:addDataProxy("card5",function(evt)
        return {type = 2,id=5}
    end)
end)

-- 卡牌掠夺队伍单元
zzy.BindManager:addCustomDataBind("card/W_jt_lveduo_1",function(widget,data)
    local tmpData = data.value
    widget:addCommond("rob",function()
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10310 then
            ch.guide:endid(10310)
        end
        tmpData.type = 4
        tmpData.userId = tmpData.id
        tmpData.altarType = data.type
        ch.AltarModel:setRobWinData("name",ch.CommonFunc:getNameNoSever(tmpData.name))
        ch.UIManager:showGamePopup("card/W_card_chakan",tmpData)
    end)
    widget:addDataProxy("name",function()
        return ch.CommonFunc:getNameNoSever(tmpData.name)
    end)
    
    widget:addDataProxy("titleIcon",function()
        local btn_rob = zzy.CocosExtra.seekNodeByName(widget, "btn_rob")
        if IS_BANHAO then
            INFO("IS_BANHAO")
        else
            INFO("NOT IS_BANHAO")
        end
        
        if IS_BANHAO and btn_rob then
            btn_rob:setTitleText("攻  击")
        end
        
        if type(tmpData.maxLevel) == "string" then
            return ch.UserTitleModel:getTitle(1,tmpData.userId).icon
        else
            return ch.UserTitleModel:getTitle(tmpData.maxLevel-1,tmpData.userId).icon
        end
    end)
    
    widget:addDataProxy("powerNum",function()
        return ch.PetCardModel:getTeamPower(tmpData.cardList)
    end)
    widget:addDataProxy("output",function()
        return ch.AltarModel:getAllOutput(tmpData.cardList)
    end)
end)

-- 掠夺结算界面
zzy.BindManager:addFixedBind("card/W_card_rob_result",function(widget)
    local tmpData = ch.AltarModel:getRobWinData()
    widget:addDataProxy("title",function()
        return Language.src_clickhero_view_AltarView_16
    end)
    widget:addDataProxy("textWin",function()
        return string.format(Language.src_clickhero_view_AltarView_17,ch.CommonFunc:getNameNoSever(tmpData.name))
    end)
    widget:addDataProxy("stoneNum",function()
        return GameConst.ALTAR_EXP_NAME[tmpData.type].. tmpData.num
    end)
    widget:addCommond("ok",function()
        widget:destory()
    end)
end)

-- 掠夺战斗记录
zzy.BindManager:addFixedBind("card/W_jt_zhandoujilu",function(widget)
    widget:addDataProxy("list",function()
        return ch.AltarModel:getRobLogData()
    end)
end)

-- 祭坛掠夺记录单元
zzy.BindManager:addCustomDataBind("card/N_jt_lueduojilu",function(widget,data)
    widget:addDataProxy("icon",function()
        return GameConst.ALTAR_ROB_LOG_DATA[data.ltype].icon
    end)

    widget:addDataProxy("textJitan",function()
        return string.format(GameConst.ALTAR_ROB_LOG_DATA[data.ltype].jitan,altarName[data.aType])
    end)

    widget:addDataProxy("textWin",function()
        return string.format(GameConst.ALTAR_ROB_LOG_DATA[data.ltype].win,ch.CommonFunc:getNameNoSever(data.name))
    end)
    widget:addDataProxy("textGet",function()
        if data.ltype == 1 or data.ltype == 4 then
            return string.format(GameConst.ALTAR_ROB_LOG_DATA[data.ltype].get,GameConst.ALTAR_EXP_NAME[data.aType],data.num)
        else
            return GameConst.ALTAR_ROB_LOG_DATA[data.ltype].get
        end
    end)
    widget:addDataProxy("time",function()
        return "00:00:00"
    end)
    widget:addDataProxy("canBack",function()
        return false
    end)
    widget:addCommond("back",function()
        cclog("反击")
    end)
    widget:addCommond("play",function()
        ch.NetworkController:arenaPlay(data.fty,data.ftime,data.id1,data.id2)
    end)
end)
