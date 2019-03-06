
local doVisibleBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    if ctrl["setVisible"] then
	   widget:addDataViewer(config.bp3,function(data)
           ctrl:setVisible(data)
       end)
	else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
	end
end

local doScaleXBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    if ctrl["setScaleX"] then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setScaleX(data)
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end
end

local doScaleYBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    if ctrl["setScaleY"] then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setScaleY(data)
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end
end

local doScaleBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    if ctrl["setScale"] then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setScale(data)
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end
end

local doColorBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    if ctrl["setColor"] then
        widget:addDataViewer(config.bp3,function(data)
            if data then
                ctrl:setColor(data)
            end
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end
end

local doDirectionBind = function(widget,config)
    local ctrl = widget:getChild(config.bp1)
    if ctrl["setDirection"] then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setDirection(data)
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end
end

local doHeightBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    local width = ctrl:getContentSize().width
    if ctrl.getInnerContainer then
        widget:addDataViewer(config.bp3,function(data)
            local px,py = ctrl:getInnerContainer():getPosition()
            ctrl:setContentSize(cc.size(width,data))
            ctrl:getInnerContainer():setPosition(px, py)
        end)
        
        local cx,cy
        widget:addCacheRefreshFunc(function()
            if not cx or not cy then return end
            widget:setTimeOut(0, function()
                ctrl:getInnerContainer():setPosition(cx, cy)
            end)
        end, function()
            cx,cy = ctrl:getInnerContainer():getPosition()
        end)
    else
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setContentSize(cc.size(width,data))
        end)
    end
end

local doOpacityBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    local name = ctrl:getDescription()
    if ctrl["setOpacity"] then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setOpacity(data)
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end
end

local doTouchEnableBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    local name = ctrl:getDescription()
    if ctrl["setBright"] then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setTouchEnabled(data)
            ctrl:setBright(data)
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end
end

local doImageBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    local name = ctrl:getDescription()
    local func = nil
    if name == "CheckBox" then
        local showImageAsyn
        if config.bp3 then
            widget:addDataViewer(config.bp3,function(data)
                if cc.SpriteFrameCache:getInstance():getSpriteFrame(data) then
                    ctrl:loadTextureBackGround(data,ccui.TextureResType.plistType)
                else
                    showImageAsyn = data
                    cc.Director:getInstance():getTextureCache():addImage(data,function()
                        if showImageAsyn == data and zzy.CocosExtra.isCobjExist(ctrl) then
                            ctrl:loadTextureBackGround(data,ccui.TextureResType.localType)
                        end
                    end)
                end
            end)
        end
    elseif name == "Slider" then
        local showImageAsyn
        if config.bp3 then
            widget:addDataViewer(config.bp3,function(data)
                if cc.SpriteFrameCache:getInstance():getSpriteFrame(data) then
                    ctrl:loadSlidBallTextureNormal(data,ccui.TextureResType.plistType)
                else
                    showImageAsyn = data
                    cc.Director:getInstance():getTextureCache():addImage(data,function()
                        if showImageAsyn == data and zzy.CocosExtra.isCobjExist(ctrl) then
                            ctrl:loadSlidBallTextureNormal(data,ccui.TextureResType.localType)
                        end
                    end)
                end
            end)
        end
    elseif name == "Button" then
        local showImageAsyn
        if config.bp3 then
            widget:addDataViewer(config.bp3,function(data)
                if cc.SpriteFrameCache:getInstance():getSpriteFrame(data) then
                    ctrl:loadTextureNormal(data,ccui.TextureResType.plistType)
                else
                    showImageAsyn = data
                    cc.Director:getInstance():getTextureCache():addImage(data,function()
                        if showImageAsyn == data and zzy.CocosExtra.isCobjExist(ctrl) then
                            ctrl:loadTextureNormal(data,ccui.TextureResType.localType)
                        end
                    end)
                end
            end)
        end
        if config.bp4 then
            widget:addDataViewer(config.bp4,function(data)
                if cc.SpriteFrameCache:getInstance():getSpriteFrame(data) then
                    ctrl:loadTexturePressed(data,ccui.TextureResType.plistType)
                else
                    showImageAsyn = data
                    cc.Director:getInstance():getTextureCache():addImage(data,function()
                        if showImageAsyn == data and zzy.CocosExtra.isCobjExist(ctrl) then
                            ctrl:loadTexturePressed(data,ccui.TextureResType.localType)
                        end
                    end)
                end
            end)
        end
        if config.bp5 and config.bp5 ~= "" then
            widget:addDataViewer(config.bp5,function(data)
                if cc.SpriteFrameCache:getInstance():getSpriteFrame(data) then
                    ctrl:loadTextureDisabled(data,ccui.TextureResType.plistType)
                else
                    showImageAsyn = data
                    cc.Director:getInstance():getTextureCache():addImage(data,function()
                        if showImageAsyn == data and zzy.CocosExtra.isCobjExist(ctrl) then
                            ctrl:loadTextureDisabled(data,ccui.TextureResType.localType)
                        end
                    end)
                end
            end)
        end
    else
        if ctrl.setSpriteFrame then  --Sprite
            func = function(data,type)
                if type == ccui.TextureResType.plistType then
                    ctrl:setSpriteFrame(data)
                else
                    local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(data)
                    ctrl:setTexture(texture)
                    ctrl:setTextureRect(cc.rect(0,0,texture:getPixelsWide(),texture:getPixelsHigh()))
                end
            end
        elseif ctrl.setBackGroundImage then  --ScrollView, ListView, PageView, Layout
            func = function(data,type)
                ctrl:setBackGroundImage(data,type)
            end
        elseif name == "ImageView" then
            func = function(data,type)
                if data then
                    ctrl:loadTexture(data,type)
                end
            end
        else
            error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
        end
    
        local showImageAsynFlag
        widget:addDataViewer(config.bp3,function(data)
            --if config.ui == "MainScreen/N_BTNSkill" then
            --    INFO("XXXXX")
            --end
            
            if data == nil or data == "" then return end
            if cc.SpriteFrameCache:getInstance():getSpriteFrame(data) then
                func(data,ccui.TextureResType.plistType)
            else
                showImageAsynFlag = data
                cc.Director:getInstance():getTextureCache():addImage(data,function()
                    if showImageAsynFlag == data and zzy.CocosExtra.isCobjExist(ctrl) then
                        func(data,ccui.TextureResType.localType)
                    end
                end)
            end
        end)
    end
end

local doTextBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    local name = ctrl:getDescription()
    if name == "Text" or name == "TextAtlas" or name == "TextField" or name == "Label" or name == "TextBMFont" then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setString(data)
        end)
    elseif name == "Button" then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setTitleText(data)
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end    
end

local doFontColorBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    local name = ctrl:getDescription()
    if name == "Text" or name == "TextField" then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setTextColor(data)
        end)
    elseif name == "Button" then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setTitleColor(data)
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end    
end

local doSelectBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    local name = ctrl:getDescription()
    if name == "CheckBox" then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setSelected(data)
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end  
end

local doProgressBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    local name = ctrl:getDescription()
    if name == "LoadingBar" or name == "Slider" then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:setPercent(data)
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end  
end

local doIndexBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    local name = ctrl:getDescription()
    if name == "PageView" then
        widget:addDataViewer(config.bp3,function(data)
            ctrl:scrollToPage(data)
        end)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end  
end


