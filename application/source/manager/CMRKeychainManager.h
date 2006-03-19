/*
 * $Id: CMRKeychainManager.h,v 1.3.4.2 2006/03/19 15:09:53 masakih Exp $
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
