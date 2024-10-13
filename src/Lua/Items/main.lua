// WEAPON SYSTEM BY @j1sk ON DISCORD
// ORIGINALLY FOR ZE2

// MM ITEM SYSTEM V2

local ITEM_DEF = {
	id = "knife",

	display_name = "Knife",
	display_icon = "MM_KNIFE",

	state = S_THOK,

	timeleft = -1,

	hit_time = 35,
	animation_time = 35,
	cooldown_time = 35,

	animation_position = {x = 0, y = 0, z = 0},
	hit_position = {x = 0, y = 0, z = 0},

	sidestick = true,
	animation = true,
	damage = true,
	weaponize = true, -- enable to put item in right hand and allow for dual-wielding with regular items
	droppable = false, -- enable to let item be dropped
	shootable = false, -- enable to make weapon shoot projectiles instead of stabbing
	shootmobj = MT_THOK, -- the mobj type it shoots

	// not required, for scripters
	pickup = func,
	equip = func,
	thinker = func,
	attack = func,
	hit = func
}

local ITEM_STRUCT = {
	id = "knife",

	display_name = "Knife",
	display_icon = "MM_KNIFE",

	mobj = MT_THOK,
	state = S_THOK,

	timeleft = -1,

	max_hit = 0,
	max_cooldown = 0,
	max_anim = 0

	hit = 0,
	anim = 0,
	cooldown = 0,

	pos = {x = 0, y = 0, z = 0},
	default_pos = {x = 0, y = 0, z = 0},
	anim_pos = {x = 0, y = 0, z = 0},

	sidestick = true,
	animation = true,
	damage = true,
	weaponize = true, -- enable to put item in right hand and allow for dual-wielding with regular items
	droppable = false, -- enable to let item be dropped
	shootable = false, -- enable to make weapon shoot projectiles instead of stabbing
	shootmobj = MT_THOK, -- the mobj type it shoots

	bullets = {} -- save valid bullets here incase modders decide they wanna do cool shit
}

local shallowCopy = MM.require "Libs/shallowCopy"

MM.Items = {}

