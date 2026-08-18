#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BZMenuAppearance : NSObject

+ (UIFont *)titleFont;
+ (UIFont *)rowFont;
+ (UIFont *)noteFont;
+ (UIColor *)labelColor;
+ (UIColor *)secondaryLabelColor;
+ (UIColor *)arrowColor;
+ (UIColor *)accentColor;
+ (UIColor *)sliderTintColor;

+ (void)applyTextShadowToLabel:(UILabel *)label;
+ (void)performImpact;

+ (UIColor *)resolvedColorWithLight:(UIColor *)light
                               dark:(UIColor *)dark
                              trait:(UITraitCollection *)trait;

+ (NSArray<id> *)resolvedCGColorsFromPairs:(NSArray<NSArray<UIColor *> *> *)lightDarkPairs
                                     trait:(UITraitCollection *)trait;

@end

NS_ASSUME_NONNULL_END
