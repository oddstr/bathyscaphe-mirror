//
//  BSThreadViewTheme.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/03/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSThreadViewTheme : NSObject<NSCoding, NSCopying> {
	NSString			*m_identifier;
	NSMutableDictionary *m_themeDict;
}

- (id) initWithIdentifier: (NSString *) aString;
- (id) initWithContentsOfFile: (NSString *) filePath;
- (BOOL) writeToFile: (NSString *) filePath atomically: (BOOL) atomically;

- (NSString *) identifier;
- (void) setIdentifier: (NSString *) aString;
@end

@interface BSThreadViewTheme(Accessors)
- (NSFont *) baseFont;
- (void) setBaseFont: (NSFont *) font;
- (NSColor *) baseColor;
- (void) setBaseColor: (NSColor *) color;

- (NSColor *) nameColor;
- (void) setNameColor: (NSColor *) color;

- (NSFont *) titleFont;
- (void) setTitleFont: (NSFont *) font;
- (NSColor *) titleColor;
- (void) setTitleColor: (NSColor *) color;

- (NSFont *) hostFont;
- (void) setHostFont: (NSFont *) font;
- (NSColor *) hostColor;
- (void) setHostColor: (NSColor *) color;

- (NSFont *) beFont;
- (void) setBeFont: (NSFont *) font;

- (NSFont *) messageFont;
- (void) setMessageFont: (NSFont *) font;
- (NSColor *) messageColor;
- (void) setMessageColor: (NSColor *) color;

- (NSFont *) AAFont;
- (void) setAAFont: (NSFont *) font;

- (NSFont *) bookmarkFont;
- (void) setBookmarkFont: (NSFont *) font;
- (NSColor *) bookmarkColor;
- (void) setBookmarkColor: (NSColor *) color;

- (NSColor *) linkColor;
- (void) setLinkColor: (NSColor *) color;

- (NSColor *) backgroundColor;
- (void) setBackgroundColor: (NSColor *) color;
@end

extern NSString *const kThreadViewThemeDefaultThemeIdentifier;
extern NSString *const kThreadViewThemeCustomThemeIdentifier;
