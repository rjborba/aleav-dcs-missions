-- _SETTINGS:SetPlayerMenuOff()
_SETTINGS:SetImperial()
_SETTINGS:SetA2G_LL_DMS()

-- RESCUE HELICOPTER
rescuehelo=RESCUEHELO:New("BLUE CV STENNIS", "BLUE CV STENNIS RESCUE HELO")
rescuehelo:SetHomeBase(AIRBASE:FindByName("BLUE CV ANZIO"))
rescuehelo:SetModex(42)
rescuehelo:__Start(1)

-- RECOVERY TANKER
tankerStennis=RECOVERYTANKER:New("BLUE CV STENNIS", "BLUE S-3B")
tankerStennis:SetRadio(238)
tankerStennis:SetTACAN(38, "ARC")
tankerStennis:SetCallsign(CALLSIGN.Tanker.Arco)
tankerStennis:SetModex(380)
tankerStennis:SetAltitude(6000)
tankerStennis:SetSpeed(336) -- 336kt TAS = 300IAS @ 6000ft. 347.2kt TAS = 310kt IAS @ 6000ft
tankerStennis:Start()

local AirbossStennis=AIRBOSS:New("BLUE CV STENNIS")
AirbossStennis:AddRecoveryWindow("9:00", "19:00", 1, nil, true, 20)
AirbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")
AirbossStennis:SetTACAN(74, "X", "STN")
AirbossStennis:SetICLS(11, "STN")
AirbossStennis:SetMenuMarkZones(false)
AirbossStennis:SetMenuSmokeZones(false)
AirbossStennis:SetPatrolAdInfinitum(true)
AirbossStennis:Start()

-- CONSTANTS *************************************************************************************

RokiChallenge = {}
RokiChallenge.playerGroups = {}
RokiChallenge.radioMenusAdded = {}

RokiChallenge.mapMarkBlueArty = 0
RokiChallenge.mapMarkBlueCommandPost = 0
RokiChallenge.mapMarkRedBarracks = 0

RokiChallenge.mapMarkCivilian1 = 0
RokiChallenge.mapMarkCivilian2 = 0
RokiChallenge.mapMarkCivilian3 = 0

RokiChallenge.blueAlphaStrikeEnabled = true
RokiChallenge.blueAfacRunning = false
RokiChallenge.blueCapRunning = false
RokiChallenge.blueCasRunning = false
RokiChallenge.blueStrikeRunning = false

RokiChallenge.blueAfacSubscribedGroups = {}

RokiChallenge.redCapRunning = false
RokiChallenge.redCasRunning = false
RokiChallenge.redStrikeRunning = false
RokiChallenge.redCarpetBomberRunning = false


-- SAM DEFENSES **********************************************************************************

BLUE_VAZIANI_SAM = SPAWN
	:New( "BLUE VAZIANI SAM")
	:InitLimit(10,10)
	:SpawnScheduled(1800, 1)

BLUE_KUTAISI_SAM = SPAWN
	:New( "BLUE KUTAISI SAM")
	:InitLimit(10,10)
	:SpawnScheduled(1800, 1)

BLUE_VAZIANI_AAA = SPAWN
	:New( "BLUE VAZIANI AAA")
	:InitLimit(4,4)
	:SpawnScheduled(900, 1)

RED_MOZDOK_SAM = SPAWN
	:New( "RED MOZDOK SAM")
	:InitLimit(14,14)
	:SpawnScheduled(1800, 1)

RED_BESLAN_SAM = SPAWN
	:New( "RED SAM BESLAN")
	:InitLimit(8,8)
	:SpawnScheduled(1800, 1)

RED_BESLAN_AAA = SPAWN
	:New( "RED AAA BESLAN")
	:InitLimit(4,4)
	:SpawnScheduled(1800, 1)

RED_NALCHIK_SAM = SPAWN
	:New( "RED SAM NALCHIK")
	:InitLimit(8,8)
	:SpawnScheduled(1800, 1)

RED_SA18_ZONES = {
	ZONE:FindByName( "BLUE SA18 ZONE1" ),
	ZONE:FindByName( "BLUE SA18 ZONE2" ),
	ZONE:FindByName( "BLUE SA18 ZONE3" ),
	ZONE:FindByName( "BLUE SA18 ZONE4" ),
	ZONE:FindByName( "BLUE SA18 ZONE5" ),
	ZONE:FindByName( "BLUE SA18 ZONE6" )
}

RED_SA18 = SPAWN
	:New( "RED SA18")
	:InitRandomizeZones(RED_SA18_ZONES)
	:InitLimit(4,6)
	:SpawnScheduled(900,0)

-- BLUE ARTY *************************************************************************************

BLUE_ARTY_SPAWN_ZONES = {
	ZONE:FindByName( "BLUE ARTY SPAWN1" ),
	ZONE:FindByName( "BLUE ARTY SPAWN2" ),
	ZONE:FindByName( "BLUE ARTY SPAWN3" ),
	ZONE:FindByName( "BLUE ARTY SPAWN4" ),
	ZONE:FindByName( "BLUE ARTY SPAWN5" )
}

BLUE_ARTY_GROUP = SPAWN
	:New( "BLUE ARTY" )
	:InitLimit(10,0)
	:InitRandomizeZones( BLUE_ARTY_SPAWN_ZONES )
	:OnSpawnGroup(
		function(MooseGroup)
			trigger.action.outText("BLUE artillery attacking, map marked", 10 , false)
			trigger.action.outSound("walkietalkie.ogg" )

			local MooseGroupCoordinate = MooseGroup:GetCoordinate()
		  	local markId = MooseGroupCoordinate:MarkToAll("BLUE Artillery Unit\nBLUE: Protect\nRED: Attack", true, nil)
		  	RokiChallenge.mapMarkBlueArty = markId

		  	MooseGroup:HandleEvent(EVENTS.Dead)	  

			function MooseGroup:OnEventDead(EventData)
			 	if MooseGroup:GetSize() == 1 then
			 		trigger.action.removeMark( RokiChallenge.mapMarkBlueArty )
			 	end
			end
		end)
	:Spawn()

