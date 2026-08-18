#import "BZMenuGlassBackdrop.h"
#import "BZMenuAppearance.h"
#import "BZMenuMetrics.h"

static UIColor *BZRGB(CGFloat r, CGFloat g, CGFloat b, CGFloat a) {
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@implementation BZMenuGlassTokenSet

+ (instancetype)panelTokens {
    BZMenuGlassTokenSet *tokens = [[self alloc] init];
    tokens.cornerRadius = BZMenuPanelCornerRadius;
    tokens.blurAlpha = 0.92;
    tokens.shadowOffsetY = 10.0;
    tokens.shadowOpacity = 0.35;
    tokens.shadowRadius = 25.0;
    tokens.borderWidth = 1.5;
    tokens.locations = @[ @0.0, @0.6, @1.0 ];
    tokens.colorDuration = 4.0;
    tokens.startPointDuration = 6.0;
    tokens.endPointDuration = 5.0;
    tokens.animatedStartPoint = CGPointMake(0.4, 0.4);
    tokens.animatedEndPoint = CGPointMake(0.6, 0.6);
    tokens.animatesEndPoint = YES;
    tokens.baseColorPairs = @[
        @[ BZRGB(0.78, 0.88, 0.98, 0.30), BZRGB(0.15, 0.25, 0.45, 0.30) ],
        @[ BZRGB(0.88, 0.78, 0.98, 0.30), BZRGB(0.25, 0.15, 0.35, 0.28) ],
        @[ BZRGB(0.85, 0.95, 0.90, 0.25), BZRGB(0.20, 0.30, 0.25, 0.25) ]
    ];
    tokens.animationColorPairs = @[
        @[ BZRGB(0.88, 0.78, 0.98, 0.35), BZRGB(0.30, 0.20, 0.40, 0.25) ],
        @[ BZRGB(0.85, 0.95, 0.90, 0.30), BZRGB(0.25, 0.35, 0.30, 0.22) ],
        @[ BZRGB(0.78, 0.88, 0.98, 0.33), BZRGB(0.20, 0.30, 0.50, 0.25) ]
    ];
    tokens.borderLightColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    tokens.borderDarkColor = BZRGB(0.80, 0.85, 0.90, 0.40);
    return tokens;
}

+ (instancetype)sectionTokens {
    BZMenuGlassTokenSet *tokens = [[self alloc] init];
    tokens.cornerRadius = BZMenuSectionCornerRadius;
    tokens.blurAlpha = 0.75;
    tokens.shadowOffsetY = 6.0;
    tokens.shadowOpacity = 0.20;
    tokens.shadowRadius = 12.0;
    tokens.borderWidth = 1.0;
    tokens.locations = @[ @0.0, @0.5, @1.0 ];
    tokens.colorDuration = 5.0;
    tokens.startPointDuration = 7.0;
    tokens.endPointDuration = 0.0;
    tokens.animatedStartPoint = CGPointMake(0.3, 0.3);
    tokens.animatedEndPoint = CGPointMake(1.0, 1.0);
    tokens.animatesEndPoint = NO;
    tokens.baseColorPairs = @[
        @[ BZRGB(0.82, 0.92, 1.00, 0.15), BZRGB(0.18, 0.28, 0.48, 0.12) ],
        @[ BZRGB(0.92, 0.82, 1.00, 0.15), BZRGB(0.28, 0.18, 0.38, 0.12) ],
        @[ BZRGB(0.87, 0.95, 0.92, 0.10), BZRGB(0.22, 0.32, 0.28, 0.10) ]
    ];
    tokens.animationColorPairs = @[
        @[ BZRGB(0.92, 0.82, 1.00, 0.25), BZRGB(0.32, 0.22, 0.42, 0.18) ],
        @[ BZRGB(0.87, 0.95, 0.92, 0.20), BZRGB(0.25, 0.38, 0.32, 0.15) ],
        @[ BZRGB(0.82, 0.92, 1.00, 0.23), BZRGB(0.22, 0.32, 0.52, 0.16) ]
    ];
    tokens.borderLightColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    tokens.borderDarkColor = BZRGB(0.75, 0.80, 0.85, 0.35);
    return tokens;
}

@end

@interface BZMenuGlassBackdrop ()
@property (nonatomic, strong) BZMenuGlassTokenSet *tokens;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) CAGradientLayer *fluidLayer;
@end

