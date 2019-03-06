local selectId = 1
local CHANG_RANK_EVENT = "RANK_CHANG_EVENT"

local getTime = function(str,time)
    if time > 0 then
        local day = time /(24*3600)
        local day = math.floor(day)
        local second = math.floor(time%60)
        time = time /60
        local minute = math.floor(time%60)
        local hour = math.floor(time/60)
        hour = math.floor(hour%24)
        return string.format(str,day,hour,minute,second)
    else
        return 0
    end
end

---
-- 排行榜界面
zzy.BindManager:addFixedBind("achievement/N_Top",function(widget)
    local rankListEvent = {}
    rankListEvent[ch.RankListModel.dataChangeEventType] = function (evt)
    	return (evt.dataType == ch.RankListModel.dataType.level and evt.id == "0") 
    	       or evt.dataType == ch.RankListModel.dataType.arena 
    	       or evt.dataType == ch.RankListModel.dataType.time
    	       or evt.dataType == ch.RankListModel.dataType.guild
    end
    rankListEvent[CHANG_RANK_EVENT] = false
    
    local listChangeEvent = {}
    listChangeEvent[ch.RankListModel.dataChangeEventType] = function (evt)
        return evt.dataType == ch.RankListModel.dataType.list
    end
    
    local selectChangeEvent = {}
    selectChangeEvent[CHANG_RANK_EVENT] = false
    
    selectId = 1
    local rfData2 = true
    local rfData3 = true
    
    widget:addDataProxy("myRank",function(evt)
        if selectId == 1 then
            return ch.RankListModel:getMyRank()
        else
            return ch.RankListModel:getMyArena()
        end
    end,rankListEvent)
    widget:addDataProxy("myPercent",function(evt)
--        return string.format("打败了%g%%的玩家",ch.RankListModel:getMyRankPercent())
        if selectId == 1 then
            return ch.RankListModel:getMyRankPercent().."%"
        else
            return ch.RankListModel:getMyArenaPercent().."%"
        end
    end,rankListEvent)
    widget:addDataProxy("desc",function(evt)
        if selectId == 1 then
            return Language.src_clickhero_view_RankListView_1
        else
            return Language.src_clickhero_view_RankListView_2
        end
    end,selectChangeEvent)
    widget:addDataProxy("myGuild",function(evt)
        return ch.RankListModel:getMyGuildNum()
    end,rankListEvent)

    widget:addDataProxy("isShowCdTime",function(evt)
        if selectId == 2 then
            return true
        else
            return false
        end
    end,selectChangeEvent)

    local cutDown
    cutDown =  function()
        widget:noticeDataChange("cdTime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("cdTime",function(evt)
        local showDesc = (selectId == 2)
        if showDesc == true then
            return Language.src_clickhero_view_RankListView_2_1
        end

        local time = 0
        if selectId == 1 then
            time = ch.RankListModel:getRankTime()
        else
            time = ch.RankListModel:getArenaTime()
        end
--        return getTime(Language.src_clickhero_view_RankListView_3,time)
        return Language.src_clickhero_view_RankListView_3 .. ch.NumberHelper:cdTimeToString(time)
    end, selectChangeEvent)
    
    widget:addDataProxy("ifOpen",function(evt)
        local levelOk = (ch.StatisticsModel:getMaxLevel() > GameConst.RANKLIST_LEVEL)
        local notGuild = (selectId ~= 3)
        return levelOk and notGuild
    end,selectChangeEvent)
    widget:addDataProxy("ifNoOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel() <= GameConst.RANKLIST_LEVEL and selectId ~= 3
    end,selectChangeEvent)
    widget:addDataProxy("ifGuildPage",function(evt)
        return selectId == 3
    end,selectChangeEvent)
    
    widget:addDataProxy("ifSelect1",function(evt)
        return selectId == 1
    end,selectChangeEvent)
    widget:addDataProxy("ifSelect2",function(evt)
        return selectId == 2 
    end,selectChangeEvent)
    widget:addDataProxy("ifSelect3",function(evt)
        return selectId == 3 
    end,selectChangeEvent)
    
    widget:addCommond("openRank",function()
        selectId = 1
        zzy.EventManager:dispatchByType(CHANG_RANK_EVENT)
    end)
    
    widget:addCommond("openArena",function()
        selectId = 2
        if rfData2 then
            ch.NetworkController:arenaList()
            rfData2 = false
        end
        zzy.EventManager:dispatchByType(CHANG_RANK_EVENT)
    end)
    widget:addCommond("openGuild",function()
        selectId = 3
        if rfData3 then
            ch.NetworkController:rankGuildList()
            rfData3 = false
        end
        zzy.EventManager:dispatchByType(CHANG_RANK_EVENT)
    end)
    widget:addCommond("close",function()
        selectId = 1
        zzy.EventManager:dispatchByType(CHANG_RANK_EVENT)
        rfData2 = true
        rfData3 = true
        widget:destory()
    end)
end)

