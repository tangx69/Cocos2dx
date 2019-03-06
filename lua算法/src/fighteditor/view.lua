local SELECT_ADD_ROLE_CHANGE_EVENT = "SELECT_ADD_ROLE_CHANGE_EVENT"

local selectRoleName = "R0_nanzhanshi"
local function getSelectRoleName() return selectRoleName end
local function setSelectRoleName(val)
    selectRoleName = val
    zzy.EventManager:dispatchByType(SELECT_ADD_ROLE_CHANGE_EVENT)
end

local mainRoleGoLeft = true
local mainRoleGoRight = true
useRoleAI = false

local oldMainAi = ch.fightRoleAI.mainDefault

ch.fightRoleAI.mainDefault = function(role)
    if not useRoleAI then
        local cp = role:getPositionX()
        if mainRoleGoLeft then
            role:moveAd(cp - 10000, 0)
        elseif mainRoleGoRight then
            role:moveAd(cp + 10000, 0)
        else
            role:moveAd(cp, 0)
        end
    else
        oldMainAi(role)
    end
end

zzy.BindManager:addFixedBind("editorPannel_3", function(widget)
    widget:addDataProxy("roleList", function(evt)
        local fullPath = cc.FileUtils:getInstance():fullPathForFilename("res/editor.json")
        local fileList = zzy.FileUtils:getDirFileNames(string.sub(fullPath, 1, string.len(fullPath)-11) .. "role")
        local ret = {}
        for _,f in ipairs(fileList) do
            local arr = zzy.StringUtils:split(f, "[.]")
            if #arr == 2 and (arr[2] == "xml" or arr[2] == "ExportJson") then
                table.insert(ret, {
                    txt = string.sub(arr[1],string.find(arr[1],"_")+1),
                    evt = SELECT_ADD_ROLE_CHANGE_EVENT,
                    get = getSelectRoleName,
                    set = setSelectRoleName
                })
            end
        end
        return ret
    end)

    
    local dps = widget:createAutoNoticeData("dps")
    local dpsRefresh
    dpsRefresh = function()
        dps.v = ch.NumberHelper:toString(ch.fightRoleLayer:getDps())
        widget:setTimeOut(1, dpsRefresh)
    end
    dpsRefresh()

--    widget:addCommond("switchMainRole", function() ch.fightRoleLayer:addMainRole(selectRoleName) end)
    widget:addCommond("switchMainRole", function() ch.fightRoleLayer:changeMainRole(selectRoleName,ch.fightRole.roleType.mainRole) end)
    widget:addCommond("addGuai", function() ch.fightRoleLayer:addEnemyRole(selectRoleName) end)

    widget:addCommond("goleft", function(widget, v)
        mainRoleGoLeft = v == "1"
    end)
    widget:addCommond("goright", function(widget, v)
        mainRoleGoRight = v == "1"
    end)
    widget:addCommond("auto", function(widget, v)
        useRoleAI = v == "1"
    end)
    
    widget:addCommond("doskill", function(widget, v)
        local role = ch.fightRoleLayer:getMainRole()
        if role then
            package.loaded["res/config/GameConst"] = nil
            GameConst = require("res/config/GameConst")
            role:attack(tonumber(v))
        end
    end)
end)