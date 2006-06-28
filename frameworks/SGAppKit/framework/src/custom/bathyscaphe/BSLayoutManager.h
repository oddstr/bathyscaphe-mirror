//
//  $Id: BSLayoutManager.h,v 1.1 2006/06/28 18:36:38 tsawada2 Exp $
//  BathyScaphe (SGAppKit)
//
//  Created by Tsutomu Sawada on 06/06/28.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSLayoutManager : NSLayoutManager
{
	@private
	BOOL	bs_liveResizing;
	BOOL	bs_shouldAntialias;
}

- (BOOL) textContainerInLiveResize;
- (void) setTextContainerInLiveResize: (BOOL) flag;

- (BOOL) shouldAntialias;
- (void) setShouldAntialias: (BOOL) flag;
@end
