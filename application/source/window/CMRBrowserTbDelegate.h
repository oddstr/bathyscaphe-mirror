//
//  CMRBrowserTbDelegate.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/07/27.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>
#import "CMRThreadViewerTbDelegate.h"

@interface CMRBrowserTbDelegate : CMRThreadViewerTbDelegate
{
}
@end

@interface CMRBrowserTbDelegate(Private)
- (void)setupSearchToolbarItem:(NSToolbarItem *)anItem itemView:(NSView *)aView;
- (void)setupSwitcherToolbarItem:(NSToolbarItem *)anItem itemView:(NSView *)aView delegate:(id)delegate windowStyle:(unsigned int)styleMask;
- (void)setupNobiNobiToolbarItem:(NSToolbarItem *)anItem;
@end
