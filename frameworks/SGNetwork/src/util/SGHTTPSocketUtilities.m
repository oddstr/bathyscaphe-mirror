//: SGHTTPSocketUtilities.m
/**
  * $Id: SGHTTPSocketUtilities.m,v 1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <SGNetwork/SGHTTPSocketUtilities.h>

//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
//Scheme
static NSString *const st_http_scheme = @"http";
static NSString *const st_https_scheme = @"https";
static NSString *const st_ftp_scheme = @"ftp";

//標準のポート番号
#define DEFAULT_HTTP_PORT		80
#define DEFAULT_HTTPS_PORT		443
#define DEFAULT_FTP_PORT		21

/**
  * [関数 : fnc_portForURL]
  * NSURLインスタンスで指定された送信先から
  * ポート番号を取得。
  * 取得できなかった場合は標準的なポート番号
  * を返す。(ex: http -> 80)
  */
int fnc_portForURL(NSURL *theURL)
{
	struct		servent *se;
	int			port;
	
	if(nil == theURL)
		return 0;
	
	// ポート番号を取得
	port = [[theURL port] intValue];
	if(port == 0){
		NSString *scheme_;
		
		scheme_ = [theURL scheme];
		// NSURLからポート番号が取得できなかった場合
		if((se = getservbyname([scheme_ cString], NULL)) == NULL){
			// ポート番号が分からない場合はデフォルト
			if([scheme_ isEqualToString : st_http_scheme])
				port = DEFAULT_HTTP_PORT;
			else if([scheme_ isEqualToString : st_https_scheme])
				port = DEFAULT_HTTPS_PORT;
			else if([scheme_ isEqualToString : st_ftp_scheme])
				port = DEFAULT_FTP_PORT;
			else
				port = 0;
		} else {
			port = se->s_port;
		}
	}
	return port;
}

/**
  * [関数 : fnc_connect_socket]
  * 指定されたホスト、ポートへの接続を確立し、
  * ファイルデスクリプタを返す。
  */
int fnc_connect_socket(char *inHost, int inPort)
{
	struct sockaddr_in	addr;
	struct hostent *host;
	int s;

	if ((host = gethostbyname(inHost)) == NULL)
		return -1;

	memset(&addr, 0, sizeof(addr));

	addr.sin_family = AF_INET;
	addr.sin_port = htons(inPort);

	memcpy(&addr.sin_addr, host->h_addr, host->h_length);

	if((s = socket(AF_INET, SOCK_STREAM, 0)) < 0)
		return s;

	if((connect(s, (struct sockaddr*)&addr, sizeof(addr))) != 0) {
		close(s);
		return -1;
	}
	return s;
}

/**
  * [関数 : fnc_portForURL]
  * NSURLインスタンスで指定された送信先への
  * 接続を確立し、FileHandleを返す。
  */
NSFileHandle *fnc_fileHandleForURL(NSURL *theURL)
{
	char *host_;			//ホスト
	int   port_;			//ポート番号
	int   descriptor_;		//ファイルデスクリプタ
	
	if(nil == theURL) return nil;
	
	port_ = fnc_portForURL(theURL);
	host_ = (char *)[[theURL host] cString];
	
	// ホストが見つからなかった場合
	if((descriptor_ = fnc_connect_socket(host_, port_)) <= 0){
		return nil;
	}

	return [[[NSFileHandle alloc] initWithFileDescriptor:descriptor_ closeOnDealloc:YES]
			autorelease];
}

