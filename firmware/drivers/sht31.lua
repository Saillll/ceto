--[[
    sht31.lua —— 气温 / 湿度（I2C）
    库：LuatOS i2c（API 以官方文档为准）
]]

local i2c = require "i2c"

local M = {}
local ID, ADDR

function M.init(id, sda, scl, addr)
    ID, ADDR = id or 0, addr or 0x44
    i2c.setup(ID, sda, scl, i2c.FAST)
end

-- 返回 temp(℃), humi(%RH)；失败返回 nil
function M.read()
    -- 单次高重复度测量，无时钟拉伸：0x2C06
    i2c.send(ID, ADDR, {0x2C, 0x06})
    sys.wait(20)
    local d = i2c.recv(ID, ADDR, 6)
    if not d or #d < 6 then return nil end
    local t_raw = (d[1] << 8) | d[2]
    local h_raw = (d[4] << 8) | d[5]
    local temp = -45 + 175 * t_raw / 65535.0
    local humi = 100 * h_raw / 65535.0
    return temp, humi
end

return M
