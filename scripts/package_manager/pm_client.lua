local component = require("component")
local event = require("event")
local modem = component.modem

local PORT = 80
local PROTOCOL = "pm"

local function initialize()
    modem.open(PORT)
    print("Initialized pm_client on port " .. PORT)
end

-- Main Program Script
local action = arg[1]
if action == nil then
    print("No action specified.")
end
