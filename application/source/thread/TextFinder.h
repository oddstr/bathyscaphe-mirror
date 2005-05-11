//:TextFinder.h
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/11/13  7:16:33 PM)
  *
  */
#import <Cocoa/Cocoa.h>
#import <CocoMonar/CocoMonar.h>


@class CMRSearchOptions;



@interface TextFinder : NSWindowController
{
	IBOutlet NSTextField *_findTextField;
	IBOutlet NSMatrix    *_buttonMatrix;
	IBOutlet NSMatrix    *_optionMatrix;
}
+ (id) standardTextFinder;

- (CMRSearchMask) searchOption;
- (void) setSearchOption : (CMRSearchMask) aOption;

- (CMRSearchOptions *) currentOperation;


- (IBAction) updateComponents : (id) sender;
- (void) setFindString: (NSString *)aString;

/*
- (NSPasteboard *) pasteboardForFind;
- (NSString *) loadFindStringFromPasteboard;
- (void) setFindStringToPasteboard;

*/
@end
