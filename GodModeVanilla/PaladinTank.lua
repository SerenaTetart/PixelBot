local LastTarget = 0 local HasAggro = false

--Variables


--Texture
BoMightTexture = "Interface\\Icons\\Spell_Holy_FistOfJustice"
BoWisdomTexture = "Interface\\Icons\\Spell_Holy_SealOfWisdom"
BoKingsTexture = "Interface\\Icons\\Spell_Magic_MageArmor"
BoSalvationTexture = "Interface\\Icons\\Spell_Holy_SealOfSalvation"
BoSanctuaryTexture = "Interface\\Icons\\Spell_Nature_LightningShield"
SoRTexture = "Interface\\Icons\\Ability_ThunderBolt"
SotCTexture = "Interface\\Icons\\Spell_Holy_HolySmite"
SoCTexture = "Interface\\Icons\\Ability_Warrior_InnerRage"
SoWTexture = "Interface\\Icons\\Spell_Holy_RighteousnessAura"
ForbearanceTexture = "Interface\\Icons\\Spell_Holy_RemoveCurse"
BoSacrificeTexture = "Interface\\Icons\\Spell_Holy_SealOfSacrifice"
DevotionAuraTexture = "Interface\\Icons\\Spell_Holy_DevotionAura"
RetributionAuraTexture = "Interface\\Icons\\Spell_Holy_AuraOfLight"
SanctityAuraTexture = "Interface\\Icons\\Spell_Holy_MindVision"
RighteousFuryTexture = "Interface\\Icons\\Spell_Holy_SealOfFury"
BubbleTexture = "Interface\\Icons\\Spell_Holy_Restoration"


