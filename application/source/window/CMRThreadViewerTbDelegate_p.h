//:CMRThreadViewerTbDelegate_p.h
#import "CMRThreadViewerTbDelegate.h"

#import "CocoMonar_Prefix.h"
#import "CMRToolbarDelegateImp_p.h"

//#import "CMRTrashItemButton.h"
//#import "CMRFavoritesItemButton.h"


@interface CMRThreadViewerTbDelegate(Private)
//- (SGToolbarIconItemButton *) trashToolbarItemView;
//- (SGToolbarIconItemButton *) favoritesToolbarItemView;

- (NSString *) reloadThreadItemIdentifier;
- (NSString *) replyItemIdentifier;
- (NSString *) addFavoritesItemIdentifier;
- (NSString *) deleteItemIdentifier;
- (NSString *) toggleOnlineModeIdentifier;
- (NSString *) launchCMLFIdentifier;
@end