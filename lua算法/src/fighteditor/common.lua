zzy.BindManager:addCustomDataBind("textBtnItem", function(widget, data)
    widget:addDataProxy("imageName", function()
        return data.txt
    end)

    local isSelectedDataChangeEvt = {}
    isSelectedDataChangeEvt[data.evt] = false
    widget:addDataProxy("isSelected", function()
        return data.get() == data.txt
    end, isSelectedDataChangeEvt)

    widget:addCommond("select", function()
        data.set(data.txt)
    end)

    if not data.get() then
        widget:exeCommond("select")
    end
end)


zzy.BindManager:addFixedBind("fightEditorMain", function(widget)
    ch.fightBackground:debugLook()
    ch.fightRoleLayer:init()
    ch.clickLayer:init()
    ch.goldLayer:init()
    
    widget:addCommond("groundDebug", function()
        ch.fightBackground:debugLook()
    end)
    widget:addCommond("groundUnDebug", function()
        ch.fightBackground:destoryDebugLook()
    end)
    widget:addCommond("roleDebug", function()
        if not ch.fightRoleLayer:getMainRole() then
            ch.fightRoleLayer:addMainRole("R0_nanzhanshi")
        end
        local role = ch.fightRoleLayer:getMainRole()
        local cp = role:getPositionX()
        role:moveAd(cp + 10000, 0)
        ch.fightRoleLayer:clearRole()
    end)
    widget:addCommond("roleUnDebug", function()
        ch.fightRoleLayer:clearRole()
    end)
end)

