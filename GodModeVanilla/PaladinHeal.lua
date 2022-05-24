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
		if(IsInGroup()) then AssistUnit(GetTank()) if((UnitCanAttack("player", "target") == nil) and Combat) then CastSpellByName("Attaque") end end
		if(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			local SoLBuff = GetUnitBuff("player", SoLTexture)
			local SoLDebuff = GetUnitDebuff("target", SoLTexture)
			if(CheckInteractDistance("target", 4) and IsFollowing) then TimerGodMode = 0.5 BlueBool = 6 end
			if(IsCurrentAction(GetSlot("Attaque")) == nil) then CastSpellByName("Attaque") end
			if(IsSpellReady("Sceau de lumière") and (PrctMana > 33) and UnitIsElite("target") and not SoLDebuff and not SoLBuff) then
				--Seal of Light
				UseAction(GetSlot("Sceau de lumière"))
			elseif(IsSpellReady("Jugement") and SealBuff and SoLBuff) then
				--Judgment
				UseAction(GetSlot("Jugement"))
			elseif(IsSpellReady("Marteau de la justice") and not IsStunned("target") and CheckInteractDistance('target', 2) and not UnitIsBoss("target")) then
				--Hammer of Justice
				UseAction(GetSlot("Marteau de la justice"))
			elseif(IsSpellReady("Exorcisme") and ((UnitCreatureType('target') == 'Mort-vivant') or (UnitCreatureType('target') == 'Démon')) and (PrctMana > 33)) then
				--Exorcism
				UseAction(GetSlot("Exorcisme"))
			elseif(IsSpellReady("Consécration") and CheckInteractDistance('target', 2) and (PrctMana > 50)) then
				--Consecration
				UseAction(GetSlot("Consécration"))
			end
		end
	end
end

function PaladinHeal_Heal()
	if(((CastingInfo == "Lumière sacrée") and (PrctHp[LastTarget] > 85)) or ((CastingInfo == "Eclair lumineux") and (PrctHp[LastTarget] > 95))) then
		--Stop Casting
		SpellStopCasting()
	elseif(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		LastTarget = HealTarget
		local BoKingsBuff = GetUnitBuff("player", BoKingsTexture)
		local BoWisdomBuff = GetUnitBuff("player", BoWisdomTexture)
		local DevotionAuraBuff = GetUnitBuff("player", DevotionAuraTexture)
		local BoKingsKey = GetBuffKey(BoKingsTexture)
		local BoWisdomKey = GetBuffKey(BoWisdomTexture)
		local PurifyDispelKey = GetDispelKey("Disease", "Poison")
		local CleanseDispelKey = GetDispelKey("Disease", "Poison", "Magic")
		if(IsPlayerSpell("Aura de dévotion") and not DevotionAuraBuff) then
			--Devotion Aura
			CastSpellByName("Aura de dévotion")
		elseif(not IsFollowing and not Combat and IsSpellReady("Rédemption") and (GetGroupDead(1) > 0)) then
			--Redemption
			TargetUnit(tar..GetGroupDead(1))
			UseAction(GetSlot("Rédemption"))
		elseif(not IsFollowing and not Combat and not DrinkingBuff and (PrctMana < 33) and (HasDrink() > 0)) then
			--Drink
			PlaceItem(120, HasDrink()) UseAction(120)
		elseif(IsSpellReady("Bénédiction des rois") and not BoKingsBuff and not Combat) then
			--Blessing of Kings (self)
			UseAction(GetSlot("Bénédiction des rois"), 0, 1)
		elseif(not IsPlayerSpell("Bénédiction des rois") and IsSpellReady("Bénédiction de sagesse") and not BoWisdomBuff) then
			--Blessing of Wisdom (self)
			UseAction(GetSlot("Bénédiction de sagesse"), 0, 1)
		elseif(IsSpellReady("Bénédiction des rois") and (BoKingsKey > 0) and not Combat) then
			--Blessing of Kings (Groupe)
			if(IsInRaid()) then TargetUnit("raid"..BoKingsKey)
			else TargetUnit("party"..BoKingsKey) end
			UseAction(GetSlot("Bénédiction des rois"))
		elseif(not IsPlayerSpell("Bénédiction des rois") and IsSpellReady("Bénédiction de sagesse") and (BoWisdomKey > 0)) then
			--Blessing of Wisdom (Groupe)
			if(IsInRaid()) then TargetUnit("raid"..BoWisdomKey)
			else TargetUnit("party"..BoWisdomKey) end
			UseAction(GetSlot("Bénédiction de sagesse"))
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
		elseif((HealTarget == 0) or (PrctHp[0] < 25)) then
			local ForbearanceDebuff = GetUnitDebuff("player", ForbearanceTexture)
			if(IsSpellReady("Imposition des mains") and (HpRatio < 15) and Combat) then
				--Lay on hands
				UseAction(GetSlot("Imposition des mains"), 0, 1)
			elseif((IsSpellReady("Protection divine") or IsSpellReady("Bouclier divin")) and (HpRatio < 25) and Combat and not ForbearanceDebuff) then
				--Divine Protection/Divine Shield
				UseAction(GetSlot("Protection divine")) UseAction(GetSlot("Bouclier divin"))
			elseif((HpRatio < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
				--Healthstone
				PlaceItem(120, "Pierre de soins") UseAction(120)
			elseif((HpRatio < 35) and HasHPotion() and (GetHPotionCD() < 1.25) and Combat) then
				--Healing Potion
				PlaceItem(120, "Potion de soins") UseAction(120)
			elseif(IsSpellReady("Horion sacré") and (HpRatio < 50)) then
				--Holy Shock
				UseAction(GetSlot("Horion sacré"), 0, 1)
			elseif(IsSpellReady("Lumière sacrée") and (HpRatio < 50)) then
				--Holy Light
				UseAction(GetSlot("Lumière sacrée"), 0, 1)
			elseif(IsSpellReady("Eclair lumineux") and (HpRatio < 80)) then
				--Flash of Light
				UseAction(GetSlot("Eclair lumineux"), 0, 1)
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
			elseif(IsSpellReady("Bénédiction de protection") and (HpRatio < 20) and not ForbearanceDebuff and Combat) then
				--Blessing of Protection
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Bénédiction de protection"))
			elseif(IsSpellReady("Bénédiction de sacrifice") and (HpRatio < 50) and not BoSacrificeBuff and Combat) then
				--Blessing of Sacrifice
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Bénédiction de sacrifice"))
			elseif(IsSpellReady("Horion sacré") and (HpRatio < 50)) then
				--Holy Shock
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Horion sacré"))
			elseif(IsSpellReady("Lumière sacrée") and (HpRatio < 50)) then
				--Holy Light
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Lumière sacrée"))
			elseif(IsSpellReady("Eclair lumineux") and (HpRatio < 80)) then
				--Flash of Light
				TargetUnit("party"..HealTarget)
				UseAction(GetSlot("Eclair lumineux"))
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
			elseif(IsSpellReady("Bénédiction de protection") and (HpRatio < 20) and not ForbearanceDebuff and Combat) then
				--Blessing of Protection
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Bénédiction de protection"))
			elseif(IsSpellReady("Bénédiction de sacrifice") and (HpRatio < 50) and not BoSacrificeBuff and Combat) then
				--Blessing of Sacrifice
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Bénédiction de sacrifice"))
			elseif(IsSpellReady("Horion sacré") and (HpRatio < 50)) then
				--Holy Shock
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Horion sacré"))
			elseif(IsSpellReady("Lumière sacrée") and (HpRatio < 50)) then
				--Holy Light
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Lumière sacrée"))
			elseif(IsSpellReady("Eclair lumineux") and (HpRatio < 80)) then
				--Flash of Light
				TargetUnit("raid"..HealTarget)
				UseAction(GetSlot("Eclair lumineux"))
			else
				PaladinDps()
			end
		end
	end
end

function Paladin_Heal_OnUpdate(elapsed)
	FollowMultibox("Saelwyn")
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end

function Paladin_Heal_OnLoad()  --Map Update
	--
end