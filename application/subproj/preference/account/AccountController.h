//:AccountController.h
/**
  *
  * アカウントの設定
  *
  * @version 1.0.0d1 (02/03/03  11:44:32 PM)
  *
  */


#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"

@interface AccountController : PreferencesController
{
	IBOutlet NSTextField		*m_userIDField;
	IBOutlet NSSecureTextField	*m_passwordField;
	
	IBOutlet NSTextField		*m_beMailAddressField;
	IBOutlet NSTextField		*m_beCodeField;
	
	IBOutlet NSButton			*m_shouldSavePWCheckBox;
	IBOutlet NSButton			*m_shouldLoginCheckBox;
	IBOutlet NSButton			*m_shouldLoginBe2chCheckBox;
	
	IBOutlet NSButton			*m_saveButton;
}
@end



@interface AccountController(Action)
- (IBAction) saveAccount : (id) sender;

- (IBAction) changeShouldSavePassword : (id) sender;
- (IBAction) changeShouldLoginIfNeeded : (id) sender;
- (IBAction) changeShouldLoginBe2chAnytime : (id) sender;

- (IBAction) changeAddressField : (id) sender;
- (IBAction) changeCodeField : (id) sender;
@end