BLUE_ARTY_SCHEDULER = SCHEDULER:New(nil,
	function()
		if BLUE_ARTY_GROUP ~= nil and BLUE_ARTY_GROUP:IsAlive() then
			-- get a random target zone of 7 zones defined in ME
			local random = math.random(7)
			local blueArtyTarget = ZONE:FindByName( "BLUE ARTY TARGET" .. random )
			local blueArtyTargetCoordinate = blueArtyTarget:GetCoordinate()
			local blueArty = ARTY:New(BLUE_ARTY_GROUP)
			blueArty:_FireAtCoord(blueArtyTargetCoordinate, 300, 50, ARTY.WeaponType.Auto)
			env.info("BlUE ARTY initiating attack")
		else
			BLUE_ARTY_GROUP:Spawn()
		end
	end,
	{}, 120, 600, 0.3)

env.info("BLUE ARTILLERY FUNCTIONS loaded ...")
trigger.action.outText("BLUE ARTILLERY FUNCTIONS loaded ...", 10)

-- RED COLUMNS *******************************************************************************************

RED_COLUMN_TEMPLATES = {
	"RED COLUMN TEMPLATE1",
	"RED COLUMN TEMPLATE2",
	"RED COLUMN TEMPLATE3",
	"RED COLUMN TEMPLATE4",
	"RED COLUMN TEMPLATE5"
}

RED_COLUMN_JAVA_W = SPAWN
	:New( "RED JAVA COLUMN W" )
	:InitRandomizeTemplate(RED_COLUMN_TEMPLATES)
	:InitLimit(12,12)
	:InitRandomizeRoute(4, 0, 500)
	:Spawn()

RED_COLUMN_JAVA_E = SPAWN
	:New( "RED JAVA COLUMN E" )
	:InitRandomizeTemplate(RED_COLUMN_TEMPLATES)
	:InitLimit(12,12)
	:InitRandomizeRoute(4, 0, 500)
	:Spawn()

RED_SATIHARI_COLUMN = SPAWN
	:New( "RED SATIHARI COLUMN" )
	:InitRandomizeTemplate(RED_COLUMN_TEMPLATES)
	:InitLimit(12,12)
	:InitRandomizeRoute(1, 0, 500)
	:Spawn()

RED_BEKMARI_COLUMN = SPAWN
	:New( "RED BEKMARI COLUMN" )
	:InitRandomizeTemplate(RED_COLUMN_TEMPLATES)
	:InitLimit(12,12)
	:InitRandomizeRoute(2, 0, 500)
	:Spawn()

RED_COLUMNS_SCHEDULER = SCHEDULER:New(nil,
  function()

  	if RED_COLUMN_JAVA_W:IsAlive() ~= true then
	    RED_COLUMN_JAVA_W = SPAWN
			:New( "RED JAVA COLUMN W" )
			:InitRandomizeTemplate(RED_COLUMN_TEMPLATES)
			:InitLimit(12,24)
			:InitRandomizeRoute(4, 0, 500)
			:Spawn()
	end
	if RED_COLUMN_JAVA_E:IsAlive() ~= true then
		RED_COLUMN_JAVA_E = SPAWN
			:New( "RED JAVA COLUMN E" )
			:InitRandomizeTemplate(RED_COLUMN_TEMPLATES)
			:InitLimit(12,24)
			:InitRandomizeRoute(4, 0, 500)
			:Spawn()
	end
	if RED_SATIHARI_COLUMN:IsAlive() ~= true then
		RED_SATIHARI_COLUMN = SPAWN
			:New( "RED SATIHARI COLUMN" )
			:InitRandomizeTemplate(RED_COLUMN_TEMPLATES)
			:InitLimit(12,20)
			:InitRandomizeRoute(2, 0, 500)
			:Spawn()
	end
	if RED_BEKMARI_COLUMN:IsAlive() ~= true then
		RED_BEKMARI_COLUMN = SPAWN
			:New( "RED BEKMARI COLUMN" )
			:InitRandomizeTemplate(RED_COLUMN_TEMPLATES)
			:InitLimit(12,20)
			:InitRandomizeRoute(3, 0, 500)
			:Spawn()
	end

  end, {}, 0, 600, 0 )

env.info("RED COLUMNS FUNCTIONS loaded ...")
trigger.action.outText("RED COLUMNS FUNCTIONS loaded ...", 10)

-- FLEEING CIVILIANS *************************************************************************************

BLUE_CIVILIANS_SCHEDULER = SCHEDULER:New(nil,
  function()
  	RokiChallenge.civiliansAttacked = false
    BLUE_CIV1 = SPAWN
		:New( "BLUE CIVILIANS1" )
		:InitLimit(1,0)
		:OnSpawnGroup(
			function(mooseGroup)
				trigger.action.removeMark( RokiChallenge.mapMarkCivilian1 )
				mooseGroup:HandleEvent(EVENTS.Dead)	  
				function mooseGroup:OnEventDead(EventData)
			 		local mooseGroupCoordinate = mooseGroup:GetCoordinate()
			 		local markId = mooseGroupCoordinate:MarkToCoalition("Civilians attacked", coalition.side.BLUE, true, nil)
			 		RokiChallenge.mapMarkCivilian1 = markId

			 		if BLUE_OBSERVER:IsAlive() then
			 			local mooseGroupVec2 = mooseGroup:GetVec2()
			 			BLUE_OBSERVER:TaskOrbitCircleAtVec2(mooseGroupVec2, 2000, 500)
			 			trigger.action.outTextForCoalition(coalition.side.BLUE, "Civilians attacked, AFAC enroute to area", 10 , false)
			 			trigger.action.outSoundForCoalition(coalition.side.BLUE, "walkietalkie.ogg")
			 		end
				end
			end)
		:Spawn()

	BLUE_CIV2 = SPAWN
		:New( "BLUE CIVILIANS2" )
		:InitLimit(1,0)
		:OnSpawnGroup(
			function(mooseGroup)
				trigger.action.removeMark( RokiChallenge.mapMarkCivilian2 )
				mooseGroup:HandleEvent(EVENTS.Dead)	  
				function mooseGroup:OnEventDead(EventData)
			 		local mooseGroupCoordinate = mooseGroup:GetCoordinate()
			 		local markId = mooseGroupCoordinate:MarkToCoalition("Civilians attacked", coalition.side.BLUE, true, nil)
			 		RokiChallenge.mapMarkCivilian2 = markId
			 		trigger.action.outTextForCoalition(coalition.side.BLUE, "Civilians attacked, see map", 10 , false)
			 		trigger.action.outSoundForCoalition(coalition.side.BLUE, "walkietalkie.ogg")
				end
			end)
		:Spawn()

	BLUE_CIV3 = SPAWN
		:New( "BLUE CIVILIANS3" )
		:InitLimit(1,0)
		:OnSpawnGroup(
			function(mooseGroup)
				trigger.action.removeMark( RokiChallenge.mapMarkCivilian3 )
				mooseGroup:HandleEvent(EVENTS.Dead)	  
				function mooseGroup:OnEventDead(EventData)
			 		local mooseGroupCoordinate = mooseGroup:GetCoordinate()
			 		local markId = mooseGroupCoordinate:MarkToCoalition("Civilians attacked", coalition.side.BLUE, true, nil)
			 		RokiChallenge.mapMarkCivilian3 = markId
			 		trigger.action.outTextForCoalition(coalition.side.BLUE, "Civilians attacked, see map", 10 , false)
			 		trigger.action.outSoundForCoalition(coalition.side.BLUE, "walkietalkie.ogg")
				end
			end)
		:Spawn()
	end, {}, 0, 1200, 0 )

