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

-- For Fusion Spells with S/T materials, make it so you can't use the Fusion Spell as material.
function Auxiliary.STSelfCheckFilter(id)
  return function(c)
  	-- cannot use this fusion spell as mat if it's in your S/T Zone face-up.
    return c:IsCode(id) and c:IsFaceup() and c:IsLocation(LOCATION_SZONE)
  end
end
