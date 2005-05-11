//:LoginController.h
/**
  *
  * ログイン時のパスワード入力ウィンドウを管理
  *
  * @version 1.0.0d1 (02/03/18  10:18:14 PM)
  *
  */


#import <Cocoa/Cocoa.h>

@class w2chAuthenticater;
@class AppDefaults;

@interface LoginController : NSWindowController
{
	IBOutlet NSButton    *m_cancelButton;
	IBOutlet NSButton    *m_okButton;
	IBOutlet NSTextField *m_passwordField;
	IBOutlet NSButton    *m_shouldSavePWBtn;
	IBOutlet NSTextField *m_userIDField;
}
- (AppDefaults *) preferences;


- (BOOL) runModalForLoginWindow : (NSString **) accountPtr
                       password : (NSString **) passwordPtr
			 shouldUsesKeychain : (BOOL		 *) savePassPtr;
@end



@interface LoginController(Action)
- (IBAction) okLogin : (id) sender;
- (IBAction) cancelLogin : (id) sender;
- (IBAction) changeShouldSavePW : (id) sender;
@end