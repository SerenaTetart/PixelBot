--Variables
local LastTarget = 0
local DrinkingBuff = ""

HealingTouchRank = 1 HealingTouchValue = {} HealingTouchLevel = {1, 8, 14, 20, 26, 32, 38, 44, 50, 56, 60}
RejuvenationRank = 1 RejuvenationValue = {} RejuvenationLevel = {4, 10, 16, 22, 28, 34, 40, 46, 52, 58, 60}
RegrowthRank = 1 RegrowthValue = {} RegrowthLevel = {12, 18, 24, 30, 36, 42, 48, 54, 60}
TranquilityRank = 1 TranquilityValue = {} TranquilityLevel = {30, 40, 50, 60}

--Texture
MarkWildTexture = "Interface\\Icons\\Spell_Nature_Regeneration"
ThornsTexture = "Interface\\Icons\\Spell_Nature_Thorns"
MoonfireTexture = "Interface\\Icons\\Spell_Nature_StarFall"
FearieFireTexture = "Interface\\Icons\\Spell_Nature_FaerieFire"
InsectSwarmTexture = "Interface\\Icons\\Spell_Nature_InsectSwarm"
RegrowthTexture = "Interface\\Icons\\Spell_Nature_ResistNature"
RejuvenationTexture = "Interface\\Icons\\Spell_Nature_Rejuvenation"
MoonkinFormTexture = "Interface\\Icons\\Spell_Nature_ForceOfNature"


local function GetSpellBonusHealing()
	HealingTouchValue = {48, 107, 229, 418, 651, 838, 1051, 1339, 1686, 2087, 2472}
	RejuvenationValue = {32, 56, 116, 180, 244, 304, 388, 488, 608, 756, 888}
	RegrowthValue = {198, 364, 532, 700, 879, 1113, 1398, 1748, 2125}
	TranquilityValue = {490, 715, 1055, 1470}
	local _,_,_,_,GiftNatureRank = GetTalentInfo(3, 12)
	local _,_,_,_,ImprovedRejuvenationRank = GetTalentInfo(3, 10)
	local bonusHealing = 0
	for i=1,18 do if(IDEquipment[i] ~= 0 and item_stat[IDEquipment[i]] ~= nil) then
		bonusHealing = bonusHealing + item_stat[IDEquipment[i]]['hsp'] end
	end
	--====================--
	local SubLevel20PENALTY = 1
	if(HealingTouchLevel[HealingTouchRank] < 20) then SubLevel20PENALTY = 1-(20-HealingTouchLevel[HealingTouchRank])*0.0375 end
	HealingTouchValue[HealingTouchRank] = (HealingTouchValue[HealingTouchRank]+bonusHealing*SubLevel20PENALTY)*(1+(0.02*GiftNatureRank))
	if(RejuvenationLevel[RejuvenationRank] < 20) then SubLevel20PENALTY = 1-(20-RejuvenationLevel[RejuvenationRank])*0.0375 else SubLevel20PENALTY = 1 end
	RejuvenationValue[RejuvenationRank] = (RejuvenationValue[RejuvenationRank]+bonusHealing*(12/15)*SubLevel20PENALTY)*(1+(0.02*GiftNatureRank))*(1+(0.05*ImprovedRejuvenationRank))
	if(RegrowthLevel[RegrowthRank] < 20) then SubLevel20PENALTY = 1-(20-RegrowthLevel[RegrowthRank])*0.0375 else SubLevel20PENALTY = 1 end
	RegrowthValue[RegrowthRank] = (RegrowthValue[RegrowthRank]+bonusHealing*(2/3.5)*SubLevel20PENALTY)*(1+(0.02*GiftNatureRank))
	TranquilityValue[TranquilityRank] = (TranquilityValue[TranquilityRank]+bonusHealing*(1/3))*(1+(0.02*GiftNatureRank))
end

local function GetNbrTranquility()
	local nbrHeal = 0
	local HpLostParty = UnitHealthMax("player") - UnitHealth("player")
	if((TranquilityRank > 0) and (HpLostParty > TranquilityValue[TranquilityRank])) then nbrHeal = nbrHeal + 1 end
	for i= 1, GetNumPartyMembers()-1 do
		HpLostParty = UnitHealthMax("party"..i) - UnitHealth("party"..i)
		if(HpLostParty > TranquilityValue[TranquilityRank]) then nbrHeal = nbrHeal + 1 end
	end
	return nbrHeal
end

