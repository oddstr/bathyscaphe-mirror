//
//  BSPopUpTitlebar.h
//  BathyScaphe "Twincam Angel"
//
//  Created by Tsutomu Sawada on 07/07/29.
//  Copyright 2007-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface BSPopUpTitlebar : NSView {
	NSString *m_titleString;
	NSButton *m_closeButton;
@private
	BOOL m_isPressed;
}

- (NSString *)title;
- (void)setTitle:(NSString *)titleString;
- (void)setTitleWithoutNeedingDisplay:(NSString *)titleString;
- (NSButton *)closeButton;
@end