local compareTable = function(oldTable,newTable)
    local result ={add = {},remove = {},move = {}}
    if oldTable == nil and newTable ~= nil then
        for k,v in ipairs(newTable) do
            table.insert(result.add,{index = k,value = v}) 
        end
    elseif oldTable ~= nil and newTable == nil then
        for k,v in ipairs(oldTable) do
            table.insert(result.remove,{index = k,value = v}) 
        end
    elseif oldTable ~= nil and newTable ~= nil then
        if json.encode(oldTable) == json.encode(newTable) then return result end
        local oldJsonTable,newJsonTable = {},{}
        for k,v in ipairs(oldTable) do
            oldJsonTable[k] = json.encode(v)
        end
        for k,v in ipairs(newTable) do
            newJsonTable[k] = {realIndex = k, value = json.encode(v)}
        end
        local removeCount = 0
        for oldK,oldV in ipairs(oldJsonTable) do
            local needRemove = true
            for newK,newV in ipairs(newJsonTable) do
                if oldV == newV.value then
                    if oldK - removeCount ~= newK then
                        table.insert(result.move,{oldIndex = oldK,newIndex = newV.realIndex,value=newTable[newV.realIndex]})
                    end
                    removeCount = removeCount + 1
                    table.remove(newJsonTable,newK)
                    needRemove = false
                    break
                end
            end
            if needRemove then
                table.insert(result.remove,{index = oldK,value = oldTable[oldK]})
                removeCount = removeCount + 1
            end
        end
        for newK,newV in pairs(newJsonTable) do
            table.insert(result.add,{index = newV.realIndex,value = newTable[newV.realIndex]})
        end
    end
    return result
end

local doItemsBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    local name = ctrl:getDescription()
    local lastData = nil
    local removeItem
    local addItem
    if name == "ListView" then
        removeItem = function(index)
            local item = ctrl:getItem(index-1)
            item:destory()
            ctrl:removeItem(index-1)
        end
        addItem = function(item,index)
            ctrl:insertCustomItem(item,index-1)
            item:setAnchorPoint(0.5,0.5)
        end
    elseif name == "PageView" then
        removeItem = function(index)
            local item =  ctrl:getPage(index-1)
            item:destory()
            ctrl:removePageAtIndex(index-1)
        end
        addItem = function(item,index)
            local layout = ccui.Layout:create()
            layout:setContentSize(ctrl:getContentSize())
            layout:addChild(item)
            layout.destory = function()
                item:destory()
            end
            ctrl:insertPage(layout,index-1)
        end
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end
    local nodes = {}
    for i= 4,11 do
        local csb = config["bp"..i]
        if csb  and csb ~= "" then
            local path = zzy.uiViewBase.DEFAULT_CSB_PATH_BASE
            local w = cc.CSLoader:createNode(path..csb..".csb", path)
            w:retain()
            nodes[csb] = w
        else	
            break
        end 
    end
    widget:addDataViewer(config.bp3,function(data)
        if not data or type(data) ~= "table" then
            error(string.format("页面 %s 内的控件 %s 绑定的数据类型不正确,变量名:%s",config.ui,config.bp1,config.bp3)) 
        end
        local result = compareTable(lastData,data)
        local removeList = {}
        local addList = {}
        local needRelease = {}
        for k, v in ipairs(result.move) do
            local item = ctrl:getItem(v.oldIndex - 1)
            item:retain()
            table.insert(removeList,{index = v.oldIndex, isRemove = false})
            table.insert(addList,{index = v.newIndex,wg = item})
            table.insert(needRelease,item)
        end
        for k, v in ipairs(result.remove) do
            table.insert(removeList,{index = v.index, isRemove = true})
        end
        for k,v in ipairs(result.add) do
            local item = nil
            if type(v.value) == "table" and v.value.isMultiple then
                local index = v.value.index or 1
                index = "bp" .. tostring(index + 3)
                local w = nodes[config[index]]:clone()
                item = widget:create(config[index],v.value.value,w)
            else
                local w = nodes[config.bp4]:clone()
                item = widget:create(config.bp4,v.value,w)
            end
            table.insert(addList,{index = v.index,wg = item})
        end
        table.sort(removeList,function(v1,v2)
            return v2.index < v1.index
        end)
        for k,v in ipairs(removeList) do
            if v.isRemove then
                removeItem(v.index)
            else
                ctrl:removeItem(v.index - 1)
            end
        end
        table.sort(addList,function(v1,v2)
            return v2.index > v1.index
        end)
        for k,v in ipairs(addList) do
            addItem(v.wg,v.index)
        end
        for k, v in ipairs(needRelease) do
            v:release()
        end
        lastData = data
        if data.autoScrollDown and #result.add > 0 then
            widget:setTimeOut(0, function()
                widget:setTimeOut(0, function()
                    ctrl:scrollToBottom(0.5, true)
                end)
            end)
        end
    end)
    local close = widget.destory
    widget.destory = function(self,cleanView)
        if not widget._cache then
            for k,v in pairs(nodes) do
                v:release()
            end
        end
        close(self,cleanView)
    end
