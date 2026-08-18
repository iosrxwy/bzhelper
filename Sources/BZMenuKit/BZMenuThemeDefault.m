#import "BZMenuThemeDefault.h"
#import "BZMenuAppearance.h"
#import "BZMenuGlassBackdrop.h"
#import "BZMenuMetrics.h"

@implementation BZMenuThemeDefault

- (BZMenuThemeStyle)style {
    return BZMenuThemeStyleDefault;
}

- (NSString *)displayName {
    return @"默认主题";
}

- (void)applyToPanel:(UIView *)panel {
    BZMenuStripThemeDecorations(panel);
    panel.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *trait) {
        if (trait.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return [UIColor colorWithWhite:0.2 alpha:0.9];
        }
        return [UIColor colorWithWhite:1.0 alpha:0.9];
    }];
    panel.layer.cornerRadius = BZMenuPanelCornerRadius;
    panel.layer.masksToBounds = NO;
    panel.layer.shadowColor = UIColor.blackColor.CGColor;
    panel.layer.shadowOffset = CGSizeMake(0, 5);
    panel.layer.shadowOpacity = 0.5;
    panel.layer.shadowRadius = 10;
    panel.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:panel.bounds cornerRadius:BZMenuPanelCornerRadius].CGPath;
}

- (void)applyToSection:(UIView *)section {
    BZMenuStripThemeDecorations(section);
    section.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *trait) {
        if (trait.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return [UIColor colorWithWhite:0.3 alpha:0.8];
        }
        return [UIColor colorWithWhite:1.0 alpha:0.8];
    }];
    section.layer.cornerRadius = BZMenuSectionCornerRadius;
    section.layer.masksToBounds = NO;
}

@end
