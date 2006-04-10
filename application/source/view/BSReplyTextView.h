//
//  $Id: BSReplyTextView.h,v 1.1.4.1 2006/04/10 17:10:21 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/03/13.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSReplyTextView : NSTextView {
	@private
	float	m_alphaValue;
}

- (float) alphaValue;
//- (void) setAlphaValue : (float) floatValue;

- (void) setBackgroundColor : (NSColor *) color withAlphaComponent : (float) alpha;
@end
