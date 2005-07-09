//:TextFinder_p.h
#import "TextFinder.h"

#import "CocoMonar_Prefix.h"

#import "TextFinder.h"
#import "AppDefaults.h"
#import "CMRSearchOptions.h"



#define kLoadNibName			@"TextFind"

#define kCaseSencitiveBtnTag		0
#define kZenkakuHankakuBtnTag		1
#define kInLinkOptionBtnTag			2

#define APP_FIND_PANEL_AUTOSAVE_NAME			@"CocoMonar:Find Panel Autosave"

@interface TextFinder(ViewAccessor)
- (NSTextField *) findTextField;
- (NSMatrix *) buttonMatrix;
- (NSMatrix *) optionMatrix;
- (void) setupUIComponents;
- (void) updateButtonEnabled;
@end