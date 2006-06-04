/*
 * $Id: CMRKeychainManager.h,v 1.5.2.1 2006/06/04 16:16:05 tsawada2 Exp $
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
