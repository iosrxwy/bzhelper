#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BZMenuToast : NSObject

+ (void)show:(NSString *)message;
+ (void)show:(NSString *)message inView:(nullable UIView *)view;

@end

NS_ASSUME_NONNULL_END
