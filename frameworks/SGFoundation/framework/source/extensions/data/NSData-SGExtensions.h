//: NSData-SGExtensions.h
/**
  * $Id: NSData-SGExtensions.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>

@class SGFileRef;

@interface NSData(SGExtensions)
+ (id) dataWithContentsOfFileRef : (SGFileRef *) fileRef;
- (id) initWithContentsOfFileRef : (SGFileRef *) fileRef;

- (BOOL) isEmpty;
@end
