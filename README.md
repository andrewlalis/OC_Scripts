# OC_Scripts
Collection of Lua and Javascript scripts for computers from the OpenComputers mod.

In this repository, you'll find the `lib` folder, containing all files which supplement the main programs, which can be found in `scripts`. Although I make every effort to keep my code readable and self-documenting, a `README.md` exists in each script's sub-directory which provides an overview of the module, and a short documentation of the methods used.

For suggestions, comments, or to report bugs, please use the GitHub's **issues** tab up above, and use an appropriate label for whatever it is you wish to submit an issue on.

## Bug Reporting
Although the code I write is tested extensively, bugs can and will continue to appear in finalized scripts. In order to minimize this, please report any bugs you find in the **issues** section, with the `bug` label.

At the very minimum, the following requirements are mandatory for submitting a bug report via an issue:
* The name of the script, along with the version number, should be included in the title of the issue.
* The `bug` label should be applied to the issue.
* A list of steps you can take to reproduce the issue.
* If the bug causes a crash, the output of the opencomputers console should be included. *You may either copy the text, or provide a screenshot.*

## Contributing
If you would like to help contribute to this collection of scripts, or simply include a change, you are free to fork the repository, add your changes, and create a pull request with either the `new feature` or `fix` label, and a detailed summary of the changes made.

### Guidelines for Contributing Code
To promote uniformity and an organized codebase, there are some guidelines to follow when writing scripts for this repository.
1. All variables and functions should be declared `local` unless required otherwise.
2. All variables should be defined using underscores. For example, ```lua local my_var = 5```
3. All function names should be defined using camelCase. For example, ```lua local myFunction()```
4. A multiline comment should appear above all functions, giving a short description of the function, and a list of all parameters, their expected types, and the return type.
5. Constants should be defined at the top of a file, in all capital characters. For example, ```lua local MY_CONSTANT = 3.14159265```
6. All `require` statements should be done at the top of the file, above all other things except the file metadata information.
7. As stated above, each file should have a metadata section, with the following format:
```lua 
--[[
Author: Andrew Lalis
File: example_script.lua
Version: 0.5.1
Last Modified: 12-06-2018

Description:
This file is an example file used for showing the setup of a typical lua script
and should be followed for every script in this repository. Note also that 
lines should be manually wrapped at 8 characters, although this is not required
for actual lines of code.
--]]
```

