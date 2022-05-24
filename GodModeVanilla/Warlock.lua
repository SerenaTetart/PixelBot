--Variables
local listRank = {"supérieure", "majeure", "", "inférieure", "mineure"}
local FearInnerCD = 0 local HealthstoneTab = {} local HealthstoneIndex = 0
local DropInnerCD = 0

--Texture
CorruptionTexture = "Interface\\Icons\\Spell_Shadow_AbominationExplosion"
CoAgonyTexture = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras"
LifeSiphonTexture = "Interface\\Icons\\Spell_Shadow_Requiem"
DemonArmorTexture = "Interface\\Icons\\Spell_Shadow_RagingScream"
ImmolateTexture = "Interface\\Icons\\Spell_Fire_Immolation"

local function HasSoulstone()
	if((GetItemCount(5232) > 0) and (UnitLevel("player") < 30)) then
		--Minor Soulstone
		return true
	elseif((GetItemCount(16892) > 0) and (UnitLevel("player") < 40)) then
		--Lesser Soulstone
		return true
	elseif((GetItemCount(16893) > 0) and (UnitLevel("player") < 50)) then
		--Soulstone
		return true
	elseif(GetItemCount(16895) > 0) then
		--Greater Soulstone
		return true
	elseif(GetItemCount(16896) > 0) then
		--Major Soulstone
		return true
	else
		return false
	end
end

local function GetSoulstoneCD()
	ListID = {5232, 16892, 16893, 16895, 16896}
	for _,ID in ipairs(ListID) do
		if(GetItemCount(ID) > 0) then return GetItemCooldownDuration(ID) end
	end
	return 99999
end

local function PartyNeedHealthstone()
	for i= 1, GetNumGroupMembers() do
		if(HealthstoneTab[i] == nil) then HealthstoneTab[i] = false end
		if((HealthstoneTab[i] == false) and CheckInteractDistance(tar..i, 2) and not UnitIsDeadOrGhost(tar..i)) then return true end
	end
	return false
end

local function GiveHealthstone()
	for i= 1, GetNumGroupMembers() do
		if((HealthstoneTab[i] == false) and CheckInteractDistance(tar..i, 2)) then
			PickupItem("Pierre de soins")
			DropItemOnUnit(tar..i)
			HealthstoneIndex = i
			DropInnerCD = 1.0
			return
		end
	end
end

function UpdateHealthstoneTab(index)
	if(index ~= nil) then
		HealthstoneTab[index] = false
	else
		HealthstoneTab[HealthstoneIndex] = true
	end
end

local function GetRankSpellList(coreTxt, list)
	for _,txt in pairs(list) do
		if(IsPlayerSpell(coreTxt..' ('..txt..')')) then return (coreTxt..' ('..txt..')') end
	end
end

