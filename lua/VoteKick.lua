-- Define plugin variables
PLUGIN.Title = "VoteKick and VoteBan"
PLUGIN.Description = "Gives Players Power To Vote Kick and Vote Ban"
PLUGIN.AUTHOR = "The Big Wig"
PLUGIN.VERSION = 1.1


--Allow User To Turn off Votekick and Vote ban
function PLUGIN:Init()
self:LoadConfig()

	self:AddChatCommand("votekick", self.cmdStartKick)
	self:AddChatCommand("Votekick", self.cmdStartKick)
	self:AddChatCommand("yes", self.cmdVoteYes)
	self:AddChatCommand("Yes", self.cmdVoteYes)
	self:AddChatCommand("no", self.cmdVoteNo)
	self:AddChatCommand("No", self.cmdVoteNo)
     	
    
	
end

function PLUGIN:LoadConfig()
	local b, res = config.Read("votekick")
	self.Config = res or {}
	if (not b) then
		self:LoadDefaultConfig()
		if (res) then config.Save("votekick") end
	end
	--Resets Values So They Plugin Will Work After Server Restart During Vote
	self.Config.YesVotes = 0
	self.Config.NoVotes = 0
	self.Config.NumberOfVotesToKick = 5
	self.Config.TargetUser = "User"
	self.Config.VoteActive =false
	--self.Config.VotedUsers ={}
	self.votedUsers = {}
end


function PLUGIN:cmdStartKick(netuser, cmd, args)
	if (not args[1]) then
	rust.SendChatToUser(netuser, "Vote Kick System", "Syntax: /votekick name")
	return
	end
	if args[1]=="Help" then
			rust.SendChatToUser(netuser, "Vote Kick System", "Commands for Players")
			rust.SendChatToUser(netuser, "Vote Kick System", "/VoteKick \"Name\" - To Vote Kick a Player From The Server")
			rust.SendChatToUser(netuser, "Vote Kick System", "/Yes -Vote Yes For a Current Poll")
			rust.SendChatToUser(netuser, "Vote Kick System", "/No - Vote No For a Current Poll")
		return
	end
	--Checks to See if Vote is Already Active	
	if self.Config.VoteActive == true then
		rust.SendChatToUser(netuser, "Vote Kick System", "There is already a Vote in Progress")
		rust.SendChatToUser(netuser, "Vote Kick System", "Please Wait Until This Vote Finishes")
		return
	end
	--Checks to See if Target User For Vote Is a Valid Name	
	local b, targetuser = rust.FindNetUsersByName( args[1] )
				if (not b) then
					if (targetuser == 0) then
						rust.Notice( netuser, "No players found with that name!" )
					else
						rust.Notice( netuser, "Multiple players found with that name!" )
					end
					return
				end
	
	self.Config.TargetUser =targetuser
	
	--Starts The Vote Kick and Alerts Users
	self.Config.VoteActive = true
	rust.BroadcastChat("Vote Kick System", "A Vote Kick Has Been Started by " ..netuser.displayName .." to Kick " ..targetuser.displayName .." From The Server")
	rust.BroadcastChat("Vote Kick System", "The Vote Will End in ".. self.Config.VoteTime.. " Seconds")
	rust.BroadcastChat("Vote Kick System", "Use /Yes or /No to Vote!")



		local UpdateTimer = self.Config.VoteTime-self.Config.RemindTime
		rust.Notice( netuser, ""..UpdateTimer)
		timer.Once(UpdateTimer, function() self:cmdRemindPoll() end )
		timer.Once(self.Config.VoteTime , function() self:cmdEndPoll() end )
		--timer.Once(15, function() self:cmdRemindPoll() end )
		--timer.Once(20 , function() self:cmdEndPoll() end )
	
	
	
	
	

	--Change Timers To Work With JSON Vaules
	--Add a way to turn off the commands v(2.0)
	
	
	
	
 
	
	

	
