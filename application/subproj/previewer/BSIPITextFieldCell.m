//
//  $Id: BSIPITextFieldCell.m,v 1.1 2006/07/26 16:28:25 tsawada2 Exp $
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
