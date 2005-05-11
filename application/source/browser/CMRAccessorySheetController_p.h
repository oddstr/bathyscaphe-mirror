//:CMRAccessorySheetController_p.h
#import "CMRAccessorySheetController.h"

#import "CocoMonar_Prefix.h"
#import "BoardManager.h"



@interface CMRAccessorySheetController(Private)
- (void) sheetDidEnd : (NSWindow *) sheet
		  returnCode : (int       ) returnCode
		 contextInfo : (void     *) contextInfo;
@end



@interface CMRAccessorySheetController(ViewAccessor)
/* Accessor for m_originalContentView */
- (NSView *) originalContentView;
/* Accessor for m_closeButton */
- (NSButton *) closeButton;
@end



@interface CMRAccessorySheetController(ViewInitializer)
- (void) setupContentView;
- (void) setupCloseButton;
- (void) setupWindow;
- (void) setupUIComponents;
@end

