local function setTarget(target, callback, callbackParam)
    local message = {
        command = 244, -- MSP_SET_4WAY_IF
        payload = {},
        processReply = function(self, buf)
            if callback then
                callback(callbackParam, true, target)
            end
        end,
        errorHandler = function(self)
            if callback then
                callback(callbackParam, false, target)
            end
        end,
        simulatorResponse = { 0 }
    }

    rf2.mspHelper.writeU8(message.payload, target or 0)
    rf2.mspQueue:add(message)
end

return {
    setTarget = setTarget
}
