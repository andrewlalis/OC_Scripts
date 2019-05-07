-- Main Program Script
local action = arg[1]
if action == nil then
    print("No action specified.")
    os.exit()
end

print("You entered the action: " .. action)
