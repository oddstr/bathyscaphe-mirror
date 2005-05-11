//: CMRTextView.m
/**
  * $Id: CMRTextView.m,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRTextView.h"
#import "CocoMonar_Prefix.h"



@implementation CMRTextView

#if 0
/*
2003-07-29 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
	* setMarkedText:selectedRange:
		現在のCocoaの実装ではなぜか、markedTextAttributes
		が反映されないようなので、勝手に置き換える。
*/
- (void) setMarkedText : (id) aString
         selectedRange : (NSRange)selRange
{
	NSDictionary	*attrs;
	id				text_ = aString;
	NSString		*str_;
	
	UTILRequireCondition(aString, CallSuper);
	attrs = [self markedTextAttributes];
	UTILRequireCondition(attrs, CallSuper);
	// こうすると、空の属性辞書を渡せなくなるが、
	// 今回はこれで十分
	UTILRequireCondition([attrs count], CallSuper);
	
	text_ = SGTemporaryAttributedString();
	
	str_ = [aString stringValue];
	if(nil == str_) str_ = @"";
	[[text_ mutableString] setString : str_];
	[text_ setAttributes:attrs range:[text_ range]];
	
CallSuper:
	[super setMarkedText:text_ selectedRange:selRange];
}

- (void) setMarkedTextAttributes : (NSDictionary *) dict
{
	// nilを渡せないようなので、とりあえず空の辞書を渡しておいて、
	// [setMarkedText:selectedRange]側で特別扱い。汎用性なし。
	[super setMarkedTextAttributes : 
		(dict ? dict : [NSDictionary empty])];
}
#endif
@end
