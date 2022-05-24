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
		if((UnitCanAttack("player", "target") == nil) and Combat) then CastSpellByName("Attaque") end
		if(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			local SoRBuff = GetUnitBuff("player", SoRTexture)
			local SoWBuff = GetUnitBuff("player", SoWTexture)
			local SealBuff = SoRBuff or SoWBuff
			local SoWDebuff = GetUnitDebuff("target", SoWTexture)
			if(IsCurrentAction(GetSlot("Attaque")) == nil) then CastSpellByName("Attaque") end
			if(IsSpellReady("Marteau de la justice") and CheckInteractDistance('target', 2) and not UnitIsBoss("target")) then
				--Hammer of Justice
				UseAction(GetSlot("Marteau de la justice"))
			elseif(IsSpellReady("Sceau de sagesse") and PrctMana < 33 and not SealBuff) then
				--Seal of Wisdom
				UseAction(GetSlot("Sceau de sagesse"))
			elseif(IsSpellReady("Sceau de piété") and not IsPlayerSpell("Sceau d'autorité") and not SealBuff) then
				--Seal of Righteousness
				UseAction(GetSlot("Sceau de piété"))
			elseif(IsSpellReady("Marteau de courroux") and not CheckInteractDistance('target', 2)) then
				--Hammer of Wrath
				UseAction(GetSlot("Marteau de courroux"))
			elseif(IsSpellReady("Exorcisme") and ((UnitCreatureType('target') == 'Mort-vivant') or (UnitCreatureType('target') == 'Démon')) and (PrctMana > 33)) then
				--Exorcism
				UseAction(GetSlot("Exorcisme"))
			elseif(IsSpellReady("Jugement") and SealBuff and ((PrctMana > 20) or (SoWBuff and not SoWDebuff and UnitIsElite("target"))) and (AATimer > 1.0)) then
				--Judgment
				UseAction(GetSlot("Jugement"))
			elseif(IsSpellReady("Bouclier sacré") and HasAggro and (PrctMana > 20)) then
				--Holy Shield
				UseAction(GetSlot("Bouclier sacré"))
			elseif(IsSpellReady("Consécration") and CheckInteractDistance('target', 2) and SealBuff and (AATimer > 1.0)) then
				--Consecration
				UseAction(GetSlot("Consécration"))
			end
		end
	end
end

function PaladinHeal_Tank()
	local BubbleBuff, _, BubbleIndex = GetUnitBuff("player", BubbleTexture)
	if(((CastingInfo == "Lumière sacrée") and (PrctHp[LastTarget] > 60)) or ((CastingInfo == "Eclair lumineux") and (PrctHp[LastTarget] > 80))) then
		--Stop Casting
		SpellStopCasting()
	elseif(BubbleBuff and (PrctHp[0] > 70)) then
		--Cancel Bubble
		CancelPlayerBuff(BubbleIndex)
	elseif(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		LastTarget = HealTarget
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
		if(IsPlayerSpell("Aura de vindicte") and not RetributionAuraBuff) then
			--Retribution Aura
			UseAction(GetSlot("Aura de vindicte"))
		elseif(IsPlayerSpell("Fureur vertueuse") and not RighteousFuryBuff) then
			--Righteous Fury
			UseAction(GetSlot("Fureur vertueuse"))
		elseif(not IsFollowing and not Combat and IsSpellReady("Rédemption") and (GetGroupDead(1) > 0)) then
			--Redemption
			TargetUnit(tar..GetGroupDead(1))
			UseAction(GetSlot("Rédemption"))
		elseif(not IsPlayerSpell("Bénédiction du sanctuaire") and IsSpellReady("Bénédiction de sagesse") and not BoWisdomBuff) then
			--Blessing of Wisdom (self)
			UseAction(GetSlot("Bénédiction de sagesse"), 0, 1)
		elseif(IsSpellReady("Bénédiction du sanctuaire") and not BoSanctuaryBuff) then
			--Blessing of Sanctuary (self)
			UseAction(GetSlot("Bénédiction du sanctuaire"), 0, 1)
		elseif(IsSpellReady("Bénédiction de sagesse") and (BoWisdomKey > 0)) then
			--Blessing of Wisdom (Groupe)
			if(IsInRaid()) then TargetUnit("raid"..BoWisdomKey)
			else TargetUnit("party"..BoWisdomKey) end
			UseAction(GetSlot("Bénédiction de sagesse"))
			if(Combat) then TargetLastEnemy() end
		elseif(IsSpellReady("Bénédiction de salut") and (BoSalvationKey > 0)) then
			--Blessing of Salvation (Groupe)
			if(IsInRaid()) then TargetUnit("raid"..BoSalvationKey)
			else TargetUnit("party"..BoSalvationKey) end
			UseAction(GetSlot("Bénédiction de salut"))
			if(Combat) then TargetLastEnemy() end
		elseif(Combat and (PrctMana < 10) and ((PrctHp[0] > 50) or not HasHPotion()) and HasMPotion() and (GetMPotionCD() < 1.25)) then
			--Mana Potion
			PlaceItem(120, "Potion de mana") UseAction(120)
		elseif(IsSpellReady("Purification") and GetUnitDispel("player", "Disease", "Poison") and (HpRatio > 50) and (PrctMana > 25)) then
			--Purify (self)
			UseAction(GetSlot("Purification"), 0, 1)
		elseif(IsSpellReady("Purification") and (PurifyDispelKey > 0) and (HpRatio > 50) and (PrctMana > 25)) then
			--Purify (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..PurifyDispelKey)
			else
				TargetUnit("party"..PurifyDispelKey)
			end
			UseAction(GetSlot("Purification"))
			TargetLastEnemy()
		elseif(IsSpellReady("Epuration") and GetUnitDispel("player", "Disease", "Poison", "Magic") and (HpRatio > 50) and (PrctMana > 25)) then
			--Cleanse (self)
			UseAction(GetSlot("Epuration"), 0, 1)
		elseif(IsSpellReady("Epuration") and (CleanseDispelKey > 0) and (HpRatio > 50) and (PrctMana > 25)) then
			--Cleanse (Groupe)
			if(IsInRaid()) then
				TargetUnit("raid"..CleanseDispelKey)
			else
				TargetUnit("party"..CleanseDispelKey)
			end
			UseAction(GetSlot("Epuration"))
			TargetLastEnemy()
		elseif((HealTarget == 0) or (PrctHp[0] < 25)) then
			local ForbearanceDebuff = GetUnitDebuff("player", ForbearanceTexture)
			if(IsSpellReady("Imposition des mains") and (HpRatio < 15) and Combat) then
				--Lay on hands
				UseAction(GetSlot("Imposition des mains"), 0, 1)
			elseif((IsSpellReady("Protection divine") or IsSpellReady("Bouclier divin")) and (HpRatio < 20) and Combat and not ForbearanceDebuff) then
				--Divine Protection/Divine Shield
				UseAction(GetSlot("Protection divine")) UseAction(GetSlot("Bouclier divin"))
			elseif((HpRatio < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
				--Healthstone
				PlaceItem(120, "Pierre de soins") UseAction(120)
			elseif((HpRatio < 35) and HasHPotion() and (GetHPotionCD() < 1.25) and Combat) then
				--Healing Potion
				PlaceItem(120, "Potion de soins") UseAction(120)
			elseif(IsSpellReady("Eclair lumineux") and not HasAggro and (HpRatio < 25)) then
				--Flash of Light
				UseAction(GetSlot("Eclair lumineux"), 0, 1)
			elseif(IsSpellReady("Lumière sacrée") and not HasAggro and (HpRatio < 40)) then
				--Holy Light
				UseAction(GetSlot("Lumière sacrée"), 0, 1)
			else
				PaladinDps()
			end
		elseif((HealTarget > 0) and (IsInRaid() == false)) then
			local ForbearanceDebuff = GetUnitDebuff("party"..HealTarget, ForbearanceTexture)
			local BoSacrificeBuff = GetUnitBuff("party"..HealTarget, BoSacrificeTexture)
			if(IsSpellReady("Imposition des mains") and (HpRatio < 15) and Combat) then
				--Lay on hands
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Imposition des mains"))
				TargetLastEnemy()
			elseif(IsSpellReady("Bénédiction de protection") and (HpRatio < 20) and not ForbearanceDebuff and Combat) then
				--Blessing of Protection
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Bénédiction de protection"))
				TargetLastEnemy()
			elseif(IsSpellReady("Bénédiction de sacrifice") and (HpRatio < 50) and not BoSacrificeBuff and Combat) then
				--Blessing of Sacrifice
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Bénédiction de sacrifice"))
				TargetLastEnemy()
			else
				PaladinDps()
			end
		elseif(HealTarget > 0) then
			local ForbearanceDebuff = GetUnitDebuff("raid"..HealTarget, ForbearanceTexture)
			local BoSacrificeBuff = GetUnitBuff("raid"..HealTarget, BoSacrificeTexture)
			if(IsSpellReady("Imposition des mains") and (HpRatio < 15) and Combat) then
				--Lay on hands
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Imposition des mains"))
				TargetLastEnemy()
			elseif(IsSpellReady("Bénédiction de protection") and (HpRatio < 20) and not ForbearanceDebuff and Combat) then
				--Blessing of Protection
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Bénédiction de protection"))
				TargetLastEnemy()
			elseif(IsSpellReady("Bénédiction de sacrifice") and (HpRatio < 50) and not BoSacrificeBuff and Combat) then
				--Blessing of Sacrifice
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Bénédiction de sacrifice"))
				TargetLastEnemy()
			else
				PaladinDps()
			end
		end
	end
end

function Paladin_Tank_OnUpdate(elapsed)
	GodModeVanilla.Pixel:SetTexture(0, 0, 0)
end

function Paladin_Tank_OnLoad()  --Map Update
	--
end