//: SGXmlPullParser.m
/**
  * $Id: SGXmlPullParser.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "SGXmlPullParser.h"
#import "PrivateDefines.h"

#import <SGFoundation/SGFoundationAdditions.h>
#import <SGFoundation/SGXMLEntityReference.h>
#import <SGFoundation/SGFoundationUtils.h>

/*
REFERENCES:

Extensible Markup Language (XML) 1.0 (Third Edition)
http://www.w3.org/TR/REC-xml

Namespaces in XML
http://www.w3.org/TR/REC-xml-names/
*/
// for Internal Use...
enum {
    XMLPULL_LEGACY   = 999,
    XMLPULL_XML_DECL = 998
};



// Features
#define FEATURE_PREFIX        @"http://www.steam_gadget.com/frameworks/SGFoundation/SGXmlPullParser/docs/features.html"

NSString *const SGXmlPullParserAllowsEmptyAttribute = FEATURE_PREFIX@"#SGXmlPullParserAllowsEmptyAttribute";

NSString *const SGXmlPullParserIgnoreEntityResolvingError = FEATURE_PREFIX@"#SGXmlPullParserIgnoreEntityResolvingError";

NSString *const SGXmlPullParserAllowsDuplicateAttribute = FEATURE_PREFIX@"#SGXmlPullParserAllowsDuplicateAttribute";

NSString *const SGXmlPullParserAllowsUnquotedValue = FEATURE_PREFIX@"#SGXmlPullParserAllowsUnquotedValue";

NSString *const SGXmlPullParserUsesLowerCaseName = FEATURE_PREFIX@"#SGXmlPullParserUsesLowerCaseName";

NSString *const SGXmlPullParserDisableEntityResolving = FEATURE_PREFIX@"#SGXmlPullParserDisableEntityResolving";

NSString *const SGXmlPullParserAllowsIllegalComment = FEATURE_PREFIX@"#SGXmlPullParserAllowsIllegalComment";

#define SGXMLPULL_TEXTBUF_SIZE        64



// ----------------------------------------
// Utility functions
// ----------------------------------------
// Peek
static void SGXmlPullPeekClear(SGXmlPullPeek *thePeek);
static UniChar SGXmlPullPeekGetAtIndex(SGXmlPullPeek *thePeek, CFIndex anIndex);
static void SGXmlPullPeekPush(SGXmlPullPeek *thePeek, UniChar c);
static UniChar SGXmlPullPeekPop(SGXmlPullPeek *thePeek);

// Text
static SGXmlUniCharBuffer *SGXmlUniCharBufferCreateWithSize(CFIndex bufSize);
static void SGXmlUniCharBufferDealloc(SGXmlUniCharBuffer *theBuffer);
static void SGXmlUniCharBufferClear(SGXmlUniCharBuffer *theBuffer);

static inline UniChar *SGXmlUniCharBufferGetBuffer(SGXmlUniCharBuffer *theBuffer);
static inline CFIndex SGXmlUniCharBufferGetCount(SGXmlUniCharBuffer *theBuffer);

static void SGXmlUniCharBufferSetCount(SGXmlUniCharBuffer *theBuffer, CFIndex newLength);
static void SGXmlUniCharBufferPush(SGXmlUniCharBuffer *theBuffer, UniChar c);


/*
XML document must not contain 0xFFFF, 0xFFFE as its contents.
so we just skip it, and use it like a NULL character.
*/
#define XML_INVALID_UNICHAR     0xFFFF

#define PEEK(thePeekIndex)      [self peek : thePeekIndex]
#define UNREAD                  [self unread]
#define READ                    [self read]
#define READ_ENSURE(theEnsure)  [self read : theEnsure]
#define PUSH(theUniChar)        [self push : theUniChar]




@interface SGXmlPullParser(Private)
// Parsing
- (void) parseText : (UniChar) theDelimiter
     resolveEntity : (BOOL   ) resolveEntity;
- (BOOL) parseEntity : (BOOL) willClearBuffer;
- (void) parseStartTag : (BOOL) xmlDecl;
- (void) parseEndTag;
- (int) parseLegacy : (BOOL) willPush;

- (BOOL) eos;
- (void) clearState;
- (int) doNext;

// Attributes
- (NSMutableDictionary *) attrsDict;
- (void) clearAttrsDict;
- (void) setName : (NSString *) aName;


// Scan Character
- (UniChar) peek : (CFIndex) thePeekIndex;
- (int) peekType;

- (UniChar) read;
- (UniChar) read : (UniChar) ensureUniChar;
- (NSString *) readName;

- (void) push : (UniChar) c;
- (void) skip;

// Exception Raise
- (NSString *) getProcessingDescription;
- (void) raiseUnexpectedEOFException : (NSString *) desc;
@end




