# TreeFarm.lua
Robot script for automatic chopping of trees, given a lumber axe, bonemeal, and saplings.

## Pastebin
[mRTULKY0](https://pastebin.com/mRTULKY0)

## Module Requirements
* tractor_beam
* inventory_controller

## Instructions
To operate this program, simply execute it, and it will prompt the user to decide if they wish to choose a number of trees to chop, or `-1` for chopping until out of resources. The robot will stop if its axe has less than 10% durability, it runs out of bonemeal, or runs out of saplings.