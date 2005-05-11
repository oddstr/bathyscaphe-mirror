//:SGDocument.h
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.9a2 (03/01/20  6:04:28 PM)
  *
  */
#import <Cocoa/Cocoa.h>



@interface SGDocument : NSDocument
@end



@interface NSWindowController(SGDocumentDelegate)
- (void)    document : (NSDocument         *) aDocument
willRemoveController : (NSWindowController *) aController;
@end
