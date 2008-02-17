//:CMRThreadFileLoadingTask.h
/**
  *
  * �t�@�C������ǂݍ��݁A�\��
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (03/01/17  1:14:58 AM)
  *
  */
#import <Foundation/Foundation.h>
#import "CMRThreadLayoutTask.h"
#import "CMRThreadComposingTask.h"



@interface CMRThreadFileLoadingTask : CMRThreadComposingTask
{
	@private
	NSString				*_filepath;
}
+ (id) taskWithFilepath : (NSString *) filepath;
- (id) initWithFilepath : (NSString *) filepath;

- (NSString *) filepath;
- (void) setFilepath : (NSString *) aFilepath;
@end


// �t�@�C������X���b�h�̏���ǂݍ���
// userInfo : �X���b�h�̏��
//extern NSString *const CMRThreadFileLoadingTaskDidLoadAttributesNotification;
