---
-- 
-- @module NetworkController
local NetworkController = {
    _data = {
        magicLevelUpData = {},
        runicLevelUpData = {},
        levelData = {},
        isGoldChanged = false
    },
    _magicStarOldId = "1",
    _guildName = "",
    _guildId = "",
    _guildSlogan = "",
    _flag = 1,
    _waitGold = false,
}

setmetatable(NetworkController,{__index = ch.NetworkController2})

---
-- 初始化
-- @function [parent=#NetworkController] init
-- @param #NetworkController self
function NetworkController:init()
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self:_sendData()
    end,1,false)
    -- 镀金部分
    zzy.EventManager:listen("S2C_dj_get",function(obj,evt)
        self:magicStarGetData(evt.data)
    end)
    zzy.EventManager:listen("S2C_dj_trans",function(obj,evt)
        self:magicStarTransData(evt.data)
    end)
    -- 镀金部分(批量)
    zzy.EventManager:listen("S2C_dj_getNum",function(obj,evt)
        if evt.data.ret == 0 and evt.data.list and table.maxn(evt.data.list)>0 then 
            for k,v in pairs(evt.data.list) do
                ch.MagicModel:addStar(v,1)
                ch.MoneyModel:addStar(-1)             
            end
            ch.MagicModel:setPlayGetList(evt.data.list)
        end
    end)
    zzy.EventManager:listen("S2C_dj_transNum",function(obj,evt)
        if evt.data.ret == 0 and evt.data.list and table.maxn(evt.data.list)>0 then
            for k,v in pairs(evt.data.list) do
                ch.MagicModel:setRemoveMagicID(v)
                ch.MagicModel:addStar(v,1)
                ch.MagicModel:addStar(self._magicStarOldId,-1)
            end
        end
    end)
    
    zzy.EventManager:listen("S2C_achievement_rank",function(obj,evt)
        if evt.data.ret == 0 then
            ch.StatisticsModel:setMaxRank(evt.data.maxRank)
        end
    end)
    
    --测试
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        zzy.EventManager:listen("S2C_guide_askgold",function(obj,evt)
            if evt.data.ret == 0 then
                DEBUG("获得银币"..evt.data.gold)
                local money = ch.LongDouble:toLongDouble(tostring(evt.data.gold))
                ch.MoneyModel:addGold(money)
            end
        end)
    end
    
    -- 首充奖励
    zzy.EventManager:listen("S2C_shop_changepay",function(obj,evt)
        ch.ShopModel:setfirstPay(1)
    end)
   zzy.EventManager:listen("S2C_shop_firstpay",function(obj,evt)
        if evt.data.ret == 0 then
            ch.PartnerModel:getOne(GameConst.SHOP_FIRST_PAY_REWARD.pet)
            ch.ShopModel:setfirstPay(2)
            if evt.data.diamond then
                ch.MoneyModel:addDiamond(tonumber(evt.data.diamond))
            end
        end
    end)
    -- 七日活动（充值类更改状态）
    zzy.EventManager:listen("S2C_festivity_change",function(obj,evt)
        if evt.data and evt.data.num then
            ch.FestivityModel:setCurNum(evt.data.num)
        end
    end)
    -- 七日活动（排行榜类更改状态）
    zzy.EventManager:listen("S2C_festivity_rank",function(obj,evt)
        if evt.data and evt.data.id then
            ch.FestivityModel:setFestivityState(tonumber(evt.data.id),1)
        end
    end)
    zzy.EventManager:listen("S2C_festivity_today",function(obj,evt)
        if evt.data and evt.data.id then
            ch.FestivityModel:setFestivityState(tonumber(evt.data.id),1)
        end
    end)
    -- 每日限购
    zzy.EventManager:listen("S2C_buylimit_buy",function(obj,evt)
        if not evt.data.err or evt.data.err == 0 then
            ch.MoneyModel:addDiamond(-ch.BuyLimitModel:getTodayData(1).price)
            ch.UIManager:showUpTips(Language.src_clickhero_controller_NetworkController_1)
        elseif evt.data.err == 1 then
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController_2,nil,nil,Language.src_clickhero_controller_NetworkController_3,1)
        end
    end)    
    zzy.EventManager:listen("S2C_buylimit_start",function(obj,evt)
        ch.BuyLimitModel:setStartData(evt.data)
    end)
    
    -- 节日活动开始（初始化数据）
    zzy.EventManager:listen("S2C_holiday_open",function(obj,evt)
        ch.ChristmasModel:openInit(evt.data)
    end)
    
    -- 节日活动停止（终止活动）节日活动停止（终止活动）
    zzy.EventManager:listen("S2C_holiday_stop",function(obj,evt)
        ch.ChristmasModel:stopHoliday(evt.data.type)
    end)
    
    -- 节日活动（限购数量更新）节日活动（限购数量更新）
    zzy.EventManager:listen("S2C_holiday_sdxgPan",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ChristmasModel:setSDXG(evt.data.list)
        end
    end)

    -- 节日活动（连续充值）
    zzy.EventManager:listen("S2C_holiday_lxczData",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ChristmasModel:setLXCZ(evt.data.hdata)
        end
    end)

    -- 节日活动（限购数量更新）节日活动（限购数量更新）
    zzy.EventManager:listen("S2C_holiday_sddhdata",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ChristmasModel:setSDDH(evt.data.hdata)
        end
    end)

    -- 节日活动（限购数量更新）节日活动（限购数量更新）
    zzy.EventManager:listen("S2C_holiday_sdxgPan",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ChristmasModel:setSDXG(evt.data.list)
        end
    end)

    -- 排行榜
    zzy.EventManager:listen("S2C_holiday_loadkfph",function(obj,evt)
        ch.RankListModel:setKfphListData(evt.data)
    end)

    -- 月末飞升
    zzy.EventManager:listen("S2C_holiday_ymfsdata",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ChristmasModel:setYMFS(evt.data.hdata)
        end
    end)
    
    -- 节日活动领奖
    zzy.EventManager:listen("S2C_holiday_get",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_GET_ERROR[tonumber(evt.data.err)],nil,nil,nil,1)
            if evt.data.err == 3 then
                ch.NetworkController:getSdxgPanel()
            end
        elseif evt.data.ret == 0 then
            if evt.data.type == 1003 and evt.data.id then
                ch.MoneyModel:addDiamond(-ch.ChristmasModel:getSDXGPrice(evt.data.id))
                ch.NetworkController:getSdxgPanel()
            end
            ch.CommonFunc:addItems(evt.data.items)
            local tmpData = {}
            tmpData.title = Language.src_clickhero_controller_NetworkController_4
            tmpData.desc = Language.src_clickhero_controller_NetworkController_5
            tmpData.list = evt.data.items
            ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
        end
        self:waitGoldPause(false)
    end)
    
    -- 兑换活动相关
    zzy.EventManager:listen("S2C_holiday_dhMoney",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_GET_ERROR[tonumber(evt.data.err)],nil,nil,nil,1)
            if evt.data.err == 3 then
                ch.NetworkController:getSdxgPanel()
            end
        elseif evt.data.ret == 0 then
            local cfgid = ch.ChristmasModel:getCfgidByType(1001)
            local cfgData = GameConst.HOLIDAY_SDDH_MONEY_DATA[cfgid]
            if evt.data.type == 0 then
                ch.MoneyModel:addDiamond(-cfgData.addCost)
                ch.MoneyModel:addCSock(cfgData.addNum)
            else
                ch.ChristmasModel:setDHGetFreeState(1) 
                ch.MoneyModel:addCSock(cfgData.addNum)
            end
        end
    end)
    
    -- 转盘
    zzy.EventManager:listen("S2C_holiday_zp",function(obj,evt)
        if evt.data.ret == 0 then
            local diamond,times = ch.ChristmasModel:getWheelCost()
            ch.MoneyModel:addDiamond(-diamond)
            ch.ChristmasModel:addWheelCount(times)
            ch.ChristmasModel:setWheelId(evt.data.id)
            ch.ChristmasModel:setWheelReward(evt.data.reward)
            local items = {evt.data.reward}
            ch.CommonFunc:addItems(items)
        else
            ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_GET_ERROR[1])
        end
        self:waitGoldPause(false)
    end)   
    -- 钻石转盘
    zzy.EventManager:listen("S2C_holiday_zszp",function(obj,evt)
        if evt.data.ret == 0 then
            local diamond = ch.ChristmasModel:getDiamondWheelCost()
            ch.MoneyModel:addDiamond(-diamond)
            ch.ChristmasModel:addDiamondWheelCount(1)
            ch.ChristmasModel:setDiamondWheelId(evt.data.id)
            ch.ChristmasModel:setDiamondWheelReward(evt.data.reward)
            local items = {evt.data.reward}
            ch.CommonFunc:addItems(items)
        else
            ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_GET_ERROR[1])
        end
        self:waitGoldPause(false)
    end) 
    -- 好运滚滚(老虎机)
    zzy.EventManager:listen("S2C_holiday_hygg",function(obj,evt)
        if evt.data.ret == 0 then
            local diamond = ch.ChristmasModel:getHYGGCost()
            ch.MoneyModel:addDiamond(-diamond)
            ch.ChristmasModel:addHYGGCount(1)
            ch.ChristmasModel:setHYGGId(evt.data.id)
            ch.ChristmasModel:setHYGGReward(evt.data.reward)
            local items = {evt.data.reward}
            ch.CommonFunc:addItems(items)
        else
            ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_GET_ERROR[1])
        end
        self:waitGoldPause(false)
    end) 
    -- 萌宠送福
    zzy.EventManager:listen("S2C_holiday_mcsf",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ChristmasModel:setHolidayState(1017,evt.data.id,2)
            ch.CommonFunc:addItems(evt.data.items)
            local tmpData = {}
            tmpData.title = Language.src_clickhero_controller_NetworkController_4
            tmpData.desc = Language.src_clickhero_controller_NetworkController_5
            tmpData.list = evt.data.items
            ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
        else
            ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_GET_ERROR[1])
        end
        self:waitGoldPause(false)
    end) 
    -- 红包数量
    zzy.EventManager:listen("S2C_holiday_rbagNum",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ChristmasModel:addRedBagDiamond(evt.data.num)
        end
    end)
    -- 拆红包
    zzy.EventManager:listen("S2C_holiday_redbag",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ChristmasModel:addRedBagOpenNum(1)
            ch.ChristmasModel:addRedBagNoOpenNum(-1)
            ch.ChristmasModel:setRedBagReward(evt.data.reward.num)
            local items = {evt.data.reward}
            ch.CommonFunc:addItems(items)
        else
            ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_GET_ERROR[1])
        end
        self:waitGoldPause(false)
    end) 
	-- 许愿池许愿
    zzy.EventManager:listen("S2C_holiday_xycxy",function(obj,evt)
          if evt.data.error and evt.data.error ~= 0 then
            ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_GET_ERROR[tonumber(evt.data.error)],nil,nil,nil,1)
        elseif evt.data.ret == 0 then
			ch.ChristmasModel:setXYData(evt.data.t,evt.data.id)
        end
    end)
	-- 许愿池领奖
    zzy.EventManager:listen("S2C_holiday_xyclj",function(obj,evt)
        if evt.data.error and evt.data.error ~= 0 then
            ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_GET_ERROR[tonumber(evt.data.error)],nil,nil,nil,1)
        elseif evt.data.ret == 0 then
			ch.CommonFunc:addItems(evt.data.items)
            local tmpData = {}
            tmpData.title = Language.src_clickhero_controller_NetworkController_4
            tmpData.desc = Language.src_clickhero_controller_NetworkController_5
            tmpData.list = evt.data.items
            ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
			ch.ChristmasModel:setXYLJData(evt.data.id)
        end
        self:waitGoldPause(false)
    end)
    -- 充值选礼领奖
    zzy.EventManager:listen("S2C_holiday_czxl",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_GET_ERROR[tonumber(evt.data.err)],nil,nil,nil,1)
        elseif evt.data.ret == 0 then
            ch.ChristmasModel:setCZXLState(evt.data.id,evt.data.rty)
            ch.CommonFunc:addItems(evt.data.items)
            local tmpData = {}
            tmpData.title = Language.src_clickhero_controller_NetworkController_4
            tmpData.desc = Language.src_clickhero_controller_NetworkController_5
            tmpData.list = evt.data.items
            ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
        end
        self:waitGoldPause(false)
    end)
    
    -- 充值选礼活动期间累计钻石
    zzy.EventManager:listen("S2C_holiday_czxlNum",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ChristmasModel:setCZXLDiamond(evt.data.num)
        end
    end)
    
    -- 充值选礼活动期间累计钻石
    zzy.EventManager:listen("S2C_holiday_zszpNum",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ChristmasModel:setZSZPDiamond(evt.data.num)
        end
    end)
    
    -- 消费返礼领奖
    zzy.EventManager:listen("S2C_holiday_xhfl",function(obj,evt)
        if evt.data.error and evt.data.error ~= 0 then
            ch.UIManager:showMsgBox(1,true,GameConst.HOLIDAY_GET_ERROR[tonumber(evt.data.error)],nil,nil,nil,1)
        elseif evt.data.ret == 0 then
            ch.ChristmasModel:setXHFLState(evt.data.id,evt.data.rty)
            ch.CommonFunc:addItems(evt.data.items)
            local tmpData = {}
            tmpData.title = Language.src_clickhero_controller_NetworkController_4
            tmpData.desc = Language.src_clickhero_controller_NetworkController_5
            tmpData.list = evt.data.items
            ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
        end
        self:waitGoldPause(false)
    end)

    -- 消费返礼活动期间累计钻石
    zzy.EventManager:listen("S2C_holiday_xhflNum",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ChristmasModel:addXHFLDiamond(evt.data.num)
        end
    end)
    

    -- 年兽相关，购买爆竹
    zzy.EventManager:listen("S2C_holiday_nsbuy",function(obj,evt)
        if evt.data.ret == 0 then
            if evt.data.error == 0 then
                ch.MoneyModel:addDiamond(-GameConst.CXHD_BASHNIAN_FIRECRACKER_PRICE)
                ch.MoneyModel:addFirecracker(GameConst.CXHD_BASHNIAN_FIRECRACKER_NUM)
            else
                local index = evt.data.error >#Language.CHRISTMAS_VIEW_NIAN_ERROR and 1 or evt.data.error
                ch.UIManager:showMsgBox(1,true,Language.CHRISTMAS_VIEW_NIAN_ERROR[index])
            end
        end
    end)

    -- 年兽相关，刷新年兽
    zzy.EventManager:listen("S2C_holiday_nsref",function(obj,evt)
        if evt.data.ret == 0 then
            if evt.data.error == 0 then
                ch.MoneyModel:addDiamond(-GameConst.CXHD_BASHNIAN_FLASH_PRICE)
                ch.ChristmasModel:resetNianShowTime(os_time())
            else
                local index = evt.data.error >#Language.CHRISTMAS_VIEW_NIAN_ERROR and 1 or evt.data.error
                ch.UIManager:showMsgBox(1,true,Language.CHRISTMAS_VIEW_NIAN_ERROR[index])
            end
        end
    end)

    -- 年兽相关，使用爆竹
    zzy.EventManager:listen("S2C_holiday_nsused",function(obj,evt)
        if evt.data.ret == 0 then
            if evt.data.error == 0 then
                local subHp = evt.data.leftHp - ch.ChristmasModel:getNianHp()
                if evt.data.items then
                    ch.CommonFunc:addItems(evt.data.items)
                end
                ch.ChristmasModel:setNianHp(evt.data.leftHp)
                if evt.data.leftHp == 0 then
                    ch.ChristmasModel:addNiankilled(1)
                end
                ch.ChristmasModel:setNianReward({hp =subHp,items = evt.data.items})
                ch.MoneyModel:addFirecracker(-1)
            else
                local index = evt.data.error >#Language.CHRISTMAS_VIEW_NIAN_ERROR and 1 or evt.data.error
                ch.UIManager:showMsgBox(1,true,Language.CHRISTMAS_VIEW_NIAN_ERROR[index])
            end
        end
        self:waitGoldPause(false)
    end)
    
    
    -- 荣誉金矿相关
    zzy.EventManager:listen("S2C_holiday_glorygold",function(obj,evt)
        if(evt.data.ret==0) then
            ch.ChristmasModel:setGloryGoldData(evt.data)
        end
    end)
    
    
    -- 特殊排行榜
    zzy.EventManager:listen("S2C_matchrank_start",function(obj,evt)
        ch.MatchRankModel:setTime(evt.data)
    end)
    zzy.EventManager:listen("S2C_matchrank_get",function(obj,evt)
        ch.MatchRankModel:setListData(evt.data)
        ch.UIManager:showGamePopup("zhousai/W_zhousaiPH",{typeId=evt.data.typeId,cfgId=evt.data.cfgId})
    end)

    -- 排行榜
    zzy.EventManager:listen("S2C_rk_get",function(obj,evt)
        ch.RankListModel:setMyRank(tonumber(evt.data.num))
        ch.RankListModel:setMyRankPercent(tonumber(evt.data.per))
        ch.RankListModel:setRankListData(evt.data.pl)
    end)
    -- 竞技榜
    zzy.EventManager:listen("S2C_rk_arena",function(obj,evt)
        ch.RankListModel:setArenaListData(evt.data)
    end)
    -- 公会榜
    zzy.EventManager:listen("S2C_rk_guild",function(obj,evt)
        ch.RankListModel:setGuildListData(evt.data)
    end)
    -- 排行榜结算更新
    zzy.EventManager:listen("S2C_rk_update",function(obj,evt)
        ch.RankListModel:setInitData(evt.data)
    end)
    -- 排行榜玩家信息
    zzy.EventManager:listen("S2C_rk_player",function(obj,evt)
        self:rankListPlayerData(evt.data)
    end)
    -- 坚守阵地战绩信息
    zzy.EventManager:listen("S2C_tf_member",function(obj,evt)
        ch.DefendModel:setRankData(evt.data)
    end)
    -- 坚守阵地次数刷新
    zzy.EventManager:listen("S2C_tf_rf",function(obj,evt)
        ch.DefendModel:refreshTimes()
    end)
    -- 公会
    -- 帮会界面
    zzy.EventManager:listen("S2C_guild_panel",function(obj,evt)
        ch.GuildModel:setGuildData(evt.data)
        if ch.GuildModel:ifJoinGuild() then
            ch.UIManager:showBottomPopup("Guild/W_NewGuild_my")
        else
            ch.UIManager:showBottomPopup("Guild/W_NewGuild_cover")
        end
    end)
    -- 帮会签到
    zzy.EventManager:listen("S2C_guild_sign",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            
            if evt.data.err == 99 then
                ch.UIManager:showMsgBox(1,true, Language.GUILD_SIGIN_ERROR_99,nil)
            end
        else
            if evt.data.type == 0 then
                ch.MoneyModel:addDiamond(-GameConst.GUILD_SIGN_COST[ch.GuildModel:myGuildSignNum()])
            end
            ch.GuildModel:addGuildSignNum(1)
            ch.GuildModel:addSignReward(evt.data.items)
        end
    end)
    -- 申请加入公会
    zzy.EventManager:listen("S2C_guild_apply",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            ch.UIManager:showMsgBox(1,true,Language.GUILD_JOIN_ERROR[evt.data.err],nil)
        else
            if evt.data.join == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            else
                ch.GuildModel:myGuildApplyTimeAdd(evt.data.tm)
                ch.NetworkController:refreshGuild()
            end
        end
    end)
    -- 任命副会长
    zzy.EventManager:listen("S2C_guild_appoint",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            if evt.data.err == 3 then
                ch.UIManager:showMsgBox(1,true,Language.GUILD_APPOINT_ERROR,nil)
            end
        else
            ch.NetworkController:guildManage(ch.GuildModel:myGuildID())
        end
    end)
    -- 转让会长
    zzy.EventManager:listen("S2C_guild_transAdmin",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            if evt.data.err == 3 then
                ch.UIManager:showMsgBox(1,true,Language.GUILD_APPOINT_ERROR,nil)
            end
        else
            ch.UIManager:cleanGamePopupLayer(true)
        end
    end)
    -- 弹劾会长
    zzy.EventManager:listen("S2C_guild_impeach",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 or evt.data.err == 2 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            if evt.data.err == 3 or evt.data.err == 4 then
                ch.UIManager:showUpTips(Language.GUILD_IMPEACH_TEXT)
                ch.UIManager:closeGamePopupLayer("Guild/W_NewGuild_memberdetail")
                ch.NetworkController:guildManage(ch.GuildModel:myGuildID())
            end
        else
            ch.UIManager:showUpTips(Language.GUILD_IMPEACH_TEXT)
            ch.UIManager:closeGamePopupLayer("Guild/W_NewGuild_memberdetail")
            ch.NetworkController:guildManage(ch.GuildModel:myGuildID())
        end
    end)
    -- 踢出公会
    zzy.EventManager:listen("S2C_guild_kick",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
        else
            ch.NetworkController:guildManage(ch.GuildModel:myGuildID())
        end
    end)
    -- 下任会长名字
    zzy.EventManager:listen("S2C_guild_nextName",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then

        else
            ch.GuildModel:setMyGuildNextName(evt.data.nextName)
        end
    end)
    -- 加入公会界面
    zzy.EventManager:listen("S2C_guild_rf",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
        else
            ch.GuildModel:setJoinData(evt.data)
        end
    end)
    -- 公会详情界面
    zzy.EventManager:listen("S2C_guild_detail",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            ch.UIManager:showMsgBox(1,true,Language.GUILD_SEARCH_ERROR,nil)
        else
            ch.GuildModel:setDetailData(evt.data)
            ch.UIManager:showGamePopup("Guild/W_NewGuild_information")
--            ch.UIManager:showGamePopup("Guild/W_GuildJoindetail",{type = 1,value = detailData})
        end
    end)
    -- 公会成员管理
    zzy.EventManager:listen("S2C_guild_manage",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            ch.UIManager:showMsgBox(1,true,Language.GUILD_JOIN_ERROR[7],nil)
        else
            ch.GuildModel:setManageData(evt.data)
--            ch.UIManager:showGamePopup("Guild/W_NewGuild_manage")
        end
    end)
    -- 公会加入申请
    zzy.EventManager:listen("S2C_guild_applyPanel",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            ch.UIManager:showMsgBox(1,true,Language.GUILD_JOIN_ERROR[7],nil)
        else
            ch.GuildModel:setApplyPanelData(evt.data)
--            ch.UIManager:showGamePopup("Guild/W_NewGuild_apply")
        end
    end)
    -- 公会加入申请
    zzy.EventManager:listen("S2C_guild_dispose",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 99 then
                ch.UIManager:showMsgBox(1,true,Language.GUILD_DISPOSE_ERROR[5],nil)
            else
                if evt.data.err == 1 then
                    ch.UIManager:cleanGamePopupLayer(true)
                    ch.NetworkController:guildPanel()
                end
                ch.UIManager:showMsgBox(1,true,Language.GUILD_DISPOSE_ERROR[evt.data.err],nil)
            end
        end
        ch.NetworkController:guildApplyPanel()
    end)
    -- 公会成员动态
    zzy.EventManager:listen("S2C_guild_report",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            ch.UIManager:showMsgBox(1,true,Language.GUILD_JOIN_ERROR[7],nil)
        else
            ch.GuildModel:setReportData(evt.data)
            ch.UIManager:showGamePopup("Guild/W_NewGuild_guildmembernews",1)
        end
    end)
    -- 公会卡牌赠予记录
    zzy.EventManager:listen("S2C_guild_cardLog",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            ch.UIManager:showMsgBox(1,true,Language.GUILD_JOIN_ERROR[7],nil)
        else
            ch.GuildModel:setCardLogData(evt.data)
            ch.UIManager:showGamePopup("Guild/W_NewGuild_guildmembernews",2)
        end
    end)
    -- 公会卡牌赠予界面
    zzy.EventManager:listen("S2C_guild_demandPanel",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            ch.UIManager:showMsgBox(1,true,Language.GUILD_JOIN_ERROR[7],nil)
        else
            ch.GuildModel:setDemandPanelData(evt.data)
        end
    end)
    -- 公会卡牌赠予（索要）
    zzy.EventManager:listen("S2C_guild_demandCard",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            ch.NetworkController:guildDemandPanel(ch.GuildModel:myGuildID())
        else
            ch.UIManager:closeGamePopupLayer("card/W_card_guild_give")
            ch.UIManager:showUpTips(Language.GUILD_DEMAND_TIPS)
            ch.GuildModel:addGuildDemandNum(-1)
            ch.NetworkController:guildDemandPanel(ch.GuildModel:myGuildID())
        end
    end)
    -- 公会卡牌赠予（赠予）
    zzy.EventManager:listen("S2C_guild_giveCard",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            ch.UIManager:showMsgBox(1,true,Language.GUILD_GIVE_CARD_ERROR[evt.data.err],nil)
            ch.NetworkController:guildDemandPanel(ch.GuildModel:myGuildID())
        else
            -- 赠送卡牌数按照初始资质算
            local num = GameConst.GUILD_CARD_GIVE_NUM_TALENT[GameConfig.CardConfig:getData(evt.data.cardID).talent]
            ch.PetCardModel:addChip(evt.data.cardID,-num)
            ch.GuildModel:addCardReward()
            ch.NetworkController:guildDemandPanel(ch.GuildModel:myGuildID())
        end
    end)
    -- 公会卡牌赠予（收取）
    zzy.EventManager:listen("S2C_guild_getCard",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            ch.UIManager:showMsgBox(1,true,Language.GUILD_GIVE_CARD_ERROR[evt.data.err],nil)
            ch.NetworkController:guildDemandPanel(ch.GuildModel:myGuildID())
        else
            ch.CommonFunc:addItems(evt.data.items)
            local tmpData = {}
            tmpData.title = Language.src_clickhero_controller_NetworkController_4
            tmpData.desc = Language.src_clickhero_controller_NetworkController_5
            tmpData.list = evt.data.items
            ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
            ch.NetworkController:guildDemandPanel(ch.GuildModel:myGuildID())
        end
    end)
    
    -- 被踢出公会主动推送
    zzy.EventManager:listen("S2C_guild_kickGuild",function(obj,evt)
        if ch.UIManager:getBottomWidget("Guild/W_NewGuild_my") then
            ch.UIManager:cleanGamePopupLayer(true)
            ch.UIManager:showMsgBox(1,true,Language.GUILD_KICKGUILD_ERROR,nil)
        end
    end)
    -- 加入公会
    zzy.EventManager:listen("S2C_guild_join",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 1 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
            end
            ch.UIManager:showMsgBox(1,true,GameConst.GUILD_JOIN_ERROR[evt.data.err],nil)
        else
            ch.GuildModel:addJoinCount(1)
            ch.UIManager:cleanGamePopupLayer(true)
            ch.NetworkController:guildPanel()
--            ch.UIManager:showBottomPopup("Guild/W_GuildList")
        end
    end)
    -- 创建帮会
    zzy.EventManager:listen("S2C_guild_build",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 11 then
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:guildPanel()
                ch.UIManager:showMsgBox(1,true,GameConst.GUILD_JOIN_ERROR[1],nil)
            else
                ch.UIManager:showMsgBox(1,true,GameConst.CNAME_ERROR[evt.data.err],nil)
            end
        else
            ch.MoneyModel:addDiamond(-GameConst.GUILD_BUILD_PRICE)
            ch.GuildModel:setGuildID(evt.data.id)
            ch.UIManager:cleanGamePopupLayer(true)
            ch.NetworkController:guildPanel()
--            ch.UIManager:showBottomPopup("Guild/W_GuildList")
        end
    end)
    -- 改名
    zzy.EventManager:listen("S2C_guild_changeN",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            ch.UIManager:showMsgBox(1,true,GameConst.CNAME_ERROR[evt.data.err],nil)
        else
            ch.MoneyModel:addDiamond(-GameConst.GUILD_CHANGE_NAME_PRICE)
            if self._guildName then
                ch.GuildModel:setGuildName(self._guildName)
            end
            if self._guildFlag then
                ch.GuildModel:setGuildFlag(self._guildFlag)
            end
            ch.UIManager:showUpTips(Language.src_clickhero_view_GuildView_22)
            ch.UIManager:closeGamePopupLayer("Guild/W_NewGuild_change")
        end
    end)
    -- 改旗帜
    zzy.EventManager:listen("S2C_guild_changeF",function(obj,evt)
        if evt.data.ret == 0 then
            ch.MoneyModel:addDiamond(-GameConst.GUILD_CHANGE_FLAG_PRICE)
            ch.GuildModel:setGuildFlag(self._guildFlag)
        end
    end)
    -- 改宣言
    zzy.EventManager:listen("S2C_guild_slogan",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            ch.UIManager:showMsgBox(1,true,GameConst.CNAME_ERROR[evt.data.err],nil)
        else
            if self._guildSlogan then
                ch.GuildModel:setMyGuildSlogan(self._guildSlogan)
            end
            ch.UIManager:showUpTips(Language.src_clickhero_view_GuildView_22)
        end
    end)
    
    -- 公会拉人
    zzy.EventManager:listen("S2C_guild_call",function(obj,evt)
        if evt.data.ret == 0 then
            ch.GuildModel:addCallNum(1)
            if ch.GuildModel:getCallNum() > GameConst.CHAT_GUILD_JOIN_FREE_COUNT then
                ch.MoneyModel:addDiamond(-GameConst.CHAT_GUILD_JOIN_COST)
            end
            ch.UIManager:showUpTips(Language.src_clickhero_view_GuildView_19)
        end
    end)
    -- 新成员加入
    zzy.EventManager:listen("S2C_guild_new",function(obj,evt)
        ch.GuildModel:newMember()
    end)

    zzy.EventManager:listen("S2C_shop_get",function(obj,evt)
        if evt.data.id then
            local num = tonumber(evt.data.num)
            ch.MoneyModel:setMoney(evt.data.id,num)
        end
        if evt.data.totalCharge then
            ch.ShopModel:setTotalCharge(evt.data.totalCharge)
        end
        if evt.data.firstID then
            ch.ShopModel:setFirstID(evt.data.firstID)
        end
    end)
    
    -- 天梯商店刷新
    zzy.EventManager:listen("S2C_randomShop_arenaShop",function(obj,evt)
        if evt.data.type == 0 then
            -- 先扣钱，再加次数
            ch.MoneyModel:addDefeat(-ch.RandomShopModel:getArenaShopPrice())  
            ch.RandomShopModel:addArenaShopCount(1)   
        end       
        ch.RandomShopModel:setArenaShopList(evt.data.list)
        ch.RandomShopModel:setArenaShopCDTime(evt.data.cdTime)
    end)
    
    -- 天梯商店购买
    zzy.EventManager:listen("S2C_randomShop_arenaBuy",function(obj,evt)
        local id = ch.RandomShopModel:getArenaShopList()[tonumber(evt.data.id)].id
        ch.MoneyModel:addDefeat(-GameConfig.Shop_rndConfig:getData(id).price)
        ch.RandomShopModel:addNumById(2,evt.data.id,1)
    end)
    
    -- 黑市商店刷新
    zzy.EventManager:listen("S2C_randomShop_blackShop",function(obj,evt)
        if evt.data.type == 0 then
            -- 先扣钱，再加次数
            ch.MoneyModel:addDiamond(-ch.RandomShopModel:getBlackShopPrice())  
            ch.RandomShopModel:addBlackShopCount(1)   
        end       
        ch.RandomShopModel:setBlackShopList(evt.data.list)
        ch.RandomShopModel:setBlackShopCDTime(evt.data.cdTime)
    end)
    
    -- 黑市商店购买
    zzy.EventManager:listen("S2C_randomShop_blackBuy",function(obj,evt)
        local id = ch.RandomShopModel:getBlackShopList()[tonumber(evt.data.id)].id
        ch.MoneyModel:addDiamond(-GameConfig.Shop_rndConfig:getData(id).price)
        ch.RandomShopModel:addNumById(3,evt.data.id,1)
    end)
    
    -- 公会商店刷新
    zzy.EventManager:listen("S2C_randomShop_guildShop",function(obj,evt)
        if evt.data.type == 0 then
            -- 先扣钱，再加次数
            ch.MoneyModel:addHonour(-ch.RandomShopModel:getGuildShopPrice())  
            ch.RandomShopModel:addGuildShopCount(1)   
        end       
        ch.RandomShopModel:setGuildShopList(evt.data.list)
        ch.RandomShopModel:setGuildShopCDTime(evt.data.cdTime)
    end)

    -- 公会商店购买
    zzy.EventManager:listen("S2C_randomShop_guildBuy",function(obj,evt)
        local id = ch.RandomShopModel:getGuildShopList()[tonumber(evt.data.id)].id
        ch.MoneyModel:addHonour(-GameConfig.Shop_rndConfig:getData(id).price)
        ch.RandomShopModel:addNumById(1,evt.data.id,1)
    end)
    
    --改名
    zzy.EventManager:listen("S2C_cname_cn",function(obj,evt)
        if not evt.data.err or evt.data.err == 0 then
            --修改成功
            -- 注意顺序，先判断是否扣费，再改名加次数
--            if ch.PlayerModel:getChangeNum() >= GameConst.CHANGE_NAME_FREE then
            if ch.PlayerModel:getPlayerGender() and ch.PlayerModel:getPlayerGender() ~= 0 then
                ch.MoneyModel:addDiamond(-GameConst.CHANGE_NAME_PRICE)
            end
            
            if evt.data.name then
                ch.PlayerModel:setPlayerName(evt.data.name)
            end
            if evt.data.gender then
                ch.PlayerModel:setPlayerGender(evt.data.gender)
            end
            if evt.data.name and evt.data.gender then
                ch.UIManager:showUpTips(Language.src_clickhero_controller_NetworkController_6)
            elseif evt.data.name then
                ch.UIManager:showUpTips(Language.src_clickhero_controller_NetworkController_7)
            elseif evt.data.gender then
                ch.UIManager:showUpTips(Language.src_clickhero_controller_NetworkController_8)
            end
            ch.UIManager:closeGamePopupLayer("setting/W_SettingCName_1")
        else
            ch.UIManager:showMsgBox(1,true,GameConst.CNAME_ERROR[evt.data.err],nil)
        end
    end)
    -- 任务过天刷新
    zzy.EventManager:listen("S2C_task_rf",function(obj,evt)
        self:taskRefreshData(evt.data)
    end)
    -- 跨天（服务器主动下行）
    zzy.EventManager:listen("S2C_nextday_rf",function(obj,evt)
        ch.ModelManager:onNextDay()
    end)
    -- 消息界面数据
    zzy.EventManager:listen("S2C_msg_panel",function(sender, evt)
        local msgData = evt.data.list
        ch.MsgModel:addMsgByType(msgData,evt.data.type)
    end)
    -- 添加一条新消息
    zzy.EventManager:listen("S2C_msg_add",function(sender, evt)
        local msgData = evt.data.content
        msgData.dq = "1"
        msgData.open = "false"
        ch.MsgModel:addMsg(msgData)
    end)
    -- 系统公告
    zzy.EventManager:listen("S2C_bro_b",function(obj,evt)
        if evt.data and evt.data.cont then
            ch.UIManager:showNotice(tostring(evt.data.cont))
        end
    end)
    -- 离线收益
    zzy.EventManager:listen("S2C_olgold_re",function(sender, evt)
        if evt.data.ret == 0 then   
            ch.ModelManager:setOffLineGold(ch.LongDouble:toLongDouble(tostring(evt.data.gold)))
        end
    end)
    -- 图腾刷新
    zzy.EventManager:listen("S2C_totem_rf",function(sender, evt)
        if evt.data.ret == 0 then
            ch.TotemModel:_setTotemID(evt.data.totem)
        end
    end)
    -- 图腾获得与刷新
    zzy.EventManager:listen("S2C_totem_get",function(sender, evt)
        if evt.data.ret == 0 and evt.data.totem then
            ch.TotemModel:_setTotemID(evt.data.totem)
        end
    end)
    -- 高级图腾刷新
    zzy.EventManager:listen("S2C_totem_rfS",function(sender, evt)
        if evt.data.ret == 0 then
            ch.TotemModel:setTotemID_senior(evt.data.totem)
        end
    end)
    -- 高级图腾获得与刷新
    zzy.EventManager:listen("S2C_totem_getS",function(sender, evt)
        if evt.data.ret == 0 and evt.data.totem then
            ch.TotemModel:setTotemID_senior(evt.data.totem)
        end
    end)
    -- 神坛升级
    zzy.EventManager:listen("S2C_holyland_up",function(sender, evt)
        if evt.data.ret == 0 then
        end
    end)
    -- 神坛重置
    zzy.EventManager:listen("S2C_holyland_reset",function(sender, evt)
        if evt.data.ret == 0 then
        end
    end)
    local lastGold = ch.MoneyModel:getGold()
    zzy.EventManager:listen(ch.MoneyModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.MoneyModel.dataType.gold then
            if ch.MoneyModel:getGold() > lastGold then
                self:_sendUpData(true)
                self._data.isGoldChanged = true
            end
            lastGold = ch.MoneyModel:getGold() 
        end
    end)
    zzy.EventManager:listen("S2C_sprite_get",function(sender, evt) 
        ch.LevelModel:addSStoneDropData(evt.data.gkid,evt.data.num)
        if evt.data.petCard then
            ch.LevelModel:addCardDropData(evt.data.gkid,evt.data.petCard)
        end
        if evt.data.fc and evt.data.fc > 0 then
            ch.LevelModel:addFirecrackerDropData(evt.data.gkid,evt.data.fc)
        end
        if evt.data.dh and evt.data.dh > 0 then
            ch.LevelModel:addConversionMoneyDropData(evt.data.gkid,evt.data.dh)
        end
    end)
    ch.TotemModel:requitRefresh()
    -- 无尽征途
    zzy.EventManager:listen("S2C_wp_start",function(sender, evt) 
        self:_onStartWarpath(evt)
    end)
    zzy.EventManager:listen("S2C_wp_get",function(sender, evt) 
        self:_onInfoChanged(evt)
    end)
    zzy.EventManager:listen("S2C_wp_info",function(sender, evt) 
        self:_onInfoChanged(evt)
    end)
    zzy.EventManager:listen("S2C_wp_kill",function(sender, evt) 
        self:_onKilledWarpath(evt)
    end)
    zzy.EventManager:listen("S2C_wp_report",function(sender, evt) 
        ch.WarpathModel:setReport(evt.data.list)
    end)
    zzy.EventManager:listen("S2C_wp_addrep",function(sender, evt) 
        ch.WarpathModel:addReport(evt.data.list)
    end)
    zzy.EventManager:listen("S2C_wp_member",function(sender, evt) 
        ch.WarpathModel:setMemberRank(evt.data.list)
    end)
    zzy.EventManager:listen("S2C_wp_rank",function(sender, evt) 
        ch.WarpathModel:setGuildRank(evt.data)
    end)
    zzy.EventManager:listen("S2C_wp_guild",function(sender, evt) 
        ch.WarpathModel:setGuildDetail(evt.data.list)
    end)
    zzy.EventManager:listen("S2C_wp_reward",function(sender, evt)
        local gold = ch.LongDouble:toLongDouble(tostring(evt.data.gold))
        ch.MoneyModel:addGold(gold)
        ch.WarpathModel:setRewardGold(gold)
        ch.WarpathModel:setRewardHonour(evt.data.honour)
        ch.UIManager:showGamePopup("Guild/W_ELresult")
    end)

    zzy.EventManager:listen("S2C_gift_act",function(sender, evt)
        self:_onGetGift(evt)
    end)

    zzy.EventManager:listen("S2C_gift_get",function(sender, evt) 
        self:_onGetItems(evt)
        ch.TimerController.canSend = true
        ch.fightRoleLayer:resume()
    end)
    zzy.EventManager:listen("S2C_cht",function(sender, evt)
        evt.data.c = zzy.StringUtils:FilterSensitiveChar(evt.data.c)
        ch.ChatView:getInstanse():addItem(evt.data)
        if not ch.ChatView:getInstanse():isOpen() then
            ch.ChatModel:addChatCount()
        end
        ch.ChatModel:setChatContent(evt.data)
    end)

    zzy.EventManager:listen("S2C_tf_level",function(sender, evt)
        if evt.data.ret == 0 then
            self:_onDefendLevelVictory(evt.data.reward)
        end
    end)
    -- 手动结束挂机
    zzy.EventManager:listen("S2C_autofight_cancel",function(sender, evt)
        evt.data.reward.gold = ch.LongDouble:toLongDouble(tostring(evt.data.reward.gold))
        evt.data.reward.petGold = ch.LongDouble:toLongDouble(tostring(evt.data.reward.petGold))
        local totalGold = evt.data.reward.gold + evt.data.reward.petGold
        ch.UIManager:showGamePopup("autofight/W_autofight_4",evt.data)
        ch.MoneyModel:addGold(totalGold)
        ch.CommonFunc:playGoldSound(totalGold)
        ch.MoneyModel:addsStone(evt.data.reward.sstone + evt.data.reward.petSstone)
        for id,count in pairs(evt.data.reward.card) do
            ch.PetCardModel:addChipByChipId(tonumber(id),count)
        end
    end)
    -- 自动结束挂机
    zzy.EventManager:listen("S2C_autofight_over",function(sender, evt)
        evt.data.reward.gold = ch.LongDouble:toLongDouble(tostring(evt.data.reward.gold))
        evt.data.reward.petGold = ch.LongDouble:toLongDouble(tostring(evt.data.reward.petGold))
        local totalGold = evt.data.reward.gold + evt.data.reward.petGold
        ch.UIManager:showGamePopup("autofight/W_autofight_4",evt.data)
        ch.MoneyModel:addGold(totalGold)
        ch.CommonFunc:playGoldSound(totalGold)
        ch.MoneyModel:addsStone(evt.data.reward.sstone + evt.data.reward.petSstone)
        for id,count in pairs(evt.data.reward.card) do
            ch.PetCardModel:addChipByChipId(tonumber(id),count)
        end
    end)
    -- 自动结束挂机
    zzy.EventManager:listen("S2C_autofight_superreborn",function(sender, evt)
        evt.data.reward.gold = ch.LongDouble:toLongDouble(tostring(evt.data.reward.gold))
        evt.data.reward.petGold = ch.LongDouble:toLongDouble(tostring(evt.data.reward.petGold))
        local totalGold = evt.data.reward.gold + evt.data.reward.petGold
        ch.UIManager:showGamePopup("autofight/W_autofight_4",evt.data)
        ch.MoneyModel:addGold(totalGold)
        ch.CommonFunc:playGoldSound(totalGold)
        ch.MoneyModel:addsStone(evt.data.reward.sstone + evt.data.reward.petSstone)
        for id,count in pairs(evt.data.reward.card) do
            ch.PetCardModel:addChipByChipId(tonumber(id),count)
        end
        
        self:taskRefresh()
        ch.TaskModel:setTodaySign(0)
        
        if ch.MoneyModel.addGods then
            ch.MoneyModel:addGods(GameConst.REBORN_GODS_NUM or 1)
        end
    end)
    
    -- 普通转生完成
    zzy.EventManager:listen("S2C_reborn_s",function(sender, evt)
        self:taskRefresh()
        ch.TaskModel:setTodaySign(0)
        
        if ch.MoneyModel.addGods then
            ch.MoneyModel:addGods(GameConst.REBORN_GODS_NUM or 1)
        end
    end)

    -- 挂机时的离线奖励
    zzy.EventManager:listen("S2C_autofight_get",function(sender, evt)
        evt.data.offGold = ch.LongDouble:toLongDouble(tostring(evt.data.offGold))
        ch.MoneyModel:addGold(evt.data.offGold)
        ch.CommonFunc:playGoldSound(evt.data.offGold)
    end)
    -- 挂机时的快速过关
    zzy.EventManager:listen("S2C_autofight_jump",function(sender, evt)
        if evt.data.ret == 0 then
            evt.data.reward.gold = ch.LongDouble:toLongDouble(tostring(evt.data.reward.gold))
            evt.data.reward.petGold = ch.LongDouble:toLongDouble(tostring(evt.data.reward.petGold))
            local total = evt.data.reward.gold + evt.data.reward.petGold
            ch.UIManager:showGamePopup("autofight/W_autofight_4",evt.data)        
            ch.MoneyModel:addGold(total)
            ch.CommonFunc:playGoldSound(total)
            ch.MoneyModel:addsStone(evt.data.reward.sstone + evt.data.reward.petSstone)
            for id,count in pairs(evt.data.reward.card) do
                ch.PetCardModel:addChipByChipId(tonumber(id),count)
            end
        end
    end)
    -- 开始挂机
    zzy.EventManager:listen("S2C_autofight_start",function(sender, evt)
        if evt.data.ret == 0 then
            ch.fightRoleLayer:resume()
            if evt.data.err == 0 then -- 都为非月卡
                ch.MoneyModel:addDiamond(-GameConst.AUTO_FIGHT_UNCARDAFK_COST)
                ch.LevelController:startAFK()
            elseif evt.data.err == 1 then -- 都为月卡
                ch.LevelController:startAFK()
            elseif evt.data.err == 2 then -- 客户端月卡，服务器非月卡
                ch.UIManager:showMsgBox(2,true,string.format(Language.src_clickhero_controller_NetworkController_9,GameConst.AUTO_FIGHT_UNCARDAFK_COST),function()
                    ch.fightRoleLayer:pause()
                    ch.NetworkController:startAFK(0)
                end,nil,Language.src_clickhero_controller_NetworkController_10,2)
            elseif evt.data.err == 3 then -- 客户端非月卡，服务器月卡
                ch.UIManager:showMsgBox(2,true,Language.src_clickhero_controller_NetworkController_11,function()
                    ch.fightRoleLayer:pause()
                    ch.NetworkController:startAFK(1)
                end,nil,Language.src_clickhero_controller_NetworkController_12,2)
            end
        end
    end)
    -- 魂石大魔王
    zzy.EventManager:listen("S2C_gk_gbkill",function(obj,evt)
        if evt.data.sStone and evt.data.sStone > 0 then
            ch.MoneyModel:addsStone(evt.data.sStone)
            local data = {victory = 1,
                gold = 0,
                sstoneNum = evt.data.sStone}
            ch.UIManager:showGamePopup("MainScreen/W_TBossresult",data)
        end
    end)
    -- 祭坛界面信息
    zzy.EventManager:listen("S2C_altar_panel",function(obj,evt)
        if evt.data then
            ch.AltarModel:setPanelData(evt.data)
        end
    end)
    -- 掠夺战斗记录
    zzy.EventManager:listen("S2C_altar_robLog",function(obj,evt)
        if evt.data then
            ch.AltarModel:setRobLogData(evt.data.list)
            ch.UIManager:showGamePopup("card/W_jt_zhandoujilu")
        end
    end)
    -- 掠夺界面信息
    zzy.EventManager:listen("S2C_altar_robPanel",function(obj,evt)
        if evt.data then
            ch.AltarModel:setRobPanelData(evt.data)
            ch.UIManager:showGamePopup("card/W_jt_lveduo",evt.data.type)
        end
    end)
    zzy.EventManager:listen("S2C_altar_rob",function(obj,evt)
        if evt.data.ret == 0 then
            if not evt.data.err or evt.data.err == 0 then
                ch.AltarModel:addRobNum(-1)
                if evt.data.num then
                    ch.AltarModel:getExp(evt.data.type,evt.data.num,false)
                    ch.AltarModel:setRobWinData("type",evt.data.type)
                    ch.AltarModel:setRobWinData("num",evt.data.num)
                end
            elseif evt.data.err and evt.data.err == 1 then -- 对方无资源可供掠夺
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController_13,nil)
            elseif evt.data.err and evt.data.err == 2 then -- 对方保护状态
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController_13,nil)
            end
        end
    end)
    -- 天梯界面信息
    zzy.EventManager:listen("S2C_arena_panel",function(obj,evt)
        if evt.data then
            ch.ArenaModel:setPanelData(evt.data)
            ch.UIManager:showGamePopup("card/W_tt")
        end
    end)
    -- 天梯战斗记录
    zzy.EventManager:listen("S2C_arena_pkLog",function(obj,evt)
        if evt.data then
            ch.ArenaModel:setPKLogData(evt.data.list)
            ch.UIManager:showGamePopup("card/W_tt_zhandoujilu")
        end
    end)
    -- 战斗录像
    zzy.EventManager:listen("S2C_arena_play",function(obj,evt)
        if evt.data.err and evt.data.err == 1 then
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController_14,nil)
        end
    end)
    -- 天梯玩家阵容详情
    zzy.EventManager:listen("S2C_arena_player",function(obj,evt)
        if evt.data then
            ch.ArenaModel:setPlayerDetail(evt.data)
            ch.UIManager:showGamePopup("card/W_card_chakan",ch.ArenaModel:getPlayerDetail())
        end
    end)
    -- 天梯挑战
    zzy.EventManager:listen("S2C_arena_pk",function(obj,evt)
        if evt.data.err and evt.data.err == 15 then
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController_15,nil)
        elseif evt.data.err and evt.data.err == 4 then
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController_16,function()
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:arenaPanel()
            end)
        elseif evt.data.err and (evt.data.err == 16 or evt.data.err == 17 or evt.data.err == 18) then
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController_16,function()
                ch.UIManager:cleanGamePopupLayer(true)
                ch.NetworkController:arenaPanel()
            end)
        else
            ch.ArenaModel:addChallengeNum(-1)
            --            ch.UIManager:cleanGamePopupLayer(true)
            --            ch.NetworkController:arenaPanel()
        end
    end)
    -- 天梯补充挑战次数
    zzy.EventManager:listen("S2C_arena_reset",function(obj,evt)
        if evt.data then
            ch.MoneyModel:addDiamond(-GameConst.ARENA_CHALLENGE_COST)
            ch.ArenaModel:addResetNum(-1)
            ch.ArenaModel:addChallengeNum(GameConst.ARENA_CHALLENGE_ADD)
        end
    end)
    -- 天梯领取奖励
    zzy.EventManager:listen("S2C_arena_get",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            if evt.data.err == 15 then
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController_17,nil,nil,nil,1)
            elseif evt.data.err == 1 then
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController_18,nil,nil,nil,1)
            elseif evt.data.err == 2 then
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController_19,nil,nil,nil,1)
            end
        elseif evt.data.ret == 0 then
            ch.ArenaModel:setMyState(2)
            ch.CommonFunc:addItems(evt.data.items)
            local tmpData = {}
            tmpData.title = Language.src_clickhero_controller_NetworkController_4
            tmpData.desc = Language.src_clickhero_controller_NetworkController_5
            tmpData.list = evt.data.items
            ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
        end
    end)
    
    -- 矿区争夺战界面信息
    zzy.EventManager:listen("S2C_mine_panel",function(obj,evt)
        if evt.data then
            ch.MineModel:setMinePanel(evt.data)
        end
    end)
    -- 矿区信息
    zzy.EventManager:listen("S2C_mine_pData",function(obj,evt)
        if evt.data then
            ch.MineModel:setCurPage(evt.data.page)
            ch.MineModel:setPageData(evt.data.list)
        end
    end)
    -- 攻打矿井
    zzy.EventManager:listen("S2C_mine_attack",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            ch.UIManager:showMsgBox(1,true,Language.MINE_ATTACK_ERROR[evt.data.err],nil,nil,nil,1)
        elseif evt.data.ret == 0 then
            if evt.data.win then
                ch.MineModel:setAttackWin(evt.data.win,evt.data.id)
--                if evt.data.win < 2 then
                    ch.MineModel:addAttNum(-1)
--                end
                if evt.data.win == 2 then
                    ch.UIManager:showGamePopup("CardPit/W_pit_occ",evt.data.id)
                end
            end
        end
    end)
    -- 占领矿井
    zzy.EventManager:listen("S2C_mine_occupy",function(obj,evt)
        if evt.data.err and evt.data.err ~= 0 then
            ch.UIManager:showMsgBox(1,true,Language.MINE_OCCUPATION_ERROR[evt.data.err],nil,nil,nil,1) 
        elseif evt.data.ret == 0 then
            if evt.data.id then
                ch.MineModel:setMyMineId(evt.data.id)
                ch.MineModel:setAddBerylNum(evt.data.beryl)
                ch.MineModel:addOccNum(-1)
                self:minePanel()
--                ch.MineModel:setOccTimeCD(os_time()+GameConst.MINE_OCCUPATION_TIME)
--                ch.MineModel:setDefTimeCD(os_time()+GameConst.MINE_SAFE_TIME)
            end
        end
        self:minePageData(ch.MineModel:getCurPage())
    end)
    -- 补充占领次数
    zzy.EventManager:listen("S2C_mine_occAdd",function(obj,evt)
        if evt.data then
            ch.MineModel:addOccNum(GameConst.MINE_OCCUPATION_ADD)
            ch.MineModel:addResetOccNum(-1)
            ch.MoneyModel:addDiamond(-GameConst.MINE_OCCUPATION_RESET_COST)
        end
    end)
    -- 绿宝石奖励结算
    zzy.EventManager:listen("S2C_mine_state",function(obj,evt)
        if evt.data then
            ch.MineModel:setAddBerylNum(evt.data.beryl)
            ch.MineModel:setMyMineState(evt.data.sType)
            if ch.MineModel.isOpen then
                if(evt.data.sType == 1 or evt.data.sType == 4) then
                    self:minePanel()
                end
                if evt.data.sType == 1 then
                    local str = string.format(GameConst.MINE_FIGHT_LOG_DATA[evt.data.sType].win,math.floor(GameConst.MINE_OCCUPATION_TIME/3600))
                    str = str .. string.format(GameConst.MINE_FIGHT_LOG_DATA[evt.data.sType].get,evt.data.beryl)
                    ch.UIManager:showMsgBox(1,true,str,nil,nil,nil,1) 
                elseif evt.data.sType == 2 then
                    local str = GameConst.MINE_FIGHT_LOG_DATA[evt.data.sType].win
                    str = str .. string.format(GameConst.MINE_FIGHT_LOG_DATA[evt.data.sType].get,evt.data.beryl)
                    ch.UIManager:showMsgBox(1,true,str,nil,nil,nil,1) 
                end
                if ch.MineModel:getCurPage() == ch.MineModel:getMyMineZone() then
                    self:minePageData(ch.MineModel:getCurPage())
                end
            end
        end
    end)
    -- 绿宝石全部出售
    zzy.EventManager:listen("S2C_mine_sell",function(obj,evt)
        if evt.data then
            ch.MineModel:setBerylNum(evt.data.num)
        end
    end)
    -- 矿区战斗记录
    zzy.EventManager:listen("S2C_mine_attLog",function(obj,evt)
        if evt.data then
            ch.MineModel:setAttLogData(evt.data.list)
            ch.UIManager:showGamePopup("CardPit/W_pit_jilu")
        end
    end)
    -- 其他人的矿区变化
    zzy.EventManager:listen("S2C_mine_mineChange",function(obj,evt)
        if evt.data then
            self:minePageData(ch.MineModel:getCurPage())
        end
    end)
    
    -- 卡牌挑战
    zzy.EventManager:listen("S2C_cfb_fight",function(obj,evt)
        if evt.data.ret == 0 then
            if evt.data.count > 0 then
                local cost = ch.CardFBModel:getStaminaCost(evt.data.cardId)
                ch.CardFBModel:addStamina(-cost)
                ch.CardFBModel:addFightCount(evt.data.cardId,1)
                local level = ch.CardFBModel:getFBLevel(evt.data.cardId)
                local chipId = GameConfig.CardFBConfig:getData(evt.data.cardId,level).chipId
                local item = {id =evt.data.cardId,chipId = chipId,num = evt.data.count,type = 1}
                ch.PetCardModel:addChipByChipId(chipId,evt.data.count)
                ch.CardFBModel:addFBLevel(evt.data.cardId)
                ch.CardFBModel:setReward(item)
            end

            if evt.data.tl then
                clientTl = ch.CardFBModel:getStamina()
                serverTl = evt.data.tl or clientTl
                addTl = serverTl - clientTl
                if addTl ~= 0 then
                    ch.CardFBModel:addStamina(addTl)
                    DEBUG("体力从%d修正为%d", clientTl, serverTl)
                else
                    DEBUG("前后体力一样，无需修正")
                end
            end
        end
    end)
    -- 卡牌副本领取
    zzy.EventManager:listen("S2C_cfb_lq",function(obj,evt)
        if evt.data.ret == 0 and evt.data.count > 0 and evt.data.cardId then
            local level = ch.CardFBModel:getFBLevel(evt.data.cardId) - 1
            local chipId = GameConfig.CardFBConfig:getData(evt.data.cardId,level).chipId
            local item = {id =evt.data.cardId,chipId = chipId,num = evt.data.count,type = 2}
            ch.PetCardModel:addChipByChipId(chipId,evt.data.count)
            ch.CardFBModel:setReward(item)
            ch.UIManager:showGamePopup("cardInstance/W_Result")
        end

        if evt.data.tl then
            clientTl = ch.CardFBModel:getStamina()
            serverTl = evt.data.tl or clientTl
            addTl = serverTl - clientTl
            if addTl ~= 0 then
                ch.CardFBModel:addStamina(addTl)
                DEBUG("体力从%d修正为%d", clientTl, serverTl)
            else
                DEBUG("前后体力一样，无需修正")
            end
        end
    end)

    -- 分享今日奖励
    zzy.EventManager:listen("S2C_share_today",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ShareModel:updateShareData(evt.data)
            ch.ShareModel:setShareAwardData(evt.data.items)
            ch.CommonFunc:addItems(evt.data.items)
            local tmpData = {}
            tmpData.title = Language.src_clickhero_controller_NetworkController_20
            tmpData.desc = Language.src_clickhero_controller_NetworkController_21
            tmpData.list = evt.data.items
            ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
        end
    end)
    
    -- 分享成就奖励
    zzy.EventManager:listen("S2C_share_achi",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ShareModel:updateShareData(evt.data)
            ch.ShareModel:setShareAwardData(evt.data.items)
            ch.CommonFunc:addItems(evt.data.items)
            local tmpData = {}
            tmpData.title = Language.src_clickhero_controller_NetworkController_20
            tmpData.desc = Language.src_clickhero_controller_NetworkController_21
            tmpData.list = evt.data.items
            ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
        end
    end)

    -- 卡牌副本领取体力
    zzy.EventManager:listen("S2C_cfb_ft",function(obj,evt)
        if evt.data.ret == 0 then
            if evt.data.error == 0 then
                local oldS = ch.CardFBModel:getStamina()
                local num = GameConst.CARD_FB_FREE_TL
                if ch.ChristmasModel:isOpenByType(1010) then
                    num = GameConst.CARD_FB_FREE_TL * ch.ChristmasModel:getHDataByType(1010).ratio
                end
                ch.CardFBModel:addStamina(num)
                local index = ch.CardFBModel:getCurFetchIndex()
                if index > 0 then
                    ch.CardFBModel:setFetched(index,true)
                end
                ch.UIManager:showMsgBox(1,true,string.format(GameConst.CARD_FB_TL_GET_TIP,oldS,oldS+num))
            elseif evt.data.error == 1 then
                local str
                local index = ch.CardFBModel:getNextFetchIndex()
                if index < 0 then
                    str = GameConst.CARD_FB_NEXTDAY_TIP
                    index = 1
                else
                    str = ""    
                end
                str = str.. GameConst.FORMAT_NUM_TO_TIME(GameConst.CARD_FB_TL_TIME[index].startTime)
                ch.UIManager:showMsgBox(1,true,string.format(GameConst.CARD_FB_TL_ERROE_TIP[1],str))
            else
                ch.UIManager:showMsgBox(1,true,GameConst.CARD_FB_TL_ERROE_TIP[2])
            end
        end
    end)
    
    zzy.EventManager:listen("S2C_fight_card",function(obj,evt)
        ch.UIManager:cleanGamePopupLayer(true)
        ch.LevelController:startCardFight(evt.data.attacker,evt.data.defender,evt.data.randomSeed,evt.data.fightType,evt.data.win)
    end)
	
	-- facebook绑定
    zzy.EventManager:listen("S2C_fbbind_bind",function(obj,evt)
        if evt.data.ret == 0 and   evt.data.error == 0 then
			ch.CommonFunc:addItems({evt.data.items})
            local tmpData = {}
            tmpData.title = Language.src_clickhero_controller_NetworkController_4
            tmpData.desc = Language.src_clickhero_controller_NetworkController_5 
            tmpData.list = {evt.data.items}
            ch.UIManager:showGamePopup("setting/W_SNbonus",tmpData)
        end
    end)
    
    -- 获取可购买新手礼包的截止时间
    zzy.EventManager:listen("S2C_shop_gifttime",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ShopModel:setGiftBagState(0)
            ch.ShopModel:setGiftBagTime(evt.data.endtime)
        end
    end)
    
    -- 购买新手礼包
    zzy.EventManager:listen("S2C_shop_buygift",function(obj,evt)
        if evt.data.ret == 0 then
            ch.ShopModel:setGiftBagState(1)
            ch.CommonFunc:addItems(GameConst.LEVEL10_GIFT_BAG.items)
            ch.MoneyModel:addDiamond(-GameConst.LEVEL10_GIFT_BAG.currentPrice)
        end
    end)
    
