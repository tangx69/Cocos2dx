
local getTime = function(time)
    if time > 0 then
        local second = math.floor(time%60)
        time = time /60
        local minute = math.floor(time%60)
        local hour = math.floor(time/60)
        return string.format("%02d:%02d:%02d",hour,minute,second)
    else
        return 0
    end
end

-- 待加入公会列表页
zzy.BindManager:addFixedBind("Guild/W_NewGuild_join", function(widget)
    local searchChangeEvent = {}
    searchChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.search
    end
    
    local applyChangeEvent = {}
    applyChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.GuildModel.dataType.apply
    end
    
    widget:addDataProxy("applyNum",function(evt)
        return ch.GuildModel:myGuildApplyTimeNum() .."/"..GameConst.GUILD_APPLY_NUM
    end,applyChangeEvent)
    local m_editBox
    local name = ""
    widget:addDataProxy("searchName",function(evt)
        return name
    end)
    
    -- 修改
    local ctr = widget:getChild("TextField_search")
    local ctrName = ctr:getDescription()
    if ctrName == "TextField" then
        local m_editBoxSize = ctr:getContentSize()
        m_editBox = ccui.EditBox:create(m_editBoxSize, ccui.Scale9Sprite:create())
        m_editBox:setPosition(cc.p(ctr:getPositionX(), ctr:getPositionY()))
        m_editBox:setFontSize(ctr:getFontSize())
        m_editBox:setAnchorPoint(ctr:getAnchorPoint())
        m_editBox:setPlaceHolder(ctr:getPlaceHolder())
        m_editBox:setMaxLength(ctr:getMaxLength())
        m_editBox:setText("")
        ctr:getParent():addChild(m_editBox)
        ctr:getParent():removeChild(ctr,true)
    end
        
    -- 确认搜索
    widget:addCommond("search",function()
        name = m_editBox:getText()        
        if name == "" then
            ch.UIManager:showMsgBox(1,true,GameConst.CNAME_ERROR[5])
        else
            ch.NetworkController:guildDetail(nil,name,2)
        end
        cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
    end)

    widget:addDataProxy("list",function(evt)
        local tmpTable = {}
        for k,v in pairs(ch.GuildModel:getGuildMemberList()) do
            table.insert(tmpTable,{index = k,value = v})
        end
        return tmpTable
    end,searchChangeEvent)
    
    -- 刷新搜索结果（暂未开放此功能）
    widget:addCommond("refresh",function()
        ch.NetworkController:refreshGuild()
    end)
end)

-- 待加入公会列表页单元
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_join_1", function(widget,data)
    local searchChangeEvent = {}
    searchChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.search
    end
    widget:addDataProxy("guildIcon",function(evt)
        return GameConst.GUILD_FLAG[data.value.flag]
    end,searchChangeEvent)

    widget:addDataProxy("guildName",function(evt)
        return ch.CommonFunc:getNameNoSever(data.value.name)
    end,searchChangeEvent)

    widget:addDataProxy("guildLevel",function(evt)
        local Button_lv = zzy.CocosExtra.seekNodeByName(widget, "Button_lv")
        if IS_BANHAO and Button_lv then
            Button_lv:setContentSize(150, 78)
            Button_lv:setTitleFontName("aaui_font/ch.ttf")
        end
        
        return data.value.level or 1
    end,searchChangeEvent)

    widget:addDataProxy("canLook",function(evt)
        return true
    end,searchChangeEvent)
    widget:addDataProxy("canJoin",function(evt)
        return data.value.apply ~= 1 and ch.GuildModel:myGuildApplyTimeNum() < GameConst.GUILD_APPLY_NUM
    end,searchChangeEvent)
    
    widget:addCommond("join",function()
--        ch.UIManager:showGamePopup("Guild/W_GuildJoinpop",data.value)
        ch.NetworkController:guildApply(data.value.id)
    end)
    widget:addCommond("look",function()
        ch.NetworkController:guildDetail(data.value.id,nil,2)
--        ch.UIManager:showGamePopup("Guild/W_NewGuild_information")
    end)
end)

