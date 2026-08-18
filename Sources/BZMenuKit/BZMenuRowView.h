#import <UIKit/UIKit.h>
#import "BZMenuItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface BZMenuRowView : UIView

@property (nonatomic, strong, readonly) BZMenuItem *item;
@property (nonatomic, copy, nullable) void (^valueHandler)(BZMenuItem *item);
@property (nonatomic, copy, nullable) void (^tapHandler)(BZMenuItem *item);
@property (nonatomic, copy, nullable) void (^longPressHandler)(BZMenuItem *item);

- (instancetype)initWithItem:(BZMenuItem *)item;
- (CGFloat)heightThatFitsWidth:(CGFloat)width;
- (void)syncFromItem;

@end

NS_ASSUME_NONNULL_END
