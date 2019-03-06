local selectGender = 0
-- 固有绑定
-- 设置界面  W_SettingList
zzy.BindManager:addFixedBind("setting/W_SettingList", function(widget)
    local settingChangeEvent = {}
    settingChangeEvent[ch.SettingModel.dataChangeEventType] = false
    local nameChangeEvent = {}
	local settingfbChangeEvent = {}
    settingfbChangeEvent[ch.SettingModel.fbdataChangeEventType] = false
	
	local levelChangeEvent = {}
    levelChangeEvent[ch.LevelModel.dataChangeEventType] =  function(evt)
        return evt.dataType == ch.LevelModel.dataType.curLevel 
    end
	
    nameChangeEvent[ch.PlayerModel.dataChangeEventType] = false
     --帮助
    widget:addDataProxy("helpVis",function(evt)
		if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" then
			return true
		end
		return false
    end)
	--切换fb账户
    widget:addDataProxy("switchfbVis",function(evt)
		return false
    end)
	 --帮助
    widget:addCommond("btn_help",function()
         local paid_user=0
		 if ch.ShopModel:getTotalCharge()>0 then
			paid_user=1
		 end
		 local extendInfo={
			f="helpshift",
			data={
				paid_user=paid_user,--是否是付费用户 （0 1）
				facebook_user="",--facebook id
				tzs=ch.ShopModel:getTotalCharge(),--充值钻石数
				first_session_date=ch.StatisticsModel._data.playTime,--首次启动游戏时间
				maxlevel=ch.StatisticsModel:getMaxLevel(),
				uin=zzy.config.loginData.userid,
				svrid_short=tonumber(string.match(ch.PlayerModel:getZoneID(), "([%d]?[%d]?[%d]?)$")),
				svrid=ch.PlayerModel:getZoneID(),
				roleid=ch.PlayerModel:getPlayerID(),
				rolename=ch.PlayerModel:getPlayerName(),
				svrname=zzy.config.svrname
			}
		}
		zzy.Sdk.extendFunc(json.encode(extendInfo))
        cclog(json.encode(extendInfo))
    end)
    --绑定fb账号
    widget:addDataProxy("bindfbVis",function(evt)
        if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" and zzy.config.loginData.fbid==nil then
			return true
		else
			return false
	    end
    end,settingfbChangeEvent)
    --解绑fb账号
    widget:addDataProxy("unbindfbVis",function(evt)
        if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" and zzy.config.loginData.fbid then
			return true
		else
			return false
	    end
    end,settingfbChangeEvent)
    
    -- 切换fb账户
    widget:addCommond("btn_switchfb",function()
          --local info={
             --f="fbswitch"
         --}
         --zzy.Sdk.extendFunc(json.encode(info))
         --cclog(json.encode(info))
    end)
    
    -- 绑定fb账号
    widget:addCommond("btn_bindfb",function()
        local info={
            f="fbbind",
            data={uin=ch.PlayerModel.channeluser }
        }
        zzy.Sdk.extendFunc(json.encode(info))
        cclog(json.encode(info))
		
		
    end)
    
    -- 解绑fb账号
    widget:addCommond("btn_unbindfb",function()
		 ch.UIManager:showMsgBox(2,true,Language.src_clickhero_view_SettingView_12,function()
                 local info={
				f="fbunbind",
				data={
					uin=ch.PlayerModel.channeluser,
					fbid=zzy.config.loginData.fbid
				}
			}
			zzy.Sdk.extendFunc(json.encode(info))
			cclog(json.encode(info))
         end,nil,Language.src_clickhero_view_SettingView_13)
        
    end)
    
    -- 标题 title
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_SettingView_1
    end)
    -- 玩家昵称
    widget:addDataProxy("myName",function(evt)
        return ch.PlayerModel:getPlayerName()
    end,nameChangeEvent)
    -- 音乐播放状态
    widget:addDataProxy("musicPlay",function(evt)
        return not ch.SettingModel:isNoMusicPlaying()
    end,settingChangeEvent)
    -- 音效播放状态
    widget:addDataProxy("soundPlay",function(evt)
        return not ch.SettingModel:isNoSoundPlaying()
    end,settingChangeEvent)
    -- 播放/停止音乐
    widget:addCommond("playMusic",function()
        ch.SettingModel:setMusicState(ch.SettingModel:isNoMusicPlaying())
    end)
    -- 播放/停止音效
    widget:addCommond("playSound",function()
        ch.SettingModel:setSoundState(not ch.SettingModel:isNoSoundPlaying())
    end)
    -- 清除数据
    widget:addCommond("clearme",function()
        ch.ModelManager:clearData()
        __G__ONRESTART__()
    end)
    widget:addDataProxy("bossTimeRemind",function(evt)
        return ch.SettingModel:isBossTimeRemind()
    end)
    widget:addCommond("openBossTimeRemind",function()
        ch.SettingModel:setBossTimeRemind(true)
    end)
    widget:addCommond("closeBossTimeRemind",function()
        ch.SettingModel:setBossTimeRemind(false)
    end)
    
    widget:addDataProxy("noticeRemind",function(evt)
        return ch.SettingModel:isNoticeRemind()
    end)
    widget:addCommond("openNoticeRemind",function()
        ch.SettingModel:setNoticeRemind(true)
    end)
    widget:addCommond("closeNoticeRemind",function()
        ch.SettingModel:setNoticeRemind(false)
    end)
    -- 是否可切换帐号，临时的
    widget:addDataProxy("ifCanChange",function(evt)
        return true
    end)
    widget:addCommond("changeID",function()
        --cclog("切换帐号")
        ch.ModelManager:clearUserID()
        __G__ONRESTART__()
    end)
    widget:addDataProxy("playID",function(evt)
        return ch.PlayerModel:getPlayerUnid()
    end)
    widget:addCommond("exchangeGift",function()
        ch.UIManager:showGamePopup("setting/W_SettingSN")
    end)
    widget:addDataProxy("isOpenGift",function()
	    if IS_IN_REVIEW then
            return false
        end
        
        return true
    end)
    
    local playerPanel = widget:getChild("icon_player")

    local roleName = ch.UserTitleModel:getAvatar()

    ch.CommonFunc:showRoleAvatar(playerPanel,roleName,ch.UserTitleModel:getWeapon())

    widget:listen(ch.PlayerModel.dataChangeEventType,function(obj,evt)
        if evt.dataType == ch.PlayerModel.dataType.gender then
            if roleName ~= ch.UserTitleModel:getAvatar() then
                ch.RoleResManager:release(roleName)
            end
            playerPanel:removeAllChildren()
            roleName = ch.UserTitleModel:getAvatar()
            ch.CommonFunc:showRoleAvatar(playerPanel,roleName,ch.UserTitleModel:getWeapon())
        end
    end)

    widget:addCommond("close",function()
        widget:destory()
        if roleName ~= ch.UserTitleModel:getAvatar() then
            ch.RoleResManager:release(roleName)
        end
    end)
