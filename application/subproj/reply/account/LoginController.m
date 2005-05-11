#import "LoginController_p.h"

#define    LOAD_NIB_NAME    @"LoginWindow"

@implementation LoginController
//////////////////////////////////////////////////////////////////////
/////////////////////// [ èâä˙âªÅEå„énññ ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
- (id) init
{
	if(self = [super initWithWindowNibName : LOAD_NIB_NAME]){
	}
	return self;
}

- (void) awakeFromNib
{
	[self setupUIComponents];
}

- (AppDefaults *) preferences
{
	return [w2chAuthenticater preferences];
}

- (BOOL) runModalForLoginWindow : (NSString **) accountPtr
                       password : (NSString **) passwordPtr
			 shouldUsesKeychain : (BOOL		 *) savePassPtr
{
	int				returnCode_;
	
	if(accountPtr != NULL) *accountPtr = nil;
	if(passwordPtr != NULL) *passwordPtr = nil;
	if(savePassPtr != NULL) *savePassPtr = NO;
	
	[self setupUIComponents];
	
	returnCode_ = [NSApp runModalForWindow : [self window]];
	if(returnCode_ != NSOKButton)
		return NO;
	
	if(accountPtr != NULL) 
		*accountPtr = [[self userIDField] stringValue];
	if(passwordPtr != NULL) 
		*passwordPtr = [[self passwordField] stringValue];
	if(savePassPtr != NULL)
		*savePassPtr = (NSOnState == [[self shouldSavePWBtn] state]);
	
	return YES;
}
@end



@implementation LoginController(Action)
- (IBAction) okLogin : (id) sender
{
	[NSApp stopModalWithCode : NSOKButton];
	[self close];
}
- (IBAction) cancelLogin : (id) sender
{
	[NSApp stopModalWithCode : NSCancelButton];
	[self close];
}
- (IBAction) changeShouldSavePW : (id) sender
{
	;
}
@end