env.info("CIVILIANS FUNCTIONS loaded ...")
trigger.action.outText("CIVILIANS FUNCTIONS loaded ...", 10)

-- FLIGHT GROUPS ***************************************************************************************
RED_CAP_GROUPS = {"RED CAP MIG-21", "RED CAP MIG-23", "RED CAP MIG-29", "RED CAP SU-27"}
BLUE_CAP_GROUPS = {"BLUE CAP F-5", "BLUE CAP F-4", "BLUE CAP MIG-29", "BLUE CAP F-15"}

-- SCHEDULED CAP *****************************************************************************************************
function RokiChallenge.redCap()
	if RED_AI_CAP == nil or (RED_AI_CAP:AllOnGround() or (RED_AI_CAP:IsAlive() ~= true)) then	
		RED_AI_CAP = SPAWN
			:New( "RED CAP" )
			:InitLimit(2,24)
			:InitRandomizeTemplate(RED_CAP_GROUPS)
			:OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.OnEngineShutDown)
					function capGroup:OnEventOnEngineShutDown(EventData)
					    capGroup:Destroy()
					 end
				end
				)
			:Spawn()

		-- this is the zone where the AI patrol will loiter
	    local RED_ALERT_PATROL_ZONE = ZONE:New( "RED CAP LOITER ZONE" )
	    -- here we define the zone where any hostile unit will be engaged
	    local RED_AI_CAP_ENGAGE_ZONE = ZONE_POLYGON:NewFromGroupName( "RED NO FLY ZONE" )
	    -- here we define parameters for the AI like floor altitude, top altitude, min speed and max speed
	    local RED_AI_CAP_ZONE = AI_CAP_ZONE:New( RED_ALERT_PATROL_ZONE, 5000, 7000, 600, 900 )
	    RED_AI_CAP_ZONE:SetControllable( RED_AI_CAP )
	    RED_AI_CAP_ZONE:SetEngageZone( RED_AI_CAP_ENGAGE_ZONE ) -- Set the Engage Zone. The AI will only engage when the bogeys are within the CapEngageZone.
	    RED_AI_CAP_ZONE:__Start( 1 ) -- They should statup, and start patrolling in the PatrolZone.
	end
end

function RokiChallenge.blueCap()
	if BLUE_AI_CAP == nil or (BLUE_AI_CAP:AllOnGround() or (BLUE_AI_CAP:IsAlive() ~= true)) then
		BLUE_AI_CAP = SPAWN
			:New( "BLUE CAP" )
			:InitLimit(2,10)
			:InitRandomizeTemplate(BLUE_CAP_GROUPS)
			:OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.OnEngineShutDown)
					function capGroup:OnEventOnEngineShutDown(EventData)
					    capGroup:Destroy()
					 end
				end
				)
			:Spawn()
		-- this is the zone where the AI patrol will loiter
	    local BLUE_ALERT_PATROL_ZONE = ZONE:New( "BLUE LOITER ZONE" )
	    -- here we define the zone where any hostile unit will be engaged
	    local BLUE_AI_CAP_ENGAGE_ZONE = ZONE_POLYGON:NewFromGroupName( "BLUE NO FLY ZONE")
	    -- here we define parameters for the AI like floor altitude, top altitude, min speed and max speed
	    local BLUE_AI_CAP_ZONE = AI_CAP_ZONE:New( BLUE_ALERT_PATROL_ZONE, 6000, 10000, 600, 850 )
	    BLUE_AI_CAP_ZONE:SetControllable( BLUE_AI_CAP )
	    BLUE_AI_CAP_ZONE:SetEngageZone( BLUE_AI_CAP_ENGAGE_ZONE ) -- Set the Engage Zone. The AI will only engage when the bogeys are within the CapEngageZone.
	    BLUE_AI_CAP_ZONE:__Start( 1 ) -- They should statup, and start patrolling in the PatrolZone.
	end
end

RED_CAP_SCHEDULER = SCHEDULER:New(nil,
	function()
		RokiChallenge.redCap()
	end,
	{}, 5, 900, 0.5)

BLUE_CAP_SCHEDULER = SCHEDULER:New(nil,
	function()
		RokiChallenge.blueCap()
	end,
	{}, 5, 900, 0.5)

RED_CAP_SCHEDULER:Start()
BLUE_CAP_SCHEDULER:Start()

env.info("AI CAP FUNCTIONS loaded ...")
trigger.action.outText("AI CAP FUNCTIONS loaded ...", 10)

-- ALPHA STRIKE FLIGHTS ***************************************************************************************************************

