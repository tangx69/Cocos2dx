---
-- 通用方法
--@module CommonFunc

local CommonFunc = {
}

local getOffLineMagicDps = function()
    local dps = (ch.MagicModel:getTotalDPS() - GameConst.MGAIC_CONFIG_BASE_HARM)/(1+ ch.RunicModel:getSkillEffect(ch.RunicModel.skillId.shuangchongdaji))
    dps = dps/(1 + ch.BuffModel:getMagicAddtion())
    if ch.BuffModel:getCardBuffTime()> 0 then
        dps = dps *(1 + GameConst.BUFF_EFFECT_VALUE[1][1])
    end
    -- 自动攻击的宠物
    local petDps = 0
    local petDps = ch.RunicModel:getBaseDPS(ch.RunicModel:getLevel())
    petDps = petDps + ch.RunicModel:getMDPSRate()* dps
    petDps = petDps + ch.AchievementModel:getRewardData(GameConst.ACHIEVEMENT_REWARD_BASE)
    petDps = petDps * ch.PetCardModel:getAllPowerDPS()
    petDps = petDps*ch.PartnerModel:getCurPartnerClickSpeed()
    dps = dps + petDps
    return dps
end

local getOffLineLevel = function(curLevel)
    local level = curLevel
	if level %5 == 0 then
        level = level -1 
	end
	return level
end

local getOffLineGold = function(level) -- levelControll有真正金币掉落的计算公式，这里将其略微修改
    local life = ch.fightRoleLayer:getLevelMaxHP(level,true)
    local fix = 1
    local gold = 0
    if (level < 200) then
        fix = 0.3*math.pow(1.005,level)
    else
        fix = 0.3*math.pow(1.005,200)+(level-200)*0.005
    end
    gold = life * (fix/15)
--    if (gold <level) then
--        gold = level
--    end
    gold = gold * (1 + ch.MagicModel:getMToMoneyAddition()) -- 宝物加成
    gold = gold * (1 + ch.TotemModel:getTotemSkillData(1,2)) -- 图腾加成
    gold = gold * (1 + ch.PartnerModel:getUpNum(4))  -- 宠物附加属性
    gold = gold *(1 + ch.BuffModel:getOGoldAddtion()) -- buff
    if ch.AltarModel:getAltarByType(1).level > 0 then -- 祭坛
        if ch.AltarModel.getFinalEffect then
            gold = gold * ch.AltarModel:getFinalEffect(1) -- 神坛
        else
            gold = gold * GameConfig.Altar_levelConfig:getData(ch.AltarModel:getAltarByType(1).level).ratio/10000 -- 祭坛
        end
    end
    return gold
end

-- 这里宝箱怪和金币暴击掉落的金钱都写死为10倍
local getRealOffLineGold = function(level)
    local gold = getOffLineGold(level)
    local chestChance = ch.fightRoleLayer:getChestProbability()
    local goldCritChance = ch.fightRoleLayer:getMoneyCritProbability()
    gold = gold *(1-chestChance) + 10*gold*chestChance* (1 + ch.TotemModel:getTotemSkillData(1,3))
    gold = gold*(1- goldCritChance) + goldCritChance*gold*10
    return gold
end

