PLUGIN.Title = "Remover Tool"
PLUGIN.Description = "Remove Building"
PLUGIN.Author = "Guewen and Thx Rexas"
PLUGIN.Version = "1.6.2"

function PLUGIN:Init()

	print("Remover Load")
	
	local b, res = config.Read( "remover" )
	self.Config = res or {}
	if (not b) then
		self:LoadDefaultConfig()
		if (res) then config.Save( "remover" ) end
	else
		self:LoadUpdateConfig()
	end
	
	oxmin_Plugin = plugins.Find("oxmin")
    if oxmin_Plugin or oxmin then
        self.FLAG_REMOVER = oxmin.AddFlag( "remover" )
    end
	
	group_Plugin = plugins.Find("groups")
    if group_Plugin then
		print("Remover Groups Loaded")
    end
	
	self:AddChatCommand("load", self.loadfiles)
	self:AddChatCommand("loada", self.loadfiles2)

	self:AddChatCommand("removerreload", self.ReloadConfig)
	
	self:AddChatCommand("removeactiveplayer", self.RemoveActivePlayer)
	self:AddChatCommand("removerestoresitems", self.RemoveRestoreItems)
	
	self:AddChatCommand("RemoveAll", self.ActiveRemoveAdminAll)
	self:AddChatCommand("removeall", self.ActiveRemoveAdminAll)
	
	self:AddChatCommand("removesteam", self.RemoveSteamId)
	self:AddChatCommand("RemoveSteam", self.RemoveSteamId)
	
    self:AddChatCommand("RemoveAdmin", self.ActiveRemoveAdmin)
    self:AddChatCommand("removeadmin", self.ActiveRemoveAdmin)

	
    self:AddChatCommand("Remove", self.ActiveRemove)
    self:AddChatCommand("remove", self.ActiveRemove)
	
    self:AddChatCommand("removestatus", self.removestatus)
    self:AddChatCommand("rstatus", self.removestatus)
	
end

function PLUGIN:LoadDefaultConfig()
	self.Config.AllowPlayer = true -- edited me to enable or disable this command to players.  ->  true or false
	self.Config.AllowPlayerGiveItems = true -- edited me to enable or disable restores items.  ->  true or false
	self.Config.UseGroups = false -- edited me to enable or disable remove by groups (plugin http://forum.rustoxide.com/resources/groups.13 )  ->  true or false
end

function PLUGIN:LoadUpdateConfig()

	if not self.Config.UseGroups then self.Config.UseGroups = false end
	config.Save( "remover" )
	
end


function PLUGIN:ReloadConfig(netuser)

	if self:GetAdmin(netuser) then
		local b, res = config.Read( "remover" )
		self.Config = res or {}
	end
	
end

function PLUGIN:loadfiles2( netuser, cmd, args )
	
	cmdReloadPlug("status")
	print(5)
end
function PLUGIN:loadfiles( netuser, cmd, args )
	cmdReloadPlug("0-remover")
	
end

function PLUGIN:GetAdmin(netuser)

	if oxmin_Plugin or oxmin then
		if  oxmin_Plugin:HasFlag( netuser, self.FLAG_REMOVER, false ) then
			return true
		end
    end

	if netuser:CanAdmin() then
		return true
	end	

	return false
end

TableActivedRemove = {}
function PLUGIN:ActiveRemove( netuser, cmd, args )

	if not self.Config.AllowPlayer then 
		rust.Notice(netuser, "Remove De-Actived for player")
		return
	end
	
	local steamID = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))

	if TableActivedRemove[steamID] then
		TableActivedRemove[steamID] = false
		rust.Notice(netuser, "Remove De-Actived")
	else
		TableActivedRemove[steamID] = true
		rust.Notice(netuser, "Remove Actived")
	end
	
end

function PLUGIN:OnResourceNodeLoaded(toto)


end

