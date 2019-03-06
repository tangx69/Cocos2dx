---
-- @module NetManager
local NetManager = {
    stateChangeEventType = "EVENT_NETMANAGER_STATE_CHANGE",--{state}
    loginStr = "",
    _conn = nil,
    _working = false,
    _isWaiting = false,
    _lastCheckTime = 0,--上一次检测服务器下行的时间
    _orderList=nil,--发送给服务器并且没有接收到反馈的指令序列
    _ignoreOrderList={rk_get = 1,msg_panel = 1,wp_report=1,wp_addrep=1,
        wp_member=1,wp_rank=1,wp_guild=1,tf_member=1,time_dis=1,say_s =1},--不需要等待服务器下行的指令列表（即使超时也不报错 排行榜）
    _orderNeedReceive={totem_rf = 1,totem_get = 1,totem_up = 1,
        dj_trans = 1, dj_get = 1,dj_getNum=1,dj_transNum=1,
        wp_start = 1,wp_reward =1,
        rk_player = 1,
        gift_act =1,
        tf_level=1,
        shop_buy=1,shop_firstpay=1,
        autofight_cancel =1,autofight_over = 1,autofight_see =1,autofight_jump=1,autofight_start=1,
        cname_cn=1,
        guild_changeN=1,guild_build=1,guild_call=1,
        task_rf=1,
        gk_gbkill =1,
        buylimit_buy=1,
        guild_sign = 1,guild_getCard=1,guild_giveCard=1,guild_demandCard=1,
        arena_panel=1,arena_reset=1,arena_pk=1,arena_pkLog=1,arena_get=1,
        cfb_fight = 1,cfb_lq = 1,cfb_reset = 1,cfb_buy = 1,cfb_ft = 1,
        altar_reset=1,altar_upStoneLimit=1,altar_robLog=1,altar_robPanel=1,
        mine_pData=1,mine_attack = 1,mine_occupy=1,mine_occAdd=1,
        randomShop_arenaShop = 1,randomShop_arenaBuy=1,randomShop_blackShop=1,randomShop_blackBuy=1,
        holiday_nsbuy=1,holiday_nsref=1,holiday_nsused=1,holiday_dhMoney=1,holiday_zszp=1,holiday_mcsf=1,
        holiday_get=1,holiday_zp = 1,holiday_redbag=1,holiday_czxl=1,holiday_xhfl=1,holiday_xycxy=1,holiday_hygg=1,
        gw_open = 1,gw_fight = 1,gw_groupChg=1,gw_apply=1,gw_pointTS=1,gw_rewardPanel=1,
        gw_getR=1,gw_getDayR=1,gw_cityDetail=1,gw_rank=1,gw_curRank=1,gw_gatherCD=1},--需要服务器返回的指令序列(显示等待界面 没有收到指令下行前禁止点击 如：totem_up = 1)
    _showError=false,
    _reconnec_times=0,--当前重连次数
    _max_reconnec_times=0,--最大重连次数
    _state={ CONNECTING=0, CONNECTED = 1, CONNECT_SUCCESS = 2
        , SOCKET_ERROR = 3, CONNECTFAIL = 4, RECONNECT_SUCCESS = 5,
        RECONNECT_FAIL = 6, SERVER_CLOSE = 7},
    _lastNetState=-1,--上一次的网络状态 检测网络状态是否改变
    --_sendFailed={}--发送失败的指令列表
}
NetManager.__index = NetManager
local instance = nil
local loaded = false 
local cacheS2CEvents = {}

