local template = rf2.executeScript(rf2.radio.template)
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}
local mspEsc4Way = "mspEsc4Way"
local mspEscAm32 = "mspEscAm32"
local escParameters = rf2.useApi(mspEscAm32).getDefaults()

local FIELD_IDX = {
    motor_direction = 1,
    motor_kv = 2,
    motor_poles = 3,
    startup_power = 4,
    brake_on_stop = 5,
    brake_strength = 6,
    running_brake_level = 7,
    beep_volume = 8,
    timing_advance = 9,
    stuck_rotor_protection = 10,
    sinusoidal_startup = 11,
    sine_mode_power = 12,
    sine_mode_range = 13,
    bidirectional_mode = 14,
    esc_protocol = 15,
    stall_protection = 16,
    interval_telemetry = 17,
    auto_advance = 18,
    complementary_pwm = 19,
    variable_pwm_frequency = 20,
    pwm_frequency = 21,
    temperature_limit = 22,
    current_limit = 23,
    low_voltage_cutoff = 24,
    low_voltage_threshold = 25,
    servo_low_threshold = 26,
    servo_high_threshold = 27,
    servo_neutral = 28,
    servo_dead_band = 29,
    rc_car_reversing = 30,
    use_hall_sensors = 31,
}

local function setReadOnly(index, readOnly)
    if fields[index] then
        fields[index].readOnly = readOnly
    end
end

local function updateConditionalFields(page)
    setReadOnly(FIELD_IDX.pwm_frequency, escParameters.variable_pwm_frequency.value == 0)
    setReadOnly(FIELD_IDX.low_voltage_threshold, escParameters.low_voltage_cutoff.value == 0)

    local servoMode = escParameters.esc_protocol.value == 2
    setReadOnly(FIELD_IDX.servo_low_threshold, not servoMode)
    setReadOnly(FIELD_IDX.servo_high_threshold, not servoMode)
    setReadOnly(FIELD_IDX.servo_neutral, not servoMode)
    setReadOnly(FIELD_IDX.servo_dead_band, not servoMode)
    setReadOnly(FIELD_IDX.rc_car_reversing, not servoMode)
end

local function onControlChange(field, page)
    updateConditionalFields(page)
end

labels[1] = { t = "ESC not ready, waiting...", x = x,          y = incY(lineSpacing) }
labels[2] = { t = "---",                       x = x + indent, y = incY(lineSpacing), bold = false }
labels[3] = { t = "---",                       x = x + indent, y = incY(lineSpacing), bold = false }

labels[4] = { t = "Basic",                    x = x,          y = incY(lineSpacing * 2) }
fields[FIELD_IDX.motor_direction]    = { t = "Motor Direction",        x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 150, data = escParameters.motor_direction }
fields[FIELD_IDX.motor_kv]           = { t = "Motor KV",               x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.motor_kv }
fields[FIELD_IDX.motor_poles]        = { t = "Motor Poles",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.motor_poles }
fields[FIELD_IDX.startup_power]      = { t = "Startup Power",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.startup_power }
fields[FIELD_IDX.brake_on_stop]      = { t = "Brake On Stop",          x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 150, data = escParameters.brake_on_stop }
fields[FIELD_IDX.brake_strength]     = { t = "Brake Strength",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.brake_strength }
fields[FIELD_IDX.running_brake_level]= { t = "Running Brake",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.running_brake_level }
fields[FIELD_IDX.beep_volume]        = { t = "Beep Volume",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.beep_volume }

labels[5] = { t = "Advanced",                 x = x,          y = incY(lineSpacing * 2) }
fields[FIELD_IDX.timing_advance]        = { t = "Timing Advance",      x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 150, data = escParameters.timing_advance }
fields[FIELD_IDX.stuck_rotor_protection]= { t = "Stuck Rotor Prot.",   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.stuck_rotor_protection }
fields[FIELD_IDX.sinusoidal_startup]    = { t = "Sinusoidal Startup",  x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.sinusoidal_startup }
fields[FIELD_IDX.sine_mode_power]       = { t = "Sine Mode Power",     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.sine_mode_power }
fields[FIELD_IDX.sine_mode_range]       = { t = "Sine Mode Range",     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.sine_mode_range }
fields[FIELD_IDX.bidirectional_mode]    = { t = "Bidirectional Mode",  x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.bidirectional_mode }
fields[FIELD_IDX.esc_protocol]          = { t = "Protocol",            x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 150, data = escParameters.esc_protocol, change = onControlChange }
fields[FIELD_IDX.stall_protection]      = { t = "Stall Protection",    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.stall_protection }
fields[FIELD_IDX.interval_telemetry]    = { t = "Telemetry Interval",  x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.interval_telemetry }
fields[FIELD_IDX.auto_advance]          = { t = "Auto Advance",        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.auto_advance }
fields[FIELD_IDX.complementary_pwm]     = { t = "Complementary PWM",   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.complementary_pwm }
fields[FIELD_IDX.variable_pwm_frequency]= { t = "Variable PWM",        x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 150, data = escParameters.variable_pwm_frequency, change = onControlChange }
fields[FIELD_IDX.pwm_frequency]         = { t = "PWM Frequency",       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.pwm_frequency }

