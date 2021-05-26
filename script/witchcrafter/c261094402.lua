-- Witchcrafter Fusion
local s, id = GetID()
Duel.LoadScript("witchcrafter-utility.lua")
function s.initial_effect(c)
  --Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),nil,s.fextra,nil,nil,s.stage2)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)

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
end
s.listed_series={0x128}
--function s.fusfilter(c,tp)
	--if c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x128) and c.has_st_mat then
	--	aux.RegisterExtraMatEffect(c,id,tp,LOCATION_DECK)
	--end
	--return c:IsRace(RACE_SPELLCASTER)
--end
function s.checkmat(tp,sg,fc)
  return (fc:IsSetCard(0x128) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK))
		and not sg:IsExists(aux.STSelfCheckFilter(id),1,nil)
		and aux.STRestrictMatLoc(LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,sg)
		--and not sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) -- deny GY material from extra mat effect.
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,0x128),s.checkmat
end
function s.stage2(e,tc,tp,mg,chk)
  -- Summon restriction
  if chk==2 then -- 1-> if summon success, 2-> anyway?
    if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetDescription(aux.Stringid(id,1))
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
      e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
      e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end
end
function s.splimit(e,c)
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
