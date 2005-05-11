//:CMRBrowserTbDelegate.h
/**
  *
  * ブラウザウィンドウのツールバーDelegate
  *
  * @author  Takanori Ishikawa
  * @author  http://www15.big.or.jp/~takanori/
  * @version Sat Jun 15 2002
  *
  */
#import <Foundation/Foundation.h>
#import "CMRThreadViewerTbDelegate.h"

@class CMRNSSearchField;

@interface CMRBrowserTbDelegate : CMRThreadViewerTbDelegate
{
	// Panther 以降では NSSearchField を使用する
	CMRNSSearchField *searchFieldController_;
}
@end
