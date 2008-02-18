//
//  CMRDocumentController.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/19.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>
#import <AppKit/NSDocumentController.h>

@interface CMRDocumentController : NSDocumentController {
}

// Returns nil if no document for absoluteDocumentURL is open.
- (NSDocument *)documentAlreadyOpenForURL:(NSURL *)absoluteDocumentURL; // Available in SilverGull and later.
@end
