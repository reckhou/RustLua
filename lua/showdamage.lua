PLUGIN.Title = "ShowDamage"
PLUGIN.Description = "Shows damage as given and received by player."
PLUGIN.Author = "iEx + Hatemail"
PLUGIN.Version = "1.2.6"

function PLUGIN:Init()
	self:AddChatCommand("showdamage", self.ShowDamageCmd)
	self:AddChatCommand("sd", self.ShowDamageCmd)
	self:AddChatCommand("showdamageanimal", self.ShowDamageAnimalCmd)
	self:AddChatCommand("sda", self.ShowDamageAnimalCmd)
	self:AddChatCommand("showmydamage", self.ShowMyDamageCmd)
	self:AddChatCommand("smd", self.ShowMyDamageCmd)
	findoxmin = plugins.Find("oxmin")
    if findoxmin or oxmin then
        self.FLAG_SHOWDMG = oxmin.AddFlag( "showdamage" )
        self.FLAG_SHOWMYDMG = oxmin.AddFlag( "showmydamage" )
        self.FLAG_SHOWDMGA = oxmin.AddFlag( "showdamageanimal" )
    end
	local b, res = config.Read("showdamage")
	self.Config = res or {}
	if (not b) then
    self:LoadDefaultConfig()
    if (res) then
      config.Save("showdamage")
    end
	end
end
function PLUGIN:LoadDefaultConfig()
	self.Config.ViewNickNames = self.Config.ViewNickNames or true
	self.Config.ViewAnimalTypes = self.Config.ViewAnimalTypes or true
	self.Config.ShowDamageAdminOnly = self.Config.ShowDamageAdminOnly or false
	self.Config.ShowMyDamageAdminOnly = self.Config.ShowMyDamageAdminOnly or true
	self.Config.ShowDamageAnimalsAdminOnly = self.Config.ShowDamageAnimalsAdminOnly or false
end

function PLUGIN:CheckPermSD(netuser)
	if(self.Config.ShowDamageAdminOnly) then
	if findoxmin or oxmin then
		if  findoxmin:HasFlag( netuser, self.FLAG_SHOWDMG, false ) then
			return true
		end
    end

	if netuser:CanAdmin() then
		return true
	end	

	return false
	end
	return true
end

function PLUGIN:CheckPermSMD(netuser)
	if(self.Config.ShowMyDamageAdminOnly) then
	if findoxmin or oxmin then
		if  findoxmin:HasFlag( netuser, self.FLAG_SHOWMYDMG, false ) then
			return true
		end
    end

	if netuser:CanAdmin() then
		return true
	end
	return false
	end
	return true
end

function PLUGIN:CheckPermSDA(netuser)
	if(self.Config.ShowDamageAnimalsAdminOnly) then
	if findoxmin or oxmin then
		if  findoxmin:HasFlag( netuser, self.FLAG_SHOWDMGA, false ) then
			return true
		end
    end
	
	if netuser:CanAdmin() then
		return true
	end
	return false
	end
	return true
end

typesystem.LoadEnum( Rust.DamageTypeFlags, "DamageType" )

NotShowDmg = {}

ShowMyDmg = {}

ShowDmgAnimal = {}

function PLUGIN:ShowDamageAnimalCmd(netuser, args)
	if(self:CheckPermSDA(netuser)) then
	local steamid = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))
	if (not ShowDmgAnimal[steamid]) then
	rust.Notice(netuser, "ShowDamageAnimal is On!")
	ShowDmgAnimal[steamid] = true
	return
	else
	ShowDmgAnimal[steamid] = false
	rust.Notice(netuser, "ShowDamageAnimal is Off!")
	return
	end
	else
	rust.Notice(netuser, "You need 'showdamageanimals' flag or admin rights to use it!")
	return
	end
end
function PLUGIN:ShowDamageCmd(netuser, args)
	if(self:CheckPermSD(netuser)) then
	local steamid = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))
	if NotShowDmg[steamid] then
	rust.Notice(netuser, "ShowDamage is On!")
	NotShowDmg[steamid] = false
	return
	else
	NotShowDmg[steamid] = true
	rust.Notice(netuser, "ShowDamage is Off!")
	return
	end
	else
	rust.Notice(netuser, "You need 'showdamage' flag or admin rights to use it!")
	return
	end
end

function PLUGIN:ShowMyDamageCmd(netuser, args)
	if(self:CheckPermSMD(netuser)) then
	local steamid = rust.CommunityIDToSteamID(  tonumber(rust.GetUserID(netuser )))
	if (ShowMyDmg[steamid]) then
	rust.Notice(netuser, "ShowMyDamage is Off!")
	ShowMyDmg[steamid] = false
	return
	else
	ShowMyDmg[steamid] = true
	rust.Notice(netuser, "ShowMyDamage is On!")
	return
	end
	else
	rust.Notice(netuser, "You need 'showmydamage' flag or admin rights to use it!")
	return
	end
end

