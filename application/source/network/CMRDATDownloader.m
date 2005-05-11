//: CMRDATDownloader.m
/**
  * $Id: CMRDATDownloader.m,v 1.1.1.1 2005/05/11 17:51:06 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRDATDownloader.h"
#import "ThreadTextDownloader_p.h"
#import "CMRServerClock.h"
#import "CMRHostHandler.h"



// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"


/*
 * (obsolute)
 *
 * �_�E�����[�h����dat�ɂ͕����ł��Ȃ��f�[�^���܂܂�Ă���ꍇ������̂ŁA
 * �������փe�L�X�g�ɒu������������ɕϊ����邩�H
 */
#define REPLACE_IVALID_CHARS		0



@implementation CMRDATDownloader
+ (BOOL) canInitWithURL : (NSURL *) url
{
	CMRHostHandler	*handler_;
	
	handler_ = [CMRHostHandler hostHandlerForURL : url];
	return handler_ ? [handler_ canReadDATFile] : NO;
}

- (NSURL *) threadURL
{
	CMRHostHandler	*handler_;
	
	UTILAssertNotNil([self threadSignature]);
	
	handler_ = [CMRHostHandler hostHandlerForURL : [self boardURL]];
	return [handler_ readURLWithBoard:[self boardURL] datName:[[self threadSignature] identifier]];
}
- (NSURL *) resourceURL
{
	CMRHostHandler	*handler_;
	
	UTILAssertNotNil([self threadSignature]);
	handler_ = [CMRHostHandler hostHandlerForURL : [self boardURL]];
	return [handler_ datURLWithBoard:[self boardURL] datName:[[self threadSignature] datFilename]];
}
@end



@implementation CMRDATDownloader(PrivateAccessor)
- (void) setupRequestHeaders : (NSMutableDictionary *) mdict
{
	[super setupRequestHeaders : mdict];
	
	
	if ([self pertialContentsRequested]) {
		NSNumber	*byteLenNum_;
		NSDate		*lastDate_;
		int			bytelen;
		NSString	*rangeString;
		
		byteLenNum_ = [[self localThreadsDict] objectForKey : ThreadPlistLengthKey];
		UTILAssertNotNil(byteLenNum_);
		lastDate_ = [[self localThreadsDict] objectForKey : CMRThreadModifiedDateKey];
		
		// 
		// 808 ���O�F ��aO521.mOts [sage] ���e���F03/01/20 22:35 ID:2nm5Rwqc
		// �@�@>>806
		// �@�@�����A�܂�͍��܂ł̎I�ł�gzip�������Ď擾���鎞��
		// �@�@Range: Start-End���ɂ�gzip�ň��k����Ă��Ȃ����̃o�C�g����
		// �@�@�͈͎w�肵�č����擾����񂾂��ǁA
		// �@�@music2��society��gzip���k��̃T�C�Y�ł̃o�C�g����
		// �@�@Range: Start-End���w�肷�邩�A�܂��͍��܂ł̗l�Ȏw��̎d�������鎞��
		// �@�@AcceptEncoding gzip ��ʂ�����Request���Ȃ��Ⴂ���Ȃ��Ƃ��������ȁB
		// 
		// �@�@�o�O���Ӑ}�I���͕�����񂯂ǁA���ꂵ�ė~�����Ƃ���ł��ˁB
		// �@�@�ł��ˑR�܂��ύX����Ă�����Ƃ����E�E�E�i��
		// 
		[mdict removeObjectForKey : HTTP_ACCEPT_ENCODING_KEY];
		
		// 
		// �������擾���邽�߂Ɏ擾�ς݂̃f�[�^�ʂ�
		// ���߁A���M����B
		// �O��擾�������̃f�[�^�͉��s(\n)�ŏI����Ă���͂��Ȃ̂ŁA
		// �����ŗ]����1�o�C�g�擾����悤�ɐݒ肵�A
		// URLHandle:resourceDataDidBecomeAvailable:
		// �ŁA�擾����1�o�C�g�ڂ����s(\n)�łȂ���΃G���[
		// 
		bytelen = [byteLenNum_ intValue];
		bytelen -= 1;
		rangeString = [NSString stringWithFormat:@"bytes=%d-", bytelen];
		[mdict setNoneNil : rangeString
				   forKey : HTTP_RANGE_KEY];
		
		// �O��Adat���擾���Ă���ꍇ��"If-Modified-Since"�w�b�_
		// ��ǉ�����B
		[mdict setNoneNil : [lastDate_ descriptionAsRFC1123]
				   forKey : HTTP_IF_MODIFIED_SINCE_KEY];
	}
}

