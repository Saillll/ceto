--[[
    sht31.lua —— 气温 / 湿度（I2C）
    库：LuatOS i2c
    官方 API（docs.openluat.com/osapi/core/i2c/）：
      i2c.setup(id, speed, polling)
      i2c.send(id, addr, data, stop) / i2c.recv(id, addr, len)
      i2c.readSHT30(id, addr)   -- 内置，SHT30/31 兼容，直接返回温湿度
      i2c.scan(id, speed)       -- 扫描总线找地址

    ⚠️ 待核实：i2c 的 SDA/SCL 引脚如何绑定（pins 配置 or 固定映射），以官方 demo 为准。
]]

local i2c = require "i2c"

local M = {}
local ID, ADDR

function M.init(id, addr)
    ID, ADDR = id or 0, addr or 0x44
    -- 注意：i2c.setup 只传 id 与速率；SDA/SCL 由 pins 配置（以官方 demo 为准）
    i2c.setup(ID, i2c.FAST)
end

-- 返回 temp(℃), humi(%RH)；失败返回 nil
function M.read()
    -- 优先用内置 readSHT30（SHT30/31 兼容）
    if i2c.readSHT30 then
        local t, h = i2c.readSHT30(ID, ADDR)
        if t then return t, h end
    end
    -- 兜底：手动发命令读
    i2c.send(ID, ADDR, {0x2C, 0x06})
    sys.wait(20)
    local d = i2c.recv(ID, ADDR, 6)
    if not d or #d < 6 then return nil end
    local t_raw = (d[1] << 8) | d[2]
    local h_raw = (d[4] << 8) | d[5]
    return -45 + 175 * t_raw / 65535.0, 100 * h_raw / 65535.0
end

return M
