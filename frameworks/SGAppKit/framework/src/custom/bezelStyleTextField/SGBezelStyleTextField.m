//: SGBezelStyleTextFieldCell.m
/**
  * $Id: SGBezelStyleTextField.m,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGBezelStyleTextField_p.h"


@implementation SGBezelStyleTextField
- (void) awakeFromNib
{
	NSCell		*cell_;
	
	cell_ = [[[[self class] cellClass] alloc] initTextCell : @""];
	[cell_ setAttributesFromCell : [self cell]];
	[self setCell : cell_];
	{
		SGBezelStyleTextFieldCell	*bezeled_;
		
		bezeled_ = (SGBezelStyleTextFieldCell*)cell_;
		if([bezeled_ isKindOfClass : [SGBezelStyleTextFieldCell class]]){
			[bezeled_ setRightSpacing : kDefaultSpacing];
			[bezeled_ setLeftSpacing : kDefaultSpacing];
			[bezeled_ sizeToFit];
		}
	}
	[cell_ release];
}
+ (Class) cellClass
{
	return [SGBezelStyleTextFieldCell class];
}
@end
