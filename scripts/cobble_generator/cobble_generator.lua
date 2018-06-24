--[[
Author: Andrew Lalis
File: cobble_generator.lua
Version: 1.0
Last Modified: 24-06-2018
   
Description:
This script makes a robot operate a square cobble generator, in the setup below

0CO
CRC
OC0
	Where 0 = lava, O = water, C = cobble, and R = robot.

The items gathered will be dropped below the robot, into a hopper or chest.

--]]

--Require statements and componenent definitions.
local robot = require("robot")

--Global variables:
local cyclesPerformed = 0

--[[
Mines one block of cobble, checking for a proper tool first.
--]]
local function mineCobble()
	local dur = robot.durability()
	while not dur do
		print("No valid tool. Please place one in the tool slot and press enter.")
		io.read()
		dur = robot.durability()
	end
	robot.swing()
end

--[[
Performs one cycle of cobblestone harvesting. Will check if it has a tool.
--]]
local function cycle()
	for i=1,4 do
		mineCobble()
		robot.turnRight()
	end
	robot.dropDown()
	print("Cycles done: "..cyclesPerformed)
	cyclesPerformed = cyclesPerformed + 1
end

--[[
Main function in which the iterations of the cycle are performed.
--]]
local function main()
	print("# Andrew's Cobblestone Generator #")
	print("# Copyright 2018 Andrew Lalis    #")
	print("#--------------------------------#")
	print("Please enter the number of cycles to perform, or -1 to continue forever.")
	local choice = tonumber(io.read())
	if (choice == nil or choice == -1) then
		print("Beginning infinite cycles.")
		while true do
			cycle()
		end
	else
		print("Beginning "..choice.." cycles.")
		for i=1,choice do
			cycle()
		end
	end
	print("#------Program completed.--------#")
end

main()