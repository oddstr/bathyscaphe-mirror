/*
 * $Id: CMRKeychainManager.h,v 1.4 2006/02/02 13:00:47 tsawada2 Exp $
 * BathyScaphe
 *
 * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <Keychain/Keychain.h>
#import <Keychain/KeychainItem.h>


@interface CMRKeychainManager : NSObject
{
	BOOL	m_shouldCheckHasAccountInKeychain;
}
+ (id) defaultManager;

- (BOOL) isAvailableKeychain;
- (void) checkHasAccountInKeychainIfNeeded;
- (NSString *) passwordFromKeychain;
- (void) createKeychainWithPassword : (NSString  *) password;
- (void) deleteAccountCompletely;
@end