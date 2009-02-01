//
//  BSIPIFullScreenWindow.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/14.
//  Copyright 2006-2009 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface BSIPIFullScreenWindow : NSWindow
{
}
@end

@interface NSObject(BSIPIFullScreenWindowAddition)
- (BOOL) handlesKeyDown : (NSEvent *) keyDown inWindow : (NSWindow *) window;
- (BOOL) handlesMouseDown : (NSEvent *) mouseDown inWindow: (NSWindow *) window;
- (BOOL) handlesScrollWheel : (NSEvent *) scrollWheel inWindow: (NSWindow *) window;
- (BOOL)handlesSwipe:(NSEvent *)event inWindow:(NSWindow *)window;
@end
