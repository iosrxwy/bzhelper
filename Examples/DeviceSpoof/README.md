# 设备与电量伪装示例

这是从宝藏助手整理出的独立示例，只包含：

- `UIDevice` 的设备类别、设备名称与系统版本
- 电量百分比、充电状态与电池监控状态
- `uname`、`sysctl`、`sysctlbyname` 读取的 `hw.machine`
- 宿主 App 内 `MGCopyAnswer` 的常见设备字段

不包含 IDFA、IDFV、ATT 授权、一键新机、Keychain、定位、缓存清理或其他宝藏助手功能。

## 使用

该示例面向已越狱设备上的 Theos/Logos tweak 开发，默认关闭伪装。先把
`BZDeviceSpoofExample.plist` 中的 `com.example.target` 改为测试 App 的 Bundle ID：

```sh
make package
```

在自己的设置 UI 中保存配置并开启：

```objc
#import "BZDeviceSpoof.h"

[BZDeviceSpoof applyMachine:@"iPhone15,4"
                       model:@"iPhone"
               marketingName:@"iPhone 15"
                  deviceName:@"iPhone"
               systemVersion:@"17.6.1"
                batteryLevel:72
                 batteryState:UIDeviceBatteryStateUnplugged];
BZDeviceSpoof.enabled = YES;
```

传入空的 `systemVersion` 会保留真实系统版本。所有设置保存在目标 App 自己的
`NSUserDefaults` 中，不同 App 互不共享。

## 实现边界

C 函数重绑定仅作用于主可执行文件和 App Bundle 内的镜像，不修改系统共享缓存，
也会跳过 tweak 自身。部分 App 会缓存设备信息，修改设置后可能需要重启目标 App。

仅用于你拥有或获准测试的设备与 App。App Store 应用不应集成运行时 Hook。

`BZFishhook.c` 基于 Facebook fishhook，并保留 BSD 3-Clause 许可证声明。