end

local doCsbBind = function(widget, config)
	local child = widget:getChild(config.bp1)
--    widget:create(config.bp4, tonumber(config.bp3) or config.bp3, child)
    if tonumber(config.bp3) then
        widget:create(config.bp4, tonumber(config.bp3), child)
    elseif config.bp5 == "1" then
        widget:create(config.bp4,config.bp3, child)
    else
        widget:create(config.bp4, widget:getDataProxy(config.bp3).tempData, child)
    end 
--	local info = widget:getDataProxy(config.bp3)
--    if not info or not info.tempData then
--        error(string.format("csb绑定，页面%s的控件%s对应的绑定数据%s为空",config.ui,config.bp1,config.bp3))
--    end
--    if type(info.tempData) ~= "table" then
--        error(string.format("csb绑定，页面%s的控件%s获取的绑定数据%s不是table类型",config.ui,config.bp1,config.bp3))
--    end
--	if not info then
--        error(string.format("Csb绑定,页面 %s 内的控件 %s 没有添加 %s 的数据代理",config.ui,config.bp1,config.bp3))
--	end
--    local bindConfig = GameConfig.UiConfig:getTable1(config.bp4) or GameConfig.EditoruiConfig:getTable1(config.bp4)
--    if not bindConfig then 
--        error("Csb绑定，配置表内无对应的绑定数据，控件名："..config.bp1.."对应的Csb："..config.bp4)
--    end
--	zzy.BindManager:addFixedBind(config.bp4,function(widget)
--        for _, c in pairs(bindConfig) do
--            if c.bind == "Data" then
--                if info.tempData[c.bp3] == nil then
--                    cclog("警告:Csb绑定，页面%s的控件%s的绑定数据%s里的%s数据为空",config.ui,config.bp1,config.bp3,c.bp3)
--                end
--                if c.bp2 ~= "Csb" then
--                    widget:addDataProxy(c.bp3, function(evt)
--                        return info.tempData[c.bp3]
--                    end)
--                else
--                    widget:addGroupDataProxy(c.bp3, function(evt)
--                        return info.tempData[c.bp3]
--                    end)
--                end
--            elseif c.bind == "Touch" then
--                if c.bp2 ~= "" and info.tempData[c.bp2] then
--                    widget:addCommond(c.bp2,info.tempData[c.bp2])
--                end
--                if c.bp3 ~= "" and info.tempData[c.bp3] then
--                    widget:addCommond(c.bp3,info.tempData[c.bp3])
--                end
--            end
--        end
--	end)
--	child = widget:create(config.bp4,nil,child)
--	local noticeChange = function()
--		for _, c in pairs(bindConfig) do
--		   if c.bind == "Data" then
--		      if not child.noticeDataChange then
--                 error(config.ui .."  "..config.bp1 .."  ".. config.bp3)
--		      end
--              child:noticeDataChange(c.bp3)
--		   end
--		end
--	end
--    table.insert(info.vufs, noticeChange)
--    for eventType, func in pairs(info.effectEvt or {}) do
--        widget:listen(eventType, function(obj, evt)
--            if not func or func(evt) then
--                local newData = info.getFunc(evt)
--                if newData ~= info.tempData then
--                    info.tempData = newData
--                    noticeChange()
--                end
--            end
--        end)
--    end
end

-- 属于增量绑定，即y值在原有基础上加上信的值
local doPositionYBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    widget:addDataViewer(config.bp3,function(data)
        local y = ctrl:getPositionY()
        ctrl:setPositionY(y + data)
    end)
end