-- 我的公会界面
zzy.BindManager:addFixedBind("Guild/W_NewGuild_my", function(widget)
    local searchChangeEvent = {}
    searchChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.panel
    end
    local nameFlagChangeEvent = {}
    nameFlagChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.panel
            or evt.dataType == ch.GuildModel.dataType.name
            or evt.dataType == ch.GuildModel.dataType.flag
    end
    
    local guildExpChangeEvent = {}
    guildExpChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.GuildModel.dataType.guildExp
            or evt.dataType == ch.GuildModel.dataType.panel
            or evt.dataType == ch.GuildModel.dataType.level
    end
    local guildLvChangeEvent = {}
    guildLvChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.level
            or evt.dataType == ch.GuildModel.dataType.panel
    end
--    local personExpChangeEvent = {}
--    personExpChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
--        return evt.dataType == ch.GuildModel.dataType.personExp
--    end
    
    
--    local m_editBox
--    local name = ""
--    local isEditing = false
--    -- 修改
--    local ctr = widget:getChild("TextField_change")
--    local ctrName = ctr:getDescription()
--    if ctrName == "TextField" then
--        local m_editBoxSize = ctr:getContentSize()
--        m_editBox = ccui.EditBox:create(m_editBoxSize, ccui.Scale9Sprite:create())
--        m_editBox:setPosition(cc.p(ctr:getPositionX(), ctr:getPositionY()))
--        m_editBox:setFontSize(ctr:getFontSize())
--        m_editBox:setAnchorPoint(ctr:getAnchorPoint())
--        m_editBox:setPlaceHolder(ctr:getPlaceHolder())
--        m_editBox:setMaxLength(GameConst.CHAT_MAX_CHAR_COUNT)
--        m_editBox:setText("")
--        ctr:getParent():addChild(m_editBox)
--        ctr:getParent():removeChild(ctr,true)
--    end
--    m_editBox:setVisible(false)
    
    widget:addDataProxy("guildIcon",function(evt)
        return GameConst.GUILD_FLAG[ch.GuildModel:myGuildFlag()]
    end,nameFlagChangeEvent)
    widget:addDataProxy("guildName",function(evt)
        return ch.CommonFunc:getNameNoSever(ch.GuildModel:myGuildName())
    end,nameFlagChangeEvent)

    widget:addDataProxy("guildLevel",function(evt)
        local Button_lvup = zzy.CocosExtra.seekNodeByName(widget, "Button_lvup")
        if IS_BANHAO and Button_lvup then
            Button_lvup:setContentSize(150, 78)
            Button_lvup:setTitleFontName("aaui_font/ch.ttf")
        end
        
        return Language.LV..ch.GuildModel:myGuildLevel()
    end,guildLvChangeEvent)
    
    widget:addDataProxy("expProgress",function(evt)
        if ch.GuildModel:myGuildData().guildExp < GameConfig.Union_levelConfig:getData(ch.GuildModel:myGuildLevel()).exp then
            return ch.GuildModel:myGuildData().guildExp/GameConfig.Union_levelConfig:getData(ch.GuildModel:myGuildLevel()).exp
        elseif ch.GuildModel:myGuildData().guildExp <= 0 then
            return 0
        else
            return 1
        end
    end,guildExpChangeEvent)
    widget:addDataProxy("exp",function(evt)
        return ch.GuildModel:myGuildData().guildExp .."/".. GameConfig.Union_levelConfig:getData(ch.GuildModel:myGuildLevel()).exp
    end,guildExpChangeEvent)
    
    widget:addDataProxy("ifCanLook",function(evt)
        return false
    end,searchChangeEvent)
    widget:addDataProxy("isLeader",function(evt)
        return ch.GuildModel:myGuildData().position ~= 3
    end,searchChangeEvent)
    widget:addDataProxy("isLeaderAndFull",function(evt)
        return ch.GuildModel:myGuildData().position ~= 3
            and GameConfig.Union_levelConfig:getData(ch.GuildModel:myGuildLevel()).exp > 0
    end,guildExpChangeEvent)
    widget:addDataProxy("isFull",function(evt)
        return GameConfig.Union_levelConfig:getData(ch.GuildModel:myGuildLevel()).exp < 1
    end,guildExpChangeEvent)
    widget:addDataProxy("ifCanUp",function(evt)
--        return ch.GuildModel:myGuildData().guildExp >= GameConfig.Union_levelConfig:getData(ch.GuildModel:myGuildLevel()).exp
--            and GameConfig.Union_levelConfig:getData(ch.GuildModel:myGuildLevel()).exp > 0
        -- 非手动升级
        return false
    end,guildExpChangeEvent)
    
--    widget:addDataProxy("slogan",function(evt)
--        return ch.GuildModel:myGuildData().slogan
--    end,searchChangeEvent)
--    
--    widget:addDataProxy("noEditing",function(evt)
--        return not isEditing
--    end)
    
--    widget:addDataProxy("saveText",function(evt)
--        if isEditing then
--            return Language.GUILD_SAVE_BTN_TEXT[2]
--        else
--            return Language.GUILD_SAVE_BTN_TEXT[1]
--        end
--    end)
--    widget:addDataProxy("btnNormal",function(evt)
--        if isEditing then
--            return "aaui_button/btn_c_gboss1.png"
--        else
--            return "aaui_button/btn_c_free1.png"
--        end
--    end)
--    widget:addDataProxy("btnPressed",function(evt)
--        if isEditing then
--            return "aaui_button/btn_c_gboss2.png"
--        else
--            return "aaui_button/btn_c_free2.png"
--        end
--    end)
    widget:addDataProxy("list",function(evt)
        local tmpTable = {}
        table.insert(tmpTable,{index = 1,value = 1,isMultiple = true})
        table.insert(tmpTable,{index = 2,value = 1,isMultiple = true})
        table.insert(tmpTable,{index = 3,value = 1,isMultiple = true})
        if ch.GuildModel:myGuildLevel() >= GameConst.GUILD_WAR_OPEN_LEVEL then
            table.insert(tmpTable,{index = 4,value = 1,isMultiple = true})
        end 
        table.insert(tmpTable,{index = 5,value = 1,isMultiple = true})
        return tmpTable
    end,guildLvChangeEvent)
    
    widget:addCommond("help",function()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildinstruction")
    end)

    widget:addCommond("levelUp",function()
        ch.NetworkController:guildLevelUp(ch.GuildModel:myGuildID(),ch.GuildModel:myGuildLevel()+1)
        ch.GuildModel:myGuildLevelUP()
        local level = ch.GuildModel:myGuildLevel()
        local numOld = GameConst.GUILD_MEMBER_NUM
        if level > 1 then
            numOld = GameConfig.Union_levelConfig:getData(level-1).max
        end
        local numNew = GameConfig.Union_levelConfig:getData(level).max
        ch.UIManager:showTitleTips(1,true,Language.GUILD_TITLE1,string.format(Language.GUILD_MSGBOX_TIPS1,level-1,level,numOld,numNew),nil,nil)
        cclog("升级")
    end)

    widget:addCommond("lookdynamic",function()
        ch.NetworkController:guildReport()
--        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildmembernews",1)
        cclog("查看动态")
    end)
    widget:addCommond("openShop",function()
        ch.UIManager:showGamePopup("Guild/W_GuildShop",1)
    end)
    widget:addCommond("openDetail",function()
        ch.NetworkController:guildManage(ch.GuildModel:myGuildID())
--        ch.UIManager:showGamePopup("Guild/W_NewGuild_manage")
        ch.UIManager:showGamePopup("Guild/W_NewGuild_information_my")
    end)
    widget:addCommond("openJoin",function()
        ch.NetworkController:guildApplyPanel()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_apply")
    end)
    widget:addCommond("quitGuild",function()
--        ch.UIManager:showGamePopup("Guild/W_GuildQuitpop")
        if ch.GuildModel:myGuildData().position == 1 then
            ch.NetworkController:guildNextName()
        end
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildtips",1)
    end)

    -- 确认保存
    widget:addCommond("save",function()
        if m_editBox:isVisible() then
            name = m_editBox:getText()
--            if name == "" then
--                ch.UIManager:showMsgBox(1,true,Language.GUILD_SLOGAN_SAVE_ERROR)
--            else
                ch.NetworkController:guildSloganChange(ch.GuildModel:myGuildID(),name)
                ch.GuildModel:myGuildData().slogan = name
--            end
            cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
            m_editBox:setVisible(false)
            isEditing = false
            widget:noticeDataChange("noEditing")
            widget:noticeDataChange("slogan")
            widget:noticeDataChange("saveText")
            widget:noticeDataChange("btnNormal")
            widget:noticeDataChange("btnPressed")
        else
            m_editBox:setText("")
            m_editBox:setVisible(true)
            isEditing = true
            widget:noticeDataChange("noEditing")
            widget:noticeDataChange("saveText")
            widget:noticeDataChange("btnNormal")
            widget:noticeDataChange("btnPressed")
        end
    end)
end)

-- 公会活动签到
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_sign", function(widget,data)
    local signChangeEvent = {}
    signChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.GuildModel.dataType.sign
    end 
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.sign
    end 
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.MoneyModel.dataType.diamond
    end
    widget:addDataProxy("ifCanSign",function(evt)
        return ch.GuildModel:myGuildSignNum() <= GameConst.GUILD_SIGN_NUM and ch.GuildModel:myGuildSignNum() > 0
    end,signChangeEvent)
    widget:addDataProxy("ifCanBuy",function(evt)
        if ch.GuildModel:myGuildSignNum() <= GameConst.GUILD_SIGN_NUM and ch.GuildModel:myGuildSignNum() > 0 then
            return ch.MoneyModel:getDiamond() >= GameConst.GUILD_SIGN_COST[ch.GuildModel:myGuildSignNum()]
        else
            return false
        end
    end,moneyChangeEvent)
    
    widget:addDataProxy("costNum",function(evt)
        if ch.GuildModel:myGuildSignNum() <= GameConst.GUILD_SIGN_NUM and ch.GuildModel:myGuildSignNum() > 0 then
            return GameConst.GUILD_SIGN_COST[ch.GuildModel:myGuildSignNum()]
        else
            return 0
        end
    end,signChangeEvent)
    widget:addDataProxy("isFree",function(evt)
        return ch.GuildModel:myGuildSignNum() < 1
    end,signChangeEvent)
    widget:addDataProxy("signNum",function(evt)
        return ch.GuildModel:myGuildSignNum()
    end,signChangeEvent)
    
    widget:addCommond("sign",function()
        if ch.GuildModel:myGuildSignNum() < 1 then
            ch.NetworkController:guildSign(1)
        elseif ch.MoneyModel:getDiamond() >= GameConst.GUILD_SIGN_COST[ch.GuildModel:myGuildSignNum()] then
            local buy = function()
                ch.NetworkController:guildSign(0)
            end
            local tmp = {price = GameConst.GUILD_SIGN_COST[ch.GuildModel:myGuildSignNum()],buy = buy}
            ch.ShopModel:getCostTips(tmp)
        else
            ch.UIManager:showMsgBox(1,true,Language.MSG_UNENOUGH_PAYCOIN)
        end
    end)    
end)

-- 公会活动无尽征途
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_EL", function(widget,data)
    widget:addDataProxy("ifCanJoin",function(evt)
        return ch.WarpathModel:isOpen() 
            and ch.WarpathModel:getTimes() < 1 
            and ch.WarpathModel:isIdle()
    end)

    widget:addCommond("openEL",function()
        ch.UIManager:showGamePopup("Guild/W_El")
    end)
end)

