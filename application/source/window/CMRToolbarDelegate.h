//:CMRToolbarDelegate.h
/**
  *
  * NSToolbar Delegate
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/06/14  3:09:56 PM)
  *
  */
#import <Foundation/Foundation.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSToolbarItem.h>

@protocol CMRToolbarDelegate<NSObject>
- (NSString *) identifier;
- (void) attachToolbarWithWindow : (NSWindow *) aWindow;
- (NSToolbarItem *) itemForItemIdentifier : (NSString *) anIdentifier;
@end