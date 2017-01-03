--RBI Baseball script
--Written by adelikat
--Shows stats and information on screen and can even change a batter or pitcher's hand

local PitchingScreenAddr = 0x001A;
local PitchingScreen;

local p1PitchHealthAddr = 0x060D;
local p1PitchHealth;

local p2PitchHealthAddr = 0x061D;
local p2PitchHealth;

local p1OutsAddr = 0x0665;
local p1Outs;

local pitchtypeAddr = 0x0112;
local pitchtype;

local P1currHitterPowerAddr = 0x062B --2 byte
local P1currSpeedAddr = 0x062D
local P1currContactAddr = 0x062A

local P2currHitterPowerAddr = 0x063B --2 byte
local P2currSpeedAddr = 0x063D
local P2currContactAddr = 0x063A

local topinningAddr = 0x0115

--Extra Ram map notes
--0627 = P1 Batter Lefy or Righty (even or odd)
--0628 = P1 Bat average 150 + this address
--0629 = P1 # of Home Runs
--0638 = P2 Bat average 2 150 + this address
--0639 = P2 # of Home Runs
--0637 = P2 Batter Lefy or Righty (even or odd)

--060x = P1 pitcher, 061x = P2 pitcher

--0607 = 
--Right digit =	P1 Pitcher Lefty or Right (even or odd)
--Left digit = P1 Pitcher drop rating

--0609 = P1 Sinker ball speed
--060A = P1 Regular ball Speed
--060B = P1 Fastball Speed
--060C = P1 Pitcher Curve rating left digit is curve left, right is curve right

--0114 = Current Inning
--0115 = 10 if bottom of inning, 0 if on top, controls which player can control the batter

--0728 & 0279 - In charge of inning music

--TODO
--A hotkeys for boosting/lowering current pitcher (p1 or 2) health
--fix pitcher L/R switching to not kill the left digit (drop rating) in the process
--Do integer division on curve rating
--Outs display is wrong
--Music on/off toggle

console.writeline("RBI Baseball script");
console.writeline("Written by adelikat");
console.writeline("Description: Shows stats and information on screen and can even change a batter or pitcher's hand");
console.writeline("\nHotkeys: ");
console.writeline("Toggle Hand of player 2: \nH/J");
console.writeline("Toggle Hand of player 1: \nK/L");

function P1BoostHitter()
	mainmemory.write_u16_le(0x062B, mainmemory.read_u16_le(0x062B) + 128);
end

function P1DropHitter()
	mainmemory.write_u16_le(0x062B, mainmemory.read_u16_le(0x062B) - 128);
end

function P2BoostHitter()
	mainmemory.write_u16_le(0x063B, mainmemory.read_u16_le(0x063B) + 128);
end

function P2DropHitter()
	mainmemory.write_u16_le(0x063B, mainmemory.read_u16_le(0x063B) - 128);
end

function SwitchP1LHand()
	if (inningtb == 0x10) then	
		mainmemory.write_u8(0x0607, 0)
	end
	if (inningtb == 0) then
		mainmemory.write_u8(0x0627, 0)
	end
end

function SwitchP1RHand()
	if (inningtb == 0x10) then	
		mainmemory.write_u8(0x0607, 1)
	end
	if (inningtb == 0) then
		mainmemory.write_u8(0x0627, 1)
	end
end

function SwitchP2LHand()
	if (inningtb == 0x0) then	
		mainmemory.write_u8(0x0617, 0)
	end
	if (inningtb == 0x10) then
		mainmemory.write_u8(0x0637, 0)
	end
end

function SwitchP2RHand()
	if (inningtb == 0x0) then	
		mainmemory.write_u8(0x0617, 1)
	end
	if (inningtb == 0x10) then
		mainmemory.write_u8(0x0637, 1)
	end
end

h_window = forms.newform(345, 205, "RBI Lua");

label_p1switch = forms.label(h_window, "Player 1", 10, 5);

label_p1switch = forms.label(h_window, "Switch Player Hand", 10, 35);
h_toggleP1L = forms.button(h_window, "Left", SwitchP1LHand, 10, 60, 50, 23);
h_toggleP1R = forms.button(h_window, "Right", SwitchP1RHand, 70, 60, 50, 23);
label_p1switch = forms.label(h_window, "Batter Power", 10, 100);
h_toggleP1R = forms.button(h_window, "More!", P1BoostHitter, 10, 125, 50, 23);
h_toggleP1R = forms.button(h_window, "Less", P1DropHitter, 70, 125, 50, 23);

