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