-- 图片变灰
local doGrayBind = function(widget, config)
    local ctrl = widget:getChild(config.bp1)
    local name = ctrl:getDescription()
    
    widget:addDataViewer(config.bp3,function(data)
        local vertDefaultSource = "\n"..
            "attribute vec4 a_position; \n" ..
            "attribute vec2 a_texCoord; \n" ..
            "attribute vec4 a_color; \n"..                                                    
            "#ifdef GL_ES  \n"..
            "varying lowp vec4 v_fragmentColor;\n"..
            "varying mediump vec2 v_texCoord;\n"..
            "#else                      \n" ..
            "varying vec4 v_fragmentColor; \n" ..
            "varying vec2 v_texCoord;  \n"..
            "#endif    \n"..
            "void main() \n"..
            "{\n" ..
            "gl_Position = CC_PMatrix * a_position; \n"..
            "v_fragmentColor = a_color;\n"..
            "v_texCoord = a_texCoord;\n"..
            "}"
        local pszFragSource = "#ifdef GL_ES \n" ..
            "precision mediump float; \n" ..
            "#endif \n" ..
            "varying vec4 v_fragmentColor; \n" ..
            "varying vec2 v_texCoord; \n" ..
            "void main(void) \n" ..
            "{ \n" ..
            "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
            "gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b); \n"..
            "gl_FragColor.w = c.w; \n"..
            "}"
        local pProgram
        if data then 
            pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
            pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
            pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
            pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
            pProgram:link()
            pProgram:updateUniforms()
            
            if name == "ImageView" then
                ctrl:getVirtualRenderer():getSprite():setGLProgram(pProgram)
            elseif name == "Scale9Sprite" then
                ctrl:getSprite():setGLProgram(pProgram)
            elseif name == "Sprite" then
                ctrl:setGLProgram(pProgram)
            end
        else
            if name == "ImageView" then
                ctrl:getVirtualRenderer():getSprite():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName("ShaderPositionTextureColor_noMVP"))
                
            elseif name == "Scale9Sprite" then
                ctrl:getSprite():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName("ShaderPositionTextureColor_noMVP"))
            elseif name == "Sprite" then
                ctrl:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName("ShaderPositionTextureColor_noMVP"))
            end
            
--            if name == "ImageView" then
--                ctrl:getVirtualRenderer():getSprite():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram(cc.SHADER_POSITION_TEXTURE_COLOR)))
--            elseif name == "Scale9Sprite" then
--            ctrl:getSprite():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram(cc.SHADER_POSITION_TEXTURE_COLOR)))
--            elseif name == "Sprite" then
--                ctrl:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram(cc.SHADER_POSITION_TEXTURE_COLOR)))   
--            end
        end
    end)
end

return function (widget, config)
    if config.bp2 == "Visible" then
        doVisibleBind(widget,config)
    elseif config.bp2 == "Opacity" then
        doOpacityBind(widget,config)
    elseif config.bp2 == "TouchEnable" then
        doTouchEnableBind(widget,config)
    elseif config.bp2 == "Image" then
        doImageBind(widget,config)
    elseif config.bp2 == "Text" then
        doTextBind(widget,config)
    elseif config.bp2 == "FontColor" then
        doFontColorBind(widget,config)
    elseif config.bp2 == "Select" then
        doSelectBind(widget,config)
    elseif config.bp2 == "Progress" then
        doProgressBind(widget,config)
    elseif config.bp2 == "Items" then
        doItemsBind(widget,config)
    elseif config.bp2 == "Direction" then
        doDirectionBind(widget,config)
    elseif config.bp2 == "Height" then
        doHeightBind(widget,config)
    elseif config.bp2 == "ScaleX" then
        doScaleXBind(widget,config)
    elseif config.bp2 == "ScaleY" then
        doScaleYBind(widget,config)
    elseif config.bp2 == "Scale" then
        doScaleBind(widget,config)
    elseif config.bp2 == "Color" then
        doColorBind(widget,config)
    elseif config.bp2 == "Index" then
        doIndexBind(widget,config)
    elseif config.bp2 == "Csb" then
        doCsbBind(widget,config)
    elseif config.bp2 == "PositionY" then
        doPositionYBind(widget,config)
    elseif config.bp2 == "Gray" then
        doGrayBind(widget,config)
    else
        error(string.format("页面  %s 内的控件  %s 没有 %s 的 Data绑定",config.ui,config.bp1,config.bp2))
    end
end