---
-- 公会model层
--@module GuildModel
local GuildModel = {
    _data = nil,
    _joinData = nil,
    _detailData = nil,
    _manageData = nil,
    _cardLogData = nil,
    _demandPanelData = nil,
    _enchantmentData = nil,
    _newTag = false,
    _nextName = nil,
    dataChangeEventType = "GuildModelDataChange",
    dataType = {
        panel = 1,
        detail = 2,
        search = 3,
        name = 4,
        flag = 5,
        new = 6,
        call = 7,
        sign = 8,
        guildExp = 9,
        personExp = 10,
        apply = 11,
        manage = 12,
        level = 13,
        report = 14,
        applyPanel = 15,
        nextName = 16,
        demand = 17,
        give = 18,
        cardLog = 19,
        demandPanel = 20,
        enchantment = 21
    }
}

---
-- @function [parent=#GuildModel] init
-- @param #GuildModel self
-- @param #table data
function GuildModel:init(data)
    self._data = {}
    if data.guild and data.guild.enchantment then
        self._enchantmentData = data.guild.enchantment
    else
        self._enchantmentData = {level=1,exp=0}
    end
end

---
-- @function [parent=#GuildModel] clean
-- @param #GuildModel self
function GuildModel:clean()
    self._data = nil
    self._joinData = nil
    self._detailData = nil
    self._manageData = nil
    self._cardLogData = nil
    self._demandPanelData = nil
    self._newTag = false
    self._nextName = nil
end

function GuildModel:_raiseDataChangeEvent(id,dataType)
    local evt = {
        type = self.dataChangeEventType,
        id = id,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 帮会界面信息
-- @function [parent=#GuildModel] setGuildData
-- @param #GuildModel self
-- @param #table data
function GuildModel:setGuildData(data)
    self._data = data
    self:_raiseDataChangeEvent("0",self.dataType.panel)
end

---
-- 自己是否加入公会
-- @function [parent=#GuildModel] ifJoinGuild
-- @param #GuildModel self
-- @return #boolean
function GuildModel:ifJoinGuild()
    if self._data.id and self._data.id ~= "" then
        return true
    else
        return false
    end
end

---
-- 搜索到的公会信息列表
-- @function [parent=#GuildModel] getGuildMemberList
-- @param #GuildModel self
-- @return #table
function GuildModel:getGuildMemberList()
    if self._joinData and self._joinData.list then
        table.sort(self._joinData.list,function(t1,t2)
            return t1.level >t2.level
        end)
        return self._joinData.list
    end
    return {}
end

---
-- 加入公会界面信息
-- @function [parent=#GuildModel] setJoinData
-- @param #GuildModel self
-- @param #table data
function GuildModel:setJoinData(data)
    self._joinData = data
    self:_raiseDataChangeEvent("0",self.dataType.search)
end

---
-- 查看公会成员管理界面信息
-- @function [parent=#GuildModel] setManageData
-- @param #GuildModel self
-- @param #table data
function GuildModel:setManageData(data)
    self._manageData = data
    self:_raiseDataChangeEvent("0",self.dataType.manage)
end

---
-- 查看公会成员管理界面信息
-- @function [parent=#GuildModel] getManageData
-- @param #GuildModel self
-- @return #table data
function GuildModel:getManageData()
    return self._manageData or {}
end

---
-- 公会成员管理列表
-- @function [parent=#GuildModel] getManageMemberList
-- @param #GuildModel self
-- @return #table
function GuildModel:getManageMemberList()
    if self._manageData and self._manageData.list then
        return self._manageData.list
    end
    return {}
end

---
-- 查看公会成员动态界面信息
-- @function [parent=#GuildModel] setReportData
-- @param #GuildModel self
-- @param #table data
function GuildModel:setReportData(data)
    self._reportData = data
    self:_raiseDataChangeEvent("0",self.dataType.report)
end

---
-- 查看公会成员动态界面信息
-- @function [parent=#GuildModel] getReportData
-- @param #GuildModel self
-- @return #table data
function GuildModel:getReportData()
    return self._reportData or {}
end

---
-- 公会成员动态列表
-- @function [parent=#GuildModel] getReportList
-- @param #GuildModel self
-- @return #table
function GuildModel:getReportList()
    if self._reportData and self._reportData.list then
        return self._reportData.list
    end
    return {}
end

---
-- 查看公会卡牌赠送记录界面信息
-- @function [parent=#GuildModel] setCardLogData
-- @param #GuildModel self
-- @param #table data
function GuildModel:setCardLogData(data)
    self._cardLogData = data
    self:_raiseDataChangeEvent("0",self.dataType.cardLog)
end

---
-- 查看公会牌赠送记录界面信息
-- @function [parent=#GuildModel] getCardLogData
-- @param #GuildModel self
-- @return #table data
function GuildModel:getCardLogData()
    return self._cardLogData or {}
end

---
-- 公会成员动态列表
-- @function [parent=#GuildModel] getCardLogList
-- @param #GuildModel self
-- @return #table
function GuildModel:getCardLogList()
    if self._cardLogData and self._cardLogData.list then
        return self._cardLogData.list
    end
    return {}
end

---
-- 查看公会加入申请界面信息
-- @function [parent=#GuildModel] setApplyPanelData
-- @param #GuildModel self
-- @param #table data
function GuildModel:setApplyPanelData(data)
    self._applyPanelData = data
    self:_raiseDataChangeEvent("0",self.dataType.applyPanel)
end

---
-- 查看公会加入申请界面信息
-- @function [parent=#GuildModel] getApplyPanelData
-- @param #GuildModel self
-- @return #table data
function GuildModel:getApplyPanelData()
    return self._applyPanelData or {}
end

---
-- 公会加入申请列表
-- @function [parent=#GuildModel] getApplyPanelMemberList
-- @param #GuildModel self
-- @return #table
function GuildModel:getApplyPanelMemberList()
    if self._applyPanelData and self._applyPanelData.list then
        return self._applyPanelData.list
    end
    return {}
end

---
-- 查看公会详情界面信息
-- @function [parent=#GuildModel] setDetailData
-- @param #GuildModel self
-- @param #table data
function GuildModel:setDetailData(data)
    self._detailData = data
    self:_raiseDataChangeEvent("0",self.dataType.detail)
end

---
-- 查看公会详情界面信息
-- @function [parent=#GuildModel] getDetailData
-- @param #GuildModel self
-- @return #table data
function GuildModel:getDetailData()
    return self._detailData or {}
end

---
-- 公会详情列表
-- @function [parent=#GuildModel] getDetailMemberList
-- @param #GuildModel self
-- @return #table
function GuildModel:getDetailMemberList()
    if self._detailData and self._detailData.list then
        return self._detailData.list
    end
    return {}
end

---
-- 公会名称
-- @function [parent=#GuildModel] myGuildName
-- @param #GuildModel self
-- @return #string
function GuildModel:myGuildName()
    return self._data.name or ""
end

---
-- 公会成员数
-- @function [parent=#GuildModel] myGuildNum
-- @param #GuildModel self
-- @return #number
function GuildModel:myGuildNum()
    return self._data.num or 1
end

---
-- 是否有新成员加入公会
-- @function [parent=#GuildModel] ifHaveNew
-- @param #GuildModel self
-- @return #boolean
function GuildModel:ifHaveNew()
    return self._newTag
end

---
-- 旗帜列表
-- @function [parent=#GuildModel] getFlagList
-- @param #GuildModel self
-- @return #table
function GuildModel:getFlagList()
    local flagTable = {}
    for i = 1,table.maxn(GameConst.GUILD_FLAG) do
        table.insert(flagTable,i)
    end
    return flagTable
end




---
-- 公会招募次数
-- @function [parent=#GuildModel] getCallNum
-- @param #GuildModel self
-- @return #number
function GuildModel:getCallNum()
    return self._data.callNum or 0
end

---
-- 设置公会招募次数
-- @function [parent=#GuildModel] setCallNum
-- @param #GuildModel self
-- @param #number num
function GuildModel:setCallNum(num)
    num = num or 0
    self._data.callNum = num
    self:_raiseDataChangeEvent("0",self.dataType.call)
end

---
-- 增加公会招募次数
-- @function [parent=#GuildModel] addCallNum
-- @param #GuildModel self
-- @param #number num
function GuildModel:addCallNum(num)
    num = num or 0
    if self._data.callNum then
        self._data.callNum = self._data.callNum + num
    else
        self._data.callNum = num
    end
    self:_raiseDataChangeEvent("0",self.dataType.call)
end

---
-- 公会详情名字
-- @function [parent=#GuildModel] getDetailName
-- @param #GuildModel self
-- @return #string
function GuildModel:getDetailName()
    return self._detailData.name or ""
end

---
-- 公会详情旗帜
-- @function [parent=#GuildModel] getDetailFlag
-- @param #GuildModel self
-- @return #number
function GuildModel:getDetailFlag()
    return self._detailData.flag or 1
end

---
-- 公会详情成员数
-- @function [parent=#GuildModel] getDetailNum
-- @param #GuildModel self
-- @return #number
function GuildModel:getDetailNum()
    return self._detailData.num or 1
end

---
-- 公会详情等级
-- @function [parent=#GuildModel] getDetailLevel
-- @param #GuildModel self
-- @return #number
function GuildModel:getDetailLevel()
    return self._detailData.lv or 1
end

---
-- 公会人员信息(userId,pet,person,name,maxLevel,yueka,rtime,ltime)
-- @function [parent=#GuildModel] myGuildList
-- @param #GuildModel self
-- @param #number num
-- @return #table
function GuildModel:myGuildList(num)
    return self._data.list[num] or {}
end

---
-- 公会人员信息
-- @function [parent=#GuildModel] myGuildMemberList
-- @param #GuildModel self
-- @return #table
function GuildModel:myGuildMemberList()
    local tmpData = {}
    for k,v in pairs(self._data.list) do 
        table.insert(tmpData,k)
    end
    return tmpData
end
---
-- 修改加入公会状态(0退出，1加入)
-- @function [parent=#GuildModel] setJoinGuild
-- @param #GuildModel self
-- @param #number state
function GuildModel:setJoinGuild(state)
    self._data.join = state
end

---
-- 自己是否为会长
-- @function [parent=#GuildModel] ifAtevent
-- @param #GuildModel self
-- @return #boolean
function GuildModel:ifAtevent()
    if self._data.atevent and tonumber(self._data.atevent) == 1 then
        return true
    else
        return false
    end
end

---
-- 修改会长状态(0否，1是)
-- @function [parent=#GuildModel] setAtevent
-- @param #GuildModel self
-- @param #number state
function GuildModel:setAtevent(state)
    self._data.atevent = state
end

---
-- 我的公会信息
-- @function [parent=#GuildModel] myGuildData
-- @param #GuildModel self
-- @return #string
function GuildModel:myGuildData()
    return self._data or {}
end

---
-- 我的公会申请
-- @function [parent=#GuildModel] myGuildApplyTime
-- @param #GuildModel self
-- @return #string
function GuildModel:myGuildApplyTime()
    return self._data.applyTime or {}
end

---
-- 修改公会宣言
-- @function [parent=#GuildModel] setMyGuildSlogan
-- @param #GuildModel self
-- @param #string slogan
function GuildModel:setMyGuildSlogan(slogan)
    self:myGuildData().slogan = slogan
    self:_raiseDataChangeEvent("0",self.dataType.panel)
end

---
-- 我的公会申请次数
-- @function [parent=#GuildModel] myGuildApplyTimeNum
-- @param #GuildModel self
-- @return #number
function GuildModel:myGuildApplyTimeNum()
    local num = 0
    if self._data.applyTime then
        for k,v in pairs(self._data.applyTime) do
            if v > 0 then
                num = num + 1
            end
        end
    end
    return num
end

---
-- 申请加入公会
-- @function [parent=#GuildModel] myGuildApplyTimeAdd
-- @param #GuildModel self
-- @param #number time
function GuildModel:myGuildApplyTimeAdd(time)
    if not self._data.applyTime then
        self._data.applyTime = {}
    end
    for k,v in pairs(self._data.applyTime) do
        if v <= 0 then
            v = time
            self:_raiseDataChangeEvent("0",self.dataType.apply)
            return
        end
    end
    table.insert(self._data.applyTime,time)
    self:_raiseDataChangeEvent("0",self.dataType.apply)
end


---
-- 公会ID
-- @function [parent=#GuildModel] myGuildID
-- @param #GuildModel self
-- @return #string
function GuildModel:myGuildID()
    return self._data.id or ""
end

---
-- 修改公会ID
-- @function [parent=#GuildModel] setGuildID
-- @param #GuildModel self
-- @param #string id
function GuildModel:setGuildID(id)
    self._data.id = id
end

---
-- 公会等级
-- @function [parent=#GuildModel] myGuildLevel
-- @param #GuildModel self
-- @return #number
function GuildModel:myGuildLevel()
    return self._data.guildLv or 1
end

---
-- 公会升级
-- @function [parent=#GuildModel] myGuildLevelUP
-- @param #GuildModel self
function GuildModel:myGuildLevelUP()
    if not self._data.guildLv then
        self._data.guildLv = 1
    end
    self:addGuildExp(-GameConfig.Union_levelConfig:getData(self._data.guildLv).exp)
    self._data.guildLv = self._data.guildLv + 1
    self:_raiseDataChangeEvent("0",self.dataType.level)
end

---
-- 公会名称
-- @function [parent=#GuildModel] myGuildName
-- @param #GuildModel self
-- @return #string
function GuildModel:myGuildName()
    return self._data.name or ""
end

---
-- 修改公会名称
-- @function [parent=#GuildModel] setGuildName
-- @param #GuildModel self
-- @param #string name
function GuildModel:setGuildName(name)
    self._data.name = name
    self:_raiseDataChangeEvent("0",self.dataType.name)
end

---
-- 公会旗帜
-- @function [parent=#GuildModel] myGuildFlag
-- @param #GuildModel self
-- @return #number
function GuildModel:myGuildFlag()
    return self._data.flag or 0
end

---
-- 修改公会旗帜
-- @function [parent=#GuildModel] setGuildFlag
-- @param #GuildModel self
-- @param #number flag
function GuildModel:setGuildFlag(flag)
    self._data.flag = flag
    self:_raiseDataChangeEvent("0",self.dataType.flag)
end

---
-- 公会成员数
-- @function [parent=#GuildModel] myGuildNum
-- @param #GuildModel self
-- @return #number
function GuildModel:myGuildNum()
    return self._data.num or 1
end

---
-- 增加公会成员数
-- @function [parent=#GuildModel] addGuildNum
-- @param #GuildModel self
-- @param #number num
function GuildModel:addGuildNum(num)
    num = num or 1
    self._data.num = self._data.num + num
end

---
-- 今日加入公会次数
-- @function [parent=#GuildModel] myJoinCount
-- @param #GuildModel self
-- @return #number
function GuildModel:myJoinCount()
    return self._data.jcount or 0
end

---
-- 增加今日加入公会次数
-- @function [parent=#GuildModel] addJoinCount
-- @param #GuildModel self
-- @param #number num
function GuildModel:addJoinCount(num)
    num = num or 1
    if self._data and self._data.jcount then
        self._data.jcount = self._data.jcount + num
    else
        self._data.jcount = num
    end
end

---
-- 设置今日加入公会次数
-- @function [parent=#GuildModel] setJoinCount
-- @param #GuildModel self
-- @param #number num
function GuildModel:setJoinCount(num)
    num = num or 0
    self._data.jcount = num
end

---
-- 公会保护时间
-- @function [parent=#GuildModel] myGuildVTime
-- @param #GuildModel self
-- @return #number
function GuildModel:myGuildVTime()
    if self._data and self._data.vtime then
        local leftTime = self._data.vtime - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end
---
-- 有新成员加入公会
-- @function [parent=#GuildModel] newMember
-- @param #GuildModel self
function GuildModel:newMember()
    self._newTag = true
    self:_raiseDataChangeEvent("0",self.dataType.new)
end

---
-- 公会签到次数
-- @function [parent=#GuildModel] myGuildSignNum
-- @param #GuildModel self
-- @return #number
function GuildModel:myGuildSignNum()
    return self._data.sign or 0
end

---
-- 公会签到次数
-- @function [parent=#GuildModel] addGuildSignNum
-- @param #GuildModel self
-- @param #number num
function GuildModel:addGuildSignNum(num)
    if self._data.sign then
        self._data.sign = self._data.sign + num
        self:_raiseDataChangeEvent("0",self.dataType.sign)
    end
end

---
-- 公会索要次数
-- @function [parent=#GuildModel] myGuildDemandNum
-- @param #GuildModel self
-- @return #number
function GuildModel:myGuildDemandNum()
    return self._data.demandNum or 0
end

---
-- 公会索要次数
-- @function [parent=#GuildModel] addGuildDemandNum
-- @param #GuildModel self
-- @param #number num
function GuildModel:addGuildDemandNum(num)
    if self._data.demandNum then
        self._data.demandNum = self._data.demandNum + num
        self:_raiseDataChangeEvent("0",self.dataType.demand)
    end
end

---
-- 公会赠送次数
-- @function [parent=#GuildModel] myGuildGiveNum
-- @param #GuildModel self
-- @return #number
function GuildModel:myGuildGiveNum()
    return self._data.giveNum or 0
end

---
-- 公会赠送次数
-- @function [parent=#GuildModel] addGuildGiveNum
-- @param #GuildModel self
-- @param #number num
function GuildModel:addGuildGiveNum(num)
    if self._data.giveNum then
        self._data.giveNum = self._data.giveNum + num
        self:_raiseDataChangeEvent("0",self.dataType.give)
    end
end


---
-- 公会签到领取奖励
-- @function [parent=#GuildModel] addSignReward
-- @param #GuildModel self
-- @param #string id
function GuildModel:addSignReward(id)
    if GameConst.GUILD_SIGN_REWARD[id] then
        self:addGuildExp(GameConst.GUILD_SIGN_REWARD[id].m90016)
        self:addPersonExp(GameConst.GUILD_SIGN_REWARD[id].m90017)
        ch.MoneyModel:addHonour(GameConst.GUILD_SIGN_REWARD[id].m90006)
        if GameConst.GUILD_SIGN_REWARD[id].m90016 > 0 then
            ch.UIManager:showUpTips(string.format(Language.GUILD_SIGN_TIPS["m90016"],GameConst.GUILD_SIGN_REWARD[id].m90016))
        end
        if GameConst.GUILD_SIGN_REWARD[id].m90017 > 0 then
            zzy.TimerUtils:setTimeOut(0.4,function()
                ch.UIManager:showUpTips(string.format(Language.GUILD_SIGN_TIPS["m90017"],GameConst.GUILD_SIGN_REWARD[id].m90017))
            end)
        end
        if GameConst.GUILD_SIGN_REWARD[id].m90006 > 0 then
            zzy.TimerUtils:setTimeOut(0.9,function()
                ch.UIManager:showUpTips(string.format(Language.GUILD_SIGN_TIPS["m90006"],GameConst.GUILD_SIGN_REWARD[id].m90006))
            end)
        end
    end
end

---
-- 公会赠送符文领取奖励
-- @function [parent=#GuildModel] addCardReward
-- @param #GuildModel self
function GuildModel:addCardReward()
    if GameConst.GUILD_CARD_GIVE_REWARD then
        self:addGuildExp(GameConst.GUILD_CARD_GIVE_REWARD.m90016)
        self:addPersonExp(GameConst.GUILD_CARD_GIVE_REWARD.m90017)
        ch.MoneyModel:addHonour(GameConst.GUILD_CARD_GIVE_REWARD.m90006)
        ch.ShopModel:addStarSoulCount(GameConst.GUILD_CARD_GIVE_REWARD.m90009)
        if GameConst.GUILD_CARD_GIVE_REWARD.m90016 > 0 then
            ch.UIManager:showUpTips(string.format(Language.GUILD_SIGN_TIPS["m90016"],GameConst.GUILD_CARD_GIVE_REWARD.m90016))
        end
        if GameConst.GUILD_CARD_GIVE_REWARD.m90017 > 0 then
            zzy.TimerUtils:setTimeOut(0.4,function()
                ch.UIManager:showUpTips(string.format(Language.GUILD_SIGN_TIPS["m90017"],GameConst.GUILD_CARD_GIVE_REWARD.m90017))
            end)
        end
        if GameConst.GUILD_CARD_GIVE_REWARD.m90006 > 0 then
            zzy.TimerUtils:setTimeOut(0.9,function()
                ch.UIManager:showUpTips(string.format(Language.GUILD_SIGN_TIPS["m90006"],GameConst.GUILD_CARD_GIVE_REWARD.m90006))
            end)
        end
        if GameConst.GUILD_CARD_GIVE_REWARD.m90009 > 0 then
            zzy.TimerUtils:setTimeOut(1.4,function()
                ch.UIManager:showUpTips(string.format(Language.GUILD_SIGN_TIPS["m90009"],GameConst.GUILD_CARD_GIVE_REWARD.m90009))
            end)
        end
    end
end

---
-- 公会经验
-- @function [parent=#GuildModel] addGuildExp
-- @param #GuildModel self
-- @param #number num
function GuildModel:addGuildExp(num)
    if self._data.guildExp and num ~= 0 then
        self._data.guildExp = self._data.guildExp + num
        self:_raiseDataChangeEvent("0",self.dataType.guildExp)
        if GameConfig.Union_levelConfig:getData(self._data.guildLv).exp > 0 
            and self._data.guildExp >= GameConfig.Union_levelConfig:getData(self._data.guildLv).exp then
            self:myGuildLevelUP()
        end
    end
end

---
-- 个人经验
-- @function [parent=#GuildModel] addPersonExp
-- @param #GuildModel self
-- @param #number num
function GuildModel:addPersonExp(num)
    if self._data.personExp and num ~= 0 then
        self._data.personExp = self._data.personExp + num
        self:_raiseDataChangeEvent("0",self.dataType.personExp)
    end
end

---
-- 公会副会长名字
-- @function [parent=#GuildModel] myGuildNextName
-- @param #GuildModel self
-- @return #string
function GuildModel:myGuildNextName()
    return self._nextName
end

---
-- 公会副会长名字
-- @function [parent=#GuildModel] setMyGuildNextName
-- @param #GuildModel self
-- @param #string nextName
function GuildModel:setMyGuildNextName(nextName)
    self._nextName = nextName
    self:_raiseDataChangeEvent("0",self.dataType.nextName)
end


---
-- 查看公会卡牌赠予界面信息
-- @function [parent=#GuildModel] setDemandPanelData
-- @param #GuildModel self
-- @param #table data
function GuildModel:setDemandPanelData(data)
    self._demandPanelData = data
    self:_raiseDataChangeEvent("0",self.dataType.demandPanel)
end

---
-- 查看公会卡牌赠予界面信息
-- @function [parent=#GuildModel] getDemandPanelData
-- @param #GuildModel self
-- @return #table data
function GuildModel:getDemandPanelData()
    return self._demandPanelData or {}
end

---
-- 公会卡牌赠予列表
-- @function [parent=#GuildModel] getDemandPanelList
-- @param #GuildModel self
-- @return #table
function GuildModel:getDemandPanelList()
    if self._demandPanelData and self._demandPanelData.list then
        return self._demandPanelData.list
    end
    return {}
end

---
-- 公会附魔等级
-- @function [parent=#GuildModel] getEnchantmentLevel
-- @param #GuildModel self
-- @return #number
function GuildModel:getEnchantmentLevel()
    return self._enchantmentData.level
end

---
-- 公会附魔等级
-- @function [parent=#GuildModel] addEnchantmentLevel
-- @param #GuildModel self
-- @return #number
function GuildModel:addEnchantmentLevel(level)
    self._enchantmentData.level = self._enchantmentData.level + level
    -- 重新计算宝物总战力
    ch.MagicModel:resetTotalDPS()
    self:_raiseDataChangeEvent("0",self.dataType.enchantment)
end

---
-- 公会附魔经验
-- @function [parent=#GuildModel] getEnchantmentExp
-- @param #GuildModel self
-- @return #number
function GuildModel:getEnchantmentExp()
    return self._enchantmentData.exp
end

---
-- 公会附魔经验
-- @function [parent=#GuildModel] setEnchantmentExp
-- @param #GuildModel self
-- @return #number
function GuildModel:setEnchantmentExp(num)
    self._enchantmentData.exp = num
    self:_raiseDataChangeEvent("0",self.dataType.enchantment)
end

---
-- 公会附魔经验
-- @function [parent=#GuildModel] addEnchantmentExp
-- @param #GuildModel self
-- @return #number
function GuildModel:addEnchantmentExp(num)
    self._enchantmentData.exp = self._enchantmentData.exp + num
    self:_raiseDataChangeEvent("0",self.dataType.enchantment)
end


---
-- 公会附魔BUFF加成
-- @function [parent=#GuildModel] getEnchantmentDPS
-- @param #GuildModel self
-- @return #number
function GuildModel:getEnchantmentDPS()
    if self:getEnchantmentLevel() and self:getEnchantmentLevel()>0 then
        return GameConst.GUILD_ENCHANTMENT_DPS_RATIO(self:getEnchantmentLevel())
    end
    return GameConst.GUILD_ENCHANTMENT_DPS_RATIO(1)
end


---
-- 过天刷新（公会加入次数）
-- @function [parent=#GuildModel] onNextDay
-- @param #GuildModel self
function GuildModel:onNextDay()
    self:setJoinCount(0)
    self:setCallNum(0)
    self:_raiseDataChangeEvent("0",self.dataType.panel)
end

return GuildModel