-- Page Manager - Basic page system for development
local PageManager = {}
PageManager.__index = PageManager

function PageManager.new()
    local self = setmetatable({}, PageManager)

    self.pages = {
        {
            name = "LFO A",
            id = "lfo_a",
            enc = self.handle_lfo_a_enc,
            draw = self.draw_lfo_a_page
        },
        {
            name = "LFO B",
            id = "lfo_b",
            enc = self.handle_lfo_b_enc,
            draw = self.draw_lfo_b_page
        },
        {
            name = "MODULATION",
            id = "modulation",
            enc = self.handle_modulation_enc,
            draw = self.draw_modulation_page
        },
        {
            name = "HARMONICS",
            id = "harmonics",
            enc = self.handle_harmonics_enc,
            draw = self.draw_harmonics_page
        },
        {
            name = "SCALE",
            id = "scale",
            enc = self.handle_scale_enc,
            draw = self.draw_scale_page
        }
    }

    self.current_page = 1
    self.keyboard_mode = false
    
    -- Waveform drawing settings
    self.waveform_x = 10
    self.waveform_y = 15
    self.waveform_width = 108
    self.waveform_height = 30

    return self
end

-- Navigation
function PageManager:handle_key(n)
    print(n)
    if n == 2 then
        self:next_page()
    elseif n == 3 then
        self:prev_page()
    end
end

function PageManager:handle_enc(n, d)
    local page = self.pages[self.current_page]
    if page.enc then
        page.enc(self, n, d)
    end
end

function PageManager:next_page()
    self.current_page = self.current_page + 1
    if self.current_page > #self.pages then
        self.current_page = 1
    end
    print("Page: " .. self.pages[self.current_page].name)
end

function PageManager:prev_page()
    self.current_page = self.current_page - 1
    if self.current_page < 1 then
        self.current_page = #self.pages
    end
    print("Page: " .. self.pages[self.current_page].name)
end

function PageManager:toggle_keyboard_mode()
    self.keyboard_mode = not self.keyboard_mode
    print("MIDI Keyboard mode: " .. (self.keyboard_mode and "ON" or "OFF"))
end

-- Main draw function
function PageManager:draw_current_page()
    screen.clear()

    -- Page title
    screen.level(15)
    screen.move(64, 6)
    screen.text_center(self.pages[self.current_page].name)

    -- Keyboard mode indicator
    if self.keyboard_mode then
        screen.level(10)
        screen.move(122, 6)
        screen.text_right("♪")
    end

    -- Page-specific content
    local page = self.pages[self.current_page]
    if page.draw then
        page.draw(self)
    end

    -- Page dots
    self:draw_page_dots()

    screen.update()
end