@implementation BZMenuGlassBackdrop

- (instancetype)initWithTokens:(BZMenuGlassTokenSet *)tokens {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _tokens = tokens;
        self.userInteractionEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        UIBlurEffect *blur;
        if (@available(iOS 13.0, *)) {
            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
        } else {
            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        }
        _blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blurView.alpha = tokens.blurAlpha;
        _blurView.layer.cornerRadius = tokens.cornerRadius;
        _blurView.layer.masksToBounds = YES;
        [self addSubview:_blurView];

        _fluidLayer = [CAGradientLayer layer];
        _fluidLayer.cornerRadius = tokens.cornerRadius;
        _fluidLayer.locations = tokens.locations;
        _fluidLayer.startPoint = CGPointMake(0, 0);
        _fluidLayer.endPoint = CGPointMake(1, 1);
        [_blurView.contentView.layer addSublayer:_fluidLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.blurView.frame = self.bounds;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.fluidLayer.frame = self.bounds;
    [CATransaction commit];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        [self refreshColorsForTraitCollection:self.traitCollection];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [self refreshColorsForTraitCollection:self.traitCollection];
        }
    }
}

- (void)refreshColorsForTraitCollection:(UITraitCollection *)trait {
    NSArray<id> *fromColors = [BZMenuAppearance resolvedCGColorsFromPairs:self.tokens.baseColorPairs trait:trait];
    NSArray<id> *toColors = [BZMenuAppearance resolvedCGColorsFromPairs:self.tokens.animationColorPairs trait:trait];
    UIColor *border = [BZMenuAppearance resolvedColorWithLight:self.tokens.borderLightColor
                                                          dark:self.tokens.borderDarkColor
                                                         trait:trait];

    [self.fluidLayer removeAllAnimations];
    self.fluidLayer.colors = fromColors;

    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"colors"];
    colorAnimation.duration = self.tokens.colorDuration;
    colorAnimation.repeatCount = HUGE_VALF;
    colorAnimation.autoreverses = YES;
    colorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    colorAnimation.fromValue = fromColors;
    colorAnimation.toValue = toColors;
    [self.fluidLayer addAnimation:colorAnimation forKey:@"fluidColors"];

    CABasicAnimation *startAnimation = [CABasicAnimation animationWithKeyPath:@"startPoint"];
    startAnimation.duration = self.tokens.startPointDuration;
    startAnimation.repeatCount = HUGE_VALF;
    startAnimation.autoreverses = YES;
    startAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    startAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    startAnimation.toValue = [NSValue valueWithCGPoint:self.tokens.animatedStartPoint];
    [self.fluidLayer addAnimation:startAnimation forKey:@"fluidPosition"];

    if (self.tokens.animatesEndPoint) {
        CABasicAnimation *endAnimation = [CABasicAnimation animationWithKeyPath:@"endPoint"];
        endAnimation.duration = self.tokens.endPointDuration;
        endAnimation.repeatCount = HUGE_VALF;
        endAnimation.autoreverses = YES;
        endAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        endAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        endAnimation.toValue = [NSValue valueWithCGPoint:self.tokens.animatedEndPoint];
        [self.fluidLayer addAnimation:endAnimation forKey:@"fluidEndPoint"];
    }

    UIView *host = self.superview;
    if (!host) {
        return;
    }
    host.layer.borderColor = border.CGColor;
}

@end

void BZMenuStripThemeDecorations(UIView *view) {
    for (UIView *subview in view.subviews.copy) {
        if ([subview isKindOfClass:[BZMenuGlassBackdrop class]] ||
            [subview isKindOfClass:[UIVisualEffectView class]]) {
            [subview removeFromSuperview];
        }
    }
    view.layer.shadowOpacity = 0;
    view.layer.borderWidth = 0;
    view.layer.shadowPath = nil;
}
