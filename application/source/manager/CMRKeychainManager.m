/*
 * $Id: CMRKeychainManager.m,v 1.8 2007/10/25 17:06:13 tsawada2 Exp $
 *
 * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
 *
 */

#import "CMRKeychainManager.h"
#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
#import <AppKit/NSApplication.h>
#import <Security/Security.h>

@implementation CMRKeychainManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

#pragma mark Accessors
- (BOOL)shouldCheckHasAccountInKeychain
{
	return m_shouldCheckHasAccountInKeychain;
}
- (void)setShouldCheckHasAccountInKeychain:(BOOL)flag
{
	m_shouldCheckHasAccountInKeychain = flag;
}

- (NSURL *)x2chAuthenticationRequestURL
{
	return [CMRPref x2chAuthenticationRequestURL];
}

- (NSString *)x2chUserAccount
{
	return [CMRPref x2chUserAccount];
}

#pragma mark Public Methods
- (id)init
{
	if (self = [super init]) {
		[self setShouldCheckHasAccountInKeychain:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(applicationDidBecomeActive:)
													 name:NSApplicationDidBecomeActiveNotification
												   object:NSApp];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)checkHasAccountInKeychainIfNeeded
{
	if ([self shouldCheckHasAccountInKeychain]) {
		BOOL		result_ = NO;
		NSString	*account_ = [self x2chUserAccount];

		if (account_) {
			OSStatus err;
			SecKeychainItemRef item = nil;

			NSURL		*url_ = [self x2chAuthenticationRequestURL];
			NSString	*host_ = [url_ host];
			NSString	*path_ = [url_ path];
			
			const char	*accountUTF8 = [account_ UTF8String];
			const char	*hostUTF8 = [host_ UTF8String];
			const char	*pathUTF8 = [path_ UTF8String];
			

			err = SecKeychainFindInternetPassword(NULL,
												  strlen(hostUTF8),
												  hostUTF8,
												  0,
												  NULL,
												  strlen(accountUTF8),
												  accountUTF8,
												  strlen(pathUTF8),
												  pathUTF8,
												  0,
												  kSecProtocolTypeHTTPS,
												  kSecAuthenticationTypeDefault,
												  NULL,
												  NULL,
												  &item);

			if ((err == noErr) && item) {
				result_ = YES;
			}
		}

		[CMRPref setHasAccountInKeychain:result_];
		[self setShouldCheckHasAccountInKeychain:NO];
	}
}

- (BOOL)deleteAccountCompletely
{
	NSString		*account_ = [self x2chUserAccount];

	if (!account_) return YES;

	OSStatus err;
	SecKeychainItemRef item = nil;

	NSURL			*url_ = [self x2chAuthenticationRequestURL];
	NSString		*host_ = [url_ host];
	NSString		*path_ = [url_ path];
	
	const char		*accountUTF8 = [account_ UTF8String];
	const char		*hostUTF8 = [host_ UTF8String];
	const char		*pathUTF8 = [path_ UTF8String];

	err = SecKeychainFindInternetPassword(NULL,
										  strlen(hostUTF8),
										  hostUTF8,
										  0,
										  NULL,
										  strlen(accountUTF8),
										  accountUTF8,
										  strlen(pathUTF8),
										  pathUTF8,
										  0,
										  kSecProtocolTypeHTTPS,
										  kSecAuthenticationTypeDefault,
										  NULL,
										  NULL,
										  &item);

	if ((noErr == err) && item) {
		err = SecKeychainItemDelete(item);
		if (err == noErr) {
			CFRelease(item);
			return YES;
		} else {
			return NO;
		}
	} else {
		return YES;
	}
}

- (NSString *)passwordFromKeychain
{
	NSString		*account_ = [self x2chUserAccount];
	
	if (!account_) return nil;

	OSStatus err;
	SecKeychainItemRef item = nil;

	NSURL			*url_ = [self x2chAuthenticationRequestURL];
	NSString		*host_ = [url_ host];
	NSString		*path_ = [url_ path];
	
	const char		*accountUTF8 = [account_ UTF8String];
	const char		*hostUTF8 = [host_ UTF8String];
	const char		*pathUTF8 = [path_ UTF8String];


	char *passwordData;
	UInt32 passwordLength;

	err = SecKeychainFindInternetPassword(NULL,
										  strlen(hostUTF8),
										  hostUTF8,
										  0,
										  NULL,
										  strlen(accountUTF8),
										  accountUTF8,
										  strlen(pathUTF8),
										  pathUTF8,
										  0,
										  kSecProtocolTypeHTTPS,
										  kSecAuthenticationTypeDefault,
										  &passwordLength,
										  (void **)&passwordData,
										  &item);

	if ((err == noErr) && item) {
		NSString *result_ = [[NSString alloc] initWithBytesNoCopy:passwordData
														   length:passwordLength
														 encoding:NSUTF8StringEncoding
													 freeWhenDone:YES];
		return [result_ autorelease];
	}

	return nil;
}

- (BOOL)createKeychainWithPassword:(NSString  *)password
{
	NSString		*account_ = [self x2chUserAccount];

	if (!account_) return NO;

	OSStatus err;

	NSURL			*url_ = [self x2chAuthenticationRequestURL];
	NSString		*host_ = [url_ host];
	NSString		*path_ = [url_ path];
	
	const char		*accountUTF8 = [account_ UTF8String];
	const char		*hostUTF8 = [host_ UTF8String];
	const char		*pathUTF8 = [path_ UTF8String];
	
	const char		*passwordUTF8 = [password UTF8String];
	
	err = SecKeychainAddInternetPassword(NULL,
										 strlen(hostUTF8),
										 hostUTF8,
										 0,
										 NULL,
										 strlen(accountUTF8),
										 accountUTF8,
										 strlen(pathUTF8),
										 pathUTF8,
										 0,
										 kSecProtocolTypeHTTPS,
										 kSecAuthenticationTypeDefault,
										 strlen(passwordUTF8),
										 passwordUTF8,
										 NULL);
 
	if(err == errSecDuplicateItem) {
//		NSLog(@"Keychain item already exists.");
		SecKeychainItemRef item = nil;
		err = SecKeychainFindInternetPassword(NULL,
											  strlen(hostUTF8),
											  hostUTF8,
											  0,
											  NULL,
											  strlen(accountUTF8),
											  accountUTF8,
											  strlen(pathUTF8),
											  pathUTF8,
											  0,
											  kSecProtocolTypeHTTPS,
											  kSecAuthenticationTypeDefault,
											  NULL,
											  NULL,
											  &item);

		if(item) {
			err == SecKeychainItemModifyContent(item, NULL, strlen(passwordUTF8), passwordUTF8);
			if(err == noErr) {
//				NSLog(@"Replacing keychain item's data successfully finished.");
				CFRelease(item);
				[CMRPref setHasAccountInKeychain:YES];
				return YES;
			}
		} else {
//			NSLog(@"Some Error Occurred while modifying content.");
			return NO;
		}
	} else if (err == noErr) {
//		NSLog(@"Keychain item was successfully created.");
		[CMRPref setHasAccountInKeychain:YES];
		return YES;
	} else {
//		NSLog(@"Some error occurred while creating keychain item");
		return NO;
	}
	return NO;
}

#pragma mark Notifications
- (void)applicationDidBecomeActive:(NSNotification *)theNotification
{
	UTILAssertNotificationName(
		theNotification,
		NSApplicationDidBecomeActiveNotification);
	UTILAssertNotificationObject(
		theNotification,
		NSApp);
	
	[self setShouldCheckHasAccountInKeychain:YES];
}
@end
