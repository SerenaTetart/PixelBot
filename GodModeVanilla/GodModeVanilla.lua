GodModeVanilla = CreateFrame("Frame", nil, UIParent)

local FollowBool = true local elapsed = 0 local InnerCDLoad = 0 local TradePending = false
local BreathTimer = -1

Combat = false BlueBool = 0 CastingInfo = nil
IDEquipment = {} TabAggro = {} NbrEnemyAggro = 0 TimerGodMode = 0
IsFollowing = false IsTrading = false tar = "party"

--Stats Related
PrctMana = 100 --Pourcentage de Mana du joueur
PrctHp = {} --Liste des pourcentages de PV restant, index = ordre des joueurs
HealTargetTab = {} --Liste d'index de joueur par ordre croissant par rapport au pourcentage de PV restant
HpLostTab = {} --Liste des PV perdu, index = ordre des joueurs
AoEHeal = 0 --Nombre d'alliés sous le seuil de 60% PV
AATimer = 0 RangedAATimer = 0 --CD des attaques automatiques

--Params
TankName = "Nihal"

--Textures
DrinkingTexture = "Interface\\Icons\\INV_Drink_07"

--======================================================================--
--======================    Fonctions Basiques    ======================--
--======================================================================--

function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(tostring(msg))
end

function GetNumGroupMembers()
	local nbrRaid = GetNumRaidMembers()
	local nbrParty = GetNumPartyMembers()
	if(nbrRaid > nbrParty) then
		return nbrRaid
	else
		return nbrParty
	end
end

function IsInRaid()
	if(GetNumRaidMembers() > 0) then return true
	else return false end
end

function IsInGroup()
	if(GetNumPartyMembers() > 0) then return true
	else return false end
end

local function ClassifyHeal()
	--Classe par priorité les cibles à soigner
	AoEHeal = 0
	if(not UnitIsDeadOrGhost("player")) then
		PrctHp[0] = (UnitHealth("player")/UnitHealthMax("player"))*100
		if(PrctHp[0] <= 60) then AoEHeal = AoEHeal+1 end
		HpLostTab[0] = UnitHealthMax("player") - UnitHealth("player")
	else
		PrctHp[0] = 100
		HpLostTab[0] = 0
	end
	for i= 1, GetNumGroupMembers() do
		if((UnitCanAttack("player", tar..i) == nil) and not UnitIsDeadOrGhost(tar..i) and UnitIsVisible(tar..i)) then
			PrctHp[i] = (UnitHealth(tar..i)/UnitHealthMax(tar..i))*100
			if(PrctHp[i] <= 60) then AoEHeal = AoEHeal+1 end
			HpLostTab[i] = UnitHealthMax(tar..i) - UnitHealth(tar..i)
		else
			PrctHp[i] = 100
			HpLostTab[i] = 0
		end
	end
	local tmpTab = {}
	for i= 0, GetNumGroupMembers() do
		tmpTab[i] = PrctHp[i]
		HealTargetTab[i] = i
	end
	for i= GetNumGroupMembers(), 0, -1 do
		for y= 0, i-1 do
			if(tmpTab[y] > tmpTab[y+1]) then
				local tmp = tmpTab[y]
				tmpTab[y] = tmpTab[y+1]
				tmpTab[y+1] = tmp
				tmp = HealTargetTab[y]
				HealTargetTab[y] = HealTargetTab[y+1]
				HealTargetTab[y+1] = tmp
			end
		end
	end
end

--======================================================================--
--===========================    Timer/CD    ===========================--
--======================================================================--

function GetItemCooldown(item_info)
	--Trouve par le nom ou l'ID le cooldown de l'item dans l'inventaire
	for i= 0, 4 do
		for y= 1, GetContainerNumSlots(i) do
			local item = GetContainerItemLink(i,y)
			if(item and string.find(item, item_info)) then
				local startTime,duration,isEnabled  = GetContainerItemCooldown(i, y)
				return startTime,duration,isEnabled
			end
		end
	end
	return 0, 0, 0
end

function GetItemCooldownDuration(item_info)
	local start, duration = GetItemCooldown(item_info)
	local cdLeft = start + duration - GetTime()
	if(cdLeft < 0) then cdLeft = 0 end
	return cdLeft
end

function GetActionCooldownDuration(slot)
	local start, duration = GetActionCooldown(slot)
	local cdLeft = start + duration - GetTime()
	if(cdLeft < 0) then cdLeft = 0 end
	return cdLeft
end

function GetSpellCooldownDuration(spell_name)
	local spell_id = GetSpellID(spell_name)
	if(spell_id > 0) then
		local start, duration = GetSpellCooldown(spell_id, BOOKTYPE_SPELL)
		local cdLeft = start + duration - GetTime()
		if(cdLeft < 0) then cdLeft = 0 end
		return cdLeft
	else return 999
	end
end

function UpdateTimer(timer)
	timer = timer - elapsed
	if(timer < 0) then timer = 0 end
	return timer
end

--======================================================================--
--=============================    Items    ============================--
--======================================================================--

function IsInventoryFull()
	for i= 0, 4 do
		for y= 1, GetContainerNumSlots(i) do
			if(GetContainerItemInfo(i,y) == nil) then return false end
		end
	end
	return true
end

function TextEqualNbr(text, nbr)
	local indTxt = string.find(text, nbr)
	local lenNbr = string.len(nbr)
	if(indTxt) then
		if(((indTxt == 1) or ((indTxt > 1) and (tonumber(string.sub(text, indTxt-1, indTxt+lenNbr-1))) == nil)) and ((indTxt+lenNbr == string.len(text)) or (tonumber(string.sub(text, indTxt, indTxt+lenNbr)) == nil))) then
			return true
		end
	end
	return false
end

