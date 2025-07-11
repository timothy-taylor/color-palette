--- Color Palette
-- Harmonaig-inspired MIDI processor
-- Starting with basic page system

include("lib/includes")

-- Global objects
local page_manager = nil
local lfo_engine = nil
local screen_timer = nil

function init()
    print("Color Mixer v0.1 - LFO Engine + Page System")

    lfo_engine = LfoEngine.new()
    page_manager = PageManager.new()

    page_manager.lfo_engine = lfo_engine

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
