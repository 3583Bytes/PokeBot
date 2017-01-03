local Utils = {}

local Memory = require "util.memory"
local Strategies
local Data = require "data.data"

local EMP = 1
local splitCheck = 0
local splitNum = 1

-- GLOBAL

function p(...)
	local string
	if #arg == 0 then
		string = arg[0]
	else
		string = ""
		for __,str in ipairs(arg) do
			if str == true then
				string = string.."\n"
			else
				string = string..str.." "
			end
		end
	end
	print(string)
end

-- GENERAL

function Utils.reset()
	splitCheck = 0
	splitNum = 1
end

function Utils.splitUpdate()
	splitNum = splitNum + 1
end

function Utils.dist(x1, y1, x2, y2)
	return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
end

function Utils.each(table, func)
	for key,val in pairs(table) do
		func(key.." = "..tostring(val)..",")
	end
end

function Utils.eachi(table, func)
	for idx,val in ipairs(table) do
		if val then
			func(idx.." "..val)
		else
			func(idx)
		end
	end
end

function Utils.match(needle, haystack)
	for __,val in ipairs(haystack) do
		if needle == val then
			return true
		end
	end
	return false
end

function Utils.key(needle, haystack)
	for key,val in pairs(haystack) do
		if needle == val then
			return key
		end
	end
	return nil
end

function Utils.capitalize(string)
	return string:sub(1, 1):upper()..string:sub(2)
end

function Utils.nextCircularIndex(index, direction, totalCount)
	local nextIndex = index + direction
	if nextIndex < 1 then
		nextIndex = totalCount
	elseif nextIndex > totalCount then
		nextIndex = 1
	end
	return nextIndex
end

function Utils.append(string, appendage, separator)
	if not string then
		return appendage
	end
	return string..separator..appendage
end

function Utils.multiplyString(string, times)
	local result = string
	for __=1, times-1 do
		result = result.." "..string
	end
	return result
end

function Utils.pluralize(amount, description)
	if amount ~= 1 then
		description = description.."s"
	end
	return amount.." "..description
end

function Utils.random(items)
	return items[math.random(1, #items)]
end

-- GAME

function Utils.canPotionWith(potion, forDamage, curr_hp, max_hp)
	if curr_hp > max_hp - 3 then
		return false
	end
	local potion_hp
	if potion == "full_restore" then
		potion_hp = 9001
	elseif potion == "super_potion" then
		potion_hp = 50
	else
		potion_hp = 20
	end
	return math.min(curr_hp + potion_hp, max_hp) > forDamage
end

function Utils.ingame()
	return Memory.raw(0x020E) > 0
end

function Utils.drawText(x, y, message, right)
	if right then
		x = x - #message * 5
	end
	gui.text(x * EMP, y * EMP, message)
end

-- TIME

function Utils.frames()
	local totalFrames = Memory.value("time", "hours") * 60
	totalFrames = (totalFrames + Memory.value("time", "minutes")) * 60
	totalFrames = (totalFrames + Memory.value("time", "seconds")) * 60
	totalFrames = totalFrames + Memory.value("time", "frames")
	return totalFrames
end

function Utils.igt()
	local hours = Memory.value("time", "hours")
	local mins = Memory.value("time", "minutes")
	local secs = Memory.value("time", "seconds")
	return (hours * 60 + mins) * 60 + secs
end

local function clockSegment(unit)
	if unit < 10 then
		unit = "0"..unit
	end
	return unit
end

function Utils.timeSince(prevTime)
	local currTime = Utils.igt()
	local diff = currTime - prevTime
	local timeString
	if diff > 0 then
		local secs = diff % 60
		local mins = math.floor(diff / 60)
		timeString = clockSegment(mins)..":"..clockSegment(secs)
	end
	return currTime, timeString
end

function Utils.elapsedTime()
	local secs = Memory.value("time", "seconds")
	local mins = Memory.value("time", "minutes")
	local hours = Memory.value("time", "hours")
	return hours..":"..clockSegment(mins)..":"..clockSegment(secs)
end

function Utils.timeToSplit(splitName)
	if splitName == nil then
		return 0
	else
		local currTime = Utils.igt()
		local splitTime = Strategies.getTimeRequirement(splitName) * 60
		local diff = currTime - splitTime
		return diff
	end
end

function Utils.splitCheck()
	local order = { "bulbasaur", "nidoran", "brock", "route3", "mt_moon", "mankey", "misty", "trash", "safari_carbos", "safari_carbos" , "safari_carbos", "victory_road", "victory_road", "victory_road", "victory_road", "victory_road", "e4center", "blue", "blue", "blue", "champion", "champion" }
	if splitCheck == 600 then
		local timediff = Utils.timeToSplit(order[splitNum])
		if timediff >= 600 then
			p("Something has gone wrong, Restarting... /n")
			Strategies.reboot()
		end
		splitCheck = 0
	else
		splitCheck = splitCheck + 1
	end
end

function Utils.init()
	Strategies = require("ai."..Data.gameName..".strategies")
end

return Utils
