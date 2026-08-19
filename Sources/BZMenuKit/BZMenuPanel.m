#import "BZMenuPanel.h"
#import "BZMenuAppearance.h"
#import "BZMenuMetrics.h"
#import "BZMenuSectionView.h"

@interface BZMenuPanel ()
@property (nonatomic, strong, readwrite) BZMenuConfiguration *configuration;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *leadingButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, copy) NSArray<BZMenuSectionView *> *sectionViews;
@end

@implementation BZMenuPanel

+ (instancetype)presentInView:(UIView *)hostView
                configuration:(BZMenuConfiguration *)configuration
                     delegate:(id<BZMenuPanelDelegate>)delegate {
    BZMenuPanel *panel = [[self alloc] initWithConfiguration:configuration];
    panel.delegate = delegate;
    [panel showInView:hostView];
    return panel;
}

- (instancetype)initWithConfiguration:(BZMenuConfiguration *)configuration {
    self = [super initWithFrame:CGRectMake(0, 0, BZMenuPanelWidth, BZMenuPanelHeight)];
    if (self) {
        _configuration = configuration;
        [_configuration loadPersistedThemeIfNeeded];
        self.layer.cornerRadius = BZMenuPanelCornerRadius;
        self.clipsToBounds = NO;
        [self rebuild];
    }
    return self;
}

- (id<BZMenuTheming>)currentTheme {
    return BZMenuThemeWithStyle(self.configuration.theme);
}

- (void)showInView:(UIView *)hostView {
    if (self.superview == hostView) {
        return;
    }
    self.center = hostView.center;
    [hostView addSubview:self];
}

- (void)dismissAnimated:(BOOL)animated {
    void (^removal)(void) = ^{
        [self removeFromSuperview];
    };
    if (!animated) {
        removal();
        return;
    }
    [UIView animateWithDuration:BZMenuThemeFadeDuration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        removal();
        self.alpha = 1;
    }];
}

- (void)setThemeStyle:(BZMenuThemeStyle)style animated:(BOOL)animated {
    if (self.configuration.theme == style && self.sectionViews.count > 0) {
        return;
    }
    self.configuration.theme = style;
    [self.configuration persistTheme];
    CGPoint center = self.center;
    [self rebuild];
    self.center = center;
    if ([self.delegate respondsToSelector:@selector(menuPanel:didChangeTheme:)]) {
        [self.delegate menuPanel:self didChangeTheme:style];
    }
    if (animated) {
        self.alpha = 0;
        [UIView animateWithDuration:BZMenuThemeFadeDuration animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)reloadRows {
    for (BZMenuSectionView *sectionView in self.sectionViews) {
        for (BZMenuRowView *row in sectionView.rowViews) {
            [row syncFromItem];
        }
    }
}

- (void)rebuild {
    for (UIView *subview in self.subviews.copy) {
        [subview removeFromSuperview];
    }
    self.sectionViews = @[];
    [self.currentTheme applyToPanel:self];
    [self buildChrome];
    [self buildContent];
}

- (void)buildChrome {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BZMenuPanelWidth, BZMenuHeaderHeight)];
    self.titleLabel.text = self.configuration.title;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [BZMenuAppearance titleFont];
    self.titleLabel.backgroundColor = UIColor.clearColor;
    self.titleLabel.textColor = [BZMenuAppearance labelColor];
    [BZMenuAppearance applyTextShadowToLabel:self.titleLabel];
    [self addSubview:self.titleLabel];

    if (self.configuration.showsCloseButton) {
        self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.closeButton.frame = CGRectMake(BZMenuPanelWidth - 35.0, 5.0, 30.0, 30.0);
        [self.closeButton setTitle:@"−" forState:UIControlStateNormal];
        [self.closeButton setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
        self.closeButton.titleLabel.font = [UIFont systemFontOfSize:24];
        [self.closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(closeLongPressed:)];
        press.minimumPressDuration = 1.3;
        [self.closeButton addGestureRecognizer:press];
        [self addSubview:self.closeButton];
    }

    if (self.configuration.showsLeadingButton) {
        self.leadingButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.leadingButton.frame = CGRectMake(5.0, 5.0, 30.0, 30.0);
        [self.leadingButton setTitle:@"×" forState:UIControlStateNormal];
        [self.leadingButton setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
        self.leadingButton.titleLabel.font = [UIFont systemFontOfSize:24];
        [self.leadingButton addTarget:self action:@selector(leadingTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leadingButton];
    }

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 2;
    [self addGestureRecognizer:doubleTap];
}

- (void)buildContent {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, BZMenuHeaderHeight, BZMenuPanelWidth, BZMenuPanelHeight - BZMenuHeaderHeight)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.clipsToBounds = YES;
    [self addSubview:self.scrollView];

    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BZMenuPanelWidth, 0)];
    [self.scrollView addSubview:self.contentView];

    NSMutableArray<BZMenuSectionView *> *sectionViews = [NSMutableArray array];
    CGFloat y = BZMenuPadding;
    id<BZMenuTheming> theme = self.currentTheme;
    for (BZMenuSection *section in self.configuration.sections) {
        BZMenuSectionView *sectionView = [[BZMenuSectionView alloc] initWithSection:section theme:theme];
        sectionView.frame = CGRectMake(BZMenuPadding, y, BZMenuPanelWidth - BZMenuPadding * 2.0, 0);
        [sectionView layoutInWidth:CGRectGetWidth(sectionView.frame)];
        [self bindRowsInSectionView:sectionView];
        [self.contentView addSubview:sectionView];
        [sectionViews addObject:sectionView];
        y = CGRectGetMaxY(sectionView.frame) + BZMenuPadding;
    }
    self.sectionViews = [sectionViews copy];
    if (self.configuration.footerNote.length > 0) {
        UILabel *footer = [[UILabel alloc] init];
        footer.text = self.configuration.footerNote;
        footer.font = [BZMenuAppearance noteFont];
        footer.textColor = UIColor.lightGrayColor;
        footer.textAlignment = NSTextAlignmentCenter;
        footer.numberOfLines = 0;
        [BZMenuAppearance applyTextShadowToLabel:footer];
        CGFloat footerWidth = BZMenuPanelWidth - BZMenuPadding * 2.0;
        CGSize size = [footer sizeThatFits:CGSizeMake(footerWidth, CGFLOAT_MAX)];
        footer.frame = CGRectMake(BZMenuPadding, y, footerWidth, ceil(size.height));
        [self.contentView addSubview:footer];
        y = CGRectGetMaxY(footer.frame) + BZMenuPadding;
    }
    self.contentView.frame = CGRectMake(0, 0, BZMenuPanelWidth, y + BZMenuPadding);
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)bindRowsInSectionView:(BZMenuSectionView *)sectionView {
    __weak typeof(self) weakSelf = self;
    for (BZMenuRowView *row in sectionView.rowViews) {
        row.valueHandler = ^(BZMenuItem *item) {
            [weakSelf handleValueChange:item];
        };
        row.tapHandler = ^(BZMenuItem *item) {
            [weakSelf handleTap:item];
        };
        row.longPressHandler = ^(BZMenuItem *item) {
            [weakSelf handleItemLongPress:item];
        };
    }
}