function WarlockDps()
	if(UnitAffectingCombat("target")) then PetAttack() end
	if(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		local DemonArmorBuff = GetUnitBuff("player", DemonArmorTexture)
		local RankHealthstone = GetRankSpellList("Création de Pierre de soins", listRank)
		local RankSoulstone = GetRankSpellList("Création de Pierre d'âme", listRank)
		if(IsInGroup()) then AssistUnit(GetTank()) if((UnitCanAttack("player", "target") == nil) and Combat) then CastSpellByName("Attaque") end end
		if((DropInnerCD == 0) and PartyNeedHealthstone() and not IsGroupInCombat() and not Combat and not IsTrading and HasHealthstone()) then
			--Trade Healthstone (party)
			GiveHealthstone()
		elseif(not Combat and not IsPlayerSpell("Armure démoniaque") and IsSpellReady("Peau de démon") and not DemonArmorBuff) then
			--Demon Skin
			CastSpellByName("Peau de démon")
		elseif(not Combat and IsSpellReady("Armure démoniaque") and not DemonArmorBuff) then
			--Demon Armor
			CastSpellByName("Armure démoniaque")
		elseif(not Combat and IsSpellReady("Invocation d'un diablotin") and not UnitExists("pet")) then
			--Summon Imp
			CastSpellByName("Invocation d'un diablotin")
		elseif(not Combat and IsSpellReady(RankHealthstone) and not HasHealthstone()) then
			--Create Healthstone
			CastSpellByName(RankHealthstone..'()')
		elseif(not Combat and IsSpellReady(RankSoulstone) and not HasSoulstone()) then
			--Create Soulstone
			CastSpellByName(RankSoulstone..'()')
		elseif(not Combat and (GetHealer() > 0) and HasSoulstone() and (GetSoulstoneCD() < 1.25)) then
			--Use Soulstone
			TargetUnit(tar..GetHealer())
			PlaceItem(120, "Pierre d'âme") UseAction(120)
		elseif(not Combat and not IsGroupInCombat() and (PrctHp[0] > 25) and (PrctMana < 80)) then
			--Life Tap (Out of Combat)
			CastSpellByName("Connexion")
		elseif((PrctHp[0] < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
			--Healthstone
			PlaceItem(120, "Pierre de soins") UseAction(120)
		elseif((PrctHp[0] < 35) and HasHPotion() and (GetHPotionCD() < 1.25) and Combat) then
			--Healing Potion
			PlaceItem(120, "Potion de soins") UseAction(120)
		elseif(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			if(CheckInteractDistance("target", 4) and IsFollowing) then TimerGodMode = 0.5 BlueBool = 6 end
			local CorruptionDebuff = GetUnitDebuff("target", CorruptionTexture)
			local CoAgonyDebuff = GetUnitDebuff("target", CoAgonyTexture)
			local LifeSiphonDebuff = GetUnitDebuff("target", LifeSiphonTexture)
			local ImmolateDebuff = GetUnitDebuff("target", ImmolateTexture)
			if(IsSpellReady("Voile mortel") and PrctHp[0] < 35) then
				--Mortal Coil
				CastSpellByName("Voile mortel")
			elseif(IsSpellReady("Peur") and (UnitPlayerControlled("target") or ((PrctHp[0] < 50) and (not IsInGroup()))) and not IsFeared("target") and (FearInnerCD == 0)) then
				--Fear
				CastSpellByName("Peur")
			elseif(IsSpellReady("Drain de vie") and PrctHp[0] < 40) then
				--Drain of Life
				CastSpellByName("Drain de vie")
			elseif(IsSpellReady("Siphon d'âme") and (UnitHealth("target") < 33) and (GetItemCount(6265) < 15)) then
				--Drain Soul
				CastSpellByName("Siphon d'âme")
			elseif(IsSpellReady("Malédiction d'agonie") and not CoAgonyDebuff and (UnitIsElite("target") or not IsInGroup())) then
				--Curse of Agony
				CastSpellByName("Malédiction d'agonie")
			elseif(IsSpellReady("Corruption") and not CorruptionDebuff) then
				--Corruption
				CastSpellByName("Corruption")
			elseif(IsSpellReady("Siphon de vie") and not LifeSiphonDebuff and (UnitIsElite("target") or not IsInGroup())) then
				--Siphon Life
				CastSpellByName("Siphon de vie")
			elseif(IsSpellReady("Immolation") and not ImmolateDebuff) then
				--Immolate
				CastSpellByName("Immolation")
			elseif(IsSpellReady("Trait de l'ombre")) then
				--Shadow Bolt
				CastSpellByName("Trait de l'ombre")
			elseif(IsSpellReady("Connexion") and (PrctHp[0] > 25) and (PrctMana < 10)) then
				--Life Tap
				CastSpellByName("Connexion")
			elseif(HasWandEquipped() and not IsAutoRepeatAction(GetSlot("Tir"))) then
				--Wand
				CastSpellByName("Tir")
			end
		end
	end
end

function Warlock_OnUpdate(elapsed)
	FollowMultibox("Saelwyn")
	FearInnerCD = UpdateTimer(FearInnerCD)
	DropInnerCD = UpdateTimer(DropInnerCD)
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end

function Warlock_OnCast(spellName)
	if(spellName == "Peur") then FearInnerCD = 10 end
end