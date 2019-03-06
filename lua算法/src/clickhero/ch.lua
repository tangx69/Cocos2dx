require "res.config.ExportJsonInfo"
require "src.clickhero.debug"
require "src.platform.platform"

ch = {}

local viewFiles = {
    "src/clickhero/view/MainView.lua",
    "src/clickhero/view/MagicView.lua",
    "src/clickhero/view/RunicView.lua",
    "src/clickhero/view/TotemView.lua",
    "src/clickhero/view/CommonView.lua",
	"src/clickhero/view/StatisticsView.lua",
	"src/clickhero/view/AchievementView.lua",
    "src/clickhero/view/ActiveSkillView.lua",
    "src/clickhero/view/SettingView.lua",
    "src/clickhero/view/OffLineView.lua",
    "src/clickhero/view/SignView.lua",
    "src/clickhero/view/RankListView.lua",
    "src/clickhero/view/ShopView.lua",
    "src/clickhero/view/PartnerView.lua",
    "src/clickhero/view/MsgView.lua",
    "src/clickhero/view/TaskView.lua",
    "src/clickhero/view/GameLoaderView.lua",
    "src/clickhero/view/ReconnectView.lua",
    "src/clickhero/view/GuildView.lua",
    "src/clickhero/view/ActivityView.lua",
    "src/clickhero/view/DefendView.lua",
    "src/clickhero/view/PetCardView.lua",
    "src/clickhero/view/FestivityView.lua",
    "src/clickhero/view/AFKView.lua",
    "src/clickhero/view/CardActivityView.lua",
    "src/clickhero/view/AltarView.lua",
    "src/clickhero/view/CardFBView.lua",
    "src/clickhero/view/ShareView.lua",
    "src/clickhero/view/ChristmasView.lua",
    "src/clickhero/view/WheelView.lua",
    "src/clickhero/view/MineView.lua",
    "src/clickhero/view/RandomShopView.lua",
    "src/clickhero/view/GuildNewView.lua",
    "src/clickhero/view/GuildWarView.lua",
}

for _,file in ipairs(viewFiles) do
	require(file)
	package.loaded[file] = nil
end

local classPath = {}


