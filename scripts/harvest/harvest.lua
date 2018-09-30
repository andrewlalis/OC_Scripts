-- Harvest Program for robots. Uses a hoe and geolyzer for optimal harvesting.
--[[
Author: Andrew Lalis
File: harvest.lua
Version: 1.0
Last Modified: 27-09-2018
   
Description:
This script enables a robot to harvest fields of crops quickly and efficiently.
The robot will traverse the field and only harvest crops considered 'done' by
their crop definition.
--]]

local robot = require("robot")
local component = require("component")
local fs = component.filesystem
local serial = require("serialization")
local geolyzer = component.geolyzer
local ic = component.inventory_controller
local sides = require("sides")

local CONFIG_FILE = "harvest.conf"

local LEFT = 1
local RIGHT = 0

-- List of crops which will be harvested.
local crop_definitions = {}

-- Repeats the given function until it returns true.
local function doUntilSuccess(func)
	local success = func()
	while (not success) do
		success = func()
	end
end

-- Pre-defined path from turtle docking bay to start of harvest area (first crop).
local function goToStart(rows, columns)
	doUntilSuccess(robot.forward)
end

-- Pre-defined path back to the turtle docking bay.
local function goBack(rows, columns)
	for i=1,(columns-1) do
		doUntilSuccess(robot.back)
	end
	robot.turnRight()
	for i=1,(rows-1) do
		doUntilSuccess(robot.back)
	end
	robot.turnLeft()
	doUntilSuccess(robot.back)
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
Checks if the hoe is equipped. Meant to be done before starting a harvest.
return - boolean: True if a hoe is equipped, or false if not.
--]]
local function isHoeEquipped()
	for i=1,16 do
		local item_stack = ic.getStackInInternalSlot(i)
		if (item_stack == nil) then
			robot.select(i)
			ic.equip()
			new_item_stack = ic.getStackInInternalSlot(i)
			if (new_item_stack ~= nil and string.match(new_item_stack.name, "_hoe")) then
				return true
			end
			return false
		end
	end
	return false
end

--[[
Tries to harvest a plant, if it is one of the crops defined in the crop
definitions table above.
return - boolean: True if a plant was harvested, false otherwise.
--]]
local function harvestPlant()
	local plant_data = geolyzer.analyze(sides.bottom)
	local crop_definition = crop_definitions[plant_data.name]
	if (crop_definition == nil) then
		return false
	end
	if (plant_data.growth >= crop_definition.growth_limit) then
		robot.swingDown()
		selectItemByName(crop_definition.item_name, 0)
		robot.placeDown()
		return true
	else
		return false
	end
end

--[[
Harvests one row of crops.
length - int: The number of plants in this row.
return - int: The number of crops that were harvested.
--]]
local function harvestRow(length)
	local harvests = 0
	for i=1,length do
		if (i > 1) then
			doUntilSuccess(robot.forward)
		end
		if (harvestPlant()) then
			harvests = harvests + 1
		end
	end
	return harvests
end

--[[
At the end of the row, the robot must rotate into the next row, and this is
dependent on where the start location is.
current_row_index - int: The row the robot is on prior to turning.
start_location - int: Whether the robot starts at the left or right.
--]]
local function turnToNextRow(current_row_index, start_location)
	if (current_row_index % 2 == start_location) then
		robot.turnRight()
	else
		robot.turnLeft()
	end
	doUntilSuccess(robot.forward)
	if (current_row_index % 2 == start_location) then
		robot.turnRight()
	else
		robot.turnLeft()
	end
end

--[[
Harvests a two dimensional area defined by rows and columns. The robot starts
by moving forward down the first row.
rows - int: The number of rows to harvest.
columns - int: The number of columns to harvest.
start_location - int: 1 for LEFT, 0 for RIGHT.
return - int: The total number of crops harvested.
--]]
local function harvestField(rows, columns, start_location)
	goToStart(rows, columns)
	-- Begin harvesting.
	robot.select(1)
	local harvests = 0
	for i=1,rows do
		harvests = harvests + harvestRow(columns)
		-- Do not turn to the next row on the last row.
		if (i < rows) then
			turnToNextRow(i, start_location)
		end
	end
	goBack(rows, columns)
	return harvests
end

--[[
Drops all carried items into an inventory below the robot.
return - int: The number of items dropped.
--]]
local function dropItems()
	local item_count = 0
	for i=1,16 do
		robot.select(i)
		local stack = ic.getStackInInternalSlot(i)
		if (stack ~= nil) then
			doUntilSuccess(robot.dropDown)
			item_count = item_count + stack.size
		end
	end
	return item_count
end

--[[
Reads config from a file.
filename - string: The string path/filename.
return - table|nil: The table defined in config, or nil if the file does not
exist or another error occurs.
--]]
local function loadConfig(filename)
	-- Config file exists.
	local f = io.open(filename, "r")
	if (f == nil) then
		print("No config file " .. filename .. " exists. Please create it before continuing.")
		return nil
	end
	local t = serial.unserialize(f:read())
	f:close()
	return t
end

--[[
Guides the user in creating a new config.
return - table: The config created.
--]]
local function createConfig(filename)
	local config = {}
	print("Does your robot start on the left or right of the field?")
	local input = io.read()
	if (input == "left") then
		config.START_LOCATION_RELATIVE = LEFT
	elseif (input == "right") then
		config.START_LOCATION_RELATIVE = RIGHT
	else
		print("Invalid choice. Should be either left or right.")
		return nil
	end
	print("Enter number of rows.")
	config.ROWS = tonumber(io.read())
	print("Enter number of columns.")
	config.COLS = tonumber(io.read())

	print("How many crops are being harvested?")
	config.crop_definitions = {}
	for i=1,tonumber(io.read()) do
		print("Crop "..i..": What is the block name? (Use geolyzer to analyze it)")
		local name = io.read()
		config.crop_definitions[name] = {}
		print("  What is the growth threshold for harvesting?")
		config.crop_definitions[name].growth_limit = tonumber(io.read())
		print("  What is the item name of this crop?")
		config.crop_definitions[name].item_name = io.read()
	end
	file = io.open(filename, "w")
	file:write(serial.serialize(config))
	file:close()
	return config
end

local function main()
	local config = loadConfig(CONFIG_FILE)
	if (config == nil) then
		config = createConfig(CONFIG_FILE)
	end
	crop_definitions = config.crop_definitions
	local harvest_count = harvestField(config.ROWS, config.COLS, config.START_LOCATION_RELATIVE)
	local drop_count = dropItems()
	print(harvest_count..", "..drop_count)
end

main()