
/**
  *
  * ツールバーをもつウィンドウのコントローラ
  *
  * @author  Takanori Ishikawa
  * @author  http:
  * @version Sat Jun 22 2002
  *
  */
#import <Cocoa/Cocoa.h>
#import "CocoMonar_Prefix.h"

@protocol CMRToolbarDelegate;



@interface CMRToolbarWindowController : NSWindowController
{
	@private
	id<CMRToolbarDelegate>		m_toolbarDelegateImp;
}
+ (Class) toolbarDelegateImpClass;
- (id<CMRToolbarDelegate>) toolbarDelegate;
@end



@interface CMRToolbarWindowController(ViewSetup)
- (void) setupUIComponents;
@end
