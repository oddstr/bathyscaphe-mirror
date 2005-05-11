//: NSMutableAttributedString-SGExtentions.h
/**
  * $Id: NSMutableAttributedString-SGExtensions.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/NSObject.h>
#import <Foundation/NSAttributedString.h>

@class NSString, NSDictionary;
@interface NSMutableAttributedString(SGExtentions)
- (void) addAttribute : (NSString *) name
				value : (id        ) value;

- (void) deleteAll;

- (void) appendString : (NSString     *) str
       withAttributes : (NSDictionary *) dict;
- (void) appendString : (NSString *) str
        withAttribute : (NSString *) attrsName
                value : (id        ) value;
@end
