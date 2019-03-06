
local CBaseObj = _M["mod/baseobj/baseobj"].CBaseObj
local CRandom = _M["mod/cardbattle/random"].CRandom
local CombatUnit = _M["mod/cardbattle/combatunit"].CombatUnit
local SK_DATA = _M["mod/cardbattle/skdata"]

function log_t(mod, formatstr,...)
    --local log_str = string.format(formatstr,...)
    --log(mod,log_str);
end

Battle = CBaseObj:Class()

local MAX_ROUND = 30 --最大回合数
local FIRST_RATE = 0.5 -- 第一次出手修正 

-- 战斗事件
local bt_event = {
[1] = function (...) return on_bt_start(...) end, --1开局时
[2] = function (...) return on_atk_start(...) end, --2攻击时
[3] = function (...) return on_hit(...) end, --3命中时
[4] = function (...) return on_behit(...) end, --4被命中时
[5] = function (...) return on_mc(...) end, --5暴击时
[6] = function (...) return on_bemc(...) end, --6被暴击时
[7] = function (...) return on_dodge(...) end, --7闪避时
[8] = function (...) return on_bedodge(...) end, --8被闪避时
[9] = function (...) return on_die(...) end, --9濒死时"
[10] = function (...) return on_round_end(...) end, --10回合结束时"
}

-- 事件时间
local event_sq =
{
[1] = 4,
[2] = 1,
[3] = 2,
[4] = 2,
[5] = 2,
[6] = 2,
[7] = 2,
[8] = 2,
[9] = 3,
[10] = 3,
} 

-- 调用事件
function call_bt_event(battle,unit,event_id,...)
    for i,skill in  pairs(unit.skills) do
        if skill.act_event == event_id then
            local event_func = bt_event[event_id];
            if event_func then
                battle.event_id = event_id
                event_func(battle,unit,skill,...)
            end
        end

    end
    
end



-- 默认处理
function on_default_event(battle,src_unit,skill,des_unit)
      -- 属性值判断
    local target_att
    if skill.act_attr == 1 then
        target_att = src_unit;
    end
    if skill.act_attr == 2 then
        target_att = des_unit;
    end
    local att_val_ok = true;
    if skill.con_attr > 0 then
        local val = target_att[SK_DATA.att_name[skill.con_attr]]
        local judge_type = skill.judge_type;
        local des_val = skill.con_attr_val/10000
        if judge_type == 1 then
            if val <= des_val then
                att_val_ok = true;
            else
                att_val_ok = false;
            end
        end
        if judge_type == 2 then
            if val >= des_val then
                att_val_ok = true;
            else

                att_val_ok = false;
            end
        end
    end
    -- 使用次数限制
    local sk_not_limit = true;
    local used_time = src_unit.used_skills[skill.id] or 0;
    if skill.sk_limit and skill.sk_limit > 0  then
        
        if  used_time >= skill.sk_limit  then
            sk_not_limit = false;
        end
    end

    --判断是否能加上
    if can_use_sk(battle,src_unit,skill,des_unit) and att_val_ok and sk_not_limit then
        battle:AddUnitBuff(src_unit,skill,src_unit,des_unit);
        used_time = used_time + 1;
        src_unit.used_skills[skill.id] = used_time;
    end
end

function on_bt_start(battle,src_unit,skill,des_unit)
   on_default_event(battle,src_unit,skill,des_unit)
end

function on_atk_start(battle,src_unit,skill,des_unit)
    on_default_event(battle,src_unit,skill,des_unit)  
end
function on_hit(battle,src_unit,skill,des_unit)
   on_default_event(battle,src_unit,skill,des_unit)
end
function on_behit(battle,src_unit,skill,des_unit)
    on_default_event(battle,src_unit,skill,des_unit)
end
function on_mc(battle,src_unit,skill,des_unit)
    on_default_event(battle,src_unit,skill,des_unit)
end
function on_bemc(battle,src_unit,skill,des_unit)
    on_default_event(battle,src_unit,skill,des_unit)
