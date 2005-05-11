//:CMRThreadsUpdateListTask.h
/**
  *
  * ���[�J�[�X���b�h��Ŏ��s�����
  * �X���b�h�ꗗ�̍X�V���
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (03/01/19  2:32:21 AM)
  *
  */
#import <Foundation/Foundation.h>
#import "CMRThreadLayoutTask.h"



@interface CMRThreadsUpdateListTask : CMRThreadLayoutConcreateTask
{
	@private
	NSString				*_boardName;
	
	NSMutableArray			*_threadsArray;
	NSMutableDictionary		*_pathMappingTbl;
	BOOL					_isUpdate;
	
	unsigned		_progress;
}
// 
// ���ۂɂ�loadedList�̗v�f��
// �Ȃǂ�ύX�͂��Ȃ�
// 
+ (id) taskWithLoadedList : (NSMutableArray      *) loadedList
			  pathMapping : (NSMutableDictionary *) table
			       update : (BOOL                 ) isUpdated;
- (id) initWithLoadedList : (NSMutableArray      *) loadedList
			  pathMapping : (NSMutableDictionary *) table
			       update : (BOOL                 ) isUpdated;

- (NSString *) boardName;
- (void) setBoardName : (NSString *) aBoardName;
@end


#define kCMRUserInfoThreadsArrayKey		@"threadsArray"
#define kCMRUserInfoThreadsDictKey		@"threadsInfo"
#define kCMRUserInfoIsUpdatedKey		@"updated"		// NSNumber As BOOL


// 
// �X�V�̊�����ʒm
// 
extern NSString *const CMRThreadsUpdateListTaskDidFinishNotification;
