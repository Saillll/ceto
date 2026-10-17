--[[
    main.lua —— Ceto 水温监测固件入口（Air780EGH / LuatOS）

    流程：
      开机 → 初始化 → NTP 对时 → GPS 定位一次
      主循环（每 5 分钟）：
        读 DS18B20(水温) + SHT31(气温湿度) + 电量
        → 更新墨水屏（变化时）
        → MQTT 上报（含 GPS/ICCID/ID）
      每天：GPS 定位一次
      全程：看门狗 + 断网重连 + 低功耗模式

    说明：各库具体 API 以合宙官方文档/对应 demo 为准，本骨架给出结构。
]]

local config = require "config"
local ds18b20 = require "drivers.ds18b20"
local sht31   = require "drivers.sht31"
local battery = require "drivers.battery"
local eink    = require "drivers.eink"
local gnss    = require "drivers.gnss"
local mqttcli = require "net.mqtt_client"
local ntp     = require "net.ntp"

local wdt   = require "wdt"
local mobile = require "mobile"
local pm    = require "pm"

local DEV = {
    dev_id   = config.dev_id,
    dev_name = config.dev_name,
    iccid    = nil,
    lat      = nil,
    lng      = nil,
}

-- ================= 初始化 =================
local function init()
    log.info("ceto", "boot", config.dev_id, config.dev_name)

    -- 看门狗（户外无人值守必备）
    wdt.init(90000)
    sys.timerLoopStart(function() wdt.feed() end, 60000)

    -- 设备标识
    DEV.iccid = mobile.iccid()

    -- 外设
    ds18b20.init(config.pin_ds18b20)
    sht31.init(config.i2c_id, config.pin_i2c_sda, config.pin_i2c_scl, config.sht31_addr)
    battery.init()
    eink.init(config.eink)
    gnss.init()

    -- 联网（4G）+ NTP 对时
    -- netdrv / socket 就绪后对时（按官方 demo 等待网络就绪）
    sys.waitUntil("IP_READY", 30000)
    ntp.sync()

    -- MQTT
    mqttcli.init(config.mqtt)

    -- 低功耗模式（长连接）
    pm.power(pm.WORK_MODE, 1)
end

-- ================= 采集 =================
local function collect()
    local d = {}
    d.dev_id   = DEV.dev_id
    d.dev_name = DEV.dev_name
    d.iccid    = DEV.iccid
    d.water_temp = ds18b20.read()
    d.air_temp, d.humidity = sht31.read()
    d.battery  = battery.percent()
    d.lat, d.lng = DEV.lat, DEV.lng
    d.ts       = ntp.ts()
    return d
end

-- ================= 主任务 =================
local function task_main()
    init()

    local last_gps = 0
    while true do
        -- 每天 GPS 一次
        if os.time() - last_gps >= 24 * 3600 then
            local lat, lng = gnss.fix(60000)
            if lat then DEV.lat, DEV.lng = lat, lng end
            last_gps = os.time()
        end

        -- 采集
        local d = collect()

        -- 墨水屏（变化时刷新）
        eink.updateIfChanged({
            dev_name   = DEV.dev_name,
            water_temp = d.water_temp,
            air_temp   = d.air_temp,
            humidity   = d.humidity,
            time_str   = ntp.hhmm(),
        })

        -- 上报（mqtt 库 autoreconn 自动断网重连）
        mqttcli.report(d)

        sys.wait(config.report_interval)
    end
end

sys.taskInit(task_main)
