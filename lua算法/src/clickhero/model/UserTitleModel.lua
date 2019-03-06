local UserTitleModel = {
    _lastLevel = nil,
    _curTitle = nil,
    _curAvatar = nil,
    _curWeapon = nil,
    showEffect = nil,
    dataChangeEventType = "USERTITLE_MODEL_DATA_CHANGE",
    dataType = {
        show = 1,
    }
}

---
-- 初始化
-- @function [parent=#UserTitleModel] init
-- @param #UserTitleModel self
function UserTitleModel:init()
    self:isNew()
end

---
-- @function [parent=#UserTitleModel] clean
-- @param #UserTitleModel self
function UserTitleModel:clean()
    self._lastLevel = nil
    self._curTitle = nil
    self._curAvatar = nil
    self._curWeapon = nil
    self.showEffect = nil
end

function UserTitleModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 是否了获得了新的称号
-- @function [parent=#UserTitleModel] isNew
-- @param #UserTitleModel self
-- @return #bool 是否获得新的称号
-- @return #bool 是否开启新的阶段
function UserTitleModel:isNew()
    local curLevel = ch.StatisticsModel:getMaxLevel() -1
    local gender = ch.PlayerModel:getPlayerGender()
    local isGot = false
    local isOpen = false
    if self._lastLevel ~= curLevel then
        for _,v in ipairs(GameConfig.UserTitleConfig:getTable()) do
            if v.openLv == curLevel then
                isOpen = true
            end
            if v.completeLv == curLevel then
                isGot = true
            end
            if curLevel < v.completeLv then break end
        end
        if isGot or not self._lastLevel then
            self:_computeTitle(curLevel,gender)
        end
        self._lastLevel = curLevel
    end
    return isGot,isOpen
end

---
-- 计算称号及应该使用的形象(gender 0无1男2女)
-- @function [parent=#UserTitleModel] _computeTitle
-- @param #UserTitleModel self
-- @param #number level
-- @param #number gender
function UserTitleModel:_computeTitle(level,gender)
    for k,v in ipairs(GameConfig.UserTitleConfig:getTable()) do
        if level >= v.completeLv then
            local avatarType
            local avatar
            if gender == 2 then
                avatarType = v.avatarType2
                avatar = v.avatar2
            else
                avatarType = v.avatarType
                avatar = v.avatar
            end
            if avatarType == 1 then
                self._curWeapon = avatar
            elseif avatarType == 2 then
                self._curAvatar = avatar
            elseif avatarType == 3 then
                self._curAvatar = avatar
                self._curWeapon = nil
            end
            self._curTitle = v.grade
        else
            break
        end
    end
end

---
-- 获得当前称号的id
-- @function [parent=#UserTitleModel] getTitleId
-- @param #UserTitleModel self
-- @return #number 
function UserTitleModel:getTitleId()
	return self._curTitle
end

---
-- 获得当前的avatar形象
-- @function [parent=#UserTitleModel] getAvatar
-- @param #UserTitleModel self
-- @return #number 
function UserTitleModel:getAvatar()
    return self._curAvatar
end

---
-- 获得当前的武器图片
-- @function [parent=#UserTitleModel] getWeapon
-- @param #UserTitleModel self
-- @return #number 
function UserTitleModel:getWeapon()
    return self._curWeapon
end

---
-- 等级对应的称号信息
-- @function [parent=#UserTitleModel] getTitleByLevel
-- @param #UserTitleModel self
-- @param #number level
-- @return #table
function UserTitleModel:getTitleByLevel(level)
    local tmpValue = GameConfig.UserTitleConfig:getData(1)
    for k,v in ipairs(GameConfig.UserTitleConfig:getTable()) do
        if level >= v.completeLv then
            tmpValue = v
        else
            break
        end
    end
    return tmpValue
end

---
-- 等级对应的称号信息(排行榜前三特殊处理)
-- @function [parent=#UserTitleModel] getTitle
-- @param #UserTitleModel self
-- @param #number level
-- @param #string userid
-- @return #table
function UserTitleModel:getTitle(level,userid)
    local tmpValue = {}
    for k,v in pairs(ch.RankListModel:getRankTop()) do
        if userid == v then
            tmpValue.icon = GameConst.RANK_TOP_TITLE[k].icon
            tmpValue.icon_b = GameConst.RANK_TOP_TITLE[k].icon_b
            tmpValue.name = GameConst.RANK_TOP_TITLE[k].name
            return tmpValue
        end
    end
    return self:getTitleByLevel(level)
end

---
-- 是否为排行榜前三名
-- @function [parent=#UserTitleModel] isRankTop
-- @param #UserTitleModel self
-- @param #string userid
-- @return #boolean
function UserTitleModel:isRankTop(userid)
    for k,v in pairs(ch.RankListModel:getRankTop()) do
        if userid == v then
            return true
        end
    end
    return false
end

---
-- 获得称号对应的avatat(0无1男2女)
-- @function [parent=#UserTitleModel] getAvatarByLevel
-- @param #UserTitleModel self
-- @param #number level 通过的关卡数，即最大关卡减一
-- @param #number gender
-- @return #string role,weapon
function UserTitleModel:getAvatarByLevel(level,gender)
    local roleName,weapon
    for k,v in ipairs(GameConfig.UserTitleConfig:getTable()) do
        if level >= v.completeLv then
            local avatarType
            local avatar
            if gender == 2 then
                avatarType = v.avatarType2
                avatar = v.avatar2
            else
                avatarType = v.avatarType
                avatar = v.avatar
            end
           if avatarType == 1 then
               weapon = avatar
           elseif avatarType == 2 then
                roleName = avatar
           elseif avatarType == 3 then
                roleName = avatar
               weapon = nil
           end
        else
            break
        end
    end
    return roleName,weapon
end

---
-- 获得称号对应的avatat(0无1男2女)
-- @function [parent=#UserTitleModel] getAvatarByTitle
-- @param #UserTitleModel self
-- @param #number title
-- @param #number gender
-- @return #string role,weapon
function UserTitleModel:getAvatarByTitle(title,gender)
    local level = GameConfig.UserTitleConfig:getData(title).completeLv
    return self:getAvatarByLevel(level,gender)
end

---
-- 是否开启新的阶段中
-- @function [parent=#UserTitleModel] isOpenNewStage
-- @param #UserTitleModel self
-- @return #bool 是否开启新的阶段中
function UserTitleModel:isOpenNewStage()
    local curLevel = ch.StatisticsModel:getMaxLevel() -1
    for _,v in ipairs(GameConfig.UserTitleConfig:getTable()) do
        if curLevel >= v.openLv and curLevel < v.completeLv then
            return true
        end
    end
    return false
end

---
-- 等级对应的新称号信息
-- @function [parent=#UserTitleModel] getNewTitleByLevel
-- @param #UserTitleModel self
-- @param #number level
-- @return #table
function UserTitleModel:getNewTitleByLevel(level)
    for k,v in ipairs(GameConfig.UserTitleConfig:getTable()) do
        if level >= v.openLv and level < v.completeLv then
            return v
        end
    end
    return GameConfig.UserTitleConfig:getData(1)
end

---
-- 是否要显示光效
-- @function [parent=#UserTitleModel] setShowEffect
-- @param #UserTitleModel self
-- @param #boolean isShow
function UserTitleModel:setShowEffect(isShow)
    self.showEffect = isShow
    self:_raiseDataChangeEvent(self.dataType.show)
end

---
-- 是否要显示光效
-- @function [parent=#UserTitleModel] getShowEffect
-- @param #UserTitleModel self
-- @return #boolean
function UserTitleModel:getShowEffect()
    return self.showEffect
end

return UserTitleModel