label_p2switch = forms.label(h_window, "Player 2", 160, 5);
label_p2switch = forms.label(h_window, "Switch Player Hand", 160, 35);
h_toggleP2L = forms.button(h_window, "Left", SwitchP2LHand, 160, 60, 50, 23);
h_toggleP2R = forms.button(h_window, "Right", SwitchP2RHand, 160, 60, 50, 23);
label_p2switch = forms.label(h_window, "Batter Power", 160, 100);
h_toggleP2R = forms.button(h_window, "More!", P2BoostHitter, 160, 125, 50, 23);
h_toggleP2R = forms.button(h_window, "Less", P2DropHitter, 220, 125, 50, 23);




while true do

mainmemory.write_u8(0x0726, 0)	--Turn of inning music
mainmemory.write_u8(0x0727, 0)
mainmemory.write_u8(0x0728, 0)
mainmemory.write_u8(0x0729, 0)

inningtb = mainmemory.read_u8(topinningAddr);
i = input.get();

--Switch P1 batter hands
if (i.K == true) then
	SwitchP1LHand()
end
	
if (i.L == true) then
	SwitchP1RHand();
end

--Switch P2 batter hands
if (i.H == true) then
	SwitchP2LHand();
end
	
if (i.J == true) then
	SwitchP2RHand();
end
	
PitchingScreen = mainmemory.read_u8(PitchingScreenAddr);

-------------------------------------------------------
if (PitchingScreen == 0x003E) then


pitchtype = mainmemory.read_u8(pitchtypeAddr);

--What the pitcher will pitch
if (pitchtype == 0) then
	gui.text(0,0,"Sinker!!", null, null, "bottomright");
end
if (pitchtype == 2) then
	gui.text(0,0, "Fast Ball", null, null, "bottomright")
end
if (pitchtype == 1) then
	gui.text(0,0,"Regular Pitch", null, null, "bottomright")
end

--Top of Inning
if (inningtb == 0) then
	gui.text(0,0, "Health    " .. mainmemory.read_u8(0x061D), null, null, "topright")
	gui.text(0,12,"Drop     " .. mainmemory.read_u8(0x0617) % 16, null, null, "topright")
	gui.text(0,24,"CurveL " .. mainmemory.read_u8(0x061C) / 16, null, null, "topright")
	gui.text(0,36,"CurveR     " .. mainmemory.read_u8(0x061C) % 16, null, null, "topright")
	gui.text(0,48,"Fast SP   " .. mainmemory.read_u8(0x061B), null, null, "topright")
	gui.text(0,60,"Reg  SP   " .. mainmemory.read_u8(0x061A), null, null, "topright")
	gui.text(0,72,"Sink SP   " .. mainmemory.read_u8(0x0619), null, null, "topright")
	
	P1currPower = mainmemory.read_u8(P1currHitterPowerAddr) + (mainmemory.read_u8(P1currHitterPowerAddr+1) * 256);
	gui.text(0,108, "Power: " .. P1currPower, null, null, "topright");
	P1currSpeed = mainmemory.read_u8(P1currSpeedAddr);
	gui.text(0,120, "Speed: " .. P1currSpeed, null, null, "topright");
	P1currCt = mainmemory.read_u8(P1currContactAddr);
	gui.text(0,132, "Contact: " .. P1currCt, null, null, "topright");
end

--Bottom of Inning
if (inningtb == 0x10) then
	gui.text(0,0,"Health   " .. mainmemory.read_u8(0x060D), null, null, "topright")
	gui.text(0,12,"Drop    " .. mainmemory.read_u8(0x0607) % 16, null, null, "topright")
	gui.text(0,24,"CurveL " .. mainmemory.read_u8(0x060C) / 16, null, null, "topright")
	gui.text(0,36,"CurveR   " .. mainmemory.read_u8(0x060C) % 16, null, null, "topright")
	gui.text(0,48,"Fast SP  " .. mainmemory.read_u8(0x060B), null, null, "topright")
	gui.text(0,60,"Reg  SP  " .. mainmemory.read_u8(0x060A), null, null, "topright")
	gui.text(0,72,"Sink SP  " .. mainmemory.read_u8(0x0609), null, null, "topright")

	P2currPower = mainmemory.read_u8(P2currHitterPowerAddr) + (mainmemory.read_u8(P2currHitterPowerAddr+1) * 256);
	gui.text(0,108, "Power: " .. P2currPower, null, null, "topright");
	P2currSpeed = mainmemory.read_u8(P2currSpeedAddr);
	gui.text(0,120, "Speed: " .. P2currSpeed, null, null, "topright");
	P2currCt = mainmemory.read_u8(P2currContactAddr);
	gui.text(0,132, "Contact: " .. P2currCt, null, null, "topright");
end

end
-------------------------------------------------------

if (PitchingScreen == 0x0036) then

p1Outs = mainmemory.read_u8(p1OutsAddr);
gui.text(0,0, "Outs " .. p1Outs, null, null, "topright");

end
-------------------------------------------------------

emu.frameadvance()

end