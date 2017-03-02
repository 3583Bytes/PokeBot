# PokéBot

An automated computer program that speedruns Pokémon generation 1 games.

Pokémon Red (Any% Glitchless) personal best runs:

* [1:50:38] Seed: 1487686641
* [1:52:19] Seed: 1484656815
* [1:52:48] Seed: 1487361908
* [1:52:26] Seed: 1487932824
* [1:52:59] Seed: 1484210277

## Watch live

### [twitch.tv/therealpokemaniak](https://www.twitch.tv/therealpokemaniak/)

My 24/7 streaming channel on Twitch 

### Run the bot locally

Follow this tutorial by Monk Preston : [Click here](http://imgur.com/a/cbHWb)

## Seeds

PokéBot comes with a built-in feature that takes advantage of random number seeding to reproduce runs in their entirety. Any time the bot resets or beats the game, it will log a number to the Lua console that is the seed for the run. If you set `CUSTOM_SEED` in `main.lua` to that number, the bot will reproduce your run.  Note that making any other modifications will prevent this from working. So if you want to make changes to the bot and share your time, be sure to fork the repo and push your changes.

## Credits


Kyle Coburn: Original concept, Red/Yellow routing (GitHub Seems to be no longer available)

[jonese1234](https://github.com/jonese1234/PokeBotBad): Updated Version works with Bizhawk version higher than 1.6

