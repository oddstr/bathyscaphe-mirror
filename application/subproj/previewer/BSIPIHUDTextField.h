//
//  BSIPIHUDTextField.h
//  BathyScaphe Preview Inspector 2.6
//
//  Created by Tsutomu Sawada on 07/05/01.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface BSIPIHUDTextField : NSTextField {
	NSRect	m_cachedRect;
	NSBezierPath *m_cachedPath;
}

@end
