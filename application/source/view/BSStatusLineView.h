//
//  BSStatusLineView.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/03/14.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <SGAppKit/BSTsuruPetaView.h>


@interface BSStatusLineView : BSTsuruPetaView {
	@private
	NSString	*m_messageText;
	float		m_rightMargin;
}

- (NSString *)messageText;
- (void)setMessageText:(NSString *)aString;

- (float)rightMargin;
- (void)setRightMargin:(float)floatValue;
@end
