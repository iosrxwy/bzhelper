#import "BZDeviceSpoof.h"
#import "BZFishhook.h"

#import <dlfcn.h>
#import <errno.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>
#import <substrate.h>
#import <string.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>

NSString *const BZDeviceSpoofEnabledKey = @"bz_device_spoof.enabled";
NSString *const BZDeviceSpoofMachineKey = @"bz_device_spoof.machine";
NSString *const BZDeviceSpoofModelKey = @"bz_device_spoof.model";
NSString *const BZDeviceSpoofMarketingNameKey = @"bz_device_spoof.marketing_name";
NSString *const BZDeviceSpoofNameKey = @"bz_device_spoof.name";
NSString *const BZDeviceSpoofSystemVersionKey = @"bz_device_spoof.system_version";
NSString *const BZDeviceSpoofBatteryLevelKey = @"bz_device_spoof.battery_level";
NSString *const BZDeviceSpoofBatteryStateKey = @"bz_device_spoof.battery_state";

static __thread BOOL BZReadingDefaults;

static BOOL BZSpoofEnabled(void) {
    if (BZReadingDefaults) return NO;
    BZReadingDefaults = YES;
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:BZDeviceSpoofEnabledKey];
    BZReadingDefaults = NO;
    return value;
}

static NSString *BZString(NSString *key, NSString *fallback) {
    if (BZReadingDefaults) return fallback;
    BZReadingDefaults = YES;
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    BZReadingDefaults = NO;
    return value.length > 0 ? value : fallback;
}

static NSInteger BZInteger(NSString *key, NSInteger fallback) {
    if (BZReadingDefaults) return fallback;
    BZReadingDefaults = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger value = [defaults objectForKey:key] ? [defaults integerForKey:key] : fallback;
    BZReadingDefaults = NO;
    return value;
}

static float BZBatteryLevel(void) {
    NSInteger percentage = MAX(0, MIN(100, BZInteger(BZDeviceSpoofBatteryLevelKey, 85)));
    return (float)percentage / 100.0f;
}

static NSString *(*BZOriginalModel)(id, SEL);
static NSString *(*BZOriginalLocalizedModel)(id, SEL);
static NSString *(*BZOriginalName)(id, SEL);
static NSString *(*BZOriginalSystemVersion)(id, SEL);
static float (*BZOriginalBatteryLevel)(id, SEL);
static UIDeviceBatteryState (*BZOriginalBatteryState)(id, SEL);
static BOOL (*BZOriginalBatteryMonitoringEnabled)(id, SEL);

static NSString *BZHookedModel(id self, SEL command) {
    return BZSpoofEnabled() ? BZString(BZDeviceSpoofModelKey, @"iPhone")
                            : BZOriginalModel(self, command);
}

static NSString *BZHookedLocalizedModel(id self, SEL command) {
    return BZSpoofEnabled() ? BZString(BZDeviceSpoofModelKey, @"iPhone")
                            : BZOriginalLocalizedModel(self, command);
}

static NSString *BZHookedName(id self, SEL command) {
    return BZSpoofEnabled() ? BZString(BZDeviceSpoofNameKey, @"iPhone")
                            : BZOriginalName(self, command);
}

static NSString *BZHookedSystemVersion(id self, SEL command) {
    if (!BZSpoofEnabled()) return BZOriginalSystemVersion(self, command);
    NSString *version = BZString(BZDeviceSpoofSystemVersionKey, @"");
    return version.length > 0 ? version : BZOriginalSystemVersion(self, command);
}

static float BZHookedBatteryLevel(id self, SEL command) {
    return BZSpoofEnabled() ? BZBatteryLevel() : BZOriginalBatteryLevel(self, command);
}

static UIDeviceBatteryState BZHookedBatteryState(id self, SEL command) {
    if (!BZSpoofEnabled()) return BZOriginalBatteryState(self, command);
    NSInteger state = BZInteger(BZDeviceSpoofBatteryStateKey, UIDeviceBatteryStateUnplugged);
    if (state < UIDeviceBatteryStateUnknown || state > UIDeviceBatteryStateFull) {
        state = UIDeviceBatteryStateUnplugged;
    }
    return (UIDeviceBatteryState)state;
}

static BOOL BZHookedBatteryMonitoringEnabled(id self, SEL command) {
    return BZSpoofEnabled() ? YES : BZOriginalBatteryMonitoringEnabled(self, command);
}

typedef int (*BZUnameFunction)(struct utsname *systemInfo);
typedef int (*BZSysctlByNameFunction)(const char *, void *, size_t *, void *, size_t);
typedef int (*BZSysctlFunction)(int *, u_int, void *, size_t *, void *, size_t);
typedef CFTypeRef (*BZMGCopyAnswerFunction)(CFStringRef question);

static BZUnameFunction BZOriginalUname;
static BZSysctlByNameFunction BZOriginalSysctlByName;
static BZSysctlFunction BZOriginalSysctl;
static BZMGCopyAnswerFunction BZOriginalMGCopyAnswer;