end)

-- 修改昵称界面(废弃)
zzy.BindManager:addFixedBind("setting/W_SettingCName", function(widget)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.diamond
        return ret
    end
    local name = ch.PlayerModel:getPlayerName()
    name = ch.CommonFunc:getNameNoSever(name)
    -- 原昵称
    widget:addDataProxy("curName",function(evt)
        return name
    end)
    -- 是否需要花费
    widget:addDataProxy("ifFree",function(evt)
        return ch.PlayerModel:getChangeNum() >= GameConst.CHANGE_NAME_FREE
    end)
    -- 修改昵称价格
    widget:addDataProxy("price",function(evt)
        return GameConst.CHANGE_NAME_PRICE
    end)
    -- 确认修改
    widget:addCommond("changeName",function()
        cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
        if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
            if zzy.StringUtils:containEmojiCharacter(name) then
                ch.UIManager:showMsgBox(1,true,GameConst.CNAME_ERROR[4])
            else
                ch.NetworkController:changeName(name)
                widget:destory()
            end
        else
            ch.NetworkController:changeName(name)
            widget:destory()
        end
    end)
    widget:addDataProxy("ifCanBuy",function(evt)
        if ch.PlayerModel:getChangeNum() < GameConst.CHANGE_NAME_FREE then
            return true
        else
            return ch.MoneyModel:getDiamond() >= GameConst.CHANGE_NAME_PRICE
        end
    end,moneyChangeEvent)
    -- 改名
    widget:addCommond("inputName",function(obj,str)
        name = str
    end)
end)

