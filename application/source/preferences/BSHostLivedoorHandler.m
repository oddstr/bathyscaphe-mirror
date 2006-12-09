/**
  * BSHostLivedoorHandler.m
  * BathyScaphe
  *
  * Written by Tsutomu Sawada on 06/12/09.
  * Copyright 2006 BathyScpahe Project. All rights reserved.
  */

#import "CMRHostHandler_p.h"
#import "CMXTextParser.h"

#define READ_URL_FORMAT_SHITARABA	@"%@/%@/%s/%@/"

@implementation BSHostLivedoorHandler
+ (BOOL) canHandleURL : (NSURL *) anURL
{
	const char *hostName_ = [[anURL host] UTF8String];
         if ( NULL == hostName_ ) return NO;
	return is_jbbs_shita( hostName_ );
}

- (NSDictionary *) properties
{
	return CMRHostPropertiesForKey(@"jbbs_livedoor");
}

- (NSURL *) boardURLWithURL : (NSURL    *) anURL
						bbs : (NSString *) bbs;
{
	NSString	*absolute_;
	NSArray		*paths_;
	
	paths_ = [[anURL path] pathComponents];
	if ([paths_ count] < 2)
		return nil;
	
	absolute_ = [NSString stringWithFormat :
					@"http://%@/%@/%@/",
					[anURL host],
					bbs,
					[paths_ objectAtIndex : 1]];
	
	return [NSURL URLWithString : absolute_];
}
- (NSString *) makeURLStringWithBoard : (NSURL *) boardURL datName : (NSString *) datName
{
	NSString		*absolute_;
	const char		*bbs_ = NULL;
	NSURL			*location_;
	NSDictionary	*properties_;
	
	UTILRequireCondition(boardURL && datName, ErrReadURL);

	location_ = [self readURLWithBoard:boardURL];
	UTILRequireCondition(location_, ErrReadURL);
	
	properties_ = [self readCGIProperties];
	UTILRequireCondition(properties_, ErrReadURL);
	
	CMRGetHostCStringFromBoardURL(boardURL, &bbs_);
	UTILRequireCondition(bbs_, ErrReadURL);

	absolute_ = [NSString stringWithFormat :
					READ_URL_FORMAT_SHITARABA,
					[location_ absoluteString],
					[[[boardURL path] pathComponents] objectAtIndex : 1],
					bbs_,
					datName];

	return absolute_;
ErrReadURL:
	return nil;
}

- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
{
	NSString		*absolute_;
	NSURL			*location_;

	absolute_ = [self makeURLStringWithBoard : boardURL datName : datName];
	UTILRequireCondition(absolute_, ErrReadURL);
	
	location_ = [NSURL URLWithString : absolute_];
	
	return location_;
	
ErrReadURL:
	return nil;
}

- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
				 latestCount : (int) count
{
	NSString	*base_;
	base_ = [self makeURLStringWithBoard : boardURL datName : datName];
	if (base_ == nil)
		return nil;

	return [NSURL URLWithString : [base_ stringByAppendingFormat : @"l%i", count]];
}

- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
				   headCount : (int) count
{
	NSString	*base_;
	base_ = [self makeURLStringWithBoard : boardURL datName : datName];
	if (base_ == nil)
		return nil;

	return [NSURL URLWithString : [base_ stringByAppendingFormat : @"-%i", count]];
}

- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
					   start : (unsigned  ) startIndex
					     end : (unsigned  ) endIndex
					 nofirst : (BOOL      ) nofirst
{
	id				tmp;
	NSURL			*location_;
	NSString		*base_;

	base_ = [self makeURLStringWithBoard : boardURL datName : datName];
	UTILRequireCondition(base_, ErrReadURL);
	tmp = SGTemporaryString();
	[tmp setString : base_];

	if (startIndex != NSNotFound)
		[tmp appendFormat : @"%u", startIndex];

	if (nofirst) {
			[tmp appendString : @"n-"];
	} else {
		[tmp appendString: @"-"];
	}
	
	
	if (endIndex != NSNotFound && endIndex != startIndex) {
		if (NSNotFound == startIndex)
			[tmp appendString : @"1-"];
		
		[tmp appendFormat : @"%u", endIndex];
	}
	location_ = [NSURL URLWithString : tmp];
	
	return location_;
	
ErrReadURL:
	return nil;
}

