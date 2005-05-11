//: SGHTTPSocketUtilities.h
/**
  * $Id: SGHTTPSocketUtilities.h,v 1.1.1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <unistd.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netdb.h>

//バッファのサイズ
#define BUF_SIZE				4096

/**
  * [関数 : fnc_portForURL]
  * NSURLインスタンスで指定された送信先から
  * ポート番号を取得。
  * 取得できなかった場合は標準的なポート番号
  * を返す。(ex: http -> 80)
  */
extern int fnc_portForURL(NSURL *theURL);

/**
  * [関数 : fnc_connect_socket]
  * 指定されたホスト、ポートへの接続を確立し、
  * ファイルデスクリプタを返す。
  */
extern int fnc_connect_socket(char *inHost, int inPort);

/**
  * [関数 : fnc_portForURL]
  * NSURLインスタンスで指定された送信先への
  * 接続を確立し、FileHandleを返す。
  */
extern NSFileHandle *fnc_fileHandleForURL(NSURL *theURL);
