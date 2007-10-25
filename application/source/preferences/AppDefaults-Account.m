#import "AppDefaults_p.h"
#import "CMRKeychainManager.h"

#define APPDEFAULTS_KEYCHAIN_STRINGS_TABLE			@"AlertPanel"

#define APP_X2CH_AUTHENTICATION_REQUEST_KEY	@"System - 2channel Auth URL"

static NSString *const st_AppDefaultsX2chUserAccountKey = @"Account";
static NSString *const st_AppDefaultsUsesKeychainKey = @"Uses Keychain";
static NSString *const st_AppDefaultsShouldLoginKey = @"Should Login";

static NSString *const st_AppDefaultsBe2chMailAddressKey = @"Be2ch Mail Address";
static NSString *const st_AppDefaultsBe2chCodeKey = @"Be2ch Authorization Code";

static NSString *const st_AppDefaultsShouldLoginBe2chAnytimeKey = @"Always Login(Be-2ch)";

@implementation AppDefaults(Account)
- (NSURL *)URLForKey:(NSString *)aKey
{
    NSString *loc = SGTemplateResource(aKey);
    NSURL *URL = nil;
    
NS_DURING
    URL = [NSURL URLWithString:loc];
NS_HANDLER
    URL = nil;
NS_ENDHANDLER
    return URL;
}

- (void)loadAccountSettings
{
	;
}

#pragma mark Account Data Accessors
- (NSURL *)x2chAuthenticationRequestURL
{
    return [self URLForKey:APP_X2CH_AUTHENTICATION_REQUEST_KEY];
}

- (NSString *)x2chUserAccount
{
	return [[self defaults] stringForKey:st_AppDefaultsX2chUserAccountKey];
}

- (void)setX2chUserAccount:(NSString *)account
{
	if (!account || [account length] == 0) {
		[[self defaults] removeObjectForKey:st_AppDefaultsX2chUserAccountKey];
		return;
	}
	[[self defaults] setObject:account forKey:st_AppDefaultsX2chUserAccountKey];
}

- (NSString *)password
{
	if (![self hasAccountInKeychain]) return nil;
	
	return [[CMRKeychainManager defaultManager] passwordFromKeychain];
}

- (NSString *)be2chAccountMailAddress
{
	return [[self defaults] stringForKey:st_AppDefaultsBe2chMailAddressKey];
}

- (void)setBe2chAccountMailAddress:(NSString *)address
{
	if (!address || [address length] == 0) {
		[[self defaults] removeObjectForKey:st_AppDefaultsBe2chMailAddressKey];
		return;
	}
	[[self defaults] setObject:address forKey:st_AppDefaultsBe2chMailAddressKey];
}

- (NSString *)be2chAccountCode
{
	return [[self defaults] stringForKey:st_AppDefaultsBe2chCodeKey];
}

- (void)setBe2chAccountCode:(NSString *)code
{
	if (!code || [code length] == 0) {
		[[self defaults] removeObjectForKey:st_AppDefaultsBe2chCodeKey];
		return;
	}
	[[self defaults] setObject:code forKey:st_AppDefaultsBe2chCodeKey];
}

#pragma mark Account Settings Accessors
- (BOOL)shouldLoginIfNeeded
{
	return [[self defaults] boolForKey:st_AppDefaultsShouldLoginKey defaultValue:DEFAULT_LOGIN_MARU_IF_NEEDED];
}

- (void)setShouldLoginIfNeeded:(BOOL)flag
{
	[[self defaults] setBool:flag forKey:st_AppDefaultsShouldLoginKey];
}

- (BOOL)shouldLoginBe2chAnyTime
{
	return [[self defaults] boolForKey:st_AppDefaultsShouldLoginBe2chAnytimeKey defaultValue:DEFAULT_LOGIN_BE_ANY_TIME];
}

- (void)setShouldLoginBe2chAnyTime:(BOOL)flag
{
	[[self defaults] setBool:flag forKey:st_AppDefaultsShouldLoginBe2chAnytimeKey];
}

