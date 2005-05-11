/**
  * $Id: CMRPullsDownButton.m,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * CMRPullsDownButton.m
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRPullsDownButton.h"
#import "UTILKit.h"

#import <Carbon/Carbon.h>



// We just need private API!
@interface NSMenu (NSMenu_private_API)
- (void)_popUpContextMenu:(id)arg1 withEvent:(id)arg2 forView:(id)arg3 withFont:(id)arg4;
@end
/* Get the Carbon MenuRef from NSMenu */
extern MenuRef _NSGetCarbonMenu(NSMenu *);


#define NEEDS_UPDATED_WIDTH -1
#define kMenuFontSize     11.0f
/*
Since I need menu width but there is no public API, 
use static value by hand.
*/
#define kMenuInnerSpacing 20.0f
#define kMenuShadowWidth  4.0f



@implementation CMRPullsDownButton
//
// P R I V A T E
//
- (NSFont *) menuFont
{
    return [NSFont menuFontOfSize : kMenuFontSize];
}

// Why Apple provides so poor Menu related API?
- (float) getMenuWidth : (NSMenu *) aMenu
{
    NSEnumerator *iter;
    NSMenuItem   *item;
    NSDictionary *attrs;
    float        maxWidth = 0;
    
    iter = [[aMenu itemArray] objectEnumerator];
    attrs = [NSDictionary dictionaryWithObject : [self menuFont]
                forKey : NSFontAttributeName];
                
    while (item = [iter nextObject]) {
        NSSize size = [[item title] sizeWithAttributes : attrs];
        
        if (maxWidth < size.width) {
            maxWidth = size.width;
        }
    }
    maxWidth += (kMenuInnerSpacing + kMenuShadowWidth)*2;
    
    return maxWidth;
}
- (float) menuWidth
{
    // can be cached?
    return [self getMenuWidth : [self menu]];
}



//
// P U B L I C
// 

// ----------------------------------------
// NSPopUpButton
// ----------------------------------------
- (NSEvent *) popUpMenuEventFromMouseDownEvent : (NSEvent *) theEvent
{
    NSPoint loc = [theEvent locationInWindow];
    
    loc = ([[self superview] convertPoint:([self frame]).origin toView:nil]);
    
    {
        float width = [self menuWidth];
        float maxX = NSMaxX([[NSScreen mainScreen] visibleFrame]);
        
        loc = [[self window] convertBaseToScreen : loc];
        // screen max y edge
        if (maxX < (loc.x + width)) {
            loc.x -= ((loc.x + width) - maxX);
        }
        // screen min x edge
        if (loc.x < kMenuShadowWidth) {
            loc.x = kMenuShadowWidth;
        }
        loc = [[self window] convertScreenToBase : loc];
    }
    
    return [NSEvent mouseEventWithType : [theEvent type]
                        location:loc
                        modifierFlags:[theEvent modifierFlags]
                        timestamp:[theEvent timestamp]
                        windowNumber:[theEvent windowNumber]
                        context:[theEvent context]
                        eventNumber:[theEvent eventNumber]
                        clickCount:[theEvent clickCount]
                        pressure:[theEvent pressure]];
}
    
- (void) mouseDown : (NSEvent *) theEvent
{
    if (NO == [self isEnabled]) {
        [super mouseDown : theEvent];
        return;
    }
    /*
    when I display the NSPopUpButton's menu in the NSButton, 
    the labels are big. Then if user click on the NSPopUpButton, 
    the labels are small the next time user display the menu.
    
    So I'm trying:
    (1) First, try to use public API (Since 10.3): 
    + [NSMenu popUpContextMenu:withEvent:forView:withFont:]
    (2) In the end, believe - [NSPopUpButton mouseDown:] can
    attach small font nicely.
    */
    NSMenu *menu = [self menu];
    SEL popUpSEL = @selector(popUpContextMenu:withEvent:forView:withFont:);
    NSEvent *event = [self popUpMenuEventFromMouseDownEvent : theEvent];
    
    if ([NSMenu respondsToSelector : popUpSEL]) {
        [NSMenu popUpContextMenu : menu
                       withEvent : event
                         forView : self
                        withFont : [self menuFont]];
    } else {
        // - [NSMenu _popUpContextMenu:withEvent:forView:withFont:]
        // doesn't work in any OS version?
        if (NO == _isAttached) {
            [super mouseDown : theEvent];
            _isAttached = YES;
            return;
        }
        [NSMenu popUpContextMenu : menu
                       withEvent : event
                         forView : self];
    }
}
@end
