#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BZDeviceSpoofEnabledKey;
FOUNDATION_EXPORT NSString *const BZDeviceSpoofMachineKey;
FOUNDATION_EXPORT NSString *const BZDeviceSpoofModelKey;
FOUNDATION_EXPORT NSString *const BZDeviceSpoofMarketingNameKey;
FOUNDATION_EXPORT NSString *const BZDeviceSpoofNameKey;
FOUNDATION_EXPORT NSString *const BZDeviceSpoofSystemVersionKey;
FOUNDATION_EXPORT NSString *const BZDeviceSpoofBatteryLevelKey;
FOUNDATION_EXPORT NSString *const BZDeviceSpoofBatteryStateKey;

/// Device and battery spoofing for an injected iOS process.
///
/// Hooks are installed automatically when the tweak loads. Spoofing remains
/// disabled until `enabled` is set to YES.
@interface BZDeviceSpoof : NSObject

@property(class, nonatomic, getter=isEnabled) BOOL enabled;

/// Saves a complete profile. Pass an empty system version to keep the real one.
+ (void)applyMachine:(NSString *)machine
               model:(NSString *)model
       marketingName:(NSString *)marketingName
          deviceName:(NSString *)deviceName
       systemVersion:(NSString *)systemVersion
        batteryLevel:(NSInteger)batteryLevel
        batteryState:(UIDeviceBatteryState)batteryState;

/// Removes the saved profile and disables spoofing.
+ (void)reset;

/// Installs the Objective-C and process-local C hooks once.
+ (void)install;

@end

NS_ASSUME_NONNULL_END
