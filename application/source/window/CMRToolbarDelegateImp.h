//:CMRToolbarDelegateImp.h
/**
  *
  * NSToolbar Delegate íäè€ÉNÉâÉX
  *
  * @author  Takanori Ishikawa
  * @author  http://www15.big.or.jp/~takanori/
  * @version Fri Jun 14 2002
  *
  */
#import <Foundation/Foundation.h>
#import "CMRToolbarDelegate.h"

@interface CMRToolbarDelegateImp : NSObject<CMRToolbarDelegate>
{
	NSMutableDictionary		*m_itemDictionary;
}
@end