- (void)handleValueChange:(BZMenuItem *)item {
    switch (item.type) {
        case BZMenuItemTypeSwitch:
            if ([self.delegate respondsToSelector:@selector(menuPanel:didToggleItem:on:)]) {
                [self.delegate menuPanel:self didToggleItem:item on:item.on];
            }
            break;
        case BZMenuItemTypeSlider:
            if ([self.delegate respondsToSelector:@selector(menuPanel:didChangeSlider:value:)]) {
                [self.delegate menuPanel:self didChangeSlider:item value:item.sliderValue];
            }
            break;
        case BZMenuItemTypeSegment:
            if ([self.delegate respondsToSelector:@selector(menuPanel:didSelectSegment:index:)]) {
                [self.delegate menuPanel:self didSelectSegment:item index:item.selectedIndex];
            }
            break;
        default:
            break;
    }
}

- (void)handleTap:(BZMenuItem *)item {
    if (item.urlString.length > 0) {
        NSURL *url = [NSURL URLWithString:item.urlString];
        if (url) {
            [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
        }
    }
    if ([self.delegate respondsToSelector:@selector(menuPanel:didTapItem:)]) {
        [self.delegate menuPanel:self didTapItem:item];
    }
}

- (void)handleItemLongPress:(BZMenuItem *)item {
    if (!item.togglesThemeOnLongPress) {
        return;
    }
    [BZMenuAppearance performImpact];
    [self setThemeStyle:BZMenuThemeStyleByToggling(self.configuration.theme) animated:YES];
}

- (void)closeTapped {
    if ([self.delegate respondsToSelector:@selector(menuPanelDidTapClose:)]) {
        [self.delegate menuPanelDidTapClose:self];
    }
    [self dismissAnimated:YES];
}

- (void)closeLongPressed:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) {
        return;
    }
    [BZMenuAppearance performImpact];
    if ([self.delegate respondsToSelector:@selector(menuPanelDidLongPressClose:)]) {
        [self.delegate menuPanelDidLongPressClose:self];
    }
}

- (void)leadingTapped {
    if ([self.delegate respondsToSelector:@selector(menuPanelDidTapLeadingButton:)]) {
        [self.delegate menuPanelDidTapLeadingButton:self];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    UIView *host = self.superview;
    if (!host) {
        return;
    }
    CGPoint translation = [pan translationInView:host];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:host];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [self dismissAnimated:YES];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:BZMenuPanelCornerRadius].CGPath;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [self.currentTheme applyToPanel:self];
            for (BZMenuSectionView *sectionView in self.sectionViews) {
                [self.currentTheme applyToSection:sectionView];
            }
        }
    }
}

@end
