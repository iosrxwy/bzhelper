#import <Foundation/Foundation.h>
#import "BZMenuItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BZMenuSectionKind) {
    BZMenuSectionKindFunction = 0,
    BZMenuSectionKindInfo
};

@interface BZMenuSection : NSObject

@property (nonatomic, assign) BZMenuSectionKind kind;
@property (nonatomic, copy) NSArray<BZMenuItem *> *items;

+ (instancetype)functionSectionWithItems:(NSArray<BZMenuItem *> *)items;
+ (instancetype)infoSectionWithItems:(NSArray<BZMenuItem *> *)items;

@end

NS_ASSUME_NONNULL_END
