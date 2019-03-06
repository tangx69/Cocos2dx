-- 分享界面
local shareViewLabel = Language.src_clickhero_view_ShareView_1
local shareDialogLabel = Language.src_clickhero_view_ShareView_2
local shareGroup = {Language.src_clickhero_view_ShareView_3, Language.src_clickhero_view_ShareView_4}
local shareJson = "{\"f\":\"share\", \"data\":{\"t\":\"%s\", \"text\":\"%s\", \"image\":\"%s\", \"link\":\"%s\",\"extra\":\"%s\"}}"
local shareToday = Language.src_clickhero_view_ShareView_5
local shareImgWX = "res/icon/share_wx.jpg"
local shareImgWB = "res/icon/share_wb.jpg"
if zzy.Sdk.getFlag()=="HDIOS" and  zzy.config.subpack==2 then
	shareImgWX= "res/icon/share1_wb.jpg"
	shareImgWB= "res/icon/share1_wb.jpg"
end

zzy.BindManager:addFixedBind("share/W_Share",function(widget)
    local shareChangeEvent = {}
    local shareAward = GameConfig.Share_awardConfig:getTable()
    shareChangeEvent[ch.ShareModel.dataChangeEventType] = false
    shareChangeEvent[ch.AchievementModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.AchievementModel.dataType.state
    end
    
    widget:addDataProxy("shareTitle",function(evt)
        return shareViewLabel
    end)
    
    widget:addDataProxy("shareAwardImg1",function(evt)
        return shareAward[1].icon
    end)
    
    widget:addDataProxy("shareAwardImg2",function(evt)
        return shareAward[2].icon
    end)
    
    widget:addDataProxy("shareAwardImg3",function(evt)
        return shareAward[3].icon
    end)
    
    widget:addDataProxy("shareAwardImg4",function(evt)
        return shareAward[4].icon
    end)
    
    widget:addDataProxy("shareAwardImg5",function(evt)
        return shareAward[5].icon
    end)
    
    widget:addDataProxy("shareList",function(evt)
        local ret = {}
        -- 今日 type为0
        local todayData = ch.ShareModel:getTodayShare()
        if todayData ~= nil and todayData[1] ~= 1 or todayData[2] ~= 1 then
            if ch.FestivityModel:getWeek() == 1 then
                if ch.FestivityModel:getDay() <= 3 then
                    ch.ShareModel:setTodayShareState(true)
                    table.insert(ret,{index = 1, value = {type = "0"}, isMultiple = true})
                elseif ch.FestivityModel:getDay() == 7 then
                    ch.ShareModel:setTodayShareState(true)
                    table.insert(ret,{index = 1, value = {type = "0"}, isMultiple = true})
                else
                end
            else
                local checkShareState = (ch.ShopModel:getSvrDays() - 7) % 4
                if checkShareState == 0 then
                    ch.ShareModel:setTodayShareState(true)
                    table.insert(ret,{index = 1, value = {type = "0"}, isMultiple = true})
                end
            end
        end
        -- 成就 type为1完成，为2未完成
        for key, var in pairs(GameConfig.Share_cfgConfig:getTable()) do
            local _key = tostring(key)
            local achiData = ch.ShareModel:getAchievementShare()
            -- 欧美版
            if zzy.Sdk.getFlag() == "CYAND" or zzy.Sdk.getFlag() == "CYIOS" then
                -- 有成就数据并且Facebook分享未分享
                if achiData ~= nil and achiData[_key][1] ~= 1 then
                    if ch.AchievementModel:getStateById(_key) then
                        table.insert(ret,{index = 1, value = {type = "1", share = var}, isMultiple = true})
                    else
                        table.insert(ret,{index = 2, value = {type = "2", share = var}, isMultiple = true})
                    end
                end
            else
                -- 有成就数据并且微信、微博分享未分享
                if achiData ~= nil and achiData[_key][1] ~= 1 or achiData[_key][2] ~= 1 then
                    if ch.AchievementModel:getStateById(_key) then
                        table.insert(ret,{index = 1, value = {type = "1", share = var}, isMultiple = true})
                    else
                        table.insert(ret,{index = 2, value = {type = "2", share = var}, isMultiple = true})
                    end
                end
            end
            
        end
        
        return ret
    end, shareChangeEvent)
    
    widget:addCommond("close",function()
        widget:destory()
    end)
end)

zzy.BindManager:addCustomDataBind("share/W_ShareAchievement",function(widget,data)
    local shareChangeEvent = {}
    shareChangeEvent[ch.ShareModel.dataChangeEventType] = false
    shareChangeEvent[ch.AchievementModel.dataChangeEventType] = function(evt)
        return evt.dataType == ch.AchievementModel.dataType.state
    end

    local isCYou = zzy.Sdk.getFlag() == "CYAND" or zzy.Sdk.getFlag() == "CYIOS"
    widget:addDataProxy("shareAchTitle", function(evt)
        --今日分享
        if data.type == "0" then
            return shareGroup[1]
        else
            return shareGroup[2]
        end
    end)
    
    widget:addDataProxy("shareAchIcon", function(evt)
        --今日分享
        if data.type == "0" then
            return "res/icon/icon_today_ach.png"
        else
            return ch.AchievementModel:getIconById(tostring(data.share.id))
        end
    end)

    widget:addDataProxy("isWXVisible", function(evt)
        if isCYou then
            return false
        else
            return true
        end
    end)

    widget:addDataProxy("isWBVisible", function(evt)
        if isCYou then
            return false
        else
            return true
        end
    end)

    widget:addDataProxy("isFBVisible", function(evt)
        if isCYou then
            return true
        else
            return false
        end
    end)
    
    widget:addDataProxy("canShareToWX", function(evt)
        -- 今日分享
        if data.type == "0" then
            if ch.ShareModel:getTodayShareState() == true then
                local todayData = ch.ShareModel:getTodayShare()
                if todayData[1] == 0 then
                    return true
                else
                    return false
                end
            else
                return false
            end
        else
        -- 成就分享已达成
            if data.type == "1" then
                local achiData = ch.ShareModel:getAchievementShare()
                -- 成就微信分享判断
                if achiData[tostring(data.share.id)][1] == 0 then
                    return true
                else
                    return false
                end
            end
        end
    end,shareChangeEvent)
    
    widget:addDataProxy("canShareToWB", function(evt)
        -- 今日分享
        if data.type == "0" then
            if ch.ShareModel:getTodayShareState() == true then
                local todayData = ch.ShareModel:getTodayShare()
                if todayData[2] == 0 then
                    return true
                else
                    return false
                end
            else
                return false
            end
        else
        -- 成就分享已达成
            if data.type == "1" then
                local achiData = ch.ShareModel:getAchievementShare()
                -- 成就微博分享判断
                if achiData[tostring(data.share.id)][2] == 0 then
                    return true
                else
                    return false
                end
            end
        end
    end,shareChangeEvent)

    widget:addDataProxy("canShareToFB", function(evt)
        if isCYou then
            if data.type == "0" then
                if ch.ShareModel:getTodayShareState() == true then
                    local todayData = ch.ShareModel:getTodayShare()
                    if todayData[1] == 0 then
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            else
            -- 成就分享已达成
                if data.type == "1" then
                    local achiData = ch.ShareModel:getAchievementShare()
                    -- 成就微博分享判断
                    if achiData[tostring(data.share.id)][1] == 0 then
                        return true
                    else
                        return false
                    end
                end
            end
        else
            return false
        end
    end,shareChangeEvent)   
    
    widget:addCommond("shareToWX", function()
        local shareData=""
        -- 微信今日分享
        if data.type == "0" then
            ch.ShareModel:setCurShareData({f="today", type=0})
            shareData = string.format(shareJson,"WX", shareToday, shareImgWX, "", "")
        else
        -- 微信成就分享
            ch.ShareModel:setCurShareData({f="achi", type=0, id=tostring(data.share.id)})
            shareData = string.format(shareJson,"WX", zzy.StringUtils:FilterSpecialChar(data.share.desc), shareImgWX, "", "")
        end
        
        ch.NetworkController:sendFixedTimeData()
        ch.UIManager:showGamePopup("share/W_ShareFix", shareData)
    end)
    
    widget:addCommond("shareToWB",function()
        -- 微博今日分享
        local shareData=""
        if data.type == "0" then
            ch.ShareModel:setCurShareData({f="today", type=1})
            shareData = string.format(shareJson,"SINAWB", shareToday, shareImgWB, "", "")
        else
        -- 微博成就分享
            ch.ShareModel:setCurShareData({f="achi", type=1, id=tostring(data.share.id)})
            shareData = string.format(shareJson,"SINAWB", zzy.StringUtils:FilterSpecialChar(data.share.desc), shareImgWB, "", "")
        end
        
        ch.NetworkController:sendFixedTimeData()
        ch.UIManager:showGamePopup("share/W_ShareFix", shareData)
    end)

    widget:addCommond("shareToFB",function()
        local shareData = "Tapstorm Trials - Idle RPG"
        local shareImgFB = "http://hwdmw.changyou.com/cyou/images/FB_Share.jpg"
        local shareTextFB = "Come play Tapstorm Trials with me! Two tappers are better than one!"
        local shareURLFB = "https://play.google.com/store/apps/details?id=com.cyou.tapstormtrials"
        if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE or 
            cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD then
            shareURLFB = "https://itunes.apple.com/app/id1095939047"
        end
        -- Facebook今日分享
        if data.type == "0" then
            ch.ShareModel:setCurShareData({f="today", type=2})
            shareData = string.format(shareJson,"FB", shareTextFB, shareImgFB, shareURLFB, shareData)
        else
        -- Facebook成就分享
            ch.ShareModel:setCurShareData({f="achi", type=2, id=tostring(data.share.id)})
            shareData = string.format(shareJson,"FB", zzy.StringUtils:FilterSpecialChar(data.share.desc), shareImgFB, shareURLFB, shareData)
        end

        ch.NetworkController:sendFixedTimeData()
        ch.UIManager:showGamePopup("share/W_ShareFix", shareData)
    end)
end)

zzy.BindManager:addCustomDataBind("share/W_Shareday",function(widget,data)
    widget:addDataProxy("shareNonAchIcon", function(evt)
        return ch.AchievementModel:getIconById(tostring(data.share.id))
    end)
    
    widget:addDataProxy("shareNonAchTitle", function(evt)
        return ch.AchievementModel:getDesById(tostring(data.share.id))..Language.src_clickhero_view_ShareView_6
    end)
end)

zzy.BindManager:addCustomDataBind("share/W_ShareFix",function(widget,data)
    widget:addDataProxy("shareConfirmText", function(evt)
        return shareDialogLabel
    end)
    
    widget:addCommond("startShare",function()
        ch.ShareModel:setShareJsonStr(data)
        if zzy.Sdk.getFlag() == "CYAND" or zzy.Sdk.getFlag() == "CYIOS" then
            if zzy.config.loginData.fbid == nil then
                local info={
                    f="fbbind",
                    data={uin=ch.PlayerModel.channeluser}
                }
                zzy.Sdk.extendFunc(json.encode(info))
                zzy.config.fbbindByShare = true
            else
                zzy.Sdk.extendFunc(data)
            end
        else
            zzy.Sdk.extendFunc(data)
        end
        
        widget:destory()
    end)
end)