end
function on_dodge(battle,src_unit,skill,des_unit)
    on_default_event(battle,src_unit,skill,des_unit)
end
function on_bedodge(battle,src_unit,skill,des_unit)
    on_default_event(battle,src_unit,skill,des_unit)
end
function on_die(battle,src_unit,skill,des_unit)
    on_default_event(battle,src_unit,skill,des_unit)
end

function on_round_end(battle,src_unit,skill,des_unit)
    on_default_event(battle,src_unit,skill,des_unit)
end

function can_use_sk(battle,unit,skill)
    --判断是否能加上
    local can_use = false;
    local cur_rand = battle:Rand();
    if cur_rand <= skill.rand then
    --[[
        local sk_buffs = unit.buffs[skill.id] or {sk_limit=0,buffs={}};
        if skill.sk_limit and sk_buffs.sk_limit > 0 then
           if skill.sk_limit <  sk_buffs.sk_limit then -- 超出技能次数限制
                can_use = true;
           end
        else
            can_use = true;
        end
    --]]
        can_use = true;
    end
    

    return can_use;
end

--使用技能
function Battle:AddUnitBuff(unit,skill,src_unit,des_unit)
    
    -- 技能生效标记，用于客户端表现，只加一次 
    local clt_buff_add = false
    for i=1,3 do
        local target_unit 
        local target_type = skill["target"..i]
        if target_type and target_type > 0 then
          if target_type == 1 then
              target_unit = src_unit;
          end
          if target_type == 2 then
              target_unit = des_unit;
          end
          local sk_buffs = target_unit.buffs[skill.id] or {sk_limit=0,buffs={}};
          local buff = {}
          buff.id = skill.id
          buff.act_event = skill.act_event
          buff.target_attr = skill["target_attr"..i];
          buff.target_rate = skill["target_rate"..i];
          buff.target_rule = skill["target_rule"..i];
          local used_turn = skill.used_round; -- 出手次数 
          if  skill.used_round < 0 then
              used_turn = MAX_ROUND * 2;
          end
          -- 特殊修正进场加血，只有一个回合 
--          if skill.act_event == 1 then
--            if buff.target_attr == 2 then
--              used_turn = 1
--            end
--          end
          --
          -- 特殊修正，光辉之力加血，每次持续一次 
          if skill.id == 23 then
            if buff.target_attr == 2 then
              used_turn = 1
            end
          end
          if skill.id == 24 then
             used_turn = used_turn+1
          end
          if skill.id == 4 then
             used_turn = used_turn+1
          end

          buff.end_turn = self.cur_turn + used_turn;
          buff.round_eff =  skill["target_eff"..i]; --skill.round_eff
          local replace = skill["replace"..i] or 0--skill.replace;
          local can_add = false;
          if replace == 0 then   -- 不叠加直接覆盖
              --sk_buffs.buffs = {}
              for index_buff,used_buff in pairs(sk_buffs.buffs) do
                if used_buff.target_attr == buff.target_attr then
                  sk_buffs.buffs[index_buff] = nil
                  break
                end
              end
              can_add = true;
          end
          if replace < 0 then
               can_add = true;
          end
          if replace > 0 then
              local same_attr = 0
              for index_buff,used_buff in pairs(sk_buffs.buffs) do
                if used_buff.target_attr == buff.target_attr then
                  same_attr = same_attr + 1
                end
              end
              if same_attr < replace then
                   can_add = true;
              end
          end
          --local can_add = true
          if can_add then
              if not clt_buff_add then
                local uidx = self.cur_uidx
                local round_event = self.event_tb[self.cur_round][uidx] or {}
                local skill_tb = round_event.skill or {}
                local tg_index = 1
                if unit.is_attacker == 0 then
                  tg_index = 2
                end
                local atk_sk = skill_tb[tg_index] or {}
                local sq = event_sq[self.event_id]
                local atk_event = atk_sk[sq] or {}
                table.insert(atk_event,{id=skill.id})
                atk_sk[sq] = atk_event
                skill_tb[tg_index] = atk_sk
                round_event.skill = skill_tb
                self.event_tb[self.cur_round][uidx] = round_event
                --log("testbattle","round_event="..json.encode(round_event))
                --log("testbattle","addbuff,uidx="..uidx..",event_tb="..tostring(self.event_tb[self.cur_round])..","..json.encode(self.event_tb[self.cur_round]))
                clt_buff_add = true
              end
              table.insert(sk_buffs.buffs,buff);
              target_unit.buffs[skill.id] = sk_buffs;
          end
        end
    end