@implementation SGXmlPullParser(Private)
- (void) parseText : (UniChar) theDelimiter
     resolveEntity : (BOOL   ) resolveEntity
{
    UniChar         c = PEEK(0);
    NSCharacterSet *wcset_;
    BOOL            skipDelimiter_ = NO;
    
    // Yes, I prefer shorter name.
    wcset_ = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    SGXmlUniCharBufferClear(_textBuf);
    while (c != XML_INVALID_UNICHAR) {
        if (theDelimiter == c && NO == skipDelimiter_) {
            break;
        }
        skipDelimiter_ = NO;
        
        // if theDelimiter was ' ', assume its contents was 
        // [NSCharacterSet whitespaceAndNewlineCharacterSet];
        if (' ' == theDelimiter) {
            if ([wcset_ characterIsMember : c] || '<' == c || '>' == c)
                break;
        }
        
        
        if ('&' == c) {    // Entity Reference
            if (NO == resolveEntity)
                break;
            
            [self parseEntity : NO];
        } else if (XMLPULL_START_TAG == _type && '\n' == c) {
            READ;
            PUSH(' ');
        /*
		} else if ('\\' == c && theDelimiter == PEEK(1)) {
            skipDelimiter_ = YES;
            READ;
        */
		} else {
            PUSH(READ);
        }
        
        c = PEEK(0);
    }
}


