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
// not available
- (BOOL) deleteFiles;
@end



//////////////////////////////////////////////////////////////////////
////////////////////// [ �萔��}�N���u�� ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/**
  * userInfo:
  * 	@"Files"	-- filepaths to be performed (NSArray)
  * 	@"Status"	-- Error code: noErr = succeeded (NSNumber)
  *
  */
#define kAppTrashUserInfoFilesKey	@"Files"
#define kAppTrashUserInfoStatusKey	@"Status"

extern NSString *const CMRTrashboxWillPerformNotification;
extern NSString *const CMRTrashboxDidPerformNotification;