---
-- @field [parent=#ch] LoginView#LoginView LoginView
classPath.LoginView = "src/clickhero/view/LoginView.lua"

---
-- @field [parent=#ch] LevelController#LevelController LevelController
classPath.LevelController = "src/clickhero/controller/LevelController.lua"
---
-- @field [parent=#ch] NetworkController#NetworkController NetworkController
classPath.NetworkController = "src/clickhero/controller/NetworkController.lua"
---
-- @field [parent=#ch] NetworkController2#NetworkController2 NetworkController2
classPath.NetworkController2 = "src/clickhero/controller/NetworkController2.lua"
---
-- @field [parent=#ch] GuildWarController#GuildWarController GuildWarController
classPath.GuildWarController = "src/clickhero/controller/GuildWarController.lua"
---
-- @field [parent=#ch] NetworkDebugController#NetworkDebugController NetworkDebugController
classPath.NetworkDebugController = "src/clickhero/controller/NetworkDebugController.lua"

---
-- @field [parent=#ch] TimerController#TimerController TimerController
classPath.TimerController = "src/clickhero/controller/TimerController.lua"

---
-- @field [parent=#ch] UIManager#UIManager UIManager
classPath.UIManager = "src/clickhero/manager/UIManager.lua"

---
-- @field [parent=#ch] UpdateManager#UpdateManager UpdateManager
classPath.UpdateManager = "src/clickhero/manager/UpdateManager.lua"


---
-- @field [parent=#ch] guide#guide guide
classPath.guide = "src/clickhero/guide/guide.lua"
---
-- @field [parent=#ch] RoleResManager#RoleResManager RoleResManager
classPath.RoleResManager = "src/clickhero/manager/RoleResManager.lua"
---
-- @field [parent=#ch] SoundManager#SoundManager SoundManager
classPath.SoundManager = "src/clickhero/manager/SoundManager.lua"
---
-- @field [parent=#ch] MusicManager#MusicManager MusicManager
classPath.MusicManager = "src/clickhero/manager/MusicManager.lua"

---
-- @field [parent=#ch] StatisticsManager#StatisticsManager StatisticsManager
classPath.StatisticsManager = "src/clickhero/manager/StatisticsManager.lua"

---
-- @field [parent=#ch] ChatView#ChatView ChatView
classPath.ChatView = "src/clickhero/view/ChatView.lua"

---
-- @field [parent=#ch] ModelManager#ModelManager ModelManager
classPath.ModelManager = "src/clickhero/model/ModelManager.lua"
---
-- @field [parent=#ch] MagicModel#MagicModel MagicModel
classPath.MagicModel = "src/clickhero/model/MagicModel.lua"
---
-- @field [parent=#ch] PetCardModel#PetCardModel PetCardModel
classPath.PetCardModel = "src/clickhero/model/PetCardModel.lua"
---
-- @field [parent=#ch] MoneyModel#MoneyModel MoneyModel
classPath.MoneyModel = "src/clickhero/model/MoneyModel.lua"
---
-- @field [parent=#ch] RunicModel#RunicModel RunicModel
classPath.RunicModel = "src/clickhero/model/RunicModel.lua"
---
-- @field [parent=#ch] TotemModel#TotemModel TotemModel
classPath.TotemModel = "src/clickhero/model/TotemModel.lua"
---
-- @field [parent=#ch] TotemModel#TotemModel TotemModel
classPath.ShentanModel = "src/clickhero/model/ShentanModel.lua"
---
-- @field [parent=#ch] GuideModel#GuideModel GuideModel
classPath.GuideModel = "src/clickhero/model/GuideModel.lua"
---
-- @field [parent=#ch] PartnerModel#PartnerModel PartnerModel
classPath.PartnerModel = "src/clickhero/model/PartnerModel.lua"
---
-- @field [parent=#ch] MsgModel#MsgModel MsgModel
classPath.MsgModel = "src/clickhero/model/MsgModel.lua"
---
-- @field [parent=#ch] FairyModel#FairyModel FairyModel
classPath.FairyModel = "src/clickhero/model/FairyModel.lua"
---
-- @field [parent=#ch] ShopModel#ShopModel ShopModel
classPath.ShopModel = "src/clickhero/model/ShopModel.lua"
---
-- @field [parent=#ch] RandomShopModel#RandomShopModel RandomShopModel
classPath.RandomShopModel = "src/clickhero/model/RandomShopModel.lua"
---
-- @field [parent=#ch] StatisticsModel#StatisticsModel StatisticsModel
classPath.StatisticsModel = "src/clickhero/model/StatisticsModel.lua"
--- 
-- @field [parent=#ch] AchievementModel#AchievementModel AchievementModel
classPath.AchievementModel = "src/clickhero/model/AchievementModel.lua"
--- 
-- @field [parent=#ch] LevelModel#LevelModel LevelModel
classPath.LevelModel = "src/clickhero/model/LevelModel.lua"
--- 
-- @field [parent=#ch] SettingModel#SettingModel SettingModel
classPath.SettingModel = "src/clickhero/model/SettingModel.lua"
--- 
-- @field [parent=#ch] SignModel#SignModel SignModel
classPath.SignModel = "src/clickhero/model/SignModel.lua"
--- 
-- @field [parent=#ch] FirstSignModel#FirstSignModel FirstSignModel
classPath.FirstSignModel = "src/clickhero/model/FirstSignModel.lua"
--- 
-- @field [parent=#ch] RankListModel#RankListModel RankListModel
classPath.RankListModel = "src/clickhero/model/RankListModel.lua"
--- 
-- @field [parent=#ch] GuildModel#GuildModel GuildModel
classPath.GuildModel = "src/clickhero/model/GuildModel.lua"
--- 
-- @field [parent=#ch] GuildWarModel#GuildWarModel GuildWarModel
classPath.GuildWarModel = "src/clickhero/model/GuildWarModel.lua"
--- 
-- @field [parent=#ch] TaskModel#TaskModel TaskModel
classPath.TaskModel = "src/clickhero/model/TaskModel.lua"
--- 
-- @field [parent=#ch] PlayerModel#PlayerModel PlayerModel
classPath.PlayerModel = "src/clickhero/model/PlayerModel.lua"
--- 
-- @field [parent=#ch] WarpathModel#WarpathModel WarpathModel
classPath.WarpathModel = "src/clickhero/model/WarpathModel.lua"
--- 
-- @field [parent=#ch] DefendModel#DefendModel DefendModel
classPath.DefendModel = "src/clickhero/model/DefendModel.lua"
--- 
-- @field [parent=#ch] PowerModel#PowerModel PowerModel
classPath.PowerModel = "src/clickhero/model/PowerModel.lua"
--- 
-- @field [parent=#ch] FestivityModel#FestivityModel FestivityModel
classPath.FestivityModel = "src/clickhero/model/FestivityModel.lua"
--- 
-- @field [parent=#ch] BuyLimitModel#BuyLimitModel BuyLimitModel
classPath.BuyLimitModel = "src/clickhero/model/BuyLimitModel.lua"
--- 
-- @field [parent=#ch] ChristmasModel#ChristmasModel ChristmasModel
classPath.ChristmasModel = "src/clickhero/model/ChristmasModel.lua"
--- 
-- @field [parent=#ch] GameLoaderModel#GameLoaderModel GameLoaderModel
classPath.GameLoaderModel = "src/clickhero/model/GameLoaderModel.lua"
--- 
-- @field [parent=#ch] BuffModel#BuffModel BuffModel
classPath.BuffModel = "src/clickhero/model/BuffModel.lua"
--- 
-- @field [parent=#ch] ChatModel#ChatModel ChatModel
classPath.ChatModel = "src/clickhero/model/ChatModel.lua"
--- 
-- @field [parent=#ch] FamiliarModel#FamiliarModel FamiliarModel
classPath.FamiliarModel = "src/clickhero/model/FamiliarModel.lua"
--- 
-- @field [parent=#ch] UserTitleModel#UserTitleModel UserTitleModel
classPath.UserTitleModel = "src/clickhero/model/UserTitleModel.lua"
--- 
-- @field [parent=#ch] AFKModel#AFKModel AFKModel
classPath.AFKModel = "src/clickhero/model/AFKModel.lua"
--- 
-- @field [parent=#ch] ArenaModel#ArenaModel ArenaModel
classPath.ArenaModel = "src/clickhero/model/ArenaModel.lua"
--- 
-- @field [parent=#ch] AltarModel#AltarModel AltarModel
classPath.AltarModel = "src/clickhero/model/AltarModel.lua"
--- 
-- @field [parent=#ch] MineModel#MineModel MineModel
classPath.MineModel = "src/clickhero/model/MineModel.lua"
--- 
-- @field [parent=#ch] MatchRankModel#MatchRankModel MatchRankModel
classPath.MatchRankModel = "src/clickhero/model/MatchRankModel.lua"
--- 
-- @field [parent=#ch] OffLineModel#OffLineModel OffLineModel
classPath.OffLineModel = "src/clickhero/model/OffLineModel.lua"
--- 
-- @field [parent=#ch] ShareModel#ShareModel ShareModel
classPath.ShareModel = "src/clickhero/model/ShareModel.lua"
--- 
-- @field [parent=#ch] CardFBModel#CardFBModel CardFBModel
classPath.CardFBModel = "src/clickhero/model/CardFBModel.lua"
---
-- @field [parent=#ch] fightBackground#fightBackground fightBackground
classPath.fightBackground = "src/clickhero/fight/fightBackground.lua"
---
-- @field [parent=#ch] fightRoleLayer#fightRoleLayer fightRoleLayer
classPath.fightRoleLayer = "src/clickhero/fight/fightRoleLayer.lua"
---
-- @field [parent=#ch] clickLayer#clickLayer clickLayer
classPath.clickLayer = "src/clickhero/fight/clickLayer.lua"
---
-- @field [parent=#ch] familiarRole#familiarRole familiarRole
classPath.familiarRole = "src/clickhero/fight/familiarRole.lua"
---
-- @field [parent=#ch] goldLayer#goldLayer goldLayer
classPath.goldLayer = "src/clickhero/fight/goldLayer.lua"
---
-- @field [parent=#ch] fightRole#fightRole fightRole
classPath.fightRole = "src/clickhero/fight/fightRole.lua"
---
-- @field [parent=#ch] petRole#petRole petRole
classPath.petRole = "src/clickhero/fight/petRole.lua"
---
-- @field [parent=#ch] fightRoleAI#fightRoleAI fightRoleAI
classPath.fightRoleAI = "src/clickhero/fight/fightRoleAI.lua"
---
-- @field [parent=#ch] fairyLayer#fairyLayer fairyLayer
classPath.fairyLayer = "src/clickhero/fight/fairyLayer.lua"
---
-- @field [parent=#ch] flyBox#flyBox flyBox
classPath.flyBox = "src/clickhero/fight/flyBox.lua"
---
-- @field [parent=#ch] editorConfig#editorConfig editorConfig
classPath.editorConfig = "src/clickhero/fight/editorConfig.lua"
---
-- @field [parent=#ch] RunicFightView#RunicFightView RunicFightView
classPath.RunicFightView = "src/clickhero/fight/RunicFightView.lua"
---
-- @field [parent=#ch] DefendMap#DefendMap DefendMap
classPath.DefendMap = "src/clickhero/fight/defend/DefendMap.lua"
---
-- @field [parent=#ch] DefendEnemy#DefendEnemy DefendEnemy
classPath.DefendEnemy = "src/clickhero/fight/defend/DefendEnemy.lua"
---
-- @field [parent=#ch] DefendTimer#DefendTimer DefendTimer
classPath.DefendTimer = "src/clickhero/fight/defend/DefendTimer.lua"
---
-- @field [parent=#ch] DefendPet#DefendPet DefendPet
classPath.DefendPet = "src/clickhero/fight/defend/DefendPet.lua"
---
-- @field [parent=#ch] DefendRefreshAI#DefendRefreshAI DefendRefreshAI
classPath.DefendRefreshAI = "src/clickhero/fight/defend/DefendRefreshAI.lua"
---
-- @field [parent=#ch] EnemyAI#EnemyAI EnemyAI
classPath.EnemyAI = "src/clickhero/fight/defend/EnemyAI.lua"
---
-- @field [parent=#ch] ALZSkill#ALZSkill ALZSkill
classPath.ALZSkill = "src/clickhero/fight/defend/skill/ALZSkill.lua"
---
-- @field [parent=#ch] CHSSkill#CHSSkill CHSSkill
classPath.CHSSkill = "src/clickhero/fight/defend/skill/CHSSkill.lua"
---
-- @field [parent=#ch] HHSSkill#HHSSkill HHSSkill
classPath.HHSSkill = "src/clickhero/fight/defend/skill/HHSSkill.lua"
---
-- @field [parent=#ch] FSZFSkill#FSZFSkill FSZFSkill
classPath.FSZFSkill = "src/clickhero/fight/defend/skill/FSZFSkill.lua"
---
-- @field [parent=#ch] YSCJSkill#YSCJSkill YSCJSkill
classPath.YSCJSkill = "src/clickhero/fight/defend/skill/YSCJSkill.lua"
---
-- @field [parent=#ch] ZRJDSkill#ZRJDSkill ZRJDSkill
classPath.ZRJDSkill = "src/clickhero/fight/defend/skill/ZRJDSkill.lua"
---
-- @field [parent=#ch] SkillFactory#SkillFactory SkillFactory
classPath.SkillFactory = "src/clickhero/fight/defend/skill/SkillFactory.lua"
---
-- @field [parent=#ch] CardFightMap#CardFightMap CardFightMap
classPath.CardFightMap = "src/clickhero/fight/card/CardFightMap.lua"
---
-- @field [parent=#ch] CardFightRole#CardFightRole CardFightRole
classPath.CardFightRole = "src/clickhero/fight/card/CardFightRole.lua"
---
-- @field [parent=#ch] CardFightView#CardFightView CardFightView
classPath.CardFightView = "src/clickhero/fight/card/CardFightView.lua"
---
-- @field [parent=#ch] CardBufferManager#CardBufferManager CardBufferManager
classPath.CardBufferManager = "src/clickhero/fight/card/CardBufferManager.lua"
---
-- @field [parent=#ch] Gesture#Gesture Gesture
classPath.Gesture = "src/clickhero/model/utils/Gesture.lua"
---
-- @field [parent=#ch] NumberHelper#NumberHelper NumberHelper
classPath.NumberHelper = "src/clickhero/utils/NumberHelper.lua"
---
-- @field [parent=#ch] CommonFunc#CommonFunc CommonFunc
classPath.CommonFunc = "src/clickhero/utils/CommonFunc.lua"
---
-- @field [parent=#ch] LongDouble#LongDouble LongDouble
classPath.LongDouble = "src/clickhero/utils/LongDouble.lua"
---
-- @field [parent=#ch] PowHelper#PowHelper PowHelper
classPath.PowHelper = "src/clickhero/utils/PowHelper.lua"

ch.loadedModules = ch.loadedModules or {}

setmetatable(ch,{__index = function(t, k)
    if not classPath[k] then return nil end

    table.insert(ch.loadedModules, k)
    local module = require(classPath[k])
    package.loaded[classPath[k]] = nil
    ch[k] = module
    return module
end})

ch.clean = function()
	ch = nil
    package.loaded["res.config.ExportJsonInfo"] = nil
    package.loaded["src.clickhero.ch"] = nil
	package.loaded["src.clickhero.debug"] = nil
    package.loaded["src.platform.platform"] = nil
    package.loaded["src.clickhero.fight.svr.load_module"] = nil
    package.loaded["src.clickhero.fight.svr.mod.baseobj.init"] = nil
    package.loaded["src.clickhero.fight.svr.mod.cardbattle.init"] = nil
    package.loaded["res.language.Language"] = nil
    if zzy.Sdk.PLATFORM_PLAYYX then
        package.loaded["src.platform.platform_playyx"] = nil
    end
end

return ch