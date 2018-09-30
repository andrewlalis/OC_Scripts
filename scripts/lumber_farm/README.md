# lumber_farm.lua
Automatically chop an array of spruce trees.

## Pastebin
[dB0XwcAY](https://pastebin.com/dB0XwcAY)

## Module Requirements
* tractor_beam
* inventory_controller
* movescript library [4c2AN8Jw](https://pastebin.com/4c2AN8Jw)
* A lumber axe of obscenely high durability, or unbreakable.

## Instructions
First, install *movescript* to `/lib/movescript.lua`.

Then, download this script, and `edit` the downloaded file to set some constants.

*  `ROWS`: The number of rows in the farm.
*  `COLS`: The number of columns in the farm.
*  `TREE_SPACING`: The number of blocks between trees.
*  `DELAY`: The time, in tens of seconds, to wait between chopping and picking up items.
*  `move_to_start`: A *movescript* describing how to get from the robot's base station to the first tree.
*  `return_from_start`: A *movescript* describing how to get back to the robot's base station from the first tree. Should usually be the opposite of `move_to_start`.

Make sure you have a very powerful lumber axe, or one which is unbreakable, and give it to the robot.

### Farm Setup
The construction of the farm should be as follows:

```
  R-1   R-2   R-3
| [T] | [T] | [T] | Column 1
| [T] | [T] | [T] | Column 2
| [T] | [T] | [T] | Column 3
| [T] | [T] | [T] | Column 4
   X
```

Where `[T]` denotes a 2x2 tree, `X` denotes the starting location for the robot.

Each tree should be separated from those adjacent to it by `TREE_SPACING` blocks.