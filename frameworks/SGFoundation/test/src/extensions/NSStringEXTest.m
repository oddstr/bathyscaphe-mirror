//: NSStringEXTest.m
/**
  * $Id: NSStringEXTest.m,v 1.1.1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSStringEXTest.h"


// Resource Access
#define TESTS_RESOURCE_DIRNAME    @"Test-Resources"
#define RB_URLENCODE_SCRT_FNAME   @"line_urlencode.rb"

#define NEWLINECR_FILENAME		@"newlineCR.txt"
#define NEWLINECRLF_FILENAME	@"newlineCRLF.txt"
#define NEWLINELF_FILENAME		@"newlineLF.txt"

/*
static NSString *test_urlencode_fnames[] = {
				@"test_urlencode_sjis.txt",
				@"test_urlencode_jis.txt",
				@"test_urlencode_macos.txt",
				@"test_urlencode_utf8.txt",
				@"test_urlencode_euc.txt"
};
static NSStringEncoding test_urlencode_encodings[] = {
				kCFStringEncodingShiftJIS,
				kCFStringEncodingISO_2022_JP,
				kCFStringEncodingMacJapanese,
				kCFStringEncodingUTF8,
				kCFStringEncodingEUC_JP
};
*/

@implementation NSStringEXTest
- (void)setUp 
{
	[self setStringValue : nil];
}

- (void)tearDown
{
	[self setStringValue : nil];
}

- (void) test_stringWithData_encoding
{
	NSString *str_, *dummy_;
	NSAutoreleasePool *pool_;
	NSStringEncoding enc_;
	
	pool_ = [[NSAutoreleasePool alloc] init];
	enc_ = [NSString defaultCStringEncoding];
	dummy_ = @"hoge";
	str_ = [NSString stringWithData : [dummy_ dataUsingEncoding : enc_]
						   encoding : enc_];
	[str_ retain];
	[self assertString : str_ 
				equals : dummy_];
	[pool_ release];
	[self assertInt : [str_ retainCount]
			 equals : 1];
	[str_ release];
}
- (void) test_componentsSeparatedByCharacterSequenceFromSet
{
	NSString		*str;
	NSArray			*result;
	NSCharacterSet	*cset;
	
	str = @"A B C";
	cset = [NSCharacterSet whitespaceCharacterSet];
	result = [str componentsSeparatedByCharacterSequenceFromSet : cset];
	
	[self assertNotNil : result
			   message : @"A B C"];
	[self assertInt : [result count]
			 equals : 3
			message : @"A B C"];
	[self assert : [result objectAtIndex : 0]
		  equals : @"A"
		 message : @"A B C - 0"];
	[self assert : [result objectAtIndex : 1]
		  equals : @"B"
		 message : @"A B C - 1"];
	[self assert : [result objectAtIndex : 2]
		  equals : @"C"
		 message : @"A B C - 2"];

	str = @"A   B C  ";
	cset = [NSCharacterSet whitespaceCharacterSet];
	result = [str componentsSeparatedByCharacterSequenceFromSet : cset];
	[self assertNotNil : result
			   message : @"A   B C  "];
	[self assertInt : [result count]
			 equals : 4
			message : @"A   B C  "];
	[self assert : [result objectAtIndex : 0]
		  equals : @"A"
		 message : @"A   B C   - 0"];
	[self assert : [result objectAtIndex : 1]
		  equals : @"B"
		 message : @"A   B C   - 1"];
	[self assert : [result objectAtIndex : 2]
		  equals : @"C"
		 message : @"A   B C   - 2"];
	[self assert : [result objectAtIndex : 3]
		  equals : @""
		 message : @"A   B C   - 3"];
}
- (void) test_rangeOfCharacterSequenceFromSet
{
	NSRange			result;
	NSString		*str;
	NSCharacterSet	*cset;
	
	str = @"";
	cset = [NSCharacterSet whitespaceCharacterSet];
	result = [str rangeOfCharacterSequenceFromSet:cset];
	[self assertInt : result.length
			 equals : 0];
	result = [str rangeOfCharacterSequenceFromSet:cset options:NSBackwardsSearch];
	[self assertInt : result.length
			 equals : 0];

	str = @"   ";
	cset = [NSCharacterSet whitespaceCharacterSet];
	result = [str rangeOfCharacterSequenceFromSet:cset];
	[self assertInt : result.location
			 equals : 0];
	[self assertInt : result.length
			 equals : 3];
	result = [str rangeOfCharacterSequenceFromSet:cset options:NSBackwardsSearch];
	[self assertInt : result.location
			 equals : 0];
	[self assertInt : result.length
			 equals : 3];

	NSRange		range_;
	
	str = @"   ";
	range_ = NSMakeRange(0, 2);
	cset = [NSCharacterSet whitespaceCharacterSet];
	result = [str rangeOfCharacterSequenceFromSet:cset options:0 range:range_];
	[self assertInt : result.location
			 equals : range_.location];
	[self assertInt : result.length
			 equals : range_.length];
	result = [str rangeOfCharacterSequenceFromSet:cset options:NSBackwardsSearch range:range_];
	[self assertInt : result.location
			 equals : range_.location];
	[self assertInt : result.length
			 equals : range_.length];
}

- (void) test_stringWithCharacter
{
	NSString *str_, *dummy_;
	unichar c;
	
	dummy_ = @" ";
	c = [dummy_ characterAtIndex : 0];
	str_ = [NSString stringWithCharacter : c];
	[self assertString : str_ 
				equals : dummy_];
}

