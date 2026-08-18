#import "BZMenuThemeGlass.h"
#import "BZMenuGlassBackdrop.h"
#import "BZMenuMetrics.h"

@implementation BZMenuThemeGlass

- (BZMenuThemeStyle)style {
    return BZMenuThemeStyleGlass;
}

- (NSString *)displayName {
    return @"液态玻璃";
}

- (void)applyTokens:(BZMenuGlassTokenSet *)tokens toView:(UIView *)view {
    BZMenuStripThemeDecorations(view);
    view.backgroundColor = UIColor.clearColor;
    view.layer.cornerRadius = tokens.cornerRadius;
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = UIColor.blackColor.CGColor;
    view.layer.shadowOffset = CGSizeMake(0, tokens.shadowOffsetY);
    view.layer.shadowOpacity = tokens.shadowOpacity;
    view.layer.shadowRadius = tokens.shadowRadius;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:tokens.cornerRadius].CGPath;
    view.layer.borderWidth = tokens.borderWidth;

    BZMenuGlassBackdrop *backdrop = [[BZMenuGlassBackdrop alloc] initWithTokens:tokens];
    backdrop.frame = view.bounds;
    [view insertSubview:backdrop atIndex:0];
    [backdrop refreshColorsForTraitCollection:view.traitCollection];
}

- (void)applyToPanel:(UIView *)panel {
    [self applyTokens:[BZMenuGlassTokenSet panelTokens] toView:panel];
}

- (void)applyToSection:(UIView *)section {
    [self applyTokens:[BZMenuGlassTokenSet sectionTokens] toView:section];
}

@end
