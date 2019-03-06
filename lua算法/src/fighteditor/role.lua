local SELECT_ROLE_CHANGE_EVENT = "SELECT_ROLE_CHANGE_EVENT"

local selectRoleName = "R0_nanzhanshi"
local function getSelectRoleName() return selectRoleName end
local function setSelectRoleName(val)
    selectRoleName = val
    zzy.EventManager:dispatchByType(SELECT_ROLE_CHANGE_EVENT)
end

zzy.EventManager:listen(SELECT_ROLE_CHANGE_EVENT, function()
	ch.fightRoleLayer:clearRole()
    ch.fightRoleLayer:addEnemyRole(selectRoleName,0)
end)

zzy.BindManager:addFixedBind("editorPannel_2", function(widget)
    widget:addDataProxy("roleList", function(evt)
        local fullPath = cc.FileUtils:getInstance():fullPathForFilename("res/editor.json")
        local fileList = zzy.FileUtils:getDirFileNames(string.sub(fullPath, 1, string.len(fullPath)-11) .. "role")
        local ret = {}
        for _,f in ipairs(fileList) do
            local arr = zzy.StringUtils:split(f, "[.]")
            if #arr == 2 and (arr[2] == "xml" or arr[2] == "ExportJson") then
                table.insert(ret, {
                    txt = string.sub(arr[1],string.find(arr[1],"_")+1),
--                    txt = zzy.StringUtils:split(arr[1], "_")[2],
                    evt = SELECT_ROLE_CHANGE_EVENT,
                    get = getSelectRoleName,
                    set = setSelectRoleName
                })
            end
        end
        return ret
    end)
    
    local curActionIndex = 0
    local anctionLoop = true
    widget:addCommond("PRE_ACTION", function()
        curActionIndex = curActionIndex - 1
        if curActionIndex < 0 then
            curActionIndex = ch.fightRoleLayer:getNewestAliveEnemy()._roleAni:getAnimation():getMovementCount() - 1
        end
        ch.fightRoleLayer:getNewestAliveEnemy()._roleAni:getAnimation():playWithIndex(curActionIndex, -1, anctionLoop and 1 or 0)
    end)
    widget:addCommond("NEXT_ACTION", function()
        curActionIndex = curActionIndex + 1
        if curActionIndex >= ch.fightRoleLayer:getNewestAliveEnemy()._roleAni:getAnimation():getMovementCount() then
            curActionIndex = 0
        end
        ch.fightRoleLayer:getNewestAliveEnemy()._roleAni:getAnimation():playWithIndex(curActionIndex, -1, anctionLoop and 1 or 0)
    end)
    widget:addCommond("ACTION_LOOP_TRUE", function() anctionLoop = true end)
    widget:addCommond("ACTION_LOOP_FALSE", function() anctionLoop = false end)
    
    local curRoleConfig
    widget:addDataProxy("CUR_ROLE_CONFIG", function()
        local ret = ch.editorConfig:getRoleConfig(selectRoleName)
        curRoleConfig = zzy.TableUtils:copy(ret)
        return ret
    end, {SELECT_ROLE_CHANGE_EVENT=false})
    
    local HCS = widget:createAutoNoticeData("HCS", false)
    local testMove = false
    local drn = widget:getChild("preViewWPos")
    local dn = cc.DrawNode:create()
    widget:listen(zzy.Events.TickEventType, function()
        local role = ch.fightRoleLayer:getNewestAliveEnemy()
        if testMove then
            if not role then return end
            role:setPositionX(role:getPositionX() + curRoleConfig.s / 30)
        end     
        if role then
            role:setScale(tonumber(curRoleConfig.c) or 1)
            local sp = role:getParent():convertToWorldSpace(cc.p(role:getPositionX(),role:getPositionY()))
            dn:setPositionX(drn:convertToNodeSpace(sp).x)
        end
    end)
    widget:addCommond("CRC_W", function(widget, val)
        curRoleConfig.w = tonumber(val) or 0
        testMove = false
        HCS.v = true
    end)
    widget:addCommond("CRC_D", function(widget, val)
        curRoleConfig.d = val
        testMove = false
        HCS.v = true
    end)
    widget:addCommond("CRC_S", function(widget, val)
        curRoleConfig.s = tonumber(val) or 0
        testMove = true
        HCS.v = true
        ch.fightRoleLayer:getNewestAliveEnemy()._roleAni:getAnimation():play("move")
    end)
    widget:addCommond("CRC_C", function(widget, val)
        curRoleConfig.c = tonumber(val) or 1
        testMove = false
        HCS.v = true
--        local role = ch.fightRoleLayer:getMainRole()
--        if not role then return end
--        role:setScale(tonumber(curRoleConfig.c))
        
        --role:setPositionX(role:getPositionX() + curRoleConfig.s / 30)
        --widget:noticeDataChange("CUR_ROLE_CONFIG")
    end)
    widget:addCommond("SRC", function(widget)
        testMove = false
        HCS.v = false
        ch.editorConfig:saveRoleConfig(selectRoleName, curRoleConfig.w, curRoleConfig.s, curRoleConfig.d, curRoleConfig.c)
    end)
    
    
    local PRE_VIEW_W = 0
    
    widget:getChild("preViewWPos"):addChild(dn)
    widget:addDataProxy("PRE_VIEW_W", function() return PRE_VIEW_W end)
    widget:addCommond("PRE_VIEW_W", function(widget, val)
        PRE_VIEW_W = tonumber(val) or 0
        widget:noticeDataChange("PRE_VIEW_W")
        
        dn:clear()
        dn:drawSegment(cc.p(PRE_VIEW_W,0),cc.p(PRE_VIEW_W, 300),1,cc.c4b(1,1,1,1))
        dn:drawSegment(cc.p(-PRE_VIEW_W,0),cc.p(-PRE_VIEW_W, 300),1,cc.c4b(1,1,1,1))
    end)
end)
