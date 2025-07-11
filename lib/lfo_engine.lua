-- LFO Engine - Dual LFO system with modulation
local LfoEngine = {}
LfoEngine.__index = LfoEngine

function LfoEngine.new()
    local self = setmetatable({}, LfoEngine)

    -- LFO A settings
    self.lfo_a = nil
    self.lfo_a_rate = 1.0
    self.lfo_a_shape = "sine"
    self.lfo_a_depth = 1.0
    self.lfo_a_value = 0
    
    -- Debug: Print initial values
    print("LFO A initialized: rate=" .. self.lfo_a_rate .. " shape=" .. self.lfo_a_shape .. " depth=" .. self.lfo_a_depth)

    -- Graph settings for visualization
    self.lfo_a_graph = nil
    self.lfo_a_buffer = {}
    self.lfo_a_buffer_size = 64

    -- LFO B settings
    self.lfo_b = nil
    self.lfo_b_rate = 0.5
    self.lfo_b_shape = "triangle"
    self.lfo_b_depth = 1.0
    self.lfo_b_value = 0

    -- Graph settings for visualization
    self.lfo_b_graph = nil
    self.lfo_b_buffer = {}
    self.lfo_b_buffer_size = 64

    -- Modulation settings
    self.mod_type = "mix"
    self.mod_amount = 0.5
    self.mod_balance = 0.5

    -- Create the LFOs
    self:create_lfos()

    return self
end

function LfoEngine:create_lfos()
    -- Create LFO A
    self.lfo_a = Lfo.new()
    self.lfo_a:set('shape', self.lfo_a_shape)
    self.lfo_a:set('min', -1)
    self.lfo_a:set('max', 1)
    self.lfo_a:set('depth', self.lfo_a_depth)
    self.lfo_a:set('mode', 'free')
    self.lfo_a:set('period', 1 / self.lfo_a_rate)
    self.lfo_a:set('action', function(scaled, raw)
        self.lfo_a_value = scaled
        -- Debug to see if this is being called
        print("LFO A callback: scaled=" .. string.format("%.2f", scaled))
    end)

    -- Create LFO B
    self.lfo_b = Lfo.new()
    self.lfo_b:set('shape', self.lfo_b_shape)
    self.lfo_b:set('min', -1)
    self.lfo_b:set('max', 1)
    self.lfo_b:set('depth', self.lfo_b_depth)
    self.lfo_b:set('mode', 'free')
    self.lfo_b:set('period', 1 / self.lfo_b_rate)
    self.lfo_b:set('action', function(scaled, raw)
        self.lfo_b_value = scaled
    end)

    -- Start both LFOs
    print("Starting LFO A...")
    self.lfo_a:start()
    print("Starting LFO B...")
    self.lfo_b:start()
    print("Both LFOs started!")
    
    -- Wait a moment and check values
    clock.run(function()
        clock.sleep(0.1)
        print("After 0.1s: LFO A value = " .. string.format("%.2f", self.lfo_a_value))
    end)
end

function LfoEngine:get_combined_output()
    local a = self:get_lfo_a_value()
    local b = self:get_lfo_b_value()
    local combined = 0

    if self.mod_type == "mix" then
        combined = a * (1 - self.mod_amount) + b * self.mod_amount
    elseif self.mod_type == "multiply" then
        combined = a * (1 + b * self.mod_amount)
    elseif self.mod_type == "am" then
        combined = a * (0.5 + 0.5 * b * self.mod_amount)
    elseif self.mod_type == "fm" then
        -- Simple FM approximation
        combined = a * (1 + b * self.mod_amount * 0.5)
    elseif self.mod_type == "min" then
        combined = math.min(a, b)
    elseif self.mod_type == "max" then
        combined = math.max(a, b)
    else
        combined = a -- Fallback
    end

    return combined
end

-- LFO A control methods
function LfoEngine:set_lfo_a_rate(rate)
    local new_rate = Util.clamp(rate, 0.01, 10)
    self.lfo_a_rate = new_rate
    if self.lfo_a then
        self.lfo_a:set('period', 1 / new_rate)
    end
end

function LfoEngine:set_lfo_a_shape(shape)
    if shape and shape ~= self.lfo_a_shape then
        self.lfo_a_shape = shape
        if self.lfo_a then
            self.lfo_a:set('shape', shape)
        end
    end
end

function LfoEngine:set_lfo_a_depth(depth)
    local new_depth = Util.clamp(depth, 0, 1)
    self.lfo_a_depth = new_depth
    if self.lfo_a then
        self.lfo_a:set('depth', new_depth)
    end
end