-- RED CAP
function RokiChallenge.spawnRedCap()
	if RokiChallenge.redCapRunning == false then
	-- GROUP for the AI (in the mission editor)
	RED_ALERT_PATROL = SPAWN
		:New( "RED AIR COVER" )
		:InitRandomizeTemplate(RED_CAP_GROUPS)
		:OnSpawnGroup(
		function (MooseGroup)
			MooseGroup:HandleEvent(EVENTS.Dead)
			MooseGroup:HandleEvent(EVENTS.Land)

			function MooseGroup:OnEventDead(EventData)
				RokiChallenge.redCapRunning = false
			end

			function MooseGroup:OnEventLand(EventData)
				trigger.action.outTextForCoalition(coalition.side.RED, "Air cover returned to base", 10 , false)
				trigger.action.outSoundForCoalition(coalition.side.RED, "walkietalkie2.ogg")
				RokiChallenge.redCapRunning = false
				MooseGroup:Destroy()
			end
		end)
		:Spawn()

	RokiChallenge.redCapRunning = true
    -- this is the zone where the AI patrol will loiter
    local RED_AIR_COVER_PATROL_ZONE = ZONE:New( "CAP ENGAGEMENT ZONE" ) -- same zone for BLUE and RED
    -- here we define parameters for the AI like floor altitude, top altitude, min speed and max speed
    RED_AI_TARCAP_ZONE = AI_CAP_ZONE:New( RED_AIR_COVER_PATROL_ZONE, 4000, 8000, 650, 850 )
    RED_AI_TARCAP_ZONE:SetControllable( RED_ALERT_PATROL )
    RED_AI_TARCAP_ZONE:SetEngageRange( 40000 ) -- set engage range
    RED_AI_TARCAP_ZONE:__Start( 1 ) -- They should statup, and start patrolling in the PatrolZone.
  	else
	    if RED_ALERT_PATROL:IsAlive() then
	    	-- do nothing
	    else
	      RokiChallenge.redCapRunning = false
	      RokiChallenge.spawnRedCap()
    	end
  	end
end

-- BLUE TARCAP
function RokiChallenge.spawnBlueCap()
  	if RokiChallenge.blueCapRunning == false then
    	-- GROUP for the AI (in the mission editor)
	    BLUE_TARCAP = SPAWN
			:New( "BLUE TARCAP" )
			:InitRandomizeTemplate(BLUE_CAP_GROUPS)
			:OnSpawnGroup(
			function (MooseGroup)
				MooseGroup:HandleEvent(EVENTS.Dead)
				MooseGroup:HandleEvent(EVENTS.Land)

				function MooseGroup:OnEventDead(EventData)
					RokiChallenge.blueCapRunning = false
				end

				function MooseGroup:OnEventLand(EventData)
					trigger.action.outTextForCoalition(coalition.side.BLUE, "TARCAP is at home plate", 10 , false)
					trigger.action.outSoundForCoalition(coalition.side.BLUE, "walkietalkie2.ogg")
					RokiChallenge.blueCapRunning = false
					MooseGroup:Destroy()
				end
			end
			)
			:Spawn()

	    RokiChallenge.blueCapRunning = true
	    -- this is the zone where the AI patrol will loiter
		local BLUE_TARCAP_PATROL_ZONE = ZONE:New( "CAP ENGAGEMENT ZONE" )
		-- here we define parameters for the AI like floor altitude, top altitude, min speed and max speed
		BLUE_AI_TARCAP_ZONE = AI_CAP_ZONE:New( BLUE_TARCAP_PATROL_ZONE, 4000, 8000, 650, 850 )
		BLUE_AI_TARCAP_ZONE:SetControllable( BLUE_TARCAP )
		BLUE_AI_TARCAP_ZONE:SetEngageRange( 30000 ) -- set engage range
		BLUE_AI_TARCAP_ZONE:__Start( 1 ) -- They should statup, and start patrolling in the PatrolZone.
  	else
	    if BLUE_TARCAP:IsAlive() then
	      --do nothing
	    else
	      RokiChallenge.blueCapRunning = false
	      RokiChallenge.spawnBlueCap()
    	end
  	end
end

-- CAS FLIGHTS
RED_CAS_GROUPS = {"RED CAS SU-17", "RED CAS MIG-27"}
BLUE_CAS_GROUPS = {"BLUE CAS A-10", "BLUE CAS L-39"}

-- RED CAS
function RokiChallenge.spawnRedCas()
  if RokiChallenge.redCasRunning == false then
    -- GROUP for the AI (in the mission editor)
    RED_CAS_GROUP = SPAWN
		:New( "RED CAS" )
		:InitRandomizeTemplate(RED_CAS_GROUPS)
		:InitLimit(2,4)
		:OnSpawnGroup(
			function (casGroup)

				if BLUE_ARTY_GROUP:IsAlive() then
					local RED_CAS_TASK = casGroup:TaskAttackGroup(BLUE_ARTY_GROUP, nil, AI.Task.WeaponExpend.ALL, 4, nil, 5000, nil, true)
        			casGroup:PushTask(RED_CAS_TASK, 60)
        		else
        			RokiChallenge.redCasRtb()
        		end

				casGroup:HandleEvent(EVENTS.Land)
				function casGroup:OnEventLand(EventData)
				    casGroup:Destroy()
				 end
			end
			)
		:Spawn()

    RokiChallenge.redCasRunning = true
  else
    if (RED_CAS_GROUP:IsAlive()) then
    	--do nothing
    else
      RokiChallenge.redCasRunning = false
      RokiChallenge.spawnRedCas()
    end
  end
end

function RokiChallenge.redCasRtb()
	if RokiChallenge.redCasRunning then
	    RED_CAS_GROUP:RouteRTB(AIRBASE.Caucasus.Vaziani, 800)
	else
	  	RokiChallenge.redCasRunning = false
	end
end

