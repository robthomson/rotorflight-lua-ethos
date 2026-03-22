local template = rf2.executeScript(rf2.radio.template)
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}

local function openEscPage(target)
    rf2.esc4wayTool = "blheli_s"
    rf2.esc4wayTarget = target
    rf2.esc4wayActiveTool = nil
    rf2.esc4wayActiveTarget = nil
    rf2.overrideCurrentPage("esc_blheli_s", string.format("BLHeli_S / Bluejay Setup / ESC%d", target + 1))
end

labels[1] = { t = "Select ESC target", x = x, y = incY(lineSpacing) }
labels[2] = { t = "The page will switch 4way target before reading.", x = x + indent, y = incY(lineSpacing), bold = false }

fields[1] = { t = "[BLHeli_S (ESC1)]", x = x + indent, y = incY(lineSpacing * 2), preEdit = function() openEscPage(0) end }
fields[2] = { t = "[BLHeli_S (ESC2)]", x = x + indent, y = incY(lineSpacing), preEdit = function() openEscPage(1) end }

return {
    read = function(self)
        rf2.onPageReady(self)
    end,
    write = nil,
    title = "BLHeli_S Select",
    labels = labels,
    fields = fields,
    readOnly = false
}
