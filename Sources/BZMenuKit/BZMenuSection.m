#import "BZMenuSection.h"

@implementation BZMenuSection

+ (instancetype)functionSectionWithItems:(NSArray<BZMenuItem *> *)items {
    BZMenuSection *section = [[self alloc] init];
    section.kind = BZMenuSectionKindFunction;
    section.items = items;
    return section;
}

+ (instancetype)infoSectionWithItems:(NSArray<BZMenuItem *> *)items {
    BZMenuSection *section = [[self alloc] init];
    section.kind = BZMenuSectionKindInfo;
    section.items = items;
    return section;
}

@end
