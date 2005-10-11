//:FCController_p.h
#import "FCController.h"
#import "PreferencePanes_Prefix.h"


@interface FCController(ViewAccessor)
- (NSButton *) alternateFontButton;
- (NSButton *) threadViewFontButton;
- (NSButton *) messageFontButton;
- (NSButton *) itemTitleFontButton;
- (NSButton *) threadsListFontButton;
- (NSButton *) newThreadFontButton;
- (NSButton *) replyFontButton;
- (NSButton *) hostFontButton;
- (NSButton *) boardListTextFontButton;
- (NSButton *) beProfileFontButton;

- (NSTextField *) rowHeightField;
- (NSStepper *) rowHeightStepper;

- (NSTextField *) boardListRowHeightField;
- (NSStepper *) boardListRowHeightStepper;

- (void) updateTableRowSettings;
- (void) updateBoardListRowSettings;

- (NSFont *) getFontOf : (int) btnTag;
@end
