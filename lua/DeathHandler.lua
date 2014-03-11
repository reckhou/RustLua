PLUGIN.Title = "Death Handler"
PLUGIN.Description = "Broadcast death messages to chat."
PLUGIN.Version = "1.6.2"
PLUGIN.ConfigVersion = "1.6"
PLUGIN.Author = "Hatemail"
PLUGIN.RID ="58"
print( "Loading " .. PLUGIN.Title .. " V: " .. PLUGIN.Version .. " ..." )

if not fileLog then fileLog = {} end

function PLUGIN:Init()
	self:UpdateCheck()
	self:LoadConfig()
	self:LoadChatCommands()
	self:LoadLog()
end

function PLUGIN:LoadLog()
	startDateTime = System.DateTime.Now:ToString("MM/dd/yyyy")
	if self.Config.logToFile then
		fileLog.file = util.GetDatafile(string.gsub("Death Handler - " .. startDateTime , "/", "-"))
		local logText = fileLog.file:GetText()
		if (logText ~= "") then
			fileLog.text = split("\r\n", logText)
		else
			fileLog.text = {}
		end
		
	end
end

function PLUGIN:PostInit()
    self:LoadFlags()
end

function PLUGIN:LoadConfig()
	local b, res = config.Read( "Death Handler" )
	self.Config = res or {}
	if (not b) then
		print("Loading Default Death Handler Config...")
		self:LoadDefaultConfig()
		if (res) then config.Save( "Death Handler" ) end
	end
	if ( self.Config.configVersion ~= self.ConfigVersion) then
		print("Out of date Death Handler Config, Updating!")
		self:LoadDefaultConfig()
		config.Save( "Death Handler" )
	end
end

function PLUGIN:LoadFlags()
    self.oxminPlugin = plugins.Find("oxmin")
    if (self.oxminPlugin) then
        self.FLAG_DEATHCONFIG = oxmin.AddFlag("Deathconfig")
        self.oxminPlugin:AddExternalOxminChatCommand(self, "death", { self.FLAG_DEATHCONFIG }, self.setConfigValue)
    end

    self.flagsPlugin = plugins.Find("flags")
    if (self.flagsPlugin) then
        self.flagsPlugin:AddFlagsChatCommand(self, "death", { "Deathconfig" }, self.setConfigValue)
    end
end
function PLUGIN:HasFlag(netuser, flag)
    if (netuser:CanAdmin()) then
        do return true end
    elseif ((self.oxminPlugin ~= nil) and (self.oxminPlugin:HasFlag(netuser, flag))) then
       do return true end
    elseif ((self.flagsPlugin ~= nil) and (self.flagsPlugin:HasFlag(netuser, flag))) then
       do return true end
    end
    return false
end

function PLUGIN:LoadChatCommands()
	self:AddChatCommand( "death", self.setConfigValue)
end

function fileLog.save()
	fileLog.file:SetText( table.concat( fileLog.text, "\r\n" ) )
	fileLog.file:Save()
end

function PLUGIN:LoadDefaultConfig()
	self.Config.configVersion 			=	"1.6"
	self.Config.logToConsole 			=	false
	self.Config.logToAdmin 				=	false
	self.Config.logToAdminChat			=	false
	self.Config.logToAdminConsole 		=	false
	self.Config.logToFile 				=	true
	self.Config.broadCastChat 			=	true
	self.Config.deathByEntity 			=	true
	self.Config.player 					=	true
	self.Config.bear 					=	false
	self.Config.wolf 					=	false
	self.Config.stag 					=	false
	self.Config.chicken 				=	false
	self.Config.rabbit 					=	false
	self.Config.boar 					=	false
	self.Config.suicide 				=	true
	self.Config.suicideMessage 			=	"@{killed} has commited suicide"
	self.Config.chatName 				=	"Death"
	self.Config.notifyKiller 			=	true
	self.Config.playerDeathMessage 		=	"@{killer} killed @{killed} (@{weapon}) with a hit to their @{bodypart} at @{distance}m"
	self.Config.logDeathMessage 		=	"@{killer} killed @{killed} (@{weapon}) with a hit to their @{bodypart} at @{distance}m"
	self.Config.adminDeathMessage 		=	"@{killer} killed @{killed} (@{weapon}) with a hit to their @{bodypart} at @{distance}m"
	self.Config.deathByEntityMessage    =   "@{killed} has died by a @{killer}"
	self.Config.wildlifeDeathMessage    =   "@{killer} killed a @{killed} (@{weapon})"


end

