//: SGTextAccessoryFieldController.h
/**
  * $Id: SGTextAccessoryFieldController.h,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGTextAccessoryFieldController
 * @discussion SGTextAccessoryFieldControllerクラス
 */

#import <Cocoa/Cocoa.h>

@class SGBackgroundSurfaceView;
@class NSView, NSTextField, NSButton;

/*!
 * @class      SGTextAccessoryFieldController
 * @abstract   外観を変更できるテキストフィールド
 *
 * @discussion 背景画像を入れ替えることで、外観をカスタマイズ可能な
 *             テキストフィールドをラップしたコントロールクラスです。
 *             また、Mail.appの検索フィールドのように「削除」
 *             ボタンを実装しています。
 *             単純にNSTextFieldをサブクラス化しただけでは
 *             埋め込みボタンを実装できなかったため、複合オブジェクト
 *             のコントローラになっています。
 */

@interface SGTextAccessoryFieldController : NSObject
{
	IBOutlet NSView						*m_componentView;
	IBOutlet SGBackgroundSurfaceView	*m_backgroundView;
	
	IBOutlet NSTextField		*m_textField;
	IBOutlet NSButton			*m_clearButton;
	
	NSView						*m_accessoryView;
	BOOL						_sendsActionOnTextDidChange;
}
+ (float) preferedHeight;
- (id) initWithViewFrame : (NSRect) aFrame;

- (void) setStringValue : (NSString *) aString;
- (void) selectAll : (id) sender;
- (void) sendTextFieldAction;

- (IBAction) clearText : (id) sender;
- (BOOL) sendsActionOnTextDidChange;
- (void) setSendsActionOnTextDidChange : (BOOL) flag;
@end



@interface SGTextAccessoryFieldController(Accessor)
- (NSView *) accessoryView;
- (void) setAccessoryView : (NSView *) anAccessoryView;

- (BOOL) isEmpty;
- (BOOL) clearButtonVisible;
- (void) setVisibleClearButton : (BOOL) flag;
@end



@interface SGTextAccessoryFieldController(ViewAccessor)
- (NSView *) componentView;
- (SGBackgroundSurfaceView *) backgroundView;
- (NSTextField *) textField;
- (NSButton *) clearButton;
@end
