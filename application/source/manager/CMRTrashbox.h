//:CMRTrashbox.h
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  *
  */
#import <Foundation/Foundation.h>


@interface CMRTrashbox : NSObject
+ (id) trash;
@end

@interface CMRTrashbox(FileOperation)
- (BOOL) performWithFiles : (NSArray *) filenames;
@end

extern NSString *const CMRTrashboxWillPerformNotification;
extern NSString *const CMRTrashboxDidPerformNotification;

extern NSString *const kAppTrashUserInfoFilesKey;
extern NSString *const kAppTrashUserInfoStatusKey;