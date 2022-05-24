local LastTarget = 0

--Variables
LesserHealRank = 1 LesserHealValue = {} LesserHealLevel = {1, 4, 10}
RenewRank = 1 RenewValue = {} RenewLevel = {8, 14, 20, 26, 32, 38, 44, 50, 56, 60}
HealRank = 1 HealValue = {} HealLevel = {16, 22, 28, 34}
GreaterHealRank = 1 GreaterHealValue = {} GreaterHealLevel = {40, 46, 52, 58, 60}
PoHealingRank = 1 PoHealingValue = {} PoHealingLevel = {30, 40, 50, 60, 60}
ShadowWordPainName = ""

local DrinkingBuff = ""

--Texture
PWordFortitudeTexture = "Interface\\Icons\\Spell_Holy_WordFortitude"
DivineSpiritTexture = "Interface\\Icons\\Spell_Holy_DivineSpirit"
PoSpiritTexture = "Interface\\Icons\\Spell_Holy_PrayerofSpirit"
PoFortitudeTexture = "Interface\\Icons\\Spell_Holy_PrayerOfFortitude"
InnerFireTexture = "Interface\\Icons\\Spell_Holy_InnerFire"
InnerFocusTexture = "Interface\\Icons\\Spell_Frost_WindWalkOn"
RenewTexture = "Interface\\Icons\\Spell_Holy_Renew"
ShadowWordPainTexture = "Interface\\Icons\\Spell_Shadow_ShadowWordPain"
HolyFireTexture = "Interface\\Icons\\Spell_Holy_SearingLight"
WeakenedSoulTexture = "Interface\\Icons\\Spell_Holy_AshesToAshes"
VampiricEmbraceTexture = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding"
ShadowformTexture = "Interface\\Icons\\Spell_Shadow_Shadowform"

local function GetSpellBonusHealing()
	LesserHealValue = {53, 84, 154} RenewValue = {45, 100, 175, 245, 315, 400, 510, 650, 810, 970}
	HealValue = {330, 476, 624, 781} GreaterHealValue = {982, 1248, 1556, 1917, 2080}
	PoHealingValue = {311, 458, 676, 965, 1070}
	local _,_,_,_,RenewTalentRank = GetTalentInfo(2, 2)
	local _,_,_,_,SpiritualHealingRank = GetTalentInfo(2, 15)
	local spirit = UnitStat("player", 5)
	local _,_,_,_,SpiritualGuidance = GetTalentInfo(2, 14)
	local bonusHealing = spirit*0.05*SpiritualGuidance
	for i=1,18 do if(IDEquipment[i] ~= 0 and item_stat[IDEquipment[i]] ~= nil) then
		bonusHealing = bonusHealing + item_stat[IDEquipment[i]]['hsp'] end
	end
	--====================--
	local SubLevel20PENALTY = 1
	if(RenewLevel[RenewRank] < 20) then SubLevel20PENALTY = 1-(20-RenewLevel[RenewRank])*0.0375 end
	RenewValue[RenewRank] = (RenewValue[RenewRank]+bonusHealing*SubLevel20PENALTY)*(1+(0.05*RenewTalentRank))*(1+(0.02*SpiritualHealingRank))
	SubLevel20PENALTY = 1-(20-LesserHealLevel[LesserHealRank])*0.0375
	LesserHealValue[LesserHealRank] = (LesserHealValue[LesserHealRank]+bonusHealing*(2.5/3.5)*SubLevel20PENALTY)*(1+(0.02*SpiritualHealingRank))
	SubLevel20PENALTY = 1
	if(HealLevel[HealRank] < 20) then SubLevel20PENALTY = 1-(20-HealLevel[HealRank])*0.0375 end
	HealValue[HealRank] = (HealValue[HealRank]+bonusHealing*(3/3.5)*SubLevel20PENALTY)*(1+(0.02*SpiritualHealingRank))
	GreaterHealValue[GreaterHealRank] = (GreaterHealValue[GreaterHealRank]+bonusHealing*(3/3.5))*(1+(0.02*SpiritualHealingRank))
	PoHealingValue[PoHealingRank] = (PoHealingValue[PoHealingRank]+bonusHealing*(3/(3.5*3)))*(1+(0.02*SpiritualHealingRank))
end

