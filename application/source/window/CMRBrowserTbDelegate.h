//:CMRBrowserTbDelegate.h
/**
  *
  * �u���E�U�E�B���h�E�̃c�[���o�[Delegate
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
	// Panther �ȍ~�ł� NSSearchField ���g�p����
	CMRNSSearchField *searchFieldController_;
}
@end
