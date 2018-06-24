--[[
Author: Andrew Lalis
File: ir_train_control.lua
Version: 1.0
Last Modified: 12-06-2018

Description:
Library which simplifies functions that are often used with immersive railroads
trains and their track augments.
--]]

local ir_train_control = {}

--Require statements and component definitions.
local component = require("component")
local detector = component.ir_augment_detector
local controller = component.ir_augment_control

--[[
Pulls the ir_train_overhead event, and passes the results to a function defined
elsewhere.
func - function(net_address, augment_type, stock_uuid): Function to handle 
pulled events.
--]]
local function ir_train_control.pullTrainEvent(func)
	local event_name, net_address, augment_type, stock_uuid = event.pull("ir_train_overhead")
	func(net_address, augment_type, stock_uuid)
end


local function ir_train_control.
