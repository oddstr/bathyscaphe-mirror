//
//  BSNobiNobiToolbarItem.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/03/27.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BSNobiNobiView: NSView {
	BOOL	m_shouldDrawBorder;
	BOOL	m_shouldFillBg;
}
- (BOOL) shouldDrawBorder;
- (void) setShouldDrawBorder: (BOOL) draw;
- (BOOL) shouldFillBackground;
- (void) setShouldFillBackground: (BOOL) fill;
@end

@interface BSNobiNobiToolbarItem : NSToolbarItem {
}
@end