function GetItemCount(item_info)
	--Trouve par le nom ou l'ID la quantité d'item similaire dans l'inventaire
	local total = 0
	local IsText = (tonumber(item_info) == nil)
	for i= 0, 4 do
		for y= 1, GetContainerNumSlots(i) do
			local item = GetContainerItemLink(i,y)
			if(item and ((IsText and string.find(item, item_info)) or (not IsText and TextEqualNbr(item, item_info)))) then
				local _,itemCount = GetContainerItemInfo(i, y)
				total = total + itemCount
			end
		end
	end
	return total
end

function GetItemQuality(bag, slot)
	local item = GetContainerItemLink(bag, slot)
	if(item == nil) then return -1
	elseif(string.find(item, "9d9d9d")) then return 0	--Poor
	elseif(string.find(item, "ffffff")) then return 1	--Common
	elseif(string.find(item, "1eff00")) then return 2	--Uncommon 
	elseif(string.find(item, "0070dd")) then return 3	--Rare
	elseif(string.find(item, "a335ee")) then return 4	--Epic
	elseif(string.find(item, "ff8000")) then return 5	--Legendary
	elseif(string.find(item, "e6cc80")) then return 6	--Artifact
	else return -1 end
end

function PickupItem(item_info)
	local IsText = (tonumber(item_info) == nil)
	for i= 0, 4 do
		for y= 1, GetContainerNumSlots(i) do
			local item = GetContainerItemLink(i,y)
			if(item and ((IsText and string.find(item, item_info)) or (not IsText and TextEqualNbr(item, item_info)))) then
				PickupContainerItem(i, y)
				return
			end
		end
	end
end

function PlaceItem(slot, itemName)
	--Place la potion dans le slot indiqué
	PickupItem(itemName)
	PlaceAction(slot)
	ClearCursor()
end

function GetEquipSlotID(item_texture)
	if(string.find(item_texture, "Helmet")) then return 1
	elseif(string.find(item_texture, "Necklace")) then return 2
	elseif(string.find(item_texture, "Shoulder")) then return 3
	elseif(string.find(item_texture, "Shirt") or string.find(item_texture, "Chest")) then return 5
	elseif(string.find(item_texture, "Belt")) then return 6
	elseif(string.find(item_texture, "Pants")) then return 7
	elseif(string.find(item_texture, "Boots")) then return 8
	elseif(string.find(item_texture, "Bracer")) then return 9
	elseif(string.find(item_texture, "Gauntlets")) then return 10
	elseif(string.find(item_texture, "Ring")) then return 11
	elseif(string.find(item_texture, "Trinket")) then return 13
	elseif(string.find(item_texture, "Cape")) then return 15
	elseif(string.find(item_texture, "Staff") or string.find(item_texture, "Mace") or string.find(item_texture, "ShortBlade")) then return 16
	elseif(string.find(item_texture, "Wand")) then return 18
	else return 0 end
end

function HasDrink()
	local listID = {159, 1179, 1205, 1645, 1708, 2136, 2288, 3772, 4791, 5350, 8077
		, 8078, 8079, 8766, 9451, 10841, 13724, 18300, 19301, 20031}
	for _, ID in ipairs(listID) do
		if(GetItemCount(ID) > 0) then return ID end
	end
	return 0
end

function HasHPotion()
	if((GetItemCount(118) > 0) and (UnitLevel("player") < 20)) then
		--Minor Healing Potion
		return true
	elseif((GetItemCount(858) > 0) and (UnitLevel("player") < 30)) then
		--Lesser Healing Potion
		return true
	elseif((GetItemCount(929) > 0) and (UnitLevel("player") < 40)) then
		--Healing Potion
		return true
	elseif((GetItemCount(1710) > 0) and (UnitLevel("player") < 50)) then
		--Greater Healing Potion
		return true
	elseif((GetItemCount(3928) > 0)) then
		--Superior Healing Potion
		return true
	elseif(GetItemCount(13446) > 0) then
		--Major Healing Potion
		return true
	else
		return false
	end
end

function GetHPotionCD()
	local listID = {118, 858, 929, 1710, 3928, 13446}
	for _,ID in ipairs(listID) do
		if(GetItemCount(ID) > 0) then return GetItemCooldownDuration(ID) end
	end
	return 99999
end

function HasMPotion()
	if((GetItemCount(2455) > 0) and (UnitLevel("player") < 25)) then
		--Minor Mana Potion
		return true
	elseif((GetItemCount(3385) > 0) and (UnitLevel("player") < 35)) then
		--Lesser Mana Potion
		return true
	elseif((GetItemCount(3827) > 0) and (UnitLevel("player") < 45)) then
		--Mana Potion
		return true
	elseif((GetItemCount(6149) > 0) and (UnitLevel("player") < 55)) then
		--Greater Mana Potion
		return true
	elseif((GetItemCount(13443) > 0)) then
		--Superior Mana Potion
		return true
	elseif(GetItemCount(13444) > 0) then
		--Major Mana Potion
		return true
	else
		return false
	end
end

function GetMPotionCD()
	local listID = {2455, 3385, 3827, 6149, 13443, 13444}
	for _,ID in ipairs(listID) do
		if(GetItemCount(ID) > 0) then return GetItemCooldownDuration(ID) end
	end
	return 99999
end

