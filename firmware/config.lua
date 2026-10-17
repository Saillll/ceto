--[[
    config.lua —— 设备配置
    电脑上用 Luatools 烧录前，按现场修改本文件。

    注意：具体 GPIO 号以 Air780EGH 核心板丝印/原理图为准。
]]

return {
    -- ===== 设备标识 =====
    dev_id   = "ceto-001",        -- 自定义设备 ID
    dev_name = "SY-Changqing",    -- 城市-基地名（SY=沈阳，Changqing=长青基地）

    -- ===== 上报 =====
    report_interval = 5 * 60 * 1000,          -- 上报间隔：5 分钟
    gps_interval    = 24 * 60 * 60 * 1000,    -- GPS 间隔：每天（另加开机一次）

    -- ===== 引脚（占位，按核心板丝印修改）=====
    pin_ds18b20 = 1,   -- DS18B20 数据线（需 4.7k 上拉到 3.3V）
    pin_i2c_sda = 2,   -- SHT31 SDA
    pin_i2c_scl = 3,   -- SHT31 SCL
    i2c_id      = 0,
    sht31_addr  = 0x44,

    -- 墨水屏 2.9" SSD1680（SPI）
    eink = {
        spi_id = 0,
        pin_cs  = 4,
        pin_dc  = 5,
        pin_rst = 6,
        pin_busy = 7,
    },

    -- ===== 腾讯云 IoT（三元组 + MQTT 接入）=====
    mqtt = {
        host      = "xxx.iotcloud.tencentdevices.com", -- 腾讯云 IoT MQTT 地址
        port      = 8883,                              -- TLS
        client_id = "",                                -- 按腾讯云规则拼
        username  = "",                                -- 三元组计算得到
        password  = "",                                -- 三元组计算得到
        keepalive = 60,
        tls       = true,
    },
}