function PLUGIN:removestatus( netuser, cmd, args )

	rust.SendChatToUser( netuser, "Remover Status" , "Command Actived:" )
	local steamID = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))

	if TableActivedRemove[steamID] then
		rust.SendChatToUser( netuser, "/remove" , "Actived" )
	else
		rust.SendChatToUser( netuser, "/remove" , "De-Actived" )
	end
	
	if self:GetAdmin(netuser) then
		if TableActivedRemoveAmin[steamID] then
			rust.SendChatToUser( netuser, "/removeadmin" , "Actived" )
		else
			rust.SendChatToUser( netuser, "/removeadmin" , "De-Actived" )
		end
		
		if TableActivedRemoveAminAll[steamID] then
			rust.SendChatToUser( netuser, "/removeall" , "Actived" )
		else
			rust.SendChatToUser( netuser, "/removeall" , "De-Actived" )
		end
	end	
end

TableActivedRemoveAmin = {}
function PLUGIN:ActiveRemoveAdmin( netuser, cmd, args )
    if self:GetAdmin(netuser) then
		local steamID = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))

		if TableActivedRemoveAmin[steamID] then
			TableActivedRemoveAmin[steamID] = false
			rust.Notice(netuser, "Remove De-Actived")
		else
			TableActivedRemoveAmin[steamID] = true
			rust.Notice(netuser, "Remove Actived")
		end
	end	
end

TableActivedRemoveAminAll = {}
function PLUGIN:ActiveRemoveAdminAll( netuser, cmd, args )
    if self:GetAdmin(netuser) then
		local steamID = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))

		if TableActivedRemoveAminAll[steamID] then
			TableActivedRemoveAminAll[steamID] = false
			rust.Notice(netuser, "Remove All De-Actived")
			if not varplayer[steamID] then varplayer[steamID] = {} end
			varplayer[steamID].RemoveAllactived = false
			varplayer[steamID].netuser = netuser
		else
			TableActivedRemoveAminAll[steamID] = true
			rust.Notice(netuser, "Remove All Actived ! ! !")
			if not varplayer[steamID] then varplayer[steamID] = {} end
			varplayer[steamID].RemoveAllactived = true
			varplayer[steamID].netuser = netuser
		end
	end	
end

-- for reload
if RemoveTimer then
RemoveTimer:Destroy()
end
RemoveTimer = timer.Repeat( 15, 0, function()

	for k,v in pairs(varplayer) do
		
		if v.RemoveAllactived then
			rust.Notice(v.netuser, "Remove All Is Actived ! ! !")	
		end
		
	end
	
end)


function PLUGIN:RemoveActivePlayer( netuser, cmd, args )
    if self:GetAdmin(netuser) then

		if not self.Config.AllowPlayer then
			
			rust.Notice(netuser, "Remove Actived for player")
			self.Config.AllowPlayer = true
			
		else
		
			rust.Notice(netuser, "Remove Disable for player")
			self.Config.AllowPlayer = false
		
		end

		config.Save( "remover" )
		
	end	
end

function PLUGIN:RemoveRestoreItems( netuser, cmd, args )
    if self:GetAdmin(netuser) then

		if not self.Config.AllowPlayerGiveItems then
		
			rust.Notice(netuser, "Remove restores items Actived")
			self.Config.AllowPlayerGiveItems = true
			
		else
		
			rust.Notice(netuser, "Remove restores items Desable")
			self.Config.AllowPlayerGiveItems = false
			
			
		end
		
		config.Save( "remover" )
		
	end	
end