end

function Battle:OnNew(...)

  self.round_limit = MAX_ROUND; -- 总回合数
  self.cur_round = 0; -- 回合，一个回合2个turn 
  self.cur_turn = 0; -- 出手 
  self.uarray = {} -- 战斗单元 
  self.m_random = CRandom:New(100);
  self.win = 0; -- 1 攻击者胜利，0 失败
  self.event_tb = {}
end


function Battle:Init()

end

-- 随机
function Battle:Rand()
  local rand = self.m_random:nextInt()%(10000+1);
  --log("testbattle","Rand(),cur_round="..self.cur_round..","..",rand="..rand)
   return  rand
end

-- 设置随机数种子
function Battle:SetRandSeed(seed)
    self.m_random = CRandom:New(seed);
end

-- 添加战斗单元
function Battle:AddUnit(unit)
    unit.battle = self; -- 当前的战斗场景 
    if unit.is_attacker == 1 then
        table.insert(self.uarray ,unit);
    else
        table.insert(self.uarray ,1,unit);
    end
    
end

-- 设置客户端接收事件表
function Battle:SetEventTb(event_tb)
    self.event_tb = event_tb;
end

-- 计算战斗
function Battle:Fight()
    local cur_round = 0;
    for cur_round=1, self.round_limit do
        local round_rp ,ret = self:FightRound(cur_round) ;
        if ret then
          break;
        end
    end
end

-- 每回合运算
function Battle:FightRound(cur_round)
    self.cur_round = cur_round;
    self.event_tb[cur_round]={};
    self.cur_uidx = 0
    local n = #self.uarray;
    for i,unit in pairs(self.uarray) do
        self.cur_uidx = self.cur_uidx+1
        --self:ClearNoUseBuffs(unit);
        if cur_round == 1 then
            call_bt_event(self,unit,1,unit);
        end
        --unit:CalAllAttr(1);
    end
    self.cur_uidx = 0
    local ret 
    for _,src_unit in pairs(self.uarray) do
        --log("testbattle","round="..cur_round..","..json.encode(src_unit))
        --src_unit:LogAttr(cur_round)
        self.cur_uidx = self.cur_uidx+1
        for _,des_unit in pairs(self.uarray) do
           if src_unit.is_attacker ~= des_unit.is_attacker then
                self.cur_turn = self.cur_turn + 1
                self:ClearNoUseBuffs(src_unit)
                self:ClearNoUseBuffs(des_unit)
                src_unit:LogAttr(cur_round)
                des_unit:LogAttr(cur_round)
                ret = self:CalDamage(src_unit,des_unit)
                
                if ret then
                  if src_unit.hp <= 0 then -- 处理濒死效果 
                    self:ProcessDeadBuff(src_unit)
                  end
                  if des_unit.hp <= 0 then
                    self:ProcessDeadBuff(des_unit)
                  end
                  if self:ProcessResult() then
                    return self.event_tb[self.cur_round], true;
                  end
                end
               
                --src_unit:CalAllAttr(0);
                
           end 
        end
    end
   
    return self.event_tb[self.cur_round],false
end

