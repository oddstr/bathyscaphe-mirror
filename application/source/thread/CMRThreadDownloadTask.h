//:CMRThreadDownloadTask.h
/**
  *
  * スレッドの更新
  *
  * [NOTE version 1.0.9a]
  * とりあえず、オートリロードの順番が狂う対策として
  * つくったので不完全。
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
