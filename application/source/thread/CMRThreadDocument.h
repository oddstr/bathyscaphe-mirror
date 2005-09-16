//:CMRThreadDocument.h
/**
  *
  * ÉXÉåÉbÉhÇÃèëóﬁ
  *
  * @author  Takanori Ishikawa
  * @author  http://www15.big.or.jp/~takanori/
  * @version Fri Jun 21 2002
  *
  */
#import <Cocoa/Cocoa.h>
#import "CMRAbstructThreadDocument.h"

@class CMRThreadViewer;



@interface CMRThreadDocument : CMRAbstructThreadDocument
- (id) initWithThreadViewer : (CMRThreadViewer *) viewer;
@end



@interface CMRThreadDocument(OpenDocument)
+ (BOOL) showDocumentWithContentOfFile : (NSString     *) filepath
						   contentInfo : (NSDictionary *) contentInfo;

- (BOOL) windowAlreadyExistsForPath : (NSString *) filePath;
@end
