#import <UIKit/UIKit.h>
#import "BZMenuConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class BZMenuPanel;

@protocol BZMenuPanelDelegate <NSObject>
@optional
- (void)menuPanel:(BZMenuPanel *)panel didToggleItem:(BZMenuItem *)item on:(BOOL)on;
- (void)menuPanel:(BZMenuPanel *)panel didChangeSlider:(BZMenuItem *)item value:(float)value;
- (void)menuPanel:(BZMenuPanel *)panel didSelectSegment:(BZMenuItem *)item index:(NSInteger)index;
- (void)menuPanel:(BZMenuPanel *)panel didTapItem:(BZMenuItem *)item;
- (void)menuPanelDidTapClose:(BZMenuPanel *)panel;
- (void)menuPanelDidTapLeadingButton:(BZMenuPanel *)panel;
- (void)menuPanelDidLongPressClose:(BZMenuPanel *)panel;
- (void)menuPanel:(BZMenuPanel *)panel didChangeTheme:(BZMenuThemeStyle)style;
@end

@interface BZMenuPanel : UIView

@property (nonatomic, strong, readonly) BZMenuConfiguration *configuration;
@property (nonatomic, weak, nullable) id<BZMenuPanelDelegate> delegate;

+ (instancetype)presentInView:(UIView *)hostView
                configuration:(BZMenuConfiguration *)configuration
                     delegate:(nullable id<BZMenuPanelDelegate>)delegate;

- (instancetype)initWithConfiguration:(BZMenuConfiguration *)configuration NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

- (void)showInView:(UIView *)hostView;
- (void)dismissAnimated:(BOOL)animated;
- (void)setThemeStyle:(BZMenuThemeStyle)style animated:(BOOL)animated;
- (void)reloadRows;

@end

NS_ASSUME_NONNULL_END
