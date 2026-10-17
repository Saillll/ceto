--[[
    mqtt_client.lua —— MQTT/TLS 上报 + 断网重连
    库：LuatOS mqtt
    官方 API（docs.openluat.com/osapi/core/mqtt/）：
      mqtt.create(adapter, host, port, ssl, opts)
      mqttc:auth(client_id, username, password, cleanSession)
      mqttc:keepalive(time) / mqttc:autoreconn(reconnect, reconnect_time)
      mqttc:on(cb) / mqttc:connect() / mqttc:ready()
      mqttc:subscribe(topic, qos) / mqttc:publish(topic, data, qos, retain)
      mqttc:state()  -- STATE_DISCONNECT / STATE_SCONNECT / STATE_MQTT / STATE_READY

    策略：长连接；autoreconn 自动重连（不补数据）。
]]

local mqtt = require "mqtt"
local json = require "json"

local M = {}
local cfg
local cli

local function payload(d)
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
    cli:auth(cfg.client_id, cfg.username, cfg.password, true)
    cli:keepalive(cfg.keepalive or 60)
    cli:autoreconn(true, 3000)   -- 断网自动重连
    cli:on(function(mqttc, evt, data)
        log.info("mqtt", evt)
    end)
    cli:connect()
end

function M.isConnected()
    return cli and cli:state() == mqtt.STATE_READY
end

function M.report(d)
    if not M.isConnected() then return false end
    local topic = cfg.topic or ("$thing/up/property/" .. d.dev_id)  -- 按腾讯云 Topic 规则
    return cli:publish(topic, payload(d), 0)
end

return M
