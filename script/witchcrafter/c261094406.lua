-- Witchcrafter Unit Appeler
local s, id = GetID()
Duel.LoadScript("witchcrafter-utility.lua")
function s.initial_effect(c)
  --link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),2,2,s.lcheck)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)

  -- Discard replace
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0)) -- Send Witchcrafter Spell from Deck to GY.
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_WITCHCRAFTER_REPLACE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetTargetRange(1,0)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(s.repcon)
  e1:SetValue(s.repval)
  e1:SetOperation(s.repop)
  c:RegisterEffect(e1)

  -- Special Summon
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1)) -- Special Summon Witchcrafter monster.
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1)
  e2:SetCost(aux.WitchcrafterDiscardCost)
  e2:SetTarget(s.sptg)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2)
end
s.listed_series={0x128}

-- different attributes for link summon
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentPropertyBinary(Card.GetAttribute,lc,sumtype,tp)
end

-- Discard replace
function s.repcfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function s.repcon(e)
  -- e is this replacement effect.
	return Duel.IsExistingMatchingCard(s.repcfilter,e:GetHandlerPlayer(),LOCATION_DECK,0,1,nil)
end
function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk)
  -- base = the card that has the replace effect.
  -- e = the card that activates the effect to discard.
	local c=e:GetHandler()
	return c:IsControler(tp) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x128) and not c:IsCode(base:GetCode())
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
  -- base = the card that has the replace effect.
  -- e = the card that activates the effect to discard.
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.repcfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

-- Special Summon
function s.spfilter(c,e,tp)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x128) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and
    Duel.GetLocationCount(tp,LOCATION_MZONE) > 0 end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
  if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
    --Cannot be used as link material
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(3312)
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(1)
    tc:RegisterEffect(e1)
  end
  Duel.SpecialSummonComplete()
end
