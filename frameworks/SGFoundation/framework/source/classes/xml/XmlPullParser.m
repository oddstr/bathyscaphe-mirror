//: XmlPullParser.m
/**
  * $Id: XmlPullParser.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "XmlPullParser.h"



//  This array can be used to convert the event type integer constants
NSString *const XMLPULL_TYPES[] = {
			@"START_DOCUMENT",
			@"END_DOCUMENT",
			@"START_TAG",
			@"END_TAG",
			@"TEXT",
			@"CDSECT",
			@"ENTITY_REF",
			@"IGNORABLE_WHITESPACE",
			@"PROCESSING_INSTRUCTION",
			@"COMMENT",
			@"DOCDECL"
	};

// General Exception
NSString *const XmlPullParserException = @"XmlPullParserException";