function PLUGIN:notifyDeath(tagInformation,useSwitch,switch)
	local message = "" 
	if self.Config.logToAdmin then
		if useSwitch then
			message = self:BuildDeathMessage(self:GetMessageConfig(switch),tagInformation)
		else
			message = self:BuildDeathMessage(self.Config.adminDeathMessage,tagInformation)
		end

		for _, netuser in pairs( rust.GetAllNetUsers() ) do
			if netuser:CanAdmin() then 
				if self.Config.logToAdminChat then
					rust.SendChatToUser( netuser, self.Config.chatName, message)
				end
				if self.Config.logToAdminConsole then
					rust.RunClientCommand( netuser, "echo " .. System.DateTime.Now:ToString("hh:mm tt") .. " " .. message ) 
				end
			end
		end
	end
	if self.Config.broadCastChat then
		if useSwitch then
			message = self:BuildDeathMessage(self:GetMessageConfig(switch),tagInformation)
		else
			message = self:BuildDeathMessage(self.Config.playerDeathMessage,tagInformation)
		end
		rust.BroadcastChat(self.Config.chatName, message)
	end
	if self.Config.logToConsole then 
		if useSwitch then
			message = self:BuildDeathMessage(self:GetMessageConfig(switch),tagInformation)
		else
			message = self:BuildDeathMessage(self.Config.logDeathMessage,tagInformation)
		end
		print(message)
	 end
	
	if self.Config.logToFile then
		if useSwitch then
			message = self:BuildDeathMessage(self:GetMessageConfig(switch),tagInformation)
		else
			message = self:BuildDeathMessage(self.Config.logDeathMessage,tagInformation)
		end
		if (startDateTime ~= System.DateTime.Now:ToString("MM/dd/yyyy")) then
			self:LoadLog()
		end
		table.insert( fileLog.text, System.DateTime.Now:ToString("hh:mm tt") .. " " .. message)
		fileLog.save()
		
	end
end

function PLUGIN:GetMessageConfig(switch)

	if switch == "AnimalDeath" then
		return self.Config.wildlifeDeathMessage
	end
	if switch == "PlayerDeath" then
		return self.Config.deathByEntityMessage 
	end
	if switch == "Suicide" then
		return self.Config.suicideMessage
	end

	return "Death Happened @{killed}"
end

function PLUGIN:BuildDeathMessage(str, tags)
	local customMessage = str
	for k, v in pairs(tags) do
		customMessage = string.gsub(customMessage, "@{".. k .. "-}", v)
	end
	return customMessage
end

function PLUGIN:DistanceFromPlayers(p1, p2)
    return math.sqrt(math.pow(p1.x - p2.x,2) + math.pow(p1.y - p2.y,2) + math.pow(p1.z - p2.z,2)) end
function PLUGIN:setConfigValue(netuser, cmd, args)
	if (type(cmd) == "table") then
		args = cmd
	end
	if (self:HasFlag(netuser,"Deathconfig")) then
		local targetConfig = args[1]
		for k, v in pairs(self.Config) do 
			if (k == targetConfig) then 
				if (tostring(self.Config[targetConfig]) == "true") then 
					self.Config[targetConfig] = false 
					rust.Notice( netuser, targetConfig .. " Set to: false") 
				else
					if (tostring(self.Config[targetConfig]) == "false") then 
						self.Config[targetConfig] = true 
						rust.Notice( netuser, targetConfig .. " Set to: true") 
					else
						table.remove(args, 1)
						
						local msg = table.concat( args, " ")
						print(string.len(msg))
						if string.len(msg) < 1 then
							rust.SendChatToUser( netuser, targetConfig, "Value: " .. self.Config[targetConfig]) 
							return 
						end
						self.Config[targetConfig] = args[2]
						rust.Notice( netuser, targetConfig .. " Set to: " .. msg) 
					end
				end
				--print("Saving Config")
				config.Save( "Death Handler" )
				self:LoadConfig()
				return
			end
		end
		rust.Notice( netuser, "No Config found!") 
	end
