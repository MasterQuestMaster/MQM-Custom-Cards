-- Witchcrafter Teamwork
local s, id = GetID()
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)

  -- Special Summon
  local e2 = Effect.CreateEffect(c)
  e2:SetDescription(1120) -- Special Summon
  e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetCountLimit(1,id)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(s.spcon)
  e2:SetTarget(s.sptg)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2)

  -- Add Witchcrafter monster
  local e3 = Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,0)) -- Add Witchcrafter monster
  e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
  e3:SetType(EFFECT_TYPE_QUICK_O)
  e3:SetCode(EVENT_FREE_CHAIN)
  e3:SetCountLimit(1,id+2)
  e3:SetRange(LOCATION_GRAVE)
  e3:SetCost(aux.bfgcost)
  e3:SetTarget(s.thtg)
  e3:SetOperation(s.thop)
  c:RegisterEffect(e3)
end
s.listed_series={0x128}
-- Special Summon
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
  local ph=Duel.GetCurrentPhase()
  return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.spfilter(c,e,tp,lv)
  return c:IsSetCard(0x128) and c:HasLevel() and c:GetLevel() < lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.remfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x128) and c:IsAbleToDeck()
    and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel())
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.remfilter(chkc,e,tp) end

  --Debug.Message("---")
  --Debug.Message(Duel.IsExistingTarget(s.remfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp))
  --Debug.Message(Duel.GetLocationCount(tp,LOCATION_MZONE) > 0)
  if chk==0 then return Duel.IsExistingTarget(s.remfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) and
    Duel.GetLocationCount(tp,LOCATION_MZONE) > 0 end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local tg=Duel.SelectTarget(tp,s.remfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
  Duel.SetTargetParam(tg:GetFirst():GetLevel())
  Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
  if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT) > 0
    and Duel.GetLocationCount(tp,LOCATION_MZONE) > 0 then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
      local sg = Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
      if #sg > 0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
      end
  end
end
-- Add Witchcrafter monster
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x128) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
