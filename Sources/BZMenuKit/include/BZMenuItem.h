#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BZMenuItemType) {
    BZMenuItemTypeSwitch = 0,
    BZMenuItemTypeSlider,
    BZMenuItemTypeSegment,
    BZMenuItemTypeDisclosure,
    BZMenuItemTypeValue,
    BZMenuItemTypeNote
};

@interface BZMenuItem : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BZMenuItemType type;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) float sliderValue;
@property (nonatomic, assign) float sliderMinimumValue;
@property (nonatomic, assign) float sliderMaximumValue;
@property (nonatomic, copy) NSString *sliderValueFormat;
@property (nonatomic, strong, nullable) UIColor *sliderTintColor;
@property (nonatomic, copy) NSArray<NSString *> *segmentOptions;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy, nullable) NSString *valueText;
@property (nonatomic, assign) BOOL togglesThemeOnLongPress;
@property (nonatomic, assign) BOOL usesAccentColor;
@property (nonatomic, copy, nullable) NSString *noteText;
@property (nonatomic, copy, nullable) NSString *urlString;

+ (instancetype)switchItem:(NSString *)identifier title:(NSString *)title on:(BOOL)on;
+ (instancetype)sliderItem:(NSString *)identifier
                     title:(NSString *)title
                     value:(float)value
                       min:(float)min
                       max:(float)max;
+ (instancetype)segmentItem:(NSString *)identifier
                      title:(NSString *)title
                    options:(NSArray<NSString *> *)options
                   selected:(NSInteger)selected;
+ (instancetype)disclosureItem:(NSString *)identifier title:(NSString *)title;
+ (instancetype)valueItem:(NSString *)identifier title:(NSString *)title value:(NSString *)value;
+ (instancetype)noteItem:(NSString *)identifier text:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
