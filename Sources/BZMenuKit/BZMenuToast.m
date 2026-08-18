#import "BZMenuToast.h"

@implementation BZMenuToast

+ (void)show:(NSString *)message {
    [self show:message inView:nil];
}

+ (void)show:(NSString *)message inView:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *host = view;
        if (!host) {
            host = UIApplication.sharedApplication.windows.firstObject;
        }
        if (!host || message.length == 0) {
            return;
        }

        UIView *toastView = [[UIView alloc] init];
        toastView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.15 alpha:0.95];
        toastView.layer.cornerRadius = 18.0;
        toastView.alpha = 0;
        toastView.layer.shadowColor = UIColor.blackColor.CGColor;
        toastView.layer.shadowOffset = CGSizeMake(0, 2);
        toastView.layer.shadowOpacity = 0.3;
        toastView.layer.shadowRadius = 4;

        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.text = message;
        messageLabel.textColor = UIColor.whiteColor;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:14];
        messageLabel.numberOfLines = 0;
        [toastView addSubview:messageLabel];
        [host addSubview:toastView];

        CGSize textSize = [message boundingRectWithSize:CGSizeMake(host.bounds.size.width - 100, CGFLOAT_MAX)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName: messageLabel.font}
                                                context:nil].size;
        CGFloat padding = 12.0;
        CGFloat toastWidth = textSize.width + padding * 2.0;
        CGFloat toastHeight = textSize.height + padding * 2.0;
        toastView.frame = CGRectMake((host.bounds.size.width - toastWidth) / 2.0,
                                     host.bounds.size.height / 7.0,
                                     toastWidth,
                                     toastHeight);
        messageLabel.frame = CGRectMake(padding, padding, textSize.width, textSize.height);

        [UIView animateWithDuration:0.3 animations:^{
            toastView.alpha = 1;
            toastView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                toastView.transform = CGAffineTransformIdentity;
            }];
        }];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                toastView.alpha = 0;
                toastView.transform = CGAffineTransformMakeScale(0.95, 0.95);
            } completion:^(BOOL finished) {
                [toastView removeFromSuperview];
            }];
        });
    });
}

@end
