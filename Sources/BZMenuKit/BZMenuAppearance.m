#import "BZMenuAppearance.h"
#import "BZMenuMetrics.h"

@implementation BZMenuAppearance

+ (UIFont *)titleFont {
    return [UIFont boldSystemFontOfSize:BZMenuTitleFontSize];
}

+ (UIFont *)rowFont {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:BZMenuRowFontSize];
    return font ?: [UIFont boldSystemFontOfSize:BZMenuRowFontSize];
}

+ (UIFont *)noteFont {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    return font ?: [UIFont systemFontOfSize:12.0];
}

+ (UIColor *)labelColor {
    if (@available(iOS 13.0, *)) {
        return UIColor.labelColor;
    }
    return UIColor.blackColor;
}

+ (UIColor *)secondaryLabelColor {
    if (@available(iOS 13.0, *)) {
        return UIColor.secondaryLabelColor;
    }
    return UIColor.grayColor;
}

+ (UIColor *)arrowColor {
    return UIColor.lightGrayColor;
}

+ (UIColor *)accentColor {
    return [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0];
}

+ (UIColor *)sliderTintColor {
    return UIColor.greenColor;
}

+ (void)applyTextShadowToLabel:(UILabel *)label {
    label.layer.shadowColor = UIColor.blackColor.CGColor;
    label.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    label.layer.shadowOpacity = 0.2;
    label.layer.shadowRadius = 1.0;
}

+ (void)performImpact {
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [generator prepare];
        [generator impactOccurred];
    }
}

+ (UIColor *)resolvedColorWithLight:(UIColor *)light
                               dark:(UIColor *)dark
                              trait:(UITraitCollection *)trait {
    if (@available(iOS 13.0, *)) {
        if (trait.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return dark;
        }
    }
    return light;
}

+ (NSArray<id> *)resolvedCGColorsFromPairs:(NSArray<NSArray<UIColor *> *> *)lightDarkPairs
                                     trait:(UITraitCollection *)trait {
    NSMutableArray<id> *colors = [NSMutableArray arrayWithCapacity:lightDarkPairs.count];
    for (NSArray<UIColor *> *pair in lightDarkPairs) {
        UIColor *color = [self resolvedColorWithLight:pair.firstObject dark:pair.lastObject trait:trait];
        [colors addObject:(id)color.CGColor];
    }
    return colors;
}

@end