-- 公会活动符文交换
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_my_cardexchange", function(widget,data)
    local signChangeEvent = {}
    signChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.demand
            or evt.dataType == ch.GuildModel.dataType.give
    end 
    widget:addDataProxy("countNum",function(evt)
        return ch.GuildModel:myGuildDemandNum()
    end,signChangeEvent)
    
    widget:addDataProxy("ifCanOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel() > GameConst.PETCARD_OPEN_LEVEL
    end)
    widget:addDataProxy("ifNoOpen",function(evt)
        return ch.StatisticsModel:getMaxLevel() <= GameConst.PETCARD_OPEN_LEVEL
    end)
    widget:addCommond("openDetail",function()
        ch.NetworkController:guildDemandPanel(ch.GuildModel:myGuildID())
        ch.UIManager:showGamePopup("Guild/W_NewGuild_cardexchange")
    end)
end)

-- 公会战入口
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildwar_entrance", function(widget,data)    
    local lastTime = os_clock()
    widget:listen(zzy.Events.TickEventType,function()
        local now = os_clock()
        if now - lastTime < 1 then return end
        lastTime = now 
            widget:noticeDataChange("applyTime")
            widget:noticeDataChange("joinTime")
            widget:noticeDataChange("getTime")
            widget:noticeDataChange("canApply")
            widget:noticeDataChange("isApply")
            widget:noticeDataChange("canNotApply")
            widget:noticeDataChange("canJoin")
            widget:noticeDataChange("canNotJoin")
            widget:noticeDataChange("canGet")
    end)
    
    widget:addDataProxy("applyTime",function(evt)
        local time = ch.GuildWarModel:getApplyInfo().endTime or 0
        local leftTime = time - os_time()
        return getTime(math.floor(leftTime))
    end)
    widget:addDataProxy("joinTime",function(evt)
        local time = ch.GuildWarModel:getFightInfo().endTime or 0
        local leftTime = time - os_time()
        return getTime(math.floor(leftTime))
    end)
    widget:addDataProxy("getTime",function(evt)
        local time = ch.GuildWarModel:getRewardInfo().endTime or 0
        local leftTime = time - os_time()
        return getTime(math.floor(leftTime))
    end)

    widget:addDataProxy("isApply",function(evt)
        return ch.GuildWarModel:getApplyInfo().startTime < os_time()
                and ch.GuildWarModel:getApplyInfo().endTime > os_time()
                and ch.GuildWarModel:getApplyInfo().state == 1
    end)
    widget:addDataProxy("canNotApply",function(evt)
        -- 会长或副会长才能报名
        return ch.GuildWarModel:getApplyInfo().startTime < os_time()
                and ch.GuildWarModel:getApplyInfo().endTime > os_time()
                and ch.GuildWarModel:getApplyInfo().state == 0
                and ch.GuildModel:myGuildData().position == 3
    end)
    
    widget:addDataProxy("canApply",function(evt)
        -- 会长或副会长才能报名
        return ch.GuildWarModel:getApplyInfo().startTime < os_time()
                and ch.GuildWarModel:getApplyInfo().endTime > os_time()
                and ch.GuildWarModel:getApplyInfo().state == 0
                and ch.GuildModel:myGuildData().position ~= 3
    end)
    widget:addDataProxy("canJoin",function(evt)
        return ch.GuildWarModel:getFightInfo().startTime < os_time()
                and ch.GuildWarModel:getFightInfo().endTime > os_time()
                and ch.GuildWarModel:getFightInfo().state == 1
    end)
    widget:addDataProxy("canNotJoin",function(evt)
        return ch.GuildWarModel:getFightInfo().startTime < os_time()
                and ch.GuildWarModel:getFightInfo().endTime > os_time()
                and ch.GuildWarModel:getFightInfo().state == 0
    end)
    widget:addDataProxy("canGet",function(evt)
        local state = ch.GuildWarModel:getRewardInfo().state
        if state == 2 then
            local txtButton = zzy.CocosExtra.seekNodeByName(widget, "Text_get")
            txtButton:setString(Language.GUILD_WAR_REWARD_STATE_TEXT[2]) --结算中
        else
            local txtButton = zzy.CocosExtra.seekNodeByName(widget, "Text_get")
            txtButton:setString(Language.GUILD_WAR_REWARD_STATE_TEXT[1]) --点击领取
        end
        return ch.GuildWarModel:getRewardInfo().state == 1
    end)
    widget:addCommond("apply",function()
        ch.UIManager:showMsgBox(2,true,Language.GUILD_WAR_APPLY_TIPS_TEXT,function()
            if ch.GuildWarModel:getApplyInfo().state == 0 then
                ch.GuildWarController:guildWarApply()
            end
        end,nil,Language.MSG_BUTTON_OK,2)    
    end)
    widget:addCommond("join",function()
        if ch.StatisticsModel:getMaxLevel() > GameConst.GUILD_WAR_PERSON_OPEN_LEVEL then
            ch.LevelController:startGuildWar()
        else
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_ChristmasView_8)
        end
    end)
    widget:addCommond("getReward",function()
        ch.GuildWarController:guildWarRewardPanel()  
    end)
    
    widget:addCommond("openHelp",function()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildwar_instruction")
    end)
    
    widget:addDataProxy("panel",function(evt)
        return true
    end)
end)

-- 公会活动附魔
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_my_fomo", function(widget,data)
    local dataChangeEvent = {}
    dataChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.GuildModel.dataType.enchantment
    end
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.MoneyModel.dataType.quintessence
    end
    widget:addDataProxy("levelNum",function(evt)
        return ch.GuildModel:getEnchantmentLevel()
    end,dataChangeEvent)
    widget:addDataProxy("costNum",function(evt)
        return ch.MoneyModel:getQuintessence()
    end,moneyChangeEvent)
    widget:addDataProxy("ratioNum",function(evt)
        return "+"..ch.NumberHelper:multiple((ch.GuildModel:getEnchantmentDPS()-1)*100,1000)
    end,dataChangeEvent)
    widget:addDataProxy("expNum",function(evt)
        local expNum = ch.NumberHelper:toString(ch.GuildModel:getEnchantmentExp())
        local needNum = ch.NumberHelper:toString(GameConst.GUILD_ENCHANTMENT_LEVEL_EXP(ch.GuildModel:getEnchantmentLevel()+1))
        return string.format("%s/%s",expNum,needNum)
    end,dataChangeEvent)
    widget:addDataProxy("expProgress",function(evt)
        return ch.GuildModel:getEnchantmentExp()/GameConst.GUILD_ENCHANTMENT_LEVEL_EXP(ch.GuildModel:getEnchantmentLevel()+1)
    end)
    widget:addDataProxy("ifCanUp",function(evt)
        return ch.MoneyModel:getQuintessence() > 0
    end,moneyChangeEvent)
    
    local time = 1
    local allRatio = 0
    local addNum = 0
    local num = 0
    local expImg = widget:getChild("Image_exp")
    local isMove = false
    local lastTime = os_clock()
    local startTime = os_clock()
    widget:listen(zzy.Events.TickEventType,function(evt)
        local now = os_clock()
        if isMove then
            local dt = now - lastTime
            if now - startTime < time then
                num = num + addNum * dt
                if num > 1 then
                    num = num-1
                end
                local numX = num>1 and 1 or num
                expImg:setScaleX(numX)
            else
                isMove = false
                widget:noticeDataChange("expProgress")
            end
        end
        lastTime = now
    end)
    
    widget:addCommond("enchantment",function()
        ch.NetworkController:guildEnchantment()
    
        local money = ch.MoneyModel:getQuintessence()
        local exp = ch.GuildModel:getEnchantmentExp()
        local level = ch.GuildModel:getEnchantmentLevel()
        local addLv = 0
        local ratioA = exp/GameConst.GUILD_ENCHANTMENT_LEVEL_EXP(level+1)
        exp = exp + money * GameConst.QUINTESSENCE_EXP_RATIO
        while exp >= GameConst.GUILD_ENCHANTMENT_LEVEL_EXP(level+1+addLv) and GameConst.GUILD_ENCHANTMENT_LEVEL_EXP(level+1+addLv) >0 do
            exp = exp - GameConst.GUILD_ENCHANTMENT_LEVEL_EXP(level+1+addLv)
            addLv = addLv + 1
        end
        ch.MoneyModel:setQuintessence(0)
        ch.GuildModel:setEnchantmentExp(exp)
        ch.GuildModel:addEnchantmentLevel(addLv)

        local ratioB = exp/GameConst.GUILD_ENCHANTMENT_LEVEL_EXP(level+1+addLv)
        allRatio = addLv - ratioA + ratioB
        num = ratioA
        addNum = allRatio/(time)
        isMove = true
        startTime = os_clock()
        
    end)
