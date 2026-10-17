--[[
    gnss.lua —— GPS 定位（Air780EGH 内置 GNSS）
    库：LuatOS libgnss / exgnss（API 以官方文档为准）

    策略：开机定位一次 + 每天一次；其余时间关闭 GNSS 省电。
]]

local M = {}

local last_fix = nil   -- {lat=, lng=}

function M.init()
    -- libgnss.init()  -- 按官方 demo
end

-- 定位一次，返回 lat, lng；失败返回 nil
function M.fix(timeout_ms)
    timeout_ms = timeout_ms or 60000
    -- 打开 GNSS，等待定位（有 AGPS 更快）
    -- 例：
    -- gnss.open()
    -- local ok = sys.waitUntil("GNSS_STATE", timeout_ms)
    -- local loc = gnss.getLocation()
    -- gnss.close()
    -- if loc then last_fix = {lat=loc.lat, lng=loc.lng} end
    if last_fix then return last_fix.lat, last_fix.lng end
    return nil
end

function M.last()
    return last_fix
end

return M
