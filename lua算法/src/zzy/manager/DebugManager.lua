local DebugManager = {}

local config = {
    port = 6003,
    logCacheCount = 10
}

local client = {}
local clientCount = 0
local logCache = {}
local socket  = nil
local server = nil

--function DebugManager:socket_send(conn,data)
--    local n,err,len
--    local conn_str=nil
--    if conn then
--        n,err,len = conn:send(data)
--        if not n then
--            for str,con in pairs(client) do
--                if con == conn then
--                    conn_str = str
--                end
--            end
--            if conn_str then
--                client.remove(conn_str,conn)
--            end
--            conn:close()
--            cclog("debug client send fail:"+err)
--        end
--    end
--end

function DebugManager:init()
    -- 重载cclog
    local _cclog = cclog
    cclog = function(...)
        _cclog(...)

        local args = {...}
        args[1] = tostring(args[1])
        local log = "[" .. os.date() .. "]  " .. string.format(unpack(args))
        if client and clientCount > 0 then
            for str,user in pairs(client) do
                if user then
                    local len,err = user:send(log .. "\n")
                    if not len then
                        user:close()
                        client[str] = nil
                        cclog("debug client[".. str .. "] send fail:" .. err)
                    end
                end
            end
        end
        table.insert(logCache, log)
        if table.maxn(logCache) > config.logCacheCount then
            table.remove(logCache, 1)
        end
    end

    -- 启动socket监听
    socket = require "socket"
    server = socket.bind("*", config.port)
    local i,p
    if server then
        i,p = server:getsockname()
        server:settimeout(0)
    end
    
    if server and i then
        cclog("DebugManager Inited! Waiting for connection ...  " .. i .. ":" .. p)
    else
        if p then cclog(p) end
        return cclog("DebugManager Inited failed!")
    end

    -- 帧频处理消息
    zzy.EventManager:listen(zzy.Events.TickEventType, function()
        -- 接受新连接
        local c = server:accept()
        if c then
            c:send("<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\""..config.port.."\" /></cross-domain-policy>\0")
            clientCount = clientCount + 1
            local clientStr = c:getpeername() .. "_" .. clientCount
            cclog("CommondLine connected : " .. clientStr)
            client[clientStr] = c
            c:settimeout(0)
            for n,log in pairs(logCache) do
                c:send(log .. "\n")
            end
        end
        -- 接收消息
        for str,user in pairs(client) do
            local l, e = user:receive("*l")
            if l then
                cclog(str .. ":" .. l)
                self:onCmd(l)
            end
        end
    end)
end

local clientDebugCommonds = {}

local clientSyncCommonds = {}


function DebugManager:onCmd(cmd)
    local cmdHead = cmd
    local cmdParam = ""
    local index = string.find(cmd, "|")
    if index then
        cmdHead = string.sub(cmd, 1, index-1)
        cmdParam = string.sub(cmd, index+1)
    end
    if clientDebugCommonds[cmdHead] then
        clientDebugCommonds[cmdHead].onCmd(cmdParam)
        return
    end

    if string.sub(cmd, 1, 2) == ">>" then
        local c2sevt = zzy.Events:createC2SEvent()
        if string.sub(cmd,1,3) == ">>>" then
            c2sevt.doCompress = true
            c2sevt.cmd = string.sub(cmd, 4)
        else
            c2sevt.doCompress = false
            c2sevt.cmd = string.sub(cmd, 3)
        end
        zzy.EventManager:dispatch(c2sevt)

        if index then
            local evtKey = string.sub(cmd, 3, index - 1)
            if c2sevt.doCompress then
                evtKey = string.sub(evtKey, 2)
            end
            if clientSyncCommonds[evtKey] then
                local data = zzy.StringUtils:splitToTable(string.sub(cmd, index + 1))
                clientSyncCommonds[evtKey](data)
                cclog("client auto sync")
            end
        elseif clientSyncCommonds[string.sub(cmd,3)] then
            clientSyncCommonds[string.sub(cmd,3)]()
        end
    elseif string.sub(cmd, 1, 2) == "<<" then
--        zzy.NetManager:getInstance():_onData(string.sub(cmd, 3))
    else
        local evt = json.decode(cmd)
        zzy.EventManager:dispatch(evt)
    end
end

function DebugManager:addClientDebugCommond(cmdName, desc, onCmd)
    clientDebugCommonds[cmdName] = {
        desc = desc,
        onCmd = onCmd
    }
end

function DebugManager:addClientSyncCommond(cmdName, syncFunc)
    clientSyncCommonds[cmdName] = syncFunc
end

function DebugManager:clean()
    for str,user in pairs(client) do
        user:close()
    end
    client = {}
    if server then
        server:close()
    end
    clientDebugCommonds = {}
    clientSyncCommonds = {}
    clientCount = 0
    cclog("DebugManager clean")
end

-- 帮助命令
clientDebugCommonds.help = {
    desc = "显示客户端命令",
    onCmd = function(cmd)
        for key, var in pairs(clientDebugCommonds) do
            cclog("%s : %s", key, var.desc)
        end
    end
}

-- 显示内存纹理
clientDebugCommonds.showTexture = {
    desc = "显示缓存纹理 showTexture|i=ui 不显示ui占用 showTexture|o=ani 只显示ani占用",
    onCmd = function(cmd)
        local opt = zzy.StringUtils:splitToTable(cmd)
        local arr = zzy.StringUtils:split(cc.Director:getInstance():getTextureCache():getCachedTextureInfo(), "\n")
        local ret = {}
        for i = 1,#arr-2 do
            local p = true
            if opt.i then
                local s,e = string.find(arr[i], opt.i)
                p = e == nil
            elseif opt.o then
                local s,e = string.find(arr[i], opt.o)
                p = e ~= nil
            end
            if p then
                arr[i] = string.gsub(arr[i], ".+/", "")
                arr[i] = string.gsub(arr[i], "\"", "")
                table.insert(ret, arr[i])
            end
        end
        table.sort(ret)
        local retStr = ""
        for i = 1,#ret do
            retStr = retStr .. "\n" .. ret[i]
        end
        cclog(retStr)
        cclog(arr[#arr-1])
    end
}

-- 执行一段脚本
clientDebugCommonds.run = {
    desc = [[执行一段脚本，使用\n进行换行；示例： run|cclog("line1")\ncclog("line2")]],
    onCmd = function(cmd)
        cmd = string.gsub(cmd, "\\n", "\n")
        zzy.cUtils.doString(cmd)
    end
}

-- 执行一段脚本
clientDebugCommonds.writetimeout = {
    desc = "输出超时表",
    onCmd = function(cmd)
        zzy.NetManager:getInstance():writeTimeoutCmd()
    end
}

-- 执行一段脚本
clientDebugCommonds.gettimeout = {
    desc = "显示超时表",
    onCmd = function(cmd)
        cclog(zzy.NetManager:getInstance():getTimeoutCmd())
    end
}

return DebugManager
