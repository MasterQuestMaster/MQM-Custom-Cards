-- Witchcrafter Instructors
local s, id = GetID()
Duel.LoadScript ("witchcrafter-utility.lua")
function s.initial_effect(c)
  -- Fusion materials
  c:EnableReviveLimit()
  Fusion.AddProcMix(c,true,true,Fusion.IsMonsterFilter(aux.FilterBoolFunctionEx(Card.IsSetCard, 0x128)),s.matfilter)
  Fusion.AddSpellTrapRep(c)
  c:SetSPSummonOnce(id)

  -- TODO: test reviving with copying Holiday because it just did nothing that one duel.

  -- Copy a Witchcrafter Spell effect
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
  e1:SetCondition(s.copycon)
  e1:SetTarget(s.copytg)
  e1:SetOperation(s.copyop)
  c:RegisterEffect(e1)

  -- Disable S/T
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_DISABLE)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetCountLimit(1)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCost(s.discost)
  e2:SetTarget(s.distg)
  e2:SetOperation(s.disop)
  c:RegisterEffect(e2)

  -- Global check keeps track of spell activated this turn
  aux.GlobalCheck(s,function()
    -- two lists of spells cast this turn, 1 for each player.
    s[0] = {}
    s[1] = {}
    aux.AddValuesReset(function()
      s[0]={}
      s[1]={}
    end)
    -- register spell activations.
    local ge1=Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_CHAINING)
    ge1:SetOperation(s.regop)
    Duel.RegisterEffect(ge1,0)
  end)
end
s.listed_series={0x128}
s.material_setcode={0x128}
--s.has_st_mat = true

function s.matfilter(c)
  return c:IsSetCard(0x128) and c:IsType(TYPE_SPELL)
end

-- Copy Witchcrafter Spell
function s.copycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.tgfilter(c,tp)
  -- Activatable Witchcrafter spell which is not in the "activated list"
  return c:IsSetCard(0x128) and (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY) and c:CheckActivateEffect(false,true,false)~=nil
    and (not s[tp] or #s[tp] == 0 or not c:IsCode(table.unpack(s[tp])))
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(c) end
  if chk == 0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end

  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local tg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if not tc or not tc:IsRelateToEffect(e) then return end
  -- copy from Darklord Ixchel
  local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	if not te then return end
	local tg=te:GetTarget()
	local op=te:GetOperation()
  if tg then
    -- clear current target (the spell) so that GetFirstTarget of the spell's tg function works correctly.
    Duel.ClearTargetCard()
    tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1)
  end
	Duel.BreakEffect()
	tc:CreateEffectRelation(te)
	Duel.BreakEffect()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	for etc in aux.Next(g) do
		etc:CreateEffectRelation(te)
	end
	if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
	tc:ReleaseEffectRelation(te)
	for etc in aux.Next(g) do
		etc:ReleaseEffectRelation(te)
	end
end

-- Disable S/T
function s.cfilter(c)
  return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
  local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  if #g > 0 then
    Duel.Remove(g,POS_FACEUP,REASON_COST)
  end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
  -- disfilter: checks if a card's effect can be negated.
  if chk==0 then return Duel.IsExistingMatchingCard(aux.disfilter1,tp,0,LOCATION_SZONE,1,nil) end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetMatchingGroup(aux.disfilter1,tp,0,LOCATION_SZONE,nil)
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
  -- Witchcrafter spell was activated
	if re:GetHandler():IsSetCard(0x128) and rp==tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
    --Debug.Message("tp: ".. tostring(tp) ..", rp: " .. tostring(rp) .. ", activated " .. tostring(re:GetHandler():GetCode()))
    -- keep track for the activating player by adding to the global check list.
    table.insert(s[rp],re:GetHandler():GetCode())
	end
end
