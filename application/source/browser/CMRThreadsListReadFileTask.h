//:CMRThreadsListReadFileTask.h
/**
  *
  * スレッド一覧をファイルから読み込む
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (03/01/19  10:51:04 AM)
  *
  */
#import <Foundation/Foundation.h>
#import "CMRThreadsUpdateListTask.h"



@interface CMRThreadsListReadFileTask : CMRThreadsUpdateListTask
{
	NSString		*_threadsListPath;
	unsigned		_readingProgress;
}
+ (id) taskWithThreadsListPath : (NSString            *) path
			       pathMapping : (NSMutableDictionary *) table;
- (id) initWithThreadsListPath : (NSString            *) path
			       pathMapping : (NSMutableDictionary *) table;
@end
