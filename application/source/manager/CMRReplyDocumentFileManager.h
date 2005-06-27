//:CMRReplyDocumentFileManager.h
/**
  *
  * 
  *
  * @author  Takanori Ishikawa
  * @author  http://www15.big.or.jp/~takanori/
  * @version Sun Sep 15 2002
  *
  */
#import <Foundation/Foundation.h>


@interface CMRReplyDocumentFileManager : NSObject
{

}
+ (id) defaultManager;
@end



@interface CMRReplyDocumentFileManager(DocumentTypes)
+ (NSArray *) documentAttributeKeys;
- (BOOL) replyDocumentFileExistsAtPath : (NSString *) path;
- (BOOL) createDocumentFileIfNeededAtPath : (NSString     *) filepath
                              contentInfo : (NSDictionary *) contentInfo;

- (NSString *) replyDocumentFileExtention;
- (NSString *) replyDocumentDirectoryWithBoardName : (NSString *) boardName;
- (NSString *) replyDocumentFilepathWithLogPath : (NSString *) filepath;

- (NSArray *) replyDocumentFilesArrayWithLogsArray : (NSArray *) logfiles;
@end

// deprecated in BathyScaphe 1.0.2
//extern NSString *const CMRReplyDocumentFontKey;
//extern NSString *const CMRReplyDocumentColorKey;
