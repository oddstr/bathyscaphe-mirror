//:AppDefaults-Account.m
/**
  *
  * @see SGKeychain.h
  * @see CMRKeychainManager.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/04  5:31:51 AM)
  *
  */
#import "AppDefaults_p.h"
#import "CMRKeychainManager.h"

// ----------------------------------------
// C o n s t a n t s
// ----------------------------------------

// このバージョンからキーチェーンを利用するので、
// これまでの初期設定は取り除く。
static NSString *const st_ShouldBeRemovedKey = @"Preferences - AccountSettings";

static NSString *const st_AppDefaultsX2chUserAccountKey = @"Account";
static NSString *const st_AppDefaultsUsesKeychainKey = @"Uses Keychain";
static NSString *const st_AppDefaultsShouldLoginKey = @"Should Login";

static NSString *const st_AppDefaultsBe2chMailAddressKey = @"Be2ch Mail Address";
static NSString *const st_AppDefaultsBe2chCodeKey = @"Be2ch Authorization Code";

static NSString *const st_AppDefaultsShouldLoginBe2chAnytimeKey = @"Always Login(Be-2ch)";


@implementation AppDefaults(Account)
- (NSURL *) URLForKey : (NSString *) aKey
{
    NSString *loc = SGTemplateResource(aKey);
    NSURL *URL = nil;
    
NS_DURING
    URL = [NSURL URLWithString : loc];
NS_HANDLER
    URL = nil;
NS_ENDHANDLER
    return URL;
}
- (NSURL *) x2chAuthenticationRequestURL
{
    return [self URLForKey : APP_X2CH_AUTHENTICATION_REQUEST_KEY];
}
- (NSURL *) x2chRegistrationPageURL
{
    return [self URLForKey : APP_X2CH_REGISTRATION_PAGE_KEY];
}

- (NSURL *) be2chRegistrationPageURL
{
	return [self URLForKey : APP_BE2CH_REGISTRATION_PAGE_KEY];
}

#pragma mark -

- (NSString *) applicationUserAgent
{
	static NSString *_userAgent;
	if(nil == _userAgent){
		_userAgent = [[NSString alloc] initWithFormat :
						@"%@/%@",
						[NSBundle applicationName],
						[NSBundle applicationVersion]];
	}
	return _userAgent;
}

- (NSString *) x2chUserAccount
{
	return [[self defaults] stringForKey : st_AppDefaultsX2chUserAccountKey];
}
- (NSString *) password
{
	if(NO == [self hasAccountInKeychain])
		return nil;
	
	return [[CMRKeychainManager defaultManager] passwordFromKeychain];
}
- (NSString *) be2chAccountMailAddress
{
	return [[self defaults] stringForKey : st_AppDefaultsBe2chMailAddressKey];
}
- (NSString *) be2chAccountCode
{
	return [[self defaults] stringForKey : st_AppDefaultsBe2chCodeKey];
}

#pragma mark -

- (BOOL) shouldLoginIfNeeded
{
	return [[self defaults] boolForKey : st_AppDefaultsShouldLoginKey
						  defaultValue : YES];
}
- (void) setShouldLoginIfNeeded : (BOOL) flag
{
	[[self defaults] setBool : flag
					  forKey : st_AppDefaultsShouldLoginKey];
}

- (BOOL) shouldLoginBe2chAnyTime
{
	return [[self defaults] boolForKey : st_AppDefaultsShouldLoginBe2chAnytimeKey
						  defaultValue : NO];
}
- (void) setShouldLoginBe2chAnyTime : (BOOL) flag
{
	[[self defaults] setBool : flag
					  forKey : st_AppDefaultsShouldLoginBe2chAnytimeKey];
}
- (BOOL) hasAccountInKeychain
{
	[[CMRKeychainManager defaultManager] checkHasAccountInKeychainIfNeeded];
	return [[self defaults] boolForKey : st_AppDefaultsUsesKeychainKey
						  defaultValue : NO];
}

#pragma mark -