// Throws exception, if IgnoreEntityResolvingError was NO.
- (BOOL) parseEntity : (BOOL) willClearBuffer
{
    UniChar                c;
    NSCharacterSet        *cset_;
    unsigned            index_   = _srcBuf.position;
    CFIndex                txtPos_;
    BOOL                isValid_ = YES;
    
    cset_ = [NSCharacterSet alphanumericCharacterSet];
    if (willClearBuffer)
        SGXmlUniCharBufferClear(_textBuf);
    
    txtPos_  = SGXmlUniCharBufferGetCount(_textBuf);
    
    c = READ_ENSURE('&');
    PUSH(c);
    c = PEEK(0);
    if ('#' == c) {
        PUSH(READ);
    }
    while (1) {
        c = PEEK(0);
        
        if (c != ';' && NO == [cset_ characterIsMember: c]) {
            // not Entity
            isValid_ = NO;
            break;
        }
        
        c = READ;
        PUSH(c);
        if (';' == c)
            break;
    }
    
    if (_PFlags.disableEntityResolving) {
        return isValid_;
    }

    UniChar            code_;
    NSString        *entityRef_ = nil;
    NSRange            entityRange_;
    
    // '&', ';' exclusive
    entityRange_ = NSMakeRange(index_, _srcBuf.position - index_);
    if (isValid_) {
        if (entityRange_.length <= 2) {
            [NSException raise:XmlPullParserException
                        format: @"%@ Empty Entity...",
                                [self getProcessingDescription]];
        }
        entityRange_.location++;
        entityRange_.length -= 2;
    }
    entityRef_ = [_srcBuf.source substringWithRange : entityRange_];
    if (isValid_) {
        
        isValid_ = SGXMLCharacterForEntityReference(
                    (CFStringRef)entityRef_,
                    &code_);
        if (isValid_) {
            SGXmlUniCharBufferSetCount(_textBuf, txtPos_);
            PUSH(code_);
        }
    }
    if (NO == isValid_ && 0 == _PFlags.IgnoreEntityResolvingError) {
        NSString        *exceptionDesc;
        
        exceptionDesc = ([self eos])
                            ? @"%@ Unexpected EOF:"
                              @" While Resolving Entity Reference(%@)"
                            : @"%@ Can't resolve Entity(%@)";
        
        [NSException raise:XmlPullParserException
                    format:    exceptionDesc, 
                            [self getProcessingDescription],
                            entityRef_];
    }
    
    return isValid_;
}
- (void) parseStartTag : (BOOL) xmlDecl
{
    UniChar            c;
    NSCharacterSet    *cset_;
    
    NSString            *name_ = nil;
    id                    value_ = nil;
    NSMutableDictionary    *dict_ = [self attrsDict];
    
    
    cset_ = [NSCharacterSet alphanumericCharacterSet];
    if (NO == xmlDecl) {
        c = READ_ENSURE('<');
    }
    
    // ----------------------------------------
    // Element Name
    // ----------------------------------------
    name_ = [self readName];
    [self setName : (NO == xmlDecl ? name_ : @"xml")];

    name_ = nil;
    [self clearAttrsDict];
    while (1) {
        UniChar        delemiter_;
        
        [self skip];
        c = PEEK(0);
        
        if (xmlDecl && '?' == c) {
            READ;
            READ_ENSURE('>');
            return;
        }
        
        if ('/' == c) {
            _PFlags.degenerated = YES;
            
            READ;
            [self skip];
            READ_ENSURE('>');
            break;
        } else if ('>' == c && NO == xmlDecl) {
            READ;
            break;
        } else if (XML_INVALID_UNICHAR == c) {
            [self raiseUnexpectedEOFException : @"While scanning Start Tag"];
        }
        
        // ----------------------------------------
        // Attributes
        // ----------------------------------------
        name_ = [self readName];
        if (nil == name_ || [name_ isEmpty]) {
            [NSException raise:XmlPullParserException
                        format:@"%@ Attributes Name not supplied.",
                                [self getProcessingDescription]];
        }
        [self skip];
        
        // check duplicate attribute
        if (0 == _PFlags.allowsDuplicateAttribute) {
            if ([dict_ objectForKey:name_] != nil) {
                [NSException raise:XmlPullParserException
                            format:
                            @"%@ Duplicate Attribute(%@) was not allowed",
                            [self getProcessingDescription],
                            name_];
            }
        }
        
        // value
        c = PEEK(0);
        if ('=' == c) {
            READ_ENSURE('=');
            [self skip];
            
            delemiter_ = READ;
            if (delemiter_ != '"' && delemiter_ != '\'') {
                if (0 == _PFlags.allowsUnquotedValue) {
                    [NSException raise:XmlPullParserException
                                format:
                                @"%@ Attribute(%@) was be quoted",
                                [self getProcessingDescription],
                                name_];
                }
                delemiter_ = ' ';
            }
            
            
            [self parseText:delemiter_ resolveEntity:YES];
            value_ = [NSString stringWithCharacters : SGXmlUniCharBufferGetBuffer(_textBuf)
                                            length : SGXmlUniCharBufferGetCount(_textBuf)];
            
            
            if (delemiter_ != ' ')
                READ;
        } else if ('>' == c || '/' == c || [cset_ characterIsMember : c]) {
            value_ = [[self class] empty];
            if (0 == _PFlags.AllowsEmptyAttribute) {
                [NSException raise:XmlPullParserException
                            format:    @"%@ Empty Attributes(%@) was not allowed.",
                                    [self getProcessingDescription],
                                    name_];
            }
        } else {
            // not in '>','/',alphabet, numeric
            value_ = nil;
            [NSException raise:XmlPullParserException
                        format:    @"%@ Unexpected Character(%@) "
                                @"While Attribute(%@).",
                                [self getProcessingDescription],
                                XML_INVALID_UNICHAR == c 
                                    ? @"EOF"
                                    : [NSString stringWithCharacter:c],
                                name_];
        }
        [dict_ setObject:value_ forKey:name_];
    }
    _depth++;
}
- (void) parseEndTag
{
    NSString    *nm;
    
    READ_ENSURE('<');
    READ_ENSURE('/');
    nm = [self readName];
    [self setName : nm];
    
    [self skip];
    READ_ENSURE('>');
    
    if (0 == [self depth]) {
        [NSException raise : XmlPullParserException
                    format : @"%@ Not Found Start Element of (%@)", 
                             [self getProcessingDescription],
                             nm];
    }
}
- (void) parseComment : (BOOL) willPush
{
    UniChar        pc = XML_INVALID_UNICHAR;
    UniChar        c;
    
    READ_ENSURE('-');
    READ_ENSURE('-');
    
    while (1) {
        c = READ;
        if ('-' == c && '-' == PEEK(0) && '>' == PEEK(1)) {
            if ('-' == pc && 0 == _PFlags.allowsIllegalComment) {
                [NSException raise: XmlPullParserException
                            format: @"%@ illegal comment delimiter: --->",
                                    [self getProcessingDescription]];
            }
            break;
        } else if (XML_INVALID_UNICHAR == c) {
            [self raiseUnexpectedEOFException : 
                @"While Comment"];
        } else if (willPush) {
            PUSH(c);
        }
        
        pc = c;
    }
    READ_ENSURE('-');
    READ_ENSURE('>');
}
- (void) parseProccessingInstruction : (BOOL) willPush
{
    UniChar        c;
    
    while (1) {
        c = READ;
        if ('?' == PEEK(0) && '>' == PEEK(1)) {
            break;
        } else if (XML_INVALID_UNICHAR == c) {
            [self raiseUnexpectedEOFException :
                @"While ProccessingInstruction."];
        } else if (willPush) {
            PUSH(c);
        }
    }
    READ_ENSURE('?');
    READ_ENSURE('>');
}
- (void) parseDocType : (BOOL) willPush
{
    char        head_[] = "DOCTYPE";
    int            i, cnt;
    
    cnt = strlen(head_);
    for (i = 0; i < cnt; i++)
        READ_ENSURE(head_[i]);
    
    unsigned    nestLevel_ = 1;
    BOOL        isQuoted_  = NO;
    
    while (1) {
        UniChar        c = READ;
        
        switch(c) {
        case XML_INVALID_UNICHAR:
            [self raiseUnexpectedEOFException :
                @"While DOCTYPE"];
            break;
        case '\'':
            isQuoted_ = !isQuoted_;
            break;
        case '>':
            if (NO == isQuoted_ && 0 == --nestLevel_)
                return;
            break;
        default:
            break;
        }
        if (willPush)PUSH(c);
    }
}
- (void) parseCDATA
{
    UniChar c;
    
    char head_[] = "[CDATA[";
    int  i, cnt;
    
    cnt = strlen(head_);
    for (i = 0; i < cnt; i++)
        READ_ENSURE(head_[i]);
    
    
    while (1) {
        c = READ;
        if (']' == c && ']' == PEEK(0) && '>' == PEEK(1)) {
            break;
        } else if (XML_INVALID_UNICHAR == c) {
            [self raiseUnexpectedEOFException:
                @"While CDATA Section"];
        }
        PUSH(c);
    }
    READ_ENSURE(']');
    READ_ENSURE('>');
}
- (int) parseLegacy : (BOOL) willPush
{
    UniChar        c;
    int            legacyType_ = XMLPULL_DOCDECL;
    
    READ_ENSURE('<');
    c = READ;
    
    SGXmlUniCharBufferClear(_textBuf);
    if ('!' == c) {
        UniChar        nc = PEEK(0);
        
        switch(nc) {
        case '-':
            legacyType_ = XMLPULL_COMMENT;
            [self parseComment : willPush];
            break;
        case '[':
            legacyType_ = XMLPULL_CDSECT;
            [self parseCDATA];
            break;
        default :
            legacyType_ = XMLPULL_DOCDECL;
            [self parseDocType : willPush];
            break;
        }
    } else if ('?' == c) {
        // <?xml
        if ('x' == tolower(PEEK(0)) && 'm' == tolower(PEEK(1))) {
            UniChar        c;
            c = READ;
            if (willPush) PUSH(c);
            c = READ;
            if (willPush) PUSH(c);
            
            if ('l' == tolower(PEEK(0)) && 
                [[NSCharacterSet whitespaceAndNewlineCharacterSet]
                    characterIsMember : PEEK(1)]) {
                
                legacyType_ = XMLPULL_XML_DECL;
                [self parseStartTag : YES];
                
                _PFlags.isWhitespace = YES;
            }
        } else {
            legacyType_ = XMLPULL_PROCESSING_INSTRUCTION;
            [self parseProccessingInstruction : willPush];
        }
    } else {
        [NSException raise:XmlPullParserException
                    format:@"Unknown Legacy Type(%@)",
                        [NSString stringWithCharacter:c]];
    }
    
    return legacyType_;
}