function PLUGIN:OnHurt(takedamage, damage)
	if(damage.attacker.client) then
	if (takedamage:GetComponent("HumanController")) then
		if(damage.victim.client) then
			if (damage.attacker.client.netUser and damage.victim.client.netUser) then
				if (damage.damageTypes == DamageType.damage_bullet or damage.damageTypes == DamageType.damage_melee) then
					steamidDmg = rust.CommunityIDToSteamID( tonumber(rust.GetUserID(damage.attacker.client.netUser )))
					if(not self:CheckPermSD(damage.attacker.client.netUser)) then -- showdamage is enabled by default,checking player does it turned on or not.
					if(not NotShowDmg[steamidDmg]) then
					NotShowDmg[steamidDmg] = true
					end
					end
					if (not NotShowDmg[steamidDmg]) then
						if (self.Config.ViewNickNames) then
							rust.Notice(damage.attacker.client.netUser, "Player: " .. damage.victim.client.netUser.displayName .. " ,Damage: " .. math.floor(damage.amount) .. " !")
							else
							rust.Notice(damage.attacker.client.netUser, "-" .. math.floor(damage.amount) )
					end
					end
					steamidMyDmg = rust.CommunityIDToSteamID( tonumber(rust.GetUserID(damage.victim.client.netUser )))
					if (ShowMyDmg[steamidMyDmg]) then
					rust.RunClientCommand(damage.victim.client.netUser, "notice.inventory " .. "\"" .. damage.attacker.client.netUser.displayName .. "\"")
					end
			end
		end
	end
end
	if(damage.attacker.client) then
    steamidDmg = rust.CommunityIDToSteamID( tonumber(rust.GetUserID(damage.attacker.client.netUser ))) -- thanks a lot to Hatemail,if it will work c;
    else
		return
    end
	if (ShowDmgAnimal[steamidDmg]) then
		if (damage.damageTypes == DamageType.damage_bullet or damage.damageTypes == DamageType.damage_melee) then
		if (self.Config.ViewAnimalTypes) then
		if (takedamage:GetComponent( "BearAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Bear , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "WolfAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Wolf , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "StagAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Stag , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "ChickenAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Chicken , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "RabbitAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Rabbit , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "BoarAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Boar , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "ZombieController" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Zombie , Damage: " .. math.floor(damage.amount) .. " !")
		end
		else
		if (takedamage:GetComponent( "BearAI" ) or takedamage:GetComponent( "WolfAI" ) or takedamage:GetComponent( "StagAI" ) or takedamage:GetComponent( "ChickenAI" ) or takedamage:GetComponent( "RabbitAI" ) or takedamage:GetComponent( "BoarAI" ) or takedamage:GetComponent( "ZombieController" )) then
		rust.Notice(damage.attacker.client.netUser, "-" .. math.floor(damage.amount))
		end
		end
		end
	end
	end
end
function PLUGIN:OnKilled( takedamage, damage )
	if (takedamage:GetComponent("HumanController")) then
		if (damage.attacker.client) then
		if (damage.victim.client) then
			if (damage.attacker.client.netUser and damage.victim.client.netUser) then
				if (damage.damageTypes == DamageType.damage_bullet or damage.damageTypes == DamageType.damage_melee) then
					steamidDmg = rust.CommunityIDToSteamID( tonumber(rust.GetUserID(damage.attacker.client.netUser )))
					if(not self:CheckPermSD(damage.attacker.client.netUser)) then
					if(not NotShowDmg[steamidDmg]) then
					NotShowDmg[steamidDmg] = true
					end
					end
					if (not NotShowDmg[steamidDmg]) then
						if self.Config.ViewNickNames then
							rust.Notice(damage.attacker.client.netUser, "[Killed] Player: " .. damage.victim.client.netUser.displayName .. " ,Damage: " .. math.floor(damage.amount) .. " !")
							else
							rust.Notice(damage.attacker.client.netUser, "[Killed] -" .. math.floor(damage.amount) )
					end
					end
					steamidMyDmg = rust.CommunityIDToSteamID( tonumber(rust.GetUserID(damage.victim.client.netUser )))
					if (ShowMyDmg[steamidMyDmg]) then
					rust.RunClientCommand(damage.victim.client.netUser, "notice.inventory " .. "\"" .. damage.attacker.client.netUser.displayName .. "\"")
				end
			end
		end
	end
	if(damage.attacker.client) then
    steamidDmg = rust.CommunityIDToSteamID( tonumber(rust.GetUserID(damage.attacker.client.netUser )))
    else
        return
    end
	if (ShowDmgAnimal[steamidDmg]) then
		if (damage.damageTypes == DamageType.damage_bullet or damage.damageTypes == DamageType.damage_melee) then
		if (self.Config.ViewAnimalTypes) then
		if (takedamage:GetComponent( "BearAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Bear , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "WolfAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Wolf , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "StagAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Stag , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "ChickenAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Chicken , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "RabbitAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Rabbit , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "BoarAI" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Boar , Damage: " .. math.floor(damage.amount) .. " !")
		end
		if (takedamage:GetComponent( "ZombieController" )) then
		rust.Notice(damage.attacker.client.netUser, "Animal: Zombie , Damage: " .. math.floor(damage.amount) .. " !")
		end
        else
		if (takedamage:GetComponent( "BearAI" ) or takedamage:GetComponent( "WolfAI" ) or takedamage:GetComponent( "StagAI" ) or takedamage:GetComponent( "ChickenAI" ) or takedamage:GetComponent( "RabbitAI" ) or takedamage:GetComponent( "BoarAI" ) or takedamage:GetComponent( "ZombieController" )) then
		rust.Notice(damage.attacker.client.netUser, "-" .. math.floor(damage.amount))
		end
		end
		end
	end
	end
end
end
function PLUGIN:SendHelpText( netuser )
	rust.SendChatToUser( netuser, "Use /showdamage or /sd to turn on/off given damage." )
	rust.SendChatToUser( netuser, "Use /showmydamage or /smd to turn on/off taken damage." )
	rust.SendChatToUser( netuser, "Use /showdamageanimal or /sda to turn on/off given damage to animals." )
end