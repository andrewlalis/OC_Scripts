--[[
Author: Andrew Lalis
File: movescript.lua
Version: 1.0
Last Modified: 27-09-2018
   
Description:
This library enables string representation of robot movement, for easier
robotic control without repeating functions many times.

Begin a script with "d_" to tell the robot to attempt to destroy blocks in the
way of the path of movement.
--]]

local r = require("robot")

local movescript = {}

local destructive = true

local function doUntilSuccess(f)
	local success = f()
	while (not success) do
		success = f()
	end
end

local function up()
	while (destructive and r.detectUp()) do
		r.swingUp()
	end
	doUntilSuccess(r.up)
end

local function down()
	while (destructive and r.detectDown()) do
		r.swingDown()
	end
	doUntilSuccess(r.down)
end

local function forward()
	while (destructive and r.detect()) do
		r.swing()
	end
	doUntilSuccess(r.forward)
end

local function back()
	if (destructive) then
		r.turnAround()
		while (r.detect()) do
			r.swing()
		end
		r.turnAround()
	end
	doUntilSuccess(r.back)
end

local functionMap = {
	["U"] = up,
	["D"] = down,
	["L"] = r.turnLeft,
	["R"] = r.turnRight,
	["F"] = forward,
	["B"] = back,
	["P"] = r.place,
	["S"] = r.swing
}

--[[
Determines if a string starts with a certain string.
str - string: The string to check the prefix of.
start - string: The prefix to look for.
--]]
local function starts_with(str, start)
	return str:sub(1, #start) == start
end

--[[
Executes a single instruction once.
c - character: One uppercase character to translate into movement.
--]]
local function executeChar(c)
	local f = functionMap[c]
	if (f == nil) then
		return
	end
	f()
end

--[[
Executes a single instruction, such as '15D'
instruction - string: An integer followed by an uppercase character.
--]]
local function executeInstruction(instruction)
	local count = string.match(instruction, "%d+")
	local char = string.match(instruction, "%u")
	if (count == nil) then
		count = 1
	end
	if (char == nil) then
		return
	end
	for i=1,count do
		executeChar(char)
	end
end

--[[
Executes a given script.
script - string: The script to execute.
--]]
function movescript.execute(script)
	if (starts_with(script, "d_")) then
		destructive = true
		script = string.sub(script, 3)
	else
		destructive = false
	end
	while (script ~= nil and script ~= "") do
		-- Matches the next instruction, possibly prefixed by an integer value.
		local next_instruction = string.match(script, "%d*%u")
		executeInstruction(next_instruction)
		script = string.sub(script, string.len(next_instruction) + 1)
	end
end

return movescript