end)

-- 未加入过公会的界面
zzy.BindManager:addFixedBind("Guild/W_NewGuild_cover", function(widget)

    widget:addDataProxy("img",function(evt)
        return "res/img/guild_cover.png"
    end)

    widget:addDataProxy("ifOpenGuild",function(evt)
        return ch.StatisticsModel:getMaxLevel() > GameConst.GUILD_OPEN_LEVEL
    end)
    
    widget:addCommond("openJoin",function()
        ch.NetworkController:refreshGuild()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_join")
    end)

    widget:addCommond("openCreate",function()
        ch.UIManager:showGamePopup("Guild/W_GuildBuilding")
    end)
    
end)

-- 成员管理界面
zzy.BindManager:addFixedBind("Guild/W_NewGuild_manage", function(widget)
    local manageChangeEvent = {}
    manageChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.GuildModel.dataType.manage
    end
    
    widget:addDataProxy("memberNum",function(evt)
        if ch.GuildModel:getManageData().num then
            return ch.GuildModel:getManageData().num .."/".. GameConfig.Union_levelConfig:getData(ch.GuildModel:getManageData().lv).max
        else
            return ""
        end
    end,manageChangeEvent)

    widget:addDataProxy("list",function(evt)
        return ch.GuildModel:getManageMemberList()
    end,manageChangeEvent)
end)

-- 成员管理单元
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_manage_1", function(widget,data)
    widget:addDataProxy("imgFrame",function(evt)
        if data.position == 1 then
            return "aaui_diban/db_guild_member_4.png"
        else
            return "aaui_diban/db_guild_member_5.png"
        end
    end)
    widget:addDataProxy("titleIcon",function(evt)
        return ch.UserTitleModel:getTitle(data.maxLevel-1,data.userID).icon
    end)
    widget:addDataProxy("title",function(evt)
        return Language.GUILD_POSITION_NAME[data.position]
    end)
    widget:addDataProxy("name",function(evt)
        return data.name
    end)
    widget:addDataProxy("lvName",function(evt)
        return GameConfig.Unmem_levelConfig:getData(data.personLv).name
    end)
    widget:addDataProxy("lvNum",function(evt)
        return data.maxLevel
    end)
    widget:addDataProxy("exp",function(evt)
        return data.personExp
    end)
    widget:addDataProxy("isLeader",function(evt)
        return data.position ~= 3
    end)
    
    widget:addCommond("openDetail",function()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_memberdetail",{type = 1,value = data})
    end)
end)

-- 查看会员界面 
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_memberdetail", function(widget,data)
    local tmpData = data.value
    
    --弹劾测试
    --tmpData.impeach = 1--可以弹劾
    --tmpData.impeach = 2--已经弹劾
    --tmpData.impeachNum = 2
    --tmpData.impeachCDTime = os_time() + 500
    
    widget:addDataProxy("p_path",function(evt)
        return GameConfig.PartnerConfig:getData(tostring(tmpData.pet)).icon
    end)

    widget:addDataProxy("title",function(evt)
        return Language.GUILD_POSITION_NAME[tmpData.position]
    end)
    widget:addDataProxy("isLeader",function(evt)
        return tmpData.userID ~= ch.PlayerModel:getPlayerID() 
            and (ch.GuildModel:myGuildData().position == 1 
                or (ch.GuildModel:myGuildData().position == 2 
                and tmpData.position == 3))
    end)
    widget:addDataProxy("name",function(evt)
        return tmpData.name
    end)
    -- 称号图标
    widget:addDataProxy("titleIcon",function(evt)
        return ch.UserTitleModel:getTitle(tmpData.maxLevel-1,tmpData.userID).icon
    end)
    widget:addDataProxy("titleName",function(evt)
        return ch.UserTitleModel:getTitle(tmpData.maxLevel-1,tmpData.userID).name
    end)

    widget:addDataProxy("guild",function(evt)
        if tmpData.guild == nil or tmpData.guild == "" then
            return tmpData.guild
        else
            return "[".. ch.CommonFunc:getNameNoSever(tmpData.guild) .."]"
        end
    end)

    widget:addDataProxy("lvName",function(evt)
        return GameConfig.Unmem_levelConfig:getData(tmpData.personLv).name
    end)

    widget:addDataProxy("exp",function(evt)
        return tmpData.personExp
    end)

    widget:addDataProxy("maxLevel",function(evt)
        return tmpData.maxLevel
    end)

    widget:addDataProxy("ltime",function(evt)
        if tmpData.ltime > 0 then
            return os.date("%Y-%m-%d %H:%M:%S",tonumber(tmpData.ltime))
        else
            return Language.src_clickhero_view_GuildView_9
        end
    end)

    widget:addDataProxy("petList",function(evt)
        if table.maxn(tmpData.petList) > 6 then
            table.remove(tmpData.petList,1)
            return tmpData.petList
        else
            return tmpData.petList
        end
    end)

    widget:addDataProxy("direction",function(evt)
        return ccui.ListViewDirection.horizontalSnap
    end)
    
    widget:addDataProxy("ifCanImpeach",function(evt)
        local Panel_impeach = tmpData.impeach ~= 0 and tmpData.position == 1
        DEBUG("Panel_impeach="..tostring(Panel_impeach))
        return Panel_impeach
    end)
    widget:addDataProxy("noCanImpeach",function(evt)
        local Panel_leader = tmpData.impeach == 0 or tmpData.position ~= 1
        DEBUG("Panel_leader="..tostring(Panel_leader))
        return Panel_leader
    end)
    widget:addDataProxy("noImpeach",function(evt)
        local Button_impeach = tmpData.impeach == 1
        DEBUG("Button_impeach="..tostring(Button_impeach))
        return Button_impeach
    end)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("impeachText")
        widget:setTimeOut(1,cutDown)
    end
    cutDown() 
    
    widget:addDataProxy("impeachText",function(evt)
        if tmpData.impeach == 2 then
            local leftTime = tmpData.impeachCDTime - os_time()
            if leftTime > 0 then 
                return string.format(Language.GUILD_IMPEACH_DESC[2],getTime(math.floor(leftTime)),GameConst.GUILD_IMPEACH_NUM,tmpData.impeachNum,GameConst.GUILD_IMPEACH_NUM)
            end
        else
            return Language.GUILD_IMPEACH_DESC[1]
        end
        return ""
    end)

    widget:addDataProxy("isAtevent",function(evt)
        return ch.GuildModel:myGuildData().position == 1 and tmpData.userID ~= ch.PlayerModel:getPlayerID() 
    end)

    widget:addDataProxy("btn_appoint_txt",function(evt)
        if tmpData.position == 2 then
            return Language.GUILD_TITLE3
        else
            return Language.GUILD_TITLE2
        end
    end)
    
    widget:addDataProxy("btnNormal",function(evt)
        if tmpData.position == 2 then
            return "aaui_button/btn_c_gboss1.png"
        else
            return "aaui_button/btn_c_freeb1.png"
        end
    end)
    widget:addDataProxy("btnPressed",function(evt)
        if tmpData.position == 2 then
            return "aaui_button/btn_c_gboss2.png"
        else
            return "aaui_button/btn_c_freeb2.png"
        end
    end)
    
    widget:addCommond("appoint",function()
        if tmpData.position == 3 then
            ch.UIManager:showTitleTips(2,true,Language.GUILD_TITLE2,string.format(Language.GUILD_MSGBOX_TIPS2,tmpData.name),function()
                ch.NetworkController:guildAppoint(ch.GuildModel:myGuildID(),tmpData.userID,1)
                widget:destory()
                cclog("任命副会长")
            end,nil)
        elseif tmpData.position == 2 then
            ch.UIManager:showTitleTips(2,true,Language.GUILD_TITLE3,string.format(Language.GUILD_MSGBOX_TIPS3,tmpData.name),function()
                ch.NetworkController:guildAppoint(ch.GuildModel:myGuildID(),tmpData.userID,2)
                widget:destory()
                cclog("免除副会长")
            end,nil)
        end        
    end)
    
    widget:addCommond("transAdmin",function()
        ch.UIManager:showTitleTips(2,true,Language.GUILD_TITLE5,string.format(Language.GUILD_MSGBOX_TIPS5,tmpData.name),function()
            ch.NetworkController:guildTransAdmin(tmpData.userID)
            widget:destory()
            cclog("转让会长")
        end,nil)     
    end)
    
    widget:addCommond("remove",function()
        ch.UIManager:showTitleTips(2,true,Language.GUILD_TITLE4,string.format(Language.GUILD_MSGBOX_TIPS4,tmpData.name,GameConfig.Unmem_levelConfig:getData(tmpData.personLv).name),function()
            ch.NetworkController:kickGuild(ch.GuildModel:myGuildID(),tmpData.userID)
            widget:destory()
            cclog("移除公会")
        end,nil)
    end)
    
    widget:addCommond("impeach",function()
        ch.NetworkController:guildImpeach(ch.GuildModel:myGuildID(),tmpData.userID)
    end)
    
    local roleName,weapon = ch.UserTitleModel:getAvatarByLevel(tmpData.maxLevel - 1,tmpData.gender)

    local playerPanel = widget:getChild("icon_player")

    ch.CommonFunc:showRoleAvatar(playerPanel,roleName,weapon)

    widget:addCommond("close",function()
        widget:destory()
        if roleName ~= ch.UserTitleModel:getAvatar() then
            ch.RoleResManager:release(roleName)
        end
    end)
