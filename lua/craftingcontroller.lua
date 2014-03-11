--[[ ***************************** ]]--
--[[ craftingcontroller - thomasfn ]]--
--[[ ***************************** ]]--


-- Define plugin variables
PLUGIN.Title = "Crafting Controller"
PLUGIN.Description = "Allows restriction of crafting and research"
PLUGIN.Author = "thomasfn"
PLUGIN.Version = "1.1"

local BlockResearchMessage = "Researching this item has been blocked."
local BlockBlueprintMessage = "This blueprint has been disabled."
local BlockCraftingMessage = "Crafting this item has been blocked."

typesystem.LoadEnum( cs.gettype( "InventoryItem+MergeResult, Assembly-CSharp" ), "MergeResult" )

-- *******************************************
-- PLUGIN:Init()
-- Initialises the plugin
-- *******************************************
function PLUGIN:Init()
	-- Load the config file
	local b, res = config.Read( "craftingcontroller" )
	self.Config = res or {}
	if (not b) then
		self:LoadDefaultConfig()
		if (res) then config.Save( "craftingcontroller" ) end
	end
	
	-- Notify console
	local cnt = 0
	for _, _ in pairs( self.Config.BlockedCrafting ) do cnt = cnt + 1 end
	if (cnt > 0) then print( tostring( cnt ) .. " items have been blocked from crafting" ) end
	cnt = 0
	for _, _ in pairs( self.Config.BlockedResearching ) do cnt = cnt + 1 end
	if (cnt > 0) then print( tostring( cnt ) .. " items have been blocked from researching" ) end
	cnt = 0
	for _, _ in pairs( self.Config.BlockedBlueprints ) do cnt = cnt + 1 end
	if (cnt > 0) then print( tostring( cnt ) .. " blueprints have been disabled" ) end
end

-- *******************************************
-- PLUGIN:LoadDefaultConfig()
-- Loads the default configuration
-- *******************************************
function PLUGIN:LoadDefaultConfig()
	self.Config.BlockedCrafting = {}
	self.Config.BlockedResearching = {}
	self.Config.BlockedBlueprints = {}
	self.Config.blockresearchmessage = "Researching this item has been blocked."
	self.Config.blockblueprintmessage = "This blueprint has been disabled."
	self.Config.blockcraftingmessage = "Crafting this item has been blocked."
end

-- *******************************************
-- PLUGIN:OnResearchItem()
-- Called when a user tries to research an item
-- *******************************************
function PLUGIN:OnResearchItem( researchtoolitem, item )
	--print( "OnResearchItem " .. item.datablock.name )
	if (self.Config.BlockedResearching[ item.datablock.name ]) then
		local playerinv = researchtoolitem.inventory
		if (playerinv and item.inventory == playerinv) then
			local netuser = rust.NetUserFromNetPlayer( playerinv.networkViewOwner )
			if (netuser) then
				rust.Notice( netuser, self.Config.blockresearchmessage )
			end
		end
		--print( "BLOCKED" )
		return MergeResult.Failed
	end
end

-- *******************************************
-- PLUGIN:OnBlueprintUse()
-- Called when a user tries to use a blueprint
-- *******************************************
function PLUGIN:OnBlueprintUse( blueprint, item )
	--print( "OnBlueprintUse " .. blueprint.name )
	if (self.Config.BlockedBlueprints[ blueprint.name ]) then
		local playerinv = item.inventory
		if (playerinv) then
			local netuser = rust.NetUserFromNetPlayer( playerinv.networkViewOwner )
			if (netuser) then
				rust.Notice( netuser, self.Config.blockblueprintmessage )
			end
		end
		--print( "BLOCKED" )
		return true
	end
end

-- *******************************************
-- PLUGIN:OnStartCrafting()
-- Called when a user tries to craft an item
-- *******************************************
function PLUGIN:OnStartCrafting( inv, blueprint, amount, starttime )
	--print( "OnStartCrafting " .. blueprint.resultItem.name )
	if (self.Config.BlockedCrafting[ blueprint.resultItem.name ]) then
		local netuser = rust.NetUserFromNetPlayer( inv.networkViewOwner )
		if (netuser) then
			rust.Notice( netuser, self.Config.blockcraftingmessage )
		end
		--print( "BLOCKED" )
		return true
	end
end