function HasHealthstone()
	if(((GetItemCount(5512) > 0) or (GetItemCount(19004) > 0) or (GetItemCount(19005) > 0)) and (UnitLevel("player") < 30)) then
		--Minor Healthstone
		return true
	elseif(((GetItemCount(5511) > 0) or (GetItemCount(19006) > 0) or (GetItemCount(19007) > 0)) and (UnitLevel("player") < 40)) then
		--Lesser Healthstone
		return true
	elseif(((GetItemCount(5509) > 0) or (GetItemCount(19008) > 0) or (GetItemCount(19009) > 0)) and (UnitLevel("player") < 50)) then
		--Healthstone
		return true
	elseif((GetItemCount(5510) > 0) or (GetItemCount(19010) > 0) or (GetItemCount(19011) > 0)) then
		--Greater Healthstone
		return true
	elseif((GetItemCount(9421) > 0) or (GetItemCount(19012) > 0) or (GetItemCount(19013) > 0)) then
		--Major Healthstone
		return true
	else
		return false
	end
end

function GetHealthstoneCD()
	local listID = {5512, 19004, 19005, 5511, 19006, 19007, 5509, 19008, 19009, 5510, 19010, 19011, 9421, 19012, 19013}
	for _,ID in ipairs(listID) do
		if(GetItemCount(ID) > 0) then return GetItemCooldownDuration(ID) end
	end
	return 99999
end

function GetEquipmentID(slotID)
	--Récupére tous les ID de l'équipement du personnage
	slotID = slotID or 0
	local IDtab = {}
	if(slotID == 0) then
		for i= 1, 18 do
			local link = GetInventoryItemLink("player",i)
			if(link ~= nil) then
				local id = 0
				for y= 1, 30000 do if(string.find(link, y)) then id = y end end
				IDtab[i] = id
			end
		end
		return IDtab
	else
		local id = 0
		local link = GetInventoryItemLink("player", slotID)
		if(link ~= nil) then
			for y= 1, 30000 do if(string.find(link, y)) then id = y end end
		end
		return id
	end
end

local function GetRessourcesList(mode)
	local ressList = {} local listID = {} local i = 1
	if(mode == 0) then --Alchimie
		listID = {765, 785, 2447, 2449, 2450, 2452, 2453, 3355, 3356, 3357, 3358, 3369, 3818, 3819, 3820, 3821, 4625, 8831, 8836, 8838, 8839, 8845}
	elseif(mode == 1) then --Leatherworking
		listID = {783, 2318, 2319, 2934, 4232, 4234, 4235, 4304, 7392, 7428, 8154, 8165, 8167, 8368, 8169}
	elseif(mode == 2) then --Tailoring
		listID = {2589, 2592, 3182, 4306, 4337, 4338, 10285, 14047, 14227, 14256}
	elseif(mode == 3) then --Blacksmithing
		listID = {2770, 2771, 2772, 2775, 2776, 2835, 2836, 2838, 3858, 7912, 10620, 11370}
	end
	for _,ID in ipairs(listID) do
		if(GetItemCount(ID) > 0) then ressList[i] = ID i = i+1 end
	end
	return ressList
end

function GiveRessources(ltwName, tailorName, alchimistName, blacksmithName)
	--Exchange ressources gathered with the team
	if(not Combat) then
		local ressAlchList = {} local ressLtwList = {} local ressTailorList = {} local ressBlacksmithList = {}
		ressAlchList = GetRessourcesList(0)
		if(ressAlchList[1] == nil or (GetAllyByName(alchimistName) == 0) or not CheckInteractDistance(tar..GetAllyByName(alchimistName), 2)) then
			ressLtwList = GetRessourcesList(1)
			if(ressLtwList[1] == nil or (GetAllyByName(ltwName) == 0) or not CheckInteractDistance(tar..GetAllyByName(ltwName), 2)) then
				ressTailorList = GetRessourcesList(2)
				if(ressTailorList[1] == nil or (GetAllyByName(tailorName) == 0) or not CheckInteractDistance(tar..GetAllyByName(tailorName), 2)) then
					ressBlacksmithList = GetRessourcesList(3)
					if((GetAllyByName(tailorName) > 0) or CheckInteractDistance(tar..GetAllyByName(blacksmithName), 2)) then
						for _,ID in ipairs(ressBlacksmithList) do
							PickupItem(ID)
							DropItemOnUnit(tar..GetAllyByName(blacksmithName))
							AcceptTrade()
						end
					end
				else
					for _,ID in ipairs(ressTailorList) do
						PickupItem(ID)
						DropItemOnUnit(tar..GetAllyByName(tailorName))
						AcceptTrade()
					end
				end
			else
				for _,ID in ipairs(ressLtwList) do
					PickupItem(ID)
					DropItemOnUnit(tar..GetAllyByName(ltwName))
					AcceptTrade()
				end
			end
		else
			for _,ID in ipairs(ressAlchList) do
				PickupItem(ID)
				DropItemOnUnit(tar..GetAllyByName(alchimistName))
				AcceptTrade()
			end
		end
	end
end

function compareEquip(msgloot)
	--!!Warning!! Ring/Trinket/Offhand
	local item_texture, item_bag, item_slot, lootid = 0
	for i= 1, 30000 do if(string.find(msgloot, i)) then lootid = i end end
	for i= 0, 4 do
		for y= 1, GetContainerNumSlots(i) do
			local link = GetContainerItemLink(i, y) or ""
			if(string.find(link, lootid)) then item_bag = i item_slot = y item_texture = GetContainerItemInfo(i,y) end
		end
	end
	local minBagSpace = 99
	for i= 1, 4 do if(minBagSpace > GetContainerNumSlots(i)) then minBagSpace = GetContainerNumSlots(i) end end
	if(string.find(GetContainerItemInfo(item_bag,item_slot), "Interface\\Icons\\INV_Misc_Bag_09") and (minBagSpace < 6)) then
		PickupContainerItem(item_bag,item_slot) AutoEquipCursorItem()
	else
		local lootSlot = GetEquipSlotID(item_texture)
		if(lootSlot > 0) then
			if(UnitClass("player") == "Prêtre") then
				Priest_OnLoot(lootid, item_texture, lootSlot, item_bag, item_slot)
			end
		end
	end