- (void) setX2chUserAccount : (NSString *) account
{
	if(nil == account || 0 == [account length]){
		[[self defaults] removeObjectForKey : st_AppDefaultsX2chUserAccountKey];
		return;
	}
	[[self defaults] setObject : account
						forKey : st_AppDefaultsX2chUserAccountKey];
}
- (void) setBe2chAccountMailAddress : (NSString *) address
{
	if(nil == address || 0 == [address length]){
		[[self defaults] removeObjectForKey : st_AppDefaultsBe2chMailAddressKey];
		return;
	}
	[[self defaults] setObject : address
						forKey : st_AppDefaultsBe2chMailAddressKey];
}
- (void) setBe2chAccountCode : (NSString *) code
{
	if(nil == code || 0 == [code length]){
		[[self defaults] removeObjectForKey : st_AppDefaultsBe2chCodeKey];
		return;
	}
	[[self defaults] setObject : code
						forKey : st_AppDefaultsBe2chCodeKey];
}

- (void) setHasAccountInKeychain : (BOOL) usesKeychain
{
	[[self defaults] setBool : usesKeychain
					  forKey : st_AppDefaultsUsesKeychainKey];
}

- (void) loadAccountSettings
{
	// このバージョンからキーチェーンを利用するので、
	// これまでの初期設定は取り除く。
	if([[self defaults] dictionaryForKey : st_ShouldBeRemovedKey]){
		[[self defaults] removeObjectForKey : st_ShouldBeRemovedKey];
	}
}
@end

#pragma mark -

@implementation AppDefaults(ChangeAccount)
- (BOOL) changeAccountNoUsesKeychain : (NSString *) newAccount
{
	if([self hasAccountInKeychain]){
		if(NO == [self deleteAccount])
			return NO;
	}
	
	[self setX2chUserAccount : newAccount];
	return YES;
}

- (BOOL) changeAccount : (NSString *) newAccount
			  password : (NSString *) newPassword
		  usesKeychain : (BOOL      ) usesKeychain
{
	if(NO == usesKeychain)
		return [self changeAccountNoUsesKeychain : newAccount];
	
	if(NO == [self checkKeychainParamWithAccount : newAccount
										password : newPassword])
		return NO;
	
	if(NO == [self hasAccountInKeychain]){
		//OSStatus	status_;
		
		[self setX2chUserAccount : newAccount];
		[[CMRKeychainManager defaultManager]
					 createKeychainWithPassword : newPassword];
					 		/*
							[self runAlertPanelWithReturnCode : status_
								  account : newAccount
								 password : newPassword];
								 */
		return YES;//(noErr == status_);
	}else{
		if(NO == [self changeKeychainAccount : newAccount
									password : newPassword]){
			[self runKeychainAlertPanelWithKey : 
					APPDEFAULTS_KEYCHAIN_ERRPR_CHANGE
								 allowedCancel : NO];
			return NO;
		}
		
		[self setX2chUserAccount : newAccount];
		return YES;
	}
	return NO;
}

- (BOOL) deleteAccount
{
	if(NO == [self hasAccountInKeychain]) return NO;
	if(NSCancelButton == [self runKeychainAlertPanelWithKey : 
								APPDEFAULTS_KEYCHAIN_DELETE
								allowedCancel : YES]){
		return NO;
	}
	/*
	if(NO == [[CMRKeychainManager defaultManager]
				deleteAccountWithAccount : [self x2chUserAccount]]){
		[self runKeychainAlertPanelWithKey : 
					APPDEFAULTS_KEYCHAIN_ERRPR_DELETE
				allowedCancel : NO];
		return NO;
	}
	*/
	[self setHasAccountInKeychain : NO];
	return YES;
}
@end



@implementation AppDefaults(AccountPrivate)
- (BOOL) checkAvailableKeychain
{
	if(NO == [[CMRKeychainManager defaultManager] isAvailableKeychain]){
		[self runKeychainAlertPanelWithKey :
				APPDEFAULTS_KEYCHAIN_NOT_AVAILABLE
			allowedCancel : NO];
		return NO;
	}
	return YES;
}


- (BOOL) changeKeychainAccount : (NSString *) newAccount
					  password : (NSString *) newPassword
{
	/*
	NSString		*account_;
	NSString		*password_;
	OSStatus		status_;
	
	account_ = [self x2chUserAccount];
	password_ = [self password];
	
	if(NO == [password_ isEqualToString : newPassword]){
		BOOL		result_;
		
		// Keychain Manager APIでパスワードを変更する方法が
		// 分からないので、新規に作成する。
		UTILRequireCondition(
			[[CMRKeychainManager defaultManager]
				deleteAccountWithAccount : account_],
			err_change_attributes);
		
		result_ = [self changeAccount : newAccount
						     password : newPassword
					     usesKeychain : YES];
		UTILRequireCondition(
			result_,
			err_change_attributes);
		
		return YES;
	}
	
	
	if(NO == [account_ isEqualToString : newAccount]){
		status_ = [[CMRKeychainManager defaultManager]
								changeAccount : newAccount];
		
		UTILRequireCondition((noErr == status_), err_change_attributes);
		return YES;
	}
	
	err_change_attributes:
	*/
		return NO;
}
@end



