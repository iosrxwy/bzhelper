#import "BZMenuSectionView.h"
#import "BZMenuMetrics.h"

@implementation BZMenuSectionView

- (instancetype)initWithSection:(BZMenuSection *)section theme:(id<BZMenuTheming>)theme {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _section = section;
        NSMutableArray<BZMenuRowView *> *rows = [NSMutableArray array];
        for (BZMenuItem *item in section.items) {
            BZMenuRowView *row = [[BZMenuRowView alloc] initWithItem:item];
            [self addSubview:row];
            [rows addObject:row];
        }
        _rowViews = [rows copy];
        [theme applyToSection:self];
    }
    return self;
}

- (CGFloat)layoutInWidth:(CGFloat)width {
    CGFloat y = BZMenuPadding;
    CGFloat innerWidth = width - BZMenuPadding * 2.0;
    for (BZMenuRowView *row in self.rowViews) {
        CGFloat height = [row heightThatFitsWidth:innerWidth];
        row.frame = CGRectMake(BZMenuPadding, y, innerWidth, height);
        y = CGRectGetMaxY(row.frame) + BZMenuPadding;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, y);
    return y;
}

- (BZMenuRowView *)rowViewForIdentifier:(NSString *)identifier {
    for (BZMenuRowView *row in self.rowViews) {
        if ([row.item.identifier isEqualToString:identifier]) {
            return row;
        }
    }
    return nil;
}

@end
