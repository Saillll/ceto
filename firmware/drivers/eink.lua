--[[
    eink.lua —— 2.9" 墨水屏（SSD1680 对应 eink.MODEL_2in9_V2 等）
    库：LuatOS eink
    官方 API（docs.openluat.com/osapi/core/eink/）：
      eink.setup(mode, spiid, pin_busy, pin_reset, pin_dc, pin_cs)
      eink.init(driver_ic, param, spi_device)
      eink.setWin(width, height, rotate) / eink.clear(color, force)
      eink.setFont(font) / eink.print(x, y, str, color)
      eink.show(x, y, noClear) / eink.qrcode(...) / eink.bat(x,y,bat)
      eink.sleep()
      屏幕常量：eink.MODEL_2in9 / MODEL_2in9_V2 / MODEL_2in9d ...
      字体：eink.font_opposansm16 / font_opposansm32 / *_chinese

    ⚠️ 待核实：2.9" SSD1680 对应的确切 eink.MODEL_* 常量（以官方 eink demo 为准）。
    策略：常亮；水温/气温/湿度变化时刷新，减少耗电。
]]

local eink = require "eink"

local M = {}
local last = {}

function M.init(c)
    -- 绑定 SPI 与 4 根控制脚
    eink.setup(0, c.spi_id, c.pin_busy, c.pin_rst, c.pin_dc, c.pin_cs)
    -- 初始化 2.9" 墨水屏（具体 MODEL 常量以官方 demo 为准）
    eink.init(eink.MODEL_2in9_V2)
    eink.clear(0, true)
end

-- 画一屏：水温为主，气温/湿度/时间次之
function M.render(d)
    eink.clear(0, false)
    eink.setFont(eink.font_opposansm16)
    eink.print(0, 0, d.dev_name or "", 0)
    eink.setFont(eink.font_opposansm32)
    eink.print(0, 24, string.format("水温 %.1f C", d.water_temp or 0), 0)
    eink.setFont(eink.font_opposansm16)
    eink.print(0, 64, string.format("气温 %.1f C  湿度 %.0f%%", d.air_temp or 0, d.humidity or 0), 0)
    eink.print(0, 88, d.time_str or "", 0)
    eink.show(0, 0, false)
end

-- 变化时刷新
function M.updateIfChanged(d)
    local key = string.format("%.1f|%.1f|%.0f|%s",
        d.water_temp or -999, d.air_temp or -999, d.humidity or -999, d.time_str or "")
    if key ~= last.key then
        M.render(d)
        last.key = key
    end
end

return M
