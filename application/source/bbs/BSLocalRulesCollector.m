//
//  BSLocalRulesCollector.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/11.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSLocalRulesCollector.h"
#import "CocoMonar_Prefix.h"
#import "BoardManager.h"
#import "CMRDocumentFileManager.h"

NSString *const BSLocalRulesCollectorErrorDomain = @"jp.tsawada2.BathyScaphe.BSLocalRulesCollector";
static NSString *const kInsertionPointMarker = @"%%%HEAD_TXT_CONTENT%%%";

@interface BSLocalRulesCollector(Private)
- (void)setBoardName:(NSString *)boardName;
- (void)setLocalRulesAttrString:(NSAttributedString *)attrString;
- (void)setLastDate:(NSDate *)date;

- (NSURLConnection *)currentConnection;
- (void)setCurrentConnection:(NSURLConnection *)connection;

- (void)setIsLoading:(BOOL)flag;
- (void)setLastError:(NSError *)error;

- (void)loadFromContentsOfFile;
- (void)startDownloadingHeadTxt;
- (NSAttributedString *)attrStringFromReceivedData;
@end


@implementation BSLocalRulesCollector
+ (NSString *)templateFilePath
{
	return [[NSBundle mainBundle] pathForResource:@"LocalRulesTemplate" ofType:@"html"];
}

- (NSString *)cacheFilePath
{
	NSString *folderPath = [[CMRDocumentFileManager defaultManager] directoryWithBoardName:[self boardName]];
	return [folderPath stringByAppendingPathComponent:BSLocalRulesRTFFileName];
}

- (id)initWithBoardName:(NSString *)boardName
{
	if (self = [super init]) {
		BOOL	isDir;
		NSAttributedString *dummyAttrStr = [[NSAttributedString alloc] initWithString:@" "];
		[self setLocalRulesAttrString:dummyAttrStr];
		[dummyAttrStr release];
		[self setBoardName:boardName];

		if ([[NSFileManager defaultManager] fileExistsAtPath:[self cacheFilePath] isDirectory:&isDir] && !isDir) {
			[self loadFromContentsOfFile];
		} else {
			[self startDownloadingHeadTxt];
		}
	}
	return self;
}

- (void)dealloc
{
	[m_receivedData release];
	m_receivedData = nil;

	[self setLastDate:nil];
	[self setLocalRulesAttrString:nil];
	[self setLastError:nil];
	[self setCurrentConnection:nil];
	[self setBoardName:nil];

	[super dealloc];
}

- (NSURL *)boardURL
{
	return [[BoardManager defaultManager] URLForBoardName:[self boardName]];
}

- (void)cancelDownloading
{
	[[self currentConnection] cancel];
}

- (void)reload
{
	if (m_receivedData) {
		[m_receivedData release];
		m_receivedData = nil;
	}

	[self setLastError:nil];
	[self startDownloadingHeadTxt];
}

- (NSString *)boardName
{
	return m_boardName;
}

- (NSAttributedString *)localRulesAttrString
{
	return m_localRulesAttrString;
}

- (NSDate *)lastDate
{
	return m_lastDate;
}

- (BOOL)isLoading
{
	return m_isLoading;
}

- (NSError *)lastError
{
	return m_lastError;
}

