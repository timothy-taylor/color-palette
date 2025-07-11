-- LFO Engine - Dual LFO system with modulation
local LfoEngine = {}
LfoEngine.__index = LfoEngine

function LfoEngine.new()
    local self = setmetatable({}, LfoEngine)
    
    -- Initialize the LFO system
    self.lfos = Lfo.new()
    
    -- LFO A settings
    self.lfo_a_id = nil
    self.lfo_a_rate = 1.0
    self.lfo_a_shape = "sine"
    self.lfo_a_depth = 1.0
    self.lfo_a_value = 0
    
    -- LFO B settings
    self.lfo_b_id = nil
    self.lfo_b_rate = 0.5
    self.lfo_b_shape = "triangle"
    self.lfo_b_depth = 1.0
    self.lfo_b_value = 0
    
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
    self.lfo_a_id = self.lfos:add{
        shape = self.lfo_a_shape,
        min = -1,
        max = 1,
        depth = self.lfo_a_depth,
        mode = "free",
        period = 1 / self.lfo_a_rate,
        action = function(scaled, raw)
            self.lfo_a_value = scaled
            State.lfo_a_value = scaled
        end
    }
    
    -- Create LFO B
    self.lfo_b_id = self.lfos:add{
        shape = self.lfo_b_shape,
        min = -1,
        max = 1,
        depth = self.lfo_b_depth,
        mode = "free",
        period = 1 / self.lfo_b_rate,
        action = function(scaled, raw)
            self.lfo_b_value = scaled
            State.lfo_b_value = scaled
        end
    }
    
    -- Start both LFOs
    self.lfos:start(self.lfo_a_id)
    self.lfos:start(self.lfo_b_id)
end

function LfoEngine:get_combined_output()
    local a = self.lfo_a_value
    local b = self.lfo_b_value
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
    
    State.combined_lfo_value = combined
    return combined
end

-- LFO A control methods
function LfoEngine:set_lfo_a_rate(rate)
    self.lfo_a_rate = Util.clamp(rate, 0.01, 10)
    if self.lfo_a_id then
        self.lfos:set(self.lfo_a_id, "period", 1 / self.lfo_a_rate)
    end
end

function LfoEngine:set_lfo_a_shape(shape)
    if shape and shape ~= self.lfo_a_shape then
        self.lfo_a_shape = shape
        if self.lfo_a_id then
            self.lfos:set(self.lfo_a_id, "shape", shape)
        end
    end
end

function LfoEngine:set_lfo_a_depth(depth)
    self.lfo_a_depth = Util.clamp(depth, 0, 1)
    if self.lfo_a_id then
        self.lfos:set(self.lfo_a_id, "depth", self.lfo_a_depth)
    end
end

-- LFO B control methods
function LfoEngine:set_lfo_b_rate(rate)
    self.lfo_b_rate = Util.clamp(rate, 0.01, 10)
    if self.lfo_b_id then
        self.lfos:set(self.lfo_b_id, "period", 1 / self.lfo_b_rate)
    end
end

function LfoEngine:set_lfo_b_shape(shape)
    if shape and shape ~= self.lfo_b_shape then
        self.lfo_b_shape = shape
        if self.lfo_b_id then
            self.lfos:set(self.lfo_b_id, "shape", shape)
        end
    end
end

function LfoEngine:set_lfo_b_depth(depth)
    self.lfo_b_depth = Util.clamp(depth, 0, 1)
    if self.lfo_b_id then
        self.lfos:set(self.lfo_b_id, "depth", self.lfo_b_depth)
    end
end

-- Modulation control methods
function LfoEngine:set_mod_type(mod_type)
    self.mod_type = mod_type
end

function LfoEngine:set_mod_amount(amount)
    self.mod_amount = Util.clamp(amount, 0, 1)
end

function LfoEngine:set_mod_balance(balance)
    self.mod_balance = Util.clamp(balance, 0, 1)
end

-- Utility methods
function LfoEngine:stop_all()
    if self.lfo_a_id then
        self.lfos:stop(self.lfo_a_id)
    end
    if self.lfo_b_id then
        self.lfos:stop(self.lfo_b_id)
    end
end

function LfoEngine:start_all()
    if self.lfo_a_id then
        self.lfos:start(self.lfo_a_id)
    end
    if self.lfo_b_id then
        self.lfos:start(self.lfo_b_id)
    end
end

function LfoEngine:get_lfo_a_value()
    return self.lfo_a_value
end

function LfoEngine:get_lfo_b_value()
    return self.lfo_b_value
end

return LfoEngine