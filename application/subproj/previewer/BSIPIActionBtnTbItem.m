//
//  $Id: BSIPIActionBtnTbItem.m,v 1.1.2.1 2006/01/28 16:06:42 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/07.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIActionBtnTbItem.h"
#import "BSImagePreviewInspector.h"

@implementation BSIPIActionBtnTbItem
- (void) validate
{
	id	popupBtn = [self view];
	BSImagePreviewInspector	*wc_ = [self target];

	if (!wc_ || !popupBtn) return;

	if([wc_ currentDownload]) {
		[popupBtn setEnabled : NO];
	} else {
		[popupBtn setEnabled : ([[wc_ imageView] image] != nil)];
	}
}


@end
