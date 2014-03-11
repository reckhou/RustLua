PLUGIN.Title = "Admin Door"
PLUGIN.Description = "Allows admins to open every door"
PLUGIN.Author = "Hatemail"
PLUGIN.Version = "1.0.3"
print( "Loading " .. PLUGIN.Title .. " V: " .. PLUGIN.Version .. "..." )
function PLUGIN:Init()
	self:AddChatCommand("admindoor", self.AdminDoor)
    self:AddChatCommand("AdminDoor", self.AdminDoor)
	timer.Repeat(tonumber(30),tonumber(2), function() self:CheckForOxmin() end )
end

local DeployableObjectOwnerID = util.GetFieldGetter( Rust.DeployableObject, "ownerID", true )
function PLUGIN:CanOpenDoor( netuser, door )

	local deployable = door:GetComponent( "DeployableObject" )
	if (not deployable) then return end
	local ownerID = tostring( DeployableObjectOwnerID( deployable ) )
	local userID = rust.GetUserID( netuser )
	if (ownerID == userID) then return true end --If you own it you open it simple..
	local steamID = rust.CommunityIDToSteamID(tonumber(userID))
	if (AdminDoorTable[steamID]) then
		return true
	end
	return
end

AdminDoorTable = {}

function PLUGIN:AdminDoor( netuser, cmd, args )
	if  netuser:CanAdmin() or (self.oxminInstalled and oxmin_Plugin:HasFlag(netuser, self.FLAG_ADMINDOOR, false))then 
		local steamID = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))
		if AdminDoorTable[steamID] then
			AdminDoorTable[steamID] = false
			rust.Notice(netuser, "Admin Door De-Activated")
		else
			AdminDoorTable[steamID] = true
			rust.Notice(netuser, "Admin Door Activated")
		end
	else
		rust.Notice(netuser, "You do not have permission to use this command!")
	end
end
function PLUGIN:OnUserDisconnect( netplayer )
	if (netplayer) then
		local netuser = rust.NetUserFromNetPlayer(netplayer)
		local steamID = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser)))
		AdminDoorTable[steamID] = false
	end
		
end
function PLUGIN:CheckForOxmin()
	oxmin_Plugin = plugins.Find("oxmin")

	if not oxmin_Plugin or not oxmin then
		print("Flag AdminDoor not added! Requires Oxmin, retrying")
		self.oxminInstalled = false
		return
	else
		if not self.FLAG_ADMINDOOR then
		self.FLAG_ADMINDOOR = oxmin.AddFlag("AdminDoor")
		self.oxminInstalled = true
		print("Flag AdminDoor added!")
		end
	end
end