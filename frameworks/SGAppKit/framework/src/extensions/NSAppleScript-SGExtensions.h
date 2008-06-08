//
//  NSAppleScript-SGExtensions.h
//  SGAppKit
//
//  Created by Tsutomu Sawada on 08/06/08.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAppleScript(SGExtensions)
- (BOOL)doHandler:(NSString *)handlerName withParameters:(NSArray *)params error:(NSDictionary **)errPtr;
@end
