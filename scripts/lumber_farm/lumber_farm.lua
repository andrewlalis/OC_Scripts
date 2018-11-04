--[[
Author: Andrew Lalis
File: lumber_farm.lua
Version: 2.0
Last Modified: 04-11-2018
   
Description:
This script will automate the farming of large spruce trees, and will chop and
replant them, but not pick up items, since there are many mod items available
which can do this more efficiently.

The robot should be given an 'unbreakable' tool with 5 reinforced upgrades.
--]]

--Require statements and componenent definitions.
local robot = require("robot")
local component = require("component")
local ms = require("movescript")
local ic = component.inventory_controller

local move_to_start = "5F"
local return_from_start = "5B"

local ROWS = 3
local COLS = 2
local TREE_SPACING = 3

-- Global counter.
local TREES_CHOPPED = 0

--Runtime Constants defined for this robot.
local SAPLING_NAME = "minecraft:sapling"
local SAPLING_DATA = 1

--[[
Select an item, given its name and damage value.
item_name - string: The id string for an item.
item_data - number: The damage value, or variation of an item. Defaults to zero.
min_count - number: The minimum number of items to have.
return - boolean: True if at least one slot contains the item. That slot is now
selected.
--]]
local function selectItemByName(item_name, item_data, min_count)
	for i=1,16 do
		local stack = ic.getStackInInternalSlot(i)
		if (stack ~= nil and stack.name == item_name and stack.damage == item_data and stack.size >= min_count) then
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
min_count - number: The minimum number of items to have.
--]]
local function selectSafely(item_name, item_data, min_count)
	local success = selectItemByName(item_name, item_data, min_count)
	while not success do
		print("Cannot find "..min_count.."x "..item_name.." in inventory. Please add some, and press enter.")
		io.read()
		success = selectItemByName(item_name, item_data, min_count)
	end
end

--[[
Gets the total number of items with the given data.
item_name - string: The id string for an item.
item_data - number: The damage value, or variation of an item. Defaults to zero.
--]]
local function getItemCount(item_name, item_data)
	local count = 0
	for i=1,16 do
		local stack = ic.getStackInInternalSlot(i)
		if (stack ~= nil and stack.name == item_name and stack.damage == item_data) then
			count = count + stack.size
		end
	end
	return count
end

--[[
return - bool: True if the tree is grown, false otherwise.
--]]
local function isTreeGrown()
	local success, str = robot.detect()
	return (success and str == "solid")
end

--[[
Plants a sapling, and if it can't place one at first, loops until it is 
possible. Assumes the robot is at the starting position:
OO
OO
R
Where O=dirt, R=robot.
--]]
local function plantTree()
	local success, str = robot.detect()
	if (success and (str == "passable" or str == "solid" or str == "replaceable")) then
		return
	end
	local saplings_needed = 4
	if (getItemCount(SAPLING_NAME, SAPLING_DATA) < saplings_needed) then
		print("Not enough saplings. Needed: "..saplings_needed..". Add some and press ENTER.")
		io.read()
	end
	selectSafely(SAPLING_NAME, SAPLING_DATA, 1)
	ms.execute("2FRP")
	selectSafely(SAPLING_NAME, SAPLING_DATA, 1)
	ms.execute("LBP")
	selectSafely(SAPLING_NAME, SAPLING_DATA, 1)
	ms.execute("RP")
	selectSafely(SAPLING_NAME, SAPLING_DATA, 1)
	ms.execute("LBP")
end

--[[
Uses the robot's axe to chop a tree, and quits if the lumber axe provided has
less than 10% durability.
return - integer: 1 if the tree was chopped, 0 otherwise.
--]]
local function chopTree()
	if (isTreeGrown()) then
		ms.execute("S")
		plantTree()
		return 1
	end
	return 0
end

--[[
Moves to the next tree in a row.
current_col - integer: The current column.
col_count - integer: The total number of columns.
--]]
local function moveToNextTree(current_col, col_count)
	if (current_col < col_count) then
		ms.execute("d_LFR3FRFL"..(TREE_SPACING - 1).."F")
	end
end

--[[
Moves to the next row.
current_row - integer: The row that was just finished.
row_count - integer: The total number of rows.
col_count - integer: The total number of columns.
--]]
local function moveToNextRow(current_row, row_count, col_count)
	local script = "d_LFL"..((TREE_SPACING + 2) * (col_count - 1)).."FLF"
	if (current_row < row_count) then
		script = script..(TREE_SPACING + 2).."FL"
	else
		script = script.."L"
	end
	ms.execute(script)
end

--[[
Moves back to the start of the orchard.
row_count - integer: The total number of rows.
--]]
local function moveToOrchardStart(row_count)
	ms.execute("d_L"..((TREE_SPACING + 2) * (row_count - 1)).."FR")
end

--[[
Performs a function at each tree in the orchard.
rows - integer: The total number of rows.
cols - integer: The total number of columns.
func - function: The function to execute at each position.
--]]
local function doForEachTree(rows, cols, func)
	ms.execute(move_to_start)
	for i=1,rows do
		for k=1,cols do
			func()
			moveToNextTree(k, cols)
		end
		moveToNextRow(i, rows, cols)
	end
	moveToOrchardStart(rows)
	ms.execute(return_from_start)
end

--[[
Chops an array of trees. The robot starts facing the first row.
--]]
local function chopOrchard(rows, cols)
	doForEachTree(rows, cols, chopTree)
end

--[[
Reads any given arguments and uses them for program constants instead of
default values.
args - table: the arguments passed to the program.
--]]
local function getSettingsFromArgs(args)
	ROWS = tonumber(args[1])
	COLS = tonumber(args[2])
	TREE_SPACING = tonumber(args[3])
	move_to_start = args[4]
	return_from_start = args[5]
end

local args = {...}
if (#args == 5) then
	getSettingsFromArgs(args)
end

chopOrchard(ROWS, COLS)
