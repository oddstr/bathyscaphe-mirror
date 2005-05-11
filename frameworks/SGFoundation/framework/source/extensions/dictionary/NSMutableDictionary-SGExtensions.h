//: NSMutableDictionary-SGExtensions.h
/**
  * $Id: NSMutableDictionary-SGExtensions.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/NSDictionary.h>
#import <Foundation/NSZone.h>
#import <Foundation/NSGeometry.h>



@interface NSMutableDictionary(SGExtensions)
- (void) setNoneNil : (id) obj 
			 forKey : (id) key;
- (void) moveEntryWithKey : (id) key
					   to : (id) other;
- (void) setFloat : (float) aValue
           forKey : (id   ) aKey;
- (void) setDouble : (double) aValue
            forKey : (id    ) aKey;
- (void) setInteger : (int) aValue
             forKey : (id ) aKey;
- (void) setUnsignedInt : (unsigned int) aValue
                 forKey : (id          ) aKey;
- (void) setBool : (BOOL) aValue
          forKey : (id  ) aKey;

- (void) setRect : (NSRect) aValue
		  forKey : (id    ) aKey;
- (void) setSize : (NSSize) aValue
		  forKey : (id    ) aKey;
- (void) setPoint : (NSPoint) aValue
		   forKey : (id     ) aKey;
@end
