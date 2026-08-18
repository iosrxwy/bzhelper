#import "BZMenuConfiguration.h"

@implementation BZMenuConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
        _title = @"BZ Menu";
        _theme = BZMenuThemeStyleGlass;
        _sections = @[];
        _showsLeadingButton = YES;
        _showsCloseButton = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    BZMenuConfiguration *copy = [[[self class] allocWithZone:zone] init];
    copy.title = self.title;
    copy.versionText = self.versionText;
    copy.theme = self.theme;
    copy.sections = self.sections;
    copy.themePersistenceKey = self.themePersistenceKey;
    copy.showsLeadingButton = self.showsLeadingButton;
    copy.showsCloseButton = self.showsCloseButton;
    return copy;
}

- (void)loadPersistedThemeIfNeeded {
    if (self.themePersistenceKey.length == 0) {
        return;
    }
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if ([defaults objectForKey:self.themePersistenceKey]) {
        self.theme = [defaults integerForKey:self.themePersistenceKey];
    } else {
        [self persistTheme];
    }
}

- (void)persistTheme {
    if (self.themePersistenceKey.length == 0) {
        return;
    }
    [NSUserDefaults.standardUserDefaults setInteger:self.theme forKey:self.themePersistenceKey];
}

- (BZMenuItem *)itemWithIdentifier:(NSString *)identifier {
    for (BZMenuSection *section in self.sections) {
        for (BZMenuItem *item in section.items) {
            if ([item.identifier isEqualToString:identifier]) {
                return item;
            }
        }
    }
    return nil;
}

@end
