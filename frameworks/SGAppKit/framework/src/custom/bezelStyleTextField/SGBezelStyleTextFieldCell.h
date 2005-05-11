//: SGBezelStyleTextFieldCell.h
/**
  * $Id: SGBezelStyleTextFieldCell.h,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSTextFieldCell.h>
#import <SGAppKit/NSCell-SGExtensions.h>


@interface SGBezelStyleTextFieldCell : NSTextFieldCell
{
	float		m_leftSpacing;
	float		m_rightSpacing;
}
@end



@interface SGBezelStyleTextFieldCell(Spacing)
- (void) sizeToFit;

- (float) leftSpacing;
- (float) rightSpacing;
- (void) setLeftSpacing : (float) aLeftSpacing;
- (void) setRightSpacing : (float) aRightSpacing;
@end