function PageManager:draw_page_dots()
    local y = 60
    local spacing = 6
    local total_width = (#self.pages - 1) * spacing
    local start_x = 64 - (total_width / 2)

    for i = 1, #self.pages do
        local x = start_x + (i - 1) * spacing

        if i == self.current_page then
            screen.level(15)
            screen.circle(x, y, 2)
            screen.fill()
        else
            screen.level(3)
            screen.circle(x, y, 1)
            screen.fill()
        end
    end
end

-- Page-specific handlers (placeholders for development)

-- LFO A Page
function PageManager:handle_lfo_a_enc(n, d)
    if not self.lfo_engine then return end

    if n == 1 then
        -- Rate control
        local new_rate = self.lfo_engine.lfo_a_rate + (d * 0.1)
        new_rate = Util.clamp(new_rate, 0.01, 10)
        self.lfo_engine:set_lfo_a_rate(new_rate)
        print("LFO A Rate: " .. string.format("%.2f", new_rate) .. " Hz")
    elseif n == 2 then
        -- Shape control
        local shapes = LFO_SHAPES
        local current_index = 1
        for i, shape in ipairs(shapes) do
            if shape == self.lfo_engine.lfo_a_shape then
                current_index = i
                break
            end
        end

        local new_index = current_index + d
        new_index = Util.clamp(new_index, 1, #shapes)

        self.lfo_engine:set_lfo_a_shape(shapes[new_index])
        print("LFO A Shape: " .. shapes[new_index])
    elseif n == 3 then
        -- Depth control
        local new_depth = self.lfo_engine.lfo_a_depth + (d * 0.05)
        new_depth = Util.clamp(new_depth, 0, 1)
        self.lfo_engine:set_lfo_a_depth(new_depth)
        print("LFO A Depth: " .. string.format("%.0f", new_depth * 100) .. "%")
    end
end

function PageManager:draw_lfo_a_page()
    -- Waveform area
    screen.level(8)
    screen.rect(10, 15, 108, 30)
    screen.stroke()

    -- Draw waveform manually
    if self.lfo_engine then
        local buffer = self.lfo_engine:get_lfo_a_buffer()
        
        if #buffer > 1 then
            screen.level(12)
            
            -- Draw connected line waveform
            for i = 1, #buffer - 1 do
                local x1 = self.waveform_x + (i - 1) * (self.waveform_width / 64)
                local y1 = self.waveform_y + self.waveform_height/2 - (buffer[i] * self.waveform_height/2)
                local x2 = self.waveform_x + i * (self.waveform_width / 64)
                local y2 = self.waveform_y + self.waveform_height/2 - (buffer[i + 1] * self.waveform_height/2)
                
                screen.move(x1, y1)
                screen.line(x2, y2)
                screen.stroke()
            end
        end
        
        -- Current value indicator
        local lfo_value = self.lfo_engine:get_lfo_a_value()
        screen.level(15)
        screen.move(118, 20)
        screen.text_right(string.format("%.2f", lfo_value))
    end

    -- Parameter display
    if self.lfo_engine then
        screen.level(10)
        screen.move(10, 52)
        screen.text(string.format("%.2fHz", self.lfo_engine.lfo_a_rate))
        screen.move(64, 52)
        screen.text_center(self.lfo_engine.lfo_a_shape)
        screen.move(118, 52)
        screen.text_right(string.format("%.0f%%", self.lfo_engine.lfo_a_depth * 100))
    end
end

-- LFO B Page
function PageManager:handle_lfo_b_enc(n, d)
    if not self.lfo_engine then return end

    if n == 1 then
        -- Rate control
        local new_rate = self.lfo_engine.lfo_b_rate + (d * 0.1)
        new_rate = Util.clamp(new_rate, 0.01, 10)
        self.lfo_engine:set_lfo_b_rate(new_rate)
        print("LFO B Rate: " .. string.format("%.2f", new_rate) .. " Hz")
    elseif n == 2 then
        -- Shape control
        local shapes = LFO_SHAPES
        local current_index = 1
        for i, shape in ipairs(shapes) do
            if shape == self.lfo_engine.lfo_b_shape then
                current_index = i
                break
            end
        end

        local new_index = current_index + d
        new_index = Util.clamp(new_index, 1, #shapes)

        self.lfo_engine:set_lfo_b_shape(shapes[new_index])
        print("LFO B Shape: " .. shapes[new_index])
    elseif n == 3 then
        -- Depth control
        local new_depth = self.lfo_engine.lfo_b_depth + (d * 0.05)
        new_depth = Util.clamp(new_depth, 0, 1)
        self.lfo_engine:set_lfo_b_depth(new_depth)
        print("LFO B Depth: " .. string.format("%.0f", new_depth * 100) .. "%")
    end
end

function PageManager:draw_lfo_b_page()
    -- Waveform area
    screen.level(8)
    screen.rect(10, 15, 108, 30)
    screen.stroke()

    -- Draw waveform manually
    if self.lfo_engine then
        local buffer = self.lfo_engine:get_lfo_b_buffer()
        
        if #buffer > 1 then
            screen.level(12)
            
            -- Draw connected line waveform
            for i = 1, #buffer - 1 do
                local x1 = self.waveform_x + (i - 1) * (self.waveform_width / 64)
                local y1 = self.waveform_y + self.waveform_height/2 - (buffer[i] * self.waveform_height/2)
                local x2 = self.waveform_x + i * (self.waveform_width / 64)
                local y2 = self.waveform_y + self.waveform_height/2 - (buffer[i + 1] * self.waveform_height/2)
                
                screen.move(x1, y1)
                screen.line(x2, y2)
                screen.stroke()
            end
        end
        
        -- Current value indicator
        local lfo_value = self.lfo_engine:get_lfo_b_value()
        screen.level(15)
        screen.move(118, 20)
        screen.text_right(string.format("%.2f", lfo_value))
    end

    -- Parameter display
    if self.lfo_engine then
        screen.level(10)
        screen.move(10, 52)
        screen.text(string.format("%.2fHz", self.lfo_engine.lfo_b_rate))
        screen.move(64, 52)
        screen.text_center(self.lfo_engine.lfo_b_shape)
        screen.move(118, 52)
        screen.text_right(string.format("%.0f%%", self.lfo_engine.lfo_b_depth * 100))
    end
end

-- Modulation Page
function PageManager:handle_modulation_enc(n, d)
    if not self.lfo_engine then return end

    if n == 1 then
        -- Modulation type
        local mod_types = { "mix", "multiply", "am", "fm", "min", "max" }
        local current_index = 1
        for i, mod_type in ipairs(mod_types) do
            if mod_type == self.lfo_engine.mod_type then
                current_index = i
                break
            end
        end

        local new_index = current_index + d
        new_index = Util.clamp(new_index, 1, #mod_types)

        self.lfo_engine:set_mod_type(mod_types[new_index])
        print("Mod Type: " .. mod_types[new_index])
    elseif n == 2 then
        -- Modulation amount
        local new_amount = self.lfo_engine.mod_amount + (d * 0.05)
        new_amount = Util.clamp(new_amount, 0, 1)
        self.lfo_engine:set_mod_amount(new_amount)
        print("Mod Amount: " .. string.format("%.0f", new_amount * 100) .. "%")
    elseif n == 3 then
        -- Modulation balance
        local new_balance = self.lfo_engine.mod_balance + (d * 0.05)
        new_balance = Util.clamp(new_balance, 0, 1)
        self.lfo_engine:set_mod_balance(new_balance)
        print("Mod Balance: " .. string.format("%.0f", new_balance * 100) .. "%")
    end
end

function PageManager:draw_modulation_page()
    -- A + B = Output diagram
    screen.level(8)

    -- LFO A box with value
    screen.rect(10, 20, 25, 15)
    screen.stroke()
    screen.move(22, 27)
    screen.text_center("A")
    if self.lfo_engine then
        screen.level(12)
        screen.move(22, 32)
        screen.text_center(string.format("%.1f", self.lfo_engine:get_lfo_a_value()))
    end

    -- LFO B box with value
    screen.level(8)
    screen.rect(93, 20, 25, 15)
    screen.stroke()
    screen.move(105, 27)
    screen.text_center("B")
    if self.lfo_engine then
        screen.level(12)
        screen.move(105, 32)
        screen.text_center(string.format("%.1f", self.lfo_engine:get_lfo_b_value()))
    end

    -- Output box with combined value
    screen.level(8)
    screen.rect(52, 38, 25, 10)
    screen.stroke()
    screen.move(64, 42)
    screen.text_center("OUT")
    if self.lfo_engine then
        screen.level(15)
        screen.move(64, 47)
        screen.text_center(string.format("%.2f", self.lfo_engine:get_combined_output()))
    end

    -- Modulation type
    screen.level(15)
    screen.move(64, 15)
    if self.lfo_engine then
        screen.text_center(string.upper(self.lfo_engine.mod_type))
    else
        screen.text_center("MIX")
    end

    -- Parameters
    screen.level(10)
    screen.move(10, 56)
    if self.lfo_engine then
        screen.text(string.format("%.0f%%", self.lfo_engine.mod_amount * 100))
        screen.move(64, 56)
        screen.text_center(self.lfo_engine.mod_type)
        screen.move(118, 56)
        screen.text_right(string.format("%.0f%%", self.lfo_engine.mod_balance * 100))
    end
end

-- Harmonics Page
function PageManager:handle_harmonics_enc(n, d)
    if n == 1 then
        print("Chord Quality: " .. d)
    elseif n == 2 then
        print("Inversion: " .. d)
    elseif n == 3 then
        print("Voicing: " .. d)
    end
end

function PageManager:draw_harmonics_page()
    -- Combined waveform area
    screen.level(8)
    screen.rect(10, 15, 108, 20)
    screen.stroke()

    screen.level(5)
    screen.move(64, 25)
    screen.text_center("Combined LFO Output")

    -- Current chord display
    screen.level(15)
    screen.move(64, 40)
    screen.text_center("CMaj7")

    screen.level(8)
    screen.move(64, 48)
    screen.text_center("C  E  G  B")

    screen.level(10)
    screen.move(10, 56)
    screen.text("Maj7")
    screen.move(64, 56)
    screen.text_center("Root")
    screen.move(118, 56)
    screen.text_right("Close")
end

-- Scale Page
function PageManager:handle_scale_enc(n, d)
    if n == 1 then
        print("Scale Type: " .. d)
    elseif n == 2 then
        print("Root Note: " .. d)
    elseif n == 3 then
        print("Octave Range: " .. d)
    end
end

function PageManager:draw_scale_page()
    -- Piano keyboard representation
    screen.level(10)
    screen.move(64, 15)
    screen.text_center("C Major Scale")

    -- Draw chromatic notes with scale highlights
    local y = 30
    local note_names = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }
    local major_scale = { true, false, true, false, true, true, false, true, false, true, false, true }

    for i = 1, 12 do
        local x = 4 + (i - 1) * 10

        if major_scale[i] then
            screen.level(15)
            screen.circle(x, y, 3)
            screen.fill()

            screen.level(10)
            screen.move(x, y + 8)
            screen.text_center(note_names[i])
        else
            screen.level(3)
            screen.circle(x, y, 2)
            screen.stroke()

            screen.level(2)
            screen.move(x, y + 8)
            screen.text_center(note_names[i])
        end
    end

    screen.level(10)
    screen.move(10, 52)
    screen.text("Major")
    screen.move(64, 52)
    screen.text_center("C4")
    screen.move(118, 52)
    screen.text_right("4 Oct")
end

return PageManager
