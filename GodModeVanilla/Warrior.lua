--Variables
TacticalMasteryTalent = 0 SlamTalent = 0

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
			PlaceItem(120, "Pierre de soins")
		elseif((PrctHp[0] < 35) and HasHPotion() and (GetItemCooldownDuration(118) < 1.25) and Combat) then
			--Healing Potion
			PlaceItem(120, "Potion de soins")
		elseif((PrctHp[0] < 35) and IsSpellReady("Dernier Rempart") and Combat) then
			--Last Stand
			CastSpellByName("Dernier Rempart")
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
			if(IsCurrentAction(GetSlot("Attaque")) == nil) then CastSpellByName("Attaque") end
			if(IsSpellReady("Charge") and (CheckInteractDistance("target", 2) == nil)) then
				--Charge
				CastSpellByName("Charge")
			elseif(IsSpellReady("Interception") and (CheckInteractDistance("target", 2) == nil)) then
				--Interception
				CastSpellByName("Interception")
			elseif((GetSpellCooldownDuration("Charge") < 1.0) and (BattleStance == nil) and (CheckInteractDistance("target", 2) == nil) and not Combat) then
				--Combat Stance -> Charge
				CastSpellByName("Posture de combat")
			elseif((GetSpellCooldownDuration("Interception") < 1.0) and (BerserkerStance == nil) and (CheckInteractDistance("target", 2) == nil) and (UnitMana("player") >= 10) and (TacticalMasteryTalent >= 2)) then
				--Berserker Stance -> Interception
				CastSpellByName("Posture berserker")
			elseif(IsSpellReady("Rage berserker") and (CheckInteractDistance("target", 2) ~= nil) and (UnitMana("player") < 50)) then
				--Berserker Rage
				CastSpellByName("Rage berserker")
			elseif(IsSpellReady("Rage sanguinaire") and (CheckInteractDistance("target", 2) ~= nil) and (UnitMana("player") < 50)) then
				--Bloodrage
				CastSpellByName("Rage sanguinaire")
			elseif((DefensiveStance == nil) and ((UnitMana("player") <= TacticalMasteryTalent*5) or (UnitMana("player") <= 5))) then
				--Defensive Stance
				CastSpellByName("Posture défensive")
			elseif(IsSpellReady("Représailles") and (PrctHp[0] < 50) and (CheckInteractDistance("target", 2) ~= nil)) then
				--Retaliation
				CastSpellByName("Représailles")
			elseif(IsSpellReady("Mur protecteur") and (PrctHp[0] < 30)) then
				--Shield Wall
				CastSpellByName("Mur protecteur")
			elseif(IsSpellReady("Brise-genou") and not HamstringDebuff and (UnitPlayerControlled("target") ~= nil)) then
				--Hamstring
				CastSpellByName("Brise-genou")
			elseif(IsSpellReady("Provocation") and not UnitPlayerControlled("target") and not TargetIsAggro("target")) then
				--Taunt
				CastSpellByName("Provocation")
			elseif(IsSpellReady("Coup railleur") and not UnitPlayerControlled("target") and TargetIsAggro("target")) then
				--Mocking Blow
				CastSpellByName("Coup railleur")
			elseif(IsSpellReady("Coup traumatisant") and not UnitIsBoss("target")) then
				--Concussion Blow
				CastSpellByName("Coup traumatisant")
			elseif(IsSpellReady("Témérité") and UnitIsElite("target")) then
				--Recklessness
				CastSpellByName("Témérité")
			elseif(IsSpellReady("Souhait Mortel") and UnitIsElite("target")) then
				--Death Wish
				CastSpellByName("Souhait Mortel")
			elseif(IsSpellReady("Fulgurance")) then
				--Overpower
				CastSpellByName("Fulgurance")
			elseif(IsSpellReady("Vengeance")) then
				--Revenge
				CastSpellByName("Vengeance")
			elseif(IsSpellReady("Coup de bouclier") and UnitIsCaster("target")) then
				--Shield Bash
				CastSpellByName("Coup de bouclier")
			elseif(IsSpellReady("Volée de coups") and UnitIsCaster("target")) then
				--Pummel
				CastSpellByName("Volée de coups")
			elseif(IsSpellReady("Désarmement") and not UnitIsCaster("target") and (UnitPlayerControlled("target") ~= nil)) then
				--Disarm
				CastSpellByName("Désarmement")
			elseif(IsSpellReady("Cri de guerre") and not BattleShoutBuff) then
				--Battle Shout
				CastSpellByName("Cri de guerre")
			elseif(IsSpellReady("Cri démoralisant") and (CheckInteractDistance("target", 2) ~= nil) and not UnitIsCaster("target") and not DemoralizingShoutDebuff) then
				--Demoralizing Shout
				CastSpellByName("Cri démoralisant")
			elseif(IsSpellReady("Maîtrise du blocage") and not ShieldBlockBuff and not UnitIsCaster("target")) then
				--Shield Block
				CastSpellByName("Maîtrise du blocage")
			elseif(IsSpellReady("Exécution")) then
				--Execution
				CastSpellByName("Exécution")
			elseif(IsSpellReady("Heurtoir") and (AATimer > 1.0) and (SlamTalent > 0)) then
				--Slam
				CastSpellByName("Heurtoir")
			elseif(IsSpellReady("Tourbillon")) then
				--Whirlwind
				CastSpellByName("Tourbillon")
			elseif(IsSpellReady("Pourfendre") and not RendDebuff and UnitIsElite("target") and (UnitCreatureType("target") ~= "Mécanique") and (UnitCreatureType("target") ~= "Mort-vivant")) then
				--Rend
				CastSpellByName("Pourfendre")
			elseif(IsSpellReady("Coup de tonnerre") and not ThunderClapDebuff and (CheckInteractDistance("target", 2) ~= nil) and not UnitIsCaster("target")) then
				--Thunderclap
				CastSpellByName("Coup de tonnerre")
			elseif(IsSpellReady("Heurt de bouclier")) then
				--Shield Slam
				CastSpellByName("Heurt de bouclier")
			elseif(IsSpellReady("Sanguinaire")) then
				--Bloodthirst
				CastSpellByName("Sanguinaire")
			elseif(IsSpellReady("Fracasser armure") and not UnitIsCaster("target") and UnitIsElite("target")) then
				--Sunder Armor
				CastSpellByName("Fracasser armure")
			elseif(IsSpellReady("Frappe héroïque")) then
				--Heroic Strike
				CastSpellByName("Frappe héroïque")
			end
		end
	end
