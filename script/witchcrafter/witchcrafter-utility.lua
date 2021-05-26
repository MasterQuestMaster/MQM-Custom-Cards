-- Fusion with S/T
Fusion.AddSpellTrapRep=(function()
    local codes={}
    local ge=Effect.GlobalEffect()
    ge:SetType(EFFECT_TYPE_FIELD)
    ge:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
    ge:SetTargetRange(LOCATION_SZONE+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,LOCATION_SZONE+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
    ge:SetTarget(function(e,cc) return cc:IsType(TYPE_SPELL+TYPE_TRAP) end)
    ge:SetValue(value or function(e,cc) if not cc then return false end return cc:IsOriginalCode(table.unpack(codes)) end)
    Duel.RegisterEffect(ge,0)
    return function(c)
        table.insert(codes,c:GetOriginalCode())
    end
end)()

local Witchcrafter={}

-- loc: The locations
-- sg: Current material group for fusion summon, from checkmat.
function Auxiliary.STRestrictMatLoc(loc,sg)
  local allLoc = LOCATION_SZONE+LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND
  -- check if any cards exist that are not in "loc". if so, return false.
  return not sg:IsExists(Witchcrafter.STMatFilter,1,nil,allLoc - loc)
end

function Witchcrafter.STMatFilter(c,loc)
  return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsLocation(loc)
end

-- fc: Fusion Card (Monster)
-- fusionspellcode: Code of Fusion Spell
-- loc: Location of Extra Mat
-- extracon: Additional condition for gaining extra location.
-- [needs has_st_mat on fusion card.]
--[[function Auxiliary.RegisterExtraMatEffect(fc,fscode,tp,loc)
  if fc.has_st_mat and Duel.GetFlagEffect(tp,fscode)==0 then
    Debug.Message("Register fs " .. tostring(fscode) .. ", fc " .. tostring(fc:GetCode()) .. ', tp ' .. tostring(tp) .. ', loc ' .. tostring(loc))
		local ge=Effect.CreateEffect(fc)
		ge:SetType(EFFECT_TYPE_FIELD)
		ge:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		ge:SetTargetRange(loc,0)
		ge:SetTarget(function(e,cc) return cc:IsType(TYPE_SPELL+TYPE_TRAP) end)
		ge:SetReset(RESET_CHAIN) -- the reset is the problem with why mag fus cannot fuse from gy without existing mats on hand/field.
		ge:SetValue(value or function(e,cc) if not cc then return false end return cc:IsOriginalCode(fc:GetOriginalCode()) end)
		Duel.RegisterEffect(ge,tp)

    Duel.RegisterFlagEffect(tp,fscode,RESET_CHAIN,0,0)
		--fc:RegisterFlagEffect(fusionspellcode,RESET_CHAIN,0,0)
	end
end]]--

function Auxiliary.STSelfCheckFilter(id)
  return function(c)
  	-- cannot use this fusion spell as mat if it's in your S/T Zone face-up.
    return c:IsCode(id) and c:IsFaceup() and c:IsLocation(LOCATION_SZONE)
  end
end

--Discard cost for Witchcrafter monsters, supports the replacements from the Continuous Spells
local CARD_WC_APPELER = 261094406
function Witchcrafter.DiscardSpell(c)
	return c:IsDiscardable() and c:IsType(TYPE_SPELL)
end
function Witchcrafter.DiscardCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Witchcrafter.DiscardSpell,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Witchcrafter.DiscardSpell,1,1,REASON_COST+REASON_DISCARD)
end
Auxiliary.WitchcrafterDiscardCost=
  Auxiliary.CostWithReplace(Auxiliary.CostWithReplace(Witchcrafter.DiscardCost,CARD_WC_APPELER),EFFECT_WITCHCRAFTER_REPLACE)

function Witchcrafter.ReleaseCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
Auxiliary.WitchcrafterDiscardAndReleaseCost=
  Auxiliary.CostWithReplace(Auxiliary.CostWithReplace(Witchcrafter.DiscardCost,CARD_WC_APPELER),EFFECT_WITCHCRAFTER_REPLACE,nil,Witchcrafter.ReleaseCost)

function Witchcrafter.repcon(e)
	return e:GetHandler():IsAbleToGraveAsCost()
end
function Witchcrafter.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	local c=e:GetHandler()
	return c:IsControler(tp) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x128)
end
function Witchcrafter.repop(id)
	return function(base,e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,0,id)
		Duel.SendtoGrave(base:GetHandler(),REASON_COST)
	end
end
function Auxiliary.CreateWitchcrafterReplace(c,id)
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetCode(EFFECT_WITCHCRAFTER_REPLACE)
	e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e:SetTargetRange(1,0)
	e:SetRange(LOCATION_SZONE)
	e:SetCountLimit(1,id)
	e:SetCondition(Witchcrafter.repcon)
	e:SetValue(Witchcrafter.repval)
	e:SetOperation(Witchcrafter.repop(id))
	return e
end
