--[[
Author: Andrew Lalis
File: movescript.lua
Version: 1.0
Last Modified: 27-09-2018
   
Description:
This library enables string representation of robot movement, for easier
robotic control without repeating functions many times.
--]]

local r = require("robot")

local movescript = {}

local functionMap = {
	["U"] = r.up,
	["D"] = r.down,
	["L"] = r.turnLeft,
	["R"] = r.turnRight,
	["F"] = r.forward,
	["B"] = r.back
}

--[[
Executes a single instruction once.
c - character: One uppercase character to translate into movement.
--]]
local function executeChar(c)
	local f = functionMap[c]
	if (f == nil) then
		return
	end
	local success = f()
	while (not success) do
		success = f()
	end
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
	while (script ~= nil and script ~= "") do
		-- Matches the next instruction, possibly prefixed by an integer value.
		local next_instruction = string.match(script, "%d*%u")
		executeInstruction(next_instruction)
		script = string.sub(script, string.len(next_instruction) + 1)
	end
end

return movescript