-- BLUE CAS
function RokiChallenge.spawnBlueCas()
	if RokiChallenge.blueCasRunning == false then
		BLUE_CAS_GROUP = SPAWN
			:New( "BLUE CAS" )
			:InitRandomizeTemplate(BLUE_CAS_GROUPS)
			:InitLimit(2,4)
			:OnSpawnGroup(
				function (casGroup)

					if RED_COLUMN_JAVA_E:IsAlive() then
						local BLUE_CAS_TASK = casGroup:TaskAttackGroup(RED_COLUMN_JAVA_E, nil, AI.Task.WeaponExpend.ALL, 4, nil, 2000, nil, true)
						casGroup:PushTask(BLUE_CAS_TASK, 30)
					elseif RED_COLUMN_JAVA_W:IsAlive() then
						local BLUE_CAS_TASK = casGroup:TaskAttackGroup(RED_COLUMN_JAVA_W, nil, AI.Task.WeaponExpend.ALL, 4, nil, 2000, nil, true)
						casGroup:PushTask(BLUE_CAS_TASK, 30)
					elseif RED_BEKMARI_COLUMN:IsAlive() then
						local BLUE_CAS_TASK = casGroup:TaskAttackGroup(RED_BEKMARI_COLUMN, nil, AI.Task.WeaponExpend.ALL, 4, nil, 2000, nil, true)
						casGroup:PushTask(BLUE_CAS_TASK, 30)
					elseif RED_SATIHARI_COLUMN:IsAlive() then
						local BLUE_CAS_TASK = casGroup:TaskAttackGroup(RED_SATIHARI_COLUMN, nil, AI.Task.WeaponExpend.ALL, 4, nil, 2000, nil, true)
						casGroup:PushTask(BLUE_CAS_TASK, 30)
					else
						RokiChallenge.blueCasRtb()
					end

					casGroup:HandleEvent(EVENTS.Land)
					function casGroup:OnEventLand(EventData)
					    casGroup:Destroy()
					end
				end
				)
			:Spawn()
	    
	    RokiChallenge.blueCasRunning = true
	else
		if BLUE_CAS_GROUP:IsAlive() then
			--do nothing
		else
		  RokiChallenge.blueCasRunning = false
		  RokiChallenge.spawnBlueCas()
		end
	end
end

function RokiChallenge.blueCasRtb()
	if RokiChallenge.blueCasRunning then
	    BLUE_CAS_GROUP:RouteRTB(AIRBASE.Caucasus.Vaziani, 800)
	else
	  	RokiChallenge.blueCasRunning = false
	end
end

function RokiChallenge.spawnRedCarpetBomber()
  if RokiChallenge.redCarpetBomberRunning == false then
    -- GROUP for the AI (in the mission editor)
    RED_CARPET_BOMBER = SPAWN
    :New( "RED CARPET BOMBER" )
    :InitLimit(1,2)
    :OnSpawnGroup(
      function( MooseGroup )
        RED_CARPET_BOMB_TASK = MooseGroup:TaskBombing(BLUE_COMMAND_POST:GetVec2(), MooseGroup, AI.Task.WeaponExpend.ALL, 1, nil, 5000, nil, false)
        MooseGroup:PushTask(RED_CARPET_BOMB_TASK, 30)

        MooseGroup:HandleEvent(EVENTS.Dead)
        MooseGroup:HandleEvent(EVENTS.Land)
        
        function MooseGroup:OnEventLand(EventData)
            MooseGroup:Destroy()
            RokiChallenge.redCarpetBomberRunning = false
        end
      
        function MooseGroup:OnEventDead(EventData)
          	RokiChallenge.redCarpetBomberRunning = false
        end
      end)
    :Spawn()

    RokiChallenge.redCarpetBomberRunning = true
    trigger.action.outTextForCoalition(coalition.side.RED, "Tu-22 taking off", 30 , false)
    trigger.action.outSoundForCoalition(coalition.side.RED, "walkietalkie.ogg")
  else
    if RED_CARPET_BOMBER:IsAlive() then
  		-- do nothing
    else
      RokiChallenge.redCarpetBomberRunning = false
      RokiChallenge.spawnRedCarpetBomber()
    end
  end
end

function RokiChallenge.spawnBlueStrike()
  if RokiChallenge.blueStrikeRunning  == false and RED_BARRACKS:IsAlive() then
    BLUE_BOMBER = SPAWN
    :New( "BLUE BOMBER" )
    :InitLimit(1,2)
    :OnSpawnGroup(
      function( MooseGroup )
        BLUE_BOMB_TASK = MooseGroup:TaskBombing(RED_BARRACKS:GetVec2(), MooseGroup, AI.Task.WeaponExpend.ALL, 1, nil, 4500, nil, false)
        MooseGroup:PushTask(BLUE_BOMB_TASK, 30)
        MooseGroup:HandleEvent(EVENTS.Dead)
        MooseGroup:HandleEvent(EVENTS.Land)
        
        function MooseGroup:OnEventLand(EventData)
            MooseGroup:Destroy()
            RokiChallenge.blueStrikeRunning = false
        end
      
        function MooseGroup:OnEventDead(EventData)
          RokiChallenge.blueStrikeRunning = false
        end
      end)
    :Spawn()

    RokiChallenge.blueStrikeRunning = true
  else
    if BLUE_BOMBER:IsAlive() then
      --do nothing
    else
      RokiChallenge.blueStrikeRunning = false
      RokiChallenge.spawnBlueStrike()
    end
  end
end

-- ALPHA STRIKE FUNCTIONS

function RokiChallenge.redAlphaStrike()
	RokiChallenge.spawnRedCap()
	timer.scheduleFunction(RokiChallenge.spawnRedCas, {}, timer.getTime() + 120)
	timer.scheduleFunction(RokiChallenge.spawnRedStrike, {}, timer.getTime() + 180)
	timer.scheduleFunction(RokiChallenge.spawnRedCarpetBomber, {}, timer.getTime() + 180)
	trigger.action.outTextForCoalition(coalition.side.RED, "Alpha Strike launched", 10 , false)
	trigger.action.outSoundForCoalition(coalition.side.RED, "walkietalkie2.ogg")
	local randomRedTimer = math.random(900, 1500)
	timer.scheduleFunction(RokiChallenge.redAlphaStrike, {}, timer.getTime() + randomRedTimer)
end

function RokiChallenge.blueAlphaStrike()
	if RokiChallenge.blueAlphaStrikeEnabled then
		RokiChallenge.spawnBlueCap()
		RokiChallenge.spawnBlueCas()
		RokiChallenge.spawnBlueStrike()
		trigger.action.outTextForCoalition(coalition.side.BLUE, "Alpha Strike launched", 10 , false)
		trigger.action.outSoundForCoalition(coalition.side.BLUE, "walkietalkie2.ogg")
		local randomBlueTimer = math.random(600, 1200)
		timer.scheduleFunction(RokiChallenge.blueAlphaStrike, {}, timer.getTime() + randomBlueTimer)
	else
		trigger.action.outTextForCoalition(coalition.side.BLUE, "Command Center is destroyed, could not launch scheduled alpha strike", 10 , false)
		trigger.action.outSoundForCoalition(coalition.side.BLUE, "walkietalkie2.ogg")
		local randomBlueTimer = math.random(600, 1200)
		timer.scheduleFunction(RokiChallenge.blueAlphaStrike, {}, timer.getTime() + randomBlueTimer)
	end