- (int) doNext
{
    UTILAssertNotNil(_srcBuf.inlineBuffer);
    
    if (XMLPULL_END_TAG == [self eventType])
        _depth--;
    
    _type = [self peekType];
    
StartDoParse:
    if (_PFlags.degenerated != 0) {
        _PFlags.degenerated = 0;
        _type = XMLPULL_END_TAG;
        return _type;
    }
    
    if (XMLPULL_ENTITY_REF == _type && 0 == _PFlags.token)
        _type = XMLPULL_TEXT;
        
    switch(_type) {
    case XMLPULL_START_TAG:
        [self parseStartTag : NO];
        break;
    case XMLPULL_END_TAG:
        [self parseEndTag];
        break;
    case XMLPULL_ENTITY_REF:
        if (NO == [self parseEntity : (_PFlags.token != 0)])
            _type = XMLPULL_TEXT;
        
        break;
    case XMLPULL_END_DOCUMENT:
        break;
    case XMLPULL_TEXT:
        [self parseText:'<' resolveEntity:(0 == _PFlags.token)];
        if (0 == [self depth] && [self isWhitespace])
            _type = XMLPULL_IGNORABLE_WHITESPACE;
                
        break;
    default :
        _type = [self parseLegacy : (_PFlags.token != 0)];
        if (XMLPULL_XML_DECL == _type)
            goto StartDoParse;
        
        break;
    }
    
    return _type;
}