// Returns 0 when copied, -1 for a short buffer, and 1 when no spoof is applied.
static int BZCopyCString(NSString *value, void *oldp, size_t *oldlenp) {
    if (!oldlenp || value.length == 0) return 1;
    const char *bytes = value.UTF8String;
    size_t requiredLength = strlen(bytes) + 1;
    if (!oldp) {
        *oldlenp = requiredLength;
        return 0;
    }
    if (*oldlenp < requiredLength) {
        *oldlenp = requiredLength;
        errno = ENOMEM;
        return -1;
    }
    memcpy(oldp, bytes, requiredLength);
    *oldlenp = requiredLength;
    return 0;
}

static int BZHookedUname(struct utsname *systemInfo) {
    if (!BZOriginalUname) {
        errno = ENOSYS;
        return -1;
    }
    int result = BZOriginalUname(systemInfo);
    if (result == 0 && systemInfo && BZSpoofEnabled()) {
        NSString *machine = BZString(BZDeviceSpoofMachineKey, @"iPhone14,5");
        strlcpy(systemInfo->machine, machine.UTF8String, sizeof(systemInfo->machine));
    }
    return result;
}

static int BZHookedSysctlByName(const char *name,
                                void *oldp,
                                size_t *oldlenp,
                                void *newp,
                                size_t newlen) {
    if (BZSpoofEnabled() && name && strcmp(name, "hw.machine") == 0 && newp == NULL) {
        int result = BZCopyCString(BZString(BZDeviceSpoofMachineKey, @"iPhone14,5"), oldp, oldlenp);
        if (result != 1) return result;
    }
    if (!BZOriginalSysctlByName) {
        errno = ENOSYS;
        return -1;
    }
    return BZOriginalSysctlByName(name, oldp, oldlenp, newp, newlen);
}

static int BZHookedSysctl(int *name,
                          u_int nameLength,
                          void *oldp,
                          size_t *oldlenp,
                          void *newp,
                          size_t newlen) {
    if (BZSpoofEnabled() && name && nameLength == 2 &&
        name[0] == CTL_HW && name[1] == HW_MACHINE && newp == NULL) {
        int result = BZCopyCString(BZString(BZDeviceSpoofMachineKey, @"iPhone14,5"), oldp, oldlenp);
        if (result != 1) return result;
    }
    if (!BZOriginalSysctl) {
        errno = ENOSYS;
        return -1;
    }
    return BZOriginalSysctl(name, nameLength, oldp, oldlenp, newp, newlen);
}

static CFTypeRef BZHookedMGCopyAnswer(CFStringRef question) {
    if (BZSpoofEnabled() && question) {
        NSString *key = (__bridge NSString *)question;
        NSString *value = nil;
        if ([key isEqualToString:@"ProductType"]) {
            value = BZString(BZDeviceSpoofMachineKey, @"iPhone14,5");
        } else if ([key isEqualToString:@"MarketingName"]) {
            value = BZString(BZDeviceSpoofMarketingNameKey, @"iPhone 13");
        } else if ([key isEqualToString:@"DeviceName"]) {
            value = BZString(BZDeviceSpoofNameKey, @"iPhone");
        } else if ([key isEqualToString:@"ProductVersion"]) {
            value = BZString(BZDeviceSpoofSystemVersionKey, @"");
        }
        if (value.length > 0) return CFRetain((__bridge CFStringRef)value);
    }
    return BZOriginalMGCopyAnswer ? BZOriginalMGCopyAnswer(question) : NULL;
}

static NSString *BZModulePath(void) {
    Dl_info info = {0};
    return dladdr((const void *)&BZHookedUname, &info) && info.dli_fname
        ? [NSString stringWithUTF8String:info.dli_fname]
        : @"";
}

static BOOL BZShouldRebindImage(const char *imagePath) {
    if (!imagePath) return NO;
    NSString *path = [NSString stringWithUTF8String:imagePath];
    NSString *executablePath = [NSBundle mainBundle].executablePath;
    NSString *bundlePath = [NSBundle mainBundle].bundlePath;
    NSString *modulePath = BZModulePath();
    if ([path isEqualToString:modulePath]) return NO;
    if ([path isEqualToString:executablePath]) return YES;
    return bundlePath.length > 0 &&
           [path hasPrefix:[bundlePath stringByAppendingString:@"/"]];
}