end)

-- 查看公会详情(自己家的)
zzy.BindManager:addFixedBind("Guild/W_NewGuild_information_my", function(widget)
    local manageChangeEvent = {}
    manageChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.manage
    end
    local searchChangeEvent = {}
    searchChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.panel
    end
    local nameFlagChangeEvent = {}
    nameFlagChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.name
            or evt.dataType == ch.GuildModel.dataType.flag
    end
    local guildExpChangeEvent = {}
    guildExpChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.guildExp
            or evt.dataType == ch.GuildModel.dataType.panel
            or evt.dataType == ch.GuildModel.dataType.level
    end
    local guildLvChangeEvent = {}
    guildLvChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.GuildModel.dataType.level
            or evt.dataType == ch.GuildModel.dataType.panel
    end

    local m_editBox
    local name = ""
    local isEditing = false
    -- 修改
    local ctr = widget:getChild("TextField_change")
    local ctrName = ctr:getDescription()
    if ctrName == "TextField" then
        local m_editBoxSize = ctr:getContentSize()
        m_editBox = ccui.EditBox:create(m_editBoxSize, ccui.Scale9Sprite:create())
        m_editBox:setPosition(cc.p(ctr:getPositionX(), ctr:getPositionY()))
        m_editBox:setFontSize(ctr:getFontSize())
        m_editBox:setFontColor(cc.c3b(145,138,138))
        m_editBox:setAnchorPoint(ctr:getAnchorPoint())
        m_editBox:setPlaceHolder(ctr:getPlaceHolder())
        m_editBox:setMaxLength(GameConst.CHAT_MAX_CHAR_COUNT)
        m_editBox:setText("")
        ctr:getParent():addChild(m_editBox)
        ctr:getParent():removeChild(ctr,true)
    end
    m_editBox:setVisible(false)
    
    widget:addDataProxy("memberNum",function(evt)
        if ch.GuildModel:getManageData().num then
            return ch.GuildModel:getManageData().num .."/".. GameConfig.Union_levelConfig:getData(ch.GuildModel:getManageData().lv).max
        else
            return ""
        end
    end,manageChangeEvent)

    widget:addDataProxy("list",function(evt)
        return ch.GuildModel:getManageMemberList()
    end,manageChangeEvent)
    
    widget:addDataProxy("expProgress",function(evt)
        if ch.GuildModel:myGuildData().guildExp < GameConfig.Union_levelConfig:getData(ch.GuildModel:myGuildLevel()).exp then
            return ch.GuildModel:myGuildData().guildExp/GameConfig.Union_levelConfig:getData(ch.GuildModel:myGuildLevel()).exp
        elseif ch.GuildModel:myGuildData().guildExp <= 0 then
            return 0
        else
            return 1
        end
    end,guildExpChangeEvent)
    widget:addDataProxy("exp",function(evt)
        return ch.GuildModel:myGuildData().guildExp .."/".. GameConfig.Union_levelConfig:getData(ch.GuildModel:myGuildLevel()).exp
    end,guildExpChangeEvent)

    widget:addDataProxy("isLeader",function(evt)
        return ch.GuildModel:myGuildData().position ~= 3
    end,searchChangeEvent)
    widget:addDataProxy("isAtevent",function(evt)
        return ch.GuildModel:myGuildData().position == 1
    end,searchChangeEvent)
    
    widget:addDataProxy("slogan",function(evt)
        return ch.GuildModel:myGuildData().slogan
    end,searchChangeEvent)
    
    widget:addDataProxy("isEditing",function(evt)
        return isEditing
    end)
    widget:addDataProxy("noEditing",function(evt)
        return not isEditing
    end)
    
    widget:addDataProxy("guildIcon",function(evt)
        return GameConst.GUILD_FLAG[ch.GuildModel:myGuildFlag()]
    end,nameFlagChangeEvent)
    widget:addDataProxy("guildName",function(evt)
        return ch.CommonFunc:getNameNoSever(ch.GuildModel:myGuildName())
    end,nameFlagChangeEvent)

    widget:addDataProxy("guildLevel",function(evt)
        local Button_lv = zzy.CocosExtra.seekNodeByName(widget, "Button_lv")
        if IS_BANHAO and Button_lv then
            Button_lv:setContentSize(150, 78)
            Button_lv:setTitleFontName("aaui_font/ch.ttf")
        end
        
        return Language.LV..ch.GuildModel:myGuildLevel()
    end)
    widget:addDataProxy("ifCanUp",function(evt)
        return false
    end)

    widget:addCommond("openChange",function()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_change")
    end)
    widget:addCommond("callWorld",function()
        local id = ch.GuildModel:myGuildID()
        local say = ch.GuildModel:myGuildName()..Language.src_clickhero_view_GuildView_11
        local tmpStr = ""
        if ch.GuildModel:getCallNum() < GameConst.CHAT_GUILD_JOIN_FREE_COUNT then
            tmpStr = string.format(Language.src_clickhero_view_GuildView_17,GameConst.CHAT_GUILD_JOIN_FREE_COUNT-ch.GuildModel:getCallNum())
        else
            tmpStr = string.format(Language.src_clickhero_view_GuildView_18,GameConst.CHAT_GUILD_JOIN_COST)
        end
        ch.UIManager:showMsgBox(2,true,tmpStr,function()
            ch.NetworkController:guildCallWorld(id,say)
        end,nil,Language.src_clickhero_view_GuildView_14,2)
    end)
    widget:addCommond("openJoin",function()
        ch.NetworkController:guildApplyPanel()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_apply")
    end)
    widget:addCommond("quitGuild",function()
--        ch.UIManager:showGamePopup("Guild/W_GuildQuitpop")
        if ch.GuildModel:myGuildData().position == 1 then
            ch.NetworkController:guildNextName()
        end
        ch.UIManager:showGamePopup("Guild/W_NewGuild_guildtips",1)
    end)
    -- 编辑
    widget:addCommond("edit",function()
        m_editBox:setText(ch.GuildModel:myGuildData().slogan)
        m_editBox:setVisible(true)
        isEditing = true
        widget:noticeDataChange("isEditing")
        widget:noticeDataChange("noEditing")
    end)
    -- 确认保存
    widget:addCommond("save",function()
        name = m_editBox:getText()
        ch.NetworkController:guildSloganChange(ch.GuildModel:myGuildID(),name)
--        ch.GuildModel:myGuildData().slogan = name
        cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
        m_editBox:setVisible(false)
        isEditing = false
        widget:noticeDataChange("isEditing")
        widget:noticeDataChange("noEditing")
        widget:noticeDataChange("slogan")
    end)
    -- 取消保存
    widget:addCommond("cancel",function()
        cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
        m_editBox:setVisible(false)
        isEditing = false
        widget:noticeDataChange("isEditing")
        widget:noticeDataChange("noEditing")
    end)
end)