@end



@implementation CMRDATDownloader(w2chConnectDelegate)
// ----------------------------------------
// Partial contents
// ----------------------------------------
- (void) handlePartialContentsCheck_ : (SGHTTPConnector *) theConnect
{
	SGHTTPResponse	*res = [theConnect response];
	NSData			*avail = [theConnect availableResourceData];
	const char		*p = NULL;
	
	UTIL_DEBUG_METHOD;
	UTIL_DEBUG_WRITE1(@"  dataLength:%u", [avail length]);
	if (nil == res) {	// why?
		NSLog(
			@"%@ called, but server response was nil.",
			UTIL_HANDLE_FAILURE_IN_METHOD);
		return;
	}
	
	switch ([res statusCode]) {
	case HTTP_PERTIAL:
		break;
	case HTTP_NOT_MODIFIED:
		return;
		break;
	case HTTP_RANGE_NOT_SATISFIABLE:  /* Requested Range Not Satisfiable */
		NSLog(@"Server Response: %@", [res statusLine]);
		[self cancelDownloadWithInvalidPartial];
		return;
		break;
	default:
		NSLog(@"Unexpected status:%u", [res statusCode]);
		return;
		break;
	}
	
	// check terminater
	if (nil == avail || 0 == [avail length])
		return;
	
	p = (const char*)[avail bytes];
	if (*p != '\n') {
		NSLog(@"Last terminater must be %c, but was %c.", '\n', *p);
		[self cancelDownloadWithInvalidPartial];
	}
}
- (void) URLHandle               : (NSURLHandle *) sender
  resourceDataDidBecomeAvailable : (NSData      *) newBytes
{
	[super URLHandle:sender resourceDataDidBecomeAvailable:newBytes];
	
	if ([self pertialContentsRequested]) {
		[self handlePartialContentsCheck_ : [self HTTPConnectorCastURLHandle : sender]];
	}
}
@end



@implementation CMRDATDownloader(LoadingResourceData)
- (void) updateLastAccessedDate : (NSURLHandle *) connector
{
	NSString			*lastReqDate_str_;
	NSDate				*lastReqDate_;
	
	// �ŏI�A�N�Z�X����
	lastReqDate_str_ = [[[self currentConnector] response] 
				headerFieldValueForKey : HTTP_DATE_KEY];
	lastReqDate_ = [NSCalendarDate dateWithHTTPTimeRepresentation : lastReqDate_str_];
	[[CMRServerClock sharedInstance] 
		setLastAccessedDate : lastReqDate_
					 forURL : [self resourceURL]];
}

- (BOOL) dataProcess : (NSData      *) resourceData
       withConnector : (NSURLHandle *) connector
{
	SGHTTPConnector		*HTTPConnector_;
	NSData				*ungzipped_;
	NSString			*datContents_;
	unsigned			contentLength_;
	
	[self updateLastAccessedDate : connector];
	
	HTTPConnector_ = (SGHTTPConnector *)connector;
	
	// ----------------------------------------
	// �X�V���ꂽ�������폜���ꂽ��������������
	// �T�[�o����e���ꂽ�̂�������Ȃ�
	// ----------------------------------------
	if (nil == resourceData || 0 == [resourceData length]) {
		if (0 == [[HTTPConnector_ response] statusCode]) {
/*
			[HTTPConnector_ removeClient : self];
			[self setCurrentConnector : nil];
			UTILNotifyName(ThreadTextDownloaderInvalidPerticalContentsNotification);
*/
		}
		return NO;
	}
	
	ungzipped_ = SGUtilUngzipIfNeeded(resourceData);
	if (nil == ungzipped_ || 0 == [ungzipped_ length])
		return NO;
	
	// ----------------------------------------
	// �ŏI�`�F�b�N
	// ----------------------------------------
	if ([self shouldCancelWithFirstArrivalData : ungzipped_]) {
		UTILNotifyName(CMRDownloaderNotFoundNotification);
		return NO;
	}
	
	
	
	datContents_ = [self contentsWithData : ungzipped_];
	contentLength_ = [HTTPConnector_ readContentLength];
	
	return [self synchronizeLocalDataWithContents : datContents_
	                                   dataLength : [ungzipped_ length]];
}