-- 计算伤害
function Battle:CalDamage(src_unit,des_unit)
    -- 计算属性
    --src_unit:CalAllAttr();
    --des_unit:CalAllAttr();
    -- 判断是否闪避
    local uidx = self.cur_uidx
    local round_event = self.event_tb[self.cur_round][uidx]
    if not round_event then
      round_event = {}
      self.event_tb[self.cur_round][uidx] = round_event
    end
    local cal_ret = false
    --cal_ret = des_unit:CalAllAttr(2); -- 伤害后结算
    --log("testbattle","damage,uidx="..uidx..",round_event="..json.encode(round_event))
    --log("testbattle","CalDamage,round="..self.cur_round..",turn="..self.cur_turn..","..des_unit.dgm)
    
    local rand_dodge = self:Rand();
    local des_dgm = des_unit.dgm * 10000
    if rand_dodge <= des_dgm then -- 对方闪避
        call_bt_event(self,src_unit,8,des_unit);
        call_bt_event(self,des_unit,7,src_unit);
        round_event.isDodge = true;
        call_bt_event(self,src_unit,10,des_unit);
        cal_ret = src_unit:CalAllAttr(1); -- 立即生效，伤害前结算
        if cal_ret then return true end -- 立即结算死亡
        cal_ret = des_unit:CalAllAttr(1); -- 立即生效，伤害前结算
        if cal_ret then return true end -- 立即结算死亡
        cal_ret = src_unit:CalAllAttr(2); -- 伤害后结算
        if cal_ret then return true end -- 立即结算死亡
        cal_ret = des_unit:CalAllAttr(2); -- 伤害后结算
        if cal_ret then return true end -- 立即结算死亡
        return true;
    end
    
    call_bt_event(self,src_unit,3,des_unit);
    call_bt_event(self,des_unit,4,src_unit);
    
    -- 判断是否暴击
    local rand_cs = self:Rand();
    local cur_csm = src_unit.csm * 10000
    local cs = 1.0;
    local isCS = false
    if rand_cs <= cur_csm then 
    --if true then
        call_bt_event(self,src_unit,5,des_unit);
        call_bt_event(self,des_unit,6,src_unit);
        --cs = src_unit.csd
        round_event.isCrit = true;
        isCS = true
    end
    call_bt_event(self,src_unit,2,des_unit);
    
    cal_ret = src_unit:CalAllAttr(1); -- 立即生效，伤害前结算 
    if cal_ret then return true end -- 立即结算死亡 
    cal_ret = des_unit:CalAllAttr(1); -- 立即生效，伤害前结算
    if cal_ret then return true end -- 立即结算死亡
    if isCS then
      cs = src_unit.csd
    end
    -- 计算伤害
    local damage = src_unit.damage * (1-des_unit.defm)*cs
    --log("testbattle","damage1="..damage..",cs="..cs..",cur_round="..self.cur_round)
    damage = damage * (src_unit.tdg) -- 潜在伤害修正 
    if self.cur_round == 1 and self.cur_uidx == 1 then -- 第一次出手修正 
       damage = damage * FIRST_RATE
    end
    if damage < 0 then
      --log("error","CalDamage damage error:"..damage)
      damage = 0
    end
    --log("testbattle","damage2="..damage..",tdg="..src_unit.tdg..",cur_round="..self.cur_round)
    round_event.harm = damage;
    des_unit.hp = des_unit.hp - damage;
    des_unit.hprate=des_unit.hp/des_unit.max_hp; -- 血量比变化
    call_bt_event(self,src_unit,10,des_unit);
    if des_unit.hp < 0 then
        des_unit.hp = 0;   -- 不一定会死，还有濒死技能 
        call_bt_event(self,des_unit,9,src_unit);
        return true
    end
    cal_ret = src_unit:CalAllAttr(2); -- 伤害后结算
    if cal_ret then return true end -- 立即结算死亡
    cal_ret = des_unit:CalAllAttr(2); -- 伤害后结算
    if cal_ret then return true end -- 立即结算死亡
    
    --log("testbattle","CalDamage2,round="..self.cur_round..",turn="..self.cur_turn..","..des_unit.dgm)
    --self.event_tb[self.cur_round][uidx] = round_event
    
    return true  -- 每个回合都结算 
   -- log("testbattle","damage,event_tb="..tostring(self.event_tb[self.cur_round])..","..json.encode(self.event_tb[self.cur_round]))
