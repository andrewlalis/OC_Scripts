--[[
Author: Andrew Lalis
File: TreeFarm.lua
Version: 1.0
Last Modified: 12-06-2018
   
Description:
This script lets a robot, equipped with a tractor_beam and inventory controller
module, chop trees with a Tinker's Construct lumber axe. It will automatically
stop when it runs out of saplings or bonemeal, or when its axe is close to 
breaking. It also can either chop a certain number of trees, or simply chop 
until its resources are depleted.
--]]

--Require statements and componenent definitions.
local robot = require("robot")
local component = require("component")
local tractor_beam = component.tractor_beam
local ic = component.inventory_controller

--Runtime Constants defined for this robot.
local SAPLING_NAME = "minecraft:sapling"
local SAPLING_DATA = 0
local BONEMEAL_NAME = "minecraft:dye"
local BONEMEAL_DATA = 15

--Global configuration variables.
--Flag for if program should run until out of resources.
local continuous = false

--[[
Exits the program.
--]]
local function quit()
	print("#--------------------------------#")
	print("# Tree Chopping Program exited.  #")
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
	if continuous and not success then
		print("Out of "..item_name..", exiting.")
		quit()
	end
	while not success do
		print("Cannot find "..item_name.." in inventory. Please add some, and press enter.")
		io.read()
		success = selectItemByName(item_name, item_data)
	end
end

--[[
Plants a sapling, and if it can't place one at first, loops until it is 
possible.
--]]
local function plantSapling()
	selectSafely(SAPLING_NAME, SAPLING_DATA)
	local success = robot.place()
	while not success do
		print("Unable to place the sapling. Please remove any blocks in front of the robot, and press enter.")
		io.read()
		success = robot.place()
	end
end

--[[
Repeatedly applies bonemeal to the sapling until either the sapling has grown,
or the robot runs out of bonemeal.
--]]
local function applyBonemeal()
	local success, block_type = robot.detect()
	while block_type ~= "solid" do
		selectSafely(BONEMEAL_NAME, BONEMEAL_DATA)
		robot.place()
		success, block_type = robot.detect()
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
Grows a tree by planting a sapling and applying bonemeal until it is grown.
--]]
local function growTree()
	plantSapling()
	applyBonemeal()
end

--[[
The entire cycle of the farm. Grows a tree, harvests the wood, and picks up 
the items.
--]]
local function farmTree()
	growTree()
	chopTree()
	os.sleep(2)
	pickupItems()
end

--[[
Main function in which the iterations of the cycle are performed.
--]]
local function main()
	print("# Andrew's Tree Chopping Program #")
	print("# Copyright 2018 Andrew Lalis    #")
	print("#--------------------------------#")
	print("Please enter the number of trees to chop, or -1 to chop until out of resources.")
	local choice = tonumber(io.read())
	if (choice == nil or choice == -1) then
		continuous = true
		print("  Chopping trees until out of resources.")
		while continuous do
			farmTree()
		end
	else
		print("  Chopping "..choice.." trees.")
		for i=1,choice do
			farmTree()
		end
	end
	quit()
end

main()