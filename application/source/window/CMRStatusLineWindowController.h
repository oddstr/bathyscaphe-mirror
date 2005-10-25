//:CMRStatusLineWindowController.h
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/24  11:18:18 AM)
  *
  */
#import <Cocoa/Cocoa.h>
#import <SGAppKit/SGAppKit.h>
#import "CMRToolbarWindowController.h"

@class CMRStatusLine;

@interface CMRStatusLineWindowController : CMRToolbarWindowController
{
	@private
	CMRStatusLine				*m_statusLine;
}
- (IBAction) toggleStatusLineShown : (id) sender;

// board / thread signature for historyManager .etc
- (id) boardIdentifier;
- (id) threadIdentifier;
@end



@interface CMRStatusLineWindowController(Action)
- (IBAction) saveAsDefaultFrame : (id) sender;
- (IBAction) cancelCurrentTask : (id) sender;
@end

