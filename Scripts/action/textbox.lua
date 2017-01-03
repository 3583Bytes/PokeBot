local Textbox = {}

local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"

local Data = require "data.data"

local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ *():;[]ab-?!mf/.,"
-- local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ *():;[]ポモ-?!♂♀/.,"

local nidoName = "A"
local nidoIdx = 1

local playerSelected = false

local function getLetterAt(index)
	return alphabet:sub(index, index)
end

local function getIndexForLetter(letter)
	return alphabet:find(letter, 1, true)
end

function Textbox.PlayerName(letter, randomize)
	local inputting = Memory.value("menu", "text_input") == 240
	if inputting then
		if Memory.value("menu", "text_length") > 3 then
			Input.press("Start")
			playerSelected = true
			return true
		end
		local lidx
		
		if (playerSelected == false) then
			if (Memory.value("menu", "text_length") > 2) then
				lidx = getIndexForLetter("M")
			elseif (Memory.value("menu", "text_length") > 1) then
				lidx = getIndexForLetter("A")
			elseif (Memory.value("menu", "text_length") > 0) then
				lidx = getIndexForLetter("D")
			elseif (Memory.value("menu", "text_length") == 0) then
				lidx = getIndexForLetter("A")
			else
				input.press("Start")
				return true
			end
		end
		
		if (playerSelected == true) then
			if (Memory.value("menu", "text_length") > 2) then
				lidx = getIndexForLetter("Y")
			elseif (Memory.value("menu", "text_length") > 1) then
				lidx = getIndexForLetter("R")
			elseif (Memory.value("menu", "text_length") > 0) then
				lidx = getIndexForLetter("A")
			elseif (Memory.value("menu", "text_length") == 0) then
				lidx = getIndexForLetter("G")
			else
				input.press("Start")
				return true
			end
		end

		local crow = Memory.value("menu", "input_row")
		local drow = math.ceil(lidx / 9)
		if Menu.balance(crow, drow, true, 6, true) then
			local ccol = math.floor(Memory.value("menu", "column") / 2)
			local dcol = math.fmod(lidx - 1, 9)
			if Menu.sidle(ccol, dcol, 9, true) then
				Input.press("A")
			end
		end
	else
		-- TODO cancel when menu isn't up
		-- if Memory.value("menu", "current") == 7 then
		if Memory.raw(0x10B7) == 3 then
			Input.press("A", 2)
		elseif randomize then
			Input.press("A", math.random(1, 5))
		else
			Input.cancel()
		end
	end
end

function Textbox.PokemonName(randomize)
	local inputting = Memory.value("menu", "text_input") == 240
	if (inputting) then
		Input.press("Start")
	else
		-- TODO cancel more when menu isn't up
		if (Memory.raw(0x10B7) == 3) then
			Input.press("A", 2)
		elseif (randomize) then
			Input.press("A", math.random(1, 5))
		else
			Input.cancel()
		end
	end
end

function Textbox.name(letter, randomize)
	local inputting = Memory.value("menu", "text_input") == 240
	if inputting then
		if Memory.value("menu", "text_length") > 0 then
			Input.press("Start")
			return true
		end
		local lidx
		if letter then
			lidx = getIndexForLetter(letter)
		else
			lidx = nidoIdx
		end

		local crow = Memory.value("menu", "input_row")
		local drow = math.ceil(lidx / 9)
		if Menu.balance(crow, drow, true, 6, true) then
			local ccol = math.floor(Memory.value("menu", "column") / 2)
			local dcol = math.fmod(lidx - 1, 9)
			if Menu.sidle(ccol, dcol, 9, true) then
				Input.press("A")
			end
		end
	else
		-- TODO cancel when menu isn't up
		-- if Memory.value("menu", "current") == 7 then
		if Memory.raw(0x10B7) == 3 then
			Input.press("A", 2)
		elseif randomize then
			Input.press("A", math.random(1, 5))
		else
			Input.cancel()
		end
	end
end

function Textbox.getName()
	if nidoName == "a" then
		return "ポ"
	end
	if nidoName == "b" then
		return "モ"
	end
	if nidoName == "m" then
		return "♂"
	end
	if nidoName == "f" then
		return "♀"
	end
	return nidoName
end

function Textbox.getNamePlaintext()
	return nidoName
end

function Textbox.setName(name)
	if type(name) == "string" then
		nidoName = name
		nidoIdx = getIndexForLetter(name)
	elseif name >= 0 and name < #alphabet then
		nidoIdx = name + 1
		nidoName = getLetterAt(name)
	end
	Data.run.voted_name = nidoName
end

function Textbox.isActive()
	return Memory.value("game", "textbox") == 1
end

function Textbox.handle()
	if not Textbox.isActive() then
		return true
	end
	Input.cancel()
end

function Textbox.reset()
	playerSelected = false
end

return Textbox
