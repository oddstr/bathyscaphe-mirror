//
//  BSTitleRulerView.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/22.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

/*!
    @class　　　　BSTitleRulerView
    @abstract　　ルーラのスペースを目的外利用して、スレッドタイトルを表示
    @discussion　TextView の上部にスレッドタイトルを表示（3ペインのとき）するために、NSRulerView の
				持っている「土地」だけを譲り受け、drawRect: で整地してスレッドタイトルを描画します。
				スレッドタイトルは、ThreadViewerDidChangeThread の通知を受け取ることで最新のデータに更新します。
*/

#import <Cocoa/Cocoa.h>
#import <SGAppKit/SGAppKit.h>
#import "CMRThreadViewer.h"

@class CMRBrowser;

@interface BSTitleRulerView : NSRulerView {
	@private
	NSString	*m_titleStr;
	NSImage		*m_bgImage;
	
	NSImage		*m_bgImageNonActive;
}

/*!
    @method     initWithScrollView:ofBrowser:
    @abstract   Designated initializer for the BSTitleRulerView class. 
    @discussion BSTitleRulerView クラスの指定イニシャライザで、初期化されたオブジェクトを返します。
*/
- (id) initWithScrollView : (NSScrollView *) scrollView
				ofBrowser : (CMRBrowser   *) browser;

- (NSString *) titleStr;
- (NSImage *) bgImage;
- (NSImage *) bgImageNonActive;
@end
