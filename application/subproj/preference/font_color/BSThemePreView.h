//
//  BSThemePreView.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 09/01/11.
//  Copyright 2009 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
@class BSThreadViewTheme;

@interface BSThemePreView : NSView {
	BSThreadViewTheme	*m_theme;
}

- (BSThreadViewTheme *)theme;
- (void)setTheme:(BSThreadViewTheme *)aTheme;
- (void)setThemeWithoutNeedingDisplay:(BSThreadViewTheme *)aTheme;
@end
