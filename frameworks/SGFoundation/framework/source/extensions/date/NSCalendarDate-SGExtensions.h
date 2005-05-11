/**
 * $Id: NSCalendarDate-SGExtensions.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
 * 
 * NSCalendarDate-SGExtensions.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import <Foundation/NSCalendarDate.h>



@interface NSCalendarDate(SGExtensions)
+ (id) dateWithHTTPTimeRepresentation : (NSString *) desc;
- (id) initWithHTTPTimeRepresentation : (NSString *) desc;
@end
