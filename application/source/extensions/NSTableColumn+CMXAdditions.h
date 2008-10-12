//
//  NSTableColumn+CMXAdditions.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/10/12.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface NSTableColumn(PropertyListRepresentation)
- (id)propertyListRepresentation;
- (id)initWithPropertyListRepresentation:(id)rep;
@end
