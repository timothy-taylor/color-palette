-- Color Mixer - Core Includes
-- Basic page system + LFO engine

engine.name = "PolyPerc"

-- Core norns libraries
Util = require("util")
MusicUtil = require("musicutil")
Lfo = require("lfo")
Graph = require("graph")

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
State = {}

-- Color Mixer modules
PageManager = include("lib/page_manager")
LfoEngine = include("lib/lfo_engine")
