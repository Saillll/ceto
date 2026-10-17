--[[
    mqtt_client.lua —— MQTT/TLS 上报 + 断网重连
    库：LuatOS mqtt（mqttc）/ socket（API 以官方文档为准）

    策略：
      - 长连接，低功耗模式
      - 断网自动重连（不补数据）
      - 上报：水温/气温/湿度/电量/GPS/ICCID/ID
]]

local mqtt = require "mqtt"
local json = require "json"

local M = {}

local cfg
local cli
local connected = false

local function build_payload(d)
    return json.encode({
        dev_id     = d.dev_id,
        dev_name   = d.dev_name,
        iccid      = d.iccid,
        water_temp = d.water_temp,
        air_temp   = d.air_temp,
        humidity   = d.humidity,
        battery    = d.battery,
        lat        = d.lat,
        lng        = d.lng,
        ts         = d.ts,
    })
end

function M.init(c)
    cfg = c
    cli = mqtt.create(nil, cfg.host, cfg.port, cfg.tls)
    cli:auth(cfg.client_id, cfg.username, cfg.password, false)
    cli:keepalive(cfg.keepalive)
    cli:on("conack", function() connected = true end)
    cli:on("discon", function() connected = false end)
end

function M.isConnected() return connected end

function M.report(d)
    if not connected then return false end
    local topic = "$thing/up/property/" .. d.dev_id   -- 按腾讯云 Topic 规则
    local ok = cli:publish(topic, build_payload(d), 0)
    return ok
end

-- 断网重连（在任务里循环调用）
function M.ensure()
    if not connected then
        cli:connect()
        -- 等待 conack，超时返回
        sys.waitUntil("mqtt_conack", 10000)
    end
    return connected
end

return M