-- 修改昵称和性别界面
zzy.BindManager:addFixedBind("setting/W_SettingCName_1", function(widget)
    local moneyChangeEvent = {}
    moneyChangeEvent[ch.MoneyModel.dataChangeEventType] = function(evt)
        local ret = evt.dataType == ch.MoneyModel.dataType.diamond
        return ret
    end
    local m_editBox
    name = ch.CommonFunc:getNameNoSever(ch.PlayerModel:getPlayerName())
    DEBUG("name="..name)
    local gender = ch.PlayerModel:getPlayerGender() or 1
    -- 原昵称
    widget:addDataProxy("curName",function(evt)
        return name
    end)
    widget:addDataProxy("isBoy",function(evt)
        return gender ~= 1
    end)
    widget:addDataProxy("isGirl",function(evt)
        return gender ~= 2
    end)
    widget:addDataProxy("isBoySelect",function(evt)
        return gender == 1
    end)
    widget:addDataProxy("isGirlSelect",function(evt)
        return gender == 2
    end)
    -- 是否需要花费
    widget:addDataProxy("notFirst",function(evt)
        return ch.PlayerModel:getPlayerGender() and ch.PlayerModel:getPlayerGender() ~= 0
    end)
    -- 第一次改名改性别
    widget:addDataProxy("ifFirst",function(evt)
        return not ch.PlayerModel:getPlayerGender() or ch.PlayerModel:getPlayerGender() == 0
    end)
    -- 修改昵称价格
    widget:addDataProxy("price",function(evt)
        return GameConst.CHANGE_NAME_PRICE
    end)
    -- 选性别
    widget:addCommond("select",function(widget,arg)
        gender = tonumber(arg)
        widget:noticeDataChange("isBoy")
        widget:noticeDataChange("isGirl")
        widget:noticeDataChange("isBoySelect")
        widget:noticeDataChange("isGirlSelect")
    end)

    -- 确认修改
    widget:addCommond("changeName",function()
        name = m_editBox:getText()
        if gender ~= 1 and gender ~= 2 then
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_SettingView_2,nil)
        elseif name == Language.INIT_PLAYER_NAME then
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_SettingView_3,nil)
        else
            local buy = function()
                if name == ch.PlayerModel:getPlayerName() then
                    if gender == ch.PlayerModel:getPlayerGender() then
                        ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_SettingView_4,nil)
                    else
                        ch.NetworkController:changeName(nil,gender)
                    end
                else
                    if gender == ch.PlayerModel:getPlayerGender() then
                        ch.NetworkController:changeName(name,nil)
                    else
                        ch.NetworkController:changeName(name,gender)
                    end
                end
                cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
            end
            if ch.PlayerModel:getPlayerGender() and ch.PlayerModel:getPlayerGender() ~= 0 then
                local tmp = {price = GameConst.CHANGE_NAME_PRICE,buy = buy}
                ch.ShopModel:getCostTips(tmp)
            else
                buy()
            end
