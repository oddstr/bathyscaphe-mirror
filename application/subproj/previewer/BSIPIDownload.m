//
//  $Id: BSIPIDownload.m,v 1.1 2006/07/26 16:28:25 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/07/15.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIDownload.h"

@implementation BSIPIDownload
- (id) initWithURLIdentifier: (NSURL *) anURL
					delegate: (id) aDelegate
				 destination: (NSString *) aPath
{
	self = [super init];
	if (self != nil) {
		[self setDelegate: aDelegate];
		[self setURLIdentifier: anURL];
		[self setDestination: aPath];
		NSURLRequest *theRequest = [NSURLRequest requestWithURL : anURL];
		m_download  = [[NSURLDownload alloc] initWithRequest: theRequest delegate: self];
	}
	return self;
}

- (void) dealloc
{
	[m_download release];
	[m_URLIdentifier release];
	[m_downloadedFilePath release];
	[m_destination release];
	
	[super dealloc];
}

- (NSURL *) URLIdentifier
{
	return m_URLIdentifier;
}
- (void) setURLIdentifier: (NSURL *) anURL
{
	[anURL retain];
	[m_URLIdentifier release];
	m_URLIdentifier = anURL;
}

- (NSURLDownload *) URLDownload
{
	return m_download;
}


- (NSString *) downloadedFilePath
{
	return m_downloadedFilePath;
}
- (void) setDownloadedFilePath: (NSString *) aPath
{
	[aPath retain];
	[m_downloadedFilePath release];
	m_downloadedFilePath = aPath;
}

- (NSString *) destination
{
	return m_destination;
}
- (void) setDestination: (NSString *) aPath
{
	[aPath retain];
	[m_destination release];
	m_destination = aPath;
}

- (id) delegate
{
	return m_delegate;
}
- (void) setDelegate: (id) aDelegate
{
	m_delegate = aDelegate;
}

- (void) cancel
{
	[[self URLDownload] cancel];
}

#pragma mark NSURLDownload Delegate
- (void) download: (NSURLDownload *) dl didReceiveResponse: (NSURLResponse *) response
{
	lExLength = [response expectedContentLength];
	lDlLength = 0;

	if (lExLength != NSURLResponseUnknownLength) {
		if ([[self delegate] respondsToSelector: @selector(bsIPIdownload:willDownloadContentOfSize:)]) {
			[[self delegate] bsIPIdownload: self willDownloadContentOfSize: lExLength];
		}
	}
}

- (NSURLRequest *) download: (NSURLDownload *) download
			willSendRequest: (NSURLRequest *) request
		   redirectResponse: (NSURLResponse *) redirectResponse
{
	id delegate_ = [self delegate];

	if([delegate_ respondsToSelector: @selector(bsIPIdownload:didRedirectToURL:)]) {
		BOOL	shouldContinue = [delegate_ bsIPIdownload: self didRedirectToURL: [request URL]];
		if(NO == shouldContinue) {
			[download cancel];
			if ([delegate_ respondsToSelector: @selector(bsIPIdownloadDidAbortRedirection:)]) {
				[delegate_ bsIPIdownloadDidAbortRedirection: self];
			} else {
				[download release];
			}
		}
	}
	return request;
}

- (void) download: (NSURLDownload *) dl decideDestinationWithSuggestedFilename: (NSString *) filename
{
	NSString *savePath;
	savePath = [[self destination] stringByAppendingPathComponent : filename];

	[dl setDestination : savePath allowOverwrite : YES];
}

- (void) download: (NSURLDownload *) dl didCreateDestination: (NSString *) asDstPath
{
	[self setDownloadedFilePath : asDstPath];
}

- (void) download: (NSURLDownload *) dl didReceiveDataOfLength: (unsigned) len
{
	lDlLength += len;

	if (lExLength != NSURLResponseUnknownLength) {
		if ([[self delegate] respondsToSelector: @selector(bsIPIdownload:didDownloadContentOfSize:)]) {
			[[self delegate] bsIPIdownload: self didDownloadContentOfSize: lDlLength];
		}
	}
}

- (void) downloadDidFinish: (NSURLDownload *) dl
{
	if ([[self delegate] respondsToSelector: @selector(bsIPIdownloadDidFinish:)]) {
		[[self delegate] bsIPIdownloadDidFinish: self];
	} else {
		[dl release];
	}
}

- (void) download: (NSURLDownload *) dl didFailWithError: (NSError *) err
{
	if ([[self delegate] respondsToSelector: @selector(bsIPIdownload:didFailWithError:)]) {
		[[self delegate] bsIPIdownload: self didFailWithError: err];
	} else {
		[dl release];
	}
}
@end