-- LFO B control methods
function LfoEngine:set_lfo_b_rate(rate)
    local new_rate = Util.clamp(rate, 0.01, 10)
    self.lfo_b_rate = new_rate
    if self.lfo_b then
        self.lfo_b:set('period', 1 / new_rate)
    end
end

function LfoEngine:set_lfo_b_shape(shape)
    if shape and shape ~= self.lfo_b_shape then
        self.lfo_b_shape = shape
        if self.lfo_b then
            self.lfo_b:set('shape', shape)
        end
    end
end

function LfoEngine:set_lfo_b_depth(depth)
    local new_depth = Util.clamp(depth, 0, 1)
    self.lfo_b_depth = new_depth
    if self.lfo_b then
        self.lfo_b:set('depth', new_depth)
    end
end

-- Modulation control methods
function LfoEngine:set_mod_type(mod_type)
    self.mod_type = mod_type
end

function LfoEngine:set_mod_amount(amount)
    local new_amount = Util.clamp(amount, 0, 1)
    self.mod_amount = new_amount
end

function LfoEngine:set_mod_balance(balance)
    local new_balance = Util.clamp(balance, 0, 1)
    self.mod_balance = new_balance
end

-- Utility methods
function LfoEngine:stop_all()
    if self.lfo_a then
        self.lfo_a:stop()
    end
    if self.lfo_b then
        self.lfo_b:stop()
    end
end

function LfoEngine:start_all()
    if self.lfo_a then
        self.lfo_a:start()
    end
    if self.lfo_b then
        self.lfo_b:start()
    end
end

function LfoEngine:get_lfo_a_value()
    if self.lfo_a then
        return self.lfo_a:get('scaled')
    end
    return 0
end

function LfoEngine:get_lfo_b_value()
    if self.lfo_b then
        return self.lfo_b:get('scaled')
    end
    return 0
end

function LfoEngine:set_lfo_a_graph(graph)
    self.lfo_a_graph = graph
end

function LfoEngine:set_lfo_b_graph(graph)
    self.lfo_b_graph = graph
end

function LfoEngine:update_visualization()
    -- Update LFO A buffer
    table.insert(self.lfo_a_buffer, self.lfo_a_value)
    if #self.lfo_a_buffer > self.lfo_a_buffer_size then
        table.remove(self.lfo_a_buffer, 1)
    end
    
    -- Update LFO B buffer
    table.insert(self.lfo_b_buffer, self.lfo_b_value)
    if #self.lfo_b_buffer > self.lfo_b_buffer_size then
        table.remove(self.lfo_b_buffer, 1)
    end
    
    -- Update graph A
    if self.lfo_a_graph then
        self.lfo_a_graph:remove_all_points()
        for i, value in ipairs(self.lfo_a_buffer) do
            -- Clamp value to graph domain
            local clamped_value = math.max(-1, math.min(1, value))
            -- Debug first few points
            if i <= 3 then
                print("LFO A: x=" .. i .. " y=" .. string.format("%.2f", value) .. " clamped=" .. string.format("%.2f", clamped_value))
            end
            self.lfo_a_graph:add_point(i, clamped_value)
        end
    end
    
    -- Update graph B
    if self.lfo_b_graph then
        self.lfo_b_graph:remove_all_points()
        for i, value in ipairs(self.lfo_b_buffer) do
            self.lfo_b_graph:add_point(i, value)
        end
    end
end

-- Helper functions to recreate LFOs
function LfoEngine:recreate_lfo_a()
    if self.lfo_a then
        self.lfo_a:stop()
    end

    self.lfo_a = Lfo.new()
    self.lfo_a:set('shape', self.lfo_a_shape)
    self.lfo_a:set('min', -1)
    self.lfo_a:set('max', 1)
    self.lfo_a:set('depth', self.lfo_a_depth)
    self.lfo_a:set('mode', 'free')
    self.lfo_a:set('period', 1 / self.lfo_a_rate)
    self.lfo_a:set('action', function(scaled, raw)
        self.lfo_a_value = scaled
    end)
    self.lfo_a:start()
end

function LfoEngine:recreate_lfo_b()
    if self.lfo_b then
        self.lfo_b:stop()
    end

    self.lfo_b = Lfo.new()
    self.lfo_b:set('shape', self.lfo_b_shape)
    self.lfo_b:set('min', -1)
    self.lfo_b:set('max', 1)
    self.lfo_b:set('depth', self.lfo_b_depth)
    self.lfo_b:set('mode', 'free')
    self.lfo_b:set('period', 1 / self.lfo_b_rate)
    self.lfo_b:set('action', function(scaled, raw)
        self.lfo_b_value = scaled
    end)
    self.lfo_b:start()
end

return LfoEngine