--            widget:destory()
        end
    end)
    widget:addDataProxy("ifCanBuy",function(evt)
        if not ch.PlayerModel:getPlayerGender() or ch.PlayerModel:getPlayerGender() == 0 then
            return true
        else
            return ch.MoneyModel:getDiamond() >= GameConst.CHANGE_NAME_PRICE
        end
    end,moneyChangeEvent)
    -- 改名
    -- widget:addCommond("inputName",function(obj,str)
    --     name = str
    -- end)
    local ctr = widget:getChild("textField_id")
    local ctrName = ctr:getDescription()
    if ctrName == "TextField" then
        local m_editBoxSize = ctr:getContentSize()
        m_editBox = ccui.EditBox:create(m_editBoxSize, ccui.Scale9Sprite:create())
        --m_editBox = ccui.EditBox:create(m_editBoxSize,"aaui_diban/db_gaiming.png",ccui.TextureResType.plistType)
        m_editBox:setPosition(cc.p(ctr:getPositionX(), ctr:getPositionY()))
        m_editBox:setFontSize(ctr:getFontSize())
        m_editBox:setInputMode(6)
        m_editBox:setAnchorPoint(ctr:getAnchorPoint())
        m_editBox:setPlaceHolder(ctr:getPlaceHolder())
        m_editBox:setMaxLength(ctr:getMaxLength())
        local nsName = ch.CommonFunc:getNameNoSever(ch.PlayerModel:getPlayerName())
        DEBUG("m_editBox:"..nsName)
        m_editBox:setText(nsName)
        ctr:getParent():addChild(m_editBox)
        ctr:getParent():removeChild(ctr,true)
    end
end)

-- 礼包码界面
zzy.BindManager:addFixedBind("setting/W_SettingSN", function(widget)
    local giftCode = nil
--    widget:addCommond("giftCode",function(obj,str)
--        giftCode = str
--    end)
    local ctr = widget:getChild("textField_id")
    local ctrName = ctr:getDescription()
    local m_editBox = nil
    if ctrName == "TextField" then
        local m_editBoxSize = ctr:getContentSize()
        m_editBox = ccui.EditBox:create(m_editBoxSize, ccui.Scale9Sprite:create())
        m_editBox:setPosition(cc.p(ctr:getPositionX(), ctr:getPositionY()))
        m_editBox:setFontSize(ctr:getFontSize())
        m_editBox:setAnchorPoint(ctr:getAnchorPoint())
        m_editBox:setPlaceHolder(ctr:getPlaceHolder())
        m_editBox:setInputMode(6)
        m_editBox:setMaxLength(18)
        ctr:getParent():addChild(m_editBox)
        ctr:getParent():removeChild(ctr,true)
    end

    widget:addCommond("ok",function()
        giftCode = m_editBox:getText()
        if giftCode == nil or giftCode == "" then
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_SettingView_5)
        else
            ch.NetworkController:getGift(giftCode)
            widget:destory()
        end
        cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
    end)
end)

zzy.BindManager:addCustomDataBind("setting/W_SNbonus",function(widget,data)
    widget:addDataProxy("title",function(evt)
        return data.title or Language.src_clickhero_view_SettingView_6
    end)
    
    widget:addDataProxy("desc",function(evt)
        return data.desc or Language.src_clickhero_view_SettingView_7
    end)

    widget:addDataProxy("items",function(evt)
        return data.list or data
    end)
    
    widget:addCommond("ok",function()
        widget:destory()
    end)
end)

zzy.BindManager:addCustomDataBind("setting/W_SNunit",function(widget,data)
    local type = tonumber(data.t)
--    local index =""
--    if type == 1 then
--        index = "db"..data.id
--    elseif type == 2 then
--        index = "cw"..data.id
--    elseif type == 3 then
--        index = "bf"..data.id
--    elseif type == 5 then 
--    end
    widget:addDataProxy("icon",function(evt)
        return ch.CommonFunc:getRewardIcon(type,data.id)
--        return GameConst.MSG_FJ_ICON[type][index]
    end)
    widget:addDataProxy("num",function(evt)
        return ch.CommonFunc:getRewardName(type,data.id).."  "..ch.CommonFunc:getRewardValue(type,data.id,data.num)
--        if type == 1 and tonumber(data.id) == ch.MoneyModel.dataType.gold then
--            return ch.NumberHelper:toString(tonumber(data.num))
--        elseif type == 3 then
--            return ch.NumberHelper:dateTimeToString(data.num)
--        else
--            return data.num
--        end
    end)
end)