end

function sellUselessItems()
	for i= 0, 4 do
		for y= 1, GetContainerNumSlots(i) do
			if(GetItemQuality(i, y) == 0) then UseContainerItem(i, y) end
		end
	end
end

--======================================================================--
--=========================    Buffs/Debuffs    ========================--
--======================================================================--

function GetUnitBuff(target, buffTexture)
	for i= 1, 32 do
		local textname, count = UnitBuff(target, i)
		if(textname == buffTexture) then return true, count, i end
	end
	return false, 0, 0
end

function GetUnitDebuff(target, buffTexture)
	for i= 1, 16 do
		local textname, count = UnitDebuff(target, i)
		if(textname == buffTexture) then return true, count end
	end
	return false, 0
end

function GetBuffKey(buffTexture, mode, buffTexture2)
	--Retourne le joueur auquel il manque le buff
	--mode 1: CaC | mode 2: Caster
	buffTexture2 = buffTexture2 or ""
	mode = mode or 0
	for i= 1, GetNumGroupMembers() do
		local buffB = false
		if((UnitCanAttack("player", tar..i) == nil) and (mode == 0 or (mode == 1 and UnitManaMax(tar..i) < 100) or (mode == 2 and UnitManaMax(tar..i) > 100)) and not UnitIsDeadOrGhost(tar..i) and CheckInteractDistance(tar..i, 4)) then
			for y= 1, 40 do
				if(UnitBuff(tar..i, y) == buffTexture or UnitBuff(tar..i, y) == buffTexture2) then buffB = true end
			end
			if(buffB == false) then return i end
		end
	end
	return 0
end

function GetUnitDispel(target, dispellType1, dispellType2, dispellType3)
	--Retourne si la cible a un debuff à dispel
	dispellType1 = dispellType1 or ""; dispellType2 = dispellType2 or ""; dispellType3 = dispellType3 or ""
	local args = {dispellType1, dispellType2, dispellType3}
	for i= 1, 16 do
		debuffIcon, _, debuffType = UnitDebuff(target, i)
		if(debuffIcon ~= "Interface\\Icons\\Spell_Frost_FrostArmor02") then
			for _,dispellType in ipairs(args) do
				if(dispellType == debuffType) then return true end
			end
		end
	end
	return false
end

function GetDispelKey(dispellType1, dispellType2, dispellType3)
	--Retourne le joueur du groupe à dispel
	dispellType1 = dispellType1 or ""; dispellType2 = dispellType2 or ""; dispellType3 = dispellType3 or ""
	for i= 1, GetNumGroupMembers() do
		if(GetUnitDispel(tar..i, dispellType1, dispellType2, dispellType3) and CheckInteractDistance(tar..i, 4)) then return i end
	end
	return 0
end

--======================================================================--
--============================    Status    ============================--
--======================================================================--

function IsStunned(target)
	--Retourne si la cible est stun
	local tab = {}
	tab[1] = "Interface\\Icons\\Spell_Holy_SealOfMight" --Hammer of Justice
	tab[2] = "Interface\\Icons\\Ability_Druid_SupriseAttack"
	tab[3] = "Interface\\Icons\\Ability_Druid_Bash"
	tab[4] = "Interface\\Icons\\Ability_Rogue_KidneyShot"
	tab[5] = "Interface\\Icons\\Ability_CheapShot"
	tab[6] = "Interface\\Icons\\Spell_Shadow_GatherShadows" --Blackout
	for i= 1, 16 do
		local debuff = UnitDebuff(target, i)
		for _,statusTexture in ipairs(tab) do
			if(debuff == statusTexture) then return true end
		end
	end
	return false
end

function IsRooted(target)
	--Retourne si la cible est root
	local tab = {}
	tab[1] = "Interface\\Icons\\Spell_Frost_FrostNova"
	tab[2] = "Interface\\Icons\\Spell_Nature_StrangleVines"
	tab[3] = "Interface\\Icons\\Ability_Ensnare"
	for i= 1, 16 do
		local debuff = UnitDebuff(target, i)
		for _,statusTexture in ipairs(tab) do
			if(debuff == statusTexture) then return true end
		end
	end
	return false
end

function IsFeared(target)
	--Retourne si la cible est fear
	local tab = {}
	tab[1] = "Interface\\Icons\\Spell_Shadow_Possession"
	tab[2] = "Interface\\Icons\\Spell_Shadow_PsychicScream"
	tab[3] = "Interface\\Icons\\Spell_Shadow_DeathCoil"
	tab[4] = "Interface\\Icons\\Ability_GolemThunderClap"
	tab[5] = "Interface\\Icons\\Ability_Physical_Taunt"
	for i= 1, 16 do
		local debuff = UnitDebuff(target, i)
		for _,statusTexture in ipairs(tab) do
			if(debuff == statusTexture) then return true end
		end
	end
	return false
end

function IsGroupFeared()
	for i= 1, GetNumGroupMembers() do
		if(IsFeared(tar..i)) then return true end
	end
	return false
end

function IsCharmed(target)
	--Retourne si la cible est fear
	local tab = {}
	tab[1] = {"Interface\\Icons\\Spell_Shadow_GatherShadows", "Shadowfang Keep"} --Arugal's charm
	tab[2] = {"Interface\\Icons\\Spell_Shadow_ShadowWordDominate", ""} --Mind control
	tab[3] = {"Interface\\Icons\\Spell_Shadow_MindSteal", ""} --Succubus' seduction
	for i= 1, 16 do
		local debuff = UnitDebuff(target, i)
		for _,statusTexture in ipairs(tab) do
			if(debuff == statusTexture[0] and (statusTexture[1] == "" or statusTexture[1] == GetRealZoneText())) then return true end
		end
	end
	return false
