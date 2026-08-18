#import "BZMenuTheming.h"
#import "BZMenuThemeDefault.h"
#import "BZMenuThemeGlass.h"

id<BZMenuTheming> BZMenuThemeWithStyle(BZMenuThemeStyle style) {
    switch (style) {
        case BZMenuThemeStyleDefault:
            return [[BZMenuThemeDefault alloc] init];
        case BZMenuThemeStyleGlass:
        default:
            return [[BZMenuThemeGlass alloc] init];
    }
}

BZMenuThemeStyle BZMenuThemeStyleByToggling(BZMenuThemeStyle style) {
    return (style == BZMenuThemeStyleGlass) ? BZMenuThemeStyleDefault : BZMenuThemeStyleGlass;
}