end
function PLUGIN:cmdRemindPoll()
	rust.BroadcastChat("Vote Kick System", "The Vote Will End in ".. self.Config.RemindTime.. " Seconds")
	rust.BroadcastChat("Vote Kick System", "Use /Yes or /No to Vote!")
	rust.BroadcastChat("Vote Kick System", "Total Yes Votes:" ..self.Config.YesVotes)
	rust.BroadcastChat("Vote Kick System", "Total No Votes:" ..self.Config.NoVotes)
end
function PLUGIN:cmdEndPoll()


	--Ends Poll Counts Votes, Carries Out Action, and Report Back To The Players
	local currentYesVotes = self.Config.YesVotes
	local KickAmount = self.Config.NumberOfVotesToKick
	if currentYesVotes<KickAmount then
	rust.BroadcastChat("Vote Kick System", "The Minimum Number of Votes Needed To Kick " ..self.Config.TargetUser.displayName .." From Server Has Not Been Reached")
	rust.BroadcastChat("Vote Kick System", self.Config.TargetUser.displayName .." Stays in the Server!")
	end
	--Resets Varibles For Next Vote Kick Poll
	self.Config.YesVotes = 0
	self.Config.NoVotes = 0
	self.Config.TargetUser = "User"
	self.Config.VoteActive =false
	self.votedUsers = {}

end


function PLUGIN:cmdVoteYes(netuser, cmd, args)
	if(self.votedUsers[netuser.displayName]) then
		rust.SendChatToUser(netuser, "Vote Kick System", "You Have Already Voted!")
	return
	end

	if( not self.Config.VoteActive) then
	rust.SendChatToUser(netuser, "Vote Kick System", "There is No Active Vote Kick. Use /votekick name To Start One")
	return
	end

	
	
	
	

		
	
	local currentYesVotes = self.Config.YesVotes
	currentYesVotes =currentYesVotes+1
	self.Config.YesVotes=currentYesVotes
	rust.BroadcastChat("Vote Kick System",netuser.displayName.." Has Voted Yes")
	rust.BroadcastChat("Vote Kick System","Total Yes Votes: " ..currentYesVotes)
    
    
    
        self.votedUsers[netuser.displayName]="True"
        
     
        
	--Kicks User As Soon As The Number Of Votes is Reached or Return Amount Needed to Do So
	local KickAmount = self.Config.NumberOfVotesToKick
	if currentYesVotes>=KickAmount then
		rust.BroadcastChat("Vote Kick System", "The Minimum Number of Votes Needed To Kick " ..self.Config.TargetUser.displayName .." From Server Has Been Reached")
		--Kicks User
		self.Config.TargetUser:Kick( NetError.Facepunch_Kick_RCON, true )
		rust.BroadcastChat("Vote Kick System", self.Config.TargetUser.displayName .." Has Been Kick From The Server")
		self:cmdEndPoll()
	else
		local numberUntil =	self.Config.NumberOfVotesToKick-currentYesVotes
		rust.BroadcastChat("Vote Kick System",numberUntil.." More Votes Until "..self.Config.TargetUser.displayName.." is Kicked From The Server")
	end


end

function PLUGIN:cmdVoteNo(netuser, cmd, args)
if(self.votedUsers[netuser.displayName]) then
		rust.SendChatToUser(netuser, "Vote Kick System", "You Have Already Voted!")
	return
	end

	if( not self.Config.VoteActive) then
	rust.SendChatToUser(netuser, "Vote Kick System", "There is No Active Vote Kick. Use /votekick name To Start One")
	return
	end

	local currentNoVotes = self.Config.NoVotes
	currentNoVotes =currentNoVotes+1
	self.Config.NoVotes=currentNoVotes
	rust.BroadcastChat("Vote Kick System",netuser.displayName.." Has Voted No")
	rust.BroadcastChat("Vote Kick System", "Total No Votes:" ..currentNoVotes)
	 self.votedUsers[netuser.displayName]="True"
end
	
function PLUGIN:LoadDefaultConfig()
	self.Config.YesVotes = 0
	self.Config.NoVotes = 0
	self.Config.VoteTime =120
	self.Config.RemindTime =15
	--self.Config.NumberOfVotesToKick = 5
	self.Config.TargetUser = "User"
	self.Config.VoteActive =false
	--self.Config.VotedUsers ={}

end
	
	
	
	
	
	

	