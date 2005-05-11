//: SGHTTPStream.m
/**
  * $Id: SGHTTPSecureSocket.m,v 1.1.1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <SGNetwork/SGHTTPSecureSocket.h>
#import <SGNetwork/SGHTTPRequest.h>
#import <SGNetwork/SGHTTPResponse.h>
#import <SGNetwork/SGHTTPSocketUtilities.h>

#import <stdio.h>
#import <string.h>
#import <sys/types.h>
#import <sys/uio.h>

/* openSSL */
#import <openssl/crypto.h>
#import <openssl/x509.h>
#import <openssl/pem.h>
#import <openssl/ssl.h>
#import <openssl/err.h>



@implementation SGHTTPSecureSocket
- (NSData *) loadInForeground
{
	auto   int			err;
	auto   int			s;
	struct hostent		*servhost; 
	struct sockaddr_in	server;
	
	SSL_CTX	*ctx;
	SSL		*ssl;
	X509	*server_cert;
	char	*str;

	NSURL         *requestURL_;			// url
	NSData        *serialized_;			// send
	NSMutableData *resourceData_;		// received
	
	[self setStatus : NSURLHandleLoadInProgress];
	if (nil == [self request]) {
		[self setStatus : NSURLHandleLoadFailed];
		return nil;
	}
	
	requestURL_   = [[self request] requestURL];
	resourceData_ = [NSMutableData data];
	
	servhost = gethostbyname([[requestURL_ host] cString]);
	if ( servhost == NULL ) {
		fprintf(stderr, 
				"[%s] fail get IP Address\n", 
				[[requestURL_ host] cString]);
		return nil;
	}
	
	bzero((char *)&server, sizeof(server));
	server.sin_family = AF_INET;
	bcopy(servhost->h_addr, (char *)&server.sin_addr, servhost->h_length);
	/* ポート番号取得 */
	server.sin_port = fnc_portForURL(requestURL_);
	
	
	s = socket(AF_INET, SOCK_STREAM, 0); 
	if ( s < 0 ) {
		[self setStatus : NSURLHandleLoadFailed];
		return nil;
	}
	if ( connect(s, (struct sockaddr*) &server, sizeof(server)) == -1 ) {
		[self setStatus : NSURLHandleLoadFailed];
		return nil;
	}
	
	/*** SSL fase ***/
	SSL_load_error_strings(); 
	SSL_library_init(); 
	ctx = SSL_CTX_new(SSLv2_client_method()); 
	ssl = SSL_new(ctx);
	SSL_set_fd(ssl, s);
	err = SSL_connect(ssl);
	//printf("  Crypto = %s \n", SSL_get_cipher(ssl));
	server_cert = SSL_get_peer_certificate(ssl); 
	//printf("Server certificate:\n");
	str = X509_NAME_oneline(X509_get_subject_name(server_cert), 0, 0);
	//printf("   subject: %s\n", str);
	str = X509_NAME_oneline(X509_get_issuer_name(server_cert), 0, 0);
	//printf("   issuer: %s\n", str);
	X509_free(server_cert);
	/* リクエストを送る */
	serialized_ = [[self request] serializedMessage];
	
	err = SSL_write(ssl,
				    [serialized_ bytes],
					[serialized_ length]);

	/* reply from web server */
	while (1) {
		UInt8	buffer[BUF_SIZE];
		int		bytesRead;
		
		bytesRead = SSL_read(ssl, buffer, BUF_SIZE);
		if (bytesRead <= 0) {
			break;
		}
		[resourceData_ appendBytes : buffer
						    length : bytesRead];
	}
	
	SSL_shutdown(ssl); 
	close(s);
	SSL_free(ssl); 
	SSL_CTX_free(ctx);
	
	// done
	[self setStatus : NSURLHandleLoadSucceeded];
	[self setResponse : [SGHTTPResponse emptyResponse]];
	if (NO == [[self response] appendBytes : resourceData_]) {
		return nil;
	}
	
	return [[self response] body];
}

/*** NOT IMPEMENTED YET ***/
- (void) loadInBackground 
{ NSAssert(1, @"Not Implemented. Use -loadInForeground"); }
@end
