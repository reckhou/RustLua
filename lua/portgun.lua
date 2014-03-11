PLUGIN.Title = "Portgun"
PLUGIN.Description = "Teleport to any visible point"
PLUGIN.Version = "0.9.9"
PLUGIN.Author = "ZOR"

function PLUGIN:Init()
    self.agodMap = {}
    self.jumpheight = 3
    oxmin_Plugin = plugins.Find("oxmin")
    if oxmin_Plugin then  self.FLAG_PORTGUN = oxmin.AddFlag("portgun") end

    flags_plugin = plugins.Find("flags")
        if flags_plugin then
            flags_plugin:AddFlagsChatCommand(self, "p", {"portgun"}, self.cmdPort)
        else     self:AddChatCommand("p", self.cmdPort)
        end

    print( self.Title .. " v" .. self.Version .. " loaded!" )
end

local Raycastp = util.FindOverloadedMethod( UnityEngine.Physics, "RaycastAll", bf.public_static, { UnityEngine.Ray } )
cs.registerstaticmethod( "tmp", Raycastp )
local RaycastAll = tmp
tmp = nil
function TraceEyesp( netuser )
    local hits = RaycastAll( rust.GetCharacter( netuser ).eyesRay )
    local tbl = cs.createtablefromarray( hits )
    if (#tbl == 0) then return end
    local closest = tbl[1]
    local closestdist = closest.distance
    for i=2, #tbl do
        if (tbl[i].distance < closestdist) then
            closest = tbl[i]
            closestdist = closest.distance
        end
    end
    return closest
end

function PLUGIN:cmdPort(netuser, cmd, args)
    local isAdmined = netuser:CanAdmin() or (not flags_plugin and oxmin_Plugin and oxmin_Plugin:HasFlag(netuser, self.FLAG_PORTGUN, false))
    if not isAdmined  then return end
    local offset = self.jumpheight if args[1] and tonumber(args[1]) then offset = tonumber(args[1]) end
    local uid = rust.GetUserID( netuser )
    self.agodMap[uid] =  timer.Once(6, function()  self.agodMap[uid] = nil end )

    local  trace = TraceEyesp(netuser)
    if not trace then return end
    local p = trace.point

    local coords = netuser.playerClient.lastKnownPosition
    coords.x ,coords.y ,coords.z = p.x,p.y+offset,p.z
    rust.ServerManagement():TeleportPlayer(netuser.playerClient.netPlayer, coords)
end

function PLUGIN:ModifyDamage(takedamage, damage)
    if (damage.attacker.client and damage.attacker.client.netUser) then --if actor is player
        local actorUser = damage.attacker.client.netUser
        if (takedamage:GetComponent("HumanController")) then --victim is player
            local victim = takedamage:GetComponent("HumanController")
            if (victim) then
                local netplayer = victim.networkViewOwner
                if (netplayer) then
                    local victimUser = rust.NetUserFromNetPlayer(netplayer)
                    if (victimUser) then
                        if victimUser:CanAdmin() and self.agodMap[rust.GetUserID( victimUser )] then
                            damage.amount = 0 damage.status = LifeStatus.IsAlive return damage
                        end
                    end
                end
            end
            return
        end
    end
end