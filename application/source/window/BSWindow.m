//
//  BSWindow.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/06/12.
//  Copyright 2005 tsawada2. All rights reserved.
//

#import "BSWindow.h"
#import "CMRStatusLineWindowController_p.h"

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1040
enum {
	NSUnifiedTitleAndToolbarWindowMask = 1 << 12,
};
#endif

#define NSAppKitVersionNumber10_3 743	// ここに書かなくてもいいと思うが、念のため

@implementation BSWindow
- (id) initWithContentRect : (NSRect)contentRect
				 styleMask : (unsigned int) styleMask
				   backing : (NSBackingStoreType)backingType
					 defer : (BOOL)flag
{
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_3) {
			// すでに nib ファイルでメタル or つるぺたになっている場合は、つるぺた Mask を加えない
		if ((styleMask & NSTexturedBackgroundWindowMask) == 0 & (styleMask & NSUnifiedTitleAndToolbarWindowMask) == 0) {
			styleMask |= NSUnifiedTitleAndToolbarWindowMask;
		}
	}
	return [super initWithContentRect : contentRect
							styleMask : styleMask
							  backing : backingType
								defer : flag];
}


/* 2005-09-29 tsawada2 <ben-sawa@td5.so-net.ne.jp>
   runToolbarCustomizationPalette: をつかまえてプログレスインジケータを表示させるようにしても、
   ツールバーボタンを Command+option+クリックしてカスタマイズシートを出した場合に捕まえられない。
   （たぶん、ツールバーボタンの方は NSToolbar の runCustomizationPalette を呼び出しているのだろう）。
   かといって、 CMRStatusLineWindowController で windowWillBeginSheet: を捕まえる方法にすると、
   シートの表示が決定してからプログレスインジケータが表示されるため、シートの中身の用意に間に合わない。
   痛し痒し。
   あとは NSToolbar をサブクラス化するか、カテゴリを使って runCustomizationPalette をオーバーライドする手があるが…
   面倒だから今はいいや…
*/
- (void) runToolbarCustomizationPalette : (id) sender
{
	id wc_ = [self windowController];

	if (wc_) {
		if ([wc_ respondsToSelector : @selector(statusLine)])
			[[[(CMRStatusLineWindowController *)wc_ statusLine] progressIndicator] setDisplayedWhenStopped : YES];
	}
	[super runToolbarCustomizationPalette : sender];
}
@end
