//:CMRKeychainManager.h
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/11  8:55:47 PM)
  *
  */
#import <Foundation/Foundation.h>


@interface CMRKeychainManager : NSObject
{
	BOOL	m_shouldCheckHasAccountInKeychain;
}
+ (id) defaultManager;
@end



@interface CMRKeychainManager(AppUserAccount)
- (BOOL) isAvailableKeychain;
- (void) checkHasAccountInKeychainIfNeeded;
- (NSString *) passwordFromKeychain;
- (OSStatus) findKeychainAccount : (NSString  *) account
						password : (NSString **) passwordPtr
				 keychainItemRef : (KCItemRef *) itemRefPtr;
- (OSStatus) findKeychainPassword : (NSString **) passwordPtr
				  keychainItemRef : (KCItemRef *) itemRefPtr;
@end



@interface CMRKeychainManager(ChangeAttributes)
- (OSStatus) createKeychainWithPassword : (NSString  *) password
						keychainItemRef : (KCItemRef *) itemRefPtr;
- (OSStatus) changeAccount : (NSString *) newAccount;
- (BOOL) deleteAccountWithAccount : (NSString *) account;
@end