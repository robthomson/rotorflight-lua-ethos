local motorDirection = {
    [0] = "Normal",
    "Reversed",
}

local timingAdvance = {
    [0] = "0 deg",
    "7.5 deg",
    "15 deg",
    "22.5 deg",
}

local onOff = {
    [0] = "Off",
    "On",
}

local protocol = {
    [0] = "Auto",
    "DShot 300-600",
    "Servo 1-2ms",
    "Serial",
    "BF Safe Arming",
}

local brakeOnStop = {
    [0] = "Off",
    "Brake",
    "Active",
}

local variablePwm = {
    [0] = "Fixed",
    "Variable",
    "By RPM",
}

local lowVoltageCutoff = {
    [0] = "Off",
    "Per Cell",
    "Absolute",
}

local function clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

local function normalizeTimingAdvance(raw)
    if raw == nil then return 0, "legacy" end
    if raw >= 10 and raw <= 42 then
        return clamp(math.floor((raw - 10) / 8 + 0.5), 0, 3), "new"
    end
    return clamp(math.floor(raw + 0.5), 0, 3), "legacy"
end

local function encodeTimingAdvance(value, encoding)
    value = clamp(math.floor((value or 0) + 0.5), 0, 3)
    if encoding == "new" then
        return 10 + value * 8
    end
    return value
end

local function normalizeMotorKv(raw)
    if raw == nil then return nil end
    return raw * 40 + 20
end

local function encodeMotorKv(value)
    if value == nil then return nil end
    return clamp(math.floor(((value - 20) / 40) + 0.5), 0, 255)
end

local function normalizeServoLow(raw)
    if raw == nil then return nil end
    return raw * 2 + 750
end

local function encodeServoLow(value)
    if value == nil then return nil end
    return clamp(math.floor(((value - 750) / 2) + 0.5), 0, 255)
end

local function normalizeServoHigh(raw)
    if raw == nil then return nil end
    return raw * 2 + 1750
end

local function encodeServoHigh(value)
    if value == nil then return nil end
    return clamp(math.floor(((value - 1750) / 2) + 0.5), 0, 255)
end

local function normalizeServoNeutral(raw)
    if raw == nil then return nil end
    return raw + 1374
end

local function encodeServoNeutral(value)
    if value == nil then return nil end
    return clamp(math.floor((value - 1374) + 0.5), 0, 255)
end

local function normalizeLowVoltageThreshold(raw)
    if raw == nil then return nil end
    return raw + 250
end

local function encodeLowVoltageThreshold(value)
    if value == nil then return nil end
    return clamp(math.floor((value - 250) + 0.5), 0, 255)
end

local function normalizeCurrentLimit(raw)
    if raw == nil then return nil end
    return raw * 2
end

local function encodeCurrentLimit(value)
    if value == nil then return nil end
    return clamp(math.floor((value / 2) + 0.5), 0, 255)
end