end

local randomRedTimer = math.random(600, 1200)
local randomBlueTimer = math.random(600, 1200)
timer.scheduleFunction(RokiChallenge.redAlphaStrike, {}, timer.getTime() + randomRedTimer)
timer.scheduleFunction(RokiChallenge.blueAlphaStrike, {}, timer.getTime() + randomBlueTimer)

env.info("ALPHA STRIKE FLIGHTS FUNCTIONS loaded ...")
trigger.action.outText("ALPHA STRIKE FLIGHTS FUNCTIONS loaded ...", 10)

-- STRATEGIC TARGETS ******************************************************************************************************

-- BLUE COMMAND OUTPOST
BLUE_COMMAND_POST_ZONES = {
	ZONE:FindByName("BLUE COMMAND POST SPAWN1"),
	ZONE:FindByName("BLUE COMMAND POST SPAWN2"),
	ZONE:FindByName("BLUE COMMAND POST SPAWN3"),
	ZONE:FindByName("BLUE COMMAND POST SPAWN4")}

function RokiChallenge.spawnBlueCommandOutpost()
	BLUE_COMMAND_POST = SPAWN
		:New( "BLUE COMMAND OUTPOST" )
		:InitRandomizeZones( BLUE_COMMAND_POST_ZONES )
		:OnSpawnGroup(
		function( MooseGroup )
		  local MooseGroupCoordinate = MooseGroup:GetCoordinate()
		  local markId = MooseGroupCoordinate:MarkToAll("Command Outpost\nBLUE: Protect\nRED: Attack", true, nil)
		  RokiChallenge.mapMarkBlueCommandPost = markId

		  RokiChallenge.blueAlphaStrikeEnabled = true
		  trigger.action.outText("BLUE Command Post recon data available, see map.", 10)
		  trigger.action.outSound("walkietalkie2.ogg" )

		  MooseGroup:HandleEvent(EVENTS.Dead)

		  function MooseGroup:OnEventDead(EventData)
		  	if BLUE_COMMAND_POST:GetSize() == 2 then
		  		trigger.action.removeMark( RokiChallenge.mapMarkBlueCommandPost )
			 	RokiChallenge.blueAlphaStrikeEnabled = false
			 	BLUE_COMMAND_POST:Destroy( false )
			 	trigger.action.outText("BLUE Command Outpost destroyed", 10)
			    trigger.action.outSound("walkietalkie2.ogg" )
			    timer.scheduleFunction(RokiChallenge.spawnBlueCommandOutpost, {}, timer.getTime() + 1800)
		  	end
		 end
		end)
		:Spawn()
end

-- RED BARRACKS
RED_BARRACKS_ZONES = { 
	ZONE:FindByName( "RED BARRACKS SPAWN1" ),
	ZONE:FindByName( "RED BARRACKS SPAWN2" ),
	ZONE:FindByName( "RED BARRACKS SPAWN3" )}

function RokiChallenge.spawnRedBarracks()
	RED_BARRACKS = SPAWN
		:New( "RED BARRACKS" )
		:InitRandomizeZones( RED_BARRACKS_ZONES )
		:OnSpawnGroup(
		function( MooseGroup )
		  local MooseGroupCoordinate = MooseGroup:GetCoordinate()
		  local markId = MooseGroupCoordinate:MarkToAll("Military Barracks\nBLUE: Attack\nRED: Protect", true, nil)
		  RokiChallenge.mapMarkRedBarracks = markId

		  RED_COLUMNS_SCHEDULER:Start()
		  trigger.action.outText("RED Military Barracks Repaired, see map.", 10)
		  trigger.action.outSound("walkietalkie2.ogg" )

		  MooseGroup:HandleEvent(EVENTS.Dead)	  

		 function MooseGroup:OnEventDead(EventData)
		 	if RED_BARRACKS:GetSize() == 9 then
		 		trigger.action.removeMark( RokiChallenge.mapMarkRedBarracks )
			 	RED_COLUMNS_SCHEDULER:Stop()
			 	RED_BARRACKS:Destroy( false )
			 	trigger.action.outText("RED Military Barracks attacked, no ground units for 30 minutes.", 10)
			    trigger.action.outSound("walkietalkie2.ogg" )
			    timer.scheduleFunction(RokiChallenge.spawnRedBarracks, {}, timer.getTime() + 1800)
		 	end
		  end
		end)
		:Spawn()
end

-- Spawn at mission start
RokiChallenge.spawnBlueCommandOutpost()
RokiChallenge.spawnRedBarracks()

env.info("STRATEGIC TARGETS FUNCTIONS loaded ...")
trigger.action.outText("STRATEGIC TARGETS FUNCTIONS loaded ...", 10)

-- BLUE AFAC ***************************************************************************************

BLUE_HQ = GROUP:FindByName( "BLUE HQ", "Zeus HQ" )
BLUE_CC = COMMANDCENTER:New( BLUE_HQ, "Zeus" )

BLUE_OBSERVER_DETECTED_GROUP = nil

BLUE_OBSERVERS = SET_GROUP:New():FilterPrefixes( "BLUE OBSERVER" ):FilterStart()
BLUE_OBSERVERS_DETECTION = DETECTION_AREAS:New( BLUE_OBSERVERS, 2000 ):FilterCategories( Unit.Category.GROUND_UNIT )
BLUE_OBSERVERS_DETECTION:BoundDetectedZones()
BLUE_OBSERVERS_DETECTION:Start()

function BLUE_OBSERVERS_DETECTION:OnAfterDetected(From, Event, To, Units)
	for groupId, isSubscribed in pairs(RokiChallenge.blueAfacSubscribedGroups) do
		if isSubscribed then
			local playerUnit = UNIT:FindByName(RokiChallenge.playerGroups[groupId])
			if playerUnit then
				trigger.action.outTextForGroup(groupId, "AFAC has new tasking available", 30 , false)
				trigger.action.outSoundForGroup(groupId, "walkietalkie.ogg")
			else
				-- remove it, just to keep things clean
				RokiChallenge.blueAfacSubscribedGroups = false
			end
		end
	end
	for index, unit in pairs(Units) do
		-- store target in a global variable
		BLUE_OBSERVER_DETECTED_GROUP = unit:GetGroup()
  	end
  	-- get target coordinate and orbit above it
  	--local groupCoordinate = BLUE_OBSERVER_DETECTED_GROUP:GetVec2()
	--local blueObserverOrbitTask = BLUE_OBSERVER:TaskOrbitCircleAtVec2(groupCoordinate, 2000, 500)
	--BLUE_OBSERVER:PushTask(blueObserverOrbitTask, 0)
	-- stop detection until player does his stuff and then detection will resume when player invokes RokiChallenge.afacResumePatrol()
  	--timer.scheduleFunction(RokiChallenge.afacStopDetection, {}, timer.getTime() + 15)
