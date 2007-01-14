/* encoding="UTF-8"
 *
 * BSFontWell.h
 * BathyScaphe
 *
 * Copyright 2005-2007 BathyScaphe Project. All rights reserved.
 * Last Update: 2007-01-14
 */

#import <Cocoa/Cocoa.h>

@interface BSFontWell: NSButton
{
    @private
    NSFont		*m_actualFont;
	id			m_controller;
	NSString	*m_keyPath;
	id			m_delegate;
}

- (NSFont *) fontValue;
- (void) setFontValue: (NSFont *) aFont;

- (void) activate;
- (void) deactivate;

- (id) delegate;
- (void) setDelegate: (id) anObject;
@end

@interface NSObject(BSFontWellDelegate)
- (void) fontValueDidChange: (NSNotification *) aNotification;
@end

extern NSString *const BSFontValueDidChangeNotification;
