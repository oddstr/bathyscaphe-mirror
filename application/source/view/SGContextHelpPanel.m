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
	NSPanel �ł́A Esc �L�[���u�p�l�������v�V���[�g�J�b�g�Ƃ��ē��삵�Ă���B
	�|�b�v�A�b�v���N���b�N���Ă��� Esc �L�[�������Ɛe�E�C���h�E���ꏏ�ɕ�����ɂ��ẮA
	��̃��\�b�h�� performClose: ���p�X���Ă���̂������ł��邩��A�������߂�Β���B
	�������A���������uEsc �L�[�Ń|�b�v�A�b�v��������v�킯�ł͂Ȃ��̂Łi�������l�����邩���H�j�A
	Esc �L�[�̃C�x���g���̂������Ńu���b�N���āA�����ɂ��邱�Ƃɂ���B
*/
- (void) cancelOperation : (id)sender
{
	//NSLog(@"Escape key has been blocked.");
}
@end
