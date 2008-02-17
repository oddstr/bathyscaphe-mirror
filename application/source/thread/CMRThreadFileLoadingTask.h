//:CMRThreadFileLoadingTask.h
/**
  *
  * ファイルから読み込み、表示
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


// ファイルからスレッドの情報を読み込んだ
// userInfo : スレッドの情報
//extern NSString *const CMRThreadFileLoadingTaskDidLoadAttributesNotification;
