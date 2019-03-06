md5 = {}

require "src.cocos.init"
require "src.adapter.code"

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    print("is android")
    luaj = require "src.cocos.cocos2d.luaj"
elseif (cc.PLATFORM_OS_IPAD == targetPlatform or cc.PLATFORM_OS_IPHONE == targetPlatform) then
    print("is ios")
    luaoc = require "src.cocos.cocos2d.luaoc"
end

USE_SPINE = true --是否使用spine骨骼动画

require "src.adapter.preProc"
require "src.zzy.zzy"
require "src.adapter.adapter"

require "res.config.GameConfig"
require "res.language.Language"
require "src.clickhero.ch"

function log2Screen(...)
    if not PALYER_UNID or tostring(PALYER_UNID) ~= "1000047" then
        return
    end

    logLabels = logLabels or {}
    totalHeight = totalHeight or 0
    logIndex = logIndex or 1

    if logIndex >= 15 then
        for k,label in pairs(logLabels) do
            label:removeFromParent()
        end

        logLabels = {}
        logIndex = 1
        totalHeight = 0
    end

    if cc.Director:getInstance():getRunningScene() == nil then
        return
        --cc.Director:getInstance():runWithScene(cc.Scene:create())
    end
    local scene = cc.Director:getInstance():getRunningScene()
    local label = cc.Label:createWithSystemFont("", "", 18)
    label:setColor(cc.c3b(0, 200, 0))
    label:enableOutline(cc.c4b(0,0,0,255),3)
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setString(string.format(...))
    label:setPosition(label:getContentSize().width/2,480-label:getContentSize().height/2-totalHeight)
    totalHeight = totalHeight + label:getContentSize().height
    scene:addChild(label)
    logLabels[logIndex] = label
    logIndex = logIndex + 1
end

local savepath = cc.FileUtils:getInstance():getWritablePath()
local logFileName = savepath.."/".."xygj_log_"..os.date("%Y%m%d%H%M%S",os_clock())..".txt"
local errorDict = {}
-- for CCLuaEngine traceback
function _log2File(msg)
    LOG_INDEX = LOG_INDEX or 1
    LOG_INDEX = LOG_INDEX + 1
    errorDict["index:"..LOG_INDEX] = tostring(msg)
    cc.FileUtils:getInstance():writeToFile(errorDict, logFileName)
end

function cclog(...)
    if targetPlatform == cc.PLATFORM_OS_WINDOWS then
        print(string.format(...))
    else
        release_print(string.format(...))
    end
    --_log2File(string.format(...))
    --log2Screen(...)
end


function log(...)
        local args = {...}
        args[1] = "["..args[1].."]"
        --logsplite(unpack(args))
        local logstr = ""
        for i=1,#args do
            logstr = logstr..args[i]
        end

        cclog(logstr)
end

cc.Device:setKeepScreenOn(true)

---- 重载view脚本
--if __G_NOT_FIRST_ENTER then
--    package.loaded["src.clickhero.ch"] = nil
--    return require "src.clickhero.ch"
--end
--
--__G_NOT_FIRST_ENTER = true
-- 重启游戏
__G__ONRESTART__ = function(back)
    local _isMark = false
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        if zzy.Sdk.getFlag()=="HDYM" then
            _isMark = true
        end
    end

    ch.LevelController:stop()
    ch.UIManager:cleanGamePopupLayer(true,false)
    zzy.NetManager:destoryInstance()
    zzy.uiViewBase:destoryCache()
    ch.ChatView:destroyInstanse()
    ccs.ArmatureDataManager:destroyInstance()
    cc.Director:getInstance():getScheduler():unscheduleAllScriptEntry()
    zzy.EventManager:clean()
    ch.MusicManager:stopMusic()
    GameConfig:clean()
    zzy.clean()
    ch.clean()
end

function __G__ON_SDK_CALLBACK__(...)
    local args = {...}
    local evt = {}
    evt.type = "sdk_event_" .. args[1]
    local i = 2
    while i < table.maxn(args) do
        evt[args[i]] = args[i+1]
        i = i + 2
    end
    cclog("lua sdk event:" .. json.encode(evt))
    zzy.EventManager:dispatch(evt)
end