#if REPLACE_IVALID_CHARS

struct Invalid_bytes_t {
	char	*oldBytes;
	char	*newBytes;
};

// �s���ȃo�C�g��
static struct Invalid_bytes_t kInvalidBytes[] = {
	{ "\x88\x0a", "?\xa"}, 
	{ "\xa0\xa0", "  "}, 
	{ "\xfe", " "}, 	/* assume that don't receieve BOM */
	{NULL, NULL}
};



#define kDecodeFailedStr			@"?>"
#define kDecodeFailedReplacement	@" <>"
static void print_as_hex_values_(const unsigned char *s)
{
	for (; *s != '\0'; s++)
		fprintf(stderr, "0x%x ", (*s));
}

- (NSString *) contentsWithData : (NSData *) theData
{
	NSString			*contents_;
	NSData				*data_	= theData;
	
	NSMutableData			*tmp = nil;
	const char				*bytes_ = [data_ bytes];
	size_t					length_ = [data_ length];
	struct Invalid_bytes_t	*p;
	
	if (nil == theData || 0 == [theData length]) return nil;
	if ([self CFEncodingForLoadedData] != kCFStringEncodingDOSJapanese) {
		return [super contentsWithData : theData];
	}
	
	for (p = kInvalidBytes; p->oldBytes != NULL; p++) {
		void	*mp, *found;
		
	#if UTIL_DEBUGGING
		fprintf(stderr, "  Check the invalid bytes sequence: ");
		print_as_hex_values_(p->oldBytes);
		fprintf(stderr, " --> ");
		print_as_hex_values_(p->newBytes);
		fprintf(stderr, "\n");
	#endif
		
		if (nsr_strnstr((char*)bytes_, p->oldBytes, length_)) {
			UTIL_DEBUG_WRITE(@" found...");
			
			if (nil == tmp) {
				tmp = [[data_ mutableCopy] autorelease];
				bytes_ = [tmp bytes];
				length_ = [tmp length];
			}
			mp = [tmp mutableBytes];
			while (found = nsr_strnstr(mp, p->oldBytes, length_)) {
				size_t	inc = (UInt8*)found - (UInt8*)mp;
				
				UTIL_DEBUG_WRITE1(@" found at character:%u.",
					(UInt8*)found - (UInt8*)[tmp mutableBytes]);
				
				memmove(found,
						p->newBytes,
						strlen(p->newBytes));
				
				inc = (UInt8*)found - (UInt8*)mp + strlen(p->newBytes);
				if (length_ <= inc)
					break;
				
				length_ -= inc;
				mp += inc;
			}
			
			bytes_ = [tmp bytes];
			length_ = [tmp length];
		}
	}
	if (tmp != nil) {
		data_ = tmp;
	}

	contents_ = [super contentsWithData : data_];
	if (nil == contents_) return nil;
	
	if ([contents_ containsString : kDecodeFailedStr]) {
		NSMutableString		*ms_;
		
		ms_ = SGTemporaryString();
		[ms_ setString : contents_];
		
		[ms_ replaceCharacters : kDecodeFailedStr
					  toString : kDecodeFailedReplacement
					   options : NSLiteralSearch];
		
		contents_ = [[ms_ copy] autorelease];
		[ms_ setString : @""];
	}
	return contents_;
}
#endif

@end


