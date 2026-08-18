#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BZMenuGlassTokenSet : NSObject

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat blurAlpha;
@property (nonatomic, assign) CGFloat shadowOffsetY;
@property (nonatomic, assign) CGFloat shadowOpacity;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, copy) NSArray<NSNumber *> *locations;
@property (nonatomic, assign) NSTimeInterval colorDuration;
@property (nonatomic, assign) NSTimeInterval startPointDuration;
@property (nonatomic, assign) NSTimeInterval endPointDuration;
@property (nonatomic, assign) CGPoint animatedStartPoint;
@property (nonatomic, assign) CGPoint animatedEndPoint;
@property (nonatomic, assign) BOOL animatesEndPoint;
@property (nonatomic, copy) NSArray<NSArray<UIColor *> *> *baseColorPairs;
@property (nonatomic, copy) NSArray<NSArray<UIColor *> *> *animationColorPairs;
@property (nonatomic, strong) UIColor *borderLightColor;
@property (nonatomic, strong) UIColor *borderDarkColor;
@property (nonatomic, assign) BOOL isPanel;

+ (instancetype)panelTokens;
+ (instancetype)sectionTokens;
+ (BOOL)supportsSystemGlass;

@end

@interface BZMenuGlassBackdrop : UIView

- (instancetype)initWithTokens:(BZMenuGlassTokenSet *)tokens;
- (void)refreshColorsForTraitCollection:(UITraitCollection *)trait;

@end

void BZMenuStripThemeDecorations(UIView *view);

NS_ASSUME_NONNULL_END