end

function RokiChallenge.afacResumePatrol(groupId)
	BLUE_OBSERVERS_DETECTION:Stop()
	-- stop detection and get back to original route after 5 seconds, trigger detection re-start after 5 minutes
	BLUE_OBSERVER_DETECTED_GROUP = nil
	local route = BLUE_OBSERVER:GetTaskRoute()
	BLUE_OBSERVER:Route(route, 5)
	timer.scheduleFunction(RokiChallenge.afacStartDetection, {}, timer.getTime() + 300)
	trigger.action.outTextForGroup(groupId, "Thanks for the support, resuming patrol", 30 , false)
	trigger.action.outSoundForGroup(groupId, "walkietalkie2.ogg")
end

function RokiChallenge.afacStartDetection()
	BLUE_OBSERVERS_DETECTION:Start()
end

function RokiChallenge.afacGetReport(groupId)
	local detectionReport = BLUE_OBSERVERS_DETECTION:DetectedReportDetailed()
	trigger.action.outTextForGroup(groupId, detectionReport, 30 , false)
	trigger.action.outSoundForGroup(groupId, "walkietalkie2.ogg")
end

function RokiChallenge.afacFlareSelf(groupId)
	trigger.action.outTextForGroup(groupId, "Flare out", 5 , false)
	trigger.action.outSoundForGroup(groupId, "walkietalkie.ogg")
	BLUE_OBSERVER:FlareRed()
end

function RokiChallenge.afacSubscribe(groupId)
	RokiChallenge.blueAfacSubscribedGroups[groupId] = true
	trigger.action.outTextForGroup(groupId, "AFAC reports ON", 30 , false)
	trigger.action.outSoundForGroup(groupId, "walkietalkie.ogg")
end

function RokiChallenge.afacUnsuscribe(groupId)
	RokiChallenge.blueAfacSubscribedGroups[groupId] = false
	trigger.action.outTextForGroup(groupId, "AFAC reports OFF", 30 , false)
	trigger.action.outSoundForGroup(groupId, "walkietalkie.ogg")
end

-- send messages to subscribed player GROUPS, can't send message to single units
BLUE_AFAC_BRA_REPORT_SCHEDULER = SCHEDULER:New(nil,
	function()
		if RokiChallenge.blueAfacRunning == true then
			for groupId, isSubscribed in pairs(RokiChallenge.blueAfacSubscribedGroups) do
				if isSubscribed then
					local playerUnit = UNIT:FindByName(RokiChallenge.playerGroups[groupId])
					if playerUnit then
						local playerUnitVec3 = playerUnit:GetVec3()
						local playerCoordinate = COORDINATE:NewFromVec3(playerUnitVec3)
						local blueObserverVec3 = BLUE_OBSERVER:GetVec3()
						local blueObserverCoordinate = COORDINATE:NewFromVec3(blueObserverVec3)
						local bra = blueObserverCoordinate:ToStringBRA(playerCoordinate, nil)
						trigger.action.outTextForGroup(groupId, bra, 30 , false)
						trigger.action.outSoundForGroup(groupId, "walkietalkie.ogg")
					else
						-- remove it, just to keep things clean
						RokiChallenge.blueAfacSubscribedGroups = false
					end
				end
			end
		end
	end, {}, 0, 30, 0 )
BLUE_AFAC_BRA_REPORT_SCHEDULER:Start()

function RokiChallenge.afacSmokeTarget(groupId)
	if BLUE_OBSERVER_DETECTED_GROUP then
		trigger.action.outTextForGroup(groupId, "AFAC running in", 30 , false)
		trigger.action.outSoundForGroup(groupId, "walkietalkie2.ogg")
		BLUE_OBSERVER_SMOKE_TASK = BLUE_OBSERVER:TaskAttackGroup(BLUE_OBSERVER_DETECTED_GROUP, nil, AI.Task.WeaponExpend.ONE, 1, nil, 2000, true)
		BLUE_OBSERVER:PushTask(BLUE_OBSERVER_SMOKE_TASK, 0)
	else
		trigger.action.outTextForGroup(groupId, "AFAC has no targets available", 30 , false)
		trigger.action.outSoundForGroup(groupId, "walkietalkie2.ogg")
	end
end

function RokiChallenge.spawnBlueAfac(groupId)
	if RokiChallenge.blueAfacRunning == false then
		BLUE_OBSERVER = SPAWN
			:New("BLUE OBSERVER")
			:InitLimit(1,0)
			:InitRepeatOnLanding()
			:OnSpawnGroup(
		        function (MooseGroup)

		        	RokiChallenge.afacStartDetection()
					MooseGroup:HandleEvent(EVENTS.Dead)
					MooseGroup:HandleEvent(EVENTS.Land)
					MooseGroup:HandleEvent(EVENTS.Shot)

					function MooseGroup:OnEventDead(EventData)
						RokiChallenge.blueAfacRunning = false
					end

					function MooseGroup:OnEventLand(EventData)
						trigger.action.outTextForCoalition(coalition.side.BLUE, "AFAC returned to base", 30 , false)
						trigger.action.outSoundForCoalition(coalition.side.BLUE, "walkietalkie2.ogg")
						RokiChallenge.blueAfacRunning = false
						MooseGroup:Destroy()
					end

					function MooseGroup:OnEventShot(self, EventData )
				        trigger.action.outTextForCoalition(coalition.side.BLUE, "Smoke out", 30 , false)
						trigger.action.outSoundForCoalition(coalition.side.BLUE, "walkietalkie2.ogg")
				    end
				end)
			:Spawn()

		RokiChallenge.blueAfacRunning = true
		trigger.action.outTextForCoalition(coalition.side.BLUE, "AFAC enroute to patrol area", 30 , false)
    	trigger.action.outSoundForCoalition(coalition.side.BLUE, "walkietalkie.ogg")
	else
		if BLUE_OBSERVER:IsAlive() then
      		trigger.action.outTextForGroup(groupId, "AFAC already in flight", 10 , false)
			trigger.action.outSoundForGroup(groupId, "walkietalkie.ogg")
		else
			RokiChallenge.blueAfacRunning = false
      		RokiChallenge.spawnBlueAfac()
		end
	end
