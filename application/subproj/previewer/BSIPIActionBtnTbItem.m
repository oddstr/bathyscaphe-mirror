//
//  $Id: BSIPIActionBtnTbItem.m,v 1.1.2.3 2006/09/01 13:46:54 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/07.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIActionBtnTbItem.h"

@implementation BSIPIActionBtnTbItem
- (id) delegate
{
	return bsIPIABTI_delegate;
}

- (void) setDelegate: (id) aDelegate
{
	bsIPIABTI_delegate = aDelegate;
}

- (void) validate
{
	id	popupBtn = [self view];
	id	myDelegate = [self delegate]; 

	if (!popupBtn) return;
	if (!myDelegate || ![myDelegate respondsToSelector: @selector(validateActionBtnTbItem:)]) {
		[popupBtn setEnabled: NO];
		return;
	}

	[popupBtn setEnabled: [myDelegate validateActionBtnTbItem: self]];
}

- (void) dealloc
{
	[self setDelegate: nil];
	[super dealloc];
}
@end