local function GetNbrPoHealing()
	local nbrHeal = 0
	local HpLostParty = UnitHealthMax("player") - UnitHealth("player")
	if((PoHealingRank > 0) and (HpLostParty > PoHealingValue[PoHealingRank])) then nbrHeal = nbrHeal + 1 end
	for i= 1, GetNumPartyMembers()-1 do
		HpLostParty = UnitHealthMax("party"..i) - UnitHealth("party"..i)
		if(HpLostParty > PoHealingValue[PoHealingRank]) then nbrHeal = nbrHeal + 1 end
	end
	return nbrHeal
end

local function PriestDps()
	if(CastingInfo == nil) then
		local ShadowformBuff = GetUnitBuff("player", ShadowformTexture)
		if(IsInGroup()) then AssistUnit(GetTank()) if((UnitCanAttack("player", "target") == nil) and Combat) then CastSpellByName("Attaque") end end
		if(ShadowformBuff and (PrctHp[0] < 40) and (PrctMana > 40)) then
			--Cancel Shadowform
			CastSpellByName("Forme d'Ombre")
		elseif(IsSpellReady("Forme d'Ombre") and not ShadowformBuff) then
			--Shadowform
			CastSpellByName("Forme d'Ombre")
		elseif(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			local ShadowWordPainDebuff = GetUnitDebuff("target", ShadowWordPainTexture)
			local HolyFireDebuff = GetUnitDebuff("target", HolyFireTexture)
			local VampiricEmbraceDebuff = GetUnitDebuff("target", VampiricEmbraceTexture)
			if(CheckInteractDistance("target", 4) and IsFollowing) then TimerGodMode = 0.5 BlueBool = 6 end
			local _,_,_,_,BlackoutRank = GetTalentInfo(3, 2)
			local _,_,_,_,SpiritTapRank = GetTalentInfo(3, 1)
			if((BlackoutRank > 0) or (SpiritTapRank > 0)) then
				if(IsSpellReady("Etreinte vampirique") and UnitIsElite("target") and not VampiricEmbraceDebuff) then
					--Vampiric Embrace
					UseAction(GetSlot("Etreinte vampirique"))
				elseif(IsSpellReady(ShadowWordPainName) and not ShadowWordPainDebuff) then
					--Shadow Word: Pain
					UseAction(GetSlot(ShadowWordPainName))
				elseif(IsSpellReady("Attaque mentale")) then
					--Mind Blast
					UseAction(GetSlot("Attaque mentale"))
				elseif(IsSpellReady("Brûlure de mana") and UnitIsCaster("target") and UnitPlayerControlled("target") and (UnitMana("target") > 5) and (UnitPowerType("target") == 0)) then
					--Mana Burn (PvP)
					UseAction(GetSlot("Brûlure de mana"))
				elseif(IsSpellReady("Fouet Mental")) then
					--Mind Flay
					UseAction(GetSlot("Fouet Mental"))
				elseif(IsSpellReady("Flammes sacrées") and not HolyFireDebuff) then
					--Holy Fire
					UseAction(GetSlot("Flammes sacrées"))
				elseif(IsSpellReady("Châtiment")) then
					--Smite
					UseAction(GetSlot("Châtiment"))
				elseif(HasWandEquipped() and not IsAutoRepeatAction(GetSlot("Tir"))) then
					--Wand
					CastSpellByName("Tir")
				end
			elseif(HasWandEquipped() and not IsAutoRepeatAction(GetSlot("Tir"))) then
				--Wand
				CastSpellByName("Tir")
			end
		end
	end
end

function PriestHeal()
	if(((CastingInfo == "Soins Rapides") and (PrctHp[LastTarget] > 70)) or ((CastingInfo == "Soins inférieurs") and (HpLostTab[LastTarget] < LesserHealValue[LesserHealRank]*0.9)) or ((CastingInfo == "Soins") and (HpLostTab[LastTarget] < HealValue[HealRank]*0.9)) or ((CastingInfo == "Soins Supérieurs") and (HpLostTab[LastTarget] < GreaterHealValue[GreaterHealRank]*0.9))) then
		--Stop Casting
		SpellStopCasting()
	elseif(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		GetSpellBonusHealing()
		LastTarget = HealTarget
		local nbrPoHealing = GetNbrPoHealing()
		local CureDiseaseKey = GetDispelKey("Disease")
		local DispelMagicKey = GetDispelKey("Magic")
		local PWordFortitudeKey = GetBuffKey(PoFortitudeTexture, 0, PWordFortitudeTexture)
		local DivineSpiritKey = GetBuffKey(PoSpiritTexture, 0, DivineSpiritTexture)
		local InnerFireBuff = GetUnitBuff("player", InnerFireTexture)
		local PWordFortitudeBuff = GetUnitBuff("player", PWordFortitudeTexture) or GetUnitBuff("player", PoFortitudeTexture)
		local DivineSpiritBuff = GetUnitBuff("player", DivineSpiritTexture) or GetUnitBuff("player", PoSpiritTexture)
		local InnerFocusBuff = GetUnitBuff("player", InnerFocusTexture)
		if(not IsFollowing and not Combat and IsSpellReady("Résurrection") and (GetGroupDead() > 0)) then
			--Resurrection
			TargetUnit(tar..GetGroupDead())
			UseAction(GetSlot("Résurrection"))
		elseif(not IsFollowing and not Combat and not DrinkingBuff and (PrctMana < 33) and (HasDrink() > 0)) then
			--Drink
			PlaceItem(120, HasDrink()) UseAction(120)
		elseif(IsSpellReady("Feu intérieur") and not InnerFireBuff) then
			--Inner Fire
			UseAction(GetSlot("Feu intérieur"))
		elseif(IsSpellReady("Prière de robustesse") and (not PWordFortitudeBuff or PWordFortitudeKey > 0) and (GetItemCount(17028) > 0)) then
			--Prayer of Fortitude
			TargetUnit("player")
			UseAction(GetSlot("Prière de robustesse"))
		elseif(IsSpellReady("Prière d'Esprit") and (not DivineSpiritBuff or DivineSpiritKey > 0) and (GetItemCount(17029) > 0)) then
			--Prayer of Spirit
			TargetUnit("player")
			UseAction(GetSlot("Prière d'Esprit"))
		elseif(IsSpellReady("Mot de pouvoir : Robustesse") and not PWordFortitudeBuff and (not IsPlayerSpell("Prière de robustesse") or (GetItemCount(17028) == 0)) and not Combat) then
			--Power Word: Fortitude (self)
			TargetUnit("player")
			UseAction(GetSlot("Mot de pouvoir : Robustesse"))
		elseif(IsSpellReady("Esprit divin") and not DivineSpiritBuff and not Combat) then
			--Divine Spirit (self)
			TargetUnit("player")
			UseAction(GetSlot("Esprit divin"))
		elseif(IsSpellReady("Mot de pouvoir : Robustesse") and (PWordFortitudeKey > 0) and (not IsPlayerSpell("Prière de robustesse") or (GetItemCount(17028) == 0)) and not Combat) then
			--Power Word: Fortitude (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..PWordFortitudeKey)
			else
				TargetUnit("party"..PWordFortitudeKey)
			end
			UseAction(GetSlot("Mot de pouvoir : Robustesse"))
		elseif(IsSpellReady("Esprit divin") and (DivineSpiritKey > 0) and not Combat) then
			--Divine Spirit (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..DivineSpiritKey)
			else
				TargetUnit("party"..DivineSpiritKey)
			end
			UseAction(GetSlot("Esprit divin"))
		elseif(IsSpellReady("Focalisation améliorée") and Combat and (PrctMana < 20)) then
			--Inner Focus
			UseAction(GetSlot("Focalisation améliorée"))
		elseif(Combat and not InnerFocusBuff and (PrctMana < 10) and ((PrctHp[0] > 50) or not HasHPotion()) and HasMPotion() and (GetMPotionCD() < 1.25)) then
			--Mana Potion
			PlaceItem(120, "Potion de mana") UseAction(120)
		elseif(IsSpellReady("Oubli") and PlayerHasAggro() and IsInGroup()) then
			--Fade
			UseAction(GetSlot("Oubli"))
		elseif(IsSpellReady("Cri psychique") and PlayerHasAggro()) then
			--Psychic Scream
			UseAction(GetSlot("Cri psychique"))
		elseif(IsSpellReady("Guérison des maladies") and GetUnitDispel("player", "Disease") and (HpRatio > 50) and (PrctMana > 25)) then
			--Cure Disease (self)
			TargetUnit("player")
			UseAction(GetSlot("Guérison des maladies"))
		elseif(IsSpellReady("Dissipation de la magie") and GetUnitDispel("player", "Magic") and (HpRatio > 50) and (PrctMana > 25)) then
			--Dispel Magic (self)
			TargetUnit("player")
			UseAction(GetSlot("Dissipation de la magie"))
		elseif(IsSpellReady("Guérison des maladies") and (CureDiseaseKey > 0) and (HpRatio > 50) and (PrctMana > 25)) then
			--Cure Disease (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..CureDiseaseKey)
			else
				TargetUnit("party"..CureDiseaseKey)
			end
			UseAction(GetSlot("Guérison des maladies"))
		elseif(IsSpellReady("Dissipation de la magie") and (DispelMagicKey > 0) and (HpRatio > 50) and (PrctMana > 25)) then
			--Dispel Magic (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..DispelMagicKey)
			else
				TargetUnit("party"..DispelMagicKey)
			end
			UseAction(GetSlot("Dissipation de la magie"))
		elseif((HealTarget == 0) or (PrctHp[0] < 25)) then
			local RenewBuff = GetUnitBuff("player", RenewTexture)
			local PWordShieldBuff = GetUnitBuff("player", PWordShieldTexture)
			local WeakenedSoulDebuff = GetUnitDebuff("player", WeakenedSoulTexture)
			if(IsSpellReady("Prière du désespoir") and (HpRatio < 40) and Combat) then
				--Desperate Prayer
				UseAction(GetSlot("Prière du désespoir"))
			elseif((HpRatio < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
				--Healthstone
				PlaceItem(120, "Pierre de soins") UseAction(120)
			elseif((HpRatio < 35) and HasHPotion() and (GetHPotionCD() < 1.25) and Combat) then
				--Healing Potion
				PlaceItem(120, "Potion de soins") UseAction(120)
			elseif(IsSpellReady("Mot de pouvoir : Bouclier") and (HpRatio < 30) and not PWordShieldBuff and not WeakenedSoulDebuff and Combat) then
				--Power Word: Shield
				TargetUnit("player")
				UseAction(GetSlot("Mot de pouvoir : Bouclier"))
			elseif(IsSpellReady("Soins rapides") and (HpRatio < 30) and Combat) then
				--Flash Heal
				TargetUnit("player")
				UseAction(GetSlot("Soins rapides"))
			elseif(IsSpellReady("Rénovation") and (HpLost >= RenewValue[RenewRank]) and not RenewBuff) then
				--Renew
				TargetUnit("player")
				UseAction(GetSlot("Rénovation"))
			elseif(IsSpellReady("Soins supérieurs") and (HpLost >= GreaterHealValue[GreaterHealRank])) then
				--Greater Heal
				TargetUnit("player")
				UseAction(GetSlot("Soins supérieurs"))
			elseif(IsSpellReady("Soins") and (HpLost >= HealValue[HealRank])) then
				--Heal
				TargetUnit("player")
				UseAction(GetSlot("Soins"))
			elseif(IsSpellReady("Soins inférieurs") and (HpLost >= LesserHealValue[LesserHealRank]) and (UnitLevel("player") < 40)) then
				--Lesser Heal
				TargetUnit("player")
				UseAction(GetSlot("Soins inférieurs"))
			else
				PriestDps()
			end
		elseif((HealTarget > 0) and (IsInRaid() == false)) then
			local RenewBuff = GetUnitBuff("party"..HealTarget, RenewTexture)
			local PWordShieldBuff = GetUnitBuff("party"..HealTarget, PWordShieldTexture)
			local WeakenedSoulDebuff = GetUnitDebuff("party"..HealTarget, WeakenedSoulTexture)
			if(IsSpellReady("Mot de pouvoir : Bouclier") and (HpRatio < 30) and not PWordShieldBuff and not WeakenedSoulDebuff and Combat) then
				--Power Word: Shield
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Mot de pouvoir : Bouclier"))
			elseif(IsSpellReady("Soins rapides") and (HpRatio < 30) and Combat) then
				--Flash Heal
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Soins rapides"))
			elseif(IsSpellReady("Prière de soins") and (nbrPoHealing >= 3)) then
				--Prayer of Healing
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Prière de soins"))
			elseif(IsSpellReady("Rénovation") and (HpLost >= RenewValue[RenewRank]) and not RenewBuff) then
				--Renew
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Rénovation"))
			elseif(IsSpellReady("Soins supérieurs") and (HpLost >= GreaterHealValue[GreaterHealRank])) then
				--Greater Heal
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Soins supérieurs"))
			elseif(IsSpellReady("Soins") and (HpLost >= HealValue[HealRank])) then
				--Heal
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Soins"))
			elseif(IsSpellReady("Soins inférieurs") and (HpLost >= LesserHealValue[LesserHealRank]) and (UnitLevel("player") < 40)) then
				--Lesser Heal
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Soins inférieurs"))
			else
				PriestDps()
			end
		elseif(HealTarget > 0) then
			local RenewBuff = GetUnitBuff("raid"..HealTarget, RenewTexture)
			local PWordShieldBuff = GetUnitBuff("raid"..HealTarget, PWordShieldTexture)
			local WeakenedSoulDebuff = GetUnitDebuff("raid"..HealTarget, WeakenedSoulTexture)
			if(IsSpellReady("Mot de pouvoir : Bouclier") and (HpRatio < 30) and not PWordShieldBuff and not WeakenedSoulDebuff and Combat) then
				--Power Word: Shield
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Mot de pouvoir : Bouclier"))
			elseif(IsSpellReady("Soins rapides") and (HpRatio < 30) and Combat) then
				--Flash Heal
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Soins rapides"))
			elseif(IsSpellReady("Prière de soins") and (nbrPoHealing >= 3)) then
				--Prayer of Healing
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Prière de soins"))
			elseif(IsSpellReady("Rénovation") and (HpLost >= RenewValue[RenewRank]) and not RenewBuff) then
				--Renew
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Rénovation"))
			elseif(IsSpellReady("Soins supérieurs") and (HpLost >= GreaterHealValue[GreaterHealRank])) then
				--Greater Heal
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Soins supérieurs"))
			elseif(IsSpellReady("Soins") and (HpLost >= HealValue[HealRank])) then
				--Heal
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Soins"))
			elseif(IsSpellReady("Soins inférieurs") and (HpLost >= LesserHealValue[LesserHealRank]) and (UnitLevel("player") < 40)) then
				--Lesser Heal
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Soins inférieurs"))
			else
				PriestDps()
			end
		end
	end
end

function Priest_OnUpdate(elapsed)
	DrinkingBuff = GetUnitBuff("player", DrinkingTexture)
	if(((PrctMana > 33) or (HasDrink() == 0)) and ((not DrinkingBuff) or (PrctMana > 80))) then FollowMultibox("Fjola") end
	if(DrinkingBuff and (PrctMana > 80)) then BlueBool = 4 end
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end

function Priest_OnLoad()  --Map Update
	--Rank/ID
	if(IsPlayerSpell("Soins inférieurs")) then _,LesserHealRank = GetSpellID("Soins inférieurs") end if(IsPlayerSpell("Rénovation")) then _,RenewRank = GetSpellID("Rénovation") end
	if(IsPlayerSpell("Soins")) then _,HealRank = GetSpellID("Soins") end if(IsPlayerSpell("Soins supérieurs")) then _,GreaterHealRank = GetSpellID("Soins supérieurs") end
	if(IsPlayerSpell("Prière de soins")) then _,PoHealingRank = GetSpellID("Prière de soins") end if(GetSpellID2(": Douleur") > 0) then ShadowWordPainName = GetSpellName(GetSpellID2(": Douleur"), BOOKTYPE_SPELL) end
end

function Priest_OnSpellLearned()

end

function Priest_OnLoot(lootid, item_texture, lootSlot, item_bag, item_slot)
	if(GetContainerItemInfo(item_bag, item_slot) == item_texture) then
		--Equipment Stats
		local equipID = GetEquipmentID(lootSlot)
		local intelB = 0 local spiritB = 0 local staminaB = 0 local hspB = 0 local mp5B = 0 local spCritB = 0
		if(item_stat[equipID] ~= nil) then
			staminaB = item_stat[equipID]['stamina']
			intelB = item_stat[equipID]['intel']
			spiritB = item_stat[equipID]['spirit']
			hspB = item_stat[equipID]['hsp']
			mp5B = item_stat[equipID]['mp5']
			spCritB = item_stat[equipID]['spCrit']
		end
		local intelL = 0 local spiritL = 0 local staminaL = 0 local hspL = 0 local mp5L = 0 local spCritL = 0
		if(item_stat[lootid] ~= nil) then
			staminaL = item_stat[lootid]['stamina']
			intelL = item_stat[lootid]['intel']
			spiritL = item_stat[lootid]['spirit']
			hspL = item_stat[lootid]['hsp']
			mp5L = item_stat[lootid]['mp5']
			spCritL = item_stat[lootid]['spCrit']
		end
		local scoreB = (intelB*((5/59.2) + (15/100)))+(1.05*spiritB*((1/4) + (0.15*2.5/4)))+hspB+mp5B+(spCritB*5)+(staminaB*0.1)
		local scoreL = (intelL*((5/59.2) + (15/100)))+(1.05*spiritL*((1/4) + (0.15*2.5/4)))+hspL+mp5L+(spCritL*5)+(staminaL*0.1)
		print(scoreB)
		print(scoreL)
		if(scoreL >= scoreB) then PickupContainerItem(item_bag,item_slot) AutoEquipCursorItem() end
	end
end