// Parser Attributes
- (NSMutableDictionary *) attrsDict
{
    if (nil == _attributes) {
        _attributes = [[NSMutableDictionary alloc] initWithCapacity:16];
    }
    return _attributes;
}
- (void) clearAttrsDict
{
    [[self attrsDict] removeAllObjects];
}
- (void) setName : (NSString *) aName
{
    id        tmp;
    
    tmp = _name;
    _name = [aName retain];
    [tmp release];
}
/* end of source */
- (BOOL) eos { return _PFlags.eos != 0; }
- (void) clearState
{
    _type = XMLPULL_START_DOCUMENT;
    [_name release];
    _name = nil;
    [_attributes release];
    _attributes = nil;
    
    _PFlags.peekReadedCR = 0;
    _PFlags.isWhitespace = 0;
    _PFlags.degenerated  = 0;
    _PFlags.token        = 0;
    _PFlags.eos          = 0;
    
    _depth        = 0;
    _line         = 0;
    _column       = 0;

    free(_srcBuf.inlineBuffer);
    _srcBuf.inlineBuffer = NULL;
    _srcBuf.position     = 0;
    _srcBuf.bufferRange  = CFRangeMake(kCFNotFound, 0);
    
    // peek
    SGXmlPullPeekClear(&_peek);
    if (NULL == _textBuf)
        _textBuf = SGXmlUniCharBufferCreateWithSize(SGXMLPULL_TEXTBUF_SIZE);
    
    SGXmlUniCharBufferClear(_textBuf);
}


// Scan Character
- (UniChar) peek : (CFIndex) thePeekIndex
{
    while (thePeekIndex >= _peek.count) {
        UniChar        c;
        
        if (NULL == _srcBuf.inlineBuffer ||
           _peek.index == _srcBuf.bufferRange.length) {
           
           /*
           maybe I should use _PFlags.eos only,
           but it is very tedious for me.
           */
           c = XML_INVALID_UNICHAR;
           _PFlags.eos = 1;
        } else {
            c = CFStringGetCharacterFromInlineBuffer(
                        _srcBuf.inlineBuffer,
                        _peek.index++);
            /* pack newline */
            if ('\r' == c) {
                _PFlags.peekReadedCR = 1;
                c = '\n';
            } else {
                BOOL skipLF = ('\n' == c && _PFlags.peekReadedCR);
                
                _PFlags.peekReadedCR = 0;
                // we already have read CR, so just skip LF
                // or
                // XML_INVALID_UNICHAR now comming, ignore it! 
                if (skipLF || XML_INVALID_UNICHAR == c)
                {
                    _srcBuf.position++;
                    continue;
                }
            }
        }
        
        SGXmlPullPeekPush(&_peek, c);
    }
    
    return SGXmlPullPeekGetAtIndex(&_peek, thePeekIndex);
}
- (int) peekType
{
    UniChar c;
    
    c = PEEK(0);
    
    if (XML_INVALID_UNICHAR == c) {
        return XMLPULL_END_DOCUMENT;
    } else if ('&' == c) {
        return XMLPULL_ENTITY_REF;
    } else if ('<' == c) {
        UniChar        nc;
        
        nc = PEEK(1);
        switch(nc) {
        case XML_INVALID_UNICHAR:
            return XMLPULL_START_TAG;
            break;
        case '/' :
            return XMLPULL_END_TAG;
            break;
        case '?' :
        case '!' :
            return XMLPULL_LEGACY;
            break;
        default :
            return XMLPULL_START_TAG;
            break;
        }
    }
    return XMLPULL_TEXT;
}

- (UniChar) read
{
    UniChar c;
    
    c = PEEK(0);
    SGXmlPullPeekPop(&_peek);
    _srcBuf.position++;
    
    _column++;
    if ('\n' == c) {
        _line++;
        _column = 0;
    }
    
    return c;
}
- (UniChar) read : (UniChar) ensureUniChar
{
    UniChar c = READ;
    
    if (ensureUniChar != c) {
            [NSException raise:XmlPullParserException
             format:@"%@(Line:%u Column:%u) Expected %@ but was %@",
                UTIL_HANDLE_FAILURE_IN_METHOD,
                [self lineNumber],
                [self columnNumber],
                [NSString stringWithCharacter : ensureUniChar],
                [NSString stringWithCharacter : c]];
    }
    return c;
}
- (NSString *) readName
{
    UniChar         c;
    NSCharacterSet *cset;
    unsigned        idx = _srcBuf.position;
    NSRange         range;
    NSString       *name;
    
    /*
	Name ::=Ê(Letter | '_' | ':') (NameChar)*
    NameChar ::=ÊLetter | Digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
    */
    
    // (Letter | '_' | ':')
    c = PEEK(0);
    cset  = [NSCharacterSet letterCharacterSet];
    if (NO == [cset characterIsMember : c] && 
        c != '_' && c != ':') {
        [NSException raise:XmlPullParserException
                    format:@"%@(Line:%u Column:%u) "
                           @"Name/Token start invalid character(%@)",
                            UTIL_HANDLE_FAILURE_IN_METHOD,
                            [self lineNumber],
                            [self columnNumber],
                            [NSString stringWithCharacter:c]];
    }
    
    // (NameChar)*
    cset = [NSCharacterSet alphanumericCharacterSet];
    do {
        READ;
        c = PEEK(0);
    } while (
        [cset characterIsMember : c]
        || c == '_'
        || c == '-'
        || c == ':'
        || c == '.'
        || c >= 0x0b7);
    
    range.location = idx;
    range.length = _srcBuf.position - idx;
    
    name = [_srcBuf.source substringWithRange : range];
    if (_PFlags.usesLowerCaseName) {
        name = [name lowercaseString];
    }
    NSAssert(NO == [name isEmpty], @"name must be not empty.");
    
    return name;
}