function MM:CreateItem(input_table)
	if not input_table then
		error("ItemDef not found.")
	end
	if type(input_table) ~= "table" then
		error("ItemDef (Argument #1) is not a table.")
	end

	for k,v in pairs(ITEM_DEF) do
		if input_table[k] == nil
		or type(input_table[k]) ~= type(ITEM_DEF[k]) then
			if item_input[k] == nil then
				print(tostring(k).." is nil. It has been corrected to the default property from ITEM_DEF.")
			else
				print(tostring(k).." is not the same type as the default. It has been corrected to the default property from ITEM_DEF.")
			end
			print("View pk3/Lua/Items/main.lua for more information.")

			input_table[k] = ITEM_DEF[k]
		end
	end

	MM.Items[input_table.id] = input_table

	print("\x84MM:".."\x82 Item ".."\""..input_table.id.." ("..idname..")".."\" included ["..(#self.ItemPresets).."]")
	return true
end



function MM:FetchInventory(p)
	if not (p and p.valid and p.mm) then return end

	return p.mm.inventory and p.mm.inventory.items
end

function MM:FetchInventoryLimit(p)
	if not (p and p.valid and p.mm) then return 1 end
	return 5 -- placeholder, will expand later
end

function MM:FetchInventorySlot(p, slot)
	if not (p and p.valid and p.mm) then return end

	local inv = self:FetchInventory(p)
	slot = $ or p.mm.inventory.cur_sel

	return inv and inv[slot]
end

function MM:ClearInventorySlot(p, slot)
	if not (p and p.valid and p.mm) then return end

	slot = $ or p.mm.inventory.cur_sel

	local inv = self:FetchInventory(p)
	if inv and inv[slot] then
		inv[slot] = nil
		return true
	end

	return false
end

-- returns number
function MM:FetchEmptySlot(p)
	if not (p and p.valid and p.mm) then return end

	for i=1,self:FetchInventoryLimit(p) do
		if not (self:FetchInventorySlot(p, i)) then
			return i
		end	
	end
	
	return false
end

function MM:GetInventoryItemFromId(p, item_id)
	if not (p and p.valid and p.mm) then return end

	local found
	local found_slot
	
	for i=1,self:FetchInventoryLimit(p) do
		if self:FetchInventorySlot(p, i)
		and self:FetchInventorySlot(p, i).item_id
		and self:FetchInventorySlot(p, i).item_id == item_id then
			found = self:FetchInventorySlot(p, i)
			found_slot = i
			
			return found, found_slot
		end
	end
		
	return false
end

function MM:IsInventoryFull(p)
	if not (p and p.valid and p.mm) then return end
	local inv = self:FetchInventory(p)

	if inv
	and #self:FetchInventory(p) >= self:FetchInventoryLimit(p) then
		return true
	elseif inv then
		return false
	end

	return true
end

function MM:GetItemInfoIndex(iteminfo, index, skin, real)
	if not iteminfo then return end

	if not (iteminfo.skin_overwrite
	and iteminfo.skin_overwrite[skin])
	or not skin
	and index then -- no overwrite or no skin, has index
		return iteminfo[index]
	elseif index then
		if skin and iteminfo.skin_overwrite[skin][index] and not real then
			return iteminfo.skin_overwrite[skin][index]
		elseif iteminfo[index] then
			return iteminfo[index]
		end
	end
end

function MM:SetItemInfoIndex(iteminfo, index, value, skin, real)
	if not iteminfo then return end
	if value == nil then return end

	if not (iteminfo.skin_overwrite and iteminfo.skin_overwrite[skin]) or not skin and index then -- no overwrite or no skin, has index
		if iteminfo[index] then
			iteminfo[index] = value
		end
	elseif index then
		if skin and iteminfo.skin_overwrite[skin][index] and not real then
			iteminfo.skin_overwrite[skin][index] = value
		elseif iteminfo[index] then
			iteminfo[index] = value
		end
	end
end

function MM:CopyItemFromID(item_id)
	local item = shallowCopy(self.ItemPresets[item_id]) or error("Invalid item_id.")

	item.ontrigger = nil
	item.onspawn = nil
	item.onhit = nil
	item.thinker = nil

	return item
end

-- iteminfo can be number or table
function MM:GiveItem(p, item_input, count, slot, overrides)
	if not (p and p.valid and p.mm) then return end

	local datatype = type(item_input)
	local isName = datatype == "string"
	
	if not item_input
	or (isName and item_input and not self.Items[item_input]) then
		return false
	elseif self:FetchInventory(p) then
		local item = shallowCopy(ITEM_STRUCT)
		local def = self.Items[item_input]

		item.id = def.id

		item.display_name = def.display_name
		item.display_icon = def.display_icon

		item.mobj = P_SpawnMobjFromMobj(p.mo, 0,0,0, MT_THOK)
		item.mobj.tics = -1
		item.mobj.fuse = -1

		item.state = def.state

		item.timeleft = def.timeleft

		item.max_hit = def.hit_time
		item.max_anim = def.animation_time
		item.max_cooldown = def.cooldown_time

		item.pos = shallowCopy(def.animation_position)
		item.default_pos = shallowCopy(def.animation_position)
		item.hit_position = shallowCopy(def.hit_position)

		item.sidestick = def.sidestick
		item.animation = def.animation
		item.damage = def.damage
		item.weaponize = def.weaponize
		item.droppable = def.droppable
		item.shootable = def.shootable
		item.shootmobj = def.shootmobj
		
		if slot then
			self:FetchInventory(p)[i] = item
			return true
		end

		local real_count = count or item.count
		local item_id
		
		if isNumber then
			item_id = item_input
		elseif isTable then
			item_id = item_input.item_id
		end
		
		local fitem,fslot = self:GetInventoryItemFromId(p, item_id) --print(fitem,fslot)

		if fitem and fitem.count and fitem.count + real_count <= fitem.max_count then
			self:FetchInventorySlot(p, fslot).count = $ + real_count
			--print("Added apon exiting item")
		elseif self:FetchEmptySlot(p) then
			local emptyslot = self:FetchEmptySlot(p) 
			
			if emptyslot then
				self:FetchInventory(p)[emptyslot] = item
				--print("Went to empty slot")
			end
		else
			CONS_Printf(p, "\x85\Inventory full!")
			return false
		end
		
		return true
	elseif not self:FetchInventory(p) then
		CONS_Printf(p, "\x85\Invalid inventory!")
		return false
	end
	
	return false
end

// FETCH VALID ITEMS

dofile "Items/Weapons/main"