//
//  $Id: BSBoardListView.h,v 1.2 2006/06/25 17:06:42 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/20.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BSBoardListView : NSOutlineView {
	@private
	int _semiSelectedRow; // 選択されていないが、コンテキストメニューのターゲットになっている
	NSRect _semiSelectedRowRect;
	
	//NSImage	*_imageNormal;
	//NSImage	*_imageFocused;
}
- (int) semiSelectedRow;
- (NSRect) semiSelectedRowRect;

//- (NSImage *) imageNormal;
//- (NSImage *) imageFocused;
+ (NSImage *) imageNormal;
+ (NSImage *) imageFocused;
@end
