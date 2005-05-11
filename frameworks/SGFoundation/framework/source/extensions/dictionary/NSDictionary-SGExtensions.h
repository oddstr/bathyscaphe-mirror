/**
  * $Id: NSDictionary-SGExtensions.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * NSDictionary-SGExtensions.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>

@class NSFont, NSColor;


@interface NSDictionary(SGExtensions)
+ (id) empty;

- (id) deepMutableCopy;
- (id) deepMutableCopyWithZone : (NSZone *) zone;



- (NSString *) stringForKey : (id) key;
- (NSNumber *) numberForKey : (id) key;
- (NSDictionary *) dictionaryForKey : (id) key;
- (NSArray *) arrayForKey : (id) key;



- (float) floatForKey : (id) key
         defaultValue : (float) defaultValue;
- (float) floatForKey : (id) key;
- (double) doubleForKey : (id) key
           defaultValue : (double) defaultValue;
- (double) doubleForKey : (id) key;
- (BOOL) boolForKey : (id) key
       defaultValue : (BOOL) defaultValue;
- (BOOL) boolForKey : (id) key;
- (int) integerForKey : (id) key
		 defaultValue : (int) defaultValue;
- (int) integerForKey : (id) key;
- (unsigned) unsignedIntForKey : (id) key
                  defaultValue : (unsigned int) defaultValue;
- (unsigned) unsignedIntForKey : (id) key;
- (id) objectForKey : (id) key
      defaultObject : (id) defaultObject;

- (NSPoint) pointForKey : (id) key;
- (NSRect) rectForKey : (id) key;
- (NSSize) sizeForKey : (id) key;
@end



@interface NSUserDefaults(SGExtensions030717)
- (int) integerForKey : (NSString *) key
		 defaultValue : (int       ) defaultValue;
- (float) floatForKey : (NSString *) key
         defaultValue : (float     ) defaultValue;
- (BOOL) boolForKey : (NSString *) key
       defaultValue : (BOOL      ) defaultValue;
@end
