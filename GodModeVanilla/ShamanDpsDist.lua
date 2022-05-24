local LastTarget = 0

--Variables
HealingWaveRank = 1 HealingWaveValue = {} HealingWaveLevel = {1, 6, 12, 18, 24, 32, 40, 48, 56, 60}
ChainHealRank = 1 ChainHealValue = {} ChainHealLevel = {40, 46, 54}

local DrinkingBuff = ""
TremorTotemDuration = 0
SearingTotemDuration = 0
StoneclawTotemDuration = 0
MagmaTotemDuration = 0

--Texture
StoneskinTotemTexture = "Interface\\Icons\\Spell_Nature_StoneSkinTotem"
StrEarthTotemTexture = "Interface\\Icons\\Spell_Nature_EarthBindTotem"
FrostResistanceTotemTexture = "Interface\\Icons\\Spell_FrostResistanceTotem_01"
HealingTotemTexture = "Interface\\Icons\\INV_Spear_04"
ManaTotemTexture = "Interface\\Icons\\Spell_Nature_ManaRegenTotem"
GraceAirTotemTexture = "Interface\\Icons\\Spell_Nature_InvisibilityTotem"
FlameShockTexture = "Interface\\Icons\\Spell_Fire_FlameShock"
LightningShieldTexture = "Interface\\Icons\\Spell_Nature_LightningShield"
FrostShockTexture = "Interface\\Icons\\Spell_Frost_FrostShock"
ClearcastingTexture = "Interface\\Icons\\Spell_Shadow_ManaBurn"


local function GetSpellBonusHealing()
	HealingWaveValue = {42, 76, 150, 304, 422, 596, 817, 1116, 1486, 1735}
	ChainHealValue = {356, 449, 607}
	local _,_,_,_,PurificationRank = GetTalentInfo(3, 14)
	local bonusHealing = 0
	for i=1,18 do if(IDEquipment[i] ~= 0 and item_stat[IDEquipment[i]] ~= nil) then
		bonusHealing = bonusHealing + item_stat[IDEquipment[i]]['hsp'] end
	end
	--====================--
	local SubLevel20PENALTY = 1
	if(HealingWaveLevel[HealingWaveRank] < 20) then SubLevel20PENALTY = 1-(20-HealingWaveLevel[HealingWaveRank])*0.0375 end
	HealingWaveValue[HealingWaveRank] = (HealingWaveValue[HealingWaveRank]+bonusHealing*(3/3.5)*SubLevel20PENALTY)*(1+(0.02*PurificationRank))
	ChainHealValue[ChainHealRank] = (ChainHealValue[ChainHealRank]+bonusHealing*(2.5/3.5))*(1+(0.02*PurificationRank))
end

local function GetNbrChainHeal()
	local nbrHeal = 0
	local HpLostParty = UnitHealthMax("player") - UnitHealth("player")
	if((ChainHealRank > 0) and (HpLostParty > ChainHealValue[ChainHealRank])) then nbrHeal = nbrHeal + 1 end
	for i= 1, GetNumPartyMembers()-1 do
		HpLostParty = UnitHealthMax(tar..i) - UnitHealth(tar..i)
		if(HpLostParty > ChainHealValue[ChainHealRank]) then nbrHeal = nbrHeal + 1 end
	end
	return nbrHeal
end

