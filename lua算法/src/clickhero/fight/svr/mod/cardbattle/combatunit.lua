
local CBaseObj = _M["mod/baseobj/baseobj"].CBaseObj
local SK_DATA = _M["mod/cardbattle/skdata"]
CombatUnit = CBaseObj:Class()
local sp_rate = 1000

function CombatUnit:OnNew(...)
  for i,nm in pairs(SK_DATA.att_name) do
    self[nm]= 0;
  end
  self.is_attacker = 0;-- 1攻击方， 0 防御方
  self.skills = {}; -- 技能
  self.buffs = {}; -- 身上的buff {id={buffs}}
  self.used_skills = {}; -- 使用过的技能，限制次数{id=num}
end

-- 添加技能ID
function CombatUnit:AddSkillID(skill_id)
    local skill = SK_DATA.card_skill[skill_id]
    table.insert(self.skills,skill); 
end

function CombatUnit:Init()
  self:CalSpAttr();
  for i,nm in pairs(SK_DATA.att_name) do
    self["base_"..nm] = self[nm];
  end
end

-- 计算特殊属性
function CombatUnit:CalSpAttr()
  self.csm = self.cs /sp_rate;
  self.defm = self.defence/(self.defence+sp_rate)
  self.dgm = self.dodge/(self.dodge+sp_rate)
  self.csd = 2
  self.tdg = 1
  self.hprate=self.hp/self.max_hp;
end

function CombatUnit:CalSpName(att_name)
  if att_name == "cs" then
    self.csm = self.cs /sp_rate;
  elseif att_name == "defence" then
    self.defm = self.defence/(self.defence+sp_rate)
  elseif att_name == "dodge" then
    self.dgm = self.dodge/(self.dodge+sp_rate)
  elseif att_name == "hp" or att_name == "max_hp" then 
    self.hprate=self.hp/self.max_hp;
  end
  --self.csd = 2
  
end

-- 打印属性
function CombatUnit:LogAttr(cur_round)
  local attr_info = {}
  for i,nm in pairs(SK_DATA.att_name) do
    attr_info[nm] = self[nm];
  end
  attr_info.buffs = self.buffs
  local battle = self.battle
  
  --log("testbattle","attr round="..cur_round..",turn="..battle.cur_turn..",is_attacker="..self.is_attacker..","..json.encode(attr_info))
end 

-- 回血显示
function CombatUnit:AddHP(round_eff,skill_id,hp)
  local battle = self.battle
  local uidx = battle.cur_uidx
  --log("testbattle","AddHP,round="..battle.cur_round..",uidx="..battle.cur_uidx..",skill_id="..skill_id..",hp="..hp)
  if hp == 0 then return end
 
  local round_event = battle.event_tb[battle.cur_round][uidx] or {}
  local recover_tb = round_event.recover or {}
  local tg_index = 1
  if self.is_attacker == 0 then
    tg_index = 2
  end
  local atk_hp = recover_tb[tg_index] or {}
  local sq = 1
  --if round_eff == 2 then
  --  sq = 3
  --end
  local atk_event = atk_hp[sq] or {}
  table.insert(atk_event,{["hp"]=hp,["id"]=skill_id})
  atk_hp[sq] = atk_event
  recover_tb[tg_index] = atk_hp
  round_event.recover = recover_tb
  battle.event_tb[battle.cur_round][uidx] = round_event
end 

-- 向客户端报告血量变化
function CombatUnit:ReportHPChange(round_eff,skill_id,target_rule,target_rate) 

  local add = 0
  local mul = 0
  if target_rule == 1 then
      add = add + target_rate/10000
  end
  if target_rule == 2 then
      mul = mul + target_rate/10000
  end
  local rc_hp = 0
  if mul ~= 0 then
    rc_hp = self["max_hp"] * mul
  end
  local pre_hp = self["hp"]
  local cur_hp = self["hp"] + rc_hp +add
  local add_hp = cur_hp - pre_hp
  self:AddHP(round_eff,skill_id, add_hp)
end

function CombatUnit:FixedHp(unit)
  unit.hp = unit.hp > 0 and unit.hp or 0
  unit.hp = unit.hp < unit.max_hp and unit.hp or unit.max_hp
end

function CombatUnit:FixedSpAttr(unit)
  for id=7,#SK_DATA.att_name do
    local nm = SK_DATA.att_name[id]
    unit[nm] = unit[nm] > 0 and unit[nm] or 0
  end
