local LastTarget = 0

--Variables
HealingWaveRank = 1 HealingWaveValue = {} HealingWaveLevel = {1, 6, 12, 18, 24, 32, 40, 48, 56, 60}
ChainHealRank = 1 ChainHealValue = {} ChainHealLevel = {40, 46, 54}

local DrinkingBuff = ""

--Texture
BoMightTexture = "Interface\\Icons\\Spell_Holy_FistOfJustice"
BoWisdomTexture = "Interface\\Icons\\Spell_Holy_SealOfWisdom"
BoKingsTexture = "Interface\\Icons\\Spell_Magic_MageArmor"
SoRTexture = "Interface\\Icons\\Ability_ThunderBolt"
SotCTexture = "Interface\\Icons\\Spell_Holy_HolySmite"
SoCTexture = "Interface\\Icons\\Ability_Warrior_InnerRage"
ForbearanceTexture = "Interface\\Icons\\Spell_Holy_RemoveCurse"
BoSacrificeTexture = "Interface\\Icons\\Spell_Holy_SealOfSacrifice"
DevotionAuraTexture = "Interface\\Icons\\Spell_Holy_DevotionAura"
SanctityAuraTexture = "Interface\\Icons\\Spell_Holy_MindVision"
RetributionAuraTexture = "Interface\\Icons\\Spell_Holy_AuraOfLight"