end

function IsGroupCharmed()
	for i= 1, GetNumGroupMembers() do
		if(IsCharmed(tar..i)) then return true end
	end
	return false
end

--======================================================================--
--========================    Spells/Actions    ========================--
--======================================================================--

function GetSpellID2(spell_name)
	--Deuxième méthode en cas de nom mal écrit par la DB
	local id = 0 local rank = 1
	for i= 1, GetNumSpellTabs() do
		local _,_,_,numSpells = GetSpellTabInfo(i)
		for y= 1, numSpells do
			id = id + 1
			if(string.find(GetSpellName(id, BOOKTYPE_SPELL), spell_name) ~= nil) then
				while(string.find(GetSpellName(id+1, BOOKTYPE_SPELL), spell_name) ~= nil) do
					id = id+1
					rank = rank + 1
				end
				return id, rank
			end
		end
	end
	return 0, 0
end

function GetSpellID(spell_name)
	local id = 0 local rank = 1
	for i= 1, GetNumSpellTabs() do
		local _,_,_,numSpells = GetSpellTabInfo(i)
		for y= 1, numSpells do
			id = id + 1
			if(spell_name == GetSpellName(id, BOOKTYPE_SPELL)) then
				while(spell_name == GetSpellName(id+1, BOOKTYPE_SPELL)) do
					id = id+1
					rank = rank + 1
				end
				return id, rank
			end
		end
	end
	return 0, 0
end

function GetSlot(spell_name, slot_type)
	local slot_type = slot_type or "SPELL"
	local slot = 0
	local spellID = GetSpellID(spell_name)
	if(spellID > 0) then
		for i= 1, 120 do
			if((HasAction(i) ~= nil) and (GetSpellTexture(spellID, BOOKTYPE_SPELL) == GetActionTexture(i)) and ((not IsConsumableAction(i) and slot_type == "SPELL") or (IsConsumableAction(i) and slot_type == "ITEM"))) then
				slot = i
				return slot
			end
		end
	end
	return slot
end

function IsPlayerSpell(spell_name)
	if(GetSpellID(spell_name) == 0) then return false
	else return true end
end

function IsSpellReady(spell_name)
	local slot = GetSlot(spell_name)
	if(slot > 0) then
		local usable, nomana = IsUsableAction(slot)
		if((usable ~= nil) and (nomana == nil) and (GetActionCooldownDuration(slot) < 1.0)) then
			return true
		else
			return false
		end
	else
		return false
	end
end

--======================================================================--
--=============================    Unit    =============================--
--======================================================================--

function GetAllyByName(Name)
	for i= 1, GetNumGroupMembers() do
		if(UnitName(tar..i) == Name) then return i end
	end
	return 0
end

local function UpdateTabAggro(enemyName, hasAggro)
	local tmpB = true
	for key in pairs(TabAggro) do
		if(TabAggro[key][1] == enemyName) then tmpB = false TabAggro[key][2] = hasAggro end
	end
	if(tmpB) then TabAggro[NbrEnemyAggro+1] = {enemyName, hasAggro} NbrEnemyAggro = NbrEnemyAggro+1 end
end

local function PopTabAggro(text)
	local tmpB = 0
	for key in pairs(TabAggro) do
		if(string.find(text, TabAggro[key][1])) then tmpB = key end
	end
	if(tmpB > 0) then
		for key in pairs(TabAggro) do
			if(key >= tmpB) then TabAggro[key] = TabAggro[key+1] end
		end
		TabAggro[NbrEnemyAggro] = nil
		NbrEnemyAggro = NbrEnemyAggro-1
	end
end

function PlayerHasAggro()
	for key in pairs(TabAggro) do
		if(TabAggro[key][2] == true) then return true end
	end
	return false
end

function TargetIsAggro(target)
	local enemyName = UnitName(target)
	for key in pairs(TabAggro) do
		if((TabAggro[key][1] == enemyName) and (TabAggro[key][2] == true)) then return true end
	end
	return false
end

function GetHealer()
	--Retourne l'indice du healer
	for i= 1, GetNumGroupMembers() do
		if(UnitClass(tar..i) == "Shaman") then return i end
	end
	for i= 1, GetNumGroupMembers() do
		if(UnitClass(tar..i) == "Priest") then return i end
	end
	for i= 1, GetNumGroupMembers() do
		if(UnitClass(tar..i) == "Druid") then return i end
	end
	for i= 1, GetNumGroupMembers() do
		if(UnitClass(tar..i) == "Paladin") then return i end
	end
	return 0
end

function GetTank()
	--Retourne l'indice du tank
	for i= 1, GetNumGroupMembers() do
		if(UnitName(tar..i) == TankName) then return tar..i end
	end
	return ""
end

function GetPlayerRole()
	local _,_,bonusStr = UnitStat("player", 1) local _,_,bonusAgi = UnitStat("player", 2) local _,_,bonusIntel = UnitStat("player", 4)
	if(UnitName("player") == TankName) then return 2 --Tank
	elseif(UnitName("player") == "Saelwyn") then return 3
	elseif(bonusIntel > bonusStr and bonusIntel > bonusAgi) then return 1 --Heal
	elseif(IsShieldEquipped()) then return 2 --Tank
	else return 3 end --Dps
end

function UnitIsCaster(target)
	--Retourne si la cible est un caster
	if((UnitClass(target) == "Priest") or (UnitClass(target) == "Warlock") or (UnitClass(target) == "Mage") or (UnitClass(target) == "Shaman")) then
		return true
	else
		return false
	end
end