@implementation AppDefaults(AccountAlert)
- (NSString *) passwordByHidingChars : (NSString *) password
{
	NSString			*mark_ = [NSString stringWithCharacter : 0xff65];
	NSMutableString		*hiding_;
	int					i, cnt;
	
	if(nil == password || 0 == [password length]) return @"";
	
	hiding_ = [NSMutableString string];
	cnt = [password length];
	for(i = 0; i < cnt; i++){
		[hiding_ appendString : mark_];
	}
	return hiding_;
}

- (int) runKeychainAlertPanelWithTitle : (NSString *) title
							   message : (NSString *) message
							   account : (NSString *) account
							  password : (NSString *) password
{
	NSString		*params_fmt_;
	NSString		*info_;
	NSString		*message_;
	
	params_fmt_ = NSLocalizedStringFromTable(
						APPDEFAULTS_KEYCHAIN_PARAM_KEY,
						APPDEFAULTS_KEYCHAIN_STRINGS_TABLE,
						APPDEFAULTS_KEYCHAIN_PARAM_KEY);
	UTILAssertNotNil(params_fmt_);
	info_ = NSLocalizedStringFromTable(
						message,
						APPDEFAULTS_KEYCHAIN_STRINGS_TABLE,
						message);
	UTILAssertNotNil(info_);
	message_ = [NSString stringWithFormat : 
						params_fmt_,
						info_,
						account ? account : @"",
						[self passwordByHidingChars : password]];
	
	return NSRunAlertPanel(
					NSLocalizedStringFromTable(
						title,
						APPDEFAULTS_KEYCHAIN_STRINGS_TABLE,
						title),
					message_,
					[[self class] labelForDefaultButton],
					nil,
					nil);
}
- (int) runKeychainAlertPanelWithKey : (NSString *) key
					   allowedCancel : (BOOL      ) allowedCancel
{
	return NSRunAlertPanel(
					NSLocalizedStringFromTable(
						APPDEFAULTS_KEYCHAIN_TITLE,
						APPDEFAULTS_KEYCHAIN_STRINGS_TABLE,
						APPDEFAULTS_KEYCHAIN_TITLE),
					NSLocalizedStringFromTable(
						key,
						APPDEFAULTS_KEYCHAIN_STRINGS_TABLE,
						key),
					[[self class] labelForDefaultButton],
					allowedCancel ? [[self class] labelForAlternateButton] : nil,
					nil);
}
- (BOOL) checkKeychainParamWithAccount : (NSString *) account
							  password : (NSString *) password
{
	UTILRequireCondition(
		(account && [account length]),
		error_invalidParameter);
	UTILRequireCondition(
		(password && [password length]),
		error_invalidParameter);
	
	return YES;
	
	error_invalidParameter:{
		[self runKeychainAlertPanelWithTitle : 
							APPDEFAULTS_KEYCHAIN_TITLE_ERR_CREATE
				message : APPDEFAULTS_KEYCHAIN_MSG_ERR_PARAM_CREATE
				account : account
				password : password];
		return NO;
	}
}
- (void) runAlertPanelWithReturnCode : (OSStatus  ) status
							 account : (NSString *) account
							password : (NSString *) password
{
	switch(status){
	case noErr:
		return;
		break;
	case errKCDuplicateItem:
		[self runKeychainAlertPanelWithTitle : 
							APPDEFAULTS_KEYCHAIN_TITLE_ERR_CREATE
				message : APPDEFAULTS_KEYCHAIN_MSG_ERRKCDUPLICATEITEM
				account : account
			   password : password];
		break;
	case errKCNoDefaultKeychain:
		[self runKeychainAlertPanelWithKey : APPDEFAULTS_KEYCHAIN_NOT_AVAILABLE
			allowedCancel : NO];
		break;
	default:
		break;
	}
}
@end