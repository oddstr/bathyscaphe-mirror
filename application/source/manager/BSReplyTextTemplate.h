//
//  BSReplyTextTemplate.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/12/20.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>

@protocol CMRPropertyListCoding;

@interface BSReplyTextTemplate : NSObject<NSCoding, CMRPropertyListCoding> {
	NSString	*m_displayName;
	NSString	*m_shortcutKeyword;
	NSString	*m_template;
}

- (NSString *)displayName;
- (void)setDisplayName:(NSString *)aString;

- (NSString *)shortcutKeyword;
- (void)setShortcutKeyword:(NSString *)aString;

- (NSString *)template;
- (void)setTemplate:(NSString *)aString;

- (NSString *)templateDescription; // Dummy
@end
