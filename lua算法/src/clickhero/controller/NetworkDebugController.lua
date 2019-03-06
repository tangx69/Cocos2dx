---
-- 客户端截获上行 并模拟服务器的下行 （不联网 调试使用）
-- @module NetworkDebugController
local NetworkDebugController = {}
---
-- 初始化
-- @function [parent=#NetworkDebugController] init
-- @param #NetworkDebugController self
function NetworkDebugController:init()
    if not zzy.config.linkSocket then
        zzy.EventManager:listen(zzy.Events.C2SEventType,self._onC2S) 
    end
end

---
-- C2S事件处理
-- @function [parent=#NetworkDebugController] _onC2S
-- @param self
-- @param Events#C2SEvent evt
function NetworkDebugController:_onC2S(evt)
    --根据cmd和f模拟不同的下行数据
    if evt and evt.data and evt.data.f and evt.cmd then
        -- 图腾
        if evt.cmd == "totem" then
            local evtS2C
            if evt.data.f == "rf" then
                evtS2C = {type = "S2C_totem_rf"}
                if tonumber(evt.data.type) == -1 then
                    evtS2C.data = {ret=0,type=-1,f="rf",totem={"1","13","4","7"}}
                    zzy.EventManager:dispatch(evtS2C)
                elseif tonumber(evt.data.type) == 1 then
                    evtS2C.data = {ret=0,type=1,f="rf",totem={"3","29","1","6"}}
                    zzy.EventManager:dispatch(evtS2C)
                elseif tonumber(evt.data.type) == 0 then
                    evtS2C.data = {ret=0,type=0,f="rf",totem={"5","20","28","27"}}
                    zzy.EventManager:dispatch(evtS2C)
        		end
        	elseif evt.data.f == "get" then
        	    evtS2C = {type = "S2C_totem_get"}
                evtS2C.data = {id=tostring(evt.data.id),type=evt.data.type,ret=0,f="get"}
                zzy.EventManager:dispatch(evtS2C)
            elseif evt.data.f == "reset" then
                evtS2C = {type = "S2C_totem_reset"}
                evtS2C.data = {ret=0,type=0,f="reset"}
                zzy.EventManager:dispatch(evtS2C)
            elseif evt.data.f == "up" then
                evtS2C = {type = "S2C_totem_up"}
                evtS2C.data = {ret=0,type=evt.data.type,id=evt.data.id,level=evt.data.level,f="up"}
                zzy.EventManager:dispatch(evtS2C)
        	end
    	end
    	-- 镀金
        if evt.cmd == "dj" then
            local evtS2C
            if evt.data.f == "get" then
                evtS2C = {type = "S2C_dj_get"}
                local tmpId = ch.MagicModel:getRandMagicID()
                evtS2C.data = {id=tostring(tmpId),ret=0,f="get"}
                zzy.EventManager:dispatch(evtS2C)
            elseif evt.data.f == "trans" then
                evtS2C = {type = "S2C_dj_trans"}
                ch.MagicModel:getRemoveMagic("1")
                local tmpDesId = ch.MagicModel:getRemoveMagicID()
                evtS2C.data = {ret=0,desid=tostring(tmpDesId),f="trans"}
                zzy.EventManager:dispatch(evtS2C)
            end
        end
        -- 排行榜
        if evt.cmd == "rk" then
            local evtS2C
            if evt.data.f == "get" then
                evtS2C = {type = "S2C_rk_get"}
                evtS2C.data = {num=20,per=69.91,pl={{n="卜心",l=2500},{n="小悦悦",l=2490},{n="浩哥",l=2370},{n="尤可涛",l=2280},{n="萧林鹏",l=2139},{n="我是好人",l=1998},{n="优雅de颓废",l=1989},{n="君子兰",l=1977},{n="大魔王",l=1977},{n="我才是大魔王",l=1975}},ret=0,f="get"}
                zzy.EventManager:dispatch(evtS2C)
            end
        end
        -- 任务过天刷新
        if evt.cmd == "task" then
            local evtS2C
            if evt.data.f == "rf" then
                evtS2C = {type = "S2C_task_rf"}
                evtS2C.data = {f="rf",ret=0,task=ch.TaskModel:onNextDay()}
                zzy.EventManager:dispatch(evtS2C)
            end
        end
        if evt.cmd == "sprite" then
            local level = evt.data.gkid
            local sNum = 0
            if level >=GameConst.SSTONE_LEVEL and level %5 == 0 then
                local probality = GameConst.SSTONE_RATIO + ch.TotemModel:getTotemSkillData(1,5)
                probality = probality + ch.BuffModel:getSDRateAddtion()
                local isDrop = math.random() < probality
                if isDrop then
                    if level == GameConst.SSTONE_LEVEL then
                        sNum = 1
                    else
                        sNum = math.pow(((level - GameConst.SSTONE_LEVEL) / 5 + 4) / 5,1.3) --基础
                        sNum = sNum * (1 + ch.TotemModel:getTotemSkillData(1,9)) -- 图腾加成
                        sNum = sNum *(1 + ch.BuffModel:getSNumberAddtion())
                    end
                end
            end
            local s2cEvt = {type = "S2C_sprite_get"}
            s2cEvt.data = {f="get",gkid=level,num = sNum}
            zzy.EventManager:dispatch(s2cEvt)
        end
    end
end

return  NetworkDebugController