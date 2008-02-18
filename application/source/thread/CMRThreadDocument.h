//
//  CMRThreadDocument.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/01/27.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import "CMRAbstructThreadDocument.h"

@class CMRThreadViewer;
@class CMRThreadSignature;

@interface CMRThreadDocument: CMRAbstructThreadDocument {
}
- (id)initWithThreadViewer:(CMRThreadViewer *)viewer;

+ (BOOL)showDocumentWithHistoryItem:(CMRThreadSignature *)historyItem;
+ (BOOL)showDocumentWithContentOfFile:(NSString *)filepath contentInfo:(NSDictionary *)contentInfo;
@end
