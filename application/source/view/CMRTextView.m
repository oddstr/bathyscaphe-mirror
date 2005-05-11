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
		���݂�Cocoa�̎����ł͂Ȃ����AmarkedTextAttributes
		�����f����Ȃ��悤�Ȃ̂ŁA����ɒu��������B
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
	// ��������ƁA��̑���������n���Ȃ��Ȃ邪�A
	// ����͂���ŏ\��
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
	// nil��n���Ȃ��悤�Ȃ̂ŁA�Ƃ肠������̎�����n���Ă����āA
	// [setMarkedText:selectedRange]���œ��ʈ����B�ėp���Ȃ��B
	[super setMarkedTextAttributes : 
		(dict ? dict : [NSDictionary empty])];
}
#endif
@end
