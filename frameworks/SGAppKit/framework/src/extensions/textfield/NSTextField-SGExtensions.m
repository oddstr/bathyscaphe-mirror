//: SGPrivateTextAccessaryField.m
/**
  * $Id: NSTextField-SGExtensions.m,v 1.1.1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSTextField-SGExtensions.h"


@implementation NSTextField(SGExtensionsFirstResponder)
- (BOOL) isFirstResponder
{
	NSText		*fieldEditor_;
	
	fieldEditor_ = [[self window] fieldEditor:NO forObject:self];
	if(nil == fieldEditor_) return NO;
	if((id)fieldEditor_ != [[self window] firstResponder]) return NO;
	
	return [fieldEditor_ isDescendantOf : self];
}
@end

