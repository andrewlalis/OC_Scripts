--Robotic Tree Farmer
-- Copyright 2018 Andrew Lalis. All rights reserved.

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

--Exit the program.
local function quit()
	print("#--------------------------------#")
	print("# Tree Chopping Program exited.  #")
	os.exit()
end

--Select a slot containing the specified item.
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

--Select a slot with an item, and if it can't be found, ask the user to add it.
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

--Plants a sapling.
local function plantSapling()
	selectSafely(SAPLING_NAME, SAPLING_DATA)
	local success = robot.place()
	while not success do
		print("Unable to place the sapling. Please remove any blocks in front of the robot, and press enter.")
		io.read()
		success = robot.place()
	end
end

--Repeatedly applies bonemeal until a tree has grown.
local function applyBonemeal()
	local success, block_type = robot.detect()
	while block_type ~= "solid" do
		selectSafely(BONEMEAL_NAME, BONEMEAL_DATA)
		robot.place()
		success, block_type = robot.detect()
	end
end

--Chops a tree, first checking the status of the tool.
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

--Uses the tractor_beam component to pick up nearby items.
local function pickupItems()
	local success = tractor_beam.suck()
	while success do
		success = tractor_beam.suck()
	end
end

local function growTree()
	plantSapling()
	applyBonemeal()
end

local function farmTree()
	growTree()
	chopTree()
	os.sleep(2)
	pickupItems()
end

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