local function csb()
--[[
cc.CSLoader:csb2Xml("res/ui/achievement/N_Achieve.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/N_AchieveIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/N_Achievelistview.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/N_Boardunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/N_Boardunit2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/N_BTNget.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/N_Top.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/N_Topframe.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/N_TopUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/N_TopUnit2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Achievelist.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_AchieveUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Board.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Taps_achieve.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Taps_AchieveNew.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Taps_Alist_in1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Taps_Alist_in2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Taps_in1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Taps_in2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Taps_in3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Top_in1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Top_in2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/achievement/W_Top_in3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/N_Novice_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_7days.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_7days_in1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_7days_in2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_7days_in3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_7days_in4.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_7days_in5.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_7days_in6.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_7days_in7.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_7days_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_7days_unit2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_meirixg.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_meirixg2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_meirixgcard.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/activity/W_Novice.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/autofight/W_autofight_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/autofight/W_autofight_2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/autofight/W_autofight_3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/autofight/W_autofight_4.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/autofight/W_autofight_5.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuDetail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuDps.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuList.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuSkill.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuStarremove.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuStars.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/btnBaowuLvup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/btnBaowustarup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuIconWsframe.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuIconWStar.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuIconWStar2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_Baowulistview.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuListviewSkill.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuSkillIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuSkillListview.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuStarRDes.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuStars.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BTNBaowuLvup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BTNBaowustarup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BTNBaowustarup2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BTNBaowuUnlock.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuDetail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuList.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuSkillunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuStar.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuStarget.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuStarlist.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuStarremove.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuStarremove2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuUnitStar.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/N_card_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/N_card_2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/N_card_3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/N_card_4.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/N_card_flag.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/N_card_jt.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/N_card_mini.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/N_card_result.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/N_card_runic.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/N_jt_lueduojilu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/N_tt_zhandoujilu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_bg.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_bw.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_chakan.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_chakan1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_detail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_detail1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_detaillist.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_f.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_f_choose.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_f_xk.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_get.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_guild_bg.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_guild_give.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_list.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_qualityup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_rob_result.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_select.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_tochip.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_card_tupojiesuan.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_jt_guize.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_jt_lveduo.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_jt_lveduounit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_jt_lveduo_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_jt_main.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_jt_zhandoujilu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_tt.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_tt_frame.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_tt_frame_after10.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_tt_frame_first10.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_tt_front.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/card/W_tt_zhandoujilu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/cardInstance/N_Btn_cishu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/cardInstance/N_Btn_lingqu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/cardInstance/N_Btn_tiaozhan.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/cardInstance/N_Btn_tiaozhan2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/cardInstance/W_ActivityCard.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/cardInstance/W_cardins.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/cardInstance/W_CardPop.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/cardInstance/W_Result.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/CardPit/N_pit_gzjilu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/CardPit/W_ActivityMine.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/CardPit/W_pit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/CardPit/W_pit_att.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/CardPit/W_pit_jilu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/CardPit/W_pit_occ.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/CardPit/W_pit_rule.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/CardPit/W_pit_seat.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/CardPit/W_pit_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/N_Xmas_buy.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/N_Xmas_icon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/N_zhuanpan1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/N_ZSZP1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Christmas.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Christmas1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Christmas2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_CZFH.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_CZFH_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_CZXL.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_CZXL_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_double_jt.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_double_kqfb.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_double_mcsl.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_double_tl.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_HYGG.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_HYGG_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Love.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Love_CP.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_MCSF.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_NianShou.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_redbag.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_redbag_JS.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_RYJK_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_RYJK_2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_RYJK_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_SQYX.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_SQYX_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_XCXY.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_XHFL.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_XHFL_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Xmas_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Xmas_2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Xmas_com.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Xmas_icon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Xmas_shop.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Xmas_txt_DH.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Xmas_txt_JJ.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Xmas_txt_JS.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Xmas_txt_LD.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Xmas_txt_QD.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_Xmas_txt_XG.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_zhuanpan.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_zhuanpan_JS.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_ZSZP.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Christmas/W_ZSZP_JS.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/btnClose.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/Level.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_BTNClose.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_BTNDown.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_BtnGupdown.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_BtnG_achieve.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_BTNLvup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_BTNUp.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Btn_cancel.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Btn_confirm.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Btn_ok.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_BwStarget.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_CBLv10.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_CBLv100.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_DBItem0.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_DBItem1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_DBItem2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_DBItems.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Des2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Dmg.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Dmgd.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Dps.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Dpsd.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_frame_9.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Line1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_listview.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Lv.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Money.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyCardd.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyChipd.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyCommond.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyCrystal.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyDiamond.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyDiamonds.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyGold.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyGoldd.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyGolds.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyS.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneySoul.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneySouls.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneySoulsd.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyStaged.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyStone.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyStones.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_MoneyStonesd.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Moneywarsongs.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Name.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Nameb.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Named.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Nameno.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Nameno2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_PlayerIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_SkillDes1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_SkillIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_SkillIcon2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Star.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Title1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Title2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Title3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Title4.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Title6.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Title7.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_Titlegettitle.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_TitleWin.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/N_TutengDes.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/ReferenceText.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_BattleFail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_BattleWin.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_building.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_building1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_building2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_drawer.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_drawerdb.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_gettitle.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_offlinegold.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop10.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop4.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop4a.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop4b.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop5.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop5a.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop7.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop8.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop8b.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop8g.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop9.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop9b.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Pop9g.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Popcard.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Popcard2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Popchat.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_Poperror.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_PopT1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_PopT2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_PopZR.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_reconnect.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_screentouch.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_sysloading.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_tips.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_tipsbossfaild.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_tipssguidefirst1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_tipssguidefirst2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_tipssguidefirstboss.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_tipssguideJszd.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_tipssguideJszd1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_tipssguideJszd2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_tipssguideStar.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_tipssguidetuteng.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_tipssguideTuteng2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Common/W_title_tips.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/btnFuwenLvup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/btnFuwenunlock.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/FuwenDetail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/FuwenList.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/FuwenPrestige.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/FuwenSkillDetail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/FuwenSkilllocked.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/FuwenSkillLvup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/nodeDes1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_BTNFight.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_BTNFuwen.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_BTNFuwenLvup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_BTNGetbonus.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_BTNPrestige.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_BTNUnlock.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_FuwenDetailunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_FuwenDetailunit2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_FuwenDmg.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_Fuwenlistview.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_FuwenPrestige.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_FuwenSkill.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_FuwenSkill2Icon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_FuwenSkillIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/N_PrestigeSkillIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/skillIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenChangepet.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenDetail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenDetail1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenDetail2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenDmg.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenGetbonus.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenGetUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenList.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenListunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenPet.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenPetChange.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenPetdetail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenPetunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenPetunit2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenPetView.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenPrestige.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenSkill.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenSkillListunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenSkillunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_FuwenSkillunit1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_PetBonusunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_PetSpecialunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_Prestageunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_Prestageunit1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_Prestageunit2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_Prestige.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_Prestige2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_Prestigecard.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/fuwen/W_Prestigepop.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_Btn_JSZD.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_ELBarStage.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_ELframe1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_ELframe3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_ELStage.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_Gglory.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_Ggloryd.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_Gglorydd.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_Guildicon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_GuildIconHero.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_GuildIconPet.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_JSZD_chest.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_newguild_guildwarteam.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_newguild_guildwarteam_2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/N_newguild_guildwar_node.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_El.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ElActivityCard.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELdiban1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELFight.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELGetUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELIn1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELIn1unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELIn2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELIn2other.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELIn2unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELIn3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELIn3unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELIn4.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELmask.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_ELresult.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildBuilding.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_Guildicon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildJoindetail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildJoinlist.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildJoinlistunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildJoinmember.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildJoinpop.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildLBtn.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildList.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildListmember.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_Guildmemberdetail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildQuitpop.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildSearchpop.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildSetting.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_GuildShop.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_JSActivityCard.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_JSZD.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_JSZDin1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_JSZDin1unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_JSZDin2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_JSZDresult.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_JSZDwaveresult.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_apply.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_apply_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_cardexchange.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_cardexchange_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_change.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_cover.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_EL.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildinstruction.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildlevel.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildlevel_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildmembernews.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildtips.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_conquest_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_conquest_2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_conquest_3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_conquest_4.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_dailyprize.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_entrance.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_instruction.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_jijieshijian.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_mainbroad.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_myarmy.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_myarmy_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_ourconquest.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_prize.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_prize_creamdata.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_prize_creamdata_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_shadowarmy.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_top.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_guildwar_top_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_information.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_information_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_information_my.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_information_my_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_join.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_join_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_manage.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_manage_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_memberdetail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_my.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_my_cardexchange.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_my_fomo.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Guild/W_NewGuild_sign.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/btnFightboss.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/btnScore.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/btnSetting.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/MainScene.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/nodeBarMenu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/nodeBarSkill.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/nodeBarTop.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/nodeMoney.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/nodeStage.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_BarMainMenu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_BarSkill.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_BarStage.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_BarTop.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_BTNFightboss.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_BTNScore.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_BTNSetting.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_BTNSkill.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_Buff.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_chat_input.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_currentdmg.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_icongroup1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_icongroup2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_icongroup3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_JSZDtips.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_JSZD_Skill.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_monsterBlood.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_MSdmg.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_MSdmgbak.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/N_Stage.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/Scene_temp.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/StageEasy.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/StageHard.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/StageNormal.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/S_MainScene.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/temp.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W3_Skill.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_Activity.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_chat.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_chat_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_chat_2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_chat_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_FuwenArea.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_Heroboss.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_Herobossresult.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_icongroup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_JSZDmain.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_JSZDpause.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_TBossresult.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_title_getnew.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/MainScreen/W_title_preview.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/N_Msgicon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_ad.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_Msg.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_MsgCattachment.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_MsgContent.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_MsgContent2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_MsgCtext.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_MsgFriend.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_MsgIn1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_MsgIn2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_MsgIn3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_MsgLine.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_MsgNotice.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/msg/W_MsgSystem.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/reg/Nreg_idlist_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/reg/Nreg_idlist_unit2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/reg/reg_change.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/reg/reg_default.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/reg/reg_login.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/reg/reg_reg.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/setting/N_Popsetting.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/setting/N_Settinglistview.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/setting/W_facebook_in.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/setting/W_SettingCName.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/setting/W_SettingCName_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/setting/W_SettingItem.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/setting/W_SettingList.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/setting/W_SettingSN.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/setting/W_SNbonus.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/setting/W_SNunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/setting/W_switch_check.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/share/N_ShareB_1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/share/N_ShareB_2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/share/N_ShareB_3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/share/N_SharePrizeIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/share/W_Popshare.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/share/W_Share.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/share/W_ShareAchievement.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/share/W_ShareCard.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/share/W_Shareday.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/share/W_ShareFix.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/N_BTNBuy.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/N_BTNUdiamond.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/N_BTNUrmb.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/N_update.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shopIn1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shopIn2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shoppop.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shopucard.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_buybosstime.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_buycard.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_buycard2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_buydiamond.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_buygold.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_buypet.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_buypet2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_buystone.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_buy_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_cdclean.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_chongzhi.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_Shop_ChongZhiItem.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_confirm.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_confirm_diamond.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_HWCZ.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/Shop/W_shop_shuoming.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/statistics/N_Statislistview.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/statistics/W_StatisItem.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/statistics/W_StatisItem2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/statistics/W_Statislist.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/statistics/setting/N_Settinglistview.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/statistics/setting/W_SettingItem.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/statistics/setting/W_SettingList.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/task/N_Popsign.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/task/W_sign.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/task/W_SignActivityCard.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/task/W_signunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/task/W_TaskList.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/task/W_TaskListBtn.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/task/W_TaskListunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/task/W_Taskrefrash.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/test/MainScene.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/test/Node.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/test/testNode.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/test/ui/loading/N_screen.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tips/W_tips.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tips/W_tips2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/N_BTNqingchu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/N_BTNqingchu1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/N_BTNqingchu2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/N_BTNTutengLvup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/N_BTNTutengLvup2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/N_BTNzhaohuan.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/N_BTNzhaohuan1.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/N_BTNzhaohuan2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/N_TutengIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/N_Tutenglistview.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/N_TutengXUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/W_TutengLBtn.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/W_TutengList.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/W_TutengLUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/W_TutengQingchu.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/W_TutengQingchu2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/W_TutengQingchu3.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/W_TutengXiangqing.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/W_TutengXuanze.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/W_TutengZhaohuan.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/W_Tuteng_jtItem.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/tuteng/W_Tuteng_tujian.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/zhousai/N_zhousai_rank.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/zhousai/N_zhousai_reward.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/zhousai/W_PopPH.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/zhousai/W_PopZS.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/zhousai/W_zhousaichakan.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/zhousai/W_zhousaiPH.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/zhousai/W_zhousai_unit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/autofight/W_autofight_4.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/autofight/W_autofight_5.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuDetail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuDps.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuList.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuSkill.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuStarremove.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuStars.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/BaowuUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/btnBaowuLvup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/btnBaowustarup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuIconWsframe.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuIconWStar.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuIconWStar2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuListviewSkill.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuSkillIcon.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuSkillListview.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuStarRDes.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuStars.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BaowuUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BTNBaowuLvup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BTNBaowustarup.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BTNBaowustarup2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/N_BTNBaowuUnlock.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuDetail.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuList.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuSkillunit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuStar.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuStarget.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuStarlist.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuStarremove.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuStarremove2.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuUnit.csb","res/ui/")
cc.CSLoader:csb2Xml("res/ui/baowu/W_BaowuUnitStar.csb","res/ui/")
]]