---
-- 计算奖励收益（小飞兔，任务，商店等）
-- @function [parent=#CommonFunc] getOffLineGold()
-- @param #CommonFunc self
-- @param #number time 单位为秒
-- @param #number curlevel 当前等级
-- @return #number
function CommonFunc:getOffLineGold(time,curlevel)
--[[
    print("this is new COMMONFUNC!!!")
    time = math.min(time, 24*3600)
    local ratio = 100
    local scale = time*ratio/(12*3600)
    if (scale<1) then
        scale = 1
    end
    time = math.floor(time*scale)
    ]]
        
    curlevel = curlevel or ch.LevelModel:getCurLevel()
    local level = getOffLineLevel(curlevel)
    --local gold = time *getOffLineMagicDps()/ch.fightRoleLayer:getLevelMaxHP(level,true)
    local oneTime = math.min(GameConst.OFFLINE_GOLD_CONFIG_TIME,math.ceil(math.pow(level,GameConst.OFFLINE_GOLD_POW)/GameConst.OFFLINE_GOLD_DIVISOR))
    local gold = (time/oneTime)*getRealOffLineGold(level)*GameConst.OFFLINE_GOLD_TO_RATIO
    return ch.LongDouble:ceil(gold)
end

local baseGoldRainNum = ch.LongDouble:new(1)
---
-- 显示金币雨
-- @function [parent=#CommonFunc] showGoldRain
-- @param #CommonFunc self
-- @param #number gold 金币数
function CommonFunc:showGoldRain(gold)
    if gold == 0 then return end
    local count = 0
    local g = gold
    while g > baseGoldRainNum do
        count = count + 1
        if count >= 50 then break end
        g= g/10
    end
    ch.goldLayer:dropMoneyByWorldPosition(400, 1200, count,1)
    self:playGoldSound(gold)
end

local showCount = 0

---
-- 显示金币收集效果
-- @function [parent=#CommonFunc] showCollectGold()
-- @param #CommonFunc self
-- @param #P startP 初始坐标点
-- @param #number gold 金币数
function CommonFunc:showCollectGold(startP,gold)
    ch.RoleResManager:loadEffect("tx_goumaijinbi")
    showCount = showCount + 1
    local endP = cc.p(50,1102)
    local intervalX = endP.x - startP.x
    local count = 0
    for i = 1,10 do
        zzy.TimerUtils:setTimeOut(2*(i-1)/30,function()
            local ani = ccs.Armature:create("tx_goumaijinbi")
            ani:getAnimation():play("play")
            ani:setScale(math.random(30,50)/100)
            ani:setPosition(startP)
            ch.UIManager:getNavigationLayer():addChild(ani)
            local r1 = math.random(15,50)/100 * intervalX
            local sx = math.random(1,2) == 1 and r1 or -r1
            local p1 = cc.p(startP.x - sx,startP.y)
            local p2 = cc.p(endP.x + sx,endP.y)
            local bezier = cc.BezierTo:create(1.5,{p1,p2,endP})
            local bezierEase = cc.EaseIn:create(bezier,1.8)
            local seq = cc.Sequence:create(bezierEase,cc.CallFunc:create(function()
                ani:removeFromParent()
                count = count + 1
                if count == 10 then
                    showCount = showCount - 1
                    if showCount == 0 then
                        ch.RoleResManager:releaseEffect("tx_goumaijinbi")
                    end
                end
            end))
            ani:runAction(seq)
        end)
    end
    self:playGoldSound(gold)
end

local baseGold1 = ch.LongDouble:new(1000)
local baseGold2 = ch.LongDouble:new(1000000)
---
-- 播放金币音效
-- @function [parent=#CommonFunc] playGoldSound()
-- @param #CommonFunc self
-- @param #number gold 金币数
function CommonFunc:playGoldSound(gold)
    if gold < baseGold1 then
        ch.SoundManager:play("gold1")
    elseif gold < baseGold2 then
        ch.SoundManager:play("gold2")
    else
        ch.SoundManager:play("gold3")
    end
end

---
-- 获得服务器下一天0点时间
-- @function [parent=#CommonFunc] getZeroTime()
-- @param #CommonFunc self
-- @return #number
function CommonFunc:getZeroTime()
    local tb = os.date("*t", os_time())
    tb.hour = 24
    tb.min = 0
    tb.sec = 0
    return os.time(tb)
end

---
-- 获得某天的某个整点时间
-- @function [parent=#CommonFunc] getAppointedTime
-- @param #CommonFunc self
-- @param #number time
-- @param #number hour
-- @return #number
function CommonFunc:getAppointedTime(time,hour)
    local tb = os.date("*t", time)
    tb.hour = hour
    tb.min = 0
    tb.sec = 0
    return os.time(tb)
end

---
-- 将总时间转化成小时，分钟，秒
-- @function [parent=#CommonFunc] getAppointedTime
-- @param #CommonFunc self
-- @param #number time
-- @param #bool isContainDay
-- @return #table {day =0,hour = 1,mintue =1,second =20}
function CommonFunc:timeToTimeSpan(time,isContainDay)
    local span = {}
    span.second = math.floor(time % 60)
    time = math.floor(time / 60)
    span.minute = math.floor(time % 60)
    time = math.floor(time / 60)
    if isContainDay then
        span.hour = math.floor(time % 24)
        span.day = math.floor(time / 24)
    else
        span.hour = time
    end
    return span
end

---
-- 获取产品名
-- @function [parent=#CommonFunc] getProductName
-- @param #CommonFunc self
-- @return #name
function CommonFunc:getProductName()
    local name=""
	if zzy.config.debugMode==1 then
        name=name.."test."
    end

	name=name.."dmw"
	local flag= string.sub(zzy.Sdk.getFlag(),1,2)
	if flag=="HD" then
		if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE 
		or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD then
			if zzy.Sdk.getFlag()=="HDIOS" then
				name=name.."a"
			elseif zzy.Sdk.getFlag()=="HDXGS" then
				name=name.."g"
			else
				name=name.."i"
			end
		else
			if zzy.Sdk.getFlag()=="HDTX" then
				name=name.."y"
			end
		end
	elseif flag=="CY" then
		if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE 
			or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD then
			name=name.."a"
		end
	elseif flag=="WE" then
		name=name.."e"
	end
    return name
end
---
-- 获取域名
-- @function [parent=#CommonFunc] getDomain
-- @param #CommonFunc self
-- @return #name
function CommonFunc:getDomain()
    local url=""
	local flag= string.sub(zzy.Sdk.getFlag(),1,2)
	if flag=="HD" then
	     url="hardtime.zizaiyouxi.com"
    elseif flag=="WY" or flag=="WE"  then
		 url="sail2world.com"
	elseif flag=="TJ" then
		 url="skylinematrix.com"
	elseif flag=="CY" then
		 url="cy.com"
	end   
	return url
end

---
-- 获取货币名
-- @function [parent=#CommonFunc] getCoinName
-- @param #CommonFunc self
-- @return #name
function CommonFunc:getCoinName()
	local flag= string.sub(zzy.Sdk.getFlag(),1,2)
	if flag=="WY" then
		return "NT"
    elseif flag=="TJ" then
		if zzy.Sdk.getFlag()=="TJIOS" then
			return "USD"
		else
			return "원"
		end
	elseif flag=="CY" then
		return "USD"
	elseif flag=="WE" then
		return "USD"
	end
	return "RMB"
end

---
-- 获取货币类型(1 人民币 2台币 3韩币 4美元)
-- @function [parent=#CommonFunc] getCoinType
-- @param #CommonFunc self
-- @return #name
function CommonFunc:getCoinType()
	local flag= string.sub(zzy.Sdk.getFlag(),1,2)
	if flag=="WY" then
		return 2
    elseif flag=="TJ" then
		if zzy.Sdk.getFlag()=="TJIOS" then
			return 4
		else
			return 3
		end
	elseif flag=="CY" then
		return 4
	elseif flag=="WE" then
		return 4
	end
	return 1
end

---
-- 消费
-- @function [parent=#CommonFunc] consumption
-- @param #CommonFunc self
-- @return #name
function CommonFunc:consumption(data)

	local orderdata=json.decode(data)
	--orderdata.payitemid="com.zzy.bigdevil.wydmw.10004"
	orderdata.data=data
	
	 local tb_price={}
	 for k,v in pairs(GameConfig.ShopConfig:getTable()) do
		if v.channelId == zzy.Sdk.getFlag() and v.shopType == 1 and v.type_cost==1 then
			tb_price[v.itemId]=v.price
		end
	end
	
	orderdata.paycash=tb_price[orderdata.payitemid]
	local orderInfo=json.decode(cc.UserDefault:getInstance():getStringForKey("orderInfo")) or {}
	local mark=false
	for k,v in pairs (orderInfo) do
		if json.decode(v.d).cporderid==orderdata.cporderid then
			mark=true
			break
		end
	end
	
	if mark==false then
		table.insert(orderInfo,{d=data,time=os_time(),count=1,cporderid=orderdata.cporderid})
		cc.UserDefault:getInstance():setStringForKey("orderInfo",json.encode(orderInfo))
        cc.UserDefault:getInstance():flush()
	end
	
	local url="http://bill."
	url=url..ch.CommonFunc:getProductName().."."..ch.CommonFunc:getDomain().."/"..string.lower(zzy.Sdk.getFlag()).."_"
	if orderdata.chargetype then
		url=url..orderdata.chargetype.."_"
	end
	url=url.."recharge.php?orderdata="..zzy.StringUtils:urlencode(data).."&paycash="..orderdata.paycash
	ch.CommonFunc:getNetString(url, function(err, str)
        local m_orderInfo=json.decode(cc.UserDefault:getInstance():getStringForKey("orderInfo")) or {}
		if err==0 then
			 local  content=json.decode(str)
			 if content.ret==0 then
				--remove succ order
                for k,v in pairs (m_orderInfo) do
                    if json.decode(v.d).cporderid==content.orderid then
                        m_orderInfo[k]=nil
                        break
                    end
                end
			 else
                if content.ret==2026 or content.ret==1101 then
                    for k,v in pairs (m_orderInfo) do
                        if json.decode(v.d).cporderid==content.orderid then
                            m_orderInfo[k]=nil
                            break
                        end
                    end
                end
				-- ch.UIManager:showMsgBox(1,true,Language.src_clickhero_controller_NetworkController2_2..content.ret,nil,nil,Language.MSG_BUTTON_OK)
			 end
		else
			 ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[1].."("..GameConst.NET_ERROR[5]..err..")",
				function()
                    for k,v in pairs (m_orderInfo) do
                        if json.decode(v.d).cporderid==content.orderid then
                            v.count = v.count + 1
                            break
                        end
                    end 
                    ch.CommonFunc:consumption(data)
			end,nil,Language.MSG_BUTTON_RETRY)
		end

        cc.UserDefault:getInstance():setStringForKey("orderInfo",json.encode(m_orderInfo))
        cc.UserDefault:getInstance():flush()
	end)
end

---
-- 获取无忧签名sig
-- @function [parent=#CommonFunc] getDomain
-- @param #CommonFunc self
-- @return #name
function CommonFunc:getWYSig(o)
    local key_table= zzy.TableUtils:sortTableByKey(o)
	local sig=""
	for _,key in pairs(key_table) do  
		sig=sig..key.."="..o[key]
	end  
    sig=sig..zzy.config.wykey
    cclog("sig "..sig )
    sig= md5.sumhexa(sig)
	return sig
end
---
-- 获取cpsid 如果没有返回channelid
-- @function [parent=#CommonFunc] getCpsid
-- @param #CommonFunc self
-- @return #name
function CommonFunc:getCpsid()
    return zzy.config.cpsid
end

---
-- 异步访问http
-- @function [parent=#CommonFunc] getNetString
-- @param #CommonFunc self
-- @param #string url 网址
-- @param #string url 网址
-- @return #func
function CommonFunc:getNetString(url,func)
   ch.UIManager:showWaiting(true)
   zzy.cUtils.getNetString(url, function(err, str)
      ch.UIManager:showWaiting(false)
      func(err, str)
   end)
end

---
-- 添加物品
-- t 1为代币，2为宠物，3为buff，4为时长金币，5为卡牌（碎片）,6最高关计算相关魂数量,7侍宠,9通用符文包
-- @function [parent=#CommonFunc] addItems
-- @param #CommonFunc self
-- @param #table items [{id=90001,num =2000,t =1}...] 
function CommonFunc:addItems(items)
    for k,item in ipairs(items) do
        local type = tonumber(item.t)
        if type == 1 then  -- 代币
            local id = tonumber(item.id)
            local num
            if id == 90002 then
                num = ch.LongDouble:toLongDouble(tostring(item.num))
            else
                num = tonumber(item.num)
            end
            if id == 90008 then   --力量源泉
                ch.TaskModel:addPowerNum(num)
            elseif id == 90009 then  --圣光转移次数
                ch.ShopModel:addStarSoulCount(num)
            elseif id == 90010 or id == 90030 then  --体力
                DEBUG("加体力")
                item.id = 90010
                ch.CardFBModel:addStamina(num)
            elseif id == 90016 then
                -- 公会经验
            elseif id == 90017 then
                -- 个人贡献
            elseif id == 90031 then
                DEBUG("加转生次数")
                ch.ShopModel:addSamsaraCount(num)
            elseif id == 90032 then
                DEBUG("加神灵")
                ch.MoneyModel:addGods(num)
            else
                ch.MoneyModel:addMoney(id,num)
            end
            if id == tonumber(ch.MoneyModel.dataType.gold) then
                ch.CommonFunc:playGoldSound(num)
            end
        elseif type == 2 then  -- 宠物
            ch.PartnerModel:getOne(tostring(item.id))
        elseif type == 3 then  -- buff
            ch.BuffModel:addBuff(item.id,item.num)
        elseif type == 4 then  -- 时长金币
            local id = 90002
            local num = ch.CommonFunc:getOffLineGold(tonumber(item.num))
            ch.MoneyModel:addMoney(id,num)
            ch.CommonFunc:playGoldSound(num)
        elseif type == 5 then -- 卡牌
            ch.PetCardModel:addChipByChipId(item.id,item.num)
        elseif type == 6 then    -- 最高关卡获得魂或魂石
            local level = math.floor(ch.StatisticsModel:getMaxLevel()/5)*5
            local id = 90004
            if item.id == 40100 then  -- 最高关卡获得魂石
                id = 90004
            elseif item.id == 40101 then  -- 最高关卡获得魂
                id = 90003
            end
            local num = math.floor(ch.LevelController:getPrimalHeroSoulRewards(level)*item.num)
            if num < 1 then
                num = 1
            end
            ch.MoneyModel:addMoney(id,num)
        elseif type == 7 then  -- 侍宠
            ch.FamiliarModel:addFamiliar(item.id)
        elseif type == 9 then  -- 通用符文包
            local id = 90011
            if item.id == 40200 then
                id = 90011
            end
            local num =GameConst.COMMON_RUNIC_NUM[ch.CardFBModel:getMAXFBLevel()]*item.num
            ch.MoneyModel:addMoney(id,num)
        elseif type == 11 then
            if item.id == 90014 then
            -- 绿宝石
            end
        end
    end
end

function CommonFunc:formateItems(items)
    for k,item in ipairs(items) do
        local type = tonumber(item.t)
        if type == 1 then  -- 代币
            local id = tonumber(item.id)
            if id == 90002 then   --金币
                item.num = ch.LongDouble:toLongDouble(tostring(item.num))
            else
                item.num = tonumber(item.num)
            end
        else
            item.num = tonumber(item.num)
        end
    end
end

---
-- 获得奖励图标
-- @function [parent=#CommonFunc] getRewardIcon
-- @param #CommonFunc self
-- @param #number type
-- @param #number id
-- @return #string
function CommonFunc:getRewardIcon(type,id)
    if type == 0 then
        return "res/icon/moneyGolds.png"
    end
    local index =""
    if type == 1 then
        if id == 90012 and ch.ChristmasModel:isOpenByType(1001) then
            local cfgid = ch.ChristmasModel:getCfgidByType(1001)
            local cfgData = GameConst.HOLIDAY_SDDH_MONEY_DATA[cfgid]
            return GameConst.SDDH_MONEY_ICON[cfgData.moneyType]
        else
            index = "db"..id
        end
    elseif type == 2 then
        index = "cw"..id
    elseif type == 3 then
        index = "bf"..id
    elseif type == 4 then
        return GameConst.MSG_FJ_ICON[1]["db90002"]
    elseif type == 5 then
        if id >51000 then
            return GameConst.CARD_GET_ICON.chips
        else
            return GameConst.CARD_GET_ICON.card
        end
    elseif type == 6 then
        if id == 40100 then
            return GameConst.MSG_FJ_ICON[1]["db90004"]
        elseif id == 40101 then
            return GameConst.MSG_FJ_ICON[1]["db90003"]
        end
    elseif type == 7 then
        return "res/icon/icon_boss.png"
    elseif type == 9 then
        if id == 40200 then
            return GameConst.MSG_FJ_ICON[1]["db90011"]
        end
    elseif type == 10 then
        index = "db"..id
        return GameConst.MSG_FJ_ICON[1][index]
    elseif type == 11 then
        index = "db"..id
        return GameConst.MSG_FJ_ICON[1][index]
    end
    return GameConst.MSG_FJ_ICON[type][index]
end

---
-- 获得奖励名称
-- @function [parent=#CommonFunc] getRewardName
-- @param #CommonFunc self
-- @param #number type
-- @param #number id
-- @return #string
function CommonFunc:getRewardName(type,id)
    if type == 0 then
        return ""
    end
    local index =""
    if type == 1 then
        if id == 90012 and ch.ChristmasModel:isOpenByType(1001) then
            local cfgid = ch.ChristmasModel:getCfgidByType(1001)
            local cfgData = GameConst.HOLIDAY_SDDH_MONEY_DATA[cfgid]
            return Language.SDDH_MONEY_NAME[cfgData.moneyType]
        else
            index = "db"..id
        end
    elseif type == 2 then
        index = "cw"..id
    elseif type == 3 then
        index = "bf"..id
    elseif type == 4 then
        return GameConst.MSG_FJ_NAME[1]["db90002"]
    elseif type == 5 then
        return GameConfig.CardConfig:getData(id).name
    elseif type == 6 then
        if id == 40100 then
            return GameConst.MSG_FJ_NAME[1]["db90004"]
        elseif id == 40101 then
            return GameConst.MSG_FJ_NAME[1]["db90003"]
        end
    elseif type == 7 then
        return GameConfig.FamiliarConfig:getData(id).name
    elseif type == 9 then
        if id == 40200 then
            return GameConst.MSG_FJ_NAME[1]["db90011"]
        end
    elseif type == 10 then
        index = "db"..id
        return GameConst.MSG_FJ_NAME[1][index]
    elseif type == 11 then
        index = "db"..id
        return GameConst.MSG_FJ_NAME[1][index]
    end
    return GameConst.MSG_FJ_NAME[type][index]
end

---
-- 获得奖励数量
-- @function [parent=#CommonFunc] getRewardValue
-- @param #CommonFunc self
-- @param #number type
-- @param #number id
-- @param #number num
-- @return #string
function CommonFunc:getRewardValue(type,id,num)
    if type == 3 then
        return string.format(Language.MSG_G_HOUR,num/3600)
    elseif type == 4 then
        return string.format(Language.MSG_G_HOUR,num/3600)
--        local tmpNum = ch.CommonFunc:getOffLineGold(num)
--        return ch.NumberHelper:toString(tmpNum)
    elseif type == 6 then
        local level = math.floor(ch.StatisticsModel:getMaxLevel()/5)*5
        local tmpNum = math.floor(ch.LevelController:getPrimalHeroSoulRewards(level)*num)
        if tmpNum < 1 then
            tmpNum = 1
        end
        return tmpNum
    elseif type == 9 then  -- 通用符文包
        return GameConst.COMMON_RUNIC_NUM[ch.CardFBModel:getMAXFBLevel()]*num
    else
        return ch.NumberHelper:toString(num)
    end
end

---
-- 获得奖励大图标
-- @function [parent=#CommonFunc] getRewardBigIcon
-- @param #CommonFunc self
-- @param #number type
-- @param #number id
-- @return #string
function CommonFunc:getRewardBigIcon(type,id)
    local index =""
    if type == 1 then
        index = "db"..id
    elseif type == 2 then
        index = "cw"..id
    elseif type == 3 then
        index = "bf"..id
    elseif type == 4 then
        return GameConst.MSG_FJ_BIG_ICON[1]["db90002"]
    elseif type == 5 then
        local cardId
        if id >51000 then
            cardId =  GameConfig.CardConfig:getData(id).enid
        else
            cardId = id
        end
        return GameConfig.CardConfig:getData(cardId).mini
    elseif type == 6 then
        if id == 40100 then
            return GameConst.MSG_FJ_BIG_ICON[1]["db90004"]
        elseif id == 40101 then
            return GameConst.MSG_FJ_BIG_ICON[1]["db90003"]
        end
    elseif type == 7 then
        return "res/icon/icon_boss.png"
    elseif type == 9 then
        if id == 40200 then
            return GameConst.MSG_FJ_BIG_ICON[1]["db90011"]
        end
    end
    return GameConst.MSG_FJ_BIG_ICON[type][index]
end

---
-- 显示主角形象
-- @function [parent=#CommonFunc] showRoleAvatar
-- @param #CommonFunc self
-- @param #Wiget widget
-- @param #string roleName
-- @param #string weapon
function CommonFunc:showRoleAvatar(widget,roleName,weapon)
    DEBUG("[CommonFunc:showRoleAvatar]"..roleName)
    ch.RoleResManager:load(roleName,function()
        if zzy.CocosExtra.isCobjExist(widget) then
            local ani = self:createRoleAvatar(roleName,weapon)
            self:playAni(ani, "stand", true)
            widget:addChild(ani)
        else
            ch.RoleResManager:release(roleName)
        end
    end)
end

---
-- 显示主角形象
-- @function [parent=#CommonFunc] createRoleAvatar
-- @param #CommonFunc self
-- @param #string roleName
-- @param #string weapon
-- @return #Armature
function CommonFunc:createRoleAvatar(roleName,weapon)
    DEBUG("[CommonFunc:createRoleAvatar]"..roleName)
    local ani = self:createAnimation(roleName)
    self:changeWeapon(ani, weapon)

    return ani
end

function CommonFunc:changeWeapon(ani, weapon)
    if not ani then return end
    if not weapon then return end

    if ch.CommonFunc:isSpine(ani) then
        if weapon == "res/icon/weapon2.png" then
            ani:setTexture("weapon01", "weapon02", "")
        end
        if weapon == "res/icon/weapon3.png" then
            ani:setTexture("weapon01", "weapon03", "")
        end
        if weapon == "res/icon/weapon4.png" then
            ani:setTexture("weapon01", "weapon04", "")
        end
        if weapon == "res/icon/weapon5.png" then
            ani:setTexture("weapon01", "weapon05", "")
        end
        if weapon == "res/icon/weapon6.png" then
            ani:setTexture("weapon01", "weapon06", "")
        end
        if weapon == "res/icon/weapon7.png" then
            ani:setTexture("weapon01", "weapon07", "")
        end
        if weapon == "res/icon/weapon8.png" then
            ani:setTexture("weapon01", "weapon08", "")
        end
        if weapon == "res/icon/weapon9.png" then
            ani:setTexture("weapon01", "weapon09", "")
        end
    else
        local sprite = ccs.Skin:create(weapon)
        sprite:setAnchorPoint(0.13,0.38)
        ani:getBone("weapon"):addDisplay(sprite,1)
        ani:getBone("weapon"):changeDisplayWithIndex(1,true)
    end
end

---
-- 合服名字处理
-- @function [parent=#CommonFunc] getNameNoSever
-- @param #CommonFunc self
-- @param #string name
-- @return #string
function CommonFunc:getNameNoSever(name)
    if name and name ~= "" then
        return string.gsub(name,"%.s[0-9]+","")
    end
    return ""
end

---
-- 卡牌掉落合成特效
-- @function [parent=#CommonFunc] cardDropEffect
-- @param #CommonFunc self
-- @param #string cardId
function CommonFunc:cardDropEffect(cardId)
    ch.RoleResManager:loadEffect("tx_kapaichuxian")
    local ani = ccs.Armature:create("tx_kapaichuxian")
    ani:getAnimation():play("chuxian",-1,0)
    local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    ani:setPosition(size.width/2,size.height/2)
    ch.UIManager:getNavigationLayer():addChild(ani,1)
    ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.complete then
            ani:removeFromParent()
            ch.RoleResManager:releaseEffect("tx_kapaichuxian")
        end
    end)
    
    if true then return end --tgx 不显示合成卡牌之后的大图
    
    zzy.TimerUtils:setTimeOut(0.6,function()
        local path = GameConfig.CardConfig:getData(cardId).img
        local spr = cc.Layer:create()
        
        
        
        local scale = 640/spr:getContentSize().width
        
        CommonFunc:showCardSke(spr, cardId, scale*0.8, 0, 300)
        
        --spr:setScale(scale)
        --spr:setPosition(size.width/2,size.height/2)
        ch.UIManager:getNavigationLayer():addChild(spr)
        zzy.TimerUtils:setTimeOut(1.2,function()
            local act1 = cc.FadeOut:create(5.0)
            local seq = cc.Sequence:create(act1,cc.CallFunc:create(function()
                spr:removeFromParent()
            end))
            spr:runAction(seq)
            local scale = spr:getScale()*1.5
            local act2 = cc.EaseExponentialIn:create(cc.ScaleTo:create(0.3,scale))
            spr:runAction(act2)
        end)
    end)
end

---
-- 不同汇率处理钻石换货币(未取整)
-- @function [parent=#CommonFunc] getMoneyByDiamond
-- @param #CommonFunc self
-- @param #number diamond
-- @return #number
function CommonFunc:getMoneyByDiamond(diamond)
    diamond = diamond or 0
    return diamond*zzy.config.exchange_rate/10
end

---
-- 不同汇率处理货币换钻石(未取整)
-- @function [parent=#CommonFunc] getDiamondByMoney
-- @param #CommonFunc self
-- @param #number money
-- @return #number
function CommonFunc:getDiamondByMoney(money)
    money = money or 0
    return money*10/zzy.config.exchange_rate
end

function CommonFunc:showCardSke(aniPanel, cardId, scale, xOffset, yOffset, _roleName, aniName)
    _G_SKES = _G_SKES or {}
    local config = GameConfig.CardConfig:getData(cardId)
    
    local img_card = ccui.Helper:seekWidgetByName(aniPanel, "img_card")
    if img_card then
        img_card:setVisible(false)
    end
        
    local scaleConfig = {
        xiaohuangrenC = 1.6
        ,gesila = 0.8
        ,maoguai = 0.9
        ,dabaibai = 0.9
        ,dayanjing = 1.6
        ,luokeren  = 1.6
        ,aoteman = 1.2
        ,huanxiong = 1.2
        ,nanjue = 1.6
        ,heiwushi = 1.1
    }
    
    local xoffSetConfig = {
        pikaqiu = 50
        ,gesila = 0
    }
    
    local roleName = _roleName or config.avatar
    DEBUG("create roleName=%s", roleName)
    
    ch.RoleResManager:load(roleName, function(roleName)
        table.insert(_G_SKES, roleName)
        if aniPanel._cardNode then
            aniPanel._cardNode:destory()
        end
        
        local cardNode = ch.fightRole:create(roleName, 90000, 1, ch.fightRole.roleType.monster, GameConst.GUAI_ACTION_SPEED_SCALE)
        local ani = cardNode._roleAni or cardNode._ani
        ani:setPosition(0,0)
        
        

        if not zzy.CocosExtra.isCobjExist(aniPanel) then
            return
        end
        
        local panelSize = aniPanel:getContentSize()
        local rate = scaleConfig[roleName] or 1
        if self:isSpine(ani) then
            rate = 2
            xoffSetConfig[roleName] = 0
        end
        
        aniPanel:addChild(cardNode)
        cardNode:setAnchorPoint(0.5,0.5)
        cardNode:setPosition(panelSize.width/2+(xOffset or 0)+(xoffSetConfig[roleName] or 0)*(scale or 1), 150+(yOffset or 0)-20)
        cardNode:setLocalZOrder(10)
        --cardNode._roleAni:getAnimation():play("stand",-1,1)
        cardNode:setScale(rate*(scale or 1))
        if self:isSpine(ani) then
            ani:setAnimation(0, aniName or "idle", true)
        else
            ani:setScaleX(-1) --水平翻转
        end

        aniPanel._cardNode = cardNode
    end)
    -- tgx
    
    aniPanel:registerScriptHandler(function(eventType)
        if eventType == "cleanup" then
            DEBUG("aniPanel:removeFromParent()")
            if aniPanel._cardNode and aniPanel._cardNode:getParent() then
                aniPanel._cardNode:destory()
                aniPanel._cardNode = nil
                DEBUG("aniPanel._cardNode:destory")
                
                aniPanel:unregisterScriptHandler()
            end
        elseif eventType == "exit" then

        end
    end)
end

function CommonFunc:delCardSkes()
    for k,v in pairs(_G_SKES or {}) do
        INFO("relase roleName=%s", v)
        ch.RoleResManager:release(v)
    end
    
    _G_SKES = {}
end

function CommonFunc:getTimeZoneDiff()
    local ServerTimeZone = 28800 --+8时区
    local function get_timezone()
        local now = os.time()
        return os.difftime(now, os.time(os.date("!*t", now)))
    end
    local localTimeZone = get_timezone()
    --DEBUG("本地时区="..localTimeZone)
    local timeZoneD = ServerTimeZone - localTimeZone  --计算出服务端时区与客户端时区差值
    
    return timeZoneD
end

--重新登录
function CommonFunc:gotoLogin()
    --local scene = cc.Scene:create()
    --cc.Director:getInstance():replaceScene(scene)
    
    zzy.NetManager:getInstance():disconnect()
    __G__ONRESTART__()
    package.loaded["src/main.lua"] = nil
    require("src/main.lua")
end

--添加返回键监听
function CommonFunc:addBackListener(_scene)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
    if (cc.PLATFORM_OS_ANDROID ~= targetPlatform) then
        return
    end

    DEBUG("[CommonFunc:addBackListener]")
    
    --监听手机返回键
    local key_listener = cc.EventListenerKeyboard:create()
    
    --返回键回调
    local function key_return(keycode)
		DEBUG("[key_return]keycode="..keycode)
        if keycode == 6 then
            cc.libPlatform:getInstance():exitGame()
        end
    end
    
    local scene = _scene or gameScene
    key_listener:registerScriptHandler(key_return, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatch = scene:getEventDispatcher()
    eventDispatch:addEventListenerWithSceneGraphPriority(key_listener,scene)
end

--将"FF0000"转成cc.c3b(255, 0, 0)
function CommonFunc:hexStringToColor3b(hexString)
    if  not (hexString and string.len(hexString) >= 6) then
        return cc.c3b(0,0,0)
    end

    local function hex2dec(hex)
        local dec = tonumber(string.format("%d", "0x"..hex))
        return dec
    end
    local r = hex2dec(string.sub(hexString, 1,2))
    local g = hex2dec(string.sub(hexString, 3,4))
    local b = hex2dec(string.sub(hexString, 5,6))
    DEBUG("[hexStringToColor3b]r=%d, g=%d, b=%d", r,g,b)
    local colorC3b = cc.c3b(r or 0,g or 0,b or 0)
    return colorC3b
    
end

function CommonFunc:useSpine(_roleName)
    if (not _roleName) or (_roleName == "") then return false end
    
    local roleJson = string.format("res/spine/%s.json", _roleName)
    local roleSkel = string.format("res/spine/%s.skel", _roleName)
    local isJsonExist = cc.FileUtils:getInstance():isFileExist(roleJson)
    local isSkelExist = cc.FileUtils:getInstance():isFileExist(roleSkel)

    if (USE_SPINE or IS_IN_REVIEW) and (isJsonExist or isSkelExist) then
        if isJsonExist then
            return roleJson
        end

        if isSkelExist then
            return roleSkel
        end
    else
        return false
    end
end

function CommonFunc:createAnimation(_roleName)
    if not _roleName then 
    return 1 
    end

    local roleName = "role_".._roleName
    --DEBUG("[CommonFunc:createAnimation]roleName=%s", roleName)
    
    local isMainRole = string.find(roleName, "nanzhanshi")
    if IS_IN_REVIEW and isMainRole then
        roleName = "role_R4_nanzhanshi"
    end

    if self:useSpine(roleName) then
        return self:createSpine(roleName)
    else
        roleName = _roleName
        return self:createArmature(roleName)
    end
end

function CommonFunc:createSpine(_roleName)
    local roleName = _roleName
    local scale = GameConst.spine_scale[roleName] or 1
    local roleJson = self:useSpine(roleName)
    if roleJson  then
        local roleAtlas = string.format( "res/spine/%s.atlas", roleName)
        --DEBUG("[CommonFunc:createSpine]json="..roleJson)
        local ani = sp.SkeletonAnimation:create(roleJson, roleAtlas, scale)

        local isMainRole = string.find(roleName, "nanzhanshi")
        if isMainRole then
            ani:setTexture("weapon", "weapon", "")
        else

        end

        if _roleName == "role_daqiao" then
            ani:setScaleX(ani:getScaleX()*-1)
        end
        ani._type = "spine"
        return ani
    else
        return ccs.Armature:create(roleName)
    end
end

function CommonFunc:createArmature(_roleName)
    local roleName = _roleName
    return ccs.Armature:create(_roleName)
end

function CommonFunc:isSpine(obj)
    if not obj then return false end
    
    local ani = obj._ani or obj._roleAni or obj
    return ani._type == "spine"
end

function CommonFunc:getHpBarPos(obj, boneName)
    if ch.CommonFunc:isSpine(obj) then
        local ani = obj._ani or obj._roleAni or obj

        local newX = 0
        local newY = ani:getBoundingBox().height --tgx
        return cc.p(newX,newY)
    else
        local ani = obj._roleAni or obj._ani
        local newY = ani:getContentSize().height --tgx
        newY = math.min(newY, 250)
        newX = 0
        return cc.p(newX,newY)
    end
end

function CommonFunc:getFramesCount(skillId)
    local frameCounts = {
        [3] = 49,
        [5] = 34,
        [7] = 16,
        [6] = 40,
        [2] = 50,
        [1] = 40,
        [4] = 47,
    }

    local count = frameCounts[skillId] or 30
    return count
end

function CommonFunc:setAniCb(_ani, _cb)
    local ani = _ani
    
    local function callBackSpine(...)
        local args = {...}
        local armatureBack = nil
        local movementType = nil

        local movementID = args[1].animation
        local spineEventType = args[1].type
        --DEBUG("[spine][callback]role=%d,ani=%s,event=%s", obj._roleType, movementID, spineEventType)

        if spineEventType == "start" and _ani.start then
            --DEBUG("[SPINE][ANIMATION_START]")
            --movementType = ccs.MovementEventType.start
        elseif spineEventType == "end" then
            --DEBUG("[SPINE][ANIMATION_END]")
            --movementType = ccs.MovementEventType.complete
        elseif spineEventType == "complete" then
            --DEBUG("[SPINE][ANIMATION_COMPLETE]")
            movementType = ccs.MovementEventType.complete
            --movementType = ccs.MovementEventType.loopComplete
        elseif spineEventType == "event" then
            --DEBUG("[SPINE][ANIMATION_EVENT]")
        end

        if movementType and movementID then
            _cb(armatureBack, movementType, movementID)
        end
    end

    local function callBackArmatrue(...)
         _cb(...)
    end

    if self:isSpine(_ani) then
        ani:registerSpineEventHandler(callBackSpine, sp.EventType.ANIMATION_START)
        ani:registerSpineEventHandler(callBackSpine, sp.EventType.ANIMATION_END)
        ani:registerSpineEventHandler(callBackSpine, sp.EventType.ANIMATION_COMPLETE)
        ani:registerSpineEventHandler(callBackSpine, sp.EventType.ANIMATION_EVENT)
    else
        ani:getAnimation():setMovementEventCallFunc(callBackArmatrue)
    end
end

function CommonFunc:playAni(_ani, _aniName, _isLoop)
    if not (_ani and _aniName) then return end

    if self:isSpine(_ani) then
        _ani:setTimeScale(1);
        if _aniName == "hurt" or _aniName == "hitted" then
            _aniName = "hitted" --spine里的hurt全部改为hitted
            _ani:setTimeScale(0.45);
        end
        if _aniName == "move" then
            _aniName = "walk" --spine里的move全部改为walk
        end
        if _aniName == "stand" then
            _aniName = "idle" --spine里的全部改为idle
        end
        _ani:setAnimation(0, _aniName, _isLoop or false)
    else
        local isLoop = _isLoop and 1 or 0
        if _ani:getAnimation():getAnimationData():getMovement(_aniName) then
            _ani:getAnimation():play(_aniName, -1, isLoop)
        end
    end
end

function CommonFunc:pauseAni(_ani)
    if not _ani then return false end

    if self:isSpine(_ani) then
        --NOTHING TODO
    else
        _ani:getAnimation():pause()
    end
end

function CommonFunc:resumeAni(_ani)
    if not _ani then return false end

    if self:isSpine(_ani) then
        --NOTHING TODO
    else
        _ani:getAnimation():resume()
    end
end

function CommonFunc:stopAni(_ani)
    if not _ani then return false end

    if self:isSpine(_ani) then
        --NOTHING TODO
        self:playAni(_ani, "idle", false)
    else
        _ani:getAnimation():stop()
    end
end

function CommonFunc:speedAni(_ani, _ratio)
    if not _ani then return false end
    
    if self:isSpine(_ani) then
        --NOTHING TODO
    else
        _ani:getAnimation():setSpeedScale(_ratio)
    end
end

return CommonFunc 