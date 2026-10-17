--[[
    ds18b20.lua —— 水温（1-Wire）
    说明：DS18B20 数据线必须加 4.7kΩ 上拉到 3.3V。
    库：LuatOS onewire（API 以官方文档为准）
]]

local onewire = require "onewire"

local M = {}

local PIN

function M.init(pin)
    PIN = pin
    onewire.setup(1, PIN)   -- 具体 API 对照官方 onewire 文档/demo
end

-- 读温度（℃），失败返回 nil
function M.read()
    -- 1) 复位
    if not onewire.reset(1) then return nil end
    -- 2) 跳过 ROM + 启动转换
    onewire.write(1, 0xCC)
    onewire.write(1, 0x44)
    sys.wait(750)           -- 12bit 转换约 750ms
    -- 3) 复位 + 跳过 ROM + 读暂存器
    if not onewire.reset(1) then return nil end
    onewire.write(1, 0xCC)
    onewire.write(1, 0xBE)
    local b = {}
    for i = 1, 9 do b[i] = onewire.read(1) end
    if not b[1] then return nil end
    local raw = b[1] | (b[2] << 8)
    local t = raw / 16.0
    return t
end

return M
