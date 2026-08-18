#import "DemoViewController.h"
#import "BZHelperMenuCatalog.h"

@interface DemoViewController ()
@property (nonatomic, strong) CAGradientLayer *backgroundGradient;
@property (nonatomic, copy) NSArray<UIView *> *orbs;
@property (nonatomic, strong) BZMenuPanel *panel;
@property (nonatomic, strong) UIButton *showButton;
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self installWallpaper];
    [self installShowButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.panel.superview) {
        [self presentMenu];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgroundGradient.frame = self.view.bounds;
    CGSize size = self.view.bounds.size;
    NSArray<NSValue *> *centers = @[
        [NSValue valueWithCGPoint:CGPointMake(size.width * 0.18, size.height * 0.22)],
        [NSValue valueWithCGPoint:CGPointMake(size.width * 0.82, size.height * 0.30)],
        [NSValue valueWithCGPoint:CGPointMake(size.width * 0.60, size.height * 0.78)]
    ];
    [self.orbs enumerateObjectsUsingBlock:^(UIView *orb, NSUInteger idx, BOOL *stop) {
        orb.center = centers[idx].CGPointValue;
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)installWallpaper {
    self.backgroundGradient = [CAGradientLayer layer];
    self.backgroundGradient.colors = @[
        (id)[UIColor colorWithRed:0.18 green:0.29 blue:0.55 alpha:1].CGColor,
        (id)[UIColor colorWithRed:0.45 green:0.22 blue:0.55 alpha:1].CGColor,
        (id)[UIColor colorWithRed:0.12 green:0.42 blue:0.40 alpha:1].CGColor
    ];
    self.backgroundGradient.locations = @[ @0.0, @0.5, @1.0 ];
    self.backgroundGradient.startPoint = CGPointMake(0, 0);
    self.backgroundGradient.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:self.backgroundGradient atIndex:0];

    NSMutableArray<UIView *> *orbs = [NSMutableArray array];
    [orbs addObject:[self addOrbWithColor:[UIColor colorWithRed:1 green:0.75 blue:0.85 alpha:0.55] size:220]];
    [orbs addObject:[self addOrbWithColor:[UIColor colorWithRed:0.55 green:0.85 blue:1 alpha:0.50] size:260]];
    [orbs addObject:[self addOrbWithColor:[UIColor colorWithRed:0.70 green:1 blue:0.80 alpha:0.40] size:240]];
    self.orbs = orbs;

    UILabel *hint = [[UILabel alloc] init];
    hint.translatesAutoresizingMaskIntoConstraints = NO;
    hint.text = @"宝藏助手 · 开源主菜单";
    hint.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    hint.textColor = [UIColor colorWithWhite:1 alpha:0.86];
    hint.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:hint];
    [NSLayoutConstraint activateConstraints:@[
        [hint.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [hint.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:28]
    ]];
}

- (UIView *)addOrbWithColor:(UIColor *)color size:(CGFloat)size {
    UIView *orb = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    orb.backgroundColor = color;
    orb.layer.cornerRadius = size / 2.0;
    [self.view addSubview:orb];
    return orb;
}

- (void)installShowButton {
    self.showButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.showButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.showButton setTitle:@"显示菜单" forState:UIControlStateNormal];
    self.showButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.showButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.showButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.18];
    self.showButton.layer.cornerRadius = 16;
    self.showButton.contentEdgeInsets = UIEdgeInsetsMake(10, 18, 10, 18);
    [self.showButton addTarget:self action:@selector(presentMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.showButton];
    [NSLayoutConstraint activateConstraints:@[
        [self.showButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.showButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-28]
    ]];
}

- (void)presentMenu {
    if (self.panel.superview) {
        return;
    }
    self.panel = [BZMenuPanel presentInView:self.view
                              configuration:[BZHelperMenuCatalog configuration]
                                   delegate:self];
}

- (void)menuPanel:(BZMenuPanel *)panel didToggleItem:(BZMenuItem *)item on:(BOOL)on {
    [BZHelperMenuCatalog persistItem:item];
    [BZMenuAppearance performImpact];
    [BZMenuToast show:[NSString stringWithFormat:@"%@ %@", item.title, on ? @"已开启" : @"已关闭"]];
}

- (void)menuPanel:(BZMenuPanel *)panel didChangeSlider:(BZMenuItem *)item value:(float)value {
    [BZHelperMenuCatalog persistItem:item];
}

- (void)menuPanel:(BZMenuPanel *)panel didSelectSegment:(BZMenuItem *)item index:(NSInteger)index {
    [BZHelperMenuCatalog persistItem:item];
}

- (void)menuPanel:(BZMenuPanel *)panel didTapItem:(BZMenuItem *)item {
    [BZMenuToast show:[NSString stringWithFormat:@"打开%@", item.title]];
}

- (void)menuPanelDidLongPressClose:(BZMenuPanel *)panel {
    [panel dismissAnimated:YES];
}

- (void)menuPanelDidTapLeadingButton:(BZMenuPanel *)panel {
    [BZMenuToast show:@"这是演示按钮"];
}

- (void)menuPanel:(BZMenuPanel *)panel didChangeTheme:(BZMenuThemeStyle)style {
    NSString *name = BZMenuThemeWithStyle(style).displayName;
    [BZMenuToast show:[NSString stringWithFormat:@"已切换到%@", name]];
}

@end