labels[6] = { t = "Limits / Input",            x = x,          y = incY(lineSpacing * 2) }
fields[FIELD_IDX.temperature_limit]    = { t = "Temperature Limit",    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.temperature_limit }
fields[FIELD_IDX.current_limit]        = { t = "Current Limit (A)",    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.current_limit }
fields[FIELD_IDX.low_voltage_cutoff]   = { t = "Low Voltage Cutoff",   x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 150, data = escParameters.low_voltage_cutoff, change = onControlChange }
fields[FIELD_IDX.low_voltage_threshold]= { t = "Low Voltage Threshold",x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.low_voltage_threshold }
fields[FIELD_IDX.servo_low_threshold]  = { t = "Servo Low (us)",       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.servo_low_threshold }
fields[FIELD_IDX.servo_high_threshold] = { t = "Servo High (us)",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.servo_high_threshold }
fields[FIELD_IDX.servo_neutral]        = { t = "Servo Neutral (us)",   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.servo_neutral }
fields[FIELD_IDX.servo_dead_band]      = { t = "Servo Dead Band",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.servo_dead_band }
fields[FIELD_IDX.rc_car_reversing]     = { t = "RC Car Reversing",     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.rc_car_reversing }
fields[FIELD_IDX.use_hall_sensors]     = { t = "Use Hall Sensors",     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.use_hall_sensors }

local function receivedEscParameters(page, data)
    page.switchPending = false
    page.readPending = false

    if data.esc_signature ~= 194 then
        page.labels[1].t = "Invalid ESC detected"
    else
        page.labels[1].t = string.format("AM32 ESC%d", (rf2.esc4wayTarget or 0) + 1)
        page.labels[2].t = string.format("FW: %d.%d", data.version_major or 0, data.version_minor or 0)
        page.labels[3].t = string.format("EEPROM: %d", data.eeprom_version or 0)
        updateConditionalFields(page)
        page.readOnly = false
    end

    rf2.onPageReady(page)
end

    return {
        read = function(self)
        local target = rf2.esc4wayTarget

        if rf2.esc4wayTool ~= "am32" or target == nil then
            self.labels[1].t = "Select ESC target first"
            self.labels[2].t = "---"
            self.labels[3].t = "---"
            self.readOnly = true
            rf2.onPageReady(self)
            return
        end

        if self.switchPending or self.readPending then
            return
        end

        local function readEsc()
            self.readPending = true
            rf2.useApi(mspEscAm32).read(receivedEscParameters, self, escParameters)
        end

        if rf2.esc4wayActiveTool == "am32" and rf2.esc4wayActiveTarget == target then
            readEsc()
            return
        end

        self.labels[1].t = string.format("Selecting ESC%d...", target + 1)
        self.labels[2].t = "---"
        self.labels[3].t = "---"
        self.switchPending = true
        self.readOnly = true
        rf2.useApi(mspEsc4Way).setTarget(target, function(page, ok, selectedTarget)
            page.switchPending = false
            if not ok then
                page.labels[1].t = string.format("ESC%d select failed", (selectedTarget or 0) + 1)
                page.labels[2].t = "Check telemetry / ESC power"
                page.labels[3].t = "---"
                rf2.onPageReady(page)
                return
            end

            rf2.esc4wayActiveTool = "am32"
            rf2.esc4wayActiveTarget = selectedTarget
            readEsc()
        end, self)
    end,
    write = function(self)
        rf2.useApi(mspEscAm32).write(escParameters)
        rf2.settingsSaved(false, false)
    end,
    title       = "AM32 Setup",
    labels      = labels,
    fields      = fields,
    readOnly    = true
}
