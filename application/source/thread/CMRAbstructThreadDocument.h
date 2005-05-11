//:CMRAbstructThreadDocument.h
/**
  *
  * �X���b�h�̏��ށi���ۃN���X�j
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
  * �X���b�h���؂�ւ��Ƃ��A
  * �T�u�N���X���ɒ񋟂����t�b�N
  * ���ꂪ�Ă΂��Ƃ��͐V����CMRThreadAttributes
  * �͂��łɃC���X�^���X�ϐ��ŕێ�����Ă���
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