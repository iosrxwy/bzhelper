#import <UIKit/UIKit.h>
#import "BZMenuSection.h"
#import "BZMenuTheming.h"
#import "BZMenuRowView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BZMenuSectionView : UIView

@property (nonatomic, strong, readonly) BZMenuSection *section;
@property (nonatomic, copy) NSArray<BZMenuRowView *> *rowViews;

- (instancetype)initWithSection:(BZMenuSection *)section theme:(id<BZMenuTheming>)theme;
- (CGFloat)layoutInWidth:(CGFloat)width;
- (nullable BZMenuRowView *)rowViewForIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
