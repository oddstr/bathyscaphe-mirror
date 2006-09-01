//
//  $Id: BSBoardListView.h,v 1.2.4.1 2006/09/01 13:46:56 masakih Exp $
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