-- 查看公会详情成员单元(自己家的)
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_information_my_1", function(widget,data)
    widget:addDataProxy("imgFrame",function(evt)
        if data.position == 1 then
            return GameConst.GUILD_FRAME_ICON[1]
        elseif data.position == 2 then
            return GameConst.GUILD_FRAME_ICON[2]
        else
            return GameConst.GUILD_FRAME_ICON[3]
        end
    end)
    widget:addDataProxy("name",function(evt)
        return data.name
    end) 
    widget:addDataProxy("maxLevel",function(evt)
        return data.maxLevel
    end)
    widget:addDataProxy("lvName",function(evt)
        local str = GameConfig.Unmem_levelConfig:getData(data.personLv).name
        str = str .. "("..Language.src_clickhero_view_GuildView_20 .. data.personExp ..")"
        return  str
    end)
    widget:addDataProxy("exp",function(evt)
        return data.todayExp
    end)
    widget:addDataProxy("isLeader",function(evt)
        return data.position ~= 3
    end)
    widget:addCommond("openDetail",function()
        ch.UIManager:showGamePopup("Guild/W_NewGuild_memberdetail",{type = 1,value = data})
    end)
end)


-- 查看公会详情(别人家的)
zzy.BindManager:addFixedBind("Guild/W_NewGuild_information", function(widget)
    widget:addDataProxy("guildIcon",function(evt)
        return GameConst.GUILD_FLAG[ch.GuildModel:getDetailFlag()]
    end)
    widget:addDataProxy("guildName",function(evt)
        return ch.CommonFunc:getNameNoSever(ch.GuildModel:getDetailName())
    end)

    widget:addDataProxy("guildLevel",function(evt)
        local Button_lv = zzy.CocosExtra.seekNodeByName(widget, "Button_lv")
        if IS_BANHAO and Button_lv then
            Button_lv:setContentSize(150, 78)
            Button_lv:setTitleFontName("aaui_font/ch.ttf")
        end
        
        return Language.LV..ch.GuildModel:getDetailLevel()
    end)
    widget:addDataProxy("ifCanUp",function(evt)
        return false
    end)
    widget:addDataProxy("slogan",function(evt)
        return ch.GuildModel:getDetailData().slogan or ""
    end)
    
    widget:addDataProxy("memberNum",function(evt)
        return ch.GuildModel:getDetailNum().."/"..GameConfig.Union_levelConfig:getData(ch.GuildModel:getDetailLevel()).max
    end)
    widget:addDataProxy("ifCanJoin",function(evt)
        return ch.GuildModel:getDetailData().apply ~= 1 
            and ch.GuildModel:myGuildApplyTimeNum() < GameConst.GUILD_APPLY_NUM
    end)
    -- 排行榜中打开不显示
    widget:addDataProxy("joinVis",function(evt)
        return ch.GuildModel:getDetailData().type ~= 1
    end)
    widget:addCommond("join",function()
        ch.NetworkController:guildApply(ch.GuildModel:getDetailData().id)
        widget:destory()
    end)
    widget:addDataProxy("list",function(evt)
        return ch.GuildModel:getDetailMemberList()
    end)
end)

-- 查看公会详情成员单元(别人家的)
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_information_1", function(widget,data)
    widget:addDataProxy("imgFrame",function(evt)
        if data.position == 1 then
            return GameConst.GUILD_FRAME_ICON[1]
        elseif data.position == 2 then
            return GameConst.GUILD_FRAME_ICON[2]
        else
            return GameConst.GUILD_FRAME_ICON[3]
        end
    end)
    widget:addDataProxy("titleIcon",function(evt)
        return ch.UserTitleModel:getTitle(data.maxLevel-1,data.userID).icon
    end)
    widget:addDataProxy("title",function(evt)
        return Language.GUILD_POSITION_NAME[data.position]
    end)
    widget:addDataProxy("name",function(evt)
        return data.name
    end) 
    widget:addDataProxy("maxLevel",function(evt)
        return data.maxLevel
    end)
end)

-- 公会加入申请界面
zzy.BindManager:addFixedBind("Guild/W_NewGuild_apply", function(widget)
    local applyPanelChangeEvent = {}
    applyPanelChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.GuildModel.dataType.applyPanel
    end
    
    local isSelect = (ch.GuildModel:getApplyPanelData().maxLevel or 0) > 0
    local m_editBox
    widget:addDataProxy("level",function(evt)
        if m_editBox then
            m_editBox:setText(ch.GuildModel:getApplyPanelData().maxLevel or 0)
            isSelect = (ch.GuildModel:getApplyPanelData().maxLevel or 0) > 0
            widget:noticeDataChange("isSelect1")
        end
        return ch.GuildModel:getApplyPanelData().maxLevel or 0
    end,applyPanelChangeEvent)

    local function editboxEventHandler(eventType)
        if eventType == "began" then
            isSelect = false
            widget:noticeDataChange("isSelect1")
        elseif eventType == "ended" then
        elseif eventType == "changed" then
        elseif eventType == "return" then
        end
    end

    -- 修改
    local ctr = widget:getChild("TextField_search")
    local ctrName = ctr:getDescription()
    if ctrName == "TextField" then
        local m_editBoxSize = ctr:getContentSize()
        m_editBox = ccui.EditBox:create(m_editBoxSize, ccui.Scale9Sprite:create())
        m_editBox:registerScriptEditBoxHandler(editboxEventHandler)
        m_editBox:setPosition(cc.p(ctr:getPositionX(), ctr:getPositionY()))
        m_editBox:setFontSize(ctr:getFontSize())
        m_editBox:setAnchorPoint(ctr:getAnchorPoint())
        m_editBox:setPlaceHolder(ctr:getPlaceHolder())
        m_editBox:setMaxLength(ctr:getMaxLength())
        m_editBox:setText(ch.GuildModel:getApplyPanelData().maxLevel or 0)
        ctr:getParent():addChild(m_editBox)
        ctr:getParent():removeChild(ctr,true)
    end

    
    widget:addDataProxy("isSelect1",function(evt)
        return isSelect
    end,applyPanelChangeEvent)
    widget:addDataProxy("isSelect2",function(evt)
        return ch.GuildModel:getApplyPanelData().auto == 1
    end,applyPanelChangeEvent)
    widget:addCommond("select",function(widget,arg)
        if arg == "-1" then
            ch.NetworkController:guildApplyLevel(0)
            ch.GuildModel:getApplyPanelData().maxLevel = 0
            isSelect = false
            widget:noticeDataChange("isSelect1")
        elseif arg == "1" then
            level = m_editBox:getText()
            if tonumber(level) and tonumber(level) > 0 then
                if tonumber(level) < 4000 then
                    ch.NetworkController:guildApplyLevel(tonumber(level))
                    ch.GuildModel:getApplyPanelData().maxLevel = tonumber(level)
                else
                    ch.NetworkController:guildApplyLevel(4000)
                    ch.GuildModel:getApplyPanelData().maxLevel = 4000
                end
            else
                ch.NetworkController:guildApplyLevel(0)
                ch.GuildModel:getApplyPanelData().maxLevel = 0
            end
            isSelect = true
            widget:noticeDataChange("isSelect1")
        elseif arg == "-2" then
            ch.NetworkController:guildApplyAuto(0)
        elseif arg == "2" then
            ch.NetworkController:guildApplyAuto(1)
        end
    end)
    widget:addDataProxy("list",function(evt)
        return ch.GuildModel:getApplyPanelMemberList()
    end,applyPanelChangeEvent)
end)

