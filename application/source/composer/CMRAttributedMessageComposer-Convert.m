/**
  * $Id: CMRAttributedMessageComposer-Convert.m,v 1.8 2007/04/13 12:31:41 tsawada2 Exp $
  * 
  * CMRAttributedMessageComposer-Convert.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRAttributedMessageComposer_p.h"
#import <OgreKit/OgreKit.h>

static void convertMessageOrNameWith(NSMutableAttributedString *ms, NSString *str, NSDictionary *attributes)
{	
	if(ms == nil) return;

	[ms replaceCharactersInRange: [ms range] withString : str];
	[ms setAttributes: attributes range: [ms range]];

	[CMXTextParser convertMessageSourceToCachedMessage : [ms mutableString]];
}

static void convertMessageWith(NSMutableAttributedString *ms)
{
	if(0 == [ms length] || ms == nil)
		return;

	static OGRegularExpression	*regExpUl = nil;
	static OGRegularExpression	*regExp = nil;
	NSMutableString	*contents_ = [ms mutableString];

	if(!regExpUl) {
		NSString *tmp = [NSString stringWithFormat: @"(%@) <ul> ", NSLocalizedStringFromTable(@"saku target", @"MessageComposer", @"")];
		regExpUl = [[OGRegularExpression alloc] initWithString: tmp];
	}
	if(!regExp) {
		regExp = [[OGRegularExpression alloc] initWithString: @"ID:\\s?([[[:ascii:]]&&[^\\s]]{8,11})"];
	}
	OGRegularExpressionMatch *sakuMatch = [regExpUl matchInAttributedString: ms];
	if (sakuMatch) {
		NSRange redRange = [sakuMatch rangeOfSubstringAtIndex: 1];
		
		[contents_ replaceOccurrencesOfRegularExpressionString: @"</?ul> ?"
													withString: @"\n"
													   options: OgreNoneOption
														 range: NSMakeRange(0, [contents_ length])];

		[ms addAttribute: NSForegroundColorAttributeName value: [NSColor redColor] range: redRange];

	}
	// 本文中の「ID: xxxxxxxxxx」という文字列にも Attribute を仕込んで、長押しによる ID ポップアップを可能にする
	NSEnumerator *iter_ = [regExp matchEnumeratorInAttributedString: ms];
	if (!iter_) return;
	OGRegularExpressionMatch *eachMatch;
	while (eachMatch = [iter_ nextObject]) {
		NSRange IDRange = [eachMatch rangeOfMatchedString];
		[ms addAttribute:BSMessageIDAttributeName value: [eachMatch substringAtIndex: 1] range: IDRange];
	}
}

@implementation CMRAttributedMessageComposer(Convert)
- (void) convertMessage : (NSString                  *) message
				   with : (NSMutableAttributedString *) buffer
{
	convertMessageOrNameWith(buffer, message, [ATTR_TEMPLATE attributesForMessage]);
	convertMessageWith(buffer);
	[self convertLinkAnchor : buffer];
}
- (void) convertName : (NSString                  *) name
				with : (NSMutableAttributedString *) buffer
{
	convertMessageOrNameWith(buffer, name, [ATTR_TEMPLATE attributesForName]);
	[self makeInnerLinkAnchorInNameField : buffer];
}
@end