---
-- 排行榜列表
zzy.BindManager:addFixedBind("achievement/W_Top_in1",function(widget)
    widget:addDataProxy("rankList",function(evt)
        local items = {}
        for i = 1,50 do
            if i<4 then
                table.insert(items,{index = 1,value = {rank=i,type=1},isMultiple = true})
            else
                table.insert(items,{index = 2,value = {rank=i,type=1},isMultiple = true})
            end
        end
        return items
    end)
end)

---
-- 竞技场列表
zzy.BindManager:addFixedBind("achievement/W_Top_in2",function(widget)
    widget:addDataProxy("arenaList",function(evt)
        local items = {}
        for i = 1,50 do
            if i<4 then
                table.insert(items,{index = 1,value = {rank=i,type=2},isMultiple = true})
            else
                table.insert(items,{index = 2,value = {rank=i,type=2},isMultiple = true})
            end
        end
        return items
    end)
end)

---
-- 公会榜列表
zzy.BindManager:addFixedBind("achievement/W_Top_in3",function(widget)
    local rankListEvent = {}
    rankListEvent[ch.RankListModel.dataChangeEventType] = function (evt)
        return evt.dataType == ch.RankListModel.dataType.guild
    end
    widget:addDataProxy("guildList",function(evt)
        local items = {}
        for k,v in pairs(ch.RankListModel:getGuildList()) do
            if tonumber(k)<4 then
                table.insert(items,{index = 1,value = {rank=tonumber(k),type=3,tmpData = v},isMultiple = true})
            else
                table.insert(items,{index = 2,value = {rank=tonumber(k),type=3,tmpData = v},isMultiple = true})
            end
        end
        return items
    end,rankListEvent)
end)

