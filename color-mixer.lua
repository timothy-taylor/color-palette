--- Color Palette
-- Harmonaig-inspired MIDI processor
-- Starting with basic page system

include("lib/includes")

-- Global objects
local page_manager = nil
local lfo_engine = nil
local screen_timer = nil
local lfo_a_graph = nil
local lfo_b_graph = nil

function init()
    print("Color Mixer v0.1 - LFO Engine + Page System")

    -- Create graph objects for waveform visualization
    lfo_a_graph = Graph.new(1, 64, "lin", -1, 1, "lin", "line", false, false)
    lfo_a_graph:set_position_and_size(10, 15, 108, 30)
    
    lfo_b_graph = Graph.new(1, 64, "lin", -1, 1, "lin", "line", false, false)
    lfo_b_graph:set_position_and_size(10, 15, 108, 30)

    -- Create LFO engine and page manager
    lfo_engine = LfoEngine.new()
    page_manager = PageManager.new()

    -- Connect objects
    page_manager.lfo_engine = lfo_engine
    
    -- Pass graphs to LFO engine
    lfo_engine:set_lfo_a_graph(lfo_a_graph)
    lfo_engine:set_lfo_b_graph(lfo_b_graph)

    screen_timer = metro.init(redraw, 1 / 60, -1)
    screen_timer:start()

    print("Color Mixer initialized with LFO engine")
    print("KEY 2: Next page, KEY 3: Previous page")
end

function redraw()
    if page_manager then page_manager:draw_current_page() end
end

function cleanup()
    if lfo_engine then lfo_engine:stop_all() end
    if screen_timer then screen_timer:stop() end
end

function key(n, z)
    if z == 1 then
        if page_manager then page_manager:handle_key(n) end
        redraw()
    end
end

function enc(n, d)
    if page_manager then page_manager:handle_enc(n, d) end
    redraw()
end
