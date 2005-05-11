//:CMRThreadLayoutTask.h
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (03/01/16  11:56:40 PM)
  *
  */
#import <Foundation/Foundation.h>
#import "CocoMonar_Prefix.h"
#import "CMRTask.h"
#import "CMRThreadLayout.h"
#import "CMXInternalMessaging.h"



@protocol CMRThreadLayoutTask <NSObject, CMRTask, CMXRunnable>
/**
  * @exception CMRThreadTaskInterruptedException
  *            �L�����Z����\�����Ȃ��󋵂ɂ��I�������B
  */
- (void) executeWithLayout : (CMRThreadLayout *) layout;
@end



@interface CMRThreadLayoutConcreateTask : SGBaseObject<CMRThreadLayoutTask>
{
	BOOL		_isInterrupted;
	BOOL		_didFinished;
	
	id			_identifier;
	CMRThreadLayout	*_layout;
}
// initializer
+ (id) task;
+ (id) taskWithIndentifier : (id) anIdentifier;

- (id) identifier;
- (void) setIdentifier : (id) anIdentifier;

- (CMRThreadLayout *) layout;
- (void) setLayout : (CMRThreadLayout *) aLayout;

- (BOOL) isInterrupted;
- (void) setIsInterrupted : (BOOL) anIsInterrupted;
/**
  * @exception CMRThreadTaskInterruptedException
  *            [self isInterrupted] == YES�Ȃ��O�𔭐�
  */
- (void) checkIsInterrupted;
- (BOOL) didFinished;
- (void) setDidFinished : (BOOL) aDidFinished;
/**
  * 
  * �ȉ��̃��\�b�h�̓T�u�N���X�ɒ�
  * 
  */
- (NSString *) messageInProgress;
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout;
- (void) finalizeWhenInterrupted;
@end



/* subclasses */
@interface CMRThreadClearTask : CMRThreadLayoutConcreateTask
@end