- (void) push : (UniChar) c
{
    _PFlags.isWhitespace = [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember : c];
    
    SGXmlUniCharBufferPush(_textBuf, c);
}
- (void) skip
{
    UniChar                c;
    NSCharacterSet        *wcset_;
    
    wcset_ = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    while (1) {
        c =PEEK(0);
        if (![wcset_ characterIsMember : (c) ] || XML_INVALID_UNICHAR == c)
            break;
        
        READ;
    }
}

// Exception Raise
- (NSString *) getProcessingDescription
{
    return [NSString stringWithFormat :
                @"%@(Line:%u Column:%u)",
                UTIL_HANDLE_FAILURE_IN_METHOD,
                [self lineNumber],
                [self columnNumber]];
}
- (void) raiseUnexpectedEOFException : (NSString *) desc
{
        [NSException raise: XmlPullParserException
                    format: @"%@ Unexpected EOF: %@",
                            [self getProcessingDescription],
                            desc];
}
@end



static void SGXmlPullPeekClear(SGXmlPullPeek *thePeek)
{
    nsr_bzero(thePeek, sizeof(struct SGXmlPullPeek));
    thePeek->size = SGXML_PEEK_SIZE;
}
static UniChar SGXmlPullPeekGetAtIndex(SGXmlPullPeek *thePeek, CFIndex anIndex)
{
    NSCAssert2(
        anIndex < thePeek->size,
        @"the Peek Position must be less than %u. but was %u",
        thePeek->size,
        anIndex);
    
    return thePeek->buffer[anIndex];
}

static void SGXmlPullPeekPush(SGXmlPullPeek *thePeek, UniChar c)
{
    thePeek->buffer[thePeek->count++] = c;
}
static UniChar SGXmlPullPeekPop(SGXmlPullPeek *thePeek)
{
    UniChar        c;
    
    c = SGXmlPullPeekGetAtIndex(thePeek, 0);
    if (thePeek->count > 0) {
        thePeek->buffer[0] = thePeek->buffer[1];
        thePeek->count--;
    }
    return c;
}





static SGXmlUniCharBuffer *SGXmlUniCharBufferCreateWithSize(CFIndex size)
{
    SGXmlUniCharBuffer        *p;
    UniChar                    *bufp;
    
    p = malloc(sizeof(SGXmlUniCharBuffer));
    if (NULL == p)
        return NULL;
    
    nsr_bzero(p, sizeof(SGXmlUniCharBuffer));
    
    bufp = malloc(size * sizeof(UniChar));
    if (NULL == bufp) {
        free(p);
        return NULL;
    }
    nsr_bzero(bufp, size * sizeof(UniChar));
    
    p->buffer = bufp;
    p->size   = size;
    p->count  = 0;
    
    return p;
}
static void SGXmlUniCharBufferDealloc(SGXmlUniCharBuffer *theBuffer)
{
    NSCAssert(theBuffer != NULL, @"theBuffer must be not NULL");
    
    free(theBuffer->buffer);
    free(theBuffer);
}
static void SGXmlUniCharBufferClear(SGXmlUniCharBuffer *theBuffer)
{
    NSCAssert(theBuffer != NULL, @"theBuffer must be not NULL");
    
    //SGNSRFillBytesZero(theBuffer->buffer, theBuffer->size * sizeof(UniChar));
    SGXmlUniCharBufferSetCount(theBuffer, 0);
}

static inline UniChar *SGXmlUniCharBufferGetBuffer(SGXmlUniCharBuffer *theBuffer)
{
    return theBuffer->buffer;
}
static inline CFIndex SGXmlUniCharBufferGetCount(SGXmlUniCharBuffer *theBuffer)
{
    return theBuffer->count;
}

