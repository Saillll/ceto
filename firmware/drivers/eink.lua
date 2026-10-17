--[[
    eink.lua —— 2.9" 墨水屏 SSD1680（SPI）
    库：LuatOS eink / epd（API 以官方文档 + 对应屏 demo 为准）

    策略：常亮；水温/气温/湿度变化时局部刷新，减少耗电。
]]

local M = {}

local cfg
local last = {}

function M.init(c)
    cfg = c
    -- eink.setup(spi_id, {cs=, dc=, rst=, busy=, ...})
    -- eink.init(2.9, ...)  -- 按官方 eink demo 填写
end

-- 画一屏：水温为主，气温/湿度/时间次之
function M.render(data)
    -- data = { water_temp, air_temp, humidity, time_str, battery, dev_name }
    -- 例（按官方 demo 的 API）：
    -- eink.clear(0)
    -- eink.setFont(eink.font_opposansm16)
    -- eink.drawStr(0, 0, data.dev_name)
    -- eink.setFont(eink.font_opposansm32)
    -- eink.drawStr(0, 30, string.format("水温 %.1f C", data.water_temp or 0))
    -- eink.setFont(eink.font_opposansm16)
    -- eink.drawStr(0, 70, string.format("气温 %.1f C  湿度 %.0f%%", data.air_temp or 0, data.humidity or 0))
    -- eink.drawStr(0, 90, data.time_str or "")
    -- eink.update()
end

-- 变化时刷新
function M.updateIfChanged(data)
    local key = string.format("%.1f|%.1f|%.0f|%s",
        data.water_temp or -999, data.air_temp or -999, data.humidity or -999, data.time_str or "")
    if key ~= last.key then
        M.render(data)
        last.key = key
    end
end

return M
