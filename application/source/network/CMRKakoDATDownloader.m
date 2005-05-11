//: CMRKakoDATDownloader.m
/**
  * $Id: CMRKakoDATDownloader.m,v 1.1 2005/05/11 17:51:06 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRKakoDATDownloader.h"
#import "ThreadTextDownloader_p.h"


@implementation CMRKakoDATDownloader

static NSString *const k9x9datKey = @"999999999";

static BOOL lessThan9x9Key(NSString *aKey)
{
	return [k9x9datKey length] == [aKey length] && [aKey hasPrefix : @"9"] && (NSOrderedDescending == [k9x9datKey compare : aKey]);
}

- (NSURL *) boardURL
{
	UTILAssertNotNil([self threadSignature]);
	return [[[BoardManager defaultManager] allKakoURLsForBoardName : [[self threadSignature] BBSName]] lastObject];
}


/*

HTMLâªÇ≥ÇÍÇΩâﬂãéÉçÉOÅF
--------------------------------
999999999 à»ëO
  http://mentai.2ch.net/mystery/kako/981/981536136.dat.gz
999999999 à»ç~
  http://pc3.2ch.net/tech/kako/1012/10125/1012544484.dat.gz

*/
- (NSURL *) resourceURL
{
	NSString	*key_;
	NSURL		*boardURL_;
	id			location_;
	
	UTILAssertNotNil([self threadSignature]);
	key_ = [[self threadSignature] identifier];
	if([key_ length] < [k9x9datKey length])
		return nil;
	
	if(lessThan9x9Key(key_))
		location_ = [NSString stringWithFormat : @"%@/%@",
						[key_ substringToIndex : 3],
						key_];
	else
		location_ = [NSString stringWithFormat : @"%@/%@/%@",
						[key_ substringToIndex : 4],
						[key_ substringToIndex : 5],
						key_];
	
	boardURL_ = [self boardURL];
	if(nil == boardURL_) return nil;
	
	location_ = [NSString stringWithFormat : @"%@kako/%@.dat.gz",
					[boardURL_ absoluteString],
					location_];
	
	UTILDescription(location_);
	return [NSURL URLWithString : location_];
}
@end