end

env.info("AFAC FUNCTIONS loaded ...")
trigger.action.outText("AFAC FUNCTIONS loaded ...", 10)

-- AWACS ********************************************************************************************

BLUE_AWACS = SPAWN
	:New( "BLUE AWACS" )
	:InitLimit(1,1)
	:OnSpawnGroup(
		function(MooseGroup)
			MooseGroup:HandleEvent(EVENTS.Land)

			function MooseGroup:OnEventLand(EventData)
		        MooseGroup:Destroy()
		    end
		end
	)
	:SpawnScheduled(900, 1)

RED_AWACS = SPAWN
	:New( "RED AWACS" )
	:InitLimit(1,1)
	:OnSpawnGroup(
		function(MooseGroup)
			MooseGroup:HandleEvent(EVENTS.Land)

			function MooseGroup:OnEventLand(EventData)
		        MooseGroup:Destroy()
		    end
		end
	)
	:SpawnScheduled(900, 1)

-- TANKER *********************************************************************************************

BLUE_TANKER = SPAWN
	:New( "BLUE TANKER" )
	:InitLimit( 1,1)
	:OnSpawnGroup(
		function(MooseGroup)
			MooseGroup:HandleEvent(EVENTS.Land)

			function MooseGroup:OnEventLand(EventData)
		        MooseGroup:Destroy()
		    end
		 end
	)		
	:SpawnScheduled(600, 1)
	
BLUE_TANKER_ESCORT = SPAWN
	:New( "BLUE TANKER ESCORT" )
	:InitLimit( 2,4)
	:OnSpawnGroup(
		function(MooseGroup)
			MooseGroup:HandleEvent(EVENTS.Land)

			function MooseGroup:OnEventLand(EventData)
		        MooseGroup:Destroy()
		    end
		 end
	)		
	:SpawnScheduled(300, 1)		
		

-- ADD RADIO MENUS ***************************************************************************************

function RokiChallenge.addRadioMenus(_side)

  local _players = coalition.getPlayers(_side)

    if _players ~= nil then
        for _, _playerUnit in pairs(_players) do
          local _groupId = ctld.getGroupId(_playerUnit)
          if _groupId then
          	  RokiChallenge.playerGroups[_groupId] = _playerUnit:getName()
              if RokiChallenge.radioMenusAdded[tostring(_groupId)] == nil then
              	if _side == coalition.side.BLUE then
              		local afacMenuRoot = missionCommands.addSubMenuForGroup(_groupId, "AFAC")
              		missionCommands.addCommandForGroup(_groupId, "Request new AFAC", afacMenuRoot, RokiChallenge.spawnBlueAfac, _groupId)
              		missionCommands.addCommandForGroup(_groupId, "Report contacts", afacMenuRoot, RokiChallenge.afacGetReport, _groupId)
              		missionCommands.addCommandForGroup(_groupId, "Shoot flare", afacMenuRoot, RokiChallenge.afacFlareSelf, _groupId)
              		missionCommands.addCommandForGroup(_groupId, "Smoke target", afacMenuRoot, RokiChallenge.afacSmokeTarget, _groupId)
              		missionCommands.addCommandForGroup(_groupId, "START AFAC reports", afacMenuRoot, RokiChallenge.afacSubscribe, _groupId)
              		missionCommands.addCommandForGroup(_groupId, "STOP AFAC reports", afacMenuRoot, RokiChallenge.afacUnsuscribe, _groupId)
              		missionCommands.addCommandForGroup(_groupId, "Tasking out", afacMenuRoot, RokiChallenge.afacResumePatrol, _groupId)
              	end
                missionCommands.addCommandForGroup(_groupId, "List Radio Frequencies", nil, RokiChallenge.listRadioFrequencies, _groupId)
                RokiChallenge.radioMenusAdded[tostring(_groupId)] = true
              end
          end
        end
    end
end

-- reschedule for users that change slot or coalition
RADIO_MENU_SCHEDULER = SCHEDULER:New(nil,
  function()
    -- ADD MENUS FOR RED
    RokiChallenge.addRadioMenus(1)
    -- ADD MENUS FOR BLUE
    RokiChallenge.addRadioMenus(2)
  end, {}, 0, 60, 0 )

-- LIST RADIO FREQUENCIES FUNCTIONS ***************************************************************************************

function RokiChallenge.listRadioFrequencies(_groupId)

  trigger.action.outTextForGroup(_groupId, 
    [[
    BLUEFOR
    GUARD - 243 MHz
    AWACS - 231 MHz
    SHELL - 245 Mhz  TCN 64X
    ARCO - 238 Mhz TCN 38X
    ****
    CAP 250 MHz
    CAS 260 MHz
    ****
    USS STENNIS TCN 74X - AWCLS 11
    ***
    Vaziani 140/269 MHz
    ILS 108.75 MHz CRS 129
    TCN 22X
    ****
    ]]
    , 15 , false)  
  trigger.action.outSoundForGroup(_groupId, "walkietalkie.ogg")
end

env.info("RADIO FREQUENCIES FUNCTIONS loaded ...")
trigger.action.outText("RADIO FREQUENCIES FUNCTIONS loaded ...", 10)

-- SCORING ***************************************************************************************

RokiChallengeScore = SCORING:New( "Roki Challenge" )
RokiChallengeScore:SetScaleDestroyScore( 100 )
RokiChallengeScore:SetScaleDestroyPenalty( 200 )
RokiChallengeScore:SetMessagesHit( false )
RokiChallengeScore:SetMessagesDestroy( true )
RokiChallengeScore:SetMessagesToAll( true )

env.info("SCORING loaded ...")
trigger.action.outText("SCORING loaded ...", 10)

-- END ***************************************************************************************

env.info("Roki Challenge loaded OK ...")
trigger.action.outText("Roki Challenge loaded OK ...", 10)