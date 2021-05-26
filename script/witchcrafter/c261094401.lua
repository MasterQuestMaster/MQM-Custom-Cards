-- Witchcrafter Command
local s, id = GetID()
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_POSITION)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
  e1:SetCountLimit(1,id)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)

  --Add to hand
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0)) -- Add to hand
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_PHASE+PHASE_END)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1,id)
  e2:SetCondition(s.thcon)
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)

  --act in hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
  e3:SetRange(LOCATION_HAND)
	c:RegisterEffect(e3)
end
s.listed_series = {0x128}

function s.tgfilter(c)
  return c:IsFaceup() and c:IsCanTurnSet() and not c:IsRace(RACE_SPELLCASTER)
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
  if chk == 0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
  local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)

  local c=e:GetHandler()
  Debug.Message("hastype: " .. tostring(e:IsHasType(EFFECT_TYPE_ACTIVATE)))
  Debug.Message("status: " .. tostring(c:IsStatus(STATUS_ACT_FROM_HAND)))
  Debug.Message("prev fd: " .. tostring(c:IsPreviousPosition(POS_FACEDOWN)))
  Debug.Message("opp turn: " .. tostring(Duel.GetTurnPlayer() ~= tp))
  local acthand = e:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsStatus(STATUS_ACT_FROM_HAND)
    and not (c:IsPreviousPosition(POS_FACEDOWN) and POS_FACEDOWN) and Duel.GetTurnPlayer() ~= tp or 0

  if acthand then e:SetLabel(1) else e:SetLabel(0) end
  Debug.Message(e:GetLabel())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
  local acthand=e:GetLabel()
  if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
  if acthand==1 then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1)) -- Cannot Special Summon, except Spellcasters.
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
    Duel.RegisterEffect(e1,tp)
  end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_SPELLCASTER)
end

-- Add to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x128),tp,LOCATION_MZONE,0,1,nil) and Duel.GetTurnPlayer()==tp
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,tp,REASON_EFFECT)
	end
end