local function PaladinDps()
	if(CastingInfo == nil) then
		if(IsInGroup()) then AssistUnit(GetTank()) end
		if(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			local SoLBuff = GetUnitBuff("player", SoLTexture)
			local SoLDebuff = GetUnitDebuff("target", SoLTexture)
			if(CheckInteractDistance("target", 4) and IsFollowing) then TimerGodMode = 0.5 BlueBool = 6 end
			if(IsSpellReady("Seal of Light") and (PrctMana > 33) and UnitIsElite("target") and not SoLDebuff and not SoLBuff) then
				--Seal of Light
				UseAction(GetSlot("Seal of Light"))
			elseif(IsSpellReady("Judgement") and SealBuff and SoLBuff) then
				--Judgement
				UseAction(GetSlot("Judgement"))
			elseif(IsSpellReady("Hammer of Justice") and not IsStunned("target") and CheckInteractDistance('target', 2) and not UnitIsBoss("target")) then
				--Hammer of Justice
				UseAction(GetSlot("Hammer of Justice"))
			elseif(IsSpellReady("Exorcism") and ((UnitCreatureType('target') == 'Undead') or (UnitCreatureType('target') == 'Demon')) and (PrctMana > 33)) then
				--Exorcism
				UseAction(GetSlot("Exorcism"))
			elseif(IsSpellReady("Consecration") and CheckInteractDistance('target', 2) and (PrctMana > 50)) then
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
		elseif((IsSpellReady("Divine Protection") or IsSpellReady("Divine Shield")) and (HpRatio < 25) and Combat and not ForbearanceDebuff) then
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
		elseif(IsSpellReady("Holy Shock") and (HpRatio < 50)) then
			--Holy Shock
			UseAction(GetSlot("Holy Shock"), 0, 1)
			return 0
		elseif(IsSpellReady("Holy Light") and (HpRatio < 50)) then
			--Holy Light
			UseAction(GetSlot("Holy Light"), 0, 1)
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Flash of Light") and (HpRatio < 80)) then
			--Flash of Light
			UseAction(GetSlot("Flash of Light"), 0, 1)
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
			return 0
		elseif(IsSpellReady("Blessing of Protection") and (HpRatio < 20) and not ForbearanceDebuff and Combat) then
			--Blessing of Protection
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Blessing of Protection"))
			return 0
		elseif(IsSpellReady("Blessing of Sacrifice") and (HpRatio < 50) and not BoSacrificeBuff and Combat) then
			--Blessing of Sacrifice
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Blessing of Sacrifice"))
			return 0
		elseif(IsSpellReady("Holy Shock") and (HpRatio < 50)) then
			--Holy Shock
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Holy Shock"))
			return 0
		elseif(IsSpellReady("Holy Light") and (HpRatio < 50)) then
			--Holy Light
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Holy Light"))
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Flash of Light") and (HpRatio < 80)) then
			--Flash of Light
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Flash of Light"))
			LastTarget = indexP
			return 0
		end
	elseif(indexP > 0) then
		local ForbearanceDebuff = GetUnitDebuff("raid"..indexP, ForbearanceTexture)
		local BoSacrificeBuff = GetUnitBuff("raid"..indexP, BoSacrificeTexture)
		if(IsSpellReady("Lay on hands") and (HpRatio < 15) and Combat) then
			--Lay on hands
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Lay on hands"))
			return 0
		elseif(IsSpellReady("Blessing of Protection") and (HpRatio < 20) and not ForbearanceDebuff and Combat) then
			--Blessing of Protection
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Blessing of Protection"))
			return 0
		elseif(IsSpellReady("Blessing of Sacrifice") and (HpRatio < 50) and not BoSacrificeBuff and Combat) then
			--Blessing of Sacrifice
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Blessing of Sacrifice"))
			return 0
		elseif(IsSpellReady("Holy Shock") and (HpRatio < 50)) then
			--Holy Shock
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Holy Shock"))
			return 0
		elseif(IsSpellReady("Holy Light") and (HpRatio < 50)) then
			--Holy Light
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Holy Light"))
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Flash of Light") and (HpRatio < 80)) then
			--Flash of Light
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Flash of Light"))
			LastTarget = indexP
			return 0
		end
	end
	return 1
end

function PaladinHeal_Heal()
	if(((CastingInfo == "Holy Light") and (PrctHp[LastTarget] > 85)) or ((CastingInfo == "Flash of Light") and (PrctHp[LastTarget] > 95))) then
		--Stop Casting
		SpellStopCasting()
	elseif(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		local BoKingsBuff = GetUnitBuff("player", BoKingsTexture)
		local BoWisdomBuff = GetUnitBuff("player", BoWisdomTexture)
		local DevotionAuraBuff = GetUnitBuff("player", DevotionAuraTexture)
		local BoKingsKey = GetBuffKey(BoKingsTexture)
		local BoWisdomKey = GetBuffKey(BoWisdomTexture)
		local PurifyDispelKey = GetDispelKey("Disease", "Poison")
		local CleanseDispelKey = GetDispelKey("Disease", "Poison", "Magic")
		if(IsPlayerSpell("Devotion Aura") and not DevotionAuraBuff) then
			--Devotion Aura
			CastSpellByName("Devotion Aura")
		elseif(not IsFollowing and not Combat and IsSpellReady("Redemption") and (GetGroupDead(1) > 0)) then
			--Redemption
			TargetUnit(tar..GetGroupDead(1))
			UseAction(GetSlot("Redemption"))
		elseif(not IsFollowing and not Combat and not DrinkingBuff and (PrctMana < 33) and (HasDrink() > 0)) then
			--Drink
			PlaceItem(120, HasDrink()) UseAction(120)
		elseif(IsSpellReady("Blessing of Kings") and not BoKingsBuff and not Combat) then
			--Blessing of Kings (self)
			UseAction(GetSlot("Blessing of Kings"), 0, 1)
		elseif(not IsPlayerSpell("Blessing of Kings") and IsSpellReady("Blessing of Wisdom") and not BoWisdomBuff) then
			--Blessing of Wisdom (self)
			UseAction(GetSlot("Blessing of Wisdom"), 0, 1)
		elseif(IsSpellReady("Blessing of Kings") and (BoKingsKey > 0) and not Combat) then
			--Blessing of Kings (Groupe)
			if(IsInRaid()) then TargetUnit("raid"..BoKingsKey)
			else TargetUnit("party"..BoKingsKey) end
			UseAction(GetSlot("Blessing of Kings"))
		elseif(not IsPlayerSpell("Blessing of Kings") and IsSpellReady("Blessing of Wisdom") and (BoWisdomKey > 0)) then
			--Blessing of Wisdom (Groupe)
			if(IsInRaid()) then TargetUnit("raid"..BoWisdomKey)
			else TargetUnit("party"..BoWisdomKey) end
			UseAction(GetSlot("Blessing of Wisdom"))
		elseif(Combat and (PrctMana < 10) and ((PrctHp[0] > 50) or not HasHPotion()) and HasMPotion() and (GetMPotionCD() < 1.25)) then
			--Mana Potion
			PlaceItem(120, "Mana Potion") UseAction(120)
		elseif(IsSpellReady("Purify") and GetUnitDispel("player", "Disease", "Poison") and (HpRatio > 50) and (PrctMana > 25)) then
			--Purify (self)
			UseAction(GetSlot("Purify"), 0, 1)
		elseif(IsSpellReady("Purify") and (PurifyDispelKey > 0) and (HpRatio > 50) and (PrctMana > 25)) then
			--Purify (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..PurifyDispelKey)
			else
				TargetUnit("party"..PurifyDispelKey)
			end
			UseAction(GetSlot("Purify"))
		elseif(IsSpellReady("Cleanse") and GetUnitDispel("player", "Disease", "Poison", "Magic") and (HpRatio > 50) and (PrctMana > 25)) then
			--Cleanse (self)
			UseAction(GetSlot("Cleanse"), 0, 1)
		elseif(IsSpellReady("Cleanse") and (CleanseDispelKey > 0) and (HpRatio > 50) and (PrctMana > 25)) then
			--Cleanse (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..CleanseDispelKey)
			else
				TargetUnit("party"..CleanseDispelKey)
			end
			UseAction(GetSlot("Cleanse"))
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

function Paladin_Heal_OnUpdate(elapsed)
	DrinkingBuff = GetUnitBuff("player", DrinkingTexture)
	if(((PrctMana > 33) or (HasDrink() == 0)) and ((not DrinkingBuff) or (PrctMana > 80))) then FollowMultibox("Saelwyn") end
	if(DrinkingBuff and (PrctMana > 80)) then BlueBool = 4 end
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end

function Paladin_Heal_OnLoad()  --Map Update
	--
end