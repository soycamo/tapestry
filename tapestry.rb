#!/usr/bin/env ruby 
# 
# camo wrote this code
# it is MIT licensed
# if you use this and you're a jerk 
# you will probably get mal de ojo
#

require './lib/kamishibai'

# Not sure if I want to handle file, directory or *gulp*
# A WINDOWS EXECUTABLE PACKAGE. i cry e'ery nite
gamefile = ARGV[0] 
Kamishibai.new(gamefile).export
