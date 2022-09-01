--Variables
local TacticalMasteryTalent = 0 local SlamTalent = 0

--Texture
RendTexture = "" ThunderclapTexture = ""
HamstringTexture = "" BattleShoutTexture = ""
DemoralizingShoutTexture = "" ShieldBlockTexture = ""


function WarriorDps()
	if(CastingInfo == nil) then
		if(Combat and UnitCanAttack("player", "target") and UnitAffectingCombat("target") == nil) then ClearTarget()
		elseif(Combat and ((UnitCanAttack("player", "target") == nil) or (CheckInteractDistance("target", 4) == nil))) then TargetNearestEnemy() end
		if((PrctHp[0] < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
			--Healthstone
			PlaceItem(120, "Healthstone")
		elseif((PrctHp[0] < 35) and HasHPotion() and (GetItemCooldownDuration(118) < 1.25) and Combat) then
			--Healing Potion
			PlaceItem(120, "Healing Potion")
		elseif((PrctHp[0] < 35) and IsSpellReady("Last Stand") and Combat) then
			--Last Stand
			UseAction(GetSlot("Last Stand"))
		elseif(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			local _,_,BattleStance = GetShapeshiftFormInfo(1)
			local _,_,DefensiveStance = GetShapeshiftFormInfo(2)
			local _,_,BerserkerStance = GetShapeshiftFormInfo(3)
			local RendDebuff = GetUnitDebuff("target", RendTexture)
			local ThunderClapDebuff = GetUnitDebuff("target", ThunderclapTexture)
			local HamstringDebuff = GetUnitDebuff("target", HamstringTexture)
			local BattleShoutBuff = GetUnitBuff("player", BattleShoutTexture)
			local DemoralizingShoutDebuff = GetUnitDebuff("target", DemoralizingShoutTexture)
			local ShieldBlockBuff = GetUnitBuff("player", ShieldBlockTexture)
			if(IsCurrentAction(GetSlot("Attack")) == nil) then CastSpellByName("Attack") end
			if(IsSpellReady("Charge") and (CheckInteractDistance("target", 2) == nil)) then
				--Charge
				UseAction(GetSlot("Charge"))
			elseif(IsSpellReady("Interception") and (CheckInteractDistance("target", 2) == nil)) then
				--Interception
				UseAction(GetSlot("Interception"))
			elseif((GetSpellCooldownDuration("Charge") < 1.0) and (BattleStance == nil) and (CheckInteractDistance("target", 2) == nil) and not Combat) then
				--Combat Stance -> Charge
				UseAction(GetSlot("Combat Stance"))
			elseif((GetSpellCooldownDuration("Interception") < 1.0) and (BerserkerStance == nil) and (CheckInteractDistance("target", 2) == nil) and (UnitMana("player") >= 10) and (TacticalMasteryTalent >= 2)) then
				--Berserker Stance -> Interception
				UseAction(GetSlot("Berserker Stance"))
			elseif(IsSpellReady("Berserker Rage") and (CheckInteractDistance("target", 2) ~= nil) and (UnitMana("player") < 50)) then
				--Berserker Rage
				UseAction(GetSlot("Berserker Rage"))
			elseif(IsSpellReady("Bloodrage") and (CheckInteractDistance("target", 2) ~= nil) and (UnitMana("player") < 50)) then
				--Bloodrage
				UseAction(GetSlot("Bloodrage"))
			elseif((DefensiveStance == nil) and ((UnitMana("player") <= TacticalMasteryTalent*5) or (UnitMana("player") <= 5))) then
				--Defensive Stance
				UseAction(GetSlot("Defensive Stance"))
			elseif(IsSpellReady("Retaliation") and (PrctHp[0] < 50) and (CheckInteractDistance("target", 2) ~= nil)) then
				--Retaliation
				UseAction(GetSlot("Retaliation"))
			elseif(IsSpellReady("Shield Wall") and (PrctHp[0] < 30)) then
				--Shield Wall
				UseAction(GetSlot("Shield Wall"))
			elseif(IsSpellReady("Hamstring") and not HamstringDebuff and (UnitPlayerControlled("target") ~= nil)) then
				--Hamstring
				UseAction(GetSlot("Hamstring"))
			elseif(IsSpellReady("Taunt") and not UnitPlayerControlled("target") and not TargetIsAggro("target")) then
				--Taunt
				UseAction(GetSlot("Taunt"))
			elseif(IsSpellReady("Mocking Blow") and not UnitPlayerControlled("target") and TargetIsAggro("target")) then
				--Mocking Blow
				UseAction(GetSlot("Mocking Blow"))
			elseif(IsSpellReady("Concussion Blow") and not UnitIsBoss("target")) then
				--Concussion Blow
				UseAction(GetSlot("Concussion Blow"))
			elseif(IsSpellReady("Recklessness") and UnitIsElite("target")) then
				--Recklessness
				UseAction(GetSlot("Recklessness"))
			elseif(IsSpellReady("Death Wish") and UnitIsElite("target")) then
				--Death Wish
				UseAction(GetSlot("Death Wish"))
			elseif(IsSpellReady("Overpower")) then
				--Overpower
				UseAction(GetSlot("Overpower"))
			elseif(IsSpellReady("Revenge")) then
				--Revenge
				UseAction(GetSlot("Revenge"))
			elseif(IsSpellReady("Shield Bash") and UnitIsCaster("target")) then
				--Shield Bash
				UseAction(GetSlot("Shield Bash"))
			elseif(IsSpellReady("Pummel") and UnitIsCaster("target")) then
				--Pummel
				UseAction(GetSlot("Pummel"))
			elseif(IsSpellReady("Disarm") and not UnitIsCaster("target") and (UnitPlayerControlled("target") ~= nil)) then
				--Disarm
				UseAction(GetSlot("Disarm"))
			elseif(IsSpellReady("Battle Shout") and not BattleShoutBuff) then
				--Battle Shout
				UseAction(GetSlot("Battle Shout"))
			elseif(IsSpellReady("Demoralizing Shout") and (CheckInteractDistance("target", 2) ~= nil) and not UnitIsCaster("target") and not DemoralizingShoutDebuff) then
				--Demoralizing Shout
				UseAction(GetSlot("Demoralizing Shout"))
			elseif(IsSpellReady("Shield Block") and not ShieldBlockBuff and not UnitIsCaster("target")) then
				--Shield Block
				UseAction(GetSlot("Shield Block"))
			elseif(IsSpellReady("Execution")) then
				--Execution
				UseAction(GetSlot("Execution"))
			elseif(IsSpellReady("Slam") and (AATimer > 1.0) and (SlamTalent > 0)) then
				--Slam
				UseAction(GetSlot("Slam"))
			elseif(IsSpellReady("Whirlwind")) then
				--Whirlwind
				UseAction(GetSlot("Whirlwind"))
			elseif(IsSpellReady("Rend") and not RendDebuff and UnitIsElite("target") and (UnitCreatureType("target") ~= "Mécanique") and (UnitCreatureType("target") ~= "Mort-vivant")) then
				--Rend
				UseAction(GetSlot("Rend"))
			elseif(IsSpellReady("Thunderclap") and not ThunderClapDebuff and (CheckInteractDistance("target", 2) ~= nil) and not UnitIsCaster("target")) then
				--Thunderclap
				UseAction(GetSlot("Thunderclap"))
			elseif(IsSpellReady("Shield Slam")) then
				--Shield Slam
				UseAction(GetSlot("Shield Slam"))
			elseif(IsSpellReady("Bloodthirst")) then
				--Bloodthirst
				UseAction(GetSlot("Bloodthirst"))
			elseif(IsSpellReady("Sunder Armor") and not UnitIsCaster("target") and UnitIsElite("target")) then
				--Sunder Armor
				UseAction(GetSlot("Sunder Armor"))
			elseif(IsSpellReady("Heroic Strike")) then
				--Heroic Strike
				UseAction(GetSlot("Heroic Strike"))
			end
		end
	end
end

function Warrior_OnUpdate(elapsed)
	GodModeVanilla.Pixel:SetTexture(0, 0, 0)
end

function Warrior_OnLoad()  --Map Update
	_,_,_,_,TacticalMasteryTalent = GetTalentInfo(1, 5)
	_,_,_,_,SlamTalent = GetTalentInfo(2, 12)
	if(IsPlayerSpell("Rend")) then RendTexture = GetSpellTexture(GetSpellID("Rend"), BOOKTYPE_SPELL) end
	if(IsPlayerSpell("Thunderclap")) then ThunderclapTexture = GetSpellTexture(GetSpellID("Thunderclap"), BOOKTYPE_SPELL) end
	if(IsPlayerSpell("Hamstring")) then HamstringTexture = GetSpellTexture(GetSpellID("Hamstring"), BOOKTYPE_SPELL) end
	if(IsPlayerSpell("Battle Shout")) then BattleShoutTexture = GetSpellTexture(GetSpellID("Battle Shout"), BOOKTYPE_SPELL) end
	if(IsPlayerSpell("Demoralizing Shout")) then DemoralizingShoutTexture = GetSpellTexture(GetSpellID("Demoralizing Shout"), BOOKTYPE_SPELL) end
	if(IsPlayerSpell("Shield Block")) then ShieldBlockTexture = GetSpellTexture(GetSpellID("Shield Block"), BOOKTYPE_SPELL) end
	--TirArbaleteName = GetSpellName(GetSpellID2("arbalète"), BOOKTYPE_SPELL)
end