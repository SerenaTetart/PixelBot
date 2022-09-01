--Variables
local listRank = {"Ruby", "Citrine", "Jade", "Agate"}
local DrinkingBuff = ""

--Texture
ArcaneIntellectTexture = "Interface\\Icons\\Spell_Holy_MagicalSentry"
FrostArmorTexture = "Interface\\Icons\\Spell_Frost_FrostArmor02"
MageArmorTexture = "Interface\\Icons\\Spell_MageArmor"
IceBarrierTexture = "Interface\\Icons\\Spell_Ice_Lament"
ManaShieldTexture = "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility"

local function HasManaStone()
	if((GetItemCount(5514) > 0) or (GetItemCount(5513) > 0) or (GetItemCount(8007) > 0) or (GetItemCount(10054) > 0)) then
		return true
	else return false end
end

local function GetManaStoneCD()
	listID = {5514, 5513, 8007, 10054}
	for _,ID in ipairs(listID) do
		if(GetItemCount(ID) > 0) then return GetItemCooldownDuration(ID) end
	end
	return 99999
end

local function GetRankSpellList(coreTxt, list)
	for _,txt in pairs(list) do
		if(IsPlayerSpell(coreTxt..' '..txt)) then return (coreTxt..' '..txt) end
	end
end

function MageDps()
	if(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		local FrostArmorBuff = GetUnitBuff("player", FrostArmorTexture)
		local MageArmorBuff = GetUnitBuff("player", MageArmorTexture)
		local IceBarrierBuff = GetUnitBuff("player", IceBarrierTexture)
		local ManaShieldBuff = GetUnitBuff("player", ManaShieldTexture)
		local ArcaneIntellectBuff = GetUnitBuff("player", ArcaneIntellectTexture)
		local ArcaneIntellectKey = GetBuffKey(ArcaneIntellectTexture)
		local RankConjureMana = GetRankSpellList("Conjure Mana", listRank)
		if(IsInGroup()) then AssistUnit(GetTank()) end
		if(not IsPlayerSpell("Mage Armor") and IsSpellReady("Frost Armor") and not FrostArmorBuff) then
			--Frost Armor
			UseAction(GetSlot("Frost Armor"))
		elseif(IsSpellReady("Mage Armor") and not MageArmorBuff) then
			--Mage Armor
			UseAction(GetSlot("Mage Armor"))
		elseif(IsSpellReady("Arcane Intellect") and not ArcaneIntellectBuff) then
			--Arcane Intellect (self)
			UseAction(GetSlot("Arcane Intellect"), 0, 1)
		elseif(IsSpellReady("Arcane Intellect") and (ArcaneIntellectKey > 0)) then
			--Arcane Intellect (Groupe)
			if(IsInRaid()) then TargetUnit("raid"..ArcaneIntellectKey)
			else TargetUnit("party"..ArcaneIntellectKey) end
			UseAction(GetSlot("Arcane Intellect"))
		elseif(not Combat and IsSpellReady(RankConjureMana) and not HasManaStone()) then
			--Conjure Mana (stone)
			UseAction(GetSlot(RankConjureMana))
		elseif(IsSpellReady("Conjure Water", true) and not Combat and (HasDrink() == 0)) then
			--Conjure Water
			UseAction(GetSlot("Conjure Water"))
		elseif(not IsFollowing and not Combat and not DrinkingBuff and (PrctMana < 33) and (HasDrink() > 0)) then
			--Drink
			PlaceItem(120, HasDrink()) UseAction(120)
		elseif(IsSpellReady("Ice Barrier") and not IceBarrierBuff) then
			--Ice Barrier
			UseAction(GetSlot("Ice Barrier"))
		elseif(IsSpellReady("Mana Shield") and (PrctHp[0] < 25) and (PrctMana > 50) and not ManaShieldBuff) then
			--Mana Shield
			UseAction(GetSlot("Mana Shield"))
		elseif((PrctHp[0] < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
			--Healthstone
			PlaceItem(120, "Healthstone") UseAction(120)
		elseif((PrctHp[0] < 35) and HasHPotion() and (GetHPotionCD() < 1.25) and Combat) then
			--Healing Potion
			PlaceItem(120, "Healing Potion") UseAction(120)
		elseif((PrctMana < 15) and HasManaStone() and (GetManaStoneCD() < 1.25) and Combat) then
			--Mana Stone
			PlaceItem(120, "Mana ") UseAction(120)
		elseif((PrctMana < 15) and IsSpellReady("Evocation") and Combat) then
			--Evocation
			UseAction(GetSlot("Evocation"))
		elseif(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			if(CheckInteractDistance("target", 4) and IsFollowing) then
				if(not Combat) then TimerGodMode = 0.5 BlueBool = 7
				else TimerGodMode = 0.5 BlueBool = 6 end
			end
			if(IsSpellReady("Frost Nova") and CheckInteractDistance("target", 2)) then
				--Frost Nova
				UseAction(GetSlot("Frost Nova"))
			elseif(IsSpellReady("Cone of Cold") and CheckInteractDistance("target", 2) and UnitPlayerControlled("target")) then
				--Cone of Cold
				UseAction(GetSlot("Cone of Cold"))
			elseif(IsSpellReady("Fire Blast") and (IsFollowing or BlueBool > 0)) then
				--Fire Blast (Movement)
				UseAction(GetSlot("Fire Blast"))
			elseif(IsSpellReady("Frostbolt")) then
				--Frostbolt
				UseAction(GetSlot("Frostbolt"))
			elseif(HasWandEquipped() and not IsAutoRepeatAction(GetSlot("Wand"))) then
				--Wand
				UseAction(GetSlot("Wand"))
			elseif(IsSpellReady("Fireball")) then
				--Fireball
				UseAction(GetSlot("Fireball"))
			end
		end
	end
end

function Mage_OnUpdate(elapsed)
	DrinkingBuff = GetUnitBuff("player", DrinkingTexture)
	if(((PrctMana > 33) or (HasDrink() == 0)) and ((not DrinkingBuff) or (PrctMana > 80))) then FollowMultibox("Saelwyn") end
	if(DrinkingBuff and (PrctMana > 80)) then BlueBool = 4 end
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end

function Mage_OnCast(spellName)
	
end