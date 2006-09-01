//
//  $Id: BSIPITextFieldCell.m,v 1.1.4.1 2006/09/01 13:46:54 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/07/10.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPITextFieldCell.h"


@implementation BSIPITextFieldCell
- (NSRect) drawingRectForBounds: (NSRect) theRect
{
	return NSInsetRect([super drawingRectForBounds: theRect], 0, 10.0);
}
@end