#pragma mark NSURLConnection Delegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	if (!redirectResponse) return request;

	[connection cancel];
	[self setCurrentConnection:nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Can't get head.txt", @"") forKey:NSLocalizedDescriptionKey];
	NSError *error = [NSError errorWithDomain:BSLocalRulesCollectorErrorDomain code:[(NSHTTPURLResponse *)redirectResponse statusCode] userInfo:dict];
	[self setLastError:error];
	[self setIsLoading:NO];
	return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)resp
{
    NSHTTPURLResponse *http = (NSHTTPURLResponse *)resp;
	int status = [http statusCode];

    switch (status) {
    case 200:
        break;
    default:
		[connection cancel];
		[self setCurrentConnection:nil];
		NSDictionary *dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Can't get head.txt", @"") forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:BSLocalRulesCollectorErrorDomain code:status userInfo:dict];
		[self setLastError:error];
		[self setIsLoading:NO];
        break;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [m_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self setCurrentConnection:nil];
	[self setLastError:error];
	[self setIsLoading:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSAttributedString *attrStr;

	[self setLastDate:[NSDate date]];
    [self setCurrentConnection:nil];

	attrStr = [self attrStringFromReceivedData];
	if (attrStr) {
		[self setLocalRulesAttrString:attrStr];
		[self setLastError:nil];
	} else {
		NSDictionary *dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Can't get head.txt", @"") forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:BSLocalRulesCollectorErrorDomain code:BSLocalRulesCollectorErrorCannotCreateAttrString userInfo:dict];
		[self setLastError:error];
	}
	[self setIsLoading:NO];
}
@end


@implementation BSLocalRulesCollector(Private)
- (void)setBoardName:(NSString *)boardName
{
	[boardName retain];
	[m_boardName release];
	m_boardName = boardName;
}

- (void)setLocalRulesAttrString:(NSAttributedString *)attrString
{
	[attrString retain];
	[m_localRulesAttrString release];
	m_localRulesAttrString = attrString;
}

- (void)setLastDate:(NSDate *)date
{
	[date retain];
	[m_lastDate release];
	m_lastDate = date;
}

- (NSURLConnection *)currentConnection
{
	return m_currentConnection;
}

- (void)setCurrentConnection:(NSURLConnection *)connection
{
	[connection retain];
	[m_currentConnection release];
	m_currentConnection = connection;
}

- (void)setIsLoading:(BOOL)flag
{
	m_isLoading = flag;
}

- (void)setLastError:(NSError *)error
{
	[error retain];
	[m_lastError release];
	m_lastError = error;
}

- (void)loadFromContentsOfFile
{
	NSAttributedString	*attrStr;
	NSDictionary		*docAttrs = [NSDictionary dictionary];
	[self setIsLoading:YES];

	attrStr = [[NSAttributedString alloc] initWithPath:[self cacheFilePath] documentAttributes:&docAttrs];
	
	if (!attrStr) {
//		NSDictionary *dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Can't get head.txt 3", @"") forKey:NSLocalizedDescriptionKey];
//		NSError *error = [NSError errorWithDomain:BSLocalRulesCollectorErrorDomain code:BSLocalRulesCollectorErrorCannotReadFile userInfo:dict];
//		[self setLastError:error];
		[self startDownloadingHeadTxt];
		return;
	} else {
		if ([docAttrs objectForKey:NSCreationTimeDocumentAttribute]) [self setLastDate:[docAttrs objectForKey:NSCreationTimeDocumentAttribute]];
		[self setLocalRulesAttrString:attrStr];
		[attrStr release];
	}
	[self setLastError:nil];
	[self setIsLoading:NO];
}

- (NSURLRequest *)requestForDownloadingHeadTxt
{
	NSURL	*url = [NSURL URLWithString:BSHeadTextFileName relativeToURL:[self boardURL]];
	NSMutableURLRequest	*request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];

	[request setValue:[NSBundle monazillaUserAgent] forHTTPHeaderField:@"User-Agent"];
//	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

	return request;
}

- (void)startDownloadingHeadTxt
{
	NSURLConnection *connection;

	m_receivedData = [[NSMutableData alloc] init];

    connection = [[NSURLConnection alloc] initWithRequest:[self requestForDownloadingHeadTxt] delegate:self];
	[self setCurrentConnection:connection];
	[connection release];
	[self setIsLoading:YES];
}

// Mac OS X 10.4 以降限定にすれば定数が使えるのになぁ… 10.3 のために仕方なく
- (NSDictionary *)optionsDict
{
	NSArray *keys = [NSArray arrayWithObjects:@"BaseURL"/*NSBaseURLDocumentOption*/, @"DocumentType"/*NSDocumentTypeDocumentOption*/, 
											 @"CharacterEncoding"/*NSCharacterEncodingDocumentOption*/, @"UseWebKit"/*Tiger 以降では不要*/, nil];
	NSArray *values = [NSArray arrayWithObjects:[self boardURL], NSHTMLTextDocumentType,
											[NSNumber numberWithUnsignedInt:NSShiftJISStringEncoding], [NSNumber numberWithBool:YES], nil];
	return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

- (NSMutableString *)templateFromFile
{
	return [NSMutableString stringWithContentsOfFile:[[self class] templateFilePath]
											encoding:NSShiftJISStringEncoding
											   error:NULL];
}

- (NSString *)insertHeadTxtString:(NSData *)data intoString:(NSMutableString *)template
{
	NSRange range = [template rangeOfString:kInsertionPointMarker options:NSLiteralSearch];
	if (range.location == NSNotFound) return nil;

	NSString *content = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
	[template replaceCharactersInRange:range withString:content];
	[content release];

	return [NSString stringWithString:template];
}

- (NSAttributedString *)attrStringFromReceivedData
{
	NSString			*src = nil;
	NSAttributedString	*attrStr = nil;

	if (!m_receivedData || [m_receivedData length] == 0) return nil;
	
	src = [self insertHeadTxtString:m_receivedData intoString:[self templateFromFile]];

	if (!src) return nil;

	NSData *finalData = [src dataUsingEncoding:NSShiftJISStringEncoding];

	attrStr = [[NSAttributedString alloc] initWithHTML:finalData options:[self optionsDict] documentAttributes:NULL];
	
	if (!attrStr) return nil;
	NSDictionary  *docAttr = [NSDictionary dictionaryWithObjectsAndKeys:[self lastDate],
		@"NSCreationTimeDocumentAttribute"/*NSCreationTimeDocumentAttribute*/,
		[NSString stringWithFormat:NSLocalizedString(@"DocTitleAttributeTemplate", nil), [self boardName]],
		@"NSTitleDocumentAttribute"/*NSTitleDocumentAttribute*/,
		NULL];
	NSData *data = [attrStr RTFFromRange:NSMakeRange(0, [attrStr length]) documentAttributes:docAttr];
	[data writeToFile:[self cacheFilePath] atomically:YES];
	return [attrStr autorelease];
}
@end
