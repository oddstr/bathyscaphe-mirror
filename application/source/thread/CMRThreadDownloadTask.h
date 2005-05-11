//:CMRThreadDownloadTask.h
/**
  *
  * �X���b�h�̍X�V
  *
  * [NOTE version 1.0.9a]
  * �Ƃ肠�����A�I�[�g�����[�h�̏��Ԃ������΍�Ƃ���
  * �������̂ŕs���S�B
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.9a2 (03/01/20  11:46:10 PM)
  *
  */
#import <Foundation/Foundation.h>
#import "CMRThreadLayoutTask.h"

@class CMRThreadViewer;



@interface CMRThreadDownloadTask : CMRThreadLayoutConcreateTask
{
	@private
	CMRThreadViewer		*_threadViewer;
}
- (id) initWithThreadViewer : (CMRThreadViewer *) tviewr;
@end
