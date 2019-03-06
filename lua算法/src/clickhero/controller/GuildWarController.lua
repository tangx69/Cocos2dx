---
-- 公会战网络控制层
--@module GuildWarController
local GuildWarController = {
}

---
-- 初始化
-- @function [parent=#GuildWarController] init
-- @param #GuildWarController self
function GuildWarController:init()
    zzy.EventManager:listen("S2C_gw_open",function(obj,evt)
        ch.GuildWarModel:refreshData(evt.data)
    end)
    
    zzy.EventManager:listen("S2C_gw_start",function(obj,evt)
        ch.GuildWarModel:setHomeCityData(evt.data.hCity)
        ch.GuildWarModel:setFightState(1)
    end)
    zzy.EventManager:listen("S2C_gw_change",function(obj,evt)
        for k,v in pairs(evt.data.nCity) do
            ch.GuildWarModel:setCityData(k,v.s,v.b)
        end
        ch.GuildWarModel:setCityCount(evt.data.jhc,evt.data.lnc)
    end)
    zzy.EventManager:listen("S2C_gw_prod",function(obj,evt)
        ch.GuildWarModel:setProductionNumber(evt.data.jhn,evt.data.lnn)
    end)
    zzy.EventManager:listen("S2C_gw_team",function(obj,evt)
        ch.GuildWarModel:setTeamStatus(evt.data.index,evt.data.status,evt.data.morale,evt.data.cid,evt.data.arrtime,evt.data.dietime)
    end)
    zzy.EventManager:listen("S2C_gw_morale",function(obj,evt)
        ch.GuildWarModel:setTeamMorale(evt.data.index,evt.data.morale)
    end)
    zzy.EventManager:listen("S2C_gw_exploits",function(obj,evt)
        ch.GuildWarModel:setExploits(evt.data.exploits)
        ch.GuildWarModel:setDailyExploits(evt.data.daily)
    end)
    zzy.EventManager:listen("S2C_gw_groupChg",function(obj,evt)
        ch.GuildWarModel:setTeamTid(evt.data.index,evt.data.tid)
        ch.GuildWarModel:setTeamStatus(evt.data.index,1,100,ch.GuildWarModel:getMyHomeCityId())
    end)
    zzy.EventManager:listen("S2C_gw_fight",function(obj,evt)
        ch.GuildWarModel:setCityData(evt.data.city.id,evt.data.city.s,evt.data.city.b)
        ch.GuildWarModel:setFightInfo(evt.data.fInfo,evt.data.tInfo,evt.data.ptInfo)
        if not ch.GuildWarModel:getFightPageCid() then
            ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_conquest_1",evt.data.city.id)
        end
    end)
    zzy.EventManager:listen("S2C_gw_apply",function(obj,evt)
        if evt.data.err and evt.data.err == 99 then
            ch.UIManager:showUpTips(Language.GUILD_WAR_APPLY_ERROR)
            ch.UIManager:cleanGamePopupLayer(true)
            ch.NetworkController:guildPanel()
        else
            ch.GuildWarModel:setApplyState(1)
        end
    end)
    zzy.EventManager:listen("S2C_gw_applyAll",function(obj,evt)
        ch.GuildWarModel:setApplyState(1)
    end)
    zzy.EventManager:listen("S2C_gw_shadow",function(obj,evt)
        if not evt.data.err then
            ch.GuildWarModel:addShadowCallNum() -- 先加次数后扣钱
            local diamond = ch.GuildWarModel:callShadowPrice()
            ch.MoneyModel:addDiamond(-diamond)
            ch.GuildWarModel:addConjuringShadowTeam(evt.data.team)
            ch.UIManager:showUpTips(Language.GUILD_WAR_SHADOW_TEAM_TIPS[1])
        else
            ch.UIManager:showUpTips(Language.GUILD_WAR_SHADOW_TEAM_TIPS[2])
        end
    end)
    zzy.EventManager:listen("S2C_gw_pointTS",function(obj,evt)
        -- 据点详情
        ch.GuildWarModel:setCityTeamNum(evt.data.city.id,evt.data.att,evt.data.def,evt.data.ptime)
        ch.GuildWarModel:setCityData(evt.data.city.id,evt.data.city.s,evt.data.city.b)
    end)
    zzy.EventManager:listen("S2C_gw_go",function(obj,evt)
        -- 出征
    end)
    zzy.EventManager:listen("S2C_gw_joinNew",function(obj,evt)
        if evt.data.ret == 0 then
            ch.GuildWarModel:updata(evt.data)
            if ch.LevelController.mode == ch.LevelController.GameMode.guildWar 
                and (evt.data.fight.startTime > os_time() or evt.data.fight.endTime < os_time()) then
                ch.UIManager:showMsgBox(1,true,Language.GUILD_WAR_END_TIPS,function()
                    ch.UIManager:cleanGamePopupLayer(true)
                    ch.LevelController:startNormal()
                end)
            end
        end
    end)
    zzy.EventManager:listen("S2C_gw_rewardPanel",function(obj,evt)
        ch.GuildWarModel:setGuildWarRewardPanel(evt.data)
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_prize")
    end)
    zzy.EventManager:listen("S2C_gw_getR",function(obj,evt)
        -- 领奖
        if evt.data.type == 1 then
            ch.GuildWarModel:setRewardState(evt.data.id,1)
        elseif evt.data.type == 0 then
            ch.GuildWarModel:setRewardState(evt.data.id,2)
            ch.MoneyModel:addDiamond(-GameConst.GUILD_WAR_REWARD_PRICE)
        end
    end)
    zzy.EventManager:listen("S2C_gw_getDayR",function(obj,evt)
        ch.GuildWarModel:setDailyPrize(evt.data.id)
        for k,v in ipairs(evt.data.id) do
            ch.CommonFunc:addItems(GameConst.GUILD_WAR_SCORE_DAY_PRIZE[v].reward)
        end
    end)
    
    zzy.EventManager:listen("S2C_gw_rank",function(obj,evt)
        -- 排行榜
        ch.GuildWarModel:setGuildWarRank(evt.data.pl)
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_top",self.rankType)--公会战附魔精华
    end)
    zzy.EventManager:listen("S2C_gw_curRank",function(obj,evt)
        -- 当前战功排行榜
        ch.GuildWarModel:setGuildWarCurRank(evt.data)
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_top",2)
    end)
    zzy.EventManager:listen("S2C_gw_cityDetail",function(obj,evt)
        -- 查看援军->据点详情
        ch.GuildWarModel:setArrivingTeams(evt.data.att, evt.data.def)
        ch.GuildWarModel:setCityData(evt.data.city.id, evt.data.city.s, evt.data.city.b)
        ch.GuildWarModel:raiseArrivingTeamsEvent(evt.data.city.id)
        if not ch.GuildWarModel:isCityDetailPageOpened() then
            ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_conquest_2",evt.data.city.id)
        end
    end)
    
    zzy.EventManager:listen("S2C_gw_gatherCD",function(obj,evt)
        -- 清理集合时间
        if evt.data.err and evt.data.err ~= 0 then
            -- 不处理
        end
        --如果返回结果为0，表示清理集合时间成功
        if evt.data.ret==0 then
            if not evt.data.err or evt.data.err == 0 then
                if evt.data.type==0 then--钻石清除集合时间
                    ch.MoneyModel:addDiamond(-evt.data.num)
                elseif evt.data.type==1 then--号角清除集合时间
                    ch.GuildWarModel:addToken(-GameConst.GUILD_WAR_CLEANCD_TOKENPRICE)
                else
                    assert(evt.data.type>1,"sorry,this type:"..evt.data.type.." we don't recognize")
                end
                local nTeamIndex=ch.GuildWarModel:getTeamIndexByTID(evt.data.id)
                assert(nTeamIndex,"teamid=="..evt.data.id.." not found")
                ch.GuildWarModel:setTeamStatusAfterGatherCD(nTeamIndex,1,evt.data.dieTime)--设置战队状态为主城闲置
                evt={type=ch.GuildWarModel.ged_gatherCDSuccessEventType}
                zzy.EventManager:dispatch(evt)
            end
        else
           assert(evt.data.ret~=0,"gathercd failed,reason::"..evt.data.ret)
        end
    end)
end

---
-- 刷新地图数据
-- @function [parent=#GuildWarController] refreshMapData
-- @param #GuildWarController self
function GuildWarController:refreshMapData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "open",
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 停止下行
-- @function [parent=#GuildWarController] stop
-- @param #GuildWarController self
function GuildWarController:stop()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "close",
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 查看战斗数据
-- @function [parent=#GuildWarController] requestFightInfo
-- @param #GuildWarController self
-- @param #string cid
function GuildWarController:requestFightInfo(cid)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "fight",
        id = cid,
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会战报名
-- @function [parent=#GuildWarController] guildWarApply
-- @param #GuildWarController self
function GuildWarController:guildWarApply()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "apply",
        id = ch.GuildModel:myGuildID(),
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会战进攻队伍设置
-- @function [parent=#GuildWarController] changeMyCardList
-- @param #GuildWarController self
-- @param #number index
-- @param #table cardList
function GuildWarController:changeMyCardList(index,cardList)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "groupChg",
        index = index,
        group1=cardList[1],
        group2=cardList[2],
        group3=cardList[3],
        group4=cardList[4],
        group5=cardList[5],
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会战召唤影子战队
-- @function [parent=#GuildWarController] guildWarShadowCall
-- @param #GuildWarController self
-- @param #string cid
function GuildWarController:guildWarShadowCall(cid)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "shadow",
        id = cid,
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会战据点详情
-- @function [parent=#GuildWarController] guildWarPointTS
-- @param #GuildWarController self
-- @param #string cid
function GuildWarController:guildWarPointTS(cid)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "pointTS",
        id = cid,
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会战出征
-- @function [parent=#GuildWarController] guildWarGo
-- @param #GuildWarController self
-- @param #string tid
-- @param #string way
function GuildWarController:guildWarGo(tid,way)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "go",
        tid = tid,
        way = way,
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 查看援军->据点详情
-- @function [parent=#GuildWarController] cityDetailFromCheckReinforcements
-- @param #GuildWarController self
-- @param #string cid
function GuildWarController:cityDetailFromCheckReinforcements(cid)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "cityDetail",
        id = cid,
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会战奖励界面信息
-- @function [parent=#GuildWarController] guildWarRewardPanel
-- @param #GuildWarController self
function GuildWarController:guildWarRewardPanel()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "rewardPanel",
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会战领奖(0钻石1免费)
-- @function [parent=#GuildWarController] guildWarGetReward
-- @param #GuildWarController self
-- @param #number id
-- @param #number type
function GuildWarController:guildWarGetReward(id,type)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "getR",
        id = id,
        type = type,
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会战日常战功领奖
-- @function [parent=#GuildWarController] guildWarGetDailyReward
-- @param #GuildWarController self
function GuildWarController:guildWarGetDailyReward()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "getDayR",
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会战排行榜
-- @function [parent=#GuildWarController] guildWarRank
-- @param #GuildWarController self
function GuildWarController:guildWarRank()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "rank",
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
    self.rankType = 1 --公会战附魔精华
end

---
-- 公会战排行榜
-- @function [parent=#GuildWarController] guildWarRank
-- @param #GuildWarController self
function GuildWarController:guildWarRank_JH()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "rank",
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
    self.rankType = 3 --公会战附魔精华
end

---
-- 公会战当前战功排行榜
-- @function [parent=#GuildWarController] guildWarCurRank
-- @param #GuildWarController self
function GuildWarController:guildWarCurRank()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "curRank",
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 清除集合时间
-- @function [parent=#GuildWarController] sendMsgGatherCD
-- @param #GuildWarController self
-- @param #string id teamid
-- @param #numver type 0为钻石，1为号角
-- @param #number num  消耗数量
-- @param #number tm
function GuildWarController:sendMsgGatherCD(teamid,nCostType,nCostNum)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "gw"
    evt.data = {
        f = "gatherCD",
        id = teamid,
        type=nCostType,
        num=nCostNum,
        tm = math.ceil(os_time()),
    }
    zzy.EventManager:dispatch(evt)
end

return GuildWarController