- (NSURL *) rawmodeURLWithBoard: (NSURL    *) boardURL
						datName: (NSString *) datName
						  start: (unsigned  ) startIndex
							end: (unsigned  ) endIndex
						nofirst: (BOOL      ) nofirst
{
	NSURL	*url_ = [self readURLWithBoard: boardURL datName: datName start: startIndex end: NSNotFound nofirst: nofirst];
	if (!url_) return nil;

	NSMutableString	*tmp = [[url_ absoluteString] mutableCopy];
	[tmp replaceOccurrencesOfString: @"read.cgi" withString: @"rawmode.cgi" options: NSLiteralSearch range: NSMakeRange(0, [tmp length])];
	
	NSURL	*newURL_ = [NSURL URLWithString: tmp];
	[tmp release];
	
	return newURL_;
}

#pragma mark HTML Parser
- (NSString *) convertObjectsToExtraFields: (NSArray *) components
{
    NSMutableString *tmp = [NSMutableString string];
    NSString    *idOrHost;

    [tmp appendString: [components objectAtIndex: 3]]; // Date

    idOrHost = [components objectAtIndex: 6]; // ID or HOST

    if (NO == [idOrHost isEqualToString: @""]) {
        unsigned length_ = [idOrHost length];

        [tmp appendString: (length_ < 11) ? @" ID:" : @" HOST:"];
        [tmp appendString: idOrHost];
    }
    
    return tmp;
}

- (void) addDatLine: (NSArray *) components with: (id) thread count: (unsigned) loadedCount
{
    unsigned actualIndex = [[components objectAtIndex: 0] intValue];

    if (actualIndex == 0) return;

	if (loadedCount != NSNotFound && loadedCount +1 != actualIndex) {
		unsigned	i;

        // 適当に行を詰める
        NSLog(@"Invisible Abone Occurred(%u)", actualIndex);
        for (i = loadedCount +1; i < actualIndex; i++) {
            [thread appendString : @"<><><><>\n"];
        }
    }

    NSString *extraFields = [self convertObjectsToExtraFields: components];

    NSString *tmp_ = [NSString stringWithFormat: @"%@<>%@<>%@<>%@<>\n",
                                                 [components objectAtIndex: 1],
                                                 [components objectAtIndex: 2],
                                                 extraFields,
                                                 [components objectAtIndex: 4]];

    [thread appendString: tmp_];
}

- (id) parseHTML : (NSString *) inputSource
			with : (id        ) thread
		   count : (unsigned  ) loadedCount
{
    NSArray *eachLineArray_ = [inputSource componentsSeparatedByString: @"\n"];
    NSEnumerator    *iter_ = [eachLineArray_ objectEnumerator];
    NSString        *eachLine_;
    BOOL            titleParsed_ = NO;
    unsigned        parsedCount = loadedCount;

NS_DURING
    while (eachLine_ = [iter_ nextObject]) {
        NSArray *components_ = [eachLine_ componentsSeparatedByString: @"<>"];
        /* sample
        レス番号<>名前<>メール欄<>日付<>本文<>スレタイ（最初のレスのみ）<>ID
        3<>名無しさん<><>2006/08/10(木) 23:36:41<>ぬるぽ<><>ZCWPDDtE
        */
        
        [self addDatLine: components_ with: thread count: parsedCount];
        
        if (NO == titleParsed_) {
            NSString *title_ = [components_ objectAtIndex: 5];
            if (NO == [title_ isEqualToString: @""]) {
		      NSRange		found;
		
		      found = [thread rangeOfString: @"\n"];
		      if (found.length != 0) {
			     [thread insertString: title_ atIndex: found.location];
		      }
            }
            titleParsed_ = YES;
        }
		
		parsedCount++;
    }
	
NS_HANDLER
	UTILCatchException(XmlPullParserException) {
		NSLog(@"***LOCAL_EXCEPTION***%@", localException);
		
	} else {
		[localException raise];
	}
NS_ENDHANDLER
	
	return thread;
}
@end
