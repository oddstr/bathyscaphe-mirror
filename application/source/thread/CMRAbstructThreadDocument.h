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

@class CMRThreadAttributes;
@class BSRelativeKeywordsCollector;


@interface CMRAbstructThreadDocument : NSDocument
{
	CMRThreadAttributes			*_threadAttributes;
	NSTextStorage				*_textStorage;
	NSArray				*m_keywords;
	BSRelativeKeywordsCollector	*m_collector;
}

- (CMRThreadAttributes *) threadAttributes;
- (void) setThreadAttributes : (CMRThreadAttributes *) attributes;
- (BOOL) isAAThread;
- (void) setIsAAThread: (BOOL) flag;
- (BOOL) isDatOchiThread;
- (void) setIsDatOchiThread: (BOOL) flag;
- (BOOL) isMarkedThread;
- (void) setIsMarkedThread: (BOOL) flag;
- (NSArray *) cachedKeywords;
- (void) setCachedKeywords: (NSArray *) array;
- (BSRelativeKeywordsCollector *) keywordsCollector;
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

- (BOOL) windowAlreadyExistsForPath : (NSString *) filePath;

// NSWindowController ���� NSDocument �ւ� Action �����ւ��i���₷�����̂������Ă����j
// Available in Starlight Breaker.
- (IBAction) showDocumentInfo: (id) sender;
- (IBAction) showMainBrowser: (id) sender;
- (IBAction) toggleAAThread: (id) sender;
- (IBAction) toggleDatOchiThread: (id) sender;
- (IBAction) toggleMarkedThread: (id) sender;
- (IBAction) toggleAAThreadFromInfoPanel: (id) sender;

// Available in Twincam Angel.
- (IBAction)revealInFinder:(id)sender;
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


@interface NSWindowController(CMRAbstructThreadDocumentDelegate)
- (void)    document : (NSDocument         *) aDocument
willRemoveController : (NSWindowController *) aController;
@end

extern NSString *const CMRAbstractThreadDocumentDidToggleDatOchiNotification;