static void BZInstallCFunctionHooks(void) {
    BZOriginalUname = (BZUnameFunction)dlsym(RTLD_DEFAULT, "uname");
    BZOriginalSysctlByName = (BZSysctlByNameFunction)dlsym(RTLD_DEFAULT, "sysctlbyname");
    BZOriginalSysctl = (BZSysctlFunction)dlsym(RTLD_DEFAULT, "sysctl");
    BZOriginalMGCopyAnswer = (BZMGCopyAnswerFunction)dlsym(RTLD_DEFAULT, "MGCopyAnswer");

    struct bz_rebinding rebindings[4] = {
        {"uname", (void *)&BZHookedUname, NULL},
        {"sysctlbyname", (void *)&BZHookedSysctlByName, NULL},
        {"sysctl", (void *)&BZHookedSysctl, NULL},
    };
    size_t count = 3;
    if (BZOriginalMGCopyAnswer) {
        rebindings[count++] = (struct bz_rebinding){"MGCopyAnswer", (void *)&BZHookedMGCopyAnswer, NULL};
    }

    uint32_t imageCount = _dyld_image_count();
    for (uint32_t index = 0; index < imageCount; index++) {
        const char *imagePath = _dyld_get_image_name(index);
        if (!BZShouldRebindImage(imagePath)) continue;
        bz_rebind_symbols_image((void *)_dyld_get_image_header(index),
                                _dyld_get_image_vmaddr_slide(index),
                                rebindings,
                                count);
    }
}

@implementation BZDeviceSpoof

+ (BOOL)isEnabled {
    return BZSpoofEnabled();
}

+ (void)setEnabled:(BOOL)enabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:enabled forKey:BZDeviceSpoofEnabledKey];
    [defaults synchronize];
}

+ (void)applyMachine:(NSString *)machine
               model:(NSString *)model
       marketingName:(NSString *)marketingName
          deviceName:(NSString *)deviceName
       systemVersion:(NSString *)systemVersion
        batteryLevel:(NSInteger)batteryLevel
        batteryState:(UIDeviceBatteryState)batteryState {
    if (machine.length == 0 || model.length == 0 || marketingName.length == 0 || deviceName.length == 0) {
        return;
    }
    batteryLevel = MAX(0, MIN(100, batteryLevel));
    if (batteryState < UIDeviceBatteryStateUnknown || batteryState > UIDeviceBatteryStateFull) {
        batteryState = UIDeviceBatteryStateUnplugged;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:machine forKey:BZDeviceSpoofMachineKey];
    [defaults setObject:model forKey:BZDeviceSpoofModelKey];
    [defaults setObject:marketingName forKey:BZDeviceSpoofMarketingNameKey];
    [defaults setObject:deviceName forKey:BZDeviceSpoofNameKey];
    [defaults setObject:systemVersion ?: @"" forKey:BZDeviceSpoofSystemVersionKey];
    [defaults setInteger:batteryLevel forKey:BZDeviceSpoofBatteryLevelKey];
    [defaults setInteger:batteryState forKey:BZDeviceSpoofBatteryStateKey];
    [defaults synchronize];
}

+ (void)reset {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray<NSString *> *keys = @[
        BZDeviceSpoofEnabledKey,
        BZDeviceSpoofMachineKey,
        BZDeviceSpoofModelKey,
        BZDeviceSpoofMarketingNameKey,
        BZDeviceSpoofNameKey,
        BZDeviceSpoofSystemVersionKey,
        BZDeviceSpoofBatteryLevelKey,
        BZDeviceSpoofBatteryStateKey,
    ];
    for (NSString *key in keys) [defaults removeObjectForKey:key];
    [defaults synchronize];
}

+ (void)install {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{
            BZDeviceSpoofEnabledKey: @NO,
            BZDeviceSpoofMachineKey: @"iPhone14,5",
            BZDeviceSpoofModelKey: @"iPhone",
            BZDeviceSpoofMarketingNameKey: @"iPhone 13",
            BZDeviceSpoofNameKey: @"iPhone",
            BZDeviceSpoofSystemVersionKey: @"",
            BZDeviceSpoofBatteryLevelKey: @85,
            BZDeviceSpoofBatteryStateKey: @(UIDeviceBatteryStateUnplugged),
        }];

        Class deviceClass = UIDevice.class;
        MSHookMessageEx(deviceClass, @selector(model), (IMP)BZHookedModel, (IMP *)&BZOriginalModel);
        MSHookMessageEx(deviceClass, @selector(localizedModel), (IMP)BZHookedLocalizedModel, (IMP *)&BZOriginalLocalizedModel);
        MSHookMessageEx(deviceClass, @selector(name), (IMP)BZHookedName, (IMP *)&BZOriginalName);
        MSHookMessageEx(deviceClass, @selector(systemVersion), (IMP)BZHookedSystemVersion, (IMP *)&BZOriginalSystemVersion);
        MSHookMessageEx(deviceClass, @selector(batteryLevel), (IMP)BZHookedBatteryLevel, (IMP *)&BZOriginalBatteryLevel);
        MSHookMessageEx(deviceClass, @selector(batteryState), (IMP)BZHookedBatteryState, (IMP *)&BZOriginalBatteryState);
        MSHookMessageEx(deviceClass, @selector(isBatteryMonitoringEnabled),
                        (IMP)BZHookedBatteryMonitoringEnabled,
                        (IMP *)&BZOriginalBatteryMonitoringEnabled);
        BZInstallCFunctionHooks();
    });
}

@end

__attribute__((constructor))
static void BZDeviceSpoofLoad(void) {
    [BZDeviceSpoof install];
}
