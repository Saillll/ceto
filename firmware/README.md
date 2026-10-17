# firmware · 设备端固件（LuatOS）

> 基于 **Air780EGH** 的 LuatOS 二次开发固件骨架。
> **各库具体 API 以合宙官方文档 / 对应 demo 为准**（本骨架给出结构与逻辑）。

## 目录结构

```
firmware/
├── main.lua            # 入口：初始化 + 主循环
├── config.lua          # 设备ID/名字/引脚/云参数（烧录前修改）
├── drivers/
│   ├── ds18b20.lua     # 水温（onewire）
│   ├── sht31.lua       # 气温湿度（i2c）
│   ├── battery.lua     # 电量（adc.CH_VBAT）
│   ├── eink.lua        # 2.9" 墨水屏 SSD1680（变化时局部刷新）
│   └── gnss.lua        # GPS 定位（libgnss）
└── net/
    ├── mqtt_client.lua # MQTT/TLS 上报 + 断网重连
    └── ntp.lua         # NTP 对时（北京时间）
```

## 运行流程

```
开机 → 初始化(wdt/外设/联网/NTP/MQTT/低功耗)
     → GPS 定位一次
主循环（每 5 分钟）：
     读 水温 + 气温 + 湿度 + 电量
     → 墨水屏（变化时刷新：水温为主，气温/湿度/时间次之）
     → MQTT 上报（含 GPS/ICCID/ID/名字）
每天：GPS 定位一次
全程：看门狗 + 断网重连 + 低功耗模式
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

## 待补全（对照官方 demo）

- [ ] `onewire` DS18B20 读写 API 具体名
- [ ] `i2c` SHT31 收发 API
- [ ] `eink`/`epd` 2.9" SSD1680 驱动与绘图 API
- [ ] `libgnss` 定位 API 与事件
- [ ] `mqtt` 腾讯云接入（三元组、Topic、TLS）
- [ ] `socket` NTP 对时 API
- [ ] 低功耗 `pm` 模式设置与唤醒

## 关键点

- 5 分钟上报，长连接，低功耗模式
- GPS：开机 1 次 + 每天 1 次
- 断网重连（不补数据）
- 看门狗 `wdt`
- FOTA `libfota`
- 墨水屏变化时局部刷新
