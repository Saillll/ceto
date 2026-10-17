# firmware · 设备端固件（LuatOS）

> 基于 **Air780EGH** 的 LuatOS 二次开发固件，待编写。

## 计划结构

```
firmware/
├── main.lua            # 入口：初始化 + 主循环
├── config.lua          # 设备ID/名字/云参数（电脑烧录时配置）
├── drivers/
│   ├── ds18b20.lua     # 水温（onewire）
│   ├── sht31.lua       # 气温湿度（i2c）
│   ├── battery.lua     # 电量（adc.CH_VBAT）
│   ├── eink.lua        # 2.9" 墨水屏 SSD1680
│   └── gnss.lua        # GPS 定位（libgnss）
├── net/
│   ├── mqtt_client.lua # MQTT/TLS 上报 + 断网重连
│   └── ntp.lua         # NTP 对时（北京时间）
└── ui/
    └── display.lua     # 墨水屏排版（水温为主）
```

## 上报数据格式

```json
{
  "dev_id": "ceto-001",
  "dev_name": "SY-Changqing",
  "iccid": "8986xxxxxxxxxxxxxx",
  "water_temp": 3.5,
  "air_temp": -20.1,
  "humidity": 45.2,
  "battery": 85,
  "lat": 43.9123,
  "lng": 128.7654,
  "ts": 1730000000
}
```

## 关键点

- 5 分钟上报，长连接，低功耗模式
- GPS：开机 1 次 + 每天 1 次
- 断网重连（不补数据）
- 看门狗 `wdt`
- FOTA `libfota`
- 墨水屏变化时局部刷新
