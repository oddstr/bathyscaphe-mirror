//
//  CMRThreadDocument.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/01/27.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMRAbstructThreadDocument.h"

@class CMRThreadViewer;
@class CMRThreadSignature;

@interface CMRThreadDocument: CMRAbstructThreadDocument
- (id) initWithThreadViewer: (CMRThreadViewer *) viewer;

+ (BOOL) showDocumentWithContentOfFile: (NSString *) filepath contentInfo: (NSDictionary *) contentInfo;
+ (BOOL) showDocumentWithHistoryItem: (CMRThreadSignature *) historyItem;
@end
