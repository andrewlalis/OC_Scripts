--[[
Author: Andrew Lalis
File: train_speed_checkpoint.lua
Version: 1.0
Last Modified: 16-06-2018
   
Script used for helping to control the speed of a train. Use many
computers running this script to calibrate trains to run at a certain speed.
--]]

--Require statements and component definitions.
local component = require("component")
local event = require("event")
local computer = require("computer")
local term = require("term")
local detector = component.ir_augment_detector
local controller = component.ir_augment_control

-- Optimal Speed.
local DESIRED_SPEED = 20

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
local function isStockLocomotive(id)
	return strStarts(id, "rolling_stock/loc")
end

local function balanceSpeed(info, target_speed)
	local diff = target_speed - info.speed
	local percent_diff = info.speed / target_speed
	if diff > 0 then -- We are too slow.
		controller.setBrake(0)
		controller.setThrottle(info.throttle + percent_diff)
	else -- We are too fast.
		controller.setThrottle(0)
		controller.setBrake(percent_diff)
	end
end

local function handleTrainEvent(net_address, augment_type, stock_uuid)
	local info = detector.info()
	local data = detector.consist()
	if not (data and info and isStockLocomotive(info.id)) then
		return
	end
	if (augment_type == "DETECTOR") then
		term.clear()
		term.setCursor(1, 1)
		term.write("  Speed: "..data.speed_km.." Km/h")
		term.write("  Dir: "..data.direction)
		term.write("  Weight: "..data.weight_kg.." Kg")
	end
	if (augment_type == "LOCO_CONTROL") then
		balanceSpeed(info, DESIRED_SPEED)
	end
end

while true do
	pullTrainEvent(handleTrainEvent)
end