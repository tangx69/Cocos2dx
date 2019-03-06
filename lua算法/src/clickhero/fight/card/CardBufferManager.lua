local CardBufferManager = {
    _containers = nil,
    _buffers = nil,
}

function CardBufferManager:init(attBuffer,defBuffer)
    self._buffers = {{},{}}
    self:setContainer(attBuffer,defBuffer)
end

function CardBufferManager:setContainer(attBuffer,defBuffer)
	self._containers = {}
    self._containers[ch.CardFightMap.RoleType.attacker] = {attBuffer}
    self._containers[ch.CardFightMap.RoleType.defender] = {defBuffer}
end

function CardBufferManager:RoundEnd()
	for _,i in pairs(ch.CardFightMap.RoleType) do
	   for id,buffer in pairs(self._buffers[i]) do
	      if not buffer.isNew and buffer.round > 0 then
             buffer.round = buffer.round - 1
             self:changeRoundText(buffer.widget,buffer.round)
          else
             buffer.isNew = nil  
	      end
	      if buffer.round == 0 then
             local pos = 1
             self._containers[i][pos]:removeChild(buffer.widget,true)
             self._buffers[i][id] = nil
          elseif buffer.round == 1 then
             self:startWidgetAction(buffer.widget)
	      end
	   end
	end
end

function CardBufferManager:addBuffer(roleType,id)
    local config = GameConfig.CardskillConfig:getData(id)
    local pos = roleType
    if config.status_obj == 2 then
        for k,v in pairs(ch.CardFightMap.RoleType) do
            if v ~= roleType then
                pos = v
                break
            end
        end
    end
    if self._buffers[pos][id] then
        if self._buffers[pos][id].round >= 0 then
            if self._buffers[pos][id].round <= 1 and
                self._buffers[pos][id].round+config.used_round >1 then
                self:stopWidgetAction(self._buffers[pos][id].widget)
            end
            self._buffers[pos][id].round = self._buffers[pos][id].round + config.used_round
            self:changeRoundText(self._buffers[pos][id].widget,self._buffers[pos][id].round)
        end
    else
        self._buffers[pos][id] = self:createBuffer(config)
        local container = self._containers[pos][1]
        container:pushBackCustomItem(self._buffers[pos][id].widget)
    end
end

function CardBufferManager:Close()
	self._buffers = nil
	self._containers = nil
end

function CardBufferManager:createBuffer(config)
	local buffer = {}
    buffer.isBuffer = config.status_jdg == 1 -- true buffer,false debuffer
    buffer.target = config.status_obj        -- 1为己方，2为对方
    buffer.round = config.used_round
    buffer.isNew = true
    buffer.widget = self:createBufferWidget(config)
    return buffer
end

function CardBufferManager:createBufferWidget(config)
    local image = ccui.ImageView:create("res/icon/"..config.icon,ccui.TextureResType.localType)
    if config.used_round >= 0 then
        local value = math.ceil(config.used_round/2)
        local text
        if config.used_round == 0 or config.used_round == 1 then
            text = ccui.TextAtlas:create("","res/ui/aaui_font/num_yellow.png",16,24,".")
        else
            text = ccui.TextAtlas:create(value,"res/ui/aaui_font/num_yellow.png",16,24,".")
        end
        text:setName("txRound")
        text:setPosition(cc.p(12,35))
        text:setScale(0.8)
        image:addChild(text)
    end
    if config.used_round == 0 then
        self:startWidgetAction(image)
    end
    return image
end

function CardBufferManager:changeRoundText(widget,round)
    local text = widget:getChildByName("txRound")
    if text then
        if round == 0 or round == 1 then
            text:setString("")
        else
            text:setString(math.ceil(round/2))
        end
    end
end

function CardBufferManager:startWidgetAction(widget)
    local seq = cc.Sequence:create(cc.FadeOut:create(0.25),cc.FadeIn:create(0.25),cc.DelayTime:create(0.5))
    local action = cc.RepeatForever:create(seq)
    widget:runAction(action)
    local text = widget:getChildByName("txRound")
    if text then
        text:runAction(action:clone())
    end
end

function CardBufferManager:stopWidgetAction(widget)
    widget:stopAllActions()
    widget:setOpacity(255)
    local text = widget:getChildByName("txRound")
    if text then
        text:stopAllActions()
        text:setOpacity(255)
    end
end

return CardBufferManager