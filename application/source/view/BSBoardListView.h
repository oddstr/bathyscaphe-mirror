//
//  $Id: BSBoardListView.h,v 1.2.2.1 2006/01/29 12:58:10 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/20.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SGAppKit/SGAppKit.h>

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