function UnitIsRanged(target)
	--Retourne si la cible a une classe à distance
	local playerRole = GetPlayerRole()
	if((target == "player") and ((UnitClass(target) == "Priest") or (UnitClass(target) == "Warlock") or (UnitClass(target) == "Mage") or ((UnitClass(target) == "Druid") and (playerRole < 3)) or ((UnitClass(target) == "Shaman") and (playerRole < 3)) or ((UnitClass(target) == "Paladin") and (playerRole == 1)) or (UnitClass(target) == "Hunter"))) then
		return true
	elseif((target ~= "player") and ((UnitClass(target) == "Priest") or (UnitClass(target) == "Warlock") or (UnitClass(target) == "Mage") or (UnitClass(target) == "Druid") or (UnitClass(target) == "Shaman") or (UnitClass(target) == "Hunter"))) then
		return true
	else
		return false
	end
end

function UnitIsElite(target)
	if((UnitClassification(target) == "elite") or (UnitClassification(target) == "rareelite") or (UnitLevel(target) == -1) or UnitPlayerControlled(target)) then
		return true
	else
		return false
	end
end

function UnitIsBoss(target)
	if(((UnitLevel(target) >= UnitLevel("player")+3) or (UnitLevel(target) == -1) or (UnitHealthMax("target") > UnitHealthMax("player")*4)) and not UnitPlayerControlled(target)) then
		return true
	else
		return false
	end
end

function FollowMultibox(name)
	if(TimerGodMode < 0.1 and FollowBool) then
		for i= 1, GetNumGroupMembers() do
			if(not Combat and not IsGroupInCombat() and (UnitName(tar..i) == name) and CheckInteractDistance(tar..i, 4) and ((not UnitIsDeadOrGhost(tar..i) and not UnitIsDeadOrGhost("player")) or (UnitIsDeadOrGhost(tar..i) and UnitIsDeadOrGhost("player")))) then
				FollowUnit(tar..i)
			end
		end
	end
end

function IsGroupInCombat()
	for i= 1, GetNumGroupMembers() do
		if(UnitAffectingCombat(tar..i)) then return true end
	end
	return false
end

function GetGroupDead(mode)
	mode = mode or 0
	if(mode == 0) then
		for i= 1, GetNumGroupMembers() do
			if(UnitIsDeadOrGhost(tar..i)) then return i end
		end
	else
		for i= GetNumGroupMembers(), 1, -1 do
			if(UnitIsDeadOrGhost(tar..i)) then return i end
		end
	end
	return 0
end

function IsShieldEquipped()
	local _,_,id = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("SecondaryHandSlot")) or "","(item:%d+:%d+:%d+:%d+)")
	if(id ~= nil) then
		local _,_,_,_,itemType = GetItemInfo(id)
		return (itemType=="Armor")
	else return false end
end

--======================================================================--
--=============================    Core    =============================--
--======================================================================--

function GodModeVanilla:OnUpdate()
	  --Variables
	elapsed = (1/GetFramerate())
	tar = "party" if(IsInRaid()) then tar = "raid" end
	ClassifyHeal()
	PrctMana = (UnitMana("player")/UnitManaMax("player"))*100
	TimerGodMode = UpdateTimer(TimerGodMode)
	InnerCDLoad = UpdateTimer(InnerCDLoad)
	if(BreathTimer > 0) then
		BreathTimer = UpdateTimer(BreathTimer)
		if((BreathTimer < 15) and (BlueBool ~= 8)) then TimerGodMode = 0.5 BlueBool = 8 end
	end
	if(TimerGodMode == 0) then
		if(TradePending and IsTrading) then
			if((UnitClass("player") == "Warlock") and (GetTradePlayerItemInfo(1) ~= nil) and string.find(GetTradePlayerItemInfo(1), "Healthstone")) then
				UpdateHealthstoneTab()
			end
			AcceptTrade() TradePending = false ClearCursor()
		end
		TimerGodMode = 1 BlueBool = 0
	end
	AATimer = UpdateTimer(AATimer); RangedAATimer = UpdateTimer(RangedAATimer)
	  --Fonctions
	if(UnitClass("player") == "Shaman" and (GetPlayerRole() < 3)) then
		if(UnitName("player") == "Layera") then Shaman_DpsDist_OnUpdate(elapsed)
		else Shaman_Heal_OnUpdate(elapsed) end
	elseif(UnitClass("player") == "Shaman" and (GetPlayerRole() == 3)) then
		Shaman_Dps_OnUpdate(elapsed)
	elseif(UnitClass("player") == "Hunter") then
		Hunter_OnUpdate(elapsed)
	elseif(UnitClass("player") == "Druid") then
		Druid_OnUpdate(elapsed)
	elseif(UnitClass("player") == "Mage") then
		Mage_OnUpdate(elapsed)
	elseif(UnitClass("player") == "Warlock") then
		Warlock_OnUpdate(elapsed)
	elseif(UnitClass("player") == "Warrior") then
		Warrior_OnUpdate(elapsed)
	elseif(UnitClass("player") == "Paladin" and (GetPlayerRole() == 2)) then
		Paladin_Tank_OnUpdate(elapsed)
	elseif(UnitClass("player") == "Paladin" and (GetPlayerRole() == 1)) then
		Paladin_Heal_OnUpdate(elapsed)
	elseif(UnitClass("player") == "Paladin") then
		Paladin_Dps_OnUpdate(elapsed)
	elseif(UnitClass("player") == "Priest") then
		Priest_OnUpdate(elapsed)
	elseif(UnitClass("player") == "Rogue") then
		Rogue_OnUpdate(elapsed)
	end
end

local function MakeCombatMacro(index, body, txt)
	if(index == 0) then CreateMacro("God Mode", 9, txt, nil)
	elseif(body ~= txt) then EditMacro(index, "God Mode", 9, txt, nil) end
end

