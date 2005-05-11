//:CMRDocumentFileManager.h
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/15  10:57:26 PM)
  *
  */
#import <Foundation/Foundation.h>


@class SGFileRef;
@interface CMRDocumentFileManager : NSObject
+ (id) defaultManager;

- (NSString *) threadDocumentFileExtention;

- (NSString *) datIdentifierWithLogPath : (NSString *) filepath;
- (NSString *) boardNameWithLogPath : (NSString *) filepath;

- (NSString *) threadPathWithBoardName : (NSString *) boardName
                         datIdentifier : (NSString *) datIdentifier;
- (NSString *) threadsListPathWithBoardName : (NSString *) boardName;

// Ç±ÇÃÇ÷ÇÒÅAÇ±ÇÃÉNÉâÉXÇ≤Ç∆Ç»Ç≠Ç»ÇÈó\íË
- (SGFileRef *) ensureDirectoryExistsWithBoardName : (NSString *) boardName;
- (NSString *) directoryWithBoardName : (NSString *) boardName;
@end

