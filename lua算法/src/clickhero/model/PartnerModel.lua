---
-- 宠物 model层     结构 { "cz"=20001,"hs"={"20001","20003"}, "jl"={"20003"="20", "20005"="100"}, "ylq"={"20003"="20", "20005"="100"}}
--@module PartnerModel
local PartnerModel = {
    _data = nil,
    dataChangeEventType = "PartnerModelDataChange",
    dataTypelj = {
        lq = 1,
        gb = 2,
    },
    czChangeEventType = "PartnerModelCzChange",
	_petData = nil,
	dataType = {
        fight = 1,
        get = 2,
    }}

---
-- @function [parent=#PartnerModel] init
-- @param #PartnerModel self
-- @param #table data
function PartnerModel:init(data)
    if data and data.partner then
        self._data = data.partner
        if self._data and self._data.jl then
            for k,v in pairs(self._data.jl) do
                local partner = GameConfig.PartnerConfig:getData(k)
                if partner and (partner.add_type == 3 or partner.add_type == 6) then
                    self._data.jl[k] = ch.LongDouble:toLongDouble(tostring(v))
                else
        		    self._data.jl[k] = tonumber(v)
        		end
        	end
        end
        if self._data and self._data.ylq then
            for ky,vy in pairs(self._data.ylq) do
                local partner = GameConfig.PartnerConfig:getData(k)
                if partner and (partner.add_type == 3 or partner.add_type == 6) then
                    self._data.ylq[ky] = ch.LongDouble:toLongDouble(tostring(vy))
                else
                    self._data.ylq[ky] = tonumber(vy)
                end
            end
        end
    else
        self._data = { cz=20001, hs={20001}, jl={}, ylq={} }
        self._data.jl["20003"] = 20
        self._data.jl["20004"] = 200
        self._data.jl["20005"] = 100
    end
    -- 获取所有宠物列表
    self:orderAllPartner()
end

---
-- @function [parent=#PartnerModel] clean
-- @param #PartnerModel self
function PartnerModel:clean()
    self._data = nil
    self._petData = nil
end

---
-- 是否有未领取的宠物属性加成（未加上的属性）
-- @function [parent=#PartnerModel] isGetReward
-- @param #PartnerModel self
-- @return #string
function PartnerModel:isGetReward()
    for k,v in pairs(self._data.jl) do
        local partner = GameConfig.PartnerConfig:getData(k)
        if partner and (partner.add_type == 3 or partner.add_type == 6) then
            if self:getShuXing(k) > ch.LongDouble.zero then
                return true
            end
        else
            if self:getShuXing(k) > 0 then
                return true
            end
        end
    end
    return false
end

---
-- 获取宠物的属性加成（未加上的属性）
-- @function [parent=#PartnerModel] getShuXing
-- @param #PartnerModel self
-- @param #number id
-- @return #string
function PartnerModel:getShuXing(id)
    if self._data.jl and self._data.jl[id] then
        return self._data.jl[id]
    end
    return 0
end

---
-- 添加宠物的属性加成（未加上的属性）
-- @function [parent=#PartnerModel] addShuXing
-- @param #PartnerModel self
-- @param #string id
-- @param #number num
function PartnerModel:addShuXing(id, num)
    if self._data.jl[id] then
        self._data.jl[id] = self._data.jl[id] + num
    else
        self._data.jl[id] = num
    end
    self:lqChangeEvt(id,self.dataTypelj.gb)
end

---
-- 获取宠物的属性加成（已加上的属性）
-- @function [parent=#PartnerModel] getYlqShuXing
-- @param #number id
-- @param #PartnerModel self
-- @return #string
function PartnerModel:getYlqShuXing(id)
    if self._data.ylq and self._data.ylq[id] then
        return self._data.ylq[id]
    end
    return 0
end

---
-- 添加宠物的属性加成（已加上的属性）
-- @function [parent=#PartnerModel] addYlqShuXing
-- @param #string id
-- @param #number num
-- @param #PartnerModel self
function PartnerModel:addYlqShuXing(id, num)
    if self._data.ylq[id] then
        self._data.ylq[id] = self._data.ylq[id] + num
    else
        self._data.ylq[id] = num
    end
    if id == "20003" then
        ch.MagicModel:resetDPS()
    end
end

---
-- 获取宠物的属性加成（已获得的）
-- @function [parent=#PartnerModel] getRewardCurNum
-- @param #number id
-- @param #PartnerModel self
-- @return #number
function PartnerModel:getRewardCurNum(id)
    return self:getYlqShuXing(id)+self:getShuXing(id)
end

---
-- 下一关
-- @function [parent=#PartnerModel] nextLevel
-- @param #PartnerModel self
function PartnerModel:nextLevel()
    --计算宠物的属性加成
    local guanqia = 0
    local jiange = 0
    local arg = 0
    --水属性宠物
    local shuiData = GameConfig.PartnerConfig:getData("20004")
    guanqia = shuiData.guanqia
    if self:ifHavePartner("20004") and ch.LevelModel:getCurLevel() >= guanqia then
        jiange = shuiData.jiange
        arg = shuiData.arg
        if self:ifAddShuXing(ch.LevelModel:getCurLevel(), guanqia, jiange) then 
        local addGold = ch.CommonFunc:getOffLineGold(arg/10000,ch.LevelModel:getCurLevel()+1)
            ch.PartnerModel:addShuXing("20004", addGold)
        end
    end

    --火属性宠物
    local huoData = GameConfig.PartnerConfig:getData("20005")
    local tmpAddLevelSMax = 0
    if (ch.StatisticsModel:getMaxLevel()-1)<huoData.guanqia then
        tmpAddLevelSMax = huoData.guanqia
    else
        tmpAddLevelSMax = (math.floor((ch.StatisticsModel:getMaxLevel()-1 - huoData.guanqia) / huoData.jiange)+1)*huoData.jiange+huoData.guanqia
    end
    if self:ifHavePartner("20005") and ch.StatisticsModel:getMaxLevel() >= tmpAddLevelSMax then
        jiange = huoData.jiange
        arg = huoData.arg
        if self:ifAddShuXing(ch.LevelModel:getCurLevel(), tmpAddLevelSMax, jiange) then 
            ch.PartnerModel:addShuXing("20005", arg / 10000)
        end
    end

    --风属性宠物
    local fengData = GameConfig.PartnerConfig:getData("20006")
    guanqia = fengData.guanqia
    if self:ifHavePartner("20006") and ch.LevelModel:getCurLevel() >= guanqia then
        jiange = fengData.jiange
        arg = fengData.arg
        if self:ifAddShuXing(ch.LevelModel:getCurLevel(), guanqia, jiange) then
            local num20006 = math.floor((arg / 10000)*ch.LevelController:getPrimalHeroSoulRewards(ch.LevelModel:getCurLevel())) 
            if num20006 < 1 then
            	num20006 = 1
            end
            ch.PartnerModel:addShuXing("20006", num20006)
        end
    end
end

---
--  判断是否添加属性
-- @function [parent=#LevelModel] ifAddShuXing
-- @param #LevelModel self
-- @param #number curLv
-- @param #number baseLv
-- @param #number addLv
function PartnerModel:ifAddShuXing(curLv, baseLv, addLv)
    local ifAdd = false
    if curLv >= baseLv and (curLv - baseLv) % addLv == 0 then
        ifAdd = true
    end
    return ifAdd
end

---
-- 获取已获得宠物列表
-- @function [parent=#PartnerModel] getPartner
-- @param #PartnerModel self
-- @return #table
function PartnerModel:getPartner()
    return self._data.hs
end

---
-- 获取可出战的宠物列表
-- @function [parent=#PartnerModel] getCanFightPartner
-- @param #PartnerModel self
-- @return #table
function PartnerModel:getCanFightPartner()
    local tmpTable = {}
    for k,v in ipairs(GameConst.PET_ORDER) do
        if v ~= self:getCurPartner() and self:ifHavePartner(v) then
            table.insert(tmpTable,v)
        end
    end
    return tmpTable
end

---
-- 获取所有宠物列表
-- @function [parent=#PartnerModel] orderAllPartner
-- @param #PartnerModel self
function PartnerModel:orderAllPartner()
    local petTable = GameConfig.PartnerConfig:getTable()
    self._petData = {}
    for k,v in pairs(petTable) do
        table.insert(self._petData,v.id)
    end
    table.sort(self._petData,function(t1,t2)
        return tonumber(t1)<tonumber(t2)
    end)
end

---
-- 获取所有宠物列表
-- @function [parent=#PartnerModel] getAllPartner
-- @param #PartnerModel self
-- @return #table
function PartnerModel:getAllPartner()
    return self._petData or {}
end


---
-- 获得一个宠物
-- @function [parent=#PartnerModel] getOne
-- @param #PartnerModel self
-- @param #string id
-- @return #table
function PartnerModel:getOne(id)
    local ifHave = false
    for v,k in ipairs(self._data.hs) do
        if tostring(k) == tostring(id) then
        	ifHave = true
        	break
        end
    end
    if not ifHave then
        table.insert(self._data.hs, id)
        if GameConfig.PartnerConfig:getData(id).up_type == 1 then
            ch.MagicModel:resetDPS()
        end
    end
    self:czChangeEvt(self.dataType.get,tostring(id))
end

---
-- 宠物附加属性值
-- @function [parent=#PartnerModel] getUpNum
-- @param #PartnerModel self
-- @param #number type
-- @return #number
function PartnerModel:getUpNum(type)
    for k,v in pairs(self._data.hs) do
        if GameConfig.PartnerConfig:getData(v).up_type == type then
            return GameConfig.PartnerConfig:getData(v).upNum/10000
        end
    end
    return 0
end

---
-- 获取可领奖的宠物列表
-- @function [parent=#PartnerModel] getLJPartner
-- @param #PartnerModel self
-- @return #table
function PartnerModel:getLJPartner()
    local list = {}
    for k,v in pairs(self._data.jl) do
        local partner = GameConfig.PartnerConfig:getData(k)
        if partner and (partner.add_type == 3 or partner.add_type == 6) then
            if v > ch.LongDouble.zero then
                table.insert(list,k)
            end
        else
            if v > 0 then
                table.insert(list,k)
            end
        end
    end
    return list
end

---
-- 领取奖励
-- @function [parent=#PartnerModel] getReward
-- @param #PartnerModel self
-- @param #string id
function PartnerModel:getReward(id)
    if self._data.jl[id] then
        if id == "20003" and self._data.jl[id] > 0 then --宠物（地）
            self:addYlqShuXing(id, self._data.jl[id])
            self._data.jl[id] = 0
        elseif id == "20004" and self._data.jl[id] > ch.LongDouble.zero then --宠物（水）
            local gold = self._data.jl[id]
            ch.MoneyModel:addGold(gold)
    	    ch.CommonFunc:playGoldSound(gold)
            self:addYlqShuXing(id, self._data.jl[id])
            self._data.jl[id] = ch.LongDouble.zero
        elseif id == "20005" and self._data.jl[id] > 0 then --宠物（火）
            ch.MoneyModel:addStar(self._data.jl[id])
            self:addYlqShuXing(id, self._data.jl[id])
            self._data.jl[id] = 0
        elseif id == "20006" and self._data.jl[id] > 0 then --宠物（风）
            ch.MoneyModel:addsStone(self._data.jl[id])
            self:addYlqShuXing(id, self._data.jl[id])
            self._data.jl[id] = 0
        end
        self:lqChangeEvt(id,self.dataTypelj.lq)
    end
end

---
-- 获取宠物(地)的属性加成（百分比）
-- @function [parent=#PartnerModel] getGjjc
-- @param #PartnerModel self
-- @return #number
function PartnerModel:getGjjc()
    local num = 0
    if self._data.ylq and self._data.ylq["20003"] then
        num = self._data.ylq["20003"] * (GameConfig.PartnerConfig:getData("20003")["arg"] / 10000)
    end
    return num
end

---
-- 通过宠物id判断代币类型是否显示
-- @function [parent=#PartnerModel] ifShowMoney
-- @param #PartnerModel self
-- @param #string id
-- @param #string moneyType
-- @return #boolean
function PartnerModel:ifShowMoney(id, moneyType)
    local ifShow = false
    if id == "20003" and moneyType == "dmg" then
    	ifShow = true
    end
    if id == "20004" and moneyType == "gold" then
        ifShow = true
    end
    if id == "20005" and moneyType == "star" then
        ifShow = true
    end
    if id == "20006" and moneyType == "soul" then
        ifShow = true
    end
    return ifShow
end

---
-- 设置当前出战的宠物id
-- @function [parent=#PartnerModel] setCurPartner
-- @param #PartnerModel self
-- @param #string id
-- @return #string
function PartnerModel:setCurPartner(id)
    id = id or "20001"
    self._data.cz = id
    -- 切换宠物
    ch.fightRoleLayer:getMainRole():changePetRole(self:getCurPartnerAvatar(),id)
end

---
-- 获取当前出战的宠物id
-- @function [parent=#PartnerModel] getCurPartner
-- @param #PartnerModel self
-- @return #string
function PartnerModel:getCurPartner()
    if self._data and self._data.cz then
        return self._data.cz
    end
    return "20001"
end

---
-- 获取界面宠物index
-- @function [parent=#PartnerModel] getCurPartnerIndex
-- @param #PartnerModel self
-- @param #string id
-- @return #number
function PartnerModel:getCurPartnerIndex(id)
    for k,v in ipairs(GameConst.PET_ORDER) do
        if v == id then
            return k-1
        end
    end
    return 0
end

---
-- 获取当前出战的宠物的属性
-- @function [parent=#PartnerModel] getCurPartnerRestrain
-- @param #PartnerModel self
-- @return #string
function PartnerModel:getCurPartnerRestrain()
    return GameConfig.PartnerConfig:getData(self:getCurPartner()).shuxing
end

---
-- 获取当前出战的宠物的自动点击次数
-- @function [parent=#PartnerModel] getCurPartnerClickSpeed
-- @param #PartnerModel self
-- @return #number
function PartnerModel:getCurPartnerClickSpeed()
    return GameConfig.PartnerConfig:getData(self:getCurPartner()).clickSpeed or 0
end

---
-- 获取当前出战的宠物的动画形象
-- @function [parent=#PartnerModel] getCurPartnerAvatar
-- @param #PartnerModel self
-- @return #string
function PartnerModel:getCurPartnerAvatar()
    return GameConfig.PartnerConfig:getData(tostring(self:getCurPartner())).apath
end

---
-- 获取宠物的价格
-- @function [parent=#PartnerModel] getPartnerPrice
-- @param #PartnerModel self
-- @param #string id
-- @return #number,number,number
function PartnerModel:getPartnerPrice(id)
    if self:ifHavePartner(id) then
        return 1,0,1
    else
        local curFlag=zzy.Sdk.getFlag()..zzy.config.subpack
        local flag= string.sub(zzy.Sdk.getFlag(),1,2)
        if "ANYSDK" == curFlag or "YIJIE" == curFlag or "DEFAULT" == curFlag then
			curFlag="DEFAULT" --tgx 这里curFlag = "1", 决定了取哪个渠道的商品id
		end
        local cs = GameConfig.ShopConfig:getTable()
        for k,v in pairs(cs) do
            if v.channelId == curFlag and v.reward == tonumber(id) then
                return v.type_cost,v.price,v.id
            end
        end
        return 1,0,1
    end
end

---
-- 通过宠物id判断是否拥有
-- @function [parent=#PartnerModel] ifHavePartner
-- @param #PartnerModel self
-- @param #string id
-- @return #boolean
function PartnerModel:ifHavePartner(id)
    for k,v in ipairs(self._data.hs) do
        if tostring(v) == tostring(id) then
            return true
        end
    end
    return false
end

---
-- 宠物奖励说明（当前）
-- @function [parent=#PartnerModel] getRewardDesc
-- @param #PartnerModel self
-- @param #string id
-- @return #string,string
function PartnerModel:getRewardDesc(id)
    local cs = GameConfig.PartnerConfig:getData(tostring(id))
    if cs.add_type == 0 then 
        if cs.id == "20007" then
--            local val = ch.CommonFunc:getMoneyByDiamond(GameConfig.Charge_levelConfig:getData(7).val)
--            return string.format(GameConst.SHOP_CHARGE_TITLE,val,ch.CommonFunc:getCoinName()),""
            local val = GameConfig.Charge_levelConfig:getData(7).val
            return string.format(GameConst.SHOP_CHARGE_TITLE,val,Language.MSG_PAYCOIN),""
        end
        return cs.desc_get,"" 
    end 
    local curDesc = GameConst.PET_REWARD_DESC[cs.add_type][1]
    local nextDesc = GameConst.PET_REWARD_DESC[cs.add_type][2]
    local rewardCurNum = self:getRewardCurNum(id)
    -- 暂时没用
    local tmpLevel = math.floor((ch.StatisticsModel:getMaxLevel()-1)/10)*10
    local tmpAddLevel = 0
    if (ch.LevelModel:getMaxLevel()-1)<cs.guanqia then
        tmpAddLevel = cs.guanqia
    else
        tmpAddLevel = (math.floor((ch.LevelModel:getCurLevel()-1 - cs.guanqia) / cs.jiange)+1)*cs.jiange+cs.guanqia
    end
    local tmpAddLevelSMax = 0
    if (ch.StatisticsModel:getMaxLevel()-1)<cs.guanqia then
        tmpAddLevelSMax = cs.guanqia
    else
        tmpAddLevelSMax = (math.floor((ch.StatisticsModel:getMaxLevel()-1 - cs.guanqia) / cs.jiange)+1)*cs.jiange+cs.guanqia
    end
    if cs.add_type == 1 then -- 暂时可能用不到了
        curDesc = string.format(curDesc,cs.arg/10000)
    elseif cs.add_type == 2 then -- 攻击力是次数
        curDesc = string.format(curDesc,ch.StatisticsModel:getRTimes(),rewardCurNum*cs.arg/100)
        nextDesc = string.format(nextDesc,(rewardCurNum+1)*cs.arg/100)
    elseif cs.add_type == 3 then
        curDesc = string.format(curDesc,tmpLevel,rewardCurNum)
        nextDesc = string.format(nextDesc,tmpAddLevelSMax)
    elseif cs.add_type == 4 then
        curDesc = string.format(curDesc,tmpLevel,rewardCurNum)
        nextDesc = string.format(nextDesc,tmpAddLevelSMax,cs.arg/10000)
    elseif cs.add_type == 5 then
        curDesc = string.format(curDesc,tmpLevel,rewardCurNum)
        nextDesc = string.format(nextDesc,tmpAddLevelSMax,math.floor((cs.arg / 10000)*ch.LevelController:getPrimalHeroSoulRewards(tmpAddLevel)))
    elseif cs.add_type == 6 then
        curDesc = string.format(curDesc,tmpLevel,rewardCurNum)
        nextDesc = string.format(nextDesc,tmpAddLevel)
    elseif cs.add_type == 7 then
        curDesc = string.format(curDesc,tmpLevel,rewardCurNum)
        nextDesc = string.format(nextDesc,tmpAddLevel,math.floor((cs.arg / 10000)*ch.LevelController:getPrimalHeroSoulRewards(tmpAddLevel)))
    end
    curDesc = cs.desc_get
    return curDesc,nextDesc
end

---
-- 领取奖励界面发送事件（客户端监听）
-- @function [parent=#PartnerModel] lqChangeEvt
-- @param #PartnerModel self
-- @param #string id
-- @param #number dataType
function PartnerModel:lqChangeEvt(id,dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType,
        id = id
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 切换宠物发送事件（客户端监听）
-- @function [parent=#PartnerModel] czChangeEvt
-- @param #PartnerModel self
-- @param #number dataType
-- @param #string id
function PartnerModel:czChangeEvt(dataType,id)
    local evt = {
        type = self.czChangeEventType,
        dataType = dataType,
        value = id
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 关于轮回
-- @function [parent=#PartnerModel] onSamsara
-- @param #PartnerModel self
function PartnerModel:onSamsara()
    if self:ifHavePartner("20003") then
        self:addShuXing("20003", 1)
    end
    if self._data.jl["20004"] and self._data.jl["20004"] > ch.LongDouble.zero then
        self._data.jl["20004"] = ch.LongDouble:new(0)
        self:lqChangeEvt("20004",self.dataTypelj.lq)
    end
end

---
-- 关于轮回
-- @function [parent=#PartnerModel] onSamsara
-- @param #PartnerModel self
function PartnerModel:onSuperSamsara()
    if self:ifHavePartner("20003") then
        self:addShuXing("20003", 1)
    end
end

return PartnerModel