static void SGXmlUniCharBufferSetCount(SGXmlUniCharBuffer *theBuffer, CFIndex newLength)
{
    NSCAssert2(
        theBuffer != NULL && theBuffer->size > newLength,
        @"size(%d) but new length was (%d)",
        theBuffer->size,
        newLength);
    theBuffer->count = newLength;
}
static void SGXmlUniCharBufferPush(SGXmlUniCharBuffer *theBuffer, UniChar c)
{
    UniChar                    *bufp;
    
    NSCAssert(theBuffer != NULL, @"theBuffer must be not NULL");
    
    if (0 == theBuffer->size) {
        
        bufp = malloc(1 * sizeof(UniChar));
        NSCAssert(bufp != NULL, @"***ERROR*** malloc");
        theBuffer->buffer = bufp;
        theBuffer->size   = 1;
        theBuffer->count  = 0;
    } else if (theBuffer->size == theBuffer->count) {
        bufp = theBuffer->buffer;
        bufp = realloc(bufp, (theBuffer->size * 2) * sizeof(UniChar));
        NSCAssert(bufp != NULL, @"***ERROR*** realloc");
        
        theBuffer->buffer = bufp;
        theBuffer->size   *= 2;
    }
    
    theBuffer->buffer[theBuffer->count++] = c;
}



@implementation SGXmlPullParser
- (id) init
{
    if (self = [super init]) {
        [self setInputSource : nil];
    }
    return self;
}
- (id) initHTMLParser
{
    if (self = [self init]) {
        [self setFeature:YES forKey:SGXmlPullParserAllowsEmptyAttribute];
        [self setFeature:YES forKey:SGXmlPullParserIgnoreEntityResolvingError];
        [self setFeature:YES forKey:SGXmlPullParserAllowsDuplicateAttribute];
        [self setFeature:YES forKey:SGXmlPullParserAllowsUnquotedValue];
        [self setFeature:YES forKey:SGXmlPullParserUsesLowerCaseName];
        [self setFeature:YES forKey:SGXmlPullParserAllowsIllegalComment];
    }
    return self;
}


- (void) dealloc
{
    [self setInputSource : nil];
    SGXmlUniCharBufferDealloc(_textBuf);
    _textBuf = NULL;
    
    [_name release];
    [_attributes release];
    [super dealloc];
}

/* The marker object for empty attribute */
+ (id) null { return @""; }
/* alias for + [SGXmlPullParser null] */
+ (id) empty
{
    return [self null];
}
- (NSString *) inputSource
{
    return _srcBuf.source;
}
- (void) setInputSource : (NSString *) anInputSource
{
    id        tmp;
    
    tmp = _srcBuf.source;
    _srcBuf.source = [anInputSource retain];
    [tmp autorelease];
    
    [self clearState];
    
    if (_srcBuf.source != nil) {
        NSAssert(
            NULL == _srcBuf.inlineBuffer, 
            @"NULL == _srcBuf.inlineBuffer");
        
        _srcBuf.inlineBuffer = malloc(sizeof(CFStringInlineBuffer));
        NSAssert(_srcBuf.inlineBuffer != NULL, @"Error malloc");
        
        _srcBuf.bufferRange = 
            CFRangeMake(
                0,
                [_srcBuf.source length]);
        
         CFStringInitInlineBuffer(
                (CFStringRef)_srcBuf.source,
                _srcBuf.inlineBuffer,
                _srcBuf.bufferRange);
        
    }
}

- (NSString *) name
{
    if (_type != XMLPULL_START_TAG && _type != XMLPULL_END_TAG)
        return nil;
    
    return _name;
}

/*!
 * @method        attributeForName:
 * @abstract      Returns the given attributes value
 * @discussion    
 *
 * Returns the given attributes value. Throws an NSRangeException 
 * if current event type is not START_TAG.
 *
 * @param  aName  If namespaces enabled local name of attribute 
 *                otherwise just attribute name
 * @result        value of attribute or null if attribute with 
 *                given name does not exist
 */
- (NSString *) attributeForName : (NSString *) aName
{
    if (_type != XMLPULL_START_TAG && 
        _type != XMLPULL_PROCESSING_INSTRUCTION &&
        _type != XMLPULL_DOCDECL) 
    {
        [NSException raise : NSRangeException
         format : @"Current event(%@) doesn't support attributes.",
         XMLPULL_TYPES[_type]];
    }
    return [[self attrsDict] objectForKey : aName];
}

- (int) eventType
{
    return _type;
}
- (NSString *) text
{
    NSString    *text_;
    
    if (_type < XMLPULL_TEXT)
        return nil;
    
    NSAssert(_textBuf != NULL, @"theBuffer must be not NULL");
    text_ = [NSString stringWithCharacters : SGXmlUniCharBufferGetBuffer(_textBuf)
                                    length : SGXmlUniCharBufferGetCount(_textBuf)];
    
    return text_;
}
- (UniChar *) textCharacters : (CFRange *) holderForStartAndLength;
{
    UniChar        *bufp_;
    
    bufp_ = SGXmlUniCharBufferGetBuffer(_textBuf);
    if (holderForStartAndLength != NULL) {
        *holderForStartAndLength = 
            CFRangeMake(0, SGXmlUniCharBufferGetCount(_textBuf));
    }
    
    return bufp_;
}


