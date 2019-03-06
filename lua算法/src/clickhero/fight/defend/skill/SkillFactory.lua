---
-- 技能工厂
-- @module SkillFactory
local SkillFactory = {
}

---
-- 创建
-- @function [parent=#SkillFactory] create
-- @param #SkillFactory self
-- @param #number id
-- @return #table
function SkillFactory:create(id)
	if id == ch.DefendModel.skillId.ALZ then
        return ch.ALZSkill:create()
    elseif id == ch.DefendModel.skillId.CHS then
	    return ch.CHSSkill:create()
    elseif id == ch.DefendModel.skillId.HHS then
        return ch.HHSSkill:create()
    elseif id == ch.DefendModel.skillId.FSZF then
        return ch.FSZFSkill:create()
    elseif id == ch.DefendModel.skillId.YSCJ then
	    return ch.YSCJSkill:create()
    elseif id == ch.DefendModel.skillId.ZRJD then
	    return ch.ZRJDSkill:create()
	end
	return nil
end

return SkillFactory