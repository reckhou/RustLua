PLUGIN.Title = "AirDropInbound"
PLUGIN.Version = "1.2"
PLUGIN.Description = "Announce AirDrops with distance and direction in Chat!"
PLUGIN.Author = "FeuerSturm91"

function PLUGIN:Init()
	print( self.Title .. " v" .. self.Version .. ": successfully initialized! Enjoy!" )
end

function PLUGIN:OnDatablocksLoaded()
	self:LoadConfig()
end

function PLUGIN:LoadConfig()
	local AirDropInbound = "AirDropInbound"
	local b, res = config.Read(AirDropInbound)
	self.Config = res or {}
	if (not b) then
		self:LoadDefaultConfig()
		if (res) then
			config.Save(AirDropInbound)
		end
	end
end

function PLUGIN:LoadDefaultConfig()
	self.Config.plugin_enabled = true
	self.Config.display_location = true
	self.Config.display_distance_and_direction = true
	print("AdminChat: cfg_AirDropInbound.txt has been created!")
end

function PLUGIN:OnAirdrop( AirDropPosition )
	if (self.Config.plugin_enabled) then
		local location = "Airdrop inbound 空投正在进行"
		local distdir = ""
		if (self.Config.display_location) then
			location = "AirDrop is going down near " .. self:GetLocation( AirDropPosition ) .. "!"
		end
		local players = rust.GetAllNetUsers()
		for i = 1, #players do
			local netuser = players[i]
			if (self.Config.display_distance_and_direction and netuser.playerClient.hasLastKnownPosition) then
				local lastKnownPosition = netuser.playerClient.lastKnownPosition
				local distance = math.floor(math.sqrt(math.pow(AirDropPosition.x - lastKnownPosition.x,2) + math.pow(AirDropPosition.z - lastKnownPosition.z,2)))
				local direction = self:GetDirection( AirDropPosition, lastKnownPosition )
				distdir = " (approx. " .. distance .. "m " .. direction .. " of your position)"
			end
			local message = location .. distdir
			rust.SendChatToUser( netuser, "[AirDropInbound]",  message)
		end
	end
end

function PLUGIN:GetDirection( AirDropPosition, lastKnownPosition )
	local direction = "unknown direction"
	local northsouth = "unknown direction"
	local eastwest = "unknown direction"
	local diffx = math.abs(AirDropPosition.x - lastKnownPosition.x)
	local diffz = math.abs(AirDropPosition.z - lastKnownPosition.z)
	if (lastKnownPosition.x < AirDropPosition.x) then northsouth = "South" else northsouth = "North" end
	if (lastKnownPosition.z < AirDropPosition.z) then westeast = "East" else westeast = "West" end
	if (diffx / diffz <= 0.5) then direction = westeast end
	if (diffx / diffz > 0.5 and diffx / diffz < 1.5) then direction = northsouth .. "-" .. westeast end
	if (diffx / diffz >= 1.5) then direction = northsouth end
	return direction
end

function PLUGIN:GetLocation( AirDropPosition )
	local areas = {
		{ description = "Hacker Valley South", x = 5907, z = -1848 },
		{ description = "Hacker Mountain South", x = 5268, z = -1961 },
		{ description = "Hacker Valley Middle", x = 5268, z = -2700 },
		{ description = "Hacker Mountain North", x = 4529, z = -2274 },
		{ description = "Hacker Valley North", x = 4416, z = -2813 },
		{ description = "Wasteland North", x = 3208, z = -4191 },
		{ description = "Wasteland South", x = 6433, z = -2374 },
		{ description = "Wasteland East", x = 4942, z = -2061 },
		{ description = "Wasteland West", x = 3827, z = -5682 },
		{ description = "Sweden", x = 3677, z = -4617 },
		{ description = "Everust Mountain", x = 5005, z = -3226 },
		{ description = "North Everust Mountain", x = 4316, z = -3439 },
		{ description = "South Everust Mountain", x = 5907, z = -2700 },
		{ description = "Metal Valley", x = 6825, z = -3038 },
		{ description = "Metal Mountain", x = 7185, z = -3339 },
		{ description = "Metal Hill", x = 5055, z = -5256 },
		{ description = "Resource Mountain", x = 5268, z = -3665 },
		{ description = "Resource Valley", x = 5531, z = -3552 },
		{ description = "Resource Hole", x = 6942, z = -3502 },
		{ description = "Resource Road", x = 6659, z = -3527 },
		{ description = "Beach", x = 5494, z = -5770 },
		{ description = "Beach Mountain", x = 5108, z = -5875 },
		{ description = "Coast Valley", x = 5501, z = -5286 },
		{ description = "Coast Mountain", x = 5750, z = -4677 },
		{ description = "Coast Resource", x = 6120, z = -4930 },
		{ description = "Secret Mountain", x = 6709, z = -4730 },
		{ description = "Secret Valley", x = 7085, z = -4617 },
		{ description = "Factory Radtown", x = 6446, z = -4667 },
		{ description = "Small Radtown", x = 6120, z = -3452 },
		{ description = "Big Radtown", x = 5218, z = -4800 },
		{ description = "Hangar", x = 6809, z = -4304 },
		{ description = "Tanks", x = 6859, z = -3865 },
		{ description = "Civilian Forest", x = 6659, z = -4028 },
		{ description = "Civilian Mountain", x = 6346, z = -4028 },
		{ description = "Civilian Road", x = 6120, z = -4404 },
		{ description = "Ballzack Mountain", x =4316, z = -5682 },
		{ description = "Ballzack Valley", x = 4720, z = -5660 },
		{ description = "Spain Valley", x = 4742, z = -5143 },
		{ description = "Portugal Mountain", x = 4203, z = -4570 },
		{ description = "Portugal", x = 4579, z = -4637 },
		{ description = "Lone Tree Mountain", x = 4842, z = -4354 },
		{ description = "Forest", x = 5368, z = -4434 },
		{ description = "Rad-Town Valley", x = 5907, z = -3400 },
		{ description = "Next Valley", x = 4955, z = -3900 },
		{ description = "Silk Valley", x = 5674, z = -4048 },
		{ description = "French Valley", x = 5995, z = -3978 },
		{ description = "Ecko Valley", x = 7085, z = -3815 },
		{ description = "Ecko Mountain", x = 7348, z = -4100 },
		{ description = "Middle Mountain", x = 6346, z = -4028 },
		{ description = "Zombie Hill", x = 6396, z = -3428 }
	}
	local nearest = -1
	local nearestIndex = -1
	for i = 1, #areas do
	   if (nearestIndex == -1) then
			nearest = (areas[i].x-AirDropPosition.x)^2+(areas[i].z-AirDropPosition.z)^2
			nearestIndex = i
	   else
			local distance = (areas[i].x-AirDropPosition.x)^2+(areas[i].z-AirDropPosition.z)^2
			if (distance < nearest) then
				nearest = distance
				nearestIndex = i
			end
	   end
	end
	return areas[nearestIndex].description
end