end

-- 计算所有属性
function CombatUnit:CalAllAttr(round_eff)
   
  local battle = self.battle
  local cur_turn = battle.cur_turn
  -- 计算所有属性加成
  for id,nm in pairs(SK_DATA.att_name) do
    local mul = 0;
    local add = 0;
    -- bug fixed 2016.0307
    -- 出手前的属性加成，累计到出手后中，每次出手前清理 
    if round_eff == 1 then
      self["pre_mul"..nm] = 0
      self["pre_add"..nm] = 0
    end
    --log("testbattle","att_name="..nm)
    for skid,sk_buffs in pairs(self.buffs) do
        for key,buff in pairs(sk_buffs.buffs) do
            --for i=1,3 do
                local target_attr = buff.target_attr--buff.sk["target_attr"..i]
                --log("testbattle","target_attr="..target_attr)
                --log("testbattle","target_attr2="..target_attr..",round_eff="..round_eff..",buff.round_eff="..buff.round_eff..",round="..battle.cur_round..",skid="..skid)
                if target_attr and target_attr > 0 and id == target_attr and round_eff == buff.round_eff then
                    --log("testbattle","target_attr2="..target_attr..",round_eff="..round_eff..",buff.round_eff="..buff.round_eff..",mul="..mul..",add="..add)
                    local target_rate = buff.target_rate --buff.sk["target_rate"..i]
                    local target_rule = buff.target_rule--buff.sk["target_rule"..i]
                    if nm == "hp" then -- 血量计算不能累计 
                      mul = 0;
                      add = 0;
                    end
                    if target_rule == 1 then
                        add = add + target_rate/10000
                    end
                    if target_rule == 2 then
                        mul = mul + target_rate/10000
                    end
                    --if nm == "hp" or nm == "max_hp" then
                    --  self:ReportHPChange(round_eff,skid,target_rule,target_rate)
                    --end
                    
                    --log("testbattle","target_attr3="..target_attr..",target_rate="..target_rate..",target_rule="..target_rule..",add="..add..",mul="..mul)

                    --log("testbattle","target_attr4 "..nm.."="..self[nm]..",add="..add..",mul="..mul)
                    if nm == "hp" then
                      
                       --local pre_hp = self[nm]
                      local rc_hp = 0
                      if mul ~= 0 then
                        rc_hp = self["max_hp"] * mul
                      end
                      local add_hp = rc_hp + add
                      self[nm] = self[nm]+ rc_hp +add;
                      self:FixedHp(self)
                      self:AddHP(round_eff,skid, add_hp)
                    elseif nm == "max_hp" then  -- 回复血量上限时也加血 
                      local pre_max_hp = self[nm]
                      self[nm] = self["base_"..nm]*(1+mul)+add;
                      local add_max_hp = self[nm] - pre_max_hp
                      self.hp = self.hp + add_max_hp
                      self:FixedHp(self)
                      self:AddHP(round_eff,skid, add_max_hp)
                    else
                      local pre_mul = self["pre_mul"..nm]
                      local pre_add = self["pre_add"..nm]
                      self[nm] = self["base_"..nm]*(1+(mul+pre_mul))+(add+pre_add);
                     
                      --local cur_hp = self[nm]
                      --local add_hp = cur_hp - pre_hp
                      --self:AddHP(round_eff,add_hp)
                    end
                    --log("testbattle","target_attr5 "..nm.."="..self[nm]..",add="..add..",mul="..mul)
                    --if id >=4 and id <= 6 then -- 基本属性计算后，需要计算特殊属性
                    --  self:CalSpAttr();
                    --end
                    self:CalSpName(nm)
                    self:FixedSpAttr(self)
              end
        end  
--        for key,buff in pairs(sk_buffs.buffs) do
          -- 是否删除
--          if buff.end_turn >= cur_turn then
--            sk_buffs.buffs[key] = nil
--          end
--        end
    end
    -- 记录出手前的属性加成
    if round_eff == 1 then
      self["pre_mul"..nm] = mul
      self["pre_add"..nm] = add
      --log("testbattle","buff:"..nm..",mul="..mul..",add="..add)
    end
    
    
  end
  --self:CalSpAttr();
  if self.hp <= 0 then
    return true
  end
end
