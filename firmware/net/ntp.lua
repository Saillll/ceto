--[[
    ntp.lua —— NTP 对时（北京时间 UTC+8）
    库：LuatOS socket.ntp / ntp（API 以官方文档为准）
]]

local M = {}

local TZ_OFFSET = 8 * 3600   -- 北京时间 UTC+8

function M.sync()
    -- 例：
    -- socket.ntpSync("ntp.aliyun.com", 8)   -- 按官方 API
    -- 或 socket.ntpSync(nil, 8)
end

-- 返回 "HH:MM" 北京时间
function M.hhmm()
    local t = os.date("*t", os.time() + TZ_OFFSET)
    return string.format("%02d:%02d", t.hour, t.min)
end

-- 返回 Unix 时间戳
function M.ts()
    return os.time()
end

return M