---
--@field [parent=#NetManager] Socket#Socket _conn

---
--@field [parent=#NetManager] #string stateChangeEventType


---
-- 获取单例
-- @function [parent=#NetManager] getInstance
-- @param self
-- @return #NetManager ret
function NetManager:getInstance()
    if instance == nil then
        instance = NetManager:_new()
    end
    return instance
end
---
-- 断开连接
-- @function [parent=#NetManager] disconnect
-- @param clearPool 
-- @param self
function NetManager:disconnect(clearPool)
    ch.UIManager:showWaiting(false,true)
    if instance then
        instance._working = false
        if clearPool then
             instance._orderList = {}
        end
        if self._conn then
            self._conn:disconnect()
        end
    end
end
---
-- 删除实例
-- @function [parent=#NetManager] destoryInstance
-- @param self
function NetManager:destoryInstance()
    if instance then
        instance._conn:release()
        instance._working = false
        instance._conn = nil
        zzy.EventManager:unListen(instance._tickELI)
        zzy.EventManager:unListen(instance._c2sELI)
        instance = nil
    end
end

---
-- 私有构造函数
-- @function [parent=#NetManager] _new
-- @param self
-- @return #NetManager ret
function NetManager:_new(o)
    o = o or {}
    setmetatable(o, self)

if not ADAPTER then
    o._conn = zzy.Socket:new(function(state) -- tgx
        o:_onState(state)
    end,function(cmd)
        o:_onData(cmd)
    end)
else
    o._conn = zzy.Socket:getInstance() -- tgx
    local ipV6First = IS_IN_REVIEW and (not luaj)
    o._conn:init(ipV6First,
    function(state)-- tgx
        o:_onState(state)
    end,
    function(cmd)
        o:_onData(cmd)
    end)
	
	o._conn:hasHead(true)
	
    --local scene = cc.Director:getInstance():getRunningScene() -- tgx
    --scene:addChild(o._conn) -- tgx
    o._conn:retain()
end

    o._orderList={}
    -- 注册帧频事件监听
    o._tickELI = zzy.EventManager:listen(zzy.Events.TickEventType,o._onTick,nil,o,false)
    -- 注册向服务器发包事件监听
    o._c2sELI = zzy.EventManager:listen(zzy.Events.C2SEventType,o._onC2S,nil,o,false)
    
    o._loadedELI = zzy.EventManager:listen(ch.GameLoaderModel.loadCompletedEvent,function()
        loaded = true
        for _,evt in ipairs(cacheS2CEvents) do
            zzy.EventManager:dispatch(evt)
        end
        zzy.EventManager:unListen(o._loadedELI)
        cacheS2CEvents = nil
    end)
    
    return o
end

---
-- 初始化
-- @function [parent=#NetManager] init
-- @param self
-- @param #string host
-- @param #int port
function NetManager:init(host, port)
    -- 开始连接服务器
    self._conn:connect(host,port)
    INFO("[connect]".."host:"..host.."  port:".. port)
    
	if true then
        local parent = self._conn:getParent()
        if parent == nil then
            self._conn:removeFromParent()
            self._conn:release()
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(self._conn)
        end
	else
	    cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		   self._conn:update(0.2)
		end, 0.2, false)
	end
end

---
-- 是否正在工作
-- @function [parent=#NetManager] isWorking
-- @param self
-- @return #bool ret
function NetManager:isWorking()
    return self._working
end

---
-- 前后台切换
-- @function [parent=#NetManager] switchBackGround
-- @param self
-- @param #bool back
function NetManager:switchBackGround(back)
    if self._working and self._conn then
        if back then
            self._conn:handleOnPause()
        else
            self._conn:handleOnResume()
        end
    end
end

function NetManager:_onData(cmd)
    if cmd == nil or cmd == "" then
        return
    end
    
	local one_msg_len = 800
    local isFirst = true
    local function logsplite(str, isSub)
        local len = string.len(str)
        if len > one_msg_len then
            if isFirst then
                INFO("[S2C]%s", string.sub(str, 1, one_msg_len))
                isFirst = false
            else
                INFO("%s", string.sub(str, 1, one_msg_len))
            end
            logsplite(string.sub(str, one_msg_len+1, len))
        else
            if isFirst then
                INFO("[S2C]%s", str)
            else
                INFO("%s", str)
            end
        end
    end
    logsplite(cmd)
--[[    
    if string.sub(cmd, 1,2) == "tf" then
        _G_TF_START_TIMES = _G_TF_START_TIMES or 0
        _G_TF_START_TIMES = _G_TF_START_TIMES + 1
        if _G_TF_START_TIMES > 1 and _G_TF_START_TIMES < 4 then
            DEBUG("测试，不处理")
            return
        end
    end
]]--
    local s2cEvt = {}
    local flag1Index = string.find(cmd, "#")
    local flag2Index = string.find(cmd, "|")
    if flag1Index and flag1Index < 15 then
        s2cEvt.cmd=string.sub(cmd, 1, flag1Index - 1)
        s2cEvt.type = "S2C_" ..s2cEvt.cmd
        s2cEvt.data = json.decode(string.sub(cmd, flag1Index + 1))
        if s2cEvt.data.f then
            s2cEvt.type = s2cEvt.type .. "_" .. s2cEvt.data.f
        end
    elseif flag2Index and flag2Index < 15 then
        s2cEvt.cmd=string.sub(cmd, 1, flag2Index - 1)
        s2cEvt.type = "S2C_" .. s2cEvt.cmd
        s2cEvt.str = string.sub(cmd, flag2Index + 1)
        s2cEvt.data = zzy.StringUtils:splitToTable(s2cEvt.str)
        if s2cEvt.data and s2cEvt.data.f then
            s2cEvt.type = s2cEvt.type .. "_" .. s2cEvt.data.f
        end
    else
        s2cEvt.type = "S2C_" .. cmd
    end

    if s2cEvt.cmd and s2cEvt.data and s2cEvt.data.f then
        self:_Waiting("S2C",tostring(s2cEvt.cmd),tostring(s2cEvt.data.f))
    end

    -- 不重启
    --检测是否存在ret不为0的  不为0的话证明客户端和服务器不一致        
    if s2cEvt.data and s2cEvt.data.ret and s2cEvt.data.ret~=0 then
        --if not ADAPTER then return end -- tgx

        --ch.fightRoleLayer:pause()
        cc.Director:getInstance():pause()
        --        zzy.EventManager:unListen(self._tickELI)
        self:disconnect(true)
        if self._showError==false then
            ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[4] ..tostring(s2cEvt.data.ret)..","..s2cEvt.cmd.."_"..(s2cEvt.data.f or ""), function()
                ch.LevelController:reStartGame()
            end)
            self._showError=true
        end
        return
    end


    --检索oderlist 去掉已下行的order
    if  s2cEvt.data and s2cEvt.cmd and s2cEvt.data.f and  s2cEvt.data.oseq then
        local key=s2cEvt.cmd.."_"..s2cEvt.data.f.."_"..s2cEvt.data.oseq
        --        cclog("key "..key)
        local mark=false
        for k,v in ipairs(self._orderList) do
            if v.k== key then
                table.remove(self._orderList,k)
                mark=true
                break;
            end
        end
        if mark==false then
            --断线重新可能多次上行相同的指令 如果在本地缓存中找不到对应的key 则可能是断线重连收到多次下行 只处理一次即可
            return
        end
    end
    --    cclog("len "..#self._orderList)
    if loaded or s2cEvt.type == "S2C_ls_lgn" or s2cEvt.type == "S2C_lgn_er" 
        or s2cEvt.type == "S2C_sys_gd" or s2cEvt.type == "S2C_sys_ckf" or s2cEvt.type == "S2C_cue_pop" then
        zzy.EventManager:dispatch(s2cEvt)
    else
        table.insert(cacheS2CEvents,s2cEvt)
    end
end


function NetManager:_onState(state)
	DEBUG("net state change to %d", state or 0)
    if state == self._state.CONNECT_SUCCESS and self._reconnec_times == 0 then
        -- 链接验证串验证通过，发登陆验证包  连接成功 2
        self._showError=false
        self._conn:putCmd("lgn|" .. self.loginStr,false)
        INFO("[MESSAGE][C2S]".."lgn|" .. self.loginStr)
        self._working = true
        
        local lastServerInfo_t = {}
        lastServerInfo_t.last1 = zzy.config.svrid or 1
        local lastServerInfo_str = json.encode(lastServerInfo_t)
        DEBUG("[lastlySer]"..lastServerInfo_str)
        cc.UserDefault:getInstance():setStringForKey("lastlySer", lastServerInfo_str)
    elseif state == self._state.SOCKET_ERROR then
        ERROR("SOCKET_ERROR ")
        --socket error 3
        if self._reconnec_times ==0 then
            self:delayReConnect()
            self._working = false
        end
    elseif state == self._state.CONNECTFAIL then
        if IS_IN_REVIEW then
            return
        end
        
        --4 连接失败 或者断线重连失败
        WARNING("CONNECTFAIL "..tostring( self._reconnec_times))
        if self._reconnec_times then
            if  self._reconnec_times <self._max_reconnec_times then
                self:delayReConnect()
            else
                --重连超过最大次数 失败
                self._reconnec_times=0
                --ch.fightRoleLayer:pause()
                cc.Director:getInstance():pause()
                self:disconnect(true)
                ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[4].."("..GameConst.NET_ERROR[5]..state..")",function()
                    ch.LevelController:reStartGame()
                end)
                ERROR("reconnect over times ")
            end
            self._working = false
        else
            --连接失败  重新connect
             ch.UIManager:showWaiting(false,true)
            ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[1].."("..GameConst.NET_ERROR[5]..state..")",function()
                self:init(zzy.config.host,zzy.config.port)
            end,nil,Language.MSG_BUTTON_RETRY)
        end
    elseif state == self._state.CONNECT_SUCCESS and self._reconnec_times > 0 then
        --5 重连成功  结束 转圈
        INFO("RECONNECT_SUCCESS ")
        self._reconnec_times=0
        ch.UIManager:showWaiting(false)
        self._isWaiting = false
        --self:reSendFailedOrder()
        self:reSendLocalOrder()
        self._working = true
    elseif state == self._state.SERVER_CLOSE then
        --7 服务器关闭
        ERROR("SERVER_CLOSE")
         zzy.TimerUtils:setTimeOut(0,function()
            --ch.fightRoleLayer:pause()
            cc.Director:getInstance():pause()
            self:disconnect(true)
            ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[4].."("..GameConst.NET_ERROR[5]..state..")",function()
                ch.LevelController:reStartGame()
            end)
        end)
    end

    --如果已经弹过错误对话框 则不再报网络错误
    --    if  self._showError==false then
    --        zzy.EventManager:dispatch({
    --            type = self.stateChangeEventType,
    --            state = state
    --        })
    --        if state==3 or state==4 then
    --            self._showError=true
    --        end
    --    end

end

---
-- 延时1秒重连
-- @function [parent=#NetManager] delayReConnect
-- @param self
function NetManager:delayReConnect(errMsg)
--[[
    --显示转圈
    if not self._isWaiting then
        ch.UIManager:showWaiting(true)
        self._isWaiting = true
    end
    self._reconnec_times =self._reconnec_times+1
    zzy.TimerUtils:setTimeOut(1,function()
        local ret= self._conn:reconnect()
        INFO("self._reconnec_times:"..self._reconnec_times.."  ret:"..ret)
    end)
]]
    if true then
        return
    end
    
    --重连超过最大次数 失败
    self._reconnec_times=0
    --ch.fightRoleLayer:pause()
    cc.Director:getInstance():pause()
    self:disconnect(true)
    
    local errMsgToShow = GameConst.NET_ERROR[4]
    if errMsg then
        errMsgToShow = errMsgToShow.."("..errMsg..")"
    end
    ch.UIManager:showMsgBox(1,true,errMsgToShow,function()
        ch.LevelController:reStartGame()
    end)
end
---
-- 输入超时指令到文件
-- @function [parent=#NetManager] writeTimeoutCmd
-- @param self
-- @param checktime
-- @return #NetManager nil
function NetManager:writeTimeoutCmd(checktime)
    local timeoutFileName = "timeout.log"
    local timeoutlist = {}
    local key,value
    for key,value in ipairs(self._orderList) do
        timeoutlist[tostring(value.v)] = value.k
    end
    checktime = checktime or os_clock()
    timeoutlist["checktime"] = tostring(checktime)
    cc.FileUtils:getInstance():writeToFile(timeoutlist, cc.FileUtils:getInstance():getWritablePath() .. timeoutFileName)
end

---
-- 输入超时指令到文件
-- @function [parent=#NetManager] getTimeoutCmd
-- @param self
-- @return #NetManager ret
function NetManager:getTimeoutCmd()
    local timeoutFileName = "timeout.log"
    return cc.FileUtils:getInstance():getStringFromFile(cc.FileUtils:getInstance():getWritablePath() .. timeoutFileName)
end
---
-- 帧频事件处理
-- @function [parent=#NetManager] _onTick
-- @param self
-- @param Events#TickEvent evt
function NetManager:_onTick(evt)
    --检测服务器下行是否超时半秒检查一次  只检测第一个即可 每个都是按顺序
    local nowtime = os_clock()
    if nowtime > self._lastCheckTime + 0.5  and self._orderList[1] and  self._working then
        if (nowtime - self._orderList[1].v) > 30 then
            local needReconnect = ""
             if self._reconnec_times == 0 then
                ERROR("服务器响应超时")
                
                for i=1, #self._orderList do
                    ERROR("[MESSAGE][C2S]%s", self._orderList[i].cmd)
                    if string.sub(self._orderList[i].k, 1, 5) ~=  "gk_rf" then
                        needReconnect = needReconnect..self._orderList[i].k.." "
                    end
                end
                if needReconnect ~= "" then
                    self:delayReConnect(needReconnect) --tgx
                end
            end
        end
        
        self:reSendLocalOrder()
        
        self._lastCheckTime = nowtime
    end
end

---
--重发发送没有收到返回值的指令
-- @function [parent=#NetManager] reSendLocalOrder
-- @param self
function NetManager:reSendLocalOrder()
    local nowtime = os_clock()

    for k,order in ipairs(self._orderList or {}) do
        if (nowtime - order.v) > 5 then
            if (string.sub(order.k,1,3) == "tf_" or string.sub(order.k,1,3) == "dj_")
            and (order.resendTimes == nil or order.resendTimes < 3) then
                order.resendTimes = (order.resendTimes or 0) + 1
                order.v = nowtime
                self._conn:putCmd(order.cmd, false)
                DEBUG("[MESSAGE][C2S][resend]%s", order.cmd)
            end
        end
    end
end
---
--重发发送失败的指令
-- @function [parent=#NetManager] reSendFailedOrder
-- @param self
--function NetManager:reSendFailedOrder()
--    for i=1, #self._sendFailed do
--        self:_onC2S(self._sendFailed[i])
--    end
--    self._sendFailed={}
--end

---
-- C2S事件处理
-- @function [parent=#NetManager] _onC2S
-- @param self
-- @param Events#C2SEvent evt
function NetManager:_onC2S(evt)
    local cmd = evt.cmd
    if evt.data  then
        if not self._ignoreOrderList[evt.cmd.."_"..evt.data.f] then
            evt.data.oseq=zzy.GuidUtils:getOrderIndex()
        end
        if evt.isjson then
            cmd = cmd .. "#" .. json.encode(evt.data)
        else
            cmd = cmd .. "|" .. zzy.StringUtils:tableToString(evt.data)
        end
    end
	
    if evt.cmd and evt.data and evt.data.f then
        self:_Waiting("C2S",tostring(evt.cmd),tostring(evt.data.f))
    end
    
    if evt.data  and evt.data.oseq then
        table.insert(self._orderList,{cmd=cmd,compress=evt.doCompress,k=evt.cmd.."_"..evt.data.f.."_"..evt.data.oseq,v=os_clock()})
    end
    
    if not self._working then
--        table.insert(self._sendFailed,evt)
        return
    end
    local curNetState=zzy.cUtils.getNetworkState()
    if curNetState==0   then
        --无网络  如果不正常并且没有在重连则需要重连
        INFO("zzy.cUtils.getNetworkState()"..zzy.cUtils.getNetworkState())
        if self._reconnec_times ==0 then
            self:delayReConnect()     
        end
    elseif curNetState~=self._lastNetState and self._lastNetState~=-1 then
        INFO("zzy.cUtils.getNetworkState()"..zzy.cUtils.getNetworkState())
        --网络状态改变 并且没有在重连则需要重连
         if self._reconnec_times ==0 then
            self:delayReConnect()     
        end   
    else
        if self._reconnec_times ==0 then
            --判断是否在重连过程中，如果是不调用putCmd
            local ret=self._conn:putCmd(cmd,evt.doCompress)  
			INFO("[MESSAGE][C2S]%s", cmd)
        end
    end
    self._lastNetState=curNetState
--    if ret >0 then
--        if evt.data  and evt.data.oseq then
--            table.insert(self._orderList,{k=evt.cmd.."_"..evt.data.f.."_"..evt.data.oseq,v=os_clock()})
--        end
--    else
--        table.insert(self._sendFailed,evt)
--        cclog("send failed:"..cmd)
--    end
end

---
-- 检查指令弹出或关闭等待界面
-- @function [parent=#NetManager] _Waiting
-- @param self
-- @param #string type
-- @param #string order
-- @param #string f
function NetManager:_Waiting(type, order, f)
    if type == "C2S" then
        if self._orderNeedReceive[order .. "_" .. f] then
            ch.UIManager:showWaiting(true)
        end
    elseif type == "S2C" then
        if self._orderNeedReceive[order .. "_" .. f] then
            ch.UIManager:showWaiting(false)
        end
    end
end

return NetManager
