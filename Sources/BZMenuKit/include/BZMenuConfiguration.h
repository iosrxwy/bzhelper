#import <Foundation/Foundation.h>
#import "BZMenuSection.h"
#import "BZMenuTheming.h"

NS_ASSUME_NONNULL_BEGIN

@interface BZMenuConfiguration : NSObject <NSCopying>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *versionText;
@property (nonatomic, copy, nullable) NSString *footerNote;
@property (nonatomic, assign) BZMenuThemeStyle theme;
@property (nonatomic, copy) NSArray<BZMenuSection *> *sections;
@property (nonatomic, copy, nullable) NSString *themePersistenceKey;
@property (nonatomic, assign) BOOL showsLeadingButton;
@property (nonatomic, assign) BOOL showsCloseButton;

- (void)loadPersistedThemeIfNeeded;
- (void)persistTheme;

- (nullable BZMenuItem *)itemWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
