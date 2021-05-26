--円融魔術
--Magicalized Fusion
local s,id=GetID()
Duel.LoadScript("witchcrafter-utility.lua")
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),s.matfilter,s.fextra,Fusion.BanishMaterial)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
--function s.fusfilter(c,tp)
	--Debug.Message("filter " .. tostring(c:GetCode()) .. ", player " .. tostring(tp) )
	--if c:IsRace(RACE_SPELLCASTER) then
		--aux.RegisterExtraMatEffect(c,id,tp,LOCATION_GRAVE)
	--end
	--return c:IsRace(RACE_SPELLCASTER)
--end
function s.matfilter(c)
	return c:IsAbleToRemove() and (c:IsOnField() or c:IsLocation(LOCATION_GRAVE))
end
function s.checkmat(tp,sg,fc)
  return not sg:IsExists(aux.STSelfCheckFilter(id),1,nil) -- cannot use self as mat in ST Zone.
		and aux.STRestrictMatLoc(LOCATION_SZONE+LOCATION_GRAVE,sg) -- can only use S/T mats from field and GY.
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		-- if affected by SpirElim, you can still banish the S/Ts from GY, therefore the checkmat will not exclude grave materials.
		return Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil),s.checkmat
	end
	return nil,s.checkmat
end
