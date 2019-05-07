#!/usr/bin/env bash

# Executes minify program on all lua scripts in the repo.

find . -name "*.lua" | lua minify.lua minify

for i in *.lua; do
	echo "$i";
	lua minify.lua minify "$i" > "min_$i"
done