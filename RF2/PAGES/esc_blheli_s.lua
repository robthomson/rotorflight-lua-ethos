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
local mspEscBlheliS = "mspEscBlheliS"
local escParameters = rf2.useApi(mspEscBlheliS).getDefaults()

local FIELD_IDX = {
    motor_direction = 1,
    startup_power = 2,
    commutation_timing = 3,
    demag_compensation = 4,
    brake_on_stop = 5,
    temperature_protection = 6,
    beep_strength = 7,
    beacon_strength = 8,
    beacon_delay = 9,
    ppm_min_throttle = 10,
    ppm_max_throttle = 11,
    ppm_center_throttle = 12,
}

local function updateConditionalFields(page)
    fields[FIELD_IDX.ppm_center_throttle].readOnly = escParameters.motor_direction.value < 2
end

local function onControlChange(field, page)
    updateConditionalFields(page)
end

labels[1] = { t = "ESC not ready, waiting...", x = x,          y = incY(lineSpacing) }
labels[2] = { t = "---",                       x = x + indent, y = incY(lineSpacing), bold = false }
labels[3] = { t = "---",                       x = x + indent, y = incY(lineSpacing), bold = false }

labels[4] = { t = "Basic",                    x = x,          y = incY(lineSpacing * 2) }
fields[FIELD_IDX.motor_direction]     = { t = "Motor Direction",       x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 150, data = escParameters.motor_direction, change = onControlChange }
fields[FIELD_IDX.startup_power]       = { t = "Startup Power",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.startup_power }
fields[FIELD_IDX.commutation_timing]  = { t = "Motor Timing",          x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 150, data = escParameters.commutation_timing }
fields[FIELD_IDX.demag_compensation]  = { t = "Demag Compensation",    x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 150, data = escParameters.demag_compensation }
fields[FIELD_IDX.brake_on_stop]       = { t = "Brake On Stop",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.brake_on_stop }

labels[5] = { t = "Advanced",                 x = x,          y = incY(lineSpacing * 2) }
fields[FIELD_IDX.temperature_protection] = { t = "Temp Protection",    x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 150, data = escParameters.temperature_protection }
fields[FIELD_IDX.beep_strength]         = { t = "Beep Strength",       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.beep_strength }
fields[FIELD_IDX.beacon_strength]       = { t = "Beacon Strength",     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.beacon_strength }
fields[FIELD_IDX.beacon_delay]          = { t = "Beacon Delay",        x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 150, data = escParameters.beacon_delay }

labels[6] = { t = "Input",                    x = x,          y = incY(lineSpacing * 2) }
fields[FIELD_IDX.ppm_min_throttle]     = { t = "PPM Min (us)",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.ppm_min_throttle }
fields[FIELD_IDX.ppm_max_throttle]     = { t = "PPM Max (us)",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.ppm_max_throttle }
fields[FIELD_IDX.ppm_center_throttle]  = { t = "PPM Center (us)",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.ppm_center_throttle }

local function receivedEscParameters(page, data)
    page.switchPending = false
    page.readPending = false

    if data.esc_signature ~= 193 then
        page.labels[1].t = "Invalid ESC detected"
    else
        if data.main_revision == 0 then
            page.labels[1].t = string.format("Bluejay ESC%d", (rf2.esc4wayTarget or 0) + 1)
        else
            page.labels[1].t = string.format("BLHeli_S ESC%d", (rf2.esc4wayTarget or 0) + 1)
        end
        page.labels[2].t = string.format("FW: %d.%d", data.main_revision or 0, data.sub_revision or 0)
        page.labels[3].t = string.format("Revision: %d", data.layout_revision or 0)
        updateConditionalFields(page)
        page.readOnly = false
    end

    rf2.onPageReady(page)
end

    return {
        read = function(self)
        local target = rf2.esc4wayTarget

        if rf2.esc4wayTool ~= "blheli_s" or target == nil then
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
            rf2.useApi(mspEscBlheliS).read(receivedEscParameters, self, escParameters)
        end

        if rf2.esc4wayActiveTool == "blheli_s" and rf2.esc4wayActiveTarget == target then
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

            rf2.esc4wayActiveTool = "blheli_s"
            rf2.esc4wayActiveTarget = selectedTarget
            readEsc()
        end, self)
    end,
    write = function(self)
        rf2.useApi(mspEscBlheliS).write(escParameters)
        rf2.settingsSaved(false, false)
    end,
    title       = "BLHeli_S / Bluejay Setup",
    labels      = labels,
    fields      = fields,
    readOnly    = true
}
