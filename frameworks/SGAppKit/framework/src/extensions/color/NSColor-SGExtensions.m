//: NSColorl-SGExtensions.m
/**
  * $Id: NSColor-SGExtensions.m,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "NSColor-SGExtensions.h"


#define iTunesStripedColorStr	@"1 0.92 0.95 1.0 1.0"

@implementation NSColor(iTunesSkin)
+ (NSColor *) iTunesStripedColor
{
	return SGColorFromString(iTunesStripedColorStr);
}
@end



enum {
	kSGColorspaceRGBTag = 1,
	kSGColorspaceCMYKTag,
	kSGColorspaceGrayscaleTag,
	kSGColorspaceUnknown
};
NSString *SGStringFromColor(NSColor *aColor)
{
	NSString	*str = nil;
	
	if(nil == aColor) return nil;

// RGB Color
NS_DURING
	float		red, green, blue, alpha;
	
	[aColor getRed:&red green:&green blue:&blue alpha:&alpha];
	str = [NSString stringWithFormat :
				@"%d %.2f %.2f %.2f %.2f",
				kSGColorspaceRGBTag,
				red,
				green,
				blue,
				alpha];
NS_HANDLER
	
NS_ENDHANDLER
	if(str != nil) return str;
	
// CMYK color.
NS_DURING
	float		cyan, magenta, yellow, black, alpha;
	[aColor getCyan:&cyan magenta:&magenta yellow:&yellow black:&black alpha:&alpha];
	str = [NSString stringWithFormat :
				@"%d %.2f %.2f %.2f %.2f %.2f",
				kSGColorspaceCMYKTag,
				cyan, magenta, yellow, black, alpha];
NS_HANDLER

NS_ENDHANDLER
	if(str != nil) return str;
	
// grayscale color.
NS_DURING
	float		white, alpha;
	
	
	[aColor getWhite:&white alpha:&alpha];
	str = [NSString stringWithFormat :
				@"%d %.2f %.2f",
				kSGColorspaceGrayscaleTag,
				white,
				alpha];
NS_HANDLER

NS_ENDHANDLER
	if(str != nil) return str;
	
	return nil;
}

NSColor	*SGColorFromString(NSString *aString)
{
	const char	*p;
	int			nscaned_;
	int			tag_;
	NSColor		*color_ = nil;
	
	if(nil == aString || 0 == [aString length]) return nil;
	if(NULL == (p = [aString UTF8String])) return nil;
	
	nscaned_ = sscanf(p, "%d", &tag_);
	if(nscaned_ != 1){
		NSLog(@"Can't scan Colorspace tag from string(%@).", aString);
		return nil;
	}
	
	// ì«Ç›çûÇÒÇæÉ^ÉOÇÃï™ÇæÇØêiÇﬂÇÈ
	p++;
	switch(tag_){
	case kSGColorspaceRGBTag:{
		float		red, green, blue, alpha;
		nscaned_ = sscanf(p,
					"%f %f %f %f",
					&red, &green, &blue, &alpha);
		
		if(4 == nscaned_){
			color_ = [NSColor colorWithCalibratedRed : red
											   green : green
												blue : blue
											   alpha : alpha];
		}
		break;
	}

	case kSGColorspaceCMYKTag:{
		float		cyan, magenta, yellow, black, alpha;
		
		nscaned_ = sscanf(p,
					"%f %f %f %f %f",
					&cyan, &magenta, &yellow, &black, &alpha);
		if(5 == nscaned_){
			color_ = [NSColor colorWithDeviceCyan : cyan
									magenta:magenta
									yellow:yellow
									black:black
									alpha:alpha];
		}
		break;
	}
	case kSGColorspaceGrayscaleTag:{
		float		white, alpha;
		nscaned_ = sscanf(p,
					"%f %f",
					&white, &alpha);
		
		if(2 == nscaned_){
			color_ = [NSColor colorWithCalibratedWhite : white
											   alpha : alpha];
		}
		break;
	}
	
	default :
		NSLog(@"***ERROR*** SGColorFromString() Unknown tag (%d)", tag_);
		break;
	}

	return color_;
}
