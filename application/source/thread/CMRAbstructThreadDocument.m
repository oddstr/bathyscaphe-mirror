//:CMRAbstructThreadDocument.m
/**
  *
  * @see CMRThreadAttributes.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.9a2 (03/01/20  4:59:59 PM)
  *
  */
#import "CMRAbstructThreadDocument_p.h"
#import "CocoMonar_Prefix.h"


@implementation CMRAbstructThreadDocument
- (void) dealloc
{
	[_threadAttributes release];
	[_textStorage release];
	[super dealloc];
}

// CMRAbstructThreadDocument:
- (NSTextStorage *) textStorage
{
	if(nil == _textStorage) {
		_textStorage = [[NSTextStorage alloc] init];
	}
	return _textStorage;
}
- (void) setTextStorage : (NSTextStorage *) aTextStorage
{
	id		tmp;
	
	tmp = _textStorage;
	_textStorage = [aTextStorage retain];
	[tmp release];
}

- (CMRThreadAttributes *) threadAttributes
{
	return _threadAttributes;
}

- (void) setThreadAttributes : (CMRThreadAttributes *) newAttributes
{
	CMRThreadAttributes		*oldAttributes_;
	
	oldAttributes_ = _threadAttributes;
	_threadAttributes = [newAttributes retain];	
	
	[self replace:oldAttributes_ with:newAttributes];
	
	[oldAttributes_ release];
}
- (void) replace : (CMRThreadAttributes *) oldAttributes
			with : (CMRThreadAttributes *) newAttributes
{
	//
	// for subclass
	//
}


- (void) makeWindowControllers
{
	
	[super makeWindowControllers];
}

- (BOOL) windowAlreadyExistsForPath : (NSString *) filePath
{
	/* 2005-09-15 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	このメソッドはスレッドを履歴メニューなどから切り替える直前に呼ばれる。
	パラメータには、これから切り替えようとしている（切り替え先の）スレッドのファイルパスを与える。
	
	ファイルパスを基に NSDocument を探す。見つかれば、もうそのドキュメントが開かれている訳だから、
	切り替えを中止し、かわりにそのドキュメントのウインドウをアクティブに。
	
	見つからなければ、切り替えの許可、return YES;。*/
	NSDocumentController	*dc_;
	NSDocument				*document_;
	
	if (nil == filePath) return NO;

	dc_ = [NSDocumentController sharedDocumentController];
	document_ = [dc_ documentForFileName : filePath];
	
	if (nil == document_) {
		return NO;
	} else {
		[document_ showWindows];
		return YES;
	}
}

/* override */
- (void) removeWindowController : (NSWindowController *) windowController
{
	NSEnumerator		*iter_;
	NSWindowController	*controller_;
	SEL					selector_;
	
	selector_ = @selector(document:willRemoveController:);
	iter_ = [[self windowControllers] objectEnumerator];
	
	while(controller_ = [iter_ nextObject]){
		if(NO == [controller_ respondsToSelector : selector_])
			continue;
		
		[controller_ document:self willRemoveController:windowController];
	}
	
	[super removeWindowController : windowController];
}

- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	SEL action_;

	action_ = [theItem action];
	
	if(action_ == @selector(saveDocumentAs:)) 
		[theItem setTitle : NSLocalizedString(@"Save Menu Item Default", @"Save as...")];
		
	return [super validateMenuItem : theItem];
}
@end

/* for AppleScript */
@implementation CMRAbstructThreadDocument(ScriptingSupport)
- (NSTextStorage *) selectedText
{
	NSAttributedString* attrString = [[self textStorage] attributedSubstringFromRange:[[[[self windowControllers] lastObject] textView] selectedRange]];
	NSTextStorage * storage = [[NSTextStorage alloc] initWithAttributedString:attrString];
	return [storage autorelease];
}

- (NSDictionary *) threadAttrDict
{
	return [[self threadAttributes] dictionaryRepresentation];
}
- (NSString *) threadTitleAsString
{
	return [[self threadAttributes] threadTitle];
}

- (NSString *) threadURLAsString
{
	return [[[self threadAttributes] threadURL] stringValue];
}
- (NSString *) boardNameAsString
{
	return [[self threadAttributes] boardName];
}
- (NSString *) boardURLAsString
{
	return [[[self threadAttributes] boardURL] stringValue];
}

- (void)handleReloadThreadCommand:(NSScriptCommand*)command
{
	[[[self windowControllers] lastObject] reloadThread : nil];
}
@end
