--Variables

--Texture
AotHawkTexture = "Interface\\Icons\\Spell_Nature_RavenForm"
AotMonkeyTexture = "Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey"
HunterMarkTexture = "Interface\\Icons\\Ability_Hunter_SniperShot"
ViperStingTexture = "Interface\\Icons\\Ability_Hunter_AimedShot"
SerpentStingTexture = "Interface\\Icons\\Ability_Hunter_Quickshot"
TrueshotAuraTexture = "Interface\\Icons\\Ability_TrueShot"


function HunterDps()
	if(CastingInfo == nil and not UnitIsDeadOrGhost("player")) then
		local TrueshotAuraBuff = GetUnitBuff("player", TrueshotAuraTexture)
		local HasAggro = PlayerHasAggro()
		if(IsInGroup()) then AssistUnit(GetTank()) if((UnitCanAttack("player", "target") == nil) and Combat) then CastSpellByName("Attaque") end end
		if(IsSpellReady("Aspect du faucon") and not AotHawkBuff and not Combat) then
			--Aspect of the Hawk
			CastSpellByName("Aspect du faucon")
		elseif((PrctHp[0] < 40) and HasHealthstone() and (GetHealthstoneCD() < 1.25) and Combat) then
			--Healthstone
			PlaceItem(120, "Pierre de soins") UseAction(120)
		elseif((PrctHp[0] < 35) and HasHPotion() and (GetHPotionCD() < 1.25) and Combat) then
			--Healing Potion
			PlaceItem(120, "Potion de soins") UseAction(120)
		elseif(IsSpellReady("Aura de précision") and not TrueshotAuraBuff) then
			--Trueshot Aura
			CastSpellByName("Aura de précision")
		elseif(IsSpellReady("Feindre la mort") and HasAggro and IsInGroup()) then
			--Feign Death
			CastSpellByName("Feindre la mort")
		elseif(UnitCanAttack("player", "target") and (UnitIsDeadOrGhost("target") == nil)) then
			local HunterMarkDebuff = GetUnitDebuff("target", HunterMarkTexture)
			local ViperStingDebuff = GetUnitDebuff("target", ViperStingTexture)
			local SerpentStingDebuff = GetUnitDebuff("target", SerpentStingTexture)
			local StingDebuff = SerpentStingDebuff or ViperStingDebuff
			if(IsActionInRange(GetSlot("Tir automatique")) == 1) then
				local AotHawkBuff = GetUnitBuff("player", AotHawkTexture)
				if(IsFollowing) then TimerGodMode = 0.5 BlueBool = 6 end
				if(IsSpellReady("Aspect du faucon") and not AotHawkBuff) then
					--Aspect of the Hawk
					CastSpellByName("Aspect du faucon")
				elseif(IsSpellReady("Marque du chasseur") and not HunterMarkDebuff and UnitIsElite("target")) then
					--Hunter's Mark
					CastSpellByName("Marque du chasseur")
				elseif(IsAutoRepeatAction(GetSlot("Tir automatique")) == nil) then
					--Auto Shot
					CastSpellByName("Tir automatique")
				elseif(IsSpellReady("Tir rapide") and UnitIsElite("target")) then
					--Rapid Fire
					CastSpellByName("Tir rapide")
				elseif(IsSpellReady("Trait de choc") and (UnitPlayerControlled("target") or not IsInGroup()) and (RangedAATimer > 1.0)) then
					--Concussive Shot
					CastSpellByName("Trait de choc")
				elseif(IsSpellReady("Morsure de la vipère") and not StingDebuff and (UnitMana("target") > 100) and (RangedAATimer > 1.0)) then
					--Viper Sting
					CastSpellByName("Morsure de la vipère")
				elseif(IsSpellReady("Morsure de serpent") and UnitPlayerControlled("target") and (RangedAATimer > 1.0)) then
					--Serpent Sting
					CastSpellByName("Morsure de serpent")
				elseif(IsSpellReady("Visée") and (RangedAATimer > 2.0)) then
					--Aimed Shot
					CastSpellByName("Visée")
				elseif(IsSpellReady("Flèches multiples") and (RangedAATimer > 1.0)) then
					--Multi-Shot
					CastSpellByName("Flèches multiples")
				elseif(IsSpellReady("Tir des arcanes") and not IsPlayerSpell("Visée")) then
					--Arcane Shot
					CastSpellByName("Tir des arcanes")
				end
			elseif(CheckInteractDistance("target", 2)) then
				local AotMonkeyBuff = GetUnitBuff("player", AotMonkeyTexture)
				if(not HasAggro) then BlueBool = 5 end
				if(IsCurrentAction(GetSlot("Attaque")) == nil) then CastSpellByName("Attaque") end
				if(IsSpellReady("Aspect du singe") and not AotMonkeyBuff and HasAggro) then
					--Aspect of the Monkey
					CastSpellByName("Aspect du singe")
				elseif(IsSpellReady("Coupure d'ailes") and UnitPlayerControlled("target")) then
					--Wing Clip
					CastSpellByName("Coupure d'ailes")
				elseif(IsSpellReady("Morsure de la mangouste")) then
					--Mongoose Bite
					CastSpellByName("Morsure de la mangouste")
				elseif(IsSpellReady("Attaque du raptor")) then
					--Raptor Strike
					CastSpellByName("Attaque du raptor")
				end
			elseif(IsAutoRepeatAction(GetSlot("Tir automatique")) == nil) then
				--Auto Shot
				CastSpellByName("Tir automatique")
			end
		end
	end
end

function Hunter_OnUpdate(elapsed)
	FollowMultibox("Serena")
	GodModeVanilla.Pixel:SetTexture(0, 0, 0.003921*BlueBool)
end

function Hunter_OnLoad()  --Map Update
	--
end