function GodModeVanilla:OnEvent(this, event, arg1, arg2, arg3, arg4, arg5)
	if(event =="ADDON_LOADED" and arg1 == "GodModeVanilla") then
		GodModeVanilla.Pixel = GodModeVanilla:CreateTexture()
		GodModeVanilla.Pixel:SetPoint("CENTER", UIParent, "CENTER", -300, -50)
		GodModeVanilla.Pixel:SetWidth(15)
		GodModeVanilla.Pixel:SetHeight(15)
		GodModeVanilla.Pixel:SetTexture(0, 0, 0)
		print("GodModeVanilla chargé !")
	elseif(event == "MIRROR_TIMER_START" and arg1 == "BREATH") then BreathTimer = (arg2/1000) if(BreathTimer < 15) then FollowBool = false end
	elseif(event == "MIRROR_TIMER_STOP" and arg1 == "BREATH") then BreathTimer = -1 FollowBool = true
	elseif((InnerCDLoad == 0) and (event == "UPDATE_WORLD_STATES") or (event =="PLAYER_ENTERING_WORLD")) then
		InnerCDLoad = 60.0
		local macroIndex = GetMacroIndexByName("God Mode")
		local _,_,macroBody = GetMacroInfo(macroIndex)
		if(UnitClass("player") == "Shaman" and (GetPlayerRole() < 3)) then
			if(UnitName("player") == "Layera") then MakeCombatMacro(macroIndex, macroBody, "/run ShamanHeal_DpsDist()")
			else MakeCombatMacro(macroIndex, macroBody, "/run ShamanHeal_Heal()") end
			IDEquipment = GetEquipmentID()
			Shaman_OnLoad()
		elseif(UnitClass("player") == "Shaman" and (GetPlayerRole() == 3)) then
			MakeCombatMacro(macroIndex, macroBody, "/run ShamanHeal_Dps()")
			Shaman_OnLoad()
		elseif(UnitClass("player") == "Hunter") then
			MakeCombatMacro(macroIndex, macroBody, "/run HunterDps()")
		elseif(UnitClass("player") == "Druid") then
			MakeCombatMacro(macroIndex, macroBody, "/run DruidHeal()")
			IDEquipment = GetEquipmentID()
			Druid_OnLoad()
		elseif(UnitClass("player") == "Mage") then
			MakeCombatMacro(macroIndex, macroBody, "/run MageDps()")
		elseif(UnitClass("player") == "Warlock") then
			MakeCombatMacro(macroIndex, macroBody, "/run WarlockDps()")
		elseif(UnitClass("player") == "Warrior") then
			MakeCombatMacro(macroIndex, macroBody, "/run WarriorDps()")
			Warrior_OnLoad()
		elseif(UnitClass("player") == "Paladin" and (GetPlayerRole() == 2)) then
			MakeCombatMacro(macroIndex, macroBody, "/run PaladinHeal_Tank()")
		elseif(UnitClass("player") == "Paladin" and (GetPlayerRole() == 1)) then
			MakeCombatMacro(macroIndex, macroBody, "/run PaladinHeal_Heal()")
		elseif(UnitClass("player") == "Paladin") then
			MakeCombatMacro(macroIndex, macroBody, "/run PaladinHeal_Dps()")
		elseif(UnitClass("player") == "Priest") then
			MakeCombatMacro(macroIndex, macroBody, "/run PriestHeal()")
			IDEquipment = GetEquipmentID()
			Priest_OnLoad()
		elseif(UnitClass("player") == "Rogue") then
			MakeCombatMacro(macroIndex, macroBody, "/run RogueDps()")
		end
	elseif(event == "PLAYER_REGEN_ENABLED") then
		Combat = false TabAggro = {} NbrEnemyAggro = 0
		print("GodModeVanilla: Combat ended")
	elseif(event == "PLAYER_REGEN_DISABLED") then
		Combat = true
		print("GodModeVanilla: Combat engaged")
	elseif(event == "UI_ERROR_MESSAGE") then
		if(((arg1 == "Target needs to be in front of you") or (arg1 == "You are facing the wrong way!")) and (BlueBool ~= 3)) then
			if((GetTank() ~= "") and CheckInteractDistance(GetTank(), 4)) then
				if(not IsFollowing) then FollowByName(TankName) end
			else TimerGodMode = 0.2 BlueBool = 3 end
		elseif(((arg1 == "Out of range.") or (arg1 == "You are too far away!" and not UnitIsRanged("player")) or (arg1 == "Target not in line of sight")) and (BlueBool ~= 4)) then
			if((GetTank() ~= "") and CheckInteractDistance(GetTank(), 4)) then
				if(not IsFollowing) then FollowByName(TankName) end
			elseif((arg1 == "Out of range.") or (arg1 == "Target not in line of sight")) then TimerGodMode = 0.5 BlueBool = 4 end
		elseif(string.find(arg1, "Inventory is full.")) then
			CloseTrade()
		end
	elseif(event == "SPELLCAST_START" or event == "SPELLCAST_CHANNEL_START") then
		--arg1: Spell name | arg2: Cast time (ms)
		CastingInfo = arg1
	elseif(event == "SPELLCAST_STOP" or event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED" or event == "SPELLCAST_CHANNEL_STOP") then
		if(UnitClass("player") == "Shaman" and event == "SPELLCAST_STOP") then
			Shaman_OnCast(CastingInfo)
		elseif(UnitClass("player") == "Warlock" and event == "SPELLCAST_STOP") then
			Warlock_OnCast(CastingInfo)
		end
		CastingInfo = nil
	elseif(event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS") then
		local enemyName = string.sub(arg1, 0, (string.find(arg1, "hits") or string.find(arg1, "crits"))-2)
		if(string.find(arg1, "you")) then UpdateTabAggro(enemyName, true)
		else UpdateTabAggro(enemyName, false) end
	elseif(event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES") then
		local enemyName = string.sub(arg1, 0, (string.find(arg1, "attacks") or string.find(arg1, "misses"))-2)
		UpdateTabAggro(enemyName, true)
		if(string.find(arg1, "parry")) then AATimer = AATimer - UnitAttackSpeed("player")*0.4 end
	elseif(event == "CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS") then
		local enemyName = string.sub(arg1, 0, (string.find(arg1, "hits") or string.find(arg1, "crits"))-2)
		UpdateTabAggro(enemyName, false)
	elseif(event == "CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES") then
		local enemyName = string.sub(arg1, 0, (string.find(arg1, "attacks") or string.find(arg1, "misses"))-2)
		UpdateTabAggro(enemyName, false)
	elseif(event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then PopTabAggro(arg1)
	elseif(event == "CHAT_MSG_COMBAT_SELF_HITS" or event == "CHAT_MSG_COMBAT_SELF_MISSES") then
		AATimer = UnitAttackSpeed("player")
	elseif(event == "CHAT_MSG_SPELL_SELF_DAMAGE") then
		if(string.find(arg1, "Auto Shot")) then RangedAATimer = UnitRangedDamage("player")
		elseif(string.find(arg1, "Heroic Strike")) then AATimer = UnitAttackSpeed("player")
		elseif(string.find(arg1, "Cleave")) then AATimer = UnitAttackSpeed("player") end
	elseif(event == "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF") then
		if((UnitClass("player") == "Warlock") and string.find(arg1, "Healthstone")) then
			for i= 1, GetNumGroupMembers() do
				if(string.find(arg1, UnitName(tar..i))) then UpdateHealthstoneTab(i) end
			end
		end
	elseif(event == "QUEST_DETAIL") then AcceptQuest()
	elseif(event == "TRADE_SHOW") then IsTrading = true
	elseif(event == "TRADE_TARGET_ITEM_CHANGED" and (GetTradeTargetItemLink(arg1) ~= nil) and string.find(GetTradeTargetItemLink(arg1), "Healthstone")) then TimerGodMode = 0.5 TradePending = true
	elseif(event == "TRADE_ACCEPT_UPDATE" and arg1 == 0) then TimerGodMode = 0.5 TradePending = true
	elseif(event == "TRADE_CLOSED") then IsTrading = false TradePending = false
	elseif(event == "AUTOFOLLOW_BEGIN") then IsFollowing = true
	elseif(event == "AUTOFOLLOW_END") then IsFollowing = false
	elseif(event == "MERCHANT_SHOW") then sellUselessItems() RepairAllItems()
	elseif(event == "RESURRECT_REQUEST") then AcceptResurrect() end
end

SLASH_GMVANILLA1 = "/gmvanilla.togglefollow"
local function handler(msg, editBox)
	if(msg == "ON") then
		print("GodModeVanilla: Follow activated")
		FollowBool = true
	elseif(msg == "OFF") then
		print("GodModeVanilla: Follow disabled")
		FollowBool = false
		TimerGodMode = 0.5 BlueBool = 6
	elseif(msg == "") then
		if(FollowBool == true) then
			print("GodModeVanilla: Follow disabled")
			FollowBool = false
			TimerGodMode = 0.5 BlueBool = 6
		else
			print("GodModeVanilla: Follow activated")
			FollowBool = true
		end
	end
end
SlashCmdList["GMVANILLA"] = handler

GodModeVanilla:SetScript("OnEvent", function() GodModeVanilla:OnEvent(this, event, arg1, arg2, arg3, arg4, arg5) end)
GodModeVanilla:SetScript("OnUpdate", function() GodModeVanilla:OnUpdate() end)
GodModeVanilla:RegisterEvent("ADDON_LOADED")
GodModeVanilla:RegisterEvent("PLAYER_ENTERING_WORLD")
GodModeVanilla:RegisterEvent("UPDATE_WORLD_STATES")
GodModeVanilla:RegisterEvent("PLAYER_REGEN_ENABLED")
GodModeVanilla:RegisterEvent("PLAYER_REGEN_DISABLED")
GodModeVanilla:RegisterEvent("UI_ERROR_MESSAGE")
GodModeVanilla:RegisterEvent("SPELLCAST_START")
GodModeVanilla:RegisterEvent("SPELLCAST_CHANNEL_START")
GodModeVanilla:RegisterEvent("SPELLCAST_STOP")
GodModeVanilla:RegisterEvent("SPELLCAST_FAILED")
GodModeVanilla:RegisterEvent("SPELLCAST_INTERRUPTED")
GodModeVanilla:RegisterEvent("SPELLCAST_CHANNEL_STOP")
GodModeVanilla:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
GodModeVanilla:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
GodModeVanilla:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
GodModeVanilla:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS")
GodModeVanilla:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES")
GodModeVanilla:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
GodModeVanilla:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
GodModeVanilla:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
GodModeVanilla:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
GodModeVanilla:RegisterEvent("QUEST_DETAIL")
GodModeVanilla:RegisterEvent("TRADE_SHOW")
GodModeVanilla:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")
GodModeVanilla:RegisterEvent("TRADE_ACCEPT_UPDATE")
GodModeVanilla:RegisterEvent("TRADE_CLOSED")
GodModeVanilla:RegisterEvent("AUTOFOLLOW_BEGIN")
GodModeVanilla:RegisterEvent("AUTOFOLLOW_END")
GodModeVanilla:RegisterEvent("MERCHANT_SHOW")
GodModeVanilla:RegisterEvent("RESURRECT_REQUEST")
GodModeVanilla:RegisterEvent("MIRROR_TIMER_START")
GodModeVanilla:RegisterEvent("MIRROR_TIMER_STOP")
--GodModeVanilla:RegisterAllEvents()