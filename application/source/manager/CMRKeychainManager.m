/*
 * $Id: CMRKeychainManager.m,v 1.3.4.1 2005/12/14 16:05:06 masakih Exp $
 *
 * Copyright 2005 BathyScaphe Project. All rights reserved.
 *
 */

#import "CMRKeychainManager_p.h"
#import <AppKit/NSApplication.h>

@implementation CMRKeychainManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

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
	if(nil == [Keychain defaultKeychain])
		return NO;
	
	return YES;
}

- (void) checkHasAccountInKeychainIfNeeded
{
	if([self shouldCheckHasAccountInKeychain]){
			KeychainItem	*item_;
			NSURL			*url_ = [self x2chAuthenticationRequestURL];
			
			item_ = [[Keychain defaultKeychain] internetServer : [url_ host]
													forAccount : [self x2chUserAccount] 
														  port : 0
														  path : [url_ path]
											  inSecurityDomain : nil
													  protocol : kSecProtocolTypeHTTPS
														  auth : kSecAuthenticationTypeDefault];

			if (item_ == nil)
				NSLog(@"KeyChain Account Not Found - checkHasAccountInKeychainIfNeeded");

			[CMRPref setHasAccountInKeychain : (nil != item_)];
	}
	[self setShouldCheckHasAccountInKeychain : NO];
}

- (void) deleteAccountCompletely
{
	KeychainItem	*item_;
	NSURL			*url_ = [self x2chAuthenticationRequestURL];
                
	item_ = [[Keychain defaultKeychain] internetServer : [url_ host]
											forAccount : [self x2chUserAccount] 
												  port : 0
												  path : [url_ path]
									  inSecurityDomain : nil
											  protocol : kSecProtocolTypeHTTPS
											      auth : kSecAuthenticationTypeDefault];

	if (item_ == nil) {
		NSLog(@"KeyChain Account Not Found - deleteAccountCompletely");
		return;
	}

	[item_ deleteCompletely];
}

- (NSString *) passwordFromKeychain
{
	NSString	*password_;
	NSURL		*url_ = [self x2chAuthenticationRequestURL];
	
	password_ = [[Keychain defaultKeychain] passwordForInternetServer : [url_ host] 
														   forAccount : [self x2chUserAccount]
																 port : 0
																 path : [url_ path]
													 inSecurityDomain : nil
															 protocol : kSecProtocolTypeHTTPS 
																 auth : kSecAuthenticationTypeDefault];
	
	return password_; // Note: On Error(or No password found), password_ may be nil.
}

- (void) createKeychainWithPassword : (NSString  *) password
{
	NSURL	*url_ = [self x2chAuthenticationRequestURL];

	[[Keychain defaultKeychain]	addInternetPassword : password
										   onServer : [url_ host]
										 forAccount : [self x2chUserAccount]
											   port : 0
											   path : [url_ path] 
								   inSecurityDomain : nil
										   protocol : kSecProtocolTypeHTTPS 
											   auth : kSecAuthenticationTypeDefault
									replaceExisting : YES];

	[CMRPref setHasAccountInKeychain : YES];
}
@end


@implementation CMRKeychainManager(Private)
/* Accessor for m_shouldCheckHasAccountInKeychain */
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