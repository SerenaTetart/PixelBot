--Variables
SliceDiceDuration = 0

--Texture
SliceDiceTexture = "Interface\\Icons\\Ability_Rogue_SliceDice"
GougeTexture = "Interface\\Icons\\Ability_Gouge"
BlindTexture = "Interface\\Icons\\Spell_Shadow_MindSteal"

function RogueDps()
	if(CastingInfo == nil) then
		if(Combat and UnitCanAttack("player", "target") and UnitAffectingCombat("target") == nil) then ClearTarget()
		elseif(Combat and ((UnitCanAttack("player", "target") == nil) or (CheckInteractDistance("target", 4) == nil))) then TargetNearestEnemy() end
		local _,_,Stealthing = GetShapeshiftFormInfo(1)
		if((UnitCanAttack("player", "target") == nil) and Stealthing) then
			--Stop Stealth
			CastSpellByName("Stealth")
		elseif(not Stealthing and (PrctHp[0] < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
			--Healthstone
			PlaceItem(120, "Healthstone")
		elseif(not Stealthing and (PrctHp[0] < 35) and HasHPotion() and (GetItemCooldownDuration(118) < 1.25) and Combat) then
			--Healing Potion
			PlaceItem(120, "Healing Potion")
		elseif(not Stealthing and IsSpellReady("Evasion") and (PrctHp[0] < 70) and PlayerHasAggro()) then
			--Evasion
			UseAction(GetSlot("Evasion"))
		elseif(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			local SliceDiceBuff = GetUnitBuff("player", SliceDiceTexture)
			local GougeDebuff = GetUnitDebuff("target", GougeTexture)
			local BlindDebuff = GetUnitDebuff("target", BlindTexture)
			if((IsCurrentAction(GetSlot("Attack")) == nil) and not Stealthing and not GougeDebuff and not BlindDebuff) then UseAction(GetSlot("Attack")) end
			if(IsSpellReady("Stealth") and not Stealthing) then
				--Stealth
				CastSpellByName("Stealth")
			elseif(IsSpellReady("Cheap Shot")) then
				--Cheap Shot
				UseAction(GetSlot("Cheap Shot"))
			elseif(IsSpellReady("Feint") and TargetIsAggro("target") and not UnitPlayerControlled("target")) then
				--Feint (panic)
				UseAction(GetSlot("Feint"))
			elseif(IsSpellReady("Adrenaline Rush") and UnitIsElite("target") and SliceDiceBuff) then
				--Adrenaline Rush
				UseAction(GetSlot("Adrenaline Rush"))
			elseif(IsSpellReady("Blade Flurry") and ((NbrEnemyAggro >= 2) or UnitPlayerControlled("target")) and (SliceDiceDuration >= 15)) then
				--Blade Flurry
				UseAction(GetSlot("Blade Flurry"))
			elseif(IsSpellReady("Slice and Dice") and (((GetComboPoints() >= 3) and not SliceDiceBuff) or (SliceDiceDuration < 8 and (GetComboPoints() >= 5)))) then
				--Slice and Dice
				local _,_,_,_,SliceDiceTalent = GetTalentInfo(1, 6)
				SliceDiceDuration = (6+(3*GetComboPoints()))*(1+(0.15*SliceDiceTalent))
				UseAction(GetSlot("Slice and Dice"))
			elseif(IsSpellReady("Kidney Shot") and (GetComboPoints() >= 3) and UnitPlayerControlled("target")) then
				--Kidney Shot
				UseAction(GetSlot("Kidney Shot"))
			elseif(IsSpellReady("Eviscerate") and (GetComboPoints() >= 5) and SliceDiceDuration >= 8) then
				--Eviscerate
				UseAction(GetSlot("Eviscerate"))
			elseif(IsSpellReady("Kick") and UnitIsCaster("target") and not IsStunned("target")) then
				--Kick
				UseAction(GetSlot("Kick"))
			elseif(IsSpellReady("Sinister Strike")) then
				--Sinister Strike
				UseAction(GetSlot("Sinister Strike"))
			end
		end
	end
end

function Rogue_OnUpdate(elapsed)
	FollowMultibox("Sapphire")
	SliceDiceDuration = UpdateTimer(SliceDiceDuration)
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end