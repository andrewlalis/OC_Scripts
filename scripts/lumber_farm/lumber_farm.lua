--[[
Author: Andrew Lalis
File: lumber_farm.lua
Version: 1.0
Last Modified: 30-09-2018
   
Description:
This script will automate the farming of large spruce trees, and manages an
array of 2x2 trees which it will replant and collect the saplings of.

The robot should be given an 'unbreakable' tool with 5 reinforced upgrades.
--]]

--Require statements and componenent definitions.
local robot = require("robot")
local component = require("component")
local ms = require("movescript")
local tractor_beam = component.tractor_beam
local ic = component.inventory_controller

local move_to_start = "5F"
local return_from_start = "5B"

local ROWS = 3
local COLS = 2
local TREE_SPACING = 3
local DELAY = 15

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
Uses the tractor_beam module to repeatedly pick up items until there are no 
more to pick up.
--]]
local function pickupItems()
	local success = tractor_beam.suck()
	while success do
		success = tractor_beam.suck()
	end
end

--[[
Uses the robot's axe to chop a tree, and quits if the lumber axe provided has
less than 10% durability.
return - integer: 1 if the tree was chopped, 0 otherwise.
--]]
local function chopTree()
	if (isTreeGrown()) then
		local durability = robot.durability()
		while (durability == nil) or (durability < 0.1) do
			print("Please ensure that a lumber axe with at least 10% durability is equipped in the tool slot, and press enter.")
			io.read()
			durability = robot.durability()
		end
		ms.execute("SF")
		os.sleep(1)
		pickupItems()
		ms.execute("B")
		return 1
	end
	return 0
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
	--Pick up any remaining items.
	pickupItems()
	local success, str = robot.detect()
	if (success and (str == "passable" or str == "solid" or str == "replaceable")) then
		return
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
Collects items from an array of trees.
--]]
local function collectItems(rows, cols)
	doForEachTree(rows, cols, pickupItems)
end

--[[
Plants saplings for the array of trees.
--]]
local function plantSaplings(rows, cols)
	local saplings_needed = TREES_CHOPPED * 4
	if (getItemCount(SAPLING_NAME, SAPLING_DATA) < saplings_needed) then
		print("Not enough saplings. Needed: "..saplings_needed..". Add some and press ENTER.")
		io.read()
	end
	doForEachTree(rows, cols, plantTree)
	TREES_CHOPPED = 0
end

--[[
Deposits all items into a chest below the robot.
--]]
local function depositItems()
	for i=1,16 do
		robot.select(i)
		robot.dropDown()
	end
	robot.select(1)
end

chopOrchard(ROWS, COLS)
depositItems()
print("Orchard chopped. Waiting 2.5 min before collecting saplings...")
for i=1,(DELAY) do
	os.sleep(10)
	print(i*10)
end
collectItems(ROWS, COLS)
plantSaplings(ROWS, COLS)
depositItems()
