zzy.BindManager:addCommonCmd("openCsb",function(widget, csb, data)
    if data and string.sub(data, 1, 1) == ":" then
        widget:addDataViewer(string.sub(data, 2), nil, function(realData)
            data = realData
        end)
    end
    ch.UIManager:showGamePopup(csb, data)
    ch.SoundManager:play("click")
end)

zzy.BindManager:addCommonCmd("openCsbOverMain",function(widget, csb, data)
    if data and string.sub(data, 1, 1) == ":" then
        widget:addDataViewer(string.sub(data, 2), nil, function(realData)
            data = realData
        end)
    end
    ch.UIManager:_addPopupOverMain(csb, data)
    ch.SoundManager:play("click")
end)

zzy.BindManager:addCommonCmd("close",function(widget, csb, data)
    widget:destory()
    ch.SoundManager:play("close")
end)

zzy.BindManager:addCommonCmd("popOpen",function(widget, csb, data)
--    ch.UIManager:cleanGamePopupLayer()
    if data and string.sub(data, 1, 1) == ":" then
        widget:addDataViewer(string.sub(data, 2), nil, function(realData)
            data = realData
        end)
    end
    ch.UIManager:showBottomPopup(csb, data)
    ch.SoundManager:play("click")
    
    --结束引导
    if csb == "fuwen/W_FuwenList" then
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10020 then
    		ch.guide:endid(10020)
    	end
    elseif csb == "baowu/W_BaowuList" then
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10050 then
            ch.guide:endid(10050)
        end
    elseif csb == "tuteng/W_TutengList" then
        if ch.guide and ch.guide.obj and ch.guide.obj.id and ch.guide.obj.id == 10080 then
            ch.guide:endid(10080)
        end
    end
end)

zzy.BindManager:addCommonCmd("popClose",function(widget, csb, data)
    ch.UIManager:closeBottomPopup(widget:getCsbStr())
    ch.SoundManager:play("close")
end)

zzy.BindManager:addCommonCmd("popUp",function(widget, csb, data)
    ch.UIManager:BottomUp(widget:getCsbStr())
    ch.SoundManager:play("updown")
end)

zzy.BindManager:addCommonCmd("popDown",function(widget, csb, data)
    ch.UIManager:BottomDown(widget:getCsbStr())
    ch.SoundManager:play("updown")
end)