end

function Warrior_OnUpdate(elapsed)
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end

function Warrior_OnLoad()  --Map Update
	_,_,_,_,TacticalMasteryTalent = GetTalentInfo(1, 5)
	_,_,_,_,SlamTalent = GetTalentInfo(2, 12)
	if(IsPlayerSpell("Pourfendre")) then RendTexture = GetSpellTexture(GetSpellID("Pourfendre"), BOOKTYPE_SPELL) end
	if(IsPlayerSpell("Coup de tonnerre")) then ThunderclapTexture = GetSpellTexture(GetSpellID("Coup de tonnerre"), BOOKTYPE_SPELL) end
	if(IsPlayerSpell("Brise-genou")) then HamstringTexture = GetSpellTexture(GetSpellID("Brise-genou"), BOOKTYPE_SPELL) end
	if(IsPlayerSpell("Cri de guerre")) then BattleShoutTexture = GetSpellTexture(GetSpellID("Cri de guerre"), BOOKTYPE_SPELL) end
	if(IsPlayerSpell("Cri démoralisant")) then DemoralizingShoutTexture = GetSpellTexture(GetSpellID("Cri démoralisant"), BOOKTYPE_SPELL) end
	if(IsPlayerSpell("Maîtrise du blocage")) then ShieldBlockTexture = GetSpellTexture(GetSpellID("Maîtrise du blocage"), BOOKTYPE_SPELL) end
	--TirArbaleteName = GetSpellName(GetSpellID2("arbalète"), BOOKTYPE_SPELL)
end