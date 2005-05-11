//:CMRKeychainManager.m
/**
  *
  * @see SGKeychain.h
  * @see AppDefaults.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/11  8:55:35 PM)
  *
  */
#import "CMRKeychainManager_p.h"
#import <AppKit/NSApplication.h>

@implementation CMRKeychainManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (id) init
{
	if(self = [super init]){
		[self setShouldCheckHasAccountInKeychain : YES];
		[[NSNotificationCenter defaultCenter]
			addObserver : self
			   selector : @selector(applicationDidBecomeActive:)
				   name : NSApplicationDidBecomeActiveNotification
				 object : NSApp];
	}
	return self;
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



@implementation CMRKeychainManager(AppUserAccount)
- (BOOL) isAvailableKeychain
{
	if(NO == [SGKeychain keychainManagerAvailable])
		return NO;
	if(nil == [SGKeychain defaultKeychain])
		return NO;
	
	return YES;
}
- (void) checkHasAccountInKeychainIfNeeded
{
	if([self shouldCheckHasAccountInKeychain]){
		OSStatus	status_;
		
		UTILMethodLog;
		status_ = [self findKeychainPassword : NULL
							 keychainItemRef : NULL];
		UTILDebugWrite1(@"  status = %d." ,status_);
		[CMRPref 
			setHasAccountInKeychain : (noErr == status_)];
	}
	[self setShouldCheckHasAccountInKeychain : NO];
}
- (NSString *) passwordFromKeychain
{
	NSString	*password_;
	OSStatus	status_;
	
	status_ = [self findKeychainPassword : &password_
						 keychainItemRef : NULL];
	if(noErr == status_) return password_;
	
	return nil;
}
- (OSStatus) findKeychainAccount : (NSString  *) account
						password : (NSString **) passwordPtr
				 keychainItemRef : (KCItemRef *) itemRefPtr
{
	NSURL		*requestURL_;
	OSStatus	status_;
	
	if(nil == account || 0 == [account length]) return errKCItemNotFound;
	if(NO == [self isAvailableKeychain]) return errKCNoDefaultKeychain;
	
	requestURL_ = [self x2chAuthenticationRequestURL];
	status_ = [SGKeychain findInternetPasswordWithURL : requestURL_
									   accountName : account
										  password : passwordPtr
								   keychainItemRef : itemRefPtr];
	
	[CMRPref
		setHasAccountInKeychain : (noErr == status_)];
	return status_;
}

- (OSStatus) findKeychainPassword : (NSString **) passwordPtr
				  keychainItemRef : (KCItemRef *) itemRefPtr
{
	return [self findKeychainAccount : [self x2chUserAccount]
							password : passwordPtr
					 keychainItemRef : itemRefPtr];
}
@end



@implementation CMRKeychainManager(ChangeAttributes)
- (OSStatus) createKeychainWithPassword : (NSString  *) password
						keychainItemRef : (KCItemRef *) itemRefPtr
{
	return [SGKeychain 
				addInternetPasswordWithURL : [self x2chAuthenticationRequestURL]
							   accountName : [self x2chUserAccount]
								  password : password
						   keychainItemRef : itemRefPtr];
}
- (OSStatus) changeAccount : (NSString *) newAccount
{
	KCItemRef		keychainItem_;
	OSStatus		status_;
	
	if([[self x2chUserAccount] isEqualToString : newAccount]) 
		return noErr;
	
	status_ = [self findKeychainPassword : NULL
						 keychainItemRef : &keychainItem_];
	UTILRequireCondition((noErr == status_), err_change_attributes);
	
	status_ = [SGKeychain item : keychainItem_
					setAccount : newAccount];
	UTILRequireCondition((noErr == status_), err_change_attributes);
	
	status_ = [SGKeychain updateItem : keychainItem_];
	UTILRequireCondition((noErr == status_), err_change_attributes);
	
	return status_;
	
	err_change_attributes:
		return status_;
}

- (BOOL) deleteAccountWithAccount : (NSString *) account
{
	KCItemRef	keychainItem_;
	OSStatus	status_;
	
	status_ = [self findKeychainAccount : account
							   password : NULL 
						keychainItemRef : &keychainItem_];
	if(status_ != noErr) return NO;
	
	status_ = [SGKeychain deleteItem : keychainItem_];
	return (noErr == status_);
}
@end