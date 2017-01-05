local Bridge = {}

local Utils = require "util.utils"

local socket = require "socket"
local memory = require "util.memory"

local client = nil
local timeStopped = true
local timeMin = 0
local timeFrames = 0

local function send(prefix, body)

end


-- Wrapper functions

function Bridge.init(gameName)
	
end

function Bridge.tweet(message)
	--print("tweet::"..message)
	return true
end

function Bridge.pollForName()
	Bridge.polling = true
end

function Bridge.chatRandom(...)
	return Bridge.chat(Utils.random(arg))
end

function Bridge.chat(message, suppressed, extra, newLine)
	if not suppressed then
		if extra then
			p(message.." | "..extra, newLine)
		else
			p(message, newLine)
		end
	end
	return true
end

function Bridge.time()
	if (not timeStopped) then
		local frames = memory.raw(0x1A45)
		local seconds = memory.raw(0x1A44)
		local minutes = memory.raw(0x1A43)
		local hours = memory.raw(0x1A41)

		if (frames == timeFrames) then
			local seconds2 = seconds + (frames / 60)
			local message = hours..":"..minutes..":"..seconds2
			send("setgametime", message)
			if timeFrames == 59 then
				timeFrames = 0
			else
				timeFrames = (frames + 1)
			end
		end

		send("unpausegametime")
	end
end

function Bridge.stats(message)
	return true
end

function Bridge.command(command)
	--print("Bridge Command")
	return send(command)
end

function Bridge.comparisonTime()
	print("Bridge Comparison Time")
	return send("getcomparisonsplittime")
end

function Bridge.process()
	
end

function Bridge.input(key)
	
end

function Bridge.caught(name)
	
end

function Bridge.hp(curr_hp, max_hp, curr_xp, max_xp, level)
	
end


function Bridge.liveSplit()
	timeStopped = false
end

function Bridge.split(finished)
	if finished then
		timeStopped = true
	end
	send("split")
	Utils.splitUpdate()
end

function Bridge.pausegametime()
	send("pausegametime")
end

function Bridge.encounter()
end

function Bridge.report(report)
	
end

-- GUESSING

function Bridge.guessing(guess, enabled)
	
end

function Bridge.guessResults(guess, result)
	
end

function Bridge.moonResults(encounters, cutter)
	
end

-- RESET

function Bridge.reset()
	timeStopped = false
end

function Bridge.close()
	
end

return Bridge
