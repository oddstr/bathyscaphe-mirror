/*
 * $Id: CMRKeychainManager.m,v 1.7 2006/02/28 05:40:06 tsawada2 Exp $
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
- (BOOL) shouldCheckHasAccountInKeychain
{
	return m_shouldCheckHasAccountInKeychain;
}
- (void) setShouldCheckHasAccountInKeychain : (BOOL) flag
{
	m_shouldCheckHasAccountInKeychain = flag;
}

- (NSURL *) x2chAuthenticationRequestURL
{
	return [CMRPref x2chAuthenticationRequestURL];
}
- (NSString *) x2chUserAccount
{
	return [CMRPref x2chUserAccount];
}

#pragma mark Public Methods

- (id) init
{
	if (self = [super init]) {
		[self setShouldCheckHasAccountInKeychain : YES];
		[[NSNotificationCenter defaultCenter] addObserver : self
												 selector : @selector(applicationDidBecomeActive:)
													 name : NSApplicationDidBecomeActiveNotification
												   object : NSApp];
	}
	return self;
}

- (BOOL) isAvailableKeychain
{
	UInt32	dummy_;
	return (noErr == SecKeychainGetVersion(&dummy_));
}

- (void) checkHasAccountInKeychainIfNeeded
{
	if([self shouldCheckHasAccountInKeychain]) {
		BOOL		result_ = NO;
		NSString	*account_ = [self x2chUserAccount];

		if(account_ != nil) {
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
//				NSLog(@"KeyChain Account successfully found");
				result_ = YES;
//			} else {
//				NSLog(@"Some Error Occured - checkHasAccountInKeychainIfNeeded");
			}
		}

		[CMRPref setHasAccountInKeychain : result_];
		[self setShouldCheckHasAccountInKeychain : NO];
	}
}

- (void) deleteAccountCompletely
{
	NSString		*account_ = [self x2chUserAccount];

	if(account_ == nil) return;

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
//		NSLog(@"KeyChain Account Found and will remove...");
		err = SecKeychainItemDelete(item);
		if(err == noErr)
			CFRelease(item);
//		else
//			NSLog(@"Some Error Occured while deleting keychain item.");
//	} else {
//		NSLog(@"Keychian Account Not found - deleteAccountCompletely");
	}
}

- (NSString *) passwordFromKeychain
{
	NSString		*account_ = [self x2chUserAccount];
	
	if(account_ == nil)
		return nil;

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
		NSString *result_ = [[NSString alloc] initWithBytesNoCopy : passwordData
														   length : passwordLength
														 encoding : NSUTF8StringEncoding
													 freeWhenDone : YES];

//		NSLog(@"Successfully got password");
		return [result_ autorelease];
//	} else {
//		NSLog(@"Some Error Occrred while getting keychianItem");
	}

	return nil;
}

- (void) createKeychainWithPassword : (NSString  *) password
{
	NSString		*account_ = [self x2chUserAccount];

	if (account_ == nil)
		return;

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
				[CMRPref setHasAccountInKeychain : YES];
			}
//		} else {
//			NSLog(@"Some Error Occurred while modifying content.");
		}
	} else if (err == noErr) {
//		NSLog(@"Keychain item was successfully created.");
		[CMRPref setHasAccountInKeychain : YES];
//	} else {
//		NSLog(@"Some error occurred while creating keychain item");
	}
}

#pragma mark Notifications

- (void) applicationDidBecomeActive : (NSNotification *) theNotification
{
	UTILAssertNotificationName(
		theNotification,
		NSApplicationDidBecomeActiveNotification);
	UTILAssertNotificationObject(
		theNotification,
		NSApp);
	
	[self setShouldCheckHasAccountInKeychain : YES];
}
@end
