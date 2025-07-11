-- Color Mixer
-- Harmonaig-inspired MIDI processor
-- Starting with basic page system

include("lib/includes")

-- Global objects
local page_manager = nil
local lfo_engine = nil

-- Timing
local screen_timer = nil

function init()
    print("Color Mixer v0.1 - LFO Engine + Page System")

    -- Initialize LFO engine
    lfo_engine = LfoEngine.new()
    
    -- Initialize page manager
    page_manager = PageManager.new()
    
    -- Pass LFO engine to page manager for control
    page_manager.lfo_engine = lfo_engine

    -- Start screen refresh
    screen_timer = metro.init(draw_screen, 1 / 15, -1)
    screen_timer:start()

    print("Color Mixer initialized with LFO engine")
    print("KEY 2: Next page, KEY 3: Previous page")
    print("KEY 2 + KEY 3: Toggle keyboard mode")
end

function draw_screen()
    if State.screen_dirty then
        page_manager:draw_current_page()
        State.screen_dirty = false
    end
end

function cleanup()
    -- Stop LFO engine
    if lfo_engine then
        lfo_engine:stop_all()
    end
    
    -- Stop timers
    if screen_timer then screen_timer:stop() end

    print("Color Mixer cleanup complete")
end

-- Input handlers
function key(n, z)
    page_manager:handle_key(n, z)
    State.screen_dirty = true
end

function enc(n, d)
    page_manager:handle_enc(n, d)
    State.screen_dirty = true
end
