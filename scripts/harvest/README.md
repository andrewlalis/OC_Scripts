# harvest.lua
Script for smart harvesting of rectangular farms of multiple crops.

## Pastebin
[ytYCVGsc](https://pastebin.com/ytYCVGsc)

## Module Requirements
* geolyzer
* inventory_controller
* *equipped hoe*

## Instructions
To operate the program, you simply need to run the program. If no `harvest.conf` config file exists, the program will guide you through the creation of it. For it, you'll need the following information:

* On what side does the robot start harvesting (left or right)?
* How many rows are in the field?
* How many columns are in the field?
* What crops will be grown?

For each crop that will be grown, you will need the following pieces of information:

1. The crop's block name (can be found using the `geolyzer` component.
2. The floating point value at which the crop is ready to be harvested. Can also be found with the `geolyzer`.
3. The name of the item used to replant the crop. This can be found in the minecraft inventory after pressing `F3 + H` to enable more detailed information for displayed items.

Once all this information is entered, running the program will harvest the defined area, and drop all gathered items into a chest below the robot's resting point.

### Diagram of setup
The below diagram shows how farms should be set up: the robot faces into the first row, and has a charger behind it to replenish energy after each harvest. A chest or hopper can be placed below the robot for item collection.

```
CR---------
  ---------
  ---------
  ---------
  ---------
  ---------
  ---------
  ---------
  ---------
```