- (BOOL)hasAccountInKeychain
{
	[[CMRKeychainManager defaultManager] checkHasAccountInKeychainIfNeeded];
	return [[self defaults] boolForKey:st_AppDefaultsUsesKeychainKey defaultValue:DEFAULT_USE_KEYCHAIN];
}

- (void)setHasAccountInKeychain:(BOOL)usesKeychain
{
	[[self defaults] setBool:usesKeychain forKey:st_AppDefaultsUsesKeychainKey];
}

- (BOOL)availableBe2chAccount
{
	NSString	*dmdm_;
	NSString	*mdmd_;
	
	dmdm_ = [self be2chAccountMailAddress];
	if (!dmdm_ || [dmdm_ length] == 0) return NO;

	mdmd_ = [self be2chAccountCode];
	if (!mdmd_ || [mdmd_ length] == 0) return NO;

	return YES;
}

#pragma mark Keychain
- (void)showKeychainOperationErrorAlertWithMessageKey:(NSString *)key
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:NSLocalizedStringFromTable(key, APPDEFAULTS_KEYCHAIN_STRINGS_TABLE, @"")];
	[alert setInformativeText:NSLocalizedStringFromTable(@"Keychain Err Informative", APPDEFAULTS_KEYCHAIN_STRINGS_TABLE, @"")];
	[alert runModal];
}

- (BOOL)checkKeychainParamWithAccount:(NSString *)account password:(NSString *)password
{
	UTILRequireCondition((account && [account length]), error_invalidParameter);
	UTILRequireCondition((password && [password length]), error_invalidParameter);
	return YES;
	
error_invalidParameter:{
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert setMessageText:NSLocalizedStringFromTable(@"Create Keychain Err Message", APPDEFAULTS_KEYCHAIN_STRINGS_TABLE, @"")];
		[alert setInformativeText:NSLocalizedStringFromTable(@"Create Keychain Err Informative", APPDEFAULTS_KEYCHAIN_STRINGS_TABLE, @"")];
		[alert runModal];
		return NO;
	}
}

- (BOOL)changeAccountNoUsesKeychain:(NSString *)newAccount
{
	if ([self hasAccountInKeychain] && ![self deleteAccount]) {
			return NO;
	}

	[self setX2chUserAccount:newAccount];
	return YES;
}

- (BOOL)changeAccount:(NSString *)newAccount password:(NSString *)newPassword usesKeychain:(BOOL)usesKeychain
{
	if (!usesKeychain) {
		return [self changeAccountNoUsesKeychain:newAccount];
	}

	if (![self checkKeychainParamWithAccount:newAccount password:newPassword]) {
		return NO;
	}

	[self setX2chUserAccount:newAccount];
	if ([[CMRKeychainManager defaultManager] createKeychainWithPassword:newPassword]) {
		return YES;
	} else {
		[self showKeychainOperationErrorAlertWithMessageKey:@"Create Keychain Err 2 Message"];
		return NO;
	}
}

- (BOOL)deleteAccount
{
	if (![self hasAccountInKeychain]) return NO;

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert setMessageText:NSLocalizedStringFromTable(@"Delete Keychain Message", APPDEFAULTS_KEYCHAIN_STRINGS_TABLE, @"")];
	[alert setInformativeText:NSLocalizedStringFromTable(@"Delete Keychain Informative", APPDEFAULTS_KEYCHAIN_STRINGS_TABLE, @"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"OK", APPDEFAULTS_KEYCHAIN_STRINGS_TABLE, @"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", APPDEFAULTS_KEYCHAIN_STRINGS_TABLE, @"")];

	if ([alert runModal] == NSAlertFirstButtonReturn) {
		if ([[CMRKeychainManager defaultManager] deleteAccountCompletely]) {
			[self setHasAccountInKeychain:NO];
			return YES;
		} else {
			[self showKeychainOperationErrorAlertWithMessageKey:@"Delete Keychain Err Message"];
			return NO;
		}
	}
	return NO;
}
@end
