//: NSUserDefaults+SGAppKitExtensions.h
/**
  * $Id: NSUserDefaults+SGAppKitExtensions.h,v 1.1.1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>

@class NSFont, NSColor;


@interface NSUserDefaults(SGAppKitExtensions)
- (NSColor *) colorForKey : (NSString *) key;
- (NSFont *) fontForKey : (NSString *) key;
- (void) setColor : (NSColor  *) color
           forKey : (NSString *) key;
- (void) setFont : (NSFont   *) aFont
          forKey : (NSString *) key;
@end



@interface NSDictionary(SGAppKitExtensions)
- (NSColor *) colorForKey : (id) key;
- (NSFont *) fontForKey : (id) key;
@end



@interface NSMutableDictionary(SGAppKitExtensions)
- (void) setColor : (NSColor *) color
           forKey : (id       ) key;
- (void) setFont : (NSFont *) aFont
          forKey : (id      ) key;
@end
