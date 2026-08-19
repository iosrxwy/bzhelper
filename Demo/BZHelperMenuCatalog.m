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
    BZMenuItem *version = [BZMenuItem valueItem:@"version" title:@"演示版本" value:@"1.0.0"];
    version.togglesThemeOnLongPress = YES;

    BZMenuItem *channel = [BZMenuItem disclosureItem:@"channel" title:@"宝藏频道"];
    channel.usesAccentColor = YES;
    channel.urlString = @"https://t.me/iosrxwy";

    BZMenuItem *release = [BZMenuItem disclosureItem:@"release" title:@"发布地址"];
    release.usesAccentColor = YES;
    release.urlString = @"https://github.com/iosrxwy/bzhelper";

    BZMenuConfiguration *config = [[BZMenuConfiguration alloc] init];
    config.title = @"BZ Menu";
    config.versionText = @"1.0.0";
    config.footerNote = @"当前为开源演示版本。仅含UI 显示。";
    config.theme = BZMenuThemeStyleGlass;
    config.themePersistenceKey = @"bz_menu_theme";
    config.sections = @[
        [BZMenuSection functionSectionWithItems:@[
            [BZMenuItem switchItem:@"demo.switch" title:@"演示开关" on:BZDemoBool(@"demo.switch", YES)],
            [BZMenuItem sliderItem:@"demo.slider" title:@"演示滑杆" value:BZDemoFloat(@"demo.slider", 2.0) min:1.0 max:5.0],
            [BZMenuItem segmentItem:@"demo.mode"
                             title:@"演示模式"
                           options:@[@"选项 A", @"选项 B", @"选项 C"]
                          selected:BZDemoInteger(@"demo.mode", 0)],
            [BZMenuItem disclosureItem:@"demo.page" title:@"演示页面"]
        ]],
        [BZMenuSection infoSectionWithItems:@[
            version,
            channel,
            release
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
