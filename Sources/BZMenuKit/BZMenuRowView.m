#import "BZMenuRowView.h"
#import "BZMenuAppearance.h"
#import "BZMenuMetrics.h"

@interface BZMenuRowView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *accessoryLabel;
@property (nonatomic, strong) UISwitch *toggle;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UISegmentedControl *segment;
@end

@implementation BZMenuRowView

- (instancetype)initWithItem:(BZMenuItem *)item {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _item = item;
        [self build];
    }
    return self;
}

- (void)build {
    switch (self.item.type) {
        case BZMenuItemTypeSwitch:
            [self buildSwitch];
            break;
        case BZMenuItemTypeSlider:
            [self buildSlider];
            break;
        case BZMenuItemTypeSegment:
            [self buildSegment];
            break;
        case BZMenuItemTypeDisclosure:
            [self buildDisclosure];
            break;
        case BZMenuItemTypeValue:
            [self buildValue];
            break;
        case BZMenuItemTypeNote:
            [self buildNote];
            break;
    }
}

- (UILabel *)makeTitleLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [BZMenuAppearance rowFont];
    label.textColor = self.item.usesAccentColor ? [BZMenuAppearance accentColor] : [BZMenuAppearance labelColor];
    label.text = self.item.title;
    [BZMenuAppearance applyTextShadowToLabel:label];
    return label;
}

- (void)buildSwitch {
    self.titleLabel = [self makeTitleLabel];
    [self addSubview:self.titleLabel];

    self.toggle = [[UISwitch alloc] init];
    self.toggle.on = self.item.on;
    self.toggle.enabled = self.item.enabled;
    [self.toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.toggle];
}

- (void)buildSlider {
    self.titleLabel = [self makeTitleLabel];
    [self addSubview:self.titleLabel];

    self.slider = [[UISlider alloc] init];
    self.slider.minimumValue = self.item.sliderMinimumValue;
    self.slider.maximumValue = self.item.sliderMaximumValue;
    self.slider.value = self.item.sliderValue;
    self.slider.enabled = self.item.enabled;
    self.slider.tintColor = self.item.sliderTintColor ?: [BZMenuAppearance sliderTintColor];
    [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.slider];

    self.accessoryLabel = [[UILabel alloc] init];
    self.accessoryLabel.font = [BZMenuAppearance rowFont];
    self.accessoryLabel.textColor = [BZMenuAppearance labelColor];
    self.accessoryLabel.textAlignment = NSTextAlignmentRight;
    [self updateSliderText];
    [self addSubview:self.accessoryLabel];
}

- (void)buildSegment {
    self.titleLabel = [self makeTitleLabel];
    [self addSubview:self.titleLabel];

    self.segment = [[UISegmentedControl alloc] initWithItems:self.item.segmentOptions];
    self.segment.selectedSegmentIndex = self.item.selectedIndex;
    self.segment.enabled = self.item.enabled;
    [self.segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.segment];
}

- (void)buildDisclosure {
    self.titleLabel = [self makeTitleLabel];
    [self addSubview:self.titleLabel];

    self.accessoryLabel = [[UILabel alloc] init];
    self.accessoryLabel.text = @"≻";
    self.accessoryLabel.font = [BZMenuAppearance rowFont];
    self.accessoryLabel.textColor = self.item.usesAccentColor ? UIColor.blueColor : [BZMenuAppearance arrowColor];
    self.accessoryLabel.textAlignment = NSTextAlignmentRight;
    [BZMenuAppearance applyTextShadowToLabel:self.accessoryLabel];
    [self addSubview:self.accessoryLabel];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
}

- (void)buildValue {
    self.titleLabel = [self makeTitleLabel];
    [self addSubview:self.titleLabel];

    self.accessoryLabel = [[UILabel alloc] init];
    self.accessoryLabel.text = self.item.valueText;
    self.accessoryLabel.font = [BZMenuAppearance rowFont];
    self.accessoryLabel.textColor = [BZMenuAppearance labelColor];
    self.accessoryLabel.textAlignment = NSTextAlignmentRight;
    [BZMenuAppearance applyTextShadowToLabel:self.accessoryLabel];
    [self addSubview:self.accessoryLabel];

    if (self.item.togglesThemeOnLongPress) {
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        press.minimumPressDuration = 1.0;
        [self addGestureRecognizer:press];
        self.userInteractionEnabled = YES;
    }
}

- (void)buildNote {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.item.noteText;
    self.titleLabel.font = [BZMenuAppearance noteFont];
    self.titleLabel.textColor = UIColor.lightGrayColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [BZMenuAppearance applyTextShadowToLabel:self.titleLabel];
    [self addSubview:self.titleLabel];
}

