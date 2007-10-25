/*
 * $Id: CMRKeychainManager.h,v 1.7 2007/10/25 17:06:13 tsawada2 Exp $
 * BathyScaphe
 *
 * Copyright 2005-2006 BathyScaphe Project. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@interface CMRKeychainManager : NSObject {
	BOOL	m_shouldCheckHasAccountInKeychain;
}

+ (id)defaultManager;

- (void)checkHasAccountInKeychainIfNeeded;
- (NSString *)passwordFromKeychain;

- (BOOL)createKeychainWithPassword:(NSString *)password;
- (BOOL)deleteAccountCompletely;
@end
