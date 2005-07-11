//:SGContextHelpPanel.m

#import "SGContextHelpPanel.h"
#import "CMXPopUpWindowController.h"



@implementation NSWindow(PopUpWindow)
- (BOOL) isPopUpWindow
{
	return NO;
}
@end



@implementation SGContextHelpPanel
- (BOOL) isPopUpWindow
{
	return YES;
}
- (BOOL) canBecomeKeyWindow
{
	return YES;
}
- (BOOL) canBecomeMainWindow
{
	return NO;
}

- (NSWindow *) ownerWindow
{
	CMXPopUpWindowController	*c;
	
	c = [self windowController];
	if(NO == [c isKindOfClass : [CMXPopUpWindowController class]]){
		return nil;
	}
	return [c ownerWindow];
}
- (void) performMiniaturize : (id) sender
{
	[[self ownerWindow] performMiniaturize : sender];
}
- (void) performClose : (id)sender
{
	[[self ownerWindow] performClose : sender];
}

/*
	2005-07-12 tsawada2<ben-sawa@td5.so-net.ne.jp>
	NSPanel では、 Esc キーが「パネルを閉じる」ショートカットとして動作している。
	ポップアップをクリックしてから Esc キーを押すと親ウインドウも一緒に閉じる問題については、
	上のメソッドで performClose: をパスしているのが原因であるから、それをやめれば直る。
	しかし、そもそも「Esc キーでポップアップを閉じたい」わけではないので（閉じたい人もいるかも？）、
	Esc キーのイベント自体をここでブロックして、無効にすることにする。
*/
- (void) cancelOperation : (id)sender
{
	//NSLog(@"Escape key has been blocked.");
}
@end
