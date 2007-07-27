//:CMRBrowserTbDelegate_p.h
#import "CMRBrowserTbDelegate.h"

#import "CocoMonar_Prefix.h"
#import "CMRThreadViewerTbDelegate_p.h"



@interface CMRBrowserTbDelegate(Private)
- (NSMenuItem *) searchToolbarItemMenuFormRepresentationWithItem : (NSToolbarItem *) anItem;
- (void) setupSearchToolbarItem : (NSToolbarItem *) anItem
					   itemView : (NSView		 *) aView;
- (void) setupSwitcherToolbarItem : (NSToolbarItem *) anItem
					   itemView : (NSView		 *) aView;
- (void) setupSpace: (NSToolbarItem *) anItem;
@end