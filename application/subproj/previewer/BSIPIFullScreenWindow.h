//
//  $Id: BSIPIFullScreenWindow.h,v 1.4 2006/07/30 02:39:25 tsawada2 Exp $
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
