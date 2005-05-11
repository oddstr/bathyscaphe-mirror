//: SGComparable.h
/**
  * $Id: SGComparable.h,v 1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSCell.h>



@protocol SGComparable
- (NSComparisonResult) compareTo : (id) other;
@end



@interface NSDate(SGComparable)<SGComparable>
@end

@interface NSString(SGComparable)<SGComparable>
@end

@interface NSNumber(SGComparable)<SGComparable>
@end

@interface NSCell(SGComparable)<SGComparable>
@end
