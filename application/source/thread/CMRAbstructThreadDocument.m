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

#if 0

@interface CMRTextStorageProxy : NSProxy
{
	@private
    NSTextStorage	*_storage;
}
@end



@implementation CMRTextStorageProxy
- (id) init
{
	_storage = [[NSTextStorage alloc] init];
	return self;
}
- (void) dealloc
{
	[_storage release];
	[super dealloc];
}
- (NSMethodSignature *) methodSignatureForSelector : (SEL) aSelector
{
/*
	UTILDescSelector(aSelector);
*/
    return [_storage methodSignatureForSelector:aSelector];
}
- (void) forwardInvocation : (NSInvocation *) anInvocation
{
	[anInvocation setTarget:_storage];
	[anInvocation invoke];
	return;
}

- (NSString *)string { return [_storage string]; }
- (NSMutableString *) mutableString { return [_storage mutableString]; }
- (unsigned) length { return [_storage length]; }

- (NSDictionary *) attributesAtIndex : (unsigned      ) location
                      effectiveRange : (NSRangePointer) range
{
	NSDictionary	*v;
	
	v = [_storage attributesAtIndex:location effectiveRange:range];
	
	UTILMethodLog;
	UTILDescription(v);
	
	return v;
}
- (NSDictionary *)attributesAtIndex:(unsigned)location longestEffectiveRange:(NSRangePointer)range inRange:(NSRange)rangeLimit
{
	NSDictionary	*v;

	v =  [_storage attributesAtIndex:location longestEffectiveRange:range inRange:rangeLimit];
	UTILMethodLog;
	UTILDescription(v);
	
	return v;
}
- (id) attribute : (NSString *) attrName atIndex:(unsigned int)location effectiveRange:(NSRangePointer)range
{
	id		v;
	
	v = [_storage attribute:attrName atIndex:location effectiveRange:range];
	UTILMethodLog;
	UTILDescription(attrName);
	UTILDescription(v);
	
	return v;
}
- (id)attribute:(NSString *)attrName atIndex:(unsigned int)location longestEffectiveRange:(NSRangePointer)range inRange:(NSRange)rangeLimit
{
	UTILMethodLog;
	return [_storage attribute:attrName atIndex:location longestEffectiveRange:range inRange:rangeLimit];
}
- (BOOL)isEqualToAttributedString:(NSAttributedString *)other
{
	return [_storage isEqualToAttributedString : other];
}
- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)range
{ [_storage addAttribute:name value:value range:range]; }
- (void)addAttributes:(NSDictionary *)attrs range:(NSRange)range;
{ [_storage addAttributes:attrs range:range]; }
- (void)removeAttribute:(NSString *)name range:(NSRange)range;
{ [_storage removeAttribute:name range:range]; }




- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
	[_storage replaceCharactersInRange:range withString:str];
}
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
	[_storage setAttributes:attrs range:range];
}
- (void)replaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)attrString
{
	[_storage replaceCharactersInRange:range withAttributedString:attrString];
}
- (void)insertAttributedString:(NSAttributedString *)attrString atIndex:(unsigned)loc
{
	[_storage insertAttributedString:attrString atIndex:loc];
}
- (void)appendAttributedString:(NSAttributedString *)attrString
{
	[_storage appendAttributedString:attrString];
}
- (void)deleteCharactersInRange:(NSRange)range
{
	[_storage deleteCharactersInRange:range];
}
- (void)setAttributedString:(NSAttributedString *)attrString
{
	[_storage setAttributedString:attrString];
}


/*** NSTextStorage ***/
- (void) addLayoutManager : (NSLayoutManager *) aLayoutManager
{
	[_storage addLayoutManager : aLayoutManager];
	[aLayoutManager setTextStorage : self];
}
- (void) edited:(unsigned)editedMask range:(NSRange)range changeInLength:(int)delta
{ 
	[_storage edited:editedMask range:range changeInLength:delta];
}
- (void)processEditing
{
	[_storage processEditing];
}
- (void)invalidateAttributesInRange:(NSRange)range
{
	[_storage invalidateAttributesInRange:range];
}
- (void)ensureAttributesAreFixedInRange:(NSRange)range
{
	[_storage ensureAttributesAreFixedInRange:range];
}
- (BOOL)fixesAttributesLazily
{
	return [_storage fixesAttributesLazily];
}
- (unsigned)editedMask
{
	return [_storage editedMask];
}
- (NSRange)editedRange
{
	return [_storage editedRange];
}
- (int)changeInLength
{
	return [_storage changeInLength];
}
@end
#endif


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