end
local _BodyParts = cs.gettype( "BodyParts, Facepunch.HitBox" )
local _GetNiceName = util.GetStaticMethod( _BodyParts, "GetNiceName" )
local _NetworkView = cs.gettype( "Facepunch.NetworkView, Facepunch.ID" )
local _Find = util.GetStaticMethod( _NetworkView, "Find" )
function PLUGIN:OnKilled(takedamage, damage)
	local tags = {}
	tags.killer = ""
	tags.killed = ""
	tags.weapon = ""
	tags.bodypart = ""
	tags.distance = ""
	if not (tostring(type(damage) ~= "userdata")) or not (tostring(type(takedamage) ~= "userdata")) then
		return
	end
	--TakeDamage , DamageEvent
	local weapon
	if(damage.extraData) then
		weapon = damage.extraData.dataBlock.name
	end
	if( weapon) then 
		tags.weapon = weapon
	else 
		tags.weapon = "Unknown"
	end
    if (takedamage:GetComponent( "HumanController" ) and self.Config.player) then
		if(damage.victim.client) then
			if(self.Config.deathByEntity) then
				if not damage.attacker.networkView then return end
				tags.killed = damage.victim.client.netUser.displayName
				idMain = damage.attacker.idMain
                if idMain then
                    idMain = idMain.idMain
                end
                killer = idMain:ToString()
				local idMainT = {}
			 	for k in string.gmatch(killer , "%a+") do
			       table.insert(idMainT , k)
			    end
			    
				if(damage.attacker.networkView.gameObject:GetComponent("BearAI")) then
					if idMainT[1] == "MutantBear" then
						tags.killer = "mutant bear"
					else
						tags.killer = "bear"
					end
					self:notifyDeath(tags, true, "PlayerDeath")
					return
				end
				if(damage.attacker.networkView.gameObject:GetComponent("WolfAI")) then
					if idMainT[1] == "MutantWolf" then
						tags.killer = "mutant wolf"
					else
						tags.killer = "wolf"
					end
					self:notifyDeath(tags, true, "PlayerDeath")
					return
				end
			end
		end          
        if(damage.victim.client and damage.attacker.client) then
			local isSamePlayer = (damage.victim.client == damage.attacker.client)
			tags.killed = damage.victim.client.netUser.displayName
			tags.killer = damage.attacker.client.netUser.displayName
			if not isSamePlayer then				
				local dist = self:DistanceFromPlayers(damage.attacker.client.netUser.playerClient.lastKnownPosition,damage.victim.client.netUser.playerClient.lastKnownPosition)
				if self.Config.notifyKiller then
					rust.Notice(damage.attacker.client.netUser, "You killed " .. tags.killed)
				end
				tags.bodypart = "body"
				if (damage.bodyPart ~= nil) then
					if(damage.bodyPart:GetType().Name == "BodyPart" and _GetNiceName(damage.bodyPart) ~= nil) then
						tags.bodypart = _GetNiceName(damage.bodyPart)
					end
				end
				tags.distance = tostring(math.floor(dist))			
				self:notifyDeath(tags,false)
				return
			end
			if(isSamePlayer and self.Config.suicide) then
				self:notifyDeath(tags,true, "Suicide")
				return
			end
		end
		
        return
    end

    if (takedamage:GetComponent( "BearAI" ) and self.Config.bear) then
    	tags.killer = damage.attacker.client.netUser.displayName
    	tags.killed = "bear"
    	self:notifyDeath(tags, true, "AnimalDeath")
        return
    end
    
    if (takedamage:GetComponent( "WolfAI" ) and self.Config.wolf) then
       tags.killer = damage.attacker.client.netUser.displayName
       tags.killed = "wolf"
       self:notifyDeath(tags, true, "AnimalDeath")
        return
    end
	
	if (takedamage:GetComponent( "StagAI" ) and self.Config.stag) then
	   tags.killer = damage.attacker.client.netUser.displayName
       tags.killed = "deer"
       self:notifyDeath(tags, true, "AnimalDeath")
        return
    end
	
	if (takedamage:GetComponent( "ChickenAI" ) and self.Config.chicken) then
		tags.killer = damage.attacker.client.netUser.displayName
       	tags.killed = "chicken"
		self:notifyDeath(tags, true, "AnimalDeath")
        return
    end
	
	if (takedamage:GetComponent( "RabbitAI" ) and self.Config.rabbit) then
        tags.killer = damage.attacker.client.netUser.displayName
       	tags.killed = "rabbit"
        self:notifyDeath(tags, true, "AnimalDeath")
        return
    end
	
	if (takedamage:GetComponent( "BoarAI" ) and self.Config.boar) then
        tags.killer = damage.attacker.client.netUser.displayName
       	tags.killed = "boar"
        self:notifyDeath(tags, true, "AnimalDeath")
        return
    end
end
function PLUGIN:SendHelpText( netuser )
	if (self:HasFlag(netuser,"Deathconfig")) then
		rust.SendChatToUser( netuser, self.Config.chatName, "Use /death configName <value> to change config in-game" )
	end
end
function split( sep, str )
	local t = {}
	for word in string.gmatch( str, "[^"..sep.."]+" ) do 
		table.insert( t, word )
	end	
	return t
end

function PLUGIN:UpdateCheck()
	print("Checking for an update for: " .. self.Title .. ": Version " .. self.Version)
	local r = webrequest.Send("http://update.busheezy.me/"..self.RID, function(code, response)
		if (code == 200 and response ~= "fail")  then
			if (response ~= self.Version) then
				print(self.Title .. ": Please update to version " .. response .. " at http://forum.rustoxide.com/resources/" .. self.RID)
			else
				print(self.Title .. ": Update check passed")
			end
		end
	end )
	if (not r) then 
		print(self.Title .. ": Update check failed")
	end
end