---
-- 排行榜列表内容
zzy.BindManager:addCustomDataBind("achievement/N_TopUnit",function(widget,data)
    local rankListEvent = {}
    rankListEvent[ch.RankListModel.dataChangeEventType] = function (evt)
        return evt.dataType == ch.RankListModel.dataType.arena 
            or (evt.dataType == ch.RankListModel.dataType.list and evt.id == data.rank)
            or evt.dataType == ch.RankListModel.dataType.guild
    end
    widget:addDataProxy("rank",function(evt)
        return GameConst.RANKLIST_ICON[tonumber(data.rank)]
    end)
    widget:addDataProxy("name",function(evt)
        if data.n then
            return data.n
        else
            return ch.RankListModel:getNameByRank(data.rank,data.type)
        end
    end,rankListEvent)
    widget:addDataProxy("maxLevel",function(evt)
        if data.num then
            if type(data.num) == "string" then
                return data.num
            else
                return ch.NumberHelper:toString(data.num)
            end
        else
            return ch.RankListModel:getNumByRank(data.rank,data.type)
        end
    end,rankListEvent)
    widget:addDataProxy("harmText",function(evt)
        if data.type then
            if data.type == 2 then
                return Language.src_clickhero_view_RankListView_4
            elseif data.type == 3 then
                return Language.src_clickhero_view_RankListView_6
            else
                return ""
            end
        else
            return data.harmText..": "
        end
    end)
    widget:addDataProxy("notRank",function(evt)
        if data.type and data.type == 1 then
            return false
        else
            return true
        end
    end)
    widget:addDataProxy("isRank",function(evt)
        if data.type and data.type == 1 then
            return true
        else
            return false
        end
    end)   
    
    widget:addDataProxy("dbImage",function(evt)
        if ((data.type == 1 or data.type == 2) and ch.RankListModel:getUserIdByRank(data.rank,data.type) == ch.PlayerModel:getPlayerID() ) 
            or (data.type == 3 and ch.RankListModel:getUserIdByRank(data.rank,data.type) == ch.RankListModel:getMyGuildID()) then
            return "aaui_diban/db_itemrank_my.png"
        else
            return "aaui_diban/db_itemrank.png"
        end
    end,rankListEvent) 
    
    -- 称号图标
    widget:addDataProxy("titleIcon",function(evt)
        if data.l then
            return ch.UserTitleModel:getTitle(data.l-1,data.id).icon
        else
            if data.type == 3 then
                return GameConst.GUILD_FLAG[tonumber(data.tmpData.flag)]
            else
                return ch.UserTitleModel:getTitle(ch.RankListModel:getMaxLevelByRank(data.rank,data.type)-1,ch.RankListModel:getUserIdByRank(data.rank,data.type)).icon
            end
        end
    end,rankListEvent)
    -- 公会图标
    widget:addDataProxy("guildIcon",function(evt)
        if data.l then
            return ch.UserTitleModel:getTitle(data.l-1,data.id).icon
        else
            if data.type == 3 then
                return GameConst.GUILD_FLAG[tonumber(data.tmpData.flag)]
            else
                return ch.UserTitleModel:getTitle(ch.RankListModel:getMaxLevelByRank(data.rank,data.type)-1,ch.RankListModel:getUserIdByRank(data.rank,data.type)).icon
            end
        end
    end,rankListEvent)
    -- 是否有称号,显示公会图标还是显示称号
    widget:addDataProxy("ifGuild",function(evt)
        if data.type and data.type == 3 then
            return true
        else
            return false
        end
    end,rankListEvent)
    widget:addDataProxy("noGuild",function(evt)
        if (data.type and data.type ~= 3) or data.l then
            return true
        else
            return false
        end
    end,rankListEvent)
    widget:addCommond("openDetail",function()
        if data.type then
            if data.type == 1 then
                ch.NetworkController:rankListPlayer(ch.RankListModel:getUserIdByRank(data.rank,data.type))
            elseif data.type == 2 then
                ch.NetworkController:arenaPlayer(ch.RankListModel:getUserIdByRank(data.rank,data.type),data.rank,1)
            elseif data.type == 3 then
                ch.NetworkController:guildDetail(data.tmpData.id,nil,1)
            end
        elseif not data.l then
            ch.NetworkController:guildDetail(data.id,nil,1)
        else
            ch.NetworkController:rankListPlayer(data.id)
        end
    end)
end)

