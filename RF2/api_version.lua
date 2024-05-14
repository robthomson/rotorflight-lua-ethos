local MSP_API_VERSION = 1

local apiVersionReceived = false
local lastRunTS = 0
local INTERVAL = 50

local function processMspReply(cmd,rx_buf,err)
    if cmd == MSP_API_VERSION and #rx_buf >= 3 and not err then
        rf2.apiVersion = rx_buf[2] + rx_buf[3] / 100
        apiVersionReceived = true
    end
end

local function getApiVersion()
    if not apiVersionReceived and (lastRunTS == 0 or lastRunTS + INTERVAL < rf2.getTime()) then
        rf2.protocol.mspRead(MSP_API_VERSION)
        lastRunTS = rf2.getTime()
    end

    mspProcessTxQ()
    processMspReply(mspPollReply())

    return apiVersionReceived
end

return { f = getApiVersion, t = "Waiting for API version" }
