//
//  BSBeSAAPAnchorComposer.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/10/12.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSBeSAAPAnchorComposer.h"


@implementation BSBeSAAPAnchorComposer
static BOOL g_showsSAAPIcon = YES;

static inline NSString *convertedLinkString(NSString *saapString)
{
	NSMutableString *string = [NSMutableString stringWithString:saapString];
	[string replaceCharactersInRange:NSMakeRange(0, 4) withString:@"http"];
	return string;
}

static inline NSAttributedString *beIconAttachment(NSURL *adjustedUrl)
{
	NSImage						*image_;
	NSTextAttachment			*attachment_;
	NSAttributedString			*attrs_;
	NSTextAttachmentCell		*cell_;

	if (!adjustedUrl) return nil;
	image_ = [[NSImage alloc] initWithContentsOfURL:adjustedUrl];

	if (!image_) return nil;

	attachment_ =  [[NSTextAttachment alloc] init];
	cell_ = [[NSTextAttachmentCell alloc] initImageCell:image_];
	[image_ release];
	
	[attachment_ setAttachmentCell:cell_];
	[cell_ release];
	
	if (!attachment_ || !cell_) return nil;

	attrs_ = [NSAttributedString attributedStringWithAttachment:attachment_];
	[attachment_ release];
	if (!attrs_) return nil;
	
	return attrs_;
}

+ (BOOL)showsSAAPIcon
{
	return g_showsSAAPIcon;
}

+ (void)setShowsSAAPIcon:(BOOL)flag
{
	g_showsSAAPIcon = flag;
}

- (id)initWithRange:(NSRange)range saapLinkString:(NSString *)string
{
	if (self = [super init]) {
		m_replacingRange = range;
		m_httpLinkString = [convertedLinkString(string) retain];
	}
	return self;
}

- (void)dealloc
{
	[m_httpLinkString release];
	m_httpLinkString = nil;
	[super dealloc];
}

- (void)composeSAAPAnchorIfNeeded:(NSMutableAttributedString *)message
{
	if ([[self class] showsSAAPIcon]) {
		NSURL *url = [NSURL URLWithString:m_httpLinkString];
		NSAttributedString *attrStr = beIconAttachment(url);
		if (attrStr) {
			[message replaceCharactersInRange:m_replacingRange withAttributedString:attrStr];
			return;
		}
	}

	[message replaceCharactersInRange:m_replacingRange withString:@""];
}
@end
