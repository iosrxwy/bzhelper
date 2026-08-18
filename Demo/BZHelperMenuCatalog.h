#import "BZMenuKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface BZHelperMenuCatalog : NSObject

+ (BZMenuConfiguration *)configuration;
+ (void)persistItem:(BZMenuItem *)item;

@end

NS_ASSUME_NONNULL_END
