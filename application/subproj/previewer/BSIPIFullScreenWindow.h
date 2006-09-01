//
//  $Id: BSIPIFullScreenWindow.h,v 1.1.2.2 2006/09/01 13:46:54 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/14.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSIPIFullScreenWindow : NSWindow
{
}
@end

@interface NSObject(BSIPIFullScreenWindowAddition)
- (BOOL) handlesKeyDown : (NSEvent *) keyDown inWindow : (NSWindow *) window;
- (BOOL) handlesMouseDown : (NSEvent *) mouseDown inWindow: (NSWindow *) window;
@end