--cc.CSLoader:csb2Xml("res/ui/MainScreen/W3_Skill.csb","res/ui/")

end

local function main()
	-- tgx
    local uipath = "/res/ui"
    local tmpPaths = {}
    local spath = cc.FileUtils:getInstance():getSearchPaths()
	for i=1, #spath do
		local path = spath[i]
        
        local resStart, resEnd = string.find(path, "/res")
        if resStart then
            tmpPaths[#tmpPaths + 1] = string.sub(path, 1, resStart-1)..uipath..string.sub(path, resEnd+1, -1)
        end
	end
    
    for i=1, #tmpPaths do
        table.insert(spath,1,tmpPaths[i])
        print(string.format("tmpPaths[%d]=%s", i, tmpPaths[i]))
    end    
	cc.FileUtils:getInstance():setSearchPaths(spath)
    
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    zzy.cUtils.cancelLocalNotifications()
    local director = cc.Director:getInstance()
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC or
        cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        --director:setDisplayStats(true)
    else
         director:setDisplayStats(false)
    end
    if zzy.cUtils.isLowMemory() then
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
    end
   
--    local fm,pm = zzy.cUtils.getMemory()
--    
--    cclog("可用内存".. fm)
--    cclog("总内存："..pm)
--    
   
    director:setAnimationInterval(1.0 / 30)
    
    director:getOpenGLView():setDesignResolutionSize(640, 1136, cc.ResolutionPolicy.SHOW_ALL)
    gameScene = cc.Scene:create()
    
    -- 启动场景
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
    
    -- 封面
--    local default = nil
--    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
--        if zzy.Sdk.getFlag()~="DEFAULT" then
--            default = ccui.ImageView:create("res/ui/aaui_png/default_hdzzy.png")
--        else
--            default = ccui.ImageView:create("res/ui/aaui_png/default.png")
--        end
--        default:setPosition(cc.p(320, 568))
--        gameScene:addChild(default)
--    end
    
    --tgx for test
    --csb()
    --local testNode = cc.CSLoader:csb2Xml("res/ui/test/MainScene.csb")
    cclog("----------------------------------")
    --tgx test

    zzy.EventManager:listen(zzy.Sdk.Events.initDone, function(sender, evt)
        --sdk初始化完成后初始化游戏
        if zzy.Sdk.getFlag()=="HDANY" then
            print("=====HDANY=====")
			 --重置ChannelID anysdk的channel在initdone之后会换成anysdk渠道的channelid  之前是默认的999999
			local appConfig = zzy.StringUtils:splitToTable(zzy.cUtils.getAppConfig())
			zzy.config.ChannelID = appConfig.ChannelID or  zzy.config.ChannelID
            zzy.config.ChannelID = GameConst.CHANNELID[tostring(zzy.config.ChannelID)].channelid
        end
		local flag= string.sub(zzy.Sdk.getFlag(),1,2)
		if flag=="WY" then
			zzy.config.exchange_rate=5
		end
	
		--  网络测试 
        math.randomseed(os_clock())
        local totalFrame = 0
        local count=0
        local _lastTime = os_clock()
        local _timeInterval = 5
		local lastcheck=false --上次检测结果 true为加速 只有2次都出问题才认为加速 防止自动同步系统时间导致误判
        
        if _G_TICK then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_G_TICK)
        end
        _G_TICK = director:getScheduler():scheduleScriptFunc(function()
			count=count+1
			if  count==math.floor(_timeInterval*30*1.3)  then
                if  os_clock() < _lastTime + _timeInterval then
				   if lastcheck ==false then
						 lastcheck=true
				   else
					   ch.fightRoleLayer:pause()
                       local realFps = count / (os_clock() - _lastTime)
                       local fps = 30
                       local ratio = realFps / fps
					   ch.UIManager:showMsgBox(1,true,Language.src_main_1,function()
							os.exit()
							return
					   end)
				   end
				else
					lastcheck=false
                end
                _lastTime = os_clock()
                count=0
            end
            -- 大任务处理器
            zzy.BigTaskUtils:loop()
            -- 时间工具
            zzy.TimerUtils:update()
           
            -- 自动移除不在使用的纹理
            if totalFrame % 300 == 0 then
                cc.Director:getInstance():getTextureCache():removeUnusedTextures()
            end
            
            if totalFrame % 300 == 0 then
				cc.AnimationCache:destroyInstance()
                ch.CommonFunc:delCardSkes()
            end
            -- 抛出帧频时间
            local tickEvt = zzy.Events:createTickEvent()
            tickEvt.frameCount = totalFrame
            zzy.EventManager:dispatch(tickEvt)
            totalFrame = totalFrame + 1
             --定时发送指令和控制
            ch.TimerController:update()
        end, 0, false)
        -- cocostudio配置
        zzy.uiViewBase.DEFAULT_CSB_PATH_BASE = "res/ui/"
        ch.LoginView:init(gameScene)
    end)
    if zzy.cUtils.getNetworkState() == 0 then
        local message = GameConst.NET_ERROR[1]
        local text = Language.MSG_BUTTON_YESOK
        cc.Director:getInstance():getTextureCache():addImage("res/ui/tips/plist_tips.png")
        cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/tips/plist_tips.plist")
        local render = cc.CSLoader:createNode("res/ui/tips/W_tips.csb","res/ui/")
        local label = zzy.CocosExtra.seekNodeByName(render, "text_message")
        label:setString(message)
        local btn = zzy.CocosExtra.seekNodeByName(render,"Button_qingchu")
        btn:setTitleText(text)    
        btn:addTouchEventListener(function(sender, evnentType)
            if evnentType == ccui.TouchEventType.ended then
                render:removeFromParent()
                cclog("重启")
                __G__ONRESTART__()
            end
        end)
        if gameScene then
            gameScene:addChild(render)
        end
        render:setLocalZOrder(1000)
    else
        zzy.Sdk.init()
    end
    
    local useWarningLayer = IS_BANHAO
    local warningLayer = cc.CSLoader:createNode("res/ui/loading/warning.csb")
    gameScene:addChild(warningLayer, 20000)
    local function closeMe()
        local evt = {
        type = "sdk_event_flashDone",
        }
        zzy.EventManager:dispatch(evt)
        warningLayer:removeFromParent()
    end
    local cbCloseMe = cc.CallFunc:create(closeMe)
    local delay = cc.DelayTime:create(1.7)
    local fadeOut = cc.FadeOut:create(0.5)
    
    if not useWarningLayer then
        closeMe()
    else
        warningLayer:runAction(cc.Sequence:create(delay,fadeOut, cbCloseMe))
    end
