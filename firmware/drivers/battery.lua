--[[
    battery.lua —— 电池电量（ADC）
    LuatOS 提供 adc.CH_VBAT 直接读供电/电池电压。
]]

local adc = require "adc"

local M = {}

function M.init()
    adc.open(adc.CH_VBAT)
end

-- 读电池电压(mV)
function M.voltage()
    local v = adc.get(adc.CH_VBAT)
    return v
end

-- 电压 → 电量百分比（锂电粗略估算）
function M.percent()
    local mv = M.voltage()
    if not mv then return nil end
    local v = mv / 1000.0
    if v >= 4.15 then return 100 end
    if v <= 3.30 then return 0 end
    -- 3.30~4.15V 线性近似（仅粗估）
    return math.floor((v - 3.30) / (4.15 - 3.30) * 100)
end

return M
