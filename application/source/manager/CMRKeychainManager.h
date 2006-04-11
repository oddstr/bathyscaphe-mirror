/*
 * $Id: CMRKeychainManager.h,v 1.6 2006/04/11 17:31:21 masakih Exp $
 * BathyScaphe
 *
 * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

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
