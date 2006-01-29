//
//  $Id: BSIPIFullScreenWindow.h,v 1.1.2.1 2006/01/29 12:58:10 masakih Exp $
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
