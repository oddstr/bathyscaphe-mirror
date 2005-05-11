//: XmlPullParser.h
/**
  * $Id: XmlPullParser.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#ifndef XMLPULLPARSER_H_INCLUDED
#define XMLPULLPARSER_H_INCLUDED



#import <Foundation/Foundation.h>
#import <SGFoundation/SGBase.h>

SG_DECL_BEGIN

/*
 * This is an Objective-C Interface for XML Pull Parsing API.
 *
 * [XML Pull -- Common API for XML Pull Parsing]
 * HomePage: http://www.xmlpull.org/
 *
 */


enum {
	XMLPULL_START_DOCUMENT = 0,
	XMLPULL_END_DOCUMENT,
	XMLPULL_START_TAG,
	XMLPULL_END_TAG,
	XMLPULL_TEXT,
	
	/* additional events */
	XMLPULL_CDSECT,
	XMLPULL_ENTITY_REF,
	XMLPULL_IGNORABLE_WHITESPACE,
	XMLPULL_PROCESSING_INSTRUCTION,
	XMLPULL_COMMENT,
	XMLPULL_DOCDECL
};
//  This array can be used to convert the event type integer constants
SG_EXPORT
NSString *const XMLPULL_TYPES[];

// Exception
SG_EXPORT
NSString *const XmlPullParserException;


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
// èÌÇ…è¨ï∂éöÇÃñºëOÇ…ïœä∑Ç∑ÇÈ
SG_EXPORT
NSString *const SGXmlPullParserUsesLowerCaseName;


SG_EXPORT
NSString *const SGXmlPullParserDisableEntityResolving;
// allows comment like a "<!--- blur blur... --->"
SG_EXPORT
NSString *const SGXmlPullParserAllowsIllegalComment;


@protocol XmlPullParser
- (void) setInputSource : (NSString *) aSource;

- (int) eventType;


// Returend value from these methods may be temporary object.
- (NSString *) name;
- (NSString *) text;
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
- (NSString *) attributeForName : (NSString *) aName;
- (UniChar *) textCharacters : (CFRange *) holderForStartAndLength;

- (int) depth;
- (unsigned) lineNumber;
- (unsigned) columnNumber;
// e.g. <element/> 
- (BOOL) isEmptyElementTag;
- (BOOL) isWhitespace;

- (int) next;
- (int) nextToken;
- (int) nextTag;
- (NSString *) nextText;

- (BOOL) featureForKey : (NSString *) name;
- (void) setFeature : (BOOL      ) state
			 forKey : (NSString *) name;



- (int) nextName : (NSString *) name
			type : (int       ) type
		 options : (unsigned  ) mask;
@end


SG_DECL_END

#endif /* XMLPULLPARSER_H_INCLUDED */
