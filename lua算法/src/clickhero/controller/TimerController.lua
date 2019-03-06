---
-- 定时控制
-- @module TimerController
local TimerController = { _lastTime = nil,_lastCheckNet = 0,canSend = true} 

---
-- 初始化
-- @function [parent=#TimerController] start
-- @param #TimerController self
function TimerController:start()
    self._lastTime = os_clock()
    zzy.EventManager:listen(zzy.Events.BackgroundEventType,function(obj,evt)
        if evt.isBack then
            TimerController._lastTime = nil 
        else
            TimerController._lastTime = os_clock()
        end
    end)
end

---
-- 初始化
-- @function [parent=#TimerController] update
-- @param #TimerController self
function TimerController:update()
    if not self._lastTime or not zzy.NetManager:getInstance():isWorking() then return end
    if ch.fightRoleLayer:isPause() or ch.LevelController.mode ~= ch.LevelController.GameMode.normal then 
        self._lastTime = os_clock()
        return
    end
    -- 每30秒定时发送指令
    if os_clock() > self._lastTime + 30 then
        self._lastTime = os_clock()
        if self.canSend then
            ch.NetworkController:sendFixedTimeData()
        end
    end
    
    --在loading完成前检测网络状态
--    if ch.GameLoaderModel.loadingCom==false then
--        if os_clock() > self._lastCheckNet + 2 then
--            cclog("zzy.cUtils.getNetworkState()" .. tostring(zzy.cUtils.getNetworkState()))
--             if zzy.cUtils.getNetworkState() == 0 then
    --                ch.UIManager:showMsgBox(1,false,"网络连接失败，请检查网络")
--             end
--             self._lastCheckNet = os_clock()
--        end
--    end
end
return  TimerController