//: CMXThreadDATConvertingTask.h
/**
  * $Id: CMXThreadDATConvertingTask.h,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import "CMRThreadComposingTask.h"



@interface CMXThreadDATConvertingTask : CMRThreadComposingTask
{
	NSString	*_contents;
	unsigned	_baseIndex;
}
+ (id) taskWithContents : (NSString *) datContents;
- (id) initWithContents : (NSString *) datContents;

- (NSString *) contents;
- (void) setContents : (NSString *) aContents;
- (unsigned) baseIndex;
- (void) setBaseIndex : (unsigned) aBaseIndex;
@end



