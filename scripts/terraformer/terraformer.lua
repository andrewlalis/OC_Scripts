--[[
Author: Andrew Lalis
File: terraformer.lua
Version: 1.0
Last Modified: 16-06-2018
   
Description:
This script enables a robot to make drastic, albeit slow, changes to the 
terrain of an area, through several sub-functions, such as flattening, filling,
and removal of trees. 
--]]

--Require statements and componenent definitions.
local robot = require("robot")
local component = require("component")
local ic = component.inventory_controller

--Runtime Constants defined for this robot.
local SAPLING_NAME = "minecraft:sapling"
local SAPLING_DATA = 0
local BONEMEAL_NAME = "minecraft:dye"
local BONEMEAL_DATA = 15

--Global configuration variables.

--[[
Exits the program.
--]]
local function quit()
	print("#--------------------------------#")
	print("# Program exited.                #")
	os.exit()
end

--[[
Select an item, given its name and damage value.
item_name - string: The id string for an item.
item_data - number: The damage value, or variation of an item. Defaults to zero.
return - boolean: True if at least one slot contains the item. That slot is now
selected.
--]]
local function selectItemByName(item_name, item_data)
	for i=1,16 do
		local stack = ic.getStackInInternalSlot(i)
		if (stack ~= nil and stack.name == item_name and stack.damage == item_data) then
			robot.select(i)
			return true
		end
	end
	return false
end

--[[
Select an item, similar to selectItemByName, but if the item cannot be found,
the user will be prompted to add it to the robot's inventory and press enter to
continue.
item_name - string: The id string for an item.
item_data - number: The damage value, or variation of an item. Defaults to zero.
return - nil: If set to be continuous, then if the item cannot be found, then
the program will exit. If not, it will loop until the item is provided by the 
user.
--]]
local function selectSafely(item_name, item_data)
	local success = selectItemByName(item_name, item_data)
	while not success do
		print("Cannot find "..item_name.." in inventory. Please add some, and press enter.")
		io.read()
		success = selectItemByName(item_name, item_data)
	end
end

local function repeatUntilSuccess(robot_func)
	local success = robot_func()
	while not success do
		success = robot_func()
	end
end

--[[
Uses the robot's axe to chop a tree, and quits if the lumber axe provided has
less than 10% durability.
--]]
local function chopTree()
	local durability = robot.durability()
	if continuous and (durability == nil or durability < 0.1) then
		print("Inadequate tool to chop trees, exiting.")
		quit()
	end
	while (durability == nil) or (durability < 0.1) do
		print("Please ensure that a lumber axe with at least 10% durability is equipped in the tool slot, and press enter.")
		io.read()
		durability = robot.durability()
	end
	robot.swing()
end

local function ensureToolDurability()
	local n1, n2, n3 = robot.durability()
	while (n1 == nil and n2 == "no tool equipped") or (n1 < 0.01) do
		print("Please enter a valid tool with enough durability, and press enter.")
		io.read()
		n1, n2, n3 = robot.durability()
	end
end

local function safeSwing(func)
	ensureToolDurability()
	repeatUntilSuccess(func)
end

local function flattenSpot()
	-- First try to dig until it can't dig anymore.
	local displacement = 0
	while robot.detectUp() do
		safeSwing(robot.swingUp)
		repeatUntilSuccess(robot.up)
		displacement = displacement + 1
	end
	for i=1, displacement do
		repeatUntilSuccess(robot.down)
	end
	-- Then place any floor blocks if needed.
	local success, data = robot.detectDown()
	if not (success and data == "solid") then
		-- Remove any grass or other obstructions below.
		if success then
			local obstructed = success
			while obstructed do
				safeSwing(robot.swingDown)
				obstructed, data = robot.detectDown()
			end
		end
		selectSafely("minecraft:dirt", 0)
		repeatUntilSuccess(robot.placeDown)
	end
end

local function flattenArea(length, width)
	for row=1, length do
		print("Beginning row "..row.." of "..length..".")
		if (robot.detect()) then
			safeSwing(robot.swing)
		end
		repeatUntilSuccess(robot.forward)
		if (row%2) == 1 then
			robot.turnRight()
		else
			robot.turnLeft()
		end
		for col=1, width-1 do
			flattenSpot()
			if robot.detect() then
				safeSwing(robot.swing)
			end
			repeatUntilSuccess(robot.forward)
		end
		flattenSpot()
		if (row%2) == 1 then
			robot.turnLeft()
		else
			robot.turnRight()
		end
	end
end

local function getNumberInput(str, lower_bound, upper_bound)
	print(str)
	local choice = tonumber(io.read())
	while (choice == nil or choice < lower_bound or choice > upper_bound) do
		print("Invalid input! Enter a number n such that "..lower_bound.." <= n <= "..upper_bound)
		choice = tonumber(io.read())
	end
	return choice
end

local function flattenMenu()
	length = getNumberInput("Enter the length (distance forward).", 1, 256)
	width = getNumberInput("Enter the width (distance to the right).", 1, 256)
	print("Flattening a "..length.." x "..width.." area. Total of "..(length*width).." spots to flatten.")
	flattenArea(length, width)
end

local function treeRemovalMenu()
	quit()-- Implement this!
end

local function mainMenu()
	print("# Andrew's Terraformer           #")
	print("# Copyright 2018 Andrew Lalis    #")
	print("#--------------------------------#")
	print("1. Flatten")
	print("2. Remove Trees (Not yet implemented)")
	print("Please enter a number corresponding to one of the options above, or -1 to quit.")
	local choice = tonumber(io.read())
	if choice == 1 then
		flattenMenu()
	elseif choice == 2 then
		treeRemovalMenu()
	else
		quit()
	end
end

--[[
Main function in which the iterations of the cycle are performed.
--]]
local function main()
	mainMenu()
	quit()
end

main()