end

-- 不重启
zzy.EventManager:listen(zzy.NetManager.stateChangeEventType,function(obj,evt) 
    if evt.state == 3 or evt.state == 4 then 
        ch.fightRoleLayer:pause()
        ch.UIManager:showMsgBox(1,false,GameConst.BREAK_LINE_REMIND,function()
            cclog("网络状态"..zzy.cUtils.getNetworkState())
            ch.LevelController:reStartGame()
        end)
    end
end)

local notice = function()
    local time = {}
    -- 2小时，6小时，12小时，18小时，24小时
    for i = 1,table.maxn(GameConst.CALLBACK_TIME)-1 do
        time[i] = os_clock() + GameConst.CALLBACK_TIME[i]
        
        if time[i]>ch.CommonFunc:getAppointedTime(time[i],8) and time[i]<ch.CommonFunc:getAppointedTime(time[i],23) then
            cclog("正常提醒")
        elseif time[i] <= ch.CommonFunc:getAppointedTime(time[i],8) then
            time[i] = ch.CommonFunc:getAppointedTime(time[i],8)
        elseif time[i] >= ch.CommonFunc:getAppointedTime(time[i],23) then
            time[i] = ch.CommonFunc:getAppointedTime(ch.CommonFunc:getAppointedTime(time[i],24),8)
        end
        if i==1 or time[i] > time[i-1] then
            zzy.cUtils.addLocalNotification(time[i],false,GameConst.CALLBACK_MESSAGE,GameConst.CALLBACK_MESSAGE,GameConst.CALLBACK_TITLE,GameConst.CALLBACK_SCROLL)
        end
    end
