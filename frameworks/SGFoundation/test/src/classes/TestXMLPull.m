//: TestXMLPull.m
/**
  * $Id: TestXMLPull.m,v 1.1.1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "TestXMLPull.h"
#import "UTILKit.h"



@implementation TestXMLPull
// ----------------------------------------
// SetUp / TearDown
// ----------------------------------------
- (void) setUp
{
    ;
}
- (void) tearDown
{
    ;
}

// ----------------------------------------
// Tests
// ----------------------------------------
- (void) test_simple_text
{
    NSString          *source_ = @"xxx";
    id<XmlPullParser> xpp_;
    int               type_;
    
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [self assertNotNil : xpp_
               message : @"init"];
    [xpp_ setInputSource : source_];
    
    type_ = [xpp_ eventType];
    [self assertInt : type_
             equals : XMLPULL_START_DOCUMENT];
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_TEXT];
    [self assertString : [xpp_ text]
                equals : source_];
    
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_END_DOCUMENT];
    [self assertNil : [xpp_ text]];
}

- (void) test_simple_xml001
{
    NSString            *source_ ;
    id<XmlPullParser>    xpp_;
    int                    type_;
    
    source_ = @"<greeting>Hello</greeting>";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_START_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];

    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_TEXT];
    [self assertString : [xpp_ text]
                equals : @"Hello"];

    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_END_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];

}


- (void) test_simple_xml001_emptyText
{
    NSString            *source_ ;
    id<XmlPullParser>    xpp_;
    int                    type_;
    
    source_ = @"<greeting></greeting>";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];

    [xpp_ setInputSource : source_];
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_START_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];

    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_END_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];

}
- (void) test_simple_xml001_newline
{
    NSString          *source_ ;
    id<XmlPullParser> xpp_;
    int               type_;
    
    source_ = @"<greeting>\nHello\r\n</greeting>";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_START_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];
    
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_TEXT];
    [self assertString : [xpp_ text]
                equals : @"\nHello\n"];

    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_END_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];

}


- (void) test_simple_xml002
{
    NSString            *source_ ;
    id<XmlPullParser>    xpp_;
    int                    type_;
    
    source_ = @"<song>Cine Du Samedi<artist>clementine</artist></song>";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_START_TAG];
    [self assertString : [xpp_ name]
                equals : @"song"];

    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_TEXT];
    [self assertString : [xpp_ text]
                equals : @"Cine Du Samedi"];
    // artist
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_START_TAG];
    [self assertString : [xpp_ name]
                equals : @"artist"];
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_TEXT];
    [self assertString : [xpp_ text]
                equals : @"clementine"];
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_END_TAG];
    [self assertString : [xpp_ name]
                equals : @"artist"];

    
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_END_TAG];
    [self assertString : [xpp_ name]
                equals : @"song"];

}

- (void) test_simple_xml003_EmptyTag
{
    NSString            *source_ ;
    id<XmlPullParser>    xpp_;
    int                    type_;
    
    source_ = @"<Empty />";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_START_TAG];
    [self assertString : [xpp_ name]
                equals : @"Empty"];
    [self assertTrue : [xpp_ isEmptyElementTag]];
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_END_TAG];
    [self assertString : [xpp_ name]
                equals : @"Empty"];
}
- (void) test_simple_xml004
{
    NSString            *source_ ;
    id<XmlPullParser>    xpp_;
    int                    type_;
    
    source_ = @"<greeting name=\"takanori_is\">Hello</greeting>";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_START_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];
    [self assertFalse : [xpp_ isEmptyElementTag]];
    
    [self assertString : [xpp_ attributeForName : @"name"]
                equals : @"takanori_is"];
    
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_TEXT];
    [self assertString : [xpp_ text]
                equals : @"Hello"];

    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_END_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];
}

- (void) test_simple_xml005
{
    NSString            *source_ ;
    id<XmlPullParser>    xpp_;
    int                    type_;
    
    source_ = @"<greeting>Hello &amp; Bye!</greeting>";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_START_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];

    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_TEXT];
    [self assertString : [xpp_ text]
                equals : @"Hello & Bye!"];

    type_ = [xpp_ next];
    [self assertInt : type_
             equals : XMLPULL_END_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];

}
- (void) test_simple_xml006
{
    NSString            *source_ ;
    id<XmlPullParser>    xpp_;
    int                    type_;
    
    source_ = @"<greeting>Hello &amp; Bye!</greeting>";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    type_ = [xpp_ nextToken];
    [self assertInt : type_
             equals : XMLPULL_START_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];

    type_ = [xpp_ nextToken];
    [self assertInt : type_
             equals : XMLPULL_TEXT];
    [self assertString : [xpp_ text]
                equals : @"Hello "];
    type_ = [xpp_ nextToken];
    [self assertInt : type_
             equals : XMLPULL_ENTITY_REF];
    [self assertString : [xpp_ text]
                equals : @"&"];
    type_ = [xpp_ nextToken];
    [self assertInt : type_
             equals : XMLPULL_TEXT];
    [self assertString : [xpp_ text]
                equals : @" Bye!"];

    type_ = [xpp_ nextToken];
    [self assertInt : type_
             equals : XMLPULL_END_TAG];
    [self assertString : [xpp_ name]
                equals : @"greeting"];

}

- (void) test_Entity_Ref
{
    NSString            *source_ ;
    id<XmlPullParser>    xpp_;
    int                    type_;
    
    // &quot;
    source_ = @"&quot;";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    type_ = [xpp_ nextToken];
    [self assertInt : type_
             equals : XMLPULL_ENTITY_REF
            message : @"&quot;"];
    [self assertString : [xpp_ text]
                equals : @"\""
               message : @"&quot;"];

    // &#32;
    source_ = @"&#32;";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    type_ = [xpp_ nextToken];
    [self assertInt : type_
             equals : XMLPULL_ENTITY_REF
            message : @"&#32;"];
    [self assertString : [xpp_ text]
                equals : @" "
               message : @"&#32;"];

    // &#x3A; == ':';
    source_ = @"&#x3A;";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    type_ = [xpp_ nextToken];
    [self assertInt : type_
             equals : XMLPULL_ENTITY_REF
            message : @"&#x3A"];
    [self assertString : [xpp_ text]
                equals : @":"
               message : @"&#x3A"];
}
- (void) test_Invalid_Entity
{
    NSString            *source_ ;
    id<XmlPullParser>    xpp_;
    int                    type_;
    
    source_ = @"&&amp;&amp";
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    [xpp_ setFeature:YES forKey:SGXmlPullParserIgnoreEntityResolvingError];
    
    type_ = [xpp_ nextToken];
    [self assertInt : type_
             equals : XMLPULL_TEXT
            message : @"&<&amp;&amp"];
    [self assertString : [xpp_ text]
                equals : @"&"
               message : @"&<&amp;&amp"];

    type_ = [xpp_ nextToken];
    
    [self assertInt : type_
             equals : XMLPULL_ENTITY_REF
            message : @"&&amp;<&amp"];
    [self assertString : [xpp_ text]
                equals : @"&"
               message : @"&&amp;<&amp"];
    type_ = [xpp_ nextToken];
    [self assertInt : type_
             equals : XMLPULL_TEXT];
    [self assertString : [xpp_ text]
                equals : @"&amp"
               message : @"&&amp;&amp<"];

}

- (void) test_attribute001
{
    NSString          *src ;
    id<XmlPullParser> xpp;
    int               type;
    BOOL              expectedExceptionRaised = NO;
    
    src = @"<Sample>Text</Sample>";
    
    xpp = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp setInputSource : src];
    
    
NS_DURING
    [xpp nextToken];
    [xpp nextToken];
    [xpp attributeForName : @"How?"];
NS_HANDLER
    
    UTILCatchException(NSRangeException){
        expectedExceptionRaised = YES;
    }
    
NS_ENDHANDLER
    if(NO == expectedExceptionRaised) {
        [self fail];
    }
}

- (void) test_Empty_Attributes
{
    NSString          *src ;
    id<XmlPullParser> xpp;
    int               type;
    BOOL              expectedExceptionRaised = NO;
    
    src = @"<Sample empty/>";
    
    xpp = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp setInputSource : src];
    
    
NS_DURING
    type = [xpp nextToken];
NS_HANDLER
    
    UTILCatchException(XmlPullParserException){
        expectedExceptionRaised = YES;
    }
    
NS_ENDHANDLER
    if(NO == expectedExceptionRaised) {
        [self fail];
    }
}
- (void) test_Empty_Attributes_002
{
    NSString            *source_ ;
    id<XmlPullParser>    xpp_;
    int                    type_;
    
    source_ = @"<Sample empty/>";
    
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    [xpp_ setFeature:YES forKey:SGXmlPullParserAllowsEmptyAttribute];
    
    type_ = [xpp_ nextToken];
    [self assertInt:type_
             equals:XMLPULL_START_TAG];
    [self assertString:[xpp_ name]
                equals:@"Sample"];
    [self assertNotNil:[xpp_ attributeForName:@"empty"]];
    
    [self assertTrue:[xpp_ isEmptyElementTag]];
    
    type_ = [xpp_ nextToken];
    [self assertInt:type_
             equals:XMLPULL_END_TAG];
}

- (void) test_XMLPULL_TYPES
{
    unsigned        length_;
    
    [self assertNotNil:XMLPULL_TYPES[XMLPULL_START_DOCUMENT]];
    [self assertNotNil:XMLPULL_TYPES[XMLPULL_DOCDECL]];
    
    length_ = [XMLPULL_TYPES[XMLPULL_DOCDECL] length];
}
- (void) test_CaseInsensitiveName
{
    id<XmlPullParser>    xpp_;    
    
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setFeature:YES forKey:SGXmlPullParserUsesLowerCaseName];
    
    [xpp_ setInputSource : @"<GREETING SAY=\"HELLO\"/>"];
    [xpp_ next];
    [self assertString:[xpp_ name]
                equals:@"greeting"
               message:@"Tag Name"];
    [self assertString:[xpp_ attributeForName:@"say"]
                equals:@"HELLO"
               message:@"Attribute"];
}
- (void) test_TEXT001
{
    id<XmlPullParser>    xpp_;    
    
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    
    [xpp_ setInputSource : @"&amp;Text&amp;"];
    [xpp_ next];
    [self assertString:[xpp_ text]
                equals:@"&Text&"
               message:@"&Text&"];
}
- (void) test_TEXT002
{
    id<XmlPullParser>    xpp_;    
    
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    
    [xpp_ setInputSource : @"&amp;Text&amp;"];
    [xpp_ setFeature:YES forKey:SGXmlPullParserDisableEntityResolving];
    
    [xpp_ next];
    [self assertString:[xpp_ text]
                equals:@"&amp;Text&amp;"
               message:@"&Text&"];
}
- (void) test_Newline
{
    id<XmlPullParser>    xpp_;    
    
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    
    [xpp_ setInputSource : @"Hoge\nHoge"];
    [xpp_ next];
    [self assertString:[xpp_ text]
                equals:@"Hoge\nHoge"
               message:@"LF"];

    [xpp_ setInputSource : @"Hoge\nHoge"];
    [xpp_ next];
    [self assertString:[xpp_ text]
                equals:@"Hoge\nHoge"
               message:@"CRLF"];

    [xpp_ setInputSource : @"Hoge\rHoge"];
    [xpp_ next];
    [self assertString:[xpp_ text]
                equals:@"Hoge\nHoge"
               message:@"CR"];
}
/* <a href="&">hoge</a> */
- (void) test_invalid_html001
{
    NSString            *source_ = @"<a href=\"one&two\">hoge</a>";
    id<XmlPullParser>    xpp_;

    xpp_ = [[[SGXmlPullParser alloc] initHTMLParser] autorelease];
    
    [xpp_ setInputSource : source_];
    [xpp_ setFeature:YES forKey:SGXmlPullParserDisableEntityResolving];
    
    [xpp_ next];
    [self assertString:[xpp_ name]
                equals:@"a"
               message:@"a"];
    [self assertString:[xpp_ attributeForName:@"href"]
                equals:@"one&two"
               message:@"href"];
    
    [xpp_ next];
    [self assertString:[xpp_ text]
                equals:@"hoge"
               message:@"hoge"];
}

- (void) test_Duplicate_Attributes
{
    NSString            *source_ ;
    id<XmlPullParser>    xpp_;
    int                    type_;
    BOOL                expectedExceptionRaised_ = NO;
    
    source_ = @"<Sample attrs=\"OK\" attrs=\"ERROR\"/>";
    
    xpp_ = [[[SGXmlPullParser alloc] init] autorelease];
    [xpp_ setInputSource : source_];
    
    
NS_DURING
    type_ = [xpp_ nextToken];
NS_HANDLER
    
    UTILCatchException(XmlPullParserException){
        // NS_VOIDRETURN;
        expectedExceptionRaised_ = YES;
        
    }
    
NS_ENDHANDLER
    if(NO == expectedExceptionRaised_)
        [self fail];
}
@end
