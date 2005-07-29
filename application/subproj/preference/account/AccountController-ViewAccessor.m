//:AccountController-ViewAccessor.m
/**
  *
  * @see AppDefaults.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/04  6:29:23 AM)
  *
  */
#import "AccountController_p.h"



@implementation AccountController(ViewAccessor)
- (NSSecureTextField *) passwordField
{
	return m_passwordField;
}
- (NSTextField *) userIDField
{
	return m_userIDField;
}
- (NSTextField *) beMailAddressField
{
	return m_beMailAddressField;
}
- (NSTextField *) beCodeField
{
	return m_beCodeField;
}
- (NSButton *) shouldSavePWCheckBox
{
	return m_shouldSavePWCheckBox;
}
- (NSButton *) saveButton
{
	return m_saveButton;
}
- (NSButton *) shouldLoginCheckBox
{
	return m_shouldLoginCheckBox;
}
- (NSButton *) shouldLoginBe2chCheckBox
{
	return m_shouldLoginBe2chCheckBox;
}
@end



@implementation AccountController(ViewSetup)
- (void) setupUIComponents
{
	[super setupUIComponents];

	[[self userIDField] setDelegate : self];
	[[self passwordField] setDelegate : self];
	/*[[self beMailAddressField] setDelegate : self];
	[[self beCodeField] setDelegate : self];*/
	
	[[self saveButton] setEnabled : NO];
	//[self updateUIComponents];
}


- (void) updateUIComponents
{
	NSString		*account_;
	NSString		*password_;
	NSString		*beMail_;
	NSString		*beCode_;
	BOOL			hasAccountInKeychain_;
	BOOL			shouldLoginIfNeeded_;
	
	account_ = [[self preferences] x2chUserAccount];
	beMail_ = [[self preferences] be2chAccountMailAddress];
	beCode_ = [[self preferences] be2chAccountCode];
	password_ = nil;
	hasAccountInKeychain_ = [[self preferences] hasAccountInKeychain];
	shouldLoginIfNeeded_ = [[self preferences] shouldLoginIfNeeded];
	
	[[self shouldSavePWCheckBox] setState : 
			hasAccountInKeychain_ ? NSOnState : NSOffState];
	[[self shouldLoginCheckBox] setState : 
			shouldLoginIfNeeded_ ? NSOnState : NSOffState];
	[[self shouldLoginBe2chCheckBox] setState : 
			[[self preferences] shouldLoginBe2chAnyTime] ? NSOnState : NSOffState];
	
	if(hasAccountInKeychain_){
		password_ = [[self preferences] password];
		if(nil == password_) password_ = @"";
		
		[[self passwordField] setEnabled : YES];
		[[self passwordField] setStringValue : password_];
	}else{
		[[self passwordField] setEnabled : NO];
		[[self passwordField] setStringValue : @""];
	}
	
	if(nil == account_) account_ = @"";
	if(nil == beMail_) beMail_ = @"";
	if(nil == beCode_) beCode_ = @"";
	
	[[self userIDField] setStringValue : account_];
	[[self beMailAddressField] setStringValue : beMail_];
	[[self beCodeField] setStringValue : beCode_];
}
@end



@implementation AccountController(Localizable)
- (NSString *) localizableStringsForKey : (NSString *) key
{
	return PPLocalizedString(key);
}
/*- (NSString *) createNewAccountString
{
	return [self localizableStringsForKey : APP_ACCOUNTCONTROLLER_CREATENEWACCOUNT];
}
- (NSString *) saveChangedString
{
	return [self localizableStringsForKey : APP_ACCOUNTCONTROLLER_SAVE_CHANGED];
}*/
@end
