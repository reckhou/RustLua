--[[ ************************* ]]--
--[[ lootspawnlists - thomasfn ]]--
--[[ ************************* ]]--


-- Define plugin variables
PLUGIN.Title = "Loot Spawn Lists"
PLUGIN.Description = "Allows customisation of the spawn lists for loot"
PLUGIN.Author = "thomasfn"
PLUGIN.Version = "1.1"

-- Load some util methods
--local GetSpawnLists = static_field_get( Rust.DatablockDictionary, "_lootSpawnLists" )
--local ScriptableObjectCreateOverloads = static( UnityEngine.ScriptableObject, "CreateInstance" )
--local ScriptableObjectCreateMethod = rust.FindOverload( ScriptableObjectCreateOverloads, { System.Type } )
local ScriptableObjectCreateMethod = util.FindOverloadedMethod( UnityEngine.ScriptableObject, "CreateInstance", bf.public_static, { System.Type } )
--util.FindOverloadedMethod( Rust.BasicDoor, "ToggleStateServer", bf.private_instance, { NullableOfVector3, System.UInt64, NullableOfBoolean } )
local function ScriptableObjectCreate( typ )
	typ = typesystem.TypeFromMetatype( typ )
	return ScriptableObjectCreateMethod:Invoke( nil, util.ArrayFromTable( System.Object, { typ } ) )
end

-- *******************************************
-- PLUGIN:OnDatablocksLoaded()
-- Called when the datablocks are ready to be modified
-- *******************************************
function PLUGIN:OnDatablocksLoaded()
	-- Get default spawn lists
	self.DefaultSpawnlists = self:LoadDefaultSpawnlists()
	
	-- Read custom loot tables in
	local data = util.GetDatafile( "loot_tables" )
	if (data:GetText() == "") then
		data:SetText( json.encode( self.DefaultSpawnlists, { indent = true } ) )
		data:Save()
		self.Spawnlists = self.DefaultSpawnlists
	else
		self.Spawnlists = json.decode( data:GetText() )
		self:PatchNewSpawnlists()
	end
end

-- *******************************************
-- PLUGIN:LoadDefaultSpawnlists()
-- Loads the default spawn lists
-- *******************************************
function PLUGIN:LoadDefaultSpawnlists()
	local spawnlists = Rust.DatablockDictionary._lootSpawnLists
	local tblspawnlists = {}
	local keyenum = spawnlists.Keys:GetEnumerator()
	while (keyenum:MoveNext()) do
		local key = keyenum.Current
		local lootspawnlist = spawnlists[ key ]
		local spawnlist = {}
		spawnlist.min = lootspawnlist.minPackagesToSpawn
		spawnlist.max = lootspawnlist.maxPackagesToSpawn
		spawnlist.nodupes = lootspawnlist.noDuplicates
		spawnlist.oneofeach = lootspawnlist.spawnOneOfEach
		spawnlist.packages = {}
		for i=0, lootspawnlist.LootPackages.Length - 1 do
			local entry = lootspawnlist.LootPackages[i]
			local tblentry = {}
			--local t = entry.obj:GetType()
			--if (t:IsAssignableFrom( Rust.Datablock )) then
				--tblentry.object = entry.obj.name
			--end
			--print( entry.obj:GetType().FullName .. " - " .. tostring( entry.obj ) )
			if (entry.obj) then
				tblentry.object = entry.obj.name
			else
				tblentry.object = tostring( entry.obj )
			end
			tblentry.weight = entry.weight
			tblentry.min = entry.amountMin
			tblentry.max = entry.amountMax
			spawnlist.packages[i] = tblentry
		end
		tblspawnlists[ key ] = spawnlist
	end
	return tblspawnlists
end

-- *******************************************
-- PLUGIN:PatchNewSpawnlists()
-- Patches new spawn lists into the server
-- *******************************************
local LootWeightedEntry = cs.gettype( "LootSpawnList+LootWeightedEntry, Assembly-CSharp" )
function PLUGIN:PatchNewSpawnlists()
	local spawnlistobjects = {}
	local cnt = 0
	for k, v in pairs( self.Spawnlists ) do
		local obj = ScriptableObjectCreate( Rust.LootSpawnList )
		obj.minPackagesToSpawn = v.min
		obj.maxPackagesToSpawn = v.max
		obj.noDuplicates = v.nodupes
		obj.spawnOneOfEach = v.oneofeach
		obj.name = k
		spawnlistobjects[ k ] = obj
		cnt = cnt + 1
	end
	for k, v in pairs( self.Spawnlists ) do
		local entrylist = {}
		local i = 0
		local is = "0"
		while (v.packages[ is ]) do
			local entry = v.packages[ is ]
			local entryobj = new( LootWeightedEntry )
			entryobj.amountMin = entry.min
			entryobj.amountMax = entry.max
			entryobj.weight = entry.weight
			if (spawnlistobjects[ entry.object ]) then
				entryobj.obj = spawnlistobjects[ entry.object ]
				if (not entryobj.obj) then
					error( "Couldn't find spawn list by name '" .. entry.object .. "'!" )
				end
			else
				entryobj.obj = rust.GetDatablockByName( entry.object )
				if (not entryobj.obj) then
					error( "Couldn't find datablock by name '" .. entry.object .. "'!" )
				end
			end
			entrylist[ i + 1 ] = entryobj
			i = i + 1
			is = tostring( i )
		end
		spawnlistobjects[ k ].LootPackages = util.ArrayFromTable( LootWeightedEntry, entrylist )
	end
	local spawnlists = Rust.DatablockDictionary._lootSpawnLists
	spawnlists:Clear()
	for k, v in pairs( self.Spawnlists ) do
		spawnlists:Add( k, spawnlistobjects[ k ] )
	end
	print( tostring( cnt ) .. " custom loot tables were loaded!" )
end