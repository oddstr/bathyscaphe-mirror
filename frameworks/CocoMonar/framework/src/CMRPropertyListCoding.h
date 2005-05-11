//: CMRPropertyListCoding.h
/**
  * $Id: CMRPropertyListCoding.h,v 1.1 2005/05/11 17:51:19 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>



// Protocol
@protocol CMRPropertyListCoding<NSObject>
+ (id) objectWithPropertyListRepresentation : (id) rep;
- (id) propertyListRepresentation;
@end


// Informal Protocol
@interface NSObject(CMRPropertyListCoding)
- (id) initWithPropertyListRepresentation : (id) rep;
- (BOOL) initializeFromPropertyListRepresentation : (id) rep;
@end
