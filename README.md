# bzhelper

宝藏助手开源版，先放出双套主题主菜单 UI（`BZMenuKit`）。

视觉对齐现网主菜单：320×450、默认 / 液态玻璃、标题栏、拖拽、功能区 + 信息区。开关和入口是 Demo，不含 Hook、去广告实现或内购逻辑。

This repository currently publishes the overlay menu UI used by 宝藏助手. The look matches the shipping panel; feature rows are inert.

## 预览

用 Xcode 打开 [`BZMenuKit.xcodeproj`](BZMenuKit.xcodeproj)，跑 `BZMenuKitDemo`。

- 启动后自动弹出菜单
- 长按「插件版本」在默认主题和液态玻璃之间切换
- 右上角 `−` 收起，左上角 `×` 弹出重启确认（Demo 不会杀进程）
- 双指双击收起

## 嵌入

最低 iOS 13。把 `Sources/BZMenuKit` 拖进工程，或用 Swift Package 指向本仓库。

```objc
#import "BZMenuKit.h"

BZMenuConfiguration *config = [BZMenuConfiguration new];
config.title = @"iOS宝藏";
config.theme = BZMenuThemeStyleGlass;
config.themePersistenceKey = @"bz_menu_theme";
config.sections = @[
    [BZMenuSection functionSectionWithItems:@[
        [BZMenuItem switchItem:@"boost" title:@"广告加速" on:NO],
        [BZMenuItem sliderItem:@"rate" title:@"加速倍数" value:20 min:1 max:300],
    ]],
    [BZMenuSection infoSectionWithItems:@[
        [BZMenuItem valueItem:@"version" title:@"插件版本" value:@"1.6.7"],
    ]],
];
[BZMenuPanel presentInView:self.view configuration:config delegate:self];
```

主题由 `BZMenuTheming` 绘制，行由 `BZMenuItem` 声明。宿主只提供数据和回调。

## 目录

```
Sources/BZMenuKit/   可复用 UI 组件
Demo/                现网主菜单外观 Demo
```

## 许可证

[MIT](LICENSE)
