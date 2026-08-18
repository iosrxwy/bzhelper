#import "BZMenuItem.h"
#import "BZMenuAppearance.h"

@implementation BZMenuItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = YES;
        _sliderMinimumValue = 1.0;
        _sliderMaximumValue = 5.0;
        _sliderValue = 1.0;
        _sliderValueFormat = @"%.1fx";
        _segmentOptions = @[];
    }
    return self;
}

+ (instancetype)switchItem:(NSString *)identifier title:(NSString *)title on:(BOOL)on {
    BZMenuItem *item = [[self alloc] init];
    item.identifier = identifier;
    item.title = title;
    item.type = BZMenuItemTypeSwitch;
    item.on = on;
    return item;
}

+ (instancetype)sliderItem:(NSString *)identifier
                     title:(NSString *)title
                     value:(float)value
                       min:(float)min
                       max:(float)max {
    BZMenuItem *item = [[self alloc] init];
    item.identifier = identifier;
    item.title = title;
    item.type = BZMenuItemTypeSlider;
    item.sliderValue = value;
    item.sliderMinimumValue = min;
    item.sliderMaximumValue = max;
    item.sliderTintColor = [BZMenuAppearance sliderTintColor];
    return item;
}

+ (instancetype)segmentItem:(NSString *)identifier
                      title:(NSString *)title
                    options:(NSArray<NSString *> *)options
                   selected:(NSInteger)selected {
    BZMenuItem *item = [[self alloc] init];
    item.identifier = identifier;
    item.title = title;
    item.type = BZMenuItemTypeSegment;
    item.segmentOptions = options;
    item.selectedIndex = selected;
    return item;
}

+ (instancetype)disclosureItem:(NSString *)identifier title:(NSString *)title {
    BZMenuItem *item = [[self alloc] init];
    item.identifier = identifier;
    item.title = title;
    item.type = BZMenuItemTypeDisclosure;
    return item;
}

+ (instancetype)valueItem:(NSString *)identifier title:(NSString *)title value:(NSString *)value {
    BZMenuItem *item = [[self alloc] init];
    item.identifier = identifier;
    item.title = title;
    item.type = BZMenuItemTypeValue;
    item.valueText = value;
    return item;
}

+ (instancetype)noteItem:(NSString *)identifier text:(NSString *)text {
    BZMenuItem *item = [[self alloc] init];
    item.identifier = identifier;
    item.type = BZMenuItemTypeNote;
    item.noteText = text;
    return item;
}

@end