end


function NetworkController:clean()
    self._data.magicLevelUpData = {}
    self._data.runicLevelUpData = {}
    self._data.levelData = {}
    self._data.isGoldChanged = false
    self._magicStarOldId = "1"
    self._guildName = ""
    self._guildId = ""
    self._guildSlogan = ""
    self._flag = 1
    self._waitGold = false
end


---
-- 发言
-- @function [parent=#NetworkController] sendChat
-- @param #NetworkController self
-- @param #string channel
-- @param #string content
function NetworkController:sendChat(channel,content)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "say"
    evt.data = {
        f = "s",
        t = channel,
        tm = math.ceil(os_time()),
        c = content.." "
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 发送fb绑定领奖
-- @function [parent=#NetworkController] sendFBBind
-- @param #NetworkController self
-- @param #string channel
-- @param #string content
function NetworkController:sendFBBind()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "fbbind"
    evt.data = {
        f = "bind",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end


---
-- 合成卡牌
-- @function [parent=#NetworkController] getNewCard
-- @param #NetworkController self
-- @param #number id
function NetworkController:getNewCard(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "petcard"
    evt.data = {
        f = "get",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 卡牌进阶(type为1是用万能符文，0为不用万能符文，num为使用万能符文数量)
-- @function [parent=#NetworkController] cardLevelUp
-- @param #NetworkController self
-- @param #number id
-- @param #number type
-- @param #number num
function NetworkController:cardLevelUp(id,type,num)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "petcard"
    evt.data = {
        f = "up",
        id = id,
        type = type,
        num = num,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 卡牌品质提升
-- @function [parent=#NetworkController] talentUp
-- @param #NetworkController self
-- @param #number id
function NetworkController:talentUp(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "petcard"
    evt.data = {
        f = "talentUp",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 能量同步
-- @function [parent=#NetworkController] PowerCheck
-- @param #NetworkController self
-- @param #number curPower
-- @param #number usedPower
function NetworkController:PowerCheck(curPower,usedPower)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "power"
    evt.data = {
        f = "check",
        curPower = curPower,
        used = usedPower,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 开始挂机
-- @function [parent=#NetworkController] startAFK
-- @param #NetworkController self
-- @param #number type
function NetworkController:startAFK(type)
    self:sendCacheData()
    local maxLevel,time = ch.AFKModel:getAFKLevelAndTime()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "autofight"
    evt.data = {
        f = "start",
        level = ch.LevelModel:getCurLevel(),
        num = ch.LevelModel:getTotalCount(ch.LevelModel:getCurLevel()),
        time = time,
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 手动停止挂机
-- @function [parent=#NetworkController] stopAFK
-- @param #NetworkController self
function NetworkController:stopAFK()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "autofight"
    evt.data = {
        f = "cancel",
        level = ch.LevelModel:getCurLevel(),
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 挂机自动结束
-- @function [parent=#NetworkController] autoStopAFK
-- @param #NetworkController self
function NetworkController:autoStopAFK()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "autofight"
    evt.data = {
        f = "over",
        level = ch.LevelModel:getCurLevel(),
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 领取挂机奖励
-- @function [parent=#NetworkController] getAFKReward
-- @param #NetworkController self
function NetworkController:getAFKReward()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "autofight"
    evt.data = {
        f = "get",
        level = ch.LevelModel:getCurLevel(),
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    self:clearLevelData()
end

---
-- 请求展示信息
-- @function [parent=#NetworkController] AFKRewardPreview
-- @param #NetworkController self
--function NetworkController:AFKRewardPreview()
--    local evt = zzy.Events:createC2SEvent()
--    evt.cmd = "autofight"
--    evt.data = {
--        f = "see",
--        tm = math.ceil(os_time())
--    }
--    zzy.EventManager:dispatch(evt)
--end

---
-- 快速过关
-- @function [parent=#NetworkController] AFKSkipLevel
-- @param #NetworkController self
-- @param #number level
function NetworkController:AFKSkipLevel(level)
    self._jumpLevel = level
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "autofight"
    evt.data = {
        f = "jump",
        level = ch.LevelModel:getCurLevel(),
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求祭坛界面信息
-- @function [parent=#NetworkController] altarPanel
-- @param #NetworkController self
-- @param #number type
function NetworkController:altarPanel(type)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "altar"
    evt.data = {
        f = "panel",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求祭坛战斗记录
-- @function [parent=#NetworkController] altarRobLog
-- @param #NetworkController self
function NetworkController:altarRobLog()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "altar"
    evt.data = {
        f = "robLog",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求祭坛掠夺补充次数
-- @function [parent=#NetworkController] altarReset
-- @param #NetworkController self
function NetworkController:altarReset()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "altar"
    evt.data = {
        f = "reset",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 祭坛增加氪金保存数
-- @function [parent=#NetworkController] upStoneLimit
-- @param #NetworkController self
-- @param #number type
function NetworkController:upStoneLimit(type)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "altar"
    evt.data = {
        f = "upStoneLimit",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 升级祭坛
-- @function [parent=#NetworkController] altarUpLevel
-- @param #NetworkController self
-- @param #number type
function NetworkController:altarUpLevel(type)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "altar"
    evt.data = {
        f = "upLevel",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 领取氪金
-- @function [parent=#NetworkController] altarAddExp
-- @param #NetworkController self
-- @param #number type
function NetworkController:altarAddExp(type)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "altar"
    evt.data = {
        f = "addExp",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求祭坛掠夺界面信息
-- @function [parent=#NetworkController] altarRobPanel
-- @param #NetworkController self
-- @param #number type
function NetworkController:altarRobPanel(type)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "altar"
    evt.data = {
        f = "robPanel",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 祭坛掠夺
-- @function [parent=#NetworkController] altarRob
-- @param #NetworkController self
-- @param #string id
-- @param #number type
function NetworkController:altarRob(id,type)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "altar"
    evt.data = {
        f = "rob",
        userid = id,
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 祭坛防守阵容更换
-- @function [parent=#NetworkController] changeMyAltarList
-- @param #NetworkController self
-- @param #number type
-- @param #table cardList
function NetworkController:changeMyAltarList(type,cardList)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "altar"
    evt.data = {
        f = "groupChg",
        type = type,
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
-- 请求天梯界面信息
-- @function [parent=#NetworkController] arenaPanel
-- @param #NetworkController self
function NetworkController:arenaPanel()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "arena"
    evt.data = {
        f = "panel",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求天梯战斗记录
-- @function [parent=#NetworkController] arenaPKLog
-- @param #NetworkController self
function NetworkController:arenaPKLog()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "arena"
    evt.data = {
        f = "pkLog",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求天梯领奖
-- @function [parent=#NetworkController] arenaGetReward
-- @param #NetworkController self
function NetworkController:arenaGetReward()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "arena"
    evt.data = {
        f = "get",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求天梯补充次数
-- @function [parent=#NetworkController] arenaReset
-- @param #NetworkController self
function NetworkController:arenaReset()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "arena"
    evt.data = {
        f = "reset",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求玩家阵容详情
-- @function [parent=#NetworkController] arenaPlayer
-- @param #NetworkController self
-- @param #string id
-- @param #number rank
-- @param #number type
function NetworkController:arenaPlayer(id,rank,type)
    if id == "" or id == nil then
        return
    end
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "arena"
    evt.data = {
        f = "player",
        userid = id,
        rank = rank,
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 出战阵容更换
-- @function [parent=#NetworkController] changeMyCardList
-- @param #NetworkController self
-- @param #table cardList
function NetworkController:changeMyCardList(cardList)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "arena"
    evt.data = {
        f = "groupChg",
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
-- 战斗记录回放
-- @function [parent=#NetworkController] arenaPlay
-- @param #NetworkController self
-- @param #number fty
-- @param #number ftime
-- @param #string id1
-- @param #string id2
function NetworkController:arenaPlay(fty,ftime,id1,id2)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "arena"
    evt.data = {
        f = "play",
        id1 = id1,
        id2 = id2,
        fty = fty,
        ftime = ftime,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 天梯挑战
-- @function [parent=#NetworkController] arenaPK
-- @param #NetworkController self
-- @param #string id
-- @param #number rank
function NetworkController:arenaPK(id,rank)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "arena"
    evt.data = {
        f = "pk",
        userid = id,
        rank = rank,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 卡牌副本挑战
-- @function [parent=#NetworkController] cardFBFight
-- @param #NetworkController self
-- @param #string id
function NetworkController:cardFBFight(id)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "cfb"
    evt.data = {
        f = "fight",
        id  = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 卡牌副本领取
-- @function [parent=#NetworkController] cardFBFetch
-- @param #NetworkController self
-- @param #string id
function NetworkController:cardFBFetch(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "cfb"
    evt.data = {
        f = "lq",
        id  = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 卡牌副本重置
-- @function [parent=#NetworkController] cardFBReset
-- @param #NetworkController self
-- @param #string id
function NetworkController:cardFBReset(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "cfb"
    evt.data = {
        f = "reset",
        id  = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 卡牌副本购买体力
-- @function [parent=#NetworkController] cardFBBuy
-- @param #NetworkController self
function NetworkController:cardFBBuy()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "cfb"
    evt.data = {
        f = "buy",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 卡牌副本每日领取体力
-- @function [parent=#NetworkController] cardFBFetchStamina
-- @param #NetworkController self
function NetworkController:cardFBFetchStamina()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "cfb"
    evt.data = {
        f = "ft",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 节日活动领取奖励（签到，兑换，限购）
-- @function [parent=#NetworkController] getHolidayReward
-- @param #NetworkController self
-- @param #number type
-- @param #number id
-- @param #number day
function NetworkController:getHolidayReward(type,id,day)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "get",
        type = type,
        id = id,
        day = day,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    self:waitGoldPause(true)
end

---
-- 兑换活动领取元宵
-- @function [parent=#NetworkController] dhMoneyGet
-- @param #NetworkController self
-- @param #number type 领取类型
function NetworkController:dhMoneyGet(type, cost)
    self:sendCacheData()

    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "dhMoney",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 转盘
-- @function [parent=#NetworkController] startWheel
-- @param #NetworkController self
-- @param #number times 倍率
function NetworkController:startWheel(times)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "zp",
        times = times,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    self:waitGoldPause(true)
end

---
-- 钻石转盘
-- @function [parent=#NetworkController] startDiamondWheel
-- @param #NetworkController self
function NetworkController:startDiamondWheel()
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "zszp",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    self:waitGoldPause(true)
end

---
-- 好运滚滚(老虎机)
-- @function [parent=#NetworkController] startHYGG
-- @param #NetworkController self
function NetworkController:startHYGG()
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "hygg",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    self:waitGoldPause(true)
end

---
-- 拆红包
-- @function [parent=#NetworkController] openRedBag
-- @param #NetworkController self
function NetworkController:openRedBag()
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "redbag",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    self:waitGoldPause(true)
end

---
-- 节日活动限购相关面板数据
-- @function [parent=#NetworkController] getSdxgPanel
-- @param #NetworkController self
function NetworkController:getSdxgPanel()
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "sdxgPan",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 开服排行获取榜单数据
-- @function [parent=#NetworkController] getSdxgPanel
-- @param #NetworkController self
function NetworkController:getKfphPanel()
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "loadkfph",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 节日活动限购相关面板数据
-- @function [parent=#NetworkController] getSdxgPanel
-- @param #NetworkController self
function NetworkController:getSddhPanel()
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "sddhdata",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 充值选礼领取奖励
-- @function [parent=#NetworkController] getCZXLReward
-- @param #NetworkController self
-- @param #number id
-- @param #number rType
function NetworkController:getCZXLReward(id,rType)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "czxl",
        id = id,
        rty = rType,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    self:waitGoldPause(true)
end

---
-- 许愿池许愿
-- @function [parent=#NetworkController] xycXY
-- @param #NetworkController self
-- @param #number type
-- @param #number id
function NetworkController:xycXY(type,id)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "xycxy",
        t = type,
        tm = math.ceil(os_time())
    }
	if type==1 then
		evt.data.id = id
	end
    zzy.EventManager:dispatch(evt)
end

---
-- 许愿池领奖
-- @function [parent=#NetworkController] xycLJ
-- @param #NetworkController self
-- @param #number id
function NetworkController:xycLJ(id)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "xyclj",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    self:waitGoldPause(true)
end

---
-- 消费返礼领取奖励
-- @function [parent=#NetworkController] getXHFLReward
-- @param #NetworkController self
-- @param #number id
-- @param #number rType
function NetworkController:getXHFLReward(id,rType)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "xhfl",
        id = id,
        rty = rType,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    self:waitGoldPause(true)
end

---
-- 发送荣耀金矿请求
-- @function [parent=#NetworkController] sendGloryGold
-- @param #NetworkController self
function NetworkController:sendGloryGold()
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "glorygold",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 宝物镀金(批量)
-- @function [parent=#NetworkController] magicStarNum
-- @param #NetworkController self
-- @param #number num
function NetworkController:magicStarNum(num)
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "dj"
    evt.data = {
        f = "getNum",
        num = num,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 宝物镀金转移(批量)
-- @function [parent=#NetworkController] magicStarTransNum
-- @param #NetworkController self
-- @param #string oldId 原宝物id
-- @param #string type 0为钻石1为魂
-- @param #number num
function NetworkController:magicStarTransNum(oldId,type,num)
    self._magicStarOldId = oldId
    self:_sendUpData(false)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "dj"
    evt.data = {
        f = "transNum",
        srcid = oldId,
        type = type,
        num = num,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    if tostring(type) == "0" then
        ch.MoneyModel:addDiamond(-GameConst.MGAIC_STAR_PRICE_DIAMOND*num)
        ch.ShopModel:addDiamondStar(num)
    else
        ch.MoneyModel:addSoul(-GameConst.MGAIC_STAR_PRICE*num)
        ch.ShopModel:addStarSoulCount(-num)
    end
end

---
-- 请求我的矿区信息
-- @function [parent=#NetworkController] minePanel
-- @param #NetworkController self
function NetworkController:minePanel()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "mine"
    evt.data = {
        f = "panel",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求矿区界面信息
-- @function [parent=#NetworkController] minePageData
-- @param #NetworkController self
-- @param #number page
function NetworkController:minePageData(page)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "mine"
    evt.data = {
        f = "pData",
        page = page,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 攻打矿井
-- @function [parent=#NetworkController] attackMine
-- @param #NetworkController self
-- @param #number id
-- @param #string userid
function NetworkController:attackMine(id,userid)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "mine"
    evt.data = {
        f = "attack",
        id = id,
        userid = userid,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 占领矿井(取消cancel为1，占领不传cancel)
-- @function [parent=#NetworkController] occupyMine
-- @param #NetworkController self
-- @param #number id
-- @param #number cancel
function NetworkController:occupyMine(id,cancel)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "mine"
    evt.data = {
        f = "occupy",
        id = id,
        cancel = cancel,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 补充占领矿井次数
-- @function [parent=#NetworkController] occAddMine
-- @param #NetworkController self
function NetworkController:occAddMine()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "mine"
    evt.data = {
        f = "occAdd",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 绿宝石全部出售
-- @function [parent=#NetworkController] sellBeryl
-- @param #NetworkController self
-- @param #number beryl
-- @param #number gold
function NetworkController:sellBeryl(beryl,gold)
    local tmoney = ch.MoneyModel:getGold()
    tmoney = tmoney + gold
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "mine"
    evt.data = {
        f = "sell",
        beryl = beryl,
        gold = gold,
        tmoney = tmoney,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    ch.MineModel:addBerylNum(-beryl)
    ch.MoneyModel:addGold(gold)
    
    --立刻同步数据
    self:sendFixedTimeData()
end

---
-- 请求矿区战斗记录
-- @function [parent=#NetworkController] mineAttLog
-- @param #NetworkController self
function NetworkController:mineAttLog()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "mine"
    evt.data = {
        f = "attLog",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 关闭矿区界面
-- @function [parent=#NetworkController] minePanelClose
-- @param #NetworkController self
function NetworkController:minePanelClose()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "mine"
    evt.data = {
        f = "close",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 使用爆竹
-- @function [parent=#NetworkController] useFirecracker
-- @param #NetworkController self
function NetworkController:useFirecracker()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "nsused",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    self:waitGoldPause(true)
end

---
-- 刷新年兽
-- @function [parent=#NetworkController] clearNianCD
-- @param #NetworkController self
function NetworkController:clearNianCD()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "nsref",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 购买爆竹
-- @function [parent=#NetworkController] buyFirecracker
-- @param #NetworkController self
function NetworkController:buyFirecracker()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "nsbuy",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 萌宠送福领奖
-- @function [parent=#NetworkController] getMCSFReward
-- @param #NetworkController self
-- @param #number id
function NetworkController:getMCSFReward(id)
    self:sendCacheData()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "holiday"
    evt.data = {
        f = "mcsf",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
    self:waitGoldPause(true)
end

---
-- 天梯商店请求刷新
-- @function [parent=#NetworkController] arenaShopRefresh
-- @param #NetworkController self
-- @param #number type
function NetworkController:arenaShopRefresh(type)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "randomShop"
    evt.data = {
        f = "arenaShop",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 天梯商店购买
-- @function [parent=#NetworkController] arenaShopBuy
-- @param #NetworkController self
-- @param #number id
function NetworkController:arenaShopBuy(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "randomShop"
    evt.data = {
        f = "arenaBuy",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 黑市商店请求刷新
-- @function [parent=#NetworkController] blackShopRefresh
-- @param #NetworkController self
-- @param #number type
function NetworkController:blackShopRefresh(type)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "randomShop"
    evt.data = {
        f = "blackShop",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 黑市商店购买
-- @function [parent=#NetworkController] blackShopBuy
-- @param #NetworkController self
-- @param #number id
function NetworkController:blackShopBuy(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "randomShop"
    evt.data = {
        f = "blackBuy",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会商店请求刷新
-- @function [parent=#NetworkController] guildShopRefresh
-- @param #NetworkController self
-- @param #number type
function NetworkController:guildShopRefresh(type)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "randomShop"
    evt.data = {
        f = "guildShop",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会商店购买
-- @function [parent=#NetworkController] guildShopBuy
-- @param #NetworkController self
-- @param #number id
function NetworkController:guildShopBuy(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "randomShop"
    evt.data = {
        f = "guildBuy",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会签到
-- @function [parent=#NetworkController] guildSign
-- @param #NetworkController self
-- @param #number type
function NetworkController:guildSign(type)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "sign",
        type = type,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会升级(level升级后等级)
-- @function [parent=#NetworkController] guildLevelUp
-- @param #NetworkController self
-- @param #string id
-- @param #number level
function NetworkController:guildLevelUp(id,level)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "lvup",
        id = id,
        level = level,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会宣言修改
-- @function [parent=#NetworkController] guildSloganChange
-- @param #NetworkController self
-- @param #string id
-- @param #string str
function NetworkController:guildSloganChange(id,str)
    self._guildSlogan = str
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "slogan",
        id = id,
        txt = str,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 申请加入公会
-- @function [parent=#NetworkController] guildApply
-- @param #NetworkController self
-- @param #string id
function NetworkController:guildApply(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "apply",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会管理界面
-- @function [parent=#NetworkController] guildManage
-- @param #NetworkController self
-- @param #string id
function NetworkController:guildManage(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "manage",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 任命副会长 1任职2撤职
-- @function [parent=#NetworkController] guildAppoint
-- @param #NetworkController self
-- @param #string id
-- @param #string userid
-- @param #number state
function NetworkController:guildAppoint(id,userid,state)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "appoint",
        id = id,
        userid = userid,
        state = state,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 转让会长
-- @function [parent=#NetworkController] guildAppoint
-- @param #NetworkController self
-- @param #string id
-- @param #string userid
-- @param #number state
function NetworkController:guildTransAdmin(userid)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "transAdmin",
        id = userid,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 弹劾会长
-- @function [parent=#NetworkController] guildImpeach
-- @param #NetworkController self
-- @param #string id
-- @param #string userid
function NetworkController:guildImpeach(id,userid)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "impeach",
        id = id,
        userid = userid,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 申请列表
-- @function [parent=#NetworkController] guildApplyPanel
-- @param #NetworkController self
function NetworkController:guildApplyPanel()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "applyPanel",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会申请同意或拒绝申请 1同意2拒绝
-- @function [parent=#NetworkController] guildDispose
-- @param #NetworkController self
-- @param #string id
-- @param #string userid
-- @param #number state
function NetworkController:guildDispose(id,userid,state)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "dispose",
        id = id,
        userid = userid,
        state = state,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会设置申请条件(允许最低关卡)
-- @function [parent=#NetworkController] guildApplyLevel
-- @param #NetworkController self
-- @param #number maxLevel
function NetworkController:guildApplyLevel(maxLevel)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "applyLV",
        maxLevel = maxLevel,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会申请是否自动同意（0不自动1自动）
-- @function [parent=#NetworkController] guildApplyAuto
-- @param #NetworkController self
-- @param #number state
function NetworkController:guildApplyAuto(state)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "applyAuto",
        state = state,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会成员动态
-- @function [parent=#NetworkController] guildReport
-- @param #NetworkController self
function NetworkController:guildReport()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "report",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 请求下任会长名字
-- @function [parent=#NetworkController] guildNextName
-- @param #NetworkController self
function NetworkController:guildNextName()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "nextName",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会符文互赠活动界面
-- @function [parent=#NetworkController] guildDemandPanel
-- @param #NetworkController self
-- @param #string id
function NetworkController:guildDemandPanel(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "demandPanel",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会符文互赠活动（索要）
-- @function [parent=#NetworkController] guildDemandCard
-- @param #NetworkController self
-- @param #string id
-- @param #number cardID
function NetworkController:guildDemandCard(id,cardID)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "demandCard",
        id = id,
        cardID = cardID,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会符文互赠活动（赠予）
-- @function [parent=#NetworkController] guildGiveCard
-- @param #NetworkController self
-- @param #string id
-- @param #number cardID
-- @param #string userId
function NetworkController:guildGiveCard(id,cardID,userId)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "giveCard",
        id = id,
        cardID = cardID,
        userId = userId,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会符文互赠活动（收取）
-- @function [parent=#NetworkController] guildGetCard
-- @param #NetworkController self
-- @param #string id
function NetworkController:guildGetCard(id)
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "getCard",
        id = id,
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 公会符文赠送记录
-- @function [parent=#NetworkController] guildCardLog
-- @param #NetworkController self
function NetworkController:guildCardLog()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "cardLog",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 获取可购买新手礼包的截止时间
-- @function [parent=#NetworkController] getGiftBagEndTime
-- @param #NetworkController self
function NetworkController:getGiftBagEndTime()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "shop"
    evt.data = {
        f = "gifttime",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 购买新手礼包
-- @function [parent=#NetworkController] buyGiftBag
-- @param #NetworkController self
function NetworkController:buyGiftBag()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "shop"
    evt.data = {
        f = "buygift",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end
-- 公会附魔
-- @function [parent=#NetworkController] guildEnchantment
-- @param #NetworkController self
function NetworkController:guildEnchantment()
    local evt = zzy.Events:createC2SEvent()
    evt.cmd = "guild"
    evt.data = {
        f = "enchantment",
        tm = math.ceil(os_time())
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 等待下行加金币暂停游戏
-- @function [parent=#NetworkController] waitGoldPause
-- @param #NetworkController self
-- @param #boolean isWait
function NetworkController:waitGoldPause(isWait)
    -- 加金币后同步
    if isWait then
        ch.fightRoleLayer:pause()
        self._waitGold = isWait
    else
        ch.fightRoleLayer:resume()
        self._waitGold = isWait
        self:sendFixedTimeData()
    end
end

return NetworkController