-- 获得新称号
zzy.BindManager:addFixedBind("MainScreen/W_title_getnew", function(widget)
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_SettingView_8
    end)
    widget:addDataProxy("desc",function(evt)
        return string.format(Language.src_clickhero_view_SettingView_9,ch.UserTitleModel:getTitleByLevel(ch.StatisticsModel:getMaxLevel()-1).completeLv)
    end)
    widget:addDataProxy("titleIcon",function(evt)
        return ch.UserTitleModel:getTitleByLevel(ch.StatisticsModel:getMaxLevel()-1).icon_b
    end)
    widget:addDataProxy("titleName",function(evt)
        return ch.UserTitleModel:getTitleByLevel(ch.StatisticsModel:getMaxLevel()-1).name
    end)
    widget:addDataProxy("playerImg",function(evt)
        return ch.UserTitleModel:getTitleByLevel(ch.StatisticsModel:getMaxLevel()-1).avatarIcon
    end)
    
    local playerPanel = widget:getChild("Image_player")
    
    local roleName = ch.UserTitleModel:getAvatar()

    ch.CommonFunc:showRoleAvatar(playerPanel,roleName,ch.UserTitleModel:getWeapon())
    
    
    widget:addCommond("ok",function()
        widget:destory()
        if roleName ~= ch.UserTitleModel:getAvatar() then
            ch.RoleResManager:release(roleName)
        end
    end)
end)


-- 称号预览
zzy.BindManager:addFixedBind("MainScreen/W_title_preview", function(widget)
    widget:addDataProxy("title",function(evt)
        return Language.src_clickhero_view_SettingView_10
    end)
    widget:addDataProxy("desc",function(evt)
        ch.UserTitleModel:setShowEffect(false)
        return string.format(Language.src_clickhero_view_SettingView_11,ch.UserTitleModel:getNewTitleByLevel(ch.StatisticsModel:getMaxLevel()-1).completeLv)
    end)
    widget:addDataProxy("titleIconOld",function(evt)
        return ch.UserTitleModel:getTitleByLevel(ch.StatisticsModel:getMaxLevel()-1).icon_b
    end)
    widget:addDataProxy("titleNameOld",function(evt)
        return ch.UserTitleModel:getTitleByLevel(ch.StatisticsModel:getMaxLevel()-1).name
    end)
    widget:addDataProxy("playerImgOld",function(evt)
        return ch.UserTitleModel:getTitleByLevel(ch.StatisticsModel:getMaxLevel()-1).avatarIcon
    end)
    widget:addDataProxy("titleIconNew",function(evt)
        return ch.UserTitleModel:getNewTitleByLevel(ch.StatisticsModel:getMaxLevel()-1).icon_b
    end)
    widget:addDataProxy("titleNameNew",function(evt)
        return ch.UserTitleModel:getNewTitleByLevel(ch.StatisticsModel:getMaxLevel()-1).name
    end)
    widget:addDataProxy("playerImgNew",function(evt)
        return ch.UserTitleModel:getNewTitleByLevel(ch.StatisticsModel:getMaxLevel()-1).avatarIcon
    end)
    
    local curTitleId = ch.UserTitleModel:getTitleId()
    local lastConfig = GameConfig.UserTitleConfig:getData(curTitleId + 1)
    local r,w = ch.UserTitleModel:getAvatarByLevel(lastConfig.completeLv,ch.PlayerModel:getPlayerGender())
    local roleNames = {ch.UserTitleModel:getAvatar(),r}
    local playerPanel1 = widget:getChild("Image_player")
    local playerPanel2 = widget:getChild("Image_player_new")
    
    ch.CommonFunc:showRoleAvatar(playerPanel1,roleNames[1],ch.UserTitleModel:getWeapon())
    
    ch.CommonFunc:showRoleAvatar(playerPanel2,roleNames[2],w)
    
    widget:addCommond("close",function()
        widget:destory()
        for _,name in ipairs(roleNames) do
            if name ~= ch.UserTitleModel:getAvatar() then
                ch.RoleResManager:release(name)
            end
        end
    end)
end)
-- 绑定fb界面
zzy.BindManager:addFixedBind("setting/W_facebook_in", function(widget)
    widget:addCommond("btn_fb_bind",function()
		ch.UIManager:cleanGamePopupLayer(true)
        ch.UIManager:showGamePopup("setting/W_SettingList")	
    end)
end)
