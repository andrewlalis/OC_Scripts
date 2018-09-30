# movescript.lua
A more convenient way to move a robot.

## Pastebin
[4c2AN8Jw](https://pastebin.com/4c2AN8Jw)

## Module Requirements
*None*

## Instructions
Simply run `pastebin get 4c2AN8Jw /home/lib/movescript` to install movescript to the local computer. Then you can begin writing movescripts to tell your robots how to move. For example:

```
local ms = require("movescript")

local my_script = "FFURFFL"
ms.execute(my_script)
```

The above code will make the robot move forward twice, then up once, then turn right, then move forward twice, and finally turn left.

It is also possible to specify the amount of times to perform an action, by giving an integer value before the character for the movement you want. For example:

```
local my_long_script = "10D2R5B3U"
ms.execute(my_long_script)
```