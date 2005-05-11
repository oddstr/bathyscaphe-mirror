//:CMRAbstructThreadDocument.h
/**
  *
  * スレッドの書類（抽象クラス）
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.9a2 (03/01/20  4:51:51 PM)
  *
  */
#import <Cocoa/Cocoa.h>
#import "SGDocument.h"
#import "CMRThreadViewer.h"

@class CMRThreadAttributes;



@interface CMRAbstructThreadDocument : SGDocument
{
	CMRThreadAttributes			*_threadAttributes;
	NSTextStorage				*_textStorage;
}

- (CMRThreadAttributes *) threadAttributes;
- (void) setThreadAttributes : (CMRThreadAttributes *) attributes;

/**
  *
  * スレッドが切り替わるとき、
  * サブクラス側に提供されるフック
  * これが呼ばれるときは新しいCMRThreadAttributes
  * はすでにインスタンス変数で保持されている
  *
  */
- (void) replace : (CMRThreadAttributes *) oldAttrs
			with : (CMRThreadAttributes *) newAttrs;

- (NSTextStorage *) textStorage;
- (void) setTextStorage : (NSTextStorage *) aTextStorage;
@end

/* for AppleScript */
@interface CMRAbstructThreadDocument(ScriptingSupport)
- (NSTextStorage *) selectedText;

- (NSDictionary *) threadAttrDict;
- (NSString *) threadTitleAsString;
- (NSString *) threadURLAsString;
- (NSString *) boardNameAsString;
- (NSString *) boardURLAsString;

- (void)handleReloadThreadCommand:(NSScriptCommand*)command;
@end