local function getDefaults()
    return {
        esc_signature = nil,
        esc_command = nil,
        reserved_0 = nil,
        eeprom_version = nil,
        reserved_1 = nil,
        version_major = nil,
        version_minor = nil,
        max_ramp = nil,
        minimum_duty_cycle = nil,
        disable_stick_calibration = nil,
        absolute_voltage_cutoff = nil,
        current_p = nil,
        current_i = nil,
        current_d = nil,
        active_brake_power = nil,
        reserved_eeprom_3_0 = nil,
        reserved_eeprom_3_1 = nil,
        reserved_eeprom_3_2 = nil,
        reserved_eeprom_3_3 = nil,
        timing_advance_encoding = "legacy",
        motor_direction = { min = 0, max = #motorDirection, table = motorDirection },
        bidirectional_mode = { min = 0, max = #onOff, table = onOff },
        sinusoidal_startup = { min = 0, max = #onOff, table = onOff },
        complementary_pwm = { min = 0, max = #onOff, table = onOff },
        variable_pwm_frequency = { min = 0, max = #variablePwm, table = variablePwm },
        stuck_rotor_protection = { min = 0, max = #onOff, table = onOff },
        timing_advance = { min = 0, max = #timingAdvance, table = timingAdvance },
        pwm_frequency = { min = 8, max = 144, unit = " kHz" },
        startup_power = { min = 50, max = 150, unit = rf2.units.percentage },
        motor_kv = { min = 20, max = 10220, unit = " KV" },
        motor_poles = { min = 2, max = 36 },
        brake_on_stop = { min = 0, max = #brakeOnStop, table = brakeOnStop },
        stall_protection = { min = 0, max = #onOff, table = onOff },
        beep_volume = { min = 0, max = 11 },
        interval_telemetry = { min = 0, max = #onOff, table = onOff },
        servo_low_threshold = { min = 750, max = 1250 },
        servo_high_threshold = { min = 1750, max = 2250 },
        servo_neutral = { min = 1374, max = 1630 },
        servo_dead_band = { min = 0, max = 100 },
        low_voltage_cutoff = { min = 0, max = #lowVoltageCutoff, table = lowVoltageCutoff },
        low_voltage_threshold = { min = 250, max = 350, scale = 100, unit = rf2.units.volt },
        rc_car_reversing = { min = 0, max = #onOff, table = onOff },
        use_hall_sensors = { min = 0, max = #onOff, table = onOff },
        sine_mode_range = { min = 5, max = 25 },
        brake_strength = { min = 0, max = 10 },
        running_brake_level = { min = 0, max = 10 },
        temperature_limit = { min = 70, max = 141, unit = rf2.units.celsius },
        current_limit = { min = 0, max = 404 },
        sine_mode_power = { min = 1, max = 10 },
        esc_protocol = { min = 0, max = #protocol, table = protocol },
        auto_advance = { min = 0, max = #onOff, table = onOff },
    }
end

local function getEscParameters(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 217, -- MSP_ESC_PARAMETERS
        processReply = function(self, buf)
            local signature = rf2.mspHelper.readU8(buf)
            if signature ~= 194 then
                return
            end

            data.esc_signature = signature
            data.esc_command = rf2.mspHelper.readU8(buf)
            data.reserved_0 = rf2.mspHelper.readU8(buf)
            data.eeprom_version = rf2.mspHelper.readU8(buf)
            data.reserved_1 = rf2.mspHelper.readU8(buf)
            data.version_major = rf2.mspHelper.readU8(buf)
            data.version_minor = rf2.mspHelper.readU8(buf)
            data.max_ramp = rf2.mspHelper.readU8(buf)
            data.minimum_duty_cycle = rf2.mspHelper.readU8(buf)
            data.disable_stick_calibration = rf2.mspHelper.readU8(buf)
            data.absolute_voltage_cutoff = rf2.mspHelper.readU8(buf)
            data.current_p = rf2.mspHelper.readU8(buf)
            data.current_i = rf2.mspHelper.readU8(buf)
            data.current_d = rf2.mspHelper.readU8(buf)
            data.active_brake_power = rf2.mspHelper.readU8(buf)
            data.reserved_eeprom_3_0 = rf2.mspHelper.readU8(buf)
            data.reserved_eeprom_3_1 = rf2.mspHelper.readU8(buf)
            data.reserved_eeprom_3_2 = rf2.mspHelper.readU8(buf)
            data.reserved_eeprom_3_3 = rf2.mspHelper.readU8(buf)
            data.motor_direction.value = rf2.mspHelper.readU8(buf)
            data.bidirectional_mode.value = rf2.mspHelper.readU8(buf)
            data.sinusoidal_startup.value = rf2.mspHelper.readU8(buf)
            data.complementary_pwm.value = rf2.mspHelper.readU8(buf)
            data.variable_pwm_frequency.value = rf2.mspHelper.readU8(buf)
            data.stuck_rotor_protection.value = rf2.mspHelper.readU8(buf)

            local timingRaw = rf2.mspHelper.readU8(buf)
            data.timing_advance.value, data.timing_advance_encoding = normalizeTimingAdvance(timingRaw)

            data.pwm_frequency.value = rf2.mspHelper.readU8(buf)
            data.startup_power.value = rf2.mspHelper.readU8(buf)
            data.motor_kv.value = normalizeMotorKv(rf2.mspHelper.readU8(buf))
            data.motor_poles.value = rf2.mspHelper.readU8(buf)
            data.brake_on_stop.value = rf2.mspHelper.readU8(buf)
            data.stall_protection.value = rf2.mspHelper.readU8(buf)
            data.beep_volume.value = rf2.mspHelper.readU8(buf)
            data.interval_telemetry.value = rf2.mspHelper.readU8(buf)
            data.servo_low_threshold.value = normalizeServoLow(rf2.mspHelper.readU8(buf))
            data.servo_high_threshold.value = normalizeServoHigh(rf2.mspHelper.readU8(buf))
            data.servo_neutral.value = normalizeServoNeutral(rf2.mspHelper.readU8(buf))
            data.servo_dead_band.value = rf2.mspHelper.readU8(buf)
            data.low_voltage_cutoff.value = rf2.mspHelper.readU8(buf)
            data.low_voltage_threshold.value = normalizeLowVoltageThreshold(rf2.mspHelper.readU8(buf))
            data.rc_car_reversing.value = rf2.mspHelper.readU8(buf)
            data.use_hall_sensors.value = rf2.mspHelper.readU8(buf)
            data.sine_mode_range.value = rf2.mspHelper.readU8(buf)
            data.brake_strength.value = rf2.mspHelper.readU8(buf)
            data.running_brake_level.value = rf2.mspHelper.readU8(buf)
            data.temperature_limit.value = rf2.mspHelper.readU8(buf)
            data.current_limit.value = normalizeCurrentLimit(rf2.mspHelper.readU8(buf))
            data.sine_mode_power.value = rf2.mspHelper.readU8(buf)
            data.esc_protocol.value = rf2.mspHelper.readU8(buf)
            data.auto_advance.value = rf2.mspHelper.readU8(buf)

            callback(callbackParam, data)
        end
    }
    rf2.mspQueue:add(message)
end

local function setEscParameters(data)
    local message = {
        command = 218, -- MSP_SET_ESC_PARAMETERS
        payload = {}
    }

    rf2.mspHelper.writeU8(message.payload, data.esc_signature)
    rf2.mspHelper.writeU8(message.payload, data.esc_command)
    rf2.mspHelper.writeU8(message.payload, data.reserved_0)
    rf2.mspHelper.writeU8(message.payload, data.eeprom_version)
    rf2.mspHelper.writeU8(message.payload, data.reserved_1)
    rf2.mspHelper.writeU8(message.payload, data.version_major)
    rf2.mspHelper.writeU8(message.payload, data.version_minor)
    rf2.mspHelper.writeU8(message.payload, data.max_ramp)
    rf2.mspHelper.writeU8(message.payload, data.minimum_duty_cycle)
    rf2.mspHelper.writeU8(message.payload, data.disable_stick_calibration)
    rf2.mspHelper.writeU8(message.payload, data.absolute_voltage_cutoff)
    rf2.mspHelper.writeU8(message.payload, data.current_p)
    rf2.mspHelper.writeU8(message.payload, data.current_i)
    rf2.mspHelper.writeU8(message.payload, data.current_d)
    rf2.mspHelper.writeU8(message.payload, data.active_brake_power)
    rf2.mspHelper.writeU8(message.payload, data.reserved_eeprom_3_0)
    rf2.mspHelper.writeU8(message.payload, data.reserved_eeprom_3_1)
    rf2.mspHelper.writeU8(message.payload, data.reserved_eeprom_3_2)
    rf2.mspHelper.writeU8(message.payload, data.reserved_eeprom_3_3)
    rf2.mspHelper.writeU8(message.payload, data.motor_direction.value)
    rf2.mspHelper.writeU8(message.payload, data.bidirectional_mode.value)
    rf2.mspHelper.writeU8(message.payload, data.sinusoidal_startup.value)
    rf2.mspHelper.writeU8(message.payload, data.complementary_pwm.value)
    rf2.mspHelper.writeU8(message.payload, data.variable_pwm_frequency.value)
    rf2.mspHelper.writeU8(message.payload, data.stuck_rotor_protection.value)
    rf2.mspHelper.writeU8(message.payload, encodeTimingAdvance(data.timing_advance.value, data.timing_advance_encoding))
    rf2.mspHelper.writeU8(message.payload, data.pwm_frequency.value)
    rf2.mspHelper.writeU8(message.payload, data.startup_power.value)
    rf2.mspHelper.writeU8(message.payload, encodeMotorKv(data.motor_kv.value))
    rf2.mspHelper.writeU8(message.payload, data.motor_poles.value)
    rf2.mspHelper.writeU8(message.payload, data.brake_on_stop.value)
    rf2.mspHelper.writeU8(message.payload, data.stall_protection.value)
    rf2.mspHelper.writeU8(message.payload, data.beep_volume.value)
    rf2.mspHelper.writeU8(message.payload, data.interval_telemetry.value)
    rf2.mspHelper.writeU8(message.payload, encodeServoLow(data.servo_low_threshold.value))
    rf2.mspHelper.writeU8(message.payload, encodeServoHigh(data.servo_high_threshold.value))
    rf2.mspHelper.writeU8(message.payload, encodeServoNeutral(data.servo_neutral.value))
    rf2.mspHelper.writeU8(message.payload, data.servo_dead_band.value)
    rf2.mspHelper.writeU8(message.payload, data.low_voltage_cutoff.value)
    rf2.mspHelper.writeU8(message.payload, encodeLowVoltageThreshold(data.low_voltage_threshold.value))
    rf2.mspHelper.writeU8(message.payload, data.rc_car_reversing.value)
    rf2.mspHelper.writeU8(message.payload, data.use_hall_sensors.value)
    rf2.mspHelper.writeU8(message.payload, data.sine_mode_range.value)
    rf2.mspHelper.writeU8(message.payload, data.brake_strength.value)
    rf2.mspHelper.writeU8(message.payload, data.running_brake_level.value)
    rf2.mspHelper.writeU8(message.payload, data.temperature_limit.value)
    rf2.mspHelper.writeU8(message.payload, encodeCurrentLimit(data.current_limit.value))
    rf2.mspHelper.writeU8(message.payload, data.sine_mode_power.value)
    rf2.mspHelper.writeU8(message.payload, data.esc_protocol.value)
    rf2.mspHelper.writeU8(message.payload, data.auto_advance.value)

    rf2.mspQueue:add(message)
end

return {
    read = getEscParameters,
    write = setEscParameters,
    getDefaults = getDefaults
}
