#import "NSMutableStringEXTest.h"


#define    TEST_REPLACECHARACTERS_FINAME    @"test_replaceCharacters_toString.plist"
#define    RESULT_REPLACECHARACTERS_FINAME    @"result_replaceCharacters_toString.plist"

@implementation NSMutableStringEXTest
- (void)setUp 
{
}

- (void)tearDown
{
}

- (void) test_replaceCharacters_toString_options_range
{
	NSString *standard_ = @"test_replaceCharacters_toString_options_range";
	NSString *newlines_ = @"test\nis\rFirst!\r\n";
	NSMutableString *source_;
	
	source_ = [NSMutableString stringWithString : standard_];
	[source_ replaceCharacters : @"toString"
                  toString : @"TOSTRING"];
	[self assertString : source_
	equals : @"test_replaceCharacters_TOSTRING_options_range"];

	source_ = [NSMutableString stringWithString : standard_];
	[source_ replaceCharacters : @"TOSTRING"
                  toString : @"TOSTRING"
				  options : NSCaseInsensitiveSearch];
	[self assertString : source_
	equals : @"test_replaceCharacters_TOSTRING_options_range"];

	source_ = [NSMutableString stringWithString : standard_];
	[source_ replaceCharacters : @"test"
                  toString : @"TOSTRING"];
	[self assertString : source_
	equals : @"TOSTRING_replaceCharacters_toString_options_range"];

	source_ = [NSMutableString stringWithString : standard_];
	[source_ replaceCharacters : @"test"
                  toString : @"TOSTRING"
				  options : NSLiteralSearch
				  range : NSMakeRange(0, 3)];
	[self assertString : source_
	equals : standard_];

	source_ = [NSMutableString stringWithString : standard_];
	[source_ replaceCharacters : @"hoge"
                  toString : @"TOSTRING"];
	[self assertString : source_
	equals : standard_];

	source_ = [NSMutableString stringWithString : standard_];
	[source_ replaceCharacters : @""
                  toString : @"TOSTRING"];
	[self assertString : source_
	equals : standard_];

	source_ = [NSMutableString stringWithString : newlines_];
	[source_ replaceCharacters : @"\n"
                  toString : @""];
	[self assertString : source_
	equals : @"testis\rFirst!\r"];
}

- (void) test_deleteCharactersInSet
{
	NSString *str_ = @"abcdefghijklmnABCD0123456789";
	NSMutableString *mstr_;
	NSCharacterSet *cset_;
	
	mstr_ = [NSMutableString stringWithString : str_];
	cset_ = [NSCharacterSet alphanumericCharacterSet];
	[mstr_ deleteCharactersInSet : cset_];
	[self assertString : mstr_
	equals : @""];

	mstr_ = [NSMutableString stringWithString : str_];
	cset_ = [NSCharacterSet controlCharacterSet];
	[mstr_ deleteCharactersInSet : cset_];
	[self assertString : mstr_
	equals : str_];

	mstr_ = [NSMutableString stringWithString : str_];
	cset_ = [NSCharacterSet decimalDigitCharacterSet];
	[mstr_ deleteCharactersInSet : cset_];
	[self assertString : mstr_
				equals : @"abcdefghijklmnABCD"
			   message : @"decimalDigitCharacterSet"];

	mstr_ = [NSMutableString stringWithString : str_];
	cset_ = [NSCharacterSet decimalDigitCharacterSet];
	[mstr_ deleteCharactersInSet : cset_
				options : NSLiteralSearch
				range : NSMakeRange(0, 18)];
	[self assertString : mstr_
				equals : @"abcdefghijklmnABCD0123456789"
			   message : @"decimalDigitCharacterSet+range"];
}

- (void) test_strip
{
	NSString *str_ = @"    test   \t  \n";
	NSMutableString *mstr_;
	
	mstr_ = [NSMutableString stringWithString : str_];
	[mstr_ strip];
	[self assertString : mstr_
				equals : @"test"];
	mstr_ = [NSMutableString stringWithString : @"test"];
	[mstr_ strip];
	[self assertString : mstr_
				equals : @"test"];
	mstr_ = [NSMutableString stringWithString : @""];
	[mstr_ strip];
	[self assertString : mstr_
				equals : @""];
}

- (void) test_deleteAllTagElements
{
	NSString *str_ = @"<html>\n<head>\n<TITLE>hoge</TITLE>\n<META HTTP-EQUIV=\"Content-type\" CONTENT=\"text/html;charset=iso-2022-jp\">\n<META NAME=\"robots\" CONTENT=\"noindex,nofollow\">\n</head>\n<BODY BGCOLOR=#000000 TEXT=#FFFFFF LINK=#FF0000 VLINK=FFFF00>\n<p>\n<center><FONT SIZE=+3 FACE=\"sjdfjisdjifjosidjfo\"><FONT COLOR=\"#FF8020\"><b>hoge</b></FONT></FONT></center>\n<p>\n";
	NSMutableString *mstr_;
	mstr_ = [NSMutableString stringWithString : str_];
	[mstr_ deleteAllTagElements];
	[self assertString : mstr_
				equals : @"\n\nhoge\n\n\n\n\n\nhoge\n\n"];
	
}

- (void) test_replaceEntityReference
{
	NSMutableString *mstr_;
	NSString		*str_;
	
	str_ = @"";
	mstr_ = [NSMutableString stringWithString : str_];
	[mstr_ replaceEntityReference];
	[self assertString : mstr_
			equals : str_
			message : @"F:empty"];
	
	str_ = @"          ";
	[mstr_ setString : str_];
	[mstr_ replaceEntityReference];
	[self assertString : mstr_
			equals : str_
			message : @"F:space"];
	
	str_ = @"&;&;&;&;";
	[mstr_ setString : str_];
	[mstr_ replaceEntityReference];
	[self assertString : mstr_
			equals : str_
			message : @"F:\"&;&;&;&;\""];
	
	str_ = @"&&amp;";
	[mstr_ setString : str_];
	[mstr_ replaceEntityReference];
	[self assertString : mstr_
			equals : @"&&"
			message : @"F:&"];
	
	str_ = @"&amp;";
	[mstr_ setString : str_];
	[mstr_ replaceEntityReference];
	[self assertString : mstr_
			equals : @"&"
			message : @"F:&"];
	
	str_ = @"&#65;&#66;&#67;&#68;";
	[mstr_ setString : str_];
	[mstr_ replaceEntityReference];
	[self assertString : mstr_
			equals : @"ABCD"
			message : @"F:ABCD"];

	
	str_ = @"&9829;";
	[mstr_ setString : str_];
	[mstr_ replaceEntityReference];
	[self assertString : mstr_
			equals : @"&9829;"
			message : @"F:&9829;"];
}
@end