--    -- 超过24小时，少于7天（早九点和晚九点）
    local j = table.maxn(GameConst.CALLBACK_TIME)
--    if time[j-1] < ch.CommonFunc:getAppointedTime(time[j-1],9) then
--        time[j] = ch.CommonFunc:getAppointedTime(time[j-1],9)
--    elseif time[j-1] < ch.CommonFunc:getAppointedTime(time[j-1],21) then
--        time[j] = ch.CommonFunc:getAppointedTime(time[j-1],21)
--    else
--        time[j] = ch.CommonFunc:getAppointedTime(ch.CommonFunc:getAppointedTime(time[j-1],24),9)
--    end
--    while time[j] < GameConst.CALLBACK_TIME[table.maxn(GameConst.CALLBACK_TIME)] do
--        zzy.cUtils.addLocalNotification(time[j],true,GameConst.CALLBACK_MESSAGE_NEW,GameConst.CALLBACK_MESSAGE_NEW,GameConst.CALLBACK_TITLE,GameConst.CALLBACK_SCROLL)
--    	j = j + 1
--    	time[j] = time[j-1] + 12*60*60
--    end
    -- 第7天最后一次提醒
    time[j] = os_clock() + GameConst.CALLBACK_TIME[table.maxn(GameConst.CALLBACK_TIME)]
    zzy.cUtils.addLocalNotification(time[j],false,GameConst.CALLBACK_MESSAGE,GameConst.CALLBACK_MESSAGE,GameConst.CALLBACK_TITLE,GameConst.CALLBACK_SCROLL)
    
    -- 月卡提醒
    local timeYK = os_time()+ch.BuffModel:getCardBuffTime()-1800
    if timeYK > os_clock() then
        zzy.cUtils.addLocalNotification(timeYK,false,GameConst.CALLBACK_YUEKA_MESSAGE,GameConst.CALLBACK_YUEKA_MESSAGE,GameConst.CALLBACK_YUEKA_TITLE,GameConst.CALLBACK_YUEKA_SCROLL)
    end
    -- 体力通知
    if string.sub(zzy.Sdk.getFlag(),1,2)~="CY" and ch.StatisticsModel:getMaxLevel() > GameConst.CARD_FB_OPEN_LEVEL then
        local zeroTime = ch.CommonFunc:getAppointedTime(os_time(),0)
        local addTime = os_clock() - os_time()
        for i=1,#GameConst.CARD_FB_TL_TIME do
            local time = zeroTime + GameConst.CARD_FB_TL_TIME[i].startTime *3600 + addTime
            if time <= 1200 + os_time() or time <= os_time() then 
                time = time + 24*3600
            end
            zzy.cUtils.addLocalNotification(time,false,GameConst.CALLBACK_STAMINA_MESSAGE,GameConst.CALLBACK_STAMINA_MESSAGE,GameConst.CALLBACK_YUEKA_TITLE,GameConst.CALLBACK_STAMINA_MESSAGE)
        end
    end
