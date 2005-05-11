//:LoginController_p.h
#import "LoginController.h"
#import "URLConnector_Prefix.h"


#import "w2chAuthenticater.h"
#import "AppDefaults.h"



@interface LoginController(ViewAccessor)
- (NSButton *) cancelButton;
- (NSButton *) okButton;
- (NSTextField *) passwordField;
- (NSButton *) shouldSavePWBtn;
- (NSTextField *) userIDField;
@end



@interface LoginController(UISetup)
- (void) updateButtonState;
- (void) setupUIComponents;
@end