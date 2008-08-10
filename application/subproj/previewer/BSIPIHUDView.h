//
//  BSIPIHUDView.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/08/04.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface BSIPIHUDView : NSView {
	NSRect	m_cachedRect;
	NSBezierPath *m_cachedPath;
}
@end
