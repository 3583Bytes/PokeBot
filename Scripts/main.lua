-- OPTIONS

RESET_FOR_TIME = false -- Set to true if you're trying to break the record, not just finish a run
BEAST_MODE = false -- WARNING: Do not engage. Will yolo everything, and reset at every opportunity in the quest for 1:47.

INITIAL_SPEED = 400
AFTER_BROCK_SPEED = 400

RUNS_FILE = "C:/Users/Adam/Documents/PokeBotGoodv5/runs.txt" -- Use / insted of \ otherwise it will not work

local CUSTOM_SEED  = nil -- Set to a known seed to replay it, or leave nil for random runs
local NIDORAN_NAME = "A" -- Set this to the single character to name Nidoran (note, to replay a seed, it MUST match!)
local PAINT_ON     = false -- Display contextual information while the bot runs

-- START CODE (hard hats on)

VERSION = "2.5.1"

local Data = require "data.data"

Data.init()

local Battle = require "action.battle"
local Textbox = require "action.textbox"
local Walk = require "action.walk"

local Combat = require "ai.combat"
local Control = require "ai.control"
local Strategies = require("ai."..Data.gameName..".strategies")

local Pokemon = require "storage.pokemon"

local Bridge = require "util.bridge"
local Input = require "util.input"
local Memory = require "util.memory"
local Paint = require "util.paint"
local Utils = require "util.utils"
local Settings = require "util.settings"

local hasAlreadyStartedPlaying = false
local oldSeconds
local running = true
local previousMap
local pxLast, pyLast
local SuckCount = 0

-- HELPERS

function resetAll()
	Strategies.softReset()
	Combat.reset()
	Control.reset()
	Walk.reset()
	Paint.reset()
	Bridge.reset()
	Utils.reset()
	Textbox.reset()
	oldSeconds = 0
	SuckCount = 0
	running = false
	client.speedmode(INITIAL_SPEED)

	if CUSTOM_SEED then
		if CUSTOM_SEED == 1482661519 then
			CUSTOM_SEED = 1482669594
		elseif CUSTOM_SEED == 1482669594 then
			CUSTOM_SEED = 1482661519
		else
			CUSTOM_SEED = 1482669594
		end
	
		Data.run.seed = CUSTOM_SEED
		Strategies.replay = true
		print("PokeBot v"..VERSION..": ".."Fixed Seed:".." "..Data.run.seed)
	else
		Data.run.seed = os.time()
		print("PokeBot v"..VERSION..": ".."Seed:".." "..Data.run.seed)
	end
	math.randomseed(Data.run.seed)
end


-- EXECUTE

Control.init()
Utils.init()

if CUSTOM_SEED then
	Strategies.reboot()
else
	hasAlreadyStartedPlaying = Utils.ingame()
end

Strategies.init(hasAlreadyStartedPlaying)

if hasAlreadyStartedPlaying and RESET_FOR_TIME then
	RESET_FOR_TIME = false
	p("Disabling time-limit resets as the game is already running. Please reset the emulator and restart the script if you'd like to go for a fast time.", true)
end

Bridge.init(Data.gameName)

-- LOOP

local function generateNextInput(currentMap)
	if not Utils.ingame() then
		Bridge.pausegametime()
		if currentMap == 0 then
			if running then
				if not hasAlreadyStartedPlaying then
					if emu.framecount() ~= 1 then Strategies.reboot() end
					hasAlreadyStartedPlaying = true
				else
					resetAll()
				end
			else
				Settings.startNewAdventure()
			end
		else
			if not running then
				Bridge.liveSplit()
				running = true
			end
			Settings.choosePlayerNames()
		end
	else
		Bridge.time()
		Utils.splitCheck()
		local battleState = Memory.value("game", "battle")
		Control.encounter(battleState)

		local curr_hp = Combat.hp()
		Combat.updateHP(curr_hp)

		if curr_hp == 0 and not Control.canDie() and Pokemon.index(0) > 0 then
			Strategies.death(currentMap)
		elseif Walk.strategy then
			if Strategies.execute(Walk.strategy) then
				if Walk.traverse(currentMap) == false then
					return generateNextInput(currentMap)
				end
			end
		elseif battleState > 0 then
			if not Control.shouldCatch() then
				SuckCount = 0
				Battle.automate()
			end
		elseif Textbox.handle() then
			if Walk.traverse(currentMap) == false then
				return generateNextInput(currentMap)
			end
		end
	end
end

while true do

	SuckCount = SuckCount + 1

	local currentMap = Memory.value("game", "map")
	if currentMap ~= previousMap then
		Input.clear()
		previousMap = currentMap
		SuckCount = 0
	end
	if Strategies.frames then
		if Memory.value("game", "battle") == 0 then
			Strategies.frames = Strategies.frames + 1
		end
		Utils.drawText(0, 80, Strategies.frames)
	end
	if Bridge.polling then
		Settings.pollForResponse(NIDORAN_NAME)
	end

	if not Input.update() then
		generateNextInput(currentMap)
	end

	
	local newSeconds = Memory.value("time", "seconds")
	if newSeconds ~= oldSeconds and (newSeconds > 0 or Memory.value("time", "frames") > 0) then
		Bridge.time(Utils.elapsedTime())
		oldSeconds = newSeconds
	end
	
	
	if SuckCount > 25000 then
		print ("Stuck Detected")
		Strategies.reset("Stuck Detected", SuckCount, nil, true)
	end
	
	
	Input.advance()
	emu.frameadvance()
end

Bridge.close()
