--Variables

--Texture
AotHawkTexture = "Interface\\Icons\\Spell_Nature_RavenForm"
AotMonkeyTexture = "Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey"
HunterMarkTexture = "Interface\\Icons\\Ability_Hunter_SniperShot"
ViperStingTexture = "Interface\\Icons\\Ability_Hunter_AimedShot"
SerpentStingTexture = "Interface\\Icons\\Ability_Hunter_Quickshot"
TrueshotAuraTexture = "Interface\\Icons\\Ability_TrueShot"
FeedingTexture = "Interface\\Icons\\Ability_Hunter_BeastTraining"

function HunterDps()
	if(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		local TrueshotAuraBuff = GetUnitBuff("player", TrueshotAuraTexture)
		local FeedingBuff = GetUnitBuff("pet", FeedingTexture)
		local HasAggro = PlayerHasAggro()
		if(IsInGroup()) then AssistUnit(GetTank()) end
		if(not HasPetUI()) then
			--Call Pet
			CastSpellByName("Call Pet")
			PlaceItem(120, HasMeat()) UseAction(120)
		elseif(UnitIsDeadOrGhost("pet") and IsSpellReady("Revive Pet")) then
			--Revive Pet
			CastSpellByName("Revive Pet")
		elseif(not Combat and not IsGroupInCombat() and HasPetUI() and (GetPetHappiness() < 3) and not UnitIsDeadOrGhost("pet") and not FeedingBuff and HasMeat()) then
			--Feed Pet
			CastSpellByName("Feed Pet")
			PlaceItem(120, HasMeat()) UseAction(120)
		elseif(IsSpellReady("Aspect of the Hawk") and not AotHawkBuff and not Combat) then
			--Aspect of the Hawk
			CastSpellByName("Aspect of the Hawk")
		elseif((PrctHp[0] < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
			--Healthstone
			PlaceItem(120, "Healthstone") UseAction(120)
		elseif((PrctHp[0] < 35) and HasHPotion() and (GetHPotionCD() < 1.25) and Combat) then
			--Healing Potion
			PlaceItem(120, "Healing Potion") UseAction(120)
		elseif(IsSpellReady("Trueshot Aura") and not TrueshotAuraBuff) then
			--Trueshot Aura
			CastSpellByName("Trueshot Aura")
		elseif(IsSpellReady("Feign Death") and HasAggro and IsInGroup()) then
			--Feign Death
			CastSpellByName("Feign Death")
		elseif(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			local HunterMarkDebuff = GetUnitDebuff("target", HunterMarkTexture)
			local ViperStingDebuff = GetUnitDebuff("target", ViperStingTexture)
			local SerpentStingDebuff = GetUnitDebuff("target", SerpentStingTexture)
			local StingDebuff = SerpentStingDebuff or ViperStingDebuff
			if(UnitAffectingCombat("target")) then PetAttack() end
			if(IsActionInRange(GetSlot("Auto Shot")) == 1) then
				local AotHawkBuff = GetUnitBuff("player", AotHawkTexture)
				if(IsFollowing) then TimerGodMode = 0.5 BlueBool = 6 end
				if(IsSpellReady("Aspect of the Hawk") and not AotHawkBuff) then
					--Aspect of the Hawk
					CastSpellByName("Aspect of the Hawk")
				elseif(IsSpellReady("Hunter's Mark") and not HunterMarkDebuff and UnitIsElite("target")) then
					--Hunter's Mark
					CastSpellByName("Hunter's Mark")
				elseif(IsAutoRepeatAction(GetSlot("Auto Shot")) == nil) then
					--Auto Shot
					CastSpellByName("Auto Shot")
				elseif(IsSpellReady("Rapid Fire") and UnitIsElite("target")) then
					--Rapid Fire
					CastSpellByName("Rapid Fire")
				elseif(IsSpellReady("Aimed Shot") and (RangedAATimer > 2.0)) then
					--Aimed Shot
					CastSpellByName("Aimed Shot")
				elseif(IsSpellReady("Multi-Shot") and (RangedAATimer > 1.0)) then
					--Multi-Shot
					CastSpellByName("Multi-Shot")
				elseif(IsSpellReady("Concussive Shot") and (UnitPlayerControlled("target") or not IsInGroup()) and (RangedAATimer > 1.0)) then
					--Concussive Shot
					CastSpellByName("Concussive Shot")
				elseif(IsSpellReady("Viper Sting") and not StingDebuff and (UnitMana("target") > 100) and (RangedAATimer > 1.0)) then
					--Viper Sting
					CastSpellByName("Viper Sting")
				elseif(IsSpellReady("Serpent Sting") and UnitPlayerControlled("target") and (RangedAATimer > 1.0)) then
					--Serpent Sting
					CastSpellByName("Serpent Sting")
				elseif(IsSpellReady("Arcane Shot") and not IsPlayerSpell("Aimed Shot")) then
					--Arcane Shot
					CastSpellByName("Arcane Shot")
				end
			elseif(CheckInteractDistance("target", 2)) then
				local AotMonkeyBuff = GetUnitBuff("player", AotMonkeyTexture)
				if(not HasAggro) then BlueBool = 5 end
				if(IsCurrentAction(GetSlot("Attack")) == nil) then CastSpellByName("Attack") end
				if(IsSpellReady("Aspect of the Monkey") and not AotMonkeyBuff and HasAggro) then
					--Aspect of the Monkey
					CastSpellByName("Aspect of the Monkey")
				elseif(IsSpellReady("Wing Clip") and UnitPlayerControlled("target")) then
					--Wing Clip
					CastSpellByName("Wing Clip")
				elseif(IsSpellReady("Mongoose Bite")) then
					--Mongoose Bite
					CastSpellByName("Mongoose Bite")
				elseif(IsSpellReady("Raptor Strike")) then
					--Raptor Strike
					CastSpellByName("Raptor Strike")
				end
			elseif(IsAutoRepeatAction(GetSlot("Auto Shot")) == nil) then
				--Auto Shot
				CastSpellByName("Auto Shot")
			end
		else
			PetPassiveMode()
		end
	end
end

function Hunter_OnUpdate(elapsed)
	FollowMultibox("Eydis")
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end

function Hunter_OnLoad()  --Map Update
	--
end