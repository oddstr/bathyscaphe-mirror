//
//  BSSegmentedControlTbItem.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/08/30.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoMonar_Prefix.h"

/*!
    @class			BSSegmentedControlTbItem
    @abstract		BSSegmentedControlTbItem は、NSToolbarItem のサブクラスで、「戻る／進む」ボタンの
					適切な validation のために用意されています。この toolbarItem は NSSegmentedControl を
					view として持っています。
    @discussion		このクラスはほとんどオリジナルの NSToolbarItem と変わりませんが、view item を適切に validate
					するために、validate メソッドをオーバーライドしています。また、NSSegmentedControl を作成する
					作業を一括して行うため、setupItemViewWithTarget: メソッドを独自に持っています。これは
					ツールバー作成時に、CMRThreadViewerTbDelegate から呼び出されます。
*/

@interface BSSegmentedControlTbItem : NSToolbarItem {

}
- (void) setupItemViewWithTarget : (id) windowController_;
@end
