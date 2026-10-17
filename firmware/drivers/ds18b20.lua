--[[
    ds18b20.lua —— 水温（1-Wire）
    说明：DS18B20 数据线必须加 4.7kΩ 上拉到 3.3V。
    库：LuatOS onewire
    官方 API（docs.openluat.com/osapi/core/onewire/）：
      onewire.init(id) / onewire.reset(id, need_ack) / onewire.bit(id, bit)
      onewire.tx(id, data, is_msb, need_reset, need_ack)
      onewire.rx(id, len, cmd, buff, is_msb, need_reset, need_ack)
      onewire.deinit(id)

    ⚠️ 待核实：onewire.init(id) 的 id 是否为 GPIO 号（以官方 demo 为准）。
]]

local onewire = require "onewire"

local M = {}
local ID

function M.init(pin)
    ID = pin
    onewire.init(ID)
end

-- 读温度（℃），失败返回 nil
function M.read()
    -- 复位（需要存在应答）
    if not onewire.reset(ID, true) then return nil end
    -- 跳过 ROM(0xCC) + 启动转换(0x44)
    onewire.tx(ID, string.char(0xCC, 0x44), false, true, false)
    sys.wait(750)   -- 12bit 转换约 750ms
    -- 复位 + 跳过 ROM + 读暂存器(0xBE)
    if not onewire.reset(ID, true) then return nil end
    local buff = zbuff.create(9)
    onewire.rx(ID, 9, string.char(0xCC, 0xBE), buff, false, true, false)
    local lo = buff:get(0)
    local hi = buff:get(1)
    if not lo or not hi then return nil end
    local raw = lo | (hi << 8)
    if raw >= 0x8000 then raw = raw - 0x10000 end
    return raw / 16.0
end

return M
