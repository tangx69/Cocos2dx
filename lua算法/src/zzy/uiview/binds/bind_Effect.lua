return function (widget, config)
    local ctrl = nil
    if config.bp1 and config.bp1 ~= "" then
        ctrl = widget:getChild(config.bp1)
    end
    widget:addEffect(config.bp5,ctrl,config.bp2,config.bp3,config.bp4)
end