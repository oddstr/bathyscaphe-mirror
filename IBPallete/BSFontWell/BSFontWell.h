//
//  BSFontWell.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/11/02.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@interface BSFontWell: NSButton {
    @private
    NSFont		*m_actualFont;
	id			m_controller;
	NSString	*m_keyPath;
	id			m_delegate;
}

- (NSFont *)fontValue;
- (void)setFontValue:(NSFont *)aFont;

- (void)activate;
- (void)deactivate;

- (id)delegate;
- (void)setDelegate:(id)anObject;
@end


@interface NSObject(BSFontWellDelegate)
- (void)fontValueDidChange:(NSNotification *)aNotification;
@end

extern NSString *const BSFontValueDidChangeNotification;
