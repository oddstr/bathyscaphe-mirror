//:CMRThreadViewerTbDelegate_p.h
#import "CMRThreadViewerTbDelegate.h"

#import "CocoMonar_Prefix.h"
#import "CMRToolbarDelegateImp_p.h"

@interface CMRThreadViewerTbDelegate(Private)
- (NSString *) reloadThreadItemIdentifier;
- (NSString *) replyItemIdentifier;
- (NSString *) addFavoritesItemIdentifier;
- (NSString *) deleteItemIdentifier;
- (NSString *) toggleOnlineModeIdentifier;
- (NSString *) launchCMLFIdentifier;
- (NSString *) stopTaskIdentifier;
- (NSString *) historySegmentedControlIdentifier;
@end