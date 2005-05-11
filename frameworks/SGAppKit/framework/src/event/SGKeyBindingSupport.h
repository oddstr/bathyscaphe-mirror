//: SGKeyBindingSupport.h
/**
  * $Id: SGKeyBindingSupport.h,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGAppKit/SGKeyBindingSupport
 * @discussion Custom Key Bindings Support
 */
#import <Cocoa/Cocoa.h>


/*
キーバインディング文字列のマクロ展開
マクロの一覧はSGKeybindingMacros.plistにある。
*/
/*!
 * @class       SGKeyBindingSupport
 * @abstract    アプリケーションのキー・バインディングを提供する
 *
 * @discussion  
 * CocoaのKey Bindingで使われているProperty List形式のキー・バインディング
 * ファイルを読み込んで、キー入力とアクションを関連づけます
 * 
 * "^" = Control Key
 * "~" = Alt Key
 * "$" = Shift Key
 * "#" = Numeric Keypad
 * "@" = Command Key
 *
 * See Also:
 *   http://developer.apple.com/techpubs/macosx/Cocoa/TasksAndConcepts/ProgrammingTopics/BasicEventHandling/Tasks/TextDefaultsAndBindings.html
 *   http://developer.apple.com/techpubs/macosx/Cocoa/TasksAndConcepts/ProgrammingTopics/InputManager/index.html
 */



@interface SGKeyBindingSupport : NSObject
{
	@private
	NSDictionary		*_keyBindingDict;
}
/*!
 * @method              keyBindingSupportWithContentsOfFile:
 * @abstract            autoreleaseされたインスタンスの生成
 * @discussion          KeyBindings.dictを読み込んで、インスタンスを生成します
 *
 * @param dictFilepath  KeyBindings.dictのファイルパス
 * @result              autoreleaseされたインスタンス
 */
+ (id) keyBindingSupportWithContentsOfFile : (NSString *) dictFilepath;
/*!
 * @method      keyBindingSupportWithDictionary:
 * @abstract    autoreleaseされたインスタンスの生成
 * @discussion  KeyBindings.dictの内容を読み込んで、
 *              インスタンスを生成します
 *
 * @param dict  KeyBindings.dictの辞書
 * @result      autoreleaseされたインスタンス
 */
+ (id) keyBindingSupportWithDictionary : (NSDictionary *) dict;

/*!
 * @method              initWithContentsOfFile:
 * @abstract            autoreleaseされたインスタンスの生成
 * @discussion          KeyBindings.dictを読み込んで、インスタンスを生成します
 *
 * @param dictFilepath  KeyBindings.dictのファイルパス
 * @result              autoreleaseされたインスタンス
 */
- (id) initWithContentsOfFile : (NSString *) dictFilepath;
/*!
 * @method      initWithDictionary:
 * @abstract    autoreleaseされたインスタンスの生成
 * @discussion  KeyBindings.dictの内容を読み込んで、
 *              インスタンスを生成します
 *
 * @param dict  KeyBindings.dictの辞書
 * @result      autoreleaseされたインスタンス
 */
- (id) initWithDictionary : (NSDictionary *) dict;


/*!
 * @method      keyBindingDict
 * @abstract    KeyBindings.dictの辞書へのアクセサ
 * @discussion  KeyBindings.dictの辞書を返します
 * @result      KeyBindings.dictの辞書
 */
- (NSDictionary *) keyBindingDict;
- (void) setKeyBindingDict : (NSDictionary *) aKeyBindingDict;


- (BOOL) interpretKeyBindingWithEvent : (NSEvent *) theEvent
							   target : (id       ) theTarget;
- (BOOL) interpretKeyBindings : (NSArray *) eventArray
					   target : (id       ) theTarget;
@end



@interface SGKeyBindingSupport(Convert)
+ (unsigned) modifierFlagsWithKeyBindingString : (NSString *) str;
+ (NSString *) keyBindingStringWithModifierFlags : (unsigned) flags;

/* dictionary Key Normalize */
+ (NSString *) keyBindingStringWithKey : (NSString *) aKey;

/* Key Event --> dictionary Key */
/*!
 * @method         keyBindingStringWithEvent:
 * @abstract       キー入力イベントを辞書のキーに使われる文字列に変換
 * @discussion     キー入力イベントを辞書のキーに使われる文字列に変換します。
 *                 辞書のキーは@"^s"などの文字列になります。
 * @param anEvent  キー入力イベント
 * @result         辞書のキー。失敗時にはnilを返す。
 */
+ (NSString *) keyBindingStringWithEvent : (NSEvent *) anEvent;
+ (NSString *) keyBindingStringWithCharacters : (NSString *) characters
								modifierFlags : (unsigned  ) modifierFlags;
@end
