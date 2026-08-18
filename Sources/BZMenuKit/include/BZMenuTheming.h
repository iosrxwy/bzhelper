#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BZMenuThemeStyle) {
    BZMenuThemeStyleDefault = 0,
    BZMenuThemeStyleGlass = 1
};

@protocol BZMenuTheming <NSObject>
@property (nonatomic, readonly) BZMenuThemeStyle style;
@property (nonatomic, copy, readonly) NSString *displayName;
- (void)applyToPanel:(UIView *)panel;
- (void)applyToSection:(UIView *)section;
@end

id<BZMenuTheming> BZMenuThemeWithStyle(BZMenuThemeStyle style);
BZMenuThemeStyle BZMenuThemeStyleByToggling(BZMenuThemeStyle style);

NS_ASSUME_NONNULL_END