- (void) test_componentsSeparatedByNewline
{
	NSArray *array_;
	
	NSString *str1 = @"01223\ncntjfi\njfi";
	NSString *emptyString = @"";
	NSString *noNewline = @"Testing";
	NSString *onlyNewline = @"\n";
	NSString *anyNewLine = @"\n\r\n";
	
	array_ = [str1 componentsSeparatedByNewline];
	[self assertInt : [array_ count]
			 equals : [[str1 componentsSeparatedByString : @"\n"] count]
			message : str1];
	array_ = [emptyString componentsSeparatedByNewline];
	[self assertInt : [array_ count]
			 equals : [[emptyString componentsSeparatedByString : @"\n"] count]
			message : @"[Test Empty String]"];

	array_ = [noNewline componentsSeparatedByNewline];
	[self assertInt : [array_ count]
			 equals : [[noNewline componentsSeparatedByString : @"\n"] count]
			message : @"[Test None NewLine String]"];
	
	
	array_ = [onlyNewline componentsSeparatedByNewline];
	[self assertInt : [array_ count]
			 equals : [[onlyNewline componentsSeparatedByString : @"\n"] count]
			message : @"[Test Only NewLine<\"\\n\"> String]"];

	array_ = [anyNewLine componentsSeparatedByNewline];
	[self assertString : [array_ objectAtIndex : 0]
				equals : @""];
	[self assertInt : [array_ count]
			 equals : [[@"\n\n" componentsSeparatedByString : @"\n"] count]
			message : @"Test Any NewLine\\n\\r\\n"];
}

- (void) test_stringByURLEncodedUsingEncoding_tilde
{
	NSString	*tilde_ = @"~takanori ";
	
	[self assertString : [tilde_ stringByURLEncodingUsingEncoding:CF2NSEncoding(kCFStringEncodingMacJapanese)]
				equals : @"%7Etakanori%20"
			      name : @"tilde_"];

}

// というかCFURLCreateStringByAddingPercentEscapesがちょっと。。
/*
- (void) test_stringByURLEncodedUsingEncoding
{
	NSString *no_encode_ = @"0123456789abcdefgABGCJDY";
	NSString *encoded_;
	
	NSString *scpt_path_, *test_fpath_;
	int i, cnt;
	
	//scripts
	scpt_path_ = [[self class] pathForTestResourceWithName : 
									RB_URLENCODE_SCRT_FNAME];
	
	cnt = (sizeof(test_urlencode_fnames) / sizeof(NSString *));
	for(i = 0; i < cnt; i++){
		NSString *fcontents_;
		NSString *CFURLEncoded_;
		
		// 日本語ファイルを順番に処理。
		test_fpath_ = [[self class] pathForTestResourceWithName : 
											test_urlencode_fnames[i]];
		fcontents_ = [NSString stringWithContentsOfFile : test_fpath_];
		
		encoded_ = [fcontents_ stringByURLEncodingUsingCFEncoding : 
								test_urlencode_encodings[i]];
		CFURLEncoded_ = (NSString*)CFURLCreateStringByAddingPercentEscapes(
					CFAllocatorGetDefault(), 
					(CFStringRef)fcontents_, 
					NULL, 
					NULL, 
					test_urlencode_encodings[i]);
		
		NSLog(@"encoded_ = %@", encoded_);
		NSLog(@"CFURLEncoded_ = %@", CFURLEncoded_);
		
		
		[self assertString : encoded_
					equals : CFURLEncoded_
				    name : [test_fpath_ lastPathComponent]];
	}
	
	encoded_ = [no_encode_ stringByURLEncodingUsingCFEncoding : 
					[NSString defaultCStringEncoding]];
	[self assertString : encoded_
			    equals : no_encode_];
	
}

*/
- (void) testValidURLCharacters
{
	NSString	*valid_		= @"hoge/foo";
	NSString	*invalid_	= @"hoge<>";
	
	[self assertTrue : [valid_ isValidURLCharacters]
			 message : @"F:valid isValidURLCharacters"];
	[self assertFalse : [invalid_ isValidURLCharacters]
			  message : @"F:invalid_ isValidURLCharacters"];
	[self assertFalse : [@"" isValidURLCharacters]
			  message : @"F:\"\" isValidURLCharacters"];
	
}

- (NSString *) stringResourceWithName : (NSString *) filename
{
	NSString		*path_;
	path_ = [[self class] pathForTestResourceWithName : filename];
	[self assertNotNil : path_
			   message : filename];
	return [NSString stringWithContentsOfFile : path_];
}

- (void) test_componentsSeparatedByNewline2
{
	NSArray		*components001, *components002,*components003;
	int			cnt;
	
	components001 = [[self stringResourceWithName : NEWLINECR_FILENAME] componentsSeparatedByNewline];
	components002 = [[self stringResourceWithName : NEWLINECRLF_FILENAME] componentsSeparatedByNewline];
	components003 = [[self stringResourceWithName : NEWLINELF_FILENAME] componentsSeparatedByNewline];
	
	cnt = [components001 count];
	
	[self assertTrue : (cnt == [components002 count])
	message : [NSString stringWithFormat : @"%@: expected %u but was %u.",
				NEWLINECRLF_FILENAME,
				cnt,
				[components002 count]]];
	[self assertTrue : (cnt == [components003 count])
	message : [NSString stringWithFormat : @"%@: expected %u but was %u.",
				NEWLINELF_FILENAME,
				cnt,
				[components003 count]]];
}
//////////////////////////////////////////////////////////////////////
////////////////////// [ アクセサメソッド ] //////////////////////////
//////////////////////////////////////////////////////////////////////
/* Accessor for m_stringValue */
- (NSString *) stringValue
{
	return m_stringValue;
}
- (void) setStringValue : (NSString *) aStringValue
{
	[aStringValue retain];
	[[self stringValue] release];
	m_stringValue = aStringValue;
}

@end