local GetComponents, SetComponents = typesystem.GetField( Rust.StructureMaster, "_structureComponents", bf.private_instance )
local function GetConnectedComponents( master )
    local hashset = GetComponents( master )
    local tbl = {}
    local it = hashset:GetEnumerator()
    while (it:MoveNext()) do
        tbl[ #tbl + 1 ] = it.Current
    end
    return tbl
end

local ItemTable ={}

-- Base
ItemTable["Wood_Shelter(Clone)"] = "Wood Shelter"
ItemTable["Campfire(Clone)"] = "Camp Fire"
ItemTable["Furnace(Clone)"] = "Furnace"
ItemTable["Workbench(Clone)"] = "Workbench"
ItemTable["SleepingBagA(Clone)"] = "Sleeping Bag"
ItemTable["SingleBed(Clone)"] = "Bed"


-- Attack and protect
ItemTable["LargeWoodSpikeWall(Clone)"] = "Large Spike Wall"
ItemTable["WoodSpikeWall(Clone)"] = "Spike Wall"
ItemTable["Barricade_Fence_Deployable(Clone)"] = "Wood Barricade"
ItemTable["WoodGateway(Clone)"] = "Wood Gateway"
ItemTable["WoodGate(Clone)"] = "Wood Gate"

-- Storage
ItemTable["WoodBoxLarge(Clone)"] = "Large Wood Storage"
ItemTable["WoodBox(Clone)"] = "Wood Storage Box"
ItemTable["SmallStash(Clone)"] = "Small Stash"

-- Structure Wood
ItemTable["WoodFoundation(Clone)"] = "Wood Foundation"
ItemTable["WoodWindowFrame(Clone)"] = "Wood Window"
ItemTable["WoodDoorFrame(Clone)"] = "Wood Doorway"    -- ?
ItemTable["WoodWall(Clone)"] = "Wood Wall"
ItemTable["WoodenDoor(Clone)"] = "Wooden Door"
ItemTable["WoodCeiling(Clone)"] = "Wood Ceiling"
ItemTable["WoodRamp(Clone)"] = "Wood Ramp"
ItemTable["WoodStairs(Clone)"] = "Wood Stairs"
ItemTable["WoodPillar(Clone)"] = "Wood Pillar"

-- Structure Metal
ItemTable["MetalFoundation(Clone)"] = "Metal Foundation"
ItemTable["MetalWall(Clone)"] = "Metal Wall"
ItemTable["MetalDoorFrame(Clone)"] = "Metal Doorway"
ItemTable["MetalDoor(Clone)"] = "Metal Door"
ItemTable["MetalCeiling(Clone)"] = "Metal Ceiling"
ItemTable["MetalStairs(Clone)"] = "Metal Stairs"
ItemTable["MetalRamp(Clone)"] = "Metal Ramp"
ItemTable["MetalBarsWindow(Clone)"] = "Metal Window Bars"
ItemTable["MetalWindowFrame(Clone)"] = "Metal Window"
ItemTable["MetalPillar(Clone)"] = "Metal Pillar"

ents = {}
ents.FindByClass = util.GetStaticMethod( UnityEngine.Resources._type, "FindObjectsOfTypeAll")

function ents:GetAll()
 
	local tab = {}
	
	local allStructureComponent = ents.FindByClass(Rust.StructureComponent._type)
	for i = 0, tonumber(allStructureComponent.Length-1)
	do
		local component = allStructureComponent[i];
		
		table.insert(tab, component)
	end
	
	local allStructureComponent = ents.FindByClass(Rust.DeployableObject._type)
	for i = 0, tonumber(allStructureComponent.Length-1)
	do
		local component = allStructureComponent[i];
		
		table.insert(tab, component)
	end
	
	return tab
	
end

function PLUGIN:OnProcessDamageEvent( takedamage, damage )

	MyHostIsNoMultiplay = true
	
	if takedamage then

		if takedamage.gameObject then

			if takedamage.GetComponent == "GetComponent" then

				plugins.Call( "OnEntityTakeDamage", takedamage.idMain, damage, takedamage.idMain.name)
				return
			end 

			if takedamage.gameObject == "gameObject" then return end
			
			if takedamage.gameObject.Name then

				if ItemTable[takedamage.gameObject.Name] then

					local name = ItemTable[takedamage.gameObject.Name]

					plugins.Call( "OnEntityTakeDamage", takedamage, damage, name )
				end
			end
		end	
	end
end

function PLUGIN:OnHurt( takedamage, damage )

	if MyHostIsNoMultiplay then return end

	if takedamage then

		if takedamage.gameObject then

			if takedamage.GetComponent == "GetComponent" then

				plugins.Call( "OnEntityTakeDamage", takedamage.idMain, damage, takedamage.idMain.name)
				return
			end 

			if takedamage.gameObject == "gameObject" then return end
			
			if takedamage.gameObject.Name then

				if ItemTable[takedamage.gameObject.Name] then

					local name = ItemTable[takedamage.gameObject.Name]

					plugins.Call( "OnEntityTakeDamage", takedamage, damage, name )
				end
			end
		end	
	end
end

varplayer = {}
local GetStructureComponentownerID = util.GetFieldGetter( Rust.StructureMaster, "ownerID", true )
local GetDeployableObjectownerID = util.GetFieldGetter( Rust.DeployableObject, "ownerID", true )
local GetDeployableObjectcreatorID = util.GetFieldGetter( Rust.DeployableObject, "creatorID", true )
local GetDeployableObjectownerName = util.GetFieldGetter( Rust.DeployableObject, "ownerName", true )
NetCullRemove = util.FindOverloadedMethod( Rust.NetCull._type, "Destroy", bf.public_static, { UnityEngine.GameObject} )

IsRemoved= {}
function Remove(object)

	if IsRemoved[object] then return end
	IsRemoved[object] = true
	if object.name == "name" then return end
	if object == "GameObject" then return end
	
	arr = util.ArrayFromTable( cs.gettype( "System.Object" ), { object } )  ;
	cs.convertandsetonarray( arr, 0, object , UnityEngine.GameObject._type )
	NetCullRemove:Invoke( nil, arr )
	
end
function PLUGIN:RemoveSteamId(netuser, cmd, args )
   
	if self:GetAdmin(netuser) then

		if not args[1] then rust.SendChatToUser( netuser, "Error Remove SteamID" , "Use /removesteam \"SteamID\" " ) return end
	
		local steamid = util.QuoteSafe(args[1])
		
		
		for k,v in pairs(ents:GetAll()) do
		
			if (v:GetComponent("StructureComponent")) then
				
				local master = v._master
				
				if master == "_master" then return end
				if type(master) == "string" then return end
				
				if master then 
				
					userID = GetStructureComponentownerID(master)
					SteamIdEntity = rust.CommunityIDToSteamID( userID )
					
				end	
			end

			if (v:GetComponent("DeployableObject")) then
				
				userID = GetDeployableObjectownerID(v)
				SteamIdEntity = rust.CommunityIDToSteamID( userID )
				
			end
			
			if SteamIdEntity == steamid then
				Remove(v.GameObject)
			end	
			
		end
		
	end
	
end

function PLUGIN:OnEntityTakeDamage( takedamage, damage , name)

	local netuser = nil
	local steamID = nil
	local userID = nil
	
	if damage then
	
		if damage.attacker then
			
			if damage.attacker.client then
		
				if damage.attacker.client.netUser then
			
					netuser = damage.attacker.client.netUser
				
					if self:GetAdmin(netuser) then
						allow = true
					end
				
					steamID = rust.CommunityIDToSteamID( tonumber(rust.GetUserID(netuser )))
				else
					return
				end
			else
				return
			end
			
			if damage.attacker.idMain then
				
				if damage.attacker.idMain.GetComponent == "GetComponent" then
					
					if not damage.attacker.client.netUser then
						netuser = nil
					end
				
				else
				
					if type(damage.attacker.idMain:GetComponent("PlayerInventory")) == "nil" then
						netuser = nil
					
					else
						
					end
				
				end
			end
		end
	end

	if not netuser then return end

	if TableActivedRemoveAminAll[steamID] then
		if allow then

			if takedamage.GameObject:GetComponent("StructureComponent") then
				local entity = takedamage.GameObject:GetComponent("StructureComponent")
				if not entity then return end
				for k,v in pairs (GetConnectedComponents(entity._master) ) do
			
					timer.Once(0.5, function()  Remove(v.GameObject) end)
				
				end
			end	
			
		end  
	end 

	if TableActivedRemoveAmin[steamID] then
		if allow then
		
			timer.Once(0.5, function()  Remove(takedamage.GameObject) end)
			return
	
		end  
	end  
	
	if (takedamage.GameObject:GetComponent("StructureComponent")) then
		entity = takedamage.GameObject:GetComponent("StructureComponent")
		local master = entity._master
		
		if master == "_master" then return end
		if type(master) == "string" then return end
		
		if master then 
		
			userID = GetStructureComponentownerID(master)
			SteamIdEntity = rust.CommunityIDToSteamID( userID )
			
		end	
	end

	if (takedamage.GameObject:GetComponent("DeployableObject")) then
		entity = takedamage.GameObject:GetComponent("DeployableObject")
	
		if entity.GetComponent == "GetComponent" then
			return
		end
		
		if type(entity.GetComponent) == "string" then return end
		
		userID = GetDeployableObjectownerID(entity)
		SteamIdEntity = rust.CommunityIDToSteamID( userID )
	end
	
	if self.Config.AllowPlayer then
	
		if TableActivedRemove[steamID] then
			
			local AllowGroup = false
			
			local userID2 = rust.GetUserID( netuser )
			if self.Config.UseGroups then
				if group_Plugin then
				
					local id1 = group_Plugin:checkPlayerGroup(userID2)
					local id2 = group_Plugin:checkPlayerGroup(tostring(userID))
			
					if id1 == id2 then
						AllowGroup = true
					end
					
				end
			end
	
			if (SteamIdEntity == steamID) or AllowGroup then
			
				if self.Config.AllowPlayerGiveItems then
					if not varplayer[steamID] then varplayer[steamID] = {} end
					if not varplayer[steamID].OldRemove then varplayer[steamID].OldRemove = {} end
					
					-- Fix duplication shootgun
					local dup = false
					for a,b in pairs(varplayer[steamID].OldRemove) do
						if b == entity then
							dup = true
						end
					end
					-- local dup = varplayer[steamID].OldRemove == entity
					if not dup then
						
						local nodrop = false
						
						if takedamage.gameObject.Name == "Campfire(Clone)" then
							local wood = rust.GetDatablockByName( "Wood" )


							inv = entity:GetComponent( "Inventory" )
							local item1 = inv:FindItem(wood)
							if item1 then
								
								
								if item1.uses >= 5 then
								
									if item1.uses > 5 then
										local num = item1.uses - 5
										timer.Once(0.05, function()  
											local netusers = netuser
											rust.RunServerCommand("inv.giveplayer \"" .. util.QuoteSafe( netusers.displayName ) .. "\" \"" .. util.QuoteSafe( "Wood" ) .. "\" " .. num ) 
											rust.InventoryNotice( netusers, num .. " x Wood" )
										end)
									end
								else
									nodrop = true
									timer.Once(0.05, function()  
										local netusers = netuser
										rust.RunServerCommand("inv.giveplayer \"" .. util.QuoteSafe( netusers.displayName ) .. "\" \"" .. util.QuoteSafe( "Wood" ) .. "\" " .. item1.uses ) 
										rust.InventoryNotice( netusers, item1.uses .. " x Wood" )
									end)
								end
							else
								nodrop = true
							end	
						end
						
						
						if not nodrop then
							
							timer.Once(0.05, function()  
								local netusers = netuser
								rust.RunServerCommand("inv.giveplayer \"" .. util.QuoteSafe( netusers.displayName ) .. "\" \"" .. util.QuoteSafe( name ) .. "\" " .. 1 ) 
								rust.InventoryNotice( netusers, 1 .. " x " .. name )
							end)
							
						end	
						
					end	
				end
				
				if not varplayer[steamID] then varplayer[steamID] = {} end
				if not varplayer[steamID].OldRemove then varplayer[steamID].OldRemove = {} end
				
				table.insert(varplayer[steamID].OldRemove, entity)
				
				timer.Once(0.5, function()  Remove(takedamage.GameObject) end)
				return
				
			end
		end
	end
end