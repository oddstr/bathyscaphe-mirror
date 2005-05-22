//:AccountController.m
#import "AccountController_p.h"


//////////////////////////////////////////////////////////////////////
////////////////////// [ íËêîÇ‚É}ÉNÉçíuä∑ ] //////////////////////////
//////////////////////////////////////////////////////////////////////
#define    LOAD_NIB_NAME    @"AccountPane"



@implementation AccountController
- (NSString *) mainNibName
{
	return LOAD_NIB_NAME;
}
@end



@implementation AccountController(NSControlDelegate)
- (void) controlTextDidChange : (NSNotification *) aNotification
{
	UTILAssertNotificationName(
		aNotification,
		NSControlTextDidChangeNotification);
	
	[[self saveButton] setEnabled : YES];
}
@end



@implementation AccountController(Action)
- (IBAction) saveAccount : (id) sender
{
	NSString		*newAccount_;
	NSString		*newPassword_;
	BOOL			usesKeychain_;

	newAccount_ = [[self userIDField] stringValue];
	newPassword_ = [[self passwordField] stringValue];
	usesKeychain_ = (NSOnState == [[self shouldSavePWCheckBox] state]);
	
	if([[self preferences] changeAccount : newAccount_
								password : newPassword_
							usesKeychain : usesKeychain_]){
		
	}
	[[self saveButton] setEnabled : NO];
	[self updateUIComponents];
	
}

/*
- (IBAction) deleteAccount : (id) sender
{
	if([[self preferences] deleteAccount]){
		[[self saveButton] setEnabled : NO];
	}else{
		
	}
	[self updateUIComponents];
}
*/


- (IBAction) changeShouldSavePassword : (id) sender
{
	BOOL		passwordFieldEnabled_;
	
	UTILAssertKindOfClass(sender, NSButton);
	
	passwordFieldEnabled_ = ([sender state] == NSOnState);
	[[self passwordField] setEnabled : passwordFieldEnabled_];
	
	if(NO == passwordFieldEnabled_)
		[[self passwordField] setStringValue : @""]; 

	[[self saveButton] setEnabled : YES];
}

- (IBAction) changeShouldLoginIfNeeded : (id) sender
{
	BOOL			shouldLoginIfNeeded_;
	
	UTILAssertKindOfClass(sender, NSButton);
	
	shouldLoginIfNeeded_ = 
		(NSOnState == [[self shouldLoginCheckBox] state]);
	[[self preferences] setShouldLoginIfNeeded : shouldLoginIfNeeded_];
}

- (IBAction) changeShouldLoginBe2chAnytime : (id) sender
{
	BOOL			tmp_;
	
	UTILAssertKindOfClass(sender, NSButton);
	
	tmp_ = 
		(NSOnState == [[self shouldLoginBe2chCheckBox] state]);
	[[self preferences] setShouldLoginBe2chAnyTime : tmp_];
}

- (IBAction) changeAddressField : (id) sender
{
	[[self preferences] setBe2chAccountMailAddress : [sender stringValue]];
}
- (IBAction) changeCodeField : (id) sender
{
	[[self preferences] setBe2chAccountCode : [sender stringValue]];
}

/*
- (IBAction) openURLFor2chRegistration : (id) sender
{
	UTILAssertKindOfClass(sender, NSButton);
	[[NSWorkspace sharedWorkspace] openURL :
		[[self preferences] x2chRegistrationPageURL]];
}
*/
- (IBAction) openHelpForAccountPanel : (id) sender
{
	[[NSHelpManager sharedHelpManager] findString:PPLocalizedString(@"Help_Account") inBook:PPLocalizedString(@"HelpBookName")];
}
@end



@implementation AccountController(Toolbar)
- (NSString *) identifier
{
	return PPAccountSettingsIdentifier;
}
- (NSString *) label
{
	return PPLocalizedString(@"Account Label");
}
- (NSString *) paletteLabel
{
	return PPLocalizedString(@"Account Label");
}
- (NSString *) toolTip
{
	return PPLocalizedString(@"Account ToolTip");
}
- (NSString *) imageName
{
	return @"Account";
}
@end
