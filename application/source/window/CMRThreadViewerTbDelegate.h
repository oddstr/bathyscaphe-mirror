//:CMRThreadViewerTbDelegate.h
/**
  *
  * スレッド表示のツールバー
  *
  * @author  Takanori Ishikawa
  * @author  http://www15.big.or.jp/~takanori/
  * @version Fri Jun 21 2002
  *
  */
#import <Foundation/Foundation.h>
#import "CMRToolbarDelegateImp.h"

@interface CMRThreadViewerTbDelegate : CMRToolbarDelegateImp
{
}
@end

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
