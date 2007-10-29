//
//  BSURLDownload.h
//  SGFoundation (BathyScaphe)
//
//  Created by Tsutomu Sawada on 07/10/27.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>

@interface BSURLDownload : NSObject {
	NSURL			*m_targetURL;
	NSURLDownload	*m_download;
	NSString		*m_downloadedFilePath;
	NSString		*m_destination;

	long long  lExLength;
	long long  lDlLength;
	
	id		m_delegate;
	BOOL	m_allowsOverwrite;
}

// Designated Initializer
- (id)initWithURL:(NSURL *)url delegate:(id)delegate destination:(NSString *)path;

- (NSURL *)URL;
- (NSURLDownload *)URLDownload;
- (NSString *)destination;
- (NSString *)downloadedFilePath;

- (void)cancel;

- (id)delegate;

- (BOOL)allowsOverwriteDownloadedFile;
- (void)setAllowsOverwriteDownloadedFile:(BOOL)flag;
@end


@interface NSObject(BSURLDownloadDelegate)
- (void)bsURLDownload:(BSURLDownload *)download willDownloadContentOfSize:(double)expectedLength;
- (void)bsURLDownload:(BSURLDownload *)download didDownloadContentOfSize:(double)downloadedLength;

- (void)bsURLDownloadDidFinish:(BSURLDownload *)download;

- (BOOL)bsURLDownload:(BSURLDownload *)download shouldRedirectToURL:(NSURL *)newURL;
- (void)bsURLDownload:(BSURLDownload *)download didAbortRedirectionToURL:(NSURL *)canceledURL;

- (void)bsURLDownload:(BSURLDownload *)download didFailWithError:(NSError *)error;
@end