end

local offTime = os_clock()

zzy.EventManager:listen(zzy.Events.BackgroundEventType,function(obj,evt)

    zzy.NetManager:getInstance():switchBackGround(evt.isBack)
    if not evt.isBack then
        
        zzy.cUtils.cancelLocalNotifications()
        
        --从后台切回到游戏，请求下离线收益
        if ch.GameLoaderModel.loadingCom and os_clock()-offTime > 35 then
            ch.NetworkController:reOffLine()
        end
    end
    if evt.isBack then
        offTime = os_clock()
    end
    if evt.isBack and ch.SettingModel:isNoticeRemind() and zzy.NetManager:getInstance():isWorking() then
        notice()
    end
end)

zzy.EventManager:listen("sdk_event_restart",function(obj,evt)
   __G__ONRESTART__()
end)

zzy.EventManager:listen("sdk_event_showPop",function(obj,evt)
    ch.UIManager:showMsgBox(1,true,evt.data.msg,function()
        cclog("showPop") 
    end)
end)


 --监听扩展数据接口
zzy.EventManager:listen("sdk_event_extendFunc",function(obj,evt)
	local extendData = json.decode(evt.data)
	if extendData ~= nil  then
		if  extendData.f == "share" then
			-- 分享回调到游戏
			local body = extendData.body
			if body.t == "WX" then -- 微信
				ch.NetworkController:getShareReward(ch.ShareModel:getCurShareData())
			elseif body.t == "SINAWB" then -- 微博
				ch.NetworkController:getShareReward(ch.ShareModel:getCurShareData())
            elseif body.t == "FB" then
                ch.NetworkController:getShareReward(ch.ShareModel:getCurShareData())
			end
		elseif extendData.f =="charge" then
			-- 消费成功后回调到游戏
			--local orderdata=json.decode(extendData.body)
            -- orderdata.receipt=json.decode(jsonReceipt)
			-- orderdata.receiptsign=extendData.receiptsign
			ch.CommonFunc:consumption(evt.data) 
		elseif extendData.f =="fbbind" then
			--绑定fb成功
			if extendData.data.ret==0 then
				zzy.config.loginData.fbid=extendData.data.fbid 
				ch.SettingModel:fbDataChangeEvent()
				if zzy.config.fbbindByShare == true then
					zzy.Sdk.extendFunc(ch.ShareModel:getShareJsonStr())
				end
				ch.NetworkController:sendFBBind()
			else
				local tips =Language.FB_ERROR_TIPS["e"..math.abs(extendData.data.ret)] 
				if tips==nil then
					 tips =Language.FB_ERROR_TIPS["e99999999"] 
				end
				ch.UIManager:showMsgBox(1,true,tips,nil)
			end
		elseif extendData.f =="fbswitch" then
			--切换账号
			if extendData.data.ret==0 then
				ch.UIManager:showMsgBox(1,true,Language.FB_SWITCH_SUCC_TIPS,nil)
			else
				local tips =Language.FB_ERROR_TIPS["e"..math.abs(extendData.data.ret)] 
				if tips==nil then
					 tips =Language.FB_ERROR_TIPS["e99999999"] 
				end
				ch.UIManager:showMsgBox(1,true,tips,nil)
			end
		elseif extendData.f =="fbunbind" then
			--解绑fb
			if extendData.data.ret==0 then
				zzy.config.loginData.fbid=nil
				zzy.config.fbbindByShare = false
				ch.SettingModel:fbDataChangeEvent()
			else
				local tips =Language.FB_ERROR_TIPS["e"..math.abs(extendData.data.ret)] 
				if tips==nil then
					 tips =Language.FB_ERROR_TIPS["e99999999"] 
				end
				ch.UIManager:showMsgBox(1,true,tips,nil)
			end
		elseif extendData.f =="showloading" then
			if extendData.data.t==1 then
				ch.UIManager:showWaiting(true)
			elseif extendData.data.t==2 then
				ch.UIManager:showWaiting(false)
			elseif extendData.data.t==3 then
				ch.UIManager:showWaiting(false,true)
			end
	   end
	end
end)

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end

