local LastTarget = 0

--Variables


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
			local SoRBuff = GetUnitBuff("player", SoRTexture)
			local SotCBuff = GetUnitBuff("player", SotCTexture)
			local SoCBuff = GetUnitBuff("player", SoCTexture)
			local SealBuff = SoRBuff or SotCBuff or SoCBuff
			local SotCDebuff = GetUnitDebuff("target", SotCTexture)
			if(IsCurrentAction(GetSlot("Attack")) == nil) then CastSpellByName("Attack") end
			if(IsSpellReady("Seal of the Crusader") and UnitIsElite("target") and not SotCDebuff and not SealBuff) then
				--Seal of the Crusader
				UseAction(GetSlot("Seal of the Crusader"))
			elseif(IsSpellReady("Seal of Righteousness") and not IsPlayerSpell("Seal of Command") and not SealBuff) then
				--Seal of Righteousness
				UseAction(GetSlot("Seal of Righteousness"))
			elseif(IsSpellReady("Seal of Command") and not SealBuff) then
				--Seal of Command
				UseAction(GetSlot("Seal of Command"))
			elseif(IsSpellReady("Hammer of Wrath") and (AATimer > 1.0)) then
				--Hammer of Wrath
				UseAction(GetSlot("Hammer of Wrath"))
			elseif(IsSpellReady("Exorcism") and ((UnitCreatureType('target') == 'Undead') or (UnitCreatureType('target') == 'Demon')) and (PrctMana > 33)) then
				--Exorcism
				UseAction(GetSlot("Exorcism"))
			elseif(IsSpellReady("Judgement") and SealBuff and ((PrctMana > 33) or SotCBuff) and (AATimer > 1.0)) then
				--Judgement
				UseAction(GetSlot("Judgement"))
			elseif(IsSpellReady("Hammer of Justice") and not IsStunned("target") and CheckInteractDistance('target', 2) and not UnitIsBoss("target")) then
				--Hammer of Justice
				UseAction(GetSlot("Hammer of Justice"))
			elseif(IsSpellReady("Consecration") and CheckInteractDistance('target', 2) and (PrctMana > 50)) then
				--Consecration
				UseAction(GetSlot("Consecration"))
			end
		end
	end
end

local function HealGroup(indexP)
	local HpRatio = PrctHp[indexP]
	if((indexP == 0) or (PrctHp[0] < 25)) then
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
		elseif(IsSpellReady("Holy Light") and (HpRatio < 40) and (AATimer > 2.0)) then
			--Holy Light
			UseAction(GetSlot("Holy Light"), 0, 1)
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Flash of Light") and (HpRatio < 80) and (AATimer > 1.0)) then
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
		elseif(IsSpellReady("Holy Light") and (HpRatio < 40) and (AATimer > 2.0)) then
			--Holy Light
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Holy Light"))
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Flash of Light") and (HpRatio < 80) and (AATimer > 1.0)) then
			--Flash of Light
			TargetUnit("party"..indexP)
			UseAction(GetSlot("Flash of Light"))
			LastTarget = indexP
			return 0
		end
	elseif(indexP > 0) then
		local ForbearanceDebuff = GetUnitDebuff("raid"..indexP, ForbearanceTexture)
		local BoSacrificeBuff = GetUnitBuff("raid"..indexP, BoSacrificeTexture)
		if(IsSpellReady("Imposition des mains") and (HpRatio < 15) and Combat) then
			--Lay on hands
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Imposition des mains"))
			return 0
		elseif(IsSpellReady("Bénédiction de protection") and (HpRatio < 20) and not ForbearanceDebuff and Combat) then
			--Blessing of Protection
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Bénédiction de protection"))
			return 0
		elseif(IsSpellReady("Bénédiction de sacrifice") and (HpRatio < 50) and not BoSacrificeBuff and Combat) then
			--Blessing of Sacrifice
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Bénédiction de sacrifice"))
			return 0
		elseif(IsSpellReady("Holy Light") and (HpRatio < 40) and (AATimer > 2.0)) then
			--Holy Light
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Holy Light"))
			LastTarget = indexP
			return 0
		elseif(IsSpellReady("Flash of Light") and (HpRatio < 80) and (AATimer > 1.0)) then
			--Flash of Light
			TargetUnit("raid"..indexP)
			UseAction(GetSlot("Flash of Light"))
			LastTarget = indexP
			return 0
		end
	end
	return 1
end

function PaladinHeal_Dps()
	if(((CastingInfo == "Holy Light") and (PrctHp[LastTarget] > 85)) or ((CastingInfo == "Flash of Light") and (PrctHp[LastTarget] > 95))) then
		--Stop Casting
		SpellStopCasting()
	elseif(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		local BoKingsBuff = GetUnitBuff("player", BoKingsTexture)
		local BoWisdomBuff = GetUnitBuff("player", BoWisdomTexture)
		local SanctityAuraBuff = GetUnitBuff("player", SanctityAuraTexture)
		local RetributionAuraBuff = GetUnitBuff("player", RetributionAuraTexture)
		local BoKingsKey = GetBuffKey(BoKingsTexture)
		local BoWisdomKey = GetBuffKey(BoWisdomTexture)
		local PurifyDispelKey = GetDispelKey("Disease", "Poison")
		local CleanseDispelKey = GetDispelKey("Disease", "Poison", "Magic")
		if(not IsPlayerSpell("Sanctity Aura") and IsPlayerSpell("Retribution Aura") and not RetributionAuraBuff) then
			--Retribution Aura
			CastSpellByName("Retribution Aura")
		elseif(IsPlayerSpell("Sanctity Aura") and not SanctityAuraBuff) then
			--Sanctity Aura
			CastSpellByName("Sanctity Aura")
		elseif(not IsFollowing and not Combat and IsSpellReady("Redemption") and (GetGroupDead(1) > 0)) then
			--Redemption
			TargetUnit(tar..GetGroupDead(1))
			UseAction(GetSlot("Redemption"))
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

function Paladin_Dps_OnUpdate(elapsed)
	FollowMultibox("Nihal")
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end

function Paladin_Dps_OnLoad()  --Map Update
	--
end