-- 公会加入申请单元
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_apply_1", function(widget,data)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("refuseTime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown()
    
    widget:addDataProxy("refuseTime",function(evt)
        if data.cdTime then
            local leftTime = data.cdTime - os_time()
            if leftTime > 0 then 
                return getTime(math.floor(leftTime))..Language.GUILD_APPLY_CD_DESC 
            end
        end
        return getTime(-1)..Language.GUILD_APPLY_CD_DESC
    end)
    
    widget:addDataProxy("titleIcon",function(evt)
        return ch.UserTitleModel:getTitle(data.maxLevel-1,data.userID).icon
    end)
    
    widget:addDataProxy("name",function(evt)
        return data.name
    end)   

    widget:addDataProxy("maxLevel",function(evt)
        return data.maxLevel
    end)
    widget:addDataProxy("isCanLook",function(evt)
        return true
    end)
    widget:addDataProxy("isCanOk",function(evt)
        return true
    end)
    widget:addDataProxy("isCanRefuse",function(evt)
        return true
    end)
    widget:addCommond("look",function()
        ch.NetworkController:rankListPlayer(data.userID)
    end)
    widget:addCommond("ok",function()
        ch.NetworkController:guildDispose(ch.GuildModel:myGuildID(),data.userID,1)
        cclog("同意")
    end)
    widget:addCommond("refuse",function()
        ch.NetworkController:guildDispose(ch.GuildModel:myGuildID(),data.userID,2)
        cclog("拒绝")
    end)
end)

-- 公会等级特权(暂未开放)
zzy.BindManager:addFixedBind("Guild/W_NewGuild_guildlevel", function(widget)
    widget:addDataProxy("list",function(evt)
        return {1,2,3}
    end)
    
end)


-- 公会等级特权单元(暂未开放)
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildlevel_1", function(widget,data)
    widget:addDataProxy("memberNum",function(evt)
        return 10 + data
    end)
    widget:addDataProxy("openDesc",function(evt)
        return ""
    end)
    widget:addDataProxy("dpsRatio",function(evt)
        return string.format("+%d%%",data*5)
    end)
    widget:addDataProxy("lvNum",function(evt)
        return data
    end)
end)


-- 公会脱离提醒
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildtips", function(widget,data)
    local nextNameChangeEvent = {}
    nextNameChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.GuildModel.dataType.nextName
    end
    widget:addDataProxy("tips1",function(evt)
        return string.format(Language.GUILD_QUIT_TIPS1,ch.GuildModel:myGuildData().personLv)
    end)
    widget:addDataProxy("tips2",function(evt)
        if ch.GuildModel:myGuildData().position == 1 then
            if ch.GuildModel:myGuildNextName() then
                return string.format(Language.GUILD_QUIT_TIPS2[1],ch.GuildModel:myGuildNextName())
            else
                return Language.GUILD_QUIT_TIPS2[2]
            end
        else
            return ""
        end
    end,nextNameChangeEvent)
    widget:addCommond("close",function()
        widget:destory()
    end)
    widget:addCommond("ok",function()
        ch.NetworkController:quitGuild(ch.GuildModel:myGuildID())
        widget:destory()
        ch.UIManager:cleanGamePopupLayer(true)
    end)
end)

-- 公会成员动态,卡牌赠予记录
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_guildmembernews", function(widget,data)
    local dataChangeEvent = {}
    dataChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.GuildModel.dataType.report
    	   or evt.dataType == ch.GuildModel.dataType.cardLog
    end
    widget:addDataProxy("title",function(evt)
        return Language.GUILD_REPORT_TITLE[data]
    end)
    widget:addDataProxy("news",function(evt)
        local str = ""
        if data == 1 then
            for k,v in pairs(ch.GuildModel:getReportList()) do
                local tmpStr = Language.GUILD_DYNAMIC_DESC[v.type]
                local name = v.name or ""
                local time = os.date("%Y-%m-%d %H:%M:%S",tonumber(v.tm))
                if v.type == 6 then
                    tmpStr = string.format(tmpStr,v.level)
                elseif v.type == 7 then
                    tmpStr = string.format(tmpStr,v.level)
                end
                str = str .. "\n  ".. time .."  ".. name .."  ".. tmpStr .."\n"
            end
        else
            for k,v in pairs(ch.GuildModel:getCardLogList()) do
                local tmpStr = Language.GUILD_CARD_LOG_DESC
                local cardName = GameConfig.CardConfig:getData(v.cardID).name
                tmpStr = string.format(tmpStr,v.name1,v.name2,cardName,v.num)
                str = str .. "\n"..tmpStr .."\n"
            end
        end
        return str
    end)
end)

-- 公会索要卡牌活动
zzy.BindManager:addFixedBind("Guild/W_NewGuild_cardexchange", function(widget)
    local dataChangeEvent = {}
    dataChangeEvent[ch.GuildModel.dataChangeEventType] = function(evt)
    	return evt.dataType == ch.GuildModel.dataType.demandPanel
    end
    widget:addDataProxy("cardList",function(evt)
        return ch.GuildModel:getDemandPanelList()
    end,dataChangeEvent)
    widget:addDataProxy("cardIcon",function(evt)
        local cardID = ch.GuildModel:getDemandPanelData().cardID or 50001
        return GameConfig.CardConfig:getData(cardID).mini
    end,dataChangeEvent)
    widget:addDataProxy("talentImg",function(evt)
        local cardID = ch.GuildModel:getDemandPanelData().cardID or 50001
        return GameConst.CARD_TALENT_IMAGE[GameConfig.CardConfig:getData(cardID).talent]
    end,dataChangeEvent)
    widget:addDataProxy("iconFrame",function(evt)
        local cardID = ch.GuildModel:getDemandPanelData().cardID or 50001
        return GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(cardID)).iconFrame
    end,dataChangeEvent)
    widget:addDataProxy("isDemand",function(evt)
        if ch.GuildModel:getDemandPanelData().cardID then
            local cdTime = ch.GuildModel:getDemandPanelData().cdTime or 0
            return cdTime > os_time()
        else
            return false
        end
    end,dataChangeEvent)
    widget:addDataProxy("ifCanGet",function(evt)
        local getNum = ch.GuildModel:getDemandPanelData().getNum or 0
        return getNum > 0
    end,dataChangeEvent)
    widget:addDataProxy("ifCanDemand",function(evt)
        local cdTime = ch.GuildModel:getDemandPanelData().cdTime or 0
        return cdTime < os_time()
    end,dataChangeEvent)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("demandCDTime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown() 

    widget:addDataProxy("demandCDTime",function(evt)
        if ch.GuildModel:getDemandPanelData().cdTime then
            local leftTime = ch.GuildModel:getDemandPanelData().cdTime - os_time()
            if leftTime > 0 then 
                return string.format(Language.GUILD_DEMAND_CD_DESC,getTime(math.floor(leftTime)))
            end
        end
        return ""
    end,dataChangeEvent)
    widget:addDataProxy("getNum",function(evt)
        local getNum = ch.GuildModel:getDemandPanelData().getNum or 0
        return string.format(Language.GUILD_DEMAND_GET_NUM_DESC,getNum,GameConst.GUILD_CARD_GET_NUM_MAX)
    end,dataChangeEvent)
    widget:addCommond("look",function()
        ch.NetworkController:guildCardLog()
    end)
    widget:addCommond("getReward",function()
        ch.NetworkController:guildGetCard(ch.GuildModel:myGuildID())
    end)
    widget:addCommond("demand",function()
        ch.UIManager:showGamePopup("card/W_card_guild_give")
    end)    
end)

