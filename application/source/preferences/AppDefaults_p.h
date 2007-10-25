//:AppDefaults_p.h
#import "AppDefaults.h"

//#import <AppKit/NSApplication.h>
//#import <AppKit/NSPanel.h>
//#import <AppKit/NSDrawer.h>
//#import <AppKit/NSColor.h>
//#import <AppKit/NSFont.h>
#import <SGAppKit/SGAppKit.h>
#import "CMRPreferencesDefautValues.h"


@class CMRMessageAttributesTemplate;

@interface AppDefaults(AccountPrivate)
- (BOOL) checkAvailableKeychain;
@end

#define AppDefaultsOldFontsAndColorsConvertedKey	@"Old FontsAndColors Setting Converted"
#define AppDefaultsBackgroundsKey					@"Preferences - BackgroundColors"

@interface AppDefaults(FontColorPrivate)
- (NSMutableDictionary *) appearances;

- (NSFont *) appearanceFontForKey : (NSString *) key;
- (NSFont *) appearanceFontCleaningForKey : (NSString *) key
					  defaultSize : (float     ) fontSize;
- (void) setAppearanceFont : (NSFont   *) aFont
					forKey : (NSString *) key;
- (NSColor *) appearanceColorForKey : (NSString *) key;
- (NSColor *) textAppearanceColorCleaningForKey : (NSString *) key;
- (void) setAppearanceColor : (NSColor  *) color
					 forKey : (NSString *) key;

// return default aFont if nil.
- (NSFont *) appearanceFontForKey : (NSString *) key
					  defaultSize : (float     ) fontSize;
- (NSColor *) textAppearanceColorForKey : (NSString *) key;
@end

@interface AppDefaults(ConvertOldSettingsToThemeFile)
- (void) convertOldFCToThemeFile;
@end
