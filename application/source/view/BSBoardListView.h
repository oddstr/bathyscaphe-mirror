//
//  $Id: BSBoardListView.h,v 1.2.2.2 2006/02/27 17:31:50 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/20.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BSBoardListView : NSOutlineView {
	@private
	int _semiSelectedRow; // 選択されていないが、コンテキストメニューのターゲットになっている
	
	NSImage	*_imageNormal;
	NSImage	*_imageFocused;
}
- (int) semiSelectedRow;

- (NSImage *) imageNormal;
- (NSImage *) imageFocused;
@end