---
-- 排行榜列表内容
zzy.BindManager:addCustomDataBind("achievement/N_TopUnit2",function(widget,data)
    local rankListEvent = {}
    rankListEvent[ch.RankListModel.dataChangeEventType] = function (evt)
        local res = evt.dataType == ch.RankListModel.dataType.arena 
                or (evt.dataType == ch.RankListModel.dataType.list and evt.id == data.rank)
                or evt.dataType == ch.RankListModel.dataType.guild
        return res
    end

    widget:addDataProxy("rank",function(evt)
        return tostring(data.rank)
    end)
    widget:addDataProxy("name",function(evt)
        if data.n then
            return data.n
        else    
            return ch.RankListModel:getNameByRank(data.rank,data.type)
        end
    end,rankListEvent)
    widget:addDataProxy("maxLevel",function(evt)
        if data.num then
            if type(data.num) == "string" then
                return data.num
            else
                return ch.NumberHelper:toString(data.num)
            end
        else
            return ch.RankListModel:getNumByRank(data.rank,data.type)
        end
        
    end,rankListEvent)
    widget:addDataProxy("harmText",function(evt)
        if data.type then
            if data.type == 2 then
                return Language.src_clickhero_view_RankListView_4
            elseif data.type == 3 then
                return Language.src_clickhero_view_RankListView_6
            else
                return ""
            end
        else
            return data.harmText..": "
        end
    end)
    widget:addDataProxy("notRank",function(evt)
        if data.type and data.type == 1 then
            return false
        else
            return true
        end
    end)
    widget:addDataProxy("isRank",function(evt)
        if data.type and data.type == 1 then
            return true
        else
            return false
        end
    end)   
    
    widget:addDataProxy("dbImage",function(evt)
        if ((data.type == 1 or data.type == 2) and ch.RankListModel:getUserIdByRank(data.rank,data.type) == ch.PlayerModel:getPlayerID() ) 
            or (data.type == 3 and ch.RankListModel:getUserIdByRank(data.rank,data.type) == ch.RankListModel:getMyGuildID()) then
            return "aaui_diban/db_itemrank_my.png"
        else
            return "aaui_diban/db_itemrank.png"
        end
    end,rankListEvent)
    
    -- 称号图标
    widget:addDataProxy("titleIcon",function(evt)
        if data.l then
            return ch.UserTitleModel:getTitle(data.l-1,data.id).icon
        else
            if data.type == 3 then
                return GameConst.GUILD_FLAG[tonumber(data.tmpData.flag)]
            else
                return ch.UserTitleModel:getTitle(ch.RankListModel:getMaxLevelByRank(data.rank,data.type)-1,ch.RankListModel:getUserIdByRank(data.rank,data.type)).icon
            end
        end
    end,rankListEvent)
    -- 公会图标
    widget:addDataProxy("guildIcon",function(evt)
        if data.l then
            return ch.UserTitleModel:getTitle(data.l-1,data.id).icon
        else
            if data.type == 3 then
                return GameConst.GUILD_FLAG[tonumber(data.tmpData.flag)]
            else
                return ch.UserTitleModel:getTitle(ch.RankListModel:getMaxLevelByRank(data.rank,data.type)-1,ch.RankListModel:getUserIdByRank(data.rank,data.type)).icon
            end
        end
    end,rankListEvent)
    -- 是否有称号,显示公会图标还是显示称号
    widget:addDataProxy("ifGuild",function(evt)
        if data.type and data.type == 3 then
            return true
        else
            return false
        end
    end,rankListEvent)
    widget:addDataProxy("noGuild",function(evt)
        if (data.type and data.type ~= 3) or data.l then
            return true
        else
            return false
        end
    end,rankListEvent)
    widget:addCommond("openDetail",function()
        if data.type then
            if data.type == 1 then
                ch.NetworkController:rankListPlayer(ch.RankListModel:getUserIdByRank(data.rank,data.type))
            elseif data.type == 2 then
                ch.NetworkController:arenaPlayer(ch.RankListModel:getUserIdByRank(data.rank,data.type),data.rank,1)
            elseif data.type == 3 then
                ch.NetworkController:guildDetail(data.tmpData.id,nil,1)
            end
        elseif not data.l then
            ch.NetworkController:guildDetail(data.id,nil,1)
        else
            ch.NetworkController:rankListPlayer(data.id)
        end
    end)
end)

---
-- 周赛奖励查看界面
zzy.BindManager:addCustomDataBind("zhousai/W_zhousaichakan",function(widget,data)
    local config = GameConfig.Rank_cfgConfig:getData(data.typeId,data.cfgId)
    local rewardData = ch.MatchRankModel:getRewardData(config.awardid,ch.MatchRankModel:getMyRank())
    widget:addDataProxy("title",function(evt)
        return config.name
    end)
    
    widget:addDataProxy("desc",function(evt)
        return "1."..config.desc
    end)
    
    widget:addDataProxy("myRank",function(evt)
        return ch.MatchRankModel:getMyRank()
    end)
    widget:addDataProxy("isOut",function(evt)
        return ch.MatchRankModel:getMyRank()<1
    end)
    widget:addDataProxy("isIn",function(evt)
        return ch.MatchRankModel:getMyRank()>0
    end)    
    widget:addDataProxy("openTime",function(evt)
        local time = ch.MatchRankModel:getTime(data.typeId)
        return os.date(Language.src_clickhero_view_ChristmasView_6,time.openTime)..os.date(Language.src_clickhero_view_ChristmasView_7,time.endTime)
    end)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("cdTime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("cdTime",function(evt)
        local time = ch.MatchRankModel:getEndTimeCD(data.typeId)
--        return getTime(Language.src_clickhero_view_ActivityView_5,time)
        return ch.NumberHelper:cdTimeToString(time)
    end)

    widget:addDataProxy("rewardList",function(evt)
        return rewardData.all
    end)
    
    widget:addDataProxy("reward1",function(evt)
        return {icon=ch.CommonFunc:getRewardIcon(rewardData.myData.idty1,rewardData.myData.id1),num=ch.CommonFunc:getRewardValue(rewardData.myData.idty1,rewardData.myData.id1,rewardData.myData.num1),vis=rewardData.myData.vis1}
    end)

    widget:addDataProxy("reward2",function(evt)
        return {icon=ch.CommonFunc:getRewardIcon(rewardData.myData.idty2,rewardData.myData.id2),num=ch.CommonFunc:getRewardValue(rewardData.myData.idty2,rewardData.myData.id2,rewardData.myData.num2),vis=rewardData.myData.vis2}
    end)

    widget:addDataProxy("reward3",function(evt)
        return {icon=ch.CommonFunc:getRewardIcon(rewardData.myData.idty3,rewardData.myData.id3),num=ch.CommonFunc:getRewardValue(rewardData.myData.idty3,rewardData.myData.id3,rewardData.myData.num3),vis=rewardData.myData.vis3}
    end)
end)

