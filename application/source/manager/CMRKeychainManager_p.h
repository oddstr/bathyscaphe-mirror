//:CMRKeychainManager_p.h
#import "CocoMonar_Prefix.h"
#import "CMRKeychainManager.h"
#import "CMXPreferences.h"



@interface CMRKeychainManager(Private)
- (BOOL) shouldCheckHasAccountInKeychain;
- (void) setShouldCheckHasAccountInKeychain : (BOOL) flag;

- (NSURL *) x2chAuthenticationRequestURL;
- (NSString *) x2chUserAccount;

- (void) applicationDidBecomeActive : (NSNotification *) theNotification;
@end
