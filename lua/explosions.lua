PLUGIN.Title = "Explosions"
PLUGIN.Description = "Manage damage from explosions"
PLUGIN.Version = "1.2.2"
PLUGIN.Author = "D4K1NG"

function PLUGIN:Init()
    local b, res = config.Read( "explosions" )
    self.Config = res or {}
    if (not b) then
        self.Config.ExplosionsActive = 1
        self.Config.ExplosionWoodWallsActive = 1
        self.Config.ExplosionMetalWallsActive = 1
        self.Config.ExplosionDamage = 100 -- explosion damage in percent, default: 100
        if ( res ) then 
        	config.Save( "explosions" )
        end
    end
	self:AddChatCommand("explosions", self.setExplosionState)
	self:AddChatCommand("explosiondamage", self.setExplosionDamage)
	self:AddChatCommand("explosionwoodwalls", self.setExplosionWoodWalls)
	self:AddChatCommand("explosionmetalwalls", self.setExplosionMetalWalls)
end

function PLUGIN:setExplosionWoodWalls(netuser, cmd, args)
	if (not(netuser:CanAdmin())) then
        rust.Notice(netuser, "Only admins can do this")
        return
    end
    if (not args[1]) then
    	if (self.Config.ExplosionWoodWallsActive == 1) then
    		rust.Notice(netuser, "Explosions at Wood Walls|Doorways|WindowWalls are active and they take damage. The damage is at: " .. self.Config.ExplosionDamage .. " percent.")
    	else
    		rust.Notice(netuser, "Explosions at Wood Walls|Doorways|WindowWalls are inactive and they take no damage!")
    	end
		return
	end
	if (args[1] ~= "off" and args[1] ~= "on") then
		rust.Notice(netuser, "Syntax: /explosionwoodwalls on|off")
		return
	end
	if (args[1] == "on") then
		self.Config.ExplosionWoodWallsActive = 1
		rust.Notice(netuser, "Explosions on Wood Walls|Doorways|WindowWalls are active now!")
		config.Save( "explosions" )
		return
	end
	if (args[1] == "off") then
		self.Config.ExplosionWoodWallsActive = 0
		rust.Notice(netuser, "Explosions on Wood Walls|Doorways|WindowWalls are inactive now!")
		config.Save( "explosions" )
		return
	end
end

function PLUGIN:setExplosionMetalWalls(netuser, cmd, args)
	if (not(netuser:CanAdmin())) then
        rust.Notice(netuser, "Only admins can do this")
        return
    end
    if (not args[1]) then
    	if (self.Config.ExplosionMetalWallsActive == 1) then
    		rust.Notice(netuser, "Explosions at Metal Walls|Doorways|WindowWalls are active and they take damage. The damage is at: " .. self.Config.ExplosionDamage .. " percent.")
    	else
    		rust.Notice(netuser, "Explosions at Metal Walls|Doorways|WindowWalls are inactive and they take no damage!")
    	end
		return
	end
	if (args[1] ~= "off" and args[1] ~= "on") then
		rust.Notice(netuser, "Syntax: /explosionmetalwalls on|off")
		return
	end
	if (args[1] == "on") then
		self.Config.ExplosionMetalWallsActive = 1
		rust.Notice(netuser, "Explosions on Metal Walls|Doorways|WindowWalls are active now!")
		config.Save( "explosions" )
		return
	end
	if (args[1] == "off") then
		self.Config.ExplosionMetalWallsActive = 0
		rust.Notice(netuser, "Explosions on Metal Walls|Doorways|WindowWalls are inactive now!")
		config.Save( "explosions" )
		return
	end
end

function PLUGIN:setExplosionDamage(netuser, cmd, args)
	if (not(netuser:CanAdmin())) then
        rust.Notice(netuser, "Only admins can do this")
        return
    end
    if (not args[1]) then
    	rust.Notice(netuser, "Syntax: /explosiondamage value")
    	return
    end
    local amount = tonumber(args[1])
    if (type(amount) ~= "number") then
    	rust.Notice(netuser, "Only numbers are allowed! Example: 10 or 22.50")
    	return
    end
    self.Config.ExplosionDamage = amount
    rust.Notice(netuser, "Explosion damage is now " .. self.Config.ExplosionDamage .. " percent.")
    config.Save( "explosions" )
    return
end

function PLUGIN:setExplosionState(netuser, cmd, args)
	if (not(netuser:CanAdmin())) then
        rust.Notice(netuser, "Only admins can do this")
        return
    end
    if (not args[1]) then
    	if (self.Config.ExplosionsActive == 1) then
    		rust.Notice(netuser, "Explosions are active and damage is at: " .. self.Config.ExplosionDamage .. " percent.")
    	else
    		rust.Notice(netuser, "Explosions are inactive")
    	end
		return
	end
	if (args[1] ~= "off" and args[1] ~= "on") then
		rust.Notice(netuser, "Syntax: /explosions on|off")
		return
	end
	if (args[1] == "on") then
		self.Config.ExplosionsActive = 1
		rust.Notice(netuser, "Explosions are active now!")
		config.Save( "explosions" )
		return
	end
	if (args[1] == "off") then
		self.Config.ExplosionsActive = 0
		rust.Notice(netuser, "Explosions are inactive now!")
		config.Save( "explosions" )
		return
	end
end
typesystem.LoadEnum( Rust.DamageTypeFlags, "DamageType" )
local StructureMaterialType = cs.gettype( "StructureMaster+StructureMaterialType, Assembly-CSharp" )
typesystem.LoadEnum( StructureMaterialType, "MaterialType" )
function PLUGIN:ModifyDamage(takedamage, damage)
	if (tostring(damage.damageTypes) == tostring(DamageType.damage_explosion)) then
		if (self.Config.ExplosionsActive == 0) then
			damage.amount = 0
			return damage
		else
			if (self.Config.ExplosionWoodWallsActive == 0) then
				if (takedamage:GetComponent("StructureComponent")) then
					local structure = takedamage:GetComponent("StructureComponent")
					if (structure:IsWallType()) then
						local type = structure:GetMaterialType()
						if( tostring(type) == tostring(MaterialType.Wood) ) then
							damage.amount = 0
							return damage
						end
					end 
				end
			end
			if (self.Config.ExplosionMetalWallsActive == 0) then
				if (takedamage:GetComponent("StructureComponent")) then
					local structure = takedamage:GetComponent("StructureComponent")
					if (structure:IsWallType()) then
						local type = structure:GetMaterialType()
						if( tostring(type) == tostring(MaterialType.Metal) ) then
							damage.amount = 0
							return damage
						end
					end 
				end
			end
			local old_amount = damage.amount
			local one_percent = old_amount / 100
			local new_amount = one_percent * self.Config.ExplosionDamage
			damage.amount = new_amount
			return damage 
		end
	end
end