- (CGSize)fittedSwitchSize {
    self.toggle.transform = CGAffineTransformIdentity;
    [self.toggle sizeToFit];
    CGSize size = self.toggle.bounds.size;
    if (size.width < 1.0 || size.height < 1.0) {
        size = self.toggle.intrinsicContentSize;
    }
    if (size.width < 1.0 || size.height < 1.0) {
        size = CGSizeMake(BZMenuSwitchWidth, 31.0);
    }
    return size;
}

- (CGFloat)heightThatFitsWidth:(CGFloat)width {
    if (self.item.type == BZMenuItemTypeSlider) {
        return BZMenuRowHeight * 2.0 + BZMenuPadding;
    }
    if (self.item.type == BZMenuItemTypeSwitch) {
        return MAX(BZMenuRowHeight, ceil([self fittedSwitchSize].height));
    }
    if (self.item.type == BZMenuItemTypeNote) {
        CGSize size = [self.item.noteText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName: [BZMenuAppearance noteFont]}
                                                       context:nil].size;
        return ceil(size.height);
    }
    return BZMenuRowHeight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);

    switch (self.item.type) {
        case BZMenuItemTypeSwitch: {
            CGSize switchSize = [self fittedSwitchSize];
            CGFloat rowHeight = CGRectGetHeight(self.bounds);
            self.toggle.frame = CGRectMake(width - switchSize.width,
                                           (rowHeight - switchSize.height) / 2.0,
                                           switchSize.width,
                                           switchSize.height);
            self.titleLabel.frame = CGRectMake(0, 0, width - switchSize.width - 8.0, rowHeight);
            break;
        }
        case BZMenuItemTypeSlider:
            self.titleLabel.frame = CGRectMake(0, 0, width - 70.0, BZMenuRowHeight);
            self.slider.frame = CGRectMake(0, BZMenuRowHeight + BZMenuPadding, width - 50.0, BZMenuRowHeight);
            self.accessoryLabel.frame = CGRectMake(width - 50.0, BZMenuRowHeight + BZMenuPadding, 50.0, BZMenuRowHeight);
            break;
        case BZMenuItemTypeSegment:
            self.titleLabel.frame = CGRectMake(0, 0, 80.0, BZMenuRowHeight);
            self.segment.frame = CGRectMake(90.0, 0, width - 90.0, BZMenuRowHeight);
            break;
        case BZMenuItemTypeDisclosure:
            self.titleLabel.frame = CGRectMake(0, 0, width - 30.0, BZMenuRowHeight);
            self.accessoryLabel.frame = CGRectMake(width - 30.0, 0, 30.0, BZMenuRowHeight);
            break;
        case BZMenuItemTypeValue: {
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
            self.accessoryLabel.textAlignment = NSTextAlignmentRight;
            CGFloat valueWidth = [self.accessoryLabel sizeThatFits:CGSizeMake(width, BZMenuRowHeight)].width;
            valueWidth = MIN(width * 0.45, MAX(ceil(valueWidth), 1.0));
            self.titleLabel.frame = CGRectMake(0, 0, width - valueWidth - 8.0, BZMenuRowHeight);
            self.accessoryLabel.frame = CGRectMake(width - valueWidth, 0, valueWidth, BZMenuRowHeight);
            break;
        }
        case BZMenuItemTypeNote:
            self.titleLabel.frame = self.bounds;
            break;
    }
}

- (void)syncFromItem {
    if (self.toggle) {
        self.toggle.on = self.item.on;
        self.toggle.enabled = self.item.enabled;
    }
    if (self.slider) {
        self.slider.value = self.item.sliderValue;
        self.slider.enabled = self.item.enabled;
        [self updateSliderText];
    }
    if (self.segment) {
        self.segment.selectedSegmentIndex = self.item.selectedIndex;
        self.segment.enabled = self.item.enabled;
    }
}

- (void)updateSliderText {
    NSString *format = self.item.sliderValueFormat.length ? self.item.sliderValueFormat : @"%.1fx";
    self.accessoryLabel.text = [NSString stringWithFormat:format, self.item.sliderValue];
}

- (void)toggleChanged:(UISwitch *)sender {
    self.item.on = sender.isOn;
    if (self.valueHandler) {
        self.valueHandler(self.item);
    }
}

- (void)sliderChanged:(UISlider *)sender {
    self.item.sliderValue = sender.value;
    [self updateSliderText];
    if (self.valueHandler) {
        self.valueHandler(self.item);
    }
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    self.item.selectedIndex = sender.selectedSegmentIndex;
    if (self.valueHandler) {
        self.valueHandler(self.item);
    }
}

- (void)handleTap {
    if (self.tapHandler) {
        self.tapHandler(self.item);
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan && self.longPressHandler) {
        self.longPressHandler(self.item);
    }
}

@end
