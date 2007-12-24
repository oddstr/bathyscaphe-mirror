//
//  BSReplyTextTemplateManager.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/12/20.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>
#import "BSReplyTextTemplate.h"

@interface BSReplyTextTemplateManager : NSObject<NSCoding> { // ツールバー絡みで NSCoding が必要
	NSMutableArray *m_templates;
}

+ (id)defaultManager;

- (NSString *)templateForDisplayName:(NSString *)aString;
- (NSString *)templateForShortcutKeyword:(NSString *)aString;

- (NSMutableArray *)templates;
- (void)setTemplates:(NSMutableArray *)anArray;
- (unsigned int)countOfTemplates;
- (id)objectInTemplatesAtIndex:(unsigned int)index;
- (void)insertObject:(id)anObject inTemplatesAtIndex:(unsigned int)index;
- (void)removeObjectFromTemplatesAtIndex:(unsigned int)index;
- (void)replaceObjectInTemplatesAtIndex:(unsigned int)index withObject:(id)anObject;

- (void)writeToFileNow;
@end


@interface BSBugReportingTemplate : BSReplyTextTemplate {
	// Special template for bug-reporting.
}
@end
