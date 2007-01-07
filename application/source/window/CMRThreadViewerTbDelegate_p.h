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
// Available in BathyScaphe 1.0.2 and later.
- (NSString *) stopTaskIdentifier;
// Available in SledgeHammer and later.
- (NSString *) historySegmentedControlIdentifier;
- (NSString *) orderFrontBrowserItemIdentifier;
// Available in ReinforceII and later.
- (NSString *) scaleSegmentedControlIdentifier;
@end