end

-- 清理无效的buff
function Battle:ClearNoUseBuffs(unit)
    for skid,sk_buffs in pairs(unit.buffs) do
        for i,buff in pairs(sk_buffs.buffs) do
            if self.cur_turn >= buff.end_turn  then
                sk_buffs.buffs[i] = nil
                -- 除了血量恢复其它属性
                if buff.target_attr > 0 and buff.target_attr ~= 2 then
                  local nm = SK_DATA.att_name[buff.target_attr]
                  unit[nm] = unit["base_"..nm]
                end
            end    
        end  
    end
end

-- 处理死亡buff
function Battle:ProcessDeadBuff(unit)
  for skid,sk_buffs in pairs(unit.buffs) do
        for i,buff in pairs(sk_buffs.buffs) do
            if buff.act_event == 9  then
                unit:CalAllAttr(2)
                return 
            end
        end
  end
end 

-- 处理结果
function Battle:ProcessResult()
    local atker_win = 0;
    local defer_win = 0;
    local n = #self.uarray;
    for i,unit in pairs(self.uarray) do
       if unit.is_attacker == 1 then
          if unit.hp > 0 then
            atker_win = atker_win +1
          end

       else
          if unit.hp > 0 then
            defer_win = defer_win +1
          end
       end
    end
    if defer_win == 0 then
        self.win =1;
        self.event_tb[self.cur_round].win = 1;
        return true;
    end
    if atker_win == 0 then
        self.win = 0;
        self.event_tb[self.cur_round].win = 0;
        return true;
    end
    if self.cur_round >= MAX_ROUND then
        self.win = 0;
        self.event_tb[self.cur_round].win = 0;
        return true;
    end

    return false;
end

function Battle:GetUnitFromData(unit_data)
  local unit = CombatUnit:New()
  for _,nm in pairs(SK_DATA.att_name) do
    if unit_data.attr[nm] then
      unit[nm] = unit_data.attr[nm]
    end
  end
  for j=1,5 do
    local sk_data = unit_data.sk[j]
    if sk_data and sk_data.skid then
      unit:AddSkillID(sk_data.skid);
    end
  end
  
  return unit
  
end

-- 创建战斗
-- 通过战斗数据创建战斗对象
--[[ 
battle_data= {randomSeed = 20,attacker = {},defender = {},fightType = 1,}  - 1竞技场战斗
  其中 attacker,defender = 
  {    -- 初始化战斗数据 格式
        role = {
                   maxLevel = 89,
                   name = "王的男人",
                   fid = 25001 -- 当前侍宠id ，没有为空
                },
         attr={
           "hp" = 0, --1当前血量
           "max_hp"=0, --2最大血量
           "damage"=0, -- 3攻击
           "cs"=0,--4暴击
           "defence"=0,--5防御
           "dodge"=0,--6闪避
   }，
   sk={{id=20005,l=16},...}
     }

用法:
  local battle =  Battle:CreateBattle(battle_data)
  battle:Fight()
  local report = battle:GetBattleReport() 
 --]]
function  Battle:CreateBattle(battle_data)
    local battle = Battle:New();
    
    if not battle_data.randomSeed then -- 没有设置随机种子，就自动设置一个 
      battle_data.randomSeed = math.random(1,10000)
    end
    battle:SetRandSeed(battle_data.randomSeed)
    local unit_attacker = battle:GetUnitFromData(battle_data.attacker)
    unit_attacker.is_attacker = 1
    unit_attacker:Init();
    battle:AddUnit(unit_attacker);

    local unit_defender = Battle:GetUnitFromData(battle_data.defender)
    unit_defender.is_attacker = 0
    unit_defender:Init();
    battle:AddUnit(unit_defender);
    
    battle:Init();
    battle.battle_data = battle_data
    return battle

end

-- 得到战报
function Battle:GetBattleReport()
  self.battle_data.f = "card"
  self.battle_data.win = self.win
  return self.battle_data
end 