local function ShamanDps()
	if(CastingInfo == nil) then
		if(IsInGroup()) then AssistUnit(GetTank()) if((UnitCanAttack("player", "target") == nil) and Combat) then CastSpellByName("Attaque") end end
		if(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			local ClearcastingBuff = GetUnitBuff("player", ClearcastingTexture)
			local FrostShockDebuff = GetUnitDebuff("target", FrostShockTexture)
			if(CheckInteractDistance("target", 4) and IsFollowing) then TimerGodMode = 0.5 BlueBool = 6 end
			if(IsSpellReady("Horion de givre") and not FrostShockDebuff and UnitPlayerControlled("target")) then
				--Frost Shock
				UseAction(GetSlot("Horion de givre"))
			elseif(IsFollowing and IsSpellReady("Horion de terre")) then
				--Earth Shock
				UseAction(GetSlot("Horion de terre"))
			elseif(IsSpellReady("Maîtrise élémentaire") and not ClearcastingBuff and IsSpellReady("Chaîne d'éclairs")) then
				--Elemental Mastery
				UseAction(GetSlot("Maîtrise élémentaire"))
			elseif(IsSpellReady("Chaîne d'éclairs")) then
				--Chain Lightning
				UseAction(GetSlot("Chaîne d'éclairs"))
			elseif(IsSpellReady("Eclair")) then
				--Lightning Bolt
				UseAction(GetSlot("Eclair"))
			end
		end
	end
end

function ShamanHeal_DpsDist()
	if((CastingInfo == "Vague de soins inférieurs") and (PrctHp[LastTarget] > 70)) then
		--Stop Casting
		SpellStopCasting()
	elseif(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		GetSpellBonusHealing()
		LastTarget = HealTarget
		local nbrChainHeal = GetNbrChainHeal()
		local CureDiseaseKey = GetDispelKey("Disease")
		local CurePoisonKey = GetDispelKey("Poison")
		local LightningShieldBuff = GetUnitBuff("player", LightningShieldTexture)
		local GraceAirTotemBuff = GetUnitBuff("player", GraceAirTotemTexture)
		local HealingTotemBuff = GetUnitBuff("player", HealingTotemTexture)
		local StrEarthTotemBuff = GetUnitBuff("player", StrEarthTotemTexture)
		if(not IsFollowing and not Combat and IsSpellReady("Esprit ancestral") and (GetGroupDead() > 0)) then
			--Ancestral Spirit
			TargetUnit(tar..GetGroupDead())
			UseAction(GetSlot("Esprit ancestral"))
		elseif(not IsFollowing and not Combat and not DrinkingBuff and (PrctMana < 33) and (HasDrink() > 0)) then
			--Drink
			PlaceItem(120, HasDrink()) UseAction(120)
		elseif(IsSpellReady("Bouclier de foudre") and not LightningShieldBuff) then
			--Lightning Shield
			UseAction(GetSlot("Bouclier de foudre"))
		elseif(Combat and (PrctMana < 10) and ((PrctHp[0] > 50) or not HasHPotion()) and HasMPotion() and (GetMPotionCD() < 1.25)) then
			--Mana Potion
			PlaceItem(120, "Potion de mana") UseAction(120)
		elseif(IsSpellReady("Guérison des maladies") and GetUnitDispel("player", "Disease") and (HpRatio > 50) and (PrctMana > 25)) then
			--Cure Disease (self)
			UseAction(GetSlot("Guérison des maladies"), 0, 1)
		elseif(IsSpellReady("Guérison du poison") and GetUnitDispel("player", "Poison") and (HpRatio > 50) and (PrctMana > 25)) then
			--Cure Poison (self)
			UseAction(GetSlot("Guérison du poison"), 0, 1)
		elseif(IsSpellReady("Guérison des maladies") and (CureDiseaseKey > 0) and (HpRatio > 50) and (PrctMana > 25)) then
			--Cure Disease (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..CureDiseaseKey)
			else
				TargetUnit("party"..CureDiseaseKey)
			end
			UseAction(GetSlot("Guérison des maladies"))
		elseif(IsSpellReady("Guérison du poison") and (CurePoisonKey > 0) and (HpRatio > 50) and (PrctMana > 25)) then
			--Cure Poison (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..CurePoisonKey)
			else
				TargetUnit("party"..CurePoisonKey)
			end
			UseAction(GetSlot("Guérison du poison"))
		elseif(IsSpellReady("Totem guérisseur") and not HealingTotemBuff and Combat) then
			--Healing Stream Totem
			UseAction(GetSlot("Totem guérisseur"))
		elseif(IsSpellReady("Totem de Grâce aérienne") and not GraceAirTotemBuff and Combat) then
			--Grace of Air Totem
			UseAction(GetSlot("Totem de Grâce aérienne"))
		elseif(IsSpellReady("Totem de Séisme") and IsGroupFeared() and (TremorTotemDuration == 0)) then
			--Tremor Totem
			CastingInfo = "Totem de Séisme"
			UseAction(GetSlot("Totem de Séisme"))
		elseif(IsSpellReady("Totem de Force de la Terre") and not StrEarthTotemBuff and (TremorTotemDuration == 0) and Combat) then
			--Strength of Earth Totem
			UseAction(GetSlot("Totem de Force de la Terre"))
		elseif(IsSpellReady("Totem de Magma") and (MagmaTotemDuration == 0) and (NbrEnemyAggro > 2) and Combat) then
			--Magma Totem
			CastingInfo = "Totem de Magma"
			UseAction(GetSlot("Totem de Magma"))
		elseif(CheckInteractDistance("target", 2) and IsSpellReady("Totem incendiaire") and (SearingTotemDuration == 0) and (MagmaTotemDuration == 0) and Combat) then
			--Searing Totem
			CastingInfo = "Totem incendiaire"
			UseAction(GetSlot("Totem incendiaire"))
		elseif((HealTarget == 0) or (PrctHp[0] < 25)) then
			if((HpRatio < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
				--Healthstone
				PlaceItem(120, "Pierre de soins") UseAction(120)
			elseif((HpRatio < 35) and HasHPotion() and (GetHPotionCD() < 1.25) and Combat) then
				--Healing Potion
				PlaceItem(120, "Potion de soins") UseAction(120)
			elseif(IsSpellReady("Vague de soins inférieurs") and (HpRatio < 30)) then
				--Lesser Healing Wave
				UseAction(GetSlot("Vague de soins inférieurs"), 0, 1)
			else
				ShamanDps()
			end
		elseif((HealTarget > 0) and (IsInRaid() == false)) then
			if(IsSpellReady("Vague de soins inférieurs") and (HpRatio < 30)) then
				--Lesser Healing Wave
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Vague de soins inférieurs"))
			elseif(IsSpellReady("Salve de guérison") and (nbrChainHeal >= 3)) then
				--Chain Heal
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Salve de guérison"))
			else
				ShamanDps()
			end
		elseif(HealTarget > 0) then
			if(IsSpellReady("Vague de soins inférieurs") and (HpRatio < 30)) then
				--Lesser Healing Wave
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Vague de soins inférieurs"))
			elseif(IsSpellReady("Salve de guérison") and (nbrChainHeal >= 3)) then
				--Chain Heal
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Salve de guérison"))
			else
				ShamanDps()
			end
		end
	end
end

function Shaman_DpsDist_OnUpdate(elapsed)
	DrinkingBuff = GetUnitBuff("player", DrinkingTexture)
	if(((PrctMana > 33) or (HasDrink() == 0)) and ((not DrinkingBuff) or (PrctMana > 80))) then FollowMultibox("Saelwyn") end
	if(DrinkingBuff and (PrctMana > 80)) then BlueBool = 4 end
	TremorTotemDuration = UpdateTimer(TremorTotemDuration)
	SearingTotemDuration = UpdateTimer(SearingTotemDuration)
	MagmaTotemDuration = UpdateTimer(MagmaTotemDuration)
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end