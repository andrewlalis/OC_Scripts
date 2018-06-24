# cobble_generator.lua
Robot script for generating cobblestone on a square 4-block generator, as shown below:

```
Top Layer:
 OOO				O = Glass
OLSWO				L = Lava source
OS SO				W = Water source
OWSLO				S = Sign
 OOO				R = Robot
 					C = Cobblestone
 Second layer:
 OOO
O C O
OCRCO
O C O
 OOO
```

The robot will rotate and mine each cobblestone block in sequence, and drop its harvest to the block below it.

## Pastebin
[52ZtDZF1](https://pastebin.com/52ZtDZF1)

## Module Requirements
None

## Instructions
To operate this program, simply execute it, and choose either to run infinitely, or for a set number of cycles. If infinite cycles are chosen, then be sure to check back once in a while, because the tool the robot uses may run out, in which case it will stop until a new tool is added.