local function DruidDps()
	if(CastingInfo == nil) then
		local MoonkinFormBuff = GetUnitBuff("player", MoonkinFormTexture)
		if(IsInGroup()) then AssistUnit(GetTank()) end
		if(MoonkinFormBuff and (not Combat or ((PrctHp[0] < 40) and (PrctMana > 40)))) then
			--Cancel Moonkin Form
			UseAction(GetSlot("Moonkin Form"))
		elseif(IsSpellReady("Moonkin Form") and Combat and not MoonkinFormBuff) then
			--Moonkin Form
			UseAction(GetSlot("Moonkin Form"))
		elseif(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			local MoonfireDebuff = GetUnitDebuff("target", MoonfireTexture)
			local InsectSwarmDebuff = GetUnitDebuff("target", InsectSwarmTexture)
			local FearieFireDebuff = GetUnitDebuff("target", FearieFireTexture)
			if(CheckInteractDistance("target", 4) and IsFollowing) then
				if(not Combat) then TimerGodMode = 0.5 BlueBool = 7
				else TimerGodMode = 0.5 BlueBool = 6 end
			end
			if(PrctMana >= 50) then
				if(IsSpellReady("Moonfire") and not MoonfireDebuff) then
					--Moonfire
					UseAction(GetSlot("Moonfire"))
				elseif(IsSpellReady("Faerie fire") and not FearieFireDebuff and UnitIsElite("target")) then
					--Faerie fire
					UseAction(GetSlot("Faerie fire"))
				elseif(IsSpellReady("Insect Swarm") and not InsectSwarmDebuff) then
					--Insect Swarm
					UseAction(GetSlot("Insect Swarm"))
				elseif(IsSpellReady("Wrath")) then
					--Wrath
					UseAction(GetSlot("Wrath"))
				end
			end
		end
	end
end

local function HealGroup(indexP)
	local HpRatio = PrctHp[indexP]
	local HpLost = HpLostTab[indexP]
	if((indexP == 0) or (PrctHp[0] < 25)) then
		local RegrowthBuff = GetUnitBuff("player", RegrowthTexture)
		local RejuvenationBuff = GetUnitBuff("player", RejuvenationTexture)
		if((HpRatio < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
			--Healthstone
			PlaceItem(120, "Healthstone") UseAction(120)
			return 0
		elseif((HpRatio < 35) and HasHPotion() and (GetHPotionCD() < 1.25) and Combat) then
			--Healing Potion
			PlaceItem(120, "Healing Potion") UseAction(120)
			return 0
		elseif(IsSpellReady("Regrowth") and not RegrowthBuff and (HpLost >= RegrowthValue[RegrowthRank])) then
			--Regrowth
			TargetUnit("player")
			UseAction(GetSlot("Regrowth"))
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Healing Touch") and (HpLost >= HealingTouchValue[HealingTouchRank])) then
			--Healing Touch
			TargetUnit("player")
			UseAction(GetSlot("Healing Touch"))
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Rejuvenation") and not RejuvenationBuff and (HpLost >= RejuvenationValue[RejuvenationRank])) then
			--Rejuvenation
			TargetUnit("player")
			UseAction(GetSlot("Rejuvenation"))
			return 0
		end
	elseif((indexP > 0) and (IsInRaid() == false)) then
		local RegrowthBuff = GetUnitBuff("party"..indexP, RegrowthTexture)
		local RejuvenationBuff = GetUnitBuff("party"..indexP, RejuvenationTexture)
		if(IsSpellReady("Tranquility") and (nbrTranquility >= 3)) then
			--Tranquility
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Tranquility"))
			return 0
		elseif(IsSpellReady("Regrowth") and not RegrowthBuff and (HpLost >= RegrowthValue[RegrowthRank])) then
			--Regrowth
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Regrowth"))
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Healing Touch") and (HpLost >= HealingTouchValue[HealingTouchRank])) then
			--Healing Touch
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Healing Touch"))
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Rejuvenation") and not RejuvenationBuff and (HpLost >= RejuvenationValue[RejuvenationRank])) then
			--Rejuvenation
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Rejuvenation"))
			return 0
		end
	elseif(indexP > 0) then
		local RegrowthBuff = GetUnitBuff("raid"..indexP, RegrowthTexture)
		local RejuvenationBuff = GetUnitBuff("raid"..indexP, RejuvenationTexture)
		if(IsSpellReady("Tranquility") and (nbrTranquility >= 3)) then
			--Tranquility
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Tranquility"))
			return 0
		elseif(IsSpellReady("Regrowth") and not RegrowthBuff and (HpLost >= RegrowthValue[RegrowthRank])) then
			--Regrowth
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Regrowth"))
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Healing Touch") and (HpLost >= HealingTouchValue[HealingTouchRank])) then
			--Healing Touch
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Healing Touch"))
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Rejuvenation") and not RejuvenationBuff and (HpLost >= RejuvenationValue[RejuvenationRank])) then
			--Rejuvenation
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Rejuvenation"))
			return 0
		end
	end
	return 1
end

function DruidHeal()
	if(((CastingInfo == "Healing Touch") and (HpLostTab[LastTarget] < HealingTouchValue[HealingTouchRank]*0.9)) or ((CastingInfo == "Rétablissement") and (HpLostTab[LastTarget] < RegrowthValue[RegrowthRank]*0.9))) then
		--Stop Casting
		SpellStopCasting()
	elseif(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		GetSpellBonusHealing()
		local nbrTranquility = GetNbrTranquility()
		local RemoveCurseKey = GetDispelKey("Curse")
		local CurePoisonKey = GetDispelKey("Poison")
		local MarkWildBuff = GetUnitBuff("player", MarkWildTexture)
		local ThornsBuff = GetUnitBuff("player", ThornsTexture)
		local MarkWildKey = GetBuffKey(MarkWildTexture)
		local ThornsKey = GetBuffKey(ThornsTexture)
		if(not IsFollowing and Combat and IsSpellReady("Renaissance") and (GetGroupDead() > 0)) then
			--Rebirth
			TargetUnit(tar..GetGroupDead())
			UseAction(GetSlot("Rebirth"))
		elseif(not IsFollowing and not Combat and not DrinkingBuff and (PrctMana < 33) and (HasDrink() > 0)) then
			--Drink
			PlaceItem(120, HasDrink()) UseAction(120)
		elseif(IsSpellReady("Mark of the Wild") and not MarkWildBuff and not Combat) then
			--Mark of the Wild (self)
			TargetUnit("player")
			UseAction(GetSlot("Mark of the Wild"))
		elseif(IsSpellReady("Thorns") and not ThornsBuff and not Combat) then
			--Thorns (self)
			TargetUnit("player")
			UseAction(GetSlot("Thorns"))
		elseif(IsSpellReady("Mark of the Wild") and (MarkWildKey > 0) and not Combat) then
			--Mark of the Wild (Groupe)
			if(IsSpellReady("Don du fauve") and (GetItemCount(17026) > 0)) then
				UseAction(GetSlot("Mark of the Wild"))
			else
				if(IsInRaid()) then TargetUnit("raid"..MarkWildKey)
				else TargetUnit("party"..MarkWildKey) end
				UseAction(GetSlot("Mark of the Wild"))
			end
		elseif(IsSpellReady("Thorns") and (ThornsKey > 0) and not Combat) then
			--Thorns (Groupe)
			if(IsInRaid()) then TargetUnit("raid"..ThornsKey)
			else TargetUnit("party"..ThornsKey) end
			UseAction(GetSlot("Thorns"))
		elseif(IsSpellReady("Innervation") and (PrctMana < 15) and Combat) then
			--Innervation
			TargetUnit("player")
			UseAction(GetSlot("Innervation"))
		elseif(Combat and (PrctMana < 10) and ((PrctHp[0] > 50) or not HasHPotion()) and HasMPotion() and (GetMPotionCD() < 1.25)) then
			--Mana Potion
			PlaceItem(120, "Mana Potion") UseAction(120)
		elseif(IsSpellReady("Remove Curse") and GetUnitDispel("player", "Curse")) then
			--Remove Curse (self)
			TargetUnit("player")
			UseAction(GetSlot("Remove Curse"))
		elseif(IsSpellReady("Cure Poison") and GetUnitDispel("player", "Poison")) then
			--Cure Poison (self)
			TargetUnit("player")
			UseAction(GetSlot("Cure Poison"))
		elseif(IsSpellReady("Remove Curse") and (RemoveCurseKey > 0)) then
			--Remove Curse (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..RemoveCurseKey)
			else
				TargetUnit("party"..RemoveCurseKey)
			end
			UseAction(GetSlot("Remove Curse"))
		elseif(IsSpellReady("Cure Poison") and (CurePoisonKey > 0)) then
			--Cure Poison (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..CurePoisonKey)
			else
				TargetUnit("party"..CurePoisonKey)
			end
			UseAction(GetSlot("Cure Poison"))
		else
			local tmp = 1; local index = 0
			while(tmp == 1 and index <= GetNumGroupMembers()) do
				tmp = HealGroup(HealTargetTab[index])
				index = index + 1
			end
			if(tmp == 1) then DruidDps() end
		end
	end
end

function Druid_OnUpdate(elapsed)
	DrinkingBuff = GetUnitBuff("player", DrinkingTexture)
	if(((PrctMana > 33) or (HasDrink() == 0)) and ((not DrinkingBuff) or (PrctMana > 80))) then FollowMultibox("Fiore") end
	if(DrinkingBuff and (PrctMana > 80)) then BlueBool = 4 end
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end

function Druid_OnLoad()  --Map Update
	--Rank/ID
	if(IsPlayerSpell("Healing Touch")) then _,HealingTouchRank = GetSpellID("Healing Touch") end
	if(IsPlayerSpell("Rejuvenation")) then _,RejuvenationRank = GetSpellID("Rejuvenation") end
	if(IsPlayerSpell("Regrowth")) then _,RegrowthRank = GetSpellID("Regrowth") end
	if(IsPlayerSpell("Tranquility")) then _,TranquilityRank = GetSpellID("Tranquility") end
end

function Druid_OnSpellLearned()

end