local function PaladinDps()
	if(CastingInfo == nil) then
		if(Combat and UnitCanAttack("player", "target") and UnitAffectingCombat("target") == nil) then ClearTarget()
		elseif(Combat and ((UnitCanAttack("player", "target") == nil) or (CheckInteractDistance("target", 4) == nil))) then TargetNearestEnemy() end
		if(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			local SoRBuff = GetUnitBuff("player", SoRTexture)
			local SoWBuff = GetUnitBuff("player", SoWTexture)
			local SealBuff = SoRBuff or SoWBuff
			local SoWDebuff = GetUnitDebuff("target", SoWTexture)
			if(IsCurrentAction(GetSlot("Attack")) == nil) then CastSpellByName("Attack") end
			if(IsSpellReady("Hammer of Justice") and CheckInteractDistance('target', 2) and not UnitIsBoss("target")) then
				--Hammer of Justice
				UseAction(GetSlot("Hammer of Justice"))
			elseif(IsSpellReady("Seal of Wisdom") and PrctMana < 33 and not SealBuff) then
				--Seal of Wisdom
				UseAction(GetSlot("Seal of Wisdom"))
			elseif(IsSpellReady("Seal of Righteousness") and not SealBuff) then
				--Seal of Righteousness
				UseAction(GetSlot("Seal of Righteousness"))
			elseif(IsSpellReady("Hammer of Wrath") and not CheckInteractDistance('target', 2)) then
				--Hammer of Wrath
				UseAction(GetSlot("Hammer of Wrath"))
			elseif(IsSpellReady("Exorcism") and ((UnitCreatureType('target') == 'Undead') or (UnitCreatureType('target') == 'Demon')) and (PrctMana > 33)) then
				--Exorcism
				UseAction(GetSlot("Exorcism"))
			elseif(IsSpellReady("Judgement") and SealBuff and ((PrctMana > 20) or (SoWBuff and not SoWDebuff and UnitIsElite("target"))) and (AATimer > 1.0)) then
				--Judgement
				UseAction(GetSlot("Judgement"))
			elseif(IsSpellReady("Holy Shield") and HasAggro and (PrctMana > 20)) then
				--Holy Shield
				UseAction(GetSlot("Holy Shield"))
			elseif(IsSpellReady("Consecration") and CheckInteractDistance('target', 2) and SealBuff and (AATimer > 1.0)) then
				--Consecration
				UseAction(GetSlot("Consecration"))
			end
		end
	end
end

local function HealGroup(indexP)
	local HpRatio = PrctHp[indexP]
	if(indexP == 0) then
		local ForbearanceDebuff = GetUnitDebuff("player", ForbearanceTexture)
		if(IsSpellReady("Lay on hands") and (HpRatio < 15) and Combat) then
			--Lay on hands
			UseAction(GetSlot("Lay on hands"), 0, 1)
			return 0
		elseif((IsSpellReady("Divine Protection") or IsSpellReady("Divine Shield")) and (HpRatio < 20) and Combat and not ForbearanceDebuff) then
			--Divine Protection/Divine Shield
			UseAction(GetSlot("Divine Protection")) UseAction(GetSlot("Divine Shield"))
			return 0
		elseif((HpRatio < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
			--Healthstone
			PlaceItem(120, "Healthstone") UseAction(120)
			return 0
		elseif((HpRatio < 35) and HasHPotion() and (GetHPotionCD() < 1.25) and Combat) then
			--Healing Potion
			PlaceItem(120, "Healing Potion") UseAction(120)
			return 0
		elseif(IsSpellReady("Flash of Light") and not HasAggro and (HpRatio < 25) and (AATimer > 1.0)) then
			--Flash of Light
			UseAction(GetSlot("Flash of Light"), 0, 1)
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Holy Light") and not HasAggro and (HpRatio < 40) and (AATimer > 2.0)) then
			--Holy Light
			UseAction(GetSlot("Holy Light"), 0, 1)
			LastTarget = indexP
			return 0
		end
	elseif((indexP > 0) and (IsInRaid() == false)) then
		local ForbearanceDebuff = GetUnitDebuff("party"..indexP, ForbearanceTexture)
		local BoSacrificeBuff = GetUnitBuff("party"..indexP, BoSacrificeTexture)
		if(IsSpellReady("Lay on hands") and (HpRatio < 15) and Combat) then
			--Lay on hands
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Lay on hands"))
			TargetLastEnemy()
			return 0
		elseif(IsSpellReady("Blessing of Protection") and (HpRatio < 20) and not ForbearanceDebuff and Combat) then
			--Blessing of Protection
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Blessing of Protection"))
			TargetLastEnemy()
			return 0
		elseif(IsSpellReady("Blessing of Sacrifice") and (HpRatio < 50) and not BoSacrificeBuff and Combat) then
			--Blessing of Sacrifice
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Blessing of Sacrifice"))
			TargetLastEnemy()
			return 0
		end
	elseif(indexP > 0) then
		local ForbearanceDebuff = GetUnitDebuff("raid"..indexP, ForbearanceTexture)
		local BoSacrificeBuff = GetUnitBuff("raid"..indexP, BoSacrificeTexture)
		if(IsSpellReady("Lay on hands") and (HpRatio < 15) and Combat) then
			--Lay on hands
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Lay on hands"))
			TargetLastEnemy()
			return 0
		elseif(IsSpellReady("Blessing of Protection") and (HpRatio < 20) and not ForbearanceDebuff and Combat) then
			--Blessing of Protection
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Blessing of Protection"))
			TargetLastEnemy()
			return 0
		elseif(IsSpellReady("Blessing of Sacrifice") and (HpRatio < 50) and not BoSacrificeBuff and Combat) then
			--Blessing of Sacrifice
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Blessing of Sacrifice"))
			TargetLastEnemy()
			return 0
		end
	end
	return 1
end

function PaladinHeal_Tank()
	local BubbleBuff, _, BubbleIndex = GetUnitBuff("player", BubbleTexture)
	if(((CastingInfo == "Holy Light") and (PrctHp[LastTarget] > 60)) or ((CastingInfo == "Flash of Light") and (PrctHp[LastTarget] > 80))) then
		--Stop Casting
		SpellStopCasting()
	elseif(BubbleBuff and (PrctHp[0] > 70)) then
		--Cancel Bubble
		CancelPlayerBuff(BubbleIndex)
	elseif(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		local BoWisdomBuff = GetUnitBuff("player", BoWisdomTexture)
		local BoSanctuaryBuff = GetUnitBuff("player", BoSanctuaryTexture)
		local DevotionAuraBuff = GetUnitBuff("player", DevotionAuraTexture)
		local RetributionAuraBuff = GetUnitBuff("player", RetributionAuraTexture)
		local RighteousFuryBuff = GetUnitBuff("player", RighteousFuryTexture)
		local BoSalvationKey = GetBuffKey(BoSalvationTexture)
		local BoWisdomKey = GetBuffKey(BoWisdomTexture, 0)
		local PurifyDispelKey = GetDispelKey("Disease", "Poison")
		local CleanseDispelKey = GetDispelKey("Disease", "Poison", "Magic")
		HasAggro = PlayerHasAggro()
		if(IsPlayerSpell("Retribution Aura") and not RetributionAuraBuff) then
			--Retribution Aura
			CastSpellByName("Retribution Aura")
		elseif(IsPlayerSpell("Righteous Fury") and not RighteousFuryBuff) then
			--Righteous Fury
			UseAction(GetSlot("Righteous Fury"))
		elseif(not IsFollowing and not Combat and IsSpellReady("Redemption") and (GetGroupDead(1) > 0)) then
			--Redemption
			TargetUnit(tar..GetGroupDead(1))
			UseAction(GetSlot("Redemption"))
		elseif(not IsPlayerSpell("Blessing of Sanctuary") and IsSpellReady("Blessing of Wisdom") and not BoWisdomBuff) then
			--Blessing of Wisdom (self)
			UseAction(GetSlot("Blessing of Wisdom"), 0, 1)
		elseif(IsSpellReady("Blessing of Sanctuary") and not BoSanctuaryBuff) then
			--Blessing of Sanctuary (self)
			UseAction(GetSlot("Blessing of Sanctuary"), 0, 1)
		elseif(IsSpellReady("Blessing of Wisdom") and (BoWisdomKey > 0)) then
			--Blessing of Wisdom (Groupe)
			if(IsInRaid()) then TargetUnit("raid"..BoWisdomKey)
			else TargetUnit("party"..BoWisdomKey) end
			UseAction(GetSlot("Blessing of Wisdom"))
			if(Combat) then TargetLastEnemy() end
		elseif(IsSpellReady("Blessing of Salvation") and (BoSalvationKey > 0)) then
			--Blessing of Salvation (Groupe)
			if(IsInRaid()) then TargetUnit("raid"..BoSalvationKey)
			else TargetUnit("party"..BoSalvationKey) end
			UseAction(GetSlot("Blessing of Salvation"))
			if(Combat) then TargetLastEnemy() end
		elseif(Combat and (PrctMana < 10) and ((PrctHp[0] > 50) or not HasHPotion()) and HasMPotion() and (GetMPotionCD() < 1.25)) then
			--Mana Potion
			PlaceItem(120, "Mana Potion") UseAction(120)
		elseif(IsSpellReady("Purify") and GetUnitDispel("player", "Disease", "Poison") and (PrctMana > 25)) then
			--Purify (self)
			UseAction(GetSlot("Purify"), 0, 1)
		elseif(IsSpellReady("Purify") and (PurifyDispelKey > 0) and (PrctMana > 25)) then
			--Purify (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..PurifyDispelKey)
			else
				TargetUnit("party"..PurifyDispelKey)
			end
			UseAction(GetSlot("Purify"))
			TargetLastEnemy()
		elseif(IsSpellReady("Cleanse") and GetUnitDispel("player", "Disease", "Poison", "Magic") and (PrctMana > 25)) then
			--Cleanse (self)
			UseAction(GetSlot("Cleanse"), 0, 1)
		elseif(IsSpellReady("Cleanse") and (CleanseDispelKey > 0) and (PrctMana > 25)) then
			--Cleanse (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..CleanseDispelKey)
			else
				TargetUnit("party"..CleanseDispelKey)
			end
			UseAction(GetSlot("Cleanse"))
			TargetLastEnemy()
		else
			local tmp = 1; local index = 0
			while(tmp == 1 and index <= GetNumGroupMembers()) do
				tmp = HealGroup(HealTargetTab[index])
				index = index + 1
			end
			if(tmp == 1) then PaladinDps() end
		end
	end
end

function Paladin_Tank_OnUpdate(elapsed)
	GodModeVanilla.Pixel:SetTexture(0, 0, 0)
end

function Paladin_Tank_OnLoad()  --Map Update
	--
end