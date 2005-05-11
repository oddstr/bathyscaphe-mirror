//: NSArray-SGExtensions.h
/**
  * $Id: NSArray-SGExtensions.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import "SGDeepCopying.h"



@interface NSArray(SGExtensions)<SGDeepCopying>
+ (id) empty;
- (BOOL) isEmpty;
// firstObject used by HTMLView
- (id) head;
@end



#if 0
@interface NSArray(CStringArrayExtension)
+ (id) arrayWithUTF8Strings : (const char *) first,...;
- (id) initWithUTF8Strings : (const char *) first,...;
- (id) initWithUTF8Strings : (const char *) first
				 arguments : (va_list     ) vList;
@end
#endif
