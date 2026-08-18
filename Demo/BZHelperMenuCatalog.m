#import "BZHelperMenuCatalog.h"

static NSString *BZDemoKey(NSString *name) {
    return [@"BZMenuKit." stringByAppendingString:name];
}

static BOOL BZDemoBool(NSString *name, BOOL fallback) {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if ([defaults objectForKey:BZDemoKey(name)]) {
        return [defaults boolForKey:BZDemoKey(name)];
    }
    return fallback;
}

static NSInteger BZDemoInteger(NSString *name, NSInteger fallback) {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if ([defaults objectForKey:BZDemoKey(name)]) {
        return [defaults integerForKey:BZDemoKey(name)];
    }
    return fallback;
}

static float BZDemoFloat(NSString *name, float fallback) {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if ([defaults objectForKey:BZDemoKey(name)]) {
        return [defaults floatForKey:BZDemoKey(name)];
    }
    return fallback;
}

@implementation BZHelperMenuCatalog

+ (BZMenuConfiguration *)configuration {
    BOOL adBlockOn = BZDemoBool(@"adblock", NO);
    NSInteger mode = BZDemoInteger(@"mode", 0);

    BZMenuItem *boost = [BZMenuItem sliderItem:@"rate" title:@"加速倍数" value:BZDemoFloat(@"rate", 20.0) min:1.0 max:300.0];
    BZMenuItem *modeItem = [BZMenuItem segmentItem:@"mode"
                                            title:@"屏蔽模式"
                                          options:@[@"默认", @"自定义", @"混合"]
                                         selected:mode];
    modeItem.enabled = adBlockOn;

    BZMenuItem *rules = [BZMenuItem segmentItem:@"rules"
                                         title:@"默认规则"
                                       options:@[@"一般", @"增强", @"不当人"]
                                      selected:BZDemoInteger(@"rules", 2)];
    rules.enabled = adBlockOn && mode == 0;

    BZMenuItem *channel = [BZMenuItem disclosureItem:@"channel" title:@"宝藏频道"];
    channel.usesAccentColor = YES;
    channel.urlString = @"https://t.me/iosrxwy";

    BZMenuItem *release = [BZMenuItem disclosureItem:@"release" title:@"发布地址"];
    release.usesAccentColor = YES;
    release.urlString = @"https://github.com/iosrxwy/bzhelper";

    BZMenuItem *version = [BZMenuItem valueItem:@"version" title:@"插件版本" value:@"1.6.7"];
    version.togglesThemeOnLongPress = YES;

    BZMenuItem *thanks = [BZMenuItem noteItem:@"thanks" text:[@[
        @"仅供免费测试，切勿做它用！",
        @"感谢来了老弟在初版中的错误修正",
        @"感谢公众号：十三座州府I的去广告优化",
        @"感谢🌺huami的鼎力支持代码优化及改善建议！"
    ] componentsJoinedByString:@"\n"]];

    BZMenuConfiguration *config = [[BZMenuConfiguration alloc] init];
    config.title = @"iOS宝藏";
    config.versionText = @"1.6.7";
    config.theme = BZMenuThemeStyleGlass;
    config.themePersistenceKey = @"bz_menu_theme";
    config.sections = @[
        [BZMenuSection functionSectionWithItems:@[
            [BZMenuItem switchItem:@"reward" title:@"秒过激励" on:BZDemoBool(@"reward", NO)],
            [BZMenuItem switchItem:@"boost" title:@"广告加速" on:BZDemoBool(@"boost", NO)],
            boost,
            [BZMenuItem switchItem:@"adblock" title:@"广告屏蔽" on:adBlockOn],
            modeItem,
            rules,
            [BZMenuItem disclosureItem:@"edit" title:@"编辑规则"],
            [BZMenuItem switchItem:@"game" title:@"游戏去广" on:BZDemoBool(@"game", NO)],
            [BZMenuItem switchItem:@"shake" title:@"禁用摇广" on:BZDemoBool(@"shake", NO)],
            [BZMenuItem switchItem:@"netblock" title:@"断网去广" on:BZDemoBool(@"netblock", NO)],
            [BZMenuItem switchItem:@"rating" title:@"禁用评分" on:BZDemoBool(@"rating", NO)],
            [BZMenuItem switchItem:@"trail" title:@"触摸轨迹" on:BZDemoBool(@"trail", NO)],
            [BZMenuItem switchItem:@"iap" title:@"内购解锁" on:BZDemoBool(@"iap", NO)],
            [BZMenuItem switchItem:@"monitor" title:@"网络监听" on:BZDemoBool(@"monitor", NO)],
            [BZMenuItem disclosureItem:@"monitor.page" title:@"监听页面"]
        ]],
        [BZMenuSection infoSectionWithItems:@[
            version,
            [BZMenuItem disclosureItem:@"cache" title:@"缓存清理"],
            [BZMenuItem disclosureItem:@"language" title:@"语言切换"],
            channel,
            release,
            thanks
        ]]
    ];
    return config;
}

+ (void)persistItem:(BZMenuItem *)item {
    NSString *key = BZDemoKey(item.identifier);
    switch (item.type) {
        case BZMenuItemTypeSwitch:
            [NSUserDefaults.standardUserDefaults setBool:item.on forKey:key];
            break;
        case BZMenuItemTypeSlider:
            [NSUserDefaults.standardUserDefaults setFloat:item.sliderValue forKey:key];
            break;
        case BZMenuItemTypeSegment:
            [NSUserDefaults.standardUserDefaults setInteger:item.selectedIndex forKey:key];
            break;
        default:
            break;
    }
}

@end
