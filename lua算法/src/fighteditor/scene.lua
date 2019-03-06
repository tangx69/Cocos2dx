local SELECT_SCENE_CHANGE_EVENT = "SELECT_SCENE_CHANGE_EVENT"

local selectSceneImg
local showSceneChangeAni = false

local function getSelectSceneImg()
    return selectSceneImg
end
local function setSelectSceneImg(val)
    selectSceneImg = val
    zzy.EventManager:dispatchByType(SELECT_SCENE_CHANGE_EVENT)
    ch.fightBackground:showScene(val, showSceneChangeAni and "xxxoooxxx",1)
end


zzy.BindManager:addFixedBind("editorPannel_1", function(widget)
    local autoScrollScene = false
    local currentLookPos = 0
    local lookLeftSpeed = 0
    local lookRightSpeed = 0

    widget:listen(zzy.Events.TickEventType, function(obj, evt)
        if lookLeftSpeed > 0 then
            lookLeftSpeed = lookLeftSpeed + 0.1
            currentLookPos = currentLookPos - lookLeftSpeed
        elseif lookRightSpeed > 0 then
            lookRightSpeed = lookRightSpeed + 0.1
            currentLookPos = currentLookPos + lookRightSpeed
        elseif autoScrollScene then
            currentLookPos = currentLookPos + 5
            return ch.fightBackground:_updateXTo(currentLookPos)
        end

        ch.fightBackground:debugLookTo(currentLookPos)
    end)

    widget:addCommond("SLL", function() lookLeftSpeed = 0.1 end)
    widget:addCommond("USLL", function() lookLeftSpeed = 0 end)
    widget:addCommond("SLR", function() lookRightSpeed = 0.1 end)
    widget:addCommond("USLR", function() lookRightSpeed = 0 end)

    widget:addCommond("ASS", function() autoScrollScene = true end)
    widget:addCommond("UASS", function() autoScrollScene = false end)

    local sceneGlobalConfig = zzy.TableUtils:copy(ch.editorConfig:getSceneGlobalConfig())
    local HCSGC = false
    widget:addDefaultCommond(function(widget, cmd, ...)
        local args = {...}
        if string.sub(cmd, 1, 4) == "CTV_" then
            local vName = string.sub(cmd, 5)
            sceneGlobalConfig[vName] = args[1]
            HCSGC = true
            widget:noticeDataChange("HCSGC")
        end
    end)

    widget:addDataProxy("HCSGC", function()
        return HCSGC
    end)
    
    widget:addCommond("APSGC", function()
        ch.editorConfig:saveSceneGlobalConfig(sceneGlobalConfig)
        
        HCSGC = false
        widget:noticeDataChange("HCSGC")
        widget:noticeDataChange("sceneGlobalConfig")
    end)
    
    widget:addDataProxy("sceneGlobalConfig", function()
        return ch.editorConfig:getSceneGlobalConfig()
    end)

    widget:addDataProxy("sceneImageList", function(evt)
        local fullPath = cc.FileUtils:getInstance():fullPathForFilename("res/editor.json")
        local fileList = zzy.FileUtils:getDirFileNames(string.sub(fullPath, 1, string.len(fullPath)-11) .. "scene")
        local ret = {}
        for _,f in ipairs(fileList) do
            local arr = zzy.StringUtils:split(f, "[.]")
            if #arr == 2 and arr[2] == "png" then
                table.insert(ret, {
                    txt = arr[1],
                    evt = SELECT_SCENE_CHANGE_EVENT,
                    get = getSelectSceneImg,
                    set = setSelectSceneImg
                    })
            end
        end
        return ret
    end)

    local hasUnSaveSceneConfig = false
    local curConfig = nil
    local changeSCUS2True = function()
        if hasUnSaveSceneConfig then return end
        hasUnSaveSceneConfig = true
        widget:noticeDataChange("SCUS")
    end

    local isSelectedDataChangeEvt = {}
    isSelectedDataChangeEvt[SELECT_SCENE_CHANGE_EVENT] = false
    widget:addDataProxy("sceneConfig", function()
        hasUnSaveSceneConfig = false
        local config = ch.editorConfig:getSceneConfig(selectSceneImg)
        curConfig = zzy.TableUtils:copy(config)
        return config
    end,isSelectedDataChangeEvt)

    widget:addDataProxy("SCUS", function()
        return hasUnSaveSceneConfig
    end)

    widget:addCommond("SCCSH", function(widget, v)
        curConfig.sky.h = v
        changeSCUS2True()
    end)
    widget:addCommond("SCCSS", function(widget, v)
        curConfig.sky.s = v
        changeSCUS2True()
    end)
    widget:addCommond("SCCSO", function(widget, v)
        curConfig.sky.o = v
        changeSCUS2True()
    end)
    widget:addCommond("SCCMH", function(widget, v)
        curConfig.mon.h = v
        changeSCUS2True()
    end)
    widget:addCommond("SCCMS", function(widget, v)
        curConfig.mon.s = v
        changeSCUS2True()
    end)
    widget:addCommond("SCCMO", function(widget, v)
        curConfig.mon.o = v
        changeSCUS2True()
    end)
    widget:addCommond("SCCFH", function(widget, v)
        curConfig.frt.h = v
        changeSCUS2True()
    end)
    widget:addCommond("SCCFS", function(widget, v)
        curConfig.frt.s = v
        changeSCUS2True()
    end)
    widget:addCommond("SCCFO", function(widget, v)
        curConfig.frt.o = v
        changeSCUS2True()
    end)

    widget:addCommond("APSCC", function()
        hasUnSaveSceneConfig = false
        widget:noticeDataChange("SCUS")
        ch.editorConfig:saveSceneConfig(selectSceneImg, {curConfig.sky.h,curConfig.sky.s,curConfig.sky.o}, {curConfig.mon.h,curConfig.mon.s,curConfig.mon.o}, {curConfig.frt.h,curConfig.frt.s,curConfig.frt.o})
        zzy.EventManager:dispatchByType(SELECT_SCENE_CHANGE_EVENT)
        ch.fightBackground:showScene(selectSceneImg)
    end)

    widget:addCommond("SSCA", function() showSceneChangeAni = true end)
    widget:addCommond("USSCA", function() showSceneChangeAni = false end)
end)