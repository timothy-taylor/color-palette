-- Color Mixer - Core Includes
-- Basic page system + LFO engine

engine.name = "PolyPerc"

-- Core norns libraries
Util = require("util")
MusicUtil = require("musicutil")
Lfo = require("lib/lfo")
Graph = require("lib/graph")

-- LFO shapes
LFO_SHAPES = {
    "sine",
    "triangle",
    "saw",
    "square",
    "random",
    "noise"
}

-- Global application state
State = {
    screen_dirty = true,
    lfo_a_value = 0,
    lfo_b_value = 0,
    combined_lfo_value = 0
}

-- Color Mixer modules
PageManager = include("lib/page_manager")
LfoEngine = include("lib/lfo_engine")