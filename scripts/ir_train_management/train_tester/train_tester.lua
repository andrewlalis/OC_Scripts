--[[
Author: Andrew Lalis
File: train_tester.lua
Version: 1.0
Last Modified: 15-06-2018
   
Script used to get experimental values for train stopping distance, 
acceleration, and other properties that would otherwise be difficult to
determine with just the information gained from reading a detector.
--]]

--Require statements and component definitions.
local component = require("component")
local event = require("event")
local computer = require("computer")
local detector = component.ir_augment_detector
local controller = component.ir_augment_control

local BRAKE_ENABLED = false

--[[
Shortcut for pulling only train events.
func - function(net_address, augment_type, stock_uuid): function to handle the
train event, with augment type being either DETECTOR or LOCO_CONTROL.
--]]
local function pullTrainEvent(func)
	local event_name, net_address, augment_type, stock_uuid = event.pull("ir_train_overhead")
	func(net_address, augment_type, stock_uuid)
end

--[[
Determines if a string starts with a given substring.
return - boolean: true if str starts with start, false otherwise.
--]]
local function strStarts(str, start)
	return string.sub(str, 1, string.len(start)) == start
end

--[[
Determines if a stock car over the detector is a locomotive by reading info.id
from the detector's info() method. If it begins with rolling_stock/loc, then 
it is a locomotive.
--]]
local function isStockLocomotive()
	local info = detector.info()
	return strStarts(info.id, "rolling_stock/loc")
end

--[[
Main function to perform test. Currently configured to determine the distance
needed to stop a train. It does this by waiting for a train to go over the
detector, and then applies full brakes, idle throttle, and the train will slow
to a halt. It also records the current time at which the locomotive was 
detected, and some other information that is of use.
net_address - string: the network address of the adapter for the augment.
augment_type - string: either DETECTOR or LOCO_CONTROL.
stock_uuid - string: the unique id of the stock detected.
--]]
local function handleTrainEvent(net_address, augment_type, stock_uuid)
	if (augment_type == "DETECTOR") then
		local data = detector.consist()
		-- Only if there's data, and this is a locomotive, do we continue.
		if (data == nil  or not isStockLocomotive()) then
			return
		end
		print("Locomotive Data from: "..net_address)
		print("  Speed: "..data.speed_km.." Km/h")
		print("  Direction: "..data.direction)
		print("  Weight: "..data.weight_kg.." Kg")
		print("  Tractive Effort: "..data.tractive_effort_N.." N")
		print("  Cars: "..data.cars)
		print("  TIME: "..os.time())
	end
	-- In the case that the train is over the control augment, apply changes to locomotive control.
	-- Also sound horn.
	if (augment_type == "LOCO_CONTROL" and BRAKE_ENABLED) then
		controller.setThrottle(0)
		controller.setBrake(1)
		controller.horn()
	end
end

while true do
	pullTrainEvent(handleTrainEvent)
end