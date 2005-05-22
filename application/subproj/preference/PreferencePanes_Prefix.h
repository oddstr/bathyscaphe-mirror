#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>

#import "UTILKit.h"



#define PPLocalizedString(key)	[[NSBundle bundleForClass : [self class]] localizedStringForKey:(key) value:@"" table:nil]



// controllers identifier
extern NSString *const PPShowAllIdentifier;
extern NSString *const PPGeneralPreferencesIdentifier;
extern NSString *const PPAdvancedPreferencesIdentifier;
extern NSString *const PPFilterPreferencesIdentifier;
extern NSString *const PPFontsAndColorsIdentifier;
extern NSString *const PPAccountSettingsIdentifier;
extern NSString *const PPReplyDefaultIdentifier;
