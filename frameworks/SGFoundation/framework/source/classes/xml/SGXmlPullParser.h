//: SGXmlPullParser.h
/**
  * $Id: SGXmlPullParser.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#ifndef SGXMLPULLPARSER_H_INCLUDED
#define SGXMLPULLPARSER_H_INCLUDED

#import <SGFoundation/SGBase.h>
#import <Foundation/Foundation.h>
#import <SGFoundation/XmlPullParser.h>

SG_DECL_END



#define SGXML_PEEK_SIZE        2
typedef struct SGXmlPullPeek SGXmlPullPeek;
typedef struct SGXmlPullInlineBuffer SGXmlPullInlineBuffer;
typedef struct _SGXmlUniCharBuffer SGXmlUniCharBuffer;
struct _SGXmlUniCharBuffer {
    UniChar *buffer;
    CFIndex size;
    CFIndex count;
};

@interface SGXmlPullParser : NSObject<XmlPullParser>
{
    @private
    struct SGXmlPullFlags{
        unsigned int AllowsEmptyAttribute : 1;
        unsigned int IgnoreEntityResolvingError : 1;
        unsigned int allowsDuplicateAttribute : 1;
        unsigned int allowsUnquotedValue : 1;
        unsigned int usesLowerCaseName : 1;
        unsigned int disableEntityResolving : 1;
        unsigned int allowsIllegalComment : 1;
        unsigned int : 9;
        unsigned int peekReadedCR : 1;
        unsigned int isWhitespace : 1;
        unsigned int degenerated : 1;
        unsigned int token : 1;
        unsigned int eos : 1; /* end of source */
        unsigned int : 11;
    } _PFlags;
    
    /* internal buffer for input source */
    struct SGXmlPullInlineBuffer{
        NSString             *source;
        CFStringInlineBuffer *inlineBuffer;
        unsigned              position;
        CFRange               bufferRange;
    } _srcBuf;
    
    /* internal buffer for peek */
    struct SGXmlPullPeek {
        UniChar buffer[SGXML_PEEK_SIZE];
        CFIndex size;
        CFIndex count;
        CFIndex index;
    } _peek;
    
    int      _type;
    NSString *_name;
    id       _attributes;
    
    /* position */
    int      _depth;
    unsigned _line;
    unsigned _column;
    
    /* internal buffer for text */
    SGXmlUniCharBuffer *_textBuf;
}

/**
 * @method null
 * @abstract Return the marker object for empty attribute.
 * @discussion

Return the marker object for empty attribute.
If SGXmlPullParserAllowsEmptyAttribute feature is enabled, 
SGXmlPullParser allows empty value of any attribute. Then
attributeForKey: method returns unique object that is equivalent
of object this method returned.
You can simply compare each object uning '==' operator.

 * @result The marker object for empty attribute
 */
+ (id) null;

/*!
 * @method        empty
 * @abstract      Deprecated. 
 * @discussion    

Deprecated.ÊAs of current version, replaced by  
- [SGXmlPullParser null]

 */
+ (id) empty;

// sets All HTML Features enable
- (id) initHTMLParser;

- (NSString *) inputSource;
- (void) setInputSource : (NSString *) aSource;
@end



// SGXmlPullParser Features

/* HTML Parsing */
SG_EXPORT
NSString *const SGXmlPullParserAllowsEmptyAttribute;
SG_EXPORT
NSString *const SGXmlPullParserIgnoreEntityResolvingError;
SG_EXPORT
NSString *const SGXmlPullParserAllowsDuplicateAttribute;
SG_EXPORT
NSString *const SGXmlPullParserAllowsUnquotedValue;
// always tag name as lower
SG_EXPORT
NSString *const SGXmlPullParserUsesLowerCaseName;


SG_EXPORT
NSString *const SGXmlPullParserDisableEntityResolving;


SG_DECL_END

#endif /* SGXMLPULLPARSER_H_INCLUDED */