- (int) depth
{
    return _depth;
}
- (unsigned) lineNumber
{
    return _line +1;
}
- (unsigned) columnNumber
{
    return _column +1;
}

- (BOOL) isEmptyElementTag
{
    return (_PFlags.degenerated != 0);
}
- (BOOL) isWhitespace
{
    if (_type != XMLPULL_TEXT &&
        _type != XMLPULL_IGNORABLE_WHITESPACE &&
        _type != XMLPULL_CDSECT) {
        
        return NO;
    }
    return (_PFlags.isWhitespace != 0);
}

- (int) next
{
    int            minType_ = INT_MAX;
    
    _PFlags.isWhitespace = YES;
    _PFlags.token = 0;
    
    do{
        int        type_;
        
        type_ = [self doNext];
        if (type_ < minType_)
            minType_ = type_;
    } while (
        minType_ > XMLPULL_ENTITY_REF ||
        (minType_ >= XMLPULL_TEXT &&
        [self peekType] >= XMLPULL_TEXT));
    
    _type = minType_;
    if (_type > XMLPULL_TEXT)
        _type = XMLPULL_TEXT;
    
    return _type;
}
- (int) nextToken
{
    int        type_;

    _PFlags.isWhitespace = YES;
    _PFlags.token = 1;
    
    type_ = [self doNext];
    return _type;
}
- (int) nextTag
{
    [self next];
    if (_type == XMLPULL_TEXT && [self isWhitespace])
        [self next];
    
    NSAssert1(
        XMLPULL_END_TAG == _type || XMLPULL_START_TAG == _type,
        @"Next of TEXT must be TAG but was (%d)",
        _type);

    return _type;
}
- (int) nextName : (NSString *) name
            type : (int       ) type
         options : (unsigned  ) mask
{
    NSString    *nm;
    
    while (_type != XMLPULL_END_DOCUMENT) {
        [self next];
        if (type == _type) {
            nm = [self name];
            if (NSOrderedSame == [nm compare:name options:mask range:[nm range]])
                break;
        }
    }
    return _type;
}
- (NSString *) nextText
{
    NSString    *text_ = nil;
    
    if (XMLPULL_END_DOCUMENT == _type)
        return nil;
    ;
    while ([self next] != XMLPULL_END_DOCUMENT && nil == (text_ = [self text]))
        ;
    
    return text_;
}

- (BOOL) featureForKey : (NSString *) name
{
    if ([SGXmlPullParserAllowsEmptyAttribute isEqualToString : name])
        return (1 == _PFlags.AllowsEmptyAttribute);
    else if ([SGXmlPullParserIgnoreEntityResolvingError isEqualToString : name])
        return (1 == _PFlags.IgnoreEntityResolvingError);
    else if ([SGXmlPullParserAllowsDuplicateAttribute isEqualToString : name])
        return (1 == _PFlags.allowsDuplicateAttribute);
    else if ([SGXmlPullParserAllowsUnquotedValue isEqualToString : name])
        return (1 == _PFlags.allowsUnquotedValue);
    else if ([SGXmlPullParserUsesLowerCaseName isEqualToString : name])
        return (1 == _PFlags.usesLowerCaseName);
    else if ([SGXmlPullParserDisableEntityResolving isEqualToString : name])
        return (1 == _PFlags.disableEntityResolving);
    else if ([SGXmlPullParserAllowsIllegalComment isEqualToString : name])
        return (1 == _PFlags.allowsIllegalComment);
    
    return NO;
}
- (void) setFeature : (BOOL      ) state
             forKey : (NSString *) name
{
    int v = (state ? 1 : 0);
    
    if ([SGXmlPullParserAllowsEmptyAttribute isEqualToString : name])
        _PFlags.AllowsEmptyAttribute = v;
    else if ([SGXmlPullParserIgnoreEntityResolvingError isEqualToString : name])
        _PFlags.IgnoreEntityResolvingError = v;
    else if ([SGXmlPullParserAllowsDuplicateAttribute isEqualToString : name])
        _PFlags.allowsDuplicateAttribute = v;
    else if ([SGXmlPullParserAllowsUnquotedValue isEqualToString : name])
        _PFlags.allowsUnquotedValue = v;
    else if ([SGXmlPullParserUsesLowerCaseName isEqualToString : name])
        _PFlags.usesLowerCaseName = v;
    else if ([SGXmlPullParserDisableEntityResolving isEqualToString : name])
        _PFlags.disableEntityResolving = v;
    else if ([SGXmlPullParserAllowsIllegalComment isEqualToString : name])
        _PFlags.allowsIllegalComment = v;
    
}
@end