---
-- 周赛奖励单元
zzy.BindManager:addCustomDataBind("zhousai/N_zhousai_reward",function(widget,data)
    widget:addDataProxy("rewardIcon",function(evt)
        return data.icon
    end)
    widget:addDataProxy("rewardNum",function(evt)
        return data.num
    end)
    widget:addDataProxy("ifVis",function(evt)
        return data.vis
    end)
end)

---
-- 周赛查看单元
zzy.BindManager:addCustomDataBind("zhousai/W_zhousai_unit",function(widget,data)
    widget:addDataProxy("rank",function(evt)
        return data.rank
    end)

    widget:addDataProxy("reward1",function(evt)
        return {icon=ch.CommonFunc:getRewardIcon(data.idty1,data.id1),num=ch.CommonFunc:getRewardValue(data.idty1,data.id1,data.num1),vis=true}
    end)

    widget:addDataProxy("reward2",function(evt)
        return {icon=ch.CommonFunc:getRewardIcon(data.idty2,data.id2),num=ch.CommonFunc:getRewardValue(data.idty2,data.id2,data.num2),vis=data.vis2}
    end)

    widget:addDataProxy("reward3",function(evt)
        return {icon=ch.CommonFunc:getRewardIcon(data.idty3,data.id3),num=ch.CommonFunc:getRewardValue(data.idty3,data.id3,data.num3),vis=data.vis3}
    end)
end)

---
-- 特殊排行榜查看界面
zzy.BindManager:addCustomDataBind("zhousai/W_zhousaiPH",function(widget,data)
    local config = GameConfig.Rank_cfgConfig:getData(data.typeId,data.cfgId)

    widget:addDataProxy("title",function(evt)
        return config.name
    end)

    widget:addDataProxy("desc",function(evt)
        return config.desc
    end)

    widget:addDataProxy("myRank",function(evt)
        return ch.MatchRankModel:getMyRank()
    end)
    
    widget:addDataProxy("isOut",function(evt)
        return ch.MatchRankModel:getMyRank()<1
    end)
    widget:addDataProxy("isIn",function(evt)
        return ch.MatchRankModel:getMyRank()>0
    end)
    widget:addDataProxy("noData",function(evt)
        return table.maxn(ch.MatchRankModel:getListData()) < 1
    end)
    widget:addDataProxy("openTime",function(evt)
        local time = ch.MatchRankModel:getTime(data.typeId)
        return os.date(Language.src_clickhero_view_ChristmasView_6,time.openTime)..os.date(Language.src_clickhero_view_ChristmasView_7,time.endTime)
    end)
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("cdTime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()

    widget:addDataProxy("cdTime",function(evt)
        local time = ch.MatchRankModel:getEndTimeCD(data.typeId)
--        return getTime(Language.src_clickhero_view_ActivityView_5,time)
        return ch.NumberHelper:cdTimeToString(time)
    end)
    widget:addDataProxy("rankList",function(evt)
        local items = {}
        for k,v in pairs(ch.MatchRankModel:getListData()) do
            local tmpData = v
            tmpData.rank = k
            if k<4 then
                table.insert(items,{index = 1,value = tmpData,isMultiple = true})
            else
                table.insert(items,{index = 2,value = tmpData,isMultiple = true})
            end
        end
        return items
    end)
    widget:addDataProxy("myPercent",function(evt)
        return string.format(Language.src_clickhero_view_RankListView_5,ch.MatchRankModel:getMyPercent())
    end)
    
    widget:addCommond("openReward",function()
        ch.UIManager:showGamePopup("zhousai/W_zhousaichakan",data)
    end)
end)