-- 公会索要卡牌活动单元
zzy.BindManager:addCustomDataBind("Guild/W_NewGuild_cardexchange_1", function(widget,data)
    widget:addDataProxy("cardIcon",function(evt)
        return GameConfig.CardConfig:getData(data.cardID).mini
    end)
    widget:addDataProxy("talentImg",function(evt)
        return GameConst.CARD_TALENT_IMAGE[GameConfig.CardConfig:getData(data.cardID).talent]
    end)
    widget:addDataProxy("titleIcon",function(evt)
        if data.position == 1 then
            return GameConst.GUILD_FRAME_ICON[1]
        elseif data.position == 2 then
            return GameConst.GUILD_FRAME_ICON[2]
        else
            return GameConst.GUILD_FRAME_ICON[3]
        end
    end)
    widget:addDataProxy("name",function(evt)
        return data.name
    end)
    widget:addDataProxy("lvName",function(evt)
        return GameConfig.Unmem_levelConfig:getData(data.personLv).name
    end)
    widget:addDataProxy("getNum",function(evt)
        return string.format(Language.GUILD_GIVE_NUM_DESC,data.giveNum,GameConst.GUILD_CARD_GIVE_COUNT)
    end)
    widget:addDataProxy("ifCanGive",function(evt)
        return (data.giveState == 1) and (data.giveNum < GameConst.GUILD_CARD_GIVE_COUNT)
    end)
    
    local cutDown
    cutDown =  function()
        widget:noticeDataChange("giveCDTime")
        widget:setTimeOut(1,cutDown)
    end
    cutDown() 
    
    widget:addDataProxy("giveCDTime",function(evt)
    if data.cdTime then
            local leftTime = data.cdTime - os_time()
            if leftTime > 0 then 
                return string.format(Language.GUILD_GIVE_CDTIME_DESC,getTime(math.floor(leftTime)))
            end
        end
        return ""
    end)
    widget:addCommond("give",function()
        if ch.PetCardModel:getLevel(data.cardID) < 1 then
            local name = GameConfig.CardConfig:getData(data.cardID).name
            ch.UIManager:showMsgBox(1,true,string.format(Language.GUILD_DEMAND_ERROR_1,name,name),nil)
        else
            if ch.PetCardModel:getChipNum(data.cardID) >= GameConst.GUILD_CARD_GIVE_NUM_TALENT[GameConfig.CardConfig:getData(data.cardID).talent] then
                local Button_give = zzy.CocosExtra.seekNodeByName(widget, "Button_give")
                Button_give:setTouchEnabled(false)
                Button_give:setBright(false)
                ch.NetworkController:guildGiveCard(ch.GuildModel:myGuildID(),data.cardID,data.userId)
            else
                local name = GameConfig.CardConfig:getData(data.cardID).name
                ch.UIManager:showMsgBox(1,true,string.format(Language.GUILD_DEMAND_ERROR,name),nil)   
            end
        end
    end)   
end)

-- 公会索要卡牌活动选择列表
zzy.BindManager:addFixedBind("card/W_card_guild_give",function(widget)
    widget:addDataProxy("title",function(evt)
        return Language.GUILD_DEMAND_CARD_TITLE
    end)
    
    widget:addDataProxy("cardList",function(evt)
        local items = {}
        if ch.CardFBModel:getFBList() then
            for k,v in pairs(ch.PetCardModel:getAllPetCardID()) do
                if ch.PetCardModel:getLevel(v) > 0 then
                    table.insert(items,{index=k,id=v})
                end
            end
        end
        return items
    end)
end)

-- 卡牌单元
zzy.BindManager:addCustomDataBind("card/W_card_guild_bg", function(widget,data)
    local petCardChangeEvent = {}
    petCardChangeEvent[ch.PetCardModel.dataChangeEventType] = function(evt)
        return evt.id == data.id
    end

    local fightingChangeEvent = {}
    fightingChangeEvent[ch.ArenaModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.ArenaModel.dataType.myCardList
    end

    local config = GameConfig.CardConfig:getData(data.id)

    widget:addDataProxy("isFighting",function(evt)
        return ch.ArenaModel:isInGroup(data.id)
    end,fightingChangeEvent)

    widget:addDataProxy("isCard",function(evt)
        return ch.PetCardModel:getLevel(data.id) > 0
    end,petCardChangeEvent)

    widget:addDataProxy("isChip",function(evt)
        return ch.PetCardModel:getLevel(data.id) < 1
    end,petCardChangeEvent)

    widget:addDataProxy("isChipDB",function(evt)
        if ch.PetCardModel:getLevel(data.id) < 1 then
            return "aaui_card/card_bg_no.png"
        else
            return "aaui_card/card_bg_have.png"
        end
    end,petCardChangeEvent)            

    widget:addDataProxy("cardName",function(evt)
        if ch.PetCardModel:getStar(data.id) < 1 then
            return config.name
        else
            return config.name.."+"..ch.PetCardModel:getStar(data.id)
        end
    end,petCardChangeEvent)

    widget:addDataProxy("cardNameColor",function(evt)
        if ch.PetCardModel:getLevel(data.id) < 1 then
            return cc.c3b(230,230,230)
        else
            return GameConst.PETCARD_COLOR[GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).color]
        end
    end,petCardChangeEvent)

    widget:addDataProxy("cardIcon",function(evt)
        return config.mini
    end)

    widget:addDataProxy("iconFrame",function(evt)
        return GameConfig.CarduplevelConfig:getData(ch.PetCardModel:getQuality(data.id)).iconFrame
    end,petCardChangeEvent)

    widget:addDataProxy("jobIcon",function(evt)
        return GameConst.PETCARD_JOB[config.job].icon
    end)

    widget:addDataProxy("chipNum",function(evt)
        return ch.PetCardModel:getChipNum(data.id).."/"..ch.PetCardModel:getChipCost(data.id)
    end,petCardChangeEvent)

    widget:addDataProxy("chipProgress",function(evt) 
        if not ch.PetCardModel:getChipCost(data.id) or ch.PetCardModel:getChipCost(data.id) < 1 or ch.PetCardModel:getChipNum(data.id) > ch.PetCardModel:getChipCost(data.id) then
            return 1
        else
            return ch.PetCardModel:getChipNum(data.id)/ch.PetCardModel:getChipCost(data.id)
        end
    end,petCardChangeEvent)

    widget:addDataProxy("talentImg",function(evt)
        return GameConst.CARD_TALENT_IMAGE[ch.PetCardModel:getTalent(data.id)]
    end,petCardChangeEvent)
    -- csb部分
    widget:addDataProxy("data",function(evt)
        local ret = {}
        local quality = ch.PetCardModel:getQuality(data.id)
        -- 星星变化
        local maxStar = GameConfig.CarduplevelConfig:getData(quality).max_star
        ret.star1 = maxStar == 4
        ret.star2 = maxStar == 3
        ret.star3 = maxStar == 4 or maxStar == 2
        ret.star4 = maxStar == 3 or maxStar == 1
        ret.star5 = maxStar == 4 or maxStar == 2
        ret.star6 = maxStar == 3
        ret.star7 = maxStar == 4

        local star = ch.PetCardModel:getStar(data.id)
        ret.starImg1 = (maxStar == 4 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg2 = (maxStar == 3 and star >= 1) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg3 = ((maxStar == 4 and star >= 2) or (maxStar == 2 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg4 = ((maxStar == 3 and star >= 2) or (maxStar == 1 and star >= 1)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg5 = ((maxStar == 4 and star >= 3) or (maxStar == 2 and star >= 2)) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg6 = (maxStar == 3 and star >= 3) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"
        ret.starImg7 = (maxStar == 4 and star >= 4) and "aaui_card/card_q_star.png" or "aaui_card/card_q_s1.png"

        return ret
    end,petCardChangeEvent)
    
    widget:addCommond("select",function()
        ch.NetworkController:guildDemandCard(ch.GuildModel:myGuildID(),data.id)
    end)
    
end)
